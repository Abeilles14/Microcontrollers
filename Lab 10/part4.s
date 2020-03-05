//THIS CODE IS COPIED FROM "interrupt_examples.s"
.include    "address_map_arm.s" 
.include    "interrupt_ID.s" 

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly language code.
 * The program responds to interrupts from the pushbutton KEY port in the FPGA.
 *
 * The interrupt service routine for the pushbutton KEYs indicates which KEY has
 * been pressed on the LED display.
 ********************************************************************************/

.section    .vectors, "ax" 

            B       _start                  // reset vector
            B       SERVICE_UND             // undefined instruction vector
            B       SERVICE_SVC             // software interrrupt vector
            B       SERVICE_ABT_INST        // aborted prefetch vector
            B       SERVICE_ABT_DATA        // aborted data vector
.word       0 // unused vector
            B       SERVICE_IRQ             // IRQ interrupt vector
            B       SERVICE_FIQ             // FIQ interrupt vector

.text    
.global RUNPG0
.global RUNPG1
.global TICK
TICK:
	.word 0x0
.extern TICK

.global count 
count:
	.word 0x0

.global CURRENT_PID
CURRENT_PID:
	.word 0

.global CHAR_BUFFER
CHAR_BUFFER:
	.word 0x0

.global CHAR_FLAG
CHAR_FLAG:
	.word 0x0
.global PROC1
.global PD_ARRAY
PD_ARRAY:
	.fill 17,4,0xDEADBEEF
	.fill 13,4,0xDEADBEE1
	.word 0x3F000000 // SP
	.word 0 // LR
	.word PROC1+4 // PC
	.word 0x53 // CPSR (0x53 means IRQ enabled, mode = SVC)

.global MPCORE_ISR
.global JTAG_URAT_ISR
.global PUT_JTAG
.global END_PUT
.global     _start 
_start:                                     
/* Set up stack pointers for IRQ and SVC processor modes */
            MOV     R1, #0b11010010         // interrupts masked, MODE = IRQ
            MSR     CPSR_c, R1              // change to IRQ mode
            LDR     SP, =A9_ONCHIP_END - 3  // set IRQ stack to top of A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
            MOV     R1, #0b11010011         // interrupts masked, MODE = SVC
            MSR     CPSR, R1                // change to supervisor mode
            LDR     SP, =DDR_END - 3        // set SVC stack to top of DDR3 memory

            BL      CONFIG_GIC              // configure the ARM generic interrupt controller

                                            // write to the pushbutton KEY interrupt mask register
            LDR     R0, =KEY_BASE           // pushbutton KEY base address
            MOV     R1, #0xF               // set interrupt mask bits
            STR     R1, [R0, #0x8]          // interrupt mask register is (base + 8)

                                            // enable IRQ interrupts in the processor
            MOV     R0, #0b01010011         // IRQ unmasked, MODE = SVC
            MSR     CPSR_c, R0              

			//code from DE1-SoC computer manual page 5
			LDR R0, =MPCORE_PRIV_TIMER
			LDR R1, =100000000 // timeout = 1/(200 MHz) x 100×10^6 = 0.5 sec
			STR R1, [R0] // write to timer load register
			MOV R3, #0b111 // set bits:interrupt=1, mode = 1 (auto), enable = 1
			STR R3, [R0, #0x8] // write to timer control register

			LDR R0, =JTAG_UART_BASE
			MOV R2, #0b00000000
			STR R2, [R0]
			MOV R2, #0b00000001
			STR R2, [R0, #0x4]

			/*LDR R0, =count
			MOV R1,#0
			STR R1, [R0]*/


IDLE:       
			LDR R1,=CHAR_FLAG
			LDR R0,[R1]
			CMP R0,#1
			BNE IDLE
			LDR R2,=CHAR_BUFFER
			LDR R0,[R2]
			BL PUT_JTAG
			LDR R1,=CHAR_FLAG
			MOV R2, #0
			STR R2,[R1]
            B       IDLE                    // main program simply idles
PROC1:
	LDR R0, =count
	LDR R1, [R0]

	MOV R3,#255   //large_number
	ADD R1, R1, #1
	STR R1, [R0]
	LDR R2,=LEDR_BASE
	STR R1,[R2]
	MOV R2, #0
LOOP2:
	ADD R2, R2,#1
	CMP R2, R3
	BLT LOOP2
	B PROC1


/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:                                
            B       SERVICE_UND             

/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:                                
            B       SERVICE_SVC             

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:                           
            B       SERVICE_ABT_DATA        

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:                           
            B       SERVICE_ABT_INST        

/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:                                
            PUSH    {R0-R7, LR}             

/* Read the ICCIAR from the CPU interface */
            LDR     R4, =MPCORE_GIC_CPUIF   
            LDR     R5, [R4, #ICCIAR]       // read from ICCIAR
			CMP		R5, #80
			BEQ		JTAG_URAT_ISR
			CMP		R5, #29
			BNE		FPGA_IRQ1_HANDLER


			BL		MPCORE_ISR
			B		EXIT_IRQ

FPGA_IRQ1_HANDLER:                          
            CMP     R5, #KEYS_IRQ           
UNEXPECTED: BNE     UNEXPECTED              // if not recognized, stop here

            BL      KEY_ISR                 
EXIT_IRQ:                                   
/* Write to the End of Interrupt Register (ICCEOIR) */
            STR     R5, [R4, #ICCEOIR]      // write to ICCEOIR

            POP     {R0-R7, LR}             
            SUBS    PC, LR, #4              

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:                                
            B       SERVICE_FIQ             


//Code from DE1-SoC computer manual page 28
MPCORE_ISR: 
	LDR		R0,=0xFFFEC600
	LDR		R1,=TICK
	LDR		R3,=CURRENT_PID
	LDR		R4,[R3]
	LDR		R2,[R1]
	ADD		R2, R2, #1
	STR		R2, [R1] // ++tick


	LDR		R0,=PD_ARRAY
	CMP		R4,#0
	BEQ		RUNPG1
RUNPG0:
	STR R8, [R0,#32]
	STR R9, [R0,#36]
	STR R10, [R0,#40]
	STR R11, [R0,#44]
	STR R12, [R0,#48]
	LDR R11, [SP,#0]
	STR R11, [R0,#0]
	LDR R11, [SP,#4]
	STR R11, [R0,#4]
	LDR R11, [SP,#8]
	STR R11, [R0,#8]
	LDR R11, [SP,#12]
	STR R11, [R0,#12]
	LDR R11, [SP,#16]
	STR R11, [R0,#16]
	LDR R11, [SP,#20]
	STR R11, [R0,#20]
	LDR R11, [SP,#24]
	STR R11, [R0,#24]
	LDR R11, [SP,#28]
	STR R11, [R0,#28]
	LDR R11, [SP,#32]
	STR R11, [R0,#60]
	MRS R1, SPSR
	STR R1, [R0,#64]

    POP     {R0-R7, LR}             
	LDR		R0,=PD_ARRAY
	MOV     R1, #0b11010011         // interrupts masked, MODE = SVC
    MSR     CPSR, R1
	
	STR R13,[R0,#52]
	STR R14,[R0,#56]
	
	LDR R13,[R0,#120]
	LDR R14,[R0,#128]

	MOV     R1, #0b11010010         // interrupts masked, MODE = IRQ
    MSR     CPSR, R1              // change to IRQ mode

	LDR R14,[R0,#128]
	LDR		R3,=CURRENT_PID
	MOV		R4,#1
	LDR		R4,[R3]

	LDR		R0,=0xFFFEC600
	LDR		R0, [R0, #0xC] // read timer end-of-interrupt
	LDR     R4, =MPCORE_GIC_CPUIF
	LDR		R5, [R4, #ICCIAR]
	STR     R5, [R4, #ICCEOIR]      // write to ICCEOIR

	LDR R0,=PD_ARRAY
	LDR R2, [R0,#76]
	LDR R3, [R0,#80]
	LDR R4, [R0,#84]
	LDR R5, [R0,#88]
	LDR R6, [R0,#92]
	LDR R7, [R0,#96]
	LDR R8, [R0,#100]
	LDR R9, [R0,#104]
	LDR R10, [R0,#108]
	LDR R11, [R0,#112]
	LDR R12, [R0,#116]

	LDR R1, [R0,#132]
	MSR SPSR, R1
	LDR R1, [R0,#72]
	LDR R0, [R0,#68]
	SUBS PC, LR, #4
	
RUNPG1:
	STR R8, [R0,#32]
	STR R9, [R0,#36]
	STR R10, [R0,#40]
	STR R11, [R0,#44]
	STR R12, [R0,#48]
	LDR R11, [SP,#0]
	STR R11, [R0,#0]
	LDR R11, [SP,#4]
	STR R11, [R0,#4]
	LDR R11, [SP,#8]
	STR R11, [R0,#8]
	LDR R11, [SP,#12]
	STR R11, [R0,#12]
	LDR R11, [SP,#16]
	STR R11, [R0,#16]
	LDR R11, [SP,#20]
	STR R11, [R0,#20]
	LDR R11, [SP,#24]
	STR R11, [R0,#24]
	LDR R11, [SP,#28]
	STR R11, [R0,#28]
	LDR R11, [SP,#32]
	STR R11, [R0,#60]
	MRS R1, SPSR
	STR R1, [R0,#64]

    POP     {R0-R7, LR}             
	LDR		R0,=PD_ARRAY
	MOV     R1, #0b11010011         // interrupts masked, MODE = SVC
    MSR     CPSR, R1
	
	STR R13,[R0,#52]
	STR R14,[R0,#56]
	
	LDR R13,[R0,#120]
	LDR R14,[R0,#128]

	MOV     R1, #0b11010010         // interrupts masked, MODE = IRQ
    MSR     CPSR, R1              // change to IRQ mode

	LDR R14,[R0,#128]
	LDR		R3,=CURRENT_PID
	MOV		R4,#1
	LDR		R4,[R3]

	LDR		R0,=0xFFFEC600
	LDR		R0, [R0, #0xC] // read timer end-of-interrupt
	LDR     R4, =MPCORE_GIC_CPUIF
	LDR		R5, [R4, #ICCIAR]
	STR     R5, [R4, #ICCEOIR]      // write to ICCEOIR

	LDR R0,=PD_ARRAY
	LDR R2, [R0,#76]
	LDR R3, [R0,#80]
	LDR R4, [R0,#84]
	LDR R5, [R0,#88]
	LDR R6, [R0,#92]
	LDR R7, [R0,#96]
	LDR R8, [R0,#100]
	LDR R9, [R0,#104]
	LDR R10, [R0,#108]
	LDR R11, [R0,#112]
	LDR R12, [R0,#116]

	LDR R1, [R0,#132]
	MSR SPSR, R1
	LDR R1, [R0,#72]
	LDR R0, [R0,#68]
	SUBS PC, LR, #4



JTAG_URAT_ISR:
	LDR		R0,=JTAG_UART_BASE
	LDR		R1,=CHAR_BUFFER
	LDR		R2,=CHAR_FLAG
	LDRB	R3, [R0]
	STR     R3,[R1]
	MOV		R3,#1
	STR		R3,[R2]

	B		EXIT_IRQ
	PUT_JTAG: 
	LDR R1, =0xFF201000 // JTAG UART base address
	LDR R2, [R1, #4] // read the JTAG UART control register
	LDR R3,=0xFFFF
	ANDS R2, R2, R3  // check for write space
	BEQ END_PUT // if no space, ignore the character
	STR R0, [R1] // send the character
END_PUT: 	BX LR	

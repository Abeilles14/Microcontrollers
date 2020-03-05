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
.global TICK
TICK:
.word 0x0
.extern TICK
.global MPCORE_ISR
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
			MOV R3, #0b111 // set bits: mode = 1 (auto), enable = 1
			STR R3, [R0, #0x8] // write to timer control register

IDLE:       

            B       IDLE                    // main program simply idles

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
	LDR		R3,=LEDR_BASE

	LDR		R2,[R1]
	ADD		R2, R2, #1
	STR		R2, [R1] // ++tick
	STR		R2, [R3]

	LDR		R0, [R0, #0xC] // read timer end-of-interrupt
	// register to clear the interrupt
	BX		LR
.end


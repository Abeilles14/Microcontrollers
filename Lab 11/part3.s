
//modify code to measure cycles and nubmer of load instructions
//measure all 3 performance counters and compute 3 factors in processor performance equ
//Exec Time = Instruc Count x CPI x Cycle Time, CPI = Cycle count/Instruc Count
//Exec Time = Cycle count x Cycle Time
//measure all 3 counters for 2 values of left shift param, compute 3 terms in processor perf

/*Code from COD 4e pg 250-253 */

.text
.global _start
.global N
.global sum
.global arrayA
.global arrayB
.global arrayC
.global blocksize

blocksize: 
	.word 0x20
N:
	.word 0x2
sum:
	.double 0.0

arrayA:
	.double 1.1
	.double 1.2
	.double 2.1
	.double 2.2
arrayB:
	.double 1.3
	.double 1.4
	.double 2.3
	.double 2.4
arrayC:
	.double 0.0
	.double 0.0
	.double 0.0
	.double 0.0

_start:
	BL CONFIG_VIRTUAL_MEMORY

	// Step 1-3: configure PMN0 to count cycles
	/////// CPU CYCLES //////
	MOV R0, #0 // Write 0 into R0 then PMSELR
	MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN0
	MOV R1, #0x11 // Event 0x11 is CPU cycles
	MCR p15, 0, R1, c9, c13, 1 // Write 0x11 into PMXEVTYPER (PMN0 measure CPU cycles)
	/////// CACHE MISSES ///////
	MOV R0, #1 // Write 1 into R0 then PMSELR
	MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN1
	MOV R1, #0x3 // Event 0x11 is CPU cycles
	MCR p15, 0, R1, c9, c13, 1 // Write 0x3 into PMXEVTYPER (PMN1 measure cache misses)
	/////// LDR INSTRUCTION ///////
	MOV R0, #2 // Write 0 into R0 then PMSELR
	MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN2
	MOV R1, #0x6 // Event 0x11 is CPU cycles
	MCR p15, 0, R1, c9, c13, 1 // Write 0x6 into PMXEVTYPER (PMN2 measure LDR instructions)

	// Step 4: enable PMNx
	MOV R0, #7 // = 1'b111, PMN0-2 is bit 0-2 of PMCNTENSET
	MCR p15, 0, R0, c9, c12, 1 // Setting bit 0-2 of PMCNTENSET enables PMN0-2

	// Step 5: clear all counters and start counters
	MOV R0, #3 // bits 0 (start counters) and 1 (reset counters), clear 6 PCs, starts PCs
	MCR p15, 0, r0, c9, c12, 0 // Setting PMCR to 3

	// Step 6: code we wish to profile using hardware counters
/////////////// MATRIX MULTIPLY //////////////
//Matrix multiply X = X + Y*Z
// for i<N
//	 for j<N
//		for k<N
//			sum = sum + A[i][k]*B[k][j]
//		C[i][j] = sum

INITIALIZE:
	MOV R0, =N		//N = 0
	LDR R4, =arrayA	//base addr A
	LDR R5, =arrayB	//base addr B
	LDR R6, =arrayC	//base addr C
	LDR R7, =blocksize //?????????????

		MOV R8, #0   //initialize j = 0
DGEMM_L1:
		CMP R5, R0   //j < n exit
        BGE EXIT

        ADD R5, R5, R7          //j += BLOCKSIZE

        MOV R9, #0  		 //initialize i = 0
DGEMM_L2:
		CMP R9, R0         //i < n
        BGE DGEMM_L1

        ADD R9, R9, R7     //i += BLOCKSIZE

        MOV R10, #0        //k = 0
DGEMM_L2:
		CMP R10, R0       //check if k < n
        BGE DGEMM_L2

		//initialize all params in registers R1-R3 for si, sj, sk
		//N, A, B, C already defined globally in R0, R4-R6

        MOV R1, R8    //i=si initialize 1st for loop L1 in do_block function
        MOV R2, R9     //j = sj; initialize 2nd for loop
		MOV R3, R10     //k = sk; initialize 3rd for loop


LI: 
	CMP R1, R0
	BGE EXIT		//if i>N exit loop

	ADD R1, R1, #1		//i++
LJ:
	CMP R2, R0
	BGE LI		//if j>N loop i

	LDR R7, =sum
	.word 0xED960B00 //sum = 0.0; 0.0 into D0 ??????????
LK: 
	CMP R2, R0
	BGE LJ_sum	//if k>N compute sum before finish loop j

	///////// IMPLEMENT CODE INSIDE LOOP K HERE /////////////
	ADD   R7, R5, R3, LSL #1
	ADD   R7, R0, R7, LSL #3;
	.word 0xED974B00
	ADD   R7, R4, R5, LSL #1
	ADD   R7, R1, R7, LSL #3;
	.word 0xED975B00
	
	.word 0xEE245B05
	.word 0xEE350B00

	ADD  R5,R5, #1
	CMP R5,R9
	BLT L3

	ADD R8, R4, R3, LSL #1
	ADD R8, R2, R8, LSL #3
	
	.word 0xED880B00

	//////////////////////////////////
	
	ADD R3, R3, #1		//k++
	B LK
LJ_sum:
	.word 0xED883B00	//C[i][j] = sum ????????
	ADD R2, R2, #1		//j++
	B LI				//loop i

////////////// STOP COUNTERS /////////////////
EXIT:
	// Step 7: stop counters
	MOV r0, #0
	MCR p15, 0, r0, c9, c12, 0 // Write 0 to PMCR to stop counters

	// Step 8-10: Select PMN0 and read out result into R3
	/////// CPU CYCLES ///////
	MOV r0, #0 // PMN0
	MCR p15, 0, R0, c9, c12, 5 // Write 0 to PMSELR
	MRC p15, 0, R3, c9, c13, 2 // Read PMXEVCNTR into R3
	/////// CACHE MISSES ///////
	MOV r0, #1 // PMN1
	MCR p15, 0, R0, c9, c12, 5 // Write 1 to PMSELR
	MRC p15, 0, R4, c9, c13, 2 // Read PMXEVCNTR into R4
	/////// LDR INSTRUCTION ///////
	MOV r0, #2 // PMN2
	MCR p15, 0, R0, c9, c12, 5 // Write 1 to PMSELR
	MRC p15, 0, R5, c9, c13, 2 // Read PMXEVCNTR into R5

	END: B END // wait here
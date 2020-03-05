.text
.global _start

//modify code to measure cycles and nubmer of load instructions
//measure all 3 performance counters and compute 3 factors in processor performance equ
//Exec Time = Instruc Count x CPI x Cycle Time, CPI = Cycle count/Instruc Count
//Exec Time = Cycle count x Cycle Time
//measure all 3 counters for 2 values of left shift param, compute 3 terms in processor perf

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
	MOV r0, #3 // bits 0 (start counters) and 1 (reset counters), clear 6 PCs, starts PCs
	MCR p15, 0, r0, c9, c12, 0 // Setting PMCR to 3

	// Step 6: code we wish to profile using hardware counters
	MOV r1, #0x00100000 // base of array
	MOV r2, #0x100 // iterations of inner loop
	MOV r3, #2 // iterations of outer loop
	MOV r4, #0 // i=0 (outer loop counter)

L_outer_loop:
	MOV r5, #0 // j=0 (inner loop counter)

L_inner_loop:
	LDR r6, [r1, r5, LSL #2] // read data from memory, not used
	ADD r5, r5, #1 // j=j+1
	CMP r5, r2 // compare j with 256
	BLT L_inner_loop // branch if less than
	ADD r4, r4, #1 // i=i+1
	CMP r4, r3 // compare i with 2
	BLT L_outer_loop // branch if less than

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

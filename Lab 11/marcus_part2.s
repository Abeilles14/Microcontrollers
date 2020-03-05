/*Code from COD 4e pg 250-253 */
.text
.global _start
.global N
N:
.word 0x3
.global sum
sum:
.double 0.0

.global arrA
.global arrB
.global arrC
.global end

_start:
BL CONFIG_VIRTUAL_MEMORY
// Step 1-3: configure PMN0 to count cycles
MOV R0, #0 // Write 0 into R0 then PMSELR
MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN0
MOV R1, #0x11 // Event 0x11 is CPU cycles
MCR p15, 0, R1, c9, c13, 1 // Write 0x11 into PMXEVTYPER (PMN0 measure CPU cycles)

MOV R0, #1 // Write 1 into R0 then PMSELR
MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN1
MOV R1, #0x6 // Event 0x6 is LDR instructs
MCR p15, 0, R1, c9, c13, 1 // Write 0x6 into PMXEVTYPER (PMN0 measure LDR instructions)

MOV R0, #2 // Write 2 into R0 then PMSELR
MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN1
MOV R1, #0x3 // Event 0x3 is cache misses
MCR p15, 0, R1, c9, c13, 1 // Write 0x3 into PMXEVTYPER (PMN0 measure cache misses)


// Step 4: enable PMN0
mov R0, #7 // PMN0 is bit 0 of PMCNTENSET
MCR p15, 0, R0, c9, c12, 1 // Setting bit 0 of PMCNTENSET enables PMN0, Setting bit 1 of PMCNTENSET enables PMN1, Setting bit 2 of PMCNTENSET enables PMN2
// Step 5: clear all counters and start counters
mov r0, #3 // bits 0 (start counters) and 1 (reset counters)
MCR p15, 0, r0, c9, c12, 0 // Setting PMCR to 3


// Step 6: code we wish to profile using hardware counters
	SUB sp, sp, #44 //make room on stack for 3 registers
	STR R0, [sp, #40] //save r4 on stack
	STR R1, [sp, #36] //save r5 on stack
	STR R2, [sp, #32] //save r6 on stack
	STR R3, [sp, #28] //save r7 on stack
	STR r4, [sp, #24] //save r4 on stack
	STR r5, [sp, #20] //save r5 on stack
	STR r6, [sp, #16] //save r6 on stack
	STR r7, [sp, #12] //save r7 on stack
	STR r8, [sp, #8] //save r8 on stack
	STR r9, [sp, #4] //save r8 on stack
	STR r10, [sp, #0]
	
	LDR R0, =arrA
	LDR R1, =arrB
	LDR R2, =arrC
	LDR R9, N

	MOV   R3, #0  //i = 0; initialize 1st for loop
L1: MOV   R4, #0  //j = 0; restart 2nd for loop
	
L2: LDR   R6, =sum  
	.word 0xED960B00 //sum=0.0; 0.0 into D0 
    MOV   R5, #0  //k = 0; restart 3rd for loop

L3:	MUL   R10,R9, R3
	ADD   R7, R5, R10
	ADD   R7, R0, R7, LSL #3;
	.word 0xED974B00
	MUL   R10,R9,R5
	ADD   R7, R4, R10
	ADD   R7, R1, R7, LSL #3;
	.word 0xED975B00
	
	.word 0xEE245B05
	.word 0xEE350B00

	ADD  R5,R5,#1
	CMP R5,R9
	BLT L3
	MUL R10, R9, R3
	ADD R8, R4, R10
	ADD R8, R2, R8, LSL #3
	
	.word 0xED880B00

	ADD R4,R4,#1
	CMP R4,R9
	BLT L2
	ADD R3, R3, #1
	CMP R3, R9
	BLT L1
	LDR r10,[sp, #0]
	LDR r9, [sp, #4] 
	LDR r8, [sp, #8] 
	LDR r7, [sp, #12]
	LDR r6, [sp, #16] 
	LDR r5, [sp, #20] 
	LDR r4, [sp, #24] 
	LDR R3, [sp, #28] //save r7 on stack
	LDR R2, [sp, #32] //save r6 on stack
	LDR R1, [sp, #36] //save r5 on stack
	LDR R0, [sp, #40] //save r4 on stack
	ADD sp, sp, #44
// Step 7: stop counters
mov r0, #0
MCR p15, 0, r0, c9, c12, 0 // Write 0 to PMCR to stop counters


// Step 8-10: Select PMN0 and read out result into R3
mov r0, #0 // PMN0
MCR p15, 0, R0, c9, c12, 5 // Write 0 to PMSELR
MRC p15, 0, R3, c9, c13, 2 // Read PMXEVCNTR into R3

mov r0, #1 // PMN2
MCR p15, 0, R0, c9, c12, 5 // Write 1 to PMSELR
MRC p15, 0, R1, c9, c13, 2 // Read PMXEVCNTR into R1

mov r0, #2 // PMN2
MCR p15, 0, R0, c9, c12, 5 // Write 2 to PMSELR
MRC p15, 0, R2, c9, c13, 2 // Read PMXEVCNTR into R2

end: b end // wait here

arrA: 
	  .double 1.1
	  .double 1.2
	  .double 1.3
	  .double 2.1
	  .double 2.2
	  .double 2.3
	  .double 3.1
	  .double 3.2
	  .double 3.3
arrB: 
	  .double 1.4
	  .double 1.5
	  .double 1.6
	  .double 2.4
	  .double 2.5
	  .double 2.6
	  .double 3.4
	  .double 3.5
	  .double 3.6
arrC: 
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
/*Code from COD 4e pg 250-253 */
.text
.global _start
.global N
N:
.word 0x3
.global sum
sum:
.double 0.0

.global arrA
.global arrB
.global arrC
.global end

_start:
BL CONFIG_VIRTUAL_MEMORY
// Step 1-3: configure PMN0 to count cycles
MOV R0, #0 // Write 0 into R0 then PMSELR
MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN0
MOV R1, #0x11 // Event 0x11 is CPU cycles
MCR p15, 0, R1, c9, c13, 1 // Write 0x11 into PMXEVTYPER (PMN0 measure CPU cycles)

MOV R0, #1 // Write 1 into R0 then PMSELR
MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN1
MOV R1, #0x6 // Event 0x6 is LDR instructs
MCR p15, 0, R1, c9, c13, 1 // Write 0x6 into PMXEVTYPER (PMN0 measure LDR instructions)

MOV R0, #2 // Write 2 into R0 then PMSELR
MCR p15, 0, R0, c9, c12, 5 // Write 0 into PMSELR selects PMN1
MOV R1, #0x3 // Event 0x3 is cache misses
MCR p15, 0, R1, c9, c13, 1 // Write 0x3 into PMXEVTYPER (PMN0 measure cache misses)


// Step 4: enable PMN0
mov R0, #7 // PMN0 is bit 0 of PMCNTENSET
MCR p15, 0, R0, c9, c12, 1 // Setting bit 0 of PMCNTENSET enables PMN0, Setting bit 1 of PMCNTENSET enables PMN1, Setting bit 2 of PMCNTENSET enables PMN2
// Step 5: clear all counters and start counters
mov r0, #3 // bits 0 (start counters) and 1 (reset counters)
MCR p15, 0, r0, c9, c12, 0 // Setting PMCR to 3


// Step 6: code we wish to profile using hardware counters
	SUB sp, sp, #44 //make room on stack for 3 registers
	STR R0, [sp, #40] //save r4 on stack
	STR R1, [sp, #36] //save r5 on stack
	STR R2, [sp, #32] //save r6 on stack
	STR R3, [sp, #28] //save r7 on stack
	STR r4, [sp, #24] //save r4 on stack
	STR r5, [sp, #20] //save r5 on stack
	STR r6, [sp, #16] //save r6 on stack
	STR r7, [sp, #12] //save r7 on stack
	STR r8, [sp, #8] //save r8 on stack
	STR r9, [sp, #4] //save r8 on stack
	STR r10,[sp, #0]
	
	LDR R0, =arrA
	LDR R1, =arrB
	LDR R2, =arrC
	LDR R9, N

	MOV   R3, #0  //i = 0; initialize 1st for loop
L1: MOV   R4, #0  //j = 0; restart 2nd for loop
	
L2: LDR   R6, =sum  
	.word 0xED960B00 //sum=0.0; 0.0 into D0 
    MOV   R5, #0  //k = 0; restart 3rd for loop

L3:	MUL   R10,R9, R3
	ADD   R7, R5, R10
	ADD   R7, R0, R7, LSL #3;
	.word 0xED974B00
	MUL   R10,R9,R5
	ADD   R7, R4, R10
	ADD   R7, R1, R7, LSL #3;
	.word 0xED975B00
	
	.word 0xEE245B05
	.word 0xEE350B00

	ADD  R5,R5,#1
	CMP R5,R9
	BLT L3
	MUL R10, R9, R3
	ADD R8, R4, R10
	ADD R8, R2, R8, LSL #3
	
	.word 0xED880B00

	ADD R4,R4,#1
	CMP R4,R9
	BLT L2
	ADD R3, R3, #1
	CMP R3, R9
	BLT L1
	LDR r10,[sp, #0]
	LDR r9, [sp, #4] 
	LDR r8, [sp, #8] 
	LDR r7, [sp, #12]
	LDR r6, [sp, #16] 
	LDR r5, [sp, #20] 
	LDR r4, [sp, #24] 
	LDR R3, [sp, #28] //save r7 on stack
	LDR R2, [sp, #32] //save r6 on stack
	LDR R1, [sp, #36] //save r5 on stack
	LDR R0, [sp, #40] //save r4 on stack
	ADD sp, sp, #44
// Step 7: stop counters
mov r0, #0
MCR p15, 0, r0, c9, c12, 0 // Write 0 to PMCR to stop counters


// Step 8-10: Select PMN0 and read out result into R3
mov r0, #0 // PMN0
MCR p15, 0, R0, c9, c12, 5 // Write 0 to PMSELR
MRC p15, 0, R3, c9, c13, 2 // Read PMXEVCNTR into R3

mov r0, #1 // PMN2
MCR p15, 0, R0, c9, c12, 5 // Write 1 to PMSELR
MRC p15, 0, R1, c9, c13, 2 // Read PMXEVCNTR into R1

mov r0, #2 // PMN2
MCR p15, 0, R0, c9, c12, 5 // Write 2 to PMSELR
MRC p15, 0, R2, c9, c13, 2 // Read PMXEVCNTR into R2

end: b end // wait here

arrA: 
	  .double 1.1
	  .double 1.2
	  .double 1.3
	  .double 2.1
	  .double 2.2
	  .double 2.3
	  .double 3.1
	  .double 3.2
	  .double 3.3
arrB: 
	  .double 1.4
	  .double 1.5
	  .double 1.6
	  .double 2.4
	  .double 2.5
	  .double 2.6
	  .double 3.4
	  .double 3.5
	  .double 3.6
arrC: 
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0
	  .double 0.0

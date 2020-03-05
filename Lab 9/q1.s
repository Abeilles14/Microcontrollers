/* Lab 9 */
    .include "address_map_arm.s"
    .text
    .global _start

func:	SUB sp, sp, #20   //creating stack space for 2 opperations 

	STR LR, [sp, #12]
	STR R7, [sp, #8]   //saving register r7 to use for  MIDDLEINDEX
	STR r4, [sp, #4]   //copy of R4 as backup
	STR R9, [sp, #16]
	STR r8, [sp, #0]  //saving register r8 to use for arrayofmiddleindex
  
	SUB R4, R0, 10// r4 is result
	Mov r7, #0
	LDR r5, [R1, R7, LSL#2]// r5 is a[0]
	Add r6, r5, #1// r6 num calls
	
	STR R6, [R1, R7, LSL#2]// storing numcalls to array
	cmp R0,#100
	BGT RETURN
	
	Add R0, R0, #11
	Bl func
	Bl func
	cmp R4,R1
	BGE return
	Sub R9, R2,r6
	STR R0, [R1, R9, LSL#2]


RETURN:

	
	LDR R8, [sp, #0]
	LDR LR, [sp, #12]
	LDR R7, [sp, #8]    // unloads the stack
	LDR R4, [sp, #4] 
	LDR R9, [sp, #16]
	ADD sp, sp, #20 

	MOV PC, LR 
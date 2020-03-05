 .globl binary_search
 binary_search:
   SUB sp,  sp,#40
   STR lr, [sp,#36]
   STR R7, [sp,#32]
   STR R6, [sp,#28]   
   STR R5, [sp,#24]  
   STR R4, [sp,#20]
   STR R3, [sp,#16]
   STR R2, [sp,#12]
   STR R1, [sp,#8]   
   STR R0, [sp,#4]
   LDR R5, [sp,#40]
   STR R5, [sp,#0]
 
   SUB R4, R3, R2
   ADD R4, R2, R4, LSR #1 
   
   ADD R5, R5, #1 
   STR R5, [sp,#0]

   CMP R2, R3
   BGT L1  
   
   LDR R6, [R0,R4, LSL #2] 
   CMP R6, R1
   BEQ L2
   
   BGT L3
   ADD R2,R4,#1
   BL binary_search
   MOV R7,R0
   MOV R0,R1
last: 
   RSB R5,R5,#0
   STR R5, [R0,R4,LSL #2]
   MOV R0, R7  //return 
   LDR R5, [sp,#40]
   STR R5, [sp,#0]
   LDR R1, [sp,#4]
   LDR R2, [sp,#12]
   LDR R3, [sp,#16]
   LDR R4, [sp,#20]
   LDR R5, [sp,#24]  
   LDR R6, [sp,#28]   
   LDR R7, [sp,#32]
   LDR lr, [sp,#36]
   ADD sp,sp,#40
   MOV pc, lr
    
L1: 
   MOV r0, #-1 
   LDR R5, [sp,#40]
   STR R5, [sp,#0]
   LDR R1, [sp,#4]
   LDR R2, [sp,#12]
   LDR R3, [sp,#16]
   LDR R4, [sp,#20]
   LDR R5, [sp,#24]  
   LDR R6, [sp,#28]   
   LDR R7, [sp,#32]
   LDR lr, [sp,#36]
   ADD sp,sp,#40
   MOV pc, lr

L2: MOV R7,R4
    B last

L3: SUB R3, R4,#1
    BL binary_search
	MOV R7,R0
	MOV R0,R1
	B last



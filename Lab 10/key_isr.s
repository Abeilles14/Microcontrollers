.include    "address_map_arm.s" 

/****************************************************************************************
 * Pushbutton - Interrupt Service Routine
 *
 * This routine checks which KEY has been pressed. It writes to LED display
 ***************************************************************************************/

.global     KEY_ISR 
KEY_ISR:                        
        LDR     R0, =KEY_BASE   // base address of pushbutton KEY port
        LDR     R1, [R0, #0xC]  // read edge capture register
        MOV     R2, #0xF        
        STR     R2, [R0, #0xC]  // clear the interrupt

        LDR     R0, =LED_BASE   // based address of LED display
CHECK_KEY0:                     
        MOV     R3, #0x1        
        ANDS    R3, R3, R1      // check for KEY0
        BEQ     CHECK_KEY1      
        MOV     R2, #0b1        
        B       END_KEY_ISR     
CHECK_KEY1:
	MOV	R3, #0x2
	ANDS	R3, R3, R1	// check for KEY1
	BEQ	CHECK_KEY2                     
        MOV     R2, #0b10 
	B	END_KEY_ISR
CHECK_KEY2:
	MOV	R3, #0x4
	ANDS	R3, R3, R1	// check for KEY2
	BEQ	CHECK_KEY3                     
        MOV     R2, #0b100 
	B	END_KEY_ISR
CHECK_KEY3:                     
        MOV     R2, #0b1000    
END_KEY_ISR:                    
        STR     R2, [R0]        // display KEY pressed on LED
        BX      LR              

.end         

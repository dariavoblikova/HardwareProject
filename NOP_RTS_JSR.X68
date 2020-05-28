*-----------------------------------------------------------
* Title      : Decoding NOP, RTS, JSR opcodes
* Written by : Daria Voblikova
* Date       : May 10, 2020
* Description: Decodes word to identify the subroutine (RTS, JSR) or NOP operation
*-----------------------------------------------------------
*    ORG    $2000 starting address determined by the user

NOP_RTS_JSR:                  ; first instruction of program
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6
* Enter this subroutine when we know we have a subroutine (RTS, JSR) or NOP
* instruction that we want to decode. That is if the first byte is 4E.
* Assuming that a word was given to us hexadecimal in data register 4.
* Based on this word, this subroutine will print to console if this is a 
* NOP, RTS, or JSR opcode.

* Put program code here
    * MOVE.W  D4,-(SP)    * move the word to the stack to analyze one byte at a time
    * CLR.W   D4          * clear the contents of D4
    MOVE.L  D4,D3       * copy word to D3
    AND.W   #$FF00,D3   * mask D3 to only read most significant byte
    CMP.W   #$4E00,D3   * check if this could be NOP, RTS, or JSR
    BNE     SUB_INVALID     * not a valid NOP, RTS, or JSR opcode    
    
    CMP.W   #$4E71,D4   * check if this is a NOP opcode
    BEQ     NOP_CASE    * we know this is a NOP opcode, can now print this in console
    
    CMP.W   #$4E75,D4   * check if this is a RTS opcode
    BEQ     RTS_CASE    * we know this is a RTS opcoe, can now print this in console
    
    MOVE.B  D4,D3       * copy least significant byte data over to D3
    AND.B   #$C0,D3     * mask D3 so we only retain two most significant bits
    CMP.B   #$80,D3   * if 10 are first two bits, this could be JSR opcode
    BEQ     JSR_CASE    * we know this is a JSR opcode, now find effective address     
    
    BRA     SUB_INVALID     * reach this point if condition bits are invalid
    
* tell user that this isn't a valid opcode   
SUB_INVALID    JSR     INVALID
            BRA     JSR_END

* will print out that this is an NOP opcode   
NOP_CASE    MOVE.L  #$2,D6  * store displacement in D6
            LEA NOP_M,A1
            BRA JSR_PRINT
            
* will print out that this is an RTS opcode   
RTS_CASE    MOVE.L  #$2,D6  * store displacement in D6
            LEA RTS_M,A1
            BRA JSR_PRINT

* finds effective address of JSR opcode, if valid at all            
JSR_CASE    MOVE.L  D4,D3
            AND.B   #$F8,D3     * mask D3, to check effective address mode
            CMP.B   #$90,D3   
            BEQ     JSR_INDIRECT    * if equal, we know address register indirect is EA
            CMP.B   #$B8,D3
            BEQ     JSR_ABSOLUTE
            BRA     SUB_INVALID

* check for address register we are using for EA
JSR_INDIRECT    MOVE.L  #$2,D6  * store displacement in D6
            MOVE.L  D4,D3
            AND.L  #$07,D3
            MOVE.L  D3,D1
            
            LEA     JSR_M,A1 * print that this is a JSR opcode
            MOVE.B  #14,D0
            TRAP    #15
            
            LEA     ADDR_INDR,A1 * print '(A' for appropriate assembly syntax
            MOVE.B  #14,D0
            TRAP    #15
            
            MOVE.B  #3,D0   * print register number
            TRAP    #15
            
            LEA     END_PAREN,A1    * print ')' for appropriate assembly syntax
            MOVE.B  #14,D0
            TRAP    #15
            BRA     JSR_END
            
JSR_ABSOLUTE    MOVE.L  D4,D3
            AND.L   #$07,D3
            CMP.L   #$00,D3
            BEQ     JSR_WORD
            CMP.L   #$01,D3
            BEQ     JSR_LONG
            BRA     SUB_INVALID
            
JSR_WORD        MOVE.L  #$4,D6  * store displacement in D6
            ADDI.L  #$2,D5  * add 2 to grab next instruction from memory
            MOVEA.L D5,A0 
            MOVE.W  (A0),D3
            BRA     JSR_ABS_PRINT            

JSR_LONG        MOVE.L  #$6,D6  * store displacement in D6
            ADDI.L  #$2,D5  * add 2 to grab next instruction from memory
            MOVEA.L D5,A0 
            MOVE.L  (A0),D3
            BRA     JSR_ABS_PRINT
            
JSR_ABS_PRINT   LEA     JSR_M,A1 * print that this is a JSR opcode
            MOVE.B  #14,D0
            TRAP    #15

            LEA     HEX_SYMBOL,A1
            MOVE.B  #14,D0  * print '$' for appropriate assembly syntax
            TRAP    #15
            
            MOVE.L  D3,D1
            MOVE.B  #3,D0
            TRAP    #15    
            
            BRA     JSR_END
           
JSR_PRINT       MOVE.B  #14,D0
            TRAP    #15
JSR_END            MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6
            RTS     *Return to subroutine here
    
    * SIMHALT             ; halt simulator

* Put variables and constants here
NOP_M       DC.B    'NOP    ',0
RTS_M       DC.B    'RTS    ',0
JSR_M       DC.B    'JSR    ',0
ADDR_INDR   DC.B    '(A'     ,0 
END_PAREN   DC.B    ')'      ,0
HEX_SYMBOL  DC.B    '$'      ,0
INV_M       DC.B    'Not a valid NOP, RTS, or JSR opcode',0

    * END    NOP_RTS_JSR        ; last line of source
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

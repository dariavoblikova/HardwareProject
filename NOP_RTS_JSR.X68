*-----------------------------------------------------------
* Title      : Decoding NOP, RTS, JSR opcodes
* Written by : Daria Voblikova
* Date       : May 10, 2020
* Description: Decodes word to identify the subroutine (RTS, JSR) or NOP operation
*-----------------------------------------------------------
*    ORG    $2000 starting address determined by the user

NOP_RTS_JSR:                  ; first instruction of program

* Enter this subroutine when we know we have a subroutine (RTS, JSR) or NOP
* instruction that we want to decode. That is if the first byte is 4E.
* Assuming that a word was given to us hexadecimal in data register 4.
* Based on this word, this subroutine will print to console if this is a 
* NOP, RTS, or JSR opcode.

* Put program code here
    * MOVE.W  D4,-(SP)    * move the word to the stack to analyze one byte at a time
    * CLR.W   D4          * clear the contents of D4
    
    CMP.W   #$4E71,D4   * check if this is a NOP opcode
    BEQ     NOP_CASE    * we know this is a NOP opcode, can now print this in console
    
    CMP.W   #$4E75,D4   * check if this is a RTS opcode
    BEQ     RTS_CASE    * we know this is a RTS opcoe, can now print this in console
    
    BRA     INVALID     * reach this point if condition bits are invalid
    
* tell user that this isn't a valid opcode   
INVALID     LEA INV_M,A1
            BRA PRINT

* will print out that this is an NOP opcode   
NOP_CASE    LEA NOP_M,A1
            BRA PRINT
            
* will print out that this is an RTS opcode   
RTS_CASE    LEA RTS_M,A1
            BRA PRINT
           
PRINT       MOVE.B  #14,D0
            TRAP    #15
    
    RTS     *Return to subroutine here
    SIMHALT             ; halt simulator

* Put variables and constants here
NOP_M       DC.B    'NOP    ',0
RTS_M       DC.B    'RTS    ',0
JSR_M       DC.B    'JSR    ',0
INV_M       DC.B    'Not a valid NOP, RTS, or JSR opcode',0

    END    NOP_RTS_JSR        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

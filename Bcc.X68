*-----------------------------------------------------------
* Title      : Decoding Branch Opcodes
* Written by : Amman Nega
* Date       : May 10, 2020
* Description: Decodes word to identify the type of branching operation
*-----------------------------------------------------------

* CR      EQU     $0D
* LF      EQU     $0A


BCC:                  ; first instruction of program
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6

* Enter this subroutine when we know we have a Branch instruction
* that we want to decode. Assuming that a word was given to us
* hexadecimal in data register 4. Based on this word, this subroutine
* will print to console if this is a BEQ, BLE, BGT, or BRA opcode.

* Parameters:
* D4: contains word we will decode to specific Bcc opcode
* D5: contains long representing current PC location

    MOVE.W  D4,-(SP)  * move the word to the stack to analyze one byte at a time
    MOVE.B  D4,D6     * move byte representing displacement into D4
    CLR.W   D4        * clear the contents of D3
    
    * must remember to pop low order byte from stack before RTS
    MOVE.B  (SP)+,D4  * store high order byte in variable branchType
    
    CMP.B   #$67,D4 * check if this is a BEQ opcode
    BEQ     EQUAL   * we know this is a BEQ opcode, can now print this in console
    
    CMP.B   #$6F,D4 * check if this is a BLE opcode
    BEQ     LESS    * we know this is a BLE opcde, can now print this in console
    
    CMP.B   #$6E,D4 * check if this is a BGT opcode
    BEQ     GREATER * we know this is a BEQ opcode, can now print this in console
    
    CMP.B   #$60,D4 * check if this is a BRA opcode
    BEQ     ALWAYS  * we know this is a BRA opcode, can now print this in console
    
    BRA     BCC_INVALID * reach this point if condition bits are invalid
 
* tell user that this isn't a valid opcode   
BCC_INVALID JSR INVALID
            BRA BCC_END
    
* will print out that this is an Equals opcode   
EQUAL   LEA opcode_BEQ,A1
        BRA BCC_DISPLACEMENT
   
* will print out that this is a less than or equal to opcode       
LESS    LEA opcode_BLE,A1
        BRA BCC_DISPLACEMENT

* will print out that this is a greater than opcode              
GREATER LEA opcode_BGT,A1
        BRA BCC_DISPLACEMENT
        
* will print out that this is a branch always opcode        
ALWAYS  LEA opcode_BRA,A1
        BRA BCC_DISPLACEMENT
        
* we assume that the memory location we are currently dissasembling was passed into D5
BCC_DISPLACEMENT MOVE.L  D5,D1   * move current mem address location to D1
        ADDI.L  #$2,D1  * add 2 in hex to mem location in order to calculate displacement   
        CMP.B   #$00,D6
        BEQ     BCC_SIXTEEN * need to calculate 16-bit displacement
        CMP.B   #$FF,D6
        BEQ     BCC_THIRTYTWO    * need to go back to main program, and grab next two words from memory (32-bit displacement)
        
        * otherwise, calculate 8-bit dislacement
        CMP.B   #$0,D6  * check if the displacement is positive or negative
        BLT     BCC_NEG     * add FF to D4 for sign extension
        BRA     BCC_EIGHT    * if D4 is positive, can just calculate displacement as is

BCC_NEG     ADDI.W  #$FF00,D6   * make D4 sign extended
        BRA     BCC_EIGHT    * branch to calculate displacement

BCC_EIGHT   ADD.W   D6,D1   * calculate displacement and store result in D1
        MOVE.W  #$2,D6  * store displacement in D6
        BRA     BCC_OUTPUT

BCC_OUTPUT  MOVE.B  #14,D0  * output Bcc opcode to console 
        TRAP    #15
        LEA     SPACE,A1    * create empty space between opcode
        TRAP    #15
        MOVE.B  #16,D2  * output displacement in base 16 (hexadecimal)
        MOVE.B  #15,D0  * move trap task into D0
        TRAP    #15     * outputs displacement to console
        
        *LEA     NEWL,A1 * makes a new line for outputting next opcode
        *MOVE.B  #14,D0  * move trap task to D0
        *TRAP    #15     * output new line
        BRA     BCC_END             * end subroutine once displacement is calculated
        
BCC_SIXTEEN ADDI.L  #$2,D5  
        CMP.L   A6,D5   * check if displacement word is out of bounds of memory we read
        BGE     BCC_INVALID
        MOVEA.L D5,A2   * stores memory location of PC in address register
        ADD.W   #$2,A2  * increment memory location to look at next word
        ADD.W   (A2),D1 * calculate 16-bit displacement
        MOVE.W  #$4,D6  * store displacement in D6
        BRA     BCC_OUTPUT  * output displacement to display
        
BCC_THIRTYTWO   ADDI.L  #$4,D5
        CMP.L   A6,D5
        BGE     BCC_INVALID  
        MOVEA.L  D5,A2 * stores memory location of PC in address register
        ADD.W   #$2,A2  * increment memory location to look at next long
        ADD.L   (A2),D1 * calculate 32-bit displacement
        MOVE.W  #$6,D6  * store displacement in D6
        BRA     BCC_OUTPUT  * output displacement to display

BCC_END     MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6
            RTS     *Return to subroutine here

    *SIMHALT             ; halt simulator


    *END    BCC        ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

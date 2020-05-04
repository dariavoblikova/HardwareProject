*-----------------------------------------------------------
* Title      : Subroutine for Bcc Opcodes
* Written by : Amman Nega
* Date       : May 3, 2020
* Description: Decodes a word and then prints out the type of
* Bcc opcode that is being used, along with the label that it
* will branch to.
*-----------------------------------------------------------
    *ORG    $1000 starting address determined by the user
branchType  EQU     $00

START:                  ; first instruction of program

* Enter this subroutine when we know we have a Branch instruction
* that we want to decode. Assuming that a word was given to us
* hexadecimal in data register 3. Based on this word, this subroutine
* will print to console if this is a BEQ, BLE, BGT, or BRA opcode.

* Put program code here

    MOVE.W  D3,(SP)+  * move the word to the stack to analyze one byte at a time
    
    * must remember to pop low order byte from stack before RTS
    MOVE.B  -(SP),branchType  * store high order byte in variable branchType
    
    CMP.B   #$67,branchType * check if this is a BEQ opcode
    BEQ     EQUAL   * we know this is a BEQ opcode, can now print this in console
    
    CMP.B   #$6F,branchType * check if this is a BLE opcode
    BEQ     LESS    * we know this is a BLE opcde, can now print this in console
    
    CMP.B   #$6E,branchType * check if this is a BGT opcode
    BEQ     GREATER * we know this is a BEQ opcode, can now print this in console
    
    CMP.B   #$60,branchType * check if this is a BRA opcode
    BEQ     ALWAYS  * we know this is a BRA opcode, can now print this in console
    
    BRA     INVALID * reach this point if condition bits are invalid
 
* tell user that this isn't a valid opcode   
INVALID LEA INV,A1
        BRA PRINT
    
* will print out that this is an Equals opcode   
EQUAL   LEA EQ,A1
        BRA PRINT
   
* will print out that this is a less than or equal to opcode       
LESS    LEA LESSEQUAL,A1
        BRA PRINT

* will print out that this is a greater than opcode              
GREATER LEA GREATERTHAN,A1
        BRA PRINT

ALWAYS  LEA BRANCH,A1
        BRA PRINT
        
PRINT   MOVE.B  #14,D0
        TRAP    #15
        BRA     DONE
        
*TODO: pop least significant byte from stack and determine label from given displacement        
DONE    

    RTS     *Return to subroutine here

    SIMHALT             ; halt simulator

* Put variables and constants here
BRANCH     DC.B    'BRA    ',0
EQ     DC.B    'BEQ    ',0
LESSEQUAL     DC.B    'BLE    ',0
GREATERTHAN     DC.B    'BGT    ',0
INV     DC.B    'Not a valid Bcc opcode',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

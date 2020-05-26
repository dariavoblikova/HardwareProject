*-----------------------------------------------------------
* Title      : Main
* Written by : Daria Voblikova
* Date       : 5/18/2020
* Description: Includes other files (http://www.easy68k.com/EASy68Kforum/viewtopic.php?f=5&t=316)
*-----------------------------------------------------------
* Amman: just testing to see if I could push my code

stack EQU $00100000
    
MAIN    ORG    $1000
    LEA         stack,SP                    Set location of the stack pointer
    JSR         GET_ADDRESS_IO              Located in USERINPUT.X68, Loads start address to D5 and end address to D6
    *JSR         MAIN_LOOP                   NOT IMPLEMENTED YET (should be in a separate file)
    *JSR         ASK_TO_REPEAT               NOT IMPLEMENTED YET(should be in I_O_SUBROUTINE)
    *CMP ...                                 COMPARE ANSWER TO 1 (1 = yes)
    *BEQ         MAIN
    JSR         FINISH_MESSAGE
    JMP         STOP
    
*-----------------------------------------------------------
    INCLUDE 'I_O_SUBROUTINE.X68'            I/O subroutines    
    * INCLUDE 'Bcc.X68'                     Decoding Branch Opcodes
    * INCLUDE 'NOP_RTS_JSR.X68'             Decoding NOP, RTS, JSR opcodes
    * INCLUDE 'REG_MEM.X68'                 MOVEM Decoding for Register to Memory
    INCLUDE 'USERINPUT.X68'                        Get Adrresses AsciiToHex
    INCLUDE 'strings.X68'                   Put all the strings here and give them good names
    SIMHALT                                 ; halt simulator

STOP:
    END    MAIN                             ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

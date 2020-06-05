*-----------------------------------------------------------
* Title      : Main
* Written by : Daria Voblikova
* Date       : 5/18/2020
* Description: Includes other files
*-----------------------------------------------------------

stack EQU $00100000
    
MAIN    ORG    $1000
    LEA         stack,SP                    Set location of the stack pointer
    MOVE.B      #$00, LINECOUNTER           Set line counter to 0
    JSR         GET_ADDRESS_IO              Located in USERINPUT.X68, Loads start address to A5 and end address to A6
    
    LEA         NEWLINE,A1                  Print new line
    MOVE.B      #14,D0                      Stores task 14 in D0
    TRAP        #15                         Task 15, print new line

    JSR         MAIN_LOOP                   Located in MAIN_LOOP.X68 file
    BRA         INPUT_QUIT_RESTART          Located in I_O_SUBROUTINE
    
*-----------------------------------------------------------
    * The order of includes is important!!
    INCLUDE 'I_O_SUBROUTINE.X68'            I/O subroutines
    INCLUDE 'USERINPUT.X68'                 Get Adrresses AsciiToHex
    INCLUDE 'MAIN_LOOP.X68'                 Opcodes loop
    INCLUDE 'strings.X68'                   Put all the strings here and give them good names
    INCLUDE 'INVALID.X68'
    INCLUDE 'NOP_RTS_JSR.X68'             Decoding NOP, RTS, JSR opcodes
    INCLUDE 'SHIFT_OPCODES.X68'
    INCLUDE 'Bcc.X68'                         Decoding Branch Opcodes
    INCLUDE 'REG_MEM.X68'  *caused errors, put in mainloop
    INCLUDE 'MEM_REG.X68'  *caused errors, put in mainloop
    INCLUDE 'IO.x68'
    INCLUDE 'ADD_SUBROUTINE.x68'
    INCLUDE 'MOVE_SUBROUTINE.x68'
    INCLUDE 'NOT.x68'
    INCLUDE 'LEA.x68'
    INCLUDE 'MOVEQ.x68'
    INCLUDE 'INVALIDEA.X68'
    
    
LINECOUNTER      DS.B    1

STOP    SIMHALT   
        END    MAIN                             ; last line of source




































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

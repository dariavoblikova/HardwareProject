*-----------------------------------------------------------
* Title      : I/O subroutines
* Written by : Daria Voblikova
* Date       : 5/18/2020
* Description: Prompt user for a starting and ending address in memory
*-----------------------------------------------------------

FINISH_MESSAGE:
    MOVEM.L     D0/D1/D2/A1, -(SP)          Push(save) registers
    
    LEA         NEWL,A1
    MOVE.B      #14,D0
    TRAP        #15
    
    LEA         FinishQuestionString, A1
    MOVE.B      #14, D0                     Task 14: Display the NULL terminated string at (A1) without CR, LF.
    TRAP        #15                         Display
    
    MOVE        #4,D0                       Task 4: Read a number from the keyboard into D1.L.
    TRAP        #15                         Perform task 4
    MOVE.L      D1,D2                       D2 = user input
    CMPI.L      #$1, D2                     Compare to 1
    BEQ         FINISH_PROGRAM              If 1 finish the program
  
    MOVEM.L     (SP)+, D0/D1/D2/A1          Pop(restore) registers
    RTS

*FINISH_PROGRAM:
*    MOVE        #4,D0                       JUST FOR TESTING!!REWRITE LATER

INPUT_ENTER     LEA     PRESS_ENTER_PROMPT, A1      
                MOVE.B  #14,D0                      * Task 14 of trap 15
                TRAP    #15
                MOVE.B  #00,LINECOUNTER             * Clear the line counter
                MOVE.B  #5,D0                       * Task 5 of trap 15 (Read single character from the keyboard into D1.B. )
                TRAP    #15                         * Trap 15
                CMP.B   #$0D, D1                    * D1.B Contains user input, ENTER = D000D
                BEQ     CLEAR_SCREEN                * If user pressed clear the screen (need it to print next set of instructions from memory)
                BNE     INPUT_ENTER                 * Loop back until press an enter

INPUT_QUIT_RESTART  LEA     QUIT_RESTART_PROMPT, A1
                    MOVE.B  #14,D0
                    TRAP    #15
                    MOVE.B  #00,LINECOUNTER             * Clear the line counter
                    MOVE.B  #5,D0                       * Task 5 of trap 15 (Read single character from the keyboard into D1.B. )
                    TRAP    #15                         * Trap 15
                    CMP.B   #$71, D1                    * D1.B Contains user input (quit) q = $71
                    BEQ     FINISH_PROGRAM
                    CMP.B   #$51, D1                    * D1.B Contains user input (quit) Q = $51
                    BEQ     FINISH_PROGRAM
                    CMP.B   #$72, D1                    * D1.B Contains user input (restart) r = $72
                    BEQ     RESTART_PROGRAM
                    CMP.B   #$52, D1                    * D1.B Contains user input (restart) R = $52
                    BEQ     RESTART_PROGRAM
                    BNE     INPUT_QUIT_RESTART
  

CLEAR_SCREEN    MOVE.B  #11,D0                      * Task 11 of trap 15
                MOVE.W  #$FF00,D1                   * To clear Screen set D1.W to $FF00
                TRAP #15                            * I/O. Trap 15 task 11
                CLR     D0                          * Clear registers used
                CLR     D1                          * Clear registers used
                RTS

RESTART_PROGRAM JSR     CLEAR_SCREEN
                JSR     CLEAR_REGISTERS
                MOVE.L  #$00000000,A5
                MOVE.L  #$00000000,A6
                BRA     MAIN
                
FINISH_PROGRAM  JSR     CLEAR_SCREEN
                JMP     STOP



NULL    EQU 00
* CR      EQU $0D                             ;ASCII code for Carriage Return
* LF      EQU $0A                             ;ASCII code for Line Feed
* Put variables and constants here













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

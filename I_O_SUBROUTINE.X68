*-----------------------------------------------------------
* Title      : I/O subroutines
* Written by : Daria Voblikova
* Date       : 5/18/2020
* Description: Prompt user for a starting and ending address in memory
*-----------------------------------------------------------
GET_STARTING_AND_ENDING:
    MOVEM.L     D0-D7/A0-A6, -(SP)          Push(save) registers  THINK WHICH REGISTERES TO SAVE?
                                            * NOT IMPLEMENTED YET
    MOVEM.L     (SP)+, D0-D7/A0-A6          Pop(restore) registers  SHOULD BE SAME AS PUSH!
    RTS

FINISH_MESSAGE:
    MOVEM.L     D0/D1/D2/A1, -(SP)          Push(save) registers
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

FINISH_PROGRAM:
    MOVE        #4,D0                       JUST FOR TESTING!!REWRITE LATER



NULL    EQU 00
CR      EQU $0D                             ;ASCII code for Carriage Return
LF      EQU $0A                             ;ASCII code for Line Feed
* Put variables and constants here
InputStartingAddressMessage         DC.B    'Enter an 8-digit starting address(even and in hex)',CR,LF,0
InputEndingAddressMessage           DC.B    'Enter an 8-digit ending address(even and in hex)',CR,LF,0
FinishQuestionString                DC.B    'To finish type 1', CR,LF,0
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

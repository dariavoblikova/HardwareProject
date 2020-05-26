*-----------------------------------------------------------
* Title      :  Main Routine for Disassembler ; testing addition
* Written by :  Alexander A Dietrich
* Date       :  5/25/2020
* Description:  Gets two addresses, reads memory inbetween,
* tries to parse memory into opcodes/EA
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
*get starting address
        LEA PROMPT, A1
        BSR PRINT
        BSR INPUT_PROMPT
        BSR PARSE_ADDR_L
        LEA INPUT_COUNTER, A0
        MOVE.L D5, (A0)
*get ending address
        LEA PROMPT, A1
        BSR PRINT
        BSR INPUT_PROMPT
        BSR PARSE_ADDR_L
        LEA INPUT_END, A0
        MOVE.L D5, (A0)     
        
*mainloop
MNLP    Move.L #$00000002, D6 *by default go opcode length
        LEA INPUT_COUNTER, A1
        LEA INPUT_END, A2
        MOVEA.L (A1), A3
        MOVE.W (A3), D4 *opcode only word length
        MOVE.L (A1), D5
        MOVE.L (A2), A6
        
        MOVEM.L D0-D5/D7/A0-A6, -(SP)
        *SUBROUTINE*
        BSR ADD_SUBROUTINE
        *since I only have add available right now, no point in hexgroup checking
        *TODO: hexgroup checking
        MOVEM.L (SP)+, D0-D5/D7/A0-A6
        ADD.L D6, D5
        MOVE.L D5, (A1)
        
        
        CMP.L (A2), D5
        BGE END
        BRA MNLP
    
* Put subroutines here

        INCLUDE "ADD_SUBROUTINE.x68"
        INCLUDE "IO.x68"

****************************************************************
* Contract:
****************************************************************
* Input:        Main->Subroutine contract
* Operation:    Chooses subroutine
* Output:       Subroutine-dependent
****************************************************************
HEXGROUP:
        MOVEM   D0-D7/A0-A6, -(SP)
        *check static opcodes first*
        CMP.W   #$4E71, D4
        BEQ HXNOP
        BRA PHXNOP
HXNOP   *insert NOP subroutine here*      
PHXNOP  CMP.W   #$4E75, D4
        BEQ HXRTS
        BRA PHXRTS
HXRTS   *insert NOP subroutine here*      
PHXRTS  
    
        *separate digits*
        MOVE.B  D4,     D3
        AND.B   #$0F,   D3     *last digit in D3
    
        LSR.L   #4,     D4     *shift to bring next digit to front
     
        MOVE.B  D4,     D2
        AND.B   #$0F,   D2     *second to last digit in D2
    
        LSR.L   #4,     D4     *shift to bring next digit to front
    
        MOVE.B  D4,     D1
        AND.B   #$0F,   D1     *second to last digit in D2
    
        LSR.L   #4,     D4     *shift to bring next digit to front
    
        MOVE.B  D4,     D0
        AND.B   #$0F,   D0     *second to last digit in D2
    
        LSR.L   #4,     D4     *shift to bring next digit to front
        *By this point, the digits 0123 of the opcode should be in D0,D1,D2,D3
    
    
      


****************************************************************
* Contract:
****************************************************************
* Input:        None
* Operation:    ADDRESS_STRING becomes a string equal to user input
* Output:       ADDRESS_STRING
****************************************************************
INPUT_PROMPT:
    MOVEM.L D0/A1, -(SP)
    LEA ADDRESS_STRING, A1
    MOVE.B #2, D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
****************************************************************
* Contract:
****************************************************************
* Input:        ADDRESS_STRING contains a 8-char string
* Operation:    D5 modified
* Output:       Address as hexa in D5
****************************************************************
PARSE_ADDR_L:
    MOVEM.L D0-D4/D6-D7/A1-A6, -(SP)
    LEA ADDRESS_STRING, A1
    MOVEM.W (A1)+, D0-D3
    *now that all the data is in-register, process
    ROR.W #8, D0 *8 for two hexa digits so first char in front
    ROR.W #8, D1
    ROR.W #8, D2
    ROR.W #8, D3
    
    BSR D0_PARSE_D5
    LSL.L #8, D5
    MOVE.W D1, D0
    BSR D0_PARSE_D5
    LSL.L #8, D5
    MOVE.W D2, D0
    BSR D0_PARSE_D5
    LSL.L #8, D5
    MOVE.W D3, D0
    BSR D0_PARSE_D5
    

    MOVEM.L (SP)+, D0-D4/D6-D7/A1-A6
    RTS

*parse string byte in word of D0 to byte in D5
D0_PARSE_D5:
    BSR PARSE_HEXA_D0
    ADD.B  D0, D5
    LSL.B  #4, D5
    LSR.W  #8, D0
    BSR PARSE_HEXA_D0
    ADD.B D0, D5
    RTS


****************************************************************
* Contract:
****************************************************************
* Input:        D0 contains a string hexa digit in its byte field
* Operation:    D0 modified
* Output:       D0 contains hexa digit
* developed for homework 2, modified for mainroutine
****************************************************************
PARSE_HEXA_D0:
            CMP.B #$40, D0  *if D0 > 40
            BGT PHD0_DIG    *then digit  (A-F)
            BLT PHD0_NUM    *else number (0-9)
PHD0_DIG    SUBI.B #$37, D0 *(A-F) = ($41-$46)
            BRA PHD0_POST
PHD0_NUM    SUBI.B #$30, D0 *(0-9) = ($30-$39)
PHD0_POST   RTS


* Put variables and constants here
CR              EQU $0D
LF              EQU $0A
PROMPT          DC.B    'Enter an address: ',0
INPUT_COUNTER   DC.L    $CCCCCCCC
INPUT_END       DC.L    $CCCCDDDD
ADDRESS_STRING  DC.B    'CCCCCCCC',0

END:    SIMHALT             ; halt simulator
        END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

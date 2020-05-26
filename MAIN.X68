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
        BSR HEXGROUP
        *since I only have add available right now, no point in hexgroup checking
        *TODO: hexgroup checking        *one difference in terms of error recovery I think is INPUT_COUNTER and INPUT_END
        MOVEM.L (SP)+, D0-D5/D7/A0-A6
        ADD.L D6, D5
        MOVE.L D5, (A1)
        
        
        CMP.L (A2), D5
        BGE END
        BRA MNLP
    
* Put subroutines here

        INCLUDE "ADD_SUBROUTINE.x68"
        INCLUDE "BCC_SUBROUTINE.x68"
        INCLUDE "SHIFT_SUBROUTINE.x68"
        INCLUDE "IO.x68"

****************************************************************
* Contract:
****************************************************************
* Input:        Main->Subroutine contract
* Operation:    Chooses subroutine
* Output:       Subroutine-dependent
****************************************************************
HEXGROUP:
        MOVEM.L   D0-D7/A0-A6, -(SP)    *saving registers at start of subroutine as I edit them 
        *check static opcodes first*
        CMP.W   #$4E71, D4              *NOP = 4E71
        BEQ HXNOP                       *Hex NOP branches to the subroutine
        BRA PHXNOP                      *PHXNOP = Post Hex NOP = after the check, check other opcodes
HXNOP   MOVEM.L   (SP)+, D0-D7/A0-A6    *HXNOP = Hex NOP
        *insert NOP subroutine here*    *Will need to insert NOP subroutine here 
        RTS                             *return after subroutine execution
PHXNOP  CMP.W   #$4E75, D4              *Post Hex NOP, check for RTS = 4E75
        BEQ HXRTS                       *if == 4E75 go to Hex RTS
        BRA PHXRTS                      *otherwise post hex rts check other opcodes
HXRTS   MOVEM.L   (SP)+, D0-D7/A0-A6    *HXRTS = Hex RTS check is true, go to RTS subroutine
        *insert RTS subroutine here*   
        RTS                             *return after RTS subroutine
PHXRTS  *separate digits*               *Post Hex RTS = after the Hex RTS check
        MOVE.B  D4,     D3              *opcode->D3 
        AND.B   #$0F,   D3              *last digit in D3
    
        LSR.L   #4,     D4              *shift to bring next digit to front
     
        MOVE.B  D4,     D2
        AND.B   #$0F,   D2              *second to last digit in D2
    
        LSR.L   #4,     D4              *shift to bring next digit to front
    
        MOVE.B  D4,     D1
        AND.B   #$0F,   D1              *second to last digit in D2
    
        LSR.L   #4,     D4              *shift to bring next digit to front
    
        MOVE.B  D4,     D0
        AND.B   #$0F,   D0              *second to last digit in D2
    
        LSR.L   #4,     D4              *shift to bring next digit to front
****************************************************************************************
        *By this point, the digits 0123 of the opcode should be in D0,D1,D2,D3
****************************************************************************************
        CMP.B   #$04,   D0  *check if it's group four
        BEQ HXG4            *if it is branch to Hex Group Four (HXG4)
        BRA PHXG4           *if it is not branch to Post Hex Group Four
HXG4    CMP.B   #$0E,   D1  *after this, known: 4E
        BEQ HXG41           *HXGroup 4 #1 = passed first check, check more digits for JSR
        BRA PHXG41          *PHXG41 = failed first check, check a different opcode in group 4
HXG41   CMP.B   #$09,   D2  *Known is 4E, check for 4E9
        BEQ HXG42           *if so it passes
        CMP.B   #$0B,   D2  *after this, known: 4E(9||B) 
        BNE PHXG41          *if it's not 4E9 but it is 4EB it passes         
HXG42   CMP.B   #$09,   D3  *after this, known: 4E(9||B)(0-9)
        BGT PHXG41          *if the last digit is less than or equal to 9 it passes (not greater than 9)
HXJSR   MOVEM.L   (SP)+, D0-D7/A0-A6    *pop the registers back for JSR
        *insert jsr subroutine here* 
        RTS                             *return after JSR
PHXG41  CMP.B   #$06,   D1              *If it's not JSR (Post hexgroup41)
        BNE PHXNOT1                     *if it's not 46 then it's not NOT
        CMP.B   #$0B,   D2              *
        BGT PHXNOT1
        MOVEM.L   (SP)+, D0-D7/A0-A6    *the pop here restores the registers to the mainloop contract
        *insert NOT subroutine here*    *the subroutine call here will end with D6 in the correct place
        RTS                             *this will return to the mainloop
PHXNOT1 MOVE.B  D1,     -(SP)
        AND.B   #$01,   D1
        CMP.B   #$00,   D1
        BEQ     PHXLEA      *if least significant bit is 0 then not odd, therefore not lea
        CMP.B   #$0D,   D2
        BEQ HXLEAZ9
        CMP.B   #$0F,   D2
        BNE PHXLEA
HXLEAZ9 CMP.B   #$09,   D3
        BGT PHXLEA        
        MOVE.B  (SP)+,  D1
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert LEA subroutine here*
        RTS
PHXLEA  MOVE.B  (SP)+,  D1
        CMP.B   #$08,   D1
        BEQ HXMVM2
        CMP.B   #$0C,   D1
        BNE HX4ERR
HXMVM2  CMP.B   #$08,   D2
        BLT HX4ERR
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert MOVEM subroutine here*
        RTS
HX4ERR  *insert error message here* 
        RTS   
PHXG4   CMP.B   #$04,   D0
        BGE PHXGM           *Hexgroup Move is 1-3
        CMP.B   #$00,   D0
        BEQ PHXGM
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert MOVE/MOVEA subroutine here*
        RTS
PHXGM   CMP.B   #$07,   D0
        BNE PHXMQ
        MOVE.B  D1,     -(SP)
        AND.B   #$01,   D1
        CMP.B   #$00,   D1
        BNE PHXMQ0
        MOVE.B  (SP)+,  D1
        MOVEM.L (SP)+,  D0-D7/A0-A6
        *insert MOVEQ subroutine here*
        RTS
PHXMQ0  MOVE.B (SP)+,   D1
PHXMQ   CMP.B   #$0D,   D0
        BNE PHXADD
        MOVEM.L   (SP)+, D0-D7/A0-A6
        BSR ADD_SUBROUTINE
        RTS
PHXADD  CMP.B   #$05,   D0
        BNE PHXADQ
        MOVE.B  D1,     -(SP)
        AND.B   #$01,   D1
        CMP.B   #$00,   D1
        BNE PHXADQ0
        MOVE.B  (SP)+,  D1
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert ADDQ subroutine here*
        RTS
PHXADQ0 MOVE.B  (SP)+,  D1
PHXADQ  CMP.B   #$09,   D0
        BNE PHXSUB
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert SUB subroutine here*
        RTS  
PHXSUB  CMP.B   #$0C,   D0
        BNE PHXAND
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert AND subroutine here*
        RTS
PHXAND  CMP.B   #$08,   D0
        BNE PHXOR
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert OR subroutine here*
        RTS  
PHXOR   CMP.B   #$0E,   D0
        BNE PHXSHFT
        MOVEM.L   (SP)+, D0-D7/A0-A6
        BSR SHIFT_SUBROUTINE
        RTS
PHXSHFT CMP.B   #$06,   D0
        BNE PHXSIX
        MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert BRANCH subroutine here*
        BSR BCC_SUBROUTINE
        RTS
PHXSIX  MOVEM.L   (SP)+, D0-D7/A0-A6
        *insert ERROR message here*
        RTS


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

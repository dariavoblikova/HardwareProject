*-----------------------------------------------------------
* Title      : MOVE Parser
* Written by : Alexander A Dietrich
* Date       : 5/24/2020
* Description: Parses a move, fulfills contract.
*00(      )(destination  )(source       )
*00(size*2)(reg*3)(mode*3)(mode*3)(reg*3)
*-----------------------------------------------------------

MOVE_SUBROUTINE:
            MOVE.L D5, -(SP)    *store so we can use it
************************************************************************    
* print opcode, size
************************************************************************
            LEA MOVE_ST, A1
            BSR PRINT
            MOVE.W  D4,     D0  *move to D0 to check size
            AND.W   #$F000, D0  *only keep hex dig with size
            CMP.W   #$1000, D0  *byte is size 1
            BEQ MOVE_PRINTB
            CMP.W   #$3000, D0  *for some reason only the easy68k dev knows, 3 is word
            BEQ MOVE_PRINTW
            CMP.W   #$2000, D0  *why? why is long less than word? 
            BEQ MOVE_PRINTL
MOVE_PRINTB LEA BDISP, A1
            *since it's convenient format opmode size here*
            MOVE.L #$00000000, D3
            BRA POST_MOVE_SIZE
MOVE_PRINTW LEA WDISP, A1
            *since it's convenient format opmode size here*
            MOVE.L #$00000001, D3
            BRA POST_MOVE_SIZE
MOVE_PRINTL LEA LDISP, A1
            *since it's convenient format opmode size here*
            MOVE.L #$00000002, D3
POST_MOVE_SIZE 
            BSR PRINT
            LEA SPACE, A1
            BSR PRINT
************************************************************************    
* initial parsing: D1 = source reg, D2 = source mode, D3 = size in opmode
* format, D5 = input program counter
* see "print opcode, size" for D3
************************************************************************
            MOVE.L  D4, D1
            MOVE.L  D4, D2
            AND.W #$0007, D1
            AND.W #$003F, D2
            LSR.W #3, D2
            BSR EAPRINT
            LEA COMMA, A1
            BSR PRINT
            LEA SPACE, A1
            BSR PRINT
************************************************************************    
* determine increment 1
************************************************************************   
            MOVE.L  #$00000002, D6         
            BSR MOVE_INCREMENT
************************************************************************    
* second parsing: D1 = dest reg, D2 = dest mode
*00(      )(destination  )(source       )
*00(size*2)(reg*3)(mode*3)(mode*3)(reg*3)
*00ss rrrm mmMM MRRR
************************************************************************  
            MOVE.L D4, D1
            MOVE.L D4, D2
            AND.W #$0E00, D1
            AND.W #$01C0, D2
            LSR.W #8, D1
            LSR.W #1, D1
            LSR.W #6, D2
            ADD.L D6, D5
            SUBI.L #2, D5   *subtract the two from opcode as EAPRINT adds it by default
            BSR EAPRINT
            BSR MOVE_INCREMENT  *determine increment 2
            MOVE.L (SP)+, D5    *restore
            RTS
                



MOVE_INCREMENT:           
                CMP.B   #$04, D2
                BGT MV_ADR_CHK
                BRA POST_MV_INC1
MV_ADR_CHK      CMP.B   #$04, D1    *mode == 7 reg == 4 then immediate
                BEQ MV_IMM
                CMP.B   #$00, D1    *mode == 7 reg == 0 then word address
                BEQ MV_WADDR
                ADD.L   #$00000004, D6  *must be long addr
                BRA POST_MV_INC1
MV_WADDR        ADD.L   #$00000002, D6
                BRA POST_MV_INC1
MV_IMM          ADD.L   D3, D6                    
                ADD.L   D3, D6    *increment = size*2 + 2 if mode is #<>
POST_MV_INC1    *TODO: check increment out of bounds here*
                RTS
                


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

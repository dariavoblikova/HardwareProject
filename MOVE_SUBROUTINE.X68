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
            MOVE.W D4, D0       *check MOVEA
            AND.W   #$01C0, D0  *mask the destination mode bits 
            CMP.W   #$0040, D0  *check if the bits signify MOVEA (001)
            BNE MOVE_PRINT      *if not it's move
            LEA MOVEA_ST, A1    *if so load MOVEA
            BRA MOVE_PRINT2     
MOVE_PRINT  LEA MOVE_ST, A1     *if it's not MOVEA load MOVE
MOVE_PRINT2 BSR PRINT           *print whichever was loaded
            MOVE.W  D4,     D0  *move to D0 to check size
            AND.W   #$F000, D0  *only keep hex dig with size
            CMP.W   #$1000, D0  *byte is size 1
            BEQ MOVE_PRINTB     
            CMP.W   #$3000, D0  *for some reason only the easy68k dev knows, 3 is word
            BEQ MOVE_PRINTW
            CMP.W   #$2000, D0  *why? why is long less than word? 
            BEQ MOVE_PRINTL
MOVE_PRINTB LEA BDISP, A1   *load byte display
            *since it's convenient format opmode size here*
            MOVE.L #$00000000, D3
            BRA POST_MOVE_SIZE
MOVE_PRINTW LEA WDISP, A1   *load word display
            *since it's convenient format opmode size here*
            MOVE.L #$00000001, D3
            BRA POST_MOVE_SIZE
MOVE_PRINTL LEA LDISP, A1   *load long display
            *since it's convenient format opmode size here*
            MOVE.L #$00000002, D3
POST_MOVE_SIZE 
            BSR PRINT       *print size
            LEA SPACE, A1   *print a space ('MOVE.X ' or 'MOVEA.X ')
            BSR PRINT
************************************************************************    
* initial parsing: D1 = source reg, D2 = source mode, D3 = size in opmode
* format, D5 = input program counter
* see "print opcode, size" for D3
************************************************************************
            MOVE.L  D4, D1      *source reg
            MOVE.L  D4, D2      *source mode
            AND.W #$0007, D1    *separate reg bits
            AND.W #$003F, D2    *separate mode bits (needs shift to front)
            LSR.W #3, D2        *shift to front
            BSR EAPRINT         *now we fulfill EAPRINT's contract (D1 = reg, D2 = mode, D3 = opmode size, D5 = input PC)
            LEA COMMA, A1       *after printing EA print ', '
            BSR PRINT
            LEA SPACE, A1       *('MOVE.X EA, ' or 'MOVEA.X EA, ')
            BSR PRINT
************************************************************************    
* determine increment 1
************************************************************************   
            MOVE.L  #$00000002, D6         *init at 2 as most EA's don't need more than opcode displacement (2)
            BSR MOVE_INCREMENT             *increase D6 if it's the rare EA's that increment more ($.W $.L #<>)
************************************************************************    
* second parsing: D1 = dest reg, D2 = dest mode
*00(      )(destination  )(source       )
*00(size*2)(reg*3)(mode*3)(mode*3)(reg*3)
*00ss rrrm mmMM MRRR
************************************************************************  
            MOVE.L D4, D1       *dest reg
            MOVE.L D4, D2       *dest mode
            AND.W #$0E00, D1    *separate reg bits
            AND.W #$01C0, D2    *separate mode bits
            LSR.W #8, D1        *shift to front (9 positions)
            LSR.W #1, D1
            LSR.W #6, D2        *shift to front (6 positions)
            ADD.L D6, D5        *add displacement to print the next EA in memory
            SUBI.L #2, D5       *negate the two from opcode as EAPRINT adds it by default
            BSR EAPRINT         *('MOVE.X EA, EA' or 'MOVEA.X EA, EA')
            BSR MOVE_INCREMENT  *determine increment 2
            MOVE.L (SP)+, D5    *restore before return
            RTS
                



MOVE_INCREMENT:           
                CMP.B   #$04, D2    *if it's <= 4 then it's an EA that doesn't have special displacement
                BGT MV_ADR_CHK      *therefore >4 have to check special displacements
                BRA POST_MV_INC1    *otherwise just go return
MV_ADR_CHK      CMP.B   #$04, D1    *mode == 7 reg == 4 then immediate displacement
                BEQ MV_IMM          *go to immediate protocol
                CMP.B   #$00, D1    *mode == 7 reg == 0 then word address displacement
                BEQ MV_WADDR        *go to word address protocol
                ADD.L   #$00000004, D6  *must be long address displacement (4 extra mem locations as it's byte addressable)
                BRA POST_MV_INC1    *go to end
MV_WADDR        ADD.L   #$00000002, D6  *word address is 2 extra bytes
                BRA POST_MV_INC1    * go to end
MV_IMM          ADD.L   D3, D6                    
                ADD.L   D3, D6    *increment = size*2 + 2 if mode is #<>
POST_MV_INC1    *TODO: check increment out of bounds here*
                RTS
                



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

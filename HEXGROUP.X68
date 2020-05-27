*-----------------------------------------------------------
* Title      :  HEXGROUP    
* Written by :  Alexander A Dietrich
* Date       :  5/25/2020
* Modified by:
* Date       :
* Description:  Chooses a subroutine to branch to based on opcode.
*-----------------------------------------------------------
HEXGROUP:
        MOVE.W  D4,D3                   * use D3 for masking so we don't lose opcode in D4
        ANDI.W  #$FF00,D3               * mask word to look at leftmost byte
        CMP.W   #$4E00,D3               * check if word could be a NOP, JSR, or RTS opcode
        BEQ     FOUREOP                 * branch to call subroutine that decodes this opcode
        
FOUREOP  JSR    NOP_RTS_JSR             * subroutine to decode one of three opcodes
        CMP.W   #$1,D6                  * our check to see if opcode was invalid
        BNE     DONE                    * if not equal, we decoded opcode and can leave subroutine
* this can be the format for the rest of the file, HEXGROUP continuously masks word and sees if 
* it matches with opcode(s), branch to label if equal to do a JSR. Then, check if displacement is
* set to 1, if so, we know the opcode was invalid, so we either keep moving through the code if 
* there is a chance the opcode could be found somewhere else, or we leave subroutine to print
* error message.


       

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
        *insert SHIFT subroutine here
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

DONE    RTS                             * leave subroutine



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

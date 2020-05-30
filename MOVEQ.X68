*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:  Decodes the MOVEQ opcode.
*-----------------------------------------------------------

* we come into this subroutine assuming that the leftmost nibble is a 7.
MOVEQ:                  
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6
* First mask all but the 8th bit from the left, to see if it is set to 0
    MOVE.L  D4,D3
    ANDI.L  #$0100,D3
    CMP.L   #$0000,D3
    BNE     INVALID_MOVEQ    * if not set to 0, we know the opcode is invalid
    
* mask opcode word to get register number
    MOVE.L  #$2,D6          * displacement will always be 2, no EA's
    MOVE.L  D4,D3
    ANDI.L  #$0E00,D3
    LSR.L   #8,D3           * shift register number to the right
    LSR.L   #1,D3
    MOVE.L  D3,D2           * D2 will store register number
    BRA     MOVEQ_DATA

* get low order byte, which holds the data, then print output
MOVEQ_DATA  MOVE.L  D4,D3
    ANDI.L  #$00FF,D3
    MOVE.L  D3,D1
    LEA     MOVEQ_CODE,A1
    MOVE.L  #14,D0
    TRAP    #15
    LEA     MOVEQ_POUND,A1
    TRAP    #15
    MOVE.L  D1, -(SP)   *safe replacement for trap 15
    MOVE.L  D1, D0
    BSR ADAPTIVE_PRINTREG
    MOVE.L  (SP)+, D1
    LEA     MOVEQ_COMMA,A1
    MOVE.L  #14,D0
    TRAP    #15
    LEA     MOVEQ_DREG,A1
    TRAP    #15
    MOVE.L  D2,D1
    MOVE.L  D1, -(SP)   *safe replacement for trap 15
    MOVE.L  D1, D0
    BSR PRINTHEX
    MOVE.L  (SP)+, D1   
    BRA     MOVEQ_DONE
    
* opcode is only invalid if bit 8 in the instruction format isn't a 0  
INVALID_MOVEQ  JSR   INVALID
        BRA     MOVEQ_DONE
        
MOVEQ_DONE  MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6
            RTS     *Return to subroutine here
  
    *SIMHALT             ; halt simulator

* Put variables and constants here
MOVEQ_CODE  DC.B    'MOVEQ  ',0
MOVEQ_DREG  DC.B    'D',0
MOVEQ_POUND DC.B    '#',0
MOVEQ_COMMA DC.B    ',',0

    *END    MOVEQ        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

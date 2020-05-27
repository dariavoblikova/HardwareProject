*-----------------------------------------------------------
* Title         :   Decoding Branch Opcodes
* Written by    :   Amman Nega
* Date          :   May 10, 2020
* Modified by   :   Alexander A Dietrich
* Date          :   5/26/2020
* Description   :   Decodes word to identify the type of branching operation
*-----------------------------------------------------------

* Enter this subroutine when we know we have a Branch instruction
* that we want to decode. Assuming that a word was given to us
* hexadecimal in data register 4. Based on this word, this subroutine
* will print to console if this is a BEQ, BLE, BGT, or BRA opcode.
* Parameters:
* D4: contains word we will decode to specific Bcc opcode
* D5: contains long representing current PC location
BCC_SUBROUTINE:
        BSR DISP_BRANCH_TYPE
        BSR DISP_DISPLACEMENT
        RTS


DISP_DISPLACEMENT:
        MOVE.L  A0,     -(SP)   
        MOVE.L  D5,     -(SP)   *set up A0
        ADDI.L  #2,     D5
        MOVE.L  D5,     A0
        MOVE.L  (SP)+,  D5
        
        CMP.B   #$FF,   D4  *least significant byte contains displacement
        BEQ DPLC32
        CMP.B   #$00,   D4
        BEQ DPLC16
        
DPLC8   MOVE.L  D0,     -(SP)
        MOVE.L  D4,     D0    *if 8 bit then displacement contained in-opcode
        ROL.B   #4,     D0
        BSR PRINTHEX
        ROL.B   #4,     D0
        BSR PRINTHEX
        MOVE.L  (SP)+,  D0      *restore D0
        MOVE.L  (SP)+,  A0      *restore A0 before returning
        MOVE.L  #$00000002, D6
        RTS
        
DPLC16  MOVE.L  D0,     -(SP)
        MOVE.W  (A0),   D0
        
        ROL.W   #4,     D0
        BSR PRINTHEX
        ROL.W   #4,     D0
        BSR PRINTHEX
        ROL.W   #4,     D0
        BSR PRINTHEX
        ROL.W   #4,     D0
        BSR PRINTHEX

        MOVE.L  (SP)+,  D0      *restore D0
        MOVE.L  (SP)+,  A0      *restore A0 before returning
        MOVE.L  #$00000004, D6
        RTS

DPLC32  MOVE.L  D0,     -(SP)
        MOVE.L  (A0),   D0
        BSR PRINTREG
        MOVE.L  (SP)+,  D0      *restore D0
        MOVE.L  (SP)+,  A0      *restore A0 before returning
        MOVE.L  #$00000006, D6
        RTS

*Contract:
*Input: D4 contains opcode
*Operation: stack/register idempotent
*Output: Prints which type of branch
DISP_BRANCH_TYPE:
        MOVE.W  D4,     -(SP)
        LSR     #8,     D4
        
        CMP.B   #$67,   D4 * check if this is a BEQ opcode
        BNE BTLC
        LEA opcode_BEQ, A1
        BRA BTCE
        
BTLC    CMP.B   #$6F,   D4 * check if this is a BLE opcode
        BNE BTGC
        LEA opcode_BLE, A1
        BRA BTCE
        
BTGC    CMP.B   #$6E,   D4 * check if this is a BGT opcode
        BNE BTAC
        LEA opcode_BGT, A1
        BRA BTCE
    
BTAC    CMP.B   #$60,D4 * check if this is a BRA opcode
        BNE BTCF
        LEA opcode_BRA, A1
        BRA BTCE
        
BTCF    *insert error message*
        MOVE.W  (SP)+, D4
        RTS
        
BTCE    BSR PRINT
        MOVE.W  (SP)+,  D4
        RTS
    
    
    
    


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

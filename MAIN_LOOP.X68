*-----------------------------------------------------------
* Title      : Main Subroutine (decoding opcodes loop)
* Written by : Daria Voblikova
* Date       : 5/25/2020
* Description: Gets starting address from A5 and ending address from A6, parses memory and opcodes
* A5 first hold starting address and then serves as a current address
*-----------------------------------------------------------
    * ORG    $1000
    
CR      EQU     $0D
LF      EQU     $0A

MAIN_LOOP   MOVEM.L     D0-D7/A0-A6, -(SP)          * save all registers 
            CMPA.L      A5,A6                       * A6-A5
            BLE         EXIT_MAIN_LOOP              * IF A6<=A5, we are done
            JSR         PRINT_CURR_ADDR             * Print current memory location to the console
            MOVE.W      (A5),D4                     * Load opcode word to D4, subroutines use it
            
            LEA         TAB,A1                      * Print tab
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print tab
            
            * check if NOP/JSR/RTS opcode
            MOVE.W      D4,D3                   * use D3 for masking so we don't lose opcode in D4
            ANDI.W      #$FF00,D3               * mask word to look at leftmost byte
            CMP.W       #$4E00,D3               * check if word could be a NOP, JSR, or RTS opcode
            BEQ         FOUREOP                 * branch to call subroutine that decodes this opcode
                       
            * check for type of MOVEM
            CMP.W       #$4800,D3
            BEQ         REGMEMOP
            
            CMP.W       #$4C00,D3
            BEQ         MEMREGOP
            
            * check if shift opcode (LSL,ROL,ASL)
            MOVE.W      D4,D3
            ANDI.W      #$F000,D3
            CMP.W       #$E000,D3
            BEQ         SHIFTOP  

            * check if Bcc opcode
            CMP.W       #$6000,D3
            BEQ         BCCOP           
        
FOUREOP     JSR         NOP_RTS_JSR             * subroutine to decode one of three opcodes
            JSR         DISP1        
            *BRA        branch to where we would print the error message
            
REGMEMOP    JSR         REG_MEM             * subroutine to decode one of three opcodes
            JSR         DISP1        
            *BRA        branch to where we would print the error message

MEMREGOP    JSR         MEM_REG             * subroutine to decode one of three opcodes
            JSR         DISP1        
            *BRA        branch to where we would print the error message
           
BCCOP       JSR         BCC                     * jump to subroutine that decodes Bcc opcodes
            JSR         DISP1
            *BRA        branch to where we would print the error message

SHIFTOP     JSR         SHIFT_OPCODES
            JSR         DISP1
            *BRA        branch to where we would print the error message

* check if opcode was decoded or not
DISP1       CMP.W       #$1,D6                  * our check to see if opcode was invalid
            BNE         EXIT_MAIN_LOOP          * if not equal, we decoded opcode and can leave subroutine
            RTS            



* this can be the format for the rest of the file, HEXGROUP continuously masks word and sees if 
* it matches with opcode(s), branch to label if equal to do a JSR. Then, check if displacement is
* set to 1, if so, we know the opcode was invalid, so we either keep moving through the code if 
* there is a chance the opcode could be found somewhere else, or we leave subroutine to print
* error message.

            LEA         NEWLINE,A1                  * Print new line
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print new line

            BRA         MAIN_LOOP                   * If not done yet, branch to MAIN_LOOP
        
PRINT_CURR_ADDR
            MOVEM.L     D0-D7/A0-A6, -(SP)          * Save all registers 
            BSR         CLEAR_REGISTERS             * Clears all registers except for A5 and A6 that has current and ending addresses
            MOVE.L      A5,D1                       * Move current address to D1 for printing
            MOVE.B      #16,D2                      * Base 16 for for trap 15 task 15
            MOVE.B      #15,D0                      * Task 15 for printing desired base
            TRAP        #15                         * Trap 15, print current address
            MOVEM.L     (SP)+, D0-D7/A0-A6          * Pop the registers back
            RTS
            
CLEAR_REGISTERS                                     * Clear all registers except for starting (A5) and ending(A6) address
            CLR.L   D0
            CLR.L   D5
            CLR.L   D2
            CLR.L   D1
            CLR.L   D3
            CLR.L   D4
            CLR.L   D6
            MOVE.L  #$00000000,A1
            MOVE.L  #$00000000,A2
            MOVE.L  #$00000000,A3
            MOVE.L  #$00000000,A4
            RTS

EXIT_MAIN_LOOP  MOVEM.L     (SP)+, D0-D7/A0-A6      * pop the registers back
                RTS
          
NEWLINE       DC.B    '',CR,LF,0
TAB           DC.B    '    ',0
    
    INCLUDE 'strings.X68'                   Put all the strings here and give them good names

    INCLUDE 'INVALID.X68'
    INCLUDE 'NOP_RTS_JSR.X68'             Decoding NOP, RTS, JSR opcodes
    INCLUDE 'SHIFT_OPCODES.X68'
    INCLUDE 'Bcc.X68'                         Decoding Branch Opcodes
    INCLUDE 'REG_MEM.X68'
    INCLUDE 'MEM_REG.X68'

        * INCLUDE 'NOP_RTS_JSR.X68'             Decoding NOP, RTS, JSR opcodes

 * SIMHALT                                 ; halt simulator

* STOP:
    * END    MAIN_LOOP                             ; last line of source













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

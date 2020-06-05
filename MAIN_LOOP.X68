*-----------------------------------------------------------
* Title      : Main Subroutine (decoding opcodes loop)
* Written by : Daria Voblikova, Alexander Dietrich, Amman Zenebe Nega
* Date       : 5/25/2020
* Description: Gets starting address from A5 and ending address from A6, parses memory and opcodes
* A5 first hold starting address and then serves as a current address
*-----------------------------------------------------------
    * ORG    $1000
    
* CR      EQU     $0D
* LF      EQU     $0A

MAIN_LOOP   MOVEM.L     D0-D7/A0-A6, -(SP)          * save all registers 
MAIN_LOOPS  MOVE.L      A5,D5
            CMPA.L      A5,A6                       * A6-A5 (MAIN_LOOPS for MAIN_LOOP start, fixes stack issue with saving each loop)
            BLE         EXIT_MAIN_LOOP              * IF A6<=A5, we are done
            
            CMP.B       #30,LINECOUNTER             * Screen is 32-lines long, check if line counter is almost full, one line need to print prompt plus one more to be save if we print new line
            BNE         CONTINUE_MAIN_LOOPS         * If line counter is not maxed out yet, move on
            JSR         INPUT_ENTER                 * Screen is full, prompt user to press enter
CONTINUE_MAIN_LOOPS JSR PRINT_CURR_ADDR             * Print current memory location to the console
            MOVE.W      (A5),D4                     * Load opcode word to D4, subroutines use it
            
            LEA         TAB,A1                      * Print tab
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print tab
            
            * check if NOP/JSR/RTS opcode
            MOVE.W      D4,D3                       * use D3 for masking so we don't lose opcode in D4
            CLR.L       D7
            MOVE.W      D4,D7                       * use D7 for when we print invalid opcode as data( because we lose the opcode in D4 when we jsr to opcodes)
            ANDI.W      #$FF00,D3                   * mask word to look at leftmost byte
            CMP.W       #$4E00,D3                   * check if word could be a NOP, JSR, or RTS opcode
            BEQ         FOUREOP                     * branch to call subroutine that decodes this opcode
                       
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
            
            *check if ADD opcode
            MOVE.W  D4, D3
            AND.W   #$F000, D3
            CMP.W   #$D000, D3
            BEQ ADDOP
            *check if SUB opcode
            CMP.W   #$9000, D3                      *almost over 9000
            BEQ ADDOP                               *SUB included in ADD as they're the same other than first hex digit
            *check if AND opcode
            CMP.W   #$C000, D3
            BEQ ADDOP
            *check if OR opcode
            CMP.W   #$8000, D3
            BEQ ADDOP
            *check if ADDQ opcode
            CMP.W   #$5000, D3
            BEQ ADDOP
MLAFTERADD            
            *check if NOT opcode
            MOVE.W  D4, D3
            AND.W   #$FF00, D3
            CMP.W   #$4600, D3
            BEQ NOTOP
            
            * check if LEA opcode
            MOVE.W  D4,D3
            AND.W   #$F000,D3
            CMP.W   #$4000,D3
            BEQ     LEAOP
            
            * check if MOVEQ opcode
            MOVE.W  D4,D3
            AND.W   #$F000,D3
            CMP.W   #$7000,D3
            BEQ     MOVEQOP
            
            *check if MOVE opcode
            MOVE.W D4, D3
            AND.W   #$F000, D3
            CMP.W   #$0000, D3
            BEQ DATA
            CMP.W   #$3000, D3
            BGT DATA
            BRA MOVEOP                              * first nibble in MOVE and MOVEA is 1, 2, or 3
            
            
DATA        JSR INVALID
            BRA LOOP_CHECK
            
LOOP_CHECK  CMP.W       #$1,D6                      * our check to see if opcode was invalid
            BNE         NOT_ERROR
            BRA         ERROR   
NOT_ERROR   ADD.L       D6, A5                      * Increment current address by displacement
            
            LEA         NEWLINE,A1                  * Print new line
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print new line
            
            ADD.B       #01,LINECOUNTER             * Increment line counter
            BRA MAIN_LOOPS


NOTOP       JSR NOT
            BRA LOOP_CHECK
            
LEAOP       JSR LEA
            BRA LOOP_CHECK
           
MOVEQOP     JSR MOVEQ
            BRA LOOP_CHECK

ADDOP       JSR ADD_SUBROUTINE
            CMP.L #$FFFFFFFF, D6
            BEQ ADDOPERR
            BRA LOOP_CHECK
            
ADDOPERR    MOVE.L #$00000002, D6
            BRA ERROR

MOVEOP      JSR MOVE_SUBROUTINE
            CMP.L #$FFFFFFFF, D6
            BEQ ADDOPERR
            BRA  LOOP_CHECK       
        
FOUREOP     JSR         NOP_RTS_JSR                 * subroutine to decode one of three opcodes
            BRA         LOOP_CHECK        
            
REGMEMOP    JSR         REG_MEM                     * subroutine to decode one of three opcodes
            BRA         LOOP_CHECK         

MEMREGOP    JSR         MEM_REG                     * subroutine to decode one of three opcodes
            BRA         LOOP_CHECK         
           
BCCOP       JSR         BCC                         * jump to subroutine that decodes Bcc opcodes
            BRA         LOOP_CHECK 

SHIFTOP     JSR         SHIFT_OPCODES
            BRA         LOOP_CHECK 


* opcode error message can go in place of ERROR label (ex. XXXXXXXX DATA YYYY)
ERROR       LEA         DATA_STRING, A1             * data message
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print new line
            
            LEA         TAB,A1                      * Print tab
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print tab
                        
            MOVE.L      D7,D1                       * Move current data(bad opcode) to D1 for printing
            MOVE.B      #16,D2                      * Base 16 for for trap 15 task 15
            MOVE.B      #15,D0                      * Task 15 for printing desired base
            TRAP        #15                         * Trap 15, print current address

            MOVE.B       #2,D6
            BRA         NOT_ERROR

EA_ERROR    LEA         EAERROR_MESSAGE,A1          * invalid EA error message
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print new line
            ADD.B       #01,LINECOUNTER             * Printed an error, need to increment line counter
            MOVE.B      #2, D6
            BRA         NOT_ERROR           


* this can be the format for the rest of the file, HEXGROUP continuously masks word and sees if 
* it matches with opcode(s), branch to label if equal to do a JSR. Then, check if displacement is
* set to 1, if so, we know the opcode was invalid, so we either keep moving through the code if 
* there is a chance the opcode could be found somewhere else, or we leave subroutine to print
* error message.
        
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
            CLR.L   D1
            CLR.L   D2
            CLR.L   D3
            CLR.L   D4
            CLR.L   D5
            CLR.L   D6
            CLR.L   D7
            MOVE.L  #$00000000,A0
            MOVE.L  #$00000000,A1
            MOVE.L  #$00000000,A2
            MOVE.L  #$00000000,A3
            MOVE.L  #$00000000,A4
            RTS

EXIT_MAIN_LOOP  MOVEM.L     (SP)+, D0-D7/A0-A6      * pop the registers back
                RTS
          
NEWLINE       DC.B    '',CR,LF,0
TAB           DC.B    '    ',0
    


 * SIMHALT                                 ; halt simulator

* STOP:
    * END    MAIN_LOOP                             ; last line of source


















































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

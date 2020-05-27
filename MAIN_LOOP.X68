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
MAIN_LOOPS  CMPA.L      A5,A6                       * A6-A5
            BLE         EXIT_MAIN_LOOP              * IF A6<=A5, we are done
            JSR         PRINT_CURR_ADDR             * Print current memory location to the console
            MOVE.W      (A5),D4                     * Load opcode word to D4, subroutines use it
            MOVE.L      A5, D5
            
            LEA         TAB,A1                      * Print tab
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print tab
            
            BSR         HEXGROUP               
            ADDA.L      D6, A5                      * Add displacent located in D6 to our current address
            
            LEA         NEWLINE,A1                  * Print new line
            MOVE.B      #14,D0                      * Stores task 14 in D0
            TRAP        #15                         * Task 15, print new line

            BRA         MAIN_LOOPS                   * If not done yet, branch to MAIN_LOOP
        
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

        * INCLUDE 'NOP_RTS_JSR.X68'             Decoding NOP, RTS, JSR opcodes

 * SIMHALT                                 ; halt simulator

* STOP:
    * END    MAIN_LOOP                             ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

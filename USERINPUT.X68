*-----------------------------------------------------------
* Title      :
* Written by : Amman Nega, Daria Voblikova
* Date       : 5/22/2020
* Description: This code asks the user for two 32-bit memory address
* locations to represent a starting and an ending memory address. The long value
* will be stored in D5 for starting address and in D6 for ending address and will be 
* used by the main routine to start reading from memory and decoding opcodes.
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A
num     DS.L    $8700
ex      DS.B    $00

IO                  ; first instruction of program

* Outputs 32-bit long value in A5 representing starting memory address.
* Outputs 32-bit  long value in A6 representing ending memory address.
* Assumptions: Hexadecimal values A-F must be capitalized, lowercase
* letters result in an invalid message and asks the user to input again.

*TODO: Validate addresses are within appropriate range?
GET_ADDRESS_IO
                    MOVEM.L     D0-D7/A0-A4, -(SP)       * Enter subroutine. Saving all the registers(except D5 and D6) to the stack
GET_START_ADDR:        
                    CLR.L       D5                          * Clear D5 register that we'll use for starting address output
                    LEA         InpStartAddrMess,A1         * Loads string into A1
                    MOVE.B      #14,D0                      * Stores our trap task in D0
                    TRAP        #15                         * Performs trap task 14, reading string from A1
                    MOVEA       #$6000,A2
                    CLR.L       D4                          * Clear D4 register used for counter in input routine
                    BRA         INPUT
    
GET_END_ADDR:
                    LEA         NEWL,A1                     * Loads new line string into A1
                    MOVE.B      #14,D0                      * Stores task 14 in D0
                    TRAP        #15                         * Perform trap 15 task 14, reading string from A1
                    LEA         InpEndAddrMess,A1           * Loads string for end address into A1
                    MOVE.B      #14,D0                      * Stores our trap task in D0
                    TRAP        #15                         * Performs trap task 14, reading string from A1
                    MOVEA       #$6000,A2
                    CLR.L       D4                          * Clear D4 register used for counter in input routine (we just finished input for start address)
                    
INPUT               CMP         #$8,D4                      * Check if we should stop looping
                    BEQ         DONE_INPUT                  * Stop inputting after 8 chars
                    MOVE.B      #5,D0                       * Stores our trap task in D0
                    TRAP        #15                         * Performs trap task 5, read a character
                    MOVE.B      D1,D3                       * Move byte to D3, used as parameter for subroutine
                    BRA         CONVERTNUM                  * Branch to subroutine that converts ASCII to hex

CONVERTNUM          CMP.B       #$39,D3                     * Check if input is valid hex digit from 0-9
                    BGT         CONVERTLETTER               * Branch to check if input is a character A-F
                    CMP.B       #$30,D3                     * Check if input is greater than 30
                    BLT         INVALID_HEX                 * Input is not a valid a hex digit
                    SUB.B       #$30,D3                     * Subtract 30 from input to convert ASCII to hex digit
                    ADD.B       #$1,D4                      * Increment D4,keep track of num inputs from user
                    ADD.L       D3,D2                       * Copy hex digit to D2, so we don't lose value
                    CMP.B       #$4,D4  
                    BEQ         SWAP
                    CMP.B       #$8,D4                      * Check if we're done looping
                    BNE         MULT                        * Make room for next hex digit
                    BEQ         SWAP
                    BRA         INPUT                       * Branch to request another input from user

CONVERTLETTER       CMP.B       #$41,D3                     * Check if ASCII character is letters A-F
                    BLT         INVALID_HEX                 * Output that input is invalid hex digit
                    CMP.B       #$46,D3                     * Check if ASCII character is letters A-F
                    BGT         INVALID_HEX                 * Output that input is invalid hex digit
                    SUB.B       #$40,D3                     * Convert ASCII to hex digit
                    ADD.B       #$9,D3                      * Part of conversion from ASCII to hex
                    ADD.B       #$1,D4                      * Increment D4,keep track of num inputs from user
                    ADD.L       D3,D2                       * Copy hex digit to D2, so we don't lose value
                    CMP.B       #$4,D4  
                    BEQ         SWAP
                    CMP.B       #$8,D4                      * Check if we're done looping
                    BNE         MULT                        * Make room for next hex digit
                    BEQ         SWAP
                    BRA         INPUT                       * Branch to request another input from user

MULT                MULS        #$00000010,D2               * Multiply by 10 so we can add second hex digit later
                    BRA         INPUT
        
SWAP                MOVE.W      D2,(A2)+                    * Move the input to memory, one word at a time
                    CLR         D2                          * Clear D2 to make room for data
                    BRA         INPUT                       * Continue to get input

INVALID_HEX         LEA         NEWL,A1
                    MOVE.B      #14,D0
                    TRAP        #15
                    LEA         INV_HEX_MESSAGE,A1          * Load string in A1
                    TRAP        #15                         * Print invalid message
                    BRA         INPUT                       * Re prompt user for valid hex digit

DONE_INPUT          CMP.L       #$0, D5                     * Since we cleared D5 before if it's not 0, it's got starting address already
                    BNE         DONE_END_ADDR               * If not 0 branch to DONE_END_ADDR
                    BEQ         DONE_START_ADDR             * If it's 0 branch to DONE_START_ADRR
                    
DONE_START_ADDR     MOVE.L      -(A2),D5                    * Saving Starting address to D5
                    BRA         GET_END_ADDR

DONE_END_ADDR       MOVE.L      -(A2),D6                    * Saving Ending address to D6
                    BRA         CHECK_INPUTS
                    
CHECK_INPUTS        MOVE.L      D5, A5                      * Preparing output. Copying starting address to A5
                    MOVE.L      D6, A6                      * Preparing output. Copying ending address to A6
                    CMPA.L      A5, A6                      * A6-A5
                    BLE         ADDRESS_INPUT_ERROR         * if A6 <= A5, input error
                    BTST        #0,D5                       * test the least significant bit in D5(starting address), #0 means least significant
                    BNE         NOT_EVEN_ADDRESS            * if the bit is not zero => the address is odd
                    BTST        #0,D6                       * test the least significant bit in D6(endinging address), #0 means least significant
                    BNE         NOT_EVEN_ADDRESS            * if the bit is not zero => the address is odd
                    BRA         SUCCESS_ADDR_INPUT
                    
ADDRESS_INPUT_ERROR LEA         NEWL,A1                     * Loads new line string into A1
                    MOVE.B      #14,D0                      * Stores task 14 in D0
                    TRAP        #15                         * Perform trap 15 task 14, reading string from A1
                    LEA         InvAddresses,A1             * Input doesn't make sense(starting is less than ending). Load error message 
                    MOVE.B      #14,D0                      * Stores task 14 in D0
                    TRAP        #15                         * Perform trap 15 task 14, reading string from A1
                    BRA         GET_START_ADDR              * Starting address is less than ending address. Start over
                    
NOT_EVEN_ADDRESS    LEA         NEWL,A1
                    MOVE.B      #14,D0                      * Stores task 14 in D0
                    TRAP        #15                         * Perform trap 15 task 14, reading string from A1
                    LEA         OddAddrErr,A1               * Load odd address error message
                    MOVE.B      #14,D0                      * Stores task 14 in D0
                    TRAP        #15                         * Perform trap 15 task 14, reading string from A1
                    BRA         GET_START_ADDR              * One of the addresses is odd. Start over
SUCCESS_ADDR_INPUT
                    MOVEM.L     (SP)+, D0-D7/A0-A4          * Returning from subroutine(need to pop saved registers). Returning starting addr in A5 and ending in A6
                    RTS                                     * Return to main routine

     * SIMHALT             ; halt simulator

* Put variables and constants here

* NEWL    DC.B    '',CR,LF,0

     * END         IO   ; last line of source

























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

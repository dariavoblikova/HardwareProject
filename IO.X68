*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A
num     DS.L    $8700
ex      DS.B    $00

IO                  ; first instruction of program

* Put program code here
        LEA MESSAGE,A1  * Loads string into A1
        MOVE.B  #14,D0  * Stores our trap task in D0
        TRAP    #15     * Performs trap task 14, reading string from A1
        MOVEA   #$6000,A2
    
INPUT   CMP     #$8,D4  * Check if we should stop looping
        BEQ     DONE    * Stop inputting after 8 chars
        MOVE.B  #5,D0   * Stores our trap task in D0
        TRAP    #15     * Performs trap task 5, read a character
        MOVE.B  D1,D3   * Move byte to D3, used as parameter for subroutine
        BRA     CONVERTNUM * Branch to subroutine that converts ASCII to hex

CONVERTNUM  CMP.B   #$39,D3 * Check if input is valid hex digit from 0-9
        BGT     CONVERTLETTER  * Branch to check if input is a character A-F
        CMP.B   #$30,D3  * Check if input is greater than 30
        BLT     INVALID  * Input is not a valid a hex digit
        SUB.B   #$30,D3  * Subtract 30 from input to convert ASCII to hex digit
        ADD.B   #$1,D4 * Increment D4,keep track of num inputs from user
        ADD.L   D3,D2  * Copy hex digit to D2, so we don't lose value
        CMP.B   #$4,D4  
        BEQ     SWAP
        CMP.B   #$8,D4 * Check if we're done looping
        BNE     MULT   * Make room for next hex digit
        BEQ     SWAP
        BRA     INPUT  * Branch to request another input from user

CONVERTLETTER   CMP.B   #$41,D3  * Check if ASCII character is letters A-F
        BLT     INVALID * Output that input is invalid hex digit
        CMP.B   #$46,D3 * Check if ASCII character is letters A-F
        BGT     INVALID * Output that input is invalid hex digit
        SUB.B   #$40,D3 * Convert ASCII to hex digit
        ADD.B   #$9,D3  * Part of conversion from ASCII to hex
        ADD.B   #$1,D4  * Increment D4,keep track of num inputs from user
        ADD.L   D3,D2   * Copy hex digit to D2, so we don't lose value
        CMP.B   #$4,D4  
        BEQ     SWAP
        CMP.B   #$8,D4  * Check if we're done looping
        BNE     MULT    * Make room for next hex digit
        BEQ     SWAP
        BRA     INPUT   * Branch to request another input from user

MULT    MULS    #$00000010,D2 * Multiply by 10 so we can add second hex digit later
        BRA     INPUT
        
SWAP    MOVE.W  D2,(A2)+ * Move the input to memory, one word at a time
        CLR     D2       * Clear D2 to make room for data
        BRA     INPUT    * Continue to get input

INVALID LEA     NEWL,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     INV,A1  * Load string in A1
        TRAP    #15     * Print invalid message
        BRA     INPUT   * Re prompt user for valid hex digit

DONE    MOVE.L  -(A2),D5
        RTS     * Return to main routine

    SIMHALT             ; halt simulator

* Put variables and constants here
MESSAGE DC.B    'Input a starting address location: ',0
NEWL    DC.B    ' ',CR,LF,0
INV     DC.B    'Not a hex digit.',CR,LF,0

    END         IO   ; last line of source
*-----------------------------------------------------------
* Title      : ADD parser
* Written by : Alexander A Dietrich
* Date       : 5/24/2020
* Description: Parses an opcode within the memory that has
* been identified as an ADD for EA and other details, and 
* displays what can be deduced about the original command.
*-----------------------------------------------------------
*    ORG    $1000
*START:                  ; first instruction of program
ADD_SUBROUTINE:
************************************************************************ 
*load test data to mimic main routine contract
************************************************************************ 
*D4: Opcode D5: Input Program PC A6: Input Program ending address
        *add an immediate long to D2 = D4BC
        *add an immediate word to D2 = D47C
        *add an immediate byte to D2 = D43C
        *add an long from D3 to A $.W address = D6B8
        *MOVE.W  #$D6B8,     D4  
        *MOVE.L  #$00007336, D5  *vegeta, what does the scouter say about his power level?
        *MOVEA.L #$00009001, A6  */cronch/ it's over 9000!
        *MOVE.L  #$D43C0012, $00007336
        *MOVE.L  #$3456789A, $0000733A
        
************************************************************************    
* initial parsing: D0 = Dn ; D1 = EA reg ; D2 = EA mode ; D3 = opmode
************************************************************************
        MOVE.L  D4,     D0
        MOVE.L  D4,     D1
        MOVE.L  D4,     D2
        MOVE.L  D4,     D3
        BSR     DREG_PARSE
        BSR     REG_PARSE
        BSR     MODE_PARSE
        BSR     OPMODE_PARSE

************************************************************************    
* increment parsing
************************************************************************
        *if ea mode < 5 then D6 is 2 (Dn, An, (An), (An)+, -(An))
        CMP.B   #$05,   D2
        BLT T
        BRA PT
*then
T       MOVE.B  #$02,   D6
        BRA PI
*post then
PT      CMP.B   #$07,   D2  *if opmode == 7 then it's either abs w, abs l, or immediate. otherwise, error
        BNE MODE_ERROR
        *now that it's been proven, check which of the three it is
        CMP.B   #$00,   D1 *if reg == 0 ($.W)
        BEQ T2
        BRA PT2
*then
T2      MOVE.B  #$04,   D6
        BRA PI
*post then
PT2     CMP.B   #$01,   D1  *if reg == 1 ($.L)
        BEQ T3
        BRA PT3
*then
T3      MOVE.B  #$06,   D6
        BRA PI
*post then
PT3     CMP.B   #$04,   D1  *if reg == 4 (#<>)
        BEQ T4
        BRA EREG_ERROR      *if it isn't any of the above a bad input has been given
*then
T4      AND.B #$03, D3  *only keep the last two bits
        CMP.B #$01, D3  
        BLT     BYTET   * < 1 byte.
        BEQ     WORDT   * = 1 word.
        BGT     LONGT   * > 1 long.
*if byte then
BYTET   MOVE.B #$04, D6
        BRA PT4
*if word then
WORDT   MOVE.B #$04, D6
        BRA PT4
*if long then
LONGT   MOVE.B #$06, D6
PT4     MOVE.L  D4,     D3
        BSR     OPMODE_PARSE *reset D3
*post increment parsing (section end)
PI    
************************************************************************    
* out-of-bounds check
************************************************************************
        MOVEM.L D5/A6, -(SP)
        ADD.L D6, D5
        ADDA.L #1, A6 *since the displacement goes one over the end of 
        *the current instruction the ending should be plus one
        CMP.L A6, D5
        BGT RANGE_ERROR
        MOVEM.L (SP)+, D5/A6 *restore D5 state, maintain stack idempotency
        
************************************************************************    
* display
************************************************************************
        CMP.B #$03, D3
        BEQ ADDAT       *if opmode == 3 then ADDA
        CMP.B #$07, D3
        BEQ ADDAT       *if opmode == 7 then ADDA


        LEA ADDDOT, A1  *print 'ADD.'
        BSR PRINT
        MOVE.B  D3, -(SP)   *we're going to modify D3 so store it 
        AND.B #$03, D3      *only keep the last two bits
        CMP.B #$01, D3  
        BLT     BYTET2      * < 1 byte. print 'ADD.B'
        BEQ     WORDT2      * = 1 word. print 'ADD.W'
        BGT     LONGT2      * > 1 long. print 'ADD.L'
BYTET2  LEA BDISP, A1
        BRA PT5
WORDT2  LEA WDISP, A1
        BRA PT5
LONGT2  LEA LDISP, A1  
PT5     BSR PRINT
        LEA SPACE, A1
        BSR PRINT           * printed 'ADD.X '
        MOVE.B (SP)+, D3    *restore D3
        
        CMP.B #$03, D3
        BGT DNDEST
        BLT EADEST
DNDEST  LEA DDISP, A1
        BSR PRINT
        *D0 = Dn ; D1 = EA reg ; D2 = EA mode ; D3 = opmode 
        BSR PRINTHEX
        LEA COMMA, A1
        BSR PRINT
        LEA SPACE, A1
        BSR PRINT   
        BSR EAPRINT
        BRA ADD_END
EADEST  BSR EAPRINT
        LEA COMMA, A1
        BSR PRINT
        LEA SPACE, A1
        BSR PRINT   
        LEA DDISP, A1
        BSR PRINT
        *D0 = Dn ; D1 = EA reg ; D2 = EA mode ; D3 = opmode 
        BSR PRINTHEX
        BRA ADD_END
        
ADDAT           LEA ADDA_ST, A1       *ADDA section
                BSR PRINT       
                CMP.B #$03, D3        *if opmode = 3 then sign extended word
                BNE ADDA_L_CHECK
                LEA WDISP, A1
                BSR PRINT
                BRA ADDA_PRINT
ADDA_L_CHECK    LEA LDISP, A1
                BSR PRINT
ADDA_PRINT      LEA SPACE, A1
                BSR PRINT
                BSR EAPRINT
                LEA COMMA, A1
                BSR PRINT
                LEA ADISP, A1
                BSR PRINT
                BSR PRINTHEX
ADD_END RTS
* Put variables and constants here

**********CONTRACT**********
*  INPUT:        D0 = opcode
*  OPERATION:    D0 MODIFIED
*  OUTPUT:       D0 = reg
DREG_PARSE: AND.W   #$0E00, D0
        LSR     #8,     D0
        LSR     #1,     D0
        RTS  

**********CONTRACT**********
*  INPUT:        D1 = opcode
*  OPERATION:    D1 MODIFIED
*  OUTPUT:       D1 = reg
REG_PARSE: AND.W   #$0007, D1
        RTS

**********CONTRACT**********
*  INPUT:        D2 = opcode
*  OPERATION:    D2 MODIFIED
*  OUTPUT:       D2 = mode
MODE_PARSE: AND.W   #$0038, D2
        LSR     #3,     D2
        RTS

**********CONTRACT**********
*  INPUT:        D3 = opcode
*  OPERATION:    D3 MODIFIED
*  OUTPUT:       D3 = opmode
OPMODE_PARSE: AND.W   #$01C0, D3
        LSR     #6,     D3
        RTS        

MODE_ERROR: LEA MERROR, A1
        BSR PRINT
        BRA ADD_END
EREG_ERROR: LEA EAREGERROR, A1
        BSR PRINT
        BRA ADD_END
RANGE_ERROR: MOVE.L (SP)+, D5 *maintain stack idempotency
        LEA RERROR, A1
        BSR PRINT
        BRA ADD_END        
        

    *SIMHALT
    *;END    START        ; last line of source















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*****************************
*
* 4E_test.X68
*
* Created 5/26/2020
*
* Test program for CSS 422 Disassembler Project Demo
*
*****************************

start		EQU	$00009000	* ORG and END address

* ORG the program so that it straddles the address boundary $00007FFF to $00008000

		ORG	start

NOP
    ADDQ        #8, D3
    ADDQ        #6, $12349999
    AND.L       #$00000000, D4
    OR.W        (A6)+,  D6  
    OR.L        D4,     D4
    SUB.L       A4,     D4
    SUB.W       D0,     (A3)+
    SUB.B       D1,     D6
    MOVEA.L     $12343210, A4
    MOVEA.L     -(A0),  A6
    MOVE.W      #$DDDD, D7
    MOVE.L      $ABABABAB, $F0F0F0F0
    MOVE.W      $1234FFFF, D1
    MOVE.L      (A0), $AAAABBBB
    MOVE.L      -(A2),  (A2)+
    ADD.W       D0,     (A3)+
    ADD.B       D1,     D6
    RTS
    JSR       (A0)
    JSR       $12345678
    JSR       label1
label1
    NOP
    RTS
    JSR       label1

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~

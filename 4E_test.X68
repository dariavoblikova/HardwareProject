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
    ADD.W       D0,     (A3)+
    ADD.B       D1,     D6
    RTS
    NOP
    RTS
    JSR       (A0)
    JSR       $1234
    JSR       $12345678
    JSR       label1
    NOP
    RTS
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

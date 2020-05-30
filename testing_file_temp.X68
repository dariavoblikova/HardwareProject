*****************************
*
* demo_test.X68
*
* Created 12/05/2018
*
* Test program for CSS 422 Disassembler Project Demo
*
*****************************

start		EQU	$00009000	* ORG and END address

* ORG the program so that it straddles the address boundary $00007FFF to $00008000

		ORG	start

    MOVEA.L D4,         A0
    MOVEA.W $00004000,  A1
    MOVEA.L #$A0A0A0A0, A2
    MOVEA.W (A3),       A3
    MOVEA.L (A0)+,      A4
    MOVEA.L -(A6),      A5
    
    

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~

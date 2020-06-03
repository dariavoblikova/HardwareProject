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

NOP
    BCHG        #1,D1   * illegal
    BCLR        #1,D1   * illegal 
    RTS
    NOP
    RTS
    BGT.B     label1
    BGT.B     label2
    BLE.B     label1
    BLE.B     label2
    
    BGE.B     label1    * illegal
    BGE.B     label2    * illegal                
    BLT.B     label2    * illegal
    BLT.W     label1    * illegal

    NOP
    RTS
label1
    NOP
    RTS
    LEA       $12,A0
    LEA       $1234,A0
label2
    MOVEQ     #$0,D0
    MOVEQ     #$12,D0
    MOVEQ     #$FF,D0
label3
    LSL.L     #$3,D2
label4
    BGT.B     label4
    BGT.B     label4
    BGT.B     label4
    BLE.W     label1
    BLE.W     label2
    BLE.W     label3
    BEQ.W     label1
    BEQ.W     label2
    BEQ.W     label3
    JSR       label1
    JSR       label2
    JSR       label3

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~

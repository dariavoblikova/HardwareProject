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
    RTS
    NOP
    RTS
*    MOVEM.W   (A1)+,A1-A7
*    MOVEM.L   (A1)+,D1-D7
*    MOVEM.W   (A1)+,A1/D7
*    MOVEM.L   (A1)+,A1/D7
*    MOVEM.W   (A1),A1-A7
*    MOVEM.L   (A1),D1-D7
*    MOVEM.W   (A1),A1/D7
*    MOVEM.L   (A1),A1/D7
*    ADD.B     D1,D2
*    ADD.B     D1,(A1)
*    ADD.B     D1,(A1)+
*    ADD.B     D1,-(A1)
*    ADD.B     (A1),D1
*    ADD.B     (A1)+,D1
*    ADD.B     -(A1),D1
*    ADD.W     D1,D2
*    ADD.W     D1,(A1)
*    ADD.W     D1,(A1)+
*    ADD.W     D1,-(A1)
*    ADD.W     (A1),D1
*    ADD.W     (A1)+,D1
*    ADD.W     -(A1),D1
*    ADD.L     D1,D2
*    ADD.L     D1,(A1)
*    ADD.L     D1,(A1)+
*    ADD.L     D1,-(A1)
*    ADD.L     (A1),D1
*    ADD.L     (A1)+,D1
*    ADD.L     -(A1),D1
    LSL.B     D1,D2
    LSL.W     D1,D2
    LSL.W     (A1)
    LSL.W     (A1)+
    LSL.W     -(A1)
    LSL.L     D1,D2
    LSR.B     D1,D2
    LSR.W     D1,D2
    LSR.W     (A1)
    LSR.W     (A1)+
    LSR.W     -(A1)
    LSR.L     D1,D2    
    ASR.B     D1,D2
    ASR.W     D1,D2
    ASR.W     (A1)
    ASR.W     (A1)+
    ASR.W     -(A1)
    ASR.L     D1,D2
    ASL.B     D1,D2
    ASL.W     D1,D2
    ASL.W     (A1)
    ASL.W     (A1)+
    ASL.W     -(A1)
    ASL.L     D1,D2  
    BGT.B     label1
    BLE.B     label1
    BGE.B     label1
    BEQ.W     label1
    JSR       (A0)
    JSR       $1234
    JSR       $12345678
    JSR       label1
    JSR       label3
    NOP
    RTS
label1
    NOP
    RTS
label3
*    MOVEM.W   A1-A7,$12
*    MOVEM.L   D1-D7,$12
*    MOVEM.W   A1/D7,$12
*    MOVEM.L   A1/D7,$12
*    MOVEM.W   A1-A7,$1234
*    MOVEM.L   D1-D7,$1234
*    MOVEM.W   A1/D7,$1234
*    MOVEM.L   A1/D7,$1234
*    MOVEM.W   A1-A7,$12345678
*    MOVEM.L   D1-D7,$12345678
*    MOVEM.W   A1/D7,$12345678
*    MOVEM.L   A1/D7,$12345678
*    MOVEM.W   $12,A1-A7
*    MOVEM.L   $12,D1-D7
*    MOVEM.W   $12,A1/D7
*    MOVEM.L   $12,A1/D7
*    MOVEM.W   $1234,A1-A7
*    MOVEM.L   $1234,D1-D7
*    MOVEM.W   $1234,A1/D7
*    MOVEM.L   $1234,A1/D7
*    MOVEM.W   $12345678,A1-A7
*    MOVEM.L   $12345678,D1-D7
*    MOVEM.W   $12345678,A1/D7
*    MOVEM.L   $12345678,A1/D7
    LSL.B     #$1,D2
    LSL.W     #$2,D2
    LSL.L     #$3,D2
    LSL.W     $12
    LSL.W     $1234
    LSL.W     $12345678
    ASR.B     #$1,D1
    ASR.W     #$2,D2
    ASR.L     #$3,D3
    ASR.W     $12
    ASR.W     $1234
    ASR.W     $12345678
label4
    BGT.B     label4
    BGT.B     label4
    BGT.B     label4
    BLE.W     label1
    BLE.W     label3
    BEQ.W     label1
    BEQ.W     label3
    JSR       label1
    JSR       label3

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~

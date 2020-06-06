*-----------------------------------------------------------
* Title      : Tests each opcode specified for the project.
* Written by : Alexander A Dietrich, elaborating on bad_opcodes_test
* Date       : 6/5/2020
* Description: At least four different tests for each opcode, along 
* with a stress-test of the third instruction being invalid.
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program
    *NOP TESTING*
    NOP
    NOP
    MULS D1, D2
    NOP
    NOP
    *RTS TESTING*
    RTS
    RTS
    DIVU D1, D2
    RTS
    RTS
    *JSR TESTING*
A   JSR B
B   JSR A
    BCHG        #1,D1
C   JSR D
D   JSR C
    *NOT TESTING*
    NOT.B D0
    NOT.L (A2)
    SUBA.W #$FFFF, A0
    NOT.B (A3)+
    NOT.W -(A4)
    NOT.L $1234
    NOT.L $F0F0
    *LEA TESTING*
    LEA (A3), A2
    LEA $F0F0, A3
    BTST #$01, D0
    LEA $0F0F0F0F, A4
    *MOVEM TESTING*
    MOVEM.W D0-D7/A0-A7, (A0)
    MOVEM.L D0-D7/A0-A7, (A0)
    MULS D1, D2
    MOVEM.W D0-D7/A0-A7, -(A0)
    MOVEM.L D0-D7/A0-A7, -(A0)
    MOVEM.W D0-D7/A0-A7, $1234
    MOVEM.L D0-D7/A0-A7, $1234
    MOVEM.W D0-D7/A0-A7, $12344321
    MOVEM.L D0-D7/A0-A7, $12344321
    MOVEM.W  (A0), D0-D7/A0-A7
    MOVEM.L  (A0), D0-D7/A0-A7
    MOVEM.W  (A0)+, D0-D7/A0-A7
    MOVEM.L  (A0)+, D0-D7/A0-A7
    MOVEM.W  $1234, D0-D7/A0-A7
    MOVEM.L  $1234, D0-D7/A0-A7
    MOVEM.W  $12344321, D0-D7/A0-A7
    MOVEM.L  $12344321, D0-D7/A0-A7
    
    *MOVE.B byte
    MOVE.B D0,    D1
    MOVE.W D0,    A1
    DIVU D1, D2
    MOVE.B D0,    (A1)
    MOVE.B D0,    (A1)+
    MOVE.B D0,    -(A1)
    MOVE.B D0,    $1234
    MOVE.B D0,    $F0F0F0F0
    
    MOVE.W A1,    D1
    MOVE.W A1,    A1
    MOVE.W A1,    (A1)
    MOVE.W A1,    (A1)+
    MOVE.W A1,    -(A1)
    MOVE.W A1,    $1234
    MOVE.W A1,    $F0F0F0F0
    
    MOVE.B (A1),    D1
    MOVE.W (A1),    A1
    MOVE.B (A1),    (A1)
    MOVE.B (A1),    (A1)+
    MOVE.B (A1),    -(A1)
    MOVE.B (A1),    $1234
    MOVE.B (A1),    $F0F0F0F0
    
    MOVE.B (A1)+,    D1
    MOVE.W (A1)+,    A1
    MOVE.B (A1)+,    (A1)
    MOVE.B (A1)+,    (A1)+
    MOVE.B (A1)+,    -(A1)
    MOVE.B (A1)+,    $1234
    MOVE.B (A1)+,    $F0F0F0F0
    
    MOVE.B -(A1),    D1
    MOVE.W -(A1),    A1
    MOVE.B -(A1),    (A1)
    MOVE.B -(A1),    (A1)+
    MOVE.B -(A1),    -(A1)
    MOVE.B -(A1),    $1234
    MOVE.B -(A1),    $F0F0F0F0
    
    MOVE.B $4567,    D1
    MOVE.W $4567,    A1
    MOVE.B $4567,    (A1)
    MOVE.B $4567,    (A1)+
    MOVE.B $4567,    -(A1)
    MOVE.B $4567,    $1234
    MOVE.B $4567,    $F0F0F0F0
    
    MOVE.B $0F0F0F0F,    D1
    MOVE.W $0F0F0F0F,    A1
    MOVE.B $0F0F0F0F,    (A1)
    MOVE.B $0F0F0F0F,    (A1)+
    MOVE.B $0F0F0F0F,    -(A1)
    MOVE.B $0F0F0F0F,    $1234
    MOVE.B $0F0F0F0F,    $F0F0F0F0
    
    MOVE.B #$12,    D1
    MOVE.W #$1234,    A1
    MOVE.B #$12,    (A1)
    MOVE.B #$12,    (A1)+
    MOVE.B #$12,    -(A1)
    MOVE.B #$12,    $1234
    MOVE.B #$12,    $F0F0F0F0
    
    *MOVE.W word
    MOVE.W D0,    D1
    MOVE.W D0,    A1
    MOVE.W D0,    (A1)
    MOVE.W D0,    (A1)+
    MOVE.W D0,    -(A1)
    MOVE.W D0,    $1234
    MOVE.W D0,    $F0F0F0F0
    
    MOVE.W A1,    D1
    MOVE.W A1,    A1
    MOVE.W A1,    (A1)
    MOVE.W A1,    (A1)+
    MOVE.W A1,    -(A1)
    MOVE.W A1,    $1234
    MOVE.W A1,    $F0F0F0F0
    
    MOVE.W (A1),    D1
    MOVE.W (A1),    A1
    MOVE.W (A1),    (A1)
    MOVE.W (A1),    (A1)+
    MOVE.W (A1),    -(A1)
    MOVE.W (A1),    $1234
    MOVE.W (A1),    $F0F0F0F0
    
    MOVE.W (A1)+,    D1
    MOVE.W (A1)+,    A1
    MOVE.W (A1)+,    (A1)
    MOVE.W (A1)+,    (A1)+
    MOVE.W (A1)+,    -(A1)
    MOVE.W (A1)+,    $1234
    MOVE.W (A1)+,    $F0F0F0F0
    
    MOVE.W -(A1),    D1
    MOVE.W -(A1),    A1
    MOVE.W -(A1),    (A1)
    MOVE.W -(A1),    (A1)+
    MOVE.W -(A1),    -(A1)
    MOVE.W -(A1),    $1234
    MOVE.W -(A1),    $F0F0F0F0
    
    MOVE.W $4567,    D1
    MOVE.W $4567,    A1
    MOVE.W $4567,    (A1)
    MOVE.W $4567,    (A1)+
    MOVE.W $4567,    -(A1)
    MOVE.W $4567,    $1234
    MOVE.W $4567,    $F0F0F0F0
    
    MOVE.W $0F0F0F0F,    D1
    MOVE.W $0F0F0F0F,    A1
    MOVE.W $0F0F0F0F,    (A1)
    MOVE.W $0F0F0F0F,    (A1)+
    MOVE.W $0F0F0F0F,    -(A1)
    MOVE.W $0F0F0F0F,    $1234
    MOVE.W $0F0F0F0F,    $F0F0F0F0
    
    MOVE.W #$1234,    D1
    MOVE.W #$1234,    A1
    MOVE.W #$1234,    (A1)
    MOVE.W #$1234,    (A1)+
    MOVE.W #$1234,    -(A1)
    MOVE.W #$1234,    $1234
    MOVE.W #$1234,    $F0F0F0F0
    
    *MOVE.L long
    MOVE.L D0,    D1
    MOVE.L D0,    A1
    MOVE.L D0,    (A1)
    MOVE.L D0,    (A1)+
    MOVE.L D0,    -(A1)
    MOVE.L D0,    $1234
    MOVE.L D0,    $F0F0F0F0
    
    MOVE.L A1,    D1
    MOVE.L A1,    A1
    MOVE.L A1,    (A1)
    MOVE.L A1,    (A1)+
    MOVE.L A1,    -(A1)
    MOVE.L A1,    $1234
    MOVE.L A1,    $F0F0F0F0
    
    MOVE.L (A1),    D1
    MOVE.L (A1),    A1
    MOVE.L (A1),    (A1)
    MOVE.L (A1),    (A1)+
    MOVE.L (A1),    -(A1)
    MOVE.L (A1),    $1234
    MOVE.L (A1),    $F0F0F0F0
    
    MOVE.L (A1)+,    D1
    MOVE.L (A1)+,    A1
    MOVE.L (A1)+,    (A1)
    MOVE.L (A1)+,    (A1)+
    MOVE.L (A1)+,    -(A1)
    MOVE.L (A1)+,    $1234
    MOVE.L (A1)+,    $F0F0F0F0
    
    MOVE.L -(A1),    D1
    MOVE.L -(A1),    A1
    MOVE.L -(A1),    (A1)
    MOVE.L -(A1),    (A1)+
    MOVE.L -(A1),    -(A1)
    MOVE.L -(A1),    $1234
    MOVE.L -(A1),    $F0F0F0F0
    
    MOVE.L $4567,    D1
    MOVE.L $4567,    A1
    MOVE.L $4567,    (A1)
    MOVE.L $4567,    (A1)+
    MOVE.L $4567,    -(A1)
    MOVE.L $4567,    $1234
    MOVE.L $4567,    $F0F0F0F0
    
    MOVE.L $0F0F0F0F,    D1
    MOVE.L $0F0F0F0F,    A1
    MOVE.L $0F0F0F0F,    (A1)
    MOVE.L $0F0F0F0F,    (A1)+
    MOVE.L $0F0F0F0F,    -(A1)
    MOVE.L $0F0F0F0F,    $1234
    MOVE.L $0F0F0F0F,    $F0F0F0F0
    
    MOVE.L #$1234,    D1
    MOVE.L #$1234,    A1
    MOVE.L #$1234,    (A1)
    MOVE.L #$1234,    (A1)+
    MOVE.L #$1234,    -(A1)
    MOVE.L #$1234,    $1234
    MOVE.L #$1234,    $F0F0F0F0
    
    *moveq testing*
    MOVEQ #$FF, D0
    MOVEQ #$00, D1
    BCHG        #1,D1
    MOVEQ #$F0, D2
    MOVEQ #$0F, D3
    
    *add testing*
    *ADD.B byte
    ADD.B D0,    D1
    ADD.W D0,    A1
    DIVU D1, D2
    ADD.B D0,    (A1)
    ADD.B D0,    (A1)+
    ADD.B D0,    -(A1)
    ADD.B D0,    $1234
    ADD.B D0,    $F0F0F0F0
    
    ADD.W A1,    D1
    ADD.W A1,    A1
    
    ADD.B (A1),    D1
    ADD.W (A1),    A1
    
    ADD.B (A1)+,    D1
    ADD.W (A1)+,    A1
    
    ADD.B -(A1),    D1
    ADD.W -(A1),    A1
    
    ADD.B $4567,    D1
    ADD.W $4567,    A1
    
    ADD.B $0F0F0F0F,    D1
    ADD.W $0F0F0F0F,    A1
    
    ADD.W #$1234,    A1
    
    *ADD.W word
    ADD.W D0,    D1
    ADD.W D0,    A1
    ADD.W D0,    (A1)
    ADD.W D0,    (A1)+
    ADD.W D0,    -(A1)
    ADD.W D0,    $1234
    ADD.W D0,    $F0F0F0F0
    
    ADD.W A1,    D1
    ADD.W A1,    A1
    
    ADD.W (A1),    D1
    ADD.W (A1),    A1
    
    ADD.W (A1)+,    D1
    ADD.W (A1)+,    A1
    
    ADD.W -(A1),    D1
    ADD.W -(A1),    A1
    
    ADD.W $4567,    D1
    ADD.W $4567,    A1
    
    ADD.W $0F0F0F0F,    D1
    ADD.W $0F0F0F0F,    A1
    
    ADD.W #$1234,    A1
    
    *ADD.L long
    ADD.L D0,    D1
    ADD.L D0,    A1
    ADD.L D0,    (A1)
    ADD.L D0,    (A1)+
    ADD.L D0,    -(A1)
    ADD.L D0,    $1234
    ADD.L D0,    $F0F0F0F0
    
    ADD.L A1,    D1
    ADD.L A1,    A1
    
    ADD.L (A1),    D1
    ADD.L (A1),    A1
    
    ADD.L (A1)+,    D1
    ADD.L (A1)+,    A1
    
    ADD.L -(A1),    D1
    ADD.L -(A1),    A1
    
    ADD.L $4567,    D1
    ADD.L $4567,    A1
    
    ADD.L $0F0F0F0F,    D1
    ADD.L $0F0F0F0F,    A1
    
    ADD.L #$1234,    A1
    
    *addq testing*
    ADDQ #1, D0
    ADDQ #3, D1
    BCHG        #1,D1
    ADDQ #4, D2
    ADDQ #8, D3
    
    *sub testing*
    *SUB.B byte
    SUB.B D0,    D1
    SUB.W D0,    A1
    DIVU D1, D2
    SUB.B D0,    (A1)
    SUB.B D0,    (A1)+
    SUB.B D0,    -(A1)
    SUB.B D0,    $1234
    SUB.B D0,    $F0F0F0F0
    
    SUB.W A1,    D1
    SUB.W A1,    A1
    
    SUB.B (A1),    D1
    SUB.W (A1),    A1
    
    SUB.B (A1)+,    D1
    SUB.W (A1)+,    A1
    
    SUB.B -(A1),    D1
    SUB.W -(A1),    A1
    
    SUB.B $4567,    D1
    SUB.W $4567,    A1
    
    SUB.B $0F0F0F0F,    D1
    SUB.W $0F0F0F0F,    A1
    
    SUB.W #$1234,    A1
    
    *SUB.W word
    SUB.W D0,    D1
    SUB.W D0,    A1
    SUB.W D0,    (A1)
    SUB.W D0,    (A1)+
    SUB.W D0,    -(A1)
    SUB.W D0,    $1234
    SUB.W D0,    $F0F0F0F0
    
    SUB.W A1,    D1
    SUB.W A1,    A1
    
    SUB.W (A1),    D1
    SUB.W (A1),    A1
    
    SUB.W (A1)+,    D1
    SUB.W (A1)+,    A1
    
    SUB.W -(A1),    D1
    SUB.W -(A1),    A1
    
    SUB.W $4567,    D1
    SUB.W $4567,    A1
    
    SUB.W $0F0F0F0F,    D1
    SUB.W $0F0F0F0F,    A1
    
    SUB.W #$1234,    A1
    
    *SUB.L long
    SUB.L D0,    D1
    SUB.L D0,    A1
    SUB.L D0,    (A1)
    SUB.L D0,    (A1)+
    SUB.L D0,    -(A1)
    SUB.L D0,    $1234
    SUB.L D0,    $F0F0F0F0
    
    SUB.L A1,    D1
    SUB.L A1,    A1
    
    SUB.L (A1),    D1
    SUB.L (A1),    A1
    
    SUB.L (A1)+,    D1
    SUB.L (A1)+,    A1
    
    SUB.L -(A1),    D1
    SUB.L -(A1),    A1
    
    SUB.L $4567,    D1
    SUB.L $4567,    A1
    
    SUB.L $0F0F0F0F,    D1
    SUB.L $0F0F0F0F,    A1
    
    SUB.L #$1234,    A1
    
    *and testing*
    *AND.B byte
    AND.B D0,    D1
    DIVU D1, D2
    AND.B D0,    (A1)
    AND.B D0,    (A1)+
    AND.B D0,    -(A1)
    AND.B D0,    $1234
    AND.B D0,    $F0F0F0F0
    
    
    AND.B (A1),    D1
    
    AND.B (A1)+,    D1
    
    AND.B -(A1),    D1
    
    AND.B $4567,    D1
    
    AND.B $0F0F0F0F,    D1
    
    
    *AND.W word
    AND.W D0,    D1
    AND.W D0,    (A1)
    AND.W D0,    (A1)+
    AND.W D0,    -(A1)
    AND.W D0,    $1234
    AND.W D0,    $F0F0F0F0
    
    
    AND.W (A1),    D1
    
    AND.W (A1)+,    D1
    
    AND.W -(A1),    D1
    
    AND.W $4567,    D1
    
    AND.W $0F0F0F0F,    D1
    
    
    *AND.L long
    AND.L D0,    D1
    AND.L D0,    (A1)
    AND.L D0,    (A1)+
    AND.L D0,    -(A1)
    AND.L D0,    $1234
    AND.L D0,    $F0F0F0F0
    
    AND.L (A1),    D1
    
    AND.L (A1)+,    D1
    
    AND.L -(A1),    D1
    
    AND.L $4567,    D1
    
    AND.L $0F0F0F0F,    D1
    
    *or testing*
    *OR.B byte
    OR.B D0,    D1
    OR.B D0,    (A1)
    DIVU D1, D2
    OR.B D0,    (A1)+
    OR.B D0,    -(A1)
    OR.B D0,    $1234
    OR.B D0,    $F0F0F0F0
    
    
    OR.B (A1),    D1
    
    OR.B (A1)+,    D1
    
    OR.B -(A1),    D1
    
    OR.B $4567,    D1
    
    OR.B $0F0F0F0F,    D1
    
    
    *OR.W word
    OR.W D0,    D1
    OR.W D0,    (A1)
    OR.W D0,    (A1)+
    OR.W D0,    -(A1)
    OR.W D0,    $1234
    OR.W D0,    $F0F0F0F0
    
    OR.W (A1),    D1
    
    OR.W (A1)+,    D1
    
    OR.W -(A1),    D1
    
    OR.W $4567,    D1
    
    OR.W $0F0F0F0F,    D1
    
    
    *OR.L long
    OR.L D0,    D1

    OR.L D0,    (A1)
    OR.L D0,    (A1)+
    OR.L D0,    -(A1)
    OR.L D0,    $1234
    OR.L D0,    $F0F0F0F0
    


    
    OR.L (A1),    D1

    
    OR.L (A1)+,    D1

    
    OR.L -(A1),    D1

    
    OR.L $4567,    D1

    
    OR.L $0F0F0F0F,    D1


    *shift testing*
    ROR.B #1, D0
    ASR.L #2, D1
    BTST #$F, D0
    LSL.W #3, D7
    
    *branch testing*
    BGT A
    BLE B
    DIVU D4, D5
    BEQ C
    BRA D
    



    SIMHALT             ; halt simulator
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*-----------------------------------------------------------
* Title      : TEST ADD
* Written by : Alexander A Dietrich
* Date       : 5/25/2020
* Description: Has a bunch of instructions to test the ability to parse add
*-----------------------------------------------------------
START:
    ORG    $9000    *not over 9000
    ADD.B D0, D1
    ADD.W D0, D2
    ADD.L D0, D3
    ADD.W A1, D4
    ADD.W -(A2), D5
    ADD.L (A3)+, D6
    BEQ ABC
    BLE ABC
    BGT ABC
    BRA ABC
ABC SIMHALT
    END START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

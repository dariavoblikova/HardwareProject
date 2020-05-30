*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
LEA:                  
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6

* Put program code here
LEA_REG MOVE.L  D4,D2
    ANDI.L  #$0E00,D2
    LSR.L   #$8,D2
    LSR.L   #$1,D2
    BRA     LEA_MODE
    
LEA_MODE  MOVE.L  D4,D3
    ANDI.L  #$38,D3
    CMP.L   #$10,D3
    BEQ     LEA_INDIRECT
    
    CMP.L   #$38,D3
    BEQ     LEA_ABSOLUTE
    BRA     LEA_INVALID
    
LEA_INDIRECT  LEA   LEA_ADDRPAREN,A2
    LEA     LEA_ENDPAREN,A3
    MOVE.L  D4,D3
    ANDI.L  #$07,D3
    MOVE.L  #$2,D6
    BRA     LEA_PRINT

LEA_ABSOLUTE  LEA LEA_HEXSYMB,A2
    LEA     LEA_COMMA,A3  
    MOVE.L  D4,D3
    ANDI.L  #$07,D3
    CMP.L   #$00,D3
    BEQ     LEA_WORD
    CMP.L   #$01,D3
    BEQ     LEA_LONG
    BRA     LEA_INVALID
    
LEA_WORD  MOVE.L  D5,D3
    ADDI.L  #$4,D3
    CMP.L   A6,D3   
    BGT     LEA_INVALID
    ADDI.L  #$2,D5
    MOVE.L  D5,A5
    MOVE.W  (A5),D3
    MOVE.L  #$4,D6
    BRA     LEA_PRINT

LEA_LONG MOVE.L  D5,D3
        ADDI.L  #$6,D3
        CMP.L   A6,D3   
        BGT     LEA_INVALID
        ADDI.L  #$2,D5
        MOVE.L  D5,A5
        MOVE.L  (A5),D3
        MOVE.L  #$6,D6
        BRA     LEA_PRINT 

LEA_PRINT   LEA LEA_CODE,A1
    MOVE.L  #14,D0
    TRAP    #15
    MOVEA.L A2,A1
    TRAP    #15
    MOVE.L  D3,D1
    MOVE.L  D1, -(SP)   *safe replacement for trap 15
    MOVE.L  D1, D0
    BSR PRINTHEX
    MOVE.L  (SP)+, D1
    MOVEA.L A3,A1
    MOVE.L  #14,D0
    TRAP    #15
    LEA     LEA_ADDR,A1
    TRAP    #15
    MOVE.L  D2,D1
    MOVE.L  D1, -(SP)   *safe replacement for trap 15
    MOVE.L  D1, D0
    BSR ADAPTIVE_PRINTREG
    MOVE.L  (SP)+, D1
    BRA     LEA_DONE
 
LEA_INVALID JSR    INVALID
            BRA LEA_DONE
     
LEA_DONE  MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6    
        RTS       


* Put variables and constants here
LEA_CODE    DC.B    'LEA    ',0
LEA_ADDRPAREN   DC.B    '(A',0
LEA_ENDPAREN    DC.B    '),',0
LEA_HEXSYMB     DC.B    '$',0
LEA_COMMA       DC.B    ',',0
LEA_ADDR        DC.B    'A',0




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

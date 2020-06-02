*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
NOT:                  
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6  

* here we check what size the operation is (byte, word, or long) 
NOT_SIZE    MOVE.L  D4,D3
        ANDI.L  #$C0,D3
        CMP.L   #$00,D3
        BEQ     NOT_BYTE
        CMP.L   #$40,D3
        BEQ     NOT_WORD
        CMP.L   #$80,D3
        BEQ     NOT_LONG
 
* load string saying this is a byte operation       
NOT_BYTE  LEA NOT_BSIZE, A2
        BRA     NOT_MODE

* load string saying this is a word operation               
NOT_WORD  LEA NOT_WSIZE, A2
        BRA     NOT_MODE

* load string saying this is a long operation       
NOT_LONG  LEA NOT_LSIZE, A2
        BRA     NOT_MODE
    
* check what the EA mode is    
NOT_MODE  MOVE.L  D4,D3
        ANDI.L  #$38,D3
        
        CMP.L   #$00,D3
        BEQ     NOT_DATA    * EA is a data register
        
        CMP.L   #$10,D3
        BEQ     NOT_INDIRECT    * EA is indirect address register
        
        CMP.L   #$18,D3
        BEQ     NOT_POST_INCREMENT  * EA is indirect address register, post-increment
        
        CMP.L   #$20,D3
        BEQ     NOT_PRE_DECREMENT   * EA is indirect address register, pre-decrement
        
        CMP.L   #$38,D3
        BEQ     NOT_ABSOLUTE    * EA is absolute addressing 
        
        BRA     INVALID_NOTEA

* load string specifying EA is a data register
NOT_DATA  LEA NOT_DREG, A3
        MOVE.L  D4,D3
        ANDI.L  #$07,D3
        MOVE.L  D3,D1   * to print register number from D1
        MOVE.L  #$2,D6
        BRA     NOT_PRINT
    
NOT_INDIRECT   LEA NOT_ADDRPAREN, A3
        LEA    NOT_ENDPAREN,A4
        MOVE.L  D4,D3
        ANDI.L  #$07,D3
        MOVE.L  D3,D1   * to print register number from D1
        MOVE.L  #$2,D6
        BRA     NOT_ADDR_PRINT
 
NOT_POST_INCREMENT   LEA NOT_ADDRPAREN, A3
        LEA    NOT_POSTPAREN,A4
        MOVE.L  D4,D3
        ANDI.L  #$07,D3
        MOVE.L  D3,D1   * to print register number from D1
        MOVE.L  #$2,D6
        BRA     NOT_ADDR_PRINT
    
NOT_PRE_DECREMENT  LEA NOT_PREPAREN, A3
        LEA    NOT_ENDPAREN,A4
        MOVE.L  D4,D3
        ANDI.L  #$07,D3
        MOVE.L  D3,D1   * to print register number from D1
        MOVE.L  #$2,D6
        BRA     NOT_ADDR_PRINT
   
* check if EA is absolute word addressing or absolute long addressing 
NOT_ABSOLUTE 
        LEA    NOT_HEXSYMB,A3   
        MOVE.L  D4,D3
        ANDI.L  #$07,D3
        
        CMP.L   #$00,D3
        BEQ     NOT_ABSOLUTE_WORD

        CMP.L   #$01,D3
        BEQ     NOT_ABSOLUTE_LONG

        BRA     INVALID_NOTEA

NOT_ABSOLUTE_WORD   MOVE.L  D5,D3
        ADDI.L  #$4,D3
        CMP.L   A6,D3   
        BGT     INVALID_NOT
        ADDI.L  #$2,D5
        MOVE.L  D5,A5
        MOVE.W  (A5),D1
        MOVE.L  #$4,D6
        BRA     NOT_PRINT
                

NOT_ABSOLUTE_LONG   MOVE.L  D5,D3
        ADDI.L  #$6,D3
        CMP.L   A6,D3   
        BGT     INVALID_NOT
        ADDI.L  #$2,D5
        MOVE.L  D5,A5
        MOVE.L  (A5),D1
        MOVE.L  #$6,D6
        BRA     NOT_PRINT
   
* print opcode to console    
NOT_PRINT  LEA  NOT_CODE,A1
        MOVE.L  #14,D0
        TRAP    #15 
        MOVEA.L A2,A1   * string containing size of opcode
        TRAP    #15
        MOVEA.L A3,A1   * string containing the EA
        TRAP    #15
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        BRA     NOT_DONE

NOT_ADDR_PRINT 
        LEA  NOT_CODE,A1
        MOVE.L  #14,D0
        TRAP    #15 
        MOVEA.L A2,A1   * string containing size of opcode
        TRAP    #15
        MOVEA.L A3,A1   * string containing the EA
        TRAP    #15
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        MOVEA.L A4,A1
        MOVE.L  #14,D0
        TRAP    #15
        BRA     NOT_DONE

INVALID_NOT JSR INVALID
            BRA NOT_DONE
            
INVALID_NOTEA   JSR INVALIDEA
            BRA NOT_DONE
        
NOT_DONE    MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6
                RTS

* Put variables and constants here
NOT_CODE    DC.B    'NOT',0
NOT_BSIZE   DC.B    '.B     ',0
NOT_WSIZE   DC.B    '.W     ',0
NOT_LSIZE   DC.B    '.L     ',0
NOT_DREG    DC.B    'D',0
NOT_ADDRPAREN   DC.B    '(A',0
NOT_ENDPAREN    DC.B    ')',0
NOT_PREPAREN    DC.B    '-(A',0
NOT_POSTPAREN   DC.B    ')+',0
NOT_HEXSYMB     DC.B    '$',0




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

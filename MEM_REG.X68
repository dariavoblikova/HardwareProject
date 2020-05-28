*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

MEM_REG:                  ; first instruction of program
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6

* Mask byte of opcode to figure out the size field
    MOVE.B  D4,D3
    AND.B   #$C0,D3
    CMP.B   #$80,D3
    BEQ     MEM_REG_WORD
    CMP.B   #$C0,D3
    BEQ     MEM_REG_LONG
    BRA     MEM_REG_INVALID

* branch here if size field is a word    
MEM_REG_WORD    LEA WORD_LEN,A1
        BRA MEM_REG_EA_MODE
  
* branch here if size field is a long      
MEM_REG_LONG    LEA LONG_LEN,A1
        BRA MEM_REG_EA_MODE

* identify EA mode      
MEM_REG_EA_MODE MOVE.B  D4,D3
        AND.B   #$38,D3
        CMP.B   #$18,D3
        BEQ     MEM_REG_POST_INC * we know it's a predecrement mode if equal
        CMP.B   #$10,D3
        BEQ     MEM_REG_IND_ADDR
        
        * check for absolute addressing EA
        MOVE.B  D4,D3
        AND.B   #$3F,D3
        CMP.B   #$38,D3
        BEQ     MEM_REG_ABS_WORD
        CMP.B   #$39,D3
        BEQ     MEM_REG_ABS_LONG  
        
        BRA     MEM_REG_INVALID

* branch here to grab strings displaying '(AX)+'
MEM_REG_POST_INC    LEA ADDRPAREN,A2
        LEA     POST_PLUS,A3
        BRA     MEM_REG_REG_RANGE
  
* branch here to grab strings displaying '(AX)'      
MEM_REG_IND_ADDR    LEA ADDRPAREN,A2
        LEA     END_PAREN,A3
        BRA     MEM_REG_REG_RANGE
        
MEM_REG_ABS_WORD ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     MEM_REG_INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     MEM_REG_INVALID
        MOVE.W  (A0)+,D1 * put absolute word address in D4
        CMP.L   A6,A0   * word is past ending memory address given by user
        BGT     MEM_REG_INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A1
        MOVE.B  #14,D0
        TRAP    #15
        CMP.W   #$0000,D1
        BEQ     MEM_REG_DISP_ADD
        MOVE.B  #3,D0
        TRAP    #15
        MOVEA.W #$0000,A1
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     MEM_REG_A_RANGE
        
MEM_REG_ABS_LONG  ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     MEM_REG_INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     MEM_REG_INVALID
        MOVE.L  (A0)+,D1 * put absolute word address in D4
        CMP.L   A6,A0
        BGT     MEM_REG_INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A1
        MOVE.B  #14,D0
        TRAP    #15
        CMP.L   #$00000000,D1
        BEQ     MEM_REG_DISP_LONG
        MOVE.B  #3,D0
        TRAP    #15
        MOVEA.W #$0000,A1
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     MEM_REG_A_RANGE
        
MEM_REG_DISP_ADD    LEA ZERO_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     MEM_REG_A_RANGE
        
MEM_REG_DISP_LONG   LEA LONG_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     MEM_REG_A_RANGE     
   
* here we grab the word representing the range of registers in MOVEM operand     
MEM_REG_REG_RANGE MOVE.B  D4,D3 * move opcode word to D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D1   * move to D1 for when we display register number
        
        ADDI.L  #$2,D5  * move PC counter by 2
        CMP.L   A6,D5   * check if we are reading past end memory address
        BGE     MEM_REG_INVALID * opcode is out of bounds of memory we read  
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     MEM_REG_INVALID * if range is 0000, then there are no registers
        MOVE.B  #14,D0  * starting print MOVEM opcode
        TRAP    #15
        * print address register (indirect post-increment or regular increment)  
        MOVEA   A2,A1   
        TRAP    #15
        MOVE.B  #3,D0   * print register number
        TRAP    #15
        
        MOVEA   A3,A1
        MOVE.B  #14,D0
        TRAP    #15
        CLR     D4      * clear D4 for further use
        BRA     MEM_REG_A_RANGE * start identifying the registers in the operand  
        
MEM_REG_A_RANGE CMP.L    #$0100,D3
        BLT MEM_REG_D_RANGE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$8000,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$4000,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$2000,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$1000,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$0800,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$0400,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$0200,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A
        
        MOVE.W  #$0100,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_A   

MEM_REG_MIN_A   CMP.B   #$00,D4
        BEQ MEM_REG_FIRST_AREG
        BRA MEM_REG_A_SLASH
        
MEM_REG_A_SLASH LEA   ADDR_SLASH,A1       
        BRA MEM_REG_SUB_AVALUE 

MEM_REG_FIRST_AREG MOVE.W  #$0001,D4
        LEA ADDR_REG,A1
        BRA MEM_REG_SUB_AVALUE 
        
MEM_REG_SUB_AVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     MEM_REG_A_RANGE
      
MEM_REG_D_RANGE CMP.L    #$0000,D3
        BEQ MEM_REG_DONE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$0080,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0040,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0020,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0010,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0008,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0004,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0002,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
        
        MOVE.W  #$0001,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     MEM_REG_MIN_D
  
MEM_REG_MIN_D   CMP.B   #$00,D4
        BEQ MEM_REG_FIRSTD_REG
        BRA MEM_REG_ADDD_SLASH

MEM_REG_ADDD_SLASH LEA   DATA_SLASH,A1       
        BRA MEM_REG_SUB_DVALUE 

MEM_REG_FIRSTD_REG MOVE.W  #$0001,D4
        LEA DATA_REG,A1
        BRA MEM_REG_SUB_DVALUE 
   
MEM_REG_SUB_DVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     MEM_REG_D_RANGE

MEM_REG_INVALID JSR     INVALID
            BRA     MEM_REG_DONE

MEM_REG_DONE    MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6  
             RTS

    * SIMHALT             ; halt simulator

* Put variables and constants here
COMMA_ADD   DC.B    ','          ,0
*WORD_LEN    DC.B    'MOVEM.W    ',0
*LONG_LEN    DC.B    'MOVEM.L    ',0
*DATA_SLASH  DC.B    '/D'         ,0
*DATA_REG    DC.B    'D'          ,0
*ADDR_SLASH  DC.B    '/A'         ,0
*ADDR_REG    DC.B    'A'          ,0
POST_PLUS   DC.B    ')+,'        ,0
*ADDRPAREN   DC.B    '(A'         ,0
*END_PAREN   DC.B    '),'         ,0
*HEX_SYMB    DC.B    '$'          ,0
*ZERO_ADD    DC.B    '0000'        ,0
*LONG_ADD    DC.B    '00000000'    ,0






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
MEM_REG:                  ; first instruction of program

* Mask byte of opcode to figure out the size field
    MOVE.B  D4,D3
    AND.B   #$C0,D3
    CMP.B   #$80,D3
    BEQ     WORD
    CMP.B   #$C0,D3
    BEQ     LONG
    BRA     INVALID

* branch here if size field is a word    
WORD    LEA WORD_LEN,A1
        BRA EA_MODE
  
* branch here if size field is a long      
LONG    LEA LONG_LEN,A1
        BRA EA_MODE

* identify EA mode      
EA_MODE MOVE.B  D4,D3
        AND.B   #$38,D3
        CMP.B   #$18,D3
        BEQ     POST_INC * we know it's a predecrement mode if equal
        CMP.B   #$10,D3
        BEQ     IND_ADDR
        
        * check for absolute addressing EA
        MOVE.B  D4,D3
        AND.B   #$3F,D3
        CMP.B   #$38,D3
        BEQ     ABS_WORD
        CMP.B   #$39,D3
        BEQ     ABS_LONG  
        
        BRA     INVALID

* branch here to grab strings displaying '(AX)+'
POST_INC    LEA ADDRPAREN,A2
        LEA     POST_PLUS,A3
        BRA     REG_RANGE
  
* branch here to grab strings displaying '(AX)'      
IND_ADDR    LEA ADDRPAREN,A2
        LEA     END_PAREN,A3
        BRA     REG_RANGE
        
ABS_WORD ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  (A0),D1 * put absolute word address in D4
        CMP.W   #$0000,D1
        BEQ     DISP_ADD
        MOVE.B  #3,D0
        TRAP    #15
        MOVEA.W #$0000,A1
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     A_RANGE
        
ABS_LONG  ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  (A0),D1 * put absolute word address in D4
        CMP.L   #$00000000,D1
        BEQ     DISP_LONG
        MOVE.B  #3,D0
        TRAP    #15
        MOVEA.W #$0000,A1
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     A_RANGE
        
DISP_ADD    LEA ZERO_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     A_RANGE
        
DISP_LONG   LEA LONG_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        LEA     COMMA_ADD,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.L  #$0000,D1
        CLR     D4
        BRA     A_RANGE     
   
* here we grab the word representing the range of registers in MOVEM operand     
REG_RANGE MOVE.B  D4,D3 * move opcode word to D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D1   * move to D6 for when we display register number
        
        ADDI.L  #$2,D5  * move PC counter by 2
        CMP.L   A6,D5   * check if we are reading past end memory address
        BGE     INVALID * opcode is out of bounds of memory we read  
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID * if range is 0000, then there are no registers
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
        BRA     A_RANGE * start identifying the registers in the operand  
        
A_RANGE CMP.L    #$0100,D3
        BLT D_RANGE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$8000,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$4000,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$2000,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$1000,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$0800,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$0400,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$0200,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     MIN_A
        
        MOVE.W  #$0100,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     MIN_A   

MIN_A   CMP.B   #$00,D4
        BEQ FIRST_AREG
        BRA A_SLASH
        
A_SLASH LEA   ADDR_SLASH,A1       
        BRA SUB_AVALUE 

FIRST_AREG MOVE.W  #$0001,D4
        LEA ADDR_REG,A1
        BRA SUB_AVALUE 
        
SUB_AVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     A_RANGE
      
D_RANGE CMP.L    #$0000,D3
        BEQ DONE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$0080,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0040,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0020,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0010,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0008,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0004,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0002,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     MIN_D
        
        MOVE.W  #$0001,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     MIN_D
  
MIN_D   CMP.B   #$00,D4
        BEQ FIRSTD_REG
        BRA ADDD_SLASH

ADDD_SLASH LEA   DATA_SLASH,A1       
        BRA SUB_DVALUE 

FIRSTD_REG MOVE.W  #$0001,D4
        LEA DATA_REG,A1
        BRA SUB_DVALUE 
   
SUB_DVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     D_RANGE

INVALID MOVE.B  #$1,D6  * indicates invalid opcode, impossible to have displacement of 1
        BRA     DONE    * perform RTS

DONE    RTS

    SIMHALT             ; halt simulator

* Put variables and constants here
COMMA_ADD   DC.B    ','          ,0
WORD_LEN    DC.B    'MOVEM.W    ',0
LONG_LEN    DC.B    'MOVEM.L    ',0
DATA_SLASH  DC.B    '/D'         ,0
DATA_REG    DC.B    'D'          ,0
ADDR_SLASH  DC.B    '/A'         ,0
ADDR_REG    DC.B    'A'          ,0
POST_PLUS   DC.B    ')+,'        ,0
ADDRPAREN   DC.B    '(A'         ,0
END_PAREN   DC.B    '),'         ,0
HEX_SYMB    DC.B    '$'          ,0
ZERO_ADD    DC.B    '000,'        ,0
LONG_ADD    DC.B    '0000000,'    ,0


    END    MEM_REG        ; last line of source

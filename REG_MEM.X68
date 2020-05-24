*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
REG_MEM:                  ; first instruction of program

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
        CMP.B   #$20,D3
        BEQ     PRE_DEC * we know it's a predecrement mode if equal
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
    
PRE_DEC MOVE.B  D4,D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D6   * move to D6 for when we display register number
        
        ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     INVALID * opcode is out of bounds of memory we read  
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        CLR     D4
        LEA     INDIRECT,A2
        LEA     END_PAREN,A3
        BRA     DATA_RANGE   

* find out range of data registers we are moving to memory        
DATA_RANGE CMP.L    #$0100,D3
        BLT ADDR_RANGE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$8000,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$4000,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$2000,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$1000,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$0800,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$0400,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$0200,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
        MOVE.W  #$0100,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     MIN_DATA
        
MIN_DATA    CMP.B   #$00,D4
        BEQ FIRST_REG
        BRA ADD_SLASH
        
ADD_SLASH LEA   DATA_SLASH,A1       
        BRA SUB_DATAVALUE 

FIRST_REG MOVE.W  #$0001,D4
        LEA DATA_REG,A1
        BRA SUB_DATAVALUE 
        
SUB_DATAVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     DATA_RANGE       
        
ADDR_RANGE    CMP.L    #$0000,D3
        BEQ PRINT
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$0080,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0040,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0020,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0010,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0008,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0004,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0002,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
        
        MOVE.W  #$0001,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     MIN_ADDR
  
MIN_ADDR    CMP.B   #$00,D4
        BEQ FIRSTA_REG
        BRA ADDA_SLASH

ADDA_SLASH LEA   ADDR_SLASH,A1       
        BRA SUB_ADDRVALUE 

FIRSTA_REG MOVE.W  #$0001,D4
        LEA ADDR_REG,A1
        BRA SUB_ADDRVALUE 
   
SUB_ADDRVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     ADDR_RANGE  
        
IND_ADDR MOVE.B  D4,D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D6   * move to D6 for when we display register number
        
        ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     INVALID * opcode is out of bounds of memory we read  
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        CLR     D4
        LEA     ADDRPAREN,A2
        LEA     END_PAREN,A3
        BRA     A_RANGE

ABS_WORD ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVEA.L A0,A4
        MOVE.W  (A4)+,D4 * put absolute word address in D4
        CMP.L   A6,A4   * word is past ending memory address given by user
        BGT     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A2
        CMP.W   #$0000,D4
        BEQ     DISP_ADD
        MOVE.B  #$8,D6
        CLR     D4
        BRA     A_RANGE
        
ABS_LONG  ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVEA.L A0,A4
        MOVE.L  (A4)+,D4 * put absolute word address in D4
        CMP.L   A6,A4   * word is past ending memory address given by user
        BGT     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A2
        CMP.L   #$00000000,D4
        BEQ     DISP_LONG
        MOVE.B  #$9,D6
        CLR     D4
        BRA     A_RANGE
  
        
DISP_ADD    LEA ZERO_ADD,A3
        CLR     D4
        BRA     A_RANGE

DISP_LONG   LEA LONG_ADD,A3
        CLR     D4
        BRA     A_RANGE     

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
        BEQ PRINT
        
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
        
PRINT   MOVEA   A2,A1
        MOVE.B  #14,D0
        TRAP    #15
        CMP.B   #$8,D6
        BEQ     WORD_END
        CMP.B   #$9,D6
        BEQ     LONG_END
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        
FINAL   MOVEA   A3,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  #$4,D6
        BRA     DONE

WORD_END    MOVE.W  (A0),D1
        MOVE.B  #3,D0
        TRAP    #15
        MOVE.W  #$6,D6  * displacement value stored in D6
        BRA     DONE
 
LONG_END    MOVE.L  (A0),D1
        MOVE.B  #3,D0
        TRAP    #15
        MOVE.W  #$8,D6  * displacement value stored in D6
        BRA     DONE
  
INVALID MOVE.B  #$1,D6  * indicates invalid opcode, impossible to have displacement of 1
        BRA     DONE    * perform RTS
        
DONE    RTS

    SIMHALT             ; halt simulator

* Put variables and constants here
WORD_LEN    DC.B    'MOVEM.W    ',0
LONG_LEN    DC.B    'MOVEM.L    ',0
DATA_SLASH  DC.B    '/D'         ,0
DATA_REG    DC.B    'D'          ,0
ADDR_SLASH  DC.B    '/A'         ,0
ADDR_REG    DC.B    'A'          ,0
INDIRECT    DC.B    ',-(A'       ,0
ADDRPAREN   DC.B    ',(A'        ,0
END_PAREN   DC.B    ')'          ,0
HEX_SYMB    DC.B    ',$'         ,0
ZERO_ADD    DC.B    '000'       ,0
LONG_ADD    DC.B    '0000000'   ,0


    END    REG_MEM        ; last line of source



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
        * will have to check for all other possible EA modes
        BRA     INVALID
    
PRE_DEC MOVE.B  D4,D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D6   * move to D6 for when we display register number
        
        ADDI.B  #$2,D5
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        CLR     D4
        BEQ     DATA_RANGE   

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
        BEQ PRINTPRE
        
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
        
        ADDI.B  #$2,D5
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        CLR     D4
        BEQ     A_RANGE

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
        BEQ PRINTIND
        
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
        LEA ADDR_REG,A1
        BRA SUB_DVALUE 
   
SUB_DVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        MOVE.B  #3,D0
        TRAP    #15
        SUB.W   D2,D3 
        BRA     D_RANGE  
       
 
PRINTPRE   LEA     INDIRECT,A1
        BRA     PRINT
        
PRINTIND    LEA     ADDRPAREN,A1
        BRA     PRINT
        
PRINT   MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  D6,D1
        MOVE.B  #3,D0
        TRAP    #15
        
        LEA     END_PAREN,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     DONE
   
INVALID LEA INV,A1
        MOVE.B  #14,D0
        TRAP    #15
        
DONE    RTS

    SIMHALT             ; halt simulator

* Put variables and constants here
WORD_LEN    DC.B    'MOVEM.W    ',0
LONG_LEN    DC.B    'MOVEM.L    ',0
DATA_SLASH  DC.B    '/D'         ,0
DATA_REG    DC.B    'D'          ,0
ADDR_SLASH  DC.B    '/A'         ,0
ADDR_REG    DC.B    'A'          ,0
INDIRECT    DC.B    ',-(A'        ,0
ADDRPAREN   DC.B    ',(A'         ,0
END_PAREN   DC.B    ')'          ,0
INV     DC.B    'Not a valid MOVEM opcode',0


    END    REG_MEM        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
REG_MEM:                  ; first instruction of program
    MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6
* Mask byte of opcode to figure out the size field
    MOVE.B  D4,D3
    AND.B   #$C0,D3
    CMP.B   #$80,D3
    BEQ     REG_MEM_WORD
    CMP.B   #$C0,D3
    BEQ     REG_MEM_LONG
    BRA     REG_MEM_INVALID

* branch here if size field is a word    
REG_MEM_WORD    LEA WORD_LEN,A1
        BRA REG_MEM_EA_MODE
  
* branch here if size field is a long      
REG_MEM_LONG    LEA LONG_LEN,A1
        BRA REG_MEM_EA_MODE
  
* identify EA mode      
REG_MEM_EA_MODE MOVE.B  D4,D3
        AND.B   #$38,D3
        CMP.B   #$20,D3
        BEQ     REG_MEM_PRE_DEC * we know it's a predecrement mode if equal
        CMP.B   #$10,D3
        BEQ     REG_MEM_IND_ADDR
        
        * check for absolute addressing EA
        MOVE.B  D4,D3
        AND.B   #$3F,D3
        CMP.B   #$38,D3
        BEQ     REG_MEM_ABS_WORD
        CMP.B   #$39,D3
        BEQ     REG_MEM_ABS_LONG  
        
        BRA     REG_MEM_INVALIDEA
    
REG_MEM_PRE_DEC MOVE.B  D4,D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D6   * move to D6 for when we display register number
        
        ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     REG_MEM_INVALID * opcode is out of bounds of memory we read  
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     REG_MEM_INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        CLR     D4
        LEA     INDIRECT,A2
        LEA     REND_PAREN,A3
        BRA     REG_MEM_DATA_RANGE   

* find out range of data registers we are moving to memory        
REG_MEM_DATA_RANGE CMP.L    #$0100,D3
        BLT REG_MEM_ADDR_RANGE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$8000,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$4000,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$2000,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$1000,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$0800,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$0400,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$0200,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
        MOVE.W  #$0100,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_DATA
        
REG_MEM_MIN_DATA    CMP.B   #$00,D4
        BEQ REG_MEM_FIRST_REG
        BRA REG_MEM_ADD_SLASH
        
REG_MEM_ADD_SLASH LEA   DATA_SLASH,A1       
        BRA REG_MEM_SUB_DATAVALUE 

REG_MEM_FIRST_REG MOVE.W  #$0001,D4
        LEA DATA_REG,A1
        BRA REG_MEM_SUB_DATAVALUE 
        
REG_MEM_SUB_DATAVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        
        SUB.W   D2,D3 
        BRA     REG_MEM_DATA_RANGE       
        
REG_MEM_ADDR_RANGE    CMP.L    #$0000,D3
        BEQ REG_MEM_PRINT
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$0080,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0040,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0020,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0010,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0008,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0004,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0002,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
        
        MOVE.W  #$0001,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_ADDR
  
REG_MEM_MIN_ADDR    CMP.B   #$00,D4
        BEQ REG_MEM_FIRSTA_REG
        BRA REG_MEM_ADDA_SLASH

REG_MEM_ADDA_SLASH LEA   ADDR_SLASH,A1       
        BRA REG_MEM_SUB_ADDRVALUE 

REG_MEM_FIRSTA_REG MOVE.W  #$0001,D4
        LEA ADDR_REG,A1
        BRA REG_MEM_SUB_ADDRVALUE 
   
REG_MEM_SUB_ADDRVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1

        SUB.W   D2,D3 
        BRA     REG_MEM_ADDR_RANGE  
        
REG_MEM_IND_ADDR MOVE.B  D4,D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D6   * move to D6 for when we display register number
        
        ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     REG_MEM_INVALID * opcode is out of bounds of memory we read  
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     REG_MEM_INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        CLR     D4
        LEA     ADDRPAREN_COMMA,A2
        LEA     REND_PAREN,A3
        BRA     REG_MEM_A_RANGE

REG_MEM_ABS_WORD ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     REG_MEM_INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     REG_MEM_INVALID
        MOVEA.L A0,A4
        MOVE.W  (A4)+,D4 * put absolute word address in D4
        CMP.L   A6,A4   * word is past ending memory address given by user
        BGT     REG_MEM_INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A2
        *CMP.W   #$0000,D4
        *BEQ     REG_MEM_DISP_ADD
        MOVE.B  #$8,D6
        CLR     D4
        BRA     REG_MEM_A_RANGE
        
REG_MEM_ABS_LONG  ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     REG_MEM_INVALID * opcode is out of bounds of memory we read
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0)+,D3 * move word representing register range to D3
        CMP.W   #$0000,D3  
        BEQ     REG_MEM_INVALID
        MOVEA.L A0,A4
        MOVE.L  (A4)+,D4 * put absolute word address in D4
        CMP.L   A6,A4   * word is past ending memory address given by user
        BGT     REG_MEM_INVALID
        MOVE.B  #14,D0 * starting print MOVEM opcode
        TRAP    #15   
        LEA     HEX_SYMB,A2
        *CMP.L   #$00000000,D4
        *BEQ     REG_MEM_DISP_LONG
        MOVE.B  #$9,D6
        CLR     D4
        BRA     REG_MEM_A_RANGE      

REG_MEM_A_RANGE CMP.L    #$0100,D3
        BLT REG_MEM_D_RANGE
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$8000,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$4000,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$2000,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$1000,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$0800,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$0400,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$0200,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A
        
        MOVE.W  #$0100,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_A   

REG_MEM_MIN_A   CMP.B   #$00,D4
        BEQ REG_MEM_FIRST_AREG
        BRA REG_MEM_A_SLASH
        
REG_MEM_A_SLASH LEA   ADDR_SLASH,A1       
        BRA REG_MEM_SUB_AVALUE 

REG_MEM_FIRST_AREG MOVE.W  #$0001,D4
        LEA ADDR_REG,A1
        BRA REG_MEM_SUB_AVALUE 
        
REG_MEM_SUB_AVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        
        SUB.W   D2,D3 
        BRA     REG_MEM_A_RANGE
      
REG_MEM_D_RANGE CMP.L    #$0000,D3
        BEQ REG_MEM_PRINT
        
        * we compare the register range with each possible value
        * and display the register in the output
        * store register word value in D2, and register number in D0
        MOVE.W  #$0080,D2
        MOVE.W  #$7,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0040,D2
        MOVE.W  #$6,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0020,D2
        MOVE.W  #$5,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0010,D2
        MOVE.W  #$4,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0008,D2
        MOVE.W  #$3,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0004,D2
        MOVE.W  #$2,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0002,D2
        MOVE.W  #$1,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
        
        MOVE.W  #$0001,D2
        MOVE.W  #$0,D7
        CMP.L   D2,D3
        BGE     REG_MEM_MIN_D
  
REG_MEM_MIN_D   CMP.B   #$00,D4
        BEQ REG_MEM_FIRSTD_REG
        BRA REG_MEM_ADDD_SLASH

REG_MEM_ADDD_SLASH LEA   DATA_SLASH,A1       
        BRA REG_MEM_SUB_DVALUE 

REG_MEM_FIRSTD_REG MOVE.W  #$0001,D4
        LEA DATA_REG,A1
        BRA REG_MEM_SUB_DVALUE 
   
REG_MEM_SUB_DVALUE   MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  D7,D1
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        
        SUB.W   D2,D3 
        BRA     REG_MEM_D_RANGE  
        
REG_MEM_PRINT   
        LEA COMMA, A1
        BSR PRINT
        MOVEA.L   A2,A1
        MOVE.B  #14,D0
        TRAP    #15
        CMP.B   #$8,D6
        BEQ     REG_MEM_WORD_END
        CMP.B   #$9,D6
        BEQ     REG_MEM_LONG_END
        MOVE.B  D6,D1
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        *BSR ADAPTIVE_PRINTREG
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        
        
REG_MEM_FINAL   MOVEA.L   A3,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.W  #$4,D6
        BRA     REG_MEM_DONE

REG_MEM_WORD_END    MOVE.W  (A0),D1
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR ADAPTIVE_PRINTREG
        MOVE.L  (SP)+, D1
        
        
        
        MOVE.W  #$6,D6  * displacement value stored in D6
        BRA     REG_MEM_DONE
 
REG_MEM_LONG_END    MOVE.L  (A0),D1
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR ADAPTIVE_PRINTREG
        MOVE.L  (SP)+, D1
        
        MOVE.W  #$8,D6  * displacement value stored in D6
        BRA     REG_MEM_DONE
  
REG_MEM_INVALID JSR   INVALID
            BRA     REG_MEM_DONE
            
REG_MEM_INVALIDEA   JSR INVALIDEA
            BRA     REG_MEM_DONE
        
REG_MEM_DONE    MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6
            RTS     *Return to subroutine here

* Put variables and constants here
WORD_LEN    DC.B    'MOVEM.W    ',0
LONG_LEN    DC.B    'MOVEM.L    ',0
DATA_SLASH  DC.B    '/D'         ,0
DATA_REG    DC.B    'D'          ,0
ADDR_SLASH  DC.B    '/A'         ,0
ADDR_REG    DC.B    'A'          ,0
INDIRECT    DC.B    '-(A'       ,0
ADDRPAREN   DC.B    '(A'        ,0
ADDRPAREN_COMMA DC.B    '(A'    ,0
REND_PAREN   DC.B    ')'          ,0
HEX_SYMB    DC.B    '$'         ,0
ZERO_ADD    DC.B    '000'       ,0
LONG_ADD    DC.B    '0000000'   ,0

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

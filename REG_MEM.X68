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
        * will have to check for all other possible EA modes
        * also need to check if invalid opcode
    
PRE_DEC MOVE.B  D4,D3
        AND.B   #$07,D3 * obtain address register number
        MOVE.B  D3,D6   * move to D6 for when we display register number
        
        * starting print MOVEM opcode
        MOVE.B  #14,D0
        TRAP    #15   
        ADDI.B  #$2,D5
        MOVEA.L  D5,A0  * move PC counter to an address register
        MOVE.W  (A0),D3 * move word representing register range to D3
        CLR     D4
        BRA     DATA_RANGE

* find out range of data registers we are moving to memory        
DATA_RANGE CMP.L    #$0100,D3
        BLT ADDR_RANGE
        
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
        
ADDR_RANGE      
    

    SIMHALT             ; halt simulator

* Put variables and constants here
WORD_LEN    DC.B    'MOVEM.W    ',0
LONG_LEN    DC.B    'MOVEM.L    ',0
DATA_SLASH    DC.B    '/D'       ,0
DATA_REG    DC.B    'D'          ,0

    END    REG_MEM        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

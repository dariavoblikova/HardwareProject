*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

SHIFT_OPCODES:                  ; first instruction of program

* Put program code here
    MOVE.W  D4,D3     * store copy in D3 for masking
    ANDI.W  #$0100,D3 * mask opcode to see if it's rotate left or right
    CMP.W   #$0100,D3
    BEQ     LEFT_ROTATE * if equal, we know it's a left rotate
    CMP.W   #$0000,D3
    BEQ     RIGHT_ROTATE * if equal, we know it's a right rotate
 
* loads string specifying direction of rotate   
LEFT_ROTATE LEA ROTATEL,A1
    BRA     REG_NUM
  
* loads string specifying direction of rotate     
RIGHT_ROTATE LEA ROTATER,A1
    BRA     REG_NUM

* finds count/register value    
REG_NUM MOVE.W  D4,D1   * store copy in D1 for masking
    ANDI.W  #$0E00,D1   * mask opcode to get count/register number
    LSR.W   #8,D1       * shift right so number is in right most byte
    LSR.W   #$1,D1
    BRA     OP_SIZE     * branch to get size of rotate operation
    
* finds operation size (B, W, or L)
OP_SIZE MOVE.B  D4,D3   * store copy in D3 for masking
    ANDI.B  #$C0,D3     * mask to only show size bits
    CMP.B   #$00,D3
    BEQ     BYTE        * we know the size is a byte if equal
    CMP.B   #$40,D3
    BEQ     WORD        * we know the size is a word if equal
    CMP.B   #$80,D3
    BEQ     LONG        * we know the size is a long if equal
    CMP.B   #$C0,D3     * we have an EA to find
    BEQ     EA          * find EA
 
* branch here to load appropriate size operation to A2
   
BYTE    LEA SIZEB,A2
        BRA IR

WORD    LEA SIZEW,A2
        BRA IR

LONG    LEA SIZEL,A2
        BRA IR 
        
EA      MOVE.B  D4,D3
        ANDI.B  #$38,D3 * only show EA mode bits
        CMP.B   #$10,D3
        BEQ     SHIFT_IND   * EA is address register indirect
        CMP.B   #$18,D3
        BEQ     SHIFT_POST  * EA is address register indirect post-increment
        
SHIFT_IND   LEA ADDRI,A2
        LEA     ENDPAREN,A3
        MOVE.B  D4,D1
        ANDI.B  #$07,D1 * only show register number bits
        BRA     PRINTIND
        
        
SHIFT_POST  LEA ADDRI,A2
        LEA     POSTPAREN,A3
        MOVE.B  D4,D1
        ANDI.B  #$07,D1 * only show register number bits
        BRA     PRINTIND

PRINTIND MOVE.B #14,D0
        TRAP    #15
        LEA     SPACE,A1    * create empty space between opcode and operand
        TRAP    #15
        MOVEA   A2,A1
        TRAP    #15
        MOVE.B  #3,D0
        TRAP    #15
        MOVEA   A3,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     DONE

* check if count/register is immediate value or data register
IR      MOVE.B  D4,D3  * store copy in D3 for masking 
        ANDI.B  #$20,D3 * only show i/r bit
        CMP.B   #$20,D3
        BEQ     DREG    * need to display that this is a data register
        CMP.B   #$00,D3
        BEQ     IMMEDIATE   * need to display that this is an immediate value

* branch here to load appropriate count/register type (D or #)

DREG    LEA     DATAR,A3
        BRA     REGNUM
        
IMMEDIATE   LEA POUNDSIGN,A3
        BRA     CHECKVAL
  
* account for case where immediate value uses 0 to represent move 8      
CHECKVAL  CMP.B   #$0,D1
        BNE     REGNUM
        MOVE.B  #$08,D1 * 0 represents move 8
        BRA     REGNUM
        
REGNUM  MOVE.B  D4,D3 * store copy in D3 for masking 
        ANDI.B  #$07,D3 * only show register bits
        BRA     PRINT   * can now print entire opcode
  
* print all information for opcode to console      
PRINT   MOVE.B  #14,D0
        TRAP    #15     * display shift opcode
        MOVEA   A2,A1   * move string representing size to A1
        TRAP    #15     * display size of opcode
        MOVEA   A3,A1   * move string representing count/reg to A1
        TRAP    #15     * display '#' or 'D'
        MOVE.B  #3,D0
        TRAP    #15     * display count/register number
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15     * display comma seperating operands
        LEA     DATAR,A1    * for displaying destination operand
        TRAP    #15     * displays 'D' for destination operand
        MOVE.B  D3,D1   * register number moves to D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     DONE
        
        
        

DONE    RTS
    *SIMHALT             ; halt simulator

* Put variables and constants here
ROTATEL DC.B    'ROL',0
ROTATER DC.B    'ROR',0
SIZEB   DC.B    '.B     ',0
SIZEW   DC.B    '.W     ',0
SIZEL   DC.B    '.L     ',0
DATAR   DC.B    'D',0
POUNDSIGN   DC.B    '#',0
COMMA   DC.B    ',',0
ADDRI   DC.B    '(A',0
ENDPAREN    DC.B    ')',0
POSTPAREN   DC.B    ')+',0
SPACE       DC.B    '   ',0

    END    SHIFT_OPCODES        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

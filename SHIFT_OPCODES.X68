*-----------------------------------------------------------
* Title      : Shift Opcodes
* Written by : Amman Nega
* Date       : May 25, 2020
* Description: Decodes ROR, ROL, ASR, ASL, LSR, and LSL.
*-----------------------------------------------------------

SHIFT_OPCODES: MOVEM.L     D0-D5/D7/A0-A6, -(SP)          * save all registers except for D6
* Put program code here
* determine if there is an EA or not
SHIFT_START    CLR     D7
    MOVE.B  D4,D3
    ANDI.B  #$C0,D3
    CMP.B   #$C0,D3
    BEQ     SHIFT_EACHECK
    BRA     SHIFT_NOTEA

* check which type of shift opcode has the EA
SHIFT_EACHECK MOVE.W  D4,D3
    ANDI.W  #$0E00,D3
    CMP.W   #$0000,D3
    BEQ     ASHIFT
    CMP.W   #$0600,D3
    BEQ     RSHIFT
    CMP.W   #$0200,D3
    BEQ     LSHIFT

* find direction type of arithmetic shift
ASHIFT  MOVE.W  #$1,D7
    BRA     ARITHMETIC

* find direction type of rotation
RSHIFT   MOVE.W  #$1,D7
    BRA     ROTATE
  
* find direction type of logical shift  
LSHIFT  MOVE.W  #$1,D7
    BRA     LOGICAL
    
* in case there is no EA, check what shift opcode it is    
SHIFT_NOTEA  MOVE.B   D4,D3
    ANDI.B  #$18,D3
    CMP.B   #$00,D3
    BEQ     ARITHMETIC
    CMP.B   #$18,D3
    BEQ     ROTATE
    CMP.B   #$08,D3
    BEQ     LOGICAL
    BRA     SHIFT_INVALID
      
* determine if arithmetic left or right
ARITHMETIC    MOVE.W  D4,D3     * store copy in D3 for masking
    ANDI.W  #$0100,D3 * mask opcode to see if it's rotate left or right
    CMP.W   #$0100,D3
    BEQ     LEFT_ARITH * if equal, we know it's a left rotate
    CMP.W   #$0000,D3
    BEQ     RIGHT_ARITH * if equal, we know it's a right rotate    

* determine if rotate left or right
ROTATE    MOVE.W  D4,D3     * store copy in D3 for masking
    ANDI.W  #$0100,D3 * mask opcode to see if it's rotate left or right
    CMP.W   #$0100,D3
    BEQ     LEFT_ROTATE * if equal, we know it's a left rotate
    CMP.W   #$0000,D3
    BEQ     RIGHT_ROTATE * if equal, we know it's a right rotate
    
* determine if rotate left or right
LOGICAL   MOVE.W  D4,D3     * store copy in D3 for masking
    ANDI.W  #$0100,D3 * mask opcode to see if it's rotate left or right
    CMP.W   #$0100,D3
    BEQ     LEFT_LOGICAL * if equal, we know it's a left rotate
    CMP.W   #$0000,D3
    BEQ     RIGHT_LOGICAL * if equal, we know it's a right rotate
 
* loads string specifying direction of rotate   
LEFT_LOGICAL LEA LOGICALL,A1
    CMP.W   #$1,D7
    BEQ     SHIFT_EA      * we know there is an EA, so skip REG_NUM
    BRA     REG_NUM
  
* loads string specifying direction of rotate     
RIGHT_LOGICAL LEA LOGICALR,A1
    CMP.W   #$1,D7
    BEQ     SHIFT_EA      * we know there is an EA, so skip REG_NUM
    BRA     REG_NUM 
 
* loads string specifying direction of rotate   
LEFT_ROTATE LEA ROTATEL,A1
    CMP.W   #$1,D7
    BEQ     SHIFT_EA      * we know there is an EA, so skip REG_NUM
    BRA     REG_NUM
  
* loads string specifying direction of rotate     
RIGHT_ROTATE LEA ROTATER,A1
    CMP.W   #$1,D7
    BEQ     SHIFT_EA      * we know there is an EA, so skip REG_NUM
    BRA     REG_NUM
    
* loads string specifying direction of rotate   
LEFT_ARITH LEA ARITHL,A1
    CMP.W   #$1,D7
    BEQ     SHIFT_EA      * we know there is an EA, so skip REG_NUM
    BRA     REG_NUM
  
* loads string specifying direction of rotate     
RIGHT_ARITH LEA ARITHR,A1
    CMP.W   #$1,D7
    BEQ     SHIFT_EA      * we know there is an EA, so skip REG_NUM
    BRA     REG_NUM

* finds count/register value    
REG_NUM MOVE.W  D4,D1   * store copy in D1 for masking
    ANDI.W  #$0E00,D1   * mask opcode to get count/register number
    LSR.W   #8,D1       * shift right so number is in right most byte
    LSR.W   #$1,D1
    BRA     SHIFT_OP_SIZE     * branch to get size of rotate operation
    
* finds operation size (B, W, or L)
SHIFT_OP_SIZE MOVE.B  D4,D3   * store copy in D3 for masking
    ANDI.B  #$C0,D3     * mask to only show size bits
    CMP.B   #$00,D3
    BEQ     SREAD_BYTE        * we know the size is a byte if equal
    CMP.B   #$40,D3
    BEQ     SREAD_WORD        * we know the size is a word if equal
    CMP.B   #$80,D3
    BEQ     SREAD_LONG        * we know the size is a long if equal
    CMP.B   #$C0,D3     * we have an EA to find
    BEQ     SHIFT_EA          * find EA
 
* branch here to load appropriate size operation to A2
   
SREAD_BYTE    LEA SIZEB,A2
        BRA IR

SREAD_WORD    LEA SIZEW,A2
        BRA IR

SREAD_LONG    LEA SIZEL,A2
        BRA IR 
        
SHIFT_EA    MOVE.B  D4,D3
        ANDI.B  #$38,D3 * only show EA mode bits
        CMP.B   #$10,D3
        BEQ     SHIFT_IND   * EA is address register indirect
        CMP.B   #$18,D3
        BEQ     SHIFT_POST  * EA is address register indirect post-increment
        CMP.B   #$20,D3
        BEQ     SHIFT_PRE   * EA is address register indirect pre-decrement
        MOVE.B  D4,D3
        ANDI.B  #$3F,D3     * only show EA bits
        CMP.B   #$38,D3
        BEQ     SHIFT_WORD  * EA is absolute word addressing
        CMP.B   #$39,D3
        BEQ     SHIFT_LONG  * EA is absolute long addressing
        BRA     SHIFT_INVALIDEA
        
SHIFT_IND   LEA ADDRI,A2
        LEA     ENDPAREN,A3
        MOVE.B  D4,D1
        ANDI.B  #$07,D1 * only show register number bits
        MOVE.W  #$2,D6      * store displacement
        BRA     PRINTIND
        
        
SHIFT_POST  LEA ADDRI,A2
        LEA     POSTPAREN,A3
        MOVE.B  D4,D1
        ANDI.B  #$07,D1 * only show register number bits
        MOVE.W  #$2,D6      * store displacement
        BRA     PRINTIND
        
SHIFT_PRE   LEA PREPAREN,A2
        LEA     ENDPAREN,A3
        MOVE.B  D4,D1
        ANDI.B  #$07,D1 * only show register number bits
        MOVE.W  #$2,D6      * store displacement
        BRA     PRINTIND
        
SHIFT_WORD  
        LEA HEXSYMB,A2  * load string with '$' symbol in A2
        ADDI.L  #$2,D5
        CMP.L   A6,D5
        BGE     SHIFT_INVALID     * past ending address
        MOVEA.L D5,A3
        MOVE.W  (A3),D1     * move absolute word address to D1
        MOVE.W  #$4,D6      * store displacement
        BRA     PRINTABS        

SHIFT_LONG  LEA HEXSYMB,A2  * load string with '$' symbol in A2
        MOVE.L  D5,D2
        ADDI.L  #$4,D2
        CMP.L   A6,D2
        BGE     SHIFT_INVALID     * past ending address
        ADDI.L  #$2,D5
        MOVEA.L D5,A3
        MOVE.L  (A3),D1     * move absolute word address to D1
        MOVE.W  #$6,D6      * store displacement
        BRA     PRINTABS
        
PRINTABS MOVE.B #14,D0
        TRAP    #15
        LEA SIZEW,A4  * load '.W    ' because memory shifts can only be word-sized
        MOVEA.L A4,A1       load '.W    ' for printing
        TRAP    #15         print string at (A1) 
        *LEA     SPACE,A1    * create empty space between opcode and operand
        *TRAP    #15
        MOVEA.L   A2,A1
        TRAP    #15
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR ADAPTIVE_PRINTREG
        MOVE.L  (SP)+, D1
        
        BRA     SHIFT_END

PRINTIND MOVE.B #14,D0
        TRAP    #15
        LEA SIZEW,A4  * load '.W    ' because memory shifts can only be word-sized
        MOVEA.L A4,A1       load '.W    ' for printing
        TRAP    #15         print string at (A1)  
        *LEA     SPACE,A1    * create empty space between opcode and operand
        *TRAP    #15
        MOVEA.L   A2,A1
        TRAP    #15
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR ADAPTIVE_PRINTREG
        MOVE.L  (SP)+, D1
        
        MOVEA.L   A3,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     SHIFT_END

* check if count/register is immediate value or data register
IR      MOVE.W  #$2,D6  * store displacement in D6
        MOVE.B  D4,D3  * store copy in D3 for masking 
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
        BRA     SHIFT_PRINT   * can now print entire opcode
  
* print all information for opcode to console      
SHIFT_PRINT   MOVE.B  #14,D0
        TRAP    #15     * display shift opcode
        MOVEA.L   A2,A1   * move string representing size to A1
        TRAP    #15     * display size of opcode
        MOVEA.L   A3,A1   * move string representing count/reg to A1
        TRAP    #15     * display '#' or 'D'
        
        MOVE.L  D1, -(SP)   *safe replacement for trap 15
        MOVE.L  D1, D0
        BSR PRINTHEX
        MOVE.L  (SP)+, D1
        
        LEA     COMMA,A1
        MOVE.B  #14,D0
        TRAP    #15     * display comma seperating operands
        LEA     DATAR,A1    * for displaying destination operand
        TRAP    #15     * displays 'D' for destination operand
        MOVE.B  D3,D1   * register number moves to D1
        MOVE.B  #3,D0
        TRAP    #15
        BRA     SHIFT_END
  
SHIFT_INVALID   JSR     INVALID
            BRA     SHIFT_END 

SHIFT_INVALIDEA JSR     INVALIDEA
            BRA     SHIFT_END 
      
SHIFT_END   MOVEM.L     (SP)+, D0-D5/D7/A0-A6          * pop the registers back except for D6
            RTS     *Return to subroutine here

* Put variables and constants here
ROTATEL DC.B    'ROL',0
ROTATER DC.B    'ROR',0
ARITHL  DC.B    'ASL',0
ARITHR  DC.B    'ASR',0
LOGICALL    DC.B    'LSL',0
LOGICALR    DC.B    'LSR',0
SIZEB   DC.B    '.B     ',0
SIZEW   DC.B    '.W     ',0
SIZEL   DC.B    '.L     ',0
DATAR   DC.B    'D',0
POUNDSIGN   DC.B    '#',0
COMMA   DC.B    ',',0
ADDRI   DC.B    '(A',0
PREPAREN  DC.B  '-(A',0
ENDPAREN    DC.B    ')',0
POSTPAREN   DC.B    ')+',0
SPACE       DC.B    '   ',0
HEXSYMB     DC.B    '$',0
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

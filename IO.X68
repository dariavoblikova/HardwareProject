*****************************STRINGS************************************
CR  EQU $0D
LF  EQU $0A
LN          DC.B '',CR,LF,0
MERROR      DC.B 'ERROR PARSING MODE',CR,LF,0
EAREGERROR  DC.B 'ERROR PARSING EA REG',CR,LF,0
EAMODERROR  DC.B 'ERROR PARSING EA MODE',CR,LF,0
RERROR      DC.B 'ERROR: OUT OF BOUNDS',CR,LF,0
BDISP       DC.B 'B',0
WDISP       DC.B 'W',0
LDISP       DC.B 'L',0
ADDDOT      DC.B 'ADD.',0
ADISP       DC.B 'A',0
DDISP       DC.B 'D',0
OPAREN      DC.B '(',0
CPAREN      DC.B ')',0
PLUS        DC.B '+',0
MINUS       DC.B '-',0
HEXI        DC.B '#$',0
MONEY       DC.B '$',0 
ADDA_ST     DC.B 'ADDA.',0
**********************REFER TO STRINGS************************
*SPACE       DC.B ' ',0
*COMMA       DC.B ',',0
*opcode_BEQ  DC.B 'BEQ ',0 
*opcode_BLE  DC.B 'BLE ',0
*opcode_BGT  DC.B 'BGT ',0
*opcode_BRA  DC.B 'BRA ',0
*ROTATEL DC.B    'ROL',0
*ROTATER DC.B    'ROR',0
*ARITHL  DC.B    'ASL',0
*ARITHR  DC.B    'ASR',0
*LOGICALL    DC.B    'LSL',0
*LOGICALR    DC.B    'LSR',0
*SIZEB   DC.B    '.B     ',0
*SIZEW   DC.B    '.W     ',0
*SIZEL   DC.B    '.L     ',0
*DATAR   DC.B    'D',0
*POUNDSIGN   DC.B    '#',0
*ADDRI   DC.B    '(A',0
*PREPAREN  DC.B  '-(A',0
*ENDPAREN    DC.B    ')',0
*POSTPAREN   DC.B    ')+',0
*HEXSYMB     DC.B    '$',0
**********************HEX DIGITS*******************************
HEX0        DC.B '0',0 
HEX1        DC.B '1',0
HEX2        DC.B '2',0
HEX3        DC.B '3',0
HEX4        DC.B '4',0
HEX5        DC.B '5',0
HEX6        DC.B '6',0
HEX7        DC.B '7',0
HEX8        DC.B '8',0
HEX9        DC.B '9',0
HEXA        DC.B 'A',0
HEXB        DC.B 'B',0
HEXC        DC.B 'C',0
HEXD        DC.B 'D',0
HEXE        DC.B 'E',0
HEXF        DC.B 'F',0



****************************************************************
* Contract:
****************************************************************
* Input:        A1 contains address of null terminated string
* Operation:    No changes to stack/registers 
* Output:       Prints string at A1
****************************************************************
PRINT: MOVE.B D0, -(SP)     *push to stack
    MOVE.B #14, D0          *load print trap
    TRAP #15                *execute print trap
    MOVE.B (SP)+, D0        *pop from stack
    RTS                     *return
    

**********CONTRACT**********
*  INPUT:        D0 = Dn ; D1 = EA reg ; D2 = EA mode ; D3 = opmode 
*  OPERATION:    Decides which EA is being used and prints accordingly, used in ADD_SUBROUTINE
*  OUTPUT:       Prints based on EA
*  this subroutine is flawed and needs improvements, namely when it errors it does so poorly
EAPRINT: CMP.B #$00, D2  *if it's 00, it's Dn
        BEQ EAT
        BRA PEAT
        
EAT     LEA DDISP, A1   *Dn
        BSR PRINT           *prints D
        MOVE.B D0, -(SP)    *store D0 on stack as we will need it for printhex
        MOVE.B D1, D0       *move D1 to D0 as printhex takes D0 as input
        BSR PRINTHEX        *print what's in D0 as hex
        MOVE.B (SP)+, D0    *restore D0
        RTS
        
PEAT    CMP.B #$01, D2  *if it's 01, it's An
        BEQ EAT2
        BRA PEAT2
        
EAT2    LEA ADISP, A1   *Prints A
        BSR PRINT
        MOVE.B D0, -(SP)    *Refer to EAT (Dn) for procedure of PRINTHEX and D0
        MOVE.B D1, D0
        BSR PRINTHEX
        MOVE.B (SP)+, D0
        RTS
        
PEAT2   CMP.B #$02, D2  *if it's 02, it's (An)
        BEQ EAT3
        BRA PEAT3

EAT3    LEA OPAREN, A1  *print open parentheses
        BSR PRINT
        LEA ADISP, A1   *print A
        BSR PRINT
        
        MOVE.B D0, -(SP)    *refer to EAT (Dn)
        MOVE.B D1, D0       *print register number
        BSR PRINTHEX
        MOVE.B (SP)+, D0
        
        LEA CPAREN, A1      *print closed parentheses
        BSR PRINT
        RTS
        
PEAT3   CMP.B #$03, D2  *if it's 03, it's (An)+
        BEQ EAT4
        BRA PEAT4

EAT4    LEA OPAREN, A1  *print (A
        BSR PRINT
        LEA ADISP, A1
        BSR PRINT
        
        MOVE.B D0, -(SP)    *print register 
        MOVE.B D1, D0
        BSR PRINTHEX
        MOVE.B (SP)+, D0
        
        LEA CPAREN, A1  *print )+
        BSR PRINT
        LEA PLUS, A1
        BSR PRINT
        RTS    
        
PEAT4   CMP.B #$04, D2  *if it's 04, it's -(An)
        BEQ EAT5
        BRA PEAT5

EAT5    LEA MINUS, A1   *print -(A
        BSR PRINT
        LEA OPAREN, A1
        BSR PRINT
        LEA ADISP, A1
        BSR PRINT
        
        MOVE.B D0, -(SP)    *print register
        MOVE.B D1, D0
        BSR PRINTHEX
        MOVE.B (SP)+, D0
        
        LEA CPAREN, A1      *print )
        BSR PRINT
        RTS 

PEAT5   CMP.B #$07, D2
        BNE EAMODE_ERROR    *error if it's not seven (111), as we've checked all other valid EAMODE's
        *d1 eareg
        CMP.B   #$00,   D1  *is it $.W
        BEQ     EAT6
        BRA     PEAT6
        
EAT6    LEA     MONEY,  A1  *it is $.W, so print $
        BSR     PRINT   
        MOVE.L  D5,     -(SP) *store states
        MOVE.L  D0,     -(SP)
        ADDI.L  #2,     D5 *compensate for opcode len
        MOVE.L  D5,     A0 *get data from memory through A0
        
        MOVE.W  (A0),   D0  *load data from A0
        ROL.W #4, D0        *print digit 4
        BSR PRINTHEX
        ROL.W #4, D0        *3
        BSR PRINTHEX
        ROL.W #4, D0        *2
        BSR PRINTHEX     
        ROL.W #4, D0        *1
        BSR PRINTHEX
        MOVE.L (SP)+,   D0  *restore stack
        MOVE.L (SP)+,   D5
        RTS
        
PEAT6   CMP.B #$01,     D1  *is it $.L
        BEQ EAT7
        BRA PEAT7

EAT7    LEA     MONEY,  A1  *it is $.W
        BSR     PRINT   
        MOVE.L  D5,     -(SP) *store states
        MOVE.L  D0,     -(SP)
        ADDI.L  #2,     D5 *compensate for opcode len
        MOVE.L  D5,     A0
        
        MOVE.W  (A0),   D0
        BSR     PRINTREG        *printreg prints all of D0 (long) as hex
        MOVE.L  (SP)+,   D0
        MOVE.L  (SP)+,   D5
        RTS
        
PEAT7   LEA     HEXI,   A1
        BSR     PRINT
        CMP.B   #$01,   D3  
        BLT     PBYTET   * < 1 byte, #$AB
        BEQ     PWORDT   * = 1 word, #$ABCD
        BGT     PLONGT   * > 1 long, #$ABCDEFGH
        
*if immediate byte then
PBYTET  MOVE.L  D5,     -(SP) *store states
        MOVE.L  D0,     -(SP)
        ADDI.L  #2,     D5 *compensate for opcode len
        MOVE.L  D5,     A0
        
        MOVE.W  (A0),   D0
        
        ROL.B #4, D0    *print digit 2
        BSR PRINTHEX
        ROL.B #4, D0    *print digit 1
        BSR PRINTHEX
        
        MOVE.L (SP)+,   D0
        MOVE.L (SP)+,   D5
        RTS
        
*if immediate word then
PWORDT  MOVE.L  D5,     -(SP) *store states
        MOVE.L  D0,     -(SP)
        ADDI.L  #2,     D5 *compensate for opcode len
        MOVE.L  D5,     A0
        
        MOVE.W  (A0),   D0
        ROL.W #4, D0
        BSR PRINTHEX
        ROL.W #4, D0
        BSR PRINTHEX
        ROL.W #4, D0
        BSR PRINTHEX
        ROL.W #4, D0
        BSR PRINTHEX
        
        MOVE.L (SP)+,   D0
        MOVE.L (SP)+,   D5
        RTS
        
*if immediate long then
PLONGT  MOVE.L  D5,     -(SP) *store states
        MOVE.L  D0,     -(SP)
        ADDI.L  #2,     D5 *compensate for opcode len
        MOVE.L  D5,     A0
        
        MOVE.L  (A0),   D0
        BSR PRINTREG
        MOVE.L (SP)+,   D0
        MOVE.L (SP)+,   D5
        RTS 

EAMODE_ERROR    LEA EAMODERROR, A1    
                BSR PRINT
                RTS
                
 

* prints D0
PRINTREG:
        MOVEM D0-D1, -(SP)  *store D0 and D1
        MOVE.B #$08, D1     *for loop 8->0
PRGL    CMP.B #$00, D1      *if it's reached zero break
        BEQ PPRGL           
        SUBI.B #$01, D1     *else subtract 1
        ROL.L #4, D0        *print digits 1-8
        BSR PRINTHEX        *print hex in D0
        BRA PRGL            *loop
PPRGL   MOVEM (SP)+, D0-D1  *post loop, restore D0 and D1
        RTS



    


* 
* This is a very bad way to print hex
* digits but we can't use trap 15
* so whatever. Literally just checks every digit, prints its string equivalent.
* 
PRINTHEX: MOVE.B  D0,     -(SP)
        AND.B   #$0F,   D0
        
        CMP.B   #$00,   D0
        BEQ     PHT0
        BRA     PPHT0
        
PHT0    LEA     HEX0,   A1  *print hex0 if it's zero
        BSR     PRINT
        BRA     PHEND
         
PPHT0   CMP.B   #$01,   D0  
        BEQ     PHT1
        BRA     PPHT1
        
PHT1    LEA     HEX1,   A1  *print hex1 if it's one
        BSR     PRINT
        BRA     PHEND
        
PPHT1   CMP.B   #$02,   D0
        BEQ     PHT2
        BRA     PPHT2
        
PHT2    LEA     HEX2,   A1  *print hex2 if it's two
        BSR     PRINT
        BRA     PHEND 
        
PPHT2   CMP.B   #$03,   D0
        BEQ     PHT3
        BRA     PPHT3
        
PHT3    LEA     HEX3,   A1  *you get the picture
        BSR     PRINT
        BRA     PHEND 
        
PPHT3   CMP.B   #$04,   D0
        BEQ     PHT4
        BRA     PPHT4
        
PHT4    LEA     HEX4,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHT4   CMP.B   #$05,   D0
        BEQ     PHT5
        BRA     PPHT5
        
PHT5    LEA     HEX5,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHT5   CMP.B   #$06,   D0
        BEQ     PHT6
        BRA     PPHT6
        
PHT6    LEA     HEX6,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHT6   CMP.B   #$07,   D0
        BEQ     PHT7
        BRA     PPHT7
        
PHT7    LEA     HEX7,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHT7   CMP.B   #$08,   D0
        BEQ     PHT8
        BRA     PPHT8
        
PHT8    LEA     HEX8,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHT8   CMP.B   #$09,   D0
        BEQ     PHT9
        BRA     PPHT9
        
PHT9    LEA     HEX9,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHT9   CMP.B   #$0A,   D0
        BEQ     PHTA
        BRA     PPHTA
        
PHTA    LEA     HEXA,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHTA   CMP.B   #$0B,   D0
        BEQ     PHTB
        BRA     PPHTB
        
PHTB    LEA     HEXB,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHTB   CMP.B   #$0C,   D0
        BEQ     PHTC
        BRA     PPHTC
        
PHTC    LEA     HEXC,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHTC   CMP.B   #$0D,   D0
        BEQ     PHTD
        BRA     PPHTD
        
PHTD    LEA     HEXD,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHTD   CMP.B   #$0E,   D0
        BEQ     PHTE
        BRA     PPHTE
        
PHTE    LEA     HEXE,   A1 
        BSR     PRINT
        BRA     PHEND 
        
PPHTE   CMP.B   #$0F,   D0
        BEQ     PHTF
        BRA     PHEND
        
PHTF    LEA     HEXF,   A1 
        BSR     PRINT
        BRA     PHEND         

PHEND   MOVE.B (SP)+, D0    *restore stack at the end
        RTS 










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

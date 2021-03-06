; OpCodes
opcode_MOVE	                    DC.B	'MOVE',0
opcode_MOVEM                    DC.B	'MOVEM',0
opcode_BRA                      DC.B    'BRA ',0
opcode_BEQ                      DC.B    'BEQ ',0
opcode_BLE                      DC.B    'BLE ',0
opcode_BGT                      DC.B    'BGT ',0

; I_O_SUBROUTINE.X68
FinishQuestionString            DC.B    'To finish type 1',CR,LF,0

; USERINPUT.X68
InpStartAddrMess                DC.B    'Enter an 8-digit starting address(even and in hex): ',0
InpEndAddrMess                  DC.B    'Enter an 8-digit ending address(even and in hex): ',0
INV_HEX_MESSAGE                 DC.B    'Not a hex digit.',CR,LF,0
InvAddresses                    DC.B    'Starting address has to be less than an ending address. Try again! ',CR,LF,0
OddAddrErr                      DC.B    'Provided addresses have to be even. Try again! ',CR,LF,0

; Bcc.X68

; common
NEWL                            DC.B    '',CR,LF,0
GENERAL_ERROR                   DC.B    'Dissassembler encountered an error',0    *used for general errors
EAERROR_MESSAGE                 DC.B    'Invalid EA.',0 *used for invalid effective addresses
PRESS_ENTER_PROMPT              DC.B    'Press ENTER key to continue', CR,LF,0
QUIT_RESTART_PROMPT             DC.B    'Press q to quit, r to restart', CR,LF,0

;MAIN_LOOP
DATA_STRING                     DC.B    'DATA ',0



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

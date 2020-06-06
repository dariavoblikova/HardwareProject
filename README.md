# HardwareProject. Disassembler

* Scans a section of memory
* Attempts to convertthe memory’s contents to a listing of valid assembly language instructions

I/O
* Prints the address of each instruction
* Handles improper user inputs
* Prints results as one screen at a time 
* Option to re-start and finish


## Supported Opcodes:
NOP  
MOVE, MOVEQ, MOVEM, MOVEA  
ADD, ADDA, ADDQ  
SUB  
LEA  
AND,OR,NOT  
LSL, LSR, ASL, ASR  
ROL,ROR  
Bcc (BGT, BLE, BEQ)  
JSR, RTS  
BRA  

## Supported EAs:
Data Register Direct, Dn  
Address Register Direct, An  
Address Register Indirect, (An)  
Address Register Indirect Post-Increment, (An)+  
Address Register Indirect Pre-Decrement, -(An)  
Absolute Word Address, (xxx).W  
Absolute Long Address, (xxx).L  
Immediate Addressing, #\<data>  



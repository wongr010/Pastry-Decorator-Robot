.equ JTAG_UART, 0xFF201000

.global _start

.section exceptions, "ax"
#================================================================
handler:
    #read character, since we got interrupted, we assume that data is valid
    #et -> to store character
    ldwio et, 0(r7)
    andi et, et, 0xFF
    br write

write: 
    #write character
    stwio et, 0(r7)
    br exit

exit: 
    subi ea, ea, 4
    eret 

#================================================================
_start:

    #r7 -> addr of JTAG_UART
    movia r7, JTAG_UART
    movi r6, 1
    stwio r6, 4(r7)         #enable read interrupts inside JTAG_UART

    #enable interrupt listening 
    movi r10, 1
    wrctl status, r10           #enable ctl0 for listening to interrupts
    movi r10, 0x100
    wrctl ienable, r10          #enable listening to only TIMER1, triggered on timeout

loop: 
    br loop

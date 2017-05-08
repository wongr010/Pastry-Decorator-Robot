.equ TIMER1, 0xFF202000
.equ LEDS, 0xFF200002
.equ PERIOD, 100000000

.global _start


.section exceptions, "ax"
#================================================================
handler:
    movia r12, LEDS              
    ldwio r10, 0(r12)            #loads current value of LED's (1 for on, 0 for off) to r10
    andi r10, r10, 1            #bitmask to only show LED0
    beq r10, r0, turn_on        #if LED0 is off
    br turn_off                 #if LED0 is on 

turn_on:
    movi r10, 1
    stwio r10, 0(r12)            #turn LED0 on by setting r10 to 1 then storing that vlaue in addr(LED0)
    br exit

turn_off:
    stwio r0, 0(r12)             #turn LED0 off by storing r0 to addr(LED0)
    br exit

exit:
    movia ea, _start            #we want to loop back to the start after interrupt has finished
    eret

#================================================================
_start:
    #start TIMER
    movia r7, TIMER1
    movui, r8, %hi(PERIOD)      #stores higher bits of period into r8
    movui, r9, %lo(PERIOD)      #stores lower bits of period into r9
    stwio r9, 8(r7)
    stwio r8, 12(r7)            #stores period into TIMER
    stwio r0. 0(r7)             #clear timeout 

    movui r2, 4
    stwio r2, 4(r7)             #start the TIMER

    #enable interrupts, use TIMER1 
    movi r10, 1
    wrctl status, r10           #enable ctl0 for listening to interrupts
    movi r10, 1
    wrctl ienable, r10          #enable listening to only TIMER1, triggered on timeout

loop: 
    br loop
.equ RED_LEDS, 0xFF200000 	   # (From DESL website > NIOS II > devices)


.data                              # "data" section for input and output lists


IN_LIST:                  	   # List of 10 signed halfwords starting at address IN_LIST
    .hword 1
    .hword -1
    .hword -2
    .hword 2
    .hword 0
    .hword -3
    .hword 100
    .hword 0xff9c
    .hword 0b1111
LAST:			 	    # These 2 bytes are the last halfword in IN_LIST
    .byte  0x01	#LAST	  	    # address LAST
    .byte  0x02		  	    # address LAST+1
    
IN_LINKED_LIST:                     # Used only in Part 3
    A: .word 1
       .word B
    B: .word -1
       .word C
    C: .word -2
       .word E + 8
    D: .word 2
       .word C
    E: .word 0
       .word K
    F: .word -3
       .word G
    G: .word 100
       .word J
    H: .word 0xffffff9c
       .word E
    I: .word 0xff9c
       .word H
    J: .word 0b1111
       .word IN_LINKED_LIST + 0x40
    K: .byte 0x01		    # address K
       .byte 0x02		    # address K+1
       .byte 0x03		    # address K+2
       .byte 0x04		    # address K+3
       .word 0
    
OUT_NEGATIVE:
	.skip 20
OUT_POSITIVE:
	.skip 20

.global _start
_start: 
################################################################
movi  r2, 0
movi r3, 0
movia r7, IN_LIST
movia r4, OUT_POSITIVE
movi r5, 10
movia r6, OUT_NEGATIVE
movi r8, 0 #pos counter
movi r9, 0 #neg counter

LOOP:
subi r5, r5, 1  #counter 
ldh r13, 0(r7) #r13 points to IN_LIST
addi r7, r7, 2
movia  r16, RED_LEDS          # r16 and r17 are temporary values
        #ldwio  r17, 0(r16)
        #addi   r17, r17, 1
        add r17,r8,r9
		stwio  r17, 0(r16)

beq r5, r0, LOOP_FOREVER
blt r13, r0, OUT_NEG
bgt r13, r0, OUT_POS

 
br LOOP

OUT_NEG:
sth r13, 0(r6)
addi r6, r6, 2
addi r8, r8, 1
br LOOP

OUT_POS:
sth r13, 0(r4)
addi r4, r4, 2
addi r9, r9, 1
br LOOP

   # (You'll learn more about I/O in Lab 4.)
        movia  r16, RED_LEDS          # r16 and r17 are temporary values
        ldwio  r17, 0(r16)
        addi   r17, r17, 1
        stwio  r17, 0(r16)
        # Finished output to LEDs.
    # End loop


LOOP_FOREVER:
    br LOOP_FOREVER                   # Loop forever.
    
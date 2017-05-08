.equ PS2, 0xFF200100 #using controller 1
.equ LEGO, 0xff200060

#global variable r7

.global _start
_start:

movi r7, 1
movia r10, PS2

read_loop:
ldwio r2, 0(r10)
andi r1, r2, 0x0000000f

beq r1, r0, read_loop

beq r7, r0, turn_off

turn_on:

movia r8, LEGO #r8 is the base- JP0
movia r9, 0x07f557ff #direction register
stwio r9, 4(r8) #base + 4 - controller
		
movia r9, 0xfffffff0 #turn on motors
stwio r9, 0(r8)

mov r7, r0

br read_loop

turn_off:

movia r8, LEGO #r8 is the base- JP0
movia r9, 0x07f557ff #direction register
stwio r9, 4(r8) #base + 4 - controller
		
movia r9, 0xffffffff #turn on motors
stwio r9, 0(r8)

movi r7, 0x1

br read_loop





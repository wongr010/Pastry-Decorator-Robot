.equ TIMER, 0xFF202000
.equ PERIOD, 100000000
.equ REDLEDS, 0xFF200000

.global _start
_start:

Initialize:
	movi r3, 0b001
	stw r3, 4(r8) #enable read interrupts

	movi r9, 1
	wrctl ctl3, r9

	movi r9, 1
	wrctl ctl0, r9
		
	call timersetup
	movia r7, REDLEDS
	movi r8, 0xF
	stwio r8, 0(r7) #turn on LED

	LOOP:
	br LOOP

timersetup:
 
movia r17,TIMER 			#timer base
 # addi r16, r0, 0x8 					#stop the timer: 1000 = interrupt
 # stwio r16, 4(r17)
 
  addi r16, r0, %lo(PERIOD)
  stwio r16, 8(r17) 						#lower half of period gets stored in base+8
  addi r16, r0, %hi(PERIOD)
stwio r16, 12(r17) 						#base+12 - upper half of period

addi r16, r0, 0b0111 #0x6=0110 to start and cont are 1
stwio r16, 4(r17) #start the timer, store 0110 in 4(15) (timer control- 4+base)

ret

.section .exceptions, "ax"
subi sp, sp, 8
stw ea, 4(sp)
rdctl et, ctl1
stw et, 0(sp)

movia et, TIMER
stwio r0, 0(et) #ack interrupt

movia et, REDLEDS
stwio r0, 0(et) #turn off LEDs

exit:
wrctl ctl1, et
ldw et, 0(sp)
ldw ea, 4(sp)
addi sp, sp, 8

subi ea, ea, 4
eret
	

	
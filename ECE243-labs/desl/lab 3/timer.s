/*Turn Motor ON
  Delay 262150 cycles using the Timer
  Turn Motor OFF
  Delay 262150 cycles using the Timer */
 .equ PERIOD, 100000000
 .equ REDLEDS, 0xFF200000
 #what does it mean by a cycle???
 timersetup:
 
movia r10, REDLEDS

 movia r8, 0xFF202000 #timer base
 addi r9, r0, 0x8 #stop the timer: 1000 = interrupt
 stwio r9, 4(r8)
 
  addi r9, r0, %lo(PERIOD)
  stwio r9, 8(r8) #lower half of period gets stored in base+8
  addi r9, r0, %hi(PERIOD)
stwio r9, 12(r8) #base+12 - upper half of period

addi r9, r0, 0x6 #0x6=0110 to start and cont are 1
stwio r9, 4(r8) #start the timer, store 0110 in 4(15) (timer control- 4+base)

timergo:
stwio r0, 0(r10)
ldwio r9, 0(r8) #load the last bit of base into r16
andi r9, r9, 0x1 #if the last bit of r16 is 1, that means it ran out of time, and r16 becomes 1 (0th 
#bit of base is timeout bit)
beq r9, r0, timergo #if the last bit is 0, keep going
addi r9, r9, 0x0 #clear the timeout bit

###### TESTING WITH LEDS #########
#movia r10, REDLEDS
ldwio r11, 0(r10)
xori r11, r11, 0x01 #flips the LSB
stwio r11, 0(r10) #stores the r11 value with the flipped bit into the LEDs
#ldwio r11, 0(r10)
#xori r11, r11, 0x01 #flips it back
#stwio r11, 0(r10)

stwio r9, 0(r8)
subi r4, r4, 1 #decrement number of cycles, in this case r4 = 252150


bne r4, r0, timergo #if r4 isn't 0, continue

addi r9, r9, 8 #this makes r9 1001- stop the timer
stwio r9, 4(r8) #put the stop combo 1001 into the control bit
ret

INFLOOP:
		br INFLOOP
		
.global _start
_start:
	addi r4, r0, 23 #262150 r4 has the parameter, 23 sec
	call timersetup
	br INFLOOP




  
  
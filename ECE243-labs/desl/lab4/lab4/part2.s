.equ ADDR_JP1, 0xFF200060  # address GPIO JP1
.equ TIMER, 0xFF202000
.equ PERIOD, 262150 

.global _start
_start:


READ_3:
   movia  r8, ADDR_JP1

   movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
   stwio  r10, 4(r8)

 loop:
   movia  r11, 0xfffeffff     # enable sensor 3, disable all motors
   	#and r11, r11, r14

   stwio  r11, 0(r8)
   ldwio  r5,  0(r8)          # checking for valid data sensor 3
   srli   r6,  r5,17          # bit 17 is valid bit for sensor 3           
   andi   r6,  r6,0x1
   bne    r0,  r6,loop        # wait for valid bit to be low: sensor 3 needs to be valid
 good:
   srli   r5, r5, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
   andi   r5, r5, 0x0f

  READ_2:
  loop2:
  
	movia r13, 0xFFFBFFFF #enable sensor 4
	#and r13, r13, r14
	stwio r13, 0(r8)
	ldwio r9, 0(r8)
	srli r12, r9, 19 #19 is valid bit for sensor 4
	andi r12, r12, 0x1
	bne r0, r12, loop2
	good2:
	srli r9, r9, 27
	andi r9, r9, 0x0f
	
	COMPARE:
	addi r13, r0, 0
	sub r13, r9, r5
	movia r14, 2
	movia r15, -2
	bge r13, r14, FORWARD
	ble r13, r15, BACKWARD
	
	FORWARD:
	movia r14, 0xfffffffc
	stwio r14, 0(r8)
addi r4, r0, 0 #clear r4	
	addi r4, r0, 2 
	call timersetup
	movia r14, 0xFFFFFFF
	stwio r14, 0(r8)
	call timersetup
	br READ_3
	
	BACKWARD:
	movia r14, 0xFFFFFFFE
	stwio r14, 0(r8)
	addi r4, r0, 0 #clear r4
	addi r4, r0, 4
	call timersetup
	movia r14, 0xFFFFFFF
	stwio r14, 0(r8)
	call timersetup
	br READ_3
	
	
	/*Turn Motor ON
  Delay 262150 cycles using the Timer
  Turn Motor OFF
  Delay 262150 cycles using the Timer */
 
 #.equ PERIOD, 100000000
 #.equ REDLEDS, 0xFF200000
 
 timersetup:
 
movia r17,TIMER 			#timer base
 # addi r16, r0, 0x8 					#stop the timer: 1000 = interrupt
 # stwio r16, 4(r17)
 
  addi r16, r0, %lo(PERIOD)
  stwio r16, 8(r17) 						#lower half of period gets stored in base+8
  addi r16, r0, %hi(PERIOD)
stwio r16, 12(r17) 						#base+12 - upper half of period

addi r16, r0, 0x4 #0x6=0110 to start and cont are 1
stwio r16, 4(r17) #start the timer, store 0110 in 4(15) (timer control- 4+base)

timergo:
#
ldwio r16, 0(r17) #load the last bit of base into r16
andi r16, r16, 0x1 #if the last bit of r16 is 1, that means it ran out of time, and r16 becomes 1 (0th 
#bit of base is timeout bit)
beq r16, r0, timergo #if the last bit is 0, keep going
#addi r9, r9, 0x0 #clear the timeout bit
stwio r0, 0(r17)


###### TESTING WITH LEDS #########

#movia r10, REDLEDS
/*
ldwio r11, 0(r10)
xori r11, r11, 0x01 			#flips the LSB
stwio r11, 0(r10) 				#stores the r11 value with the flipped bit into the LEDs
*/
#ldwio r11, 0(r10)
#xori r11, r11, 0x01 #flips it back
#stwio r11, 0(r10)

#stwio r16, 0(r17)
# subi r4, r4, 1 #decrement number of cycles, in this case r4 = 252150


# bne r4, r0, timergo #if r4 isn't 0, continue

# addi r16, r16, 8 #this makes r9 1001- stop the timer
#stwio r16, 4(r17) #put the stop combo 1001 into the control bit

ret

/*
		
.global _start
_start:
	addi r4, r0, 23 #262150 r4 has the parameter, 23 sec
	call timersetup
	br INFLOOP

	*/
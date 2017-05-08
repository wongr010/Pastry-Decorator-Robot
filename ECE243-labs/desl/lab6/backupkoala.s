.equ PS_Data, 0xFF200100
.equ PS_CONTROL, 0xFF200104
.equ LEDS, 0xFF200000

.equ LEGO, 0xff200060
.equ C, 0x21
.equ S, 0x1B

.equ TIMER, 0xFF202000
.equ PERIODGO, 10 #will need to change this to adjust to assembly line
.equ PERIODSTOP, 20

#reserve global variable for which motor - r15
.global _start
.section .exceptions, "ax"

myISR: 

	movia r13, PS_Data
	movia r14, LEDS
	
	ldwio r17, 0(r13)
	ldwio r21, 0(r14)
	
	andi r17, r17, 0xff
	movia r18, C
	movia r19, S
	
	beq r17, r18, MOTOR1
	beq r17, r19, MOTOR2
	
	br RETURN
	
	MOTOR1: #C
	xori r21, r21, 0x02
	stwio r21, 0(r14) #turn on LED
	
	movi r15, 1 #turn on motor 1
	
	br RETURN
	
	MOTOR2: #S
	xori r21, r21, 0x01
	stwio r21, 0(r14)
	
	movi r15, 0
	br RETURN
	
	RETURN:
	addi ea, ea, -4
	eret
	
	_start:
	
	movia r8, PS_CONTROL
	movui r9, 0x1
	stwio r9, 0(r8)
	
	movui r9, 0x80
	wrctl ctl3, r9
	movui r9, 0x1
	wrctl ctl0, r9
	
	movi r15, 1 #default setting is C
	
	LOOP:
	
	#set up motor 0 (assembly line)
	FORWARD:
	movia r7, LEGO
	ldwio r6, 0(r7) #get the present state
	
	andi r6, r6, 0xfffc #all the motors stay in the same state except motor 0, which is turned on (bits 0 and 1 are 0)
	
	stwio r6, 0(r7) 
	mov r14, r9 #save the direction in r14

	

	call timersetup1 #start the timer

	movia r7, LEGO
	ldwio r6, 0(r7)
	ori r6, r6, 0x0003 #all the motors stay in same state except motor 0, which is turned off (bits 0 and 1 are 1)
	stwio r6, 0(r7) 
	mov r14, r9 #save the direction in r14

	call timersetup2
	
	beq r15, r0, SMOTOR
	
	CMOTOR:
	movia r7, LEGO
	movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
   stwio  r10, 4(r7)
   ldwio r9, 0(r7)
   ori r9, r9, 0x000c #0b01100 sets bit 2 and 3 to 1 so motor 1 will be off
   stwio r9, 0(r7)
   ldwio r9, 0(r7)
   andi r9, r9, 0xffcf #make sure bit 4, 5 are 0 so motor 2 will be on
  
		stwio r9, 0(r7)
		
		br LOOP
		
	SMOTOR:
	movia r7, LEGO
	movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
   stwio  r10, 4(r7)
   ldwio r9, 0(r7)
   ori r9, r9, 0x0030 #turn off motor 2 by setting bit 4, 5, to 1
   stwio r9, 0(r7)
   ldwio r9, 0(r7)
   andi r9, r9, 0xfff3 #make sure bit 2, 3 are 0 so motor 1 will be on, 
		stwio r9, 0(r7)
		
		br LOOP
		
		


timersetup1:
 
movia r17,TIMER 			#timer base
 # addi r16, r0, 0x8 					#stop the timer: 1000 = interrupt
 # stwio r16, 4(r17)
 movi r16, 0
  addi r16, r0, %lo(PERIODGO)
  stwio r16, 8(r17) 						#lower half of period gets stored in base+8
  addi r16, r0, %hi(PERIODGO)
stwio r16, 12(r17) 						#base+12 - upper half of period

addi r16, r0, 0x4 #0x4=0100 to start and cont are 1
stwio r16, 4(r17) #start the timer, store 0110 in 4(15) (timer control- 4+base)

timergo1:

ldwio r16, 0(r17) #load the last bit of base into r16
andi r16, r16, 0x1 #if the last bit of r16 is 1, that means it ran out of time, and r16 becomes 1 (0th 
#bit of base is timeout bit)
beq r16, r0, timergo1 #if the last bit is 0, keep going
#addi r9, r9, 0x0 #clear the timeout bit
stwio r0, 0(r17)

ret


timersetup2:
 
movia r17,TIMER 			#timer base
 # addi r16, r0, 0x8 					#stop the timer: 1000 = interrupt
 # stwio r16, 4(r17)
  movi r16, 0
  addi r16, r0, %lo(PERIODSTOP)
  stwio r16, 8(r17) 						#lower half of period gets stored in base+8
  addi r16, r0, %hi(PERIODSTOP)
stwio r16, 12(r17) 						#base+12 - upper half of period

addi r16, r0, 0x4 #0x4=0100 to start and cont are 1
stwio r16, 4(r17) #start the timer, store 0110 in 4(15) (timer control- 4+base)

timergo2:
#
ldwio r16, 0(r17) #load the last bit of base into r16
andi r16, r16, 0x1 #if the last bit of r16 is 1, that means it ran out of time, and r16 becomes 1 (0th 
#bit of base is timeout bit)
beq r16, r0, timergo2 #if the last bit is 0, keep going
#addi r9, r9, 0x0 #clear the timeout bit
stwio r0, 0(r17)

ret

	
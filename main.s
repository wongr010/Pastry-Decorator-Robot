.equ PS_Data, 0xFF200100
.equ PS_CONTROL, 0xFF200104
.equ LEDS, 0xFF200000

.equ LEGO, 0xff200060
.equ C, 0x21
.equ S, 0x1B
.equ G, 0x34
.equ E, 0x24


.equ TIMER, 0xFF202000

.equ PERIODGO,  90000  #will need to change this to adjust to assembly line

#reserve global variable for which motor - r15
#reserve global variable for assembly line slow(0)/fast(1) pace - r3
#counting variable- r2
#start variable - r22
#forward/reverse topping counter - r4
#forward 1 /reverse 0 topping indicator - r5
#door movement - r8



.global _start
.section .exceptions, "ax"

myISR:
	subi sp, sp, 16
	stw r10,0(sp)
	stw et,4(sp) #we also save et and ctl1 just in case this interrupt interrupted another ISR
	rdctl et,ctl1
	stw et,8(sp)
	stw ea,12(sp)
 
	rdctl et, ctl4 #read bit 0?
	andi et, et, 0x1 #check if timer
	beq et, r0, MOTO
		
	movia r17,TIMER 
	stwio r0, 0(r17) #ack the interrupt
	
	movi et, 1
	beq r3, et, SETR3TO0
	br NEXT
	
	SETR3TO0:
	mov r3, r0 #if the conveyer was previously in fast mode, revert to slow
	
	NEXT: 
	movi et, 10 #has the conveyer been slow for 4 cycles?
	beq r2, et, SETR3
	
	br CONTINUE
	#every time the line goes into slow mode, r2 is incremented by 1. In slow mode, r3=0. Once r2=3, r2 is set back to 0 and r3 is set to 1. The line goes into fast mode. 
	
SETR3:
	mov r2, r0 #set count to 0
	movi r3, 1 #set r3 to 1 -  fast speed
	
CONTINUE:
	beq r3, r0, SLOW
	
FAST:
	movi r3, 1 #set to fast

br DIRECTION_CHECK
	SLOW:
	addi r2, r2, 1 #increment r2 by 1
	movi r3, 0 #set to slow
	
br DIRECTION_CHECK



DIRECTION_CHECK:

	beq r8, r0, RETURN #if not opening, finish

	movi et, 1000 #has the gear been in same direction for 64 cycles?
	beq r4, et, SETR4
	
	br CONTINUE5
	#every time the line goes into slow mode, r2 is incremented by 1. In slow mode, r3=0. Once r2=3, r2 is set back to 0 and r3 is set to 1. The line goes into fast mode. 
	
SETR4:
	movi r8, 0 #reset the door opener to 0
	mov r4, r0 #set count to 0
	beq r5, r0, SETR5TO1
	
SETR5TO0: #switching directions
	movi r5, 0
	br CONTINUE5
	
SETR5TO1:
	movi r5, 1
	br CONTINUE5
	
	
CONTINUE5:
	
	addi r4, r4, 1

	
br RETURN
	



	
MOTO:
	movia r13, PS_Data
	movia r14, LEDS
	
	ldwio r17, 0(r13)
	ldwio r21, 0(r14)
	
	andi r17, r17, 0xff
	movia r18, C
	movia r19, S
	movia et, G
	beq r17, et, START
	movia et, E
	beq r17, et, STOP
	
	beq r17, r18, MOTOR1
	beq r17, r19, MOTOR2
	
	br RETURN
	
	START:
	movi r22, 1
	br RETURN
	
	STOP:
	movi r23, 1
	br RETURN
	
	MOTOR1: #C
	call sugar
	xori r21, r21, 0x02
	stwio r21, 0(r14) #turn on LED
	movi r8, 1 #motor C forwards, motor S backwards
	movi r15, 1 #turn on motor 1
	
	br RETURN
	
	MOTOR2: #S
	call sprinkle
	xori r21, r21, 0x01
	stwio r21, 0(r14)
	movi r8, 1 #motor S forwards, motor C backwards
	movi r15, 0
	br RETURN
	
	RETURN:
	
			wrctl ctl0, r0 #turn off PIE bit
			# now restore the registers we saved
			ldw r10,0(sp)
			ldw et,8(sp)
			wrctl ctl1, et
			ldw et,4(sp)
			ldw ea,12(sp) #and we save the return address, that will change if this ISR is interrupted
			addi sp,sp,16 #stack back to where it was
			subi ea,ea,4 #adjust return address
			eret #go back to interrupted routine
	
_start:
	
	movia r10, PS_CONTROL
	movui r9, 0x1
	stwio r9, 0(r10) #enable PS2 interrupts
	
	movia sp, 0x03fffffc
	
	movi r9, 0x81 #0000 0000 1000 0001 enable bit 0 and 7
	wrctl ctl3, r9
	movi r9, 0x1
	wrctl ctl0, r9
	
	movi r22, 0
	#call please
	
	start_loop:
	call please
	SLOOP:
	movia r7, LEGO
	movi r6, 0x00ff
	stwio r6, 0(r7) #turn off all motors
	movi r20, 1
	beq r22, r20, start
	br SLOOP
	
	start:
	movi r22, 0 #reset start_loop variable to 0
	movi r23, 0 #make sure pause is 0
	movi r15, 1 #default setting is C
	movi r3, 0 #initial assembly line setting is fast
	movi r2, 0 #set to 0
	movi r4, 0
	movi r5, 1 #default setting is forward
	movi r8, 1 #open the C container
	call sugar
	
	call timersetup1 #start the timer
	
LOOP:
	movi r22, 0 #make sure start is 0
	
	movi r20, 1
	beq r23, r20, start_loop #if 'E' is pressed, pause
	#set up motor 0 (assembly line)
GO:
	movia r7, LEGO
	movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
	stwio  r10, 4(r7)
	ldwio r6, 0(r7) #get the present state
	
	
	beq r3, r0, SLOW_SPEED
	
FAST_SPEED: #does not exit the fast_speed
	
	andi r6, r6, 0xfffc #all the motors stay in the same state except motor 0, which is turned on (bits 0 and 1 are 0)
	stwio r6, 0(r7) 
	mov r14, r9 #save the direction in r14
	
	beq r8, r0, LOOP #if not opening or closing mode, don't move the motors
	
	beq r15, r0, OPEN_S
	
OPEN_C:

	#movi r7, 1
	#beq r15, r7, LOOP #S is already open, do not turn the motor
	movia r7, LEGO
	movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
	stwio  r10, 4(r7)
	
	ldwio r9, 0(r7)
	
	TOWARDSC:
	andi r9, r9, 0xffcf #make sure bit 4, 5 are 0 so motor 2 will be on
	stwio r9, 0(r7)
	
	CLOSE_S:
	andi r9, r9, 0xFFFB #make sure bit 2, 3 are 0 so motor 1 will be on, 
	stwio r9, 0(r7)
	br LOOP
	
OPEN_S:
	#beq r15, r0, LOOP
	movia r7, LEGO
	movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
	stwio  r10, 4(r7)
	
	
	ldwio r9, 0(r7)
	
	TOWARDSS:
	andi r9, r9, 0xfff3 #make sure bit 2, 3 are 0 so motor 1 will be on,forward
	stwio r9, 0(r7)
	
	CLOSE_C:
	andi r9, r9, 0xffef #make sure bit 5 are 0 so motor 2 will be on
	stwio r9, 0(r7)
		
	br LOOP
	
	
SLOW_SPEED:
	
	movi r6, 0x00ff
	#ori r6, r6, 0x0003 #all the motors stay in same state except motor 0, which is turned off (bits 0 and 1 are 1)
	stwio r6, 0(r7) #stop all the motors 
	mov r14, r9 #save the direction in r14
	br LOOP

	

		
		
timersetup1:
movia r17, TIMER
    movui r16, %hi(PERIODGO)      #stores higher bits of period into r8 10
    movui r18, %lo(PERIODGO)      #stores lower bits of period into r9 11
    stwio r18, 8(r17)
    stwio r16, 12(r17)            #stores period into TIMER 11 10
    stwio r0, 0(r17)             #clear timeout 

    

    #enable interrupts, use TIMER1 
    movui r16, 0b0111 #0x6=0110 to start and cont are 1
	stwio r16, 4(r17) #start the timer, store 0110 in 4(15) (timer control- 4+base)

ret
		


	
	
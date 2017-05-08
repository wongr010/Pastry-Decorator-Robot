
.equ JTAG, 0x10001020
.equ JTAG2, 0xff201000
.equ TIMER, 0xFF202000
.equ PERIOD, 100000000 

#.section .text #<- do we need this?

.global _start
_start:
	movia r8, JTAG
	movia r15, JTAG2
	movia sp, 0x03fffffc

	#designate r20 as sensors
	#designate r21 as speed
	#r25 decides between speed and sensors
	
	Initialize:
		addi r1, r0, 0x1 #1=sensors, 0=speed
	
		movi r9, 0b0100000001
		wrctl ctl3, r9

		movi r9, 1
		wrctl ctl0, r9 #enable interrupts
		
		call timersetup
		call jtag2setup

	LOOP:
		call READ_SENSORS
		
		movi r14, 0x001F
		beq r9, r14, Straight
		
		movi r14, 0x001E
		beq r9, r14, Right
		
		movi r14, 0x001C
		beq r9, r14, HardRight
		
		movi r14, 0x000F
		beq r9, r14, Left
		
		movi r14, 0x0007
		beq r9, r14, HardLeft
		
		Straight:
			movi r6, 0
			call Steer
			
			movi r15, 48
			bge r10, r15, MaxStraightSpeed
			
			movi r5, 127
			call Accelerate
			br LOOP
			
			MaxStraightSpeed:
			movi r5, -127
			call Accelerate
			
			br LOOP
		
		Right:
			movi r6, 96
			call Steer
			
			movi r15, 36
			bgt r10, r15, MaxRightSpeed
			
			movi r5, 127
			call Accelerate
			br LOOP
			
			MaxRightSpeed:
			
			movi r5, -36
			call Accelerate
			br LOOP
			
		HardRight:
			movi r6, 127
			call Steer
			
			movi r15, 24
			bgt r10, r15, MaxHRightSpeed
			
			movi r5, 48
			call Accelerate
			br LOOP
			
			MaxHRightSpeed:
			
			movi r5, -96
			call Accelerate
			br LOOP
		
		Left:
			movi r6, -96
			call Steer
			
			movi r15, 36
			bgt r10, r15, MaxLeftSpeed
			
			movi r5, 127
			call Accelerate
			br LOOP
			
			MaxLeftSpeed:
			
			movi r5, -36
			call Accelerate
			br LOOP
			
		HardLeft:
			movi r6, -127
			call Steer
			
			movi r15, 24
			bgt r10, r15, MaxHLeftSpeed
			
			movi r5, 48
			call Accelerate
			br LOOP
			
			MaxHLeftSpeed:
			
			movi r5, -96
			call Accelerate
			br LOOP

# Puts sensor states into r9, speed into r10
READ_SENSORS:
	addi sp, sp, -4
	stw ra, 0(sp)
	
	movi r4, 0x02
	call WriteByte
	
	Check_Pack_0:
		call ReadByte
		bne r2, r0, Check_Pack_0
	
	call ReadByte
	mov r9, r2
	mov r20, r2
	call ReadByte
	mov r10, r2
	mov r21, r2
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	
# Call with acceleration value in r5
Accelerate:
	addi sp, sp, -4
	stw ra, 0(sp)
	
	movi r4, 0x04
	call WriteByte
	mov r4, r5
	call WriteByte
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	
# Call with steering value in r6
Steer:
	addi sp, sp, -4
	stw ra, 0(sp)
	
	movi r4, 0x05
	call WriteByte
	mov r4, r6
	call WriteByte
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	
# Returns read byte in r2
ReadByte:
	addi sp, sp, -4
	stw ra, 0(sp)
	
	ReadLoop:
		ldwio r7, 0(r8)
		andi r3, r7, 0x8000
		beq r3, r0, ReadLoop
	
	andi r2, r7, 0x00FF
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

WriteByte:
	addi sp, sp, -4
	stw ra, 0(sp)
	
	WriteLoop:
		ldwio r3, 4(r8)
		srli r3, r3, 16
		beq r3, r0, WriteLoop
	
	stwio r4, 0(r8)
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

	timersetup:
 
		#timer base
  movia r7, TIMER
    movui r10, %hi(PERIOD)      #stores higher bits of period into r8 10
    movui r11, %lo(PERIOD)      #stores lower bits of period into r9 11
    stwio r11, 8(r7)
    stwio r10, 12(r7)            #stores period into TIMER 11 10
    stwio r0, 0(r7)             #clear timeout 

    

    #enable interrupts, use TIMER1 
    movui r16, 0b0111 #0x6=0110 to start and cont are 1
	stwio r16, 4(r7) #start the timer, store 0110 in 4(15) (timer control- 4+base)

ret

	jtag2setup:
	
	movia r17, JTAG2
	movi r16, 0b001
	stwio r16, 4(r17)
	
	ret
	

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
	beq et, r0, jtaginterrupt
	
	movia et, TIMER
	movia r11, JTAG2
	
	stwio r0, 0(et) #acknowledge interrupt
	
	
	
	
	#need to change speed to ASCII
	
	#clear the terminal
	movi r7, 0x1b #<ESC>
	stwio r7, 0(r11) 
	
	movi r7, 0x5b #[
	stwio r7, 0(r11) 
	
	movi r7, 0x32 #2
	stwio r7, 0(r11) 
	
	movi r7, 0x4b #J
	stwio r7, 0(r11)
	beq r1, r0, SPEED
	
	SENSOR:
	andi r22, r20, 0x0F #bottom 4 bytes
	andi r23, r20, 0xF0 #top 4
	srli r23, r23, 4
	
	
	
	movi r12, 9
	bgt r12, r23, LESSTHANTEN1
	addi r23, r23, 0x41 #convert to a letter
	subi r23, r23, 0x0A
	
	br SEND1
	
	LESSTHANTEN1:
	addi r23, r23, 0x30

	SEND1:
	
	stwio r23, 0(r11)
	
	#need to convert the speed to ASCII
	movi r12, 9
	bgt r12, r22, LESSTHANTEN0
	addi r22, r22, 0x41 #convert to a letter
	subi r22, r22, 0x0A
	
	
	br SEND0
	
	LESSTHANTEN0:
	addi r22, r22, 0x30
	
	SEND0:
	stwio r22, 0(r11) #send the first speed char to the jtag
	
	br EXIT
	
	SPEED:
	andi r22, r21, 0x0F #bottom 4 bytes
	andi r23, r21, 0xF0 #top 4
	srli r23, r23, 4
	
	movi r12, 9
	bgt r12, r23, LESSTHANTEN2
	addi r23, r23, 0x41 #convert to a letter
	subi r23, r23, 0x0A
	
	br SEND2
	
	LESSTHANTEN2:
	addi r23, r23, 0x30
	
	SEND2:
	
	stwio r23, 0(r11)
	#need to convert the speed to ASCII
	movi r12, 9
	bgt r12, r22, LESSTHANTEN
	addi r22, r22, 0x41 #convert to a letter
	subi r22, r22, 0x0A
	
	
	br SEND
	
	LESSTHANTEN:
	addi r22, r22, 0x30
	
	SEND:
	stwio r22, 0(r11) #send the first speed char to the jtag
	
	
	
	movi et, 1
	wrctl ctl0, et #enable interrupts again
	
	br EXIT
	
	jtaginterrupt:
	
		movia r7, JTAG2
		
		ldwio r2, 0(r7)
		andi r3, r2, 0x8000 #is data valid?
		beq r3, r0, EXIT
		andi r2, r2, 0b01111111
		movi r4, 0x72 #is the data r
		beq r2, r4, write_sensors
		movi r4, 0x73 #is the data s
		beq r2, r4, write_speed
		br EXIT #data is neither r or s
		
		write_sensors:
			
			addi r1, r0, 0x1
			
			br EXIT
			
		write_speed:
		
			addi r1, r0, 0
			
			br EXIT
			
			EXIT:
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
	
	

.equ JTAG, 0x10001020
.equ JTAG2, 0xff201000
.equ TIMER, 0xFF202000
.equ PERIOD, 262150 

.global _start
_start:
	movia r8, JTAG
	movia sp, 0x03fffffc
	
	Initialize:
		movi r3, 0b001
		stw r3, 4(r8) #enable read interrupts

		movi r9, 0b0100000001
		wrctl ctl3, r9

		movi r9, 1
		wrctl ctl0, r9
		
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
	call ReadByte
	mov r10, r2
	
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

	jtag2setup:
	
	movia r17, JTAG2
	movi r16, 0b011
	stwio r16, 4(r17)
	
	ret
	
	.section .exceptions, "ax"
	subi sp, sp, 16
	stw r10,0(sp)
	stw et,4(sp) #we also save et and ctl1 just in case this interrupt interrupted another ISR
	rdctl et,ctl1
	stw et,8(sp)
	stw ea,12(sp)
	
	rdctl et, ctl4 #read bit 0?
	andi et, et, 0x1 #check if
	beq et, r0, jtaginterrupt
	
	movia et, TIMER
	movia r11, JTAG2
	movia r8, JTAG
	stwio r0, 0(et) #acknowledge interrupt
	
	call READ_SENSORS #sensor states in r9, speed in r10
	andi r10, r10, 0x0FF
	#need to change speed to ASCII
	
	#clear the terminal
	movi r7, 0x1b #<ESC>
	stwio r7, 0(r11) 
	
	movi r7, 0x5b #[
	stwio r7, 0(r11) 
	
	movi r7, 0x32 #2
	stwio r7, 0(r11) 
	
	movi r7, 0x4A #J
	stwio r7, 0(r11)
	
	#need to convert the speed to ASCII
	stwio r10, 0(r11) #send the speed to the jtag
	
	movi et, 1
	wrctl ctl0, et #enable interrupts again
	
	br EXIT
	
	jtaginterrupt:
	
		movia r7, JTAG2
		movia r8, JTAG
		ldwio r2, 0(r7)
		andi r3, r2, 0x8000 #is data valid?
		beq r3, r0, EXIT
		andi r2, r2, 0b01111111
		movi r4, 0b1110010 #is the data r
		beq r2, r4, write_sensors
		movi r4, 0b1110011 #is the data s
		beq r2, r4, write_speed
		br EXIT #data is neither r or s
		
		write_sensors:
			call READ_SENSORS
			#r9 has sensor data
			andi r9, r9, 0x0FF
			movi r6, 0x1b #<ESC>
			stwio r6, 0(r7) 
	
			movi r6, 0x5b #[
			stwio r6, 0(r7) 
			
			movi r6, 0x32 #2
			stwio r6, 0(r7) 
			
			movi r6, 0x4A #J
			stwio r6, 0(r7)
			
			stwio r9, 0(r7)
			
			br EXIT
			
		write_speed:
		call READ_SENSORS
			#r10 has speed data
			andi r10, r9, 0x0FF
			movi r10, 0x1b #<ESC>
			stwio r6, 0(r7) 
	
			movi r6, 0x5b #[
			stwio r6, 0(r7) 
			
			movi r6, 0x32 #2
			stwio r6, 0(r7) 
			
			movi r6, 0x4A #J
			stwio r6, 0(r7)
			#need to convert to hex
			stwio r10, 0(r7)
			
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
	
	
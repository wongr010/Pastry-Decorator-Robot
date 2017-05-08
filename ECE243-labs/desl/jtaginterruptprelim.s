.equ JTAG, 0x10001020
.equ JTAG2, 0xff201000
.equ TIMER, 0xFF202000
.equ PERIOD, 100000000 
.equ LEGO, 0xff200060

#reserve r20 for global variable: sprinkles (0) vs. cinnamon (1)
#reserve r21 for global variable: motors on (1) or off (0)
#cinnamon is motor 1, sprinkles is motor 2
#reserve r8 for lego
#reserve r7 for timer
#reserve r17 for jtag
.global _start
_start:
movia r8, JTAG
	movia r15, JTAG2
	movia sp, 0x03fffffc
Initialize:
		#addi r1, r0, 0x1 #1=sensors, 0=speed
	
		movi r9, 0b0100000001
		wrctl ctl3, r9

		movi r9, 1
		wrctl ctl0, r9
		
		#set up lego device
		movia r8, LEGO #r8 is the base- JP0
		movia r9, 0x07f557ff #direction register
		stwio r9, 4(r8) #base + 4 - controller
		
		call timersetup
		call jtag2setup
		
		
		
		#start off with sprinkles
		movi r20, 0
		movi r21, 1 #start with motors on
		
		movia r9, 0xfffffff0 #turn on motor 0 and 1
		stwio r9, 0(r8)
		
Run:
		beq r21, r0, off
		beq r20, r0, sprinkles
		
cinnamon:
		
		
		
		movia r9, 0xfffffff0 #turn on motor 0 and 1
		stwio r9, 0(r8)
		 br Run
		 
		
		 
sprinkles:

		
		
		
		movia r9, 0xFFFFFFCC #turn on motor 0 and 2
		stwio r9, 0(r8)
		br Run
		
off:

		movia r9, 0xffffffff #turn off motors if r21 is 0
		stwio r9, 0(r8)
		br Run
		
		
		
		
timersetup:
 
		#timer base
  movia r7, TIMER
    movui r10, %hi(PERIOD)      #stores higher bits of period into r8 10
    movui r11, %lo(PERIOD)      #stores lower bits of period into r9 11
    stwio r11, 8(r7)
    stwio r10, 12(r7)            #stores period into TIMER 11 10
    stwio r0, 0(r7)             #clear timeout 

    

    #enable interrupts, use TIMER1 
    movui r16, 0b0111 
	stwio r16, 4(r7) #start the timer, store 0110 in 4(15) (timer control- 4+base)

ret

	jtag2setup:
	
	movia r17, JTAG2 #enable keyboard interrupts
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
	
	timerinterrupt:
	
	movia et, TIMER
	movia r11, JTAG2
	
	stwio r0, 0(et) #acknowledge interrupt
	
	beq r21, r0, set_to_1
	
	set_to_0:
	
	movi r21, 0
	movi et, 1
	wrctl ctl0, et #enable interrupts again
	br done
	
	set_to_1:
	
	movi r21, 1
	movi et, 1
	wrctl ctl0, et #enable interrupts again
	br done
	
	
	
	movia et, TIMER
	movia r11, JTAG2
	
	jtaginterrupt:
	
		movia r7, JTAG2
		
		ldwio r2, 0(r7)
		andi r3, r2, 0x8000 #is data valid?
		beq r3, r0, done
		andi r2, r2, 0b01111111 #get the valid letter data
		movi r4, 0x63 #is the data c
		beq r2, r4, cinnamoninterrupt
		movi r4, 0x73 #is the data s
		beq r2, r4, sprinklesinterrupt
		br done #data is neither r or c
		
	cinnamoninterrupt:
		movi r20, 1
		br done
		
	sprinklesinterrupt:
		movi r20, 0
		br done
		
	done:
	
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
	
		
	
	
	
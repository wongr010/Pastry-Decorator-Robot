# Include nios_macros.s to workaround a bug in the movia pseudo-instruction. 
#.include "nios_macros.s" 

 
.equ RED_LEDS, 0x10000000 	   # Use with 18 bits 
.equ GREEN_LEDS, 0x10000010    # Used with 9 bits  
.equ ADDR_JP1, 0xff200060 
.equ ADDR_JP2, 0x10000070 
.equ ADDR_JP2_IRQ, 0x1000 
.equ LEGO_INITIALIZE, 0x07f557ff  # Set direction of all motors to outputs  
.equ ENABLE_STATE_MODE, 0xffdfffff 
.equ MOTOR0_EN_FWD, 0xfffffffc 
.equ SENSOR1_EN_MOTOR0_FWD, 0xffffeffe 
.equ SENSOR1_EN_MOTOR0_BCK, 0xffffeffc 
.equ TIMER_ADDR ,0x10002000 
# Best values are 50k and 50k or 50k (on) and 75k(off)  
 .equ PERIOD_ON,     0xc350   #   0xc350  #50000 
 .equ PERIOD_OFF,  0xc350      #0x124F8     #0x30D40 #200000 

.equ TIMER_LOOP,   1  # 10 
   movui r2, 4 
   stwio r2, 4(r7)                          /* Start the timer without continuing or interrupts */ 

 
 #---------------- 
 # Lego Commands 
 #---------------- 
# The below is to allow quick copy pasting and editing of values for project 
# 0xf (ab)  effff   # Load threshold data to sensor 3 as 5  (ab) => 1(010 1)011 
 
 # 0xfffeffff      # Enable sensor 3 and disable everything else  
 # Depending on surface, threshold value would change 
 # Threshold value is the value of the sensors when the car is at the balanced position  # Threshold value for left sensor (Sensor 0): 
  
 # Threshold value for right sensor (Sensor 1):  
#35 # Pseudocode: 
#36 # 1. Load sensor threshold to both Sensor 0 and Sensor 1 
#37 # 2. Initialize motor to rotate left 
#38 # 3. Poll for left Sensor0, once it crosses threshold and is valid 
#39 # 4. Motor rotate right 
#40 # 5. Poll for right Sensor1, once it crosses threshold and is valid 
#41 # 6. Motor rotate left 
#42 # 7. Repeat step 3-6 forever.  
#43 # Note: Only allowed to use polling  (value) mode for this mode  
#44 #------------- 
#45 # Registers 
#46 #------------- 
#47 
 
#48 # Caller  
#49 # 
#50 # 
#51 # 
#52 
 
#53 #Callee 
 
 
#55 # r2 = Parameter to send in, Period ON 
#56 # r3 = Parameter to send in, Period OFF  
#57 # r4 = Parameter to send in, N  
#58 
 
#59 # r8 = Address of JP1 (Lego Controller) 
#60 # r9 = To initialize Lego Controller and use for storing values  
#61 # r10 = Address of RED Leds (Displays sensor 1 value)  
#62 # r11 = Address of GREEN Leds (Displays Sensor 2 value) 
#63 # r12 = Holds latest value of Sensor1 
#64 # r13 = Holds latest value of Sensor 2  
#65 # r14 = Keeps track of direction of movement of motor  (Forward = 0, backward = 1) at bit 1 (note: Bits start from 0) 
#66 # r15 = To keep track of converted r14's value  
#67 # r16 = Stores temporary value for computation of and  
.section .text
.global _start
.equ	JP1, 0xff200060
.equ	TIMER, 0xff202000

_start:
	movia	r9, JP1
	# set direction registers
	movia	r8, 0x07F557FF
	stwio	r8, 4(r9)		

	# disable all sensors and motors
	ldwio	r8, 0(r9)
	orhi	r8, r8, 0x0005
	ori		r8, r8, 0x57FF
	stwio	r8, 0(r9)
	
	# set up timer
	# stop the timer, set continue bits
	movia	r9, TIMER
	movia	r8, 0b1010
	stwio	r8, 4(r9)
	
	# set the period
	addi	r8, r0, %lo(3000)
	stwio	r8, 8(r9)
	addi	r8, r0, %hi(3000)
	stwio	r8, 8(r9)
	
	# start the timer
	movia	r8, 0b0110
	stwio	r8, 4(r9)
	

	
	
check_sensors:	
	# drop the timer flag
	ldwio	r8, 0(r9)
	andhi	r8, r8, 0xFFFF
	andi	r8, r8, 0xFFFE
	stwio	r8, 0(r9)
	
	movia	r9, JP1
	
enable_sensor0:
	ldwio	r8, 0(r9)
	andhi	r8, r8, 0xFFFF
	andi	r8, r8, 0xFBFF
	stwio	r8, 0(r9)
	
poll_sensor0:
	ldwio	r8, 0(r9)
	srli	r8, r8, 11
	andhi	r8, r8, 0x0
	andi	r8, r8, 0x1
	bne		r8, r0, poll_sensor0

read_sensor0:
	ldwio	r8, 0(r9)
	srli	r8, r8, 27
	andhi	r15, r8, 0x0
	andi	r15, r8, 0xF	# r15 stores the value for sensor 0
	
disable_sensor_0:
	ldwio	r8, 0(r9)
	orhi	r8, r8, 0x0000
	ori		r8, r8, 0x0400
	stwio	r8, 0(r9)
	
enable_sensor1:
	ldwio	r8, 0(r9)
	andhi	r8, r8, 0xFFFF
	andi	r8, r8, 0xEFFF
	stwio	r8, 0(r9)
	
poll_sensor1:
	ldwio	r8, 0(r9)
	srli	r8, r8, 13
	andhi	r8, r8, 0x0
	andi	r8, r8, 0x1
	bne		r8, r0, poll_sensor1

read_sensor1:
	ldwio	r8, 0(r9)
	srli	r8, r8, 27
	andhi	r14, r8, 0x0
	andi	r14, r8, 0xF	# r14 stores the value for sensor 1
	
disable_sensor_1:
	ldwio	r8, 0(r9)
	orhi	r8, r8, 0x0000
	ori		r8, r8, 0x1000
	stwio	r8, 0(r9)
	
compare_sensor_values:
	addi	r15, r15, 0		# probably need to do some trimming here
	bgt		r15, r14, to_left			
	blt		r15, r14, to_right
	br		stop_motor

to_left:
	ldwio	r8, 0(r9)
	andhi	r8, r8, 0xFFFF
	andi	r8, r8, 0xFFFC
	stwio	r8, 0(r9)
	br		wait_before_stop

to_right:
	ldwio	r8, 0(r9)
	andhi	r8, r8, 0xFFFF
	andi	r8, r8, 0xFFFE
	stwio	r8, 0(r9)
	
wait_before_stop:
	movia	r9, TIMER
	
	ldwio	r8,	0(r9)
	andhi	r8, r8, 0x0
	andi	r8, r8, 0x1
	beq		r8, r0, wait_before_stop
	
	# drop flag
	ldwio	r8, 0(r9)
	andhi	r8, r8, 0xFFFF
	andi	r8, r8, 0xFFFE
	stwio	r8, 0(r9)
	
	movia	r9, JP1
	
stop_motor:
	ldwio	r8, 0(r9)
	orhi	r8, r8, 0x0000
	ori		r8, r8, 0x0003
	stwio	r8, 0(r9)
	br		wait_after_stop
	
wait_after_stop:
	movia	r9, TIMER
	
	ldwio	r8,	0(r9)
	andhi	r8, r8, 0x0
	andi	r8, r8, 0x1
	beq		r8, r0, wait_after_stop
	
	br		check_sensors
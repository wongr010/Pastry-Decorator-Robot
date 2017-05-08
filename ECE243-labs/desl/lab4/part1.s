.equ ADDR_JP1, 0xFF200060  # address GPIO JP1

.global _start
_start:

   movia r14, 0xffffffff

READ_3:
   movia  r8, ADDR_JP1

   movia  r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
   stwio  r10, 4(r8)
   


 loop:
   movia  r11, 0xfffeffff     # enable sensor 3, disable all motors
   	and r11, r11, r14

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
	and r13, r13, r14
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

	br READ_3
	
	BACKWARD:
	movia r14, 0xFFFFFFFE
	stwio r14, 0(r8)
	addi r4, r0, 0 #clear r4
	addi r4, r0, 4

	br READ_3
	
	
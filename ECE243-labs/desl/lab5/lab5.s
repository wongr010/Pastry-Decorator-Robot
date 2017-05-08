
.global _start
_start:

movia r7, 0x10001020
ACCELERATE:
 ldwio r3, 4(r7) /* Load from the JTAG */
  srli  r3, r3, 16 /* Check only the write available bits */
  beq   r3, r0, ACCELERATE /* If this is 0 (branch true), data cannot be sent */
  movui r2, 0x04 #write 0x02 to request speed data?
  stwio r2, 0(r7) /* Write the byte to the JTAG */
  movui r2, 0x1e
  stwio r2, 0(r7) /* Write the byte to the JTAG */

  
WRITE_POLL:
  ldwio r3, 4(r7) #Load from the JTAG
  srli  r3, r3, 16 #Check only the write available bits
  beq   r3, r0, WRITE_POLL #If this is 0 (branch true), data cannot be sent
  movui r2, 0x02 #write 0x02 to request speed data?
  stwio r2, 0(r7) #Write the byte to the JTAG 
  

READ_POLL:
	ldwio r2, 0(r7)
	andi r3, r2, 0x8000 #valid byte
	beq r3, r0, READ_POLL
	andi r3, r2, 0X00FF 
	
	ldwio r2, 0(r7)
	andi r3, r2, 0x8000 #Get first byte
	beq r3, r0, READ_POLL
	andi r3, r2, 0X00FF 
	
	movi r5, 0x1f
	beq r3, r5, STRAIGHT
	movi r5, 0x1e
	beq r3, r5, TURN_R
	RETURN_R:
	movi r5, 0x1c
	beq r5, r3, TURN_R_HARD
	RETURN_R_HARD:
	movi r5, 0x0f
	beq r5, r3, TURN_L
	RETURN_L:
	movi r5, 0x0f
	beq r5, r3, TURN_L_HARD
	RETURN_L_HARD:
	

br ACCELERATE

STRAIGHT:
	ldwio r3, 4(r7) /* Load from the JTAG */
	 srli  r3, r3, 16 /* Check only the write available bits */
	 beq   r3, r0, STRAIGHT /* If this is 0 (branch true), data cannot be sent */
	 movui r2, 0x05 #write 0x02 to request speed data?
	 stwio r2, 0(r7) /* Write the byte to the JTAG */
	 movi r2, 0X00
	 stwio r2, 0(r7)
	 br ACCELERATE

TURN_R:
	ldwio r3, 4(r7) /* Load from the JTAG */
	 srli  r3, r3, 16 /* Check only the write available bits */
	 beq   r3, r0, TURN_R /* If this is 0 (branch true), data cannot be sent */
	 movui r2, 0x05 #write 0x02 to request speed data?
	 stwio r2, 0(r7) /* Write the byte to the JTAG */
	 movi r2, 0X1E
	 stwio r2, 0(r7)
	 br RETURN_R
 
 TURN_R_HARD:
	 ldwio r3, 4(r7) /* Load from the JTAG */
	 srli  r3, r3, 16 /* Check only the write available bits */
	 beq   r3, r0, TURN_R_HARD /* If this is 0 (branch true), data cannot be sent */
	 movui r2, 0x05 #write 0x02 to request speed data?
	 stwio r2, 0(r7) /* Write the byte to the JTAG */
	 movi r2, 0X64
	 stwio r2, 0(r7)
	 
	 DECELERATE_R:
	 ldwio r3, 4(r7) /* Load from the JTAG */
	  srli  r3, r3, 16 /* Check only the write available bits */
	  beq   r3, r0,  DECELERATE_R: /* If this is 0 (branch true), data cannot be sent */
	  movui r2, 0x04 #write 0x02 to request speed data?
	  stwio r2, 0(r7) /* Write the byte to the JTAG */
	  movi r2, -25 #slow down
	  stwio r2, 0(r7) /* Write the byte to the JTAG */
	 br RETURN_R_HARD
	 
TURN_L:
	ldwio r3, 4(r7) /* Load from the JTAG */
	 srli  r3, r3, 16 /* Check only the write available bits */
	 beq   r3, r0, TURN_L /* If this is 0 (branch true), data cannot be sent */
	 movui r2, 0x05 
	 stwio r2, 0(r7) /* Write the byte to the JTAG */
	 movi r2, 0XFFFFFFFFFFFFFFCE
	 stwio r2, 0(r7)
	 br RETURN_L
 
 TURN_L_HARD:
	 ldwio r3, 4(r7) /* Load from the JTAG */
	 srli  r3, r3, 16 /* Check only the write available bits */
	 beq   r3, r0, TURN_L_HARD /* If this is 0 (branch true), data cannot be sent */
	 movui r2, 0x05 #write 0x02 to request speed data?
	 stwio r2, 0(r7) /* Write the byte to the JTAG */
	 movi r2, 0X9C
	 stwio r2, 0(r7)
	 
	  DECELERATE_L:
	 ldwio r3, 4(r7) /* Load from the JTAG */
	  srli  r3, r3, 16 /* Check only the write available bits */
	  beq   r3, r0,  DECELERATE_L: /* If this is 0 (branch true), data cannot be sent */
	  movui r2, 0x04 #write 0x02 to request speed data?
	  stwio r2, 0(r7) /* Write the byte to the JTAG */
	  movi r2, 0xFFFFFFFFFFFFFFF6 #slow down
	  stwio r2, 0(r7) /* Write the byte to the JTAG */
	 br RETURN_L_HARD




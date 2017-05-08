.equ ADDR_JP1, 0xFF200060
.global _start
_start:
   # Address GPIO JP1
  movia  r8, ADDR_JP1     

  movia  r9, 0x07f557ff       # set direction for motors to all output 
  stwio  r9, 4(r8)
  
  MOVE:
  movia	 r9, 0xfffffffc       # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
  stwio	 r9, 0(r8)	
 
  
  
/*movia r8, 0xff200060 #r8 is the base- JP1
movia r9, 0x07f557ff
stwio r9, 4(r8) #base + 4 - controller

movia r9, 0xffffeffe # turn on motor 0 and sensor 1
stwio r9, 0(r8) #send this command to the lego

FORWARD:
	movia r9, 0xffffeffe #check if this is correct orientation
	stwio r9, 0(r8) #store new direction value in base
	mov r14, r9 #save the direction in r14 

start_sensor_1:
mov r9, r14
ori r9, r9, 0x1 #last bit must be 1
stwio r9, 0(r8) 
ldwio r15, r0
#...
movia r9, 0xffffeffe #turn on the motor 0 and sensor 1
movi r16, 0xfffffffc #move motor 0 forward
ldwio r9, 0(r8)
srli r9, r9, 13 #check the validity bit
and r9, r9, 0x1 #isolate validity bit
bne r0, r9, start_sensor_1 #do it again if validity bit = 1

read_sensor_1:
ldwio r10, 0(r8)
srli r10, r10, 28 #check the 'state' bit of lego controller, aka sensor 1 reading
and r10, r10, 0x0f #get the last 4 bits

start_sensor_2:
movia r9, 0xFFFFBFFF #turn on sensor 2
movi r16, 0xfffffffc #move motor 0 forward
srli r9, r9, 15 # check bit 15, valid bit for sensor 2
and r9, r9, 0x1 #isolate valid bit
bne r0, r9, start_sensor_2

read_sensor_2:
ldwio r11, 0(r8)
srli r11, r11, 29
and r11, r11, 0x0f #get last 4 bits

CHECK_SENSORS:
	movia r21, 1 #movement tolerance
	movia r22, -1
	sub r15, r10, r11 #difference between sensor readings
	bge r15, r21, FORWARD
	ble r15, r22, BACKWARD 


#call the timer here...

BACKWARD: 
	movia r9, 0xffffeffc #check if correct
	br CHECK_SENSORS

*/








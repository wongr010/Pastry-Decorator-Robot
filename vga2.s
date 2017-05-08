.section .data
SUGAR_IMAGE:
.incbin "squad.bmp", 54 #skip 138 bytes?

.equ VGA, 0x08000000


.global sugar
sugar:

#the size of starter image is 320x240
subi sp, sp, 36
stw ra, 0(sp)
stw r18, 4(sp)
stw r19, 8(sp)
stw r20, 12(sp)
stw r21, 16(sp)
stw r16, 20(sp)
stw r23, 24(sp)
stw r24, 28(sp)
stw r25, 32(sp)

movia r18, SUGAR_IMAGE
movia r20, VGA
movi r21, 320 #x
movi r16, 0 #y
movi r19, 240#ycounter
movi r23, 0 #xcounter
#r6
#r25
#r24


#do I need to add to the image address to increment

LOOP_Y:
ble r19, r16, RETURN

movi r23, 0

LOOP_X:
bge r23, r21, END_LOOP_X
ldh r6, (r18) #load one pixel - half-word

muli r24, r19, 1024
muli r25, r23, 2
add r24, r24, r25
add r24, r24, r20 #increment the VGA address
sthio r6, (r24) #store pixel in VGA

addi r18, r18, 2 #go to the next pixel

addi r23, r23, 1 #increment x loop counter

br LOOP_X

END_LOOP_X:
subi r19, r19, 1 #increment y value to get to the next row
br LOOP_Y

RETURN:
ldw r25, 32(sp)
ldw r24, 28(sp)
ldw r23, 24(sp)
ldw r16, 20(sp)
ldw r21, 16(sp)
ldw r20, 12(sp)
ldw r19, 8(sp)
ldw r18, 4(sp)
ldw ra, 0(sp)
addi sp, sp, 36
ret
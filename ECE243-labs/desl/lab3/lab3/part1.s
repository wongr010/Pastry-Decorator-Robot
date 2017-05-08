# Print ten in octal, hexadecimal, and decimal # Use the following C functions: 
# printHex ( int ) ; 
# printOct ( int ) ; 
# printDec ( int ) ; 
#.global
main: 
addi    sp,sp,-8      # Allocate space on stack for 4 words
stw     ra,4(sp)      # Save return address to stack

movi    r2,10
stw     r2,0(sp)       # 5th parameter on stack


call printOct
call printHex
call printDec       # Call printn function

mov     r2,zero        # main's return value (in r2) is 0
ldw     ra,4(sp)      # Restore return address
addi    sp,sp,8       # Deallocate stack space

ret

# ... ret # Make sure this returns to main's caller 
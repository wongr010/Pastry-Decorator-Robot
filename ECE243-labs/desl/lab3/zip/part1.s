# Print ten in octal, hexadecimal, and decimal # Use the following C functions: 
# printHex ( int ) ; 
# printOct ( int ) ; 
# printDec ( int ) ; 
.global main
main: 



addi    sp,sp,-4      # Allocate space on stack for 4 words
stw     ra,0(sp)      # Save return address to stack

movi    r4,10
#main_ret 1       # 5th parameter on stack


call printOct
#main_ret 1
movi    r4,10
call   printHex                                                                                                                         
#main_ret 2                                               
movi    r4,10
call printDec       # Call printn function

mov     r2,zero        # main's return value (in r2) is 0
ldw     ra,0(sp)      # Restore return address
addi    sp,sp,4       # Deallocate stack space

ret

# ... ret # Make sure this returns to main's caller 
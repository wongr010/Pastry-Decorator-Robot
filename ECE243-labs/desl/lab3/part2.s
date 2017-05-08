

.global	printn

printn:
	addi sp, sp, -20     		    #push ra on the stack before calling funtions 
	stw ra, 0(sp)					#store ra into 1st 4 bytes 

	stw r4, 4(sp)         			#this is pointer to first element of string array 
	stw r5, 8(sp)        			#this is 1st function argument 
	stw r6, 12(sp)					#2nd argument 
	stw r7, 16(sp)					#SO ONNNNN ...
									#sp is now pointing to ra  
	#mov r19, sp						#mov sp to r11 
	addi r19, sp, 8				#skip ra (4), then skip string's 1st entry (4)
		
									#r11 is now pointing 1st integer argument in the function parameter 
	
	movi r21, 'H'     				#put strings into registers because br cant compare register to string
	movi r22, 'O'
	movi r23, 'D'
				    mov r16, r4 
	#start at 1st string entry
	#check if its equal to 'H', 'O' or 'D'
	#call C function and print the result accordingly
	#go to the next element in the string(restart loop)
	#NEED TO ACCESS THE ARGUMENTS OF C FUNCTION
	###USE SP AS REFERENCE, AND LOOP IT TO ACCESS THE SUCCEEDING ARGUMENTS 	 
	
	
	LOOP:		
		
		ldb r14, 0(r16)				#load r4 value into r14, because r4 is a pointer to string arrays first element 
		ldw r15, 0(r19)				#load value of r11 into r15 
	 
		mov r4, r15 
		beq r14 , r21, PRINT_HEX     #check if want to convert to hex #r4 points to 1st element of string 
									 #access the corresponding argument, pass the value and call the conversion
									 #pass integer argument 
									 
	
		beq r14, r22, PRINT_OCT		  #check if want to convert to hex 

		
		beq r14, r23, PRINT_DEC       #check if want to convert to Decimal 		
		
		main_ret3:
	
		addi r16, r16, 1				#increment to next element of the string  (address???)
		addi r19, r19, 4			#increment to next integer argument 
	 
		bne r14, r0, LOOP 				#if we havent reached end of string (/0), continue loop
	loop2:	br loop2 						#else, break out of loop
	
	ldw r4, 4(sp)         			#this is pointer to first element of string array 
	ldw r5, 8(sp)        			#this is 1st function argument 
	ldw r6, 12(sp)					#2nd argument 
	ldw r7, 16(sp)
	ldw ra, 0(sp)      #restore return address 
	addi sp, sp, 20
	ret				   #Make sure this returns to main's caller

PRINT_HEX:
call printHex
br main_ret3

PRINT_OCT:
call printOct
br main_ret3

PRINT_DEC:
call printDec
br main_ret3

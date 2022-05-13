code segment


mov di,0h  			;1 if the last read character is operator
	   			;0 if the last read character is operand	
mov cx,0h  			;store last read num 

read:
	mov ah,01h   
	int 21h
	jmp check	

check:
	cmp al,0Dh 		; check enter
	je endline
	cmp al,20h 		; check space
	je space
	cmp al,2Bh 		; check plus
	je addition
	cmp al,2Ah 		; check asterisk
	je multiplication
	cmp al,2Fh 		; check slash
	je division
	cmp al,5Eh 		; check ^
	je bitwise_xor
	cmp al,26h 		; check &
	je bitwise_and
	cmp al,7Ch 		; check |
	je bitwise_or
	cmp al,3Ah   		; check numeric   
	jb num
	cmp al,40h     	 	; check letter
	ja letter



endline:
	mov ah,02h
	mov dl,0Dh
	int 21h              	;print \r
	mov dl,0Ah
	int 21h			;print \n
	mov cx,4h              	;to track result digits
	pop ax			;pop result									
	jmp handleresult	
	
	

space:
	cmp di,1h		;if last read char is operand push; otherwise continue reading
	jne read
	push cx 			;push last operand
	mov cx,0h
	mov di,0h		;to control if another consecutive space occurs, do not push again
	jmp read
	
num:
	sub al,30h		;convert ascii value to numerical value
	from_non_numeric:
	mov di,1h		;indicate that last read char is operand
	mov bx,0		
	mov bl,al 		;copy read char at bl
	mov ax,10h		
	mul cx			;if there is a digit before, multiply it by 10h
	add bx,ax		;add them
	mov cx,bx		;copy the result to cx
	jmp read
	

letter: 
	sub ax,41h
	add ax,10d		;convert ascii value of letter to numerical value
	jmp from_non_numeric

addition:
	mov di,0h		;indicate that last read char is operator
	pop ax
	pop bx			;pop last two operand
	add ax,bx		;add them
	push ax			;push the result
	jmp read			;continue reading


multiplication:
	mov di,0h		;indicate that last read char is operator
	pop bx
	pop ax			;pop last two operand
	mul bx			;multiply them
	push ax			;push the quotient
	jmp read			;continue reading

division:
	mov di,0h		;indicate that last read char is operator
	pop bx
	pop ax			;pop last two operand
	div bx			;perform the division
	push ax			;push the result
	jmp read			;continue reading

bitwise_xor:
	mov di,0h		;indicate that last read char is operator
	pop ax
	pop bx			;pop last two operand
	xor ax,bx		;peform the operation
	push ax			;push the result
	jmp read			;continue reading

bitwise_and:			
	mov di,0h		;indicate that last read char is operator
	pop ax
	pop bx			;pop last two operand
	and ax,bx		;peform the operation
	push ax			;push the result
	jmp read			;continue reading


bitwise_or:			
	
	mov di,0h		;indicate that last read char is operator
	pop ax
	pop bx			;pop last two operand
	or ax,bx			;peform the operation
	push ax			;push the result
	jmp read			;continue reading

handleresult:
	mov dx,0			;to perform division safe
	mov bx,10h		
	div bx			;dividing the result by 10h, we get the digits one by one as the remainder
	cmp dx,0Ah        	;check digit is numeric
	jb numtoascii
	add dl,41h
	sub dl,10d		;convert back to its ascii value
	jmp fromletter
	

numtoascii:
	add dl,30h		;convert back to its ascii value
fromletter:
	push dx			;push ascii values		
	dec cx			;control the number of digits by decreasing cx from 4 to 0
	jnz handleresult		;if cx is 0 printandexit otherwise continue pushing
	jmp printandexit

printandexit:	
	pop dx
	mov ah,02h
	int 21h
	pop dx
	int 21h
	pop dx
	int 21h
	pop dx
	int 21h			;pop 4 ascii values from stack and print them to console
	int 20h         		;exit program	


	


code ends
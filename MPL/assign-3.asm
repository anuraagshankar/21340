%macro print 2
	mov rax, 01
	mov rdi, 01
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

%macro input 2
	mov rax, 00
	mov rdi, 00
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

%macro exit 0
	mov rax, 60
	mov rdi, 00
	syscall
%endmacro

section .data
	menu db 0xA,
	db "1. HEX to BCD", 0xA,
	db "2. BCD to HEX", 0xA,
	db "0. Exit", 0xA,
	db " Select an option : ",
	lenmenu equ $-menu
	option db 2

	digits db 4
	bcddigits db 0
	hexaval dw 1
	index db 0
	nl: db 0xA

section .bss
	number resb 4
	result resb 1
section .text

global _start

_start:
;------------------------Display Menu and take option--------------------
	print menu, lenmenu
	input option, 2
	mov al, [option]
	cmp al, 31
	jz case1
	cmp al, 32
	jz case2
	cmp al, 30
	jz case3
;-------------------------------All option cases-------------------------
case1:
	print menu, [menulen]
	input number, 5
	mov cl, 4
	mov rsi, number
	call asciitohex
	mov [hexaval], ax
	call hextobcd
	exit
	
case2:
	print menu, [menulen]
	print menu, [menulen]
	print option, 1
	input number, 5
	mov cl, 4
	mov rsi, number
	call bcdtohex
	;mov [hexaval], ax
	mov cl, 4
	mov rsi, number
	call hextoascii
	mov rsi, number
	mov cl, 4	
	call printarr

case3:	
	print menu, [menulen]
	print menu, [menulen]
	print menu, [menulen]
exit
;----------------------------End of all options--------------------------

;----------------------Convert axcii values to hexa----------------------
asciitohex:
	xor ax, ax
	xor bx, bx
atohloop:
	rol ax, 4
	mov bl, byte[rsi]
	cmp bl, 39h
	jbe sub30
	sub bl, 07h
sub30:
	sub bl, 30h
	add ax, bx	
	inc rsi
	dec cl
	jnz atohloop	
ret	

;----------convert hexavalues in bcdhex to its corresponding bcd----------
hextobcd:

	mov ax, [hexaval]
	mov bx, 0xA
htobloop:
	xor edx, edx
	div bx
	push dx	
	inc byte[bcddigits]
	cmp ax, 0
	jnz htobloop
	
poploop:	
	pop dx
	add dx, 30h
	mov [result], dx
	print result, 1
	dec byte[bcddigits]
	jnz poploop	
ret

;--------------convert entered bcd values to hexa values-----------------
bcdtohex:
	xor ax, ax
	xor bx, bx
	xor dx, dx

	mov bx, 0xA
btohloop:
	mul bx
	mov dl, byte[rsi]
	sub dl, 30h
	add ax, dx
	inc rsi
	dec cl
	jnz btohloop
ret
;---------------------Convert hexa values to ascii----------------------
hextoascii:
	htoaloop:
		rol ax, 04
		mov bl, al
		and bl, 0xF
		cmp bl, 09
		jbe x
		add bl, 07
	x:	add bl, 30h
		mov byte[rsi], bl
		inc rsi
		dec cl
		jnz htoaloop	
ret


;---------------------------Print the digits----------------------------
printarr:

printarrloop:
	mov dl, byte[rsi]
	mov [result], dl
	print result, 1
	inc rsi
	dec cl
	jnz printarrloop	
ret












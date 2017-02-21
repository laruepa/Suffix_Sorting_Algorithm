;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 				Suffix Sorting in NASM			  										  ;
;The program will return a tree of the entered string's suffixes sorted in lexographical  ;
;order																					  ;
;Instructions: This program takes 2 arguements,                                           ;
;				(1) 'sufsort'                                                             ;
;				(2) String of characters 0,1,or 2 with max length 30                      ;        
;																						  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "asm_io.inc"
global asm_main

section .data
	msg1: db 'length error',0
	msg2: db 'composition error',0
	msg3: db 'error - program must have 2 arguments',0
	msg4: db 'sorted suffixes:',0
	msg5: db 
section .bss
	X resb 31
	Z resb 31 
	Y resd 31
	N resb 1
	i resd 1
	j resd 1
	m resd 1
	n resd 1
section .text

asm_main:
	enter 0, 0
	pusha
	
	mov ebx, dword [ebp+12]  
	mov eax, dword [ebx+4]	

	mov [N], byte 0 
	mov ecx,eax
	mov edi, 0

	cmp [ebp+8], byte 2
	je .args_correct		 
		mov eax, msg3
        	call print_string
		call print_nl
		popa
		leave
		ret
	.args_correct:
	
	.CHARLOOP:
	mov al, [ecx] 		
	inc ecx 		

	cmp al, 0  		

	je .end_length_check
		add [N], byte 1
			cmp [N], byte 31
		jl .length_ok 			;Display Length Error
		mov eax, msg1
		call print_string
		call print_nl
		popa
		leave
		ret
		.length_ok:
		cmp al, '0'
		je .char_correct
		cmp al, '1'
		je .char_correct
		cmp al, '2'
		je .char_correct	;Display Composition Error
			mov eax, msg2
			call print_string
			call print_nl
			popa
			leave
			ret
		.char_correct:
							;add to array here
		mov [X+edi], AL		;Add character to X
		mov esi, dword [N]
		sub esi, 1
		mov [Y+4*edi], esi		;Add N to Y[]
		inc edi	
		jmp .CHARLOOP

	.end_length_check:

	mov eax, dword[N]

	mov [X+edi], byte 0 		;Add terminating 0 to char array
	mov eax, X
	call print_string			;Print string for visual inspection
	call print_nl
	
	mov ecx, dword [N]
	mov eax, dword [N]
	mov [i], eax
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.forloop_1:
	mov [j], dword 1
	mov eax, [i]

	.forloop_2:
	mov eax, [j]
	mov ebx, [i]
	cmp ebx, eax		;Loop2 check conditions
	je .end_loop_2
	
	mov eax, X
	push eax 			
	mov ebx, [j]
	sub ebx, dword 1
	mov eax, [Y+4*ebx]

	push eax	 		;Push value of subcmp(i) to stack
	mov ebx, [j]
	sub ebx, dword 0
	mov eax, [Y+4*ebx]
	push eax			;Push value of subcmp(j) to stack
	call sufcmp
	
	cmp eax, 0
	jle .else
		mov ebx, [j]
		sub ebx, 1
		mov eax, [Y+4*ebx]		;variable t
		mov edx, [j]
		sub edx, 0
		mov ecx, [Y+4*edx]
		mov [Y+4*ebx], ecx
		mov [Y+4*edx], eax

	mov ecx, dword 0			;reset index
	.else:
	add [j], dword 1
	jmp .forloop_2
	
	.end_loop_2:
	cmp [i], dword 2
	je .end_loop_1
	sub [i], dword 1
	jmp .forloop_1

	.end_loop_1:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, msg4
	call print_nl
	call print_string			
	call print_nl				
	
	mov [i], dword 0
	mov edx, [N]
	sub edx, 1	
	.forloop_3:
	cmp [i], edx
	jg .end_loop_3
	mov ecx, [i]
	mov ebx, [Y+4*ecx]			;Y index
	mov eax, X
	add eax, ebx
	call print_string			
	call print_nl
	add [i], dword 1
	jmp .forloop_3
	.end_loop_3:

	mov eax, msg5 				
	call print_nl
	call print_string
	call print_nl
	.terminate:
	call read_char				;wait for enter keypress
	cmp al, `\n`
	jne .terminate

	leave
	ret

sufcmp:
	push ebp
	mov ebp, esp
	mov eax, dword [ebp+16] 	;Address of X
	mov ecx, dword 0

	.length:
	cmp byte [eax+ecx], byte 0
	je .length_end
	add ecx, dword 1
	jmp .length
	.length_end:
	mov edi, ecx				;store length (N) in edi

	mov eax, dword [ebp+16] 	;Address of X
	mov ecx, dword 0
	.addz:
	cmp byte [X+ecx], byte 0
	je .addz_end
	mov al, byte [X+ecx]
	mov [Z+ecx], al		
	add ecx, dword 1
	jmp .addz
	.addz_end:
	mov [Z+ecx], byte 0

	mov edx, [ebp+8]	;value of j
	mov ebx, edi
	sub ebx, edx
	mov [m], ebx 		;store m

	
	mov edx, [ebp+12]	
    mov ebx, edi
    sub ebx, edx
	mov [n], ebx		;store n

	mov eax, [m]

	cmp ebx, [m]		
	jl .size
	mov edi, [m]		;store k
	jmp .size_end
	.size:
	mov edi, [n]		;store k
	.size_end:

	mov ecx, dword 0
	.forloop:
	cmp ecx, edi
	je .end_forloop	
	
	mov edx, [ebp+12] 	
	add edx, ecx
	mov al, [Z+edx]		

	mov edx, [ebp+8] 	;value of j
	add edx, ecx

	cmp al, [Z+edx]		
	jl .if_1
	jg .if_2
	inc ecx		
	jmp .forloop

	.if_1:
	mov eax, -1
	jmp .return

	.if_2:
	mov eax, 1
	jmp .return

	.end_forloop:	
		
	mov ebx, [m]
	cmp [n], ebx
	jl .less
	mov eax, 1
	jmp .return

	.less:
	mov eax, -1
	
	.return:
	leave
	ret
	

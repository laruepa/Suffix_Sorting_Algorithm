;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 				Suffix Sorting in NASM			  										  ;
;The program will return a tree of the entered string's suffixes sorted in lexographical  ;
;order																					  ;
;Instructions: This program takes 2 arguements,                                           ;
;				(1) 'sufsort'                                                             ;
;				(2) String of characters 0,1,or 2 with max length 30                      ;        
;																						  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "asm_io.inc" ;Link external c functions
global asm_main	;Declare program start-point

section .data
	;Pre-declare memory for output messages and assign message identifiers
	msg1: db 'length error',0
	msg2: db 'composition error',0
	msg3: db 'error - program must have 2 arguments',0
	msg4: db 'sorted suffixes:',0
	msg5: db 'please press key to continue',0
section .bss
	;Pre-declare memory for variables and assign variable sizes
	;31 bytes max for input string length 30 chars
	X resb 31	;Character array
	Z resb 31 	;Character array for sufcmp() subroutine
	Y resd 31	;Bubble-sort array of address pointers to X
	;1 byte integers
	N resb 1	;Number of input characters
	i resd 1	;Index of for-loop1
	j resd 1	;Index of for-loop2
	m resd 1	;Spare 1 byte int
	n resd 1	;Spare 1 byte int
section .text
	;Section not used
asm_main:
	enter 0, 0	;Declare start of stack frame
	pusha	;Push current register values to stack
	
	mov ebx, dword [ebp+12]		;Move program args into general registers
	mov eax, dword [ebx+4]		

	mov [N], byte 0		;Initialize N to zero
	mov ecx,eax
	mov edi, 0
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Start of Sanity Checks;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	cmp [ebp+8], byte 2		;Check for correct number of program args (2)
	je .args_correct	;Jump structure (if structure equivalent) 
		mov eax, msg3 		
        	call print_string	;Use print_string function from included C library, print arg error
		call print_nl
		popa 	;Return stack to pre-program state
		leave
		ret 	;Function return
	.args_correct: 	;Program continues here if number of args correct
	
	.CHARLOOP: 	;Enter loop structure to count input string length and check for invalid chars
	mov al, [ecx] 		;Move first 4 bytes of input string to al register
	inc ecx 			;Increment ecx (counting number of characters / loop iterations)

	cmp al, 0  			;Check for end of byte array (null character)

	je .end_length_check	;Jump out of character counting loop if current char equals null char
		add [N], byte 1		
			cmp [N], byte 31
		jl .length_ok 			;Display length error if N larger than 31 (max size of string)
		mov eax, msg1
		call print_string
		call print_nl
		popa 	;Return stack to pre-program state
		leave
		ret 	;Function return
		.length_ok: 	;This section defines behaviour if length ok
		
		;Check if current iterated character is valid (0,1,2)
		cmp al, '0'
		je .char_correct
		cmp al, '1'
		je .char_correct
		cmp al, '2'
		je .char_correct	;Display composition error for invalid character entry
			mov eax, msg2
			call print_string
			call print_nl
			popa 	;Return stack to pre-program state
			leave
			ret 	;Function return
		.char_correct:		
							
		mov [X+edi], AL		;Add current iterated character to X
		mov esi, dword [N]	
		sub esi, 1
		mov [Y+4*edi], esi		;Add N to Y[]
		inc edi	
		jmp .CHARLOOP		;If program reaches here, loop will iterate again

	.end_length_check:		;Length and composition checks completed here, arguements ok'd, program continues

	mov eax, dword[N]

	mov [X+edi], byte 0 		;Add terminating 0 to char array
	mov eax, X
	call print_string			;Print string for visual inspection
	call print_nl
	
	mov ecx, dword [N]
	mov eax, dword [N]
	mov [i], eax
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;End of Sanity Checks;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Start of Bubble Sort;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	.forloop_1: 	;Nested for-loops generate subsets to be bubble sorted in sufcmp function 
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
	mov eax, [Y+4*ebx]	;Generate value of i

	push eax	 		;Push value of i to stack for use by sufcmp()
	mov ebx, [j]
	sub ebx, dword 0
	mov eax, [Y+4*ebx]	;Generate value of j
	push eax			;Push value of j to stack for use by sufcmp()
	call sufcmp 		;Call sufcmp() subroutine
	
	cmp eax, 0			;Check whether the returned value of sufcmp() is 1 or -1
	jle .else
		mov ebx, [j]	;Reorder addresses in Y according to sufcmp return value
		sub ebx, 1
		mov eax, [Y+4*ebx]	
		mov edx, [j]
		sub edx, 0
		mov ecx, [Y+4*edx]
		mov [Y+4*ebx], ecx
		mov [Y+4*edx], eax

	mov ecx, dword 0			;Reset index
	.else:
	add [j], dword 1
	jmp .forloop_2
	
	.end_loop_2:
	cmp [i], dword 2			;Check loop exit conditions (range 1 - i)
	je .end_loop_1
	sub [i], dword 1
	jmp .forloop_1

	.end_loop_1:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;End of Bubble Sort;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov eax, msg4
	call print_nl
	call print_string		;Display 'sorted suffixes' title before listing suffixes 	
	call print_nl				
	
	mov [i], dword 0
	mov edx, [N]
	sub edx, 1		;Subtract 1 from number of characters counted - removes null character from count N
	.forloop_3:
	cmp [i], edx		;Here, [i] represents for loop index, compare with N to see if gone through all chars
	jg .end_loop_3		;Loop Through i indices and display X[i] to X[end]
	mov ecx, [i]
	mov ebx, [Y+4*ecx]		
	mov eax, X
	add eax, ebx
	call print_string		;Print suffix to screen	
	call print_nl
	add [i], dword 1	;For loop counter increments here
	jmp .forloop_3
	.end_loop_3:

	mov eax, msg5 		
	call print_nl
	call print_string	;Print message prompting user to press enter
	call print_nl
	.terminate:
	call read_char		;Wait for enter keypress
	cmp al, `\n`		;Compare key entered to newline character, get new character if not equal
	jne .terminate

	leave 		;Leave current stack-frame
	ret 		;Function return

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
	

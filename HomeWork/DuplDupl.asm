format elf64
	public _start
	public add_element
	public delete_element
	public convert_print
	include 'func.asm'

	volume = 10000
	section '.text' executable
	
_start:
	;; выполняем анонимное отображение в память
	mov rdi, 0    ;начальный адрес выберет сама ОС
	mov rsi, volume ;задаем размер области памяти
	mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
	mov r10,0x22  ;задаем режим MAP_ANONYMOUS|MAP_PRIVATE
	mov r8, -1   ;указываем файловый дескриптор null
	mov r9, 0     ;задаем нулевое смещение
	mov rax, 9    ;номер системного вызова mmap
	syscall

	mov rsi, rax  ;Сохраняем адрес памяти анонимного отображения
	
	xor rax, rax
	mov dl, '1'
	mov rcx, 0
	;moving with mov [placeofstring + position], number

	;adding elements from 1 to 9
	@@:
		call add_element
		inc dl
		cmp dl, '9'
		jne @b
	;todo - 1) count all numbers ending with 1, 2) get all odd numbers, 3) fill with random numbers
	;before that - print individual ascii codes for each element

	;printing result as string. Need to convert each character into ascii code
	mov rcx, rsi
	push rcx
	.ploop:
		mov al, [rsi]
		push rsi
		xor rsi, rsi
		call convert_print
		call new_line
		pop rsi
		inc rsi
		cmp byte [rsi], 0x0A
		jne .ploop
	call new_line

	;; syscall munmap, freeing memory
	mov rdi, rsi
	mov rsi, volume
	mov rax, 11
	syscall

	call exit

;input - rsi (place of begin), rcx (size), rdx (element to add)
;output... I just add element and increase size. that's it, no output
add_element:
	cmp rcx, volume
	je @f

	mov [rsi + rcx], rdx
	inc rcx
	mov byte [rsi + rcx], 0x0A

	@@:
	ret

;input - rsi (place of begin), rcx (size)
;output... I just delete element and decrease size. that's it, no output
delete_element:
	cmp rcx, 0
	je @f

	push rax
	push rbx
	xor rax, rax
	xor rbx, rbx
	;removing element from the other end
	.dloop:
		mov byte bl, [rsi + rax + 1]
		mov byte [rsi + rax], bl
		inc rax
		cmp rax, rcx
		jl .dloop
	mov byte [rsi + rcx], 00
	dec rcx
	pop rbx
	pop rax

	@@:
	ret

convert_print:
	push rsi

	;each byte is no more than 1000, so 3 numbers are enough
	mov rbx, 10
	xor rdx, rdx
	div rbx
	add rdx, 48
	push rdx

	xor rdx, rdx
	div rbx
	add rdx, 48
	push rdx
	add rax, 48

	mov rdx, 3
	cmp rax, 0
	jne @f
	dec rdx
	pop rax

	cmp rax, 0
	jne @f
	dec rdx
	pop rax

	@@:
	push rax
	mov rsi, rsp
	mov rax, 1
	mov rdi, 1
	;rdx already has nessecary len
	syscall
	@@:
	pop rax
	dec rdx
	cmp rdx, 0
	jne @b

	pop rsi
	ret
format elf64

	public _start

	extrn initscr
	extrn endwin
	extrn refresh
	extrn stdscr
	extrn start_color
	extrn init_pair
	extrn addch
	extrn getch
	extrn noecho

	include 'func.asm'

	color dq 0
	length dq 0
	anon_addr dq 0
	anon_pos dq 0

	section '.test' executable

_start:
	
	;init for colors and screen
	call initscr
	call noecho
	call start_color

	;this is red
  	mov rdx, 0x1
  	mov rsi, 0x0
  	mov rdi, 0x1
  	call init_pair

  	;this is black
	mov rdx, 0x0
  	mov rsi, 0xf
  	mov rdi, 0x2
  	call init_pair

	;this is green
	mov rdx, 0x2
  	mov rsi, 0x0
  	mov rdi, 0x3
  	call init_pair

	;this is yellow
	mov rdx, 0x3
  	mov rsi, 0x0
  	mov rdi, 0x4
  	call init_pair

	;this is blue
	mov rdx, 0x4
  	mov rsi, 0x0
  	mov rdi, 0x5
  	call init_pair

  	call refresh

	;checking if we know file name
	pop rcx
	cmp rcx, 2
	jl .exit
	pop rcx

	;open file
	mov rdi, [rsp]
	mov rax, 2
	mov rsi, 0o
	syscall
	cmp rax, 0
	jl .exit

	;file descriptor
	mov r12, rax

	;finding file length
  	mov rax, 8
  	mov rdi, r12
  	mov rsi, 0
  	mov rdx, 2
  	syscall

	mov [length], rax

	;returning to start of file
	mov rax, 8
	mov rdi, r12
	mov rsi, 0
	mov rdx, 0
	syscall
	
	; syscall mmap
	mov rdi, 0    ;начальный адрес выберет сама ОС
	mov rsi, [length] ;задаем размер области памяти
	mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
	mov r10,0x22  ;задаем режим MAP_ANONYMOUS|MAP_PRIVATE
	mov r8, -1   ;указываем файловый дескриптор null
	mov r9, 0     ;задаем нулевое смещение
	mov rax, 9    ;номер системного вызова mmap
	syscall

	mov [anon_addr], rax  ;Сохраняем адрес памяти анонимного отображения
	mov [anon_pos], rax

	;writing from file to anon
	mov rsi, rax
	mov rax, 0
	mov rdi, r12
	mov rdx, [length]
	syscall

	;close file
	mov rax, 3
	mov rdi, r12
	syscall

	;printing (painting)
	xor rcx, rcx
	xor rdi, rdi

	xor rcx, rcx
	mov rcx, [length]
	.loop:
		mov rsi, [anon_pos]
		xor rax, rax
		mov al, [rsi]
		push rsi
		call paint
		pop rsi
		inc qword [anon_pos]
		cmp rcx, 0
		loop .loop

	;temp pause
	call getch

	;syscall munmap to free memory
	mov rdi, [anon_addr]
	mov rsi, [length]
	mov rax, 11
	syscall

	.exit:
	call endwin
	mov rax, 60
	mov rdi, 0
	syscall

;replace symbols
paint:
	push rcx

  	cmp [color], 0
  	jne @f
  	or rax, 0x100
	mov [color], 1
  	jmp .painted

  	@@:
  	cmp [color], 1
  	jne @f
  	or rax, 0x200
	mov [color], 2
  	jmp .painted

	@@:
	cmp [color], 2
  	jne @f
  	or rax, 0x300
	mov [color], 3
  	jmp .painted

	@@:
	cmp [color], 3
  	jne @f
  	or rax, 0x400
	mov [color], 4
  	jmp .painted

	@@:
  	or rax, 0x500
	mov [color], 0

  	.painted:
  	mov rdi, rax
  	call addch
	pop rcx
  	ret
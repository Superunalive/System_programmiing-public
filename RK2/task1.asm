format elf64

;comments for me
; 1 - get all commands here
; 2 - get it to print from address
; 3 - read from file
; 4 - put in mmap
; 5 - profit

; next program
; 1 - learn clone
; 2 - create array
; 3 - modify array parallel to each other (clone array?)
; 4 - combine results

;first task in priority, then start Lab 7. This will make second task easier.
	public _start

	extrn initscr
	extrn endwin
	extrn refresh
	extrn stdscr
	;extrn getmaxx
	;extrn getmaxy
	;extrn move
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

	;this is blue
	mov rdx, 0x2
  	mov rsi, 0x0
  	mov rdi, 0x3
  	call init_pair

	;this is ???
	mov rdx, 0x3
  	mov rsi, 0x0
  	mov rdi, 0x4
  	call init_pair

	;this is ???
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

	;writing from file to anon
	mov rsi, rax
	mov rax, 0
	mov rdi, r12
	mov rdx, [length]
	syscall

	;close file
	mov rax, 3
	mov rdi, r12

	;printing (painting)
	xor rcx, rcx
	xor rdi, rdi
	mov rsi, anon_addr
	mov [anon_pos], rsi

	;rn is broken - jumps are weird and count of length is also unusual. Maybe read length from anon and not file?
	;also broke exit, sometimes gives segfault
	.loop:
		xor rax, rax
		mov al, '0'
		call paint
		call refresh
		pop rsi
		mov rsi, anon_pos
		inc rsi
		mov [anon_pos], rsi
		cmp rsi, [length]
		jl .loop
	
	call new_line
	call print_str

	;temp pause
	call getch

	;syscall munmap to free memory
	mov rdi, rsi
	mov rsi, [length]
	mov rax, 11
	syscall

	.exit:
	call endwin
	call exit

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
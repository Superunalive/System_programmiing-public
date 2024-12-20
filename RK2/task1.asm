format ELF64

	public _start
	public create_array
	public free_memory

	;; Указываем необходимые внешние функции из библиотки ncurses
	extrn initscr
	extrn printw
	extrn refresh
	extrn getch
	extrn endwin
	extrn exit
	extrn stdscr
	extrn getmaxx
	extrn getmaxy
	extrn move
    extrn start_color
    extrn init_pair
    extrn addch

	include 'func.asm'

	section '.data' writable

	section '.bss' writable

	array_begin rq 1
	count rq 1
	palette dq 1
	xmax dq 1
	ymax dq 1


	section '.text' executable
	_start:
		pop rcx
		mov rsi, [rsp]
		call str_number
		xor rcx, rcx




create_array:
	mov [count], rdi
	;; Получаем начальное значение адреса кучи
	xor rdi,rdi
	mov rax, 12
	syscall
	mov [array_begin], rax
	mov rdi, [array_begin]
	add rdi, [count]
	mov rax, 12
	syscall
	mov rax, array_begin
	ret

free_memory:
	xor rdi,[array_begin]
	mov rax, 12
	syscall
	ret
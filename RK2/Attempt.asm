format elf64

	public create_array
	public free_memory
	public _start

	include 'func.asm'

	section '.data' writable

	section '.bss' writable

	array_begin rq 1
	count rq 1

	section '.test' executable

_start:
	mov rdi, 9
	call create_array
	xor rcx, rcx
	mov rax, 49
	.input_loop:
		mov [array_begin + rcx * 8], rax
		inc rcx
		cmp rcx, 9
		jne .input_loop

	xor rcx, rcx
	xor rax, rax
	.print_loop:
		mov rax, [array_begin + rcx * 8]
		call number_str
		call print_str
		inc rcx
		cmp rcx, 9
		jne .print_loop

	.exit:
		call free_memory
		call exit

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
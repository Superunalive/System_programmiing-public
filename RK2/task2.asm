format ELF64

	public _start
  public create_array
	public free_memory
	include 'func.asm'
	
	THREAD_FLAGS=2147585792


	section '.data' writable
	
	section '.bss' writable
	array_begin rq 1
	count rq 1
	stack_1 rq 4096 
	stack_2 rq 4096
	
	section '.text' executable
	
_start:

  ;reading array length
  pop rcx
	mov rsi, [rsp + 8]
	call str_number
	xor rcx, rcx

  call create_array

   ;;Запускаем первый тред
   mov rdi, THREAD_FLAGS
   mov rsi, 4096
   add rsi, stack_1
   mov rax, 56
   syscall
   cmp rax, 0
   je thread_1
   
   ;;Запускаем второй тред
   mov rdi, THREAD_FLAGS
   mov rsi, 4096
   add rsi, stack_2
   mov rax, 56
   syscall
   cmp rax, 0
   je thread_2

   xor rcx, rcx
   .print_loop:
    mov rax, [array_begin + rcx * 8]
    call number_str
    call print_str
    call new_line
    inc rcx
    cmp rcx, [count]
    jne .print_loop
    call new_line
   
   call free_memory
   call exit
   
	
thread_1:

  mov rcx, 0
  mov rbx, 2

  .loop_change_even:
    xor rdx, rdx
    xor rax, rax
    mov rax, [array_begin + rcx]
    div rbx
    inc rcx

    cmp rdx, 0
    jne .is_end
    mov rax, [array_begin + rcx * 8]
    inc rax
    mov [array_begin + rcx * 8], rax

    .is_end:
    cmp rcx, [count]
    jne .loop_change_even

  call exit 
  
thread_2:
  mov rcx, 0
  mov rbx, 2

  .loop_change_uneven:
    xor rdx, rdx
    xor rax, rax
    mov rax, [array_begin + rcx * 8]
    div rbx
    inc rcx

    cmp rdx, 0
    je .is_end
    mov rax, [array_begin + rcx * 8]
    dec rax
    mov [array_begin + rcx * 8], rax

    .is_end:
    cmp rcx, [count]
    jne .loop_change_uneven

  call exit 

create_array:
	mov [count], rax
	xor rdi, rdi
	mov rax, 12
	syscall
	mov [array_begin], rax
	mov rdi, [array_begin]
	add rdi, [count]
	mov rax, 12
	syscall

  mov rax, array_begin
  xor rcx, rcx
  mov rbx, 1
  .fiil_loop:
      mov [array_begin + rcx * 8], rbx
      inc rcx
      inc rbx
      cmp rcx, [count]
      jne .fiil_loop
	ret

free_memory:
	xor rdi,[array_begin]
	mov rax, 12
	syscall
	ret
  
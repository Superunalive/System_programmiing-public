format elf64

public create_array
public free_memory
public fill
include 'func.asm'

array_begin rq 1
array_end rq 1
count rq 1

;no input
;rax - pointer to the start of array (output)
create_array:

	;Finding the beginning of heap address
    xor rdi, rdi
    mov rax, 12
    syscall
    cmp rax, 0
    jl error

    mov [array_begin], rax
    mov [array_end], rax
    mov rax, array_begin
    ret

;Filling array
;rdi - number of elements (input)
;no output (although technically speaking there is a pointer to last number)
fill:
    mov r12, rdi
    xor rbx, rbx
	mov rcx, array_begin
    xor rdi, rdi
    mov rdi, [array_begin]
    .loop:
        ;making space for next element
        mov rdi, [array_end]
        add rdi, 8
        mov rax, 12
        syscall
        cmp rax, 0
        jl error
        mov [array_end], rax
        mov rdi, [array_end]

		;putting new number in position
        mov qword [rdi], 1

        inc rbx
        cmp rbx, rax
        jne .loop

    ret

free_memory:
    xor rdi, [array_begin]
    mov rax, 12
    syscall
    ret

error:
    mov rsi, "Error"
    call print_str
    call exit
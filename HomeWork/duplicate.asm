format elf64


;to do:
;replace names
;comment everything
;add own functions
;check size problems (currently 12 is max)

public create_array
public free_memory
public edit
public count_prost
public count_chet
public get_nechet
include 'func.asm'


array_begin rq 1
count rq 1
size_elem = 8

;rdi - size of array (input)
;rax - pointer to the start of array (output)
create_array:
	;Saving important parameters
    mov [count], rdi
    mov r12, rdi

	;Finding the beginning of heap address
    xor rdi, rdi
    mov rax, 12
    syscall

	;Incresing heap to hold numbers. Breaks on 13, adding anything - breaks on 14
	;to do - do errors if possible
    mov [array_begin], rax
    mov rdi, [array_begin]
	;increasing rdi gives more possible spots for numbers - makes sense, but why does it not work with count?
    add rdi, [count]
    mov rax, 12
    syscall

    mov rax, array_begin
    ret

;f db "/dev/urandom",0
;number rq 1
;Filling array
;no input
;no output (although technically speaking there is a pointer to last number)
edit:

    ;opening file with random numbers
    ;mov rdi, f
    ;mov rax, 2
    ;mov rsi, 0o
    ;syscall
    ;checking if we succeeded
    ;cmp rax, 0
    ;jl exit

    ;moving file descriptor
    ;mov r8, rax

    xor rbx, rbx
	;filling array with random numbers
	mov rcx, array_begin
    .loop:

		;saving next position and current number count. Generating new random number in rax
        push rbx
        push rcx
        ;call random
        pop rcx
        pop rbx

		;putting new number in position (rax)
        mov qword [rcx], 1

        inc rbx
		;r12 - size of array (how many elements)
        mov rax, r12

		;adding pos*8 to current position
		add rcx, size_elem

        cmp rbx, rax
        jne .loop

    ;closing file
    ;mov rax, 3
    ;mov rdi, r8
    ;syscall

    ret




;Creates random number from urandom number
;no input
;rax - random number (output)
random:

   ;generating number (reading from file)
   mov rax, 0
   mov rdi, r8
   ;mov rsi, number
   mov rdx, 1
   syscall

   ;saving number
   ;mov rax, [number]

   ret



count_prost:
    xor rbx, rbx
    xor rsi, rsi
    .loop_prost:
        mov rcx, array_begin

        mov rax, rbx
        mov rdx, size_elem
        mul rdx

        add rcx, rax

        mov rax, qword [rcx]
        push rsi
        push rbx
        call is_prost
        pop rbx
        pop rsi
        ;mov rax, rax
        add rsi, rax


        inc rbx
        mov rax, r12

        cmp rbx, rax
        jne .loop_prost
    mov rax, rsi
    ret



count_chet:
    xor rbx, rbx
    xor rsi, rsi
    mov rbx, -1
    .loop_chet:
        inc rbx
        cmp rbx, r12
        je .skip_chet

        mov rcx, array_begin
        mov rax, rbx
        mov rdx, size_elem
        mul rdx
        add rcx, rax
        mov rax, qword [rcx]

        push rbx
        push rsi
        push rcx
        push rax
            mov rcx, 2
            mov rax, rax
            xor rdx, rdx
            div rcx
        pop rax
        pop rcx
        pop rsi
        pop rbx
            cmp rdx, 0
            jne .loop_chet

        ;mov rax, rax
        inc rsi
        cmp rbx, r12
        jne .loop_chet
    .skip_chet:
        mov rax, rsi
        ret


get_nechet:
    xor rdi, rdi
    mov rax, 12
    syscall
    ret
    xor rbx, rbx
    xor rsi, rsi
    mov rbx, -1
    .loop_chet:
        inc rbx
        cmp rbx, r12
        je .skip_chet

        mov rcx, array_begin
        mov rax, rbx
        mov rdx, size_elem
        mul rdx
        add rcx, rax
        mov rax, qword [rcx]

        push rbx
        push rsi
        push rcx
        push rax
            mov rcx, 2
            mov rax, rax
            xor rdx, rdx
            div rcx
        pop rax
        pop rcx
        pop rsi
        pop rbx
            cmp rdx, 1
            jne .loop_chet

        ;mov rax, rax
        inc rsi

        cmp rbx, r12
        jne .loop_chet
    .skip_chet:
        mov rax, rsi
        ret



;rax - input, output
is_prost:
    mov rsi, rax
    xor rbx, rbx
      inc rbx
    .iter_prost:
    inc rbx
    cmp rbx, rsi
    jge .prost
    xor rdx, rdx
        mov rax, rsi
        mov rcx, rbx
        div rcx
        cmp rdx, 0
        je .neprost
        jne .iter_prost
    .prost:
        mov rax, 1
        ret
    .neprost:
        mov rax, 0
        ret

free_memory:
    xor rdi,[array_begin]
    mov rax, 12
    syscall
    ret


;exit:
    ;mov rax, 60
    ;xor rdi, rdi
    ;syscall
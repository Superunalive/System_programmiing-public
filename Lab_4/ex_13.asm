format ELF64

public _start

include 'func.asm'

section '.bss' writable
    place rb 255
    temp dq 0

_start:
    mov rsi, place
    call input_keyboard
    call str_number

    mov [temp], rax

    @@:
    mov rax, [temp]
    push rax
    ;check for low digit count
    cmp rax, 10
    jb .end

    mov rbx, 10
    mov rcx, 2
    .loop:
        xor rdx, rdx
        div rbx
        push rdx
        dec rcx
        cmp rcx, 0
        jne .loop
    pop rcx
    pop rbx

    ;now we have number in temp and last 2 digits in rcx and rbx
    ;check for bad numbers
    cmp rcx, 0
    je .repeat
    cmp rbx, 0
    je .repeat

    ;now do normal comparison
    
        mov rax, [temp]
        push rax
        .check:
            xor rdx, rdx
            div rbx
            cmp rdx, 0
            jne .repeat
            pop rax
            xor rdx, rdx
            div rcx
            cmp rdx, 0
            jne .repeat
        
        mov rax, [temp]
        call number_str
        call print_str
        call new_line

        .repeat:
            dec [temp]
            pop rax
            cmp [temp], 0
            jne @b
    .end:
        call exit
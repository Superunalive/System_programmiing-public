format ELF64

public _start

include 'func.asm'

section '.bss' writable
    place rb 255
    count dq 0
    temp dq 0

_start:
    mov rsi, place
    call input_keyboard
    call str_number

    mov [temp], rax

    ;now do normal comparison
    mov rbx, 11
    mov rcx, 5
    @@:
        mov rax, [temp]
        push rax
        .check:
            xor rdx, rdx
            div rbx
            cmp rdx, 0
            je .repeat
            pop rax
            xor rdx, rdx
            div rcx
            cmp rdx, 0
            je .repeat
        
        inc [count]

        .repeat:
            dec [temp]
            pop rax
            cmp [temp], 0
            jne @b
    
    mov rax, [count]
    call number_str
    call print_str
    call new_line
    
    .end:
        call exit
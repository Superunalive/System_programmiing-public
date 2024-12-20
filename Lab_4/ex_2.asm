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

    xor rdx, rdx
    mov rbx, 2
    div rbx
    cmp rdx, 0
    jne .uneven
    ;please separate

    .even:
        xor rdx, rdx
        mov rax, [temp]
        mov rbx, [temp]
        add rbx, 1
        mov rcx, 2
        mul rbx
        div rcx
        mov [temp], rax
        mov [place], '-'
        call print_str
        mov rax, [temp]
        call number_str
        call print_str 
        call new_line
        jmp .end
    
    .uneven:
        xor rdx, rdx
        mov rax, [temp]
        mov rbx, [temp]
        inc rax
        mov rcx, 2
        mul rbx
        div rcx
        call number_str
        call print_str
        call new_line
        jmp .end

    .end:
        call exit
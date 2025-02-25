format ELF64

public _start
section '.data' writable
    array_size dq 10          ; array size (needs to be 973)
    array dd 10 dup(0) ; array
    f db '/dev/urandom', 0

    ;some stuff for conversion and presentation
    newline db 10
    buffer rb 20
    space db ' ', 0
    fifthlast db 'I am fifth from min', 0
    thirdfirst db 'I am third from max', 0

section '.text' executable

_start:
    ; opening /dev/urandom
    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    cmp rax, 0
    jl exit
    mov r12, rax

    ; filling array
    mov rcx, [array_size]
    lea rsi, [array]
    .read_loop:
        push rcx
        mov rax, 0
        mov rdi, r12
        mov rdx, 2
        syscall
        add rsi, 4
        pop rcx
        loop .read_loop

    ; closing file
    mov rax, 3
    mov rdi, r12
    syscall

    call bubble_sort

    ; demonstration of array
    mov rcx, [array_size]
    lea rsi, [array]
    .print_array_loop:
        ;replace lodsd
        mov eax, [rsi]
        add rsi, 4
        push rcx
        push rsi
        lea rdi, [buffer]
        call number_to_string
        call print_string
        call print_space
        pop rsi
        pop rcx
        loop .print_array_loop

    call new_line

    ; syscall fork
    mov rax, 57
    syscall
    cmp rax, 0
    jz third

    ; PARENT
    ; syscall waitpid
    mov rdi, rax
    mov rsi, 0
    mov rdx, 0
    mov rax, 61
    syscall

    jmp exit

third:
    ;put whatever to print
    lea rsi, [thirdfirst]
    call print_string
    call new_line
    jmp exit

;sorts array (not very effective, but idc)
bubble_sort:
    mov rcx, [array_size]     ; Количество элементов массива
    dec rcx                   ; Нужно (n-1) итераций
    .outer_loop:
        lea rsi, [array] ; Указатель на начало массива
        mov rdx, rcx          ; Счётчик для внутреннего цикла
        .inner_loop:
            mov eax, [rsi]    ; Загружаем текущий элемент
            mov ebx, [rsi + 4] ; Загружаем следующий элемент
            cmp eax, ebx      ; Сравниваем текущий и следующий элементы
            jle .no_swap      ; Если текущий <= следующий, не меняем местами
            mov [rsi], ebx    ; Меняем местами
            mov [rsi + 4], eax
            .no_swap:
            add rsi, 4        ; Переходим к следующему элементу
            dec rdx           ; Уменьшаем счётчик внутреннего цикла
            jnz .inner_loop   ; Повторяем, если не все элементы пройдены
        loop .outer_loop      ; Повторяем внешний цикл
    ret

; prints space
print_space:
    mov rax, 1
    mov rdi, 1
    lea rsi, [space]
    mov rdx, 1
    syscall
    ret

; converts number to string
number_to_string:
    mov rcx, 10
    lea rsi, [rdi + 19]
    mov byte [rsi], 0
    dec rsi
    .convert_loop:
        xor rdx, rdx
        div rcx
        add dl, '0'
        mov [rsi], dl
        dec rsi
        test rax, rax
        jnz .convert_loop
    inc rsi
    ret

; prints string
print_string:

    mov rax, rsi
    push rdx
    mov rdx, rax
    .iter:
      cmp byte [rax], 0
      je .next
      inc rax
      jmp .iter
    .next:
     sub rax, rdx
     pop rdx
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall

    ret

; do not use stack as it breaks the program
; prints new line
new_line:
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall
    ret

; exits program
exit:
    mov rax, 60               ; syscall: exit
    xor rdi, rdi              ; Код завершения: 0
    syscall
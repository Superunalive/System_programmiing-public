format ELF64 ;Формат для 64-битного Linux

public _start
public add_elem

include 'func.asm'

section '.data' writable
    strMessage db 'Hello, Linux with brk!'  ; Строка для записи в память
    strMessageLen dq $ - strMessage            ; Длина строки

section '.bss' writable
    newelem dq '1'
    originalBrk dq ?      ; Переменная для хранения оригинального значения brk
    allocatedMemory dq ?  ; Переменная для хранения адреса выделенной памяти

section '.text' executable

_start:
    ; Получаем текущее значение brk
    mov rax, 12           ; Номер системного вызова brk
    xor rdi, rdi          ; Аргумент 0 — получить текущее значение brk
    syscall

    ; Сохраняем оригинальное значение brk
    mov [originalBrk], rax

    ; Выделяем память, увеличивая brk
    add rax, [strMessageLen] ; Увеличиваем brk на длину строки
    mov rdi, rax           ; Новое значение brk
    mov rax, 12            ; Номер системного вызова brk
    syscall

    ; Проверяем, успешно ли изменён brk
    cmp rax, [originalBrk]
    jle .exit              ; Если brk не изменился, завершаем программу

    ; Сохраняем адрес выделенной памяти
    mov [allocatedMemory], rax

    ; Копируем строку в выделенную память
    mov rdi, rax           ; Адрес выделенной памяти
    lea rsi, [strMessage]  ; Адрес строки
    mov rcx, [strMessageLen] ; Длина строки
    rep movsb              ; Копируем байты

    xor rcx, rcx
    .loop:
        push rcx
        call add_elem
        pop rcx
        inc rcx
        cmp rcx, 16000
        jne .loop

    ; Выводим строку на экран с помощью syscall write
    mov rax, 1             ; Номер системного вызова write
    mov rdi, 1             ; Файловый дескриптор (1 — стандартный вывод)
    mov rsi, [allocatedMemory] ; Адрес строки
    mov rdx, [strMessageLen] ; Длина строки
    syscall

    ; Восстанавливаем оригинальное значение brk (освобождаем память)
    mov rax, 12            ; Номер системного вызова brk
    mov rdi, [originalBrk] ; Оригинальное значение brk
    syscall

.exit:
    ; Завершаем программу с помощью syscall exit
    mov rax, 60            ; Номер системного вызова exit
    xor rdi, rdi           ; Код возврата (0 — успешное завершение)
    syscall

add_elem:
    ;more memory
    mov rax, [allocatedMemory]
    add rax, [strMessageLen]
    inc rax
    cmp rax, [originalBrk]
    jbe @f

    mov rax, 12
    mov rdi, [originalBrk]
    add rdi, [strMessageLen]
    add rdi, 4096
    syscall

    @@:
    mov rdi, [allocatedMemory]
    add rdi, [strMessageLen]
    mov byte [rdi], '1'
    mov rax, [strMessageLen]
    inc rax
    mov [strMessageLen], rax
    ret
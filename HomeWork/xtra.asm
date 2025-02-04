format ELF64  ; Формат для 64-битного Linux

public _start

section '.data' writable
    strMessage db 'Hello, Linux with brk!', 0  ; Строка для записи в память
    strMessageLen dq $ - strMessage - 1        ; Длина строки (без нулевого байта)

section '.bss' writable
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
    mov rdi, [strMessageLen] ; Текущая длина строки
    add rdi, 1              ; Увеличиваем на 1 байт для нулевого байта
    add rax, rdi            ; Увеличиваем brk на новую длину
    mov rdi, rax            ; Новое значение brk
    mov rax, 12             ; Номер системного вызова brk
    syscall

    ; Проверяем, успешно ли изменён brk
    cmp rax, [originalBrk]
    jle .exit               ; Если brk не изменился, завершаем программу

    ; Сохраняем адрес выделенной памяти
    mov [allocatedMemory], rax

    ; Копируем строку в выделенную память
    mov rdi, rax            ; Адрес выделенной памяти
    lea rsi, [strMessage]   ; Адрес строки
    mov rcx, [strMessageLen] ; Длина строки
    rep movsb               ; Копируем байты

    ; Выводим исходную строку на экран с помощью syscall write
    mov rax, 1              ; Номер системного вызова write
    mov rdi, 1              ; Файловый дескриптор (1 — стандартный вывод)
    mov rsi, [allocatedMemory] ; Адрес строки
    mov rdx, [strMessageLen] ; Длина строки
    syscall

    ; Вызываем функцию для добавления символа '1'
    mov rdi, [allocatedMemory] ; Передаём адрес выделенной памяти
    mov rsi, [strMessageLen]   ; Передаём текущую длину строки
    mov rdx, [originalBrk]     ; Передаём оригинальное значение brk
    call append_char           ; Вызываем функцию append_char

    ; Обновляем длину строки
    mov rax, [strMessageLen]   ; Текущая длина строки
    inc rax                    ; Увеличиваем на 1
    mov [strMessageLen], rax   ; Сохраняем новую длину

    ; Выводим обновлённую строку на экран с помощью syscall write
    mov rax, 1              ; Номер системного вызова write
    mov rdi, 1              ; Файловый дескриптор (1 — стандартный вывод)
    mov rsi, [allocatedMemory] ; Адрес строки
    mov rdx, [strMessageLen] ; Новая длина строки
    syscall

    ; Восстанавливаем оригинальное значение brk (освобождаем память)
    mov rax, 12             ; Номер системного вызова brk
    mov rdi, [originalBrk]  ; Оригинальное значение brk
    syscall

.exit:
    ; Завершаем программу с помощью syscall exit
    mov rax, 60             ; Номер системного вызова exit
    xor rdi, rdi            ; Код возврата (0 — успешное завершение)
    syscall

; Функция для добавления символа '1' в конец строки и выделения дополнительной памяти
append_char:
    ; rdi — адрес выделенной памяти
    ; rsi — текущая длина строки
    ; rdx — оригинальное значение brk

    ; Проверяем, достаточно ли памяти для добавления символа
    mov rax, rdi            ; Адрес выделенной памяти
    add rax, rsi            ; Переходим к концу строки
    add rax, 1              ; Учитываем новый символ
    cmp rax, rdx            ; Сравниваем с текущим brk
    jbe .add_char           ; Если памяти достаточно, переходим к добавлению символа

    ; Если памяти недостаточно, увеличиваем brk
    mov rax, 12             ; Номер системного вызова brk
    add rdx, 4096           ; Увеличиваем brk на размер страницы (4096 байт)
    mov rdi, rdx            ; Новое значение brk
    syscall

    ; Проверяем, успешно ли изменён brk
    cmp rax, rdx
    jne .exit_func          ; Если brk не изменился, выходим из функции

.add_char:
    ; Добавляем символ '1' в конец строки
    add rdi, rsi            ; Переходим к концу строки
    mov byte [rdi], '1'     ; Записываем символ '1'
    inc rdi                 ; Переходим к следующему байту
    mov byte [rdi], 0       ; Добавляем нулевой байт для завершения строки

.exit_func:
    ret                     ; Возврат из функции
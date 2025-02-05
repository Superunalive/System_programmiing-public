format ELF64  ; Формат для 64-битного Linux

public _start
public append_number
public print_array

include 'func.asm'

section '.data' writable
    ; Исходный массив чисел (64-битные целые числа)
    initialArray dq '1', '2', '3', '4', '5'
    initialArrayLen dq ($ - initialArray) / 8  ; Количество элементов в массиве

section '.bss' writable
    originalBrk dq ?      ; Переменная для хранения оригинального значения brk
    allocatedMemory dq ?  ; Переменная для хранения адреса выделенной памяти
    arrayLen dq ?         ; Переменная для хранения текущей длины массива

section '.text' executable

_start:
    ; Получаем текущее значение brk
    mov rax, 12           ; Номер системного вызова brk
    xor rdi, rdi          ; Аргумент 0 — получить текущее значение brk
    syscall

    ; Сохраняем оригинальное значение brk
    mov [originalBrk], rax

    ; Выделяем память для массива
    mov rdi, [initialArrayLen] ; Количество элементов в массиве
    shl rdi, 3              ; Умножаем на 8 (размер каждого элемента)
    add rax, rdi            ; Увеличиваем brk на размер массива
    mov rdi, rax            ; Новое значение brk
    mov rax, 12             ; Номер системного вызова brk
    syscall

    ; Проверяем, успешно ли изменён brk
    cmp rax, [originalBrk]
    jle .exit               ; Если brk не изменился, завершаем программу

    ; Сохраняем адрес выделенной памяти
    mov [allocatedMemory], rax

    ; Копируем исходный массив в выделенную память
    mov rdi, rax            ; Адрес выделенной памяти
    lea rsi, [initialArray] ; Адрес исходного массива
    mov rcx, [initialArrayLen] ; Количество элементов
    rep movsq               ; Копируем элементы массива

    ; Сохраняем текущую длину массива
    mov rax, [initialArrayLen]
    mov [arrayLen], rax

    ; Выводим исходный массив
    call print_array

    ; Добавляем новое число в массив
    mov rdi, [allocatedMemory] ; Адрес выделенной памяти
    mov rsi, [arrayLen]        ; Текущая длина массива
    mov rdx, [originalBrk]     ; Оригинальное значение brk
    mov rcx, '6'                 ; Новое число для добавления
    call append_number          ; Вызываем функцию append_number

    ; Выводим обновлённый массив
    call print_array

    ; Восстанавливаем оригинальное значение brk (освобождаем память)
    mov rax, 12             ; Номер системного вызова brk
    mov rdi, [originalBrk]  ; Оригинальное значение brk
    syscall

.exit:
    ; Завершаем программу с помощью syscall exit
    mov rax, 60             ; Номер системного вызова exit
    xor rdi, rdi            ; Код возврата (0 — успешное завершение)
    syscall

; Функция для добавления числа в массив
append_number:
    ; rdi — адрес выделенной памяти
    ; rsi — текущая длина массива
    ; rdx — оригинальное значение brk
    ; rcx — новое число для добавления

    ; Сохраняем регистры
    push rdi
    push rsi
    push rdx
    push rcx

    ; Проверяем, достаточно ли памяти для добавления числа
    mov rax, rdi            ; Адрес выделенной памяти
    mov rbx, rsi            ; Текущая длина массива
    shl rbx, 3              ; Умножаем на 8 (размер каждого элемента)
    add rax, rbx            ; Переходим к концу массива
    add rax, 8              ; Учитываем новое число
    cmp rax, rdx            ; Сравниваем с текущим brk
    jbe .add_number         ; Если памяти достаточно, переходим к добавлению числа

    ; Если памяти недостаточно, увеличиваем brk
    mov rax, 12             ; Номер системного вызова brk
    add rdx, 4096           ; Увеличиваем brk на размер страницы (4096 байт)
    mov rdi, rdx            ; Новое значение brk
    syscall

    ; Проверяем, успешно ли изменён brk
    cmp rax, rdx
    jne .exit_func          ; Если brk не изменился, выходим из функции

.add_number:
    ; Добавляем новое число в массив
    mov rax, [rsp + 16]     ; Восстанавливаем rdi (адрес выделенной памяти)
    mov rbx, [rsp + 8]      ; Восстанавливаем rsi (текущая длина массива)
    shl rbx, 3              ; Умножаем на 8 (размер каждого элемента)
    add rax, rbx            ; Переходим к концу массива
    mov qword [rax], rcx          ; Записываем новое число

    ; Увеличиваем длину массива
    mov rax, [arrayLen]
    inc rax
    mov [arrayLen], rax

.exit_func:
    ; Восстанавливаем регистры
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    ret                     ; Возврат из функции

; Функция для вывода массива
print_array:
    ; Сохраняем регистры
    push rdi
    push rsi
    push rdx

    ; Выводим массив
    mov rdi, [allocatedMemory] ; Адрес выделенной памяти
    mov rsi, [arrayLen]        ; Количество элементов
    mov rbx, 0                 ; Индекс текущего элемента

    push rsi

.print_loop:
    pop rsi
    cmp rbx, rsi               ; Проверяем, достигли ли конца массива
    jge .end_print
    push rsi
    push rbx

    ; Выводим текущий элемент
    xor rsi, rsi
    mov rax, 1                 ; Номер системного вызова write
    mov rdi, 1                 ; Файловый дескриптор (1 — стандартный вывод)
    lea rsi, [initialArray + rbx * 8] ; Адрес текущего элемента
    mov rdx, 8                 ; Размер элемента (8 байт)
    syscall

    ; Увеличиваем индекс
    pop rbx
    inc rbx
    jmp .print_loop

.end_print:
    ; Восстанавливаем регистры
    pop rdx
    pop rsi
    pop rdi
    ret
format ELF64  ; Формат для 64-битного Linux

include 'func.asm'
public _start
section '.data' writable
    array_ptr dq 0       ; Указатель на начало массива
    array_size dq 0      ; Текущий размер массива
    brk_start dq 0       ; Начальное значение brk
    random_seed dd 0     ; Семя для генерации случайных чисел
    buffer db 20 dup(0)  ; Буфер для преобразования числа в строку
    newline db 10        ; Символ новой строки

section '.text' executable
_start:
    ; Инициализация программы
    call initialize_memory

    ; Заполнение массива случайными числами
    call fill_with_random_numbers

    ; Добавление числа в конец массива
    mov rdi, 41          ; Число для добавления
    call add_to_end

    ; Удаление числа из начала массива
    call remove_from_beginning

    ; Подсчет чисел, оканчивающихся на 1
    call count_numbers_ending_with_1
    mov rdi, rax         ; Результат подсчета
    call print_number    ; Вывод результата
    call new_line

    ; Получение списка нечетных чисел
    call get_odd_numbers_list

    ; Завершение программы
    call exit_program

; Инициализация памяти
initialize_memory:
    mov rax, 12          ; Системный вызов brk
    xor rdi, rdi         ; Нулевой аргумент для получения текущего значения brk
    syscall
    mov [brk_start], rax ; Сохраняем начальное значение brk
    mov [array_ptr], rax ; Устанавливаем указатель на начало массива
    ret

; Добавление числа в конец массива
add_to_end:
    push rdi             ; Сохраняем число для добавления
    mov rax, 12          ; Системный вызов brk
    mov rdi, [array_ptr]
    add rdi, 8           ; Увеличиваем память на 8 байт (64-битное число)
    syscall
    mov [array_ptr], rax ; Обновляем указатель на конец массива
    pop rdi              ; Восстанавливаем число
    mov [rax - 8], rdi   ; Записываем число в конец массива
    inc qword [array_size] ; Увеличиваем размер массива
    ret

; Удаление числа из начала массива
remove_from_beginning:
    cmp qword [array_size], 0
    je .done             ; Если массив пуст, ничего не делаем

    mov rsi, [array_ptr] ; Указатель на конец массива
    mov rcx, [array_size] ; Текущий размер массива
    shl rcx, 3           ; Умножаем на 8 (размер числа)
    sub rsi, rcx         ; Указатель на начало массива

    ; Сдвигаем элементы массива влево
    mov rdi, rsi         ; Указатель на текущий элемент (куда копируем)
    add rsi, 8           ; Указатель на следующий элемент (откуда копируем)
    mov rcx, [array_size]
    dec rcx              ; Уменьшаем количество копируемых элементов
    cld                  ; Сброс флага направления (движение вперед)
    rep movsq            ; Копируем элементы массива влево

    ; Уменьшаем размер массива
    dec qword [array_size]

    ; Очищаем последний элемент (опционально, для безопасности)
    mov rsi, [array_ptr]
    sub rsi, 8           ; Указатель на последний элемент
    mov qword [rsi], 0   ; Очищаем последний элемент

.done:
    ret

; Заполнение массива случайными числами
fill_with_random_numbers:
    mov rcx, 10          ; Заполняем массив 10 числами
.loop:
    push rcx
    call generate_random_number
    mov rdi, rax         ; Случайное число
    call print_number
    call add_to_end      ; Добавляем в массив
    pop rcx
    loop .loop
    call new_line
    ret

; Генерация случайного числа
generate_random_number:
    mov eax, [random_seed]
    imul eax, 1103515245
    add eax, 12345
    mov [random_seed], eax
    and eax, 0x7FFFFFFF  ; Ограничиваем диапазон
    ret

; Подсчет чисел, оканчивающихся на 1
count_numbers_ending_with_1:
    xor rax, rax         ; Счетчик (результат)
    mov rcx, [array_size] ; Текущий размер массива
    test rcx, rcx        ; Проверяем, пуст ли массив
    jz .done             ; Если массив пуст, завершаем

    mov rax, rcx
    mov rbx, 8
    xor rdx, rdx
    mul rbx
    xor rbx, rbx
    xor rdx, rdx
    mov rsi, [array_ptr] ; Указатель на конец массива
    sub rsi, rax    ; Указатель на начало массива
    xor rax, rax

.loop:
    push rax
    mov rax, [rsi]       ; Загружаем текущее число из массива
    xor rdx, rdx
    mov rbx, 10
    div rbx
    pop rax
    cmp rdx, 1          ; Проверяем, оканчивается ли число на 1
    jne .next             ; Если не оканчивается, переходим к следующему числу
    inc rax              ; Увеличиваем счетчик

.next:
    add rsi, 8           ; Переходим к следующему элементу массива
    loop .loop           ; Повторяем для всех элементов массива

.done:
    ret

; Получение списка нечетных чисел
get_odd_numbers_list:
    mov rcx, [array_size] ; Текущий размер массива
    test rcx, rcx        ; Проверяем, пуст ли массив
    jz .done             ; Если массив пуст, завершаем

    mov rsi, [array_ptr] ; Указатель на конец массива
    mov rax, rcx
    xor rdx, rdx
    mov rbx, 8
    mul rbx
    xor rbx, rbx
    xor rdx, rdx
    sub rsi, rax     ; Указатель на начало массива
    xor rax, rax

.loop:
    push rcx
    mov rdx, [rsi]       ; Загружаем текущее число из массива
    test rdx, 1          ; Проверяем, является ли число нечетным
    ;jz .next             ; Если четное, переходим к следующему числу

    ; Выводим нечетное число
    mov rdi, rdx         ; Передаем число в rdi для вывода
    call print_number    ; Вызываем функцию вывода числа

.next:
    pop rcx
    add rsi, 8           ; Переходим к следующему элементу массива
    loop .loop           ; Повторяем для всех элементов массива

.done:
    ret

; Вывод числа на экран в удобочитаемом формате
print_number:
    push rdi
    push rsi
    push rax
    mov rax, rdi         ; Число для вывода
    lea rdi, [buffer + 19] ; Указатель на конец буфера
    mov byte [rdi], 0    ; Завершающий нулевой символ
    mov rcx, 10          ; Основание системы счисления (десятичная)
.convert_loop:
    dec rdi              ; Сдвигаем указатель на предыдущий байт
    xor rdx, rdx         ; Очищаем rdx для деления
    div rcx              ; Делим rax на 10, остаток в rdx
    add dl, '0'          ; Преобразуем остаток в символ
    mov [rdi], dl        ; Сохраняем символ в буфер
    test rax, rax        ; Проверяем, закончилось ли число
    jnz .convert_loop    ; Если нет, продолжаем

    ; Вывод строки
    mov rsi, rdi         ; Указатель на начало строки
    mov rdx, buffer + 20 ; Конец буфера
    sub rdx, rsi         ; Длина строки
    mov rax, 1           ; Системный вызов write
    mov rdi, 1           ; Файловый дескриптор (stdout)
    syscall

    ; Вывод символа новой строки
    mov rax, 1           ; Системный вызов write
    mov rdi, 1           ; Файловый дескриптор (stdout)
    lea rsi, [newline]   ; Указатель на символ новой строки
    mov rdx, 1           ; Длина (1 байт)
    syscall

    pop rax
    pop rsi
    pop rdi
    ret

; Завершение программы
exit_program:
    mov rax, 60          ; Системный вызов exit
    xor rdi, rdi         ; Код возврата 0
    syscall
    ret
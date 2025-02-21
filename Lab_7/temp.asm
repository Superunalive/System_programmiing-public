format ELF64 ; Указываем формат исполняемого файла для 64-битного Linux

public _start
include 'func.asm'

section '.bss' writable

name1 db 'lab5', 0
name2 db 'lab6', 0
buffer rb 20
buffer_end rb 1
readinp db 255 dup(0)
argv dq readinp, 0
env_term db 'TERM=xterm-256color', 0  ; Указываем тип терминала
env_path db 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', 0
envp dq env_term, env_path, 0


section '.text' executable  ; Секция кода

_start:

    ;reading name of file
    .mloop:
    mov rsi, readinp
    call input_keyboard
    mov al, [readinp]
    cmp al, '0'
    je exit

    ; Вызов fork()
    mov rax, 57           ; Номер системного вызова fork (57 для x86_64)
    syscall               ; Выполняем системный вызов

    ; Проверяем результат fork()
    cmp rax, 0            ; Если rax == 0, это дочерний процесс
    jz child_process      ; Переход к дочернему процессу

    ; Родительский процесс

    ; Родительский процесс
    ; Ожидаем завершения дочернего процесса
    mov rdi, rax          ; PID дочернего процесса
    mov rsi, 0            ; Статус завершения
    mov rdx, 0            ; Опции
    mov rax, 61           ; Номер системного вызова waitpid (61 для x86_64)
    syscall               ; Выполняем системный вызов

    mov rdi, rax          ; Сохраняем PID дочернего процесса в rdi
    call print_pid        ; Выводим PID родительского процесса
    jmp .mloop              ; Завершаем родительский процесс

child_process:
    ; Дочерний процесс
    mov rdi, 0            ; Устанавливаем rdi в 0 (PID дочернего процесса)
    call print_pid        ; Выводим PID дочернего процесса
    call new_line

    mov rdi, readinp ; Указатель на имя программы (/bin/ls)
    lea rsi, [argv]       ; Указатель на массив аргументов
    lea rdx, [envp]       ; Указатель на массив переменных окружения

    ; Вызов execve
    mov rax, 59           ; Номер системного вызова execve (59 для x86_64)
    syscall               ; Выполняем системный вызов

    ; Если execve завершился с ошибкой, завершаем процесс
    jmp exit

print_pid:
    ; Функция для вывода PID
    mov rax, 39           ; Номер системного вызова getpid (39 для x86_64)
    syscall               ; Получаем PID текущего процесса

    ; Преобразуем PID в строку
    mov rdi, buffer       ; Указываем буфер для вывода
    mov rsi, rax          ; PID в rax
    call int_to_string    ; Преобразуем число в строку

    ; Выводим строку на экран
    mov rax, 1            ; Номер системного вызова write (1 для x86_64)
    mov rdi, 1            ; Файловый дескриптор (1 - стандартный вывод)
    mov rsi, buffer       ; Указываем буфер с PID
    mov rdx, 20           ; Длина строки (максимальная длина PID)
    syscall               ; Выполняем системный вызов

    ret                   ; Возвращаемся из функции

int_to_string:
    ; Преобразуем число в строку
    mov rcx, 10           ; Основание системы счисления (10 для десятичной)
    mov rbx, buffer_end   ; Указываем конец буфера
    dec rbx               ; Перемещаемся на последний символ буфера

convert_loop:
    xor rdx, rdx          ; Очищаем rdx
    div rcx               ; Делим rax на 10, остаток в rdx
    add dl, '0'           ; Преобразуем остаток в символ
    dec rbx               ; Перемещаемся на предыдущий символ в буфере
    mov [rbx], dl         ; Записываем символ в буфер
    test rax, rax         ; Проверяем, закончилось ли число
    jnz convert_loop      ; Если нет, продолжаем цикл

    call new_line
    ret                   ; Возвращаемся из функции

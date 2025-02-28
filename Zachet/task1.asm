format ELF64

public _start
section ".data"
    mssg db "Enter script name: ", 0
    mssg_len = $ - mssg

    error_mssg db "Error - the following script does not exist or cannot be executed.", 0
    error_mssg_len = $ - error_mssg

section ".bss" writable
    command rb 256  ; Buffer for input
    args db 256 dup(0)    ; Buffer for arguments (to be used)
    arg1 db 255 dup(0)
    arg2 rb 10
    arg3 rb 10

    ;argument list
    args dq 5 dup(0)

section ".text" executable

_start:
    ; Prompt output
    mov rax, 1
    mov rdi, 1
    mov rsi, mssg
    mov rdx, mssg_len
    syscall

    ; Reading input
    mov rax, 0
    mov rdi, 0
    lea rsi, [command]
    mov rdx, 256
    syscall

    ; Подготовка аргументов для execve
    lea rdi, [command]
    lea rsi, [args]
    lea rdx, [args]

    ; syscall execve
    mov rax, 59
    syscall

    ; Если execve завершился с ошибкой, выводим сообщение об ошибке
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; файловый дескриптор: stdout
    lea rsi, [error_mssg] ; адрес строки ошибки
    mov rdx, error_mssg_len ; длина строки ошибки
    syscall

    ; Завершаем программу
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; код возврата 0
    syscall

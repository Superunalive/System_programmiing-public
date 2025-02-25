format ELF64

public _start
include 'func.asm'

section '.bss' writable

;Names of files we can use
name1 db '../Lab_5/a.out', 0
name2 db '../Lab_5/b.out', 0
name3 db '../Lab_6/useme', 0

;buffer for pids
buffer rb 20
buffer_end rb 1

;input buffer for name of file
readinp db 255 dup(0)
arg1 db 255 dup(0)
arg2 db 255 dup(0)
arg3 rb 10
arg4 rb 10

;argument list
argv dq 6 dup(0)

;Basically allowing simulation of a terminal for lab 6
env_term db 'TERM=xterm-256color', 0
env_path db 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', 0
envp dq env_term, env_path, 0


section '.text' executable

_start:

    ;reading name of file
    .mloop:
    mov rsi, readinp
    call input_keyboard
    mov al, [readinp]
    cmp al, '0'
    je exit

    mov rsi, readinp
    mov rdi, name1
    call strcmp
    
    ;not lab_5 file 1 - next check
    test rax, rax
    jnz @f

    ;add arguments (3)
    mov rsi, arg1
    call input_keyboard
    mov qword [argv + 8], arg1

    mov rsi, arg2
    call input_keyboard
    mov qword [argv + 16], arg2

    mov rsi, arg3
    call input_keyboard
    mov qword [argv + 24], arg3
    
    jmp .sep

    @@:
    mov rsi, readinp
    mov rdi, name2
    call strcmp

    ;not lab_5 file 2 - next check
    test rax, rax
    jnz @f

    ;add arguments (4)
    mov rsi, arg1
    call input_keyboard
    mov qword [argv + 8], arg1

    mov rsi, arg2
    call input_keyboard
    mov qword [argv + 16], arg2

    mov rsi, arg3
    call input_keyboard
    mov qword [argv + 24], arg3

    mov rsi, arg4
    call input_keyboard
    mov qword [argv + 32], arg4

    jmp .sep

    @@:
    mov rsi, readinp
    mov rdi, name3
    call strcmp

    ;not lab_6 - loop
    test rax, rax
    jnz .mloop

    ;no arguments

    .sep:

    ; syscall fork()
    mov rax, 57
    syscall

    ; checking if parent/child
    cmp rax, 0
    jz child_process

    ;PARENT

    ; waitpid
    mov rdi, rax
    mov rsi, 0
    mov rdx, 0
    mov rax, 61
    syscall

    jmp .mloop

child_process:

    mov qword [argv], readinp
    mov rdi, readinp
    lea rsi, [argv]
    lea rdx, [envp]

    ; syscall execve
    mov rax, 59
    syscall

    ; if error
    call exit


;comparing strings
;input - rdi (pointer to first string), rsi (pointer to second string)
strcmp:

    mov al, byte [rdi]
    ;if symbols are equal
    cmp al, byte [rsi]
    jne strcmp_not_equal
    ;if end of string
    test al, al
    jz strcmp_equal
    inc rdi
    inc rsi
    jmp strcmp

    strcmp_not_equal:
        mov rax, 1
        ret
    strcmp_equal:
        xor rax, rax
        ret

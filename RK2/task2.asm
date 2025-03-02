format ELF64

public _start
include 'func.asm'

section '.data' writable
    array_size dq 0      ; array size
    array_ptr  dq 0      ; pointer to array
    buffer rq 100        ; buffer

section '.text' executable

_start:
    ; checking for arguments
    pop rcx
    cmp rcx, 2
    jne exit

    ; saving number of elements
    pop rcx
    mov rsi, [rsp]
    call str_number    
    mov [array_size], rax

    ; syscall brk
    mov rax, 12
    xor rdi, rdi
    syscall
    mov [array_ptr], rax

    ; allocating memory
    mov rbx, [array_size]
    shl rbx, 2
    add rax, rbx
    mov rdi, rax
    mov rax, 12
    syscall
    
    ; fill array
    mov rcx, [array_size]
    mov rdi, [array_ptr]
    mov eax, 1
    .fill_array:
      mov [rdi], eax
      add rdi, 4
      inc eax
      loop .fill_array

    ; syscall clone for child_process1
    mov rax, 56
    mov rdi, 0x100       ; CLONE_FS | CLONE_FILES | CLONE_SIGHAND (без CLONE_VM)
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    cmp rax, 0
    je child_process1
    mov r12, rax         ; Сохраняем PID первого дочернего процесса

    ; syscall clone for child_process2
    mov rax, 56
    mov rdi, 0x100       ; CLONE_FS | CLONE_FILES | CLONE_SIGHAND (без CLONE_VM)
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    cmp rax, 0
    je child_process2
    mov r13, rax         ; Сохраняем PID второго дочернего процесса

    ; PARENT
    ;delay because wait pid is not enough
    mov rsi, buffer
    call input_keyboard

    ; syscall wait pid for child_process1
    mov rax, 61          ; sys_waitpid
    mov rdi, r12         ; PID первого процесса
    xor rsi, rsi         ; Указатель на статус
    xor rdx, rdx         ; Опции (0)
    syscall

    ; syscall wait pid for child_process2
    mov rax, 61          ; sys_waitpid
    mov rdi, r13         ; PID второго процесса
    xor rsi, rsi         ; Указатель на статус
    xor rdx, rdx         ; Опции (0)
    syscall

    ; printing array
    mov rcx, [array_size]
    mov rdi, [array_ptr]
    mov rsi, buffer
    .print_array:
      mov eax, [rdi]
      call number_str
      call print_str
      call new_line
      add rdi, 4
      loop .print_array

    jmp exit

child_process1:
    ; add 1 to even positions
    mov rcx, [array_size]
    shr rcx, 1           ; Количество четных позиций = array_size / 2
    mov rdi, [array_ptr]
    add rdi, 4           ; Начинаем с первой четной позиции (индекс 1)
    .loop1:
      mov eax, [rdi]
      inc eax
      mov [rdi], eax
      add rdi, 8          ; Переходим к следующей четной позиции
      loop .loop1

    ; Завершаем дочерний процесс
    jmp exit

child_process2:
    ; decrease odd positions by 1
    mov rcx, [array_size]
    shr rcx, 1           ; Количество нечетных позиций = array_size / 2
    test qword [array_size], 1 ; Проверяем, нечетное ли array_size
    jz @f                ; Если четное, пропускаем увеличение
    inc rcx              ; Если нечетное, увеличиваем количество на 1
    @@:
    mov rdi, [array_ptr]
    .loop2:
      mov eax, [rdi]
      dec eax
      mov [rdi], eax
      add rdi, 8          ; Переходим к следующей нечетной позиции
      loop .loop2

    ; Завершаем дочерний процесс
    jmp exit
format ELF64

public _start
section ".data"
    mssg db "Enter script name: ", 0
    mssg_len = $ - mssg

    error_mssg db "Error - the following script does not exist or cannot be executed.", 0
    error_mssg_len = $ - error_mssg

    ;Names of files we can use
    name1 db './script1.sh', 0
    name2 db './script2.sh', 0
    name3 db './script3.sh', 0

section ".bss" writable
    command rb 256  ; Buffer for input
    args dq 5 dup(0)    ; Buffer for arguments (to be used)
    arg1 db 255 dup(0)
    arg2 rb 10
    arg3 rb 10
    

section ".text" executable

_start:
    ; Prompt output
    mov rax, 1
    mov rdi, 1
    mov rsi, mssg
    mov rdx, mssg_len
    syscall

    ; Reading input
    mov rsi, command
    call input_keyboard

    mov rsi, command
    mov rdi, name1
    call strcmp
    
    ;not script1 - next check
    test rax, rax
    jnz @f

    ; Reading input
    mov rsi, arg1
    call input_keyboard
    mov qword [args + 8], arg1

    jmp .arguments

    @@:
    mov rsi, command
    mov rdi, name2
    call strcmp
    
    ;not script2 - next check
    test rax, rax
    jnz @f

    ; Reading input
    mov rsi, arg1
    call input_keyboard
    ; Reading input
    mov rsi, arg2
    call input_keyboard
    ; Reading input
    mov rsi, arg3
    call input_keyboard
    mov qword [args + 8], arg1
    mov qword [args + 16], arg2
    mov qword [args + 24], arg3

    jmp .arguments

    @@:
    mov rsi, command
    mov rdi, name3
    call strcmp
    
    ;not script3 - next check
    test rax, rax
    jnz @f
    ; Reading input
    mov rsi, arg1
    call input_keyboard
    mov qword [args + 8], arg1

    ; arguments for execve
    .arguments:
    mov qword [args], command
    lea rdi, [command]
    lea rsi, [args]
    lea rdx, [args]

    ; syscall execve
    mov rax, 59
    syscall

    ; If error
    mov rax, 1
    mov rdi, 1
    lea rsi, [error_mssg]
    mov rdx, error_mssg_len
    syscall

    @@:
    ; syscall exit
    mov rax, 60
    xor rdi, rdi
    syscall

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

input_keyboard:
  push rax
  push rdi
  push rdx

  mov rax, 0
  mov rdi, 0
  mov rdx, 255
  syscall

  xor rcx, rcx
  .loop:
     mov al, [rsi+rcx]
     inc rcx
     cmp rax, 0x0A
     jne .loop
  dec rcx
  mov byte [rsi+rcx], 0
  pop rdx
  pop rdi
  pop rax
  ret
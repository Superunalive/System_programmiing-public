format ELF64

public _start
public print_one

include 'func.asm'

section '.bss' writable                           
    temp dq 0
    exeception db 'Even number exeception!'

section '.text' executable
  _start:
    ;reading command line, second argument
    pop rcx
    mov rsi, [rsp+8]

    ;converting string to number, output in rax
    call str_number

    ;calculating sum
    xor rdx, rdx
    push rax
    inc rax
    mov rbx, 2
    div rbx
    cmp rdx, 0
    jne .exeception
    xor rdx, rdx
    push rax
    pop rbx
    mul rbx
    
    .next:
    ;dividing the number
    mov rbx, 10
    xor rdx, rdx
    xor rcx, rcx

    xor rdx, rdx
    .sep:
        inc rcx
        div ebx
        push rdx
        xor rdx, rdx
        cmp rax, 0
        jne .sep

    ;printing the number
    .print:
        pop rax
        push rcx
        add rax, '0'
        call print_one
        pop rcx
        cmp rcx, 0
        dec rcx
        jne .print
    
    call exit

    .exeception:
        mov rsi, exeception
        call print_str
        call exit

print_one:
  mov [temp], 0
  push rax
  mov rax, 1
  mov edi, 1
  pop rdx
  mov [temp], rdx
  mov rsi, temp
  mov edx, 1
  syscall
  ret



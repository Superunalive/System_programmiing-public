format ELF64

public _start

include 'func.asm'

section '.bss' writable                     
  a dq ?
  b dq ?
  c dq ?
  temp dq ?

;Current problem - segfault

_start:
    pop rcx
    pop rcx
    xor rcx, rcx
    mov rsi, [rsp]
    call str_number
    mov [a], rax
    mov rsi, [rsp + 8]
    call str_number
    mov [b], rax
    mov rsi, [rsp + 16]
    call str_number
    mov [c], rax


    ;((((a-c)*b)/c)*a)
    
    xor rdx, rdx
    mov rcx, [c]
    mov rbx, [b]
    mov rax, [a]
    push rax
    sub rax, rcx
    mul rbx
    div rcx
    xor rdx, rdx
    pop rbx
    mul rbx

    mov rbx, 10
    xor rcx, rcx
    .division_cycle:
        xor rdx, rdx
        div rbx
        push rdx
        inc rcx
        cmp rax, 0
        jne .division_cycle
    
    .print:
        xor rax, rax
        pop rax
        add rax, '0'
        push rcx
        call print_one
        pop rcx
        dec rcx
        cmp rcx, 0
        jne .print
    call exit

print_one:
  push rax
  mov rax, 1
  mov edi, 1
  pop rdx
  mov [temp], rdx
  mov rsi, temp
  mov edx, 1
  syscall
  ret
format ELF64

include 'func.asm'

public _start
public print_one

section '.bss' writable
  number dq ?                       
  temp dq 1         

section '.text' executable
  _start:
    pop rcx
    mov rsi, [rsp + 8]
    mov [rax], rsi
    mov rax, number
    call print_str

    xor rdx, rdx
    xor rcx, rcx
    mov rbx, 10
    div rbx
    push rdx
    add rax, '0'
    call print_one
    pop rdx
    mov rax, rdx
    add rax, '0'
    call print_one

    call exit

print_one:
  push rax
  mov rax, 1
  mov rdi, 1
  pop rdx
  mov [temp], rdx
  mov rsi, temp
  mov rdx, 1
  syscall
  ret
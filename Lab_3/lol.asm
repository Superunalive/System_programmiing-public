format ELF64

include 'func.asm'

public _start
public print_one

;3363522457
section '.bss' writable
  number dq 'F'                           
  temp dq 1         

section '.text' executable
  _start:

    pop rcx
    mov rsi, [rsp+8]
    call print_str
    mov rax, [rsi]
    ;call print_one

    mov rbx, 10
    ;xor rcx, rcx
    ;.iter:
       ;inc rcx
       div rbx
       ;push rdx
       ;xor rdx, rdx
       ;cmp rcx, 3
       ;jne .iter
    
    
    ;.loop:
        ;pop rax
        add rax, '0'
        push rdx
        call print_one
        pop rdx
        mov rax, rdx
        ;pop rax
        add rax, '0'
        call print_one
        ;pop rax
        ;add rax, '0'
        ;call print_one
        ;dec rcx
        ;cmp rcx, 0
        ;ja .loop


    mov eax, 1
    mov ebx, 0
    int 0x80

print_one:
  push rax
  mov eax, 1
  mov edi, 1
  pop rdx
  mov [temp], rdx
  mov rsi, temp
  mov edx, 1
  syscall
  pop rax
  ret
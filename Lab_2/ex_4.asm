format ELF64

public _start
public print_one

;3363522457
section '.bss' writable
  number dq 3363522457   
  result dq 0                            
  temp dq 1         

section '.text' executable
  _start:



    ;sum
    mov rax, [number]
    mov rbx, 10
    .iter:
       div rbx
       add [result], rdx
       xor rdx, rdx
       cmp rax, 0
       jne .iter
    

    ;no loop because the answer has two digits.
    ;Idk if loop is more optimal
    ;With loop - divide rax (result) by 10 and output rdx + '0'
    mov rax, [result]
    xor edx, edx
    div ebx
    push rdx
    add rax, '0'
    call print_one
    pop rax
    add rax, '0'
    call print_one


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
  ret
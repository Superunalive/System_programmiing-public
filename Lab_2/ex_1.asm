format ELF64

public _start
public print_one
public new_line

section '.bss' writable
    string db 'ywSzWnIvoXjsEqgFRwuyZYQwUGXWv'
    place db ?

section '.text' executable
  _start:
    mov rcx, 28
    .iter:
       mov al, [string+rcx]
       push rcx
       call print_one
       pop rcx
       dec rcx
       cmp rcx, -1
       jne .iter
    call new_line
    mov eax, 1
    mov ebx, 0
    int 0x80

print_one:
  push rax
  mov eax, 1
  mov edi, 1
  pop rdx
  mov [place], dl
  mov rsi, place
  mov edx, 1
  syscall
  ret
new_line:
   push rax
   push rdi
   push rsi
   push rdx
   push rcx
   mov rax, 0xA
   push rax
   mov rdi, 1
   mov rsi, rsp
   mov rdx, 1
   mov rax, 1
   syscall
   pop rax
   pop rcx
   pop rdx
   pop rsi
   pop rdi
   pop rax
   ret
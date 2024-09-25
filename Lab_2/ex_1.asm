format ELF64

public _start
public print_one

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
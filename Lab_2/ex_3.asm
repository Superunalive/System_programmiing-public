format ELF64

public _start
public print_one

section '.bss' writable
  array db 9 dup ('!')
  newline db 9 dup (0xA)
  place db 1
  counter dq 0

section '.text' executable
  _start:
    xor rsi, rsi

    .iter1:
      xor rdi, rdi

      mov rbx, [counter]
      inc rbx
      mov [counter], rbx

      .iter2:
        mov al, [array+rdi]
        push rdi
        call print_one
        pop rdi
        
        inc rdi
        cmp rdi, [counter]
        jne .iter2

      mov al, [newline+rsi]
      push rsi
      call print_one
      pop rsi

      inc rsi
      cmp rsi, 9
      jne .iter1
    
    mov eax, 1         
    mov ebx, 0         
    int 0x80

print_one:
  push rax           
  mov [place], al    
  mov eax, 4         
  mov ebx, 1         
  mov ecx, place     
  mov edx, 1        
  int 0x80           
  pop rax            
  ret
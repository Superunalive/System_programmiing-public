format elf64
public _start

include 'func.asm'

section '.bss' writable
  
  step dq 0
  output dq 0
  buffer rb 2

_start:
  ;checking for number of arguments
  pop rcx 
  cmp rcx, 4
  jl .l1 

  ;reading step argument. Decreasing by 1 because (step) position is (step)-1 away from 1st position
  mov rsi, [rsp + 24]
  call str_number
  dec rax
  mov [step], rax

  ;reading input file
  mov rdi,[rsp+8] 
  mov rax, 2 
  mov rsi, 0o 
  syscall 
  cmp rax, 0 
  jl .l1 
  
  ;file descriptor
  mov r8, rax

  ;finding file length
  mov rax, 8
  mov rdi, r8
  mov rsi, 0
  mov rdx, 2
  syscall

  ;saving file length
  mov r9, rax

  ;moving to start
  mov rax, 8
  mov rdi, r8
  mov rsi, 0
  mov rdx, 0
  syscall

  ;saving starting position. We may or may not need to print it
  mov r10, rax

  ;moving to (step) position. 1st position is 1, not zero
  add r10, [step]
  mov rax, 8
  mov rdi, r8
  mov rsi, r10
  mov rdx, 0
  syscall

  ;saving current position. Returning (step) to original value
  mov r10, rax
  mov rax, [step]
  inc rax
  mov [step], rax

  ;So far r10 has current read position, r9 has last position, r8 has input file descriptor.

  ;open output file
  mov rdi, [rsp+16] 
  mov rax, 2 
  mov rsi, 577
  mov rdx, 777o 
  syscall 
  cmp rax, 0 
  jl .l1 

  ;saving file descriptor
  mov [output], rax
  

;print and move loop
.loop:
   ;Comparing current position with end. Printing next element
   cmp r10, r9
   jge .l2
   mov rax, 0
   mov rdi, r8
   mov rsi, buffer
   mov rdx, 1 
   syscall

   ;file output
   mov [buffer+1], 0x0a
   mov rax, 1
   mov rdi, [output]
   mov rsi, buffer
   syscall

   ;Moving read position
   add r10, [step]
   mov rax, 8
   mov rdi, r8
   mov rsi, r10
   mov rdx, 0
   syscall
   jmp .loop

;close files if end of file
.l2:
  call new_line
  mov rdi, r8
  mov rax, 3
  syscall

  mov rdi, [output]
  mov rax, 3
  syscall

;exit if not enough arguments/didn't open file/finished as intended
.l1:
  call exit
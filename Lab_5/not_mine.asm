format elf64
public _start
public print_func
public move_func

include 'func.asm'

section '.bss' writable
  
  pos dq 0
  endist dq 4
  output dq 0
  buffer rb 2

_start:
  ;checking for number of arguments
  pop rcx 
  cmp rcx, 4
  jl .l1 

  ;reading pos argument. Decreasing by 1 because (pos) position is (pos)-1 away from 1st position
  mov rsi, [rsp + 24]
  call str_number
  dec rax
  mov [pos], rax

  ;finished output to console
  ;need: read 1 more argument - output file

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

  ;moving to (pos) position. 1st position is 1, not zero
  add r10, [pos]
  mov rax, 8
  mov rdi, r8
  mov rsi, r10
  mov rdx, 0
  syscall

  ;saving current position. Changing (pos) to count (0 --> endist)
  mov r10, rax
  mov [pos], 0

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

  ;checking, printing middle
  cmp r10, r9
  jge .l2
  cmp r10, 0
  jl .l2
  call print_func

;print and move loop
.loop:

  mov rax, [endist]
  cmp rax, [pos]
  jle .l2

  ;Moving read position
  add r10, [pos]
  mov rax, [pos]
  inc rax
  mov [pos], rax
  add r10, [pos]
  call move_func

  ;Comparing current position with end. Printing next element
  cmp r10, r9
  jge .l2
  call print_func

  ;Moving read position
  sub r10, [pos]
  sub r10, [pos]
  call move_func

  ;Comparing current position with begin. Printing next element
  cmp r10, 0
  jl .l2
  call print_func

  jmp .loop

;close file if end of file
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

move_func:
  mov rax, 8
  mov rdi, r8
  mov rsi, r10
  mov rdx, 0
  syscall
  ret

print_func:
  mov rax, 0
  mov rdi, r8
  mov rsi, buffer
  mov rdx, 1 
  syscall

  mov [buffer+1], 0x0a
  mov rax, 1
  mov rdi, [output]
  mov rsi, buffer
  syscall
  ret
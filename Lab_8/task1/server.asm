;21 очко
format elf64

public _start

include 'func.asm'

section '.bss' writable
  ;temps and buffers
  buffer rb 200
  number rb 100
  lbuf rb 100

  ;dev urandom file + random number
  f db "/dev/urandom", 0
  rand dq ?
  s dq ?

  ;client
  client1 dq ?
  client2 dq ?

  ;array for counting
  counting_array dq 12 dup (0)

  ;errors
  msg_1 db 'Error bind', 0xa, 0
  msg_3 db 'New connection on port ', 0
  msg_4 db 'Successfull listen', 0xa, 0

  ;socket structures
  struc sockaddr
  {
    .sin_family dw 2   ; AF_INET
    .sin_port dw 0x3d9 ; port 55555
    .sin_addr dd 0     ; localhost
    .sin_zero_1 dd 0
    .sin_zero_2 dd 0
  }
  addrstr sockaddr
  addrlen = $ - addrstr
	
section '.text' executable

_start:	
  ;opening urandom file
  mov rax, 2
  mov rdi, f
  mov rsi, 0o
  syscal
  
  ;moving random numberl
  mov [rand], rax

  ;opening socket
  mov rax, 41
  mov rdi, 2 ;AF_INET - IP v4 
  mov rsi, 1 ;seq_packet
  mov rdx, 0 ;default
  syscall

  ;saving (server) socket descriptor
  mov [s], rax

  ;connecting (syscall bind)
  mov rax, 49
  mov rdi, [s]
  mov rsi, addrstr
  mov rdx, addrlen
  syscall
  cmp rax, 0
  jl _bind_error

  ;syscall listen (expecting 2 clients)
  mov rax, 50
  mov rdi, [s]
  mov rsi, 2
  syscall
  cmp rax, 0
  jl  _bind_error

  ;syscall accept
  mov rax, 43
  mov rdi, [s]
  mov rsi, 0
  mov rdx, 0
  syscall

  ;saving socket descriptor
  mov [client1], rax

  ;again
  mov rax, 43
  mov rdi, [s]
  mov rsi, 0
  mov rdx, 0
  syscall
  mov [client2], rax

  ;generating inital random numbers (for array)
  call rand_num
  add r8, rax
  mov r10, rax
  call rand_num
  add r9, rax
  mov r13, rax

  mov rax, '2'
  mov [lbuf], al

  ;reading from second client
  mov rax, 1
  mov rdi, [client2]
  mov rsi, lbuf
  mov rdx, 100
  syscall

  loop1:
    mov rax, '1'
    mov [lbuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lbuf
    mov rdx, 100
    syscall

    mov rsi, buffer
    mov rax, r8
    call number_str
    mov rax, 1
    mov rdi, [client1]
    mov rsi, buffer
    mov rdx, 100
    syscall

    mov rsi, buffer
    mov rax, r10
    call number_str
    mov rax, 1
    mov rdi, [client1]
    mov rsi, buffer
    mov rdx, 100
    syscall

    _read1:
    mov rax, 0
    mov rdi, [client1]
    mov rsi, buffer
    mov rdx, 100
    syscall
      
    ; Client didn't send anything - continue
    cmp rax, 0
    je _read1

    ;if something - checking if it's 0 
    mov rsi, buffer
    call str_number
    cmp rax, 0
    je next

    ;if not 0 - generating number (if not overflow - continue)
    call rand_num
    mov r10, rax
    add r8, rax
    cmp r8, 21
    jl loop1

    ;if overflow - send back code 3
    mov rax, '3'
    mov [lbuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lbuf
    mov rdx, 100
    syscall

    ;
    mov rsi, buffer
    mov rax, r8
    call number_str
    mov rax, 1
    mov rdi, [client1]
    mov rsi, buffer
    mov rdx, 100
    syscall

  next:
    mov rax, '2'
    mov [lbuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lbuf
    mov rdx, 100
    syscall

  loop2:
    mov rax, '1'
    mov [lbuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lbuf
    mov rdx, 100
    syscall
    mov rsi, buffer
    mov rax, r9
    call number_str
    mov rax, 1
    mov rdi, [client2]
    mov rsi, buffer
    mov rdx, 100
    syscall
    mov rsi, buffer
    mov rax, r13
    call number_str
    mov rax, 1
    mov rdi, [client2]
    mov rsi, buffer
    mov rdx, 100
    syscall
  
  ;same thing with client 2
  _read2:
    mov rax, 0
    mov rdi, [client2]
    mov rsi, buffer
    mov rdx, 100
    syscall
      
    cmp rax, 0
    je _read2
  
  mov rsi, buffer
  call str_number
  cmp rax, 0
  je res
  
  call rand_num
  mov r13, rax
  add r9, rax
  cmp r9, 21
  jl loop2

  mov rax, '3'
  mov [lbuf], al
  mov rax, 1
  mov rdi, [client2]
  mov rsi, lbuf
  mov rdx, 100
  syscall

  mov rsi, buffer
  mov rax, r9
  call number_str

  mov rax, 1
  mov rdi, [client2]
  mov rsi, buffer
  mov rdx, 100
  syscall

  ;results
  res:
  cmp r8, 21
  jnl notless1
  mov rax, 21
  sub rax, r8
  mov r8, rax
  notless1:
  sub r8, 21

  cmp r9, 21
  jnl notless2
  mov rax, 21
  sub rax, r9
  mov r9, rax
  notless2:
  sub r9, 21

  ;who wins
  cmp r8, r9
  jl win1

  cmp r8, r9
  jg win2

  mov rax, '7'
  mov [lbuf], al
  mov rax, 1
  mov rdi, [client1]
  mov rsi, lbuf
  mov rdx, 100
  syscall

  mov rax, '7'
  mov [lbuf], al
  mov rax, 1
  mov rdi, [client2]
  mov rsi, lbuf
  mov rdx, 100
  syscall

  jmp fin

  win1:
  mov rax, '8'
  mov [lbuf], al
  mov rax, 1
  mov rdi, [client1]
  mov rsi, lbuf
  mov rdx, 100
  syscall

  mov rax, '9'
  mov [lbuf], al
  mov rax, 1
  mov rdi, [client2]
  mov rsi, lbuf
  mov rdx, 100
  syscall

  jmp fin


  win2:
    mov rax, '9'
    mov [lbuf], al
    mov rax, 1
    mov rdi, [client1]
    mov rsi, lbuf
    mov rdx, 100
    syscall
    mov rax, '8'
    mov [lbuf], al
    mov rax, 1
    mov rdi, [client2]
    mov rsi, lbuf
    mov rdx, 100
    syscall
    jmp fin

  fin:
    ;closing
    mov rax, 3
    mov rdi, [rand]
    syscall
    mov rax, 3
    mov rdi, [s]
    syscall
    mov rax, 3
    mov rdi, [client1]
    syscall
    mov rax, 3
    mov rdi, [client2]
    syscall

  call exit

rand_num:
  rand_num_cycle:
  mov rax, 0
  mov rdi, [rand]
  mov rsi, number
  mov rdx, 2
  syscall

  mov al, [number]
  mov rbx, 8
  xor rdx, rdx
  div rbx
  mov rax, rdx
  add rax, 4
  mov rbx, [counting_array+rax]
  cmp rbx, 4
  jg rand_num_cycle
  
  inc [counting_array+rax]
  ret

_bind_error:
  mov rsi, msg_1
  call print_str
  call exit
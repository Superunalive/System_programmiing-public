format ELF64

public _start

section '.bss' writable
  ;temps and buffers
  buffer rb 200
  number rb 100
  total db 0
  

  s dq ?

  ;client
  client1 dq ?

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

section '.text' executable  ; Секция кода

;list of syscalls
SYS_SOCKET = 41
SYS_BIND = 49
SYS_LISTEN = 50
SYS_ACCEPT = 43
SYS_READ = 0
SYS_WRITE = 1
SYS_CLOSE = 3
SYS_EXIT = 60

; Constants for servers
AF_INET = 2
SOCK_STREAM = 1
INADDR_ANY = 0

_start:
    ; Creating socket
    mov rax, SYS_SOCKET
    mov rdi, 2
    mov rsi, SOCK_STREAM
    mov rdx, 0
    syscall

    ; Checking if successful
    cmp rax, 0
    jl .exit

    ; Saving socket descriptor
    mov rbx, rax

    ; Biding socket to address and port
    mov rax, SYS_BIND
    mov rdi, rbx
    lea rsi, [addrstr]
    mov rdx, addrlen  ; Size of structure sockaddr_in
    syscall

    ; Checking if successful
    cmp rax, 0
    jl .close_socket

    ; Listening for incoming signals
    mov rax, SYS_LISTEN
    mov rdi, rbx
    mov rsi, 5  ; Max of awaiting connections
    syscall

    ; Checking if successful
    cmp rax, 0
    jl .close_socket

.accept_loop:
    ; Accepting incoming connection
    mov rax, SYS_ACCEPT
    mov rdi, rbx
    xor rsi, rsi
    xor rdx, rdx
    syscall

    ; Checking if successful
    cmp rax, 0
    jl .close_socket

    ; Saving client descriptor
    mov r12, rax

    ; Reading from client
    mov rax, SYS_READ
    mov rdi, r12
    lea rsi, [buffer]
    mov rdx, 1  ; Читаем 1 байт
    syscall

    ; If '1' - do something, else - close socket
    cmp byte [buffer], '1'
    jne .close_client_socket

    ; Sending the message to client
    mov rax, SYS_WRITE
    mov rdi, r12
    lea rsi, [hello_msg]
    mov rdx, hello_msg_len
    syscall

.close_client_socket:
    ; Closing client socket
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall

    ; Awaiting other connections
    jmp .accept_loop

.close_socket:
    ; Close server socket
    mov rax, SYS_CLOSE
    mov rdi, rbx
    syscall

.exit:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

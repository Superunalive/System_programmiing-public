format ELF64

public _start

section '.text' executable  ; Секция кода

;Similar comments for client that are in server file are skipped UNLESS actually really important
SYS_SOCKET = 41
SYS_CONNECT = 42
SYS_READ = 0
SYS_WRITE = 1
SYS_CLOSE = 3
SYS_EXIT = 60

SOCK_STREAM = 1
INADDR_LOOPBACK = 0x7F000001  ; 127.0.0.1
PORT = 12345

_start:
    ; Creating socket
    mov rax, SYS_SOCKET
    mov rdi, 2
    mov rsi, SOCK_STREAM
    mov rdx, 0
    syscall

    cmp rax, 0
    jl .exit

    ; Socket descriptor
    mov rbx, rax

    ; syscall bind
    mov rax, 49
    mov rdi, rbx              ; server descriptor
    mov rsi, addrstr_client  ; sockaddr_in struct
    mov rdx, addrlen_client  ; length of sockaddr_in
    syscall

    ; Server connection
    mov rax, SYS_CONNECT
    mov rdi, rbx
    lea rsi, [addrstr_client]
    mov rdx, addrlen_client ; Размер структуры sockaddr_in
    syscall

    cmp rax, 0
    jl .close_socket

    ; Sending '1' to server
    mov rax, SYS_WRITE
    mov rdi, rbx
    lea rsi, [input_char]
    mov rdx, 1
    syscall

    ; Reading from server
    mov rax, SYS_READ
    mov rdi, rbx
    lea rsi, [buffer]
    mov rdx, 1024
    syscall

    ; Output data
    mov rax, SYS_WRITE
    mov rdi, 1  ; stdout
    lea rsi, [buffer]
    mov rdx, 1024
    syscall

.close_socket:
    ; Closing socket
    mov rax, SYS_CLOSE
    mov rdi, rbx
    syscall

.exit:
    ; Finish program
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

section '.data' writable  ; Секция данных

input_char db '1'
buffer rb 1024
;structures for sockets
  struc sockaddr_client
  {
    .sin_family dw 2         ; AF_INET
    .sin_port dw 0x5d9     ; port
    .sin_addr dd 0           ; localhost
    .sin_zero_1 dd 0
    .sin_zero_2 dd 0
  }

  addrstr_client sockaddr_client 
  addrlen_client = $ - addrstr_client
  
  struc sockaddr_server 
  {
    .sin_family dw 2         ; AF_INET
    .sin_port dw 0x3d9     ; port 55555
    .sin_addr dd 0           ; localhost
    .sin_zero_1 dd 0
    .sin_zero_2 dd 0
  }

  addrstr_server sockaddr_server 
  addrlen_server = $ - addrstr_server
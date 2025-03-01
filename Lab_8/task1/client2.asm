format elf64
public _start
include 'func.asm'

section '.bss' writable

buffer rb 100
mssg_wait db "Wait for the other player to finish their turn", 0
mssg_win db "Congratulations, you won", 0
mssg_lose db "Game over", 0
mssg_score db "Current score ", 0
mssg_last db "Last card ", 0
mssg_options db "You can take a new card by writing 1 or pass the turn by writing 0", 0
mssg_over db "Your score is equal or higher than 21. Your score is ", 0
mssg_draw db "Draw", 0
mssg_4 db 'Connect error', 0xa, 0
mssg_1 db 'Bind error', 0xa, 0
  
struc sockaddr_client
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x6d9     ; port
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

section '.text' executable

_start:

; creating socket
mov rdi, 2 ;AF_INET - IP v4 
mov rsi, 1
mov rdx, 0
mov rax, 41
syscall
; saving socket descriptor
mov r9, rax

; syscall bind
mov rax, 49
mov rdi, r9              ; server descriptor
mov rsi, addrstr_client  ; sockaddr_in struct
mov rdx, addrlen_client  ; length of sockaddr_in
syscall

cmp rax, 0
jl b_err
    
;syscall connect
mov rax, 42
mov rdi, r9
mov rsi, addrstr_server 
mov rdx, addrlen_server
syscall

cmp rax, 0
jl c_err

;loop
_read:
;syscall read (from server)
mov rax, 0
mov rdi, r9
mov rsi, buffer
mov rdx, 100
syscall
      
;Server sent nothing = continue
cmp rax, 0
je _read

;jumping to the correct function
mov rsi, buffer
call str_number

cmp rax, 1
je printing

cmp rax, 2
je waiting

cmp rax, 3
je overflow

cmp rax, 7
je draw

cmp rax, 8
je win

cmp rax, 9
je lose

;Asking to wait if number is different
call waiting

waiting:
  mov rsi, mssg_wait
  call print_str
  call new_line
  jmp _read

printing:
  ;printing score (message)
  mov rsi, mssg_score
  call print_str

  ;awaiting further instructions 
  _data_wait:
    mov rax, 0
    mov rdi, r9
    mov rsi, buffer
    mov rdx, 100
    syscall
    cmp rax, 0
    je _data_wait

  ;printing score (value)
  mov rsi, buffer
  call print_str
  call new_line

  ;printing the card we got (message)
  mov rsi, mssg_last
  call print_str

  ;awaiting further instructions
  _data_wait2:
    mov rax, 0
    mov rdi, r9
    mov rsi, buffer
    mov rdx, 100
    syscall
    cmp rax, 0
    je _data_wait2

  ;printing the card we got (value)
  mov rsi, buffer
  call print_str
  call new_line

  ;printing options (what you can do)
  mov rsi, mssg_options
  call print_str
  call new_line
  mov rsi, buffer

  ;awaiting input (take/pass)
  call input_keyboard
  mov rax, 1
  mov rdi, r9
  mov rsi, buffer
  mov rdx, 100
  syscall

  jmp _read

overflow:
  ;printing if >=21
  mov rsi, mssg_over
  call print_str

  ;awaiting further instuctions
  _data_wait3:
    mov rax, 0
    mov rdi, r9
    mov rsi, buffer
    mov rdx, 100
    syscall
    cmp rax, 0
    je _data_wait3

  ;prinitng score (overflow)
  mov rsi, buffer
  call print_str
  call new_line

  jmp _read

draw:
  ;grabbed card
  mov rsi, mssg_draw
  call print_str
  call new_line
  jmp finale

win:
  ;won the game
  mov rsi, mssg_win
  call print_str
  call new_line
  jmp finale

lose:
  ;lost the game
  mov rsi, mssg_lose
  call print_str
  call new_line
  jmp finale

finale:
  ;disconnecting
  mov rdi, r9
  mov rax, 3
  syscall
    
call exit

b_err:
  ;failed to bind
  mov rsi, mssg_1
  call print_str
  call exit
   
c_err:
  ;failed to connect
  mov rsi, mssg_4
  call print_str
  call exit
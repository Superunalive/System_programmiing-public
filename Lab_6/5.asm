format elf64
public _start

extrn initscr
extrn endwin
extrn refresh
extrn stdscr
extrn getmaxx
extrn getmaxy
extrn move
extrn start_color
extrn init_pair
extrn addch
extrn getch
extrn timeout
include 'func.asm'

maxx dq 0
maxy dq 0
palette dq 0
count dq 0

section ".text" executable

_start:
  ;initializing stuff
  call initscr
  mov rdi, [stdscr]
  call getmaxx
  mov [maxx], rax
  call getmaxy
  mov [maxy], rax
  

  call start_color

  ;this is blue - need red instead
  mov rdx, 0x4
  mov rsi, 0x0
  mov rdi, 0x1
  call init_pair

  ;this is black
  mov rdx, 0x0
  mov rsi, 0xf
  mov rdi, 0x2
  call init_pair

  call refresh

  ;moving to the start (just in case)
  xor rdi, rdi
  xor rsi, rsi
  call move
  call refresh

  ;cycle for 1 side
  xor rdi, rdi
  .dloop:
    ;next symbol
    xor rax, rax
    mov rax, ' '
    or rax, 0x100
    mov rdi, rax
    call addch

    call refresh

    ;moving down
    xor rdi, rdi
    xor rsi, rsi
    mov rdi, [count]
    inc rdi
    mov [count], rdi
    call move
    
    call refresh

    mov rax, [count]
    cmp rax, [maxy]
    jb .dloop
  
  xor rdi, rdi
  mov [count], 0
  .rloop:
    ;next symbol
    xor rax, rax
    mov rax, ' '
    or rax, 0x100
    mov rdi, rax
    call addch

    call refresh

    ;moving right
    mov rdi, [maxy]
    xor rsi, rsi
    mov rsi, [count]
    inc rsi
    mov [count], rsi
    call move
    
    call refresh

    mov rax, [count]
    cmp rax, [maxx]
    jb .rloop

  mov rdi, [maxy]
  mov [count], rdi
  .uloop:
    ;moving up
    xor rdi, rdi
    mov rsi, [maxx]
    mov rdi, [count]
    dec rdi
    mov [count], rdi
    call move
    
    call refresh

    ;next symbol
    xor rax, rax
    mov rax, ' '
    or rax, 0x100
    mov rdi, rax
    call addch

    ;call getch
    call refresh

    mov rax, [count]
    cmp rax, 0
    ja .uloop

  mov rdi, [maxx]
  mov [count], rdi
  .lloop:
    ;moving left
    xor rsi, rsi
    xor rdi, rdi
    mov rsi, [count]
    dec rsi
    mov [count], rsi
    call move
    
    call refresh

    ;next symbol
    xor rax, rax
    mov rax, ' '
    or rax, 0x100
    mov rdi, rax
    call addch

    ;call getch
    call refresh

    mov rax, [count]
    cmp rax, 0
    ja .lloop

  call getch
  call endwin
  call exit


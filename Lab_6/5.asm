format elf64
public _start
public paint
public change

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
extrn mydelay
extrn noecho
include 'func.asm'

maxx dq 0
maxy dq 0'
minx dq 0
miny dq 0
color dq 0
loops dq 0
speed dq 1000

section ".text" executable

_start:
  ;initializing stuff
  call initscr
  mov rdi, [stdscr]
  call getmaxx
  mov [maxx], rax
  call getmaxy
  mov [maxy], rax
  
  call noecho
  call start_color

  ;this is blue - need red instead
  mov rdx, 0x1
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

  ;4 loops in 1 for all sides of a square spiral
  xor rdi, rdi
  xor rsi, rsi
  .dloop:
    push rdi
    push rsi
    call paint
    mov rdi, [speed]
    call mydelay
    call refresh
    call timeout
    call getch
    cmp rax, 'l'
    je .exit
    cmp rax, 'p'
    jne @f
      cmp [speed], 1000
      jne .spd1
      mov [speed], 10
      jmp @f
      .spd1:
      mov [speed], 1000
    @@:


    pop rsi
    pop rdi
    inc rdi
    push rsi
    push rdi
    call move
    
    call refresh
    pop rdi
    pop rsi
    cmp rdi, [maxy]
    jne .dloop

  cmp [maxx], rsi
  jbe .ending
  .rloop:
    push rdi
    push rsi
    call paint
    mov rdi, [speed]
    call mydelay
    call refresh
    call timeout
    call getch
    cmp rax, 'l'
    je .exit
    cmp rax, 'p'
    jne @f
      cmp [speed], 1000
      jne .spd2
      mov [speed], 10
      jmp @f
      .spd2:
      mov [speed], 1000
    @@:

    pop rsi
    pop rdi
    inc rsi
    push rdi
    push rsi
    call move

    call refresh
    pop rsi
    pop rdi
    cmp rsi, [maxx]
    jne .rloop

  cmp rdi, [miny]
  jbe .ending
  .uloop:
    push rdi
    push rsi
    call paint
    mov rdi, [speed]
    call mydelay
    call refresh
    call timeout
    call getch
    cmp rax, 'l'
    je .exit
    cmp rax, 'p'
    jne @f
      cmp [speed], 1000
      jne .spd3
      mov [speed], 10
      jmp @f
      .spd3:
      mov [speed], 1000
    @@:

    pop rsi
    pop rdi
    dec rdi
    push rdi
    push rsi
    call move

    call refresh
    pop rsi
    pop rdi
    cmp rdi, [miny]
    jne .uloop

  mov rax, [minx]
  inc rax
  inc rax
  mov [minx], rax

  cmp rsi, [minx]
  jbe .ending
  mov rax, [maxy]
  dec rax
  cmp rax, [miny]
  je .ending
  .lloop:
    push rdi
    push rsi
    call paint
    mov rdi, [speed]
    call mydelay
    call refresh
    mov rdi, 1
    call timeout
    call getch
    cmp rax, 'l'
    je .exit
    cmp rax, 'p'
    jne @f
      cmp [speed], 1000
      jne .spd4
      mov [speed], 10
      jmp @f
      .spd4:
      mov [speed], 1000
    @@:

    pop rsi
    pop rdi
    dec rsi
    push rdi
    push rsi
    call move

    call refresh
    pop rsi
    pop rdi
    cmp rsi, [minx]
    jne .lloop
  
  mov rax, [maxy]
  dec rax
  dec rax
  mov [maxy], rax
  mov rax, [maxx]
  dec rax
  dec rax
  mov [maxx], rax
  mov rax, [miny]
  inc rax
  inc rax
  mov [miny], rax

  mov rax, [loops]
  inc rax
  mov [loops], rax
  cmp rax, 1
  jne @f
  mov rax, [maxy]
  dec rax
  mov [maxy], rax

  @@:
  mov rbx, [maxy]
  dec rbx
  cmp rdi, rbx
  jb .dloop
  
  .ending:
  call paint
  call refresh

  xor rdi, rdi
  xor rsi, rsi
  call move
  mov [loops], 0
  mov [minx], 0
  mov [miny], 0

  mov rdi, [stdscr]
  call getmaxx
  mov [maxx], rax
  call getmaxy
  mov [maxy], rax
  xor rdi, rdi
  xor rsi, rsi
  
  cmp [color], 0
  jne @f
  mov [color], 1
  jmp .dloop
  @@:
  mov [color], 0
  jmp .dloop
  
  .exit:
    call endwin
    call exit

paint:
  xor rax, rax
  mov rax, ' '
  cmp [color], 0
  jne @f
  or rax, 0x100
  jmp .painted
  @@:
  or rax, 0x200
  .painted:
  mov rdi, rax
  call addch
  ret

change:
  ret
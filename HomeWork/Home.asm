format ELF64

include 'func.asm'
public _start
section '.data' writable
    array_ptr dq 0       ; Pointer to end of array
    array_size dq 0      ; Current element count
    brk_start dq 0       ; Pointer to beginning of array
    number dq 0     ; temp place for number
    buffer db 20 dup(0)  ; Buffer to convert string to number
    f db '/dev/urandom', 0 ; File for random numbers

section '.text' executable

; Important - some of the new methods used here are explained
; This is more for me to understand them as this is my first time using some of them
_start:
    ; Initializing program
    call initialize_memory

    ; Fill with random numbers
    call fill

    ; Adding new element to end of array
    mov rdi, 41
    call add_to_end

    ; Deleting element from start of array
    call remove_from_beginning

    ; Counting numbers that end with 1 in base 10 (i.e. 11, 21, 101 and NOT 3 (in base 2 it is 11))
    call count_numbers_ending_with_1
    call number_str
    call print_str
    call new_line

    ; Getting full list of odd numbers
    call get_odd_numbers_list

    ; Exit + freeing memory
    call exit_program

; Input - none
; Output - pointer to the beginning of the array
initialize_memory:

    ;syscall brk
    mov rax, 12
    xor rdi, rdi         ; not moving the pointer
    syscall

    mov [brk_start], rax ; saving current position (beginning of array)
    mov [array_ptr], rax ; saving current position (end of array)
    ret

; Input - number to add (rdi)
; Output - none
add_to_end:
    ; Saving the number
    push rdi

    ;brk syscall to accommodate new element
    mov rax, 12          
    mov rdi, [array_ptr]
    add rdi, 8           ; (+ 8 bytes for 1 number)
    syscall
    
    ; Changing some constants + putting the new number in its place
    mov [array_ptr], rax

    pop rdi
    mov [rax - 8], rdi
    inc qword [array_size]
    ret

; Input - none
; Output - none
remove_from_beginning:
    ; Check if empty
    cmp qword [array_size], 0
    je @f

    mov rsi, [brk_start]

    ; Moving left
    mov rdi, rsi         ; to
    add rsi, 8           ; from
    mov rcx, [array_size]
    dec rcx              ; we need only all but 1
    jz .clear_last       ; If rcx is 0 - just clear array

    ; Copying the array
    ;rep = repeat
    ;movsq = moves from one buffer to another (qwords)
    rep movsq                ; moves from rdi to rsi, then increments rdi, rsi by 8 and decrements rcx by 1 until 0

    ; Clearing last element before changing array size
    .clear_last:
        mov rsi, [array_ptr]
        sub rsi, 8
        mov qword [rsi], 0

    ; Decreasing array size (constant and the array itself)
    dec qword [array_size]

    mov rsi, [array_ptr]
    sub rsi, 8
    mov rax, 12
    syscall

    mov [array_ptr], rax

    @@:
    ret

;tbd - change to actually FILL, not create
; Input - none
; Output - none
fill:
    ;opening the urandom file
    mov rdi, f
    mov rax, 2
    mov rsi, 0o
    syscall
    cmp rax, 0
    jl @f
    mov r12, rax

    mov rcx, 5          ; Currently just adds 10 numbers
    .loop:
        ;current problem - here number_str SOMEHOW changes SOMETHING and breaks numbers
        ;maybe check other places where they are used - might help
        push rcx
        call random
        mov rdi, rax
        push rax
        call number_str
        call print_str
        call new_line
        pop rdi
        call add_to_end
        pop rcx
        loop .loop
    
    call new_line

    ;closing file
    mov rdi, r12
    mov rax, 3
    syscall
    @@:
    ret

; No input
; Output - the number (rax)
random:
    ;reading from urandom file. r12 - file descriptor
    xor rax, rax
    mov rdi, r12
    mov rsi, number
    mov rdx, 1
    syscall
    mov rax, [number]
    ret

; Input - none
; Output - numbers ending with 1 (rax)
count_numbers_ending_with_1:
    ; Initializing counter + testing array size
    xor rax, rax
    mov rcx, [array_size]
    ;test = logical AND for each bit. Only changes flags. Here it basically checks if rcx is 0
    test rcx, rcx
    jz .done
    
    mov rsi, [brk_start]

    ; rax - counter, rsi - place of current number
    .loop:
        push rax
        mov rax, [rsi]
        xor rdx, rdx
        mov rbx, 10
        div rbx
        pop rax
        cmp rdx, 1
        jne .next
    
        inc rax

        .next:
            add rsi, 8
            loop .loop

    .done:
        ret

; Input - none
; Output - none, but it prints a list
get_odd_numbers_list:
    ; Checking if array is empty
    mov rcx, [array_size]
    test rcx, rcx
    jz @f

    mov rsi, [brk_start]
    

    .loop:
        push rcx
        mov rdx, [rsi]
        test rdx, 1
        ;jz .next

        push rsi
        mov rax, rdx
        call number_str
        call print_str
        call new_line
        pop rsi

        .next:
            pop rcx
            add rsi, 8
            loop .loop

    @@:
    ret


; Завершение программы
exit_program:
    mov rax, 60          ; Системный вызов exit
    xor rdi, rdi         ; Код возврата 0
    syscall
    ret
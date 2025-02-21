format ELF64

;Comment for myself - currently my implementation of create_array breaks all of this code
;Idk how to fix - need to ask AI
public _start
section '.data' writable
    array_ptr dq 0       ; Pointer to end of array
    array_size dq 0      ; Current element count
    brk_start dq 0       ; Pointer to beginning of array
    number dq 0          ; Temp place for number
    buffer db 20 dup(0)  ; Buffer to convert string to number
    f db '/dev/urandom', 0 ; File for random numbers

section '.text' executable

; Important - some of the new methods used here are explained
; This is more for me to understand them as this is my first time using some of them
_start:
    ; Initializing program
    mov rdi, 5
    call create_array

    ; Fill with random numbers
    call fill

    ; Adding new element to end of array
    mov rdi, 41
    call add_to_end

    ; Deleting element from start of array
    ;call remove_from_beginning

    ; Counting numbers that end with 1 in base 10 (i.e. 11, 21, 101 and NOT 3 (in base 2 it is 11))
    call count_numbers_ending_with_1
    mov rdi, rax
    call print_number

    ; Getting full list of odd numbers
    call get_odd_numbers_list

    ; Exit + freeing memory
    call exit

; Input - number of elements (rdi)
; Output - pointer to the beginning of the array (rax)
create_array:

    push rdi
    push rdi
    ;syscall brk
    mov rax, 12
    xor rdi, rdi         ; not moving the pointer
    syscall

    mov [brk_start], rax ; saving current position (beginning of array)
    mov [array_ptr], rax ; saving current position (end of array)
    
    ;brk syscall to increase array size
    xor rax, rax
    pop rax
    mov rdi, [brk_start + rax * 8]
    mov rax, 12
    syscall
    
    ; Changing some constants + putting the new number in its place
    mov [array_ptr], rax
    pop rdi
    add qword [array_size], rdi
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
    mov rcx, [array_size]
    jz .clear_last       ; If rcx is 0 - just clear array

    ; Copying the array
    xor rcx, rcx
    .mloop:
        mov rax, [brk_start + rcx * 8 + 8]
        mov [brk_start + rcx *8], rax
        inc rcx
        cmp rcx, [array_size]
        jne .mloop

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

    xor rdx, rdx
    .loop:
        call random
        mov [brk_start + rdx * 8], rax
        mov rdi, rax
        call print_number
        add rdx, 1
        cmp rdx, [array_size]
        jne .loop
    
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
    push rdx
    ;reading from urandom file. r12 - file descriptor
    xor rax, rax
    mov rdi, r12
    mov rsi, number
    mov rdx, 8
    syscall
    mov rax, [number]
    pop rdx
    ret

; Input - none
; Output - numbers ending with 1 (rax)
count_numbers_ending_with_1:
    ; Initializing counter + testing array size
    xor rax, rax
    mov rcx, [array_size]
    mov rdi, rcx
    ;test = logical AND for each bit. Only changes flags. Here it basically checks if rcx is 0
    test rcx, rcx
    jz .done
    
    mov rsi, [brk_start]

    ; rax - counter, rsi - place of current number
    ;current problem - exits early and skips most of the numbers
    xor rcx, rcx
    .loop:
        cmp rcx, [array_size]
        je .done
        push rcx
        push rax
        mov rax, [brk_start + 8*rcx]
        xor rdx, rdx
        mov rbx, 10
        div rbx

        xor rax, rax
        pop rax
        cmp rdx, 1
        jne .next
        inc rax
        .next:
        pop rcx
        inc rcx
        
        jmp .loop
            

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

        mov rdi, rdx
        call print_number

        .next:
            pop rcx
            add rsi, 8
            loop .loop

    @@:
    ret

;The function makes new line
new_line:
   push rax
   push rdi
   push rsi
   push rdx
   push rcx
   mov rax, 0xA
   push rax
   mov rdi, 1
   mov rsi, rsp
   mov rdx, 1
   mov rax, 1
   syscall
   pop rax
   pop rcx
   pop rdx
   pop rsi
   pop rdi
   pop rax
   ret

; Converts number to string and prints it. Done like this because number_str for some reason breaks my program
; Input - number (rdi)
; Output - none, but prints number
print_number:
    push rdi
    push rsi
    push rax
    push rdx
    mov rax, rdi         ; Input
    lea rdi, [buffer + 19] ; End of buffer
    mov byte [rdi], 0    ; Last symbol is NULL
    mov rcx, 10          ; Base 10
    .convert_loop:
        dec rdi
        xor rdx, rdx
        div rcx
        add dl, '0'
        mov [rdi], dl
        test rax, rax        ; testing for 0
        jnz .convert_loop

    ; Вывод строки
    mov rsi, rdi         ; Pointer to the beginning of string
    mov rdx, buffer + 20 ; End of buffer
    sub rdx, rsi         ; String length
    mov rax, 1           ; syscall write
    mov rdi, 1           ; standard output
    syscall

    call new_line
    pop rdx
    pop rax
    pop rsi
    pop rdi
    ret

; Завершение программы
exit:
    ;freeing memory
    mov rdi, [brk_start]
    mov rax, 12
    syscall
    
    ;syscall exit
    mov rax, 60
    xor rdi, rdi
    syscall
    ret
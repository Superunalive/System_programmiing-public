format ELF64

public _start
section '.data' writable
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
    mov rdi, 20
    call create_array

    ; Fill with random numbers
    call fill

    ; Adding new element to end of array
    mov rdi, 41
    call add_to_end

    ; Deleting element from start of array
    call remove_from_beginning

    ; Counting numbers that end with 1 in base 10 (i.e. 11, 21, 101 and NOT 3 (in base 2 it is 11))
    call count_numbers_ending_with_1
    mov rdi, rax
    call print_number

    ; Getting full list of odd numbers
    call get_odd_numbers_list

    ; Exit + freeing memory
    call exit

; Input - none
; Output - pointer to the beginning of the array
create_array:
    mov [number], rdi
    ;syscall brk
    mov rax, 12
    xor rdi, rdi         ; not moving the pointer
    syscall

    mov [brk_start], rax ; saving current position (beginning of array)

    mov rax, 12
    mov rbx, [number]
    mov [array_size], rbx
    shl rbx, 3
    mov rdi, [brk_start]
    add rdi, rbx
    syscall

    xor rax, rax
    mov rax, [brk_start]

    ret

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

    mov rcx, [array_size]
    mov r13, [brk_start]
    .loop:
        push rcx
        call random
        mov qword [r13], rax
        mov rdi, [r13]
        call print_number
        add r13, 8
        pop rcx
        loop .loop
    
    call new_line

    ;closing file
    mov rdi, r12
    mov rax, 3
    syscall

    xor r12, r12
    @@:
    ret

; No input
; Output - the number (rax)
;Remember to return the number of bytes to 8!
random:
    ;reading from urandom file. r12 - file descriptor
    xor rax, rax
    mov rdi, r12
    mov rsi, number
    mov rdx, 1
    syscall
    mov rax, [number]
    ret

; Input - number to add (rdi)
; Output - none
add_to_end:
    ; Saving the number
    mov [number], rdi

    ;brk syscall to accommodate new element
    mov rcx, [array_size]
    mov rax, 12          
    mov rdi, [brk_start]
    inc rcx              ; (+ 8 bytes for 1 number)
    mov [array_size], rcx
    shl rcx, 8
    add rdi, rcx
    add rdi, 8
    syscall
    
    ; Changing some constants + putting the new number in its place
    mov rbx, [number]
    mov rcx, [array_size]
    dec rcx
    mov r12, [brk_start]
    shl rcx, 3
    add r12, rcx
    mov [r12], rbx

    ret

; Input - none
; Output - none
remove_from_beginning:
    ; Check if empty
    cmp qword [array_size], 0
    je @f

    mov r12, [brk_start]

    ; Moving left
    mov r13, r12         ; to
    add r13, 8           ; from
    mov rcx, [array_size]
    dec rcx              ; we need only all but 1
    jz .clear_last       ; If rcx is 0 - just clear array

    ; Copying the array
    .copy_loop:
        mov rax, [r13]
        mov [r12], rax
        add r12, 8
        add r13, 8
        loop .copy_loop

    ; Clearing last element before changing array size
    .clear_last:
        mov rcx, [array_size]
        dec rcx
        mov [array_size], rcx
        mov qword [r13], 0

    ; Decreasing array size (constant and the array itself)

    mov rsi, r12
    mov rax, 12
    syscall

    @@:
    ret

; Input - none
; Output - numbers ending with 1 (rax)
count_numbers_ending_with_1:
    ; Initializing counter + testing array size
    mov rcx, [array_size]
    ;test = logical AND for each bit. Only changes flags. Here it basically checks if rcx is 0
    test rcx, rcx
    jz .done
    
    ; r12 - counter, r13 - place of current number
    xor r12, r12
    mov r13, [brk_start]
    .loop:
        mov qword rax, [r13]
        xor rdx, rdx
        mov rbx, 10
        div rbx
        cmp rdx, 1
        jne .next
    
        inc r12

        .next:
            add r13, 8
            loop .loop

    .done:
        mov rax, r12
        ret

; Input - none
; Output - none, but it prints a list
get_odd_numbers_list:
    ; Checking if array is empty
    mov rcx, [array_size]
    test rcx, rcx
    jz @f

    mov r12, [brk_start]

    .loop:
        push rcx
        mov rdx, [r12]
        test rdx, 1
        ;jz .next

        mov rdi, rdx
        call print_number

        .next:
            pop rcx
            add r12, 8
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
    xor rcx, rcx
    .l:
        mov [buffer + rcx], 0
        inc rcx
        cmp rcx, 20
        jne .l
    ret

; Завершение программы
exit:
    mov rax, 60          ; Системный вызов exit
    xor rdi, rdi         ; Код возврата 0
    syscall
    ret


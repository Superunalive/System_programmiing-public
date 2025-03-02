format ELF64

public create_array
public fill
public add_to_end
public remove_from_beginning
public count_numbers_ending_with_1
public sum_of_numbers
public get_odd_numbers_list
public get_even_numbers_list
section '.data' writable
    f db '/dev/urandom', 0 ; File for random numbers
    temp dq 0
    buffer rb 20  ; Buffer to convert string to number

section '.text' executable

; Input - size of array (rdi)
; Output - pointer to the beginning of the array
create_array:
    mov r12, rdi
    ;syscall brk
    mov rax, 12
    xor rdi, rdi         ; not moving the pointer
    syscall

    mov r13, rax ; saving current position (beginning of array)
    cmp r12, 0
    je @f

    mov rax, 12
    mov rbx, r12
    shl rbx, 3
    mov rdi, r13
    add rdi, rbx
    syscall

    @@:
    xor rax, rax
    mov rax, r13

    ret

; Input - pointer to brk (rdi), size (rsi)
; Output - none
fill:
    cmp rsi, 0
    je @f
    mov r13, rdi
    push rsi
    ;opening the urandom file
    mov rdi, f
    mov rax, 2
    mov rsi, 0o
    syscall
    cmp rax, 0
    jl @f
    mov r12, rax

    pop rcx
    .loop:
        push rcx
        call random
        mov [r13], rax
        add r13, 8
        pop rcx
        loop .loop
    
    ;closing file
    mov rdi, r12
    mov rax, 3
    syscall

    xor r12, r12
    xor r13, r13
    @@:
    ret

; No input
; Output - the number (rax)
;Remember to return the number of bytes to 8!
random:
    ;reading from urandom file. r12 - file descriptor
    xor rax, rax
    mov rdi, r12
    mov rsi, temp
    mov rdx, 1
    syscall
    mov rax, [temp]
    ret

; Input - pointer to brk (rdi), pointer to size (rsi), number to add (rdx)
; Output - none
add_to_end:
    ; Saving the number and the pointer
    mov [temp], rdx
    mov r13, rsi
    mov r12, rdi

    ;brk syscall to accommodate new element
    mov rcx, [rsi]
    mov rax, 12
    inc rcx              ; (+ 8 bytes for 1 number)
    mov [rsi], rcx
    shl rcx, 8
    add rdi, rcx
    syscall
    
    ; Changing some constants + putting the new number in its place
    mov rbx, [temp]
    mov rcx, [rsi]
    dec rcx
    shl rcx, 3
    add r12, rcx
    mov [r12], rbx

    mov rax, [r13]

    ret

; Input - pointer to brk (rdi), pointer to size (rsi)
; Output - none
remove_from_beginning:
    ; Check if empty
    cmp qword [rsi], 0
    je @f

    mov r12, rdi
    mov r13, rsi

    ; Moving left
    mov r14, r12         ; to
    add r14, 8           ; from
    mov rcx, [r13]
    dec rcx              ; we need only all but 1
    jz .clear_last       ; If rcx is 0 - just clear array

    ; Copying the array
    .copy_loop:
        mov rax, [r14]
        mov [r12], rax
        add r12, 8
        add r14, 8
        loop .copy_loop

    ; Clearing last element before changing array size
    .clear_last:
        mov rcx, [r13]
        dec rcx
        mov [r13], rcx
        mov qword [r14], 0

    ; Decreasing array size (constant and the array itself)

    mov rdi, r12
    mov rax, 12
    syscall

    xor rax, rax
    mov rax, [r13]
    @@:
    ret

; Input - pointer to brk (rdi), size (rsi)
; Output - numbers ending with 1 (rax)
count_numbers_ending_with_1:
    ; Initializing counter + testing array size
    mov rcx, rsi
    ;test = logical AND for each bit. Only changes flags. Here it basically checks if rcx is 0
    test rcx, rcx
    jz .done
    
    ; r12 - counter, r13 - place of current number
    xor r12, r12
    mov r13, rdi
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


; Input - pointer to brk (rdi), size (rsi)
; Output - sum (rax)
sum_of_numbers:
    ; Initializing counter + testing array size
    mov rcx, rsi
    test rcx, rcx
    jz .sdone
    
    ; r12 - counter, r13 - place of current number
    xor r12, r12
    mov r13, rdi
    .sloop:
        mov qword rax, [r13]
        add r12, rax
        add r13, 8
        loop .sloop

    .sdone:
        mov rax, r12
        ret


; Input - pointer to array (rdi), size (rsi)
; Output - none, but it prints a list
get_odd_numbers_list:
    ; Checking if array is empty
    mov rcx, rsi
    test rcx, rcx
    jz @f

    mov r12, rdi

    .loop:
        push rcx
        mov rdx, [r12]
        test rdx, 1
        jz .next

        mov rdi, rdx
        call print_number

        .next:
            pop rcx
            add r12, 8
            loop .loop

    @@:
    ret


; Input - pointer to array (rdi), size (rsi)
; Output - none, but it prints a list
get_even_numbers_list:
    ; Checking if array is empty
    mov rcx, rsi
    test rcx, rcx
    jz @f

    mov r12, rdi

    .loop:
        push rcx
        mov rdx, [r12]
        test rdx, 1
        jnz .next

        mov rdi, rdx
        call print_number

        .next:
            pop rcx
            add r12, 8
            loop .loop

    @@:
    ret

; Converts number to string and prints it. Done like this because number_str for some reason breaks my program
; Input - number (rdi)
; Output - none, but prints number
print_number:
    push rbx
    sub rsp, 20
    mov rbx, rsp

    mov rax, rdi         ; Input
    lea rdi, [rbx + 19] ; End of buffer
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
    mov rdx, rbx         ; End of buffer
    add rdx, 20
    sub rdx, rsi         ; String length
    mov rax, 1           ; syscall write
    mov rdi, 1           ; standard output
    syscall

    call new_line
    xor rcx, rcx
    .clear_loop:
        mov byte [rbx + rcx], 0
        inc rcx
        cmp rcx, 20
        jne .clear_loop 
    add rsp, 20 
    pop rbx  
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

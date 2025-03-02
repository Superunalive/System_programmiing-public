format elf64

public _start

extrn printf
extrn scanf
extrn atof

section '.data' writable
    input db "%lf", 0
    ftype db "member = %-15.10lf, power = %-15.10lf", 0xa, 0  ; Отладочный вывод
    output db "%-15.10lf %-10d %-15.10lf %-15.10lf", 0xa, 0
    header db "x           passes       lside        rside", 0xa, 0
    const_1 dq 2.0
    const dq 4.0
    partial dq 0.05
    x_power_4 dq 0.0  ; Для хранения x^4

section '.bss' writable
    atan rq 1
    ln rq 1
    member rq 1
    lside rq 1 ; the equation
    rside rq 1 ; the approx.
    precision rq 1 ; accuracy
    diff rq 1 ; temp for |lside - rside|
    number dq 0.3 ; x value
    count dq 1 ; amount of passes
    power rq 1 ; for (4n+1)
    cntr dq 0

section '.text' executable
_start:
    ; ask for precision
    mov rdi, input
    mov rsi, precision
    movq xmm0, rsi
    mov rax, 1
    call scanf

    ; printing top row
    mov rdi, header
    call printf

    ; number = x
    .loop:
        finit
        fld [number]
        fld1
        fcomip st0, st1
        jle .end
        cmp [cntr], 6
        jae .end
        
        ; left side
        ; atan(x)
        finit
        fld [number]
        fld1
        fpatan
        fstp [atan]

        ; atan(x)/2
        finit
        fld [const_1]
        fld [atan]
        fdiv st0, st1
        fstp [atan]

        ; 1+x
        finit
        fld [number]
        fld1
        fadd st0, st1
        fstp [ln]
        
        ; 1-x
        finit
        fld [number]
        fld1
        fsub st0, st1
        ; (1+x)/(1-x)
        fld [ln]
        fdiv st0, st1
        fstp [ln]

        ; ln((1+x)/(1-x))
        finit
        fldln2
        fld [ln]
        fyl2x
        fstp [ln]

        ; ln((1+x)/(1-x))/4
        finit
        fld [const]
        fld [ln]
        fdiv st0, st1
        fstp [ln]

        ; complete left side
        finit
        fld [atan]
        fld [ln]
        fadd st0, st1
        fstp [lside]

        ; right side, first member = x
        mov qword [count], 0
        finit
        fld [number]
        fstp [rside]
        fld [number]
        fstp [member]

        ; precompute x^4
        finit
        fld [number]
        fld [number]
        fmul st0, st1
        fld [number]
        fmul st0, st1
        fld [number]
        fmul st0, st1
        fstp [x_power_4]

        .loop2:
            ; check if qualifies
            finit
            fld [rside]
            fld [lside]
            fsub st0, st1
            fabs
            fstp [diff]

            finit
            fld [diff]
            fld [precision]
            fcomip st0, st1
            ja .next

            ; if not enough - get one more
            inc qword [count]

            ; calculate next member: member * x^4
            finit
            fld [member]
            fld [x_power_4]
            fmul st0, st1
            fstp [member]

            ; calculate power = 4n+1
            finit
            fild qword [count]
            fld [const]
            fmul st0, st1
            fld1
            fadd st0, st1
            fstp [power]

            ; rside += member / (4n+1)
            finit
            fld [member]
            fld [power]
            fdivp st1, st0
            fld [rside]
            fadd st0, st1
            fstp [rside]

            cmp [count], 10
            jae .next
            jmp .loop2
  
        .next:
        ; printing row
        mov rdi, output
        movq xmm0, [number]
        mov rsi, [count]
        movq xmm1, [lside]
        movq xmm2, [rside]
        mov rax, 3
        call printf

        finit
        fld [partial]
        fld [number]
        fadd st0, st1
        fstp [number]
        
        inc [cntr]
        jmp .loop

    .end:
        mov rax, 60
        xor rdi, rdi
        syscall
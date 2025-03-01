format elf64

public _start

;ld task_2.o -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2
extrn printf
extrn scanf
extrn atof

section '.data' writable
input db "%lf", 0
ftype db "%lf", 0xa, 0
output db "%-10lf%-10d%-10lf%-10lf", 0xa, 0
header db "x   passes       lside      rside", 0xa, 0
const_1 dq 2.0
const dq 4.0
partial dq 0.1

section '.bss' writable
atan rq 1
ln rq 1
member rq 1
lside rq 1 ;the equation
rside rq 1 ;the approx.
precision rq 1 ;accuracy
diff rq 1 ;temp for |lside - rside|
number dq 0.0 ;x value
count dq 1 ;amount of passes

section '.text' executable
_start:

    ;ask for precision - basically max difference between two numbers.
    mov rdi, input
    mov rsi, precision
    movq xmm0, rsi
    mov rax, 1
    call scanf

    ;printing top row
    mov rdi, header
    call printf

    ;number = x
    .loop:
        finit
        fld [number]
        fld1
        fcomip st0, st1
        jle .end
        
        ;left side
        ;atan(x)
        finit
        fld qword [number]
        fld1
        fpatan
        fstp qword [atan]

        ;atan(x)/2
        finit
        fld qword [const_1]
        fld qword [atan]
        fdiv st0, st1
        fstp qword [atan]

        ;1+x
        finit
        fld qword [number]
        fld1
        fadd st0, st1
        fstp qword [ln]
        
        ;1-x
        finit
        fld qword [number]
        fld1
        fsub st1, st0
        ;1+x/1-x
        fld qword [ln]
        fdiv st0, st1
        fstp qword [ln]

        ;ln(1+x/1-x)
        finit
        fldln2
        fld qword [ln]
        fyl2x
        fstp qword [ln]

        ;ln(1+x/1-x)/4
        finit
        fld qword [const]
        fld qword [ln]
        fdiv st0, st1
        fstp qword [ln]

        ;complete left side
        finit
        fld qword [atan]
        fld qword [ln]
        fadd st0, st1
        fstp qword [lside]

        ;right side, first member = x
        finit
        fld1
        fld1
        fsub st0, st1
        fstp qword [count]
        fld qword [number]
        fstp qword [rside]
        fld qword [number]
        fstp qword [member]
        .loop2:
            ;check if qualifies
            finit
            fld qword [rside]
            fld qword [lside]
            fsub st0, st1
            fabs
            fstp qword [diff]

            finit
            fld qword [diff]
            fld qword [precision]
            fcomip st0, st1
            ja .next

        ;if not enough - get one more
        inc qword [count]

        ;4n + 1, n = count   
        finit
        fild qword [count]
        fld qword [const_1]
        fmul st0, st1
        fld1
        fadd st0, st1
        fstp qword [atan]

        ;next (x^(4n+1)), meaning member *x four times
        finit
        fld qword [member]
        fld qword [number]
        fmul st1, st0
        fld qword [number]
        fmul st1, st0
        fld qword [number]
        fmul st1, st0
        fld qword [number]
        fmul st1, st0
        fstp qword [member]

        ;rside - adding member/(4n+1)
        finit
        fld qword [member]
        fld qword [atan]
        fdiv st1, st0
        fld qword [rside]
        fadd st1, st0
        fstp qword [rside]

        jmp .loop2
  
        .next:
        ;printing row
        mov rdi, output
        mov rsi, [number]
        mov rdx, [count]
        mov rax, 2
        movq xmm0, [atan]
        movq xmm1, [rside]
        call printf

        finit
        fld qword [partial]
        fld qword [number]
        fadd st0, st1
        fstp qword [number]
        
        jmp .loop

    .end:
        mov rax, 60
        syscall
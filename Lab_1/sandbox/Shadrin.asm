format ELF
public _start
messg db "Shadrin", 0xA, "Mikhail", 0xA, "Konstantinovich", 0xA, 0

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, messg
    mov edx, 33
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80

section .asm

global insb
global insw
global outb
global outw

insb:
    push ebp;
    mov ebp, esp;
    xor eax, eax;
    mov edx, [ebp + 8]; take port from C
    in al, dx; EAX is always to return value
    pop ebp;
    ret;

insw:
    push ebp;
    mov ebp, esp;
    xor eax, eax;
    mov edx, [ebp + 8]; take port from C
    in ax, dx; EAX is always to return value
    pop ebp;
    ret;

outb:
    push ebp;
    mov ebp, esp;
    mov eax, [ebp+12]; C args!
    mov edx, [ebp+8]; C Args!
    out dx, al
    pop ebp;
    ret;

outw:
    push ebp;
    mov ebp, esp;
    mov eax, [ebp+12]; C args!
    mov edx, [ebp+8]; C Args!
    out dx, ax
    pop ebp;
    ret;

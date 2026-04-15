section .asm

extern int21h_handler
extern no_interrupt_handler
global idt_load
global int21h
global no_interrupt
global enable_interrupts
global disable_interrupts
enable_interrupts:
    sti
    ret
disable_interrupts:
    cli
    ret
idt_load:
    push ebp;
    mov ebp, esp;
    mov ebx, [ebp+8]; the value pushed onto the stack by the C code, ebp+4 -> return address
    lidt [ebx]; load the interrupt descriptor table
    pop ebp;
    ret

int21h:
    cli     ; clear interrupts
    pushad  ; push all GP Registers
    call int21h_handler
    popad   ; pop all GP registers
    sti     ; enable interrutps
    iret; returning from an interrupt

no_interrupt:
    cli     ; clear interrupts
    pushad  ; push all GP Registers
    call no_interrupt_handler
    popad   ; pop all GP registers
    sti     ; enable interrutps
    iret; returning from an interrupt

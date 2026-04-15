#include "idt.h"
#include "config.h"
#include "memory/memory.h"
#include "kernel.h"
#include "io/io.h"
struct idt_desc idt_descriptors[PEACHOS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void int21h(); // This has the iret instruction
extern void idt_load(struct idtr_desc* ptr); // The asm routine to lidt
extern void no_interrupt();
void int21h_handler()
{
    print("Keyboard pressed!\n");
    outb(0x20, 0x20); // Sending out the ACK for the interrupt
}

void no_interrupt_handler()
{
    outb(0x20, 0x20);
}

void idt_zero() // this is kind of not ideal because it does not have an iret instruction
{
    print("Divide by zero error\n");
}

void idt_set(int interrupt_no, void* address)
{
    struct idt_desc* desc = &idt_descriptors[interrupt_no];
    desc->offset_1 = (uint32_t) address & 0x0000ffff; // lower 16 bits from offset
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0x00;
    desc->type_attr = 0xEE; //32 bit interrupt gate for lower 4 bits, (Storage + Min Privilege Level + Present) for high 4
    desc->offset_2 = (uint32_t) address >> 16; // upper 16 bits from offset
}

void idt_init()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t)idt_descriptors;

    for(int i = 0; i<PEACHOS_TOTAL_INTERRUPTS; i++)
    {
        idt_set(i, no_interrupt);
    }
    idt_set(0, idt_zero);
    idt_set(0x21, int21h);

    idt_load(&idtr_descriptor); // sends the idtr_descriptor's address having idt_descriptors' info
}

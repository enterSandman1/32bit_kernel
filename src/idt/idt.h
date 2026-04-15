#ifndef IDT_H
#define IDT_H
#include <stdint.h>
struct idt_desc
{
    uint16_t offset_1; // Bits 0-15
    uint16_t selector; // Selector that's in our GDT
    uint8_t zero; // Does nothing
    uint8_t type_attr; // Descriptor type & attributes
    uint16_t offset_2; // Bits 16-31
}__attribute__((packed)); // The byte order must align precisely in memory

struct idtr_desc
{
    uint16_t limit; // size of Descriptor table - 1
    uint32_t base; // base address of start of interrupt descriptor table
}__attribute__((packed)); // The byte order must align precisely in memory

void idt_init();
void enable_interrupts(); // STI after init
void disable_interrupts(); // CLI
#endif

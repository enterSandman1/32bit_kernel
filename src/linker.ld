ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 1M; /*load kernel at 1M in memory (origin of kernel)*/
    .text : ALIGN(4096)
    {
        *(.text)
    }

    .rodata :   ALIGN(4096)
    {
        *(.rodata)
    }

    .data : ALIGN(4096)
    {
        *(.data)
    }

    .bss :  ALIGN(4096)
    {
        *(COMMON)
        *(.bss)
    }

    .asm : ALIGN(4096) /*This has to be at the back-end of this file because if put at front would misalign C's funtions that'll be a part of text */
    {
        *(.asm)
    }
}

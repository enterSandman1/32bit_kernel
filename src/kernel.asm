[BITS 32]
CODE_SEG equ 0x08;
DATA_SEG equ 0x10;

extern kernel_main

global _start
_start:
  mov ax, DATA_SEG;
  mov ds, ax;
  mov ss, ax;
  mov es, ax;
  mov sp, ax;
  mov fs, ax;
  mov gs, ax;
  mov ebp, 0x00200000;
  mov esp, ebp;

  in al, 0x92 ; enable the fast a20 line for 21st bit on the address lines
  or al, 2    ;
  out 0x92, al;

  ; Remap the master PIC
  mov al, 00010001b;
  out 0x20, al; Tell Master PIC

  mov al, 0x20; Interrupt 0x20 is where master ISR should start
  out 0x21, al;

  mov al, 00000001b; Enable x86 mode
  out 0x21, al; remapped

  call kernel_main
  jmp $;

times 512-($-$$) db 0; Alignment with C functions!

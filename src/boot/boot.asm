ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

jmp short start;
nop;

; FAT16 Header
OEMIdentifier     db 'PEACHOS ' ; 8 bytes
BytesPerSector    dw 0x200      ; 512 bytes per sector
SectorsPerCluster db 0x80       ;
ReservedSectors   dw 200        ; For the kernel
FATCopies         db 0x02       ; 2 copies
RootDirEntries    dw 0x40       ;
NumSectors        dw 0x00       ; not using this
MediaType         db 0xF8       ;
SectorsPerFat     dw 0x100      ;
SectorsPerTrack   dw 0x20       ;
NumberOfHeads     dw 0x40       ;
HiddenSectors     dd 0x00       ;
SectorsBig        dd 0x773594   ;

; Extended BPB (Dos 4.0)
DriveNumber       db 0x80       ;
WinNTBit          db 0x00       ;
Signature         db 0x29       ;
VolumeID          dd 0xD105     ;
VolumeIDString    dw 'PEACHOS BOO' ; 11 bytes exactly!
SystemIDString    dw 'FAT16   ' ; 8 byes

start:
  jmp 0:step2; go to real code


step2:
  cli; clear interrupts
  mov ax, 0; segment
  mov ds, ax; Can't directly move an immediate
  mov es, ax;
  mov ax, 0;
  mov ss, ax;
  mov sp, 0x7c00; stack pointer
  sti; enable interrupts
  
.load_protected:
  cli
  lgdt[gdt_descriptor]  ; load GDT table
  mov eax, cr0          ; control register 0 
  or eax, 0x1           ;
  mov cr0, eax          ;
  jmp CODE_SEG:load32    ; CS = CODE_SEG, far jump to load32
; GDT
gdt_start:
gdt_null:
  dd 0x0;
  dd 0x0;

  ;offset 0x8
gdt_code:   ;CS should point to this 
  dw 0xffff ; Segment limit first 15bits
  dw 0      ; Base first 0-15 bits
  db 0      ; Base 16-23 bits
  db 0x9a   ; Access byte
  db 11001111b; High & Low 4 bit flags
  db 0;     Base 24-31 bits 
  
; offset 0x10
gdt_data:   ; DS, SS, ES, FS, GS
  dw 0xffff ;
  dw 0      ;
  db 0      ;
  db 0x92   ;
  db 11001111b;
  db 0      ;

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1; standard gdt size calculation
  dd gdt_start              ; address of the gdt (start of gdt)

[BITS 32]
load32:
  mov eax, 1; starting sector to load from
  mov ecx, 100; number of sectors to load
  mov edi, 0x0100000; 1MB of sectors
  call ata_lba_read; load the kernel
  jmp CODE_SEG:0x0100000; jump to kernel

ata_lba_read:
  ;send out higher 8 bits of lba
  mov ebx, eax; backup lba
  shr eax, 24; send highest 8 bits to controller, bits 25-32
  or eax, 0xE0; master drive
  mov dx, 0x1f6; ports to write the 8 bits to
  out dx, al; send out the 8 bits from ax onto the port no. stored in dx

  ;send out number of sectors
  mov eax, ecx; number of sectors
  mov dx, 0x1f2; port to send number of sectors to
  out dx, al; send out to port

  ;send out more bits
  mov eax, ebx; restore backup
  mov dx, 0x1f3;
  out dx, al; bits 1-8

  ;send out more
  mov dx, 0x1f4; port
  mov eax, ebx; restore
  shr eax, 8; the 9-16 bits
  out dx, al;

  ;send out remaining bits
  mov dx, 0x1f5; port
  mov eax, ebx; restore
  shr eax, 16; 17-24
  out dx, al; send out

  mov dx, 0x1f7
  mov al, 0x20;
  out dx, al;

  ;read all sectors
.next_sector:
  push ecx

.try_again:
  mov dx, 0x1f7;
  in al, dx; bring it in
  test al, 8; test for data
  jz .try_again; wait for data to arrive

  ; read 256 words at a time
  mov ecx, 256; 512 bytes
  mov dx, 0x1f0; port to read from
  rep insw; input word from I/O port in DX into memory location at ES:EDI, go to line 68 for more clarity
  pop ecx;
  loop .next_sector; read our sectors repeatedly, whilst decrementing number of sectors to read

  ret

  times 510 - ($ - $$) db 0; pad 0s till end f sector
  dw 0xAA55; BOOT Signature 

#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"
#include "disk/disk.h"
#include "fs/pparser.h"
#include "string/string.h"
#include "disk/streamer.h"
uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char c, char color)
{
    return (color << 8) | c;
}

void terminal_put_char(int x, int y, char c, int color)
{
    video_mem[(y * VGA_WIDTH + x)] = terminal_make_char(c, color); // Equation to convert 2D grid to 1D idx
}

void terminal_write_char(char c, int color)
{
    if(c == '\n') // apparently I have to handle this because Video Mem doesn't
    {
        terminal_row++;
        terminal_col = 0;
        return;
    }
    terminal_put_char(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if(terminal_col >= VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row++;
    }
}

void print(const char* str)
{
    size_t len = strlen(str);
    for(int i = 0; i<len; i++)
    {
        terminal_write_char(str[i], 15);
    }
}

void terminal_initialize()
{
    video_mem = (uint16_t*)(0xB8000);
    terminal_row = 0;
    terminal_col = 0;
    for(int y = 0; y<VGA_HEIGHT; y++)
    {
        for(int x = 0; x < VGA_WIDTH; x++)
        {
            terminal_put_char(x, y, ' ', 0);
        }
    }
}

struct paging_4gb_chunk* kernel_chunk = 0;
void kernel_main()
{
    terminal_initialize(); // blank out display
    // video_mem[0] = terminal_make_char('B', 15); // Endian-ness
    char* str = "No! This is Patrick!";
    print(str);
    kheap_init();
    disk_search_and_init();
    idt_init(); // initialise the IDT
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITEABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);
    paging_switch(paging_4gb_chunk_get_directory(kernel_chunk));
    enable_paging(); // Enable paging now

    enable_interrupts();

    struct disk_stream* stream = diskstreamer_new(0);
    diskstreamer_seek(stream, 0x201);
    unsigned char c = 0;
    diskstreamer_read(stream, &c, 1);
    while(1) {}
}

#include "streamer.h"
#include "memory/heap/kheap.h"
#include "config.h"
struct disk_stream* diskstreamer_new(int disk_id)
{
    struct disk* disk = disk_get(disk_id);
    if(!disk)
        return 0;
    struct disk_stream* streamer = kzalloc(sizeof(struct disk_stream));
    streamer-> pos = 0;
    streamer->disk = disk;
    return streamer;
}

int diskstreamer_seek(struct disk_stream* stream, int pos)
{
    stream->pos = pos;
    return 0;
}

int diskstreamer_read(struct disk_stream* stream, void* out, int total)
{
    int sector = stream->pos / PEACHOS_SECTOR_SIZE;
    int offset = stream->pos % PEACHOS_SECTOR_SIZE;
    char buf[PEACHOS_SECTOR_SIZE];
    int res = disk_read_block(stream->disk, sector, 1 , buf);
    if(res < 0)
        goto out;

    int total_to_read;
    if(offset + total > PEACHOS_SECTOR_SIZE)
        total_to_read = PEACHOS_SECTOR_SIZE - offset;
    else
        total_to_read = total;
    for(int i = 0; i < total_to_read; i++)
        *(char*)out++ = buf[offset + i];

    stream->pos += total_to_read; // adjust the stream
    total -= total_to_read;
    if(total > 0)
        res = diskstreamer_read(stream, out, total);
out:
    return res;
}

void diskstreamer_close(struct disk_stream* stream)
{
    kfree(stream);
}

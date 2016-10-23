#include "type.h"
#include "x86.h"
#include "elf.h"

#define SECTSIZE 512
static void
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}

void
readsect(void *dst, uint offset)
{
	// Issue command.
	waitdisk();
	outb(0x1F2, 1);   // count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

	// Read data.
	waitdisk();
	insl(0x1F0, dst, SECTSIZE/4);
}

//read count bytes from offset in files imag to the pa
void readseg(uint pa,uint offset,uint count)
{
	uint end=pa+count;
	pa -= (offset%SECTSIZE);
	
	offset = offset/SECTSIZE +1;
	for(;pa<end;pa+=SECTSIZE,offset++)
		readsect((void *)pa,offset);
}

void bootmain()
{
	struct elfhdr 	*elf;
	struct prohdr	*pdr,*ph;
	elf	=(struct elfhdr*)0x10000;
	//first read 1st page to the 0x10000
	readseg((uint)elf,0,4096);
	//check it whether is a elf format
	if(elf->ident !=MAGIC_NUM)
		return;
	pdr=(struct prohdr*)(elf + elf->phoff);
	ph=pdr;
	for(;pdr < ph+elf->phnum;pdr++)
	{
		readseg(pdr->vaddr&0xFFFFFF,pdr->offset,pdr->memsz);
	}
}









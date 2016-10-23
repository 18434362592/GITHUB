#include "type.h"
#define MAGIC_NUM	0x464c457fU //magic number

struct elfhdr{
	uint	ident;
	uchar 	elf[12];
	ushort	type;
	ushort 	machine;
	uint 	version;
	uint 	entry;
	uint 	phoff;		//This member holds the program header table's file offset in bytes
	uint 	shoff;
	uint 	flags;
	ushort	ehsize;
	ushort	phentsize;	//This member holds the size in bytes of one entry in the file's program header table
	ushort	phnum;		//This member holds the number of entries in the program header table
	ushort 	shentsize;
	ushort 	shnum;
	ushort	shstrndx;
};


struct prohdr{
	uint	type;
	uint 	offset;		//offset from the beginning of the file at which the first byte of the segment resides
	uint 	vaddr;		
	uint 	paddr;
	uint 	filesz;		//file size in bytes in the file image
	uint	memsz;		//file size in bytes in the memory image
	uint 	flags;		
	uint 	align;
};

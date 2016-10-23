
obj/bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
#include "asm.h"
.globl start
start:
.code16
	cli
    7c00:	fa                   	cli    
	xorw	%ax,%ax
    7c01:	31 c0                	xor    %eax,%eax
	movw	%ax,%ds
    7c03:	8e d8                	mov    %eax,%ds
	movw 	%ax,%es
    7c05:	8e c0                	mov    %eax,%es
	movw	%ax,%ss
    7c07:	8e d0                	mov    %eax,%ss

00007c09 <seta20.1>:
		
	#enable A20
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c09:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c0b:	a8 02                	test   $0x2,%al
    jnz seta20.1
    7c0d:	75 fa                	jne    7c09 <seta20.1>

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    7c0f:	b0 d1                	mov    $0xd1,%al
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port
    7c11:	e6 64                	out    %al,$0x64

00007c13 <seta20.2>:

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    7c13:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7c15:	a8 02                	test   $0x2,%al
    jnz seta20.2
    7c17:	75 fa                	jne    7c13 <seta20.2>

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    7c19:	b0 df                	mov    $0xdf,%al
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
    7c1b:	e6 60                	out    %al,$0x60
	
	#lgdt gdtdesc
	lgdt 	gdtdesc
    7c1d:	0f 01 16             	lgdtl  (%esi)
    7c20:	68 7c 0f 20 c0       	push   $0xc0200f7c
	#switch from real to protected mode
	movl	%cr0,%eax
	orl		$CR0_PE,%eax
    7c25:	66 83 c8 01          	or     $0x1,%ax
	movl 	%eax,%cr0
    7c29:	0f 22 c0             	mov    %eax,%cr0
		
	ljmp 	$SEG_KCODE,$start32
    7c2c:	ea                   	.byte 0xea
    7c2d:	31 7c 08 00          	xor    %edi,0x0(%eax,%ecx,1)

00007c31 <start32>:
		
.globl start32
start32:
.code32
	#set up the protected-mode data segment registers
	movw 	$SEG_KDATA,%ax
    7c31:	66 b8 10 00          	mov    $0x10,%ax
	movw 	%ax,%ds
    7c35:	8e d8                	mov    %eax,%ds
	movw 	%ax,%es
    7c37:	8e c0                	mov    %eax,%es
	movw	%ax,%fs
    7c39:	8e e0                	mov    %eax,%fs
	movw	%ax,%gs
    7c3b:	8e e8                	mov    %eax,%gs
	movw 	%ax,%ss
    7c3d:	8e d0                	mov    %eax,%ss
		
	#set up the stack,region(0,start)
	movl	$start,%esp
    7c3f:	bc 00 7c 00 00       	mov    $0x7c00,%esp
	movl	$SEG_KDATA,%ebp
    7c44:	bd 10 00 00 00       	mov    $0x10,%ebp
	
	#call bootmain
	call 	bootmain
    7c49:	e8 d7 00 00 00       	call   7d25 <bootmain>

00007c4e <spin>:
		
spin:
	jmp		spin
    7c4e:	eb fe                	jmp    7c4e <spin>

00007c50 <gdt>:
	...
    7c58:	ff                   	(bad)  
    7c59:	ff 00                	incl   (%eax)
    7c5b:	00 00                	add    %al,(%eax)
    7c5d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c64:	00                   	.byte 0x0
    7c65:	92                   	xchg   %eax,%edx
    7c66:	cf                   	iret   
	...

00007c68 <gdtdesc>:
    7c68:	17                   	pop    %ss
    7c69:	00 50 7c             	add    %dl,0x7c(%eax)
	...

00007c6e <readsect>:
        /* do nothing */;
}

void
readsect(void *dst, uint offset)
{
    7c6e:	55                   	push   %ebp
    7c6f:	89 e5                	mov    %esp,%ebp
    7c71:	57                   	push   %edi
    7c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
}

static inline uint_8 inb(ushort port)
{
	uint_8 data;
	asm volatile(
    7c75:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c7a:	ec                   	in     (%dx),%al
#include "elf.h"

#define SECTSIZE 512
static void
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
    7c7b:	25 c0 00 00 00       	and    $0xc0,%eax
    7c80:	83 f8 40             	cmp    $0x40,%eax
    7c83:	75 f5                	jne    7c7a <readsect+0xc>
		);
}

static inline void outb(ushort port,uint_8 data)
{
	asm volatile(
    7c85:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c8a:	b8 01 00 00 00       	mov    $0x1,%eax
    7c8f:	ee                   	out    %al,(%dx)
    7c90:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c95:	89 c8                	mov    %ecx,%eax
    7c97:	ee                   	out    %al,(%dx)
    7c98:	89 c8                	mov    %ecx,%eax
    7c9a:	c1 e8 08             	shr    $0x8,%eax
    7c9d:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca2:	ee                   	out    %al,(%dx)
    7ca3:	89 c8                	mov    %ecx,%eax
    7ca5:	c1 e8 10             	shr    $0x10,%eax
    7ca8:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cad:	ee                   	out    %al,(%dx)
    7cae:	89 c8                	mov    %ecx,%eax
    7cb0:	c1 e8 18             	shr    $0x18,%eax
    7cb3:	83 c8 e0             	or     $0xffffffe0,%eax
    7cb6:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cbb:	ee                   	out    %al,(%dx)
    7cbc:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc1:	b8 20 00 00 00       	mov    $0x20,%eax
    7cc6:	ee                   	out    %al,(%dx)
}

static inline uint_8 inb(ushort port)
{
	uint_8 data;
	asm volatile(
    7cc7:	ec                   	in     (%dx),%al
    7cc8:	25 c0 00 00 00       	and    $0xc0,%eax
    7ccd:	83 f8 40             	cmp    $0x40,%eax
    7cd0:	75 f5                	jne    7cc7 <readsect+0x59>
#include "type.h"

static inline void insl(ushort port,void *addr,uint count)
{
	asm volatile(
    7cd2:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd7:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cdc:	fc                   	cld    
    7cdd:	f3 6d                	rep insl (%dx),%es:(%edi)
	outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

	// Read data.
	waitdisk();
	insl(0x1F0, dst, SECTSIZE/4);
}
    7cdf:	5f                   	pop    %edi
    7ce0:	5d                   	pop    %ebp
    7ce1:	c3                   	ret    

00007ce2 <readseg>:

//read count bytes from offset in files imag to the pa
void readseg(uint pa,uint offset,uint count)
{
    7ce2:	55                   	push   %ebp
    7ce3:	89 e5                	mov    %esp,%ebp
    7ce5:	57                   	push   %edi
    7ce6:	56                   	push   %esi
    7ce7:	53                   	push   %ebx
    7ce8:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7ceb:	8b 75 0c             	mov    0xc(%ebp),%esi
	uint end=pa+count;
    7cee:	89 df                	mov    %ebx,%edi
    7cf0:	03 7d 10             	add    0x10(%ebp),%edi
	pa -= (offset%SECTSIZE);
    7cf3:	89 f0                	mov    %esi,%eax
    7cf5:	25 ff 01 00 00       	and    $0x1ff,%eax
    7cfa:	29 c3                	sub    %eax,%ebx
	
	offset = offset/SECTSIZE +1;
    7cfc:	c1 ee 09             	shr    $0x9,%esi
    7cff:	83 c6 01             	add    $0x1,%esi
	for(;pa<end;pa+=SECTSIZE,offset++)
    7d02:	39 df                	cmp    %ebx,%edi
    7d04:	76 17                	jbe    7d1d <readseg+0x3b>
		readsect((void *)pa,offset);
    7d06:	56                   	push   %esi
    7d07:	53                   	push   %ebx
    7d08:	e8 61 ff ff ff       	call   7c6e <readsect>
{
	uint end=pa+count;
	pa -= (offset%SECTSIZE);
	
	offset = offset/SECTSIZE +1;
	for(;pa<end;pa+=SECTSIZE,offset++)
    7d0d:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d13:	83 c6 01             	add    $0x1,%esi
    7d16:	83 c4 08             	add    $0x8,%esp
    7d19:	39 df                	cmp    %ebx,%edi
    7d1b:	77 e9                	ja     7d06 <readseg+0x24>
		readsect((void *)pa,offset);
}
    7d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d20:	5b                   	pop    %ebx
    7d21:	5e                   	pop    %esi
    7d22:	5f                   	pop    %edi
    7d23:	5d                   	pop    %ebp
    7d24:	c3                   	ret    

00007d25 <bootmain>:

void bootmain()
{
    7d25:	55                   	push   %ebp
    7d26:	89 e5                	mov    %esp,%ebp
    7d28:	56                   	push   %esi
    7d29:	53                   	push   %ebx
	struct elfhdr 	*elf;
	struct prohdr	*pdr,*ph;
	elf	=(struct elfhdr*)0x10000;
	//first read 1st page to the 0x10000
	readseg((uint)elf,0,4096);
    7d2a:	68 00 10 00 00       	push   $0x1000
    7d2f:	6a 00                	push   $0x0
    7d31:	68 00 00 01 00       	push   $0x10000
    7d36:	e8 a7 ff ff ff       	call   7ce2 <readseg>
	//check it whether is a elf format
	if(elf->ident !=MAGIC_NUM)
    7d3b:	83 c4 0c             	add    $0xc,%esp
    7d3e:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d45:	45 4c 46 
    7d48:	75 49                	jne    7d93 <bootmain+0x6e>
		return;
	pdr=(struct prohdr*)(elf + elf->phoff);
    7d4a:	6b 35 1c 00 01 00 34 	imul   $0x34,0x1001c,%esi
    7d51:	81 c6 00 00 01 00    	add    $0x10000,%esi
	ph=pdr;
	for(;pdr < ph+elf->phnum;pdr++)
    7d57:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7d5e:	c1 e0 05             	shl    $0x5,%eax
    7d61:	01 f0                	add    %esi,%eax
    7d63:	39 c6                	cmp    %eax,%esi
    7d65:	73 2c                	jae    7d93 <bootmain+0x6e>
    7d67:	89 f3                	mov    %esi,%ebx
	{
		readseg(pdr->vaddr&0xFFFFFF,pdr->offset,pdr->memsz);
    7d69:	ff 73 14             	pushl  0x14(%ebx)
    7d6c:	ff 73 04             	pushl  0x4(%ebx)
    7d6f:	8b 43 08             	mov    0x8(%ebx),%eax
    7d72:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d77:	50                   	push   %eax
    7d78:	e8 65 ff ff ff       	call   7ce2 <readseg>
	//check it whether is a elf format
	if(elf->ident !=MAGIC_NUM)
		return;
	pdr=(struct prohdr*)(elf + elf->phoff);
	ph=pdr;
	for(;pdr < ph+elf->phnum;pdr++)
    7d7d:	83 c3 20             	add    $0x20,%ebx
    7d80:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7d87:	c1 e0 05             	shl    $0x5,%eax
    7d8a:	01 f0                	add    %esi,%eax
    7d8c:	83 c4 0c             	add    $0xc,%esp
    7d8f:	39 c3                	cmp    %eax,%ebx
    7d91:	72 d6                	jb     7d69 <bootmain+0x44>
	{
		readseg(pdr->vaddr&0xFFFFFF,pdr->offset,pdr->memsz);
	}
}
    7d93:	8d 65 f8             	lea    -0x8(%ebp),%esp
    7d96:	5b                   	pop    %ebx
    7d97:	5e                   	pop    %esi
    7d98:	5d                   	pop    %ebp
    7d99:	c3                   	ret    

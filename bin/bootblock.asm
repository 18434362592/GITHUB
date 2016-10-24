
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
    7c49:	e8 e0 00 00 00       	call   7d2e <bootmain>

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

00007c6e <waitdisk>:
  entry();
}

void
waitdisk(void)
{
    7c6e:	55                   	push   %ebp
    7c6f:	89 e5                	mov    %esp,%ebp
}

static inline uint_8 inb(ushort port)
{
	uint_8 data;
	asm volatile(
    7c71:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c76:	ec                   	in     (%dx),%al
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
    7c77:	25 c0 00 00 00       	and    $0xc0,%eax
    7c7c:	83 f8 40             	cmp    $0x40,%eax
    7c7f:	75 f5                	jne    7c76 <waitdisk+0x8>
    ;
}
    7c81:	5d                   	pop    %ebp
    7c82:	c3                   	ret    

00007c83 <readsect>:

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
    7c83:	55                   	push   %ebp
    7c84:	89 e5                	mov    %esp,%ebp
    7c86:	57                   	push   %edi
    7c87:	53                   	push   %ebx
    7c88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  // Issue command.
  waitdisk();
    7c8b:	e8 de ff ff ff       	call   7c6e <waitdisk>
		);
}

static inline void outb(ushort port,uint_8 data)
{
	asm volatile(
    7c90:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c95:	b8 01 00 00 00       	mov    $0x1,%eax
    7c9a:	ee                   	out    %al,(%dx)
    7c9b:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7ca0:	89 d8                	mov    %ebx,%eax
    7ca2:	ee                   	out    %al,(%dx)
    7ca3:	89 d8                	mov    %ebx,%eax
    7ca5:	c1 e8 08             	shr    $0x8,%eax
    7ca8:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7cad:	ee                   	out    %al,(%dx)
    7cae:	89 d8                	mov    %ebx,%eax
    7cb0:	c1 e8 10             	shr    $0x10,%eax
    7cb3:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cb8:	ee                   	out    %al,(%dx)
    7cb9:	89 d8                	mov    %ebx,%eax
    7cbb:	c1 e8 18             	shr    $0x18,%eax
    7cbe:	83 c8 e0             	or     $0xffffffe0,%eax
    7cc1:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cc6:	ee                   	out    %al,(%dx)
    7cc7:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7ccc:	b8 20 00 00 00       	mov    $0x20,%eax
    7cd1:	ee                   	out    %al,(%dx)
  outb(0x1F5, offset >> 16);
  outb(0x1F6, (offset >> 24) | 0xE0);
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
    7cd2:	e8 97 ff ff ff       	call   7c6e <waitdisk>
}


static inline void insl(ushort port,void *addr,uint count)
{
	asm volatile(
    7cd7:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cda:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cdf:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7ce4:	fc                   	cld    
    7ce5:	f3 6d                	rep insl (%dx),%es:(%edi)
  insl(0x1F0, dst, SECTSIZE/4);
}
    7ce7:	5b                   	pop    %ebx
    7ce8:	5f                   	pop    %edi
    7ce9:	5d                   	pop    %ebp
    7cea:	c3                   	ret    

00007ceb <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
    7ceb:	55                   	push   %ebp
    7cec:	89 e5                	mov    %esp,%ebp
    7cee:	57                   	push   %edi
    7cef:	56                   	push   %esi
    7cf0:	53                   	push   %ebx
    7cf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cf4:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;

  epa = pa + count;
    7cf7:	89 df                	mov    %ebx,%edi
    7cf9:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;
    7cfc:	89 f0                	mov    %esi,%eax
    7cfe:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d03:	29 c3                	sub    %eax,%ebx

  // Translate from bytes to sectors; kernel starts at sector 1.
  offset = (offset / SECTSIZE) + 1;
    7d05:	c1 ee 09             	shr    $0x9,%esi
    7d08:	83 c6 01             	add    $0x1,%esi

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d0b:	39 df                	cmp    %ebx,%edi
    7d0d:	76 17                	jbe    7d26 <readseg+0x3b>
    readsect(pa, offset);
    7d0f:	56                   	push   %esi
    7d10:	53                   	push   %ebx
    7d11:	e8 6d ff ff ff       	call   7c83 <readsect>
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d16:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d1c:	83 c6 01             	add    $0x1,%esi
    7d1f:	83 c4 08             	add    $0x8,%esp
    7d22:	39 df                	cmp    %ebx,%edi
    7d24:	77 e9                	ja     7d0f <readseg+0x24>
    readsect(pa, offset);
}
    7d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d29:	5b                   	pop    %ebx
    7d2a:	5e                   	pop    %esi
    7d2b:	5f                   	pop    %edi
    7d2c:	5d                   	pop    %ebp
    7d2d:	c3                   	ret    

00007d2e <bootmain>:

void readseg(uchar*, uint, uint);

void
bootmain(void)
{
    7d2e:	55                   	push   %ebp
    7d2f:	89 e5                	mov    %esp,%ebp
    7d31:	57                   	push   %edi
    7d32:	56                   	push   %esi
    7d33:	53                   	push   %ebx
    7d34:	83 ec 0c             	sub    $0xc,%esp
  uchar* pa;

  elf = (struct elfhdr*)0x10000;  // scratch space

  // Read 1st page off disk
  readseg((uchar*)elf, 4096, 0);
    7d37:	6a 00                	push   $0x0
    7d39:	68 00 10 00 00       	push   $0x1000
    7d3e:	68 00 00 01 00       	push   $0x10000
    7d43:	e8 a3 ff ff ff       	call   7ceb <readseg>

  // Is this an ELF executable?
  if(elf->ident != MAGIC_NUM)
    7d48:	83 c4 0c             	add    $0xc,%esp
    7d4b:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d52:	45 4c 46 
    7d55:	75 50                	jne    7da7 <bootmain+0x79>
    return;  // let bootasm.S handle error

  // Load each program segment (ignores ph flags).
  ph = (struct prohdr*)((uchar*)elf + elf->phoff);
    7d57:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d5c:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
  eph = ph + elf->phnum;
    7d62:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7d69:	c1 e6 05             	shl    $0x5,%esi
    7d6c:	01 de                	add    %ebx,%esi
  for(; ph < eph; ph++){
    7d6e:	39 f3                	cmp    %esi,%ebx
    7d70:	73 2f                	jae    7da1 <bootmain+0x73>
    pa = (uchar*)ph->paddr;
    7d72:	8b 7b 0c             	mov    0xc(%ebx),%edi
    readseg(pa, ph->filesz, ph->offset);
    7d75:	ff 73 04             	pushl  0x4(%ebx)
    7d78:	ff 73 10             	pushl  0x10(%ebx)
    7d7b:	57                   	push   %edi
    7d7c:	e8 6a ff ff ff       	call   7ceb <readseg>
    if(ph->memsz > ph->filesz)
    7d81:	8b 4b 14             	mov    0x14(%ebx),%ecx
    7d84:	8b 43 10             	mov    0x10(%ebx),%eax
    7d87:	83 c4 0c             	add    $0xc,%esp
    7d8a:	39 c1                	cmp    %eax,%ecx
    7d8c:	76 0c                	jbe    7d9a <bootmain+0x6c>
static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    7d8e:	01 c7                	add    %eax,%edi
    7d90:	29 c1                	sub    %eax,%ecx
    7d92:	b8 00 00 00 00       	mov    $0x0,%eax
    7d97:	fc                   	cld    
    7d98:	f3 aa                	rep stos %al,%es:(%edi)
    return;  // let bootasm.S handle error

  // Load each program segment (ignores ph flags).
  ph = (struct prohdr*)((uchar*)elf + elf->phoff);
  eph = ph + elf->phnum;
  for(; ph < eph; ph++){
    7d9a:	83 c3 20             	add    $0x20,%ebx
    7d9d:	39 de                	cmp    %ebx,%esi
    7d9f:	77 d1                	ja     7d72 <bootmain+0x44>
  }

  // Call the entry point from the ELF header.
  // Does not return!
  entry = (void(*)(void))(elf->entry);
  entry();
    7da1:	ff 15 18 00 01 00    	call   *0x10018
}
    7da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7daa:	5b                   	pop    %ebx
    7dab:	5e                   	pop    %esi
    7dac:	5f                   	pop    %edi
    7dad:	5d                   	pop    %ebp
    7dae:	c3                   	ret    

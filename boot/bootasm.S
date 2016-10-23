#include "asm.h"
.globl start
start:
.code16
	cli
	xorw	%ax,%ax
	movw	%ax,%ds
	movw 	%ax,%es
	movw	%ax,%ss
		
	#enable A20
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
	
	#lgdt gdtdesc
	lgdt 	gdtdesc
	#switch from real to protected mode
	movl	%cr0,%eax
	orl		$CR0_PE,%eax
	movl 	%eax,%cr0
		
	ljmp 	$SEG_KCODE,$start32
		
.globl start32
start32:
.code32
	#set up the protected-mode data segment registers
	movw 	$SEG_KDATA,%ax
	movw 	%ax,%ds
	movw 	%ax,%es
	movw	%ax,%fs
	movw	%ax,%gs
	movw 	%ax,%ss
		
	#set up the stack,region(0,start)
	movl	$start,%esp
	movl	$SEG_KDATA,%ebp
	
	#call bootmain
	call 	bootmain
		
spin:
	jmp		spin
	
#set up three segments,code segment,data segment,null segment
gdt:
	SEG_NULL
	SEG_ASM(0x0,STA_X|STA_R,0xffffffff)
	SEG_ASM(0x0,STA_W,0xffffffff)
	
gdtdesc:
	.word 	(gdtdesc -gdt -1)	#gdt size,.word 	sizeof(gdt)-1 is wrong,because there is no sizeof function
	.long 	gdt					#gdt address
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

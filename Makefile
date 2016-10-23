BOOTSRC :=boot
KERNELSRC :=kernel
TOOLS :=tools
OBJ := obj
TARGET := bin
SLASH :=/
CFLAGS  :=-I libs


CC = gcc
AS =gas
LD = ld
OBJDUMP = objdump
OBJCOPY = objcopy
CFLAGS += -fno-pic -static -fno-builtin -fno-strict-aliasing -fvar-tracking -fvar-tracking-assignments -O0 -g -Wall -MD -gdwarf-2 -m32 -Werror -fno-omit-frame-pointer
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null)

bootblock := $(addprefix $(TARGET)$(SLASH),bootblock)

VPATH := boot:kernel:libs

#for xv6.img
$(TARGET)/xv6.img: $(bootblock)
	dd if=/dev/zero of=$(TARGET)/xv6.img count=10000
	dd if=$(bootblock) of=$(TARGET)/xv6.img conv=notrunc
	
#creat bootblock
bootfiles :=bootasm.S bootmain.c
$(bootblock): $(bootfiles) | $(OBJ) $(TARGET)
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c $(BOOTSRC)/bootmain.c -o $(OBJ)/bootmain.o
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c $(BOOTSRC)/bootasm.S -o $(OBJ)/bootasm.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $(OBJ)/bootblock.o $(OBJ)/bootasm.o $(OBJ)/bootmain.o
	$(OBJDUMP) -S $(OBJ)/bootblock.o > $(TARGET)/bootblock.asm
	$(OBJCOPY) -S -O binary -j .text $(OBJ)/bootblock.o $(TARGET)/bootblock
	 ./sign.pl $(TARGET)/bootblock
	
$(OBJ):
	mkdir $(OBJ)
	
$(TARGET):
	mkdir $(TARGET)
	
.PHONY :clean
clean:
	rm -r $(TARGET) $(OBJ)
	
#for qemu and gdb

ifndef QEMU
QEMU = $(shell if which qemu > /dev/null; \
	then echo qemu; exit; \
	elif which qemu-system-i386 > /dev/null; \
	then echo qemu-system-i386; exit; \
	else \
	qemu=/Applications/Q.app/Contents/MacOS/i386-softmmu.app/Contents/MacOS/i386-softmmu; \
	if test -x $$qemu; then echo $$qemu; exit; fi; fi; \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "*** or have you tried setting the QEMU variable in Makefile?" 1>&2; \
	echo "***" 1>&2; exit 1)
endif

ifndef CPUS
CPUS := 1
endif

# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)
# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)

QEMUOPTS = -hda $(TARGET)/xv6.img -smp $(CPUS) -m 512 $(QEMUEXTRA)

qemu: $(TARGET)/xv6.img
	$(QEMU) -serial mon:stdio $(QEMUOPTS)
	
qemu-gdb:$(TARGET)/xv6.img
	@echo "*** Now run 'gdb'." 1>&2
	$(QEMU) -serial mon:stdio $(QEMUOPTS) -S $(QEMUGDB)

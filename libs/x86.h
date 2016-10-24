static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}


static inline void insl(ushort port,void *addr,uint count)
{
	asm volatile(
		"cld;rep;insl"
		:"=D"(addr), "=c"(count)
		:"d"(port),"0"(addr),"1"(count)
		:"cc","memory"
		);
}

static inline void outb(ushort port,uint_8 data)
{
	asm volatile(
		"outb %0,%1"
		::"a"(data),"d"(port)
	);
}

static inline uint_8 inb(ushort port)
{
	uint_8 data;
	asm volatile(
		"inb %1,%0"
		:"=a"(data)
		:"d"(port)
		);
	return data;
}

static inline void memset(void *addr,char c,uint count)
{
	asm volatile(
		"rep;stosb"
		:"=c"(count),"=D"(addr)
		:"0"(addr),"1"(count),"a"(c)
		:"memory"
		);
}

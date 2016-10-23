#define SEG_KCODE	0x8
#define SEG_KDATA	0x10

#define SEG_ASM(base,type,lim)                                  \
    .word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),             \
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)

#define SEG_NULL                                             \
    .word 0, 0;                                                 \
    .byte 0, 0, 0, 0											\

//segment's types
#define STA_X	0x8	//exe
#define STA_R	0X2	//readable
#define STA_W	0X2	//writeable(no exe)
#define STA_A	0X1	//access
#define STA_C	0X4	//comforming
#define STA_E	0X4	//expand(no exe)

//CR0 Flags
#define CR0_PE	0x1	//protection enable

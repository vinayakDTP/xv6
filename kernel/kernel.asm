
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	91010113          	addi	sp,sp,-1776 # 80007910 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddbbf>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d9078793          	addi	a5,a5,-624 # 80000e10 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	fc26                	sd	s1,56(sp)
    800000d8:	f84a                	sd	s2,48(sp)
    800000da:	f44e                	sd	s3,40(sp)
    800000dc:	f052                	sd	s4,32(sp)
    800000de:	ec56                	sd	s5,24(sp)
    800000e0:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000e2:	04c05263          	blez	a2,80000126 <consolewrite+0x56>
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	0a4020ef          	jal	ra,8000219e <either_copyin>
    800000fe:	01550a63          	beq	a0,s5,80000112 <consolewrite+0x42>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	7da000ef          	jal	ra,800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
  }

  return i;
}
    80000112:	854a                	mv	a0,s2
    80000114:	60a6                	ld	ra,72(sp)
    80000116:	6406                	ld	s0,64(sp)
    80000118:	74e2                	ld	s1,56(sp)
    8000011a:	7942                	ld	s2,48(sp)
    8000011c:	79a2                	ld	s3,40(sp)
    8000011e:	7a02                	ld	s4,32(sp)
    80000120:	6ae2                	ld	s5,24(sp)
    80000122:	6161                	addi	sp,sp,80
    80000124:	8082                	ret
  for(i = 0; i < n; i++){
    80000126:	4901                	li	s2,0
    80000128:	b7ed                	j	80000112 <consolewrite+0x42>

000000008000012a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000012a:	7159                	addi	sp,sp,-112
    8000012c:	f486                	sd	ra,104(sp)
    8000012e:	f0a2                	sd	s0,96(sp)
    80000130:	eca6                	sd	s1,88(sp)
    80000132:	e8ca                	sd	s2,80(sp)
    80000134:	e4ce                	sd	s3,72(sp)
    80000136:	e0d2                	sd	s4,64(sp)
    80000138:	fc56                	sd	s5,56(sp)
    8000013a:	f85a                	sd	s6,48(sp)
    8000013c:	f45e                	sd	s7,40(sp)
    8000013e:	f062                	sd	s8,32(sp)
    80000140:	ec66                	sd	s9,24(sp)
    80000142:	e86a                	sd	s10,16(sp)
    80000144:	1880                	addi	s0,sp,112
    80000146:	8aaa                	mv	s5,a0
    80000148:	8a2e                	mv	s4,a1
    8000014a:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000014c:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000150:	0000f517          	auipc	a0,0xf
    80000154:	7c050513          	addi	a0,a0,1984 # 8000f910 <cons>
    80000158:	243000ef          	jal	ra,80000b9a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000015c:	0000f497          	auipc	s1,0xf
    80000160:	7b448493          	addi	s1,s1,1972 # 8000f910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000164:	00010917          	auipc	s2,0x10
    80000168:	84490913          	addi	s2,s2,-1980 # 8000f9a8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000016c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000016e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000170:	4ca9                	li	s9,10
  while(n > 0){
    80000172:	07305363          	blez	s3,800001d8 <consoleread+0xae>
    while(cons.r == cons.w){
    80000176:	0984a783          	lw	a5,152(s1)
    8000017a:	09c4a703          	lw	a4,156(s1)
    8000017e:	02f71163          	bne	a4,a5,800001a0 <consoleread+0x76>
      if(killed(myproc())){
    80000182:	6aa010ef          	jal	ra,8000182c <myproc>
    80000186:	6ab010ef          	jal	ra,80002030 <killed>
    8000018a:	e125                	bnez	a0,800001ea <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    8000018c:	85a6                	mv	a1,s1
    8000018e:	854a                	mv	a0,s2
    80000190:	469010ef          	jal	ra,80001df8 <sleep>
    while(cons.r == cons.w){
    80000194:	0984a783          	lw	a5,152(s1)
    80000198:	09c4a703          	lw	a4,156(s1)
    8000019c:	fef703e3          	beq	a4,a5,80000182 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0017871b          	addiw	a4,a5,1
    800001a4:	08e4ac23          	sw	a4,152(s1)
    800001a8:	07f7f713          	andi	a4,a5,127
    800001ac:	9726                	add	a4,a4,s1
    800001ae:	01874703          	lbu	a4,24(a4)
    800001b2:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001b6:	057d0f63          	beq	s10,s7,80000214 <consoleread+0xea>
    cbuf = c;
    800001ba:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001be:	4685                	li	a3,1
    800001c0:	f9f40613          	addi	a2,s0,-97
    800001c4:	85d2                	mv	a1,s4
    800001c6:	8556                	mv	a0,s5
    800001c8:	78d010ef          	jal	ra,80002154 <either_copyout>
    800001cc:	01850663          	beq	a0,s8,800001d8 <consoleread+0xae>
    dst++;
    800001d0:	0a05                	addi	s4,s4,1
    --n;
    800001d2:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001d4:	f99d1fe3          	bne	s10,s9,80000172 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001d8:	0000f517          	auipc	a0,0xf
    800001dc:	73850513          	addi	a0,a0,1848 # 8000f910 <cons>
    800001e0:	253000ef          	jal	ra,80000c32 <release>

  return target - n;
    800001e4:	413b053b          	subw	a0,s6,s3
    800001e8:	a801                	j	800001f8 <consoleread+0xce>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	72650513          	addi	a0,a0,1830 # 8000f910 <cons>
    800001f2:	241000ef          	jal	ra,80000c32 <release>
        return -1;
    800001f6:	557d                	li	a0,-1
}
    800001f8:	70a6                	ld	ra,104(sp)
    800001fa:	7406                	ld	s0,96(sp)
    800001fc:	64e6                	ld	s1,88(sp)
    800001fe:	6946                	ld	s2,80(sp)
    80000200:	69a6                	ld	s3,72(sp)
    80000202:	6a06                	ld	s4,64(sp)
    80000204:	7ae2                	ld	s5,56(sp)
    80000206:	7b42                	ld	s6,48(sp)
    80000208:	7ba2                	ld	s7,40(sp)
    8000020a:	7c02                	ld	s8,32(sp)
    8000020c:	6ce2                	ld	s9,24(sp)
    8000020e:	6d42                	ld	s10,16(sp)
    80000210:	6165                	addi	sp,sp,112
    80000212:	8082                	ret
      if(n < target){
    80000214:	0009871b          	sext.w	a4,s3
    80000218:	fd6770e3          	bgeu	a4,s6,800001d8 <consoleread+0xae>
        cons.r--;
    8000021c:	0000f717          	auipc	a4,0xf
    80000220:	78f72623          	sw	a5,1932(a4) # 8000f9a8 <cons+0x98>
    80000224:	bf55                	j	800001d8 <consoleread+0xae>

0000000080000226 <consputc>:
{
    80000226:	1141                	addi	sp,sp,-16
    80000228:	e406                	sd	ra,8(sp)
    8000022a:	e022                	sd	s0,0(sp)
    8000022c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000022e:	10000793          	li	a5,256
    80000232:	00f50863          	beq	a0,a5,80000242 <consputc+0x1c>
    uartputc_sync(c);
    80000236:	5d4000ef          	jal	ra,8000080a <uartputc_sync>
}
    8000023a:	60a2                	ld	ra,8(sp)
    8000023c:	6402                	ld	s0,0(sp)
    8000023e:	0141                	addi	sp,sp,16
    80000240:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000242:	4521                	li	a0,8
    80000244:	5c6000ef          	jal	ra,8000080a <uartputc_sync>
    80000248:	02000513          	li	a0,32
    8000024c:	5be000ef          	jal	ra,8000080a <uartputc_sync>
    80000250:	4521                	li	a0,8
    80000252:	5b8000ef          	jal	ra,8000080a <uartputc_sync>
    80000256:	b7d5                	j	8000023a <consputc+0x14>

0000000080000258 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000258:	1101                	addi	sp,sp,-32
    8000025a:	ec06                	sd	ra,24(sp)
    8000025c:	e822                	sd	s0,16(sp)
    8000025e:	e426                	sd	s1,8(sp)
    80000260:	e04a                	sd	s2,0(sp)
    80000262:	1000                	addi	s0,sp,32
    80000264:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000266:	0000f517          	auipc	a0,0xf
    8000026a:	6aa50513          	addi	a0,a0,1706 # 8000f910 <cons>
    8000026e:	12d000ef          	jal	ra,80000b9a <acquire>

  switch(c){
    80000272:	47d5                	li	a5,21
    80000274:	0af48063          	beq	s1,a5,80000314 <consoleintr+0xbc>
    80000278:	0297c663          	blt	a5,s1,800002a4 <consoleintr+0x4c>
    8000027c:	47a1                	li	a5,8
    8000027e:	0cf48f63          	beq	s1,a5,8000035c <consoleintr+0x104>
    80000282:	47c1                	li	a5,16
    80000284:	10f49063          	bne	s1,a5,80000384 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80000288:	761010ef          	jal	ra,800021e8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000028c:	0000f517          	auipc	a0,0xf
    80000290:	68450513          	addi	a0,a0,1668 # 8000f910 <cons>
    80000294:	19f000ef          	jal	ra,80000c32 <release>
}
    80000298:	60e2                	ld	ra,24(sp)
    8000029a:	6442                	ld	s0,16(sp)
    8000029c:	64a2                	ld	s1,8(sp)
    8000029e:	6902                	ld	s2,0(sp)
    800002a0:	6105                	addi	sp,sp,32
    800002a2:	8082                	ret
  switch(c){
    800002a4:	07f00793          	li	a5,127
    800002a8:	0af48a63          	beq	s1,a5,8000035c <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ac:	0000f717          	auipc	a4,0xf
    800002b0:	66470713          	addi	a4,a4,1636 # 8000f910 <cons>
    800002b4:	0a072783          	lw	a5,160(a4)
    800002b8:	09872703          	lw	a4,152(a4)
    800002bc:	9f99                	subw	a5,a5,a4
    800002be:	07f00713          	li	a4,127
    800002c2:	fcf765e3          	bltu	a4,a5,8000028c <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002c6:	47b5                	li	a5,13
    800002c8:	0cf48163          	beq	s1,a5,8000038a <consoleintr+0x132>
      consputc(c);
    800002cc:	8526                	mv	a0,s1
    800002ce:	f59ff0ef          	jal	ra,80000226 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002d2:	0000f797          	auipc	a5,0xf
    800002d6:	63e78793          	addi	a5,a5,1598 # 8000f910 <cons>
    800002da:	0a07a683          	lw	a3,160(a5)
    800002de:	0016871b          	addiw	a4,a3,1
    800002e2:	0007061b          	sext.w	a2,a4
    800002e6:	0ae7a023          	sw	a4,160(a5)
    800002ea:	07f6f693          	andi	a3,a3,127
    800002ee:	97b6                	add	a5,a5,a3
    800002f0:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800002f4:	47a9                	li	a5,10
    800002f6:	0af48f63          	beq	s1,a5,800003b4 <consoleintr+0x15c>
    800002fa:	4791                	li	a5,4
    800002fc:	0af48c63          	beq	s1,a5,800003b4 <consoleintr+0x15c>
    80000300:	0000f797          	auipc	a5,0xf
    80000304:	6a87a783          	lw	a5,1704(a5) # 8000f9a8 <cons+0x98>
    80000308:	9f1d                	subw	a4,a4,a5
    8000030a:	08000793          	li	a5,128
    8000030e:	f6f71fe3          	bne	a4,a5,8000028c <consoleintr+0x34>
    80000312:	a04d                	j	800003b4 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000314:	0000f717          	auipc	a4,0xf
    80000318:	5fc70713          	addi	a4,a4,1532 # 8000f910 <cons>
    8000031c:	0a072783          	lw	a5,160(a4)
    80000320:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000324:	0000f497          	auipc	s1,0xf
    80000328:	5ec48493          	addi	s1,s1,1516 # 8000f910 <cons>
    while(cons.e != cons.w &&
    8000032c:	4929                	li	s2,10
    8000032e:	f4f70fe3          	beq	a4,a5,8000028c <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000332:	37fd                	addiw	a5,a5,-1
    80000334:	07f7f713          	andi	a4,a5,127
    80000338:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000033a:	01874703          	lbu	a4,24(a4)
    8000033e:	f52707e3          	beq	a4,s2,8000028c <consoleintr+0x34>
      cons.e--;
    80000342:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000346:	10000513          	li	a0,256
    8000034a:	eddff0ef          	jal	ra,80000226 <consputc>
    while(cons.e != cons.w &&
    8000034e:	0a04a783          	lw	a5,160(s1)
    80000352:	09c4a703          	lw	a4,156(s1)
    80000356:	fcf71ee3          	bne	a4,a5,80000332 <consoleintr+0xda>
    8000035a:	bf0d                	j	8000028c <consoleintr+0x34>
    if(cons.e != cons.w){
    8000035c:	0000f717          	auipc	a4,0xf
    80000360:	5b470713          	addi	a4,a4,1460 # 8000f910 <cons>
    80000364:	0a072783          	lw	a5,160(a4)
    80000368:	09c72703          	lw	a4,156(a4)
    8000036c:	f2f700e3          	beq	a4,a5,8000028c <consoleintr+0x34>
      cons.e--;
    80000370:	37fd                	addiw	a5,a5,-1
    80000372:	0000f717          	auipc	a4,0xf
    80000376:	62f72f23          	sw	a5,1598(a4) # 8000f9b0 <cons+0xa0>
      consputc(BACKSPACE);
    8000037a:	10000513          	li	a0,256
    8000037e:	ea9ff0ef          	jal	ra,80000226 <consputc>
    80000382:	b729                	j	8000028c <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000384:	f00484e3          	beqz	s1,8000028c <consoleintr+0x34>
    80000388:	b715                	j	800002ac <consoleintr+0x54>
      consputc(c);
    8000038a:	4529                	li	a0,10
    8000038c:	e9bff0ef          	jal	ra,80000226 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000390:	0000f797          	auipc	a5,0xf
    80000394:	58078793          	addi	a5,a5,1408 # 8000f910 <cons>
    80000398:	0a07a703          	lw	a4,160(a5)
    8000039c:	0017069b          	addiw	a3,a4,1
    800003a0:	0006861b          	sext.w	a2,a3
    800003a4:	0ad7a023          	sw	a3,160(a5)
    800003a8:	07f77713          	andi	a4,a4,127
    800003ac:	97ba                	add	a5,a5,a4
    800003ae:	4729                	li	a4,10
    800003b0:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003b4:	0000f797          	auipc	a5,0xf
    800003b8:	5ec7ac23          	sw	a2,1528(a5) # 8000f9ac <cons+0x9c>
        wakeup(&cons.r);
    800003bc:	0000f517          	auipc	a0,0xf
    800003c0:	5ec50513          	addi	a0,a0,1516 # 8000f9a8 <cons+0x98>
    800003c4:	281010ef          	jal	ra,80001e44 <wakeup>
    800003c8:	b5d1                	j	8000028c <consoleintr+0x34>

00000000800003ca <consoleinit>:

void
consoleinit(void)
{
    800003ca:	1141                	addi	sp,sp,-16
    800003cc:	e406                	sd	ra,8(sp)
    800003ce:	e022                	sd	s0,0(sp)
    800003d0:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003d2:	00007597          	auipc	a1,0x7
    800003d6:	c3e58593          	addi	a1,a1,-962 # 80007010 <etext+0x10>
    800003da:	0000f517          	auipc	a0,0xf
    800003de:	53650513          	addi	a0,a0,1334 # 8000f910 <cons>
    800003e2:	738000ef          	jal	ra,80000b1a <initlock>

  uartinit();
    800003e6:	3d8000ef          	jal	ra,800007be <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800003ea:	0001f797          	auipc	a5,0x1f
    800003ee:	6be78793          	addi	a5,a5,1726 # 8001faa8 <devsw>
    800003f2:	00000717          	auipc	a4,0x0
    800003f6:	d3870713          	addi	a4,a4,-712 # 8000012a <consoleread>
    800003fa:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800003fc:	00000717          	auipc	a4,0x0
    80000400:	cd470713          	addi	a4,a4,-812 # 800000d0 <consolewrite>
    80000404:	ef98                	sd	a4,24(a5)
}
    80000406:	60a2                	ld	ra,8(sp)
    80000408:	6402                	ld	s0,0(sp)
    8000040a:	0141                	addi	sp,sp,16
    8000040c:	8082                	ret

000000008000040e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000040e:	7179                	addi	sp,sp,-48
    80000410:	f406                	sd	ra,40(sp)
    80000412:	f022                	sd	s0,32(sp)
    80000414:	ec26                	sd	s1,24(sp)
    80000416:	e84a                	sd	s2,16(sp)
    80000418:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000041a:	c219                	beqz	a2,80000420 <printint+0x12>
    8000041c:	06054f63          	bltz	a0,8000049a <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000420:	4881                	li	a7,0
    80000422:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000426:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000428:	00007617          	auipc	a2,0x7
    8000042c:	c1060613          	addi	a2,a2,-1008 # 80007038 <digits>
    80000430:	883e                	mv	a6,a5
    80000432:	2785                	addiw	a5,a5,1
    80000434:	02b57733          	remu	a4,a0,a1
    80000438:	9732                	add	a4,a4,a2
    8000043a:	00074703          	lbu	a4,0(a4)
    8000043e:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000442:	872a                	mv	a4,a0
    80000444:	02b55533          	divu	a0,a0,a1
    80000448:	0685                	addi	a3,a3,1
    8000044a:	feb773e3          	bgeu	a4,a1,80000430 <printint+0x22>

  if(sign)
    8000044e:	00088b63          	beqz	a7,80000464 <printint+0x56>
    buf[i++] = '-';
    80000452:	fe040713          	addi	a4,s0,-32
    80000456:	97ba                	add	a5,a5,a4
    80000458:	02d00713          	li	a4,45
    8000045c:	fee78823          	sb	a4,-16(a5)
    80000460:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000464:	02f05563          	blez	a5,8000048e <printint+0x80>
    80000468:	fd040713          	addi	a4,s0,-48
    8000046c:	00f704b3          	add	s1,a4,a5
    80000470:	fff70913          	addi	s2,a4,-1
    80000474:	993e                	add	s2,s2,a5
    80000476:	37fd                	addiw	a5,a5,-1
    80000478:	1782                	slli	a5,a5,0x20
    8000047a:	9381                	srli	a5,a5,0x20
    8000047c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    80000480:	fff4c503          	lbu	a0,-1(s1)
    80000484:	da3ff0ef          	jal	ra,80000226 <consputc>
  while(--i >= 0)
    80000488:	14fd                	addi	s1,s1,-1
    8000048a:	ff249be3          	bne	s1,s2,80000480 <printint+0x72>
}
    8000048e:	70a2                	ld	ra,40(sp)
    80000490:	7402                	ld	s0,32(sp)
    80000492:	64e2                	ld	s1,24(sp)
    80000494:	6942                	ld	s2,16(sp)
    80000496:	6145                	addi	sp,sp,48
    80000498:	8082                	ret
    x = -xx;
    8000049a:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000049e:	4885                	li	a7,1
    x = -xx;
    800004a0:	b749                	j	80000422 <printint+0x14>

00000000800004a2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004a2:	7155                	addi	sp,sp,-208
    800004a4:	e506                	sd	ra,136(sp)
    800004a6:	e122                	sd	s0,128(sp)
    800004a8:	fca6                	sd	s1,120(sp)
    800004aa:	f8ca                	sd	s2,112(sp)
    800004ac:	f4ce                	sd	s3,104(sp)
    800004ae:	f0d2                	sd	s4,96(sp)
    800004b0:	ecd6                	sd	s5,88(sp)
    800004b2:	e8da                	sd	s6,80(sp)
    800004b4:	e4de                	sd	s7,72(sp)
    800004b6:	e0e2                	sd	s8,64(sp)
    800004b8:	fc66                	sd	s9,56(sp)
    800004ba:	f86a                	sd	s10,48(sp)
    800004bc:	f46e                	sd	s11,40(sp)
    800004be:	0900                	addi	s0,sp,144
    800004c0:	8a2a                	mv	s4,a0
    800004c2:	e40c                	sd	a1,8(s0)
    800004c4:	e810                	sd	a2,16(s0)
    800004c6:	ec14                	sd	a3,24(s0)
    800004c8:	f018                	sd	a4,32(s0)
    800004ca:	f41c                	sd	a5,40(s0)
    800004cc:	03043823          	sd	a6,48(s0)
    800004d0:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004d4:	0000f797          	auipc	a5,0xf
    800004d8:	4fc7a783          	lw	a5,1276(a5) # 8000f9d0 <pr+0x18>
    800004dc:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004e0:	eb9d                	bnez	a5,80000516 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004e2:	00840793          	addi	a5,s0,8
    800004e6:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004ea:	00054503          	lbu	a0,0(a0)
    800004ee:	24050463          	beqz	a0,80000736 <printf+0x294>
    800004f2:	4981                	li	s3,0
    if(cx != '%'){
    800004f4:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800004f8:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800004fc:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000500:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000504:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000508:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000050c:	00007b97          	auipc	s7,0x7
    80000510:	b2cb8b93          	addi	s7,s7,-1236 # 80007038 <digits>
    80000514:	a081                	j	80000554 <printf+0xb2>
    acquire(&pr.lock);
    80000516:	0000f517          	auipc	a0,0xf
    8000051a:	4a250513          	addi	a0,a0,1186 # 8000f9b8 <pr>
    8000051e:	67c000ef          	jal	ra,80000b9a <acquire>
  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	f171                	bnez	a0,800004f2 <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    80000530:	0000f517          	auipc	a0,0xf
    80000534:	48850513          	addi	a0,a0,1160 # 8000f9b8 <pr>
    80000538:	6fa000ef          	jal	ra,80000c32 <release>
    8000053c:	aaed                	j	80000736 <printf+0x294>
      consputc(cx);
    8000053e:	ce9ff0ef          	jal	ra,80000226 <consputc>
      continue;
    80000542:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000544:	0014899b          	addiw	s3,s1,1
    80000548:	013a07b3          	add	a5,s4,s3
    8000054c:	0007c503          	lbu	a0,0(a5)
    80000550:	1c050f63          	beqz	a0,8000072e <printf+0x28c>
    if(cx != '%'){
    80000554:	ff5515e3          	bne	a0,s5,8000053e <printf+0x9c>
    i++;
    80000558:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000055c:	009a07b3          	add	a5,s4,s1
    80000560:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000564:	1c090563          	beqz	s2,8000072e <printf+0x28c>
    80000568:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000056c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000056e:	c789                	beqz	a5,80000578 <printf+0xd6>
    80000570:	009a0733          	add	a4,s4,s1
    80000574:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000578:	03690463          	beq	s2,s6,800005a0 <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    8000057c:	03890e63          	beq	s2,s8,800005b8 <printf+0x116>
    } else if(c0 == 'u'){
    80000580:	0b990d63          	beq	s2,s9,8000063a <printf+0x198>
    } else if(c0 == 'x'){
    80000584:	11a90363          	beq	s2,s10,8000068a <printf+0x1e8>
    } else if(c0 == 'p'){
    80000588:	13b90b63          	beq	s2,s11,800006be <printf+0x21c>
    } else if(c0 == 's'){
    8000058c:	07300793          	li	a5,115
    80000590:	16f90363          	beq	s2,a5,800006f6 <printf+0x254>
    } else if(c0 == '%'){
    80000594:	03591c63          	bne	s2,s5,800005cc <printf+0x12a>
      consputc('%');
    80000598:	8556                	mv	a0,s5
    8000059a:	c8dff0ef          	jal	ra,80000226 <consputc>
    8000059e:	b75d                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800005a0:	f8843783          	ld	a5,-120(s0)
    800005a4:	00878713          	addi	a4,a5,8
    800005a8:	f8e43423          	sd	a4,-120(s0)
    800005ac:	4605                	li	a2,1
    800005ae:	45a9                	li	a1,10
    800005b0:	4388                	lw	a0,0(a5)
    800005b2:	e5dff0ef          	jal	ra,8000040e <printint>
    800005b6:	b779                	j	80000544 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800005b8:	03678163          	beq	a5,s6,800005da <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005bc:	03878d63          	beq	a5,s8,800005f6 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800005c0:	09978963          	beq	a5,s9,80000652 <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005c4:	03878b63          	beq	a5,s8,800005fa <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800005c8:	0da78d63          	beq	a5,s10,800006a2 <printf+0x200>
      consputc('%');
    800005cc:	8556                	mv	a0,s5
    800005ce:	c59ff0ef          	jal	ra,80000226 <consputc>
      consputc(c0);
    800005d2:	854a                	mv	a0,s2
    800005d4:	c53ff0ef          	jal	ra,80000226 <consputc>
    800005d8:	b7b5                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	6388                	ld	a0,0(a5)
    800005ec:	e23ff0ef          	jal	ra,8000040e <printint>
      i += 1;
    800005f0:	0029849b          	addiw	s1,s3,2
    800005f4:	bf81                	j	80000544 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03668463          	beq	a3,s6,8000061e <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005fa:	07968a63          	beq	a3,s9,8000066e <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800005fe:	fda697e3          	bne	a3,s10,800005cc <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    80000602:	f8843783          	ld	a5,-120(s0)
    80000606:	00878713          	addi	a4,a5,8
    8000060a:	f8e43423          	sd	a4,-120(s0)
    8000060e:	4601                	li	a2,0
    80000610:	45c1                	li	a1,16
    80000612:	6388                	ld	a0,0(a5)
    80000614:	dfbff0ef          	jal	ra,8000040e <printint>
      i += 2;
    80000618:	0039849b          	addiw	s1,s3,3
    8000061c:	b725                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000061e:	f8843783          	ld	a5,-120(s0)
    80000622:	00878713          	addi	a4,a5,8
    80000626:	f8e43423          	sd	a4,-120(s0)
    8000062a:	4605                	li	a2,1
    8000062c:	45a9                	li	a1,10
    8000062e:	6388                	ld	a0,0(a5)
    80000630:	ddfff0ef          	jal	ra,8000040e <printint>
      i += 2;
    80000634:	0039849b          	addiw	s1,s3,3
    80000638:	b731                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    8000063a:	f8843783          	ld	a5,-120(s0)
    8000063e:	00878713          	addi	a4,a5,8
    80000642:	f8e43423          	sd	a4,-120(s0)
    80000646:	4601                	li	a2,0
    80000648:	45a9                	li	a1,10
    8000064a:	4388                	lw	a0,0(a5)
    8000064c:	dc3ff0ef          	jal	ra,8000040e <printint>
    80000650:	bdd5                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45a9                	li	a1,10
    80000662:	6388                	ld	a0,0(a5)
    80000664:	dabff0ef          	jal	ra,8000040e <printint>
      i += 1;
    80000668:	0029849b          	addiw	s1,s3,2
    8000066c:	bde1                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4601                	li	a2,0
    8000067c:	45a9                	li	a1,10
    8000067e:	6388                	ld	a0,0(a5)
    80000680:	d8fff0ef          	jal	ra,8000040e <printint>
      i += 2;
    80000684:	0039849b          	addiw	s1,s3,3
    80000688:	bd75                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    8000068a:	f8843783          	ld	a5,-120(s0)
    8000068e:	00878713          	addi	a4,a5,8
    80000692:	f8e43423          	sd	a4,-120(s0)
    80000696:	4601                	li	a2,0
    80000698:	45c1                	li	a1,16
    8000069a:	4388                	lw	a0,0(a5)
    8000069c:	d73ff0ef          	jal	ra,8000040e <printint>
    800006a0:	b555                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45c1                	li	a1,16
    800006b2:	6388                	ld	a0,0(a5)
    800006b4:	d5bff0ef          	jal	ra,8000040e <printint>
      i += 1;
    800006b8:	0029849b          	addiw	s1,s3,2
    800006bc:	b561                	j	80000544 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800006be:	f8843783          	ld	a5,-120(s0)
    800006c2:	00878713          	addi	a4,a5,8
    800006c6:	f8e43423          	sd	a4,-120(s0)
    800006ca:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ce:	03000513          	li	a0,48
    800006d2:	b55ff0ef          	jal	ra,80000226 <consputc>
  consputc('x');
    800006d6:	856a                	mv	a0,s10
    800006d8:	b4fff0ef          	jal	ra,80000226 <consputc>
    800006dc:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006de:	03c9d793          	srli	a5,s3,0x3c
    800006e2:	97de                	add	a5,a5,s7
    800006e4:	0007c503          	lbu	a0,0(a5)
    800006e8:	b3fff0ef          	jal	ra,80000226 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ec:	0992                	slli	s3,s3,0x4
    800006ee:	397d                	addiw	s2,s2,-1
    800006f0:	fe0917e3          	bnez	s2,800006de <printf+0x23c>
    800006f4:	bd81                	j	80000544 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800006f6:	f8843783          	ld	a5,-120(s0)
    800006fa:	00878713          	addi	a4,a5,8
    800006fe:	f8e43423          	sd	a4,-120(s0)
    80000702:	0007b903          	ld	s2,0(a5)
    80000706:	00090d63          	beqz	s2,80000720 <printf+0x27e>
      for(; *s; s++)
    8000070a:	00094503          	lbu	a0,0(s2)
    8000070e:	e2050be3          	beqz	a0,80000544 <printf+0xa2>
        consputc(*s);
    80000712:	b15ff0ef          	jal	ra,80000226 <consputc>
      for(; *s; s++)
    80000716:	0905                	addi	s2,s2,1
    80000718:	00094503          	lbu	a0,0(s2)
    8000071c:	f97d                	bnez	a0,80000712 <printf+0x270>
    8000071e:	b51d                	j	80000544 <printf+0xa2>
        s = "(null)";
    80000720:	00007917          	auipc	s2,0x7
    80000724:	8f890913          	addi	s2,s2,-1800 # 80007018 <etext+0x18>
      for(; *s; s++)
    80000728:	02800513          	li	a0,40
    8000072c:	b7dd                	j	80000712 <printf+0x270>
  if(locking)
    8000072e:	f7843783          	ld	a5,-136(s0)
    80000732:	de079fe3          	bnez	a5,80000530 <printf+0x8e>

  return 0;
}
    80000736:	4501                	li	a0,0
    80000738:	60aa                	ld	ra,136(sp)
    8000073a:	640a                	ld	s0,128(sp)
    8000073c:	74e6                	ld	s1,120(sp)
    8000073e:	7946                	ld	s2,112(sp)
    80000740:	79a6                	ld	s3,104(sp)
    80000742:	7a06                	ld	s4,96(sp)
    80000744:	6ae6                	ld	s5,88(sp)
    80000746:	6b46                	ld	s6,80(sp)
    80000748:	6ba6                	ld	s7,72(sp)
    8000074a:	6c06                	ld	s8,64(sp)
    8000074c:	7ce2                	ld	s9,56(sp)
    8000074e:	7d42                	ld	s10,48(sp)
    80000750:	7da2                	ld	s11,40(sp)
    80000752:	6169                	addi	sp,sp,208
    80000754:	8082                	ret

0000000080000756 <panic>:

void
panic(char *s)
{
    80000756:	1101                	addi	sp,sp,-32
    80000758:	ec06                	sd	ra,24(sp)
    8000075a:	e822                	sd	s0,16(sp)
    8000075c:	e426                	sd	s1,8(sp)
    8000075e:	1000                	addi	s0,sp,32
    80000760:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000762:	0000f797          	auipc	a5,0xf
    80000766:	2607a723          	sw	zero,622(a5) # 8000f9d0 <pr+0x18>
  printf("panic: ");
    8000076a:	00007517          	auipc	a0,0x7
    8000076e:	8b650513          	addi	a0,a0,-1866 # 80007020 <etext+0x20>
    80000772:	d31ff0ef          	jal	ra,800004a2 <printf>
  printf("%s\n", s);
    80000776:	85a6                	mv	a1,s1
    80000778:	00007517          	auipc	a0,0x7
    8000077c:	8b050513          	addi	a0,a0,-1872 # 80007028 <etext+0x28>
    80000780:	d23ff0ef          	jal	ra,800004a2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000784:	4785                	li	a5,1
    80000786:	00007717          	auipc	a4,0x7
    8000078a:	14f72523          	sw	a5,330(a4) # 800078d0 <panicked>
  for(;;)
    8000078e:	a001                	j	8000078e <panic+0x38>

0000000080000790 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000790:	1101                	addi	sp,sp,-32
    80000792:	ec06                	sd	ra,24(sp)
    80000794:	e822                	sd	s0,16(sp)
    80000796:	e426                	sd	s1,8(sp)
    80000798:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000079a:	0000f497          	auipc	s1,0xf
    8000079e:	21e48493          	addi	s1,s1,542 # 8000f9b8 <pr>
    800007a2:	00007597          	auipc	a1,0x7
    800007a6:	88e58593          	addi	a1,a1,-1906 # 80007030 <etext+0x30>
    800007aa:	8526                	mv	a0,s1
    800007ac:	36e000ef          	jal	ra,80000b1a <initlock>
  pr.locking = 1;
    800007b0:	4785                	li	a5,1
    800007b2:	cc9c                	sw	a5,24(s1)
}
    800007b4:	60e2                	ld	ra,24(sp)
    800007b6:	6442                	ld	s0,16(sp)
    800007b8:	64a2                	ld	s1,8(sp)
    800007ba:	6105                	addi	sp,sp,32
    800007bc:	8082                	ret

00000000800007be <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007be:	1141                	addi	sp,sp,-16
    800007c0:	e406                	sd	ra,8(sp)
    800007c2:	e022                	sd	s0,0(sp)
    800007c4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007c6:	100007b7          	lui	a5,0x10000
    800007ca:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ce:	f8000713          	li	a4,-128
    800007d2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007d6:	470d                	li	a4,3
    800007d8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007dc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007e0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007e4:	469d                	li	a3,7
    800007e6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ea:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ee:	00007597          	auipc	a1,0x7
    800007f2:	86258593          	addi	a1,a1,-1950 # 80007050 <digits+0x18>
    800007f6:	0000f517          	auipc	a0,0xf
    800007fa:	1e250513          	addi	a0,a0,482 # 8000f9d8 <uart_tx_lock>
    800007fe:	31c000ef          	jal	ra,80000b1a <initlock>
}
    80000802:	60a2                	ld	ra,8(sp)
    80000804:	6402                	ld	s0,0(sp)
    80000806:	0141                	addi	sp,sp,16
    80000808:	8082                	ret

000000008000080a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000080a:	1101                	addi	sp,sp,-32
    8000080c:	ec06                	sd	ra,24(sp)
    8000080e:	e822                	sd	s0,16(sp)
    80000810:	e426                	sd	s1,8(sp)
    80000812:	1000                	addi	s0,sp,32
    80000814:	84aa                	mv	s1,a0
  push_off();
    80000816:	344000ef          	jal	ra,80000b5a <push_off>

  if(panicked){
    8000081a:	00007797          	auipc	a5,0x7
    8000081e:	0b67a783          	lw	a5,182(a5) # 800078d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	10000737          	lui	a4,0x10000
  if(panicked){
    80000826:	c391                	beqz	a5,8000082a <uartputc_sync+0x20>
    for(;;)
    80000828:	a001                	j	80000828 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000082a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000082e:	0207f793          	andi	a5,a5,32
    80000832:	dfe5                	beqz	a5,8000082a <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000834:	0ff4f513          	andi	a0,s1,255
    80000838:	100007b7          	lui	a5,0x10000
    8000083c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000840:	39e000ef          	jal	ra,80000bde <pop_off>
}
    80000844:	60e2                	ld	ra,24(sp)
    80000846:	6442                	ld	s0,16(sp)
    80000848:	64a2                	ld	s1,8(sp)
    8000084a:	6105                	addi	sp,sp,32
    8000084c:	8082                	ret

000000008000084e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084e:	00007797          	auipc	a5,0x7
    80000852:	08a7b783          	ld	a5,138(a5) # 800078d8 <uart_tx_r>
    80000856:	00007717          	auipc	a4,0x7
    8000085a:	08a73703          	ld	a4,138(a4) # 800078e0 <uart_tx_w>
    8000085e:	06f70c63          	beq	a4,a5,800008d6 <uartstart+0x88>
{
    80000862:	7139                	addi	sp,sp,-64
    80000864:	fc06                	sd	ra,56(sp)
    80000866:	f822                	sd	s0,48(sp)
    80000868:	f426                	sd	s1,40(sp)
    8000086a:	f04a                	sd	s2,32(sp)
    8000086c:	ec4e                	sd	s3,24(sp)
    8000086e:	e852                	sd	s4,16(sp)
    80000870:	e456                	sd	s5,8(sp)
    80000872:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000878:	0000fa17          	auipc	s4,0xf
    8000087c:	160a0a13          	addi	s4,s4,352 # 8000f9d8 <uart_tx_lock>
    uart_tx_r += 1;
    80000880:	00007497          	auipc	s1,0x7
    80000884:	05848493          	addi	s1,s1,88 # 800078d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000888:	00007997          	auipc	s3,0x7
    8000088c:	05898993          	addi	s3,s3,88 # 800078e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000890:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000894:	02077713          	andi	a4,a4,32
    80000898:	c715                	beqz	a4,800008c4 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000089a:	01f7f713          	andi	a4,a5,31
    8000089e:	9752                	add	a4,a4,s4
    800008a0:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a4:	0785                	addi	a5,a5,1
    800008a6:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a8:	8526                	mv	a0,s1
    800008aa:	59a010ef          	jal	ra,80001e44 <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ce3          	bne	a4,a5,80000890 <uartstart+0x42>
      ReadReg(ISR);
    800008bc:	100007b7          	lui	a5,0x10000
    800008c0:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    800008c4:	70e2                	ld	ra,56(sp)
    800008c6:	7442                	ld	s0,48(sp)
    800008c8:	74a2                	ld	s1,40(sp)
    800008ca:	7902                	ld	s2,32(sp)
    800008cc:	69e2                	ld	s3,24(sp)
    800008ce:	6a42                	ld	s4,16(sp)
    800008d0:	6aa2                	ld	s5,8(sp)
    800008d2:	6121                	addi	sp,sp,64
    800008d4:	8082                	ret
      ReadReg(ISR);
    800008d6:	100007b7          	lui	a5,0x10000
    800008da:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008f2:	0000f517          	auipc	a0,0xf
    800008f6:	0e650513          	addi	a0,a0,230 # 8000f9d8 <uart_tx_lock>
    800008fa:	2a0000ef          	jal	ra,80000b9a <acquire>
  if(panicked){
    800008fe:	00007797          	auipc	a5,0x7
    80000902:	fd27a783          	lw	a5,-46(a5) # 800078d0 <panicked>
    80000906:	efbd                	bnez	a5,80000984 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000908:	00007717          	auipc	a4,0x7
    8000090c:	fd873703          	ld	a4,-40(a4) # 800078e0 <uart_tx_w>
    80000910:	00007797          	auipc	a5,0x7
    80000914:	fc87b783          	ld	a5,-56(a5) # 800078d8 <uart_tx_r>
    80000918:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091c:	0000f997          	auipc	s3,0xf
    80000920:	0bc98993          	addi	s3,s3,188 # 8000f9d8 <uart_tx_lock>
    80000924:	00007497          	auipc	s1,0x7
    80000928:	fb448493          	addi	s1,s1,-76 # 800078d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000092c:	00007917          	auipc	s2,0x7
    80000930:	fb490913          	addi	s2,s2,-76 # 800078e0 <uart_tx_w>
    80000934:	00e79d63          	bne	a5,a4,8000094e <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000938:	85ce                	mv	a1,s3
    8000093a:	8526                	mv	a0,s1
    8000093c:	4bc010ef          	jal	ra,80001df8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000940:	00093703          	ld	a4,0(s2)
    80000944:	609c                	ld	a5,0(s1)
    80000946:	02078793          	addi	a5,a5,32
    8000094a:	fee787e3          	beq	a5,a4,80000938 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000094e:	0000f497          	auipc	s1,0xf
    80000952:	08a48493          	addi	s1,s1,138 # 8000f9d8 <uart_tx_lock>
    80000956:	01f77793          	andi	a5,a4,31
    8000095a:	97a6                	add	a5,a5,s1
    8000095c:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000960:	0705                	addi	a4,a4,1
    80000962:	00007797          	auipc	a5,0x7
    80000966:	f6e7bf23          	sd	a4,-130(a5) # 800078e0 <uart_tx_w>
  uartstart();
    8000096a:	ee5ff0ef          	jal	ra,8000084e <uartstart>
  release(&uart_tx_lock);
    8000096e:	8526                	mv	a0,s1
    80000970:	2c2000ef          	jal	ra,80000c32 <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xa4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    800009ba:	a019                	j	800009c0 <uartintr+0x12>
      break;
    consoleintr(c);
    800009bc:	89dff0ef          	jal	ra,80000258 <consoleintr>
    int c = uartgetc();
    800009c0:	fc7ff0ef          	jal	ra,80000986 <uartgetc>
    if(c == -1)
    800009c4:	fe951ce3          	bne	a0,s1,800009bc <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009c8:	0000f497          	auipc	s1,0xf
    800009cc:	01048493          	addi	s1,s1,16 # 8000f9d8 <uart_tx_lock>
    800009d0:	8526                	mv	a0,s1
    800009d2:	1c8000ef          	jal	ra,80000b9a <acquire>
  uartstart();
    800009d6:	e79ff0ef          	jal	ra,8000084e <uartstart>
  release(&uart_tx_lock);
    800009da:	8526                	mv	a0,s1
    800009dc:	256000ef          	jal	ra,80000c32 <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	e7a9                	bnez	a5,80000a44 <kfree+0x5a>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00020797          	auipc	a5,0x20
    80000a02:	24278793          	addi	a5,a5,578 # 80020c40 <end>
    80000a06:	02f56f63          	bltu	a0,a5,80000a44 <kfree+0x5a>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	02f57b63          	bgeu	a0,a5,80000a44 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	258000ef          	jal	ra,80000c6e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1a:	0000f917          	auipc	s2,0xf
    80000a1e:	ff690913          	addi	s2,s2,-10 # 8000fa10 <kmem>
    80000a22:	854a                	mv	a0,s2
    80000a24:	176000ef          	jal	ra,80000b9a <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	1fe000ef          	jal	ra,80000c32 <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6902                	ld	s2,0(sp)
    80000a40:	6105                	addi	sp,sp,32
    80000a42:	8082                	ret
    panic("kfree");
    80000a44:	00006517          	auipc	a0,0x6
    80000a48:	61450513          	addi	a0,a0,1556 # 80007058 <digits+0x20>
    80000a4c:	d0bff0ef          	jal	ra,80000756 <panic>

0000000080000a50 <freerange>:
{
    80000a50:	7179                	addi	sp,sp,-48
    80000a52:	f406                	sd	ra,40(sp)
    80000a54:	f022                	sd	s0,32(sp)
    80000a56:	ec26                	sd	s1,24(sp)
    80000a58:	e84a                	sd	s2,16(sp)
    80000a5a:	e44e                	sd	s3,8(sp)
    80000a5c:	e052                	sd	s4,0(sp)
    80000a5e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a60:	6785                	lui	a5,0x1
    80000a62:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a66:	94aa                	add	s1,s1,a0
    80000a68:	757d                	lui	a0,0xfffff
    80000a6a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a6c:	94be                	add	s1,s1,a5
    80000a6e:	0095ec63          	bltu	a1,s1,80000a86 <freerange+0x36>
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6fff0ef          	jal	ra,800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00006597          	auipc	a1,0x6
    80000aa2:	5c258593          	addi	a1,a1,1474 # 80007060 <digits+0x28>
    80000aa6:	0000f517          	auipc	a0,0xf
    80000aaa:	f6a50513          	addi	a0,a0,-150 # 8000fa10 <kmem>
    80000aae:	06c000ef          	jal	ra,80000b1a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00020517          	auipc	a0,0x20
    80000aba:	18a50513          	addi	a0,a0,394 # 80020c40 <end>
    80000abe:	f93ff0ef          	jal	ra,80000a50 <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	0000f497          	auipc	s1,0xf
    80000ad8:	f3c48493          	addi	s1,s1,-196 # 8000fa10 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0bc000ef          	jal	ra,80000b9a <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if(r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	0000f517          	auipc	a0,0xf
    80000aec:	f2850513          	addi	a0,a0,-216 # 8000fa10 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	140000ef          	jal	ra,80000c32 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	172000ef          	jal	ra,80000c6e <memset>
  return (void*)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	0000f517          	auipc	a0,0xf
    80000b10:	f0450513          	addi	a0,a0,-252 # 8000fa10 <kmem>
    80000b14:	11e000ef          	jal	ra,80000c32 <release>
  if(r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e422                	sd	s0,8(sp)
    80000b1e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b20:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b22:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b26:	00053823          	sd	zero,16(a0)
}
    80000b2a:	6422                	ld	s0,8(sp)
    80000b2c:	0141                	addi	sp,sp,16
    80000b2e:	8082                	ret

0000000080000b30 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b30:	411c                	lw	a5,0(a0)
    80000b32:	e399                	bnez	a5,80000b38 <holding+0x8>
    80000b34:	4501                	li	a0,0
  return r;
}
    80000b36:	8082                	ret
{
    80000b38:	1101                	addi	sp,sp,-32
    80000b3a:	ec06                	sd	ra,24(sp)
    80000b3c:	e822                	sd	s0,16(sp)
    80000b3e:	e426                	sd	s1,8(sp)
    80000b40:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b42:	6904                	ld	s1,16(a0)
    80000b44:	4cd000ef          	jal	ra,80001810 <mycpu>
    80000b48:	40a48533          	sub	a0,s1,a0
    80000b4c:	00153513          	seqz	a0,a0
}
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret

0000000080000b5a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b5a:	1101                	addi	sp,sp,-32
    80000b5c:	ec06                	sd	ra,24(sp)
    80000b5e:	e822                	sd	s0,16(sp)
    80000b60:	e426                	sd	s1,8(sp)
    80000b62:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b64:	100024f3          	csrr	s1,sstatus
    80000b68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b6c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b6e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b72:	49f000ef          	jal	ra,80001810 <mycpu>
    80000b76:	5d3c                	lw	a5,120(a0)
    80000b78:	cb99                	beqz	a5,80000b8e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b7a:	497000ef          	jal	ra,80001810 <mycpu>
    80000b7e:	5d3c                	lw	a5,120(a0)
    80000b80:	2785                	addiw	a5,a5,1
    80000b82:	dd3c                	sw	a5,120(a0)
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret
    mycpu()->intena = old;
    80000b8e:	483000ef          	jal	ra,80001810 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b92:	8085                	srli	s1,s1,0x1
    80000b94:	8885                	andi	s1,s1,1
    80000b96:	dd64                	sw	s1,124(a0)
    80000b98:	b7cd                	j	80000b7a <push_off+0x20>

0000000080000b9a <acquire>:
{
    80000b9a:	1101                	addi	sp,sp,-32
    80000b9c:	ec06                	sd	ra,24(sp)
    80000b9e:	e822                	sd	s0,16(sp)
    80000ba0:	e426                	sd	s1,8(sp)
    80000ba2:	1000                	addi	s0,sp,32
    80000ba4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ba6:	fb5ff0ef          	jal	ra,80000b5a <push_off>
  if(holding(lk))
    80000baa:	8526                	mv	a0,s1
    80000bac:	f85ff0ef          	jal	ra,80000b30 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bb0:	4705                	li	a4,1
  if(holding(lk))
    80000bb2:	e105                	bnez	a0,80000bd2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bb4:	87ba                	mv	a5,a4
    80000bb6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bba:	2781                	sext.w	a5,a5
    80000bbc:	ffe5                	bnez	a5,80000bb4 <acquire+0x1a>
  __sync_synchronize();
    80000bbe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bc2:	44f000ef          	jal	ra,80001810 <mycpu>
    80000bc6:	e888                	sd	a0,16(s1)
}
    80000bc8:	60e2                	ld	ra,24(sp)
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	64a2                	ld	s1,8(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret
    panic("acquire");
    80000bd2:	00006517          	auipc	a0,0x6
    80000bd6:	49650513          	addi	a0,a0,1174 # 80007068 <digits+0x30>
    80000bda:	b7dff0ef          	jal	ra,80000756 <panic>

0000000080000bde <pop_off>:

void
pop_off(void)
{
    80000bde:	1141                	addi	sp,sp,-16
    80000be0:	e406                	sd	ra,8(sp)
    80000be2:	e022                	sd	s0,0(sp)
    80000be4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000be6:	42b000ef          	jal	ra,80001810 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bee:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bf0:	e78d                	bnez	a5,80000c1a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bf2:	5d3c                	lw	a5,120(a0)
    80000bf4:	02f05963          	blez	a5,80000c26 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bf8:	37fd                	addiw	a5,a5,-1
    80000bfa:	0007871b          	sext.w	a4,a5
    80000bfe:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c00:	eb09                	bnez	a4,80000c12 <pop_off+0x34>
    80000c02:	5d7c                	lw	a5,124(a0)
    80000c04:	c799                	beqz	a5,80000c12 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c06:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c0a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c0e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c12:	60a2                	ld	ra,8(sp)
    80000c14:	6402                	ld	s0,0(sp)
    80000c16:	0141                	addi	sp,sp,16
    80000c18:	8082                	ret
    panic("pop_off - interruptible");
    80000c1a:	00006517          	auipc	a0,0x6
    80000c1e:	45650513          	addi	a0,a0,1110 # 80007070 <digits+0x38>
    80000c22:	b35ff0ef          	jal	ra,80000756 <panic>
    panic("pop_off");
    80000c26:	00006517          	auipc	a0,0x6
    80000c2a:	46250513          	addi	a0,a0,1122 # 80007088 <digits+0x50>
    80000c2e:	b29ff0ef          	jal	ra,80000756 <panic>

0000000080000c32 <release>:
{
    80000c32:	1101                	addi	sp,sp,-32
    80000c34:	ec06                	sd	ra,24(sp)
    80000c36:	e822                	sd	s0,16(sp)
    80000c38:	e426                	sd	s1,8(sp)
    80000c3a:	1000                	addi	s0,sp,32
    80000c3c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c3e:	ef3ff0ef          	jal	ra,80000b30 <holding>
    80000c42:	c105                	beqz	a0,80000c62 <release+0x30>
  lk->cpu = 0;
    80000c44:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c48:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c4c:	0f50000f          	fence	iorw,ow
    80000c50:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c54:	f8bff0ef          	jal	ra,80000bde <pop_off>
}
    80000c58:	60e2                	ld	ra,24(sp)
    80000c5a:	6442                	ld	s0,16(sp)
    80000c5c:	64a2                	ld	s1,8(sp)
    80000c5e:	6105                	addi	sp,sp,32
    80000c60:	8082                	ret
    panic("release");
    80000c62:	00006517          	auipc	a0,0x6
    80000c66:	42e50513          	addi	a0,a0,1070 # 80007090 <digits+0x58>
    80000c6a:	aedff0ef          	jal	ra,80000756 <panic>

0000000080000c6e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c6e:	1141                	addi	sp,sp,-16
    80000c70:	e422                	sd	s0,8(sp)
    80000c72:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c74:	ca19                	beqz	a2,80000c8a <memset+0x1c>
    80000c76:	87aa                	mv	a5,a0
    80000c78:	1602                	slli	a2,a2,0x20
    80000c7a:	9201                	srli	a2,a2,0x20
    80000c7c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c80:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c84:	0785                	addi	a5,a5,1
    80000c86:	fee79de3          	bne	a5,a4,80000c80 <memset+0x12>
  }
  return dst;
}
    80000c8a:	6422                	ld	s0,8(sp)
    80000c8c:	0141                	addi	sp,sp,16
    80000c8e:	8082                	ret

0000000080000c90 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c90:	1141                	addi	sp,sp,-16
    80000c92:	e422                	sd	s0,8(sp)
    80000c94:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c96:	ca05                	beqz	a2,80000cc6 <memcmp+0x36>
    80000c98:	fff6069b          	addiw	a3,a2,-1
    80000c9c:	1682                	slli	a3,a3,0x20
    80000c9e:	9281                	srli	a3,a3,0x20
    80000ca0:	0685                	addi	a3,a3,1
    80000ca2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ca4:	00054783          	lbu	a5,0(a0)
    80000ca8:	0005c703          	lbu	a4,0(a1)
    80000cac:	00e79863          	bne	a5,a4,80000cbc <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000cb0:	0505                	addi	a0,a0,1
    80000cb2:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000cb4:	fed518e3          	bne	a0,a3,80000ca4 <memcmp+0x14>
  }

  return 0;
    80000cb8:	4501                	li	a0,0
    80000cba:	a019                	j	80000cc0 <memcmp+0x30>
      return *s1 - *s2;
    80000cbc:	40e7853b          	subw	a0,a5,a4
}
    80000cc0:	6422                	ld	s0,8(sp)
    80000cc2:	0141                	addi	sp,sp,16
    80000cc4:	8082                	ret
  return 0;
    80000cc6:	4501                	li	a0,0
    80000cc8:	bfe5                	j	80000cc0 <memcmp+0x30>

0000000080000cca <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cca:	1141                	addi	sp,sp,-16
    80000ccc:	e422                	sd	s0,8(sp)
    80000cce:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000cd0:	c205                	beqz	a2,80000cf0 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000cd2:	02a5e263          	bltu	a1,a0,80000cf6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00c587b3          	add	a5,a1,a2
{
    80000cde:	872a                	mv	a4,a0
      *d++ = *s++;
    80000ce0:	0585                	addi	a1,a1,1
    80000ce2:	0705                	addi	a4,a4,1
    80000ce4:	fff5c683          	lbu	a3,-1(a1)
    80000ce8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cec:	fef59ae3          	bne	a1,a5,80000ce0 <memmove+0x16>

  return dst;
}
    80000cf0:	6422                	ld	s0,8(sp)
    80000cf2:	0141                	addi	sp,sp,16
    80000cf4:	8082                	ret
  if(s < d && s + n > d){
    80000cf6:	02061693          	slli	a3,a2,0x20
    80000cfa:	9281                	srli	a3,a3,0x20
    80000cfc:	00d58733          	add	a4,a1,a3
    80000d00:	fce57be3          	bgeu	a0,a4,80000cd6 <memmove+0xc>
    d += n;
    80000d04:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d06:	fff6079b          	addiw	a5,a2,-1
    80000d0a:	1782                	slli	a5,a5,0x20
    80000d0c:	9381                	srli	a5,a5,0x20
    80000d0e:	fff7c793          	not	a5,a5
    80000d12:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d14:	177d                	addi	a4,a4,-1
    80000d16:	16fd                	addi	a3,a3,-1
    80000d18:	00074603          	lbu	a2,0(a4)
    80000d1c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d20:	fee79ae3          	bne	a5,a4,80000d14 <memmove+0x4a>
    80000d24:	b7f1                	j	80000cf0 <memmove+0x26>

0000000080000d26 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d26:	1141                	addi	sp,sp,-16
    80000d28:	e406                	sd	ra,8(sp)
    80000d2a:	e022                	sd	s0,0(sp)
    80000d2c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d2e:	f9dff0ef          	jal	ra,80000cca <memmove>
}
    80000d32:	60a2                	ld	ra,8(sp)
    80000d34:	6402                	ld	s0,0(sp)
    80000d36:	0141                	addi	sp,sp,16
    80000d38:	8082                	ret

0000000080000d3a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d3a:	1141                	addi	sp,sp,-16
    80000d3c:	e422                	sd	s0,8(sp)
    80000d3e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d40:	ce11                	beqz	a2,80000d5c <strncmp+0x22>
    80000d42:	00054783          	lbu	a5,0(a0)
    80000d46:	cf89                	beqz	a5,80000d60 <strncmp+0x26>
    80000d48:	0005c703          	lbu	a4,0(a1)
    80000d4c:	00f71a63          	bne	a4,a5,80000d60 <strncmp+0x26>
    n--, p++, q++;
    80000d50:	367d                	addiw	a2,a2,-1
    80000d52:	0505                	addi	a0,a0,1
    80000d54:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d56:	f675                	bnez	a2,80000d42 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d58:	4501                	li	a0,0
    80000d5a:	a809                	j	80000d6c <strncmp+0x32>
    80000d5c:	4501                	li	a0,0
    80000d5e:	a039                	j	80000d6c <strncmp+0x32>
  if(n == 0)
    80000d60:	ca09                	beqz	a2,80000d72 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d62:	00054503          	lbu	a0,0(a0)
    80000d66:	0005c783          	lbu	a5,0(a1)
    80000d6a:	9d1d                	subw	a0,a0,a5
}
    80000d6c:	6422                	ld	s0,8(sp)
    80000d6e:	0141                	addi	sp,sp,16
    80000d70:	8082                	ret
    return 0;
    80000d72:	4501                	li	a0,0
    80000d74:	bfe5                	j	80000d6c <strncmp+0x32>

0000000080000d76 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d76:	1141                	addi	sp,sp,-16
    80000d78:	e422                	sd	s0,8(sp)
    80000d7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d7c:	872a                	mv	a4,a0
    80000d7e:	8832                	mv	a6,a2
    80000d80:	367d                	addiw	a2,a2,-1
    80000d82:	01005963          	blez	a6,80000d94 <strncpy+0x1e>
    80000d86:	0705                	addi	a4,a4,1
    80000d88:	0005c783          	lbu	a5,0(a1)
    80000d8c:	fef70fa3          	sb	a5,-1(a4)
    80000d90:	0585                	addi	a1,a1,1
    80000d92:	f7f5                	bnez	a5,80000d7e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d94:	86ba                	mv	a3,a4
    80000d96:	00c05c63          	blez	a2,80000dae <strncpy+0x38>
    *s++ = 0;
    80000d9a:	0685                	addi	a3,a3,1
    80000d9c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000da0:	fff6c793          	not	a5,a3
    80000da4:	9fb9                	addw	a5,a5,a4
    80000da6:	010787bb          	addw	a5,a5,a6
    80000daa:	fef048e3          	bgtz	a5,80000d9a <strncpy+0x24>
  return os;
}
    80000dae:	6422                	ld	s0,8(sp)
    80000db0:	0141                	addi	sp,sp,16
    80000db2:	8082                	ret

0000000080000db4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e422                	sd	s0,8(sp)
    80000db8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000dba:	02c05363          	blez	a2,80000de0 <safestrcpy+0x2c>
    80000dbe:	fff6069b          	addiw	a3,a2,-1
    80000dc2:	1682                	slli	a3,a3,0x20
    80000dc4:	9281                	srli	a3,a3,0x20
    80000dc6:	96ae                	add	a3,a3,a1
    80000dc8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000dca:	00d58963          	beq	a1,a3,80000ddc <safestrcpy+0x28>
    80000dce:	0585                	addi	a1,a1,1
    80000dd0:	0785                	addi	a5,a5,1
    80000dd2:	fff5c703          	lbu	a4,-1(a1)
    80000dd6:	fee78fa3          	sb	a4,-1(a5)
    80000dda:	fb65                	bnez	a4,80000dca <safestrcpy+0x16>
    ;
  *s = 0;
    80000ddc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000de0:	6422                	ld	s0,8(sp)
    80000de2:	0141                	addi	sp,sp,16
    80000de4:	8082                	ret

0000000080000de6 <strlen>:

int
strlen(const char *s)
{
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e422                	sd	s0,8(sp)
    80000dea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dec:	00054783          	lbu	a5,0(a0)
    80000df0:	cf91                	beqz	a5,80000e0c <strlen+0x26>
    80000df2:	0505                	addi	a0,a0,1
    80000df4:	87aa                	mv	a5,a0
    80000df6:	4685                	li	a3,1
    80000df8:	9e89                	subw	a3,a3,a0
    80000dfa:	00f6853b          	addw	a0,a3,a5
    80000dfe:	0785                	addi	a5,a5,1
    80000e00:	fff7c703          	lbu	a4,-1(a5)
    80000e04:	fb7d                	bnez	a4,80000dfa <strlen+0x14>
    ;
  return n;
}
    80000e06:	6422                	ld	s0,8(sp)
    80000e08:	0141                	addi	sp,sp,16
    80000e0a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e0c:	4501                	li	a0,0
    80000e0e:	bfe5                	j	80000e06 <strlen+0x20>

0000000080000e10 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e406                	sd	ra,8(sp)
    80000e14:	e022                	sd	s0,0(sp)
    80000e16:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e18:	1e9000ef          	jal	ra,80001800 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e1c:	00007717          	auipc	a4,0x7
    80000e20:	acc70713          	addi	a4,a4,-1332 # 800078e8 <started>
  if(cpuid() == 0){
    80000e24:	c51d                	beqz	a0,80000e52 <main+0x42>
    while(started == 0)
    80000e26:	431c                	lw	a5,0(a4)
    80000e28:	2781                	sext.w	a5,a5
    80000e2a:	dff5                	beqz	a5,80000e26 <main+0x16>
      ;
    __sync_synchronize();
    80000e2c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e30:	1d1000ef          	jal	ra,80001800 <cpuid>
    80000e34:	85aa                	mv	a1,a0
    80000e36:	00006517          	auipc	a0,0x6
    80000e3a:	27a50513          	addi	a0,a0,634 # 800070b0 <digits+0x78>
    80000e3e:	e64ff0ef          	jal	ra,800004a2 <printf>
    kvminithart();    // turn on paging
    80000e42:	080000ef          	jal	ra,80000ec2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e46:	4d2010ef          	jal	ra,80002318 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e4a:	26a040ef          	jal	ra,800050b4 <plicinithart>
  }

  scheduler();        
    80000e4e:	611000ef          	jal	ra,80001c5e <scheduler>
    consoleinit();
    80000e52:	d78ff0ef          	jal	ra,800003ca <consoleinit>
    printfinit();
    80000e56:	93bff0ef          	jal	ra,80000790 <printfinit>
    printf("\n");
    80000e5a:	00006517          	auipc	a0,0x6
    80000e5e:	26650513          	addi	a0,a0,614 # 800070c0 <digits+0x88>
    80000e62:	e40ff0ef          	jal	ra,800004a2 <printf>
    printf("xv6 kernel is booting\n");
    80000e66:	00006517          	auipc	a0,0x6
    80000e6a:	23250513          	addi	a0,a0,562 # 80007098 <digits+0x60>
    80000e6e:	e34ff0ef          	jal	ra,800004a2 <printf>
    printf("\n");
    80000e72:	00006517          	auipc	a0,0x6
    80000e76:	24e50513          	addi	a0,a0,590 # 800070c0 <digits+0x88>
    80000e7a:	e28ff0ef          	jal	ra,800004a2 <printf>
    kinit();         // physical page allocator
    80000e7e:	c19ff0ef          	jal	ra,80000a96 <kinit>
    kvminit();       // create kernel page table
    80000e82:	2ca000ef          	jal	ra,8000114c <kvminit>
    kvminithart();   // turn on paging
    80000e86:	03c000ef          	jal	ra,80000ec2 <kvminithart>
    procinit();      // process table
    80000e8a:	0cf000ef          	jal	ra,80001758 <procinit>
    trapinit();      // trap vectors
    80000e8e:	466010ef          	jal	ra,800022f4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e92:	486010ef          	jal	ra,80002318 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e96:	208040ef          	jal	ra,8000509e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e9a:	21a040ef          	jal	ra,800050b4 <plicinithart>
    binit();         // buffer cache
    80000e9e:	2a5010ef          	jal	ra,80002942 <binit>
    iinit();         // inode table
    80000ea2:	084020ef          	jal	ra,80002f26 <iinit>
    fileinit();      // file table
    80000ea6:	61f020ef          	jal	ra,80003cc4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000eaa:	2fa040ef          	jal	ra,800051a4 <virtio_disk_init>
    userinit();      // first user process
    80000eae:	3e7000ef          	jal	ra,80001a94 <userinit>
    __sync_synchronize();
    80000eb2:	0ff0000f          	fence
    started = 1;
    80000eb6:	4785                	li	a5,1
    80000eb8:	00007717          	auipc	a4,0x7
    80000ebc:	a2f72823          	sw	a5,-1488(a4) # 800078e8 <started>
    80000ec0:	b779                	j	80000e4e <main+0x3e>

0000000080000ec2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000ec2:	1141                	addi	sp,sp,-16
    80000ec4:	e422                	sd	s0,8(sp)
    80000ec6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ec8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ecc:	00007797          	auipc	a5,0x7
    80000ed0:	a247b783          	ld	a5,-1500(a5) # 800078f0 <kernel_pagetable>
    80000ed4:	83b1                	srli	a5,a5,0xc
    80000ed6:	577d                	li	a4,-1
    80000ed8:	177e                	slli	a4,a4,0x3f
    80000eda:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000edc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000ee0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ee4:	6422                	ld	s0,8(sp)
    80000ee6:	0141                	addi	sp,sp,16
    80000ee8:	8082                	ret

0000000080000eea <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000eea:	7139                	addi	sp,sp,-64
    80000eec:	fc06                	sd	ra,56(sp)
    80000eee:	f822                	sd	s0,48(sp)
    80000ef0:	f426                	sd	s1,40(sp)
    80000ef2:	f04a                	sd	s2,32(sp)
    80000ef4:	ec4e                	sd	s3,24(sp)
    80000ef6:	e852                	sd	s4,16(sp)
    80000ef8:	e456                	sd	s5,8(sp)
    80000efa:	e05a                	sd	s6,0(sp)
    80000efc:	0080                	addi	s0,sp,64
    80000efe:	84aa                	mv	s1,a0
    80000f00:	89ae                	mv	s3,a1
    80000f02:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f04:	57fd                	li	a5,-1
    80000f06:	83e9                	srli	a5,a5,0x1a
    80000f08:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f0a:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f0c:	02b7fc63          	bgeu	a5,a1,80000f44 <walk+0x5a>
    panic("walk");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	1b850513          	addi	a0,a0,440 # 800070c8 <digits+0x90>
    80000f18:	83fff0ef          	jal	ra,80000756 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f1c:	060a8263          	beqz	s5,80000f80 <walk+0x96>
    80000f20:	babff0ef          	jal	ra,80000aca <kalloc>
    80000f24:	84aa                	mv	s1,a0
    80000f26:	c139                	beqz	a0,80000f6c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f28:	6605                	lui	a2,0x1
    80000f2a:	4581                	li	a1,0
    80000f2c:	d43ff0ef          	jal	ra,80000c6e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f30:	00c4d793          	srli	a5,s1,0xc
    80000f34:	07aa                	slli	a5,a5,0xa
    80000f36:	0017e793          	ori	a5,a5,1
    80000f3a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f3e:	3a5d                	addiw	s4,s4,-9
    80000f40:	036a0063          	beq	s4,s6,80000f60 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f44:	0149d933          	srl	s2,s3,s4
    80000f48:	1ff97913          	andi	s2,s2,511
    80000f4c:	090e                	slli	s2,s2,0x3
    80000f4e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f50:	00093483          	ld	s1,0(s2)
    80000f54:	0014f793          	andi	a5,s1,1
    80000f58:	d3f1                	beqz	a5,80000f1c <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f5a:	80a9                	srli	s1,s1,0xa
    80000f5c:	04b2                	slli	s1,s1,0xc
    80000f5e:	b7c5                	j	80000f3e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f60:	00c9d513          	srli	a0,s3,0xc
    80000f64:	1ff57513          	andi	a0,a0,511
    80000f68:	050e                	slli	a0,a0,0x3
    80000f6a:	9526                	add	a0,a0,s1
}
    80000f6c:	70e2                	ld	ra,56(sp)
    80000f6e:	7442                	ld	s0,48(sp)
    80000f70:	74a2                	ld	s1,40(sp)
    80000f72:	7902                	ld	s2,32(sp)
    80000f74:	69e2                	ld	s3,24(sp)
    80000f76:	6a42                	ld	s4,16(sp)
    80000f78:	6aa2                	ld	s5,8(sp)
    80000f7a:	6b02                	ld	s6,0(sp)
    80000f7c:	6121                	addi	sp,sp,64
    80000f7e:	8082                	ret
        return 0;
    80000f80:	4501                	li	a0,0
    80000f82:	b7ed                	j	80000f6c <walk+0x82>

0000000080000f84 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f84:	57fd                	li	a5,-1
    80000f86:	83e9                	srli	a5,a5,0x1a
    80000f88:	00b7f463          	bgeu	a5,a1,80000f90 <walkaddr+0xc>
    return 0;
    80000f8c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f8e:	8082                	ret
{
    80000f90:	1141                	addi	sp,sp,-16
    80000f92:	e406                	sd	ra,8(sp)
    80000f94:	e022                	sd	s0,0(sp)
    80000f96:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f98:	4601                	li	a2,0
    80000f9a:	f51ff0ef          	jal	ra,80000eea <walk>
  if(pte == 0)
    80000f9e:	c105                	beqz	a0,80000fbe <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fa0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fa2:	0117f693          	andi	a3,a5,17
    80000fa6:	4745                	li	a4,17
    return 0;
    80000fa8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000faa:	00e68663          	beq	a3,a4,80000fb6 <walkaddr+0x32>
}
    80000fae:	60a2                	ld	ra,8(sp)
    80000fb0:	6402                	ld	s0,0(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret
  pa = PTE2PA(*pte);
    80000fb6:	00a7d513          	srli	a0,a5,0xa
    80000fba:	0532                	slli	a0,a0,0xc
  return pa;
    80000fbc:	bfcd                	j	80000fae <walkaddr+0x2a>
    return 0;
    80000fbe:	4501                	li	a0,0
    80000fc0:	b7fd                	j	80000fae <walkaddr+0x2a>

0000000080000fc2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fc2:	715d                	addi	sp,sp,-80
    80000fc4:	e486                	sd	ra,72(sp)
    80000fc6:	e0a2                	sd	s0,64(sp)
    80000fc8:	fc26                	sd	s1,56(sp)
    80000fca:	f84a                	sd	s2,48(sp)
    80000fcc:	f44e                	sd	s3,40(sp)
    80000fce:	f052                	sd	s4,32(sp)
    80000fd0:	ec56                	sd	s5,24(sp)
    80000fd2:	e85a                	sd	s6,16(sp)
    80000fd4:	e45e                	sd	s7,8(sp)
    80000fd6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000fd8:	03459793          	slli	a5,a1,0x34
    80000fdc:	e7a9                	bnez	a5,80001026 <mappages+0x64>
    80000fde:	8aaa                	mv	s5,a0
    80000fe0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fe2:	03461793          	slli	a5,a2,0x34
    80000fe6:	e7b1                	bnez	a5,80001032 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fe8:	ca39                	beqz	a2,8000103e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fea:	79fd                	lui	s3,0xfffff
    80000fec:	964e                	add	a2,a2,s3
    80000fee:	00b609b3          	add	s3,a2,a1
  a = va;
    80000ff2:	892e                	mv	s2,a1
    80000ff4:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000ff8:	6b85                	lui	s7,0x1
    80000ffa:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ffe:	4605                	li	a2,1
    80001000:	85ca                	mv	a1,s2
    80001002:	8556                	mv	a0,s5
    80001004:	ee7ff0ef          	jal	ra,80000eea <walk>
    80001008:	c539                	beqz	a0,80001056 <mappages+0x94>
    if(*pte & PTE_V)
    8000100a:	611c                	ld	a5,0(a0)
    8000100c:	8b85                	andi	a5,a5,1
    8000100e:	ef95                	bnez	a5,8000104a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001010:	80b1                	srli	s1,s1,0xc
    80001012:	04aa                	slli	s1,s1,0xa
    80001014:	0164e4b3          	or	s1,s1,s6
    80001018:	0014e493          	ori	s1,s1,1
    8000101c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000101e:	05390863          	beq	s2,s3,8000106e <mappages+0xac>
    a += PGSIZE;
    80001022:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001024:	bfd9                	j	80000ffa <mappages+0x38>
    panic("mappages: va not aligned");
    80001026:	00006517          	auipc	a0,0x6
    8000102a:	0aa50513          	addi	a0,a0,170 # 800070d0 <digits+0x98>
    8000102e:	f28ff0ef          	jal	ra,80000756 <panic>
    panic("mappages: size not aligned");
    80001032:	00006517          	auipc	a0,0x6
    80001036:	0be50513          	addi	a0,a0,190 # 800070f0 <digits+0xb8>
    8000103a:	f1cff0ef          	jal	ra,80000756 <panic>
    panic("mappages: size");
    8000103e:	00006517          	auipc	a0,0x6
    80001042:	0d250513          	addi	a0,a0,210 # 80007110 <digits+0xd8>
    80001046:	f10ff0ef          	jal	ra,80000756 <panic>
      panic("mappages: remap");
    8000104a:	00006517          	auipc	a0,0x6
    8000104e:	0d650513          	addi	a0,a0,214 # 80007120 <digits+0xe8>
    80001052:	f04ff0ef          	jal	ra,80000756 <panic>
      return -1;
    80001056:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001058:	60a6                	ld	ra,72(sp)
    8000105a:	6406                	ld	s0,64(sp)
    8000105c:	74e2                	ld	s1,56(sp)
    8000105e:	7942                	ld	s2,48(sp)
    80001060:	79a2                	ld	s3,40(sp)
    80001062:	7a02                	ld	s4,32(sp)
    80001064:	6ae2                	ld	s5,24(sp)
    80001066:	6b42                	ld	s6,16(sp)
    80001068:	6ba2                	ld	s7,8(sp)
    8000106a:	6161                	addi	sp,sp,80
    8000106c:	8082                	ret
  return 0;
    8000106e:	4501                	li	a0,0
    80001070:	b7e5                	j	80001058 <mappages+0x96>

0000000080001072 <kvmmap>:
{
    80001072:	1141                	addi	sp,sp,-16
    80001074:	e406                	sd	ra,8(sp)
    80001076:	e022                	sd	s0,0(sp)
    80001078:	0800                	addi	s0,sp,16
    8000107a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000107c:	86b2                	mv	a3,a2
    8000107e:	863e                	mv	a2,a5
    80001080:	f43ff0ef          	jal	ra,80000fc2 <mappages>
    80001084:	e509                	bnez	a0,8000108e <kvmmap+0x1c>
}
    80001086:	60a2                	ld	ra,8(sp)
    80001088:	6402                	ld	s0,0(sp)
    8000108a:	0141                	addi	sp,sp,16
    8000108c:	8082                	ret
    panic("kvmmap");
    8000108e:	00006517          	auipc	a0,0x6
    80001092:	0a250513          	addi	a0,a0,162 # 80007130 <digits+0xf8>
    80001096:	ec0ff0ef          	jal	ra,80000756 <panic>

000000008000109a <kvmmake>:
{
    8000109a:	1101                	addi	sp,sp,-32
    8000109c:	ec06                	sd	ra,24(sp)
    8000109e:	e822                	sd	s0,16(sp)
    800010a0:	e426                	sd	s1,8(sp)
    800010a2:	e04a                	sd	s2,0(sp)
    800010a4:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010a6:	a25ff0ef          	jal	ra,80000aca <kalloc>
    800010aa:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010ac:	6605                	lui	a2,0x1
    800010ae:	4581                	li	a1,0
    800010b0:	bbfff0ef          	jal	ra,80000c6e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010b4:	4719                	li	a4,6
    800010b6:	6685                	lui	a3,0x1
    800010b8:	10000637          	lui	a2,0x10000
    800010bc:	100005b7          	lui	a1,0x10000
    800010c0:	8526                	mv	a0,s1
    800010c2:	fb1ff0ef          	jal	ra,80001072 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010c6:	4719                	li	a4,6
    800010c8:	6685                	lui	a3,0x1
    800010ca:	10001637          	lui	a2,0x10001
    800010ce:	100015b7          	lui	a1,0x10001
    800010d2:	8526                	mv	a0,s1
    800010d4:	f9fff0ef          	jal	ra,80001072 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010d8:	4719                	li	a4,6
    800010da:	040006b7          	lui	a3,0x4000
    800010de:	0c000637          	lui	a2,0xc000
    800010e2:	0c0005b7          	lui	a1,0xc000
    800010e6:	8526                	mv	a0,s1
    800010e8:	f8bff0ef          	jal	ra,80001072 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010ec:	00006917          	auipc	s2,0x6
    800010f0:	f1490913          	addi	s2,s2,-236 # 80007000 <etext>
    800010f4:	4729                	li	a4,10
    800010f6:	80006697          	auipc	a3,0x80006
    800010fa:	f0a68693          	addi	a3,a3,-246 # 7000 <_entry-0x7fff9000>
    800010fe:	4605                	li	a2,1
    80001100:	067e                	slli	a2,a2,0x1f
    80001102:	85b2                	mv	a1,a2
    80001104:	8526                	mv	a0,s1
    80001106:	f6dff0ef          	jal	ra,80001072 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000110a:	4719                	li	a4,6
    8000110c:	46c5                	li	a3,17
    8000110e:	06ee                	slli	a3,a3,0x1b
    80001110:	412686b3          	sub	a3,a3,s2
    80001114:	864a                	mv	a2,s2
    80001116:	85ca                	mv	a1,s2
    80001118:	8526                	mv	a0,s1
    8000111a:	f59ff0ef          	jal	ra,80001072 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000111e:	4729                	li	a4,10
    80001120:	6685                	lui	a3,0x1
    80001122:	00005617          	auipc	a2,0x5
    80001126:	ede60613          	addi	a2,a2,-290 # 80006000 <_trampoline>
    8000112a:	040005b7          	lui	a1,0x4000
    8000112e:	15fd                	addi	a1,a1,-1
    80001130:	05b2                	slli	a1,a1,0xc
    80001132:	8526                	mv	a0,s1
    80001134:	f3fff0ef          	jal	ra,80001072 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001138:	8526                	mv	a0,s1
    8000113a:	594000ef          	jal	ra,800016ce <proc_mapstacks>
}
    8000113e:	8526                	mv	a0,s1
    80001140:	60e2                	ld	ra,24(sp)
    80001142:	6442                	ld	s0,16(sp)
    80001144:	64a2                	ld	s1,8(sp)
    80001146:	6902                	ld	s2,0(sp)
    80001148:	6105                	addi	sp,sp,32
    8000114a:	8082                	ret

000000008000114c <kvminit>:
{
    8000114c:	1141                	addi	sp,sp,-16
    8000114e:	e406                	sd	ra,8(sp)
    80001150:	e022                	sd	s0,0(sp)
    80001152:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001154:	f47ff0ef          	jal	ra,8000109a <kvmmake>
    80001158:	00006797          	auipc	a5,0x6
    8000115c:	78a7bc23          	sd	a0,1944(a5) # 800078f0 <kernel_pagetable>
}
    80001160:	60a2                	ld	ra,8(sp)
    80001162:	6402                	ld	s0,0(sp)
    80001164:	0141                	addi	sp,sp,16
    80001166:	8082                	ret

0000000080001168 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001168:	715d                	addi	sp,sp,-80
    8000116a:	e486                	sd	ra,72(sp)
    8000116c:	e0a2                	sd	s0,64(sp)
    8000116e:	fc26                	sd	s1,56(sp)
    80001170:	f84a                	sd	s2,48(sp)
    80001172:	f44e                	sd	s3,40(sp)
    80001174:	f052                	sd	s4,32(sp)
    80001176:	ec56                	sd	s5,24(sp)
    80001178:	e85a                	sd	s6,16(sp)
    8000117a:	e45e                	sd	s7,8(sp)
    8000117c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000117e:	03459793          	slli	a5,a1,0x34
    80001182:	e795                	bnez	a5,800011ae <uvmunmap+0x46>
    80001184:	8a2a                	mv	s4,a0
    80001186:	892e                	mv	s2,a1
    80001188:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000118a:	0632                	slli	a2,a2,0xc
    8000118c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001190:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001192:	6b05                	lui	s6,0x1
    80001194:	0535ea63          	bltu	a1,s3,800011e8 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001198:	60a6                	ld	ra,72(sp)
    8000119a:	6406                	ld	s0,64(sp)
    8000119c:	74e2                	ld	s1,56(sp)
    8000119e:	7942                	ld	s2,48(sp)
    800011a0:	79a2                	ld	s3,40(sp)
    800011a2:	7a02                	ld	s4,32(sp)
    800011a4:	6ae2                	ld	s5,24(sp)
    800011a6:	6b42                	ld	s6,16(sp)
    800011a8:	6ba2                	ld	s7,8(sp)
    800011aa:	6161                	addi	sp,sp,80
    800011ac:	8082                	ret
    panic("uvmunmap: not aligned");
    800011ae:	00006517          	auipc	a0,0x6
    800011b2:	f8a50513          	addi	a0,a0,-118 # 80007138 <digits+0x100>
    800011b6:	da0ff0ef          	jal	ra,80000756 <panic>
      panic("uvmunmap: walk");
    800011ba:	00006517          	auipc	a0,0x6
    800011be:	f9650513          	addi	a0,a0,-106 # 80007150 <digits+0x118>
    800011c2:	d94ff0ef          	jal	ra,80000756 <panic>
      panic("uvmunmap: not mapped");
    800011c6:	00006517          	auipc	a0,0x6
    800011ca:	f9a50513          	addi	a0,a0,-102 # 80007160 <digits+0x128>
    800011ce:	d88ff0ef          	jal	ra,80000756 <panic>
      panic("uvmunmap: not a leaf");
    800011d2:	00006517          	auipc	a0,0x6
    800011d6:	fa650513          	addi	a0,a0,-90 # 80007178 <digits+0x140>
    800011da:	d7cff0ef          	jal	ra,80000756 <panic>
    *pte = 0;
    800011de:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	995a                	add	s2,s2,s6
    800011e4:	fb397ae3          	bgeu	s2,s3,80001198 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800011e8:	4601                	li	a2,0
    800011ea:	85ca                	mv	a1,s2
    800011ec:	8552                	mv	a0,s4
    800011ee:	cfdff0ef          	jal	ra,80000eea <walk>
    800011f2:	84aa                	mv	s1,a0
    800011f4:	d179                	beqz	a0,800011ba <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    800011f6:	6108                	ld	a0,0(a0)
    800011f8:	00157793          	andi	a5,a0,1
    800011fc:	d7e9                	beqz	a5,800011c6 <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    800011fe:	3ff57793          	andi	a5,a0,1023
    80001202:	fd7788e3          	beq	a5,s7,800011d2 <uvmunmap+0x6a>
    if(do_free){
    80001206:	fc0a8ce3          	beqz	s5,800011de <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    8000120a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000120c:	0532                	slli	a0,a0,0xc
    8000120e:	fdcff0ef          	jal	ra,800009ea <kfree>
    80001212:	b7f1                	j	800011de <uvmunmap+0x76>

0000000080001214 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001214:	1101                	addi	sp,sp,-32
    80001216:	ec06                	sd	ra,24(sp)
    80001218:	e822                	sd	s0,16(sp)
    8000121a:	e426                	sd	s1,8(sp)
    8000121c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000121e:	8adff0ef          	jal	ra,80000aca <kalloc>
    80001222:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001224:	c509                	beqz	a0,8000122e <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001226:	6605                	lui	a2,0x1
    80001228:	4581                	li	a1,0
    8000122a:	a45ff0ef          	jal	ra,80000c6e <memset>
  return pagetable;
}
    8000122e:	8526                	mv	a0,s1
    80001230:	60e2                	ld	ra,24(sp)
    80001232:	6442                	ld	s0,16(sp)
    80001234:	64a2                	ld	s1,8(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000123a:	7179                	addi	sp,sp,-48
    8000123c:	f406                	sd	ra,40(sp)
    8000123e:	f022                	sd	s0,32(sp)
    80001240:	ec26                	sd	s1,24(sp)
    80001242:	e84a                	sd	s2,16(sp)
    80001244:	e44e                	sd	s3,8(sp)
    80001246:	e052                	sd	s4,0(sp)
    80001248:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000124a:	6785                	lui	a5,0x1
    8000124c:	04f67063          	bgeu	a2,a5,8000128c <uvmfirst+0x52>
    80001250:	8a2a                	mv	s4,a0
    80001252:	89ae                	mv	s3,a1
    80001254:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001256:	875ff0ef          	jal	ra,80000aca <kalloc>
    8000125a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000125c:	6605                	lui	a2,0x1
    8000125e:	4581                	li	a1,0
    80001260:	a0fff0ef          	jal	ra,80000c6e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001264:	4779                	li	a4,30
    80001266:	86ca                	mv	a3,s2
    80001268:	6605                	lui	a2,0x1
    8000126a:	4581                	li	a1,0
    8000126c:	8552                	mv	a0,s4
    8000126e:	d55ff0ef          	jal	ra,80000fc2 <mappages>
  memmove(mem, src, sz);
    80001272:	8626                	mv	a2,s1
    80001274:	85ce                	mv	a1,s3
    80001276:	854a                	mv	a0,s2
    80001278:	a53ff0ef          	jal	ra,80000cca <memmove>
}
    8000127c:	70a2                	ld	ra,40(sp)
    8000127e:	7402                	ld	s0,32(sp)
    80001280:	64e2                	ld	s1,24(sp)
    80001282:	6942                	ld	s2,16(sp)
    80001284:	69a2                	ld	s3,8(sp)
    80001286:	6a02                	ld	s4,0(sp)
    80001288:	6145                	addi	sp,sp,48
    8000128a:	8082                	ret
    panic("uvmfirst: more than a page");
    8000128c:	00006517          	auipc	a0,0x6
    80001290:	f0450513          	addi	a0,a0,-252 # 80007190 <digits+0x158>
    80001294:	cc2ff0ef          	jal	ra,80000756 <panic>

0000000080001298 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001298:	1101                	addi	sp,sp,-32
    8000129a:	ec06                	sd	ra,24(sp)
    8000129c:	e822                	sd	s0,16(sp)
    8000129e:	e426                	sd	s1,8(sp)
    800012a0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012a2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012a4:	00b67d63          	bgeu	a2,a1,800012be <uvmdealloc+0x26>
    800012a8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012aa:	6785                	lui	a5,0x1
    800012ac:	17fd                	addi	a5,a5,-1
    800012ae:	00f60733          	add	a4,a2,a5
    800012b2:	767d                	lui	a2,0xfffff
    800012b4:	8f71                	and	a4,a4,a2
    800012b6:	97ae                	add	a5,a5,a1
    800012b8:	8ff1                	and	a5,a5,a2
    800012ba:	00f76863          	bltu	a4,a5,800012ca <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012be:	8526                	mv	a0,s1
    800012c0:	60e2                	ld	ra,24(sp)
    800012c2:	6442                	ld	s0,16(sp)
    800012c4:	64a2                	ld	s1,8(sp)
    800012c6:	6105                	addi	sp,sp,32
    800012c8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ca:	8f99                	sub	a5,a5,a4
    800012cc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ce:	4685                	li	a3,1
    800012d0:	0007861b          	sext.w	a2,a5
    800012d4:	85ba                	mv	a1,a4
    800012d6:	e93ff0ef          	jal	ra,80001168 <uvmunmap>
    800012da:	b7d5                	j	800012be <uvmdealloc+0x26>

00000000800012dc <uvmalloc>:
  if(newsz < oldsz)
    800012dc:	08b66963          	bltu	a2,a1,8000136e <uvmalloc+0x92>
{
    800012e0:	7139                	addi	sp,sp,-64
    800012e2:	fc06                	sd	ra,56(sp)
    800012e4:	f822                	sd	s0,48(sp)
    800012e6:	f426                	sd	s1,40(sp)
    800012e8:	f04a                	sd	s2,32(sp)
    800012ea:	ec4e                	sd	s3,24(sp)
    800012ec:	e852                	sd	s4,16(sp)
    800012ee:	e456                	sd	s5,8(sp)
    800012f0:	e05a                	sd	s6,0(sp)
    800012f2:	0080                	addi	s0,sp,64
    800012f4:	8aaa                	mv	s5,a0
    800012f6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012f8:	6985                	lui	s3,0x1
    800012fa:	19fd                	addi	s3,s3,-1
    800012fc:	95ce                	add	a1,a1,s3
    800012fe:	79fd                	lui	s3,0xfffff
    80001300:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001304:	06c9f763          	bgeu	s3,a2,80001372 <uvmalloc+0x96>
    80001308:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000130a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000130e:	fbcff0ef          	jal	ra,80000aca <kalloc>
    80001312:	84aa                	mv	s1,a0
    if(mem == 0){
    80001314:	c11d                	beqz	a0,8000133a <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    80001316:	6605                	lui	a2,0x1
    80001318:	4581                	li	a1,0
    8000131a:	955ff0ef          	jal	ra,80000c6e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000131e:	875a                	mv	a4,s6
    80001320:	86a6                	mv	a3,s1
    80001322:	6605                	lui	a2,0x1
    80001324:	85ca                	mv	a1,s2
    80001326:	8556                	mv	a0,s5
    80001328:	c9bff0ef          	jal	ra,80000fc2 <mappages>
    8000132c:	e51d                	bnez	a0,8000135a <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000132e:	6785                	lui	a5,0x1
    80001330:	993e                	add	s2,s2,a5
    80001332:	fd496ee3          	bltu	s2,s4,8000130e <uvmalloc+0x32>
  return newsz;
    80001336:	8552                	mv	a0,s4
    80001338:	a039                	j	80001346 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    8000133a:	864e                	mv	a2,s3
    8000133c:	85ca                	mv	a1,s2
    8000133e:	8556                	mv	a0,s5
    80001340:	f59ff0ef          	jal	ra,80001298 <uvmdealloc>
      return 0;
    80001344:	4501                	li	a0,0
}
    80001346:	70e2                	ld	ra,56(sp)
    80001348:	7442                	ld	s0,48(sp)
    8000134a:	74a2                	ld	s1,40(sp)
    8000134c:	7902                	ld	s2,32(sp)
    8000134e:	69e2                	ld	s3,24(sp)
    80001350:	6a42                	ld	s4,16(sp)
    80001352:	6aa2                	ld	s5,8(sp)
    80001354:	6b02                	ld	s6,0(sp)
    80001356:	6121                	addi	sp,sp,64
    80001358:	8082                	ret
      kfree(mem);
    8000135a:	8526                	mv	a0,s1
    8000135c:	e8eff0ef          	jal	ra,800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001360:	864e                	mv	a2,s3
    80001362:	85ca                	mv	a1,s2
    80001364:	8556                	mv	a0,s5
    80001366:	f33ff0ef          	jal	ra,80001298 <uvmdealloc>
      return 0;
    8000136a:	4501                	li	a0,0
    8000136c:	bfe9                	j	80001346 <uvmalloc+0x6a>
    return oldsz;
    8000136e:	852e                	mv	a0,a1
}
    80001370:	8082                	ret
  return newsz;
    80001372:	8532                	mv	a0,a2
    80001374:	bfc9                	j	80001346 <uvmalloc+0x6a>

0000000080001376 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001376:	7179                	addi	sp,sp,-48
    80001378:	f406                	sd	ra,40(sp)
    8000137a:	f022                	sd	s0,32(sp)
    8000137c:	ec26                	sd	s1,24(sp)
    8000137e:	e84a                	sd	s2,16(sp)
    80001380:	e44e                	sd	s3,8(sp)
    80001382:	e052                	sd	s4,0(sp)
    80001384:	1800                	addi	s0,sp,48
    80001386:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001388:	84aa                	mv	s1,a0
    8000138a:	6905                	lui	s2,0x1
    8000138c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000138e:	4985                	li	s3,1
    80001390:	a811                	j	800013a4 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001392:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001394:	0532                	slli	a0,a0,0xc
    80001396:	fe1ff0ef          	jal	ra,80001376 <freewalk>
      pagetable[i] = 0;
    8000139a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000139e:	04a1                	addi	s1,s1,8
    800013a0:	01248f63          	beq	s1,s2,800013be <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013a4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013a6:	00f57793          	andi	a5,a0,15
    800013aa:	ff3784e3          	beq	a5,s3,80001392 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800013ae:	8905                	andi	a0,a0,1
    800013b0:	d57d                	beqz	a0,8000139e <freewalk+0x28>
      panic("freewalk: leaf");
    800013b2:	00006517          	auipc	a0,0x6
    800013b6:	dfe50513          	addi	a0,a0,-514 # 800071b0 <digits+0x178>
    800013ba:	b9cff0ef          	jal	ra,80000756 <panic>
    }
  }
  kfree((void*)pagetable);
    800013be:	8552                	mv	a0,s4
    800013c0:	e2aff0ef          	jal	ra,800009ea <kfree>
}
    800013c4:	70a2                	ld	ra,40(sp)
    800013c6:	7402                	ld	s0,32(sp)
    800013c8:	64e2                	ld	s1,24(sp)
    800013ca:	6942                	ld	s2,16(sp)
    800013cc:	69a2                	ld	s3,8(sp)
    800013ce:	6a02                	ld	s4,0(sp)
    800013d0:	6145                	addi	sp,sp,48
    800013d2:	8082                	ret

00000000800013d4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013d4:	1101                	addi	sp,sp,-32
    800013d6:	ec06                	sd	ra,24(sp)
    800013d8:	e822                	sd	s0,16(sp)
    800013da:	e426                	sd	s1,8(sp)
    800013dc:	1000                	addi	s0,sp,32
    800013de:	84aa                	mv	s1,a0
  if(sz > 0)
    800013e0:	e989                	bnez	a1,800013f2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013e2:	8526                	mv	a0,s1
    800013e4:	f93ff0ef          	jal	ra,80001376 <freewalk>
}
    800013e8:	60e2                	ld	ra,24(sp)
    800013ea:	6442                	ld	s0,16(sp)
    800013ec:	64a2                	ld	s1,8(sp)
    800013ee:	6105                	addi	sp,sp,32
    800013f0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013f2:	6605                	lui	a2,0x1
    800013f4:	167d                	addi	a2,a2,-1
    800013f6:	962e                	add	a2,a2,a1
    800013f8:	4685                	li	a3,1
    800013fa:	8231                	srli	a2,a2,0xc
    800013fc:	4581                	li	a1,0
    800013fe:	d6bff0ef          	jal	ra,80001168 <uvmunmap>
    80001402:	b7c5                	j	800013e2 <uvmfree+0xe>

0000000080001404 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001404:	c65d                	beqz	a2,800014b2 <uvmcopy+0xae>
{
    80001406:	715d                	addi	sp,sp,-80
    80001408:	e486                	sd	ra,72(sp)
    8000140a:	e0a2                	sd	s0,64(sp)
    8000140c:	fc26                	sd	s1,56(sp)
    8000140e:	f84a                	sd	s2,48(sp)
    80001410:	f44e                	sd	s3,40(sp)
    80001412:	f052                	sd	s4,32(sp)
    80001414:	ec56                	sd	s5,24(sp)
    80001416:	e85a                	sd	s6,16(sp)
    80001418:	e45e                	sd	s7,8(sp)
    8000141a:	0880                	addi	s0,sp,80
    8000141c:	8b2a                	mv	s6,a0
    8000141e:	8aae                	mv	s5,a1
    80001420:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001422:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001424:	4601                	li	a2,0
    80001426:	85ce                	mv	a1,s3
    80001428:	855a                	mv	a0,s6
    8000142a:	ac1ff0ef          	jal	ra,80000eea <walk>
    8000142e:	c121                	beqz	a0,8000146e <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001430:	6118                	ld	a4,0(a0)
    80001432:	00177793          	andi	a5,a4,1
    80001436:	c3b1                	beqz	a5,8000147a <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001438:	00a75593          	srli	a1,a4,0xa
    8000143c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001440:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001444:	e86ff0ef          	jal	ra,80000aca <kalloc>
    80001448:	892a                	mv	s2,a0
    8000144a:	c129                	beqz	a0,8000148c <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000144c:	6605                	lui	a2,0x1
    8000144e:	85de                	mv	a1,s7
    80001450:	87bff0ef          	jal	ra,80000cca <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001454:	8726                	mv	a4,s1
    80001456:	86ca                	mv	a3,s2
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ce                	mv	a1,s3
    8000145c:	8556                	mv	a0,s5
    8000145e:	b65ff0ef          	jal	ra,80000fc2 <mappages>
    80001462:	e115                	bnez	a0,80001486 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    80001464:	6785                	lui	a5,0x1
    80001466:	99be                	add	s3,s3,a5
    80001468:	fb49eee3          	bltu	s3,s4,80001424 <uvmcopy+0x20>
    8000146c:	a805                	j	8000149c <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    8000146e:	00006517          	auipc	a0,0x6
    80001472:	d5250513          	addi	a0,a0,-686 # 800071c0 <digits+0x188>
    80001476:	ae0ff0ef          	jal	ra,80000756 <panic>
      panic("uvmcopy: page not present");
    8000147a:	00006517          	auipc	a0,0x6
    8000147e:	d6650513          	addi	a0,a0,-666 # 800071e0 <digits+0x1a8>
    80001482:	ad4ff0ef          	jal	ra,80000756 <panic>
      kfree(mem);
    80001486:	854a                	mv	a0,s2
    80001488:	d62ff0ef          	jal	ra,800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000148c:	4685                	li	a3,1
    8000148e:	00c9d613          	srli	a2,s3,0xc
    80001492:	4581                	li	a1,0
    80001494:	8556                	mv	a0,s5
    80001496:	cd3ff0ef          	jal	ra,80001168 <uvmunmap>
  return -1;
    8000149a:	557d                	li	a0,-1
}
    8000149c:	60a6                	ld	ra,72(sp)
    8000149e:	6406                	ld	s0,64(sp)
    800014a0:	74e2                	ld	s1,56(sp)
    800014a2:	7942                	ld	s2,48(sp)
    800014a4:	79a2                	ld	s3,40(sp)
    800014a6:	7a02                	ld	s4,32(sp)
    800014a8:	6ae2                	ld	s5,24(sp)
    800014aa:	6b42                	ld	s6,16(sp)
    800014ac:	6ba2                	ld	s7,8(sp)
    800014ae:	6161                	addi	sp,sp,80
    800014b0:	8082                	ret
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	8082                	ret

00000000800014b6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014b6:	1141                	addi	sp,sp,-16
    800014b8:	e406                	sd	ra,8(sp)
    800014ba:	e022                	sd	s0,0(sp)
    800014bc:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014be:	4601                	li	a2,0
    800014c0:	a2bff0ef          	jal	ra,80000eea <walk>
  if(pte == 0)
    800014c4:	c901                	beqz	a0,800014d4 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014c6:	611c                	ld	a5,0(a0)
    800014c8:	9bbd                	andi	a5,a5,-17
    800014ca:	e11c                	sd	a5,0(a0)
}
    800014cc:	60a2                	ld	ra,8(sp)
    800014ce:	6402                	ld	s0,0(sp)
    800014d0:	0141                	addi	sp,sp,16
    800014d2:	8082                	ret
    panic("uvmclear");
    800014d4:	00006517          	auipc	a0,0x6
    800014d8:	d2c50513          	addi	a0,a0,-724 # 80007200 <digits+0x1c8>
    800014dc:	a7aff0ef          	jal	ra,80000756 <panic>

00000000800014e0 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800014e0:	c6c9                	beqz	a3,8000156a <copyout+0x8a>
{
    800014e2:	711d                	addi	sp,sp,-96
    800014e4:	ec86                	sd	ra,88(sp)
    800014e6:	e8a2                	sd	s0,80(sp)
    800014e8:	e4a6                	sd	s1,72(sp)
    800014ea:	e0ca                	sd	s2,64(sp)
    800014ec:	fc4e                	sd	s3,56(sp)
    800014ee:	f852                	sd	s4,48(sp)
    800014f0:	f456                	sd	s5,40(sp)
    800014f2:	f05a                	sd	s6,32(sp)
    800014f4:	ec5e                	sd	s7,24(sp)
    800014f6:	e862                	sd	s8,16(sp)
    800014f8:	e466                	sd	s9,8(sp)
    800014fa:	e06a                	sd	s10,0(sp)
    800014fc:	1080                	addi	s0,sp,96
    800014fe:	8baa                	mv	s7,a0
    80001500:	8aae                	mv	s5,a1
    80001502:	8b32                	mv	s6,a2
    80001504:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001506:	74fd                	lui	s1,0xfffff
    80001508:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000150a:	57fd                	li	a5,-1
    8000150c:	83e9                	srli	a5,a5,0x1a
    8000150e:	0697e063          	bltu	a5,s1,8000156e <copyout+0x8e>
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001512:	4cd5                	li	s9,21
    80001514:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001516:	8c3e                	mv	s8,a5
    80001518:	a025                	j	80001540 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000151a:	83a9                	srli	a5,a5,0xa
    8000151c:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000151e:	409a8533          	sub	a0,s5,s1
    80001522:	0009061b          	sext.w	a2,s2
    80001526:	85da                	mv	a1,s6
    80001528:	953e                	add	a0,a0,a5
    8000152a:	fa0ff0ef          	jal	ra,80000cca <memmove>

    len -= n;
    8000152e:	412989b3          	sub	s3,s3,s2
    src += n;
    80001532:	9b4a                	add	s6,s6,s2
  while(len > 0){
    80001534:	02098963          	beqz	s3,80001566 <copyout+0x86>
    if(va0 >= MAXVA)
    80001538:	034c6d63          	bltu	s8,s4,80001572 <copyout+0x92>
    va0 = PGROUNDDOWN(dstva);
    8000153c:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    8000153e:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80001540:	4601                	li	a2,0
    80001542:	85a6                	mv	a1,s1
    80001544:	855e                	mv	a0,s7
    80001546:	9a5ff0ef          	jal	ra,80000eea <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    8000154a:	c515                	beqz	a0,80001576 <copyout+0x96>
    8000154c:	611c                	ld	a5,0(a0)
    8000154e:	0157f713          	andi	a4,a5,21
    80001552:	05971163          	bne	a4,s9,80001594 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80001556:	01a48a33          	add	s4,s1,s10
    8000155a:	415a0933          	sub	s2,s4,s5
    if(n > len)
    8000155e:	fb29fee3          	bgeu	s3,s2,8000151a <copyout+0x3a>
    80001562:	894e                	mv	s2,s3
    80001564:	bf5d                	j	8000151a <copyout+0x3a>
  }
  return 0;
    80001566:	4501                	li	a0,0
    80001568:	a801                	j	80001578 <copyout+0x98>
    8000156a:	4501                	li	a0,0
}
    8000156c:	8082                	ret
      return -1;
    8000156e:	557d                	li	a0,-1
    80001570:	a021                	j	80001578 <copyout+0x98>
    80001572:	557d                	li	a0,-1
    80001574:	a011                	j	80001578 <copyout+0x98>
      return -1;
    80001576:	557d                	li	a0,-1
}
    80001578:	60e6                	ld	ra,88(sp)
    8000157a:	6446                	ld	s0,80(sp)
    8000157c:	64a6                	ld	s1,72(sp)
    8000157e:	6906                	ld	s2,64(sp)
    80001580:	79e2                	ld	s3,56(sp)
    80001582:	7a42                	ld	s4,48(sp)
    80001584:	7aa2                	ld	s5,40(sp)
    80001586:	7b02                	ld	s6,32(sp)
    80001588:	6be2                	ld	s7,24(sp)
    8000158a:	6c42                	ld	s8,16(sp)
    8000158c:	6ca2                	ld	s9,8(sp)
    8000158e:	6d02                	ld	s10,0(sp)
    80001590:	6125                	addi	sp,sp,96
    80001592:	8082                	ret
      return -1;
    80001594:	557d                	li	a0,-1
    80001596:	b7cd                	j	80001578 <copyout+0x98>

0000000080001598 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001598:	c6a5                	beqz	a3,80001600 <copyin+0x68>
{
    8000159a:	715d                	addi	sp,sp,-80
    8000159c:	e486                	sd	ra,72(sp)
    8000159e:	e0a2                	sd	s0,64(sp)
    800015a0:	fc26                	sd	s1,56(sp)
    800015a2:	f84a                	sd	s2,48(sp)
    800015a4:	f44e                	sd	s3,40(sp)
    800015a6:	f052                	sd	s4,32(sp)
    800015a8:	ec56                	sd	s5,24(sp)
    800015aa:	e85a                	sd	s6,16(sp)
    800015ac:	e45e                	sd	s7,8(sp)
    800015ae:	e062                	sd	s8,0(sp)
    800015b0:	0880                	addi	s0,sp,80
    800015b2:	8b2a                	mv	s6,a0
    800015b4:	8a2e                	mv	s4,a1
    800015b6:	8c32                	mv	s8,a2
    800015b8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800015ba:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015bc:	6a85                	lui	s5,0x1
    800015be:	a00d                	j	800015e0 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015c0:	018505b3          	add	a1,a0,s8
    800015c4:	0004861b          	sext.w	a2,s1
    800015c8:	412585b3          	sub	a1,a1,s2
    800015cc:	8552                	mv	a0,s4
    800015ce:	efcff0ef          	jal	ra,80000cca <memmove>

    len -= n;
    800015d2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800015d6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800015d8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800015dc:	02098063          	beqz	s3,800015fc <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    800015e0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800015e4:	85ca                	mv	a1,s2
    800015e6:	855a                	mv	a0,s6
    800015e8:	99dff0ef          	jal	ra,80000f84 <walkaddr>
    if(pa0 == 0)
    800015ec:	cd01                	beqz	a0,80001604 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800015ee:	418904b3          	sub	s1,s2,s8
    800015f2:	94d6                	add	s1,s1,s5
    if(n > len)
    800015f4:	fc99f6e3          	bgeu	s3,s1,800015c0 <copyin+0x28>
    800015f8:	84ce                	mv	s1,s3
    800015fa:	b7d9                	j	800015c0 <copyin+0x28>
  }
  return 0;
    800015fc:	4501                	li	a0,0
    800015fe:	a021                	j	80001606 <copyin+0x6e>
    80001600:	4501                	li	a0,0
}
    80001602:	8082                	ret
      return -1;
    80001604:	557d                	li	a0,-1
}
    80001606:	60a6                	ld	ra,72(sp)
    80001608:	6406                	ld	s0,64(sp)
    8000160a:	74e2                	ld	s1,56(sp)
    8000160c:	7942                	ld	s2,48(sp)
    8000160e:	79a2                	ld	s3,40(sp)
    80001610:	7a02                	ld	s4,32(sp)
    80001612:	6ae2                	ld	s5,24(sp)
    80001614:	6b42                	ld	s6,16(sp)
    80001616:	6ba2                	ld	s7,8(sp)
    80001618:	6c02                	ld	s8,0(sp)
    8000161a:	6161                	addi	sp,sp,80
    8000161c:	8082                	ret

000000008000161e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000161e:	c2d5                	beqz	a3,800016c2 <copyinstr+0xa4>
{
    80001620:	715d                	addi	sp,sp,-80
    80001622:	e486                	sd	ra,72(sp)
    80001624:	e0a2                	sd	s0,64(sp)
    80001626:	fc26                	sd	s1,56(sp)
    80001628:	f84a                	sd	s2,48(sp)
    8000162a:	f44e                	sd	s3,40(sp)
    8000162c:	f052                	sd	s4,32(sp)
    8000162e:	ec56                	sd	s5,24(sp)
    80001630:	e85a                	sd	s6,16(sp)
    80001632:	e45e                	sd	s7,8(sp)
    80001634:	0880                	addi	s0,sp,80
    80001636:	8a2a                	mv	s4,a0
    80001638:	8b2e                	mv	s6,a1
    8000163a:	8bb2                	mv	s7,a2
    8000163c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000163e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001640:	6985                	lui	s3,0x1
    80001642:	a035                	j	8000166e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001644:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001648:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000164a:	0017b793          	seqz	a5,a5
    8000164e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001652:	60a6                	ld	ra,72(sp)
    80001654:	6406                	ld	s0,64(sp)
    80001656:	74e2                	ld	s1,56(sp)
    80001658:	7942                	ld	s2,48(sp)
    8000165a:	79a2                	ld	s3,40(sp)
    8000165c:	7a02                	ld	s4,32(sp)
    8000165e:	6ae2                	ld	s5,24(sp)
    80001660:	6b42                	ld	s6,16(sp)
    80001662:	6ba2                	ld	s7,8(sp)
    80001664:	6161                	addi	sp,sp,80
    80001666:	8082                	ret
    srcva = va0 + PGSIZE;
    80001668:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000166c:	c4b9                	beqz	s1,800016ba <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    8000166e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001672:	85ca                	mv	a1,s2
    80001674:	8552                	mv	a0,s4
    80001676:	90fff0ef          	jal	ra,80000f84 <walkaddr>
    if(pa0 == 0)
    8000167a:	c131                	beqz	a0,800016be <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    8000167c:	41790833          	sub	a6,s2,s7
    80001680:	984e                	add	a6,a6,s3
    if(n > max)
    80001682:	0104f363          	bgeu	s1,a6,80001688 <copyinstr+0x6a>
    80001686:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001688:	955e                	add	a0,a0,s7
    8000168a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000168e:	fc080de3          	beqz	a6,80001668 <copyinstr+0x4a>
    80001692:	985a                	add	a6,a6,s6
    80001694:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001696:	41650633          	sub	a2,a0,s6
    8000169a:	14fd                	addi	s1,s1,-1
    8000169c:	9b26                	add	s6,s6,s1
    8000169e:	00f60733          	add	a4,a2,a5
    800016a2:	00074703          	lbu	a4,0(a4)
    800016a6:	df59                	beqz	a4,80001644 <copyinstr+0x26>
        *dst = *p;
    800016a8:	00e78023          	sb	a4,0(a5)
      --max;
    800016ac:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016b0:	0785                	addi	a5,a5,1
    while(n > 0){
    800016b2:	ff0796e3          	bne	a5,a6,8000169e <copyinstr+0x80>
      dst++;
    800016b6:	8b42                	mv	s6,a6
    800016b8:	bf45                	j	80001668 <copyinstr+0x4a>
    800016ba:	4781                	li	a5,0
    800016bc:	b779                	j	8000164a <copyinstr+0x2c>
      return -1;
    800016be:	557d                	li	a0,-1
    800016c0:	bf49                	j	80001652 <copyinstr+0x34>
  int got_null = 0;
    800016c2:	4781                	li	a5,0
  if(got_null){
    800016c4:	0017b793          	seqz	a5,a5
    800016c8:	40f00533          	neg	a0,a5
}
    800016cc:	8082                	ret

00000000800016ce <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016ce:	7139                	addi	sp,sp,-64
    800016d0:	fc06                	sd	ra,56(sp)
    800016d2:	f822                	sd	s0,48(sp)
    800016d4:	f426                	sd	s1,40(sp)
    800016d6:	f04a                	sd	s2,32(sp)
    800016d8:	ec4e                	sd	s3,24(sp)
    800016da:	e852                	sd	s4,16(sp)
    800016dc:	e456                	sd	s5,8(sp)
    800016de:	e05a                	sd	s6,0(sp)
    800016e0:	0080                	addi	s0,sp,64
    800016e2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016e4:	0000e497          	auipc	s1,0xe
    800016e8:	77c48493          	addi	s1,s1,1916 # 8000fe60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016ec:	8b26                	mv	s6,s1
    800016ee:	00006a97          	auipc	s5,0x6
    800016f2:	912a8a93          	addi	s5,s5,-1774 # 80007000 <etext>
    800016f6:	04000937          	lui	s2,0x4000
    800016fa:	197d                	addi	s2,s2,-1
    800016fc:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016fe:	00014a17          	auipc	s4,0x14
    80001702:	162a0a13          	addi	s4,s4,354 # 80015860 <tickslock>
    char *pa = kalloc();
    80001706:	bc4ff0ef          	jal	ra,80000aca <kalloc>
    8000170a:	862a                	mv	a2,a0
    if(pa == 0)
    8000170c:	c121                	beqz	a0,8000174c <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    8000170e:	416485b3          	sub	a1,s1,s6
    80001712:	858d                	srai	a1,a1,0x3
    80001714:	000ab783          	ld	a5,0(s5)
    80001718:	02f585b3          	mul	a1,a1,a5
    8000171c:	2585                	addiw	a1,a1,1
    8000171e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001722:	4719                	li	a4,6
    80001724:	6685                	lui	a3,0x1
    80001726:	40b905b3          	sub	a1,s2,a1
    8000172a:	854e                	mv	a0,s3
    8000172c:	947ff0ef          	jal	ra,80001072 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001730:	16848493          	addi	s1,s1,360
    80001734:	fd4499e3          	bne	s1,s4,80001706 <proc_mapstacks+0x38>
  }
}
    80001738:	70e2                	ld	ra,56(sp)
    8000173a:	7442                	ld	s0,48(sp)
    8000173c:	74a2                	ld	s1,40(sp)
    8000173e:	7902                	ld	s2,32(sp)
    80001740:	69e2                	ld	s3,24(sp)
    80001742:	6a42                	ld	s4,16(sp)
    80001744:	6aa2                	ld	s5,8(sp)
    80001746:	6b02                	ld	s6,0(sp)
    80001748:	6121                	addi	sp,sp,64
    8000174a:	8082                	ret
      panic("kalloc");
    8000174c:	00006517          	auipc	a0,0x6
    80001750:	ac450513          	addi	a0,a0,-1340 # 80007210 <digits+0x1d8>
    80001754:	802ff0ef          	jal	ra,80000756 <panic>

0000000080001758 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001758:	7139                	addi	sp,sp,-64
    8000175a:	fc06                	sd	ra,56(sp)
    8000175c:	f822                	sd	s0,48(sp)
    8000175e:	f426                	sd	s1,40(sp)
    80001760:	f04a                	sd	s2,32(sp)
    80001762:	ec4e                	sd	s3,24(sp)
    80001764:	e852                	sd	s4,16(sp)
    80001766:	e456                	sd	s5,8(sp)
    80001768:	e05a                	sd	s6,0(sp)
    8000176a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000176c:	00006597          	auipc	a1,0x6
    80001770:	aac58593          	addi	a1,a1,-1364 # 80007218 <digits+0x1e0>
    80001774:	0000e517          	auipc	a0,0xe
    80001778:	2bc50513          	addi	a0,a0,700 # 8000fa30 <pid_lock>
    8000177c:	b9eff0ef          	jal	ra,80000b1a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001780:	00006597          	auipc	a1,0x6
    80001784:	aa058593          	addi	a1,a1,-1376 # 80007220 <digits+0x1e8>
    80001788:	0000e517          	auipc	a0,0xe
    8000178c:	2c050513          	addi	a0,a0,704 # 8000fa48 <wait_lock>
    80001790:	b8aff0ef          	jal	ra,80000b1a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001794:	0000e497          	auipc	s1,0xe
    80001798:	6cc48493          	addi	s1,s1,1740 # 8000fe60 <proc>
      initlock(&p->lock, "proc");
    8000179c:	00006b17          	auipc	s6,0x6
    800017a0:	a94b0b13          	addi	s6,s6,-1388 # 80007230 <digits+0x1f8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800017a4:	8aa6                	mv	s5,s1
    800017a6:	00006a17          	auipc	s4,0x6
    800017aa:	85aa0a13          	addi	s4,s4,-1958 # 80007000 <etext>
    800017ae:	04000937          	lui	s2,0x4000
    800017b2:	197d                	addi	s2,s2,-1
    800017b4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017b6:	00014997          	auipc	s3,0x14
    800017ba:	0aa98993          	addi	s3,s3,170 # 80015860 <tickslock>
      initlock(&p->lock, "proc");
    800017be:	85da                	mv	a1,s6
    800017c0:	8526                	mv	a0,s1
    800017c2:	b58ff0ef          	jal	ra,80000b1a <initlock>
      p->state = UNUSED;
    800017c6:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017ca:	415487b3          	sub	a5,s1,s5
    800017ce:	878d                	srai	a5,a5,0x3
    800017d0:	000a3703          	ld	a4,0(s4)
    800017d4:	02e787b3          	mul	a5,a5,a4
    800017d8:	2785                	addiw	a5,a5,1
    800017da:	00d7979b          	slliw	a5,a5,0xd
    800017de:	40f907b3          	sub	a5,s2,a5
    800017e2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e4:	16848493          	addi	s1,s1,360
    800017e8:	fd349be3          	bne	s1,s3,800017be <procinit+0x66>
  }
}
    800017ec:	70e2                	ld	ra,56(sp)
    800017ee:	7442                	ld	s0,48(sp)
    800017f0:	74a2                	ld	s1,40(sp)
    800017f2:	7902                	ld	s2,32(sp)
    800017f4:	69e2                	ld	s3,24(sp)
    800017f6:	6a42                	ld	s4,16(sp)
    800017f8:	6aa2                	ld	s5,8(sp)
    800017fa:	6b02                	ld	s6,0(sp)
    800017fc:	6121                	addi	sp,sp,64
    800017fe:	8082                	ret

0000000080001800 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001800:	1141                	addi	sp,sp,-16
    80001802:	e422                	sd	s0,8(sp)
    80001804:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001806:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001808:	2501                	sext.w	a0,a0
    8000180a:	6422                	ld	s0,8(sp)
    8000180c:	0141                	addi	sp,sp,16
    8000180e:	8082                	ret

0000000080001810 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001810:	1141                	addi	sp,sp,-16
    80001812:	e422                	sd	s0,8(sp)
    80001814:	0800                	addi	s0,sp,16
    80001816:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001818:	2781                	sext.w	a5,a5
    8000181a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000181c:	0000e517          	auipc	a0,0xe
    80001820:	24450513          	addi	a0,a0,580 # 8000fa60 <cpus>
    80001824:	953e                	add	a0,a0,a5
    80001826:	6422                	ld	s0,8(sp)
    80001828:	0141                	addi	sp,sp,16
    8000182a:	8082                	ret

000000008000182c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000182c:	1101                	addi	sp,sp,-32
    8000182e:	ec06                	sd	ra,24(sp)
    80001830:	e822                	sd	s0,16(sp)
    80001832:	e426                	sd	s1,8(sp)
    80001834:	1000                	addi	s0,sp,32
  push_off();
    80001836:	b24ff0ef          	jal	ra,80000b5a <push_off>
    8000183a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000183c:	2781                	sext.w	a5,a5
    8000183e:	079e                	slli	a5,a5,0x7
    80001840:	0000e717          	auipc	a4,0xe
    80001844:	1f070713          	addi	a4,a4,496 # 8000fa30 <pid_lock>
    80001848:	97ba                	add	a5,a5,a4
    8000184a:	7b84                	ld	s1,48(a5)
  pop_off();
    8000184c:	b92ff0ef          	jal	ra,80000bde <pop_off>
  return p;
}
    80001850:	8526                	mv	a0,s1
    80001852:	60e2                	ld	ra,24(sp)
    80001854:	6442                	ld	s0,16(sp)
    80001856:	64a2                	ld	s1,8(sp)
    80001858:	6105                	addi	sp,sp,32
    8000185a:	8082                	ret

000000008000185c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000185c:	1141                	addi	sp,sp,-16
    8000185e:	e406                	sd	ra,8(sp)
    80001860:	e022                	sd	s0,0(sp)
    80001862:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001864:	fc9ff0ef          	jal	ra,8000182c <myproc>
    80001868:	bcaff0ef          	jal	ra,80000c32 <release>

  if (first) {
    8000186c:	00006797          	auipc	a5,0x6
    80001870:	0147a783          	lw	a5,20(a5) # 80007880 <first.1>
    80001874:	e799                	bnez	a5,80001882 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001876:	2bb000ef          	jal	ra,80002330 <usertrapret>
}
    8000187a:	60a2                	ld	ra,8(sp)
    8000187c:	6402                	ld	s0,0(sp)
    8000187e:	0141                	addi	sp,sp,16
    80001880:	8082                	ret
    fsinit(ROOTDEV);
    80001882:	4505                	li	a0,1
    80001884:	636010ef          	jal	ra,80002eba <fsinit>
    first = 0;
    80001888:	00006797          	auipc	a5,0x6
    8000188c:	fe07ac23          	sw	zero,-8(a5) # 80007880 <first.1>
    __sync_synchronize();
    80001890:	0ff0000f          	fence
    80001894:	b7cd                	j	80001876 <forkret+0x1a>

0000000080001896 <allocpid>:
{
    80001896:	1101                	addi	sp,sp,-32
    80001898:	ec06                	sd	ra,24(sp)
    8000189a:	e822                	sd	s0,16(sp)
    8000189c:	e426                	sd	s1,8(sp)
    8000189e:	e04a                	sd	s2,0(sp)
    800018a0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018a2:	0000e917          	auipc	s2,0xe
    800018a6:	18e90913          	addi	s2,s2,398 # 8000fa30 <pid_lock>
    800018aa:	854a                	mv	a0,s2
    800018ac:	aeeff0ef          	jal	ra,80000b9a <acquire>
  pid = nextpid;
    800018b0:	00006797          	auipc	a5,0x6
    800018b4:	fd478793          	addi	a5,a5,-44 # 80007884 <nextpid>
    800018b8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018ba:	0014871b          	addiw	a4,s1,1
    800018be:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018c0:	854a                	mv	a0,s2
    800018c2:	b70ff0ef          	jal	ra,80000c32 <release>
}
    800018c6:	8526                	mv	a0,s1
    800018c8:	60e2                	ld	ra,24(sp)
    800018ca:	6442                	ld	s0,16(sp)
    800018cc:	64a2                	ld	s1,8(sp)
    800018ce:	6902                	ld	s2,0(sp)
    800018d0:	6105                	addi	sp,sp,32
    800018d2:	8082                	ret

00000000800018d4 <proc_pagetable>:
{
    800018d4:	1101                	addi	sp,sp,-32
    800018d6:	ec06                	sd	ra,24(sp)
    800018d8:	e822                	sd	s0,16(sp)
    800018da:	e426                	sd	s1,8(sp)
    800018dc:	e04a                	sd	s2,0(sp)
    800018de:	1000                	addi	s0,sp,32
    800018e0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800018e2:	933ff0ef          	jal	ra,80001214 <uvmcreate>
    800018e6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800018e8:	cd05                	beqz	a0,80001920 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800018ea:	4729                	li	a4,10
    800018ec:	00004697          	auipc	a3,0x4
    800018f0:	71468693          	addi	a3,a3,1812 # 80006000 <_trampoline>
    800018f4:	6605                	lui	a2,0x1
    800018f6:	040005b7          	lui	a1,0x4000
    800018fa:	15fd                	addi	a1,a1,-1
    800018fc:	05b2                	slli	a1,a1,0xc
    800018fe:	ec4ff0ef          	jal	ra,80000fc2 <mappages>
    80001902:	02054663          	bltz	a0,8000192e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001906:	4719                	li	a4,6
    80001908:	05893683          	ld	a3,88(s2)
    8000190c:	6605                	lui	a2,0x1
    8000190e:	020005b7          	lui	a1,0x2000
    80001912:	15fd                	addi	a1,a1,-1
    80001914:	05b6                	slli	a1,a1,0xd
    80001916:	8526                	mv	a0,s1
    80001918:	eaaff0ef          	jal	ra,80000fc2 <mappages>
    8000191c:	00054f63          	bltz	a0,8000193a <proc_pagetable+0x66>
}
    80001920:	8526                	mv	a0,s1
    80001922:	60e2                	ld	ra,24(sp)
    80001924:	6442                	ld	s0,16(sp)
    80001926:	64a2                	ld	s1,8(sp)
    80001928:	6902                	ld	s2,0(sp)
    8000192a:	6105                	addi	sp,sp,32
    8000192c:	8082                	ret
    uvmfree(pagetable, 0);
    8000192e:	4581                	li	a1,0
    80001930:	8526                	mv	a0,s1
    80001932:	aa3ff0ef          	jal	ra,800013d4 <uvmfree>
    return 0;
    80001936:	4481                	li	s1,0
    80001938:	b7e5                	j	80001920 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000193a:	4681                	li	a3,0
    8000193c:	4605                	li	a2,1
    8000193e:	040005b7          	lui	a1,0x4000
    80001942:	15fd                	addi	a1,a1,-1
    80001944:	05b2                	slli	a1,a1,0xc
    80001946:	8526                	mv	a0,s1
    80001948:	821ff0ef          	jal	ra,80001168 <uvmunmap>
    uvmfree(pagetable, 0);
    8000194c:	4581                	li	a1,0
    8000194e:	8526                	mv	a0,s1
    80001950:	a85ff0ef          	jal	ra,800013d4 <uvmfree>
    return 0;
    80001954:	4481                	li	s1,0
    80001956:	b7e9                	j	80001920 <proc_pagetable+0x4c>

0000000080001958 <proc_freepagetable>:
{
    80001958:	1101                	addi	sp,sp,-32
    8000195a:	ec06                	sd	ra,24(sp)
    8000195c:	e822                	sd	s0,16(sp)
    8000195e:	e426                	sd	s1,8(sp)
    80001960:	e04a                	sd	s2,0(sp)
    80001962:	1000                	addi	s0,sp,32
    80001964:	84aa                	mv	s1,a0
    80001966:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001968:	4681                	li	a3,0
    8000196a:	4605                	li	a2,1
    8000196c:	040005b7          	lui	a1,0x4000
    80001970:	15fd                	addi	a1,a1,-1
    80001972:	05b2                	slli	a1,a1,0xc
    80001974:	ff4ff0ef          	jal	ra,80001168 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001978:	4681                	li	a3,0
    8000197a:	4605                	li	a2,1
    8000197c:	020005b7          	lui	a1,0x2000
    80001980:	15fd                	addi	a1,a1,-1
    80001982:	05b6                	slli	a1,a1,0xd
    80001984:	8526                	mv	a0,s1
    80001986:	fe2ff0ef          	jal	ra,80001168 <uvmunmap>
  uvmfree(pagetable, sz);
    8000198a:	85ca                	mv	a1,s2
    8000198c:	8526                	mv	a0,s1
    8000198e:	a47ff0ef          	jal	ra,800013d4 <uvmfree>
}
    80001992:	60e2                	ld	ra,24(sp)
    80001994:	6442                	ld	s0,16(sp)
    80001996:	64a2                	ld	s1,8(sp)
    80001998:	6902                	ld	s2,0(sp)
    8000199a:	6105                	addi	sp,sp,32
    8000199c:	8082                	ret

000000008000199e <freeproc>:
{
    8000199e:	1101                	addi	sp,sp,-32
    800019a0:	ec06                	sd	ra,24(sp)
    800019a2:	e822                	sd	s0,16(sp)
    800019a4:	e426                	sd	s1,8(sp)
    800019a6:	1000                	addi	s0,sp,32
    800019a8:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019aa:	6d28                	ld	a0,88(a0)
    800019ac:	c119                	beqz	a0,800019b2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019ae:	83cff0ef          	jal	ra,800009ea <kfree>
  p->trapframe = 0;
    800019b2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019b6:	68a8                	ld	a0,80(s1)
    800019b8:	c501                	beqz	a0,800019c0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019ba:	64ac                	ld	a1,72(s1)
    800019bc:	f9dff0ef          	jal	ra,80001958 <proc_freepagetable>
  p->pagetable = 0;
    800019c0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800019c4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800019c8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800019cc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800019d0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800019d4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800019d8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800019dc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800019e0:	0004ac23          	sw	zero,24(s1)
}
    800019e4:	60e2                	ld	ra,24(sp)
    800019e6:	6442                	ld	s0,16(sp)
    800019e8:	64a2                	ld	s1,8(sp)
    800019ea:	6105                	addi	sp,sp,32
    800019ec:	8082                	ret

00000000800019ee <allocproc>:
{
    800019ee:	1101                	addi	sp,sp,-32
    800019f0:	ec06                	sd	ra,24(sp)
    800019f2:	e822                	sd	s0,16(sp)
    800019f4:	e426                	sd	s1,8(sp)
    800019f6:	e04a                	sd	s2,0(sp)
    800019f8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800019fa:	0000e497          	auipc	s1,0xe
    800019fe:	46648493          	addi	s1,s1,1126 # 8000fe60 <proc>
    80001a02:	00014917          	auipc	s2,0x14
    80001a06:	e5e90913          	addi	s2,s2,-418 # 80015860 <tickslock>
    acquire(&p->lock);
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	98eff0ef          	jal	ra,80000b9a <acquire>
    if(p->state == UNUSED) {
    80001a10:	4c9c                	lw	a5,24(s1)
    80001a12:	cb91                	beqz	a5,80001a26 <allocproc+0x38>
      release(&p->lock);
    80001a14:	8526                	mv	a0,s1
    80001a16:	a1cff0ef          	jal	ra,80000c32 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a1a:	16848493          	addi	s1,s1,360
    80001a1e:	ff2496e3          	bne	s1,s2,80001a0a <allocproc+0x1c>
  return 0;
    80001a22:	4481                	li	s1,0
    80001a24:	a089                	j	80001a66 <allocproc+0x78>
  p->pid = allocpid();
    80001a26:	e71ff0ef          	jal	ra,80001896 <allocpid>
    80001a2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a2c:	4785                	li	a5,1
    80001a2e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a30:	89aff0ef          	jal	ra,80000aca <kalloc>
    80001a34:	892a                	mv	s2,a0
    80001a36:	eca8                	sd	a0,88(s1)
    80001a38:	cd15                	beqz	a0,80001a74 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001a3a:	8526                	mv	a0,s1
    80001a3c:	e99ff0ef          	jal	ra,800018d4 <proc_pagetable>
    80001a40:	892a                	mv	s2,a0
    80001a42:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a44:	c121                	beqz	a0,80001a84 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001a46:	07000613          	li	a2,112
    80001a4a:	4581                	li	a1,0
    80001a4c:	06048513          	addi	a0,s1,96
    80001a50:	a1eff0ef          	jal	ra,80000c6e <memset>
  p->context.ra = (uint64)forkret;
    80001a54:	00000797          	auipc	a5,0x0
    80001a58:	e0878793          	addi	a5,a5,-504 # 8000185c <forkret>
    80001a5c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001a5e:	60bc                	ld	a5,64(s1)
    80001a60:	6705                	lui	a4,0x1
    80001a62:	97ba                	add	a5,a5,a4
    80001a64:	f4bc                	sd	a5,104(s1)
}
    80001a66:	8526                	mv	a0,s1
    80001a68:	60e2                	ld	ra,24(sp)
    80001a6a:	6442                	ld	s0,16(sp)
    80001a6c:	64a2                	ld	s1,8(sp)
    80001a6e:	6902                	ld	s2,0(sp)
    80001a70:	6105                	addi	sp,sp,32
    80001a72:	8082                	ret
    freeproc(p);
    80001a74:	8526                	mv	a0,s1
    80001a76:	f29ff0ef          	jal	ra,8000199e <freeproc>
    release(&p->lock);
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	9b6ff0ef          	jal	ra,80000c32 <release>
    return 0;
    80001a80:	84ca                	mv	s1,s2
    80001a82:	b7d5                	j	80001a66 <allocproc+0x78>
    freeproc(p);
    80001a84:	8526                	mv	a0,s1
    80001a86:	f19ff0ef          	jal	ra,8000199e <freeproc>
    release(&p->lock);
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	9a6ff0ef          	jal	ra,80000c32 <release>
    return 0;
    80001a90:	84ca                	mv	s1,s2
    80001a92:	bfd1                	j	80001a66 <allocproc+0x78>

0000000080001a94 <userinit>:
{
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001a9e:	f51ff0ef          	jal	ra,800019ee <allocproc>
    80001aa2:	84aa                	mv	s1,a0
  initproc = p;
    80001aa4:	00006797          	auipc	a5,0x6
    80001aa8:	e4a7ba23          	sd	a0,-428(a5) # 800078f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001aac:	03400613          	li	a2,52
    80001ab0:	00006597          	auipc	a1,0x6
    80001ab4:	de058593          	addi	a1,a1,-544 # 80007890 <initcode>
    80001ab8:	6928                	ld	a0,80(a0)
    80001aba:	f80ff0ef          	jal	ra,8000123a <uvmfirst>
  p->sz = PGSIZE;
    80001abe:	6785                	lui	a5,0x1
    80001ac0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ac2:	6cb8                	ld	a4,88(s1)
    80001ac4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ac8:	6cb8                	ld	a4,88(s1)
    80001aca:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001acc:	4641                	li	a2,16
    80001ace:	00005597          	auipc	a1,0x5
    80001ad2:	76a58593          	addi	a1,a1,1898 # 80007238 <digits+0x200>
    80001ad6:	15848513          	addi	a0,s1,344
    80001ada:	adaff0ef          	jal	ra,80000db4 <safestrcpy>
  p->cwd = namei("/");
    80001ade:	00005517          	auipc	a0,0x5
    80001ae2:	76a50513          	addi	a0,a0,1898 # 80007248 <digits+0x210>
    80001ae6:	4b3010ef          	jal	ra,80003798 <namei>
    80001aea:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001aee:	478d                	li	a5,3
    80001af0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001af2:	8526                	mv	a0,s1
    80001af4:	93eff0ef          	jal	ra,80000c32 <release>
}
    80001af8:	60e2                	ld	ra,24(sp)
    80001afa:	6442                	ld	s0,16(sp)
    80001afc:	64a2                	ld	s1,8(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <growproc>:
{
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	e04a                	sd	s2,0(sp)
    80001b0c:	1000                	addi	s0,sp,32
    80001b0e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001b10:	d1dff0ef          	jal	ra,8000182c <myproc>
    80001b14:	84aa                	mv	s1,a0
  sz = p->sz;
    80001b16:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b18:	01204c63          	bgtz	s2,80001b30 <growproc+0x2e>
  } else if(n < 0){
    80001b1c:	02094463          	bltz	s2,80001b44 <growproc+0x42>
  p->sz = sz;
    80001b20:	e4ac                	sd	a1,72(s1)
  return 0;
    80001b22:	4501                	li	a0,0
}
    80001b24:	60e2                	ld	ra,24(sp)
    80001b26:	6442                	ld	s0,16(sp)
    80001b28:	64a2                	ld	s1,8(sp)
    80001b2a:	6902                	ld	s2,0(sp)
    80001b2c:	6105                	addi	sp,sp,32
    80001b2e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b30:	4691                	li	a3,4
    80001b32:	00b90633          	add	a2,s2,a1
    80001b36:	6928                	ld	a0,80(a0)
    80001b38:	fa4ff0ef          	jal	ra,800012dc <uvmalloc>
    80001b3c:	85aa                	mv	a1,a0
    80001b3e:	f16d                	bnez	a0,80001b20 <growproc+0x1e>
      return -1;
    80001b40:	557d                	li	a0,-1
    80001b42:	b7cd                	j	80001b24 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b44:	00b90633          	add	a2,s2,a1
    80001b48:	6928                	ld	a0,80(a0)
    80001b4a:	f4eff0ef          	jal	ra,80001298 <uvmdealloc>
    80001b4e:	85aa                	mv	a1,a0
    80001b50:	bfc1                	j	80001b20 <growproc+0x1e>

0000000080001b52 <fork>:
{
    80001b52:	7139                	addi	sp,sp,-64
    80001b54:	fc06                	sd	ra,56(sp)
    80001b56:	f822                	sd	s0,48(sp)
    80001b58:	f426                	sd	s1,40(sp)
    80001b5a:	f04a                	sd	s2,32(sp)
    80001b5c:	ec4e                	sd	s3,24(sp)
    80001b5e:	e852                	sd	s4,16(sp)
    80001b60:	e456                	sd	s5,8(sp)
    80001b62:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b64:	cc9ff0ef          	jal	ra,8000182c <myproc>
    80001b68:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b6a:	e85ff0ef          	jal	ra,800019ee <allocproc>
    80001b6e:	0e050663          	beqz	a0,80001c5a <fork+0x108>
    80001b72:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001b74:	048ab603          	ld	a2,72(s5)
    80001b78:	692c                	ld	a1,80(a0)
    80001b7a:	050ab503          	ld	a0,80(s5)
    80001b7e:	887ff0ef          	jal	ra,80001404 <uvmcopy>
    80001b82:	04054863          	bltz	a0,80001bd2 <fork+0x80>
  np->sz = p->sz;
    80001b86:	048ab783          	ld	a5,72(s5)
    80001b8a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001b8e:	058ab683          	ld	a3,88(s5)
    80001b92:	87b6                	mv	a5,a3
    80001b94:	058a3703          	ld	a4,88(s4)
    80001b98:	12068693          	addi	a3,a3,288
    80001b9c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ba0:	6788                	ld	a0,8(a5)
    80001ba2:	6b8c                	ld	a1,16(a5)
    80001ba4:	6f90                	ld	a2,24(a5)
    80001ba6:	01073023          	sd	a6,0(a4)
    80001baa:	e708                	sd	a0,8(a4)
    80001bac:	eb0c                	sd	a1,16(a4)
    80001bae:	ef10                	sd	a2,24(a4)
    80001bb0:	02078793          	addi	a5,a5,32
    80001bb4:	02070713          	addi	a4,a4,32
    80001bb8:	fed792e3          	bne	a5,a3,80001b9c <fork+0x4a>
  np->trapframe->a0 = 0;
    80001bbc:	058a3783          	ld	a5,88(s4)
    80001bc0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001bc4:	0d0a8493          	addi	s1,s5,208
    80001bc8:	0d0a0913          	addi	s2,s4,208
    80001bcc:	150a8993          	addi	s3,s5,336
    80001bd0:	a829                	j	80001bea <fork+0x98>
    freeproc(np);
    80001bd2:	8552                	mv	a0,s4
    80001bd4:	dcbff0ef          	jal	ra,8000199e <freeproc>
    release(&np->lock);
    80001bd8:	8552                	mv	a0,s4
    80001bda:	858ff0ef          	jal	ra,80000c32 <release>
    return -1;
    80001bde:	597d                	li	s2,-1
    80001be0:	a09d                	j	80001c46 <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001be2:	04a1                	addi	s1,s1,8
    80001be4:	0921                	addi	s2,s2,8
    80001be6:	01348963          	beq	s1,s3,80001bf8 <fork+0xa6>
    if(p->ofile[i])
    80001bea:	6088                	ld	a0,0(s1)
    80001bec:	d97d                	beqz	a0,80001be2 <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001bee:	158020ef          	jal	ra,80003d46 <filedup>
    80001bf2:	00a93023          	sd	a0,0(s2)
    80001bf6:	b7f5                	j	80001be2 <fork+0x90>
  np->cwd = idup(p->cwd);
    80001bf8:	150ab503          	ld	a0,336(s5)
    80001bfc:	4b4010ef          	jal	ra,800030b0 <idup>
    80001c00:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c04:	4641                	li	a2,16
    80001c06:	158a8593          	addi	a1,s5,344
    80001c0a:	158a0513          	addi	a0,s4,344
    80001c0e:	9a6ff0ef          	jal	ra,80000db4 <safestrcpy>
  pid = np->pid;
    80001c12:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c16:	8552                	mv	a0,s4
    80001c18:	81aff0ef          	jal	ra,80000c32 <release>
  acquire(&wait_lock);
    80001c1c:	0000e497          	auipc	s1,0xe
    80001c20:	e2c48493          	addi	s1,s1,-468 # 8000fa48 <wait_lock>
    80001c24:	8526                	mv	a0,s1
    80001c26:	f75fe0ef          	jal	ra,80000b9a <acquire>
  np->parent = p;
    80001c2a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c2e:	8526                	mv	a0,s1
    80001c30:	802ff0ef          	jal	ra,80000c32 <release>
  acquire(&np->lock);
    80001c34:	8552                	mv	a0,s4
    80001c36:	f65fe0ef          	jal	ra,80000b9a <acquire>
  np->state = RUNNABLE;
    80001c3a:	478d                	li	a5,3
    80001c3c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c40:	8552                	mv	a0,s4
    80001c42:	ff1fe0ef          	jal	ra,80000c32 <release>
}
    80001c46:	854a                	mv	a0,s2
    80001c48:	70e2                	ld	ra,56(sp)
    80001c4a:	7442                	ld	s0,48(sp)
    80001c4c:	74a2                	ld	s1,40(sp)
    80001c4e:	7902                	ld	s2,32(sp)
    80001c50:	69e2                	ld	s3,24(sp)
    80001c52:	6a42                	ld	s4,16(sp)
    80001c54:	6aa2                	ld	s5,8(sp)
    80001c56:	6121                	addi	sp,sp,64
    80001c58:	8082                	ret
    return -1;
    80001c5a:	597d                	li	s2,-1
    80001c5c:	b7ed                	j	80001c46 <fork+0xf4>

0000000080001c5e <scheduler>:
{
    80001c5e:	715d                	addi	sp,sp,-80
    80001c60:	e486                	sd	ra,72(sp)
    80001c62:	e0a2                	sd	s0,64(sp)
    80001c64:	fc26                	sd	s1,56(sp)
    80001c66:	f84a                	sd	s2,48(sp)
    80001c68:	f44e                	sd	s3,40(sp)
    80001c6a:	f052                	sd	s4,32(sp)
    80001c6c:	ec56                	sd	s5,24(sp)
    80001c6e:	e85a                	sd	s6,16(sp)
    80001c70:	e45e                	sd	s7,8(sp)
    80001c72:	e062                	sd	s8,0(sp)
    80001c74:	0880                	addi	s0,sp,80
    80001c76:	8792                	mv	a5,tp
  int id = r_tp();
    80001c78:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c7a:	00779b13          	slli	s6,a5,0x7
    80001c7e:	0000e717          	auipc	a4,0xe
    80001c82:	db270713          	addi	a4,a4,-590 # 8000fa30 <pid_lock>
    80001c86:	975a                	add	a4,a4,s6
    80001c88:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001c8c:	0000e717          	auipc	a4,0xe
    80001c90:	ddc70713          	addi	a4,a4,-548 # 8000fa68 <cpus+0x8>
    80001c94:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001c96:	4c11                	li	s8,4
        c->proc = p;
    80001c98:	079e                	slli	a5,a5,0x7
    80001c9a:	0000ea17          	auipc	s4,0xe
    80001c9e:	d96a0a13          	addi	s4,s4,-618 # 8000fa30 <pid_lock>
    80001ca2:	9a3e                	add	s4,s4,a5
        found = 1;
    80001ca4:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ca6:	00014997          	auipc	s3,0x14
    80001caa:	bba98993          	addi	s3,s3,-1094 # 80015860 <tickslock>
    80001cae:	a0a9                	j	80001cf8 <scheduler+0x9a>
      release(&p->lock);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	f81fe0ef          	jal	ra,80000c32 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cb6:	16848493          	addi	s1,s1,360
    80001cba:	03348563          	beq	s1,s3,80001ce4 <scheduler+0x86>
      acquire(&p->lock);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	edbfe0ef          	jal	ra,80000b9a <acquire>
      if(p->state == RUNNABLE) {
    80001cc4:	4c9c                	lw	a5,24(s1)
    80001cc6:	ff2795e3          	bne	a5,s2,80001cb0 <scheduler+0x52>
        p->state = RUNNING;
    80001cca:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001cce:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001cd2:	06048593          	addi	a1,s1,96
    80001cd6:	855a                	mv	a0,s6
    80001cd8:	5b2000ef          	jal	ra,8000228a <swtch>
        c->proc = 0;
    80001cdc:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ce0:	8ade                	mv	s5,s7
    80001ce2:	b7f9                	j	80001cb0 <scheduler+0x52>
    if(found == 0) {
    80001ce4:	000a9a63          	bnez	s5,80001cf8 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ce8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cf0:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001cf4:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cf8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cfc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d00:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001d04:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d06:	0000e497          	auipc	s1,0xe
    80001d0a:	15a48493          	addi	s1,s1,346 # 8000fe60 <proc>
      if(p->state == RUNNABLE) {
    80001d0e:	490d                	li	s2,3
    80001d10:	b77d                	j	80001cbe <scheduler+0x60>

0000000080001d12 <sched>:
{
    80001d12:	7179                	addi	sp,sp,-48
    80001d14:	f406                	sd	ra,40(sp)
    80001d16:	f022                	sd	s0,32(sp)
    80001d18:	ec26                	sd	s1,24(sp)
    80001d1a:	e84a                	sd	s2,16(sp)
    80001d1c:	e44e                	sd	s3,8(sp)
    80001d1e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d20:	b0dff0ef          	jal	ra,8000182c <myproc>
    80001d24:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d26:	e0bfe0ef          	jal	ra,80000b30 <holding>
    80001d2a:	c92d                	beqz	a0,80001d9c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d2c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d2e:	2781                	sext.w	a5,a5
    80001d30:	079e                	slli	a5,a5,0x7
    80001d32:	0000e717          	auipc	a4,0xe
    80001d36:	cfe70713          	addi	a4,a4,-770 # 8000fa30 <pid_lock>
    80001d3a:	97ba                	add	a5,a5,a4
    80001d3c:	0a87a703          	lw	a4,168(a5)
    80001d40:	4785                	li	a5,1
    80001d42:	06f71363          	bne	a4,a5,80001da8 <sched+0x96>
  if(p->state == RUNNING)
    80001d46:	4c98                	lw	a4,24(s1)
    80001d48:	4791                	li	a5,4
    80001d4a:	06f70563          	beq	a4,a5,80001db4 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d54:	e7b5                	bnez	a5,80001dc0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d56:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d58:	0000e917          	auipc	s2,0xe
    80001d5c:	cd890913          	addi	s2,s2,-808 # 8000fa30 <pid_lock>
    80001d60:	2781                	sext.w	a5,a5
    80001d62:	079e                	slli	a5,a5,0x7
    80001d64:	97ca                	add	a5,a5,s2
    80001d66:	0ac7a983          	lw	s3,172(a5)
    80001d6a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001d6c:	2781                	sext.w	a5,a5
    80001d6e:	079e                	slli	a5,a5,0x7
    80001d70:	0000e597          	auipc	a1,0xe
    80001d74:	cf858593          	addi	a1,a1,-776 # 8000fa68 <cpus+0x8>
    80001d78:	95be                	add	a1,a1,a5
    80001d7a:	06048513          	addi	a0,s1,96
    80001d7e:	50c000ef          	jal	ra,8000228a <swtch>
    80001d82:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001d84:	2781                	sext.w	a5,a5
    80001d86:	079e                	slli	a5,a5,0x7
    80001d88:	97ca                	add	a5,a5,s2
    80001d8a:	0b37a623          	sw	s3,172(a5)
}
    80001d8e:	70a2                	ld	ra,40(sp)
    80001d90:	7402                	ld	s0,32(sp)
    80001d92:	64e2                	ld	s1,24(sp)
    80001d94:	6942                	ld	s2,16(sp)
    80001d96:	69a2                	ld	s3,8(sp)
    80001d98:	6145                	addi	sp,sp,48
    80001d9a:	8082                	ret
    panic("sched p->lock");
    80001d9c:	00005517          	auipc	a0,0x5
    80001da0:	4b450513          	addi	a0,a0,1204 # 80007250 <digits+0x218>
    80001da4:	9b3fe0ef          	jal	ra,80000756 <panic>
    panic("sched locks");
    80001da8:	00005517          	auipc	a0,0x5
    80001dac:	4b850513          	addi	a0,a0,1208 # 80007260 <digits+0x228>
    80001db0:	9a7fe0ef          	jal	ra,80000756 <panic>
    panic("sched running");
    80001db4:	00005517          	auipc	a0,0x5
    80001db8:	4bc50513          	addi	a0,a0,1212 # 80007270 <digits+0x238>
    80001dbc:	99bfe0ef          	jal	ra,80000756 <panic>
    panic("sched interruptible");
    80001dc0:	00005517          	auipc	a0,0x5
    80001dc4:	4c050513          	addi	a0,a0,1216 # 80007280 <digits+0x248>
    80001dc8:	98ffe0ef          	jal	ra,80000756 <panic>

0000000080001dcc <yield>:
{
    80001dcc:	1101                	addi	sp,sp,-32
    80001dce:	ec06                	sd	ra,24(sp)
    80001dd0:	e822                	sd	s0,16(sp)
    80001dd2:	e426                	sd	s1,8(sp)
    80001dd4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001dd6:	a57ff0ef          	jal	ra,8000182c <myproc>
    80001dda:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ddc:	dbffe0ef          	jal	ra,80000b9a <acquire>
  p->state = RUNNABLE;
    80001de0:	478d                	li	a5,3
    80001de2:	cc9c                	sw	a5,24(s1)
  sched();
    80001de4:	f2fff0ef          	jal	ra,80001d12 <sched>
  release(&p->lock);
    80001de8:	8526                	mv	a0,s1
    80001dea:	e49fe0ef          	jal	ra,80000c32 <release>
}
    80001dee:	60e2                	ld	ra,24(sp)
    80001df0:	6442                	ld	s0,16(sp)
    80001df2:	64a2                	ld	s1,8(sp)
    80001df4:	6105                	addi	sp,sp,32
    80001df6:	8082                	ret

0000000080001df8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001df8:	7179                	addi	sp,sp,-48
    80001dfa:	f406                	sd	ra,40(sp)
    80001dfc:	f022                	sd	s0,32(sp)
    80001dfe:	ec26                	sd	s1,24(sp)
    80001e00:	e84a                	sd	s2,16(sp)
    80001e02:	e44e                	sd	s3,8(sp)
    80001e04:	1800                	addi	s0,sp,48
    80001e06:	89aa                	mv	s3,a0
    80001e08:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e0a:	a23ff0ef          	jal	ra,8000182c <myproc>
    80001e0e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e10:	d8bfe0ef          	jal	ra,80000b9a <acquire>
  release(lk);
    80001e14:	854a                	mv	a0,s2
    80001e16:	e1dfe0ef          	jal	ra,80000c32 <release>

  // Go to sleep.
  p->chan = chan;
    80001e1a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e1e:	4789                	li	a5,2
    80001e20:	cc9c                	sw	a5,24(s1)

  sched();
    80001e22:	ef1ff0ef          	jal	ra,80001d12 <sched>

  // Tidy up.
  p->chan = 0;
    80001e26:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e2a:	8526                	mv	a0,s1
    80001e2c:	e07fe0ef          	jal	ra,80000c32 <release>
  acquire(lk);
    80001e30:	854a                	mv	a0,s2
    80001e32:	d69fe0ef          	jal	ra,80000b9a <acquire>
}
    80001e36:	70a2                	ld	ra,40(sp)
    80001e38:	7402                	ld	s0,32(sp)
    80001e3a:	64e2                	ld	s1,24(sp)
    80001e3c:	6942                	ld	s2,16(sp)
    80001e3e:	69a2                	ld	s3,8(sp)
    80001e40:	6145                	addi	sp,sp,48
    80001e42:	8082                	ret

0000000080001e44 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001e44:	7139                	addi	sp,sp,-64
    80001e46:	fc06                	sd	ra,56(sp)
    80001e48:	f822                	sd	s0,48(sp)
    80001e4a:	f426                	sd	s1,40(sp)
    80001e4c:	f04a                	sd	s2,32(sp)
    80001e4e:	ec4e                	sd	s3,24(sp)
    80001e50:	e852                	sd	s4,16(sp)
    80001e52:	e456                	sd	s5,8(sp)
    80001e54:	0080                	addi	s0,sp,64
    80001e56:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001e58:	0000e497          	auipc	s1,0xe
    80001e5c:	00848493          	addi	s1,s1,8 # 8000fe60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001e60:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001e62:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e64:	00014917          	auipc	s2,0x14
    80001e68:	9fc90913          	addi	s2,s2,-1540 # 80015860 <tickslock>
    80001e6c:	a801                	j	80001e7c <wakeup+0x38>
      }
      release(&p->lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	dc3fe0ef          	jal	ra,80000c32 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e74:	16848493          	addi	s1,s1,360
    80001e78:	03248263          	beq	s1,s2,80001e9c <wakeup+0x58>
    if(p != myproc()){
    80001e7c:	9b1ff0ef          	jal	ra,8000182c <myproc>
    80001e80:	fea48ae3          	beq	s1,a0,80001e74 <wakeup+0x30>
      acquire(&p->lock);
    80001e84:	8526                	mv	a0,s1
    80001e86:	d15fe0ef          	jal	ra,80000b9a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001e8a:	4c9c                	lw	a5,24(s1)
    80001e8c:	ff3791e3          	bne	a5,s3,80001e6e <wakeup+0x2a>
    80001e90:	709c                	ld	a5,32(s1)
    80001e92:	fd479ee3          	bne	a5,s4,80001e6e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001e96:	0154ac23          	sw	s5,24(s1)
    80001e9a:	bfd1                	j	80001e6e <wakeup+0x2a>
    }
  }
}
    80001e9c:	70e2                	ld	ra,56(sp)
    80001e9e:	7442                	ld	s0,48(sp)
    80001ea0:	74a2                	ld	s1,40(sp)
    80001ea2:	7902                	ld	s2,32(sp)
    80001ea4:	69e2                	ld	s3,24(sp)
    80001ea6:	6a42                	ld	s4,16(sp)
    80001ea8:	6aa2                	ld	s5,8(sp)
    80001eaa:	6121                	addi	sp,sp,64
    80001eac:	8082                	ret

0000000080001eae <reparent>:
{
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	e052                	sd	s4,0(sp)
    80001ebc:	1800                	addi	s0,sp,48
    80001ebe:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ec0:	0000e497          	auipc	s1,0xe
    80001ec4:	fa048493          	addi	s1,s1,-96 # 8000fe60 <proc>
      pp->parent = initproc;
    80001ec8:	00006a17          	auipc	s4,0x6
    80001ecc:	a30a0a13          	addi	s4,s4,-1488 # 800078f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ed0:	00014997          	auipc	s3,0x14
    80001ed4:	99098993          	addi	s3,s3,-1648 # 80015860 <tickslock>
    80001ed8:	a029                	j	80001ee2 <reparent+0x34>
    80001eda:	16848493          	addi	s1,s1,360
    80001ede:	01348b63          	beq	s1,s3,80001ef4 <reparent+0x46>
    if(pp->parent == p){
    80001ee2:	7c9c                	ld	a5,56(s1)
    80001ee4:	ff279be3          	bne	a5,s2,80001eda <reparent+0x2c>
      pp->parent = initproc;
    80001ee8:	000a3503          	ld	a0,0(s4)
    80001eec:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001eee:	f57ff0ef          	jal	ra,80001e44 <wakeup>
    80001ef2:	b7e5                	j	80001eda <reparent+0x2c>
}
    80001ef4:	70a2                	ld	ra,40(sp)
    80001ef6:	7402                	ld	s0,32(sp)
    80001ef8:	64e2                	ld	s1,24(sp)
    80001efa:	6942                	ld	s2,16(sp)
    80001efc:	69a2                	ld	s3,8(sp)
    80001efe:	6a02                	ld	s4,0(sp)
    80001f00:	6145                	addi	sp,sp,48
    80001f02:	8082                	ret

0000000080001f04 <exit>:
{
    80001f04:	7179                	addi	sp,sp,-48
    80001f06:	f406                	sd	ra,40(sp)
    80001f08:	f022                	sd	s0,32(sp)
    80001f0a:	ec26                	sd	s1,24(sp)
    80001f0c:	e84a                	sd	s2,16(sp)
    80001f0e:	e44e                	sd	s3,8(sp)
    80001f10:	e052                	sd	s4,0(sp)
    80001f12:	1800                	addi	s0,sp,48
    80001f14:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f16:	917ff0ef          	jal	ra,8000182c <myproc>
    80001f1a:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f1c:	00006797          	auipc	a5,0x6
    80001f20:	9dc7b783          	ld	a5,-1572(a5) # 800078f8 <initproc>
    80001f24:	0d050493          	addi	s1,a0,208
    80001f28:	15050913          	addi	s2,a0,336
    80001f2c:	00a79f63          	bne	a5,a0,80001f4a <exit+0x46>
    panic("init exiting");
    80001f30:	00005517          	auipc	a0,0x5
    80001f34:	36850513          	addi	a0,a0,872 # 80007298 <digits+0x260>
    80001f38:	81ffe0ef          	jal	ra,80000756 <panic>
      fileclose(f);
    80001f3c:	651010ef          	jal	ra,80003d8c <fileclose>
      p->ofile[fd] = 0;
    80001f40:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f44:	04a1                	addi	s1,s1,8
    80001f46:	01248563          	beq	s1,s2,80001f50 <exit+0x4c>
    if(p->ofile[fd]){
    80001f4a:	6088                	ld	a0,0(s1)
    80001f4c:	f965                	bnez	a0,80001f3c <exit+0x38>
    80001f4e:	bfdd                	j	80001f44 <exit+0x40>
  begin_op();
    80001f50:	221010ef          	jal	ra,80003970 <begin_op>
  iput(p->cwd);
    80001f54:	1509b503          	ld	a0,336(s3)
    80001f58:	30c010ef          	jal	ra,80003264 <iput>
  end_op();
    80001f5c:	285010ef          	jal	ra,800039e0 <end_op>
  p->cwd = 0;
    80001f60:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001f64:	0000e497          	auipc	s1,0xe
    80001f68:	ae448493          	addi	s1,s1,-1308 # 8000fa48 <wait_lock>
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	c2dfe0ef          	jal	ra,80000b9a <acquire>
  reparent(p);
    80001f72:	854e                	mv	a0,s3
    80001f74:	f3bff0ef          	jal	ra,80001eae <reparent>
  wakeup(p->parent);
    80001f78:	0389b503          	ld	a0,56(s3)
    80001f7c:	ec9ff0ef          	jal	ra,80001e44 <wakeup>
  acquire(&p->lock);
    80001f80:	854e                	mv	a0,s3
    80001f82:	c19fe0ef          	jal	ra,80000b9a <acquire>
  p->xstate = status;
    80001f86:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001f8a:	4795                	li	a5,5
    80001f8c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001f90:	8526                	mv	a0,s1
    80001f92:	ca1fe0ef          	jal	ra,80000c32 <release>
  sched();
    80001f96:	d7dff0ef          	jal	ra,80001d12 <sched>
  panic("zombie exit");
    80001f9a:	00005517          	auipc	a0,0x5
    80001f9e:	30e50513          	addi	a0,a0,782 # 800072a8 <digits+0x270>
    80001fa2:	fb4fe0ef          	jal	ra,80000756 <panic>

0000000080001fa6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001fa6:	7179                	addi	sp,sp,-48
    80001fa8:	f406                	sd	ra,40(sp)
    80001faa:	f022                	sd	s0,32(sp)
    80001fac:	ec26                	sd	s1,24(sp)
    80001fae:	e84a                	sd	s2,16(sp)
    80001fb0:	e44e                	sd	s3,8(sp)
    80001fb2:	1800                	addi	s0,sp,48
    80001fb4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001fb6:	0000e497          	auipc	s1,0xe
    80001fba:	eaa48493          	addi	s1,s1,-342 # 8000fe60 <proc>
    80001fbe:	00014997          	auipc	s3,0x14
    80001fc2:	8a298993          	addi	s3,s3,-1886 # 80015860 <tickslock>
    acquire(&p->lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	bd3fe0ef          	jal	ra,80000b9a <acquire>
    if(p->pid == pid){
    80001fcc:	589c                	lw	a5,48(s1)
    80001fce:	01278b63          	beq	a5,s2,80001fe4 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001fd2:	8526                	mv	a0,s1
    80001fd4:	c5ffe0ef          	jal	ra,80000c32 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001fd8:	16848493          	addi	s1,s1,360
    80001fdc:	ff3495e3          	bne	s1,s3,80001fc6 <kill+0x20>
  }
  return -1;
    80001fe0:	557d                	li	a0,-1
    80001fe2:	a819                	j	80001ff8 <kill+0x52>
      p->killed = 1;
    80001fe4:	4785                	li	a5,1
    80001fe6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001fe8:	4c98                	lw	a4,24(s1)
    80001fea:	4789                	li	a5,2
    80001fec:	00f70d63          	beq	a4,a5,80002006 <kill+0x60>
      release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	c41fe0ef          	jal	ra,80000c32 <release>
      return 0;
    80001ff6:	4501                	li	a0,0
}
    80001ff8:	70a2                	ld	ra,40(sp)
    80001ffa:	7402                	ld	s0,32(sp)
    80001ffc:	64e2                	ld	s1,24(sp)
    80001ffe:	6942                	ld	s2,16(sp)
    80002000:	69a2                	ld	s3,8(sp)
    80002002:	6145                	addi	sp,sp,48
    80002004:	8082                	ret
        p->state = RUNNABLE;
    80002006:	478d                	li	a5,3
    80002008:	cc9c                	sw	a5,24(s1)
    8000200a:	b7dd                	j	80001ff0 <kill+0x4a>

000000008000200c <setkilled>:

void
setkilled(struct proc *p)
{
    8000200c:	1101                	addi	sp,sp,-32
    8000200e:	ec06                	sd	ra,24(sp)
    80002010:	e822                	sd	s0,16(sp)
    80002012:	e426                	sd	s1,8(sp)
    80002014:	1000                	addi	s0,sp,32
    80002016:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002018:	b83fe0ef          	jal	ra,80000b9a <acquire>
  p->killed = 1;
    8000201c:	4785                	li	a5,1
    8000201e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002020:	8526                	mv	a0,s1
    80002022:	c11fe0ef          	jal	ra,80000c32 <release>
}
    80002026:	60e2                	ld	ra,24(sp)
    80002028:	6442                	ld	s0,16(sp)
    8000202a:	64a2                	ld	s1,8(sp)
    8000202c:	6105                	addi	sp,sp,32
    8000202e:	8082                	ret

0000000080002030 <killed>:

int
killed(struct proc *p)
{
    80002030:	1101                	addi	sp,sp,-32
    80002032:	ec06                	sd	ra,24(sp)
    80002034:	e822                	sd	s0,16(sp)
    80002036:	e426                	sd	s1,8(sp)
    80002038:	e04a                	sd	s2,0(sp)
    8000203a:	1000                	addi	s0,sp,32
    8000203c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000203e:	b5dfe0ef          	jal	ra,80000b9a <acquire>
  k = p->killed;
    80002042:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	bebfe0ef          	jal	ra,80000c32 <release>
  return k;
}
    8000204c:	854a                	mv	a0,s2
    8000204e:	60e2                	ld	ra,24(sp)
    80002050:	6442                	ld	s0,16(sp)
    80002052:	64a2                	ld	s1,8(sp)
    80002054:	6902                	ld	s2,0(sp)
    80002056:	6105                	addi	sp,sp,32
    80002058:	8082                	ret

000000008000205a <wait>:
{
    8000205a:	715d                	addi	sp,sp,-80
    8000205c:	e486                	sd	ra,72(sp)
    8000205e:	e0a2                	sd	s0,64(sp)
    80002060:	fc26                	sd	s1,56(sp)
    80002062:	f84a                	sd	s2,48(sp)
    80002064:	f44e                	sd	s3,40(sp)
    80002066:	f052                	sd	s4,32(sp)
    80002068:	ec56                	sd	s5,24(sp)
    8000206a:	e85a                	sd	s6,16(sp)
    8000206c:	e45e                	sd	s7,8(sp)
    8000206e:	e062                	sd	s8,0(sp)
    80002070:	0880                	addi	s0,sp,80
    80002072:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002074:	fb8ff0ef          	jal	ra,8000182c <myproc>
    80002078:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000207a:	0000e517          	auipc	a0,0xe
    8000207e:	9ce50513          	addi	a0,a0,-1586 # 8000fa48 <wait_lock>
    80002082:	b19fe0ef          	jal	ra,80000b9a <acquire>
    havekids = 0;
    80002086:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002088:	4a15                	li	s4,5
        havekids = 1;
    8000208a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000208c:	00013997          	auipc	s3,0x13
    80002090:	7d498993          	addi	s3,s3,2004 # 80015860 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002094:	0000ec17          	auipc	s8,0xe
    80002098:	9b4c0c13          	addi	s8,s8,-1612 # 8000fa48 <wait_lock>
    havekids = 0;
    8000209c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000209e:	0000e497          	auipc	s1,0xe
    800020a2:	dc248493          	addi	s1,s1,-574 # 8000fe60 <proc>
    800020a6:	a899                	j	800020fc <wait+0xa2>
          pid = pp->pid;
    800020a8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800020ac:	000b0c63          	beqz	s6,800020c4 <wait+0x6a>
    800020b0:	4691                	li	a3,4
    800020b2:	02c48613          	addi	a2,s1,44
    800020b6:	85da                	mv	a1,s6
    800020b8:	05093503          	ld	a0,80(s2)
    800020bc:	c24ff0ef          	jal	ra,800014e0 <copyout>
    800020c0:	00054f63          	bltz	a0,800020de <wait+0x84>
          freeproc(pp);
    800020c4:	8526                	mv	a0,s1
    800020c6:	8d9ff0ef          	jal	ra,8000199e <freeproc>
          release(&pp->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	b67fe0ef          	jal	ra,80000c32 <release>
          release(&wait_lock);
    800020d0:	0000e517          	auipc	a0,0xe
    800020d4:	97850513          	addi	a0,a0,-1672 # 8000fa48 <wait_lock>
    800020d8:	b5bfe0ef          	jal	ra,80000c32 <release>
          return pid;
    800020dc:	a891                	j	80002130 <wait+0xd6>
            release(&pp->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	b53fe0ef          	jal	ra,80000c32 <release>
            release(&wait_lock);
    800020e4:	0000e517          	auipc	a0,0xe
    800020e8:	96450513          	addi	a0,a0,-1692 # 8000fa48 <wait_lock>
    800020ec:	b47fe0ef          	jal	ra,80000c32 <release>
            return -1;
    800020f0:	59fd                	li	s3,-1
    800020f2:	a83d                	j	80002130 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020f4:	16848493          	addi	s1,s1,360
    800020f8:	03348063          	beq	s1,s3,80002118 <wait+0xbe>
      if(pp->parent == p){
    800020fc:	7c9c                	ld	a5,56(s1)
    800020fe:	ff279be3          	bne	a5,s2,800020f4 <wait+0x9a>
        acquire(&pp->lock);
    80002102:	8526                	mv	a0,s1
    80002104:	a97fe0ef          	jal	ra,80000b9a <acquire>
        if(pp->state == ZOMBIE){
    80002108:	4c9c                	lw	a5,24(s1)
    8000210a:	f9478fe3          	beq	a5,s4,800020a8 <wait+0x4e>
        release(&pp->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	b23fe0ef          	jal	ra,80000c32 <release>
        havekids = 1;
    80002114:	8756                	mv	a4,s5
    80002116:	bff9                	j	800020f4 <wait+0x9a>
    if(!havekids || killed(p)){
    80002118:	c709                	beqz	a4,80002122 <wait+0xc8>
    8000211a:	854a                	mv	a0,s2
    8000211c:	f15ff0ef          	jal	ra,80002030 <killed>
    80002120:	c50d                	beqz	a0,8000214a <wait+0xf0>
      release(&wait_lock);
    80002122:	0000e517          	auipc	a0,0xe
    80002126:	92650513          	addi	a0,a0,-1754 # 8000fa48 <wait_lock>
    8000212a:	b09fe0ef          	jal	ra,80000c32 <release>
      return -1;
    8000212e:	59fd                	li	s3,-1
}
    80002130:	854e                	mv	a0,s3
    80002132:	60a6                	ld	ra,72(sp)
    80002134:	6406                	ld	s0,64(sp)
    80002136:	74e2                	ld	s1,56(sp)
    80002138:	7942                	ld	s2,48(sp)
    8000213a:	79a2                	ld	s3,40(sp)
    8000213c:	7a02                	ld	s4,32(sp)
    8000213e:	6ae2                	ld	s5,24(sp)
    80002140:	6b42                	ld	s6,16(sp)
    80002142:	6ba2                	ld	s7,8(sp)
    80002144:	6c02                	ld	s8,0(sp)
    80002146:	6161                	addi	sp,sp,80
    80002148:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214a:	85e2                	mv	a1,s8
    8000214c:	854a                	mv	a0,s2
    8000214e:	cabff0ef          	jal	ra,80001df8 <sleep>
    havekids = 0;
    80002152:	b7a9                	j	8000209c <wait+0x42>

0000000080002154 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002154:	7179                	addi	sp,sp,-48
    80002156:	f406                	sd	ra,40(sp)
    80002158:	f022                	sd	s0,32(sp)
    8000215a:	ec26                	sd	s1,24(sp)
    8000215c:	e84a                	sd	s2,16(sp)
    8000215e:	e44e                	sd	s3,8(sp)
    80002160:	e052                	sd	s4,0(sp)
    80002162:	1800                	addi	s0,sp,48
    80002164:	84aa                	mv	s1,a0
    80002166:	892e                	mv	s2,a1
    80002168:	89b2                	mv	s3,a2
    8000216a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000216c:	ec0ff0ef          	jal	ra,8000182c <myproc>
  if(user_dst){
    80002170:	cc99                	beqz	s1,8000218e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002172:	86d2                	mv	a3,s4
    80002174:	864e                	mv	a2,s3
    80002176:	85ca                	mv	a1,s2
    80002178:	6928                	ld	a0,80(a0)
    8000217a:	b66ff0ef          	jal	ra,800014e0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6a02                	ld	s4,0(sp)
    8000218a:	6145                	addi	sp,sp,48
    8000218c:	8082                	ret
    memmove((char *)dst, src, len);
    8000218e:	000a061b          	sext.w	a2,s4
    80002192:	85ce                	mv	a1,s3
    80002194:	854a                	mv	a0,s2
    80002196:	b35fe0ef          	jal	ra,80000cca <memmove>
    return 0;
    8000219a:	8526                	mv	a0,s1
    8000219c:	b7cd                	j	8000217e <either_copyout+0x2a>

000000008000219e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000219e:	7179                	addi	sp,sp,-48
    800021a0:	f406                	sd	ra,40(sp)
    800021a2:	f022                	sd	s0,32(sp)
    800021a4:	ec26                	sd	s1,24(sp)
    800021a6:	e84a                	sd	s2,16(sp)
    800021a8:	e44e                	sd	s3,8(sp)
    800021aa:	e052                	sd	s4,0(sp)
    800021ac:	1800                	addi	s0,sp,48
    800021ae:	892a                	mv	s2,a0
    800021b0:	84ae                	mv	s1,a1
    800021b2:	89b2                	mv	s3,a2
    800021b4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021b6:	e76ff0ef          	jal	ra,8000182c <myproc>
  if(user_src){
    800021ba:	cc99                	beqz	s1,800021d8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800021bc:	86d2                	mv	a3,s4
    800021be:	864e                	mv	a2,s3
    800021c0:	85ca                	mv	a1,s2
    800021c2:	6928                	ld	a0,80(a0)
    800021c4:	bd4ff0ef          	jal	ra,80001598 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800021c8:	70a2                	ld	ra,40(sp)
    800021ca:	7402                	ld	s0,32(sp)
    800021cc:	64e2                	ld	s1,24(sp)
    800021ce:	6942                	ld	s2,16(sp)
    800021d0:	69a2                	ld	s3,8(sp)
    800021d2:	6a02                	ld	s4,0(sp)
    800021d4:	6145                	addi	sp,sp,48
    800021d6:	8082                	ret
    memmove(dst, (char*)src, len);
    800021d8:	000a061b          	sext.w	a2,s4
    800021dc:	85ce                	mv	a1,s3
    800021de:	854a                	mv	a0,s2
    800021e0:	aebfe0ef          	jal	ra,80000cca <memmove>
    return 0;
    800021e4:	8526                	mv	a0,s1
    800021e6:	b7cd                	j	800021c8 <either_copyin+0x2a>

00000000800021e8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800021e8:	715d                	addi	sp,sp,-80
    800021ea:	e486                	sd	ra,72(sp)
    800021ec:	e0a2                	sd	s0,64(sp)
    800021ee:	fc26                	sd	s1,56(sp)
    800021f0:	f84a                	sd	s2,48(sp)
    800021f2:	f44e                	sd	s3,40(sp)
    800021f4:	f052                	sd	s4,32(sp)
    800021f6:	ec56                	sd	s5,24(sp)
    800021f8:	e85a                	sd	s6,16(sp)
    800021fa:	e45e                	sd	s7,8(sp)
    800021fc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800021fe:	00005517          	auipc	a0,0x5
    80002202:	ec250513          	addi	a0,a0,-318 # 800070c0 <digits+0x88>
    80002206:	a9cfe0ef          	jal	ra,800004a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000220a:	0000e497          	auipc	s1,0xe
    8000220e:	dae48493          	addi	s1,s1,-594 # 8000ffb8 <proc+0x158>
    80002212:	00013917          	auipc	s2,0x13
    80002216:	7a690913          	addi	s2,s2,1958 # 800159b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000221a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000221c:	00005997          	auipc	s3,0x5
    80002220:	09c98993          	addi	s3,s3,156 # 800072b8 <digits+0x280>
    printf("%d %s %s", p->pid, state, p->name);
    80002224:	00005a97          	auipc	s5,0x5
    80002228:	09ca8a93          	addi	s5,s5,156 # 800072c0 <digits+0x288>
    printf("\n");
    8000222c:	00005a17          	auipc	s4,0x5
    80002230:	e94a0a13          	addi	s4,s4,-364 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002234:	00005b97          	auipc	s7,0x5
    80002238:	0ccb8b93          	addi	s7,s7,204 # 80007300 <states.0>
    8000223c:	a829                	j	80002256 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000223e:	ed86a583          	lw	a1,-296(a3)
    80002242:	8556                	mv	a0,s5
    80002244:	a5efe0ef          	jal	ra,800004a2 <printf>
    printf("\n");
    80002248:	8552                	mv	a0,s4
    8000224a:	a58fe0ef          	jal	ra,800004a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000224e:	16848493          	addi	s1,s1,360
    80002252:	03248163          	beq	s1,s2,80002274 <procdump+0x8c>
    if(p->state == UNUSED)
    80002256:	86a6                	mv	a3,s1
    80002258:	ec04a783          	lw	a5,-320(s1)
    8000225c:	dbed                	beqz	a5,8000224e <procdump+0x66>
      state = "???";
    8000225e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002260:	fcfb6fe3          	bltu	s6,a5,8000223e <procdump+0x56>
    80002264:	1782                	slli	a5,a5,0x20
    80002266:	9381                	srli	a5,a5,0x20
    80002268:	078e                	slli	a5,a5,0x3
    8000226a:	97de                	add	a5,a5,s7
    8000226c:	6390                	ld	a2,0(a5)
    8000226e:	fa61                	bnez	a2,8000223e <procdump+0x56>
      state = "???";
    80002270:	864e                	mv	a2,s3
    80002272:	b7f1                	j	8000223e <procdump+0x56>
  }
}
    80002274:	60a6                	ld	ra,72(sp)
    80002276:	6406                	ld	s0,64(sp)
    80002278:	74e2                	ld	s1,56(sp)
    8000227a:	7942                	ld	s2,48(sp)
    8000227c:	79a2                	ld	s3,40(sp)
    8000227e:	7a02                	ld	s4,32(sp)
    80002280:	6ae2                	ld	s5,24(sp)
    80002282:	6b42                	ld	s6,16(sp)
    80002284:	6ba2                	ld	s7,8(sp)
    80002286:	6161                	addi	sp,sp,80
    80002288:	8082                	ret

000000008000228a <swtch>:
    8000228a:	00153023          	sd	ra,0(a0)
    8000228e:	00253423          	sd	sp,8(a0)
    80002292:	e900                	sd	s0,16(a0)
    80002294:	ed04                	sd	s1,24(a0)
    80002296:	03253023          	sd	s2,32(a0)
    8000229a:	03353423          	sd	s3,40(a0)
    8000229e:	03453823          	sd	s4,48(a0)
    800022a2:	03553c23          	sd	s5,56(a0)
    800022a6:	05653023          	sd	s6,64(a0)
    800022aa:	05753423          	sd	s7,72(a0)
    800022ae:	05853823          	sd	s8,80(a0)
    800022b2:	05953c23          	sd	s9,88(a0)
    800022b6:	07a53023          	sd	s10,96(a0)
    800022ba:	07b53423          	sd	s11,104(a0)
    800022be:	0005b083          	ld	ra,0(a1)
    800022c2:	0085b103          	ld	sp,8(a1)
    800022c6:	6980                	ld	s0,16(a1)
    800022c8:	6d84                	ld	s1,24(a1)
    800022ca:	0205b903          	ld	s2,32(a1)
    800022ce:	0285b983          	ld	s3,40(a1)
    800022d2:	0305ba03          	ld	s4,48(a1)
    800022d6:	0385ba83          	ld	s5,56(a1)
    800022da:	0405bb03          	ld	s6,64(a1)
    800022de:	0485bb83          	ld	s7,72(a1)
    800022e2:	0505bc03          	ld	s8,80(a1)
    800022e6:	0585bc83          	ld	s9,88(a1)
    800022ea:	0605bd03          	ld	s10,96(a1)
    800022ee:	0685bd83          	ld	s11,104(a1)
    800022f2:	8082                	ret

00000000800022f4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800022f4:	1141                	addi	sp,sp,-16
    800022f6:	e406                	sd	ra,8(sp)
    800022f8:	e022                	sd	s0,0(sp)
    800022fa:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800022fc:	00005597          	auipc	a1,0x5
    80002300:	03458593          	addi	a1,a1,52 # 80007330 <states.0+0x30>
    80002304:	00013517          	auipc	a0,0x13
    80002308:	55c50513          	addi	a0,a0,1372 # 80015860 <tickslock>
    8000230c:	80ffe0ef          	jal	ra,80000b1a <initlock>
}
    80002310:	60a2                	ld	ra,8(sp)
    80002312:	6402                	ld	s0,0(sp)
    80002314:	0141                	addi	sp,sp,16
    80002316:	8082                	ret

0000000080002318 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002318:	1141                	addi	sp,sp,-16
    8000231a:	e422                	sd	s0,8(sp)
    8000231c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000231e:	00003797          	auipc	a5,0x3
    80002322:	d2278793          	addi	a5,a5,-734 # 80005040 <kernelvec>
    80002326:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000232a:	6422                	ld	s0,8(sp)
    8000232c:	0141                	addi	sp,sp,16
    8000232e:	8082                	ret

0000000080002330 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002330:	1141                	addi	sp,sp,-16
    80002332:	e406                	sd	ra,8(sp)
    80002334:	e022                	sd	s0,0(sp)
    80002336:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002338:	cf4ff0ef          	jal	ra,8000182c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000233c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002340:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002342:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002346:	00004617          	auipc	a2,0x4
    8000234a:	cba60613          	addi	a2,a2,-838 # 80006000 <_trampoline>
    8000234e:	00004697          	auipc	a3,0x4
    80002352:	cb268693          	addi	a3,a3,-846 # 80006000 <_trampoline>
    80002356:	8e91                	sub	a3,a3,a2
    80002358:	040007b7          	lui	a5,0x4000
    8000235c:	17fd                	addi	a5,a5,-1
    8000235e:	07b2                	slli	a5,a5,0xc
    80002360:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002362:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002366:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002368:	180026f3          	csrr	a3,satp
    8000236c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000236e:	6d38                	ld	a4,88(a0)
    80002370:	6134                	ld	a3,64(a0)
    80002372:	6585                	lui	a1,0x1
    80002374:	96ae                	add	a3,a3,a1
    80002376:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002378:	6d38                	ld	a4,88(a0)
    8000237a:	00000697          	auipc	a3,0x0
    8000237e:	10c68693          	addi	a3,a3,268 # 80002486 <usertrap>
    80002382:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002384:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002386:	8692                	mv	a3,tp
    80002388:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000238a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000238e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002392:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002396:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000239a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000239c:	6f18                	ld	a4,24(a4)
    8000239e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800023a2:	6928                	ld	a0,80(a0)
    800023a4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800023a6:	00004717          	auipc	a4,0x4
    800023aa:	cf670713          	addi	a4,a4,-778 # 8000609c <userret>
    800023ae:	8f11                	sub	a4,a4,a2
    800023b0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800023b2:	577d                	li	a4,-1
    800023b4:	177e                	slli	a4,a4,0x3f
    800023b6:	8d59                	or	a0,a0,a4
    800023b8:	9782                	jalr	a5
}
    800023ba:	60a2                	ld	ra,8(sp)
    800023bc:	6402                	ld	s0,0(sp)
    800023be:	0141                	addi	sp,sp,16
    800023c0:	8082                	ret

00000000800023c2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800023c2:	1101                	addi	sp,sp,-32
    800023c4:	ec06                	sd	ra,24(sp)
    800023c6:	e822                	sd	s0,16(sp)
    800023c8:	e426                	sd	s1,8(sp)
    800023ca:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800023cc:	c34ff0ef          	jal	ra,80001800 <cpuid>
    800023d0:	cd19                	beqz	a0,800023ee <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800023d2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800023d6:	000f4737          	lui	a4,0xf4
    800023da:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800023de:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800023e0:	14d79073          	csrw	0x14d,a5
}
    800023e4:	60e2                	ld	ra,24(sp)
    800023e6:	6442                	ld	s0,16(sp)
    800023e8:	64a2                	ld	s1,8(sp)
    800023ea:	6105                	addi	sp,sp,32
    800023ec:	8082                	ret
    acquire(&tickslock);
    800023ee:	00013497          	auipc	s1,0x13
    800023f2:	47248493          	addi	s1,s1,1138 # 80015860 <tickslock>
    800023f6:	8526                	mv	a0,s1
    800023f8:	fa2fe0ef          	jal	ra,80000b9a <acquire>
    ticks++;
    800023fc:	00005517          	auipc	a0,0x5
    80002400:	50450513          	addi	a0,a0,1284 # 80007900 <ticks>
    80002404:	411c                	lw	a5,0(a0)
    80002406:	2785                	addiw	a5,a5,1
    80002408:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000240a:	a3bff0ef          	jal	ra,80001e44 <wakeup>
    release(&tickslock);
    8000240e:	8526                	mv	a0,s1
    80002410:	823fe0ef          	jal	ra,80000c32 <release>
    80002414:	bf7d                	j	800023d2 <clockintr+0x10>

0000000080002416 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002416:	1101                	addi	sp,sp,-32
    80002418:	ec06                	sd	ra,24(sp)
    8000241a:	e822                	sd	s0,16(sp)
    8000241c:	e426                	sd	s1,8(sp)
    8000241e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002420:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002424:	57fd                	li	a5,-1
    80002426:	17fe                	slli	a5,a5,0x3f
    80002428:	07a5                	addi	a5,a5,9
    8000242a:	00f70d63          	beq	a4,a5,80002444 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000242e:	57fd                	li	a5,-1
    80002430:	17fe                	slli	a5,a5,0x3f
    80002432:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002434:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002436:	04f70463          	beq	a4,a5,8000247e <devintr+0x68>
  }
}
    8000243a:	60e2                	ld	ra,24(sp)
    8000243c:	6442                	ld	s0,16(sp)
    8000243e:	64a2                	ld	s1,8(sp)
    80002440:	6105                	addi	sp,sp,32
    80002442:	8082                	ret
    int irq = plic_claim();
    80002444:	4a5020ef          	jal	ra,800050e8 <plic_claim>
    80002448:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000244a:	47a9                	li	a5,10
    8000244c:	02f50363          	beq	a0,a5,80002472 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002450:	4785                	li	a5,1
    80002452:	02f50363          	beq	a0,a5,80002478 <devintr+0x62>
    return 1;
    80002456:	4505                	li	a0,1
    } else if(irq){
    80002458:	d0ed                	beqz	s1,8000243a <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000245a:	85a6                	mv	a1,s1
    8000245c:	00005517          	auipc	a0,0x5
    80002460:	edc50513          	addi	a0,a0,-292 # 80007338 <states.0+0x38>
    80002464:	83efe0ef          	jal	ra,800004a2 <printf>
      plic_complete(irq);
    80002468:	8526                	mv	a0,s1
    8000246a:	49f020ef          	jal	ra,80005108 <plic_complete>
    return 1;
    8000246e:	4505                	li	a0,1
    80002470:	b7e9                	j	8000243a <devintr+0x24>
      uartintr();
    80002472:	d3cfe0ef          	jal	ra,800009ae <uartintr>
    80002476:	bfcd                	j	80002468 <devintr+0x52>
      virtio_disk_intr();
    80002478:	100030ef          	jal	ra,80005578 <virtio_disk_intr>
    8000247c:	b7f5                	j	80002468 <devintr+0x52>
    clockintr();
    8000247e:	f45ff0ef          	jal	ra,800023c2 <clockintr>
    return 2;
    80002482:	4509                	li	a0,2
    80002484:	bf5d                	j	8000243a <devintr+0x24>

0000000080002486 <usertrap>:
{
    80002486:	1101                	addi	sp,sp,-32
    80002488:	ec06                	sd	ra,24(sp)
    8000248a:	e822                	sd	s0,16(sp)
    8000248c:	e426                	sd	s1,8(sp)
    8000248e:	e04a                	sd	s2,0(sp)
    80002490:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002492:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002496:	1007f793          	andi	a5,a5,256
    8000249a:	ef85                	bnez	a5,800024d2 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000249c:	00003797          	auipc	a5,0x3
    800024a0:	ba478793          	addi	a5,a5,-1116 # 80005040 <kernelvec>
    800024a4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800024a8:	b84ff0ef          	jal	ra,8000182c <myproc>
    800024ac:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800024ae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800024b0:	14102773          	csrr	a4,sepc
    800024b4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024b6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800024ba:	47a1                	li	a5,8
    800024bc:	02f70163          	beq	a4,a5,800024de <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800024c0:	f57ff0ef          	jal	ra,80002416 <devintr>
    800024c4:	892a                	mv	s2,a0
    800024c6:	c135                	beqz	a0,8000252a <usertrap+0xa4>
  if(killed(p))
    800024c8:	8526                	mv	a0,s1
    800024ca:	b67ff0ef          	jal	ra,80002030 <killed>
    800024ce:	cd1d                	beqz	a0,8000250c <usertrap+0x86>
    800024d0:	a81d                	j	80002506 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800024d2:	00005517          	auipc	a0,0x5
    800024d6:	e8650513          	addi	a0,a0,-378 # 80007358 <states.0+0x58>
    800024da:	a7cfe0ef          	jal	ra,80000756 <panic>
    if(killed(p))
    800024de:	b53ff0ef          	jal	ra,80002030 <killed>
    800024e2:	e121                	bnez	a0,80002522 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800024e4:	6cb8                	ld	a4,88(s1)
    800024e6:	6f1c                	ld	a5,24(a4)
    800024e8:	0791                	addi	a5,a5,4
    800024ea:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024f4:	10079073          	csrw	sstatus,a5
    syscall();
    800024f8:	248000ef          	jal	ra,80002740 <syscall>
  if(killed(p))
    800024fc:	8526                	mv	a0,s1
    800024fe:	b33ff0ef          	jal	ra,80002030 <killed>
    80002502:	c901                	beqz	a0,80002512 <usertrap+0x8c>
    80002504:	4901                	li	s2,0
    exit(-1);
    80002506:	557d                	li	a0,-1
    80002508:	9fdff0ef          	jal	ra,80001f04 <exit>
  if(which_dev == 2)
    8000250c:	4789                	li	a5,2
    8000250e:	04f90563          	beq	s2,a5,80002558 <usertrap+0xd2>
  usertrapret();
    80002512:	e1fff0ef          	jal	ra,80002330 <usertrapret>
}
    80002516:	60e2                	ld	ra,24(sp)
    80002518:	6442                	ld	s0,16(sp)
    8000251a:	64a2                	ld	s1,8(sp)
    8000251c:	6902                	ld	s2,0(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret
      exit(-1);
    80002522:	557d                	li	a0,-1
    80002524:	9e1ff0ef          	jal	ra,80001f04 <exit>
    80002528:	bf75                	j	800024e4 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000252a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000252e:	5890                	lw	a2,48(s1)
    80002530:	00005517          	auipc	a0,0x5
    80002534:	e4850513          	addi	a0,a0,-440 # 80007378 <states.0+0x78>
    80002538:	f6bfd0ef          	jal	ra,800004a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000253c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002540:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002544:	00005517          	auipc	a0,0x5
    80002548:	e6450513          	addi	a0,a0,-412 # 800073a8 <states.0+0xa8>
    8000254c:	f57fd0ef          	jal	ra,800004a2 <printf>
    setkilled(p);
    80002550:	8526                	mv	a0,s1
    80002552:	abbff0ef          	jal	ra,8000200c <setkilled>
    80002556:	b75d                	j	800024fc <usertrap+0x76>
    yield();
    80002558:	875ff0ef          	jal	ra,80001dcc <yield>
    8000255c:	bf5d                	j	80002512 <usertrap+0x8c>

000000008000255e <kerneltrap>:
{
    8000255e:	7179                	addi	sp,sp,-48
    80002560:	f406                	sd	ra,40(sp)
    80002562:	f022                	sd	s0,32(sp)
    80002564:	ec26                	sd	s1,24(sp)
    80002566:	e84a                	sd	s2,16(sp)
    80002568:	e44e                	sd	s3,8(sp)
    8000256a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000256c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002570:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002574:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002578:	1004f793          	andi	a5,s1,256
    8000257c:	c795                	beqz	a5,800025a8 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000257e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002582:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002584:	eb85                	bnez	a5,800025b4 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002586:	e91ff0ef          	jal	ra,80002416 <devintr>
    8000258a:	c91d                	beqz	a0,800025c0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000258c:	4789                	li	a5,2
    8000258e:	04f50a63          	beq	a0,a5,800025e2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002592:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002596:	10049073          	csrw	sstatus,s1
}
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6145                	addi	sp,sp,48
    800025a6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800025a8:	00005517          	auipc	a0,0x5
    800025ac:	e2850513          	addi	a0,a0,-472 # 800073d0 <states.0+0xd0>
    800025b0:	9a6fe0ef          	jal	ra,80000756 <panic>
    panic("kerneltrap: interrupts enabled");
    800025b4:	00005517          	auipc	a0,0x5
    800025b8:	e4450513          	addi	a0,a0,-444 # 800073f8 <states.0+0xf8>
    800025bc:	99afe0ef          	jal	ra,80000756 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025c0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025c4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800025c8:	85ce                	mv	a1,s3
    800025ca:	00005517          	auipc	a0,0x5
    800025ce:	e4e50513          	addi	a0,a0,-434 # 80007418 <states.0+0x118>
    800025d2:	ed1fd0ef          	jal	ra,800004a2 <printf>
    panic("kerneltrap");
    800025d6:	00005517          	auipc	a0,0x5
    800025da:	e6a50513          	addi	a0,a0,-406 # 80007440 <states.0+0x140>
    800025de:	978fe0ef          	jal	ra,80000756 <panic>
  if(which_dev == 2 && myproc() != 0)
    800025e2:	a4aff0ef          	jal	ra,8000182c <myproc>
    800025e6:	d555                	beqz	a0,80002592 <kerneltrap+0x34>
    yield();
    800025e8:	fe4ff0ef          	jal	ra,80001dcc <yield>
    800025ec:	b75d                	j	80002592 <kerneltrap+0x34>

00000000800025ee <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800025ee:	1101                	addi	sp,sp,-32
    800025f0:	ec06                	sd	ra,24(sp)
    800025f2:	e822                	sd	s0,16(sp)
    800025f4:	e426                	sd	s1,8(sp)
    800025f6:	1000                	addi	s0,sp,32
    800025f8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800025fa:	a32ff0ef          	jal	ra,8000182c <myproc>
  switch (n) {
    800025fe:	4795                	li	a5,5
    80002600:	0497e163          	bltu	a5,s1,80002642 <argraw+0x54>
    80002604:	048a                	slli	s1,s1,0x2
    80002606:	00005717          	auipc	a4,0x5
    8000260a:	e7270713          	addi	a4,a4,-398 # 80007478 <states.0+0x178>
    8000260e:	94ba                	add	s1,s1,a4
    80002610:	409c                	lw	a5,0(s1)
    80002612:	97ba                	add	a5,a5,a4
    80002614:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002616:	6d3c                	ld	a5,88(a0)
    80002618:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000261a:	60e2                	ld	ra,24(sp)
    8000261c:	6442                	ld	s0,16(sp)
    8000261e:	64a2                	ld	s1,8(sp)
    80002620:	6105                	addi	sp,sp,32
    80002622:	8082                	ret
    return p->trapframe->a1;
    80002624:	6d3c                	ld	a5,88(a0)
    80002626:	7fa8                	ld	a0,120(a5)
    80002628:	bfcd                	j	8000261a <argraw+0x2c>
    return p->trapframe->a2;
    8000262a:	6d3c                	ld	a5,88(a0)
    8000262c:	63c8                	ld	a0,128(a5)
    8000262e:	b7f5                	j	8000261a <argraw+0x2c>
    return p->trapframe->a3;
    80002630:	6d3c                	ld	a5,88(a0)
    80002632:	67c8                	ld	a0,136(a5)
    80002634:	b7dd                	j	8000261a <argraw+0x2c>
    return p->trapframe->a4;
    80002636:	6d3c                	ld	a5,88(a0)
    80002638:	6bc8                	ld	a0,144(a5)
    8000263a:	b7c5                	j	8000261a <argraw+0x2c>
    return p->trapframe->a5;
    8000263c:	6d3c                	ld	a5,88(a0)
    8000263e:	6fc8                	ld	a0,152(a5)
    80002640:	bfe9                	j	8000261a <argraw+0x2c>
  panic("argraw");
    80002642:	00005517          	auipc	a0,0x5
    80002646:	e0e50513          	addi	a0,a0,-498 # 80007450 <states.0+0x150>
    8000264a:	90cfe0ef          	jal	ra,80000756 <panic>

000000008000264e <fetchaddr>:
{
    8000264e:	1101                	addi	sp,sp,-32
    80002650:	ec06                	sd	ra,24(sp)
    80002652:	e822                	sd	s0,16(sp)
    80002654:	e426                	sd	s1,8(sp)
    80002656:	e04a                	sd	s2,0(sp)
    80002658:	1000                	addi	s0,sp,32
    8000265a:	84aa                	mv	s1,a0
    8000265c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000265e:	9ceff0ef          	jal	ra,8000182c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002662:	653c                	ld	a5,72(a0)
    80002664:	02f4f663          	bgeu	s1,a5,80002690 <fetchaddr+0x42>
    80002668:	00848713          	addi	a4,s1,8
    8000266c:	02e7e463          	bltu	a5,a4,80002694 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002670:	46a1                	li	a3,8
    80002672:	8626                	mv	a2,s1
    80002674:	85ca                	mv	a1,s2
    80002676:	6928                	ld	a0,80(a0)
    80002678:	f21fe0ef          	jal	ra,80001598 <copyin>
    8000267c:	00a03533          	snez	a0,a0
    80002680:	40a00533          	neg	a0,a0
}
    80002684:	60e2                	ld	ra,24(sp)
    80002686:	6442                	ld	s0,16(sp)
    80002688:	64a2                	ld	s1,8(sp)
    8000268a:	6902                	ld	s2,0(sp)
    8000268c:	6105                	addi	sp,sp,32
    8000268e:	8082                	ret
    return -1;
    80002690:	557d                	li	a0,-1
    80002692:	bfcd                	j	80002684 <fetchaddr+0x36>
    80002694:	557d                	li	a0,-1
    80002696:	b7fd                	j	80002684 <fetchaddr+0x36>

0000000080002698 <fetchstr>:
{
    80002698:	7179                	addi	sp,sp,-48
    8000269a:	f406                	sd	ra,40(sp)
    8000269c:	f022                	sd	s0,32(sp)
    8000269e:	ec26                	sd	s1,24(sp)
    800026a0:	e84a                	sd	s2,16(sp)
    800026a2:	e44e                	sd	s3,8(sp)
    800026a4:	1800                	addi	s0,sp,48
    800026a6:	892a                	mv	s2,a0
    800026a8:	84ae                	mv	s1,a1
    800026aa:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800026ac:	980ff0ef          	jal	ra,8000182c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800026b0:	86ce                	mv	a3,s3
    800026b2:	864a                	mv	a2,s2
    800026b4:	85a6                	mv	a1,s1
    800026b6:	6928                	ld	a0,80(a0)
    800026b8:	f67fe0ef          	jal	ra,8000161e <copyinstr>
    800026bc:	00054c63          	bltz	a0,800026d4 <fetchstr+0x3c>
  return strlen(buf);
    800026c0:	8526                	mv	a0,s1
    800026c2:	f24fe0ef          	jal	ra,80000de6 <strlen>
}
    800026c6:	70a2                	ld	ra,40(sp)
    800026c8:	7402                	ld	s0,32(sp)
    800026ca:	64e2                	ld	s1,24(sp)
    800026cc:	6942                	ld	s2,16(sp)
    800026ce:	69a2                	ld	s3,8(sp)
    800026d0:	6145                	addi	sp,sp,48
    800026d2:	8082                	ret
    return -1;
    800026d4:	557d                	li	a0,-1
    800026d6:	bfc5                	j	800026c6 <fetchstr+0x2e>

00000000800026d8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800026d8:	1101                	addi	sp,sp,-32
    800026da:	ec06                	sd	ra,24(sp)
    800026dc:	e822                	sd	s0,16(sp)
    800026de:	e426                	sd	s1,8(sp)
    800026e0:	1000                	addi	s0,sp,32
    800026e2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800026e4:	f0bff0ef          	jal	ra,800025ee <argraw>
    800026e8:	c088                	sw	a0,0(s1)
}
    800026ea:	60e2                	ld	ra,24(sp)
    800026ec:	6442                	ld	s0,16(sp)
    800026ee:	64a2                	ld	s1,8(sp)
    800026f0:	6105                	addi	sp,sp,32
    800026f2:	8082                	ret

00000000800026f4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800026f4:	1101                	addi	sp,sp,-32
    800026f6:	ec06                	sd	ra,24(sp)
    800026f8:	e822                	sd	s0,16(sp)
    800026fa:	e426                	sd	s1,8(sp)
    800026fc:	1000                	addi	s0,sp,32
    800026fe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002700:	eefff0ef          	jal	ra,800025ee <argraw>
    80002704:	e088                	sd	a0,0(s1)
}
    80002706:	60e2                	ld	ra,24(sp)
    80002708:	6442                	ld	s0,16(sp)
    8000270a:	64a2                	ld	s1,8(sp)
    8000270c:	6105                	addi	sp,sp,32
    8000270e:	8082                	ret

0000000080002710 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002710:	7179                	addi	sp,sp,-48
    80002712:	f406                	sd	ra,40(sp)
    80002714:	f022                	sd	s0,32(sp)
    80002716:	ec26                	sd	s1,24(sp)
    80002718:	e84a                	sd	s2,16(sp)
    8000271a:	1800                	addi	s0,sp,48
    8000271c:	84ae                	mv	s1,a1
    8000271e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002720:	fd840593          	addi	a1,s0,-40
    80002724:	fd1ff0ef          	jal	ra,800026f4 <argaddr>
  return fetchstr(addr, buf, max);
    80002728:	864a                	mv	a2,s2
    8000272a:	85a6                	mv	a1,s1
    8000272c:	fd843503          	ld	a0,-40(s0)
    80002730:	f69ff0ef          	jal	ra,80002698 <fetchstr>
}
    80002734:	70a2                	ld	ra,40(sp)
    80002736:	7402                	ld	s0,32(sp)
    80002738:	64e2                	ld	s1,24(sp)
    8000273a:	6942                	ld	s2,16(sp)
    8000273c:	6145                	addi	sp,sp,48
    8000273e:	8082                	ret

0000000080002740 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002740:	1101                	addi	sp,sp,-32
    80002742:	ec06                	sd	ra,24(sp)
    80002744:	e822                	sd	s0,16(sp)
    80002746:	e426                	sd	s1,8(sp)
    80002748:	e04a                	sd	s2,0(sp)
    8000274a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000274c:	8e0ff0ef          	jal	ra,8000182c <myproc>
    80002750:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002752:	05853903          	ld	s2,88(a0)
    80002756:	0a893783          	ld	a5,168(s2)
    8000275a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000275e:	37fd                	addiw	a5,a5,-1
    80002760:	4751                	li	a4,20
    80002762:	00f76f63          	bltu	a4,a5,80002780 <syscall+0x40>
    80002766:	00369713          	slli	a4,a3,0x3
    8000276a:	00005797          	auipc	a5,0x5
    8000276e:	d2678793          	addi	a5,a5,-730 # 80007490 <syscalls>
    80002772:	97ba                	add	a5,a5,a4
    80002774:	639c                	ld	a5,0(a5)
    80002776:	c789                	beqz	a5,80002780 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002778:	9782                	jalr	a5
    8000277a:	06a93823          	sd	a0,112(s2)
    8000277e:	a829                	j	80002798 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002780:	15848613          	addi	a2,s1,344
    80002784:	588c                	lw	a1,48(s1)
    80002786:	00005517          	auipc	a0,0x5
    8000278a:	cd250513          	addi	a0,a0,-814 # 80007458 <states.0+0x158>
    8000278e:	d15fd0ef          	jal	ra,800004a2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002792:	6cbc                	ld	a5,88(s1)
    80002794:	577d                	li	a4,-1
    80002796:	fbb8                	sd	a4,112(a5)
  }
}
    80002798:	60e2                	ld	ra,24(sp)
    8000279a:	6442                	ld	s0,16(sp)
    8000279c:	64a2                	ld	s1,8(sp)
    8000279e:	6902                	ld	s2,0(sp)
    800027a0:	6105                	addi	sp,sp,32
    800027a2:	8082                	ret

00000000800027a4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800027a4:	1101                	addi	sp,sp,-32
    800027a6:	ec06                	sd	ra,24(sp)
    800027a8:	e822                	sd	s0,16(sp)
    800027aa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800027ac:	fec40593          	addi	a1,s0,-20
    800027b0:	4501                	li	a0,0
    800027b2:	f27ff0ef          	jal	ra,800026d8 <argint>
  exit(n);
    800027b6:	fec42503          	lw	a0,-20(s0)
    800027ba:	f4aff0ef          	jal	ra,80001f04 <exit>
  return 0;  // not reached
}
    800027be:	4501                	li	a0,0
    800027c0:	60e2                	ld	ra,24(sp)
    800027c2:	6442                	ld	s0,16(sp)
    800027c4:	6105                	addi	sp,sp,32
    800027c6:	8082                	ret

00000000800027c8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800027c8:	1141                	addi	sp,sp,-16
    800027ca:	e406                	sd	ra,8(sp)
    800027cc:	e022                	sd	s0,0(sp)
    800027ce:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800027d0:	85cff0ef          	jal	ra,8000182c <myproc>
}
    800027d4:	5908                	lw	a0,48(a0)
    800027d6:	60a2                	ld	ra,8(sp)
    800027d8:	6402                	ld	s0,0(sp)
    800027da:	0141                	addi	sp,sp,16
    800027dc:	8082                	ret

00000000800027de <sys_fork>:

uint64
sys_fork(void)
{
    800027de:	1141                	addi	sp,sp,-16
    800027e0:	e406                	sd	ra,8(sp)
    800027e2:	e022                	sd	s0,0(sp)
    800027e4:	0800                	addi	s0,sp,16
  return fork();
    800027e6:	b6cff0ef          	jal	ra,80001b52 <fork>
}
    800027ea:	60a2                	ld	ra,8(sp)
    800027ec:	6402                	ld	s0,0(sp)
    800027ee:	0141                	addi	sp,sp,16
    800027f0:	8082                	ret

00000000800027f2 <sys_wait>:

uint64
sys_wait(void)
{
    800027f2:	1101                	addi	sp,sp,-32
    800027f4:	ec06                	sd	ra,24(sp)
    800027f6:	e822                	sd	s0,16(sp)
    800027f8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800027fa:	fe840593          	addi	a1,s0,-24
    800027fe:	4501                	li	a0,0
    80002800:	ef5ff0ef          	jal	ra,800026f4 <argaddr>
  return wait(p);
    80002804:	fe843503          	ld	a0,-24(s0)
    80002808:	853ff0ef          	jal	ra,8000205a <wait>
}
    8000280c:	60e2                	ld	ra,24(sp)
    8000280e:	6442                	ld	s0,16(sp)
    80002810:	6105                	addi	sp,sp,32
    80002812:	8082                	ret

0000000080002814 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002814:	7179                	addi	sp,sp,-48
    80002816:	f406                	sd	ra,40(sp)
    80002818:	f022                	sd	s0,32(sp)
    8000281a:	ec26                	sd	s1,24(sp)
    8000281c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000281e:	fdc40593          	addi	a1,s0,-36
    80002822:	4501                	li	a0,0
    80002824:	eb5ff0ef          	jal	ra,800026d8 <argint>
  addr = myproc()->sz;
    80002828:	804ff0ef          	jal	ra,8000182c <myproc>
    8000282c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000282e:	fdc42503          	lw	a0,-36(s0)
    80002832:	ad0ff0ef          	jal	ra,80001b02 <growproc>
    80002836:	00054863          	bltz	a0,80002846 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    8000283a:	8526                	mv	a0,s1
    8000283c:	70a2                	ld	ra,40(sp)
    8000283e:	7402                	ld	s0,32(sp)
    80002840:	64e2                	ld	s1,24(sp)
    80002842:	6145                	addi	sp,sp,48
    80002844:	8082                	ret
    return -1;
    80002846:	54fd                	li	s1,-1
    80002848:	bfcd                	j	8000283a <sys_sbrk+0x26>

000000008000284a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000284a:	7139                	addi	sp,sp,-64
    8000284c:	fc06                	sd	ra,56(sp)
    8000284e:	f822                	sd	s0,48(sp)
    80002850:	f426                	sd	s1,40(sp)
    80002852:	f04a                	sd	s2,32(sp)
    80002854:	ec4e                	sd	s3,24(sp)
    80002856:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002858:	fcc40593          	addi	a1,s0,-52
    8000285c:	4501                	li	a0,0
    8000285e:	e7bff0ef          	jal	ra,800026d8 <argint>
  if(n < 0)
    80002862:	fcc42783          	lw	a5,-52(s0)
    80002866:	0607c563          	bltz	a5,800028d0 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    8000286a:	00013517          	auipc	a0,0x13
    8000286e:	ff650513          	addi	a0,a0,-10 # 80015860 <tickslock>
    80002872:	b28fe0ef          	jal	ra,80000b9a <acquire>
  ticks0 = ticks;
    80002876:	00005917          	auipc	s2,0x5
    8000287a:	08a92903          	lw	s2,138(s2) # 80007900 <ticks>
  while(ticks - ticks0 < n){
    8000287e:	fcc42783          	lw	a5,-52(s0)
    80002882:	cb8d                	beqz	a5,800028b4 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002884:	00013997          	auipc	s3,0x13
    80002888:	fdc98993          	addi	s3,s3,-36 # 80015860 <tickslock>
    8000288c:	00005497          	auipc	s1,0x5
    80002890:	07448493          	addi	s1,s1,116 # 80007900 <ticks>
    if(killed(myproc())){
    80002894:	f99fe0ef          	jal	ra,8000182c <myproc>
    80002898:	f98ff0ef          	jal	ra,80002030 <killed>
    8000289c:	ed0d                	bnez	a0,800028d6 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000289e:	85ce                	mv	a1,s3
    800028a0:	8526                	mv	a0,s1
    800028a2:	d56ff0ef          	jal	ra,80001df8 <sleep>
  while(ticks - ticks0 < n){
    800028a6:	409c                	lw	a5,0(s1)
    800028a8:	412787bb          	subw	a5,a5,s2
    800028ac:	fcc42703          	lw	a4,-52(s0)
    800028b0:	fee7e2e3          	bltu	a5,a4,80002894 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800028b4:	00013517          	auipc	a0,0x13
    800028b8:	fac50513          	addi	a0,a0,-84 # 80015860 <tickslock>
    800028bc:	b76fe0ef          	jal	ra,80000c32 <release>
  return 0;
    800028c0:	4501                	li	a0,0
}
    800028c2:	70e2                	ld	ra,56(sp)
    800028c4:	7442                	ld	s0,48(sp)
    800028c6:	74a2                	ld	s1,40(sp)
    800028c8:	7902                	ld	s2,32(sp)
    800028ca:	69e2                	ld	s3,24(sp)
    800028cc:	6121                	addi	sp,sp,64
    800028ce:	8082                	ret
    n = 0;
    800028d0:	fc042623          	sw	zero,-52(s0)
    800028d4:	bf59                	j	8000286a <sys_sleep+0x20>
      release(&tickslock);
    800028d6:	00013517          	auipc	a0,0x13
    800028da:	f8a50513          	addi	a0,a0,-118 # 80015860 <tickslock>
    800028de:	b54fe0ef          	jal	ra,80000c32 <release>
      return -1;
    800028e2:	557d                	li	a0,-1
    800028e4:	bff9                	j	800028c2 <sys_sleep+0x78>

00000000800028e6 <sys_kill>:

uint64
sys_kill(void)
{
    800028e6:	1101                	addi	sp,sp,-32
    800028e8:	ec06                	sd	ra,24(sp)
    800028ea:	e822                	sd	s0,16(sp)
    800028ec:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800028ee:	fec40593          	addi	a1,s0,-20
    800028f2:	4501                	li	a0,0
    800028f4:	de5ff0ef          	jal	ra,800026d8 <argint>
  return kill(pid);
    800028f8:	fec42503          	lw	a0,-20(s0)
    800028fc:	eaaff0ef          	jal	ra,80001fa6 <kill>
}
    80002900:	60e2                	ld	ra,24(sp)
    80002902:	6442                	ld	s0,16(sp)
    80002904:	6105                	addi	sp,sp,32
    80002906:	8082                	ret

0000000080002908 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002908:	1101                	addi	sp,sp,-32
    8000290a:	ec06                	sd	ra,24(sp)
    8000290c:	e822                	sd	s0,16(sp)
    8000290e:	e426                	sd	s1,8(sp)
    80002910:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002912:	00013517          	auipc	a0,0x13
    80002916:	f4e50513          	addi	a0,a0,-178 # 80015860 <tickslock>
    8000291a:	a80fe0ef          	jal	ra,80000b9a <acquire>
  xticks = ticks;
    8000291e:	00005497          	auipc	s1,0x5
    80002922:	fe24a483          	lw	s1,-30(s1) # 80007900 <ticks>
  release(&tickslock);
    80002926:	00013517          	auipc	a0,0x13
    8000292a:	f3a50513          	addi	a0,a0,-198 # 80015860 <tickslock>
    8000292e:	b04fe0ef          	jal	ra,80000c32 <release>
  return xticks;
}
    80002932:	02049513          	slli	a0,s1,0x20
    80002936:	9101                	srli	a0,a0,0x20
    80002938:	60e2                	ld	ra,24(sp)
    8000293a:	6442                	ld	s0,16(sp)
    8000293c:	64a2                	ld	s1,8(sp)
    8000293e:	6105                	addi	sp,sp,32
    80002940:	8082                	ret

0000000080002942 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002942:	7179                	addi	sp,sp,-48
    80002944:	f406                	sd	ra,40(sp)
    80002946:	f022                	sd	s0,32(sp)
    80002948:	ec26                	sd	s1,24(sp)
    8000294a:	e84a                	sd	s2,16(sp)
    8000294c:	e44e                	sd	s3,8(sp)
    8000294e:	e052                	sd	s4,0(sp)
    80002950:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002952:	00005597          	auipc	a1,0x5
    80002956:	bee58593          	addi	a1,a1,-1042 # 80007540 <syscalls+0xb0>
    8000295a:	00013517          	auipc	a0,0x13
    8000295e:	f1e50513          	addi	a0,a0,-226 # 80015878 <bcache>
    80002962:	9b8fe0ef          	jal	ra,80000b1a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002966:	0001b797          	auipc	a5,0x1b
    8000296a:	f1278793          	addi	a5,a5,-238 # 8001d878 <bcache+0x8000>
    8000296e:	0001b717          	auipc	a4,0x1b
    80002972:	17270713          	addi	a4,a4,370 # 8001dae0 <bcache+0x8268>
    80002976:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000297a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000297e:	00013497          	auipc	s1,0x13
    80002982:	f1248493          	addi	s1,s1,-238 # 80015890 <bcache+0x18>
    b->next = bcache.head.next;
    80002986:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002988:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000298a:	00005a17          	auipc	s4,0x5
    8000298e:	bbea0a13          	addi	s4,s4,-1090 # 80007548 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002992:	2b893783          	ld	a5,696(s2)
    80002996:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002998:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000299c:	85d2                	mv	a1,s4
    8000299e:	01048513          	addi	a0,s1,16
    800029a2:	224010ef          	jal	ra,80003bc6 <initsleeplock>
    bcache.head.next->prev = b;
    800029a6:	2b893783          	ld	a5,696(s2)
    800029aa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800029ac:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800029b0:	45848493          	addi	s1,s1,1112
    800029b4:	fd349fe3          	bne	s1,s3,80002992 <binit+0x50>
  }
}
    800029b8:	70a2                	ld	ra,40(sp)
    800029ba:	7402                	ld	s0,32(sp)
    800029bc:	64e2                	ld	s1,24(sp)
    800029be:	6942                	ld	s2,16(sp)
    800029c0:	69a2                	ld	s3,8(sp)
    800029c2:	6a02                	ld	s4,0(sp)
    800029c4:	6145                	addi	sp,sp,48
    800029c6:	8082                	ret

00000000800029c8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800029c8:	7179                	addi	sp,sp,-48
    800029ca:	f406                	sd	ra,40(sp)
    800029cc:	f022                	sd	s0,32(sp)
    800029ce:	ec26                	sd	s1,24(sp)
    800029d0:	e84a                	sd	s2,16(sp)
    800029d2:	e44e                	sd	s3,8(sp)
    800029d4:	1800                	addi	s0,sp,48
    800029d6:	892a                	mv	s2,a0
    800029d8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800029da:	00013517          	auipc	a0,0x13
    800029de:	e9e50513          	addi	a0,a0,-354 # 80015878 <bcache>
    800029e2:	9b8fe0ef          	jal	ra,80000b9a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800029e6:	0001b497          	auipc	s1,0x1b
    800029ea:	14a4b483          	ld	s1,330(s1) # 8001db30 <bcache+0x82b8>
    800029ee:	0001b797          	auipc	a5,0x1b
    800029f2:	0f278793          	addi	a5,a5,242 # 8001dae0 <bcache+0x8268>
    800029f6:	02f48b63          	beq	s1,a5,80002a2c <bread+0x64>
    800029fa:	873e                	mv	a4,a5
    800029fc:	a021                	j	80002a04 <bread+0x3c>
    800029fe:	68a4                	ld	s1,80(s1)
    80002a00:	02e48663          	beq	s1,a4,80002a2c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002a04:	449c                	lw	a5,8(s1)
    80002a06:	ff279ce3          	bne	a5,s2,800029fe <bread+0x36>
    80002a0a:	44dc                	lw	a5,12(s1)
    80002a0c:	ff3799e3          	bne	a5,s3,800029fe <bread+0x36>
      b->refcnt++;
    80002a10:	40bc                	lw	a5,64(s1)
    80002a12:	2785                	addiw	a5,a5,1
    80002a14:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a16:	00013517          	auipc	a0,0x13
    80002a1a:	e6250513          	addi	a0,a0,-414 # 80015878 <bcache>
    80002a1e:	a14fe0ef          	jal	ra,80000c32 <release>
      acquiresleep(&b->lock);
    80002a22:	01048513          	addi	a0,s1,16
    80002a26:	1d6010ef          	jal	ra,80003bfc <acquiresleep>
      return b;
    80002a2a:	a889                	j	80002a7c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a2c:	0001b497          	auipc	s1,0x1b
    80002a30:	0fc4b483          	ld	s1,252(s1) # 8001db28 <bcache+0x82b0>
    80002a34:	0001b797          	auipc	a5,0x1b
    80002a38:	0ac78793          	addi	a5,a5,172 # 8001dae0 <bcache+0x8268>
    80002a3c:	00f48863          	beq	s1,a5,80002a4c <bread+0x84>
    80002a40:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002a42:	40bc                	lw	a5,64(s1)
    80002a44:	cb91                	beqz	a5,80002a58 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a46:	64a4                	ld	s1,72(s1)
    80002a48:	fee49de3          	bne	s1,a4,80002a42 <bread+0x7a>
  panic("bget: no buffers");
    80002a4c:	00005517          	auipc	a0,0x5
    80002a50:	b0450513          	addi	a0,a0,-1276 # 80007550 <syscalls+0xc0>
    80002a54:	d03fd0ef          	jal	ra,80000756 <panic>
      b->dev = dev;
    80002a58:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002a5c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002a60:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002a64:	4785                	li	a5,1
    80002a66:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a68:	00013517          	auipc	a0,0x13
    80002a6c:	e1050513          	addi	a0,a0,-496 # 80015878 <bcache>
    80002a70:	9c2fe0ef          	jal	ra,80000c32 <release>
      acquiresleep(&b->lock);
    80002a74:	01048513          	addi	a0,s1,16
    80002a78:	184010ef          	jal	ra,80003bfc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002a7c:	409c                	lw	a5,0(s1)
    80002a7e:	cb89                	beqz	a5,80002a90 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002a80:	8526                	mv	a0,s1
    80002a82:	70a2                	ld	ra,40(sp)
    80002a84:	7402                	ld	s0,32(sp)
    80002a86:	64e2                	ld	s1,24(sp)
    80002a88:	6942                	ld	s2,16(sp)
    80002a8a:	69a2                	ld	s3,8(sp)
    80002a8c:	6145                	addi	sp,sp,48
    80002a8e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002a90:	4581                	li	a1,0
    80002a92:	8526                	mv	a0,s1
    80002a94:	0c9020ef          	jal	ra,8000535c <virtio_disk_rw>
    b->valid = 1;
    80002a98:	4785                	li	a5,1
    80002a9a:	c09c                	sw	a5,0(s1)
  return b;
    80002a9c:	b7d5                	j	80002a80 <bread+0xb8>

0000000080002a9e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002a9e:	1101                	addi	sp,sp,-32
    80002aa0:	ec06                	sd	ra,24(sp)
    80002aa2:	e822                	sd	s0,16(sp)
    80002aa4:	e426                	sd	s1,8(sp)
    80002aa6:	1000                	addi	s0,sp,32
    80002aa8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002aaa:	0541                	addi	a0,a0,16
    80002aac:	1ce010ef          	jal	ra,80003c7a <holdingsleep>
    80002ab0:	c911                	beqz	a0,80002ac4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ab2:	4585                	li	a1,1
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	0a7020ef          	jal	ra,8000535c <virtio_disk_rw>
}
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6105                	addi	sp,sp,32
    80002ac2:	8082                	ret
    panic("bwrite");
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	aa450513          	addi	a0,a0,-1372 # 80007568 <syscalls+0xd8>
    80002acc:	c8bfd0ef          	jal	ra,80000756 <panic>

0000000080002ad0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ad0:	1101                	addi	sp,sp,-32
    80002ad2:	ec06                	sd	ra,24(sp)
    80002ad4:	e822                	sd	s0,16(sp)
    80002ad6:	e426                	sd	s1,8(sp)
    80002ad8:	e04a                	sd	s2,0(sp)
    80002ada:	1000                	addi	s0,sp,32
    80002adc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ade:	01050913          	addi	s2,a0,16
    80002ae2:	854a                	mv	a0,s2
    80002ae4:	196010ef          	jal	ra,80003c7a <holdingsleep>
    80002ae8:	c13d                	beqz	a0,80002b4e <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002aea:	854a                	mv	a0,s2
    80002aec:	156010ef          	jal	ra,80003c42 <releasesleep>

  acquire(&bcache.lock);
    80002af0:	00013517          	auipc	a0,0x13
    80002af4:	d8850513          	addi	a0,a0,-632 # 80015878 <bcache>
    80002af8:	8a2fe0ef          	jal	ra,80000b9a <acquire>
  b->refcnt--;
    80002afc:	40bc                	lw	a5,64(s1)
    80002afe:	37fd                	addiw	a5,a5,-1
    80002b00:	0007871b          	sext.w	a4,a5
    80002b04:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002b06:	eb05                	bnez	a4,80002b36 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002b08:	68bc                	ld	a5,80(s1)
    80002b0a:	64b8                	ld	a4,72(s1)
    80002b0c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002b0e:	64bc                	ld	a5,72(s1)
    80002b10:	68b8                	ld	a4,80(s1)
    80002b12:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002b14:	0001b797          	auipc	a5,0x1b
    80002b18:	d6478793          	addi	a5,a5,-668 # 8001d878 <bcache+0x8000>
    80002b1c:	2b87b703          	ld	a4,696(a5)
    80002b20:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002b22:	0001b717          	auipc	a4,0x1b
    80002b26:	fbe70713          	addi	a4,a4,-66 # 8001dae0 <bcache+0x8268>
    80002b2a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002b2c:	2b87b703          	ld	a4,696(a5)
    80002b30:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002b32:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002b36:	00013517          	auipc	a0,0x13
    80002b3a:	d4250513          	addi	a0,a0,-702 # 80015878 <bcache>
    80002b3e:	8f4fe0ef          	jal	ra,80000c32 <release>
}
    80002b42:	60e2                	ld	ra,24(sp)
    80002b44:	6442                	ld	s0,16(sp)
    80002b46:	64a2                	ld	s1,8(sp)
    80002b48:	6902                	ld	s2,0(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret
    panic("brelse");
    80002b4e:	00005517          	auipc	a0,0x5
    80002b52:	a2250513          	addi	a0,a0,-1502 # 80007570 <syscalls+0xe0>
    80002b56:	c01fd0ef          	jal	ra,80000756 <panic>

0000000080002b5a <bpin>:

void
bpin(struct buf *b) {
    80002b5a:	1101                	addi	sp,sp,-32
    80002b5c:	ec06                	sd	ra,24(sp)
    80002b5e:	e822                	sd	s0,16(sp)
    80002b60:	e426                	sd	s1,8(sp)
    80002b62:	1000                	addi	s0,sp,32
    80002b64:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002b66:	00013517          	auipc	a0,0x13
    80002b6a:	d1250513          	addi	a0,a0,-750 # 80015878 <bcache>
    80002b6e:	82cfe0ef          	jal	ra,80000b9a <acquire>
  b->refcnt++;
    80002b72:	40bc                	lw	a5,64(s1)
    80002b74:	2785                	addiw	a5,a5,1
    80002b76:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002b78:	00013517          	auipc	a0,0x13
    80002b7c:	d0050513          	addi	a0,a0,-768 # 80015878 <bcache>
    80002b80:	8b2fe0ef          	jal	ra,80000c32 <release>
}
    80002b84:	60e2                	ld	ra,24(sp)
    80002b86:	6442                	ld	s0,16(sp)
    80002b88:	64a2                	ld	s1,8(sp)
    80002b8a:	6105                	addi	sp,sp,32
    80002b8c:	8082                	ret

0000000080002b8e <bunpin>:

void
bunpin(struct buf *b) {
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	e426                	sd	s1,8(sp)
    80002b96:	1000                	addi	s0,sp,32
    80002b98:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002b9a:	00013517          	auipc	a0,0x13
    80002b9e:	cde50513          	addi	a0,a0,-802 # 80015878 <bcache>
    80002ba2:	ff9fd0ef          	jal	ra,80000b9a <acquire>
  b->refcnt--;
    80002ba6:	40bc                	lw	a5,64(s1)
    80002ba8:	37fd                	addiw	a5,a5,-1
    80002baa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002bac:	00013517          	auipc	a0,0x13
    80002bb0:	ccc50513          	addi	a0,a0,-820 # 80015878 <bcache>
    80002bb4:	87efe0ef          	jal	ra,80000c32 <release>
}
    80002bb8:	60e2                	ld	ra,24(sp)
    80002bba:	6442                	ld	s0,16(sp)
    80002bbc:	64a2                	ld	s1,8(sp)
    80002bbe:	6105                	addi	sp,sp,32
    80002bc0:	8082                	ret

0000000080002bc2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002bc2:	1101                	addi	sp,sp,-32
    80002bc4:	ec06                	sd	ra,24(sp)
    80002bc6:	e822                	sd	s0,16(sp)
    80002bc8:	e426                	sd	s1,8(sp)
    80002bca:	e04a                	sd	s2,0(sp)
    80002bcc:	1000                	addi	s0,sp,32
    80002bce:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002bd0:	00d5d59b          	srliw	a1,a1,0xd
    80002bd4:	0001b797          	auipc	a5,0x1b
    80002bd8:	3807a783          	lw	a5,896(a5) # 8001df54 <sb+0x1c>
    80002bdc:	9dbd                	addw	a1,a1,a5
    80002bde:	debff0ef          	jal	ra,800029c8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002be2:	0074f713          	andi	a4,s1,7
    80002be6:	4785                	li	a5,1
    80002be8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002bec:	14ce                	slli	s1,s1,0x33
    80002bee:	90d9                	srli	s1,s1,0x36
    80002bf0:	00950733          	add	a4,a0,s1
    80002bf4:	05874703          	lbu	a4,88(a4)
    80002bf8:	00e7f6b3          	and	a3,a5,a4
    80002bfc:	c29d                	beqz	a3,80002c22 <bfree+0x60>
    80002bfe:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002c00:	94aa                	add	s1,s1,a0
    80002c02:	fff7c793          	not	a5,a5
    80002c06:	8ff9                	and	a5,a5,a4
    80002c08:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002c0c:	6e9000ef          	jal	ra,80003af4 <log_write>
  brelse(bp);
    80002c10:	854a                	mv	a0,s2
    80002c12:	ebfff0ef          	jal	ra,80002ad0 <brelse>
}
    80002c16:	60e2                	ld	ra,24(sp)
    80002c18:	6442                	ld	s0,16(sp)
    80002c1a:	64a2                	ld	s1,8(sp)
    80002c1c:	6902                	ld	s2,0(sp)
    80002c1e:	6105                	addi	sp,sp,32
    80002c20:	8082                	ret
    panic("freeing free block");
    80002c22:	00005517          	auipc	a0,0x5
    80002c26:	95650513          	addi	a0,a0,-1706 # 80007578 <syscalls+0xe8>
    80002c2a:	b2dfd0ef          	jal	ra,80000756 <panic>

0000000080002c2e <balloc>:
{
    80002c2e:	711d                	addi	sp,sp,-96
    80002c30:	ec86                	sd	ra,88(sp)
    80002c32:	e8a2                	sd	s0,80(sp)
    80002c34:	e4a6                	sd	s1,72(sp)
    80002c36:	e0ca                	sd	s2,64(sp)
    80002c38:	fc4e                	sd	s3,56(sp)
    80002c3a:	f852                	sd	s4,48(sp)
    80002c3c:	f456                	sd	s5,40(sp)
    80002c3e:	f05a                	sd	s6,32(sp)
    80002c40:	ec5e                	sd	s7,24(sp)
    80002c42:	e862                	sd	s8,16(sp)
    80002c44:	e466                	sd	s9,8(sp)
    80002c46:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002c48:	0001b797          	auipc	a5,0x1b
    80002c4c:	2f47a783          	lw	a5,756(a5) # 8001df3c <sb+0x4>
    80002c50:	0e078163          	beqz	a5,80002d32 <balloc+0x104>
    80002c54:	8baa                	mv	s7,a0
    80002c56:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002c58:	0001bb17          	auipc	s6,0x1b
    80002c5c:	2e0b0b13          	addi	s6,s6,736 # 8001df38 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002c60:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002c62:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002c64:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002c66:	6c89                	lui	s9,0x2
    80002c68:	a0b5                	j	80002cd4 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002c6a:	974a                	add	a4,a4,s2
    80002c6c:	8fd5                	or	a5,a5,a3
    80002c6e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002c72:	854a                	mv	a0,s2
    80002c74:	681000ef          	jal	ra,80003af4 <log_write>
        brelse(bp);
    80002c78:	854a                	mv	a0,s2
    80002c7a:	e57ff0ef          	jal	ra,80002ad0 <brelse>
  bp = bread(dev, bno);
    80002c7e:	85a6                	mv	a1,s1
    80002c80:	855e                	mv	a0,s7
    80002c82:	d47ff0ef          	jal	ra,800029c8 <bread>
    80002c86:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002c88:	40000613          	li	a2,1024
    80002c8c:	4581                	li	a1,0
    80002c8e:	05850513          	addi	a0,a0,88
    80002c92:	fddfd0ef          	jal	ra,80000c6e <memset>
  log_write(bp);
    80002c96:	854a                	mv	a0,s2
    80002c98:	65d000ef          	jal	ra,80003af4 <log_write>
  brelse(bp);
    80002c9c:	854a                	mv	a0,s2
    80002c9e:	e33ff0ef          	jal	ra,80002ad0 <brelse>
}
    80002ca2:	8526                	mv	a0,s1
    80002ca4:	60e6                	ld	ra,88(sp)
    80002ca6:	6446                	ld	s0,80(sp)
    80002ca8:	64a6                	ld	s1,72(sp)
    80002caa:	6906                	ld	s2,64(sp)
    80002cac:	79e2                	ld	s3,56(sp)
    80002cae:	7a42                	ld	s4,48(sp)
    80002cb0:	7aa2                	ld	s5,40(sp)
    80002cb2:	7b02                	ld	s6,32(sp)
    80002cb4:	6be2                	ld	s7,24(sp)
    80002cb6:	6c42                	ld	s8,16(sp)
    80002cb8:	6ca2                	ld	s9,8(sp)
    80002cba:	6125                	addi	sp,sp,96
    80002cbc:	8082                	ret
    brelse(bp);
    80002cbe:	854a                	mv	a0,s2
    80002cc0:	e11ff0ef          	jal	ra,80002ad0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002cc4:	015c87bb          	addw	a5,s9,s5
    80002cc8:	00078a9b          	sext.w	s5,a5
    80002ccc:	004b2703          	lw	a4,4(s6)
    80002cd0:	06eaf163          	bgeu	s5,a4,80002d32 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002cd4:	41fad79b          	sraiw	a5,s5,0x1f
    80002cd8:	0137d79b          	srliw	a5,a5,0x13
    80002cdc:	015787bb          	addw	a5,a5,s5
    80002ce0:	40d7d79b          	sraiw	a5,a5,0xd
    80002ce4:	01cb2583          	lw	a1,28(s6)
    80002ce8:	9dbd                	addw	a1,a1,a5
    80002cea:	855e                	mv	a0,s7
    80002cec:	cddff0ef          	jal	ra,800029c8 <bread>
    80002cf0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002cf2:	004b2503          	lw	a0,4(s6)
    80002cf6:	000a849b          	sext.w	s1,s5
    80002cfa:	8662                	mv	a2,s8
    80002cfc:	fca4f1e3          	bgeu	s1,a0,80002cbe <balloc+0x90>
      m = 1 << (bi % 8);
    80002d00:	41f6579b          	sraiw	a5,a2,0x1f
    80002d04:	01d7d69b          	srliw	a3,a5,0x1d
    80002d08:	00c6873b          	addw	a4,a3,a2
    80002d0c:	00777793          	andi	a5,a4,7
    80002d10:	9f95                	subw	a5,a5,a3
    80002d12:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002d16:	4037571b          	sraiw	a4,a4,0x3
    80002d1a:	00e906b3          	add	a3,s2,a4
    80002d1e:	0586c683          	lbu	a3,88(a3)
    80002d22:	00d7f5b3          	and	a1,a5,a3
    80002d26:	d1b1                	beqz	a1,80002c6a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d28:	2605                	addiw	a2,a2,1
    80002d2a:	2485                	addiw	s1,s1,1
    80002d2c:	fd4618e3          	bne	a2,s4,80002cfc <balloc+0xce>
    80002d30:	b779                	j	80002cbe <balloc+0x90>
  printf("balloc: out of blocks\n");
    80002d32:	00005517          	auipc	a0,0x5
    80002d36:	85e50513          	addi	a0,a0,-1954 # 80007590 <syscalls+0x100>
    80002d3a:	f68fd0ef          	jal	ra,800004a2 <printf>
  return 0;
    80002d3e:	4481                	li	s1,0
    80002d40:	b78d                	j	80002ca2 <balloc+0x74>

0000000080002d42 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002d42:	7179                	addi	sp,sp,-48
    80002d44:	f406                	sd	ra,40(sp)
    80002d46:	f022                	sd	s0,32(sp)
    80002d48:	ec26                	sd	s1,24(sp)
    80002d4a:	e84a                	sd	s2,16(sp)
    80002d4c:	e44e                	sd	s3,8(sp)
    80002d4e:	e052                	sd	s4,0(sp)
    80002d50:	1800                	addi	s0,sp,48
    80002d52:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002d54:	47ad                	li	a5,11
    80002d56:	02b7e563          	bltu	a5,a1,80002d80 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002d5a:	02059493          	slli	s1,a1,0x20
    80002d5e:	9081                	srli	s1,s1,0x20
    80002d60:	048a                	slli	s1,s1,0x2
    80002d62:	94aa                	add	s1,s1,a0
    80002d64:	0504a903          	lw	s2,80(s1)
    80002d68:	06091663          	bnez	s2,80002dd4 <bmap+0x92>
      addr = balloc(ip->dev);
    80002d6c:	4108                	lw	a0,0(a0)
    80002d6e:	ec1ff0ef          	jal	ra,80002c2e <balloc>
    80002d72:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002d76:	04090f63          	beqz	s2,80002dd4 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80002d7a:	0524a823          	sw	s2,80(s1)
    80002d7e:	a899                	j	80002dd4 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002d80:	ff45849b          	addiw	s1,a1,-12
    80002d84:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002d88:	0ff00793          	li	a5,255
    80002d8c:	06e7eb63          	bltu	a5,a4,80002e02 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002d90:	08052903          	lw	s2,128(a0)
    80002d94:	00091b63          	bnez	s2,80002daa <bmap+0x68>
      addr = balloc(ip->dev);
    80002d98:	4108                	lw	a0,0(a0)
    80002d9a:	e95ff0ef          	jal	ra,80002c2e <balloc>
    80002d9e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002da2:	02090963          	beqz	s2,80002dd4 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002da6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002daa:	85ca                	mv	a1,s2
    80002dac:	0009a503          	lw	a0,0(s3)
    80002db0:	c19ff0ef          	jal	ra,800029c8 <bread>
    80002db4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002db6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002dba:	02049593          	slli	a1,s1,0x20
    80002dbe:	9181                	srli	a1,a1,0x20
    80002dc0:	058a                	slli	a1,a1,0x2
    80002dc2:	00b784b3          	add	s1,a5,a1
    80002dc6:	0004a903          	lw	s2,0(s1)
    80002dca:	00090e63          	beqz	s2,80002de6 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002dce:	8552                	mv	a0,s4
    80002dd0:	d01ff0ef          	jal	ra,80002ad0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002dd4:	854a                	mv	a0,s2
    80002dd6:	70a2                	ld	ra,40(sp)
    80002dd8:	7402                	ld	s0,32(sp)
    80002dda:	64e2                	ld	s1,24(sp)
    80002ddc:	6942                	ld	s2,16(sp)
    80002dde:	69a2                	ld	s3,8(sp)
    80002de0:	6a02                	ld	s4,0(sp)
    80002de2:	6145                	addi	sp,sp,48
    80002de4:	8082                	ret
      addr = balloc(ip->dev);
    80002de6:	0009a503          	lw	a0,0(s3)
    80002dea:	e45ff0ef          	jal	ra,80002c2e <balloc>
    80002dee:	0005091b          	sext.w	s2,a0
      if(addr){
    80002df2:	fc090ee3          	beqz	s2,80002dce <bmap+0x8c>
        a[bn] = addr;
    80002df6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002dfa:	8552                	mv	a0,s4
    80002dfc:	4f9000ef          	jal	ra,80003af4 <log_write>
    80002e00:	b7f9                	j	80002dce <bmap+0x8c>
  panic("bmap: out of range");
    80002e02:	00004517          	auipc	a0,0x4
    80002e06:	7a650513          	addi	a0,a0,1958 # 800075a8 <syscalls+0x118>
    80002e0a:	94dfd0ef          	jal	ra,80000756 <panic>

0000000080002e0e <iget>:
{
    80002e0e:	7179                	addi	sp,sp,-48
    80002e10:	f406                	sd	ra,40(sp)
    80002e12:	f022                	sd	s0,32(sp)
    80002e14:	ec26                	sd	s1,24(sp)
    80002e16:	e84a                	sd	s2,16(sp)
    80002e18:	e44e                	sd	s3,8(sp)
    80002e1a:	e052                	sd	s4,0(sp)
    80002e1c:	1800                	addi	s0,sp,48
    80002e1e:	89aa                	mv	s3,a0
    80002e20:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002e22:	0001b517          	auipc	a0,0x1b
    80002e26:	13650513          	addi	a0,a0,310 # 8001df58 <itable>
    80002e2a:	d71fd0ef          	jal	ra,80000b9a <acquire>
  empty = 0;
    80002e2e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002e30:	0001b497          	auipc	s1,0x1b
    80002e34:	14048493          	addi	s1,s1,320 # 8001df70 <itable+0x18>
    80002e38:	0001d697          	auipc	a3,0x1d
    80002e3c:	bc868693          	addi	a3,a3,-1080 # 8001fa00 <log>
    80002e40:	a039                	j	80002e4e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002e42:	02090963          	beqz	s2,80002e74 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002e46:	08848493          	addi	s1,s1,136
    80002e4a:	02d48863          	beq	s1,a3,80002e7a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002e4e:	449c                	lw	a5,8(s1)
    80002e50:	fef059e3          	blez	a5,80002e42 <iget+0x34>
    80002e54:	4098                	lw	a4,0(s1)
    80002e56:	ff3716e3          	bne	a4,s3,80002e42 <iget+0x34>
    80002e5a:	40d8                	lw	a4,4(s1)
    80002e5c:	ff4713e3          	bne	a4,s4,80002e42 <iget+0x34>
      ip->ref++;
    80002e60:	2785                	addiw	a5,a5,1
    80002e62:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002e64:	0001b517          	auipc	a0,0x1b
    80002e68:	0f450513          	addi	a0,a0,244 # 8001df58 <itable>
    80002e6c:	dc7fd0ef          	jal	ra,80000c32 <release>
      return ip;
    80002e70:	8926                	mv	s2,s1
    80002e72:	a02d                	j	80002e9c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002e74:	fbe9                	bnez	a5,80002e46 <iget+0x38>
    80002e76:	8926                	mv	s2,s1
    80002e78:	b7f9                	j	80002e46 <iget+0x38>
  if(empty == 0)
    80002e7a:	02090a63          	beqz	s2,80002eae <iget+0xa0>
  ip->dev = dev;
    80002e7e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002e82:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002e86:	4785                	li	a5,1
    80002e88:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002e8c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002e90:	0001b517          	auipc	a0,0x1b
    80002e94:	0c850513          	addi	a0,a0,200 # 8001df58 <itable>
    80002e98:	d9bfd0ef          	jal	ra,80000c32 <release>
}
    80002e9c:	854a                	mv	a0,s2
    80002e9e:	70a2                	ld	ra,40(sp)
    80002ea0:	7402                	ld	s0,32(sp)
    80002ea2:	64e2                	ld	s1,24(sp)
    80002ea4:	6942                	ld	s2,16(sp)
    80002ea6:	69a2                	ld	s3,8(sp)
    80002ea8:	6a02                	ld	s4,0(sp)
    80002eaa:	6145                	addi	sp,sp,48
    80002eac:	8082                	ret
    panic("iget: no inodes");
    80002eae:	00004517          	auipc	a0,0x4
    80002eb2:	71250513          	addi	a0,a0,1810 # 800075c0 <syscalls+0x130>
    80002eb6:	8a1fd0ef          	jal	ra,80000756 <panic>

0000000080002eba <fsinit>:
fsinit(int dev) {
    80002eba:	7179                	addi	sp,sp,-48
    80002ebc:	f406                	sd	ra,40(sp)
    80002ebe:	f022                	sd	s0,32(sp)
    80002ec0:	ec26                	sd	s1,24(sp)
    80002ec2:	e84a                	sd	s2,16(sp)
    80002ec4:	e44e                	sd	s3,8(sp)
    80002ec6:	1800                	addi	s0,sp,48
    80002ec8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002eca:	4585                	li	a1,1
    80002ecc:	afdff0ef          	jal	ra,800029c8 <bread>
    80002ed0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002ed2:	0001b997          	auipc	s3,0x1b
    80002ed6:	06698993          	addi	s3,s3,102 # 8001df38 <sb>
    80002eda:	02000613          	li	a2,32
    80002ede:	05850593          	addi	a1,a0,88
    80002ee2:	854e                	mv	a0,s3
    80002ee4:	de7fd0ef          	jal	ra,80000cca <memmove>
  brelse(bp);
    80002ee8:	8526                	mv	a0,s1
    80002eea:	be7ff0ef          	jal	ra,80002ad0 <brelse>
  if(sb.magic != FSMAGIC)
    80002eee:	0009a703          	lw	a4,0(s3)
    80002ef2:	102037b7          	lui	a5,0x10203
    80002ef6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002efa:	02f71063          	bne	a4,a5,80002f1a <fsinit+0x60>
  initlog(dev, &sb);
    80002efe:	0001b597          	auipc	a1,0x1b
    80002f02:	03a58593          	addi	a1,a1,58 # 8001df38 <sb>
    80002f06:	854a                	mv	a0,s2
    80002f08:	1d9000ef          	jal	ra,800038e0 <initlog>
}
    80002f0c:	70a2                	ld	ra,40(sp)
    80002f0e:	7402                	ld	s0,32(sp)
    80002f10:	64e2                	ld	s1,24(sp)
    80002f12:	6942                	ld	s2,16(sp)
    80002f14:	69a2                	ld	s3,8(sp)
    80002f16:	6145                	addi	sp,sp,48
    80002f18:	8082                	ret
    panic("invalid file system");
    80002f1a:	00004517          	auipc	a0,0x4
    80002f1e:	6b650513          	addi	a0,a0,1718 # 800075d0 <syscalls+0x140>
    80002f22:	835fd0ef          	jal	ra,80000756 <panic>

0000000080002f26 <iinit>:
{
    80002f26:	7179                	addi	sp,sp,-48
    80002f28:	f406                	sd	ra,40(sp)
    80002f2a:	f022                	sd	s0,32(sp)
    80002f2c:	ec26                	sd	s1,24(sp)
    80002f2e:	e84a                	sd	s2,16(sp)
    80002f30:	e44e                	sd	s3,8(sp)
    80002f32:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002f34:	00004597          	auipc	a1,0x4
    80002f38:	6b458593          	addi	a1,a1,1716 # 800075e8 <syscalls+0x158>
    80002f3c:	0001b517          	auipc	a0,0x1b
    80002f40:	01c50513          	addi	a0,a0,28 # 8001df58 <itable>
    80002f44:	bd7fd0ef          	jal	ra,80000b1a <initlock>
  for(i = 0; i < NINODE; i++) {
    80002f48:	0001b497          	auipc	s1,0x1b
    80002f4c:	03848493          	addi	s1,s1,56 # 8001df80 <itable+0x28>
    80002f50:	0001d997          	auipc	s3,0x1d
    80002f54:	ac098993          	addi	s3,s3,-1344 # 8001fa10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002f58:	00004917          	auipc	s2,0x4
    80002f5c:	69890913          	addi	s2,s2,1688 # 800075f0 <syscalls+0x160>
    80002f60:	85ca                	mv	a1,s2
    80002f62:	8526                	mv	a0,s1
    80002f64:	463000ef          	jal	ra,80003bc6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002f68:	08848493          	addi	s1,s1,136
    80002f6c:	ff349ae3          	bne	s1,s3,80002f60 <iinit+0x3a>
}
    80002f70:	70a2                	ld	ra,40(sp)
    80002f72:	7402                	ld	s0,32(sp)
    80002f74:	64e2                	ld	s1,24(sp)
    80002f76:	6942                	ld	s2,16(sp)
    80002f78:	69a2                	ld	s3,8(sp)
    80002f7a:	6145                	addi	sp,sp,48
    80002f7c:	8082                	ret

0000000080002f7e <ialloc>:
{
    80002f7e:	715d                	addi	sp,sp,-80
    80002f80:	e486                	sd	ra,72(sp)
    80002f82:	e0a2                	sd	s0,64(sp)
    80002f84:	fc26                	sd	s1,56(sp)
    80002f86:	f84a                	sd	s2,48(sp)
    80002f88:	f44e                	sd	s3,40(sp)
    80002f8a:	f052                	sd	s4,32(sp)
    80002f8c:	ec56                	sd	s5,24(sp)
    80002f8e:	e85a                	sd	s6,16(sp)
    80002f90:	e45e                	sd	s7,8(sp)
    80002f92:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002f94:	0001b717          	auipc	a4,0x1b
    80002f98:	fb072703          	lw	a4,-80(a4) # 8001df44 <sb+0xc>
    80002f9c:	4785                	li	a5,1
    80002f9e:	04e7f663          	bgeu	a5,a4,80002fea <ialloc+0x6c>
    80002fa2:	8aaa                	mv	s5,a0
    80002fa4:	8bae                	mv	s7,a1
    80002fa6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002fa8:	0001ba17          	auipc	s4,0x1b
    80002fac:	f90a0a13          	addi	s4,s4,-112 # 8001df38 <sb>
    80002fb0:	00048b1b          	sext.w	s6,s1
    80002fb4:	0044d793          	srli	a5,s1,0x4
    80002fb8:	018a2583          	lw	a1,24(s4)
    80002fbc:	9dbd                	addw	a1,a1,a5
    80002fbe:	8556                	mv	a0,s5
    80002fc0:	a09ff0ef          	jal	ra,800029c8 <bread>
    80002fc4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002fc6:	05850993          	addi	s3,a0,88
    80002fca:	00f4f793          	andi	a5,s1,15
    80002fce:	079a                	slli	a5,a5,0x6
    80002fd0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002fd2:	00099783          	lh	a5,0(s3)
    80002fd6:	cf85                	beqz	a5,8000300e <ialloc+0x90>
    brelse(bp);
    80002fd8:	af9ff0ef          	jal	ra,80002ad0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002fdc:	0485                	addi	s1,s1,1
    80002fde:	00ca2703          	lw	a4,12(s4)
    80002fe2:	0004879b          	sext.w	a5,s1
    80002fe6:	fce7e5e3          	bltu	a5,a4,80002fb0 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002fea:	00004517          	auipc	a0,0x4
    80002fee:	60e50513          	addi	a0,a0,1550 # 800075f8 <syscalls+0x168>
    80002ff2:	cb0fd0ef          	jal	ra,800004a2 <printf>
  return 0;
    80002ff6:	4501                	li	a0,0
}
    80002ff8:	60a6                	ld	ra,72(sp)
    80002ffa:	6406                	ld	s0,64(sp)
    80002ffc:	74e2                	ld	s1,56(sp)
    80002ffe:	7942                	ld	s2,48(sp)
    80003000:	79a2                	ld	s3,40(sp)
    80003002:	7a02                	ld	s4,32(sp)
    80003004:	6ae2                	ld	s5,24(sp)
    80003006:	6b42                	ld	s6,16(sp)
    80003008:	6ba2                	ld	s7,8(sp)
    8000300a:	6161                	addi	sp,sp,80
    8000300c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000300e:	04000613          	li	a2,64
    80003012:	4581                	li	a1,0
    80003014:	854e                	mv	a0,s3
    80003016:	c59fd0ef          	jal	ra,80000c6e <memset>
      dip->type = type;
    8000301a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000301e:	854a                	mv	a0,s2
    80003020:	2d5000ef          	jal	ra,80003af4 <log_write>
      brelse(bp);
    80003024:	854a                	mv	a0,s2
    80003026:	aabff0ef          	jal	ra,80002ad0 <brelse>
      return iget(dev, inum);
    8000302a:	85da                	mv	a1,s6
    8000302c:	8556                	mv	a0,s5
    8000302e:	de1ff0ef          	jal	ra,80002e0e <iget>
    80003032:	b7d9                	j	80002ff8 <ialloc+0x7a>

0000000080003034 <iupdate>:
{
    80003034:	1101                	addi	sp,sp,-32
    80003036:	ec06                	sd	ra,24(sp)
    80003038:	e822                	sd	s0,16(sp)
    8000303a:	e426                	sd	s1,8(sp)
    8000303c:	e04a                	sd	s2,0(sp)
    8000303e:	1000                	addi	s0,sp,32
    80003040:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003042:	415c                	lw	a5,4(a0)
    80003044:	0047d79b          	srliw	a5,a5,0x4
    80003048:	0001b597          	auipc	a1,0x1b
    8000304c:	f085a583          	lw	a1,-248(a1) # 8001df50 <sb+0x18>
    80003050:	9dbd                	addw	a1,a1,a5
    80003052:	4108                	lw	a0,0(a0)
    80003054:	975ff0ef          	jal	ra,800029c8 <bread>
    80003058:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000305a:	05850793          	addi	a5,a0,88
    8000305e:	40c8                	lw	a0,4(s1)
    80003060:	893d                	andi	a0,a0,15
    80003062:	051a                	slli	a0,a0,0x6
    80003064:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003066:	04449703          	lh	a4,68(s1)
    8000306a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000306e:	04649703          	lh	a4,70(s1)
    80003072:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003076:	04849703          	lh	a4,72(s1)
    8000307a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000307e:	04a49703          	lh	a4,74(s1)
    80003082:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003086:	44f8                	lw	a4,76(s1)
    80003088:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000308a:	03400613          	li	a2,52
    8000308e:	05048593          	addi	a1,s1,80
    80003092:	0531                	addi	a0,a0,12
    80003094:	c37fd0ef          	jal	ra,80000cca <memmove>
  log_write(bp);
    80003098:	854a                	mv	a0,s2
    8000309a:	25b000ef          	jal	ra,80003af4 <log_write>
  brelse(bp);
    8000309e:	854a                	mv	a0,s2
    800030a0:	a31ff0ef          	jal	ra,80002ad0 <brelse>
}
    800030a4:	60e2                	ld	ra,24(sp)
    800030a6:	6442                	ld	s0,16(sp)
    800030a8:	64a2                	ld	s1,8(sp)
    800030aa:	6902                	ld	s2,0(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret

00000000800030b0 <idup>:
{
    800030b0:	1101                	addi	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	1000                	addi	s0,sp,32
    800030ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800030bc:	0001b517          	auipc	a0,0x1b
    800030c0:	e9c50513          	addi	a0,a0,-356 # 8001df58 <itable>
    800030c4:	ad7fd0ef          	jal	ra,80000b9a <acquire>
  ip->ref++;
    800030c8:	449c                	lw	a5,8(s1)
    800030ca:	2785                	addiw	a5,a5,1
    800030cc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800030ce:	0001b517          	auipc	a0,0x1b
    800030d2:	e8a50513          	addi	a0,a0,-374 # 8001df58 <itable>
    800030d6:	b5dfd0ef          	jal	ra,80000c32 <release>
}
    800030da:	8526                	mv	a0,s1
    800030dc:	60e2                	ld	ra,24(sp)
    800030de:	6442                	ld	s0,16(sp)
    800030e0:	64a2                	ld	s1,8(sp)
    800030e2:	6105                	addi	sp,sp,32
    800030e4:	8082                	ret

00000000800030e6 <ilock>:
{
    800030e6:	1101                	addi	sp,sp,-32
    800030e8:	ec06                	sd	ra,24(sp)
    800030ea:	e822                	sd	s0,16(sp)
    800030ec:	e426                	sd	s1,8(sp)
    800030ee:	e04a                	sd	s2,0(sp)
    800030f0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800030f2:	c105                	beqz	a0,80003112 <ilock+0x2c>
    800030f4:	84aa                	mv	s1,a0
    800030f6:	451c                	lw	a5,8(a0)
    800030f8:	00f05d63          	blez	a5,80003112 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800030fc:	0541                	addi	a0,a0,16
    800030fe:	2ff000ef          	jal	ra,80003bfc <acquiresleep>
  if(ip->valid == 0){
    80003102:	40bc                	lw	a5,64(s1)
    80003104:	cf89                	beqz	a5,8000311e <ilock+0x38>
}
    80003106:	60e2                	ld	ra,24(sp)
    80003108:	6442                	ld	s0,16(sp)
    8000310a:	64a2                	ld	s1,8(sp)
    8000310c:	6902                	ld	s2,0(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret
    panic("ilock");
    80003112:	00004517          	auipc	a0,0x4
    80003116:	4fe50513          	addi	a0,a0,1278 # 80007610 <syscalls+0x180>
    8000311a:	e3cfd0ef          	jal	ra,80000756 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000311e:	40dc                	lw	a5,4(s1)
    80003120:	0047d79b          	srliw	a5,a5,0x4
    80003124:	0001b597          	auipc	a1,0x1b
    80003128:	e2c5a583          	lw	a1,-468(a1) # 8001df50 <sb+0x18>
    8000312c:	9dbd                	addw	a1,a1,a5
    8000312e:	4088                	lw	a0,0(s1)
    80003130:	899ff0ef          	jal	ra,800029c8 <bread>
    80003134:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003136:	05850593          	addi	a1,a0,88
    8000313a:	40dc                	lw	a5,4(s1)
    8000313c:	8bbd                	andi	a5,a5,15
    8000313e:	079a                	slli	a5,a5,0x6
    80003140:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003142:	00059783          	lh	a5,0(a1)
    80003146:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000314a:	00259783          	lh	a5,2(a1)
    8000314e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003152:	00459783          	lh	a5,4(a1)
    80003156:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000315a:	00659783          	lh	a5,6(a1)
    8000315e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003162:	459c                	lw	a5,8(a1)
    80003164:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003166:	03400613          	li	a2,52
    8000316a:	05b1                	addi	a1,a1,12
    8000316c:	05048513          	addi	a0,s1,80
    80003170:	b5bfd0ef          	jal	ra,80000cca <memmove>
    brelse(bp);
    80003174:	854a                	mv	a0,s2
    80003176:	95bff0ef          	jal	ra,80002ad0 <brelse>
    ip->valid = 1;
    8000317a:	4785                	li	a5,1
    8000317c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000317e:	04449783          	lh	a5,68(s1)
    80003182:	f3d1                	bnez	a5,80003106 <ilock+0x20>
      panic("ilock: no type");
    80003184:	00004517          	auipc	a0,0x4
    80003188:	49450513          	addi	a0,a0,1172 # 80007618 <syscalls+0x188>
    8000318c:	dcafd0ef          	jal	ra,80000756 <panic>

0000000080003190 <iunlock>:
{
    80003190:	1101                	addi	sp,sp,-32
    80003192:	ec06                	sd	ra,24(sp)
    80003194:	e822                	sd	s0,16(sp)
    80003196:	e426                	sd	s1,8(sp)
    80003198:	e04a                	sd	s2,0(sp)
    8000319a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000319c:	c505                	beqz	a0,800031c4 <iunlock+0x34>
    8000319e:	84aa                	mv	s1,a0
    800031a0:	01050913          	addi	s2,a0,16
    800031a4:	854a                	mv	a0,s2
    800031a6:	2d5000ef          	jal	ra,80003c7a <holdingsleep>
    800031aa:	cd09                	beqz	a0,800031c4 <iunlock+0x34>
    800031ac:	449c                	lw	a5,8(s1)
    800031ae:	00f05b63          	blez	a5,800031c4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800031b2:	854a                	mv	a0,s2
    800031b4:	28f000ef          	jal	ra,80003c42 <releasesleep>
}
    800031b8:	60e2                	ld	ra,24(sp)
    800031ba:	6442                	ld	s0,16(sp)
    800031bc:	64a2                	ld	s1,8(sp)
    800031be:	6902                	ld	s2,0(sp)
    800031c0:	6105                	addi	sp,sp,32
    800031c2:	8082                	ret
    panic("iunlock");
    800031c4:	00004517          	auipc	a0,0x4
    800031c8:	46450513          	addi	a0,a0,1124 # 80007628 <syscalls+0x198>
    800031cc:	d8afd0ef          	jal	ra,80000756 <panic>

00000000800031d0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800031d0:	7179                	addi	sp,sp,-48
    800031d2:	f406                	sd	ra,40(sp)
    800031d4:	f022                	sd	s0,32(sp)
    800031d6:	ec26                	sd	s1,24(sp)
    800031d8:	e84a                	sd	s2,16(sp)
    800031da:	e44e                	sd	s3,8(sp)
    800031dc:	e052                	sd	s4,0(sp)
    800031de:	1800                	addi	s0,sp,48
    800031e0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800031e2:	05050493          	addi	s1,a0,80
    800031e6:	08050913          	addi	s2,a0,128
    800031ea:	a021                	j	800031f2 <itrunc+0x22>
    800031ec:	0491                	addi	s1,s1,4
    800031ee:	01248b63          	beq	s1,s2,80003204 <itrunc+0x34>
    if(ip->addrs[i]){
    800031f2:	408c                	lw	a1,0(s1)
    800031f4:	dde5                	beqz	a1,800031ec <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800031f6:	0009a503          	lw	a0,0(s3)
    800031fa:	9c9ff0ef          	jal	ra,80002bc2 <bfree>
      ip->addrs[i] = 0;
    800031fe:	0004a023          	sw	zero,0(s1)
    80003202:	b7ed                	j	800031ec <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003204:	0809a583          	lw	a1,128(s3)
    80003208:	ed91                	bnez	a1,80003224 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000320a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000320e:	854e                	mv	a0,s3
    80003210:	e25ff0ef          	jal	ra,80003034 <iupdate>
}
    80003214:	70a2                	ld	ra,40(sp)
    80003216:	7402                	ld	s0,32(sp)
    80003218:	64e2                	ld	s1,24(sp)
    8000321a:	6942                	ld	s2,16(sp)
    8000321c:	69a2                	ld	s3,8(sp)
    8000321e:	6a02                	ld	s4,0(sp)
    80003220:	6145                	addi	sp,sp,48
    80003222:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003224:	0009a503          	lw	a0,0(s3)
    80003228:	fa0ff0ef          	jal	ra,800029c8 <bread>
    8000322c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000322e:	05850493          	addi	s1,a0,88
    80003232:	45850913          	addi	s2,a0,1112
    80003236:	a021                	j	8000323e <itrunc+0x6e>
    80003238:	0491                	addi	s1,s1,4
    8000323a:	01248963          	beq	s1,s2,8000324c <itrunc+0x7c>
      if(a[j])
    8000323e:	408c                	lw	a1,0(s1)
    80003240:	dde5                	beqz	a1,80003238 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003242:	0009a503          	lw	a0,0(s3)
    80003246:	97dff0ef          	jal	ra,80002bc2 <bfree>
    8000324a:	b7fd                	j	80003238 <itrunc+0x68>
    brelse(bp);
    8000324c:	8552                	mv	a0,s4
    8000324e:	883ff0ef          	jal	ra,80002ad0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003252:	0809a583          	lw	a1,128(s3)
    80003256:	0009a503          	lw	a0,0(s3)
    8000325a:	969ff0ef          	jal	ra,80002bc2 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000325e:	0809a023          	sw	zero,128(s3)
    80003262:	b765                	j	8000320a <itrunc+0x3a>

0000000080003264 <iput>:
{
    80003264:	1101                	addi	sp,sp,-32
    80003266:	ec06                	sd	ra,24(sp)
    80003268:	e822                	sd	s0,16(sp)
    8000326a:	e426                	sd	s1,8(sp)
    8000326c:	e04a                	sd	s2,0(sp)
    8000326e:	1000                	addi	s0,sp,32
    80003270:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003272:	0001b517          	auipc	a0,0x1b
    80003276:	ce650513          	addi	a0,a0,-794 # 8001df58 <itable>
    8000327a:	921fd0ef          	jal	ra,80000b9a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000327e:	4498                	lw	a4,8(s1)
    80003280:	4785                	li	a5,1
    80003282:	02f70163          	beq	a4,a5,800032a4 <iput+0x40>
  ip->ref--;
    80003286:	449c                	lw	a5,8(s1)
    80003288:	37fd                	addiw	a5,a5,-1
    8000328a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000328c:	0001b517          	auipc	a0,0x1b
    80003290:	ccc50513          	addi	a0,a0,-820 # 8001df58 <itable>
    80003294:	99ffd0ef          	jal	ra,80000c32 <release>
}
    80003298:	60e2                	ld	ra,24(sp)
    8000329a:	6442                	ld	s0,16(sp)
    8000329c:	64a2                	ld	s1,8(sp)
    8000329e:	6902                	ld	s2,0(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800032a4:	40bc                	lw	a5,64(s1)
    800032a6:	d3e5                	beqz	a5,80003286 <iput+0x22>
    800032a8:	04a49783          	lh	a5,74(s1)
    800032ac:	ffe9                	bnez	a5,80003286 <iput+0x22>
    acquiresleep(&ip->lock);
    800032ae:	01048913          	addi	s2,s1,16
    800032b2:	854a                	mv	a0,s2
    800032b4:	149000ef          	jal	ra,80003bfc <acquiresleep>
    release(&itable.lock);
    800032b8:	0001b517          	auipc	a0,0x1b
    800032bc:	ca050513          	addi	a0,a0,-864 # 8001df58 <itable>
    800032c0:	973fd0ef          	jal	ra,80000c32 <release>
    itrunc(ip);
    800032c4:	8526                	mv	a0,s1
    800032c6:	f0bff0ef          	jal	ra,800031d0 <itrunc>
    ip->type = 0;
    800032ca:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800032ce:	8526                	mv	a0,s1
    800032d0:	d65ff0ef          	jal	ra,80003034 <iupdate>
    ip->valid = 0;
    800032d4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800032d8:	854a                	mv	a0,s2
    800032da:	169000ef          	jal	ra,80003c42 <releasesleep>
    acquire(&itable.lock);
    800032de:	0001b517          	auipc	a0,0x1b
    800032e2:	c7a50513          	addi	a0,a0,-902 # 8001df58 <itable>
    800032e6:	8b5fd0ef          	jal	ra,80000b9a <acquire>
    800032ea:	bf71                	j	80003286 <iput+0x22>

00000000800032ec <iunlockput>:
{
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84aa                	mv	s1,a0
  iunlock(ip);
    800032f8:	e99ff0ef          	jal	ra,80003190 <iunlock>
  iput(ip);
    800032fc:	8526                	mv	a0,s1
    800032fe:	f67ff0ef          	jal	ra,80003264 <iput>
}
    80003302:	60e2                	ld	ra,24(sp)
    80003304:	6442                	ld	s0,16(sp)
    80003306:	64a2                	ld	s1,8(sp)
    80003308:	6105                	addi	sp,sp,32
    8000330a:	8082                	ret

000000008000330c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000330c:	1141                	addi	sp,sp,-16
    8000330e:	e422                	sd	s0,8(sp)
    80003310:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003312:	411c                	lw	a5,0(a0)
    80003314:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003316:	415c                	lw	a5,4(a0)
    80003318:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000331a:	04451783          	lh	a5,68(a0)
    8000331e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003322:	04a51783          	lh	a5,74(a0)
    80003326:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000332a:	04c56783          	lwu	a5,76(a0)
    8000332e:	e99c                	sd	a5,16(a1)
}
    80003330:	6422                	ld	s0,8(sp)
    80003332:	0141                	addi	sp,sp,16
    80003334:	8082                	ret

0000000080003336 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003336:	457c                	lw	a5,76(a0)
    80003338:	0cd7ef63          	bltu	a5,a3,80003416 <readi+0xe0>
{
    8000333c:	7159                	addi	sp,sp,-112
    8000333e:	f486                	sd	ra,104(sp)
    80003340:	f0a2                	sd	s0,96(sp)
    80003342:	eca6                	sd	s1,88(sp)
    80003344:	e8ca                	sd	s2,80(sp)
    80003346:	e4ce                	sd	s3,72(sp)
    80003348:	e0d2                	sd	s4,64(sp)
    8000334a:	fc56                	sd	s5,56(sp)
    8000334c:	f85a                	sd	s6,48(sp)
    8000334e:	f45e                	sd	s7,40(sp)
    80003350:	f062                	sd	s8,32(sp)
    80003352:	ec66                	sd	s9,24(sp)
    80003354:	e86a                	sd	s10,16(sp)
    80003356:	e46e                	sd	s11,8(sp)
    80003358:	1880                	addi	s0,sp,112
    8000335a:	8b2a                	mv	s6,a0
    8000335c:	8bae                	mv	s7,a1
    8000335e:	8a32                	mv	s4,a2
    80003360:	84b6                	mv	s1,a3
    80003362:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003364:	9f35                	addw	a4,a4,a3
    return 0;
    80003366:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003368:	08d76663          	bltu	a4,a3,800033f4 <readi+0xbe>
  if(off + n > ip->size)
    8000336c:	00e7f463          	bgeu	a5,a4,80003374 <readi+0x3e>
    n = ip->size - off;
    80003370:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003374:	080a8f63          	beqz	s5,80003412 <readi+0xdc>
    80003378:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000337a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000337e:	5c7d                	li	s8,-1
    80003380:	a80d                	j	800033b2 <readi+0x7c>
    80003382:	020d1d93          	slli	s11,s10,0x20
    80003386:	020ddd93          	srli	s11,s11,0x20
    8000338a:	05890793          	addi	a5,s2,88
    8000338e:	86ee                	mv	a3,s11
    80003390:	963e                	add	a2,a2,a5
    80003392:	85d2                	mv	a1,s4
    80003394:	855e                	mv	a0,s7
    80003396:	dbffe0ef          	jal	ra,80002154 <either_copyout>
    8000339a:	05850763          	beq	a0,s8,800033e8 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000339e:	854a                	mv	a0,s2
    800033a0:	f30ff0ef          	jal	ra,80002ad0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800033a4:	013d09bb          	addw	s3,s10,s3
    800033a8:	009d04bb          	addw	s1,s10,s1
    800033ac:	9a6e                	add	s4,s4,s11
    800033ae:	0559f163          	bgeu	s3,s5,800033f0 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800033b2:	00a4d59b          	srliw	a1,s1,0xa
    800033b6:	855a                	mv	a0,s6
    800033b8:	98bff0ef          	jal	ra,80002d42 <bmap>
    800033bc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800033c0:	c985                	beqz	a1,800033f0 <readi+0xba>
    bp = bread(ip->dev, addr);
    800033c2:	000b2503          	lw	a0,0(s6)
    800033c6:	e02ff0ef          	jal	ra,800029c8 <bread>
    800033ca:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800033cc:	3ff4f613          	andi	a2,s1,1023
    800033d0:	40cc87bb          	subw	a5,s9,a2
    800033d4:	413a873b          	subw	a4,s5,s3
    800033d8:	8d3e                	mv	s10,a5
    800033da:	2781                	sext.w	a5,a5
    800033dc:	0007069b          	sext.w	a3,a4
    800033e0:	faf6f1e3          	bgeu	a3,a5,80003382 <readi+0x4c>
    800033e4:	8d3a                	mv	s10,a4
    800033e6:	bf71                	j	80003382 <readi+0x4c>
      brelse(bp);
    800033e8:	854a                	mv	a0,s2
    800033ea:	ee6ff0ef          	jal	ra,80002ad0 <brelse>
      tot = -1;
    800033ee:	59fd                	li	s3,-1
  }
  return tot;
    800033f0:	0009851b          	sext.w	a0,s3
}
    800033f4:	70a6                	ld	ra,104(sp)
    800033f6:	7406                	ld	s0,96(sp)
    800033f8:	64e6                	ld	s1,88(sp)
    800033fa:	6946                	ld	s2,80(sp)
    800033fc:	69a6                	ld	s3,72(sp)
    800033fe:	6a06                	ld	s4,64(sp)
    80003400:	7ae2                	ld	s5,56(sp)
    80003402:	7b42                	ld	s6,48(sp)
    80003404:	7ba2                	ld	s7,40(sp)
    80003406:	7c02                	ld	s8,32(sp)
    80003408:	6ce2                	ld	s9,24(sp)
    8000340a:	6d42                	ld	s10,16(sp)
    8000340c:	6da2                	ld	s11,8(sp)
    8000340e:	6165                	addi	sp,sp,112
    80003410:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003412:	89d6                	mv	s3,s5
    80003414:	bff1                	j	800033f0 <readi+0xba>
    return 0;
    80003416:	4501                	li	a0,0
}
    80003418:	8082                	ret

000000008000341a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000341a:	457c                	lw	a5,76(a0)
    8000341c:	0ed7ea63          	bltu	a5,a3,80003510 <writei+0xf6>
{
    80003420:	7159                	addi	sp,sp,-112
    80003422:	f486                	sd	ra,104(sp)
    80003424:	f0a2                	sd	s0,96(sp)
    80003426:	eca6                	sd	s1,88(sp)
    80003428:	e8ca                	sd	s2,80(sp)
    8000342a:	e4ce                	sd	s3,72(sp)
    8000342c:	e0d2                	sd	s4,64(sp)
    8000342e:	fc56                	sd	s5,56(sp)
    80003430:	f85a                	sd	s6,48(sp)
    80003432:	f45e                	sd	s7,40(sp)
    80003434:	f062                	sd	s8,32(sp)
    80003436:	ec66                	sd	s9,24(sp)
    80003438:	e86a                	sd	s10,16(sp)
    8000343a:	e46e                	sd	s11,8(sp)
    8000343c:	1880                	addi	s0,sp,112
    8000343e:	8aaa                	mv	s5,a0
    80003440:	8bae                	mv	s7,a1
    80003442:	8a32                	mv	s4,a2
    80003444:	8936                	mv	s2,a3
    80003446:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003448:	00e687bb          	addw	a5,a3,a4
    8000344c:	0cd7e463          	bltu	a5,a3,80003514 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003450:	00043737          	lui	a4,0x43
    80003454:	0cf76263          	bltu	a4,a5,80003518 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003458:	0a0b0a63          	beqz	s6,8000350c <writei+0xf2>
    8000345c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000345e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003462:	5c7d                	li	s8,-1
    80003464:	a825                	j	8000349c <writei+0x82>
    80003466:	020d1d93          	slli	s11,s10,0x20
    8000346a:	020ddd93          	srli	s11,s11,0x20
    8000346e:	05848793          	addi	a5,s1,88
    80003472:	86ee                	mv	a3,s11
    80003474:	8652                	mv	a2,s4
    80003476:	85de                	mv	a1,s7
    80003478:	953e                	add	a0,a0,a5
    8000347a:	d25fe0ef          	jal	ra,8000219e <either_copyin>
    8000347e:	05850a63          	beq	a0,s8,800034d2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003482:	8526                	mv	a0,s1
    80003484:	670000ef          	jal	ra,80003af4 <log_write>
    brelse(bp);
    80003488:	8526                	mv	a0,s1
    8000348a:	e46ff0ef          	jal	ra,80002ad0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000348e:	013d09bb          	addw	s3,s10,s3
    80003492:	012d093b          	addw	s2,s10,s2
    80003496:	9a6e                	add	s4,s4,s11
    80003498:	0569f063          	bgeu	s3,s6,800034d8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000349c:	00a9559b          	srliw	a1,s2,0xa
    800034a0:	8556                	mv	a0,s5
    800034a2:	8a1ff0ef          	jal	ra,80002d42 <bmap>
    800034a6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034aa:	c59d                	beqz	a1,800034d8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800034ac:	000aa503          	lw	a0,0(s5)
    800034b0:	d18ff0ef          	jal	ra,800029c8 <bread>
    800034b4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800034b6:	3ff97513          	andi	a0,s2,1023
    800034ba:	40ac87bb          	subw	a5,s9,a0
    800034be:	413b073b          	subw	a4,s6,s3
    800034c2:	8d3e                	mv	s10,a5
    800034c4:	2781                	sext.w	a5,a5
    800034c6:	0007069b          	sext.w	a3,a4
    800034ca:	f8f6fee3          	bgeu	a3,a5,80003466 <writei+0x4c>
    800034ce:	8d3a                	mv	s10,a4
    800034d0:	bf59                	j	80003466 <writei+0x4c>
      brelse(bp);
    800034d2:	8526                	mv	a0,s1
    800034d4:	dfcff0ef          	jal	ra,80002ad0 <brelse>
  }

  if(off > ip->size)
    800034d8:	04caa783          	lw	a5,76(s5)
    800034dc:	0127f463          	bgeu	a5,s2,800034e4 <writei+0xca>
    ip->size = off;
    800034e0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800034e4:	8556                	mv	a0,s5
    800034e6:	b4fff0ef          	jal	ra,80003034 <iupdate>

  return tot;
    800034ea:	0009851b          	sext.w	a0,s3
}
    800034ee:	70a6                	ld	ra,104(sp)
    800034f0:	7406                	ld	s0,96(sp)
    800034f2:	64e6                	ld	s1,88(sp)
    800034f4:	6946                	ld	s2,80(sp)
    800034f6:	69a6                	ld	s3,72(sp)
    800034f8:	6a06                	ld	s4,64(sp)
    800034fa:	7ae2                	ld	s5,56(sp)
    800034fc:	7b42                	ld	s6,48(sp)
    800034fe:	7ba2                	ld	s7,40(sp)
    80003500:	7c02                	ld	s8,32(sp)
    80003502:	6ce2                	ld	s9,24(sp)
    80003504:	6d42                	ld	s10,16(sp)
    80003506:	6da2                	ld	s11,8(sp)
    80003508:	6165                	addi	sp,sp,112
    8000350a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000350c:	89da                	mv	s3,s6
    8000350e:	bfd9                	j	800034e4 <writei+0xca>
    return -1;
    80003510:	557d                	li	a0,-1
}
    80003512:	8082                	ret
    return -1;
    80003514:	557d                	li	a0,-1
    80003516:	bfe1                	j	800034ee <writei+0xd4>
    return -1;
    80003518:	557d                	li	a0,-1
    8000351a:	bfd1                	j	800034ee <writei+0xd4>

000000008000351c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000351c:	1141                	addi	sp,sp,-16
    8000351e:	e406                	sd	ra,8(sp)
    80003520:	e022                	sd	s0,0(sp)
    80003522:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003524:	4639                	li	a2,14
    80003526:	815fd0ef          	jal	ra,80000d3a <strncmp>
}
    8000352a:	60a2                	ld	ra,8(sp)
    8000352c:	6402                	ld	s0,0(sp)
    8000352e:	0141                	addi	sp,sp,16
    80003530:	8082                	ret

0000000080003532 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003532:	7139                	addi	sp,sp,-64
    80003534:	fc06                	sd	ra,56(sp)
    80003536:	f822                	sd	s0,48(sp)
    80003538:	f426                	sd	s1,40(sp)
    8000353a:	f04a                	sd	s2,32(sp)
    8000353c:	ec4e                	sd	s3,24(sp)
    8000353e:	e852                	sd	s4,16(sp)
    80003540:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003542:	04451703          	lh	a4,68(a0)
    80003546:	4785                	li	a5,1
    80003548:	00f71a63          	bne	a4,a5,8000355c <dirlookup+0x2a>
    8000354c:	892a                	mv	s2,a0
    8000354e:	89ae                	mv	s3,a1
    80003550:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003552:	457c                	lw	a5,76(a0)
    80003554:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003556:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003558:	e39d                	bnez	a5,8000357e <dirlookup+0x4c>
    8000355a:	a095                	j	800035be <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000355c:	00004517          	auipc	a0,0x4
    80003560:	0d450513          	addi	a0,a0,212 # 80007630 <syscalls+0x1a0>
    80003564:	9f2fd0ef          	jal	ra,80000756 <panic>
      panic("dirlookup read");
    80003568:	00004517          	auipc	a0,0x4
    8000356c:	0e050513          	addi	a0,a0,224 # 80007648 <syscalls+0x1b8>
    80003570:	9e6fd0ef          	jal	ra,80000756 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003574:	24c1                	addiw	s1,s1,16
    80003576:	04c92783          	lw	a5,76(s2)
    8000357a:	04f4f163          	bgeu	s1,a5,800035bc <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000357e:	4741                	li	a4,16
    80003580:	86a6                	mv	a3,s1
    80003582:	fc040613          	addi	a2,s0,-64
    80003586:	4581                	li	a1,0
    80003588:	854a                	mv	a0,s2
    8000358a:	dadff0ef          	jal	ra,80003336 <readi>
    8000358e:	47c1                	li	a5,16
    80003590:	fcf51ce3          	bne	a0,a5,80003568 <dirlookup+0x36>
    if(de.inum == 0)
    80003594:	fc045783          	lhu	a5,-64(s0)
    80003598:	dff1                	beqz	a5,80003574 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000359a:	fc240593          	addi	a1,s0,-62
    8000359e:	854e                	mv	a0,s3
    800035a0:	f7dff0ef          	jal	ra,8000351c <namecmp>
    800035a4:	f961                	bnez	a0,80003574 <dirlookup+0x42>
      if(poff)
    800035a6:	000a0463          	beqz	s4,800035ae <dirlookup+0x7c>
        *poff = off;
    800035aa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800035ae:	fc045583          	lhu	a1,-64(s0)
    800035b2:	00092503          	lw	a0,0(s2)
    800035b6:	859ff0ef          	jal	ra,80002e0e <iget>
    800035ba:	a011                	j	800035be <dirlookup+0x8c>
  return 0;
    800035bc:	4501                	li	a0,0
}
    800035be:	70e2                	ld	ra,56(sp)
    800035c0:	7442                	ld	s0,48(sp)
    800035c2:	74a2                	ld	s1,40(sp)
    800035c4:	7902                	ld	s2,32(sp)
    800035c6:	69e2                	ld	s3,24(sp)
    800035c8:	6a42                	ld	s4,16(sp)
    800035ca:	6121                	addi	sp,sp,64
    800035cc:	8082                	ret

00000000800035ce <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800035ce:	711d                	addi	sp,sp,-96
    800035d0:	ec86                	sd	ra,88(sp)
    800035d2:	e8a2                	sd	s0,80(sp)
    800035d4:	e4a6                	sd	s1,72(sp)
    800035d6:	e0ca                	sd	s2,64(sp)
    800035d8:	fc4e                	sd	s3,56(sp)
    800035da:	f852                	sd	s4,48(sp)
    800035dc:	f456                	sd	s5,40(sp)
    800035de:	f05a                	sd	s6,32(sp)
    800035e0:	ec5e                	sd	s7,24(sp)
    800035e2:	e862                	sd	s8,16(sp)
    800035e4:	e466                	sd	s9,8(sp)
    800035e6:	1080                	addi	s0,sp,96
    800035e8:	84aa                	mv	s1,a0
    800035ea:	8aae                	mv	s5,a1
    800035ec:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800035ee:	00054703          	lbu	a4,0(a0)
    800035f2:	02f00793          	li	a5,47
    800035f6:	00f70f63          	beq	a4,a5,80003614 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800035fa:	a32fe0ef          	jal	ra,8000182c <myproc>
    800035fe:	15053503          	ld	a0,336(a0)
    80003602:	aafff0ef          	jal	ra,800030b0 <idup>
    80003606:	89aa                	mv	s3,a0
  while(*path == '/')
    80003608:	02f00913          	li	s2,47
  len = path - s;
    8000360c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000360e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003610:	4b85                	li	s7,1
    80003612:	a861                	j	800036aa <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003614:	4585                	li	a1,1
    80003616:	4505                	li	a0,1
    80003618:	ff6ff0ef          	jal	ra,80002e0e <iget>
    8000361c:	89aa                	mv	s3,a0
    8000361e:	b7ed                	j	80003608 <namex+0x3a>
      iunlockput(ip);
    80003620:	854e                	mv	a0,s3
    80003622:	ccbff0ef          	jal	ra,800032ec <iunlockput>
      return 0;
    80003626:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003628:	854e                	mv	a0,s3
    8000362a:	60e6                	ld	ra,88(sp)
    8000362c:	6446                	ld	s0,80(sp)
    8000362e:	64a6                	ld	s1,72(sp)
    80003630:	6906                	ld	s2,64(sp)
    80003632:	79e2                	ld	s3,56(sp)
    80003634:	7a42                	ld	s4,48(sp)
    80003636:	7aa2                	ld	s5,40(sp)
    80003638:	7b02                	ld	s6,32(sp)
    8000363a:	6be2                	ld	s7,24(sp)
    8000363c:	6c42                	ld	s8,16(sp)
    8000363e:	6ca2                	ld	s9,8(sp)
    80003640:	6125                	addi	sp,sp,96
    80003642:	8082                	ret
      iunlock(ip);
    80003644:	854e                	mv	a0,s3
    80003646:	b4bff0ef          	jal	ra,80003190 <iunlock>
      return ip;
    8000364a:	bff9                	j	80003628 <namex+0x5a>
      iunlockput(ip);
    8000364c:	854e                	mv	a0,s3
    8000364e:	c9fff0ef          	jal	ra,800032ec <iunlockput>
      return 0;
    80003652:	89e6                	mv	s3,s9
    80003654:	bfd1                	j	80003628 <namex+0x5a>
  len = path - s;
    80003656:	40b48633          	sub	a2,s1,a1
    8000365a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000365e:	079c5c63          	bge	s8,s9,800036d6 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003662:	4639                	li	a2,14
    80003664:	8552                	mv	a0,s4
    80003666:	e64fd0ef          	jal	ra,80000cca <memmove>
  while(*path == '/')
    8000366a:	0004c783          	lbu	a5,0(s1)
    8000366e:	01279763          	bne	a5,s2,8000367c <namex+0xae>
    path++;
    80003672:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003674:	0004c783          	lbu	a5,0(s1)
    80003678:	ff278de3          	beq	a5,s2,80003672 <namex+0xa4>
    ilock(ip);
    8000367c:	854e                	mv	a0,s3
    8000367e:	a69ff0ef          	jal	ra,800030e6 <ilock>
    if(ip->type != T_DIR){
    80003682:	04499783          	lh	a5,68(s3)
    80003686:	f9779de3          	bne	a5,s7,80003620 <namex+0x52>
    if(nameiparent && *path == '\0'){
    8000368a:	000a8563          	beqz	s5,80003694 <namex+0xc6>
    8000368e:	0004c783          	lbu	a5,0(s1)
    80003692:	dbcd                	beqz	a5,80003644 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003694:	865a                	mv	a2,s6
    80003696:	85d2                	mv	a1,s4
    80003698:	854e                	mv	a0,s3
    8000369a:	e99ff0ef          	jal	ra,80003532 <dirlookup>
    8000369e:	8caa                	mv	s9,a0
    800036a0:	d555                	beqz	a0,8000364c <namex+0x7e>
    iunlockput(ip);
    800036a2:	854e                	mv	a0,s3
    800036a4:	c49ff0ef          	jal	ra,800032ec <iunlockput>
    ip = next;
    800036a8:	89e6                	mv	s3,s9
  while(*path == '/')
    800036aa:	0004c783          	lbu	a5,0(s1)
    800036ae:	05279363          	bne	a5,s2,800036f4 <namex+0x126>
    path++;
    800036b2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800036b4:	0004c783          	lbu	a5,0(s1)
    800036b8:	ff278de3          	beq	a5,s2,800036b2 <namex+0xe4>
  if(*path == 0)
    800036bc:	c78d                	beqz	a5,800036e6 <namex+0x118>
    path++;
    800036be:	85a6                	mv	a1,s1
  len = path - s;
    800036c0:	8cda                	mv	s9,s6
    800036c2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800036c4:	01278963          	beq	a5,s2,800036d6 <namex+0x108>
    800036c8:	d7d9                	beqz	a5,80003656 <namex+0x88>
    path++;
    800036ca:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800036cc:	0004c783          	lbu	a5,0(s1)
    800036d0:	ff279ce3          	bne	a5,s2,800036c8 <namex+0xfa>
    800036d4:	b749                	j	80003656 <namex+0x88>
    memmove(name, s, len);
    800036d6:	2601                	sext.w	a2,a2
    800036d8:	8552                	mv	a0,s4
    800036da:	df0fd0ef          	jal	ra,80000cca <memmove>
    name[len] = 0;
    800036de:	9cd2                	add	s9,s9,s4
    800036e0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800036e4:	b759                	j	8000366a <namex+0x9c>
  if(nameiparent){
    800036e6:	f40a81e3          	beqz	s5,80003628 <namex+0x5a>
    iput(ip);
    800036ea:	854e                	mv	a0,s3
    800036ec:	b79ff0ef          	jal	ra,80003264 <iput>
    return 0;
    800036f0:	4981                	li	s3,0
    800036f2:	bf1d                	j	80003628 <namex+0x5a>
  if(*path == 0)
    800036f4:	dbed                	beqz	a5,800036e6 <namex+0x118>
  while(*path != '/' && *path != 0)
    800036f6:	0004c783          	lbu	a5,0(s1)
    800036fa:	85a6                	mv	a1,s1
    800036fc:	b7f1                	j	800036c8 <namex+0xfa>

00000000800036fe <dirlink>:
{
    800036fe:	7139                	addi	sp,sp,-64
    80003700:	fc06                	sd	ra,56(sp)
    80003702:	f822                	sd	s0,48(sp)
    80003704:	f426                	sd	s1,40(sp)
    80003706:	f04a                	sd	s2,32(sp)
    80003708:	ec4e                	sd	s3,24(sp)
    8000370a:	e852                	sd	s4,16(sp)
    8000370c:	0080                	addi	s0,sp,64
    8000370e:	892a                	mv	s2,a0
    80003710:	8a2e                	mv	s4,a1
    80003712:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003714:	4601                	li	a2,0
    80003716:	e1dff0ef          	jal	ra,80003532 <dirlookup>
    8000371a:	e52d                	bnez	a0,80003784 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000371c:	04c92483          	lw	s1,76(s2)
    80003720:	c48d                	beqz	s1,8000374a <dirlink+0x4c>
    80003722:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003724:	4741                	li	a4,16
    80003726:	86a6                	mv	a3,s1
    80003728:	fc040613          	addi	a2,s0,-64
    8000372c:	4581                	li	a1,0
    8000372e:	854a                	mv	a0,s2
    80003730:	c07ff0ef          	jal	ra,80003336 <readi>
    80003734:	47c1                	li	a5,16
    80003736:	04f51b63          	bne	a0,a5,8000378c <dirlink+0x8e>
    if(de.inum == 0)
    8000373a:	fc045783          	lhu	a5,-64(s0)
    8000373e:	c791                	beqz	a5,8000374a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003740:	24c1                	addiw	s1,s1,16
    80003742:	04c92783          	lw	a5,76(s2)
    80003746:	fcf4efe3          	bltu	s1,a5,80003724 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000374a:	4639                	li	a2,14
    8000374c:	85d2                	mv	a1,s4
    8000374e:	fc240513          	addi	a0,s0,-62
    80003752:	e24fd0ef          	jal	ra,80000d76 <strncpy>
  de.inum = inum;
    80003756:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000375a:	4741                	li	a4,16
    8000375c:	86a6                	mv	a3,s1
    8000375e:	fc040613          	addi	a2,s0,-64
    80003762:	4581                	li	a1,0
    80003764:	854a                	mv	a0,s2
    80003766:	cb5ff0ef          	jal	ra,8000341a <writei>
    8000376a:	1541                	addi	a0,a0,-16
    8000376c:	00a03533          	snez	a0,a0
    80003770:	40a00533          	neg	a0,a0
}
    80003774:	70e2                	ld	ra,56(sp)
    80003776:	7442                	ld	s0,48(sp)
    80003778:	74a2                	ld	s1,40(sp)
    8000377a:	7902                	ld	s2,32(sp)
    8000377c:	69e2                	ld	s3,24(sp)
    8000377e:	6a42                	ld	s4,16(sp)
    80003780:	6121                	addi	sp,sp,64
    80003782:	8082                	ret
    iput(ip);
    80003784:	ae1ff0ef          	jal	ra,80003264 <iput>
    return -1;
    80003788:	557d                	li	a0,-1
    8000378a:	b7ed                	j	80003774 <dirlink+0x76>
      panic("dirlink read");
    8000378c:	00004517          	auipc	a0,0x4
    80003790:	ecc50513          	addi	a0,a0,-308 # 80007658 <syscalls+0x1c8>
    80003794:	fc3fc0ef          	jal	ra,80000756 <panic>

0000000080003798 <namei>:

struct inode*
namei(char *path)
{
    80003798:	1101                	addi	sp,sp,-32
    8000379a:	ec06                	sd	ra,24(sp)
    8000379c:	e822                	sd	s0,16(sp)
    8000379e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800037a0:	fe040613          	addi	a2,s0,-32
    800037a4:	4581                	li	a1,0
    800037a6:	e29ff0ef          	jal	ra,800035ce <namex>
}
    800037aa:	60e2                	ld	ra,24(sp)
    800037ac:	6442                	ld	s0,16(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret

00000000800037b2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800037b2:	1141                	addi	sp,sp,-16
    800037b4:	e406                	sd	ra,8(sp)
    800037b6:	e022                	sd	s0,0(sp)
    800037b8:	0800                	addi	s0,sp,16
    800037ba:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800037bc:	4585                	li	a1,1
    800037be:	e11ff0ef          	jal	ra,800035ce <namex>
}
    800037c2:	60a2                	ld	ra,8(sp)
    800037c4:	6402                	ld	s0,0(sp)
    800037c6:	0141                	addi	sp,sp,16
    800037c8:	8082                	ret

00000000800037ca <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800037ca:	1101                	addi	sp,sp,-32
    800037cc:	ec06                	sd	ra,24(sp)
    800037ce:	e822                	sd	s0,16(sp)
    800037d0:	e426                	sd	s1,8(sp)
    800037d2:	e04a                	sd	s2,0(sp)
    800037d4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800037d6:	0001c917          	auipc	s2,0x1c
    800037da:	22a90913          	addi	s2,s2,554 # 8001fa00 <log>
    800037de:	01892583          	lw	a1,24(s2)
    800037e2:	02892503          	lw	a0,40(s2)
    800037e6:	9e2ff0ef          	jal	ra,800029c8 <bread>
    800037ea:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800037ec:	02c92683          	lw	a3,44(s2)
    800037f0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800037f2:	02d05763          	blez	a3,80003820 <write_head+0x56>
    800037f6:	0001c797          	auipc	a5,0x1c
    800037fa:	23a78793          	addi	a5,a5,570 # 8001fa30 <log+0x30>
    800037fe:	05c50713          	addi	a4,a0,92
    80003802:	36fd                	addiw	a3,a3,-1
    80003804:	1682                	slli	a3,a3,0x20
    80003806:	9281                	srli	a3,a3,0x20
    80003808:	068a                	slli	a3,a3,0x2
    8000380a:	0001c617          	auipc	a2,0x1c
    8000380e:	22a60613          	addi	a2,a2,554 # 8001fa34 <log+0x34>
    80003812:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003814:	4390                	lw	a2,0(a5)
    80003816:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003818:	0791                	addi	a5,a5,4
    8000381a:	0711                	addi	a4,a4,4
    8000381c:	fed79ce3          	bne	a5,a3,80003814 <write_head+0x4a>
  }
  bwrite(buf);
    80003820:	8526                	mv	a0,s1
    80003822:	a7cff0ef          	jal	ra,80002a9e <bwrite>
  brelse(buf);
    80003826:	8526                	mv	a0,s1
    80003828:	aa8ff0ef          	jal	ra,80002ad0 <brelse>
}
    8000382c:	60e2                	ld	ra,24(sp)
    8000382e:	6442                	ld	s0,16(sp)
    80003830:	64a2                	ld	s1,8(sp)
    80003832:	6902                	ld	s2,0(sp)
    80003834:	6105                	addi	sp,sp,32
    80003836:	8082                	ret

0000000080003838 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003838:	0001c797          	auipc	a5,0x1c
    8000383c:	1f47a783          	lw	a5,500(a5) # 8001fa2c <log+0x2c>
    80003840:	08f05f63          	blez	a5,800038de <install_trans+0xa6>
{
    80003844:	7139                	addi	sp,sp,-64
    80003846:	fc06                	sd	ra,56(sp)
    80003848:	f822                	sd	s0,48(sp)
    8000384a:	f426                	sd	s1,40(sp)
    8000384c:	f04a                	sd	s2,32(sp)
    8000384e:	ec4e                	sd	s3,24(sp)
    80003850:	e852                	sd	s4,16(sp)
    80003852:	e456                	sd	s5,8(sp)
    80003854:	e05a                	sd	s6,0(sp)
    80003856:	0080                	addi	s0,sp,64
    80003858:	8b2a                	mv	s6,a0
    8000385a:	0001ca97          	auipc	s5,0x1c
    8000385e:	1d6a8a93          	addi	s5,s5,470 # 8001fa30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003862:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003864:	0001c997          	auipc	s3,0x1c
    80003868:	19c98993          	addi	s3,s3,412 # 8001fa00 <log>
    8000386c:	a829                	j	80003886 <install_trans+0x4e>
    brelse(lbuf);
    8000386e:	854a                	mv	a0,s2
    80003870:	a60ff0ef          	jal	ra,80002ad0 <brelse>
    brelse(dbuf);
    80003874:	8526                	mv	a0,s1
    80003876:	a5aff0ef          	jal	ra,80002ad0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000387a:	2a05                	addiw	s4,s4,1
    8000387c:	0a91                	addi	s5,s5,4
    8000387e:	02c9a783          	lw	a5,44(s3)
    80003882:	04fa5463          	bge	s4,a5,800038ca <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003886:	0189a583          	lw	a1,24(s3)
    8000388a:	014585bb          	addw	a1,a1,s4
    8000388e:	2585                	addiw	a1,a1,1
    80003890:	0289a503          	lw	a0,40(s3)
    80003894:	934ff0ef          	jal	ra,800029c8 <bread>
    80003898:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000389a:	000aa583          	lw	a1,0(s5)
    8000389e:	0289a503          	lw	a0,40(s3)
    800038a2:	926ff0ef          	jal	ra,800029c8 <bread>
    800038a6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800038a8:	40000613          	li	a2,1024
    800038ac:	05890593          	addi	a1,s2,88
    800038b0:	05850513          	addi	a0,a0,88
    800038b4:	c16fd0ef          	jal	ra,80000cca <memmove>
    bwrite(dbuf);  // write dst to disk
    800038b8:	8526                	mv	a0,s1
    800038ba:	9e4ff0ef          	jal	ra,80002a9e <bwrite>
    if(recovering == 0)
    800038be:	fa0b18e3          	bnez	s6,8000386e <install_trans+0x36>
      bunpin(dbuf);
    800038c2:	8526                	mv	a0,s1
    800038c4:	acaff0ef          	jal	ra,80002b8e <bunpin>
    800038c8:	b75d                	j	8000386e <install_trans+0x36>
}
    800038ca:	70e2                	ld	ra,56(sp)
    800038cc:	7442                	ld	s0,48(sp)
    800038ce:	74a2                	ld	s1,40(sp)
    800038d0:	7902                	ld	s2,32(sp)
    800038d2:	69e2                	ld	s3,24(sp)
    800038d4:	6a42                	ld	s4,16(sp)
    800038d6:	6aa2                	ld	s5,8(sp)
    800038d8:	6b02                	ld	s6,0(sp)
    800038da:	6121                	addi	sp,sp,64
    800038dc:	8082                	ret
    800038de:	8082                	ret

00000000800038e0 <initlog>:
{
    800038e0:	7179                	addi	sp,sp,-48
    800038e2:	f406                	sd	ra,40(sp)
    800038e4:	f022                	sd	s0,32(sp)
    800038e6:	ec26                	sd	s1,24(sp)
    800038e8:	e84a                	sd	s2,16(sp)
    800038ea:	e44e                	sd	s3,8(sp)
    800038ec:	1800                	addi	s0,sp,48
    800038ee:	892a                	mv	s2,a0
    800038f0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800038f2:	0001c497          	auipc	s1,0x1c
    800038f6:	10e48493          	addi	s1,s1,270 # 8001fa00 <log>
    800038fa:	00004597          	auipc	a1,0x4
    800038fe:	d6e58593          	addi	a1,a1,-658 # 80007668 <syscalls+0x1d8>
    80003902:	8526                	mv	a0,s1
    80003904:	a16fd0ef          	jal	ra,80000b1a <initlock>
  log.start = sb->logstart;
    80003908:	0149a583          	lw	a1,20(s3)
    8000390c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000390e:	0109a783          	lw	a5,16(s3)
    80003912:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003914:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003918:	854a                	mv	a0,s2
    8000391a:	8aeff0ef          	jal	ra,800029c8 <bread>
  log.lh.n = lh->n;
    8000391e:	4d34                	lw	a3,88(a0)
    80003920:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003922:	02d05563          	blez	a3,8000394c <initlog+0x6c>
    80003926:	05c50793          	addi	a5,a0,92
    8000392a:	0001c717          	auipc	a4,0x1c
    8000392e:	10670713          	addi	a4,a4,262 # 8001fa30 <log+0x30>
    80003932:	36fd                	addiw	a3,a3,-1
    80003934:	1682                	slli	a3,a3,0x20
    80003936:	9281                	srli	a3,a3,0x20
    80003938:	068a                	slli	a3,a3,0x2
    8000393a:	06050613          	addi	a2,a0,96
    8000393e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003940:	4390                	lw	a2,0(a5)
    80003942:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003944:	0791                	addi	a5,a5,4
    80003946:	0711                	addi	a4,a4,4
    80003948:	fed79ce3          	bne	a5,a3,80003940 <initlog+0x60>
  brelse(buf);
    8000394c:	984ff0ef          	jal	ra,80002ad0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003950:	4505                	li	a0,1
    80003952:	ee7ff0ef          	jal	ra,80003838 <install_trans>
  log.lh.n = 0;
    80003956:	0001c797          	auipc	a5,0x1c
    8000395a:	0c07ab23          	sw	zero,214(a5) # 8001fa2c <log+0x2c>
  write_head(); // clear the log
    8000395e:	e6dff0ef          	jal	ra,800037ca <write_head>
}
    80003962:	70a2                	ld	ra,40(sp)
    80003964:	7402                	ld	s0,32(sp)
    80003966:	64e2                	ld	s1,24(sp)
    80003968:	6942                	ld	s2,16(sp)
    8000396a:	69a2                	ld	s3,8(sp)
    8000396c:	6145                	addi	sp,sp,48
    8000396e:	8082                	ret

0000000080003970 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003970:	1101                	addi	sp,sp,-32
    80003972:	ec06                	sd	ra,24(sp)
    80003974:	e822                	sd	s0,16(sp)
    80003976:	e426                	sd	s1,8(sp)
    80003978:	e04a                	sd	s2,0(sp)
    8000397a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000397c:	0001c517          	auipc	a0,0x1c
    80003980:	08450513          	addi	a0,a0,132 # 8001fa00 <log>
    80003984:	a16fd0ef          	jal	ra,80000b9a <acquire>
  while(1){
    if(log.committing){
    80003988:	0001c497          	auipc	s1,0x1c
    8000398c:	07848493          	addi	s1,s1,120 # 8001fa00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003990:	4979                	li	s2,30
    80003992:	a029                	j	8000399c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003994:	85a6                	mv	a1,s1
    80003996:	8526                	mv	a0,s1
    80003998:	c60fe0ef          	jal	ra,80001df8 <sleep>
    if(log.committing){
    8000399c:	50dc                	lw	a5,36(s1)
    8000399e:	fbfd                	bnez	a5,80003994 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800039a0:	509c                	lw	a5,32(s1)
    800039a2:	0017871b          	addiw	a4,a5,1
    800039a6:	0007069b          	sext.w	a3,a4
    800039aa:	0027179b          	slliw	a5,a4,0x2
    800039ae:	9fb9                	addw	a5,a5,a4
    800039b0:	0017979b          	slliw	a5,a5,0x1
    800039b4:	54d8                	lw	a4,44(s1)
    800039b6:	9fb9                	addw	a5,a5,a4
    800039b8:	00f95763          	bge	s2,a5,800039c6 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800039bc:	85a6                	mv	a1,s1
    800039be:	8526                	mv	a0,s1
    800039c0:	c38fe0ef          	jal	ra,80001df8 <sleep>
    800039c4:	bfe1                	j	8000399c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800039c6:	0001c517          	auipc	a0,0x1c
    800039ca:	03a50513          	addi	a0,a0,58 # 8001fa00 <log>
    800039ce:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800039d0:	a62fd0ef          	jal	ra,80000c32 <release>
      break;
    }
  }
}
    800039d4:	60e2                	ld	ra,24(sp)
    800039d6:	6442                	ld	s0,16(sp)
    800039d8:	64a2                	ld	s1,8(sp)
    800039da:	6902                	ld	s2,0(sp)
    800039dc:	6105                	addi	sp,sp,32
    800039de:	8082                	ret

00000000800039e0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800039e0:	7139                	addi	sp,sp,-64
    800039e2:	fc06                	sd	ra,56(sp)
    800039e4:	f822                	sd	s0,48(sp)
    800039e6:	f426                	sd	s1,40(sp)
    800039e8:	f04a                	sd	s2,32(sp)
    800039ea:	ec4e                	sd	s3,24(sp)
    800039ec:	e852                	sd	s4,16(sp)
    800039ee:	e456                	sd	s5,8(sp)
    800039f0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800039f2:	0001c497          	auipc	s1,0x1c
    800039f6:	00e48493          	addi	s1,s1,14 # 8001fa00 <log>
    800039fa:	8526                	mv	a0,s1
    800039fc:	99efd0ef          	jal	ra,80000b9a <acquire>
  log.outstanding -= 1;
    80003a00:	509c                	lw	a5,32(s1)
    80003a02:	37fd                	addiw	a5,a5,-1
    80003a04:	0007891b          	sext.w	s2,a5
    80003a08:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003a0a:	50dc                	lw	a5,36(s1)
    80003a0c:	ef9d                	bnez	a5,80003a4a <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003a0e:	04091463          	bnez	s2,80003a56 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003a12:	0001c497          	auipc	s1,0x1c
    80003a16:	fee48493          	addi	s1,s1,-18 # 8001fa00 <log>
    80003a1a:	4785                	li	a5,1
    80003a1c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003a1e:	8526                	mv	a0,s1
    80003a20:	a12fd0ef          	jal	ra,80000c32 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003a24:	54dc                	lw	a5,44(s1)
    80003a26:	04f04b63          	bgtz	a5,80003a7c <end_op+0x9c>
    acquire(&log.lock);
    80003a2a:	0001c497          	auipc	s1,0x1c
    80003a2e:	fd648493          	addi	s1,s1,-42 # 8001fa00 <log>
    80003a32:	8526                	mv	a0,s1
    80003a34:	966fd0ef          	jal	ra,80000b9a <acquire>
    log.committing = 0;
    80003a38:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	c06fe0ef          	jal	ra,80001e44 <wakeup>
    release(&log.lock);
    80003a42:	8526                	mv	a0,s1
    80003a44:	9eefd0ef          	jal	ra,80000c32 <release>
}
    80003a48:	a00d                	j	80003a6a <end_op+0x8a>
    panic("log.committing");
    80003a4a:	00004517          	auipc	a0,0x4
    80003a4e:	c2650513          	addi	a0,a0,-986 # 80007670 <syscalls+0x1e0>
    80003a52:	d05fc0ef          	jal	ra,80000756 <panic>
    wakeup(&log);
    80003a56:	0001c497          	auipc	s1,0x1c
    80003a5a:	faa48493          	addi	s1,s1,-86 # 8001fa00 <log>
    80003a5e:	8526                	mv	a0,s1
    80003a60:	be4fe0ef          	jal	ra,80001e44 <wakeup>
  release(&log.lock);
    80003a64:	8526                	mv	a0,s1
    80003a66:	9ccfd0ef          	jal	ra,80000c32 <release>
}
    80003a6a:	70e2                	ld	ra,56(sp)
    80003a6c:	7442                	ld	s0,48(sp)
    80003a6e:	74a2                	ld	s1,40(sp)
    80003a70:	7902                	ld	s2,32(sp)
    80003a72:	69e2                	ld	s3,24(sp)
    80003a74:	6a42                	ld	s4,16(sp)
    80003a76:	6aa2                	ld	s5,8(sp)
    80003a78:	6121                	addi	sp,sp,64
    80003a7a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a7c:	0001ca97          	auipc	s5,0x1c
    80003a80:	fb4a8a93          	addi	s5,s5,-76 # 8001fa30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003a84:	0001ca17          	auipc	s4,0x1c
    80003a88:	f7ca0a13          	addi	s4,s4,-132 # 8001fa00 <log>
    80003a8c:	018a2583          	lw	a1,24(s4)
    80003a90:	012585bb          	addw	a1,a1,s2
    80003a94:	2585                	addiw	a1,a1,1
    80003a96:	028a2503          	lw	a0,40(s4)
    80003a9a:	f2ffe0ef          	jal	ra,800029c8 <bread>
    80003a9e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003aa0:	000aa583          	lw	a1,0(s5)
    80003aa4:	028a2503          	lw	a0,40(s4)
    80003aa8:	f21fe0ef          	jal	ra,800029c8 <bread>
    80003aac:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003aae:	40000613          	li	a2,1024
    80003ab2:	05850593          	addi	a1,a0,88
    80003ab6:	05848513          	addi	a0,s1,88
    80003aba:	a10fd0ef          	jal	ra,80000cca <memmove>
    bwrite(to);  // write the log
    80003abe:	8526                	mv	a0,s1
    80003ac0:	fdffe0ef          	jal	ra,80002a9e <bwrite>
    brelse(from);
    80003ac4:	854e                	mv	a0,s3
    80003ac6:	80aff0ef          	jal	ra,80002ad0 <brelse>
    brelse(to);
    80003aca:	8526                	mv	a0,s1
    80003acc:	804ff0ef          	jal	ra,80002ad0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ad0:	2905                	addiw	s2,s2,1
    80003ad2:	0a91                	addi	s5,s5,4
    80003ad4:	02ca2783          	lw	a5,44(s4)
    80003ad8:	faf94ae3          	blt	s2,a5,80003a8c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003adc:	cefff0ef          	jal	ra,800037ca <write_head>
    install_trans(0); // Now install writes to home locations
    80003ae0:	4501                	li	a0,0
    80003ae2:	d57ff0ef          	jal	ra,80003838 <install_trans>
    log.lh.n = 0;
    80003ae6:	0001c797          	auipc	a5,0x1c
    80003aea:	f407a323          	sw	zero,-186(a5) # 8001fa2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003aee:	cddff0ef          	jal	ra,800037ca <write_head>
    80003af2:	bf25                	j	80003a2a <end_op+0x4a>

0000000080003af4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003af4:	1101                	addi	sp,sp,-32
    80003af6:	ec06                	sd	ra,24(sp)
    80003af8:	e822                	sd	s0,16(sp)
    80003afa:	e426                	sd	s1,8(sp)
    80003afc:	e04a                	sd	s2,0(sp)
    80003afe:	1000                	addi	s0,sp,32
    80003b00:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003b02:	0001c917          	auipc	s2,0x1c
    80003b06:	efe90913          	addi	s2,s2,-258 # 8001fa00 <log>
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	88efd0ef          	jal	ra,80000b9a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003b10:	02c92603          	lw	a2,44(s2)
    80003b14:	47f5                	li	a5,29
    80003b16:	06c7c363          	blt	a5,a2,80003b7c <log_write+0x88>
    80003b1a:	0001c797          	auipc	a5,0x1c
    80003b1e:	f027a783          	lw	a5,-254(a5) # 8001fa1c <log+0x1c>
    80003b22:	37fd                	addiw	a5,a5,-1
    80003b24:	04f65c63          	bge	a2,a5,80003b7c <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003b28:	0001c797          	auipc	a5,0x1c
    80003b2c:	ef87a783          	lw	a5,-264(a5) # 8001fa20 <log+0x20>
    80003b30:	04f05c63          	blez	a5,80003b88 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003b34:	4781                	li	a5,0
    80003b36:	04c05f63          	blez	a2,80003b94 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003b3a:	44cc                	lw	a1,12(s1)
    80003b3c:	0001c717          	auipc	a4,0x1c
    80003b40:	ef470713          	addi	a4,a4,-268 # 8001fa30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003b44:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003b46:	4314                	lw	a3,0(a4)
    80003b48:	04b68663          	beq	a3,a1,80003b94 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003b4c:	2785                	addiw	a5,a5,1
    80003b4e:	0711                	addi	a4,a4,4
    80003b50:	fef61be3          	bne	a2,a5,80003b46 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003b54:	0621                	addi	a2,a2,8
    80003b56:	060a                	slli	a2,a2,0x2
    80003b58:	0001c797          	auipc	a5,0x1c
    80003b5c:	ea878793          	addi	a5,a5,-344 # 8001fa00 <log>
    80003b60:	963e                	add	a2,a2,a5
    80003b62:	44dc                	lw	a5,12(s1)
    80003b64:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003b66:	8526                	mv	a0,s1
    80003b68:	ff3fe0ef          	jal	ra,80002b5a <bpin>
    log.lh.n++;
    80003b6c:	0001c717          	auipc	a4,0x1c
    80003b70:	e9470713          	addi	a4,a4,-364 # 8001fa00 <log>
    80003b74:	575c                	lw	a5,44(a4)
    80003b76:	2785                	addiw	a5,a5,1
    80003b78:	d75c                	sw	a5,44(a4)
    80003b7a:	a815                	j	80003bae <log_write+0xba>
    panic("too big a transaction");
    80003b7c:	00004517          	auipc	a0,0x4
    80003b80:	b0450513          	addi	a0,a0,-1276 # 80007680 <syscalls+0x1f0>
    80003b84:	bd3fc0ef          	jal	ra,80000756 <panic>
    panic("log_write outside of trans");
    80003b88:	00004517          	auipc	a0,0x4
    80003b8c:	b1050513          	addi	a0,a0,-1264 # 80007698 <syscalls+0x208>
    80003b90:	bc7fc0ef          	jal	ra,80000756 <panic>
  log.lh.block[i] = b->blockno;
    80003b94:	00878713          	addi	a4,a5,8
    80003b98:	00271693          	slli	a3,a4,0x2
    80003b9c:	0001c717          	auipc	a4,0x1c
    80003ba0:	e6470713          	addi	a4,a4,-412 # 8001fa00 <log>
    80003ba4:	9736                	add	a4,a4,a3
    80003ba6:	44d4                	lw	a3,12(s1)
    80003ba8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003baa:	faf60ee3          	beq	a2,a5,80003b66 <log_write+0x72>
  }
  release(&log.lock);
    80003bae:	0001c517          	auipc	a0,0x1c
    80003bb2:	e5250513          	addi	a0,a0,-430 # 8001fa00 <log>
    80003bb6:	87cfd0ef          	jal	ra,80000c32 <release>
}
    80003bba:	60e2                	ld	ra,24(sp)
    80003bbc:	6442                	ld	s0,16(sp)
    80003bbe:	64a2                	ld	s1,8(sp)
    80003bc0:	6902                	ld	s2,0(sp)
    80003bc2:	6105                	addi	sp,sp,32
    80003bc4:	8082                	ret

0000000080003bc6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003bc6:	1101                	addi	sp,sp,-32
    80003bc8:	ec06                	sd	ra,24(sp)
    80003bca:	e822                	sd	s0,16(sp)
    80003bcc:	e426                	sd	s1,8(sp)
    80003bce:	e04a                	sd	s2,0(sp)
    80003bd0:	1000                	addi	s0,sp,32
    80003bd2:	84aa                	mv	s1,a0
    80003bd4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003bd6:	00004597          	auipc	a1,0x4
    80003bda:	ae258593          	addi	a1,a1,-1310 # 800076b8 <syscalls+0x228>
    80003bde:	0521                	addi	a0,a0,8
    80003be0:	f3bfc0ef          	jal	ra,80000b1a <initlock>
  lk->name = name;
    80003be4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003be8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003bec:	0204a423          	sw	zero,40(s1)
}
    80003bf0:	60e2                	ld	ra,24(sp)
    80003bf2:	6442                	ld	s0,16(sp)
    80003bf4:	64a2                	ld	s1,8(sp)
    80003bf6:	6902                	ld	s2,0(sp)
    80003bf8:	6105                	addi	sp,sp,32
    80003bfa:	8082                	ret

0000000080003bfc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003bfc:	1101                	addi	sp,sp,-32
    80003bfe:	ec06                	sd	ra,24(sp)
    80003c00:	e822                	sd	s0,16(sp)
    80003c02:	e426                	sd	s1,8(sp)
    80003c04:	e04a                	sd	s2,0(sp)
    80003c06:	1000                	addi	s0,sp,32
    80003c08:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003c0a:	00850913          	addi	s2,a0,8
    80003c0e:	854a                	mv	a0,s2
    80003c10:	f8bfc0ef          	jal	ra,80000b9a <acquire>
  while (lk->locked) {
    80003c14:	409c                	lw	a5,0(s1)
    80003c16:	c799                	beqz	a5,80003c24 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003c18:	85ca                	mv	a1,s2
    80003c1a:	8526                	mv	a0,s1
    80003c1c:	9dcfe0ef          	jal	ra,80001df8 <sleep>
  while (lk->locked) {
    80003c20:	409c                	lw	a5,0(s1)
    80003c22:	fbfd                	bnez	a5,80003c18 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003c24:	4785                	li	a5,1
    80003c26:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003c28:	c05fd0ef          	jal	ra,8000182c <myproc>
    80003c2c:	591c                	lw	a5,48(a0)
    80003c2e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003c30:	854a                	mv	a0,s2
    80003c32:	800fd0ef          	jal	ra,80000c32 <release>
}
    80003c36:	60e2                	ld	ra,24(sp)
    80003c38:	6442                	ld	s0,16(sp)
    80003c3a:	64a2                	ld	s1,8(sp)
    80003c3c:	6902                	ld	s2,0(sp)
    80003c3e:	6105                	addi	sp,sp,32
    80003c40:	8082                	ret

0000000080003c42 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003c42:	1101                	addi	sp,sp,-32
    80003c44:	ec06                	sd	ra,24(sp)
    80003c46:	e822                	sd	s0,16(sp)
    80003c48:	e426                	sd	s1,8(sp)
    80003c4a:	e04a                	sd	s2,0(sp)
    80003c4c:	1000                	addi	s0,sp,32
    80003c4e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003c50:	00850913          	addi	s2,a0,8
    80003c54:	854a                	mv	a0,s2
    80003c56:	f45fc0ef          	jal	ra,80000b9a <acquire>
  lk->locked = 0;
    80003c5a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003c5e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003c62:	8526                	mv	a0,s1
    80003c64:	9e0fe0ef          	jal	ra,80001e44 <wakeup>
  release(&lk->lk);
    80003c68:	854a                	mv	a0,s2
    80003c6a:	fc9fc0ef          	jal	ra,80000c32 <release>
}
    80003c6e:	60e2                	ld	ra,24(sp)
    80003c70:	6442                	ld	s0,16(sp)
    80003c72:	64a2                	ld	s1,8(sp)
    80003c74:	6902                	ld	s2,0(sp)
    80003c76:	6105                	addi	sp,sp,32
    80003c78:	8082                	ret

0000000080003c7a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003c7a:	7179                	addi	sp,sp,-48
    80003c7c:	f406                	sd	ra,40(sp)
    80003c7e:	f022                	sd	s0,32(sp)
    80003c80:	ec26                	sd	s1,24(sp)
    80003c82:	e84a                	sd	s2,16(sp)
    80003c84:	e44e                	sd	s3,8(sp)
    80003c86:	1800                	addi	s0,sp,48
    80003c88:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003c8a:	00850913          	addi	s2,a0,8
    80003c8e:	854a                	mv	a0,s2
    80003c90:	f0bfc0ef          	jal	ra,80000b9a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003c94:	409c                	lw	a5,0(s1)
    80003c96:	ef89                	bnez	a5,80003cb0 <holdingsleep+0x36>
    80003c98:	4481                	li	s1,0
  release(&lk->lk);
    80003c9a:	854a                	mv	a0,s2
    80003c9c:	f97fc0ef          	jal	ra,80000c32 <release>
  return r;
}
    80003ca0:	8526                	mv	a0,s1
    80003ca2:	70a2                	ld	ra,40(sp)
    80003ca4:	7402                	ld	s0,32(sp)
    80003ca6:	64e2                	ld	s1,24(sp)
    80003ca8:	6942                	ld	s2,16(sp)
    80003caa:	69a2                	ld	s3,8(sp)
    80003cac:	6145                	addi	sp,sp,48
    80003cae:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003cb0:	0284a983          	lw	s3,40(s1)
    80003cb4:	b79fd0ef          	jal	ra,8000182c <myproc>
    80003cb8:	5904                	lw	s1,48(a0)
    80003cba:	413484b3          	sub	s1,s1,s3
    80003cbe:	0014b493          	seqz	s1,s1
    80003cc2:	bfe1                	j	80003c9a <holdingsleep+0x20>

0000000080003cc4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003cc4:	1141                	addi	sp,sp,-16
    80003cc6:	e406                	sd	ra,8(sp)
    80003cc8:	e022                	sd	s0,0(sp)
    80003cca:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ccc:	00004597          	auipc	a1,0x4
    80003cd0:	9fc58593          	addi	a1,a1,-1540 # 800076c8 <syscalls+0x238>
    80003cd4:	0001c517          	auipc	a0,0x1c
    80003cd8:	e7450513          	addi	a0,a0,-396 # 8001fb48 <ftable>
    80003cdc:	e3ffc0ef          	jal	ra,80000b1a <initlock>
}
    80003ce0:	60a2                	ld	ra,8(sp)
    80003ce2:	6402                	ld	s0,0(sp)
    80003ce4:	0141                	addi	sp,sp,16
    80003ce6:	8082                	ret

0000000080003ce8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003ce8:	1101                	addi	sp,sp,-32
    80003cea:	ec06                	sd	ra,24(sp)
    80003cec:	e822                	sd	s0,16(sp)
    80003cee:	e426                	sd	s1,8(sp)
    80003cf0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003cf2:	0001c517          	auipc	a0,0x1c
    80003cf6:	e5650513          	addi	a0,a0,-426 # 8001fb48 <ftable>
    80003cfa:	ea1fc0ef          	jal	ra,80000b9a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003cfe:	0001c497          	auipc	s1,0x1c
    80003d02:	e6248493          	addi	s1,s1,-414 # 8001fb60 <ftable+0x18>
    80003d06:	0001d717          	auipc	a4,0x1d
    80003d0a:	dfa70713          	addi	a4,a4,-518 # 80020b00 <disk>
    if(f->ref == 0){
    80003d0e:	40dc                	lw	a5,4(s1)
    80003d10:	cf89                	beqz	a5,80003d2a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003d12:	02848493          	addi	s1,s1,40
    80003d16:	fee49ce3          	bne	s1,a4,80003d0e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003d1a:	0001c517          	auipc	a0,0x1c
    80003d1e:	e2e50513          	addi	a0,a0,-466 # 8001fb48 <ftable>
    80003d22:	f11fc0ef          	jal	ra,80000c32 <release>
  return 0;
    80003d26:	4481                	li	s1,0
    80003d28:	a809                	j	80003d3a <filealloc+0x52>
      f->ref = 1;
    80003d2a:	4785                	li	a5,1
    80003d2c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003d2e:	0001c517          	auipc	a0,0x1c
    80003d32:	e1a50513          	addi	a0,a0,-486 # 8001fb48 <ftable>
    80003d36:	efdfc0ef          	jal	ra,80000c32 <release>
}
    80003d3a:	8526                	mv	a0,s1
    80003d3c:	60e2                	ld	ra,24(sp)
    80003d3e:	6442                	ld	s0,16(sp)
    80003d40:	64a2                	ld	s1,8(sp)
    80003d42:	6105                	addi	sp,sp,32
    80003d44:	8082                	ret

0000000080003d46 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003d46:	1101                	addi	sp,sp,-32
    80003d48:	ec06                	sd	ra,24(sp)
    80003d4a:	e822                	sd	s0,16(sp)
    80003d4c:	e426                	sd	s1,8(sp)
    80003d4e:	1000                	addi	s0,sp,32
    80003d50:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003d52:	0001c517          	auipc	a0,0x1c
    80003d56:	df650513          	addi	a0,a0,-522 # 8001fb48 <ftable>
    80003d5a:	e41fc0ef          	jal	ra,80000b9a <acquire>
  if(f->ref < 1)
    80003d5e:	40dc                	lw	a5,4(s1)
    80003d60:	02f05063          	blez	a5,80003d80 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003d64:	2785                	addiw	a5,a5,1
    80003d66:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003d68:	0001c517          	auipc	a0,0x1c
    80003d6c:	de050513          	addi	a0,a0,-544 # 8001fb48 <ftable>
    80003d70:	ec3fc0ef          	jal	ra,80000c32 <release>
  return f;
}
    80003d74:	8526                	mv	a0,s1
    80003d76:	60e2                	ld	ra,24(sp)
    80003d78:	6442                	ld	s0,16(sp)
    80003d7a:	64a2                	ld	s1,8(sp)
    80003d7c:	6105                	addi	sp,sp,32
    80003d7e:	8082                	ret
    panic("filedup");
    80003d80:	00004517          	auipc	a0,0x4
    80003d84:	95050513          	addi	a0,a0,-1712 # 800076d0 <syscalls+0x240>
    80003d88:	9cffc0ef          	jal	ra,80000756 <panic>

0000000080003d8c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003d8c:	7139                	addi	sp,sp,-64
    80003d8e:	fc06                	sd	ra,56(sp)
    80003d90:	f822                	sd	s0,48(sp)
    80003d92:	f426                	sd	s1,40(sp)
    80003d94:	f04a                	sd	s2,32(sp)
    80003d96:	ec4e                	sd	s3,24(sp)
    80003d98:	e852                	sd	s4,16(sp)
    80003d9a:	e456                	sd	s5,8(sp)
    80003d9c:	0080                	addi	s0,sp,64
    80003d9e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003da0:	0001c517          	auipc	a0,0x1c
    80003da4:	da850513          	addi	a0,a0,-600 # 8001fb48 <ftable>
    80003da8:	df3fc0ef          	jal	ra,80000b9a <acquire>
  if(f->ref < 1)
    80003dac:	40dc                	lw	a5,4(s1)
    80003dae:	04f05963          	blez	a5,80003e00 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003db2:	37fd                	addiw	a5,a5,-1
    80003db4:	0007871b          	sext.w	a4,a5
    80003db8:	c0dc                	sw	a5,4(s1)
    80003dba:	04e04963          	bgtz	a4,80003e0c <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003dbe:	0004a903          	lw	s2,0(s1)
    80003dc2:	0094ca83          	lbu	s5,9(s1)
    80003dc6:	0104ba03          	ld	s4,16(s1)
    80003dca:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003dce:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003dd2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003dd6:	0001c517          	auipc	a0,0x1c
    80003dda:	d7250513          	addi	a0,a0,-654 # 8001fb48 <ftable>
    80003dde:	e55fc0ef          	jal	ra,80000c32 <release>

  if(ff.type == FD_PIPE){
    80003de2:	4785                	li	a5,1
    80003de4:	04f90363          	beq	s2,a5,80003e2a <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003de8:	3979                	addiw	s2,s2,-2
    80003dea:	4785                	li	a5,1
    80003dec:	0327e663          	bltu	a5,s2,80003e18 <fileclose+0x8c>
    begin_op();
    80003df0:	b81ff0ef          	jal	ra,80003970 <begin_op>
    iput(ff.ip);
    80003df4:	854e                	mv	a0,s3
    80003df6:	c6eff0ef          	jal	ra,80003264 <iput>
    end_op();
    80003dfa:	be7ff0ef          	jal	ra,800039e0 <end_op>
    80003dfe:	a829                	j	80003e18 <fileclose+0x8c>
    panic("fileclose");
    80003e00:	00004517          	auipc	a0,0x4
    80003e04:	8d850513          	addi	a0,a0,-1832 # 800076d8 <syscalls+0x248>
    80003e08:	94ffc0ef          	jal	ra,80000756 <panic>
    release(&ftable.lock);
    80003e0c:	0001c517          	auipc	a0,0x1c
    80003e10:	d3c50513          	addi	a0,a0,-708 # 8001fb48 <ftable>
    80003e14:	e1ffc0ef          	jal	ra,80000c32 <release>
  }
}
    80003e18:	70e2                	ld	ra,56(sp)
    80003e1a:	7442                	ld	s0,48(sp)
    80003e1c:	74a2                	ld	s1,40(sp)
    80003e1e:	7902                	ld	s2,32(sp)
    80003e20:	69e2                	ld	s3,24(sp)
    80003e22:	6a42                	ld	s4,16(sp)
    80003e24:	6aa2                	ld	s5,8(sp)
    80003e26:	6121                	addi	sp,sp,64
    80003e28:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003e2a:	85d6                	mv	a1,s5
    80003e2c:	8552                	mv	a0,s4
    80003e2e:	2ec000ef          	jal	ra,8000411a <pipeclose>
    80003e32:	b7dd                	j	80003e18 <fileclose+0x8c>

0000000080003e34 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003e34:	715d                	addi	sp,sp,-80
    80003e36:	e486                	sd	ra,72(sp)
    80003e38:	e0a2                	sd	s0,64(sp)
    80003e3a:	fc26                	sd	s1,56(sp)
    80003e3c:	f84a                	sd	s2,48(sp)
    80003e3e:	f44e                	sd	s3,40(sp)
    80003e40:	0880                	addi	s0,sp,80
    80003e42:	84aa                	mv	s1,a0
    80003e44:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003e46:	9e7fd0ef          	jal	ra,8000182c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003e4a:	409c                	lw	a5,0(s1)
    80003e4c:	37f9                	addiw	a5,a5,-2
    80003e4e:	4705                	li	a4,1
    80003e50:	02f76f63          	bltu	a4,a5,80003e8e <filestat+0x5a>
    80003e54:	892a                	mv	s2,a0
    ilock(f->ip);
    80003e56:	6c88                	ld	a0,24(s1)
    80003e58:	a8eff0ef          	jal	ra,800030e6 <ilock>
    stati(f->ip, &st);
    80003e5c:	fb840593          	addi	a1,s0,-72
    80003e60:	6c88                	ld	a0,24(s1)
    80003e62:	caaff0ef          	jal	ra,8000330c <stati>
    iunlock(f->ip);
    80003e66:	6c88                	ld	a0,24(s1)
    80003e68:	b28ff0ef          	jal	ra,80003190 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003e6c:	46e1                	li	a3,24
    80003e6e:	fb840613          	addi	a2,s0,-72
    80003e72:	85ce                	mv	a1,s3
    80003e74:	05093503          	ld	a0,80(s2)
    80003e78:	e68fd0ef          	jal	ra,800014e0 <copyout>
    80003e7c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003e80:	60a6                	ld	ra,72(sp)
    80003e82:	6406                	ld	s0,64(sp)
    80003e84:	74e2                	ld	s1,56(sp)
    80003e86:	7942                	ld	s2,48(sp)
    80003e88:	79a2                	ld	s3,40(sp)
    80003e8a:	6161                	addi	sp,sp,80
    80003e8c:	8082                	ret
  return -1;
    80003e8e:	557d                	li	a0,-1
    80003e90:	bfc5                	j	80003e80 <filestat+0x4c>

0000000080003e92 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003e92:	7179                	addi	sp,sp,-48
    80003e94:	f406                	sd	ra,40(sp)
    80003e96:	f022                	sd	s0,32(sp)
    80003e98:	ec26                	sd	s1,24(sp)
    80003e9a:	e84a                	sd	s2,16(sp)
    80003e9c:	e44e                	sd	s3,8(sp)
    80003e9e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003ea0:	00854783          	lbu	a5,8(a0)
    80003ea4:	cbc1                	beqz	a5,80003f34 <fileread+0xa2>
    80003ea6:	84aa                	mv	s1,a0
    80003ea8:	89ae                	mv	s3,a1
    80003eaa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003eac:	411c                	lw	a5,0(a0)
    80003eae:	4705                	li	a4,1
    80003eb0:	04e78363          	beq	a5,a4,80003ef6 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003eb4:	470d                	li	a4,3
    80003eb6:	04e78563          	beq	a5,a4,80003f00 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003eba:	4709                	li	a4,2
    80003ebc:	06e79663          	bne	a5,a4,80003f28 <fileread+0x96>
    ilock(f->ip);
    80003ec0:	6d08                	ld	a0,24(a0)
    80003ec2:	a24ff0ef          	jal	ra,800030e6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003ec6:	874a                	mv	a4,s2
    80003ec8:	5094                	lw	a3,32(s1)
    80003eca:	864e                	mv	a2,s3
    80003ecc:	4585                	li	a1,1
    80003ece:	6c88                	ld	a0,24(s1)
    80003ed0:	c66ff0ef          	jal	ra,80003336 <readi>
    80003ed4:	892a                	mv	s2,a0
    80003ed6:	00a05563          	blez	a0,80003ee0 <fileread+0x4e>
      f->off += r;
    80003eda:	509c                	lw	a5,32(s1)
    80003edc:	9fa9                	addw	a5,a5,a0
    80003ede:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003ee0:	6c88                	ld	a0,24(s1)
    80003ee2:	aaeff0ef          	jal	ra,80003190 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	70a2                	ld	ra,40(sp)
    80003eea:	7402                	ld	s0,32(sp)
    80003eec:	64e2                	ld	s1,24(sp)
    80003eee:	6942                	ld	s2,16(sp)
    80003ef0:	69a2                	ld	s3,8(sp)
    80003ef2:	6145                	addi	sp,sp,48
    80003ef4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003ef6:	6908                	ld	a0,16(a0)
    80003ef8:	34e000ef          	jal	ra,80004246 <piperead>
    80003efc:	892a                	mv	s2,a0
    80003efe:	b7e5                	j	80003ee6 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003f00:	02451783          	lh	a5,36(a0)
    80003f04:	03079693          	slli	a3,a5,0x30
    80003f08:	92c1                	srli	a3,a3,0x30
    80003f0a:	4725                	li	a4,9
    80003f0c:	02d76663          	bltu	a4,a3,80003f38 <fileread+0xa6>
    80003f10:	0792                	slli	a5,a5,0x4
    80003f12:	0001c717          	auipc	a4,0x1c
    80003f16:	b9670713          	addi	a4,a4,-1130 # 8001faa8 <devsw>
    80003f1a:	97ba                	add	a5,a5,a4
    80003f1c:	639c                	ld	a5,0(a5)
    80003f1e:	cf99                	beqz	a5,80003f3c <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80003f20:	4505                	li	a0,1
    80003f22:	9782                	jalr	a5
    80003f24:	892a                	mv	s2,a0
    80003f26:	b7c1                	j	80003ee6 <fileread+0x54>
    panic("fileread");
    80003f28:	00003517          	auipc	a0,0x3
    80003f2c:	7c050513          	addi	a0,a0,1984 # 800076e8 <syscalls+0x258>
    80003f30:	827fc0ef          	jal	ra,80000756 <panic>
    return -1;
    80003f34:	597d                	li	s2,-1
    80003f36:	bf45                	j	80003ee6 <fileread+0x54>
      return -1;
    80003f38:	597d                	li	s2,-1
    80003f3a:	b775                	j	80003ee6 <fileread+0x54>
    80003f3c:	597d                	li	s2,-1
    80003f3e:	b765                	j	80003ee6 <fileread+0x54>

0000000080003f40 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003f40:	715d                	addi	sp,sp,-80
    80003f42:	e486                	sd	ra,72(sp)
    80003f44:	e0a2                	sd	s0,64(sp)
    80003f46:	fc26                	sd	s1,56(sp)
    80003f48:	f84a                	sd	s2,48(sp)
    80003f4a:	f44e                	sd	s3,40(sp)
    80003f4c:	f052                	sd	s4,32(sp)
    80003f4e:	ec56                	sd	s5,24(sp)
    80003f50:	e85a                	sd	s6,16(sp)
    80003f52:	e45e                	sd	s7,8(sp)
    80003f54:	e062                	sd	s8,0(sp)
    80003f56:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003f58:	00954783          	lbu	a5,9(a0)
    80003f5c:	0e078863          	beqz	a5,8000404c <filewrite+0x10c>
    80003f60:	892a                	mv	s2,a0
    80003f62:	8aae                	mv	s5,a1
    80003f64:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003f66:	411c                	lw	a5,0(a0)
    80003f68:	4705                	li	a4,1
    80003f6a:	02e78263          	beq	a5,a4,80003f8e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003f6e:	470d                	li	a4,3
    80003f70:	02e78463          	beq	a5,a4,80003f98 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003f74:	4709                	li	a4,2
    80003f76:	0ce79563          	bne	a5,a4,80004040 <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003f7a:	0ac05163          	blez	a2,8000401c <filewrite+0xdc>
    int i = 0;
    80003f7e:	4981                	li	s3,0
    80003f80:	6b05                	lui	s6,0x1
    80003f82:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003f86:	6b85                	lui	s7,0x1
    80003f88:	c00b8b9b          	addiw	s7,s7,-1024
    80003f8c:	a041                	j	8000400c <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003f8e:	6908                	ld	a0,16(a0)
    80003f90:	1e2000ef          	jal	ra,80004172 <pipewrite>
    80003f94:	8a2a                	mv	s4,a0
    80003f96:	a071                	j	80004022 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003f98:	02451783          	lh	a5,36(a0)
    80003f9c:	03079693          	slli	a3,a5,0x30
    80003fa0:	92c1                	srli	a3,a3,0x30
    80003fa2:	4725                	li	a4,9
    80003fa4:	0ad76663          	bltu	a4,a3,80004050 <filewrite+0x110>
    80003fa8:	0792                	slli	a5,a5,0x4
    80003faa:	0001c717          	auipc	a4,0x1c
    80003fae:	afe70713          	addi	a4,a4,-1282 # 8001faa8 <devsw>
    80003fb2:	97ba                	add	a5,a5,a4
    80003fb4:	679c                	ld	a5,8(a5)
    80003fb6:	cfd9                	beqz	a5,80004054 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003fb8:	4505                	li	a0,1
    80003fba:	9782                	jalr	a5
    80003fbc:	8a2a                	mv	s4,a0
    80003fbe:	a095                	j	80004022 <filewrite+0xe2>
    80003fc0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003fc4:	9adff0ef          	jal	ra,80003970 <begin_op>
      ilock(f->ip);
    80003fc8:	01893503          	ld	a0,24(s2)
    80003fcc:	91aff0ef          	jal	ra,800030e6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003fd0:	8762                	mv	a4,s8
    80003fd2:	02092683          	lw	a3,32(s2)
    80003fd6:	01598633          	add	a2,s3,s5
    80003fda:	4585                	li	a1,1
    80003fdc:	01893503          	ld	a0,24(s2)
    80003fe0:	c3aff0ef          	jal	ra,8000341a <writei>
    80003fe4:	84aa                	mv	s1,a0
    80003fe6:	00a05763          	blez	a0,80003ff4 <filewrite+0xb4>
        f->off += r;
    80003fea:	02092783          	lw	a5,32(s2)
    80003fee:	9fa9                	addw	a5,a5,a0
    80003ff0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003ff4:	01893503          	ld	a0,24(s2)
    80003ff8:	998ff0ef          	jal	ra,80003190 <iunlock>
      end_op();
    80003ffc:	9e5ff0ef          	jal	ra,800039e0 <end_op>

      if(r != n1){
    80004000:	009c1f63          	bne	s8,s1,8000401e <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004004:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004008:	0149db63          	bge	s3,s4,8000401e <filewrite+0xde>
      int n1 = n - i;
    8000400c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004010:	84be                	mv	s1,a5
    80004012:	2781                	sext.w	a5,a5
    80004014:	fafb56e3          	bge	s6,a5,80003fc0 <filewrite+0x80>
    80004018:	84de                	mv	s1,s7
    8000401a:	b75d                	j	80003fc0 <filewrite+0x80>
    int i = 0;
    8000401c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000401e:	013a1f63          	bne	s4,s3,8000403c <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004022:	8552                	mv	a0,s4
    80004024:	60a6                	ld	ra,72(sp)
    80004026:	6406                	ld	s0,64(sp)
    80004028:	74e2                	ld	s1,56(sp)
    8000402a:	7942                	ld	s2,48(sp)
    8000402c:	79a2                	ld	s3,40(sp)
    8000402e:	7a02                	ld	s4,32(sp)
    80004030:	6ae2                	ld	s5,24(sp)
    80004032:	6b42                	ld	s6,16(sp)
    80004034:	6ba2                	ld	s7,8(sp)
    80004036:	6c02                	ld	s8,0(sp)
    80004038:	6161                	addi	sp,sp,80
    8000403a:	8082                	ret
    ret = (i == n ? n : -1);
    8000403c:	5a7d                	li	s4,-1
    8000403e:	b7d5                	j	80004022 <filewrite+0xe2>
    panic("filewrite");
    80004040:	00003517          	auipc	a0,0x3
    80004044:	6b850513          	addi	a0,a0,1720 # 800076f8 <syscalls+0x268>
    80004048:	f0efc0ef          	jal	ra,80000756 <panic>
    return -1;
    8000404c:	5a7d                	li	s4,-1
    8000404e:	bfd1                	j	80004022 <filewrite+0xe2>
      return -1;
    80004050:	5a7d                	li	s4,-1
    80004052:	bfc1                	j	80004022 <filewrite+0xe2>
    80004054:	5a7d                	li	s4,-1
    80004056:	b7f1                	j	80004022 <filewrite+0xe2>

0000000080004058 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004058:	7179                	addi	sp,sp,-48
    8000405a:	f406                	sd	ra,40(sp)
    8000405c:	f022                	sd	s0,32(sp)
    8000405e:	ec26                	sd	s1,24(sp)
    80004060:	e84a                	sd	s2,16(sp)
    80004062:	e44e                	sd	s3,8(sp)
    80004064:	e052                	sd	s4,0(sp)
    80004066:	1800                	addi	s0,sp,48
    80004068:	84aa                	mv	s1,a0
    8000406a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000406c:	0005b023          	sd	zero,0(a1)
    80004070:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004074:	c75ff0ef          	jal	ra,80003ce8 <filealloc>
    80004078:	e088                	sd	a0,0(s1)
    8000407a:	cd35                	beqz	a0,800040f6 <pipealloc+0x9e>
    8000407c:	c6dff0ef          	jal	ra,80003ce8 <filealloc>
    80004080:	00aa3023          	sd	a0,0(s4)
    80004084:	c52d                	beqz	a0,800040ee <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004086:	a45fc0ef          	jal	ra,80000aca <kalloc>
    8000408a:	892a                	mv	s2,a0
    8000408c:	cd31                	beqz	a0,800040e8 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    8000408e:	4985                	li	s3,1
    80004090:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004094:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004098:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000409c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800040a0:	00003597          	auipc	a1,0x3
    800040a4:	66858593          	addi	a1,a1,1640 # 80007708 <syscalls+0x278>
    800040a8:	a73fc0ef          	jal	ra,80000b1a <initlock>
  (*f0)->type = FD_PIPE;
    800040ac:	609c                	ld	a5,0(s1)
    800040ae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800040b2:	609c                	ld	a5,0(s1)
    800040b4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800040b8:	609c                	ld	a5,0(s1)
    800040ba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800040be:	609c                	ld	a5,0(s1)
    800040c0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800040c4:	000a3783          	ld	a5,0(s4)
    800040c8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800040cc:	000a3783          	ld	a5,0(s4)
    800040d0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800040d4:	000a3783          	ld	a5,0(s4)
    800040d8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800040dc:	000a3783          	ld	a5,0(s4)
    800040e0:	0127b823          	sd	s2,16(a5)
  return 0;
    800040e4:	4501                	li	a0,0
    800040e6:	a005                	j	80004106 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800040e8:	6088                	ld	a0,0(s1)
    800040ea:	e501                	bnez	a0,800040f2 <pipealloc+0x9a>
    800040ec:	a029                	j	800040f6 <pipealloc+0x9e>
    800040ee:	6088                	ld	a0,0(s1)
    800040f0:	c11d                	beqz	a0,80004116 <pipealloc+0xbe>
    fileclose(*f0);
    800040f2:	c9bff0ef          	jal	ra,80003d8c <fileclose>
  if(*f1)
    800040f6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800040fa:	557d                	li	a0,-1
  if(*f1)
    800040fc:	c789                	beqz	a5,80004106 <pipealloc+0xae>
    fileclose(*f1);
    800040fe:	853e                	mv	a0,a5
    80004100:	c8dff0ef          	jal	ra,80003d8c <fileclose>
  return -1;
    80004104:	557d                	li	a0,-1
}
    80004106:	70a2                	ld	ra,40(sp)
    80004108:	7402                	ld	s0,32(sp)
    8000410a:	64e2                	ld	s1,24(sp)
    8000410c:	6942                	ld	s2,16(sp)
    8000410e:	69a2                	ld	s3,8(sp)
    80004110:	6a02                	ld	s4,0(sp)
    80004112:	6145                	addi	sp,sp,48
    80004114:	8082                	ret
  return -1;
    80004116:	557d                	li	a0,-1
    80004118:	b7fd                	j	80004106 <pipealloc+0xae>

000000008000411a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000411a:	1101                	addi	sp,sp,-32
    8000411c:	ec06                	sd	ra,24(sp)
    8000411e:	e822                	sd	s0,16(sp)
    80004120:	e426                	sd	s1,8(sp)
    80004122:	e04a                	sd	s2,0(sp)
    80004124:	1000                	addi	s0,sp,32
    80004126:	84aa                	mv	s1,a0
    80004128:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000412a:	a71fc0ef          	jal	ra,80000b9a <acquire>
  if(writable){
    8000412e:	02090763          	beqz	s2,8000415c <pipeclose+0x42>
    pi->writeopen = 0;
    80004132:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004136:	21848513          	addi	a0,s1,536
    8000413a:	d0bfd0ef          	jal	ra,80001e44 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000413e:	2204b783          	ld	a5,544(s1)
    80004142:	e785                	bnez	a5,8000416a <pipeclose+0x50>
    release(&pi->lock);
    80004144:	8526                	mv	a0,s1
    80004146:	aedfc0ef          	jal	ra,80000c32 <release>
    kfree((char*)pi);
    8000414a:	8526                	mv	a0,s1
    8000414c:	89ffc0ef          	jal	ra,800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004150:	60e2                	ld	ra,24(sp)
    80004152:	6442                	ld	s0,16(sp)
    80004154:	64a2                	ld	s1,8(sp)
    80004156:	6902                	ld	s2,0(sp)
    80004158:	6105                	addi	sp,sp,32
    8000415a:	8082                	ret
    pi->readopen = 0;
    8000415c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004160:	21c48513          	addi	a0,s1,540
    80004164:	ce1fd0ef          	jal	ra,80001e44 <wakeup>
    80004168:	bfd9                	j	8000413e <pipeclose+0x24>
    release(&pi->lock);
    8000416a:	8526                	mv	a0,s1
    8000416c:	ac7fc0ef          	jal	ra,80000c32 <release>
}
    80004170:	b7c5                	j	80004150 <pipeclose+0x36>

0000000080004172 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004172:	711d                	addi	sp,sp,-96
    80004174:	ec86                	sd	ra,88(sp)
    80004176:	e8a2                	sd	s0,80(sp)
    80004178:	e4a6                	sd	s1,72(sp)
    8000417a:	e0ca                	sd	s2,64(sp)
    8000417c:	fc4e                	sd	s3,56(sp)
    8000417e:	f852                	sd	s4,48(sp)
    80004180:	f456                	sd	s5,40(sp)
    80004182:	f05a                	sd	s6,32(sp)
    80004184:	ec5e                	sd	s7,24(sp)
    80004186:	e862                	sd	s8,16(sp)
    80004188:	1080                	addi	s0,sp,96
    8000418a:	84aa                	mv	s1,a0
    8000418c:	8aae                	mv	s5,a1
    8000418e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004190:	e9cfd0ef          	jal	ra,8000182c <myproc>
    80004194:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004196:	8526                	mv	a0,s1
    80004198:	a03fc0ef          	jal	ra,80000b9a <acquire>
  while(i < n){
    8000419c:	09405c63          	blez	s4,80004234 <pipewrite+0xc2>
  int i = 0;
    800041a0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800041a2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800041a4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800041a8:	21c48b93          	addi	s7,s1,540
    800041ac:	a81d                	j	800041e2 <pipewrite+0x70>
      release(&pi->lock);
    800041ae:	8526                	mv	a0,s1
    800041b0:	a83fc0ef          	jal	ra,80000c32 <release>
      return -1;
    800041b4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800041b6:	854a                	mv	a0,s2
    800041b8:	60e6                	ld	ra,88(sp)
    800041ba:	6446                	ld	s0,80(sp)
    800041bc:	64a6                	ld	s1,72(sp)
    800041be:	6906                	ld	s2,64(sp)
    800041c0:	79e2                	ld	s3,56(sp)
    800041c2:	7a42                	ld	s4,48(sp)
    800041c4:	7aa2                	ld	s5,40(sp)
    800041c6:	7b02                	ld	s6,32(sp)
    800041c8:	6be2                	ld	s7,24(sp)
    800041ca:	6c42                	ld	s8,16(sp)
    800041cc:	6125                	addi	sp,sp,96
    800041ce:	8082                	ret
      wakeup(&pi->nread);
    800041d0:	8562                	mv	a0,s8
    800041d2:	c73fd0ef          	jal	ra,80001e44 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800041d6:	85a6                	mv	a1,s1
    800041d8:	855e                	mv	a0,s7
    800041da:	c1ffd0ef          	jal	ra,80001df8 <sleep>
  while(i < n){
    800041de:	05495c63          	bge	s2,s4,80004236 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800041e2:	2204a783          	lw	a5,544(s1)
    800041e6:	d7e1                	beqz	a5,800041ae <pipewrite+0x3c>
    800041e8:	854e                	mv	a0,s3
    800041ea:	e47fd0ef          	jal	ra,80002030 <killed>
    800041ee:	f161                	bnez	a0,800041ae <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800041f0:	2184a783          	lw	a5,536(s1)
    800041f4:	21c4a703          	lw	a4,540(s1)
    800041f8:	2007879b          	addiw	a5,a5,512
    800041fc:	fcf70ae3          	beq	a4,a5,800041d0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004200:	4685                	li	a3,1
    80004202:	01590633          	add	a2,s2,s5
    80004206:	faf40593          	addi	a1,s0,-81
    8000420a:	0509b503          	ld	a0,80(s3)
    8000420e:	b8afd0ef          	jal	ra,80001598 <copyin>
    80004212:	03650263          	beq	a0,s6,80004236 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004216:	21c4a783          	lw	a5,540(s1)
    8000421a:	0017871b          	addiw	a4,a5,1
    8000421e:	20e4ae23          	sw	a4,540(s1)
    80004222:	1ff7f793          	andi	a5,a5,511
    80004226:	97a6                	add	a5,a5,s1
    80004228:	faf44703          	lbu	a4,-81(s0)
    8000422c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004230:	2905                	addiw	s2,s2,1
    80004232:	b775                	j	800041de <pipewrite+0x6c>
  int i = 0;
    80004234:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004236:	21848513          	addi	a0,s1,536
    8000423a:	c0bfd0ef          	jal	ra,80001e44 <wakeup>
  release(&pi->lock);
    8000423e:	8526                	mv	a0,s1
    80004240:	9f3fc0ef          	jal	ra,80000c32 <release>
  return i;
    80004244:	bf8d                	j	800041b6 <pipewrite+0x44>

0000000080004246 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004246:	715d                	addi	sp,sp,-80
    80004248:	e486                	sd	ra,72(sp)
    8000424a:	e0a2                	sd	s0,64(sp)
    8000424c:	fc26                	sd	s1,56(sp)
    8000424e:	f84a                	sd	s2,48(sp)
    80004250:	f44e                	sd	s3,40(sp)
    80004252:	f052                	sd	s4,32(sp)
    80004254:	ec56                	sd	s5,24(sp)
    80004256:	e85a                	sd	s6,16(sp)
    80004258:	0880                	addi	s0,sp,80
    8000425a:	84aa                	mv	s1,a0
    8000425c:	892e                	mv	s2,a1
    8000425e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004260:	dccfd0ef          	jal	ra,8000182c <myproc>
    80004264:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004266:	8526                	mv	a0,s1
    80004268:	933fc0ef          	jal	ra,80000b9a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000426c:	2184a703          	lw	a4,536(s1)
    80004270:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004274:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004278:	02f71363          	bne	a4,a5,8000429e <piperead+0x58>
    8000427c:	2244a783          	lw	a5,548(s1)
    80004280:	cf99                	beqz	a5,8000429e <piperead+0x58>
    if(killed(pr)){
    80004282:	8552                	mv	a0,s4
    80004284:	dadfd0ef          	jal	ra,80002030 <killed>
    80004288:	e141                	bnez	a0,80004308 <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000428a:	85a6                	mv	a1,s1
    8000428c:	854e                	mv	a0,s3
    8000428e:	b6bfd0ef          	jal	ra,80001df8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004292:	2184a703          	lw	a4,536(s1)
    80004296:	21c4a783          	lw	a5,540(s1)
    8000429a:	fef701e3          	beq	a4,a5,8000427c <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000429e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800042a0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800042a2:	05505163          	blez	s5,800042e4 <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    800042a6:	2184a783          	lw	a5,536(s1)
    800042aa:	21c4a703          	lw	a4,540(s1)
    800042ae:	02f70b63          	beq	a4,a5,800042e4 <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800042b2:	0017871b          	addiw	a4,a5,1
    800042b6:	20e4ac23          	sw	a4,536(s1)
    800042ba:	1ff7f793          	andi	a5,a5,511
    800042be:	97a6                	add	a5,a5,s1
    800042c0:	0187c783          	lbu	a5,24(a5)
    800042c4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800042c8:	4685                	li	a3,1
    800042ca:	fbf40613          	addi	a2,s0,-65
    800042ce:	85ca                	mv	a1,s2
    800042d0:	050a3503          	ld	a0,80(s4)
    800042d4:	a0cfd0ef          	jal	ra,800014e0 <copyout>
    800042d8:	01650663          	beq	a0,s6,800042e4 <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800042dc:	2985                	addiw	s3,s3,1
    800042de:	0905                	addi	s2,s2,1
    800042e0:	fd3a93e3          	bne	s5,s3,800042a6 <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800042e4:	21c48513          	addi	a0,s1,540
    800042e8:	b5dfd0ef          	jal	ra,80001e44 <wakeup>
  release(&pi->lock);
    800042ec:	8526                	mv	a0,s1
    800042ee:	945fc0ef          	jal	ra,80000c32 <release>
  return i;
}
    800042f2:	854e                	mv	a0,s3
    800042f4:	60a6                	ld	ra,72(sp)
    800042f6:	6406                	ld	s0,64(sp)
    800042f8:	74e2                	ld	s1,56(sp)
    800042fa:	7942                	ld	s2,48(sp)
    800042fc:	79a2                	ld	s3,40(sp)
    800042fe:	7a02                	ld	s4,32(sp)
    80004300:	6ae2                	ld	s5,24(sp)
    80004302:	6b42                	ld	s6,16(sp)
    80004304:	6161                	addi	sp,sp,80
    80004306:	8082                	ret
      release(&pi->lock);
    80004308:	8526                	mv	a0,s1
    8000430a:	929fc0ef          	jal	ra,80000c32 <release>
      return -1;
    8000430e:	59fd                	li	s3,-1
    80004310:	b7cd                	j	800042f2 <piperead+0xac>

0000000080004312 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004312:	1141                	addi	sp,sp,-16
    80004314:	e422                	sd	s0,8(sp)
    80004316:	0800                	addi	s0,sp,16
    80004318:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000431a:	8905                	andi	a0,a0,1
    8000431c:	c111                	beqz	a0,80004320 <flags2perm+0xe>
      perm = PTE_X;
    8000431e:	4521                	li	a0,8
    if(flags & 0x2)
    80004320:	8b89                	andi	a5,a5,2
    80004322:	c399                	beqz	a5,80004328 <flags2perm+0x16>
      perm |= PTE_W;
    80004324:	00456513          	ori	a0,a0,4
    return perm;
}
    80004328:	6422                	ld	s0,8(sp)
    8000432a:	0141                	addi	sp,sp,16
    8000432c:	8082                	ret

000000008000432e <exec>:

int
exec(char *path, char **argv)
{
    8000432e:	de010113          	addi	sp,sp,-544
    80004332:	20113c23          	sd	ra,536(sp)
    80004336:	20813823          	sd	s0,528(sp)
    8000433a:	20913423          	sd	s1,520(sp)
    8000433e:	21213023          	sd	s2,512(sp)
    80004342:	ffce                	sd	s3,504(sp)
    80004344:	fbd2                	sd	s4,496(sp)
    80004346:	f7d6                	sd	s5,488(sp)
    80004348:	f3da                	sd	s6,480(sp)
    8000434a:	efde                	sd	s7,472(sp)
    8000434c:	ebe2                	sd	s8,464(sp)
    8000434e:	e7e6                	sd	s9,456(sp)
    80004350:	e3ea                	sd	s10,448(sp)
    80004352:	ff6e                	sd	s11,440(sp)
    80004354:	1400                	addi	s0,sp,544
    80004356:	892a                	mv	s2,a0
    80004358:	dea43423          	sd	a0,-536(s0)
    8000435c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004360:	cccfd0ef          	jal	ra,8000182c <myproc>
    80004364:	84aa                	mv	s1,a0

  begin_op();
    80004366:	e0aff0ef          	jal	ra,80003970 <begin_op>

  if((ip = namei(path)) == 0){
    8000436a:	854a                	mv	a0,s2
    8000436c:	c2cff0ef          	jal	ra,80003798 <namei>
    80004370:	c13d                	beqz	a0,800043d6 <exec+0xa8>
    80004372:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004374:	d73fe0ef          	jal	ra,800030e6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004378:	04000713          	li	a4,64
    8000437c:	4681                	li	a3,0
    8000437e:	e5040613          	addi	a2,s0,-432
    80004382:	4581                	li	a1,0
    80004384:	8556                	mv	a0,s5
    80004386:	fb1fe0ef          	jal	ra,80003336 <readi>
    8000438a:	04000793          	li	a5,64
    8000438e:	00f51a63          	bne	a0,a5,800043a2 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004392:	e5042703          	lw	a4,-432(s0)
    80004396:	464c47b7          	lui	a5,0x464c4
    8000439a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000439e:	04f70063          	beq	a4,a5,800043de <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800043a2:	8556                	mv	a0,s5
    800043a4:	f49fe0ef          	jal	ra,800032ec <iunlockput>
    end_op();
    800043a8:	e38ff0ef          	jal	ra,800039e0 <end_op>
  }
  return -1;
    800043ac:	557d                	li	a0,-1
}
    800043ae:	21813083          	ld	ra,536(sp)
    800043b2:	21013403          	ld	s0,528(sp)
    800043b6:	20813483          	ld	s1,520(sp)
    800043ba:	20013903          	ld	s2,512(sp)
    800043be:	79fe                	ld	s3,504(sp)
    800043c0:	7a5e                	ld	s4,496(sp)
    800043c2:	7abe                	ld	s5,488(sp)
    800043c4:	7b1e                	ld	s6,480(sp)
    800043c6:	6bfe                	ld	s7,472(sp)
    800043c8:	6c5e                	ld	s8,464(sp)
    800043ca:	6cbe                	ld	s9,456(sp)
    800043cc:	6d1e                	ld	s10,448(sp)
    800043ce:	7dfa                	ld	s11,440(sp)
    800043d0:	22010113          	addi	sp,sp,544
    800043d4:	8082                	ret
    end_op();
    800043d6:	e0aff0ef          	jal	ra,800039e0 <end_op>
    return -1;
    800043da:	557d                	li	a0,-1
    800043dc:	bfc9                	j	800043ae <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    800043de:	8526                	mv	a0,s1
    800043e0:	cf4fd0ef          	jal	ra,800018d4 <proc_pagetable>
    800043e4:	8b2a                	mv	s6,a0
    800043e6:	dd55                	beqz	a0,800043a2 <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043e8:	e7042783          	lw	a5,-400(s0)
    800043ec:	e8845703          	lhu	a4,-376(s0)
    800043f0:	c325                	beqz	a4,80004450 <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800043f2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043f4:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800043f8:	6a05                	lui	s4,0x1
    800043fa:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800043fe:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004402:	6d85                	lui	s11,0x1
    80004404:	7d7d                	lui	s10,0xfffff
    80004406:	a411                	j	8000460a <exec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004408:	00003517          	auipc	a0,0x3
    8000440c:	30850513          	addi	a0,a0,776 # 80007710 <syscalls+0x280>
    80004410:	b46fc0ef          	jal	ra,80000756 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004414:	874a                	mv	a4,s2
    80004416:	009c86bb          	addw	a3,s9,s1
    8000441a:	4581                	li	a1,0
    8000441c:	8556                	mv	a0,s5
    8000441e:	f19fe0ef          	jal	ra,80003336 <readi>
    80004422:	2501                	sext.w	a0,a0
    80004424:	18a91263          	bne	s2,a0,800045a8 <exec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    80004428:	009d84bb          	addw	s1,s11,s1
    8000442c:	013d09bb          	addw	s3,s10,s3
    80004430:	1b74fd63          	bgeu	s1,s7,800045ea <exec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    80004434:	02049593          	slli	a1,s1,0x20
    80004438:	9181                	srli	a1,a1,0x20
    8000443a:	95e2                	add	a1,a1,s8
    8000443c:	855a                	mv	a0,s6
    8000443e:	b47fc0ef          	jal	ra,80000f84 <walkaddr>
    80004442:	862a                	mv	a2,a0
    if(pa == 0)
    80004444:	d171                	beqz	a0,80004408 <exec+0xda>
      n = PGSIZE;
    80004446:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004448:	fd49f6e3          	bgeu	s3,s4,80004414 <exec+0xe6>
      n = sz - i;
    8000444c:	894e                	mv	s2,s3
    8000444e:	b7d9                	j	80004414 <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004450:	4901                	li	s2,0
  iunlockput(ip);
    80004452:	8556                	mv	a0,s5
    80004454:	e99fe0ef          	jal	ra,800032ec <iunlockput>
  end_op();
    80004458:	d88ff0ef          	jal	ra,800039e0 <end_op>
  p = myproc();
    8000445c:	bd0fd0ef          	jal	ra,8000182c <myproc>
    80004460:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004462:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004466:	6785                	lui	a5,0x1
    80004468:	17fd                	addi	a5,a5,-1
    8000446a:	993e                	add	s2,s2,a5
    8000446c:	77fd                	lui	a5,0xfffff
    8000446e:	00f977b3          	and	a5,s2,a5
    80004472:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004476:	4691                	li	a3,4
    80004478:	6609                	lui	a2,0x2
    8000447a:	963e                	add	a2,a2,a5
    8000447c:	85be                	mv	a1,a5
    8000447e:	855a                	mv	a0,s6
    80004480:	e5dfc0ef          	jal	ra,800012dc <uvmalloc>
    80004484:	8c2a                	mv	s8,a0
  ip = 0;
    80004486:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004488:	12050063          	beqz	a0,800045a8 <exec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000448c:	75f9                	lui	a1,0xffffe
    8000448e:	95aa                	add	a1,a1,a0
    80004490:	855a                	mv	a0,s6
    80004492:	824fd0ef          	jal	ra,800014b6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004496:	7afd                	lui	s5,0xfffff
    80004498:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000449a:	df043783          	ld	a5,-528(s0)
    8000449e:	6388                	ld	a0,0(a5)
    800044a0:	c135                	beqz	a0,80004504 <exec+0x1d6>
    800044a2:	e9040993          	addi	s3,s0,-368
    800044a6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800044aa:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800044ac:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800044ae:	939fc0ef          	jal	ra,80000de6 <strlen>
    800044b2:	0015079b          	addiw	a5,a0,1
    800044b6:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800044ba:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800044be:	11596a63          	bltu	s2,s5,800045d2 <exec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800044c2:	df043d83          	ld	s11,-528(s0)
    800044c6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800044ca:	8552                	mv	a0,s4
    800044cc:	91bfc0ef          	jal	ra,80000de6 <strlen>
    800044d0:	0015069b          	addiw	a3,a0,1
    800044d4:	8652                	mv	a2,s4
    800044d6:	85ca                	mv	a1,s2
    800044d8:	855a                	mv	a0,s6
    800044da:	806fd0ef          	jal	ra,800014e0 <copyout>
    800044de:	0e054e63          	bltz	a0,800045da <exec+0x2ac>
    ustack[argc] = sp;
    800044e2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800044e6:	0485                	addi	s1,s1,1
    800044e8:	008d8793          	addi	a5,s11,8
    800044ec:	def43823          	sd	a5,-528(s0)
    800044f0:	008db503          	ld	a0,8(s11)
    800044f4:	c911                	beqz	a0,80004508 <exec+0x1da>
    if(argc >= MAXARG)
    800044f6:	09a1                	addi	s3,s3,8
    800044f8:	fb3c9be3          	bne	s9,s3,800044ae <exec+0x180>
  sz = sz1;
    800044fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004500:	4a81                	li	s5,0
    80004502:	a05d                	j	800045a8 <exec+0x27a>
  sp = sz;
    80004504:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004506:	4481                	li	s1,0
  ustack[argc] = 0;
    80004508:	00349793          	slli	a5,s1,0x3
    8000450c:	f9040713          	addi	a4,s0,-112
    80004510:	97ba                	add	a5,a5,a4
    80004512:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffde2c0>
  sp -= (argc+1) * sizeof(uint64);
    80004516:	00148693          	addi	a3,s1,1
    8000451a:	068e                	slli	a3,a3,0x3
    8000451c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004520:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004524:	01597663          	bgeu	s2,s5,80004530 <exec+0x202>
  sz = sz1;
    80004528:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000452c:	4a81                	li	s5,0
    8000452e:	a8ad                	j	800045a8 <exec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004530:	e9040613          	addi	a2,s0,-368
    80004534:	85ca                	mv	a1,s2
    80004536:	855a                	mv	a0,s6
    80004538:	fa9fc0ef          	jal	ra,800014e0 <copyout>
    8000453c:	0a054363          	bltz	a0,800045e2 <exec+0x2b4>
  p->trapframe->a1 = sp;
    80004540:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004544:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004548:	de843783          	ld	a5,-536(s0)
    8000454c:	0007c703          	lbu	a4,0(a5)
    80004550:	cf11                	beqz	a4,8000456c <exec+0x23e>
    80004552:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004554:	02f00693          	li	a3,47
    80004558:	a039                	j	80004566 <exec+0x238>
      last = s+1;
    8000455a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000455e:	0785                	addi	a5,a5,1
    80004560:	fff7c703          	lbu	a4,-1(a5)
    80004564:	c701                	beqz	a4,8000456c <exec+0x23e>
    if(*s == '/')
    80004566:	fed71ce3          	bne	a4,a3,8000455e <exec+0x230>
    8000456a:	bfc5                	j	8000455a <exec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000456c:	4641                	li	a2,16
    8000456e:	de843583          	ld	a1,-536(s0)
    80004572:	158b8513          	addi	a0,s7,344
    80004576:	83ffc0ef          	jal	ra,80000db4 <safestrcpy>
  oldpagetable = p->pagetable;
    8000457a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000457e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004582:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004586:	058bb783          	ld	a5,88(s7)
    8000458a:	e6843703          	ld	a4,-408(s0)
    8000458e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004590:	058bb783          	ld	a5,88(s7)
    80004594:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004598:	85ea                	mv	a1,s10
    8000459a:	bbefd0ef          	jal	ra,80001958 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000459e:	0004851b          	sext.w	a0,s1
    800045a2:	b531                	j	800043ae <exec+0x80>
    800045a4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800045a8:	df843583          	ld	a1,-520(s0)
    800045ac:	855a                	mv	a0,s6
    800045ae:	baafd0ef          	jal	ra,80001958 <proc_freepagetable>
  if(ip){
    800045b2:	de0a98e3          	bnez	s5,800043a2 <exec+0x74>
  return -1;
    800045b6:	557d                	li	a0,-1
    800045b8:	bbdd                	j	800043ae <exec+0x80>
    800045ba:	df243c23          	sd	s2,-520(s0)
    800045be:	b7ed                	j	800045a8 <exec+0x27a>
    800045c0:	df243c23          	sd	s2,-520(s0)
    800045c4:	b7d5                	j	800045a8 <exec+0x27a>
    800045c6:	df243c23          	sd	s2,-520(s0)
    800045ca:	bff9                	j	800045a8 <exec+0x27a>
    800045cc:	df243c23          	sd	s2,-520(s0)
    800045d0:	bfe1                	j	800045a8 <exec+0x27a>
  sz = sz1;
    800045d2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045d6:	4a81                	li	s5,0
    800045d8:	bfc1                	j	800045a8 <exec+0x27a>
  sz = sz1;
    800045da:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045de:	4a81                	li	s5,0
    800045e0:	b7e1                	j	800045a8 <exec+0x27a>
  sz = sz1;
    800045e2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045e6:	4a81                	li	s5,0
    800045e8:	b7c1                	j	800045a8 <exec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045ea:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045ee:	e0843783          	ld	a5,-504(s0)
    800045f2:	0017869b          	addiw	a3,a5,1
    800045f6:	e0d43423          	sd	a3,-504(s0)
    800045fa:	e0043783          	ld	a5,-512(s0)
    800045fe:	0387879b          	addiw	a5,a5,56
    80004602:	e8845703          	lhu	a4,-376(s0)
    80004606:	e4e6d6e3          	bge	a3,a4,80004452 <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000460a:	2781                	sext.w	a5,a5
    8000460c:	e0f43023          	sd	a5,-512(s0)
    80004610:	03800713          	li	a4,56
    80004614:	86be                	mv	a3,a5
    80004616:	e1840613          	addi	a2,s0,-488
    8000461a:	4581                	li	a1,0
    8000461c:	8556                	mv	a0,s5
    8000461e:	d19fe0ef          	jal	ra,80003336 <readi>
    80004622:	03800793          	li	a5,56
    80004626:	f6f51fe3          	bne	a0,a5,800045a4 <exec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    8000462a:	e1842783          	lw	a5,-488(s0)
    8000462e:	4705                	li	a4,1
    80004630:	fae79fe3          	bne	a5,a4,800045ee <exec+0x2c0>
    if(ph.memsz < ph.filesz)
    80004634:	e4043483          	ld	s1,-448(s0)
    80004638:	e3843783          	ld	a5,-456(s0)
    8000463c:	f6f4efe3          	bltu	s1,a5,800045ba <exec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004640:	e2843783          	ld	a5,-472(s0)
    80004644:	94be                	add	s1,s1,a5
    80004646:	f6f4ede3          	bltu	s1,a5,800045c0 <exec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    8000464a:	de043703          	ld	a4,-544(s0)
    8000464e:	8ff9                	and	a5,a5,a4
    80004650:	fbbd                	bnez	a5,800045c6 <exec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004652:	e1c42503          	lw	a0,-484(s0)
    80004656:	cbdff0ef          	jal	ra,80004312 <flags2perm>
    8000465a:	86aa                	mv	a3,a0
    8000465c:	8626                	mv	a2,s1
    8000465e:	85ca                	mv	a1,s2
    80004660:	855a                	mv	a0,s6
    80004662:	c7bfc0ef          	jal	ra,800012dc <uvmalloc>
    80004666:	dea43c23          	sd	a0,-520(s0)
    8000466a:	d12d                	beqz	a0,800045cc <exec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000466c:	e2843c03          	ld	s8,-472(s0)
    80004670:	e2042c83          	lw	s9,-480(s0)
    80004674:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004678:	f60b89e3          	beqz	s7,800045ea <exec+0x2bc>
    8000467c:	89de                	mv	s3,s7
    8000467e:	4481                	li	s1,0
    80004680:	bb55                	j	80004434 <exec+0x106>

0000000080004682 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004682:	7179                	addi	sp,sp,-48
    80004684:	f406                	sd	ra,40(sp)
    80004686:	f022                	sd	s0,32(sp)
    80004688:	ec26                	sd	s1,24(sp)
    8000468a:	e84a                	sd	s2,16(sp)
    8000468c:	1800                	addi	s0,sp,48
    8000468e:	892e                	mv	s2,a1
    80004690:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004692:	fdc40593          	addi	a1,s0,-36
    80004696:	842fe0ef          	jal	ra,800026d8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000469a:	fdc42703          	lw	a4,-36(s0)
    8000469e:	47bd                	li	a5,15
    800046a0:	02e7e963          	bltu	a5,a4,800046d2 <argfd+0x50>
    800046a4:	988fd0ef          	jal	ra,8000182c <myproc>
    800046a8:	fdc42703          	lw	a4,-36(s0)
    800046ac:	01a70793          	addi	a5,a4,26
    800046b0:	078e                	slli	a5,a5,0x3
    800046b2:	953e                	add	a0,a0,a5
    800046b4:	611c                	ld	a5,0(a0)
    800046b6:	c385                	beqz	a5,800046d6 <argfd+0x54>
    return -1;
  if(pfd)
    800046b8:	00090463          	beqz	s2,800046c0 <argfd+0x3e>
    *pfd = fd;
    800046bc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800046c0:	4501                	li	a0,0
  if(pf)
    800046c2:	c091                	beqz	s1,800046c6 <argfd+0x44>
    *pf = f;
    800046c4:	e09c                	sd	a5,0(s1)
}
    800046c6:	70a2                	ld	ra,40(sp)
    800046c8:	7402                	ld	s0,32(sp)
    800046ca:	64e2                	ld	s1,24(sp)
    800046cc:	6942                	ld	s2,16(sp)
    800046ce:	6145                	addi	sp,sp,48
    800046d0:	8082                	ret
    return -1;
    800046d2:	557d                	li	a0,-1
    800046d4:	bfcd                	j	800046c6 <argfd+0x44>
    800046d6:	557d                	li	a0,-1
    800046d8:	b7fd                	j	800046c6 <argfd+0x44>

00000000800046da <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800046da:	1101                	addi	sp,sp,-32
    800046dc:	ec06                	sd	ra,24(sp)
    800046de:	e822                	sd	s0,16(sp)
    800046e0:	e426                	sd	s1,8(sp)
    800046e2:	1000                	addi	s0,sp,32
    800046e4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800046e6:	946fd0ef          	jal	ra,8000182c <myproc>
    800046ea:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800046ec:	0d050793          	addi	a5,a0,208
    800046f0:	4501                	li	a0,0
    800046f2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800046f4:	6398                	ld	a4,0(a5)
    800046f6:	cb19                	beqz	a4,8000470c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800046f8:	2505                	addiw	a0,a0,1
    800046fa:	07a1                	addi	a5,a5,8
    800046fc:	fed51ce3          	bne	a0,a3,800046f4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004700:	557d                	li	a0,-1
}
    80004702:	60e2                	ld	ra,24(sp)
    80004704:	6442                	ld	s0,16(sp)
    80004706:	64a2                	ld	s1,8(sp)
    80004708:	6105                	addi	sp,sp,32
    8000470a:	8082                	ret
      p->ofile[fd] = f;
    8000470c:	01a50793          	addi	a5,a0,26
    80004710:	078e                	slli	a5,a5,0x3
    80004712:	963e                	add	a2,a2,a5
    80004714:	e204                	sd	s1,0(a2)
      return fd;
    80004716:	b7f5                	j	80004702 <fdalloc+0x28>

0000000080004718 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004718:	715d                	addi	sp,sp,-80
    8000471a:	e486                	sd	ra,72(sp)
    8000471c:	e0a2                	sd	s0,64(sp)
    8000471e:	fc26                	sd	s1,56(sp)
    80004720:	f84a                	sd	s2,48(sp)
    80004722:	f44e                	sd	s3,40(sp)
    80004724:	f052                	sd	s4,32(sp)
    80004726:	ec56                	sd	s5,24(sp)
    80004728:	e85a                	sd	s6,16(sp)
    8000472a:	0880                	addi	s0,sp,80
    8000472c:	8b2e                	mv	s6,a1
    8000472e:	89b2                	mv	s3,a2
    80004730:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004732:	fb040593          	addi	a1,s0,-80
    80004736:	87cff0ef          	jal	ra,800037b2 <nameiparent>
    8000473a:	84aa                	mv	s1,a0
    8000473c:	10050b63          	beqz	a0,80004852 <create+0x13a>
    return 0;

  ilock(dp);
    80004740:	9a7fe0ef          	jal	ra,800030e6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004744:	4601                	li	a2,0
    80004746:	fb040593          	addi	a1,s0,-80
    8000474a:	8526                	mv	a0,s1
    8000474c:	de7fe0ef          	jal	ra,80003532 <dirlookup>
    80004750:	8aaa                	mv	s5,a0
    80004752:	c521                	beqz	a0,8000479a <create+0x82>
    iunlockput(dp);
    80004754:	8526                	mv	a0,s1
    80004756:	b97fe0ef          	jal	ra,800032ec <iunlockput>
    ilock(ip);
    8000475a:	8556                	mv	a0,s5
    8000475c:	98bfe0ef          	jal	ra,800030e6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004760:	000b059b          	sext.w	a1,s6
    80004764:	4789                	li	a5,2
    80004766:	02f59563          	bne	a1,a5,80004790 <create+0x78>
    8000476a:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde404>
    8000476e:	37f9                	addiw	a5,a5,-2
    80004770:	17c2                	slli	a5,a5,0x30
    80004772:	93c1                	srli	a5,a5,0x30
    80004774:	4705                	li	a4,1
    80004776:	00f76d63          	bltu	a4,a5,80004790 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000477a:	8556                	mv	a0,s5
    8000477c:	60a6                	ld	ra,72(sp)
    8000477e:	6406                	ld	s0,64(sp)
    80004780:	74e2                	ld	s1,56(sp)
    80004782:	7942                	ld	s2,48(sp)
    80004784:	79a2                	ld	s3,40(sp)
    80004786:	7a02                	ld	s4,32(sp)
    80004788:	6ae2                	ld	s5,24(sp)
    8000478a:	6b42                	ld	s6,16(sp)
    8000478c:	6161                	addi	sp,sp,80
    8000478e:	8082                	ret
    iunlockput(ip);
    80004790:	8556                	mv	a0,s5
    80004792:	b5bfe0ef          	jal	ra,800032ec <iunlockput>
    return 0;
    80004796:	4a81                	li	s5,0
    80004798:	b7cd                	j	8000477a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000479a:	85da                	mv	a1,s6
    8000479c:	4088                	lw	a0,0(s1)
    8000479e:	fe0fe0ef          	jal	ra,80002f7e <ialloc>
    800047a2:	8a2a                	mv	s4,a0
    800047a4:	cd1d                	beqz	a0,800047e2 <create+0xca>
  ilock(ip);
    800047a6:	941fe0ef          	jal	ra,800030e6 <ilock>
  ip->major = major;
    800047aa:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800047ae:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800047b2:	4905                	li	s2,1
    800047b4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800047b8:	8552                	mv	a0,s4
    800047ba:	87bfe0ef          	jal	ra,80003034 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800047be:	000b059b          	sext.w	a1,s6
    800047c2:	03258563          	beq	a1,s2,800047ec <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    800047c6:	004a2603          	lw	a2,4(s4)
    800047ca:	fb040593          	addi	a1,s0,-80
    800047ce:	8526                	mv	a0,s1
    800047d0:	f2ffe0ef          	jal	ra,800036fe <dirlink>
    800047d4:	06054363          	bltz	a0,8000483a <create+0x122>
  iunlockput(dp);
    800047d8:	8526                	mv	a0,s1
    800047da:	b13fe0ef          	jal	ra,800032ec <iunlockput>
  return ip;
    800047de:	8ad2                	mv	s5,s4
    800047e0:	bf69                	j	8000477a <create+0x62>
    iunlockput(dp);
    800047e2:	8526                	mv	a0,s1
    800047e4:	b09fe0ef          	jal	ra,800032ec <iunlockput>
    return 0;
    800047e8:	8ad2                	mv	s5,s4
    800047ea:	bf41                	j	8000477a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800047ec:	004a2603          	lw	a2,4(s4)
    800047f0:	00003597          	auipc	a1,0x3
    800047f4:	f4058593          	addi	a1,a1,-192 # 80007730 <syscalls+0x2a0>
    800047f8:	8552                	mv	a0,s4
    800047fa:	f05fe0ef          	jal	ra,800036fe <dirlink>
    800047fe:	02054e63          	bltz	a0,8000483a <create+0x122>
    80004802:	40d0                	lw	a2,4(s1)
    80004804:	00003597          	auipc	a1,0x3
    80004808:	f3458593          	addi	a1,a1,-204 # 80007738 <syscalls+0x2a8>
    8000480c:	8552                	mv	a0,s4
    8000480e:	ef1fe0ef          	jal	ra,800036fe <dirlink>
    80004812:	02054463          	bltz	a0,8000483a <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004816:	004a2603          	lw	a2,4(s4)
    8000481a:	fb040593          	addi	a1,s0,-80
    8000481e:	8526                	mv	a0,s1
    80004820:	edffe0ef          	jal	ra,800036fe <dirlink>
    80004824:	00054b63          	bltz	a0,8000483a <create+0x122>
    dp->nlink++;  // for ".."
    80004828:	04a4d783          	lhu	a5,74(s1)
    8000482c:	2785                	addiw	a5,a5,1
    8000482e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004832:	8526                	mv	a0,s1
    80004834:	801fe0ef          	jal	ra,80003034 <iupdate>
    80004838:	b745                	j	800047d8 <create+0xc0>
  ip->nlink = 0;
    8000483a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000483e:	8552                	mv	a0,s4
    80004840:	ff4fe0ef          	jal	ra,80003034 <iupdate>
  iunlockput(ip);
    80004844:	8552                	mv	a0,s4
    80004846:	aa7fe0ef          	jal	ra,800032ec <iunlockput>
  iunlockput(dp);
    8000484a:	8526                	mv	a0,s1
    8000484c:	aa1fe0ef          	jal	ra,800032ec <iunlockput>
  return 0;
    80004850:	b72d                	j	8000477a <create+0x62>
    return 0;
    80004852:	8aaa                	mv	s5,a0
    80004854:	b71d                	j	8000477a <create+0x62>

0000000080004856 <sys_dup>:
{
    80004856:	7179                	addi	sp,sp,-48
    80004858:	f406                	sd	ra,40(sp)
    8000485a:	f022                	sd	s0,32(sp)
    8000485c:	ec26                	sd	s1,24(sp)
    8000485e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004860:	fd840613          	addi	a2,s0,-40
    80004864:	4581                	li	a1,0
    80004866:	4501                	li	a0,0
    80004868:	e1bff0ef          	jal	ra,80004682 <argfd>
    return -1;
    8000486c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000486e:	00054f63          	bltz	a0,8000488c <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004872:	fd843503          	ld	a0,-40(s0)
    80004876:	e65ff0ef          	jal	ra,800046da <fdalloc>
    8000487a:	84aa                	mv	s1,a0
    return -1;
    8000487c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000487e:	00054763          	bltz	a0,8000488c <sys_dup+0x36>
  filedup(f);
    80004882:	fd843503          	ld	a0,-40(s0)
    80004886:	cc0ff0ef          	jal	ra,80003d46 <filedup>
  return fd;
    8000488a:	87a6                	mv	a5,s1
}
    8000488c:	853e                	mv	a0,a5
    8000488e:	70a2                	ld	ra,40(sp)
    80004890:	7402                	ld	s0,32(sp)
    80004892:	64e2                	ld	s1,24(sp)
    80004894:	6145                	addi	sp,sp,48
    80004896:	8082                	ret

0000000080004898 <sys_read>:
{
    80004898:	7179                	addi	sp,sp,-48
    8000489a:	f406                	sd	ra,40(sp)
    8000489c:	f022                	sd	s0,32(sp)
    8000489e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800048a0:	fd840593          	addi	a1,s0,-40
    800048a4:	4505                	li	a0,1
    800048a6:	e4ffd0ef          	jal	ra,800026f4 <argaddr>
  argint(2, &n);
    800048aa:	fe440593          	addi	a1,s0,-28
    800048ae:	4509                	li	a0,2
    800048b0:	e29fd0ef          	jal	ra,800026d8 <argint>
  if(argfd(0, 0, &f) < 0)
    800048b4:	fe840613          	addi	a2,s0,-24
    800048b8:	4581                	li	a1,0
    800048ba:	4501                	li	a0,0
    800048bc:	dc7ff0ef          	jal	ra,80004682 <argfd>
    800048c0:	87aa                	mv	a5,a0
    return -1;
    800048c2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800048c4:	0007ca63          	bltz	a5,800048d8 <sys_read+0x40>
  return fileread(f, p, n);
    800048c8:	fe442603          	lw	a2,-28(s0)
    800048cc:	fd843583          	ld	a1,-40(s0)
    800048d0:	fe843503          	ld	a0,-24(s0)
    800048d4:	dbeff0ef          	jal	ra,80003e92 <fileread>
}
    800048d8:	70a2                	ld	ra,40(sp)
    800048da:	7402                	ld	s0,32(sp)
    800048dc:	6145                	addi	sp,sp,48
    800048de:	8082                	ret

00000000800048e0 <sys_write>:
{
    800048e0:	7179                	addi	sp,sp,-48
    800048e2:	f406                	sd	ra,40(sp)
    800048e4:	f022                	sd	s0,32(sp)
    800048e6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800048e8:	fd840593          	addi	a1,s0,-40
    800048ec:	4505                	li	a0,1
    800048ee:	e07fd0ef          	jal	ra,800026f4 <argaddr>
  argint(2, &n);
    800048f2:	fe440593          	addi	a1,s0,-28
    800048f6:	4509                	li	a0,2
    800048f8:	de1fd0ef          	jal	ra,800026d8 <argint>
  if(argfd(0, 0, &f) < 0)
    800048fc:	fe840613          	addi	a2,s0,-24
    80004900:	4581                	li	a1,0
    80004902:	4501                	li	a0,0
    80004904:	d7fff0ef          	jal	ra,80004682 <argfd>
    80004908:	87aa                	mv	a5,a0
    return -1;
    8000490a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000490c:	0007ca63          	bltz	a5,80004920 <sys_write+0x40>
  return filewrite(f, p, n);
    80004910:	fe442603          	lw	a2,-28(s0)
    80004914:	fd843583          	ld	a1,-40(s0)
    80004918:	fe843503          	ld	a0,-24(s0)
    8000491c:	e24ff0ef          	jal	ra,80003f40 <filewrite>
}
    80004920:	70a2                	ld	ra,40(sp)
    80004922:	7402                	ld	s0,32(sp)
    80004924:	6145                	addi	sp,sp,48
    80004926:	8082                	ret

0000000080004928 <sys_close>:
{
    80004928:	1101                	addi	sp,sp,-32
    8000492a:	ec06                	sd	ra,24(sp)
    8000492c:	e822                	sd	s0,16(sp)
    8000492e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004930:	fe040613          	addi	a2,s0,-32
    80004934:	fec40593          	addi	a1,s0,-20
    80004938:	4501                	li	a0,0
    8000493a:	d49ff0ef          	jal	ra,80004682 <argfd>
    return -1;
    8000493e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004940:	02054063          	bltz	a0,80004960 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004944:	ee9fc0ef          	jal	ra,8000182c <myproc>
    80004948:	fec42783          	lw	a5,-20(s0)
    8000494c:	07e9                	addi	a5,a5,26
    8000494e:	078e                	slli	a5,a5,0x3
    80004950:	97aa                	add	a5,a5,a0
    80004952:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004956:	fe043503          	ld	a0,-32(s0)
    8000495a:	c32ff0ef          	jal	ra,80003d8c <fileclose>
  return 0;
    8000495e:	4781                	li	a5,0
}
    80004960:	853e                	mv	a0,a5
    80004962:	60e2                	ld	ra,24(sp)
    80004964:	6442                	ld	s0,16(sp)
    80004966:	6105                	addi	sp,sp,32
    80004968:	8082                	ret

000000008000496a <sys_fstat>:
{
    8000496a:	1101                	addi	sp,sp,-32
    8000496c:	ec06                	sd	ra,24(sp)
    8000496e:	e822                	sd	s0,16(sp)
    80004970:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004972:	fe040593          	addi	a1,s0,-32
    80004976:	4505                	li	a0,1
    80004978:	d7dfd0ef          	jal	ra,800026f4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000497c:	fe840613          	addi	a2,s0,-24
    80004980:	4581                	li	a1,0
    80004982:	4501                	li	a0,0
    80004984:	cffff0ef          	jal	ra,80004682 <argfd>
    80004988:	87aa                	mv	a5,a0
    return -1;
    8000498a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000498c:	0007c863          	bltz	a5,8000499c <sys_fstat+0x32>
  return filestat(f, st);
    80004990:	fe043583          	ld	a1,-32(s0)
    80004994:	fe843503          	ld	a0,-24(s0)
    80004998:	c9cff0ef          	jal	ra,80003e34 <filestat>
}
    8000499c:	60e2                	ld	ra,24(sp)
    8000499e:	6442                	ld	s0,16(sp)
    800049a0:	6105                	addi	sp,sp,32
    800049a2:	8082                	ret

00000000800049a4 <sys_link>:
{
    800049a4:	7169                	addi	sp,sp,-304
    800049a6:	f606                	sd	ra,296(sp)
    800049a8:	f222                	sd	s0,288(sp)
    800049aa:	ee26                	sd	s1,280(sp)
    800049ac:	ea4a                	sd	s2,272(sp)
    800049ae:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800049b0:	08000613          	li	a2,128
    800049b4:	ed040593          	addi	a1,s0,-304
    800049b8:	4501                	li	a0,0
    800049ba:	d57fd0ef          	jal	ra,80002710 <argstr>
    return -1;
    800049be:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800049c0:	0c054663          	bltz	a0,80004a8c <sys_link+0xe8>
    800049c4:	08000613          	li	a2,128
    800049c8:	f5040593          	addi	a1,s0,-176
    800049cc:	4505                	li	a0,1
    800049ce:	d43fd0ef          	jal	ra,80002710 <argstr>
    return -1;
    800049d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800049d4:	0a054c63          	bltz	a0,80004a8c <sys_link+0xe8>
  begin_op();
    800049d8:	f99fe0ef          	jal	ra,80003970 <begin_op>
  if((ip = namei(old)) == 0){
    800049dc:	ed040513          	addi	a0,s0,-304
    800049e0:	db9fe0ef          	jal	ra,80003798 <namei>
    800049e4:	84aa                	mv	s1,a0
    800049e6:	c525                	beqz	a0,80004a4e <sys_link+0xaa>
  ilock(ip);
    800049e8:	efefe0ef          	jal	ra,800030e6 <ilock>
  if(ip->type == T_DIR){
    800049ec:	04449703          	lh	a4,68(s1)
    800049f0:	4785                	li	a5,1
    800049f2:	06f70263          	beq	a4,a5,80004a56 <sys_link+0xb2>
  ip->nlink++;
    800049f6:	04a4d783          	lhu	a5,74(s1)
    800049fa:	2785                	addiw	a5,a5,1
    800049fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a00:	8526                	mv	a0,s1
    80004a02:	e32fe0ef          	jal	ra,80003034 <iupdate>
  iunlock(ip);
    80004a06:	8526                	mv	a0,s1
    80004a08:	f88fe0ef          	jal	ra,80003190 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004a0c:	fd040593          	addi	a1,s0,-48
    80004a10:	f5040513          	addi	a0,s0,-176
    80004a14:	d9ffe0ef          	jal	ra,800037b2 <nameiparent>
    80004a18:	892a                	mv	s2,a0
    80004a1a:	c921                	beqz	a0,80004a6a <sys_link+0xc6>
  ilock(dp);
    80004a1c:	ecafe0ef          	jal	ra,800030e6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004a20:	00092703          	lw	a4,0(s2)
    80004a24:	409c                	lw	a5,0(s1)
    80004a26:	02f71f63          	bne	a4,a5,80004a64 <sys_link+0xc0>
    80004a2a:	40d0                	lw	a2,4(s1)
    80004a2c:	fd040593          	addi	a1,s0,-48
    80004a30:	854a                	mv	a0,s2
    80004a32:	ccdfe0ef          	jal	ra,800036fe <dirlink>
    80004a36:	02054763          	bltz	a0,80004a64 <sys_link+0xc0>
  iunlockput(dp);
    80004a3a:	854a                	mv	a0,s2
    80004a3c:	8b1fe0ef          	jal	ra,800032ec <iunlockput>
  iput(ip);
    80004a40:	8526                	mv	a0,s1
    80004a42:	823fe0ef          	jal	ra,80003264 <iput>
  end_op();
    80004a46:	f9bfe0ef          	jal	ra,800039e0 <end_op>
  return 0;
    80004a4a:	4781                	li	a5,0
    80004a4c:	a081                	j	80004a8c <sys_link+0xe8>
    end_op();
    80004a4e:	f93fe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004a52:	57fd                	li	a5,-1
    80004a54:	a825                	j	80004a8c <sys_link+0xe8>
    iunlockput(ip);
    80004a56:	8526                	mv	a0,s1
    80004a58:	895fe0ef          	jal	ra,800032ec <iunlockput>
    end_op();
    80004a5c:	f85fe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004a60:	57fd                	li	a5,-1
    80004a62:	a02d                	j	80004a8c <sys_link+0xe8>
    iunlockput(dp);
    80004a64:	854a                	mv	a0,s2
    80004a66:	887fe0ef          	jal	ra,800032ec <iunlockput>
  ilock(ip);
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	e7afe0ef          	jal	ra,800030e6 <ilock>
  ip->nlink--;
    80004a70:	04a4d783          	lhu	a5,74(s1)
    80004a74:	37fd                	addiw	a5,a5,-1
    80004a76:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	db8fe0ef          	jal	ra,80003034 <iupdate>
  iunlockput(ip);
    80004a80:	8526                	mv	a0,s1
    80004a82:	86bfe0ef          	jal	ra,800032ec <iunlockput>
  end_op();
    80004a86:	f5bfe0ef          	jal	ra,800039e0 <end_op>
  return -1;
    80004a8a:	57fd                	li	a5,-1
}
    80004a8c:	853e                	mv	a0,a5
    80004a8e:	70b2                	ld	ra,296(sp)
    80004a90:	7412                	ld	s0,288(sp)
    80004a92:	64f2                	ld	s1,280(sp)
    80004a94:	6952                	ld	s2,272(sp)
    80004a96:	6155                	addi	sp,sp,304
    80004a98:	8082                	ret

0000000080004a9a <sys_unlink>:
{
    80004a9a:	7151                	addi	sp,sp,-240
    80004a9c:	f586                	sd	ra,232(sp)
    80004a9e:	f1a2                	sd	s0,224(sp)
    80004aa0:	eda6                	sd	s1,216(sp)
    80004aa2:	e9ca                	sd	s2,208(sp)
    80004aa4:	e5ce                	sd	s3,200(sp)
    80004aa6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004aa8:	08000613          	li	a2,128
    80004aac:	f3040593          	addi	a1,s0,-208
    80004ab0:	4501                	li	a0,0
    80004ab2:	c5ffd0ef          	jal	ra,80002710 <argstr>
    80004ab6:	12054b63          	bltz	a0,80004bec <sys_unlink+0x152>
  begin_op();
    80004aba:	eb7fe0ef          	jal	ra,80003970 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004abe:	fb040593          	addi	a1,s0,-80
    80004ac2:	f3040513          	addi	a0,s0,-208
    80004ac6:	cedfe0ef          	jal	ra,800037b2 <nameiparent>
    80004aca:	84aa                	mv	s1,a0
    80004acc:	c54d                	beqz	a0,80004b76 <sys_unlink+0xdc>
  ilock(dp);
    80004ace:	e18fe0ef          	jal	ra,800030e6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ad2:	00003597          	auipc	a1,0x3
    80004ad6:	c5e58593          	addi	a1,a1,-930 # 80007730 <syscalls+0x2a0>
    80004ada:	fb040513          	addi	a0,s0,-80
    80004ade:	a3ffe0ef          	jal	ra,8000351c <namecmp>
    80004ae2:	10050a63          	beqz	a0,80004bf6 <sys_unlink+0x15c>
    80004ae6:	00003597          	auipc	a1,0x3
    80004aea:	c5258593          	addi	a1,a1,-942 # 80007738 <syscalls+0x2a8>
    80004aee:	fb040513          	addi	a0,s0,-80
    80004af2:	a2bfe0ef          	jal	ra,8000351c <namecmp>
    80004af6:	10050063          	beqz	a0,80004bf6 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004afa:	f2c40613          	addi	a2,s0,-212
    80004afe:	fb040593          	addi	a1,s0,-80
    80004b02:	8526                	mv	a0,s1
    80004b04:	a2ffe0ef          	jal	ra,80003532 <dirlookup>
    80004b08:	892a                	mv	s2,a0
    80004b0a:	0e050663          	beqz	a0,80004bf6 <sys_unlink+0x15c>
  ilock(ip);
    80004b0e:	dd8fe0ef          	jal	ra,800030e6 <ilock>
  if(ip->nlink < 1)
    80004b12:	04a91783          	lh	a5,74(s2)
    80004b16:	06f05463          	blez	a5,80004b7e <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004b1a:	04491703          	lh	a4,68(s2)
    80004b1e:	4785                	li	a5,1
    80004b20:	06f70563          	beq	a4,a5,80004b8a <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004b24:	4641                	li	a2,16
    80004b26:	4581                	li	a1,0
    80004b28:	fc040513          	addi	a0,s0,-64
    80004b2c:	942fc0ef          	jal	ra,80000c6e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b30:	4741                	li	a4,16
    80004b32:	f2c42683          	lw	a3,-212(s0)
    80004b36:	fc040613          	addi	a2,s0,-64
    80004b3a:	4581                	li	a1,0
    80004b3c:	8526                	mv	a0,s1
    80004b3e:	8ddfe0ef          	jal	ra,8000341a <writei>
    80004b42:	47c1                	li	a5,16
    80004b44:	08f51563          	bne	a0,a5,80004bce <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004b48:	04491703          	lh	a4,68(s2)
    80004b4c:	4785                	li	a5,1
    80004b4e:	08f70663          	beq	a4,a5,80004bda <sys_unlink+0x140>
  iunlockput(dp);
    80004b52:	8526                	mv	a0,s1
    80004b54:	f98fe0ef          	jal	ra,800032ec <iunlockput>
  ip->nlink--;
    80004b58:	04a95783          	lhu	a5,74(s2)
    80004b5c:	37fd                	addiw	a5,a5,-1
    80004b5e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b62:	854a                	mv	a0,s2
    80004b64:	cd0fe0ef          	jal	ra,80003034 <iupdate>
  iunlockput(ip);
    80004b68:	854a                	mv	a0,s2
    80004b6a:	f82fe0ef          	jal	ra,800032ec <iunlockput>
  end_op();
    80004b6e:	e73fe0ef          	jal	ra,800039e0 <end_op>
  return 0;
    80004b72:	4501                	li	a0,0
    80004b74:	a079                	j	80004c02 <sys_unlink+0x168>
    end_op();
    80004b76:	e6bfe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004b7a:	557d                	li	a0,-1
    80004b7c:	a059                	j	80004c02 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004b7e:	00003517          	auipc	a0,0x3
    80004b82:	bc250513          	addi	a0,a0,-1086 # 80007740 <syscalls+0x2b0>
    80004b86:	bd1fb0ef          	jal	ra,80000756 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b8a:	04c92703          	lw	a4,76(s2)
    80004b8e:	02000793          	li	a5,32
    80004b92:	f8e7f9e3          	bgeu	a5,a4,80004b24 <sys_unlink+0x8a>
    80004b96:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b9a:	4741                	li	a4,16
    80004b9c:	86ce                	mv	a3,s3
    80004b9e:	f1840613          	addi	a2,s0,-232
    80004ba2:	4581                	li	a1,0
    80004ba4:	854a                	mv	a0,s2
    80004ba6:	f90fe0ef          	jal	ra,80003336 <readi>
    80004baa:	47c1                	li	a5,16
    80004bac:	00f51b63          	bne	a0,a5,80004bc2 <sys_unlink+0x128>
    if(de.inum != 0)
    80004bb0:	f1845783          	lhu	a5,-232(s0)
    80004bb4:	ef95                	bnez	a5,80004bf0 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004bb6:	29c1                	addiw	s3,s3,16
    80004bb8:	04c92783          	lw	a5,76(s2)
    80004bbc:	fcf9efe3          	bltu	s3,a5,80004b9a <sys_unlink+0x100>
    80004bc0:	b795                	j	80004b24 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004bc2:	00003517          	auipc	a0,0x3
    80004bc6:	b9650513          	addi	a0,a0,-1130 # 80007758 <syscalls+0x2c8>
    80004bca:	b8dfb0ef          	jal	ra,80000756 <panic>
    panic("unlink: writei");
    80004bce:	00003517          	auipc	a0,0x3
    80004bd2:	ba250513          	addi	a0,a0,-1118 # 80007770 <syscalls+0x2e0>
    80004bd6:	b81fb0ef          	jal	ra,80000756 <panic>
    dp->nlink--;
    80004bda:	04a4d783          	lhu	a5,74(s1)
    80004bde:	37fd                	addiw	a5,a5,-1
    80004be0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004be4:	8526                	mv	a0,s1
    80004be6:	c4efe0ef          	jal	ra,80003034 <iupdate>
    80004bea:	b7a5                	j	80004b52 <sys_unlink+0xb8>
    return -1;
    80004bec:	557d                	li	a0,-1
    80004bee:	a811                	j	80004c02 <sys_unlink+0x168>
    iunlockput(ip);
    80004bf0:	854a                	mv	a0,s2
    80004bf2:	efafe0ef          	jal	ra,800032ec <iunlockput>
  iunlockput(dp);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ef4fe0ef          	jal	ra,800032ec <iunlockput>
  end_op();
    80004bfc:	de5fe0ef          	jal	ra,800039e0 <end_op>
  return -1;
    80004c00:	557d                	li	a0,-1
}
    80004c02:	70ae                	ld	ra,232(sp)
    80004c04:	740e                	ld	s0,224(sp)
    80004c06:	64ee                	ld	s1,216(sp)
    80004c08:	694e                	ld	s2,208(sp)
    80004c0a:	69ae                	ld	s3,200(sp)
    80004c0c:	616d                	addi	sp,sp,240
    80004c0e:	8082                	ret

0000000080004c10 <sys_open>:

uint64
sys_open(void)
{
    80004c10:	7131                	addi	sp,sp,-192
    80004c12:	fd06                	sd	ra,184(sp)
    80004c14:	f922                	sd	s0,176(sp)
    80004c16:	f526                	sd	s1,168(sp)
    80004c18:	f14a                	sd	s2,160(sp)
    80004c1a:	ed4e                	sd	s3,152(sp)
    80004c1c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004c1e:	f4c40593          	addi	a1,s0,-180
    80004c22:	4505                	li	a0,1
    80004c24:	ab5fd0ef          	jal	ra,800026d8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c28:	08000613          	li	a2,128
    80004c2c:	f5040593          	addi	a1,s0,-176
    80004c30:	4501                	li	a0,0
    80004c32:	adffd0ef          	jal	ra,80002710 <argstr>
    80004c36:	87aa                	mv	a5,a0
    return -1;
    80004c38:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c3a:	0807cd63          	bltz	a5,80004cd4 <sys_open+0xc4>

  begin_op();
    80004c3e:	d33fe0ef          	jal	ra,80003970 <begin_op>

  if(omode & O_CREATE){
    80004c42:	f4c42783          	lw	a5,-180(s0)
    80004c46:	2007f793          	andi	a5,a5,512
    80004c4a:	c3c5                	beqz	a5,80004cea <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004c4c:	4681                	li	a3,0
    80004c4e:	4601                	li	a2,0
    80004c50:	4589                	li	a1,2
    80004c52:	f5040513          	addi	a0,s0,-176
    80004c56:	ac3ff0ef          	jal	ra,80004718 <create>
    80004c5a:	84aa                	mv	s1,a0
    if(ip == 0){
    80004c5c:	c159                	beqz	a0,80004ce2 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c5e:	04449703          	lh	a4,68(s1)
    80004c62:	478d                	li	a5,3
    80004c64:	00f71763          	bne	a4,a5,80004c72 <sys_open+0x62>
    80004c68:	0464d703          	lhu	a4,70(s1)
    80004c6c:	47a5                	li	a5,9
    80004c6e:	0ae7e963          	bltu	a5,a4,80004d20 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c72:	876ff0ef          	jal	ra,80003ce8 <filealloc>
    80004c76:	89aa                	mv	s3,a0
    80004c78:	0c050963          	beqz	a0,80004d4a <sys_open+0x13a>
    80004c7c:	a5fff0ef          	jal	ra,800046da <fdalloc>
    80004c80:	892a                	mv	s2,a0
    80004c82:	0c054163          	bltz	a0,80004d44 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004c86:	04449703          	lh	a4,68(s1)
    80004c8a:	478d                	li	a5,3
    80004c8c:	0af70163          	beq	a4,a5,80004d2e <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004c90:	4789                	li	a5,2
    80004c92:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004c96:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004c9a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004c9e:	f4c42783          	lw	a5,-180(s0)
    80004ca2:	0017c713          	xori	a4,a5,1
    80004ca6:	8b05                	andi	a4,a4,1
    80004ca8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004cac:	0037f713          	andi	a4,a5,3
    80004cb0:	00e03733          	snez	a4,a4
    80004cb4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004cb8:	4007f793          	andi	a5,a5,1024
    80004cbc:	c791                	beqz	a5,80004cc8 <sys_open+0xb8>
    80004cbe:	04449703          	lh	a4,68(s1)
    80004cc2:	4789                	li	a5,2
    80004cc4:	06f70c63          	beq	a4,a5,80004d3c <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	cc6fe0ef          	jal	ra,80003190 <iunlock>
  end_op();
    80004cce:	d13fe0ef          	jal	ra,800039e0 <end_op>

  return fd;
    80004cd2:	854a                	mv	a0,s2
}
    80004cd4:	70ea                	ld	ra,184(sp)
    80004cd6:	744a                	ld	s0,176(sp)
    80004cd8:	74aa                	ld	s1,168(sp)
    80004cda:	790a                	ld	s2,160(sp)
    80004cdc:	69ea                	ld	s3,152(sp)
    80004cde:	6129                	addi	sp,sp,192
    80004ce0:	8082                	ret
      end_op();
    80004ce2:	cfffe0ef          	jal	ra,800039e0 <end_op>
      return -1;
    80004ce6:	557d                	li	a0,-1
    80004ce8:	b7f5                	j	80004cd4 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004cea:	f5040513          	addi	a0,s0,-176
    80004cee:	aabfe0ef          	jal	ra,80003798 <namei>
    80004cf2:	84aa                	mv	s1,a0
    80004cf4:	c115                	beqz	a0,80004d18 <sys_open+0x108>
    ilock(ip);
    80004cf6:	bf0fe0ef          	jal	ra,800030e6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004cfa:	04449703          	lh	a4,68(s1)
    80004cfe:	4785                	li	a5,1
    80004d00:	f4f71fe3          	bne	a4,a5,80004c5e <sys_open+0x4e>
    80004d04:	f4c42783          	lw	a5,-180(s0)
    80004d08:	d7ad                	beqz	a5,80004c72 <sys_open+0x62>
      iunlockput(ip);
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	de0fe0ef          	jal	ra,800032ec <iunlockput>
      end_op();
    80004d10:	cd1fe0ef          	jal	ra,800039e0 <end_op>
      return -1;
    80004d14:	557d                	li	a0,-1
    80004d16:	bf7d                	j	80004cd4 <sys_open+0xc4>
      end_op();
    80004d18:	cc9fe0ef          	jal	ra,800039e0 <end_op>
      return -1;
    80004d1c:	557d                	li	a0,-1
    80004d1e:	bf5d                	j	80004cd4 <sys_open+0xc4>
    iunlockput(ip);
    80004d20:	8526                	mv	a0,s1
    80004d22:	dcafe0ef          	jal	ra,800032ec <iunlockput>
    end_op();
    80004d26:	cbbfe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004d2a:	557d                	li	a0,-1
    80004d2c:	b765                	j	80004cd4 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004d2e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d32:	04649783          	lh	a5,70(s1)
    80004d36:	02f99223          	sh	a5,36(s3)
    80004d3a:	b785                	j	80004c9a <sys_open+0x8a>
    itrunc(ip);
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	c92fe0ef          	jal	ra,800031d0 <itrunc>
    80004d42:	b759                	j	80004cc8 <sys_open+0xb8>
      fileclose(f);
    80004d44:	854e                	mv	a0,s3
    80004d46:	846ff0ef          	jal	ra,80003d8c <fileclose>
    iunlockput(ip);
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	da0fe0ef          	jal	ra,800032ec <iunlockput>
    end_op();
    80004d50:	c91fe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004d54:	557d                	li	a0,-1
    80004d56:	bfbd                	j	80004cd4 <sys_open+0xc4>

0000000080004d58 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004d58:	7175                	addi	sp,sp,-144
    80004d5a:	e506                	sd	ra,136(sp)
    80004d5c:	e122                	sd	s0,128(sp)
    80004d5e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004d60:	c11fe0ef          	jal	ra,80003970 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004d64:	08000613          	li	a2,128
    80004d68:	f7040593          	addi	a1,s0,-144
    80004d6c:	4501                	li	a0,0
    80004d6e:	9a3fd0ef          	jal	ra,80002710 <argstr>
    80004d72:	02054363          	bltz	a0,80004d98 <sys_mkdir+0x40>
    80004d76:	4681                	li	a3,0
    80004d78:	4601                	li	a2,0
    80004d7a:	4585                	li	a1,1
    80004d7c:	f7040513          	addi	a0,s0,-144
    80004d80:	999ff0ef          	jal	ra,80004718 <create>
    80004d84:	c911                	beqz	a0,80004d98 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d86:	d66fe0ef          	jal	ra,800032ec <iunlockput>
  end_op();
    80004d8a:	c57fe0ef          	jal	ra,800039e0 <end_op>
  return 0;
    80004d8e:	4501                	li	a0,0
}
    80004d90:	60aa                	ld	ra,136(sp)
    80004d92:	640a                	ld	s0,128(sp)
    80004d94:	6149                	addi	sp,sp,144
    80004d96:	8082                	ret
    end_op();
    80004d98:	c49fe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004d9c:	557d                	li	a0,-1
    80004d9e:	bfcd                	j	80004d90 <sys_mkdir+0x38>

0000000080004da0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004da0:	7135                	addi	sp,sp,-160
    80004da2:	ed06                	sd	ra,152(sp)
    80004da4:	e922                	sd	s0,144(sp)
    80004da6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004da8:	bc9fe0ef          	jal	ra,80003970 <begin_op>
  argint(1, &major);
    80004dac:	f6c40593          	addi	a1,s0,-148
    80004db0:	4505                	li	a0,1
    80004db2:	927fd0ef          	jal	ra,800026d8 <argint>
  argint(2, &minor);
    80004db6:	f6840593          	addi	a1,s0,-152
    80004dba:	4509                	li	a0,2
    80004dbc:	91dfd0ef          	jal	ra,800026d8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004dc0:	08000613          	li	a2,128
    80004dc4:	f7040593          	addi	a1,s0,-144
    80004dc8:	4501                	li	a0,0
    80004dca:	947fd0ef          	jal	ra,80002710 <argstr>
    80004dce:	02054563          	bltz	a0,80004df8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004dd2:	f6841683          	lh	a3,-152(s0)
    80004dd6:	f6c41603          	lh	a2,-148(s0)
    80004dda:	458d                	li	a1,3
    80004ddc:	f7040513          	addi	a0,s0,-144
    80004de0:	939ff0ef          	jal	ra,80004718 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004de4:	c911                	beqz	a0,80004df8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004de6:	d06fe0ef          	jal	ra,800032ec <iunlockput>
  end_op();
    80004dea:	bf7fe0ef          	jal	ra,800039e0 <end_op>
  return 0;
    80004dee:	4501                	li	a0,0
}
    80004df0:	60ea                	ld	ra,152(sp)
    80004df2:	644a                	ld	s0,144(sp)
    80004df4:	610d                	addi	sp,sp,160
    80004df6:	8082                	ret
    end_op();
    80004df8:	be9fe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004dfc:	557d                	li	a0,-1
    80004dfe:	bfcd                	j	80004df0 <sys_mknod+0x50>

0000000080004e00 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e00:	7135                	addi	sp,sp,-160
    80004e02:	ed06                	sd	ra,152(sp)
    80004e04:	e922                	sd	s0,144(sp)
    80004e06:	e526                	sd	s1,136(sp)
    80004e08:	e14a                	sd	s2,128(sp)
    80004e0a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e0c:	a21fc0ef          	jal	ra,8000182c <myproc>
    80004e10:	892a                	mv	s2,a0
  
  begin_op();
    80004e12:	b5ffe0ef          	jal	ra,80003970 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004e16:	08000613          	li	a2,128
    80004e1a:	f6040593          	addi	a1,s0,-160
    80004e1e:	4501                	li	a0,0
    80004e20:	8f1fd0ef          	jal	ra,80002710 <argstr>
    80004e24:	04054163          	bltz	a0,80004e66 <sys_chdir+0x66>
    80004e28:	f6040513          	addi	a0,s0,-160
    80004e2c:	96dfe0ef          	jal	ra,80003798 <namei>
    80004e30:	84aa                	mv	s1,a0
    80004e32:	c915                	beqz	a0,80004e66 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004e34:	ab2fe0ef          	jal	ra,800030e6 <ilock>
  if(ip->type != T_DIR){
    80004e38:	04449703          	lh	a4,68(s1)
    80004e3c:	4785                	li	a5,1
    80004e3e:	02f71863          	bne	a4,a5,80004e6e <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004e42:	8526                	mv	a0,s1
    80004e44:	b4cfe0ef          	jal	ra,80003190 <iunlock>
  iput(p->cwd);
    80004e48:	15093503          	ld	a0,336(s2)
    80004e4c:	c18fe0ef          	jal	ra,80003264 <iput>
  end_op();
    80004e50:	b91fe0ef          	jal	ra,800039e0 <end_op>
  p->cwd = ip;
    80004e54:	14993823          	sd	s1,336(s2)
  return 0;
    80004e58:	4501                	li	a0,0
}
    80004e5a:	60ea                	ld	ra,152(sp)
    80004e5c:	644a                	ld	s0,144(sp)
    80004e5e:	64aa                	ld	s1,136(sp)
    80004e60:	690a                	ld	s2,128(sp)
    80004e62:	610d                	addi	sp,sp,160
    80004e64:	8082                	ret
    end_op();
    80004e66:	b7bfe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004e6a:	557d                	li	a0,-1
    80004e6c:	b7fd                	j	80004e5a <sys_chdir+0x5a>
    iunlockput(ip);
    80004e6e:	8526                	mv	a0,s1
    80004e70:	c7cfe0ef          	jal	ra,800032ec <iunlockput>
    end_op();
    80004e74:	b6dfe0ef          	jal	ra,800039e0 <end_op>
    return -1;
    80004e78:	557d                	li	a0,-1
    80004e7a:	b7c5                	j	80004e5a <sys_chdir+0x5a>

0000000080004e7c <sys_exec>:

uint64
sys_exec(void)
{
    80004e7c:	7145                	addi	sp,sp,-464
    80004e7e:	e786                	sd	ra,456(sp)
    80004e80:	e3a2                	sd	s0,448(sp)
    80004e82:	ff26                	sd	s1,440(sp)
    80004e84:	fb4a                	sd	s2,432(sp)
    80004e86:	f74e                	sd	s3,424(sp)
    80004e88:	f352                	sd	s4,416(sp)
    80004e8a:	ef56                	sd	s5,408(sp)
    80004e8c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004e8e:	e3840593          	addi	a1,s0,-456
    80004e92:	4505                	li	a0,1
    80004e94:	861fd0ef          	jal	ra,800026f4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004e98:	08000613          	li	a2,128
    80004e9c:	f4040593          	addi	a1,s0,-192
    80004ea0:	4501                	li	a0,0
    80004ea2:	86ffd0ef          	jal	ra,80002710 <argstr>
    80004ea6:	87aa                	mv	a5,a0
    return -1;
    80004ea8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004eaa:	0a07c463          	bltz	a5,80004f52 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80004eae:	10000613          	li	a2,256
    80004eb2:	4581                	li	a1,0
    80004eb4:	e4040513          	addi	a0,s0,-448
    80004eb8:	db7fb0ef          	jal	ra,80000c6e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004ebc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004ec0:	89a6                	mv	s3,s1
    80004ec2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004ec4:	02000a13          	li	s4,32
    80004ec8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004ecc:	00391793          	slli	a5,s2,0x3
    80004ed0:	e3040593          	addi	a1,s0,-464
    80004ed4:	e3843503          	ld	a0,-456(s0)
    80004ed8:	953e                	add	a0,a0,a5
    80004eda:	f74fd0ef          	jal	ra,8000264e <fetchaddr>
    80004ede:	02054663          	bltz	a0,80004f0a <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80004ee2:	e3043783          	ld	a5,-464(s0)
    80004ee6:	cf8d                	beqz	a5,80004f20 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004ee8:	be3fb0ef          	jal	ra,80000aca <kalloc>
    80004eec:	85aa                	mv	a1,a0
    80004eee:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004ef2:	cd01                	beqz	a0,80004f0a <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004ef4:	6605                	lui	a2,0x1
    80004ef6:	e3043503          	ld	a0,-464(s0)
    80004efa:	f9efd0ef          	jal	ra,80002698 <fetchstr>
    80004efe:	00054663          	bltz	a0,80004f0a <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80004f02:	0905                	addi	s2,s2,1
    80004f04:	09a1                	addi	s3,s3,8
    80004f06:	fd4911e3          	bne	s2,s4,80004ec8 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f0a:	10048913          	addi	s2,s1,256
    80004f0e:	6088                	ld	a0,0(s1)
    80004f10:	c121                	beqz	a0,80004f50 <sys_exec+0xd4>
    kfree(argv[i]);
    80004f12:	ad9fb0ef          	jal	ra,800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f16:	04a1                	addi	s1,s1,8
    80004f18:	ff249be3          	bne	s1,s2,80004f0e <sys_exec+0x92>
  return -1;
    80004f1c:	557d                	li	a0,-1
    80004f1e:	a815                	j	80004f52 <sys_exec+0xd6>
      argv[i] = 0;
    80004f20:	0a8e                	slli	s5,s5,0x3
    80004f22:	fc040793          	addi	a5,s0,-64
    80004f26:	9abe                	add	s5,s5,a5
    80004f28:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004f2c:	e4040593          	addi	a1,s0,-448
    80004f30:	f4040513          	addi	a0,s0,-192
    80004f34:	bfaff0ef          	jal	ra,8000432e <exec>
    80004f38:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f3a:	10048993          	addi	s3,s1,256
    80004f3e:	6088                	ld	a0,0(s1)
    80004f40:	c511                	beqz	a0,80004f4c <sys_exec+0xd0>
    kfree(argv[i]);
    80004f42:	aa9fb0ef          	jal	ra,800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f46:	04a1                	addi	s1,s1,8
    80004f48:	ff349be3          	bne	s1,s3,80004f3e <sys_exec+0xc2>
  return ret;
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	a011                	j	80004f52 <sys_exec+0xd6>
  return -1;
    80004f50:	557d                	li	a0,-1
}
    80004f52:	60be                	ld	ra,456(sp)
    80004f54:	641e                	ld	s0,448(sp)
    80004f56:	74fa                	ld	s1,440(sp)
    80004f58:	795a                	ld	s2,432(sp)
    80004f5a:	79ba                	ld	s3,424(sp)
    80004f5c:	7a1a                	ld	s4,416(sp)
    80004f5e:	6afa                	ld	s5,408(sp)
    80004f60:	6179                	addi	sp,sp,464
    80004f62:	8082                	ret

0000000080004f64 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004f64:	7139                	addi	sp,sp,-64
    80004f66:	fc06                	sd	ra,56(sp)
    80004f68:	f822                	sd	s0,48(sp)
    80004f6a:	f426                	sd	s1,40(sp)
    80004f6c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004f6e:	8bffc0ef          	jal	ra,8000182c <myproc>
    80004f72:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004f74:	fd840593          	addi	a1,s0,-40
    80004f78:	4501                	li	a0,0
    80004f7a:	f7afd0ef          	jal	ra,800026f4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004f7e:	fc840593          	addi	a1,s0,-56
    80004f82:	fd040513          	addi	a0,s0,-48
    80004f86:	8d2ff0ef          	jal	ra,80004058 <pipealloc>
    return -1;
    80004f8a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004f8c:	0a054463          	bltz	a0,80005034 <sys_pipe+0xd0>
  fd0 = -1;
    80004f90:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004f94:	fd043503          	ld	a0,-48(s0)
    80004f98:	f42ff0ef          	jal	ra,800046da <fdalloc>
    80004f9c:	fca42223          	sw	a0,-60(s0)
    80004fa0:	08054163          	bltz	a0,80005022 <sys_pipe+0xbe>
    80004fa4:	fc843503          	ld	a0,-56(s0)
    80004fa8:	f32ff0ef          	jal	ra,800046da <fdalloc>
    80004fac:	fca42023          	sw	a0,-64(s0)
    80004fb0:	06054063          	bltz	a0,80005010 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fb4:	4691                	li	a3,4
    80004fb6:	fc440613          	addi	a2,s0,-60
    80004fba:	fd843583          	ld	a1,-40(s0)
    80004fbe:	68a8                	ld	a0,80(s1)
    80004fc0:	d20fc0ef          	jal	ra,800014e0 <copyout>
    80004fc4:	00054e63          	bltz	a0,80004fe0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004fc8:	4691                	li	a3,4
    80004fca:	fc040613          	addi	a2,s0,-64
    80004fce:	fd843583          	ld	a1,-40(s0)
    80004fd2:	0591                	addi	a1,a1,4
    80004fd4:	68a8                	ld	a0,80(s1)
    80004fd6:	d0afc0ef          	jal	ra,800014e0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004fda:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fdc:	04055c63          	bgez	a0,80005034 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004fe0:	fc442783          	lw	a5,-60(s0)
    80004fe4:	07e9                	addi	a5,a5,26
    80004fe6:	078e                	slli	a5,a5,0x3
    80004fe8:	97a6                	add	a5,a5,s1
    80004fea:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004fee:	fc042503          	lw	a0,-64(s0)
    80004ff2:	0569                	addi	a0,a0,26
    80004ff4:	050e                	slli	a0,a0,0x3
    80004ff6:	94aa                	add	s1,s1,a0
    80004ff8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004ffc:	fd043503          	ld	a0,-48(s0)
    80005000:	d8dfe0ef          	jal	ra,80003d8c <fileclose>
    fileclose(wf);
    80005004:	fc843503          	ld	a0,-56(s0)
    80005008:	d85fe0ef          	jal	ra,80003d8c <fileclose>
    return -1;
    8000500c:	57fd                	li	a5,-1
    8000500e:	a01d                	j	80005034 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005010:	fc442783          	lw	a5,-60(s0)
    80005014:	0007c763          	bltz	a5,80005022 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005018:	07e9                	addi	a5,a5,26
    8000501a:	078e                	slli	a5,a5,0x3
    8000501c:	94be                	add	s1,s1,a5
    8000501e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005022:	fd043503          	ld	a0,-48(s0)
    80005026:	d67fe0ef          	jal	ra,80003d8c <fileclose>
    fileclose(wf);
    8000502a:	fc843503          	ld	a0,-56(s0)
    8000502e:	d5ffe0ef          	jal	ra,80003d8c <fileclose>
    return -1;
    80005032:	57fd                	li	a5,-1
}
    80005034:	853e                	mv	a0,a5
    80005036:	70e2                	ld	ra,56(sp)
    80005038:	7442                	ld	s0,48(sp)
    8000503a:	74a2                	ld	s1,40(sp)
    8000503c:	6121                	addi	sp,sp,64
    8000503e:	8082                	ret

0000000080005040 <kernelvec>:
    80005040:	7111                	addi	sp,sp,-256
    80005042:	e006                	sd	ra,0(sp)
    80005044:	e40a                	sd	sp,8(sp)
    80005046:	e80e                	sd	gp,16(sp)
    80005048:	ec12                	sd	tp,24(sp)
    8000504a:	f016                	sd	t0,32(sp)
    8000504c:	f41a                	sd	t1,40(sp)
    8000504e:	f81e                	sd	t2,48(sp)
    80005050:	e4aa                	sd	a0,72(sp)
    80005052:	e8ae                	sd	a1,80(sp)
    80005054:	ecb2                	sd	a2,88(sp)
    80005056:	f0b6                	sd	a3,96(sp)
    80005058:	f4ba                	sd	a4,104(sp)
    8000505a:	f8be                	sd	a5,112(sp)
    8000505c:	fcc2                	sd	a6,120(sp)
    8000505e:	e146                	sd	a7,128(sp)
    80005060:	edf2                	sd	t3,216(sp)
    80005062:	f1f6                	sd	t4,224(sp)
    80005064:	f5fa                	sd	t5,232(sp)
    80005066:	f9fe                	sd	t6,240(sp)
    80005068:	cf6fd0ef          	jal	ra,8000255e <kerneltrap>
    8000506c:	6082                	ld	ra,0(sp)
    8000506e:	6122                	ld	sp,8(sp)
    80005070:	61c2                	ld	gp,16(sp)
    80005072:	7282                	ld	t0,32(sp)
    80005074:	7322                	ld	t1,40(sp)
    80005076:	73c2                	ld	t2,48(sp)
    80005078:	6526                	ld	a0,72(sp)
    8000507a:	65c6                	ld	a1,80(sp)
    8000507c:	6666                	ld	a2,88(sp)
    8000507e:	7686                	ld	a3,96(sp)
    80005080:	7726                	ld	a4,104(sp)
    80005082:	77c6                	ld	a5,112(sp)
    80005084:	7866                	ld	a6,120(sp)
    80005086:	688a                	ld	a7,128(sp)
    80005088:	6e6e                	ld	t3,216(sp)
    8000508a:	7e8e                	ld	t4,224(sp)
    8000508c:	7f2e                	ld	t5,232(sp)
    8000508e:	7fce                	ld	t6,240(sp)
    80005090:	6111                	addi	sp,sp,256
    80005092:	10200073          	sret
	...

000000008000509e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000509e:	1141                	addi	sp,sp,-16
    800050a0:	e422                	sd	s0,8(sp)
    800050a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800050a4:	0c0007b7          	lui	a5,0xc000
    800050a8:	4705                	li	a4,1
    800050aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800050ac:	c3d8                	sw	a4,4(a5)
}
    800050ae:	6422                	ld	s0,8(sp)
    800050b0:	0141                	addi	sp,sp,16
    800050b2:	8082                	ret

00000000800050b4 <plicinithart>:

void
plicinithart(void)
{
    800050b4:	1141                	addi	sp,sp,-16
    800050b6:	e406                	sd	ra,8(sp)
    800050b8:	e022                	sd	s0,0(sp)
    800050ba:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800050bc:	f44fc0ef          	jal	ra,80001800 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800050c0:	0085171b          	slliw	a4,a0,0x8
    800050c4:	0c0027b7          	lui	a5,0xc002
    800050c8:	97ba                	add	a5,a5,a4
    800050ca:	40200713          	li	a4,1026
    800050ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800050d2:	00d5151b          	slliw	a0,a0,0xd
    800050d6:	0c2017b7          	lui	a5,0xc201
    800050da:	953e                	add	a0,a0,a5
    800050dc:	00052023          	sw	zero,0(a0)
}
    800050e0:	60a2                	ld	ra,8(sp)
    800050e2:	6402                	ld	s0,0(sp)
    800050e4:	0141                	addi	sp,sp,16
    800050e6:	8082                	ret

00000000800050e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800050e8:	1141                	addi	sp,sp,-16
    800050ea:	e406                	sd	ra,8(sp)
    800050ec:	e022                	sd	s0,0(sp)
    800050ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800050f0:	f10fc0ef          	jal	ra,80001800 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800050f4:	00d5179b          	slliw	a5,a0,0xd
    800050f8:	0c201537          	lui	a0,0xc201
    800050fc:	953e                	add	a0,a0,a5
  return irq;
}
    800050fe:	4148                	lw	a0,4(a0)
    80005100:	60a2                	ld	ra,8(sp)
    80005102:	6402                	ld	s0,0(sp)
    80005104:	0141                	addi	sp,sp,16
    80005106:	8082                	ret

0000000080005108 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005108:	1101                	addi	sp,sp,-32
    8000510a:	ec06                	sd	ra,24(sp)
    8000510c:	e822                	sd	s0,16(sp)
    8000510e:	e426                	sd	s1,8(sp)
    80005110:	1000                	addi	s0,sp,32
    80005112:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005114:	eecfc0ef          	jal	ra,80001800 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005118:	00d5151b          	slliw	a0,a0,0xd
    8000511c:	0c2017b7          	lui	a5,0xc201
    80005120:	97aa                	add	a5,a5,a0
    80005122:	c3c4                	sw	s1,4(a5)
}
    80005124:	60e2                	ld	ra,24(sp)
    80005126:	6442                	ld	s0,16(sp)
    80005128:	64a2                	ld	s1,8(sp)
    8000512a:	6105                	addi	sp,sp,32
    8000512c:	8082                	ret

000000008000512e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000512e:	1141                	addi	sp,sp,-16
    80005130:	e406                	sd	ra,8(sp)
    80005132:	e022                	sd	s0,0(sp)
    80005134:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005136:	479d                	li	a5,7
    80005138:	04a7ca63          	blt	a5,a0,8000518c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000513c:	0001c797          	auipc	a5,0x1c
    80005140:	9c478793          	addi	a5,a5,-1596 # 80020b00 <disk>
    80005144:	97aa                	add	a5,a5,a0
    80005146:	0187c783          	lbu	a5,24(a5)
    8000514a:	e7b9                	bnez	a5,80005198 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000514c:	00451613          	slli	a2,a0,0x4
    80005150:	0001c797          	auipc	a5,0x1c
    80005154:	9b078793          	addi	a5,a5,-1616 # 80020b00 <disk>
    80005158:	6394                	ld	a3,0(a5)
    8000515a:	96b2                	add	a3,a3,a2
    8000515c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005160:	6398                	ld	a4,0(a5)
    80005162:	9732                	add	a4,a4,a2
    80005164:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005168:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000516c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005170:	953e                	add	a0,a0,a5
    80005172:	4785                	li	a5,1
    80005174:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005178:	0001c517          	auipc	a0,0x1c
    8000517c:	9a050513          	addi	a0,a0,-1632 # 80020b18 <disk+0x18>
    80005180:	cc5fc0ef          	jal	ra,80001e44 <wakeup>
}
    80005184:	60a2                	ld	ra,8(sp)
    80005186:	6402                	ld	s0,0(sp)
    80005188:	0141                	addi	sp,sp,16
    8000518a:	8082                	ret
    panic("free_desc 1");
    8000518c:	00002517          	auipc	a0,0x2
    80005190:	5f450513          	addi	a0,a0,1524 # 80007780 <syscalls+0x2f0>
    80005194:	dc2fb0ef          	jal	ra,80000756 <panic>
    panic("free_desc 2");
    80005198:	00002517          	auipc	a0,0x2
    8000519c:	5f850513          	addi	a0,a0,1528 # 80007790 <syscalls+0x300>
    800051a0:	db6fb0ef          	jal	ra,80000756 <panic>

00000000800051a4 <virtio_disk_init>:
{
    800051a4:	1101                	addi	sp,sp,-32
    800051a6:	ec06                	sd	ra,24(sp)
    800051a8:	e822                	sd	s0,16(sp)
    800051aa:	e426                	sd	s1,8(sp)
    800051ac:	e04a                	sd	s2,0(sp)
    800051ae:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800051b0:	00002597          	auipc	a1,0x2
    800051b4:	5f058593          	addi	a1,a1,1520 # 800077a0 <syscalls+0x310>
    800051b8:	0001c517          	auipc	a0,0x1c
    800051bc:	a7050513          	addi	a0,a0,-1424 # 80020c28 <disk+0x128>
    800051c0:	95bfb0ef          	jal	ra,80000b1a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800051c4:	100017b7          	lui	a5,0x10001
    800051c8:	4398                	lw	a4,0(a5)
    800051ca:	2701                	sext.w	a4,a4
    800051cc:	747277b7          	lui	a5,0x74727
    800051d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800051d4:	14f71063          	bne	a4,a5,80005314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800051d8:	100017b7          	lui	a5,0x10001
    800051dc:	43dc                	lw	a5,4(a5)
    800051de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800051e0:	4709                	li	a4,2
    800051e2:	12e79963          	bne	a5,a4,80005314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800051e6:	100017b7          	lui	a5,0x10001
    800051ea:	479c                	lw	a5,8(a5)
    800051ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800051ee:	12e79363          	bne	a5,a4,80005314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800051f2:	100017b7          	lui	a5,0x10001
    800051f6:	47d8                	lw	a4,12(a5)
    800051f8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800051fa:	554d47b7          	lui	a5,0x554d4
    800051fe:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005202:	10f71963          	bne	a4,a5,80005314 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005206:	100017b7          	lui	a5,0x10001
    8000520a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000520e:	4705                	li	a4,1
    80005210:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005212:	470d                	li	a4,3
    80005214:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005216:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005218:	c7ffe737          	lui	a4,0xc7ffe
    8000521c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddb1f>
    80005220:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005222:	2701                	sext.w	a4,a4
    80005224:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005226:	472d                	li	a4,11
    80005228:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000522a:	5bbc                	lw	a5,112(a5)
    8000522c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005230:	8ba1                	andi	a5,a5,8
    80005232:	0e078763          	beqz	a5,80005320 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005236:	100017b7          	lui	a5,0x10001
    8000523a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000523e:	43fc                	lw	a5,68(a5)
    80005240:	2781                	sext.w	a5,a5
    80005242:	0e079563          	bnez	a5,8000532c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005246:	100017b7          	lui	a5,0x10001
    8000524a:	5bdc                	lw	a5,52(a5)
    8000524c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000524e:	0e078563          	beqz	a5,80005338 <virtio_disk_init+0x194>
  if(max < NUM)
    80005252:	471d                	li	a4,7
    80005254:	0ef77863          	bgeu	a4,a5,80005344 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005258:	873fb0ef          	jal	ra,80000aca <kalloc>
    8000525c:	0001c497          	auipc	s1,0x1c
    80005260:	8a448493          	addi	s1,s1,-1884 # 80020b00 <disk>
    80005264:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005266:	865fb0ef          	jal	ra,80000aca <kalloc>
    8000526a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000526c:	85ffb0ef          	jal	ra,80000aca <kalloc>
    80005270:	87aa                	mv	a5,a0
    80005272:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005274:	6088                	ld	a0,0(s1)
    80005276:	cd69                	beqz	a0,80005350 <virtio_disk_init+0x1ac>
    80005278:	0001c717          	auipc	a4,0x1c
    8000527c:	89073703          	ld	a4,-1904(a4) # 80020b08 <disk+0x8>
    80005280:	cb61                	beqz	a4,80005350 <virtio_disk_init+0x1ac>
    80005282:	c7f9                	beqz	a5,80005350 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80005284:	6605                	lui	a2,0x1
    80005286:	4581                	li	a1,0
    80005288:	9e7fb0ef          	jal	ra,80000c6e <memset>
  memset(disk.avail, 0, PGSIZE);
    8000528c:	0001c497          	auipc	s1,0x1c
    80005290:	87448493          	addi	s1,s1,-1932 # 80020b00 <disk>
    80005294:	6605                	lui	a2,0x1
    80005296:	4581                	li	a1,0
    80005298:	6488                	ld	a0,8(s1)
    8000529a:	9d5fb0ef          	jal	ra,80000c6e <memset>
  memset(disk.used, 0, PGSIZE);
    8000529e:	6605                	lui	a2,0x1
    800052a0:	4581                	li	a1,0
    800052a2:	6888                	ld	a0,16(s1)
    800052a4:	9cbfb0ef          	jal	ra,80000c6e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800052a8:	100017b7          	lui	a5,0x10001
    800052ac:	4721                	li	a4,8
    800052ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800052b0:	4098                	lw	a4,0(s1)
    800052b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800052b6:	40d8                	lw	a4,4(s1)
    800052b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800052bc:	6498                	ld	a4,8(s1)
    800052be:	0007069b          	sext.w	a3,a4
    800052c2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800052c6:	9701                	srai	a4,a4,0x20
    800052c8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800052cc:	6898                	ld	a4,16(s1)
    800052ce:	0007069b          	sext.w	a3,a4
    800052d2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800052d6:	9701                	srai	a4,a4,0x20
    800052d8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800052dc:	4705                	li	a4,1
    800052de:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800052e0:	00e48c23          	sb	a4,24(s1)
    800052e4:	00e48ca3          	sb	a4,25(s1)
    800052e8:	00e48d23          	sb	a4,26(s1)
    800052ec:	00e48da3          	sb	a4,27(s1)
    800052f0:	00e48e23          	sb	a4,28(s1)
    800052f4:	00e48ea3          	sb	a4,29(s1)
    800052f8:	00e48f23          	sb	a4,30(s1)
    800052fc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005300:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005304:	0727a823          	sw	s2,112(a5)
}
    80005308:	60e2                	ld	ra,24(sp)
    8000530a:	6442                	ld	s0,16(sp)
    8000530c:	64a2                	ld	s1,8(sp)
    8000530e:	6902                	ld	s2,0(sp)
    80005310:	6105                	addi	sp,sp,32
    80005312:	8082                	ret
    panic("could not find virtio disk");
    80005314:	00002517          	auipc	a0,0x2
    80005318:	49c50513          	addi	a0,a0,1180 # 800077b0 <syscalls+0x320>
    8000531c:	c3afb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005320:	00002517          	auipc	a0,0x2
    80005324:	4b050513          	addi	a0,a0,1200 # 800077d0 <syscalls+0x340>
    80005328:	c2efb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk should not be ready");
    8000532c:	00002517          	auipc	a0,0x2
    80005330:	4c450513          	addi	a0,a0,1220 # 800077f0 <syscalls+0x360>
    80005334:	c22fb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk has no queue 0");
    80005338:	00002517          	auipc	a0,0x2
    8000533c:	4d850513          	addi	a0,a0,1240 # 80007810 <syscalls+0x380>
    80005340:	c16fb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk max queue too short");
    80005344:	00002517          	auipc	a0,0x2
    80005348:	4ec50513          	addi	a0,a0,1260 # 80007830 <syscalls+0x3a0>
    8000534c:	c0afb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk kalloc");
    80005350:	00002517          	auipc	a0,0x2
    80005354:	50050513          	addi	a0,a0,1280 # 80007850 <syscalls+0x3c0>
    80005358:	bfefb0ef          	jal	ra,80000756 <panic>

000000008000535c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000535c:	7119                	addi	sp,sp,-128
    8000535e:	fc86                	sd	ra,120(sp)
    80005360:	f8a2                	sd	s0,112(sp)
    80005362:	f4a6                	sd	s1,104(sp)
    80005364:	f0ca                	sd	s2,96(sp)
    80005366:	ecce                	sd	s3,88(sp)
    80005368:	e8d2                	sd	s4,80(sp)
    8000536a:	e4d6                	sd	s5,72(sp)
    8000536c:	e0da                	sd	s6,64(sp)
    8000536e:	fc5e                	sd	s7,56(sp)
    80005370:	f862                	sd	s8,48(sp)
    80005372:	f466                	sd	s9,40(sp)
    80005374:	f06a                	sd	s10,32(sp)
    80005376:	ec6e                	sd	s11,24(sp)
    80005378:	0100                	addi	s0,sp,128
    8000537a:	8aaa                	mv	s5,a0
    8000537c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000537e:	00c52d03          	lw	s10,12(a0)
    80005382:	001d1d1b          	slliw	s10,s10,0x1
    80005386:	1d02                	slli	s10,s10,0x20
    80005388:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000538c:	0001c517          	auipc	a0,0x1c
    80005390:	89c50513          	addi	a0,a0,-1892 # 80020c28 <disk+0x128>
    80005394:	807fb0ef          	jal	ra,80000b9a <acquire>
  for(int i = 0; i < 3; i++){
    80005398:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000539a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000539c:	0001bb97          	auipc	s7,0x1b
    800053a0:	764b8b93          	addi	s7,s7,1892 # 80020b00 <disk>
  for(int i = 0; i < 3; i++){
    800053a4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800053a6:	0001cc97          	auipc	s9,0x1c
    800053aa:	882c8c93          	addi	s9,s9,-1918 # 80020c28 <disk+0x128>
    800053ae:	a8a9                	j	80005408 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800053b0:	00fb8733          	add	a4,s7,a5
    800053b4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800053b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800053ba:	0207c563          	bltz	a5,800053e4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800053be:	2905                	addiw	s2,s2,1
    800053c0:	0611                	addi	a2,a2,4
    800053c2:	05690863          	beq	s2,s6,80005412 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800053c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800053c8:	0001b717          	auipc	a4,0x1b
    800053cc:	73870713          	addi	a4,a4,1848 # 80020b00 <disk>
    800053d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800053d2:	01874683          	lbu	a3,24(a4)
    800053d6:	fee9                	bnez	a3,800053b0 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800053d8:	2785                	addiw	a5,a5,1
    800053da:	0705                	addi	a4,a4,1
    800053dc:	fe979be3          	bne	a5,s1,800053d2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800053e0:	57fd                	li	a5,-1
    800053e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800053e4:	01205b63          	blez	s2,800053fa <virtio_disk_rw+0x9e>
    800053e8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800053ea:	000a2503          	lw	a0,0(s4)
    800053ee:	d41ff0ef          	jal	ra,8000512e <free_desc>
      for(int j = 0; j < i; j++)
    800053f2:	2d85                	addiw	s11,s11,1
    800053f4:	0a11                	addi	s4,s4,4
    800053f6:	ffb91ae3          	bne	s2,s11,800053ea <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800053fa:	85e6                	mv	a1,s9
    800053fc:	0001b517          	auipc	a0,0x1b
    80005400:	71c50513          	addi	a0,a0,1820 # 80020b18 <disk+0x18>
    80005404:	9f5fc0ef          	jal	ra,80001df8 <sleep>
  for(int i = 0; i < 3; i++){
    80005408:	f8040a13          	addi	s4,s0,-128
{
    8000540c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000540e:	894e                	mv	s2,s3
    80005410:	bf5d                	j	800053c6 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005412:	f8042583          	lw	a1,-128(s0)
    80005416:	00a58793          	addi	a5,a1,10
    8000541a:	0792                	slli	a5,a5,0x4

  if(write)
    8000541c:	0001b617          	auipc	a2,0x1b
    80005420:	6e460613          	addi	a2,a2,1764 # 80020b00 <disk>
    80005424:	00f60733          	add	a4,a2,a5
    80005428:	018036b3          	snez	a3,s8
    8000542c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000542e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005432:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005436:	f6078693          	addi	a3,a5,-160
    8000543a:	6218                	ld	a4,0(a2)
    8000543c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000543e:	00878513          	addi	a0,a5,8
    80005442:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005444:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005446:	6208                	ld	a0,0(a2)
    80005448:	96aa                	add	a3,a3,a0
    8000544a:	4741                	li	a4,16
    8000544c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000544e:	4705                	li	a4,1
    80005450:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005454:	f8442703          	lw	a4,-124(s0)
    80005458:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000545c:	0712                	slli	a4,a4,0x4
    8000545e:	953a                	add	a0,a0,a4
    80005460:	058a8693          	addi	a3,s5,88
    80005464:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005466:	6208                	ld	a0,0(a2)
    80005468:	972a                	add	a4,a4,a0
    8000546a:	40000693          	li	a3,1024
    8000546e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005470:	001c3c13          	seqz	s8,s8
    80005474:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005476:	001c6c13          	ori	s8,s8,1
    8000547a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000547e:	f8842603          	lw	a2,-120(s0)
    80005482:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005486:	0001b697          	auipc	a3,0x1b
    8000548a:	67a68693          	addi	a3,a3,1658 # 80020b00 <disk>
    8000548e:	00258713          	addi	a4,a1,2
    80005492:	0712                	slli	a4,a4,0x4
    80005494:	9736                	add	a4,a4,a3
    80005496:	587d                	li	a6,-1
    80005498:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000549c:	0612                	slli	a2,a2,0x4
    8000549e:	9532                	add	a0,a0,a2
    800054a0:	f9078793          	addi	a5,a5,-112
    800054a4:	97b6                	add	a5,a5,a3
    800054a6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800054a8:	629c                	ld	a5,0(a3)
    800054aa:	97b2                	add	a5,a5,a2
    800054ac:	4605                	li	a2,1
    800054ae:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800054b0:	4509                	li	a0,2
    800054b2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800054b6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800054ba:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800054be:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800054c2:	6698                	ld	a4,8(a3)
    800054c4:	00275783          	lhu	a5,2(a4)
    800054c8:	8b9d                	andi	a5,a5,7
    800054ca:	0786                	slli	a5,a5,0x1
    800054cc:	97ba                	add	a5,a5,a4
    800054ce:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800054d2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800054d6:	6698                	ld	a4,8(a3)
    800054d8:	00275783          	lhu	a5,2(a4)
    800054dc:	2785                	addiw	a5,a5,1
    800054de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800054e2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800054e6:	100017b7          	lui	a5,0x10001
    800054ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800054ee:	004aa783          	lw	a5,4(s5)
    800054f2:	00c79f63          	bne	a5,a2,80005510 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800054f6:	0001b917          	auipc	s2,0x1b
    800054fa:	73290913          	addi	s2,s2,1842 # 80020c28 <disk+0x128>
  while(b->disk == 1) {
    800054fe:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005500:	85ca                	mv	a1,s2
    80005502:	8556                	mv	a0,s5
    80005504:	8f5fc0ef          	jal	ra,80001df8 <sleep>
  while(b->disk == 1) {
    80005508:	004aa783          	lw	a5,4(s5)
    8000550c:	fe978ae3          	beq	a5,s1,80005500 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005510:	f8042903          	lw	s2,-128(s0)
    80005514:	00290793          	addi	a5,s2,2
    80005518:	00479713          	slli	a4,a5,0x4
    8000551c:	0001b797          	auipc	a5,0x1b
    80005520:	5e478793          	addi	a5,a5,1508 # 80020b00 <disk>
    80005524:	97ba                	add	a5,a5,a4
    80005526:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000552a:	0001b997          	auipc	s3,0x1b
    8000552e:	5d698993          	addi	s3,s3,1494 # 80020b00 <disk>
    80005532:	00491713          	slli	a4,s2,0x4
    80005536:	0009b783          	ld	a5,0(s3)
    8000553a:	97ba                	add	a5,a5,a4
    8000553c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005540:	854a                	mv	a0,s2
    80005542:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005546:	be9ff0ef          	jal	ra,8000512e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000554a:	8885                	andi	s1,s1,1
    8000554c:	f0fd                	bnez	s1,80005532 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000554e:	0001b517          	auipc	a0,0x1b
    80005552:	6da50513          	addi	a0,a0,1754 # 80020c28 <disk+0x128>
    80005556:	edcfb0ef          	jal	ra,80000c32 <release>
}
    8000555a:	70e6                	ld	ra,120(sp)
    8000555c:	7446                	ld	s0,112(sp)
    8000555e:	74a6                	ld	s1,104(sp)
    80005560:	7906                	ld	s2,96(sp)
    80005562:	69e6                	ld	s3,88(sp)
    80005564:	6a46                	ld	s4,80(sp)
    80005566:	6aa6                	ld	s5,72(sp)
    80005568:	6b06                	ld	s6,64(sp)
    8000556a:	7be2                	ld	s7,56(sp)
    8000556c:	7c42                	ld	s8,48(sp)
    8000556e:	7ca2                	ld	s9,40(sp)
    80005570:	7d02                	ld	s10,32(sp)
    80005572:	6de2                	ld	s11,24(sp)
    80005574:	6109                	addi	sp,sp,128
    80005576:	8082                	ret

0000000080005578 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005578:	1101                	addi	sp,sp,-32
    8000557a:	ec06                	sd	ra,24(sp)
    8000557c:	e822                	sd	s0,16(sp)
    8000557e:	e426                	sd	s1,8(sp)
    80005580:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005582:	0001b497          	auipc	s1,0x1b
    80005586:	57e48493          	addi	s1,s1,1406 # 80020b00 <disk>
    8000558a:	0001b517          	auipc	a0,0x1b
    8000558e:	69e50513          	addi	a0,a0,1694 # 80020c28 <disk+0x128>
    80005592:	e08fb0ef          	jal	ra,80000b9a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005596:	10001737          	lui	a4,0x10001
    8000559a:	533c                	lw	a5,96(a4)
    8000559c:	8b8d                	andi	a5,a5,3
    8000559e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800055a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800055a4:	689c                	ld	a5,16(s1)
    800055a6:	0204d703          	lhu	a4,32(s1)
    800055aa:	0027d783          	lhu	a5,2(a5)
    800055ae:	04f70663          	beq	a4,a5,800055fa <virtio_disk_intr+0x82>
    __sync_synchronize();
    800055b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800055b6:	6898                	ld	a4,16(s1)
    800055b8:	0204d783          	lhu	a5,32(s1)
    800055bc:	8b9d                	andi	a5,a5,7
    800055be:	078e                	slli	a5,a5,0x3
    800055c0:	97ba                	add	a5,a5,a4
    800055c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800055c4:	00278713          	addi	a4,a5,2
    800055c8:	0712                	slli	a4,a4,0x4
    800055ca:	9726                	add	a4,a4,s1
    800055cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800055d0:	e321                	bnez	a4,80005610 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800055d2:	0789                	addi	a5,a5,2
    800055d4:	0792                	slli	a5,a5,0x4
    800055d6:	97a6                	add	a5,a5,s1
    800055d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800055da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800055de:	867fc0ef          	jal	ra,80001e44 <wakeup>

    disk.used_idx += 1;
    800055e2:	0204d783          	lhu	a5,32(s1)
    800055e6:	2785                	addiw	a5,a5,1
    800055e8:	17c2                	slli	a5,a5,0x30
    800055ea:	93c1                	srli	a5,a5,0x30
    800055ec:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800055f0:	6898                	ld	a4,16(s1)
    800055f2:	00275703          	lhu	a4,2(a4)
    800055f6:	faf71ee3          	bne	a4,a5,800055b2 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800055fa:	0001b517          	auipc	a0,0x1b
    800055fe:	62e50513          	addi	a0,a0,1582 # 80020c28 <disk+0x128>
    80005602:	e30fb0ef          	jal	ra,80000c32 <release>
}
    80005606:	60e2                	ld	ra,24(sp)
    80005608:	6442                	ld	s0,16(sp)
    8000560a:	64a2                	ld	s1,8(sp)
    8000560c:	6105                	addi	sp,sp,32
    8000560e:	8082                	ret
      panic("virtio_disk_intr status");
    80005610:	00002517          	auipc	a0,0x2
    80005614:	25850513          	addi	a0,a0,600 # 80007868 <syscalls+0x3d8>
    80005618:	93efb0ef          	jal	ra,80000756 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...


_testSysCall:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 18             	sub    $0x18,%esp
    int a = 1;
  11:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    int b = 1;
  18:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    int c = 1;
    dump_physmem(&a, &b, c);
  1f:	6a 01                	push   $0x1
  21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  24:	50                   	push   %eax
  25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  28:	50                   	push   %eax
  29:	e8 32 02 00 00       	call   260 <dump_physmem>
    exit();
  2e:	e8 8d 01 00 00       	call   1c0 <exit>

00000033 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  33:	55                   	push   %ebp
  34:	89 e5                	mov    %esp,%ebp
  36:	53                   	push   %ebx
  37:	8b 45 08             	mov    0x8(%ebp),%eax
  3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3d:	89 c2                	mov    %eax,%edx
  3f:	0f b6 19             	movzbl (%ecx),%ebx
  42:	88 1a                	mov    %bl,(%edx)
  44:	8d 52 01             	lea    0x1(%edx),%edx
  47:	8d 49 01             	lea    0x1(%ecx),%ecx
  4a:	84 db                	test   %bl,%bl
  4c:	75 f1                	jne    3f <strcpy+0xc>
    ;
  return os;
}
  4e:	5b                   	pop    %ebx
  4f:	5d                   	pop    %ebp
  50:	c3                   	ret    

00000051 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  57:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  5a:	eb 06                	jmp    62 <strcmp+0x11>
    p++, q++;
  5c:	83 c1 01             	add    $0x1,%ecx
  5f:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  62:	0f b6 01             	movzbl (%ecx),%eax
  65:	84 c0                	test   %al,%al
  67:	74 04                	je     6d <strcmp+0x1c>
  69:	3a 02                	cmp    (%edx),%al
  6b:	74 ef                	je     5c <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  6d:	0f b6 c0             	movzbl %al,%eax
  70:	0f b6 12             	movzbl (%edx),%edx
  73:	29 d0                	sub    %edx,%eax
}
  75:	5d                   	pop    %ebp
  76:	c3                   	ret    

00000077 <strlen>:

uint
strlen(const char *s)
{
  77:	55                   	push   %ebp
  78:	89 e5                	mov    %esp,%ebp
  7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  7d:	ba 00 00 00 00       	mov    $0x0,%edx
  82:	eb 03                	jmp    87 <strlen+0x10>
  84:	83 c2 01             	add    $0x1,%edx
  87:	89 d0                	mov    %edx,%eax
  89:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8d:	75 f5                	jne    84 <strlen+0xd>
    ;
  return n;
}
  8f:	5d                   	pop    %ebp
  90:	c3                   	ret    

00000091 <memset>:

void*
memset(void *dst, int c, uint n)
{
  91:	55                   	push   %ebp
  92:	89 e5                	mov    %esp,%ebp
  94:	57                   	push   %edi
  95:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  98:	89 d7                	mov    %edx,%edi
  9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	fc                   	cld    
  a1:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  a3:	89 d0                	mov    %edx,%eax
  a5:	5f                   	pop    %edi
  a6:	5d                   	pop    %ebp
  a7:	c3                   	ret    

000000a8 <strchr>:

char*
strchr(const char *s, char c)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  b2:	0f b6 10             	movzbl (%eax),%edx
  b5:	84 d2                	test   %dl,%dl
  b7:	74 09                	je     c2 <strchr+0x1a>
    if(*s == c)
  b9:	38 ca                	cmp    %cl,%dl
  bb:	74 0a                	je     c7 <strchr+0x1f>
  for(; *s; s++)
  bd:	83 c0 01             	add    $0x1,%eax
  c0:	eb f0                	jmp    b2 <strchr+0xa>
      return (char*)s;
  return 0;
  c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c7:	5d                   	pop    %ebp
  c8:	c3                   	ret    

000000c9 <gets>:

char*
gets(char *buf, int max)
{
  c9:	55                   	push   %ebp
  ca:	89 e5                	mov    %esp,%ebp
  cc:	57                   	push   %edi
  cd:	56                   	push   %esi
  ce:	53                   	push   %ebx
  cf:	83 ec 1c             	sub    $0x1c,%esp
  d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  da:	8d 73 01             	lea    0x1(%ebx),%esi
  dd:	3b 75 0c             	cmp    0xc(%ebp),%esi
  e0:	7d 2e                	jge    110 <gets+0x47>
    cc = read(0, &c, 1);
  e2:	83 ec 04             	sub    $0x4,%esp
  e5:	6a 01                	push   $0x1
  e7:	8d 45 e7             	lea    -0x19(%ebp),%eax
  ea:	50                   	push   %eax
  eb:	6a 00                	push   $0x0
  ed:	e8 e6 00 00 00       	call   1d8 <read>
    if(cc < 1)
  f2:	83 c4 10             	add    $0x10,%esp
  f5:	85 c0                	test   %eax,%eax
  f7:	7e 17                	jle    110 <gets+0x47>
      break;
    buf[i++] = c;
  f9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  fd:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 100:	3c 0a                	cmp    $0xa,%al
 102:	0f 94 c2             	sete   %dl
 105:	3c 0d                	cmp    $0xd,%al
 107:	0f 94 c0             	sete   %al
    buf[i++] = c;
 10a:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 10c:	08 c2                	or     %al,%dl
 10e:	74 ca                	je     da <gets+0x11>
      break;
  }
  buf[i] = '\0';
 110:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 114:	89 f8                	mov    %edi,%eax
 116:	8d 65 f4             	lea    -0xc(%ebp),%esp
 119:	5b                   	pop    %ebx
 11a:	5e                   	pop    %esi
 11b:	5f                   	pop    %edi
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    

0000011e <stat>:

int
stat(const char *n, struct stat *st)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	56                   	push   %esi
 122:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 123:	83 ec 08             	sub    $0x8,%esp
 126:	6a 00                	push   $0x0
 128:	ff 75 08             	pushl  0x8(%ebp)
 12b:	e8 d0 00 00 00       	call   200 <open>
  if(fd < 0)
 130:	83 c4 10             	add    $0x10,%esp
 133:	85 c0                	test   %eax,%eax
 135:	78 24                	js     15b <stat+0x3d>
 137:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 139:	83 ec 08             	sub    $0x8,%esp
 13c:	ff 75 0c             	pushl  0xc(%ebp)
 13f:	50                   	push   %eax
 140:	e8 d3 00 00 00       	call   218 <fstat>
 145:	89 c6                	mov    %eax,%esi
  close(fd);
 147:	89 1c 24             	mov    %ebx,(%esp)
 14a:	e8 99 00 00 00       	call   1e8 <close>
  return r;
 14f:	83 c4 10             	add    $0x10,%esp
}
 152:	89 f0                	mov    %esi,%eax
 154:	8d 65 f8             	lea    -0x8(%ebp),%esp
 157:	5b                   	pop    %ebx
 158:	5e                   	pop    %esi
 159:	5d                   	pop    %ebp
 15a:	c3                   	ret    
    return -1;
 15b:	be ff ff ff ff       	mov    $0xffffffff,%esi
 160:	eb f0                	jmp    152 <stat+0x34>

00000162 <atoi>:

int
atoi(const char *s)
{
 162:	55                   	push   %ebp
 163:	89 e5                	mov    %esp,%ebp
 165:	53                   	push   %ebx
 166:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 169:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 16e:	eb 10                	jmp    180 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 170:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 173:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 176:	83 c1 01             	add    $0x1,%ecx
 179:	0f be d2             	movsbl %dl,%edx
 17c:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 180:	0f b6 11             	movzbl (%ecx),%edx
 183:	8d 5a d0             	lea    -0x30(%edx),%ebx
 186:	80 fb 09             	cmp    $0x9,%bl
 189:	76 e5                	jbe    170 <atoi+0xe>
  return n;
}
 18b:	5b                   	pop    %ebx
 18c:	5d                   	pop    %ebp
 18d:	c3                   	ret    

0000018e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 18e:	55                   	push   %ebp
 18f:	89 e5                	mov    %esp,%ebp
 191:	56                   	push   %esi
 192:	53                   	push   %ebx
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 199:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 19c:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 19e:	eb 0d                	jmp    1ad <memmove+0x1f>
    *dst++ = *src++;
 1a0:	0f b6 13             	movzbl (%ebx),%edx
 1a3:	88 11                	mov    %dl,(%ecx)
 1a5:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1a8:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1ab:	89 f2                	mov    %esi,%edx
 1ad:	8d 72 ff             	lea    -0x1(%edx),%esi
 1b0:	85 d2                	test   %edx,%edx
 1b2:	7f ec                	jg     1a0 <memmove+0x12>
  return vdst;
}
 1b4:	5b                   	pop    %ebx
 1b5:	5e                   	pop    %esi
 1b6:	5d                   	pop    %ebp
 1b7:	c3                   	ret    

000001b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1b8:	b8 01 00 00 00       	mov    $0x1,%eax
 1bd:	cd 40                	int    $0x40
 1bf:	c3                   	ret    

000001c0 <exit>:
SYSCALL(exit)
 1c0:	b8 02 00 00 00       	mov    $0x2,%eax
 1c5:	cd 40                	int    $0x40
 1c7:	c3                   	ret    

000001c8 <wait>:
SYSCALL(wait)
 1c8:	b8 03 00 00 00       	mov    $0x3,%eax
 1cd:	cd 40                	int    $0x40
 1cf:	c3                   	ret    

000001d0 <pipe>:
SYSCALL(pipe)
 1d0:	b8 04 00 00 00       	mov    $0x4,%eax
 1d5:	cd 40                	int    $0x40
 1d7:	c3                   	ret    

000001d8 <read>:
SYSCALL(read)
 1d8:	b8 05 00 00 00       	mov    $0x5,%eax
 1dd:	cd 40                	int    $0x40
 1df:	c3                   	ret    

000001e0 <write>:
SYSCALL(write)
 1e0:	b8 10 00 00 00       	mov    $0x10,%eax
 1e5:	cd 40                	int    $0x40
 1e7:	c3                   	ret    

000001e8 <close>:
SYSCALL(close)
 1e8:	b8 15 00 00 00       	mov    $0x15,%eax
 1ed:	cd 40                	int    $0x40
 1ef:	c3                   	ret    

000001f0 <kill>:
SYSCALL(kill)
 1f0:	b8 06 00 00 00       	mov    $0x6,%eax
 1f5:	cd 40                	int    $0x40
 1f7:	c3                   	ret    

000001f8 <exec>:
SYSCALL(exec)
 1f8:	b8 07 00 00 00       	mov    $0x7,%eax
 1fd:	cd 40                	int    $0x40
 1ff:	c3                   	ret    

00000200 <open>:
SYSCALL(open)
 200:	b8 0f 00 00 00       	mov    $0xf,%eax
 205:	cd 40                	int    $0x40
 207:	c3                   	ret    

00000208 <mknod>:
SYSCALL(mknod)
 208:	b8 11 00 00 00       	mov    $0x11,%eax
 20d:	cd 40                	int    $0x40
 20f:	c3                   	ret    

00000210 <unlink>:
SYSCALL(unlink)
 210:	b8 12 00 00 00       	mov    $0x12,%eax
 215:	cd 40                	int    $0x40
 217:	c3                   	ret    

00000218 <fstat>:
SYSCALL(fstat)
 218:	b8 08 00 00 00       	mov    $0x8,%eax
 21d:	cd 40                	int    $0x40
 21f:	c3                   	ret    

00000220 <link>:
SYSCALL(link)
 220:	b8 13 00 00 00       	mov    $0x13,%eax
 225:	cd 40                	int    $0x40
 227:	c3                   	ret    

00000228 <mkdir>:
SYSCALL(mkdir)
 228:	b8 14 00 00 00       	mov    $0x14,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <chdir>:
SYSCALL(chdir)
 230:	b8 09 00 00 00       	mov    $0x9,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <dup>:
SYSCALL(dup)
 238:	b8 0a 00 00 00       	mov    $0xa,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <getpid>:
SYSCALL(getpid)
 240:	b8 0b 00 00 00       	mov    $0xb,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <sbrk>:
SYSCALL(sbrk)
 248:	b8 0c 00 00 00       	mov    $0xc,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <sleep>:
SYSCALL(sleep)
 250:	b8 0d 00 00 00       	mov    $0xd,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <uptime>:
SYSCALL(uptime)
 258:	b8 0e 00 00 00       	mov    $0xe,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <dump_physmem>:
SYSCALL(dump_physmem)
 260:	b8 16 00 00 00       	mov    $0x16,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 268:	55                   	push   %ebp
 269:	89 e5                	mov    %esp,%ebp
 26b:	83 ec 1c             	sub    $0x1c,%esp
 26e:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 271:	6a 01                	push   $0x1
 273:	8d 55 f4             	lea    -0xc(%ebp),%edx
 276:	52                   	push   %edx
 277:	50                   	push   %eax
 278:	e8 63 ff ff ff       	call   1e0 <write>
}
 27d:	83 c4 10             	add    $0x10,%esp
 280:	c9                   	leave  
 281:	c3                   	ret    

00000282 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	57                   	push   %edi
 286:	56                   	push   %esi
 287:	53                   	push   %ebx
 288:	83 ec 2c             	sub    $0x2c,%esp
 28b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 28d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 291:	0f 95 c3             	setne  %bl
 294:	89 d0                	mov    %edx,%eax
 296:	c1 e8 1f             	shr    $0x1f,%eax
 299:	84 c3                	test   %al,%bl
 29b:	74 10                	je     2ad <printint+0x2b>
    neg = 1;
    x = -xx;
 29d:	f7 da                	neg    %edx
    neg = 1;
 29f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2a6:	be 00 00 00 00       	mov    $0x0,%esi
 2ab:	eb 0b                	jmp    2b8 <printint+0x36>
  neg = 0;
 2ad:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2b4:	eb f0                	jmp    2a6 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2b6:	89 c6                	mov    %eax,%esi
 2b8:	89 d0                	mov    %edx,%eax
 2ba:	ba 00 00 00 00       	mov    $0x0,%edx
 2bf:	f7 f1                	div    %ecx
 2c1:	89 c3                	mov    %eax,%ebx
 2c3:	8d 46 01             	lea    0x1(%esi),%eax
 2c6:	0f b6 92 c4 05 00 00 	movzbl 0x5c4(%edx),%edx
 2cd:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2d1:	89 da                	mov    %ebx,%edx
 2d3:	85 db                	test   %ebx,%ebx
 2d5:	75 df                	jne    2b6 <printint+0x34>
 2d7:	89 c3                	mov    %eax,%ebx
  if(neg)
 2d9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2dd:	74 16                	je     2f5 <printint+0x73>
    buf[i++] = '-';
 2df:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2e4:	8d 5e 02             	lea    0x2(%esi),%ebx
 2e7:	eb 0c                	jmp    2f5 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2e9:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 2ee:	89 f8                	mov    %edi,%eax
 2f0:	e8 73 ff ff ff       	call   268 <putc>
  while(--i >= 0)
 2f5:	83 eb 01             	sub    $0x1,%ebx
 2f8:	79 ef                	jns    2e9 <printint+0x67>
}
 2fa:	83 c4 2c             	add    $0x2c,%esp
 2fd:	5b                   	pop    %ebx
 2fe:	5e                   	pop    %esi
 2ff:	5f                   	pop    %edi
 300:	5d                   	pop    %ebp
 301:	c3                   	ret    

00000302 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	57                   	push   %edi
 306:	56                   	push   %esi
 307:	53                   	push   %ebx
 308:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 30b:	8d 45 10             	lea    0x10(%ebp),%eax
 30e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 311:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 316:	bb 00 00 00 00       	mov    $0x0,%ebx
 31b:	eb 14                	jmp    331 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 31d:	89 fa                	mov    %edi,%edx
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	e8 41 ff ff ff       	call   268 <putc>
 327:	eb 05                	jmp    32e <printf+0x2c>
      }
    } else if(state == '%'){
 329:	83 fe 25             	cmp    $0x25,%esi
 32c:	74 25                	je     353 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 32e:	83 c3 01             	add    $0x1,%ebx
 331:	8b 45 0c             	mov    0xc(%ebp),%eax
 334:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 338:	84 c0                	test   %al,%al
 33a:	0f 84 23 01 00 00    	je     463 <printf+0x161>
    c = fmt[i] & 0xff;
 340:	0f be f8             	movsbl %al,%edi
 343:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 346:	85 f6                	test   %esi,%esi
 348:	75 df                	jne    329 <printf+0x27>
      if(c == '%'){
 34a:	83 f8 25             	cmp    $0x25,%eax
 34d:	75 ce                	jne    31d <printf+0x1b>
        state = '%';
 34f:	89 c6                	mov    %eax,%esi
 351:	eb db                	jmp    32e <printf+0x2c>
      if(c == 'd'){
 353:	83 f8 64             	cmp    $0x64,%eax
 356:	74 49                	je     3a1 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 358:	83 f8 78             	cmp    $0x78,%eax
 35b:	0f 94 c1             	sete   %cl
 35e:	83 f8 70             	cmp    $0x70,%eax
 361:	0f 94 c2             	sete   %dl
 364:	08 d1                	or     %dl,%cl
 366:	75 63                	jne    3cb <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 368:	83 f8 73             	cmp    $0x73,%eax
 36b:	0f 84 84 00 00 00    	je     3f5 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 371:	83 f8 63             	cmp    $0x63,%eax
 374:	0f 84 b7 00 00 00    	je     431 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 37a:	83 f8 25             	cmp    $0x25,%eax
 37d:	0f 84 cc 00 00 00    	je     44f <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 383:	ba 25 00 00 00       	mov    $0x25,%edx
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	e8 d8 fe ff ff       	call   268 <putc>
        putc(fd, c);
 390:	89 fa                	mov    %edi,%edx
 392:	8b 45 08             	mov    0x8(%ebp),%eax
 395:	e8 ce fe ff ff       	call   268 <putc>
      }
      state = 0;
 39a:	be 00 00 00 00       	mov    $0x0,%esi
 39f:	eb 8d                	jmp    32e <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3a4:	8b 17                	mov    (%edi),%edx
 3a6:	83 ec 0c             	sub    $0xc,%esp
 3a9:	6a 01                	push   $0x1
 3ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	e8 ca fe ff ff       	call   282 <printint>
        ap++;
 3b8:	83 c7 04             	add    $0x4,%edi
 3bb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3be:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3c1:	be 00 00 00 00       	mov    $0x0,%esi
 3c6:	e9 63 ff ff ff       	jmp    32e <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3ce:	8b 17                	mov    (%edi),%edx
 3d0:	83 ec 0c             	sub    $0xc,%esp
 3d3:	6a 00                	push   $0x0
 3d5:	b9 10 00 00 00       	mov    $0x10,%ecx
 3da:	8b 45 08             	mov    0x8(%ebp),%eax
 3dd:	e8 a0 fe ff ff       	call   282 <printint>
        ap++;
 3e2:	83 c7 04             	add    $0x4,%edi
 3e5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3e8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3eb:	be 00 00 00 00       	mov    $0x0,%esi
 3f0:	e9 39 ff ff ff       	jmp    32e <printf+0x2c>
        s = (char*)*ap;
 3f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3f8:	8b 30                	mov    (%eax),%esi
        ap++;
 3fa:	83 c0 04             	add    $0x4,%eax
 3fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 400:	85 f6                	test   %esi,%esi
 402:	75 28                	jne    42c <printf+0x12a>
          s = "(null)";
 404:	be bc 05 00 00       	mov    $0x5bc,%esi
 409:	8b 7d 08             	mov    0x8(%ebp),%edi
 40c:	eb 0d                	jmp    41b <printf+0x119>
          putc(fd, *s);
 40e:	0f be d2             	movsbl %dl,%edx
 411:	89 f8                	mov    %edi,%eax
 413:	e8 50 fe ff ff       	call   268 <putc>
          s++;
 418:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 41b:	0f b6 16             	movzbl (%esi),%edx
 41e:	84 d2                	test   %dl,%dl
 420:	75 ec                	jne    40e <printf+0x10c>
      state = 0;
 422:	be 00 00 00 00       	mov    $0x0,%esi
 427:	e9 02 ff ff ff       	jmp    32e <printf+0x2c>
 42c:	8b 7d 08             	mov    0x8(%ebp),%edi
 42f:	eb ea                	jmp    41b <printf+0x119>
        putc(fd, *ap);
 431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 434:	0f be 17             	movsbl (%edi),%edx
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	e8 29 fe ff ff       	call   268 <putc>
        ap++;
 43f:	83 c7 04             	add    $0x4,%edi
 442:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 445:	be 00 00 00 00       	mov    $0x0,%esi
 44a:	e9 df fe ff ff       	jmp    32e <printf+0x2c>
        putc(fd, c);
 44f:	89 fa                	mov    %edi,%edx
 451:	8b 45 08             	mov    0x8(%ebp),%eax
 454:	e8 0f fe ff ff       	call   268 <putc>
      state = 0;
 459:	be 00 00 00 00       	mov    $0x0,%esi
 45e:	e9 cb fe ff ff       	jmp    32e <printf+0x2c>
    }
  }
}
 463:	8d 65 f4             	lea    -0xc(%ebp),%esp
 466:	5b                   	pop    %ebx
 467:	5e                   	pop    %esi
 468:	5f                   	pop    %edi
 469:	5d                   	pop    %ebp
 46a:	c3                   	ret    

0000046b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 46b:	55                   	push   %ebp
 46c:	89 e5                	mov    %esp,%ebp
 46e:	57                   	push   %edi
 46f:	56                   	push   %esi
 470:	53                   	push   %ebx
 471:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 474:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 477:	a1 5c 08 00 00       	mov    0x85c,%eax
 47c:	eb 02                	jmp    480 <free+0x15>
 47e:	89 d0                	mov    %edx,%eax
 480:	39 c8                	cmp    %ecx,%eax
 482:	73 04                	jae    488 <free+0x1d>
 484:	39 08                	cmp    %ecx,(%eax)
 486:	77 12                	ja     49a <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 488:	8b 10                	mov    (%eax),%edx
 48a:	39 c2                	cmp    %eax,%edx
 48c:	77 f0                	ja     47e <free+0x13>
 48e:	39 c8                	cmp    %ecx,%eax
 490:	72 08                	jb     49a <free+0x2f>
 492:	39 ca                	cmp    %ecx,%edx
 494:	77 04                	ja     49a <free+0x2f>
 496:	89 d0                	mov    %edx,%eax
 498:	eb e6                	jmp    480 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 49a:	8b 73 fc             	mov    -0x4(%ebx),%esi
 49d:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4a0:	8b 10                	mov    (%eax),%edx
 4a2:	39 d7                	cmp    %edx,%edi
 4a4:	74 19                	je     4bf <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4a6:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4a9:	8b 50 04             	mov    0x4(%eax),%edx
 4ac:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4af:	39 ce                	cmp    %ecx,%esi
 4b1:	74 1b                	je     4ce <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4b3:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4b5:	a3 5c 08 00 00       	mov    %eax,0x85c
}
 4ba:	5b                   	pop    %ebx
 4bb:	5e                   	pop    %esi
 4bc:	5f                   	pop    %edi
 4bd:	5d                   	pop    %ebp
 4be:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4bf:	03 72 04             	add    0x4(%edx),%esi
 4c2:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4c5:	8b 10                	mov    (%eax),%edx
 4c7:	8b 12                	mov    (%edx),%edx
 4c9:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4cc:	eb db                	jmp    4a9 <free+0x3e>
    p->s.size += bp->s.size;
 4ce:	03 53 fc             	add    -0x4(%ebx),%edx
 4d1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4d4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4d7:	89 10                	mov    %edx,(%eax)
 4d9:	eb da                	jmp    4b5 <free+0x4a>

000004db <morecore>:

static Header*
morecore(uint nu)
{
 4db:	55                   	push   %ebp
 4dc:	89 e5                	mov    %esp,%ebp
 4de:	53                   	push   %ebx
 4df:	83 ec 04             	sub    $0x4,%esp
 4e2:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4e4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4e9:	77 05                	ja     4f0 <morecore+0x15>
    nu = 4096;
 4eb:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 4f0:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 4f7:	83 ec 0c             	sub    $0xc,%esp
 4fa:	50                   	push   %eax
 4fb:	e8 48 fd ff ff       	call   248 <sbrk>
  if(p == (char*)-1)
 500:	83 c4 10             	add    $0x10,%esp
 503:	83 f8 ff             	cmp    $0xffffffff,%eax
 506:	74 1c                	je     524 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 508:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 50b:	83 c0 08             	add    $0x8,%eax
 50e:	83 ec 0c             	sub    $0xc,%esp
 511:	50                   	push   %eax
 512:	e8 54 ff ff ff       	call   46b <free>
  return freep;
 517:	a1 5c 08 00 00       	mov    0x85c,%eax
 51c:	83 c4 10             	add    $0x10,%esp
}
 51f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 522:	c9                   	leave  
 523:	c3                   	ret    
    return 0;
 524:	b8 00 00 00 00       	mov    $0x0,%eax
 529:	eb f4                	jmp    51f <morecore+0x44>

0000052b <malloc>:

void*
malloc(uint nbytes)
{
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	53                   	push   %ebx
 52f:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 532:	8b 45 08             	mov    0x8(%ebp),%eax
 535:	8d 58 07             	lea    0x7(%eax),%ebx
 538:	c1 eb 03             	shr    $0x3,%ebx
 53b:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 53e:	8b 0d 5c 08 00 00    	mov    0x85c,%ecx
 544:	85 c9                	test   %ecx,%ecx
 546:	74 04                	je     54c <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 548:	8b 01                	mov    (%ecx),%eax
 54a:	eb 4d                	jmp    599 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 54c:	c7 05 5c 08 00 00 60 	movl   $0x860,0x85c
 553:	08 00 00 
 556:	c7 05 60 08 00 00 60 	movl   $0x860,0x860
 55d:	08 00 00 
    base.s.size = 0;
 560:	c7 05 64 08 00 00 00 	movl   $0x0,0x864
 567:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 56a:	b9 60 08 00 00       	mov    $0x860,%ecx
 56f:	eb d7                	jmp    548 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 571:	39 da                	cmp    %ebx,%edx
 573:	74 1a                	je     58f <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 575:	29 da                	sub    %ebx,%edx
 577:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 57a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 57d:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 580:	89 0d 5c 08 00 00    	mov    %ecx,0x85c
      return (void*)(p + 1);
 586:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 589:	83 c4 04             	add    $0x4,%esp
 58c:	5b                   	pop    %ebx
 58d:	5d                   	pop    %ebp
 58e:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 58f:	8b 10                	mov    (%eax),%edx
 591:	89 11                	mov    %edx,(%ecx)
 593:	eb eb                	jmp    580 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 595:	89 c1                	mov    %eax,%ecx
 597:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 599:	8b 50 04             	mov    0x4(%eax),%edx
 59c:	39 da                	cmp    %ebx,%edx
 59e:	73 d1                	jae    571 <malloc+0x46>
    if(p == freep)
 5a0:	39 05 5c 08 00 00    	cmp    %eax,0x85c
 5a6:	75 ed                	jne    595 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5a8:	89 d8                	mov    %ebx,%eax
 5aa:	e8 2c ff ff ff       	call   4db <morecore>
 5af:	85 c0                	test   %eax,%eax
 5b1:	75 e2                	jne    595 <malloc+0x6a>
        return 0;
 5b3:	b8 00 00 00 00       	mov    $0x0,%eax
 5b8:	eb cf                	jmp    589 <malloc+0x5e>

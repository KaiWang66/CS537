
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 0c             	sub    $0xc,%esp
  char* a = "a";
  char* b = "b";
  symlink(a,b);
  11:	68 ac 05 00 00       	push   $0x5ac
  16:	68 ae 05 00 00       	push   $0x5ae
  1b:	e8 32 02 00 00       	call   252 <symlink>
  
  exit();
  20:	e8 8d 01 00 00       	call   1b2 <exit>

00000025 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  25:	55                   	push   %ebp
  26:	89 e5                	mov    %esp,%ebp
  28:	53                   	push   %ebx
  29:	8b 45 08             	mov    0x8(%ebp),%eax
  2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  2f:	89 c2                	mov    %eax,%edx
  31:	0f b6 19             	movzbl (%ecx),%ebx
  34:	88 1a                	mov    %bl,(%edx)
  36:	8d 52 01             	lea    0x1(%edx),%edx
  39:	8d 49 01             	lea    0x1(%ecx),%ecx
  3c:	84 db                	test   %bl,%bl
  3e:	75 f1                	jne    31 <strcpy+0xc>
    ;
  return os;
}
  40:	5b                   	pop    %ebx
  41:	5d                   	pop    %ebp
  42:	c3                   	ret    

00000043 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  43:	55                   	push   %ebp
  44:	89 e5                	mov    %esp,%ebp
  46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  49:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  4c:	eb 06                	jmp    54 <strcmp+0x11>
    p++, q++;
  4e:	83 c1 01             	add    $0x1,%ecx
  51:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  54:	0f b6 01             	movzbl (%ecx),%eax
  57:	84 c0                	test   %al,%al
  59:	74 04                	je     5f <strcmp+0x1c>
  5b:	3a 02                	cmp    (%edx),%al
  5d:	74 ef                	je     4e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  5f:	0f b6 c0             	movzbl %al,%eax
  62:	0f b6 12             	movzbl (%edx),%edx
  65:	29 d0                	sub    %edx,%eax
}
  67:	5d                   	pop    %ebp
  68:	c3                   	ret    

00000069 <strlen>:

uint
strlen(const char *s)
{
  69:	55                   	push   %ebp
  6a:	89 e5                	mov    %esp,%ebp
  6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  6f:	ba 00 00 00 00       	mov    $0x0,%edx
  74:	eb 03                	jmp    79 <strlen+0x10>
  76:	83 c2 01             	add    $0x1,%edx
  79:	89 d0                	mov    %edx,%eax
  7b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  7f:	75 f5                	jne    76 <strlen+0xd>
    ;
  return n;
}
  81:	5d                   	pop    %ebp
  82:	c3                   	ret    

00000083 <memset>:

void*
memset(void *dst, int c, uint n)
{
  83:	55                   	push   %ebp
  84:	89 e5                	mov    %esp,%ebp
  86:	57                   	push   %edi
  87:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  8a:	89 d7                	mov    %edx,%edi
  8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  92:	fc                   	cld    
  93:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  95:	89 d0                	mov    %edx,%eax
  97:	5f                   	pop    %edi
  98:	5d                   	pop    %ebp
  99:	c3                   	ret    

0000009a <strchr>:

char*
strchr(const char *s, char c)
{
  9a:	55                   	push   %ebp
  9b:	89 e5                	mov    %esp,%ebp
  9d:	8b 45 08             	mov    0x8(%ebp),%eax
  a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  a4:	0f b6 10             	movzbl (%eax),%edx
  a7:	84 d2                	test   %dl,%dl
  a9:	74 09                	je     b4 <strchr+0x1a>
    if(*s == c)
  ab:	38 ca                	cmp    %cl,%dl
  ad:	74 0a                	je     b9 <strchr+0x1f>
  for(; *s; s++)
  af:	83 c0 01             	add    $0x1,%eax
  b2:	eb f0                	jmp    a4 <strchr+0xa>
      return (char*)s;
  return 0;
  b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  b9:	5d                   	pop    %ebp
  ba:	c3                   	ret    

000000bb <gets>:

char*
gets(char *buf, int max)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  be:	57                   	push   %edi
  bf:	56                   	push   %esi
  c0:	53                   	push   %ebx
  c1:	83 ec 1c             	sub    $0x1c,%esp
  c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  cc:	8d 73 01             	lea    0x1(%ebx),%esi
  cf:	3b 75 0c             	cmp    0xc(%ebp),%esi
  d2:	7d 2e                	jge    102 <gets+0x47>
    cc = read(0, &c, 1);
  d4:	83 ec 04             	sub    $0x4,%esp
  d7:	6a 01                	push   $0x1
  d9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  dc:	50                   	push   %eax
  dd:	6a 00                	push   $0x0
  df:	e8 e6 00 00 00       	call   1ca <read>
    if(cc < 1)
  e4:	83 c4 10             	add    $0x10,%esp
  e7:	85 c0                	test   %eax,%eax
  e9:	7e 17                	jle    102 <gets+0x47>
      break;
    buf[i++] = c;
  eb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  ef:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  f2:	3c 0a                	cmp    $0xa,%al
  f4:	0f 94 c2             	sete   %dl
  f7:	3c 0d                	cmp    $0xd,%al
  f9:	0f 94 c0             	sete   %al
    buf[i++] = c;
  fc:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
  fe:	08 c2                	or     %al,%dl
 100:	74 ca                	je     cc <gets+0x11>
      break;
  }
  buf[i] = '\0';
 102:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 106:	89 f8                	mov    %edi,%eax
 108:	8d 65 f4             	lea    -0xc(%ebp),%esp
 10b:	5b                   	pop    %ebx
 10c:	5e                   	pop    %esi
 10d:	5f                   	pop    %edi
 10e:	5d                   	pop    %ebp
 10f:	c3                   	ret    

00000110 <stat>:

int
stat(const char *n, struct stat *st)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	56                   	push   %esi
 114:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 115:	83 ec 08             	sub    $0x8,%esp
 118:	6a 00                	push   $0x0
 11a:	ff 75 08             	pushl  0x8(%ebp)
 11d:	e8 d0 00 00 00       	call   1f2 <open>
  if(fd < 0)
 122:	83 c4 10             	add    $0x10,%esp
 125:	85 c0                	test   %eax,%eax
 127:	78 24                	js     14d <stat+0x3d>
 129:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 12b:	83 ec 08             	sub    $0x8,%esp
 12e:	ff 75 0c             	pushl  0xc(%ebp)
 131:	50                   	push   %eax
 132:	e8 d3 00 00 00       	call   20a <fstat>
 137:	89 c6                	mov    %eax,%esi
  close(fd);
 139:	89 1c 24             	mov    %ebx,(%esp)
 13c:	e8 99 00 00 00       	call   1da <close>
  return r;
 141:	83 c4 10             	add    $0x10,%esp
}
 144:	89 f0                	mov    %esi,%eax
 146:	8d 65 f8             	lea    -0x8(%ebp),%esp
 149:	5b                   	pop    %ebx
 14a:	5e                   	pop    %esi
 14b:	5d                   	pop    %ebp
 14c:	c3                   	ret    
    return -1;
 14d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 152:	eb f0                	jmp    144 <stat+0x34>

00000154 <atoi>:

int
atoi(const char *s)
{
 154:	55                   	push   %ebp
 155:	89 e5                	mov    %esp,%ebp
 157:	53                   	push   %ebx
 158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 15b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 160:	eb 10                	jmp    172 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 162:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 165:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 168:	83 c1 01             	add    $0x1,%ecx
 16b:	0f be d2             	movsbl %dl,%edx
 16e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 172:	0f b6 11             	movzbl (%ecx),%edx
 175:	8d 5a d0             	lea    -0x30(%edx),%ebx
 178:	80 fb 09             	cmp    $0x9,%bl
 17b:	76 e5                	jbe    162 <atoi+0xe>
  return n;
}
 17d:	5b                   	pop    %ebx
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	56                   	push   %esi
 184:	53                   	push   %ebx
 185:	8b 45 08             	mov    0x8(%ebp),%eax
 188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 18b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 18e:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 190:	eb 0d                	jmp    19f <memmove+0x1f>
    *dst++ = *src++;
 192:	0f b6 13             	movzbl (%ebx),%edx
 195:	88 11                	mov    %dl,(%ecx)
 197:	8d 5b 01             	lea    0x1(%ebx),%ebx
 19a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 19d:	89 f2                	mov    %esi,%edx
 19f:	8d 72 ff             	lea    -0x1(%edx),%esi
 1a2:	85 d2                	test   %edx,%edx
 1a4:	7f ec                	jg     192 <memmove+0x12>
  return vdst;
}
 1a6:	5b                   	pop    %ebx
 1a7:	5e                   	pop    %esi
 1a8:	5d                   	pop    %ebp
 1a9:	c3                   	ret    

000001aa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1aa:	b8 01 00 00 00       	mov    $0x1,%eax
 1af:	cd 40                	int    $0x40
 1b1:	c3                   	ret    

000001b2 <exit>:
SYSCALL(exit)
 1b2:	b8 02 00 00 00       	mov    $0x2,%eax
 1b7:	cd 40                	int    $0x40
 1b9:	c3                   	ret    

000001ba <wait>:
SYSCALL(wait)
 1ba:	b8 03 00 00 00       	mov    $0x3,%eax
 1bf:	cd 40                	int    $0x40
 1c1:	c3                   	ret    

000001c2 <pipe>:
SYSCALL(pipe)
 1c2:	b8 04 00 00 00       	mov    $0x4,%eax
 1c7:	cd 40                	int    $0x40
 1c9:	c3                   	ret    

000001ca <read>:
SYSCALL(read)
 1ca:	b8 05 00 00 00       	mov    $0x5,%eax
 1cf:	cd 40                	int    $0x40
 1d1:	c3                   	ret    

000001d2 <write>:
SYSCALL(write)
 1d2:	b8 10 00 00 00       	mov    $0x10,%eax
 1d7:	cd 40                	int    $0x40
 1d9:	c3                   	ret    

000001da <close>:
SYSCALL(close)
 1da:	b8 15 00 00 00       	mov    $0x15,%eax
 1df:	cd 40                	int    $0x40
 1e1:	c3                   	ret    

000001e2 <kill>:
SYSCALL(kill)
 1e2:	b8 06 00 00 00       	mov    $0x6,%eax
 1e7:	cd 40                	int    $0x40
 1e9:	c3                   	ret    

000001ea <exec>:
SYSCALL(exec)
 1ea:	b8 07 00 00 00       	mov    $0x7,%eax
 1ef:	cd 40                	int    $0x40
 1f1:	c3                   	ret    

000001f2 <open>:
SYSCALL(open)
 1f2:	b8 0f 00 00 00       	mov    $0xf,%eax
 1f7:	cd 40                	int    $0x40
 1f9:	c3                   	ret    

000001fa <mknod>:
SYSCALL(mknod)
 1fa:	b8 11 00 00 00       	mov    $0x11,%eax
 1ff:	cd 40                	int    $0x40
 201:	c3                   	ret    

00000202 <unlink>:
SYSCALL(unlink)
 202:	b8 12 00 00 00       	mov    $0x12,%eax
 207:	cd 40                	int    $0x40
 209:	c3                   	ret    

0000020a <fstat>:
SYSCALL(fstat)
 20a:	b8 08 00 00 00       	mov    $0x8,%eax
 20f:	cd 40                	int    $0x40
 211:	c3                   	ret    

00000212 <link>:
SYSCALL(link)
 212:	b8 13 00 00 00       	mov    $0x13,%eax
 217:	cd 40                	int    $0x40
 219:	c3                   	ret    

0000021a <mkdir>:
SYSCALL(mkdir)
 21a:	b8 14 00 00 00       	mov    $0x14,%eax
 21f:	cd 40                	int    $0x40
 221:	c3                   	ret    

00000222 <chdir>:
SYSCALL(chdir)
 222:	b8 09 00 00 00       	mov    $0x9,%eax
 227:	cd 40                	int    $0x40
 229:	c3                   	ret    

0000022a <dup>:
SYSCALL(dup)
 22a:	b8 0a 00 00 00       	mov    $0xa,%eax
 22f:	cd 40                	int    $0x40
 231:	c3                   	ret    

00000232 <getpid>:
SYSCALL(getpid)
 232:	b8 0b 00 00 00       	mov    $0xb,%eax
 237:	cd 40                	int    $0x40
 239:	c3                   	ret    

0000023a <sbrk>:
SYSCALL(sbrk)
 23a:	b8 0c 00 00 00       	mov    $0xc,%eax
 23f:	cd 40                	int    $0x40
 241:	c3                   	ret    

00000242 <sleep>:
SYSCALL(sleep)
 242:	b8 0d 00 00 00       	mov    $0xd,%eax
 247:	cd 40                	int    $0x40
 249:	c3                   	ret    

0000024a <uptime>:
SYSCALL(uptime)
 24a:	b8 0e 00 00 00       	mov    $0xe,%eax
 24f:	cd 40                	int    $0x40
 251:	c3                   	ret    

00000252 <symlink>:
SYSCALL(symlink)
 252:	b8 16 00 00 00       	mov    $0x16,%eax
 257:	cd 40                	int    $0x40
 259:	c3                   	ret    

0000025a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 25a:	55                   	push   %ebp
 25b:	89 e5                	mov    %esp,%ebp
 25d:	83 ec 1c             	sub    $0x1c,%esp
 260:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 263:	6a 01                	push   $0x1
 265:	8d 55 f4             	lea    -0xc(%ebp),%edx
 268:	52                   	push   %edx
 269:	50                   	push   %eax
 26a:	e8 63 ff ff ff       	call   1d2 <write>
}
 26f:	83 c4 10             	add    $0x10,%esp
 272:	c9                   	leave  
 273:	c3                   	ret    

00000274 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	57                   	push   %edi
 278:	56                   	push   %esi
 279:	53                   	push   %ebx
 27a:	83 ec 2c             	sub    $0x2c,%esp
 27d:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 27f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 283:	0f 95 c3             	setne  %bl
 286:	89 d0                	mov    %edx,%eax
 288:	c1 e8 1f             	shr    $0x1f,%eax
 28b:	84 c3                	test   %al,%bl
 28d:	74 10                	je     29f <printint+0x2b>
    neg = 1;
    x = -xx;
 28f:	f7 da                	neg    %edx
    neg = 1;
 291:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 298:	be 00 00 00 00       	mov    $0x0,%esi
 29d:	eb 0b                	jmp    2aa <printint+0x36>
  neg = 0;
 29f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2a6:	eb f0                	jmp    298 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2a8:	89 c6                	mov    %eax,%esi
 2aa:	89 d0                	mov    %edx,%eax
 2ac:	ba 00 00 00 00       	mov    $0x0,%edx
 2b1:	f7 f1                	div    %ecx
 2b3:	89 c3                	mov    %eax,%ebx
 2b5:	8d 46 01             	lea    0x1(%esi),%eax
 2b8:	0f b6 92 b8 05 00 00 	movzbl 0x5b8(%edx),%edx
 2bf:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2c3:	89 da                	mov    %ebx,%edx
 2c5:	85 db                	test   %ebx,%ebx
 2c7:	75 df                	jne    2a8 <printint+0x34>
 2c9:	89 c3                	mov    %eax,%ebx
  if(neg)
 2cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2cf:	74 16                	je     2e7 <printint+0x73>
    buf[i++] = '-';
 2d1:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2d6:	8d 5e 02             	lea    0x2(%esi),%ebx
 2d9:	eb 0c                	jmp    2e7 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2db:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 2e0:	89 f8                	mov    %edi,%eax
 2e2:	e8 73 ff ff ff       	call   25a <putc>
  while(--i >= 0)
 2e7:	83 eb 01             	sub    $0x1,%ebx
 2ea:	79 ef                	jns    2db <printint+0x67>
}
 2ec:	83 c4 2c             	add    $0x2c,%esp
 2ef:	5b                   	pop    %ebx
 2f0:	5e                   	pop    %esi
 2f1:	5f                   	pop    %edi
 2f2:	5d                   	pop    %ebp
 2f3:	c3                   	ret    

000002f4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	57                   	push   %edi
 2f8:	56                   	push   %esi
 2f9:	53                   	push   %ebx
 2fa:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 2fd:	8d 45 10             	lea    0x10(%ebp),%eax
 300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 303:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 308:	bb 00 00 00 00       	mov    $0x0,%ebx
 30d:	eb 14                	jmp    323 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 30f:	89 fa                	mov    %edi,%edx
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	e8 41 ff ff ff       	call   25a <putc>
 319:	eb 05                	jmp    320 <printf+0x2c>
      }
    } else if(state == '%'){
 31b:	83 fe 25             	cmp    $0x25,%esi
 31e:	74 25                	je     345 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 320:	83 c3 01             	add    $0x1,%ebx
 323:	8b 45 0c             	mov    0xc(%ebp),%eax
 326:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 32a:	84 c0                	test   %al,%al
 32c:	0f 84 23 01 00 00    	je     455 <printf+0x161>
    c = fmt[i] & 0xff;
 332:	0f be f8             	movsbl %al,%edi
 335:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 338:	85 f6                	test   %esi,%esi
 33a:	75 df                	jne    31b <printf+0x27>
      if(c == '%'){
 33c:	83 f8 25             	cmp    $0x25,%eax
 33f:	75 ce                	jne    30f <printf+0x1b>
        state = '%';
 341:	89 c6                	mov    %eax,%esi
 343:	eb db                	jmp    320 <printf+0x2c>
      if(c == 'd'){
 345:	83 f8 64             	cmp    $0x64,%eax
 348:	74 49                	je     393 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 34a:	83 f8 78             	cmp    $0x78,%eax
 34d:	0f 94 c1             	sete   %cl
 350:	83 f8 70             	cmp    $0x70,%eax
 353:	0f 94 c2             	sete   %dl
 356:	08 d1                	or     %dl,%cl
 358:	75 63                	jne    3bd <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 35a:	83 f8 73             	cmp    $0x73,%eax
 35d:	0f 84 84 00 00 00    	je     3e7 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 363:	83 f8 63             	cmp    $0x63,%eax
 366:	0f 84 b7 00 00 00    	je     423 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 36c:	83 f8 25             	cmp    $0x25,%eax
 36f:	0f 84 cc 00 00 00    	je     441 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 375:	ba 25 00 00 00       	mov    $0x25,%edx
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
 37d:	e8 d8 fe ff ff       	call   25a <putc>
        putc(fd, c);
 382:	89 fa                	mov    %edi,%edx
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	e8 ce fe ff ff       	call   25a <putc>
      }
      state = 0;
 38c:	be 00 00 00 00       	mov    $0x0,%esi
 391:	eb 8d                	jmp    320 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 396:	8b 17                	mov    (%edi),%edx
 398:	83 ec 0c             	sub    $0xc,%esp
 39b:	6a 01                	push   $0x1
 39d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	e8 ca fe ff ff       	call   274 <printint>
        ap++;
 3aa:	83 c7 04             	add    $0x4,%edi
 3ad:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3b0:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3b3:	be 00 00 00 00       	mov    $0x0,%esi
 3b8:	e9 63 ff ff ff       	jmp    320 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3c0:	8b 17                	mov    (%edi),%edx
 3c2:	83 ec 0c             	sub    $0xc,%esp
 3c5:	6a 00                	push   $0x0
 3c7:	b9 10 00 00 00       	mov    $0x10,%ecx
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	e8 a0 fe ff ff       	call   274 <printint>
        ap++;
 3d4:	83 c7 04             	add    $0x4,%edi
 3d7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3da:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3dd:	be 00 00 00 00       	mov    $0x0,%esi
 3e2:	e9 39 ff ff ff       	jmp    320 <printf+0x2c>
        s = (char*)*ap;
 3e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3ea:	8b 30                	mov    (%eax),%esi
        ap++;
 3ec:	83 c0 04             	add    $0x4,%eax
 3ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 3f2:	85 f6                	test   %esi,%esi
 3f4:	75 28                	jne    41e <printf+0x12a>
          s = "(null)";
 3f6:	be b0 05 00 00       	mov    $0x5b0,%esi
 3fb:	8b 7d 08             	mov    0x8(%ebp),%edi
 3fe:	eb 0d                	jmp    40d <printf+0x119>
          putc(fd, *s);
 400:	0f be d2             	movsbl %dl,%edx
 403:	89 f8                	mov    %edi,%eax
 405:	e8 50 fe ff ff       	call   25a <putc>
          s++;
 40a:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 40d:	0f b6 16             	movzbl (%esi),%edx
 410:	84 d2                	test   %dl,%dl
 412:	75 ec                	jne    400 <printf+0x10c>
      state = 0;
 414:	be 00 00 00 00       	mov    $0x0,%esi
 419:	e9 02 ff ff ff       	jmp    320 <printf+0x2c>
 41e:	8b 7d 08             	mov    0x8(%ebp),%edi
 421:	eb ea                	jmp    40d <printf+0x119>
        putc(fd, *ap);
 423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 426:	0f be 17             	movsbl (%edi),%edx
 429:	8b 45 08             	mov    0x8(%ebp),%eax
 42c:	e8 29 fe ff ff       	call   25a <putc>
        ap++;
 431:	83 c7 04             	add    $0x4,%edi
 434:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 437:	be 00 00 00 00       	mov    $0x0,%esi
 43c:	e9 df fe ff ff       	jmp    320 <printf+0x2c>
        putc(fd, c);
 441:	89 fa                	mov    %edi,%edx
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	e8 0f fe ff ff       	call   25a <putc>
      state = 0;
 44b:	be 00 00 00 00       	mov    $0x0,%esi
 450:	e9 cb fe ff ff       	jmp    320 <printf+0x2c>
    }
  }
}
 455:	8d 65 f4             	lea    -0xc(%ebp),%esp
 458:	5b                   	pop    %ebx
 459:	5e                   	pop    %esi
 45a:	5f                   	pop    %edi
 45b:	5d                   	pop    %ebp
 45c:	c3                   	ret    

0000045d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 45d:	55                   	push   %ebp
 45e:	89 e5                	mov    %esp,%ebp
 460:	57                   	push   %edi
 461:	56                   	push   %esi
 462:	53                   	push   %ebx
 463:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 466:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 469:	a1 50 08 00 00       	mov    0x850,%eax
 46e:	eb 02                	jmp    472 <free+0x15>
 470:	89 d0                	mov    %edx,%eax
 472:	39 c8                	cmp    %ecx,%eax
 474:	73 04                	jae    47a <free+0x1d>
 476:	39 08                	cmp    %ecx,(%eax)
 478:	77 12                	ja     48c <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 47a:	8b 10                	mov    (%eax),%edx
 47c:	39 c2                	cmp    %eax,%edx
 47e:	77 f0                	ja     470 <free+0x13>
 480:	39 c8                	cmp    %ecx,%eax
 482:	72 08                	jb     48c <free+0x2f>
 484:	39 ca                	cmp    %ecx,%edx
 486:	77 04                	ja     48c <free+0x2f>
 488:	89 d0                	mov    %edx,%eax
 48a:	eb e6                	jmp    472 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 48c:	8b 73 fc             	mov    -0x4(%ebx),%esi
 48f:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 492:	8b 10                	mov    (%eax),%edx
 494:	39 d7                	cmp    %edx,%edi
 496:	74 19                	je     4b1 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 498:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 49b:	8b 50 04             	mov    0x4(%eax),%edx
 49e:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4a1:	39 ce                	cmp    %ecx,%esi
 4a3:	74 1b                	je     4c0 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4a5:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4a7:	a3 50 08 00 00       	mov    %eax,0x850
}
 4ac:	5b                   	pop    %ebx
 4ad:	5e                   	pop    %esi
 4ae:	5f                   	pop    %edi
 4af:	5d                   	pop    %ebp
 4b0:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4b1:	03 72 04             	add    0x4(%edx),%esi
 4b4:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4b7:	8b 10                	mov    (%eax),%edx
 4b9:	8b 12                	mov    (%edx),%edx
 4bb:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4be:	eb db                	jmp    49b <free+0x3e>
    p->s.size += bp->s.size;
 4c0:	03 53 fc             	add    -0x4(%ebx),%edx
 4c3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4c6:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4c9:	89 10                	mov    %edx,(%eax)
 4cb:	eb da                	jmp    4a7 <free+0x4a>

000004cd <morecore>:

static Header*
morecore(uint nu)
{
 4cd:	55                   	push   %ebp
 4ce:	89 e5                	mov    %esp,%ebp
 4d0:	53                   	push   %ebx
 4d1:	83 ec 04             	sub    $0x4,%esp
 4d4:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4d6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4db:	77 05                	ja     4e2 <morecore+0x15>
    nu = 4096;
 4dd:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 4e2:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 4e9:	83 ec 0c             	sub    $0xc,%esp
 4ec:	50                   	push   %eax
 4ed:	e8 48 fd ff ff       	call   23a <sbrk>
  if(p == (char*)-1)
 4f2:	83 c4 10             	add    $0x10,%esp
 4f5:	83 f8 ff             	cmp    $0xffffffff,%eax
 4f8:	74 1c                	je     516 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 4fa:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 4fd:	83 c0 08             	add    $0x8,%eax
 500:	83 ec 0c             	sub    $0xc,%esp
 503:	50                   	push   %eax
 504:	e8 54 ff ff ff       	call   45d <free>
  return freep;
 509:	a1 50 08 00 00       	mov    0x850,%eax
 50e:	83 c4 10             	add    $0x10,%esp
}
 511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 514:	c9                   	leave  
 515:	c3                   	ret    
    return 0;
 516:	b8 00 00 00 00       	mov    $0x0,%eax
 51b:	eb f4                	jmp    511 <morecore+0x44>

0000051d <malloc>:

void*
malloc(uint nbytes)
{
 51d:	55                   	push   %ebp
 51e:	89 e5                	mov    %esp,%ebp
 520:	53                   	push   %ebx
 521:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	8d 58 07             	lea    0x7(%eax),%ebx
 52a:	c1 eb 03             	shr    $0x3,%ebx
 52d:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 530:	8b 0d 50 08 00 00    	mov    0x850,%ecx
 536:	85 c9                	test   %ecx,%ecx
 538:	74 04                	je     53e <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 53a:	8b 01                	mov    (%ecx),%eax
 53c:	eb 4d                	jmp    58b <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 53e:	c7 05 50 08 00 00 54 	movl   $0x854,0x850
 545:	08 00 00 
 548:	c7 05 54 08 00 00 54 	movl   $0x854,0x854
 54f:	08 00 00 
    base.s.size = 0;
 552:	c7 05 58 08 00 00 00 	movl   $0x0,0x858
 559:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 55c:	b9 54 08 00 00       	mov    $0x854,%ecx
 561:	eb d7                	jmp    53a <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 563:	39 da                	cmp    %ebx,%edx
 565:	74 1a                	je     581 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 567:	29 da                	sub    %ebx,%edx
 569:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 56c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 56f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 572:	89 0d 50 08 00 00    	mov    %ecx,0x850
      return (void*)(p + 1);
 578:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 57b:	83 c4 04             	add    $0x4,%esp
 57e:	5b                   	pop    %ebx
 57f:	5d                   	pop    %ebp
 580:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 581:	8b 10                	mov    (%eax),%edx
 583:	89 11                	mov    %edx,(%ecx)
 585:	eb eb                	jmp    572 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 587:	89 c1                	mov    %eax,%ecx
 589:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 58b:	8b 50 04             	mov    0x4(%eax),%edx
 58e:	39 da                	cmp    %ebx,%edx
 590:	73 d1                	jae    563 <malloc+0x46>
    if(p == freep)
 592:	39 05 50 08 00 00    	cmp    %eax,0x850
 598:	75 ed                	jne    587 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 59a:	89 d8                	mov    %ebx,%eax
 59c:	e8 2c ff ff ff       	call   4cd <morecore>
 5a1:	85 c0                	test   %eax,%eax
 5a3:	75 e2                	jne    587 <malloc+0x6a>
        return 0;
 5a5:	b8 00 00 00 00       	mov    $0x0,%eax
 5aa:	eb cf                	jmp    57b <malloc+0x5e>


_ofiletest:     file format elf32-i386


Disassembly of section .text:

00000000 <reverse>:
#include "user.h"
#include "fcntl.h"


void reverse(char s[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 18             	sub    $0x18,%esp
   9:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
   c:	53                   	push   %ebx
   d:	e8 62 02 00 00       	call   274 <strlen>
  12:	83 e8 01             	sub    $0x1,%eax
  15:	83 c4 10             	add    $0x10,%esp
  18:	ba 00 00 00 00       	mov    $0x0,%edx
  1d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  20:	eb 1c                	jmp    3e <reverse+0x3e>
        c = s[i];
  22:	89 d6                	mov    %edx,%esi
  24:	03 75 08             	add    0x8(%ebp),%esi
  27:	0f b6 3e             	movzbl (%esi),%edi
        s[i] = s[j];
  2a:	89 c1                	mov    %eax,%ecx
  2c:	03 4d 08             	add    0x8(%ebp),%ecx
  2f:	0f b6 19             	movzbl (%ecx),%ebx
  32:	88 1e                	mov    %bl,(%esi)
        s[j] = c;
  34:	89 fb                	mov    %edi,%ebx
  36:	88 19                	mov    %bl,(%ecx)
    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
  38:	83 c2 01             	add    $0x1,%edx
  3b:	83 e8 01             	sub    $0x1,%eax
  3e:	39 c2                	cmp    %eax,%edx
  40:	7c e0                	jl     22 <reverse+0x22>
    }
}
  42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  45:	5b                   	pop    %ebx
  46:	5e                   	pop    %esi
  47:	5f                   	pop    %edi
  48:	5d                   	pop    %ebp
  49:	c3                   	ret    

0000004a <itoa>:

static void
itoa(int x, char buf[])
{
  4a:	55                   	push   %ebp
  4b:	89 e5                	mov    %esp,%ebp
  4d:	57                   	push   %edi
  4e:	56                   	push   %esi
  4f:	53                   	push   %ebx
  50:	83 ec 0c             	sub    $0xc,%esp
  53:	89 c1                	mov    %eax,%ecx
  55:	89 d6                	mov    %edx,%esi
    static char digits[] = "0123456789";
    int i;

    i = 0;
  57:	bb 00 00 00 00       	mov    $0x0,%ebx
    do{
        buf[i++] = digits[x % 10];
  5c:	ba 67 66 66 66       	mov    $0x66666667,%edx
  61:	89 c8                	mov    %ecx,%eax
  63:	f7 ea                	imul   %edx
  65:	c1 fa 02             	sar    $0x2,%edx
  68:	89 c8                	mov    %ecx,%eax
  6a:	c1 f8 1f             	sar    $0x1f,%eax
  6d:	29 c2                	sub    %eax,%edx
  6f:	89 d0                	mov    %edx,%eax
  71:	8d 3c 92             	lea    (%edx,%edx,4),%edi
  74:	8d 14 3f             	lea    (%edi,%edi,1),%edx
  77:	29 d1                	sub    %edx,%ecx
  79:	8d 7b 01             	lea    0x1(%ebx),%edi
  7c:	0f b6 91 40 08 00 00 	movzbl 0x840(%ecx),%edx
  83:	88 14 1e             	mov    %dl,(%esi,%ebx,1)
    }while((x /= 10) != 0);
  86:	89 c1                	mov    %eax,%ecx
        buf[i++] = digits[x % 10];
  88:	89 fb                	mov    %edi,%ebx
    }while((x /= 10) != 0);
  8a:	85 c0                	test   %eax,%eax
  8c:	75 ce                	jne    5c <itoa+0x12>
    buf[i] = '\0';
  8e:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
    reverse(buf);
  92:	83 ec 0c             	sub    $0xc,%esp
  95:	56                   	push   %esi
  96:	e8 65 ff ff ff       	call   0 <reverse>
}
  9b:	83 c4 10             	add    $0x10,%esp
  9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  a1:	5b                   	pop    %ebx
  a2:	5e                   	pop    %esi
  a3:	5f                   	pop    %edi
  a4:	5d                   	pop    %ebp
  a5:	c3                   	ret    

000000a6 <main>:

int
main(int argc, char *argv[])
{
  a6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  aa:	83 e4 f0             	and    $0xfffffff0,%esp
  ad:	ff 71 fc             	pushl  -0x4(%ecx)
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	57                   	push   %edi
  b4:	56                   	push   %esi
  b5:	53                   	push   %ebx
  b6:	51                   	push   %ecx
  b7:	83 ec 28             	sub    $0x28,%esp
  ba:	8b 39                	mov    (%ecx),%edi
  bc:	8b 41 04             	mov    0x4(%ecx),%eax
  bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    if(argc < 2){
  c2:	83 ff 01             	cmp    $0x1,%edi
  c5:	7e 31                	jle    f8 <main+0x52>
        printf(2, "ofiletest N <list of file nums to close and delete>\n");
        exit();
    }

    char buf[2];
    int n = atoi(argv[1]);
  c7:	83 ec 0c             	sub    $0xc,%esp
  ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  cd:	ff 70 04             	pushl  0x4(%eax)
  d0:	e8 8a 02 00 00       	call   35f <atoi>
  d5:	89 c6                	mov    %eax,%esi
    char fn[7] = "ofile";
  d7:	a1 38 08 00 00       	mov    0x838,%eax
  dc:	89 45 df             	mov    %eax,-0x21(%ebp)
  df:	0f b7 05 3c 08 00 00 	movzwl 0x83c,%eax
  e6:	66 89 45 e3          	mov    %ax,-0x1d(%ebp)
  ea:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    for (int i = 0; i < n; i++) {
  ee:	83 c4 10             	add    $0x10,%esp
  f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  f6:	eb 2a                	jmp    122 <main+0x7c>
        printf(2, "ofiletest N <list of file nums to close and delete>\n");
  f8:	83 ec 08             	sub    $0x8,%esp
  fb:	68 c0 07 00 00       	push   $0x7c0
 100:	6a 02                	push   $0x2
 102:	e8 00 04 00 00       	call   507 <printf>
        exit();
 107:	e8 b1 02 00 00       	call   3bd <exit>
        itoa(i, buf);
        fn[5] = buf[0];
        fn[6] = buf[1];
        fn[7] = '\0';
        if (i >= 13) {
            printf(1, "can not open ofile%d\n", i);
 10c:	83 ec 04             	sub    $0x4,%esp
 10f:	53                   	push   %ebx
 110:	68 f8 07 00 00       	push   $0x7f8
 115:	6a 01                	push   $0x1
 117:	e8 eb 03 00 00       	call   507 <printf>
            continue;
 11c:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < n; i++) {
 11f:	83 c3 01             	add    $0x1,%ebx
 122:	39 f3                	cmp    %esi,%ebx
 124:	7d 37                	jge    15d <main+0xb7>
        itoa(i, buf);
 126:	8d 55 e6             	lea    -0x1a(%ebp),%edx
 129:	89 d8                	mov    %ebx,%eax
 12b:	e8 1a ff ff ff       	call   4a <itoa>
        fn[5] = buf[0];
 130:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
 134:	88 45 e4             	mov    %al,-0x1c(%ebp)
        fn[6] = buf[1];
 137:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 13b:	88 45 e5             	mov    %al,-0x1b(%ebp)
        fn[7] = '\0';
 13e:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
        if (i >= 13) {
 142:	83 fb 0c             	cmp    $0xc,%ebx
 145:	7f c5                	jg     10c <main+0x66>
        }
        open(fn, O_CREATE);
 147:	83 ec 08             	sub    $0x8,%esp
 14a:	68 00 02 00 00       	push   $0x200
 14f:	8d 45 df             	lea    -0x21(%ebp),%eax
 152:	50                   	push   %eax
 153:	e8 a5 02 00 00       	call   3fd <open>
 158:	83 c4 10             	add    $0x10,%esp
 15b:	eb c2                	jmp    11f <main+0x79>
    }

    int numOfFileClose = argc - 2;
 15d:	8d 47 fe             	lea    -0x2(%edi),%eax
 160:	89 45 d0             	mov    %eax,-0x30(%ebp)
    for (int i = 0; i < numOfFileClose; i++) {
 163:	bf 00 00 00 00       	mov    $0x0,%edi
 168:	eb 21                	jmp    18b <main+0xe5>
        fn[6] = buf[1];
        fn[7] = '\0';
        if (c >= n) {
            printf(1, "%s is invalid\n", fn);
        }
        close(3 + c);
 16a:	83 ec 0c             	sub    $0xc,%esp
 16d:	83 c3 03             	add    $0x3,%ebx
 170:	53                   	push   %ebx
 171:	e8 6f 02 00 00       	call   3e5 <close>
        if(unlink(fn) < 0){
 176:	8d 45 df             	lea    -0x21(%ebp),%eax
 179:	89 04 24             	mov    %eax,(%esp)
 17c:	e8 8c 02 00 00       	call   40d <unlink>
 181:	83 c4 10             	add    $0x10,%esp
 184:	85 c0                	test   %eax,%eax
 186:	78 52                	js     1da <main+0x134>
    for (int i = 0; i < numOfFileClose; i++) {
 188:	83 c7 01             	add    $0x1,%edi
 18b:	3b 7d d0             	cmp    -0x30(%ebp),%edi
 18e:	7d 60                	jge    1f0 <main+0x14a>
        int c = atoi(argv[2 + i]);
 190:	83 ec 0c             	sub    $0xc,%esp
 193:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 196:	ff 74 b8 08          	pushl  0x8(%eax,%edi,4)
 19a:	e8 c0 01 00 00       	call   35f <atoi>
 19f:	89 c3                	mov    %eax,%ebx
        itoa(c, buf);
 1a1:	8d 55 e6             	lea    -0x1a(%ebp),%edx
 1a4:	e8 a1 fe ff ff       	call   4a <itoa>
        fn[5] = buf[0];
 1a9:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
 1ad:	88 45 e4             	mov    %al,-0x1c(%ebp)
        fn[6] = buf[1];
 1b0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1b4:	88 45 e5             	mov    %al,-0x1b(%ebp)
        fn[7] = '\0';
 1b7:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
        if (c >= n) {
 1bb:	83 c4 10             	add    $0x10,%esp
 1be:	39 de                	cmp    %ebx,%esi
 1c0:	7f a8                	jg     16a <main+0xc4>
            printf(1, "%s is invalid\n", fn);
 1c2:	83 ec 04             	sub    $0x4,%esp
 1c5:	8d 45 df             	lea    -0x21(%ebp),%eax
 1c8:	50                   	push   %eax
 1c9:	68 0e 08 00 00       	push   $0x80e
 1ce:	6a 01                	push   $0x1
 1d0:	e8 32 03 00 00       	call   507 <printf>
 1d5:	83 c4 10             	add    $0x10,%esp
 1d8:	eb 90                	jmp    16a <main+0xc4>
            printf(2, "%s failed to delete\n", fn);
 1da:	83 ec 04             	sub    $0x4,%esp
 1dd:	8d 45 df             	lea    -0x21(%ebp),%eax
 1e0:	50                   	push   %eax
 1e1:	68 1d 08 00 00       	push   $0x81d
 1e6:	6a 02                	push   $0x2
 1e8:	e8 1a 03 00 00       	call   507 <printf>
            break;
 1ed:	83 c4 10             	add    $0x10,%esp
        }
    }

    int num = getofilecnt(getpid());
 1f0:	e8 48 02 00 00       	call   43d <getpid>
 1f5:	83 ec 0c             	sub    $0xc,%esp
 1f8:	50                   	push   %eax
 1f9:	e8 5f 02 00 00       	call   45d <getofilecnt>
    printf(1, "%d ", num);
 1fe:	83 c4 0c             	add    $0xc,%esp
 201:	50                   	push   %eax
 202:	68 32 08 00 00       	push   $0x832
 207:	6a 01                	push   $0x1
 209:	e8 f9 02 00 00       	call   507 <printf>
    num = getofilenext(getpid());
 20e:	e8 2a 02 00 00       	call   43d <getpid>
 213:	89 04 24             	mov    %eax,(%esp)
 216:	e8 4a 02 00 00       	call   465 <getofilenext>
    printf(1, "%d\n", num);
 21b:	83 c4 0c             	add    $0xc,%esp
 21e:	50                   	push   %eax
 21f:	68 0a 08 00 00       	push   $0x80a
 224:	6a 01                	push   $0x1
 226:	e8 dc 02 00 00       	call   507 <printf>
    exit();
 22b:	e8 8d 01 00 00       	call   3bd <exit>

00000230 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 230:	55                   	push   %ebp
 231:	89 e5                	mov    %esp,%ebp
 233:	53                   	push   %ebx
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 23a:	89 c2                	mov    %eax,%edx
 23c:	0f b6 19             	movzbl (%ecx),%ebx
 23f:	88 1a                	mov    %bl,(%edx)
 241:	8d 52 01             	lea    0x1(%edx),%edx
 244:	8d 49 01             	lea    0x1(%ecx),%ecx
 247:	84 db                	test   %bl,%bl
 249:	75 f1                	jne    23c <strcpy+0xc>
    ;
  return os;
}
 24b:	5b                   	pop    %ebx
 24c:	5d                   	pop    %ebp
 24d:	c3                   	ret    

0000024e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	8b 4d 08             	mov    0x8(%ebp),%ecx
 254:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 257:	eb 06                	jmp    25f <strcmp+0x11>
    p++, q++;
 259:	83 c1 01             	add    $0x1,%ecx
 25c:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 25f:	0f b6 01             	movzbl (%ecx),%eax
 262:	84 c0                	test   %al,%al
 264:	74 04                	je     26a <strcmp+0x1c>
 266:	3a 02                	cmp    (%edx),%al
 268:	74 ef                	je     259 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 26a:	0f b6 c0             	movzbl %al,%eax
 26d:	0f b6 12             	movzbl (%edx),%edx
 270:	29 d0                	sub    %edx,%eax
}
 272:	5d                   	pop    %ebp
 273:	c3                   	ret    

00000274 <strlen>:

uint
strlen(const char *s)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 27a:	ba 00 00 00 00       	mov    $0x0,%edx
 27f:	eb 03                	jmp    284 <strlen+0x10>
 281:	83 c2 01             	add    $0x1,%edx
 284:	89 d0                	mov    %edx,%eax
 286:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 28a:	75 f5                	jne    281 <strlen+0xd>
    ;
  return n;
}
 28c:	5d                   	pop    %ebp
 28d:	c3                   	ret    

0000028e <memset>:

void*
memset(void *dst, int c, uint n)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	57                   	push   %edi
 292:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 295:	89 d7                	mov    %edx,%edi
 297:	8b 4d 10             	mov    0x10(%ebp),%ecx
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	fc                   	cld    
 29e:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2a0:	89 d0                	mov    %edx,%eax
 2a2:	5f                   	pop    %edi
 2a3:	5d                   	pop    %ebp
 2a4:	c3                   	ret    

000002a5 <strchr>:

char*
strchr(const char *s, char c)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 2af:	0f b6 10             	movzbl (%eax),%edx
 2b2:	84 d2                	test   %dl,%dl
 2b4:	74 09                	je     2bf <strchr+0x1a>
    if(*s == c)
 2b6:	38 ca                	cmp    %cl,%dl
 2b8:	74 0a                	je     2c4 <strchr+0x1f>
  for(; *s; s++)
 2ba:	83 c0 01             	add    $0x1,%eax
 2bd:	eb f0                	jmp    2af <strchr+0xa>
      return (char*)s;
  return 0;
 2bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c4:	5d                   	pop    %ebp
 2c5:	c3                   	ret    

000002c6 <gets>:

char*
gets(char *buf, int max)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	57                   	push   %edi
 2ca:	56                   	push   %esi
 2cb:	53                   	push   %ebx
 2cc:	83 ec 1c             	sub    $0x1c,%esp
 2cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d2:	bb 00 00 00 00       	mov    $0x0,%ebx
 2d7:	8d 73 01             	lea    0x1(%ebx),%esi
 2da:	3b 75 0c             	cmp    0xc(%ebp),%esi
 2dd:	7d 2e                	jge    30d <gets+0x47>
    cc = read(0, &c, 1);
 2df:	83 ec 04             	sub    $0x4,%esp
 2e2:	6a 01                	push   $0x1
 2e4:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2e7:	50                   	push   %eax
 2e8:	6a 00                	push   $0x0
 2ea:	e8 e6 00 00 00       	call   3d5 <read>
    if(cc < 1)
 2ef:	83 c4 10             	add    $0x10,%esp
 2f2:	85 c0                	test   %eax,%eax
 2f4:	7e 17                	jle    30d <gets+0x47>
      break;
    buf[i++] = c;
 2f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2fa:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 2fd:	3c 0a                	cmp    $0xa,%al
 2ff:	0f 94 c2             	sete   %dl
 302:	3c 0d                	cmp    $0xd,%al
 304:	0f 94 c0             	sete   %al
    buf[i++] = c;
 307:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 309:	08 c2                	or     %al,%dl
 30b:	74 ca                	je     2d7 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 30d:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 311:	89 f8                	mov    %edi,%eax
 313:	8d 65 f4             	lea    -0xc(%ebp),%esp
 316:	5b                   	pop    %ebx
 317:	5e                   	pop    %esi
 318:	5f                   	pop    %edi
 319:	5d                   	pop    %ebp
 31a:	c3                   	ret    

0000031b <stat>:

int
stat(const char *n, struct stat *st)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	56                   	push   %esi
 31f:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 320:	83 ec 08             	sub    $0x8,%esp
 323:	6a 00                	push   $0x0
 325:	ff 75 08             	pushl  0x8(%ebp)
 328:	e8 d0 00 00 00       	call   3fd <open>
  if(fd < 0)
 32d:	83 c4 10             	add    $0x10,%esp
 330:	85 c0                	test   %eax,%eax
 332:	78 24                	js     358 <stat+0x3d>
 334:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 336:	83 ec 08             	sub    $0x8,%esp
 339:	ff 75 0c             	pushl  0xc(%ebp)
 33c:	50                   	push   %eax
 33d:	e8 d3 00 00 00       	call   415 <fstat>
 342:	89 c6                	mov    %eax,%esi
  close(fd);
 344:	89 1c 24             	mov    %ebx,(%esp)
 347:	e8 99 00 00 00       	call   3e5 <close>
  return r;
 34c:	83 c4 10             	add    $0x10,%esp
}
 34f:	89 f0                	mov    %esi,%eax
 351:	8d 65 f8             	lea    -0x8(%ebp),%esp
 354:	5b                   	pop    %ebx
 355:	5e                   	pop    %esi
 356:	5d                   	pop    %ebp
 357:	c3                   	ret    
    return -1;
 358:	be ff ff ff ff       	mov    $0xffffffff,%esi
 35d:	eb f0                	jmp    34f <stat+0x34>

0000035f <atoi>:

int
atoi(const char *s)
{
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
 362:	53                   	push   %ebx
 363:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 366:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 36b:	eb 10                	jmp    37d <atoi+0x1e>
    n = n*10 + *s++ - '0';
 36d:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 370:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 373:	83 c1 01             	add    $0x1,%ecx
 376:	0f be d2             	movsbl %dl,%edx
 379:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 37d:	0f b6 11             	movzbl (%ecx),%edx
 380:	8d 5a d0             	lea    -0x30(%edx),%ebx
 383:	80 fb 09             	cmp    $0x9,%bl
 386:	76 e5                	jbe    36d <atoi+0xe>
  return n;
}
 388:	5b                   	pop    %ebx
 389:	5d                   	pop    %ebp
 38a:	c3                   	ret    

0000038b <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 38b:	55                   	push   %ebp
 38c:	89 e5                	mov    %esp,%ebp
 38e:	56                   	push   %esi
 38f:	53                   	push   %ebx
 390:	8b 45 08             	mov    0x8(%ebp),%eax
 393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 396:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 399:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 39b:	eb 0d                	jmp    3aa <memmove+0x1f>
    *dst++ = *src++;
 39d:	0f b6 13             	movzbl (%ebx),%edx
 3a0:	88 11                	mov    %dl,(%ecx)
 3a2:	8d 5b 01             	lea    0x1(%ebx),%ebx
 3a5:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 3a8:	89 f2                	mov    %esi,%edx
 3aa:	8d 72 ff             	lea    -0x1(%edx),%esi
 3ad:	85 d2                	test   %edx,%edx
 3af:	7f ec                	jg     39d <memmove+0x12>
  return vdst;
}
 3b1:	5b                   	pop    %ebx
 3b2:	5e                   	pop    %esi
 3b3:	5d                   	pop    %ebp
 3b4:	c3                   	ret    

000003b5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3b5:	b8 01 00 00 00       	mov    $0x1,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <exit>:
SYSCALL(exit)
 3bd:	b8 02 00 00 00       	mov    $0x2,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <wait>:
SYSCALL(wait)
 3c5:	b8 03 00 00 00       	mov    $0x3,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <pipe>:
SYSCALL(pipe)
 3cd:	b8 04 00 00 00       	mov    $0x4,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <read>:
SYSCALL(read)
 3d5:	b8 05 00 00 00       	mov    $0x5,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <write>:
SYSCALL(write)
 3dd:	b8 10 00 00 00       	mov    $0x10,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <close>:
SYSCALL(close)
 3e5:	b8 15 00 00 00       	mov    $0x15,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <kill>:
SYSCALL(kill)
 3ed:	b8 06 00 00 00       	mov    $0x6,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <exec>:
SYSCALL(exec)
 3f5:	b8 07 00 00 00       	mov    $0x7,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <open>:
SYSCALL(open)
 3fd:	b8 0f 00 00 00       	mov    $0xf,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <mknod>:
SYSCALL(mknod)
 405:	b8 11 00 00 00       	mov    $0x11,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <unlink>:
SYSCALL(unlink)
 40d:	b8 12 00 00 00       	mov    $0x12,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <fstat>:
SYSCALL(fstat)
 415:	b8 08 00 00 00       	mov    $0x8,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <link>:
SYSCALL(link)
 41d:	b8 13 00 00 00       	mov    $0x13,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <mkdir>:
SYSCALL(mkdir)
 425:	b8 14 00 00 00       	mov    $0x14,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <chdir>:
SYSCALL(chdir)
 42d:	b8 09 00 00 00       	mov    $0x9,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <dup>:
SYSCALL(dup)
 435:	b8 0a 00 00 00       	mov    $0xa,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <getpid>:
SYSCALL(getpid)
 43d:	b8 0b 00 00 00       	mov    $0xb,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <sbrk>:
SYSCALL(sbrk)
 445:	b8 0c 00 00 00       	mov    $0xc,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <sleep>:
SYSCALL(sleep)
 44d:	b8 0d 00 00 00       	mov    $0xd,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <uptime>:
SYSCALL(uptime)
 455:	b8 0e 00 00 00       	mov    $0xe,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <getofilecnt>:
SYSCALL(getofilecnt)
 45d:	b8 16 00 00 00       	mov    $0x16,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <getofilenext>:
SYSCALL(getofilenext)
 465:	b8 17 00 00 00       	mov    $0x17,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 1c             	sub    $0x1c,%esp
 473:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 476:	6a 01                	push   $0x1
 478:	8d 55 f4             	lea    -0xc(%ebp),%edx
 47b:	52                   	push   %edx
 47c:	50                   	push   %eax
 47d:	e8 5b ff ff ff       	call   3dd <write>
}
 482:	83 c4 10             	add    $0x10,%esp
 485:	c9                   	leave  
 486:	c3                   	ret    

00000487 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 487:	55                   	push   %ebp
 488:	89 e5                	mov    %esp,%ebp
 48a:	57                   	push   %edi
 48b:	56                   	push   %esi
 48c:	53                   	push   %ebx
 48d:	83 ec 2c             	sub    $0x2c,%esp
 490:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 492:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 496:	0f 95 c3             	setne  %bl
 499:	89 d0                	mov    %edx,%eax
 49b:	c1 e8 1f             	shr    $0x1f,%eax
 49e:	84 c3                	test   %al,%bl
 4a0:	74 10                	je     4b2 <printint+0x2b>
    neg = 1;
    x = -xx;
 4a2:	f7 da                	neg    %edx
    neg = 1;
 4a4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4ab:	be 00 00 00 00       	mov    $0x0,%esi
 4b0:	eb 0b                	jmp    4bd <printint+0x36>
  neg = 0;
 4b2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 4b9:	eb f0                	jmp    4ab <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 4bb:	89 c6                	mov    %eax,%esi
 4bd:	89 d0                	mov    %edx,%eax
 4bf:	ba 00 00 00 00       	mov    $0x0,%edx
 4c4:	f7 f1                	div    %ecx
 4c6:	89 c3                	mov    %eax,%ebx
 4c8:	8d 46 01             	lea    0x1(%esi),%eax
 4cb:	0f b6 92 54 08 00 00 	movzbl 0x854(%edx),%edx
 4d2:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 4d6:	89 da                	mov    %ebx,%edx
 4d8:	85 db                	test   %ebx,%ebx
 4da:	75 df                	jne    4bb <printint+0x34>
 4dc:	89 c3                	mov    %eax,%ebx
  if(neg)
 4de:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 4e2:	74 16                	je     4fa <printint+0x73>
    buf[i++] = '-';
 4e4:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 4e9:	8d 5e 02             	lea    0x2(%esi),%ebx
 4ec:	eb 0c                	jmp    4fa <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 4ee:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 4f3:	89 f8                	mov    %edi,%eax
 4f5:	e8 73 ff ff ff       	call   46d <putc>
  while(--i >= 0)
 4fa:	83 eb 01             	sub    $0x1,%ebx
 4fd:	79 ef                	jns    4ee <printint+0x67>
}
 4ff:	83 c4 2c             	add    $0x2c,%esp
 502:	5b                   	pop    %ebx
 503:	5e                   	pop    %esi
 504:	5f                   	pop    %edi
 505:	5d                   	pop    %ebp
 506:	c3                   	ret    

00000507 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 507:	55                   	push   %ebp
 508:	89 e5                	mov    %esp,%ebp
 50a:	57                   	push   %edi
 50b:	56                   	push   %esi
 50c:	53                   	push   %ebx
 50d:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 510:	8d 45 10             	lea    0x10(%ebp),%eax
 513:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 516:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 51b:	bb 00 00 00 00       	mov    $0x0,%ebx
 520:	eb 14                	jmp    536 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 522:	89 fa                	mov    %edi,%edx
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	e8 41 ff ff ff       	call   46d <putc>
 52c:	eb 05                	jmp    533 <printf+0x2c>
      }
    } else if(state == '%'){
 52e:	83 fe 25             	cmp    $0x25,%esi
 531:	74 25                	je     558 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 533:	83 c3 01             	add    $0x1,%ebx
 536:	8b 45 0c             	mov    0xc(%ebp),%eax
 539:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 53d:	84 c0                	test   %al,%al
 53f:	0f 84 23 01 00 00    	je     668 <printf+0x161>
    c = fmt[i] & 0xff;
 545:	0f be f8             	movsbl %al,%edi
 548:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 54b:	85 f6                	test   %esi,%esi
 54d:	75 df                	jne    52e <printf+0x27>
      if(c == '%'){
 54f:	83 f8 25             	cmp    $0x25,%eax
 552:	75 ce                	jne    522 <printf+0x1b>
        state = '%';
 554:	89 c6                	mov    %eax,%esi
 556:	eb db                	jmp    533 <printf+0x2c>
      if(c == 'd'){
 558:	83 f8 64             	cmp    $0x64,%eax
 55b:	74 49                	je     5a6 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 55d:	83 f8 78             	cmp    $0x78,%eax
 560:	0f 94 c1             	sete   %cl
 563:	83 f8 70             	cmp    $0x70,%eax
 566:	0f 94 c2             	sete   %dl
 569:	08 d1                	or     %dl,%cl
 56b:	75 63                	jne    5d0 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 56d:	83 f8 73             	cmp    $0x73,%eax
 570:	0f 84 84 00 00 00    	je     5fa <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 576:	83 f8 63             	cmp    $0x63,%eax
 579:	0f 84 b7 00 00 00    	je     636 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 57f:	83 f8 25             	cmp    $0x25,%eax
 582:	0f 84 cc 00 00 00    	je     654 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 588:	ba 25 00 00 00       	mov    $0x25,%edx
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	e8 d8 fe ff ff       	call   46d <putc>
        putc(fd, c);
 595:	89 fa                	mov    %edi,%edx
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	e8 ce fe ff ff       	call   46d <putc>
      }
      state = 0;
 59f:	be 00 00 00 00       	mov    $0x0,%esi
 5a4:	eb 8d                	jmp    533 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 5a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5a9:	8b 17                	mov    (%edi),%edx
 5ab:	83 ec 0c             	sub    $0xc,%esp
 5ae:	6a 01                	push   $0x1
 5b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
 5b5:	8b 45 08             	mov    0x8(%ebp),%eax
 5b8:	e8 ca fe ff ff       	call   487 <printint>
        ap++;
 5bd:	83 c7 04             	add    $0x4,%edi
 5c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5c3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5c6:	be 00 00 00 00       	mov    $0x0,%esi
 5cb:	e9 63 ff ff ff       	jmp    533 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 5d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5d3:	8b 17                	mov    (%edi),%edx
 5d5:	83 ec 0c             	sub    $0xc,%esp
 5d8:	6a 00                	push   $0x0
 5da:	b9 10 00 00 00       	mov    $0x10,%ecx
 5df:	8b 45 08             	mov    0x8(%ebp),%eax
 5e2:	e8 a0 fe ff ff       	call   487 <printint>
        ap++;
 5e7:	83 c7 04             	add    $0x4,%edi
 5ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5ed:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5f0:	be 00 00 00 00       	mov    $0x0,%esi
 5f5:	e9 39 ff ff ff       	jmp    533 <printf+0x2c>
        s = (char*)*ap;
 5fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fd:	8b 30                	mov    (%eax),%esi
        ap++;
 5ff:	83 c0 04             	add    $0x4,%eax
 602:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 605:	85 f6                	test   %esi,%esi
 607:	75 28                	jne    631 <printf+0x12a>
          s = "(null)";
 609:	be 4b 08 00 00       	mov    $0x84b,%esi
 60e:	8b 7d 08             	mov    0x8(%ebp),%edi
 611:	eb 0d                	jmp    620 <printf+0x119>
          putc(fd, *s);
 613:	0f be d2             	movsbl %dl,%edx
 616:	89 f8                	mov    %edi,%eax
 618:	e8 50 fe ff ff       	call   46d <putc>
          s++;
 61d:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 620:	0f b6 16             	movzbl (%esi),%edx
 623:	84 d2                	test   %dl,%dl
 625:	75 ec                	jne    613 <printf+0x10c>
      state = 0;
 627:	be 00 00 00 00       	mov    $0x0,%esi
 62c:	e9 02 ff ff ff       	jmp    533 <printf+0x2c>
 631:	8b 7d 08             	mov    0x8(%ebp),%edi
 634:	eb ea                	jmp    620 <printf+0x119>
        putc(fd, *ap);
 636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 639:	0f be 17             	movsbl (%edi),%edx
 63c:	8b 45 08             	mov    0x8(%ebp),%eax
 63f:	e8 29 fe ff ff       	call   46d <putc>
        ap++;
 644:	83 c7 04             	add    $0x4,%edi
 647:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 64a:	be 00 00 00 00       	mov    $0x0,%esi
 64f:	e9 df fe ff ff       	jmp    533 <printf+0x2c>
        putc(fd, c);
 654:	89 fa                	mov    %edi,%edx
 656:	8b 45 08             	mov    0x8(%ebp),%eax
 659:	e8 0f fe ff ff       	call   46d <putc>
      state = 0;
 65e:	be 00 00 00 00       	mov    $0x0,%esi
 663:	e9 cb fe ff ff       	jmp    533 <printf+0x2c>
    }
  }
}
 668:	8d 65 f4             	lea    -0xc(%ebp),%esp
 66b:	5b                   	pop    %ebx
 66c:	5e                   	pop    %esi
 66d:	5f                   	pop    %edi
 66e:	5d                   	pop    %ebp
 66f:	c3                   	ret    

00000670 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 670:	55                   	push   %ebp
 671:	89 e5                	mov    %esp,%ebp
 673:	57                   	push   %edi
 674:	56                   	push   %esi
 675:	53                   	push   %ebx
 676:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 679:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67c:	a1 50 0b 00 00       	mov    0xb50,%eax
 681:	eb 02                	jmp    685 <free+0x15>
 683:	89 d0                	mov    %edx,%eax
 685:	39 c8                	cmp    %ecx,%eax
 687:	73 04                	jae    68d <free+0x1d>
 689:	39 08                	cmp    %ecx,(%eax)
 68b:	77 12                	ja     69f <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68d:	8b 10                	mov    (%eax),%edx
 68f:	39 c2                	cmp    %eax,%edx
 691:	77 f0                	ja     683 <free+0x13>
 693:	39 c8                	cmp    %ecx,%eax
 695:	72 08                	jb     69f <free+0x2f>
 697:	39 ca                	cmp    %ecx,%edx
 699:	77 04                	ja     69f <free+0x2f>
 69b:	89 d0                	mov    %edx,%eax
 69d:	eb e6                	jmp    685 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 69f:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6a2:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6a5:	8b 10                	mov    (%eax),%edx
 6a7:	39 d7                	cmp    %edx,%edi
 6a9:	74 19                	je     6c4 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6ab:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6ae:	8b 50 04             	mov    0x4(%eax),%edx
 6b1:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6b4:	39 ce                	cmp    %ecx,%esi
 6b6:	74 1b                	je     6d3 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6b8:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6ba:	a3 50 0b 00 00       	mov    %eax,0xb50
}
 6bf:	5b                   	pop    %ebx
 6c0:	5e                   	pop    %esi
 6c1:	5f                   	pop    %edi
 6c2:	5d                   	pop    %ebp
 6c3:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 6c4:	03 72 04             	add    0x4(%edx),%esi
 6c7:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ca:	8b 10                	mov    (%eax),%edx
 6cc:	8b 12                	mov    (%edx),%edx
 6ce:	89 53 f8             	mov    %edx,-0x8(%ebx)
 6d1:	eb db                	jmp    6ae <free+0x3e>
    p->s.size += bp->s.size;
 6d3:	03 53 fc             	add    -0x4(%ebx),%edx
 6d6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6d9:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6dc:	89 10                	mov    %edx,(%eax)
 6de:	eb da                	jmp    6ba <free+0x4a>

000006e0 <morecore>:

static Header*
morecore(uint nu)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	53                   	push   %ebx
 6e4:	83 ec 04             	sub    $0x4,%esp
 6e7:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 6e9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 6ee:	77 05                	ja     6f5 <morecore+0x15>
    nu = 4096;
 6f0:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 6f5:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 6fc:	83 ec 0c             	sub    $0xc,%esp
 6ff:	50                   	push   %eax
 700:	e8 40 fd ff ff       	call   445 <sbrk>
  if(p == (char*)-1)
 705:	83 c4 10             	add    $0x10,%esp
 708:	83 f8 ff             	cmp    $0xffffffff,%eax
 70b:	74 1c                	je     729 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 70d:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 710:	83 c0 08             	add    $0x8,%eax
 713:	83 ec 0c             	sub    $0xc,%esp
 716:	50                   	push   %eax
 717:	e8 54 ff ff ff       	call   670 <free>
  return freep;
 71c:	a1 50 0b 00 00       	mov    0xb50,%eax
 721:	83 c4 10             	add    $0x10,%esp
}
 724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 727:	c9                   	leave  
 728:	c3                   	ret    
    return 0;
 729:	b8 00 00 00 00       	mov    $0x0,%eax
 72e:	eb f4                	jmp    724 <morecore+0x44>

00000730 <malloc>:

void*
malloc(uint nbytes)
{
 730:	55                   	push   %ebp
 731:	89 e5                	mov    %esp,%ebp
 733:	53                   	push   %ebx
 734:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 737:	8b 45 08             	mov    0x8(%ebp),%eax
 73a:	8d 58 07             	lea    0x7(%eax),%ebx
 73d:	c1 eb 03             	shr    $0x3,%ebx
 740:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 743:	8b 0d 50 0b 00 00    	mov    0xb50,%ecx
 749:	85 c9                	test   %ecx,%ecx
 74b:	74 04                	je     751 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74d:	8b 01                	mov    (%ecx),%eax
 74f:	eb 4d                	jmp    79e <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 751:	c7 05 50 0b 00 00 54 	movl   $0xb54,0xb50
 758:	0b 00 00 
 75b:	c7 05 54 0b 00 00 54 	movl   $0xb54,0xb54
 762:	0b 00 00 
    base.s.size = 0;
 765:	c7 05 58 0b 00 00 00 	movl   $0x0,0xb58
 76c:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 76f:	b9 54 0b 00 00       	mov    $0xb54,%ecx
 774:	eb d7                	jmp    74d <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 776:	39 da                	cmp    %ebx,%edx
 778:	74 1a                	je     794 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 77a:	29 da                	sub    %ebx,%edx
 77c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 77f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 782:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 785:	89 0d 50 0b 00 00    	mov    %ecx,0xb50
      return (void*)(p + 1);
 78b:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 78e:	83 c4 04             	add    $0x4,%esp
 791:	5b                   	pop    %ebx
 792:	5d                   	pop    %ebp
 793:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 794:	8b 10                	mov    (%eax),%edx
 796:	89 11                	mov    %edx,(%ecx)
 798:	eb eb                	jmp    785 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	89 c1                	mov    %eax,%ecx
 79c:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 79e:	8b 50 04             	mov    0x4(%eax),%edx
 7a1:	39 da                	cmp    %ebx,%edx
 7a3:	73 d1                	jae    776 <malloc+0x46>
    if(p == freep)
 7a5:	39 05 50 0b 00 00    	cmp    %eax,0xb50
 7ab:	75 ed                	jne    79a <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 7ad:	89 d8                	mov    %ebx,%eax
 7af:	e8 2c ff ff ff       	call   6e0 <morecore>
 7b4:	85 c0                	test   %eax,%eax
 7b6:	75 e2                	jne    79a <malloc+0x6a>
        return 0;
 7b8:	b8 00 00 00 00       	mov    $0x0,%eax
 7bd:	eb cf                	jmp    78e <malloc+0x5e>

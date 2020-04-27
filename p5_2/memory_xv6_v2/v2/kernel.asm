
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc f0 b5 11 80       	mov    $0x8011b5f0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 0c 2c 10 80       	mov    $0x80102c0c,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 00 b6 11 80       	push   $0x8011b600
80100046:	e8 03 3d 00 00       	call   80103d4e <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 50 fd 11 80    	mov    0x8011fd50,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb fc fc 11 80    	cmp    $0x8011fcfc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 00 b6 11 80       	push   $0x8011b600
8010007c:	e8 32 3d 00 00       	call   80103db3 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 ae 3a 00 00       	call   80103b3a <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 4c fd 11 80    	mov    0x8011fd4c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb fc fc 11 80    	cmp    $0x8011fcfc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 00 b6 11 80       	push   $0x8011b600
801000ca:	e8 e4 3c 00 00       	call   80103db3 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 60 3a 00 00       	call   80103b3a <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 80 66 10 80       	push   $0x80106680
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 91 66 10 80       	push   $0x80106691
80100100:	68 00 b6 11 80       	push   $0x8011b600
80100105:	e8 08 3b 00 00       	call   80103c12 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 4c fd 11 80 fc 	movl   $0x8011fcfc,0x8011fd4c
80100111:	fc 11 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 50 fd 11 80 fc 	movl   $0x8011fcfc,0x8011fd50
8010011b:	fc 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 34 b6 11 80       	mov    $0x8011b634,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 50 fd 11 80       	mov    0x8011fd50,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 fc fc 11 80 	movl   $0x8011fcfc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 98 66 10 80       	push   $0x80106698
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 bf 39 00 00       	call   80103b07 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 50 fd 11 80       	mov    0x8011fd50,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 50 fd 11 80    	mov    %ebx,0x8011fd50
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb fc fc 11 80    	cmp    $0x8011fcfc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 83 1c 00 00       	call   80101e18 <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 17 3a 00 00       	call   80103bc4 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 58 1c 00 00       	call   80101e18 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 9f 66 10 80       	push   $0x8010669f
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 db 39 00 00       	call   80103bc4 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 90 39 00 00       	call   80103b89 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 00 b6 11 80 	movl   $0x8011b600,(%esp)
80100200:	e8 49 3b 00 00       	call   80103d4e <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 50 fd 11 80       	mov    0x8011fd50,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 fc fc 11 80 	movl   $0x8011fcfc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 50 fd 11 80       	mov    0x8011fd50,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 50 fd 11 80    	mov    %ebx,0x8011fd50
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 00 b6 11 80       	push   $0x8011b600
8010024c:	e8 62 3b 00 00       	call   80103db3 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 a6 66 10 80       	push   $0x801066a6
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 cf 13 00 00       	call   8010164f <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028a:	e8 bf 3a 00 00       	call   80103d4e <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 e0 ff 11 80       	mov    0x8011ffe0,%eax
8010029f:	3b 05 e4 ff 11 80    	cmp    0x8011ffe4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 00 31 00 00       	call   801033ac <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 10 80       	push   $0x8010a520
801002ba:	68 e0 ff 11 80       	push   $0x8011ffe0
801002bf:	e8 8f 35 00 00       	call   80103853 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 dd 3a 00 00       	call   80103db3 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 af 12 00 00       	call   8010158d <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 e0 ff 11 80    	mov    %edx,0x8011ffe0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 60 ff 11 80 	movzbl -0x7fee00a0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 e0 ff 11 80       	mov    %eax,0x8011ffe0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 10 80       	push   $0x8010a520
80100331:	e8 7d 3a 00 00       	call   80103db3 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 4f 12 00 00       	call   8010158d <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 c2 21 00 00       	call   80102521 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 ad 66 10 80       	push   $0x801066ad
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 fb 6f 10 80 	movl   $0x80106ffb,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 99 38 00 00       	call   80103c2d <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 c1 66 10 80       	push   $0x801066c1
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 c5 66 10 80       	push   $0x801066c5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 b6 39 00 00       	call   80103e75 <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 1c 39 00 00       	call   80103dfa <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 29 4d 00 00       	call   80105234 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 10 4d 00 00       	call   80105234 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 04 4d 00 00       	call   80105234 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 f8 4c 00 00       	call   80105234 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 f0 66 10 80 	movzbl -0x7fef9910(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 8c 10 00 00       	call   8010164f <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ca:	e8 7f 37 00 00       	call   80103d4e <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 a5 10 80       	push   $0x8010a520
801005f1:	e8 bd 37 00 00       	call   80103db3 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 8c 0f 00 00       	call   8010158d <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 a5 10 80       	mov    0x8010a554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 a5 10 80       	push   $0x8010a520
80100638:	e8 11 37 00 00       	call   80103d4e <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 df 66 10 80       	push   $0x801066df
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be d8 66 10 80       	mov    $0x801066d8,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 a5 10 80       	push   $0x8010a520
80100734:	e8 7a 36 00 00       	call   80103db3 <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 fa 35 00 00       	call   80103d4e <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 e8 ff 11 80       	mov    0x8011ffe8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 e0 ff 11 80    	sub    0x8011ffe0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 e8 ff 11 80    	mov    %edx,0x8011ffe8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 60 ff 11 80    	mov    %cl,-0x7fee00a0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 e0 ff 11 80       	mov    0x8011ffe0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 e8 ff 11 80    	cmp    %eax,0x8011ffe8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 e8 ff 11 80       	mov    0x8011ffe8,%eax
801007d1:	a3 e4 ff 11 80       	mov    %eax,0x8011ffe4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 e0 ff 11 80       	push   $0x8011ffe0
801007de:	e8 d5 31 00 00       	call   801039b8 <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 e8 ff 11 80       	mov    %eax,0x8011ffe8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 e8 ff 11 80       	mov    0x8011ffe8,%eax
801007fc:	3b 05 e4 ff 11 80    	cmp    0x8011ffe4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 60 ff 11 80 0a 	cmpb   $0xa,-0x7fee00a0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 e8 ff 11 80       	mov    0x8011ffe8,%eax
8010084f:	3b 05 e4 ff 11 80    	cmp    0x8011ffe4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 e8 ff 11 80       	mov    %eax,0x8011ffe8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 10 80       	push   $0x8010a520
80100873:	e8 3b 35 00 00       	call   80103db3 <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 c9 31 00 00       	call   80103a55 <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 e8 66 10 80       	push   $0x801066e8
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 6f 33 00 00       	call   80103c12 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 ac 09 12 80 ac 	movl   $0x801005ac,0x801209ac
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 a8 09 12 80 68 	movl   $0x80100268,0x801209a8
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 bd 16 00 00       	call   80101f8a <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 c9 2a 00 00       	call   801033ac <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 63 20 00 00       	call   80102951 <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 f4 12 00 00       	call   80101bed <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 82 0c 00 00       	call   8010158d <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 63 0e 00 00       	call   8010177f <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 e9 02 00 00    	je     80100c15 <exec+0x343>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 ff 0d 00 00       	call   80101734 <iunlockput>
    end_op();
80100935:	e8 91 20 00 00       	call   801029cb <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 7c 20 00 00       	call   801029cb <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 01 67 10 80       	push   $0x80106701
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 93 5a 00 00       	call   8010640a <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 12 01 00 00    	je     80100a97 <exec+0x1c5>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 9e 00 00 00    	jle    80100a50 <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 b7 0d 00 00       	call   8010177f <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 c3 00 00 00    	jne    80100a97 <exec+0x1c5>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 a8 00 00 00    	jb     80100a97 <exec+0x1c5>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 9c 00 00 00    	jb     80100a97 <exec+0x1c5>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz, curproc->pid)) == 0)  // revise
801009fb:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a01:	ff 71 10             	pushl  0x10(%ecx)
80100a04:	50                   	push   %eax
80100a05:	57                   	push   %edi
80100a06:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a0c:	e8 96 58 00 00       	call   801062a7 <allocuvm>
80100a11:	89 c7                	mov    %eax,%edi
80100a13:	83 c4 10             	add    $0x10,%esp
80100a16:	85 c0                	test   %eax,%eax
80100a18:	74 7d                	je     80100a97 <exec+0x1c5>
    if(ph.vaddr % PGSIZE != 0)
80100a1a:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a20:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a25:	75 70                	jne    80100a97 <exec+0x1c5>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a27:	83 ec 0c             	sub    $0xc,%esp
80100a2a:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a30:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a36:	53                   	push   %ebx
80100a37:	50                   	push   %eax
80100a38:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a3e:	e8 32 57 00 00       	call   80106175 <loaduvm>
80100a43:	83 c4 20             	add    $0x20,%esp
80100a46:	85 c0                	test   %eax,%eax
80100a48:	0f 89 49 ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a4e:	eb 47                	jmp    80100a97 <exec+0x1c5>
  iunlockput(ip);
80100a50:	83 ec 0c             	sub    $0xc,%esp
80100a53:	53                   	push   %ebx
80100a54:	e8 db 0c 00 00       	call   80101734 <iunlockput>
  end_op();
80100a59:	e8 6d 1f 00 00       	call   801029cb <end_op>
  sz = PGROUNDUP(sz);
80100a5e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE, curproc->pid)) == 0) // revise
80100a69:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a6f:	ff 71 10             	pushl  0x10(%ecx)
80100a72:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a78:	52                   	push   %edx
80100a79:	50                   	push   %eax
80100a7a:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a80:	e8 22 58 00 00       	call   801062a7 <allocuvm>
80100a85:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a8b:	83 c4 20             	add    $0x20,%esp
80100a8e:	85 c0                	test   %eax,%eax
80100a90:	75 24                	jne    80100ab6 <exec+0x1e4>
  ip = 0;
80100a92:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a97:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a9d:	85 c0                	test   %eax,%eax
80100a9f:	0f 84 7f fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100aa5:	83 ec 0c             	sub    $0xc,%esp
80100aa8:	50                   	push   %eax
80100aa9:	e8 ec 58 00 00       	call   8010639a <freevm>
80100aae:	83 c4 10             	add    $0x10,%esp
80100ab1:	e9 6e fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ab6:	89 c7                	mov    %eax,%edi
80100ab8:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100abe:	83 ec 08             	sub    $0x8,%esp
80100ac1:	50                   	push   %eax
80100ac2:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100ac8:	e8 ca 59 00 00       	call   80106497 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100acd:	83 c4 10             	add    $0x10,%esp
80100ad0:	be 00 00 00 00       	mov    $0x0,%esi
80100ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad8:	8d 1c b0             	lea    (%eax,%esi,4),%ebx
80100adb:	8b 03                	mov    (%ebx),%eax
80100add:	85 c0                	test   %eax,%eax
80100adf:	74 4d                	je     80100b2e <exec+0x25c>
    if(argc >= MAXARG)
80100ae1:	83 fe 1f             	cmp    $0x1f,%esi
80100ae4:	0f 87 0d 01 00 00    	ja     80100bf7 <exec+0x325>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100aea:	83 ec 0c             	sub    $0xc,%esp
80100aed:	50                   	push   %eax
80100aee:	e8 a9 34 00 00       	call   80103f9c <strlen>
80100af3:	29 c7                	sub    %eax,%edi
80100af5:	83 ef 01             	sub    $0x1,%edi
80100af8:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100afb:	83 c4 04             	add    $0x4,%esp
80100afe:	ff 33                	pushl  (%ebx)
80100b00:	e8 97 34 00 00       	call   80103f9c <strlen>
80100b05:	83 c0 01             	add    $0x1,%eax
80100b08:	50                   	push   %eax
80100b09:	ff 33                	pushl  (%ebx)
80100b0b:	57                   	push   %edi
80100b0c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b12:	e8 db 5a 00 00       	call   801065f2 <copyout>
80100b17:	83 c4 20             	add    $0x20,%esp
80100b1a:	85 c0                	test   %eax,%eax
80100b1c:	0f 88 df 00 00 00    	js     80100c01 <exec+0x32f>
    ustack[3+argc] = sp;
80100b22:	89 bc b5 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%esi,4)
  for(argc = 0; argv[argc]; argc++) {
80100b29:	83 c6 01             	add    $0x1,%esi
80100b2c:	eb a7                	jmp    80100ad5 <exec+0x203>
  ustack[3+argc] = 0;
80100b2e:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80100b35:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b39:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b40:	ff ff ff 
  ustack[1] = argc;
80100b43:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b49:	8d 04 b5 04 00 00 00 	lea    0x4(,%esi,4),%eax
80100b50:	89 f9                	mov    %edi,%ecx
80100b52:	29 c1                	sub    %eax,%ecx
80100b54:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b5a:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
80100b61:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b63:	50                   	push   %eax
80100b64:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b6a:	50                   	push   %eax
80100b6b:	57                   	push   %edi
80100b6c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b72:	e8 7b 5a 00 00       	call   801065f2 <copyout>
80100b77:	83 c4 10             	add    $0x10,%esp
80100b7a:	85 c0                	test   %eax,%eax
80100b7c:	0f 88 89 00 00 00    	js     80100c0b <exec+0x339>
  for(last=s=path; *s; s++)
80100b82:	8b 55 08             	mov    0x8(%ebp),%edx
80100b85:	89 d0                	mov    %edx,%eax
80100b87:	eb 03                	jmp    80100b8c <exec+0x2ba>
80100b89:	83 c0 01             	add    $0x1,%eax
80100b8c:	0f b6 08             	movzbl (%eax),%ecx
80100b8f:	84 c9                	test   %cl,%cl
80100b91:	74 0a                	je     80100b9d <exec+0x2cb>
    if(*s == '/')
80100b93:	80 f9 2f             	cmp    $0x2f,%cl
80100b96:	75 f1                	jne    80100b89 <exec+0x2b7>
      last = s+1;
80100b98:	8d 50 01             	lea    0x1(%eax),%edx
80100b9b:	eb ec                	jmp    80100b89 <exec+0x2b7>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b9d:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100ba3:	89 f0                	mov    %esi,%eax
80100ba5:	83 c0 6c             	add    $0x6c,%eax
80100ba8:	83 ec 04             	sub    $0x4,%esp
80100bab:	6a 10                	push   $0x10
80100bad:	52                   	push   %edx
80100bae:	50                   	push   %eax
80100baf:	e8 ad 33 00 00       	call   80103f61 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bb4:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bb7:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bbd:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bc0:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bc6:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bd1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bd4:	8b 46 18             	mov    0x18(%esi),%eax
80100bd7:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bda:	89 34 24             	mov    %esi,(%esp)
80100bdd:	e8 0d 54 00 00       	call   80105fef <switchuvm>
  freevm(oldpgdir);
80100be2:	89 1c 24             	mov    %ebx,(%esp)
80100be5:	e8 b0 57 00 00       	call   8010639a <freevm>
  return 0;
80100bea:	83 c4 10             	add    $0x10,%esp
80100bed:	b8 00 00 00 00       	mov    $0x0,%eax
80100bf2:	e9 4b fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100bf7:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfc:	e9 96 fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c01:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c06:	e9 8c fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c10:	e9 82 fe ff ff       	jmp    80100a97 <exec+0x1c5>
  return -1;
80100c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c1a:	e9 23 fd ff ff       	jmp    80100942 <exec+0x70>

80100c1f <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c1f:	55                   	push   %ebp
80100c20:	89 e5                	mov    %esp,%ebp
80100c22:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c25:	68 0d 67 10 80       	push   $0x8010670d
80100c2a:	68 00 00 12 80       	push   $0x80120000
80100c2f:	e8 de 2f 00 00       	call   80103c12 <initlock>
}
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	c9                   	leave  
80100c38:	c3                   	ret    

80100c39 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c39:	55                   	push   %ebp
80100c3a:	89 e5                	mov    %esp,%ebp
80100c3c:	53                   	push   %ebx
80100c3d:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c40:	68 00 00 12 80       	push   $0x80120000
80100c45:	e8 04 31 00 00       	call   80103d4e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c4a:	83 c4 10             	add    $0x10,%esp
80100c4d:	bb 34 00 12 80       	mov    $0x80120034,%ebx
80100c52:	81 fb 94 09 12 80    	cmp    $0x80120994,%ebx
80100c58:	73 29                	jae    80100c83 <filealloc+0x4a>
    if(f->ref == 0){
80100c5a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c5e:	74 05                	je     80100c65 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c60:	83 c3 18             	add    $0x18,%ebx
80100c63:	eb ed                	jmp    80100c52 <filealloc+0x19>
      f->ref = 1;
80100c65:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c6c:	83 ec 0c             	sub    $0xc,%esp
80100c6f:	68 00 00 12 80       	push   $0x80120000
80100c74:	e8 3a 31 00 00       	call   80103db3 <release>
      return f;
80100c79:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c7c:	89 d8                	mov    %ebx,%eax
80100c7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c81:	c9                   	leave  
80100c82:	c3                   	ret    
  release(&ftable.lock);
80100c83:	83 ec 0c             	sub    $0xc,%esp
80100c86:	68 00 00 12 80       	push   $0x80120000
80100c8b:	e8 23 31 00 00       	call   80103db3 <release>
  return 0;
80100c90:	83 c4 10             	add    $0x10,%esp
80100c93:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c98:	eb e2                	jmp    80100c7c <filealloc+0x43>

80100c9a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c9a:	55                   	push   %ebp
80100c9b:	89 e5                	mov    %esp,%ebp
80100c9d:	53                   	push   %ebx
80100c9e:	83 ec 10             	sub    $0x10,%esp
80100ca1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100ca4:	68 00 00 12 80       	push   $0x80120000
80100ca9:	e8 a0 30 00 00       	call   80103d4e <acquire>
  if(f->ref < 1)
80100cae:	8b 43 04             	mov    0x4(%ebx),%eax
80100cb1:	83 c4 10             	add    $0x10,%esp
80100cb4:	85 c0                	test   %eax,%eax
80100cb6:	7e 1a                	jle    80100cd2 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cb8:	83 c0 01             	add    $0x1,%eax
80100cbb:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cbe:	83 ec 0c             	sub    $0xc,%esp
80100cc1:	68 00 00 12 80       	push   $0x80120000
80100cc6:	e8 e8 30 00 00       	call   80103db3 <release>
  return f;
}
80100ccb:	89 d8                	mov    %ebx,%eax
80100ccd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cd0:	c9                   	leave  
80100cd1:	c3                   	ret    
    panic("filedup");
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	68 14 67 10 80       	push   $0x80106714
80100cda:	e8 69 f6 ff ff       	call   80100348 <panic>

80100cdf <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cdf:	55                   	push   %ebp
80100ce0:	89 e5                	mov    %esp,%ebp
80100ce2:	53                   	push   %ebx
80100ce3:	83 ec 30             	sub    $0x30,%esp
80100ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100ce9:	68 00 00 12 80       	push   $0x80120000
80100cee:	e8 5b 30 00 00       	call   80103d4e <acquire>
  if(f->ref < 1)
80100cf3:	8b 43 04             	mov    0x4(%ebx),%eax
80100cf6:	83 c4 10             	add    $0x10,%esp
80100cf9:	85 c0                	test   %eax,%eax
80100cfb:	7e 1f                	jle    80100d1c <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cfd:	83 e8 01             	sub    $0x1,%eax
80100d00:	89 43 04             	mov    %eax,0x4(%ebx)
80100d03:	85 c0                	test   %eax,%eax
80100d05:	7e 22                	jle    80100d29 <fileclose+0x4a>
    release(&ftable.lock);
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	68 00 00 12 80       	push   $0x80120000
80100d0f:	e8 9f 30 00 00       	call   80103db3 <release>
    return;
80100d14:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d1a:	c9                   	leave  
80100d1b:	c3                   	ret    
    panic("fileclose");
80100d1c:	83 ec 0c             	sub    $0xc,%esp
80100d1f:	68 1c 67 10 80       	push   $0x8010671c
80100d24:	e8 1f f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d29:	8b 03                	mov    (%ebx),%eax
80100d2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d2e:	8b 43 08             	mov    0x8(%ebx),%eax
80100d31:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d34:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d3a:	8b 43 10             	mov    0x10(%ebx),%eax
80100d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d40:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d4d:	83 ec 0c             	sub    $0xc,%esp
80100d50:	68 00 00 12 80       	push   $0x80120000
80100d55:	e8 59 30 00 00       	call   80103db3 <release>
  if(ff.type == FD_PIPE)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	83 c4 10             	add    $0x10,%esp
80100d60:	83 f8 01             	cmp    $0x1,%eax
80100d63:	74 1f                	je     80100d84 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d65:	83 f8 02             	cmp    $0x2,%eax
80100d68:	75 ad                	jne    80100d17 <fileclose+0x38>
    begin_op();
80100d6a:	e8 e2 1b 00 00       	call   80102951 <begin_op>
    iput(ff.ip);
80100d6f:	83 ec 0c             	sub    $0xc,%esp
80100d72:	ff 75 f0             	pushl  -0x10(%ebp)
80100d75:	e8 1a 09 00 00       	call   80101694 <iput>
    end_op();
80100d7a:	e8 4c 1c 00 00       	call   801029cb <end_op>
80100d7f:	83 c4 10             	add    $0x10,%esp
80100d82:	eb 93                	jmp    80100d17 <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d84:	83 ec 08             	sub    $0x8,%esp
80100d87:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d8b:	50                   	push   %eax
80100d8c:	ff 75 ec             	pushl  -0x14(%ebp)
80100d8f:	e8 3e 22 00 00       	call   80102fd2 <pipeclose>
80100d94:	83 c4 10             	add    $0x10,%esp
80100d97:	e9 7b ff ff ff       	jmp    80100d17 <fileclose+0x38>

80100d9c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d9c:	55                   	push   %ebp
80100d9d:	89 e5                	mov    %esp,%ebp
80100d9f:	53                   	push   %ebx
80100da0:	83 ec 04             	sub    $0x4,%esp
80100da3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100da6:	83 3b 02             	cmpl   $0x2,(%ebx)
80100da9:	75 31                	jne    80100ddc <filestat+0x40>
    ilock(f->ip);
80100dab:	83 ec 0c             	sub    $0xc,%esp
80100dae:	ff 73 10             	pushl  0x10(%ebx)
80100db1:	e8 d7 07 00 00       	call   8010158d <ilock>
    stati(f->ip, st);
80100db6:	83 c4 08             	add    $0x8,%esp
80100db9:	ff 75 0c             	pushl  0xc(%ebp)
80100dbc:	ff 73 10             	pushl  0x10(%ebx)
80100dbf:	e8 90 09 00 00       	call   80101754 <stati>
    iunlock(f->ip);
80100dc4:	83 c4 04             	add    $0x4,%esp
80100dc7:	ff 73 10             	pushl  0x10(%ebx)
80100dca:	e8 80 08 00 00       	call   8010164f <iunlock>
    return 0;
80100dcf:	83 c4 10             	add    $0x10,%esp
80100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dda:	c9                   	leave  
80100ddb:	c3                   	ret    
  return -1;
80100ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100de1:	eb f4                	jmp    80100dd7 <filestat+0x3b>

80100de3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100de3:	55                   	push   %ebp
80100de4:	89 e5                	mov    %esp,%ebp
80100de6:	56                   	push   %esi
80100de7:	53                   	push   %ebx
80100de8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100deb:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100def:	74 70                	je     80100e61 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100df1:	8b 03                	mov    (%ebx),%eax
80100df3:	83 f8 01             	cmp    $0x1,%eax
80100df6:	74 44                	je     80100e3c <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100df8:	83 f8 02             	cmp    $0x2,%eax
80100dfb:	75 57                	jne    80100e54 <fileread+0x71>
    ilock(f->ip);
80100dfd:	83 ec 0c             	sub    $0xc,%esp
80100e00:	ff 73 10             	pushl  0x10(%ebx)
80100e03:	e8 85 07 00 00       	call   8010158d <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e08:	ff 75 10             	pushl  0x10(%ebp)
80100e0b:	ff 73 14             	pushl  0x14(%ebx)
80100e0e:	ff 75 0c             	pushl  0xc(%ebp)
80100e11:	ff 73 10             	pushl  0x10(%ebx)
80100e14:	e8 66 09 00 00       	call   8010177f <readi>
80100e19:	89 c6                	mov    %eax,%esi
80100e1b:	83 c4 20             	add    $0x20,%esp
80100e1e:	85 c0                	test   %eax,%eax
80100e20:	7e 03                	jle    80100e25 <fileread+0x42>
      f->off += r;
80100e22:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e25:	83 ec 0c             	sub    $0xc,%esp
80100e28:	ff 73 10             	pushl  0x10(%ebx)
80100e2b:	e8 1f 08 00 00       	call   8010164f <iunlock>
    return r;
80100e30:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e33:	89 f0                	mov    %esi,%eax
80100e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e38:	5b                   	pop    %ebx
80100e39:	5e                   	pop    %esi
80100e3a:	5d                   	pop    %ebp
80100e3b:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e3c:	83 ec 04             	sub    $0x4,%esp
80100e3f:	ff 75 10             	pushl  0x10(%ebp)
80100e42:	ff 75 0c             	pushl  0xc(%ebp)
80100e45:	ff 73 0c             	pushl  0xc(%ebx)
80100e48:	e8 dd 22 00 00       	call   8010312a <piperead>
80100e4d:	89 c6                	mov    %eax,%esi
80100e4f:	83 c4 10             	add    $0x10,%esp
80100e52:	eb df                	jmp    80100e33 <fileread+0x50>
  panic("fileread");
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	68 26 67 10 80       	push   $0x80106726
80100e5c:	e8 e7 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e61:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e66:	eb cb                	jmp    80100e33 <fileread+0x50>

80100e68 <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e68:	55                   	push   %ebp
80100e69:	89 e5                	mov    %esp,%ebp
80100e6b:	57                   	push   %edi
80100e6c:	56                   	push   %esi
80100e6d:	53                   	push   %ebx
80100e6e:	83 ec 1c             	sub    $0x1c,%esp
80100e71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e74:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e78:	0f 84 c5 00 00 00    	je     80100f43 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e7e:	8b 03                	mov    (%ebx),%eax
80100e80:	83 f8 01             	cmp    $0x1,%eax
80100e83:	74 10                	je     80100e95 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e85:	83 f8 02             	cmp    $0x2,%eax
80100e88:	0f 85 a8 00 00 00    	jne    80100f36 <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e8e:	bf 00 00 00 00       	mov    $0x0,%edi
80100e93:	eb 67                	jmp    80100efc <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e95:	83 ec 04             	sub    $0x4,%esp
80100e98:	ff 75 10             	pushl  0x10(%ebp)
80100e9b:	ff 75 0c             	pushl  0xc(%ebp)
80100e9e:	ff 73 0c             	pushl  0xc(%ebx)
80100ea1:	e8 b8 21 00 00       	call   8010305e <pipewrite>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	e9 80 00 00 00       	jmp    80100f2e <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100eae:	e8 9e 1a 00 00       	call   80102951 <begin_op>
      ilock(f->ip);
80100eb3:	83 ec 0c             	sub    $0xc,%esp
80100eb6:	ff 73 10             	pushl  0x10(%ebx)
80100eb9:	e8 cf 06 00 00       	call   8010158d <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ebe:	89 f8                	mov    %edi,%eax
80100ec0:	03 45 0c             	add    0xc(%ebp),%eax
80100ec3:	ff 75 e4             	pushl  -0x1c(%ebp)
80100ec6:	ff 73 14             	pushl  0x14(%ebx)
80100ec9:	50                   	push   %eax
80100eca:	ff 73 10             	pushl  0x10(%ebx)
80100ecd:	e8 aa 09 00 00       	call   8010187c <writei>
80100ed2:	89 c6                	mov    %eax,%esi
80100ed4:	83 c4 20             	add    $0x20,%esp
80100ed7:	85 c0                	test   %eax,%eax
80100ed9:	7e 03                	jle    80100ede <filewrite+0x76>
        f->off += r;
80100edb:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ede:	83 ec 0c             	sub    $0xc,%esp
80100ee1:	ff 73 10             	pushl  0x10(%ebx)
80100ee4:	e8 66 07 00 00       	call   8010164f <iunlock>
      end_op();
80100ee9:	e8 dd 1a 00 00       	call   801029cb <end_op>

      if(r < 0)
80100eee:	83 c4 10             	add    $0x10,%esp
80100ef1:	85 f6                	test   %esi,%esi
80100ef3:	78 31                	js     80100f26 <filewrite+0xbe>
        break;
      if(r != n1)
80100ef5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100ef8:	75 1f                	jne    80100f19 <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100efa:	01 f7                	add    %esi,%edi
    while(i < n){
80100efc:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100eff:	7d 25                	jge    80100f26 <filewrite+0xbe>
      int n1 = n - i;
80100f01:	8b 45 10             	mov    0x10(%ebp),%eax
80100f04:	29 f8                	sub    %edi,%eax
80100f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100f09:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f0e:	7e 9e                	jle    80100eae <filewrite+0x46>
        n1 = max;
80100f10:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f17:	eb 95                	jmp    80100eae <filewrite+0x46>
        panic("short filewrite");
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	68 2f 67 10 80       	push   $0x8010672f
80100f21:	e8 22 f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f26:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f29:	75 1f                	jne    80100f4a <filewrite+0xe2>
80100f2b:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f31:	5b                   	pop    %ebx
80100f32:	5e                   	pop    %esi
80100f33:	5f                   	pop    %edi
80100f34:	5d                   	pop    %ebp
80100f35:	c3                   	ret    
  panic("filewrite");
80100f36:	83 ec 0c             	sub    $0xc,%esp
80100f39:	68 35 67 10 80       	push   $0x80106735
80100f3e:	e8 05 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f48:	eb e4                	jmp    80100f2e <filewrite+0xc6>
    return i == n ? n : -1;
80100f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f4f:	eb dd                	jmp    80100f2e <filewrite+0xc6>

80100f51 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f51:	55                   	push   %ebp
80100f52:	89 e5                	mov    %esp,%ebp
80100f54:	57                   	push   %edi
80100f55:	56                   	push   %esi
80100f56:	53                   	push   %ebx
80100f57:	83 ec 0c             	sub    $0xc,%esp
80100f5a:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f5c:	eb 03                	jmp    80100f61 <skipelem+0x10>
    path++;
80100f5e:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f61:	0f b6 10             	movzbl (%eax),%edx
80100f64:	80 fa 2f             	cmp    $0x2f,%dl
80100f67:	74 f5                	je     80100f5e <skipelem+0xd>
  if(*path == 0)
80100f69:	84 d2                	test   %dl,%dl
80100f6b:	74 59                	je     80100fc6 <skipelem+0x75>
80100f6d:	89 c3                	mov    %eax,%ebx
80100f6f:	eb 03                	jmp    80100f74 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f71:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f74:	0f b6 13             	movzbl (%ebx),%edx
80100f77:	80 fa 2f             	cmp    $0x2f,%dl
80100f7a:	0f 95 c1             	setne  %cl
80100f7d:	84 d2                	test   %dl,%dl
80100f7f:	0f 95 c2             	setne  %dl
80100f82:	84 d1                	test   %dl,%cl
80100f84:	75 eb                	jne    80100f71 <skipelem+0x20>
  len = path - s;
80100f86:	89 de                	mov    %ebx,%esi
80100f88:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f8a:	83 fe 0d             	cmp    $0xd,%esi
80100f8d:	7e 11                	jle    80100fa0 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f8f:	83 ec 04             	sub    $0x4,%esp
80100f92:	6a 0e                	push   $0xe
80100f94:	50                   	push   %eax
80100f95:	57                   	push   %edi
80100f96:	e8 da 2e 00 00       	call   80103e75 <memmove>
80100f9b:	83 c4 10             	add    $0x10,%esp
80100f9e:	eb 17                	jmp    80100fb7 <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fa0:	83 ec 04             	sub    $0x4,%esp
80100fa3:	56                   	push   %esi
80100fa4:	50                   	push   %eax
80100fa5:	57                   	push   %edi
80100fa6:	e8 ca 2e 00 00       	call   80103e75 <memmove>
    name[len] = 0;
80100fab:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100faf:	83 c4 10             	add    $0x10,%esp
80100fb2:	eb 03                	jmp    80100fb7 <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fb4:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fb7:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fba:	74 f8                	je     80100fb4 <skipelem+0x63>
  return path;
}
80100fbc:	89 d8                	mov    %ebx,%eax
80100fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc1:	5b                   	pop    %ebx
80100fc2:	5e                   	pop    %esi
80100fc3:	5f                   	pop    %edi
80100fc4:	5d                   	pop    %ebp
80100fc5:	c3                   	ret    
    return 0;
80100fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fcb:	eb ef                	jmp    80100fbc <skipelem+0x6b>

80100fcd <bzero>:
{
80100fcd:	55                   	push   %ebp
80100fce:	89 e5                	mov    %esp,%ebp
80100fd0:	53                   	push   %ebx
80100fd1:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fd4:	52                   	push   %edx
80100fd5:	50                   	push   %eax
80100fd6:	e8 91 f1 ff ff       	call   8010016c <bread>
80100fdb:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fdd:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fe0:	83 c4 0c             	add    $0xc,%esp
80100fe3:	68 00 02 00 00       	push   $0x200
80100fe8:	6a 00                	push   $0x0
80100fea:	50                   	push   %eax
80100feb:	e8 0a 2e 00 00       	call   80103dfa <memset>
  log_write(bp);
80100ff0:	89 1c 24             	mov    %ebx,(%esp)
80100ff3:	e8 82 1a 00 00       	call   80102a7a <log_write>
  brelse(bp);
80100ff8:	89 1c 24             	mov    %ebx,(%esp)
80100ffb:	e8 d5 f1 ff ff       	call   801001d5 <brelse>
}
80101000:	83 c4 10             	add    $0x10,%esp
80101003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101006:	c9                   	leave  
80101007:	c3                   	ret    

80101008 <balloc>:
{
80101008:	55                   	push   %ebp
80101009:	89 e5                	mov    %esp,%ebp
8010100b:	57                   	push   %edi
8010100c:	56                   	push   %esi
8010100d:	53                   	push   %ebx
8010100e:	83 ec 1c             	sub    $0x1c,%esp
80101011:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101014:	be 00 00 00 00       	mov    $0x0,%esi
80101019:	eb 14                	jmp    8010102f <balloc+0x27>
    brelse(bp);
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101021:	e8 af f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101026:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010102c:	83 c4 10             	add    $0x10,%esp
8010102f:	39 35 00 0a 12 80    	cmp    %esi,0x80120a00
80101035:	76 75                	jbe    801010ac <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
80101037:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
8010103d:	85 f6                	test   %esi,%esi
8010103f:	0f 49 c6             	cmovns %esi,%eax
80101042:	c1 f8 0c             	sar    $0xc,%eax
80101045:	03 05 18 0a 12 80    	add    0x80120a18,%eax
8010104b:	83 ec 08             	sub    $0x8,%esp
8010104e:	50                   	push   %eax
8010104f:	ff 75 d8             	pushl  -0x28(%ebp)
80101052:	e8 15 f1 ff ff       	call   8010016c <bread>
80101057:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010105a:	83 c4 10             	add    $0x10,%esp
8010105d:	b8 00 00 00 00       	mov    $0x0,%eax
80101062:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80101067:	7f b2                	jg     8010101b <balloc+0x13>
80101069:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
8010106c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
8010106f:	3b 1d 00 0a 12 80    	cmp    0x80120a00,%ebx
80101075:	73 a4                	jae    8010101b <balloc+0x13>
      m = 1 << (bi % 8);
80101077:	99                   	cltd   
80101078:	c1 ea 1d             	shr    $0x1d,%edx
8010107b:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010107e:	83 e1 07             	and    $0x7,%ecx
80101081:	29 d1                	sub    %edx,%ecx
80101083:	ba 01 00 00 00       	mov    $0x1,%edx
80101088:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010108a:	8d 48 07             	lea    0x7(%eax),%ecx
8010108d:	85 c0                	test   %eax,%eax
8010108f:	0f 49 c8             	cmovns %eax,%ecx
80101092:	c1 f9 03             	sar    $0x3,%ecx
80101095:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80101098:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010109b:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
801010a0:	0f b6 f9             	movzbl %cl,%edi
801010a3:	85 d7                	test   %edx,%edi
801010a5:	74 12                	je     801010b9 <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010a7:	83 c0 01             	add    $0x1,%eax
801010aa:	eb b6                	jmp    80101062 <balloc+0x5a>
  panic("balloc: out of blocks");
801010ac:	83 ec 0c             	sub    $0xc,%esp
801010af:	68 3f 67 10 80       	push   $0x8010673f
801010b4:	e8 8f f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010b9:	09 ca                	or     %ecx,%edx
801010bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010be:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010c1:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	89 c6                	mov    %eax,%esi
801010ca:	50                   	push   %eax
801010cb:	e8 aa 19 00 00       	call   80102a7a <log_write>
        brelse(bp);
801010d0:	89 34 24             	mov    %esi,(%esp)
801010d3:	e8 fd f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010d8:	89 da                	mov    %ebx,%edx
801010da:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010dd:	e8 eb fe ff ff       	call   80100fcd <bzero>
}
801010e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010e8:	5b                   	pop    %ebx
801010e9:	5e                   	pop    %esi
801010ea:	5f                   	pop    %edi
801010eb:	5d                   	pop    %ebp
801010ec:	c3                   	ret    

801010ed <bmap>:
{
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	57                   	push   %edi
801010f1:	56                   	push   %esi
801010f2:	53                   	push   %ebx
801010f3:	83 ec 1c             	sub    $0x1c,%esp
801010f6:	89 c6                	mov    %eax,%esi
801010f8:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801010fa:	83 fa 0b             	cmp    $0xb,%edx
801010fd:	77 17                	ja     80101116 <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
801010ff:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
80101103:	85 db                	test   %ebx,%ebx
80101105:	75 4a                	jne    80101151 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101107:	8b 00                	mov    (%eax),%eax
80101109:	e8 fa fe ff ff       	call   80101008 <balloc>
8010110e:	89 c3                	mov    %eax,%ebx
80101110:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101114:	eb 3b                	jmp    80101151 <bmap+0x64>
  bn -= NDIRECT;
80101116:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
80101119:	83 fb 7f             	cmp    $0x7f,%ebx
8010111c:	77 68                	ja     80101186 <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
8010111e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101124:	85 c0                	test   %eax,%eax
80101126:	74 33                	je     8010115b <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101128:	83 ec 08             	sub    $0x8,%esp
8010112b:	50                   	push   %eax
8010112c:	ff 36                	pushl  (%esi)
8010112e:	e8 39 f0 ff ff       	call   8010016c <bread>
80101133:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101135:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
80101139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010113c:	8b 18                	mov    (%eax),%ebx
8010113e:	83 c4 10             	add    $0x10,%esp
80101141:	85 db                	test   %ebx,%ebx
80101143:	74 25                	je     8010116a <bmap+0x7d>
    brelse(bp);
80101145:	83 ec 0c             	sub    $0xc,%esp
80101148:	57                   	push   %edi
80101149:	e8 87 f0 ff ff       	call   801001d5 <brelse>
    return addr;
8010114e:	83 c4 10             	add    $0x10,%esp
}
80101151:	89 d8                	mov    %ebx,%eax
80101153:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101156:	5b                   	pop    %ebx
80101157:	5e                   	pop    %esi
80101158:	5f                   	pop    %edi
80101159:	5d                   	pop    %ebp
8010115a:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010115b:	8b 06                	mov    (%esi),%eax
8010115d:	e8 a6 fe ff ff       	call   80101008 <balloc>
80101162:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101168:	eb be                	jmp    80101128 <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
8010116a:	8b 06                	mov    (%esi),%eax
8010116c:	e8 97 fe ff ff       	call   80101008 <balloc>
80101171:	89 c3                	mov    %eax,%ebx
80101173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101176:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
80101178:	83 ec 0c             	sub    $0xc,%esp
8010117b:	57                   	push   %edi
8010117c:	e8 f9 18 00 00       	call   80102a7a <log_write>
80101181:	83 c4 10             	add    $0x10,%esp
80101184:	eb bf                	jmp    80101145 <bmap+0x58>
  panic("bmap: out of range");
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	68 55 67 10 80       	push   $0x80106755
8010118e:	e8 b5 f1 ff ff       	call   80100348 <panic>

80101193 <iget>:
{
80101193:	55                   	push   %ebp
80101194:	89 e5                	mov    %esp,%ebp
80101196:	57                   	push   %edi
80101197:	56                   	push   %esi
80101198:	53                   	push   %ebx
80101199:	83 ec 28             	sub    $0x28,%esp
8010119c:	89 c7                	mov    %eax,%edi
8010119e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801011a1:	68 20 0a 12 80       	push   $0x80120a20
801011a6:	e8 a3 2b 00 00       	call   80103d4e <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011ab:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011ae:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b3:	bb 54 0a 12 80       	mov    $0x80120a54,%ebx
801011b8:	eb 0a                	jmp    801011c4 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ba:	85 f6                	test   %esi,%esi
801011bc:	74 3b                	je     801011f9 <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011be:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011c4:	81 fb 74 26 12 80    	cmp    $0x80122674,%ebx
801011ca:	73 35                	jae    80101201 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011cc:	8b 43 08             	mov    0x8(%ebx),%eax
801011cf:	85 c0                	test   %eax,%eax
801011d1:	7e e7                	jle    801011ba <iget+0x27>
801011d3:	39 3b                	cmp    %edi,(%ebx)
801011d5:	75 e3                	jne    801011ba <iget+0x27>
801011d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011da:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011dd:	75 db                	jne    801011ba <iget+0x27>
      ip->ref++;
801011df:	83 c0 01             	add    $0x1,%eax
801011e2:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011e5:	83 ec 0c             	sub    $0xc,%esp
801011e8:	68 20 0a 12 80       	push   $0x80120a20
801011ed:	e8 c1 2b 00 00       	call   80103db3 <release>
      return ip;
801011f2:	83 c4 10             	add    $0x10,%esp
801011f5:	89 de                	mov    %ebx,%esi
801011f7:	eb 32                	jmp    8010122b <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011f9:	85 c0                	test   %eax,%eax
801011fb:	75 c1                	jne    801011be <iget+0x2b>
      empty = ip;
801011fd:	89 de                	mov    %ebx,%esi
801011ff:	eb bd                	jmp    801011be <iget+0x2b>
  if(empty == 0)
80101201:	85 f6                	test   %esi,%esi
80101203:	74 30                	je     80101235 <iget+0xa2>
  ip->dev = dev;
80101205:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010120a:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
8010120d:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101214:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010121b:	83 ec 0c             	sub    $0xc,%esp
8010121e:	68 20 0a 12 80       	push   $0x80120a20
80101223:	e8 8b 2b 00 00       	call   80103db3 <release>
  return ip;
80101228:	83 c4 10             	add    $0x10,%esp
}
8010122b:	89 f0                	mov    %esi,%eax
8010122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101230:	5b                   	pop    %ebx
80101231:	5e                   	pop    %esi
80101232:	5f                   	pop    %edi
80101233:	5d                   	pop    %ebp
80101234:	c3                   	ret    
    panic("iget: no inodes");
80101235:	83 ec 0c             	sub    $0xc,%esp
80101238:	68 68 67 10 80       	push   $0x80106768
8010123d:	e8 06 f1 ff ff       	call   80100348 <panic>

80101242 <readsb>:
{
80101242:	55                   	push   %ebp
80101243:	89 e5                	mov    %esp,%ebp
80101245:	53                   	push   %ebx
80101246:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
80101249:	6a 01                	push   $0x1
8010124b:	ff 75 08             	pushl  0x8(%ebp)
8010124e:	e8 19 ef ff ff       	call   8010016c <bread>
80101253:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101255:	8d 40 5c             	lea    0x5c(%eax),%eax
80101258:	83 c4 0c             	add    $0xc,%esp
8010125b:	6a 1c                	push   $0x1c
8010125d:	50                   	push   %eax
8010125e:	ff 75 0c             	pushl  0xc(%ebp)
80101261:	e8 0f 2c 00 00       	call   80103e75 <memmove>
  brelse(bp);
80101266:	89 1c 24             	mov    %ebx,(%esp)
80101269:	e8 67 ef ff ff       	call   801001d5 <brelse>
}
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101274:	c9                   	leave  
80101275:	c3                   	ret    

80101276 <bfree>:
{
80101276:	55                   	push   %ebp
80101277:	89 e5                	mov    %esp,%ebp
80101279:	56                   	push   %esi
8010127a:	53                   	push   %ebx
8010127b:	89 c6                	mov    %eax,%esi
8010127d:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
8010127f:	83 ec 08             	sub    $0x8,%esp
80101282:	68 00 0a 12 80       	push   $0x80120a00
80101287:	50                   	push   %eax
80101288:	e8 b5 ff ff ff       	call   80101242 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010128d:	89 d8                	mov    %ebx,%eax
8010128f:	c1 e8 0c             	shr    $0xc,%eax
80101292:	03 05 18 0a 12 80    	add    0x80120a18,%eax
80101298:	83 c4 08             	add    $0x8,%esp
8010129b:	50                   	push   %eax
8010129c:	56                   	push   %esi
8010129d:	e8 ca ee ff ff       	call   8010016c <bread>
801012a2:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801012a4:	89 d9                	mov    %ebx,%ecx
801012a6:	83 e1 07             	and    $0x7,%ecx
801012a9:	b8 01 00 00 00       	mov    $0x1,%eax
801012ae:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012b0:	83 c4 10             	add    $0x10,%esp
801012b3:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012b9:	c1 fb 03             	sar    $0x3,%ebx
801012bc:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012c1:	0f b6 ca             	movzbl %dl,%ecx
801012c4:	85 c1                	test   %eax,%ecx
801012c6:	74 23                	je     801012eb <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012c8:	f7 d0                	not    %eax
801012ca:	21 d0                	and    %edx,%eax
801012cc:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012d0:	83 ec 0c             	sub    $0xc,%esp
801012d3:	56                   	push   %esi
801012d4:	e8 a1 17 00 00       	call   80102a7a <log_write>
  brelse(bp);
801012d9:	89 34 24             	mov    %esi,(%esp)
801012dc:	e8 f4 ee ff ff       	call   801001d5 <brelse>
}
801012e1:	83 c4 10             	add    $0x10,%esp
801012e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012e7:	5b                   	pop    %ebx
801012e8:	5e                   	pop    %esi
801012e9:	5d                   	pop    %ebp
801012ea:	c3                   	ret    
    panic("freeing free block");
801012eb:	83 ec 0c             	sub    $0xc,%esp
801012ee:	68 78 67 10 80       	push   $0x80106778
801012f3:	e8 50 f0 ff ff       	call   80100348 <panic>

801012f8 <iinit>:
{
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	53                   	push   %ebx
801012fc:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012ff:	68 8b 67 10 80       	push   $0x8010678b
80101304:	68 20 0a 12 80       	push   $0x80120a20
80101309:	e8 04 29 00 00       	call   80103c12 <initlock>
  for(i = 0; i < NINODE; i++) {
8010130e:	83 c4 10             	add    $0x10,%esp
80101311:	bb 00 00 00 00       	mov    $0x0,%ebx
80101316:	eb 21                	jmp    80101339 <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
80101318:	83 ec 08             	sub    $0x8,%esp
8010131b:	68 92 67 10 80       	push   $0x80106792
80101320:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101323:	89 d0                	mov    %edx,%eax
80101325:	c1 e0 04             	shl    $0x4,%eax
80101328:	05 60 0a 12 80       	add    $0x80120a60,%eax
8010132d:	50                   	push   %eax
8010132e:	e8 d4 27 00 00       	call   80103b07 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101333:	83 c3 01             	add    $0x1,%ebx
80101336:	83 c4 10             	add    $0x10,%esp
80101339:	83 fb 31             	cmp    $0x31,%ebx
8010133c:	7e da                	jle    80101318 <iinit+0x20>
  readsb(dev, &sb);
8010133e:	83 ec 08             	sub    $0x8,%esp
80101341:	68 00 0a 12 80       	push   $0x80120a00
80101346:	ff 75 08             	pushl  0x8(%ebp)
80101349:	e8 f4 fe ff ff       	call   80101242 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010134e:	ff 35 18 0a 12 80    	pushl  0x80120a18
80101354:	ff 35 14 0a 12 80    	pushl  0x80120a14
8010135a:	ff 35 10 0a 12 80    	pushl  0x80120a10
80101360:	ff 35 0c 0a 12 80    	pushl  0x80120a0c
80101366:	ff 35 08 0a 12 80    	pushl  0x80120a08
8010136c:	ff 35 04 0a 12 80    	pushl  0x80120a04
80101372:	ff 35 00 0a 12 80    	pushl  0x80120a00
80101378:	68 f8 67 10 80       	push   $0x801067f8
8010137d:	e8 89 f2 ff ff       	call   8010060b <cprintf>
}
80101382:	83 c4 30             	add    $0x30,%esp
80101385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101388:	c9                   	leave  
80101389:	c3                   	ret    

8010138a <ialloc>:
{
8010138a:	55                   	push   %ebp
8010138b:	89 e5                	mov    %esp,%ebp
8010138d:	57                   	push   %edi
8010138e:	56                   	push   %esi
8010138f:	53                   	push   %ebx
80101390:	83 ec 1c             	sub    $0x1c,%esp
80101393:	8b 45 0c             	mov    0xc(%ebp),%eax
80101396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101399:	bb 01 00 00 00       	mov    $0x1,%ebx
8010139e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801013a1:	39 1d 08 0a 12 80    	cmp    %ebx,0x80120a08
801013a7:	76 3f                	jbe    801013e8 <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
801013a9:	89 d8                	mov    %ebx,%eax
801013ab:	c1 e8 03             	shr    $0x3,%eax
801013ae:	03 05 14 0a 12 80    	add    0x80120a14,%eax
801013b4:	83 ec 08             	sub    $0x8,%esp
801013b7:	50                   	push   %eax
801013b8:	ff 75 08             	pushl  0x8(%ebp)
801013bb:	e8 ac ed ff ff       	call   8010016c <bread>
801013c0:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013c2:	89 d8                	mov    %ebx,%eax
801013c4:	83 e0 07             	and    $0x7,%eax
801013c7:	c1 e0 06             	shl    $0x6,%eax
801013ca:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013ce:	83 c4 10             	add    $0x10,%esp
801013d1:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013d5:	74 1e                	je     801013f5 <ialloc+0x6b>
    brelse(bp);
801013d7:	83 ec 0c             	sub    $0xc,%esp
801013da:	56                   	push   %esi
801013db:	e8 f5 ed ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013e0:	83 c3 01             	add    $0x1,%ebx
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	eb b6                	jmp    8010139e <ialloc+0x14>
  panic("ialloc: no inodes");
801013e8:	83 ec 0c             	sub    $0xc,%esp
801013eb:	68 98 67 10 80       	push   $0x80106798
801013f0:	e8 53 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013f5:	83 ec 04             	sub    $0x4,%esp
801013f8:	6a 40                	push   $0x40
801013fa:	6a 00                	push   $0x0
801013fc:	57                   	push   %edi
801013fd:	e8 f8 29 00 00       	call   80103dfa <memset>
      dip->type = type;
80101402:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101406:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101409:	89 34 24             	mov    %esi,(%esp)
8010140c:	e8 69 16 00 00       	call   80102a7a <log_write>
      brelse(bp);
80101411:	89 34 24             	mov    %esi,(%esp)
80101414:	e8 bc ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
80101419:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010141c:	8b 45 08             	mov    0x8(%ebp),%eax
8010141f:	e8 6f fd ff ff       	call   80101193 <iget>
}
80101424:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101427:	5b                   	pop    %ebx
80101428:	5e                   	pop    %esi
80101429:	5f                   	pop    %edi
8010142a:	5d                   	pop    %ebp
8010142b:	c3                   	ret    

8010142c <iupdate>:
{
8010142c:	55                   	push   %ebp
8010142d:	89 e5                	mov    %esp,%ebp
8010142f:	56                   	push   %esi
80101430:	53                   	push   %ebx
80101431:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101434:	8b 43 04             	mov    0x4(%ebx),%eax
80101437:	c1 e8 03             	shr    $0x3,%eax
8010143a:	03 05 14 0a 12 80    	add    0x80120a14,%eax
80101440:	83 ec 08             	sub    $0x8,%esp
80101443:	50                   	push   %eax
80101444:	ff 33                	pushl  (%ebx)
80101446:	e8 21 ed ff ff       	call   8010016c <bread>
8010144b:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010144d:	8b 43 04             	mov    0x4(%ebx),%eax
80101450:	83 e0 07             	and    $0x7,%eax
80101453:	c1 e0 06             	shl    $0x6,%eax
80101456:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010145a:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
8010145e:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101461:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101465:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101469:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010146d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101471:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101475:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101479:	8b 53 58             	mov    0x58(%ebx),%edx
8010147c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010147f:	83 c3 5c             	add    $0x5c,%ebx
80101482:	83 c0 0c             	add    $0xc,%eax
80101485:	83 c4 0c             	add    $0xc,%esp
80101488:	6a 34                	push   $0x34
8010148a:	53                   	push   %ebx
8010148b:	50                   	push   %eax
8010148c:	e8 e4 29 00 00       	call   80103e75 <memmove>
  log_write(bp);
80101491:	89 34 24             	mov    %esi,(%esp)
80101494:	e8 e1 15 00 00       	call   80102a7a <log_write>
  brelse(bp);
80101499:	89 34 24             	mov    %esi,(%esp)
8010149c:	e8 34 ed ff ff       	call   801001d5 <brelse>
}
801014a1:	83 c4 10             	add    $0x10,%esp
801014a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014a7:	5b                   	pop    %ebx
801014a8:	5e                   	pop    %esi
801014a9:	5d                   	pop    %ebp
801014aa:	c3                   	ret    

801014ab <itrunc>:
{
801014ab:	55                   	push   %ebp
801014ac:	89 e5                	mov    %esp,%ebp
801014ae:	57                   	push   %edi
801014af:	56                   	push   %esi
801014b0:	53                   	push   %ebx
801014b1:	83 ec 1c             	sub    $0x1c,%esp
801014b4:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
801014bb:	eb 03                	jmp    801014c0 <itrunc+0x15>
801014bd:	83 c3 01             	add    $0x1,%ebx
801014c0:	83 fb 0b             	cmp    $0xb,%ebx
801014c3:	7f 19                	jg     801014de <itrunc+0x33>
    if(ip->addrs[i]){
801014c5:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014c9:	85 d2                	test   %edx,%edx
801014cb:	74 f0                	je     801014bd <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014cd:	8b 06                	mov    (%esi),%eax
801014cf:	e8 a2 fd ff ff       	call   80101276 <bfree>
      ip->addrs[i] = 0;
801014d4:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014db:	00 
801014dc:	eb df                	jmp    801014bd <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014de:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014e4:	85 c0                	test   %eax,%eax
801014e6:	75 1b                	jne    80101503 <itrunc+0x58>
  ip->size = 0;
801014e8:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014ef:	83 ec 0c             	sub    $0xc,%esp
801014f2:	56                   	push   %esi
801014f3:	e8 34 ff ff ff       	call   8010142c <iupdate>
}
801014f8:	83 c4 10             	add    $0x10,%esp
801014fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014fe:	5b                   	pop    %ebx
801014ff:	5e                   	pop    %esi
80101500:	5f                   	pop    %edi
80101501:	5d                   	pop    %ebp
80101502:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101503:	83 ec 08             	sub    $0x8,%esp
80101506:	50                   	push   %eax
80101507:	ff 36                	pushl  (%esi)
80101509:	e8 5e ec ff ff       	call   8010016c <bread>
8010150e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101511:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101514:	83 c4 10             	add    $0x10,%esp
80101517:	bb 00 00 00 00       	mov    $0x0,%ebx
8010151c:	eb 03                	jmp    80101521 <itrunc+0x76>
8010151e:	83 c3 01             	add    $0x1,%ebx
80101521:	83 fb 7f             	cmp    $0x7f,%ebx
80101524:	77 10                	ja     80101536 <itrunc+0x8b>
      if(a[j])
80101526:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101529:	85 d2                	test   %edx,%edx
8010152b:	74 f1                	je     8010151e <itrunc+0x73>
        bfree(ip->dev, a[j]);
8010152d:	8b 06                	mov    (%esi),%eax
8010152f:	e8 42 fd ff ff       	call   80101276 <bfree>
80101534:	eb e8                	jmp    8010151e <itrunc+0x73>
    brelse(bp);
80101536:	83 ec 0c             	sub    $0xc,%esp
80101539:	ff 75 e4             	pushl  -0x1c(%ebp)
8010153c:	e8 94 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101541:	8b 06                	mov    (%esi),%eax
80101543:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101549:	e8 28 fd ff ff       	call   80101276 <bfree>
    ip->addrs[NDIRECT] = 0;
8010154e:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101555:	00 00 00 
80101558:	83 c4 10             	add    $0x10,%esp
8010155b:	eb 8b                	jmp    801014e8 <itrunc+0x3d>

8010155d <idup>:
{
8010155d:	55                   	push   %ebp
8010155e:	89 e5                	mov    %esp,%ebp
80101560:	53                   	push   %ebx
80101561:	83 ec 10             	sub    $0x10,%esp
80101564:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101567:	68 20 0a 12 80       	push   $0x80120a20
8010156c:	e8 dd 27 00 00       	call   80103d4e <acquire>
  ip->ref++;
80101571:	8b 43 08             	mov    0x8(%ebx),%eax
80101574:	83 c0 01             	add    $0x1,%eax
80101577:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010157a:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
80101581:	e8 2d 28 00 00       	call   80103db3 <release>
}
80101586:	89 d8                	mov    %ebx,%eax
80101588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010158b:	c9                   	leave  
8010158c:	c3                   	ret    

8010158d <ilock>:
{
8010158d:	55                   	push   %ebp
8010158e:	89 e5                	mov    %esp,%ebp
80101590:	56                   	push   %esi
80101591:	53                   	push   %ebx
80101592:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101595:	85 db                	test   %ebx,%ebx
80101597:	74 22                	je     801015bb <ilock+0x2e>
80101599:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010159d:	7e 1c                	jle    801015bb <ilock+0x2e>
  acquiresleep(&ip->lock);
8010159f:	83 ec 0c             	sub    $0xc,%esp
801015a2:	8d 43 0c             	lea    0xc(%ebx),%eax
801015a5:	50                   	push   %eax
801015a6:	e8 8f 25 00 00       	call   80103b3a <acquiresleep>
  if(ip->valid == 0){
801015ab:	83 c4 10             	add    $0x10,%esp
801015ae:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015b2:	74 14                	je     801015c8 <ilock+0x3b>
}
801015b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015b7:	5b                   	pop    %ebx
801015b8:	5e                   	pop    %esi
801015b9:	5d                   	pop    %ebp
801015ba:	c3                   	ret    
    panic("ilock");
801015bb:	83 ec 0c             	sub    $0xc,%esp
801015be:	68 aa 67 10 80       	push   $0x801067aa
801015c3:	e8 80 ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015c8:	8b 43 04             	mov    0x4(%ebx),%eax
801015cb:	c1 e8 03             	shr    $0x3,%eax
801015ce:	03 05 14 0a 12 80    	add    0x80120a14,%eax
801015d4:	83 ec 08             	sub    $0x8,%esp
801015d7:	50                   	push   %eax
801015d8:	ff 33                	pushl  (%ebx)
801015da:	e8 8d eb ff ff       	call   8010016c <bread>
801015df:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015e1:	8b 43 04             	mov    0x4(%ebx),%eax
801015e4:	83 e0 07             	and    $0x7,%eax
801015e7:	c1 e0 06             	shl    $0x6,%eax
801015ea:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015ee:	0f b7 10             	movzwl (%eax),%edx
801015f1:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015f5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015f9:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015fd:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101601:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101605:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101609:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010160d:	8b 50 08             	mov    0x8(%eax),%edx
80101610:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101613:	83 c0 0c             	add    $0xc,%eax
80101616:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101619:	83 c4 0c             	add    $0xc,%esp
8010161c:	6a 34                	push   $0x34
8010161e:	50                   	push   %eax
8010161f:	52                   	push   %edx
80101620:	e8 50 28 00 00       	call   80103e75 <memmove>
    brelse(bp);
80101625:	89 34 24             	mov    %esi,(%esp)
80101628:	e8 a8 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
8010162d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101634:	83 c4 10             	add    $0x10,%esp
80101637:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010163c:	0f 85 72 ff ff ff    	jne    801015b4 <ilock+0x27>
      panic("ilock: no type");
80101642:	83 ec 0c             	sub    $0xc,%esp
80101645:	68 b0 67 10 80       	push   $0x801067b0
8010164a:	e8 f9 ec ff ff       	call   80100348 <panic>

8010164f <iunlock>:
{
8010164f:	55                   	push   %ebp
80101650:	89 e5                	mov    %esp,%ebp
80101652:	56                   	push   %esi
80101653:	53                   	push   %ebx
80101654:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101657:	85 db                	test   %ebx,%ebx
80101659:	74 2c                	je     80101687 <iunlock+0x38>
8010165b:	8d 73 0c             	lea    0xc(%ebx),%esi
8010165e:	83 ec 0c             	sub    $0xc,%esp
80101661:	56                   	push   %esi
80101662:	e8 5d 25 00 00       	call   80103bc4 <holdingsleep>
80101667:	83 c4 10             	add    $0x10,%esp
8010166a:	85 c0                	test   %eax,%eax
8010166c:	74 19                	je     80101687 <iunlock+0x38>
8010166e:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101672:	7e 13                	jle    80101687 <iunlock+0x38>
  releasesleep(&ip->lock);
80101674:	83 ec 0c             	sub    $0xc,%esp
80101677:	56                   	push   %esi
80101678:	e8 0c 25 00 00       	call   80103b89 <releasesleep>
}
8010167d:	83 c4 10             	add    $0x10,%esp
80101680:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101683:	5b                   	pop    %ebx
80101684:	5e                   	pop    %esi
80101685:	5d                   	pop    %ebp
80101686:	c3                   	ret    
    panic("iunlock");
80101687:	83 ec 0c             	sub    $0xc,%esp
8010168a:	68 bf 67 10 80       	push   $0x801067bf
8010168f:	e8 b4 ec ff ff       	call   80100348 <panic>

80101694 <iput>:
{
80101694:	55                   	push   %ebp
80101695:	89 e5                	mov    %esp,%ebp
80101697:	57                   	push   %edi
80101698:	56                   	push   %esi
80101699:	53                   	push   %ebx
8010169a:	83 ec 18             	sub    $0x18,%esp
8010169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801016a0:	8d 73 0c             	lea    0xc(%ebx),%esi
801016a3:	56                   	push   %esi
801016a4:	e8 91 24 00 00       	call   80103b3a <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016a9:	83 c4 10             	add    $0x10,%esp
801016ac:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016b0:	74 07                	je     801016b9 <iput+0x25>
801016b2:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016b7:	74 35                	je     801016ee <iput+0x5a>
  releasesleep(&ip->lock);
801016b9:	83 ec 0c             	sub    $0xc,%esp
801016bc:	56                   	push   %esi
801016bd:	e8 c7 24 00 00       	call   80103b89 <releasesleep>
  acquire(&icache.lock);
801016c2:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
801016c9:	e8 80 26 00 00       	call   80103d4e <acquire>
  ip->ref--;
801016ce:	8b 43 08             	mov    0x8(%ebx),%eax
801016d1:	83 e8 01             	sub    $0x1,%eax
801016d4:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016d7:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
801016de:	e8 d0 26 00 00       	call   80103db3 <release>
}
801016e3:	83 c4 10             	add    $0x10,%esp
801016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016e9:	5b                   	pop    %ebx
801016ea:	5e                   	pop    %esi
801016eb:	5f                   	pop    %edi
801016ec:	5d                   	pop    %ebp
801016ed:	c3                   	ret    
    acquire(&icache.lock);
801016ee:	83 ec 0c             	sub    $0xc,%esp
801016f1:	68 20 0a 12 80       	push   $0x80120a20
801016f6:	e8 53 26 00 00       	call   80103d4e <acquire>
    int r = ip->ref;
801016fb:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016fe:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
80101705:	e8 a9 26 00 00       	call   80103db3 <release>
    if(r == 1){
8010170a:	83 c4 10             	add    $0x10,%esp
8010170d:	83 ff 01             	cmp    $0x1,%edi
80101710:	75 a7                	jne    801016b9 <iput+0x25>
      itrunc(ip);
80101712:	89 d8                	mov    %ebx,%eax
80101714:	e8 92 fd ff ff       	call   801014ab <itrunc>
      ip->type = 0;
80101719:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
8010171f:	83 ec 0c             	sub    $0xc,%esp
80101722:	53                   	push   %ebx
80101723:	e8 04 fd ff ff       	call   8010142c <iupdate>
      ip->valid = 0;
80101728:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
8010172f:	83 c4 10             	add    $0x10,%esp
80101732:	eb 85                	jmp    801016b9 <iput+0x25>

80101734 <iunlockput>:
{
80101734:	55                   	push   %ebp
80101735:	89 e5                	mov    %esp,%ebp
80101737:	53                   	push   %ebx
80101738:	83 ec 10             	sub    $0x10,%esp
8010173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
8010173e:	53                   	push   %ebx
8010173f:	e8 0b ff ff ff       	call   8010164f <iunlock>
  iput(ip);
80101744:	89 1c 24             	mov    %ebx,(%esp)
80101747:	e8 48 ff ff ff       	call   80101694 <iput>
}
8010174c:	83 c4 10             	add    $0x10,%esp
8010174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101752:	c9                   	leave  
80101753:	c3                   	ret    

80101754 <stati>:
{
80101754:	55                   	push   %ebp
80101755:	89 e5                	mov    %esp,%ebp
80101757:	8b 55 08             	mov    0x8(%ebp),%edx
8010175a:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
8010175d:	8b 0a                	mov    (%edx),%ecx
8010175f:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101762:	8b 4a 04             	mov    0x4(%edx),%ecx
80101765:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101768:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010176c:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
8010176f:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101773:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101777:	8b 52 58             	mov    0x58(%edx),%edx
8010177a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010177d:	5d                   	pop    %ebp
8010177e:	c3                   	ret    

8010177f <readi>:
{
8010177f:	55                   	push   %ebp
80101780:	89 e5                	mov    %esp,%ebp
80101782:	57                   	push   %edi
80101783:	56                   	push   %esi
80101784:	53                   	push   %ebx
80101785:	83 ec 1c             	sub    $0x1c,%esp
80101788:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010178b:	8b 45 08             	mov    0x8(%ebp),%eax
8010178e:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101793:	74 2c                	je     801017c1 <readi+0x42>
  if(off > ip->size || off + n < off)
80101795:	8b 45 08             	mov    0x8(%ebp),%eax
80101798:	8b 40 58             	mov    0x58(%eax),%eax
8010179b:	39 f8                	cmp    %edi,%eax
8010179d:	0f 82 cb 00 00 00    	jb     8010186e <readi+0xef>
801017a3:	89 fa                	mov    %edi,%edx
801017a5:	03 55 14             	add    0x14(%ebp),%edx
801017a8:	0f 82 c7 00 00 00    	jb     80101875 <readi+0xf6>
  if(off + n > ip->size)
801017ae:	39 d0                	cmp    %edx,%eax
801017b0:	73 05                	jae    801017b7 <readi+0x38>
    n = ip->size - off;
801017b2:	29 f8                	sub    %edi,%eax
801017b4:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017b7:	be 00 00 00 00       	mov    $0x0,%esi
801017bc:	e9 8f 00 00 00       	jmp    80101850 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017c1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017c5:	66 83 f8 09          	cmp    $0x9,%ax
801017c9:	0f 87 91 00 00 00    	ja     80101860 <readi+0xe1>
801017cf:	98                   	cwtl   
801017d0:	8b 04 c5 a0 09 12 80 	mov    -0x7fedf660(,%eax,8),%eax
801017d7:	85 c0                	test   %eax,%eax
801017d9:	0f 84 88 00 00 00    	je     80101867 <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017df:	83 ec 04             	sub    $0x4,%esp
801017e2:	ff 75 14             	pushl  0x14(%ebp)
801017e5:	ff 75 0c             	pushl  0xc(%ebp)
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	ff d0                	call   *%eax
801017ed:	83 c4 10             	add    $0x10,%esp
801017f0:	eb 66                	jmp    80101858 <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017f2:	89 fa                	mov    %edi,%edx
801017f4:	c1 ea 09             	shr    $0x9,%edx
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	e8 ee f8 ff ff       	call   801010ed <bmap>
801017ff:	83 ec 08             	sub    $0x8,%esp
80101802:	50                   	push   %eax
80101803:	8b 45 08             	mov    0x8(%ebp),%eax
80101806:	ff 30                	pushl  (%eax)
80101808:	e8 5f e9 ff ff       	call   8010016c <bread>
8010180d:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
8010180f:	89 f8                	mov    %edi,%eax
80101811:	25 ff 01 00 00       	and    $0x1ff,%eax
80101816:	bb 00 02 00 00       	mov    $0x200,%ebx
8010181b:	29 c3                	sub    %eax,%ebx
8010181d:	8b 55 14             	mov    0x14(%ebp),%edx
80101820:	29 f2                	sub    %esi,%edx
80101822:	83 c4 0c             	add    $0xc,%esp
80101825:	39 d3                	cmp    %edx,%ebx
80101827:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010182a:	53                   	push   %ebx
8010182b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010182e:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101832:	50                   	push   %eax
80101833:	ff 75 0c             	pushl  0xc(%ebp)
80101836:	e8 3a 26 00 00       	call   80103e75 <memmove>
    brelse(bp);
8010183b:	83 c4 04             	add    $0x4,%esp
8010183e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101841:	e8 8f e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101846:	01 de                	add    %ebx,%esi
80101848:	01 df                	add    %ebx,%edi
8010184a:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010184d:	83 c4 10             	add    $0x10,%esp
80101850:	39 75 14             	cmp    %esi,0x14(%ebp)
80101853:	77 9d                	ja     801017f2 <readi+0x73>
  return n;
80101855:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101858:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010185b:	5b                   	pop    %ebx
8010185c:	5e                   	pop    %esi
8010185d:	5f                   	pop    %edi
8010185e:	5d                   	pop    %ebp
8010185f:	c3                   	ret    
      return -1;
80101860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101865:	eb f1                	jmp    80101858 <readi+0xd9>
80101867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186c:	eb ea                	jmp    80101858 <readi+0xd9>
    return -1;
8010186e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101873:	eb e3                	jmp    80101858 <readi+0xd9>
80101875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010187a:	eb dc                	jmp    80101858 <readi+0xd9>

8010187c <writei>:
{
8010187c:	55                   	push   %ebp
8010187d:	89 e5                	mov    %esp,%ebp
8010187f:	57                   	push   %edi
80101880:	56                   	push   %esi
80101881:	53                   	push   %ebx
80101882:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101885:	8b 45 08             	mov    0x8(%ebp),%eax
80101888:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010188d:	74 2f                	je     801018be <writei+0x42>
  if(off > ip->size || off + n < off)
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101895:	39 48 58             	cmp    %ecx,0x58(%eax)
80101898:	0f 82 f4 00 00 00    	jb     80101992 <writei+0x116>
8010189e:	89 c8                	mov    %ecx,%eax
801018a0:	03 45 14             	add    0x14(%ebp),%eax
801018a3:	0f 82 f0 00 00 00    	jb     80101999 <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
801018a9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018ae:	0f 87 ec 00 00 00    	ja     801019a0 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018b4:	be 00 00 00 00       	mov    $0x0,%esi
801018b9:	e9 94 00 00 00       	jmp    80101952 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018be:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018c2:	66 83 f8 09          	cmp    $0x9,%ax
801018c6:	0f 87 b8 00 00 00    	ja     80101984 <writei+0x108>
801018cc:	98                   	cwtl   
801018cd:	8b 04 c5 a4 09 12 80 	mov    -0x7fedf65c(,%eax,8),%eax
801018d4:	85 c0                	test   %eax,%eax
801018d6:	0f 84 af 00 00 00    	je     8010198b <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018dc:	83 ec 04             	sub    $0x4,%esp
801018df:	ff 75 14             	pushl  0x14(%ebp)
801018e2:	ff 75 0c             	pushl  0xc(%ebp)
801018e5:	ff 75 08             	pushl  0x8(%ebp)
801018e8:	ff d0                	call   *%eax
801018ea:	83 c4 10             	add    $0x10,%esp
801018ed:	eb 7c                	jmp    8010196b <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018ef:	8b 55 10             	mov    0x10(%ebp),%edx
801018f2:	c1 ea 09             	shr    $0x9,%edx
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	e8 f0 f7 ff ff       	call   801010ed <bmap>
801018fd:	83 ec 08             	sub    $0x8,%esp
80101900:	50                   	push   %eax
80101901:	8b 45 08             	mov    0x8(%ebp),%eax
80101904:	ff 30                	pushl  (%eax)
80101906:	e8 61 e8 ff ff       	call   8010016c <bread>
8010190b:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
8010190d:	8b 45 10             	mov    0x10(%ebp),%eax
80101910:	25 ff 01 00 00       	and    $0x1ff,%eax
80101915:	bb 00 02 00 00       	mov    $0x200,%ebx
8010191a:	29 c3                	sub    %eax,%ebx
8010191c:	8b 55 14             	mov    0x14(%ebp),%edx
8010191f:	29 f2                	sub    %esi,%edx
80101921:	83 c4 0c             	add    $0xc,%esp
80101924:	39 d3                	cmp    %edx,%ebx
80101926:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101929:	53                   	push   %ebx
8010192a:	ff 75 0c             	pushl  0xc(%ebp)
8010192d:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101931:	50                   	push   %eax
80101932:	e8 3e 25 00 00       	call   80103e75 <memmove>
    log_write(bp);
80101937:	89 3c 24             	mov    %edi,(%esp)
8010193a:	e8 3b 11 00 00       	call   80102a7a <log_write>
    brelse(bp);
8010193f:	89 3c 24             	mov    %edi,(%esp)
80101942:	e8 8e e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101947:	01 de                	add    %ebx,%esi
80101949:	01 5d 10             	add    %ebx,0x10(%ebp)
8010194c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010194f:	83 c4 10             	add    $0x10,%esp
80101952:	3b 75 14             	cmp    0x14(%ebp),%esi
80101955:	72 98                	jb     801018ef <writei+0x73>
  if(n > 0 && off > ip->size){
80101957:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010195b:	74 0b                	je     80101968 <writei+0xec>
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101963:	39 48 58             	cmp    %ecx,0x58(%eax)
80101966:	72 0b                	jb     80101973 <writei+0xf7>
  return n;
80101968:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010196b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010196e:	5b                   	pop    %ebx
8010196f:	5e                   	pop    %esi
80101970:	5f                   	pop    %edi
80101971:	5d                   	pop    %ebp
80101972:	c3                   	ret    
    ip->size = off;
80101973:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
80101976:	83 ec 0c             	sub    $0xc,%esp
80101979:	50                   	push   %eax
8010197a:	e8 ad fa ff ff       	call   8010142c <iupdate>
8010197f:	83 c4 10             	add    $0x10,%esp
80101982:	eb e4                	jmp    80101968 <writei+0xec>
      return -1;
80101984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101989:	eb e0                	jmp    8010196b <writei+0xef>
8010198b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101990:	eb d9                	jmp    8010196b <writei+0xef>
    return -1;
80101992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101997:	eb d2                	jmp    8010196b <writei+0xef>
80101999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010199e:	eb cb                	jmp    8010196b <writei+0xef>
    return -1;
801019a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019a5:	eb c4                	jmp    8010196b <writei+0xef>

801019a7 <namecmp>:
{
801019a7:	55                   	push   %ebp
801019a8:	89 e5                	mov    %esp,%ebp
801019aa:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019ad:	6a 0e                	push   $0xe
801019af:	ff 75 0c             	pushl  0xc(%ebp)
801019b2:	ff 75 08             	pushl  0x8(%ebp)
801019b5:	e8 22 25 00 00       	call   80103edc <strncmp>
}
801019ba:	c9                   	leave  
801019bb:	c3                   	ret    

801019bc <dirlookup>:
{
801019bc:	55                   	push   %ebp
801019bd:	89 e5                	mov    %esp,%ebp
801019bf:	57                   	push   %edi
801019c0:	56                   	push   %esi
801019c1:	53                   	push   %ebx
801019c2:	83 ec 1c             	sub    $0x1c,%esp
801019c5:	8b 75 08             	mov    0x8(%ebp),%esi
801019c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019cb:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019d0:	75 07                	jne    801019d9 <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801019d7:	eb 1d                	jmp    801019f6 <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019d9:	83 ec 0c             	sub    $0xc,%esp
801019dc:	68 c7 67 10 80       	push   $0x801067c7
801019e1:	e8 62 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 d9 67 10 80       	push   $0x801067d9
801019ee:	e8 55 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019f3:	83 c3 10             	add    $0x10,%ebx
801019f6:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019f9:	76 48                	jbe    80101a43 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019fb:	6a 10                	push   $0x10
801019fd:	53                   	push   %ebx
801019fe:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101a01:	50                   	push   %eax
80101a02:	56                   	push   %esi
80101a03:	e8 77 fd ff ff       	call   8010177f <readi>
80101a08:	83 c4 10             	add    $0x10,%esp
80101a0b:	83 f8 10             	cmp    $0x10,%eax
80101a0e:	75 d6                	jne    801019e6 <dirlookup+0x2a>
    if(de.inum == 0)
80101a10:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a15:	74 dc                	je     801019f3 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a17:	83 ec 08             	sub    $0x8,%esp
80101a1a:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a1d:	50                   	push   %eax
80101a1e:	57                   	push   %edi
80101a1f:	e8 83 ff ff ff       	call   801019a7 <namecmp>
80101a24:	83 c4 10             	add    $0x10,%esp
80101a27:	85 c0                	test   %eax,%eax
80101a29:	75 c8                	jne    801019f3 <dirlookup+0x37>
      if(poff)
80101a2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a2f:	74 05                	je     80101a36 <dirlookup+0x7a>
        *poff = off;
80101a31:	8b 45 10             	mov    0x10(%ebp),%eax
80101a34:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a36:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a3a:	8b 06                	mov    (%esi),%eax
80101a3c:	e8 52 f7 ff ff       	call   80101193 <iget>
80101a41:	eb 05                	jmp    80101a48 <dirlookup+0x8c>
  return 0;
80101a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a4b:	5b                   	pop    %ebx
80101a4c:	5e                   	pop    %esi
80101a4d:	5f                   	pop    %edi
80101a4e:	5d                   	pop    %ebp
80101a4f:	c3                   	ret    

80101a50 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a50:	55                   	push   %ebp
80101a51:	89 e5                	mov    %esp,%ebp
80101a53:	57                   	push   %edi
80101a54:	56                   	push   %esi
80101a55:	53                   	push   %ebx
80101a56:	83 ec 1c             	sub    $0x1c,%esp
80101a59:	89 c6                	mov    %eax,%esi
80101a5b:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a61:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a64:	74 17                	je     80101a7d <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a66:	e8 41 19 00 00       	call   801033ac <myproc>
80101a6b:	83 ec 0c             	sub    $0xc,%esp
80101a6e:	ff 70 68             	pushl  0x68(%eax)
80101a71:	e8 e7 fa ff ff       	call   8010155d <idup>
80101a76:	89 c3                	mov    %eax,%ebx
80101a78:	83 c4 10             	add    $0x10,%esp
80101a7b:	eb 53                	jmp    80101ad0 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a7d:	ba 01 00 00 00       	mov    $0x1,%edx
80101a82:	b8 01 00 00 00       	mov    $0x1,%eax
80101a87:	e8 07 f7 ff ff       	call   80101193 <iget>
80101a8c:	89 c3                	mov    %eax,%ebx
80101a8e:	eb 40                	jmp    80101ad0 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a90:	83 ec 0c             	sub    $0xc,%esp
80101a93:	53                   	push   %ebx
80101a94:	e8 9b fc ff ff       	call   80101734 <iunlockput>
      return 0;
80101a99:	83 c4 10             	add    $0x10,%esp
80101a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101aa1:	89 d8                	mov    %ebx,%eax
80101aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aa6:	5b                   	pop    %ebx
80101aa7:	5e                   	pop    %esi
80101aa8:	5f                   	pop    %edi
80101aa9:	5d                   	pop    %ebp
80101aaa:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101aab:	83 ec 04             	sub    $0x4,%esp
80101aae:	6a 00                	push   $0x0
80101ab0:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ab3:	53                   	push   %ebx
80101ab4:	e8 03 ff ff ff       	call   801019bc <dirlookup>
80101ab9:	89 c7                	mov    %eax,%edi
80101abb:	83 c4 10             	add    $0x10,%esp
80101abe:	85 c0                	test   %eax,%eax
80101ac0:	74 4a                	je     80101b0c <namex+0xbc>
    iunlockput(ip);
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	53                   	push   %ebx
80101ac6:	e8 69 fc ff ff       	call   80101734 <iunlockput>
    ip = next;
80101acb:	83 c4 10             	add    $0x10,%esp
80101ace:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ad3:	89 f0                	mov    %esi,%eax
80101ad5:	e8 77 f4 ff ff       	call   80100f51 <skipelem>
80101ada:	89 c6                	mov    %eax,%esi
80101adc:	85 c0                	test   %eax,%eax
80101ade:	74 3c                	je     80101b1c <namex+0xcc>
    ilock(ip);
80101ae0:	83 ec 0c             	sub    $0xc,%esp
80101ae3:	53                   	push   %ebx
80101ae4:	e8 a4 fa ff ff       	call   8010158d <ilock>
    if(ip->type != T_DIR){
80101ae9:	83 c4 10             	add    $0x10,%esp
80101aec:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101af1:	75 9d                	jne    80101a90 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101af3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101af7:	74 b2                	je     80101aab <namex+0x5b>
80101af9:	80 3e 00             	cmpb   $0x0,(%esi)
80101afc:	75 ad                	jne    80101aab <namex+0x5b>
      iunlock(ip);
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	53                   	push   %ebx
80101b02:	e8 48 fb ff ff       	call   8010164f <iunlock>
      return ip;
80101b07:	83 c4 10             	add    $0x10,%esp
80101b0a:	eb 95                	jmp    80101aa1 <namex+0x51>
      iunlockput(ip);
80101b0c:	83 ec 0c             	sub    $0xc,%esp
80101b0f:	53                   	push   %ebx
80101b10:	e8 1f fc ff ff       	call   80101734 <iunlockput>
      return 0;
80101b15:	83 c4 10             	add    $0x10,%esp
80101b18:	89 fb                	mov    %edi,%ebx
80101b1a:	eb 85                	jmp    80101aa1 <namex+0x51>
  if(nameiparent){
80101b1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b20:	0f 84 7b ff ff ff    	je     80101aa1 <namex+0x51>
    iput(ip);
80101b26:	83 ec 0c             	sub    $0xc,%esp
80101b29:	53                   	push   %ebx
80101b2a:	e8 65 fb ff ff       	call   80101694 <iput>
    return 0;
80101b2f:	83 c4 10             	add    $0x10,%esp
80101b32:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b37:	e9 65 ff ff ff       	jmp    80101aa1 <namex+0x51>

80101b3c <dirlink>:
{
80101b3c:	55                   	push   %ebp
80101b3d:	89 e5                	mov    %esp,%ebp
80101b3f:	57                   	push   %edi
80101b40:	56                   	push   %esi
80101b41:	53                   	push   %ebx
80101b42:	83 ec 20             	sub    $0x20,%esp
80101b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b48:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b4b:	6a 00                	push   $0x0
80101b4d:	57                   	push   %edi
80101b4e:	53                   	push   %ebx
80101b4f:	e8 68 fe ff ff       	call   801019bc <dirlookup>
80101b54:	83 c4 10             	add    $0x10,%esp
80101b57:	85 c0                	test   %eax,%eax
80101b59:	75 2d                	jne    80101b88 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b5b:	b8 00 00 00 00       	mov    $0x0,%eax
80101b60:	89 c6                	mov    %eax,%esi
80101b62:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b65:	76 41                	jbe    80101ba8 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b67:	6a 10                	push   $0x10
80101b69:	50                   	push   %eax
80101b6a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b6d:	50                   	push   %eax
80101b6e:	53                   	push   %ebx
80101b6f:	e8 0b fc ff ff       	call   8010177f <readi>
80101b74:	83 c4 10             	add    $0x10,%esp
80101b77:	83 f8 10             	cmp    $0x10,%eax
80101b7a:	75 1f                	jne    80101b9b <dirlink+0x5f>
    if(de.inum == 0)
80101b7c:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b81:	74 25                	je     80101ba8 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b83:	8d 46 10             	lea    0x10(%esi),%eax
80101b86:	eb d8                	jmp    80101b60 <dirlink+0x24>
    iput(ip);
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	50                   	push   %eax
80101b8c:	e8 03 fb ff ff       	call   80101694 <iput>
    return -1;
80101b91:	83 c4 10             	add    $0x10,%esp
80101b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b99:	eb 3d                	jmp    80101bd8 <dirlink+0x9c>
      panic("dirlink read");
80101b9b:	83 ec 0c             	sub    $0xc,%esp
80101b9e:	68 e8 67 10 80       	push   $0x801067e8
80101ba3:	e8 a0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101ba8:	83 ec 04             	sub    $0x4,%esp
80101bab:	6a 0e                	push   $0xe
80101bad:	57                   	push   %edi
80101bae:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bb1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bb4:	50                   	push   %eax
80101bb5:	e8 5f 23 00 00       	call   80103f19 <strncpy>
  de.inum = inum;
80101bba:	8b 45 10             	mov    0x10(%ebp),%eax
80101bbd:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bc1:	6a 10                	push   $0x10
80101bc3:	56                   	push   %esi
80101bc4:	57                   	push   %edi
80101bc5:	53                   	push   %ebx
80101bc6:	e8 b1 fc ff ff       	call   8010187c <writei>
80101bcb:	83 c4 20             	add    $0x20,%esp
80101bce:	83 f8 10             	cmp    $0x10,%eax
80101bd1:	75 0d                	jne    80101be0 <dirlink+0xa4>
  return 0;
80101bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bdb:	5b                   	pop    %ebx
80101bdc:	5e                   	pop    %esi
80101bdd:	5f                   	pop    %edi
80101bde:	5d                   	pop    %ebp
80101bdf:	c3                   	ret    
    panic("dirlink");
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 f4 6d 10 80       	push   $0x80106df4
80101be8:	e8 5b e7 ff ff       	call   80100348 <panic>

80101bed <namei>:

struct inode*
namei(char *path)
{
80101bed:	55                   	push   %ebp
80101bee:	89 e5                	mov    %esp,%ebp
80101bf0:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bf3:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bf6:	ba 00 00 00 00       	mov    $0x0,%edx
80101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfe:	e8 4d fe ff ff       	call   80101a50 <namex>
}
80101c03:	c9                   	leave  
80101c04:	c3                   	ret    

80101c05 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101c05:	55                   	push   %ebp
80101c06:	89 e5                	mov    %esp,%ebp
80101c08:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c0e:	ba 01 00 00 00       	mov    $0x1,%edx
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	e8 35 fe ff ff       	call   80101a50 <namex>
}
80101c1b:	c9                   	leave  
80101c1c:	c3                   	ret    

80101c1d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c1d:	55                   	push   %ebp
80101c1e:	89 e5                	mov    %esp,%ebp
80101c20:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c22:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c27:	ec                   	in     (%dx),%al
80101c28:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c2a:	83 e0 c0             	and    $0xffffffc0,%eax
80101c2d:	3c 40                	cmp    $0x40,%al
80101c2f:	75 f1                	jne    80101c22 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c31:	85 c9                	test   %ecx,%ecx
80101c33:	74 0c                	je     80101c41 <idewait+0x24>
80101c35:	f6 c2 21             	test   $0x21,%dl
80101c38:	75 0e                	jne    80101c48 <idewait+0x2b>
    return -1;
  return 0;
80101c3a:	b8 00 00 00 00       	mov    $0x0,%eax
80101c3f:	eb 05                	jmp    80101c46 <idewait+0x29>
80101c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c46:	5d                   	pop    %ebp
80101c47:	c3                   	ret    
    return -1;
80101c48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c4d:	eb f7                	jmp    80101c46 <idewait+0x29>

80101c4f <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	56                   	push   %esi
80101c53:	53                   	push   %ebx
  if(b == 0)
80101c54:	85 c0                	test   %eax,%eax
80101c56:	74 7d                	je     80101cd5 <idestart+0x86>
80101c58:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c5a:	8b 58 08             	mov    0x8(%eax),%ebx
80101c5d:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c63:	77 7d                	ja     80101ce2 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c65:	b8 00 00 00 00       	mov    $0x0,%eax
80101c6a:	e8 ae ff ff ff       	call   80101c1d <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c6f:	b8 00 00 00 00       	mov    $0x0,%eax
80101c74:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c79:	ee                   	out    %al,(%dx)
80101c7a:	b8 01 00 00 00       	mov    $0x1,%eax
80101c7f:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c84:	ee                   	out    %al,(%dx)
80101c85:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c8a:	89 d8                	mov    %ebx,%eax
80101c8c:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c8d:	89 d8                	mov    %ebx,%eax
80101c8f:	c1 f8 08             	sar    $0x8,%eax
80101c92:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c97:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c98:	89 d8                	mov    %ebx,%eax
80101c9a:	c1 f8 10             	sar    $0x10,%eax
80101c9d:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101ca2:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101ca3:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101ca7:	c1 e0 04             	shl    $0x4,%eax
80101caa:	83 e0 10             	and    $0x10,%eax
80101cad:	c1 fb 18             	sar    $0x18,%ebx
80101cb0:	83 e3 0f             	and    $0xf,%ebx
80101cb3:	09 d8                	or     %ebx,%eax
80101cb5:	83 c8 e0             	or     $0xffffffe0,%eax
80101cb8:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cbd:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cbe:	f6 06 04             	testb  $0x4,(%esi)
80101cc1:	75 2c                	jne    80101cef <idestart+0xa0>
80101cc3:	b8 20 00 00 00       	mov    $0x20,%eax
80101cc8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ccd:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cd1:	5b                   	pop    %ebx
80101cd2:	5e                   	pop    %esi
80101cd3:	5d                   	pop    %ebp
80101cd4:	c3                   	ret    
    panic("idestart");
80101cd5:	83 ec 0c             	sub    $0xc,%esp
80101cd8:	68 4b 68 10 80       	push   $0x8010684b
80101cdd:	e8 66 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	68 54 68 10 80       	push   $0x80106854
80101cea:	e8 59 e6 ff ff       	call   80100348 <panic>
80101cef:	b8 30 00 00 00       	mov    $0x30,%eax
80101cf4:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cf9:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cfa:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d07:	fc                   	cld    
80101d08:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d0a:	eb c2                	jmp    80101cce <idestart+0x7f>

80101d0c <ideinit>:
{
80101d0c:	55                   	push   %ebp
80101d0d:	89 e5                	mov    %esp,%ebp
80101d0f:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d12:	68 66 68 10 80       	push   $0x80106866
80101d17:	68 80 a5 10 80       	push   $0x8010a580
80101d1c:	e8 f1 1e 00 00       	call   80103c12 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d21:	83 c4 08             	add    $0x8,%esp
80101d24:	a1 60 2d 14 80       	mov    0x80142d60,%eax
80101d29:	83 e8 01             	sub    $0x1,%eax
80101d2c:	50                   	push   %eax
80101d2d:	6a 0e                	push   $0xe
80101d2f:	e8 56 02 00 00       	call   80101f8a <ioapicenable>
  idewait(0);
80101d34:	b8 00 00 00 00       	mov    $0x0,%eax
80101d39:	e8 df fe ff ff       	call   80101c1d <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d3e:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d43:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d48:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d49:	83 c4 10             	add    $0x10,%esp
80101d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d51:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d57:	7f 19                	jg     80101d72 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d59:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d5e:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d5f:	84 c0                	test   %al,%al
80101d61:	75 05                	jne    80101d68 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d63:	83 c1 01             	add    $0x1,%ecx
80101d66:	eb e9                	jmp    80101d51 <ideinit+0x45>
      havedisk1 = 1;
80101d68:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101d6f:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d72:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d77:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d7c:	ee                   	out    %al,(%dx)
}
80101d7d:	c9                   	leave  
80101d7e:	c3                   	ret    

80101d7f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d7f:	55                   	push   %ebp
80101d80:	89 e5                	mov    %esp,%ebp
80101d82:	57                   	push   %edi
80101d83:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d84:	83 ec 0c             	sub    $0xc,%esp
80101d87:	68 80 a5 10 80       	push   $0x8010a580
80101d8c:	e8 bd 1f 00 00       	call   80103d4e <acquire>

  if((b = idequeue) == 0){
80101d91:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101d97:	83 c4 10             	add    $0x10,%esp
80101d9a:	85 db                	test   %ebx,%ebx
80101d9c:	74 48                	je     80101de6 <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d9e:	8b 43 58             	mov    0x58(%ebx),%eax
80101da1:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101da6:	f6 03 04             	testb  $0x4,(%ebx)
80101da9:	74 4d                	je     80101df8 <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101dab:	8b 03                	mov    (%ebx),%eax
80101dad:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101db0:	83 e0 fb             	and    $0xfffffffb,%eax
80101db3:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101db5:	83 ec 0c             	sub    $0xc,%esp
80101db8:	53                   	push   %ebx
80101db9:	e8 fa 1b 00 00       	call   801039b8 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101dbe:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101dc3:	83 c4 10             	add    $0x10,%esp
80101dc6:	85 c0                	test   %eax,%eax
80101dc8:	74 05                	je     80101dcf <ideintr+0x50>
    idestart(idequeue);
80101dca:	e8 80 fe ff ff       	call   80101c4f <idestart>

  release(&idelock);
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	68 80 a5 10 80       	push   $0x8010a580
80101dd7:	e8 d7 1f 00 00       	call   80103db3 <release>
80101ddc:	83 c4 10             	add    $0x10,%esp
}
80101ddf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101de2:	5b                   	pop    %ebx
80101de3:	5f                   	pop    %edi
80101de4:	5d                   	pop    %ebp
80101de5:	c3                   	ret    
    release(&idelock);
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 80 a5 10 80       	push   $0x8010a580
80101dee:	e8 c0 1f 00 00       	call   80103db3 <release>
    return;
80101df3:	83 c4 10             	add    $0x10,%esp
80101df6:	eb e7                	jmp    80101ddf <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101df8:	b8 01 00 00 00       	mov    $0x1,%eax
80101dfd:	e8 1b fe ff ff       	call   80101c1d <idewait>
80101e02:	85 c0                	test   %eax,%eax
80101e04:	78 a5                	js     80101dab <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101e06:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101e09:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e0e:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e13:	fc                   	cld    
80101e14:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e16:	eb 93                	jmp    80101dab <ideintr+0x2c>

80101e18 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e18:	55                   	push   %ebp
80101e19:	89 e5                	mov    %esp,%ebp
80101e1b:	53                   	push   %ebx
80101e1c:	83 ec 10             	sub    $0x10,%esp
80101e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e22:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e25:	50                   	push   %eax
80101e26:	e8 99 1d 00 00       	call   80103bc4 <holdingsleep>
80101e2b:	83 c4 10             	add    $0x10,%esp
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 37                	je     80101e69 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e32:	8b 03                	mov    (%ebx),%eax
80101e34:	83 e0 06             	and    $0x6,%eax
80101e37:	83 f8 02             	cmp    $0x2,%eax
80101e3a:	74 3a                	je     80101e76 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e3c:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e40:	74 09                	je     80101e4b <iderw+0x33>
80101e42:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101e49:	74 38                	je     80101e83 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 80 a5 10 80       	push   $0x8010a580
80101e53:	e8 f6 1e 00 00       	call   80103d4e <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e58:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e5f:	83 c4 10             	add    $0x10,%esp
80101e62:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e67:	eb 2a                	jmp    80101e93 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e69:	83 ec 0c             	sub    $0xc,%esp
80101e6c:	68 6a 68 10 80       	push   $0x8010686a
80101e71:	e8 d2 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e76:	83 ec 0c             	sub    $0xc,%esp
80101e79:	68 80 68 10 80       	push   $0x80106880
80101e7e:	e8 c5 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e83:	83 ec 0c             	sub    $0xc,%esp
80101e86:	68 95 68 10 80       	push   $0x80106895
80101e8b:	e8 b8 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e90:	8d 50 58             	lea    0x58(%eax),%edx
80101e93:	8b 02                	mov    (%edx),%eax
80101e95:	85 c0                	test   %eax,%eax
80101e97:	75 f7                	jne    80101e90 <iderw+0x78>
    ;
  *pp = b;
80101e99:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e9b:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101ea1:	75 1a                	jne    80101ebd <iderw+0xa5>
    idestart(b);
80101ea3:	89 d8                	mov    %ebx,%eax
80101ea5:	e8 a5 fd ff ff       	call   80101c4f <idestart>
80101eaa:	eb 11                	jmp    80101ebd <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101eac:	83 ec 08             	sub    $0x8,%esp
80101eaf:	68 80 a5 10 80       	push   $0x8010a580
80101eb4:	53                   	push   %ebx
80101eb5:	e8 99 19 00 00       	call   80103853 <sleep>
80101eba:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101ebd:	8b 03                	mov    (%ebx),%eax
80101ebf:	83 e0 06             	and    $0x6,%eax
80101ec2:	83 f8 02             	cmp    $0x2,%eax
80101ec5:	75 e5                	jne    80101eac <iderw+0x94>
  }


  release(&idelock);
80101ec7:	83 ec 0c             	sub    $0xc,%esp
80101eca:	68 80 a5 10 80       	push   $0x8010a580
80101ecf:	e8 df 1e 00 00       	call   80103db3 <release>
}
80101ed4:	83 c4 10             	add    $0x10,%esp
80101ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101eda:	c9                   	leave  
80101edb:	c3                   	ret    

80101edc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101edc:	55                   	push   %ebp
80101edd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101edf:	8b 15 74 26 12 80    	mov    0x80122674,%edx
80101ee5:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ee7:	a1 74 26 12 80       	mov    0x80122674,%eax
80101eec:	8b 40 10             	mov    0x10(%eax),%eax
}
80101eef:	5d                   	pop    %ebp
80101ef0:	c3                   	ret    

80101ef1 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ef1:	55                   	push   %ebp
80101ef2:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ef4:	8b 0d 74 26 12 80    	mov    0x80122674,%ecx
80101efa:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101efc:	a1 74 26 12 80       	mov    0x80122674,%eax
80101f01:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f04:	5d                   	pop    %ebp
80101f05:	c3                   	ret    

80101f06 <ioapicinit>:

void
ioapicinit(void)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	57                   	push   %edi
80101f0a:	56                   	push   %esi
80101f0b:	53                   	push   %ebx
80101f0c:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f0f:	c7 05 74 26 12 80 00 	movl   $0xfec00000,0x80122674
80101f16:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f19:	b8 01 00 00 00       	mov    $0x1,%eax
80101f1e:	e8 b9 ff ff ff       	call   80101edc <ioapicread>
80101f23:	c1 e8 10             	shr    $0x10,%eax
80101f26:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f29:	b8 00 00 00 00       	mov    $0x0,%eax
80101f2e:	e8 a9 ff ff ff       	call   80101edc <ioapicread>
80101f33:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f36:	0f b6 15 c0 27 14 80 	movzbl 0x801427c0,%edx
80101f3d:	39 c2                	cmp    %eax,%edx
80101f3f:	75 07                	jne    80101f48 <ioapicinit+0x42>
{
80101f41:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f46:	eb 36                	jmp    80101f7e <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f48:	83 ec 0c             	sub    $0xc,%esp
80101f4b:	68 b4 68 10 80       	push   $0x801068b4
80101f50:	e8 b6 e6 ff ff       	call   8010060b <cprintf>
80101f55:	83 c4 10             	add    $0x10,%esp
80101f58:	eb e7                	jmp    80101f41 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f5a:	8d 53 20             	lea    0x20(%ebx),%edx
80101f5d:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f63:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f67:	89 f0                	mov    %esi,%eax
80101f69:	e8 83 ff ff ff       	call   80101ef1 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f6e:	8d 46 01             	lea    0x1(%esi),%eax
80101f71:	ba 00 00 00 00       	mov    $0x0,%edx
80101f76:	e8 76 ff ff ff       	call   80101ef1 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f7b:	83 c3 01             	add    $0x1,%ebx
80101f7e:	39 fb                	cmp    %edi,%ebx
80101f80:	7e d8                	jle    80101f5a <ioapicinit+0x54>
  }
}
80101f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f85:	5b                   	pop    %ebx
80101f86:	5e                   	pop    %esi
80101f87:	5f                   	pop    %edi
80101f88:	5d                   	pop    %ebp
80101f89:	c3                   	ret    

80101f8a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f8a:	55                   	push   %ebp
80101f8b:	89 e5                	mov    %esp,%ebp
80101f8d:	53                   	push   %ebx
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f91:	8d 50 20             	lea    0x20(%eax),%edx
80101f94:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f98:	89 d8                	mov    %ebx,%eax
80101f9a:	e8 52 ff ff ff       	call   80101ef1 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fa2:	c1 e2 18             	shl    $0x18,%edx
80101fa5:	8d 43 01             	lea    0x1(%ebx),%eax
80101fa8:	e8 44 ff ff ff       	call   80101ef1 <ioapicwrite>
}
80101fad:	5b                   	pop    %ebx
80101fae:	5d                   	pop    %ebp
80101faf:	c3                   	ret    

80101fb0 <update>:
  int use_lock;
  struct run *freelist;
} kmem;

void 
update() {
80101fb0:	55                   	push   %ebp
80101fb1:	89 e5                	mov    %esp,%ebp
  for (int i = 0; i < 16384; i++) {
80101fb3:	b8 00 00 00 00       	mov    $0x0,%eax
80101fb8:	eb 19                	jmp    80101fd3 <update+0x23>
      if (frame[i] != 0){ 
        r_frame[i] = 0xDFFF - i;
        r_pid[i] = frame[i];       
      }
    } else {
      r_frame[i] = -1;
80101fba:	c7 04 85 c0 26 13 80 	movl   $0xffffffff,-0x7fecd940(,%eax,4)
80101fc1:	ff ff ff ff 
      r_pid[i] = -1;
80101fc5:	c7 04 85 c0 26 12 80 	movl   $0xffffffff,-0x7fedd940(,%eax,4)
80101fcc:	ff ff ff ff 
  for (int i = 0; i < 16384; i++) {
80101fd0:	83 c0 01             	add    $0x1,%eax
80101fd3:	3d ff 3f 00 00       	cmp    $0x3fff,%eax
80101fd8:	7f 29                	jg     80102003 <update+0x53>
    if (i <= 10000) {
80101fda:	3d 10 27 00 00       	cmp    $0x2710,%eax
80101fdf:	7f d9                	jg     80101fba <update+0xa>
      if (frame[i] != 0){ 
80101fe1:	8b 14 85 e0 a5 10 80 	mov    -0x7fef5a20(,%eax,4),%edx
80101fe8:	85 d2                	test   %edx,%edx
80101fea:	74 e4                	je     80101fd0 <update+0x20>
        r_frame[i] = 0xDFFF - i;
80101fec:	b9 ff df 00 00       	mov    $0xdfff,%ecx
80101ff1:	29 c1                	sub    %eax,%ecx
80101ff3:	89 0c 85 c0 26 13 80 	mov    %ecx,-0x7fecd940(,%eax,4)
        r_pid[i] = frame[i];       
80101ffa:	89 14 85 c0 26 12 80 	mov    %edx,-0x7fedd940(,%eax,4)
80102001:	eb cd                	jmp    80101fd0 <update+0x20>
    }
  }
}
80102003:	5d                   	pop    %ebp
80102004:	c3                   	ret    

80102005 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102005:	55                   	push   %ebp
80102006:	89 e5                	mov    %esp,%ebp
80102008:	56                   	push   %esi
80102009:	53                   	push   %ebx
8010200a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010200d:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102013:	75 5b                	jne    80102070 <kfree+0x6b>
80102015:	81 fb 08 55 14 80    	cmp    $0x80145508,%ebx
8010201b:	72 53                	jb     80102070 <kfree+0x6b>
8010201d:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80102023:	81 fe ff ff ff 0d    	cmp    $0xdffffff,%esi
80102029:	77 45                	ja     80102070 <kfree+0x6b>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010202b:	83 ec 04             	sub    $0x4,%esp
8010202e:	68 00 10 00 00       	push   $0x1000
80102033:	6a 01                	push   $0x1
80102035:	53                   	push   %ebx
80102036:	e8 bf 1d 00 00       	call   80103dfa <memset>

  if(kmem.use_lock)
8010203b:	83 c4 10             	add    $0x10,%esp
8010203e:	83 3d b4 26 12 80 00 	cmpl   $0x0,0x801226b4
80102045:	75 36                	jne    8010207d <kfree+0x78>
    acquire(&kmem.lock);
  r = (struct run*)v;
  int addr = (V2P((char*)r) >> 12);
80102047:	c1 ee 0c             	shr    $0xc,%esi
  // if (addr <= 1200) {
  r->next = kmem.freelist;
8010204a:	a1 b8 26 12 80       	mov    0x801226b8,%eax
8010204f:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102051:	89 1d b8 26 12 80    	mov    %ebx,0x801226b8
  // } else {
    if (flag) {
80102057:	83 3d c0 a5 10 80 00 	cmpl   $0x0,0x8010a5c0
8010205e:	75 2f                	jne    8010208f <kfree+0x8a>
      frame[index] = 0;
      update();
    }

  // }
  if(kmem.use_lock)
80102060:	83 3d b4 26 12 80 00 	cmpl   $0x0,0x801226b4
80102067:	75 3f                	jne    801020a8 <kfree+0xa3>
    release(&kmem.lock);
}
80102069:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010206c:	5b                   	pop    %ebx
8010206d:	5e                   	pop    %esi
8010206e:	5d                   	pop    %ebp
8010206f:	c3                   	ret    
    panic("kfree");
80102070:	83 ec 0c             	sub    $0xc,%esp
80102073:	68 e6 68 10 80       	push   $0x801068e6
80102078:	e8 cb e2 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010207d:	83 ec 0c             	sub    $0xc,%esp
80102080:	68 80 26 12 80       	push   $0x80122680
80102085:	e8 c4 1c 00 00       	call   80103d4e <acquire>
8010208a:	83 c4 10             	add    $0x10,%esp
8010208d:	eb b8                	jmp    80102047 <kfree+0x42>
      int index = 0XDFFF - addr;
8010208f:	b8 ff df 00 00       	mov    $0xdfff,%eax
80102094:	29 f0                	sub    %esi,%eax
      frame[index] = 0;
80102096:	c7 04 85 e0 a5 10 80 	movl   $0x0,-0x7fef5a20(,%eax,4)
8010209d:	00 00 00 00 
      update();
801020a1:	e8 0a ff ff ff       	call   80101fb0 <update>
801020a6:	eb b8                	jmp    80102060 <kfree+0x5b>
    release(&kmem.lock);
801020a8:	83 ec 0c             	sub    $0xc,%esp
801020ab:	68 80 26 12 80       	push   $0x80122680
801020b0:	e8 fe 1c 00 00       	call   80103db3 <release>
801020b5:	83 c4 10             	add    $0x10,%esp
}
801020b8:	eb af                	jmp    80102069 <kfree+0x64>

801020ba <freerange>:
{
801020ba:	55                   	push   %ebp
801020bb:	89 e5                	mov    %esp,%ebp
801020bd:	56                   	push   %esi
801020be:	53                   	push   %ebx
801020bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	05 ff 0f 00 00       	add    $0xfff,%eax
801020ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801020cf:	eb 0e                	jmp    801020df <freerange+0x25>
    kfree(p);
801020d1:	83 ec 0c             	sub    $0xc,%esp
801020d4:	50                   	push   %eax
801020d5:	e8 2b ff ff ff       	call   80102005 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801020da:	83 c4 10             	add    $0x10,%esp
801020dd:	89 f0                	mov    %esi,%eax
801020df:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
801020e5:	39 de                	cmp    %ebx,%esi
801020e7:	76 e8                	jbe    801020d1 <freerange+0x17>
}
801020e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801020ec:	5b                   	pop    %ebx
801020ed:	5e                   	pop    %esi
801020ee:	5d                   	pop    %ebp
801020ef:	c3                   	ret    

801020f0 <kinit1>:
{
801020f0:	55                   	push   %ebp
801020f1:	89 e5                	mov    %esp,%ebp
801020f3:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
801020f6:	68 ec 68 10 80       	push   $0x801068ec
801020fb:	68 80 26 12 80       	push   $0x80122680
80102100:	e8 0d 1b 00 00       	call   80103c12 <initlock>
  kmem.use_lock = 0;
80102105:	c7 05 b4 26 12 80 00 	movl   $0x0,0x801226b4
8010210c:	00 00 00 
  freerange(vstart, vend);
8010210f:	83 c4 08             	add    $0x8,%esp
80102112:	ff 75 0c             	pushl  0xc(%ebp)
80102115:	ff 75 08             	pushl  0x8(%ebp)
80102118:	e8 9d ff ff ff       	call   801020ba <freerange>
}
8010211d:	83 c4 10             	add    $0x10,%esp
80102120:	c9                   	leave  
80102121:	c3                   	ret    

80102122 <kinit2>:
{
80102122:	55                   	push   %ebp
80102123:	89 e5                	mov    %esp,%ebp
80102125:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102128:	ff 75 0c             	pushl  0xc(%ebp)
8010212b:	ff 75 08             	pushl  0x8(%ebp)
8010212e:	e8 87 ff ff ff       	call   801020ba <freerange>
  kmem.use_lock = 1;
80102133:	c7 05 b4 26 12 80 01 	movl   $0x1,0x801226b4
8010213a:	00 00 00 
  flag = 1;
8010213d:	c7 05 c0 a5 10 80 01 	movl   $0x1,0x8010a5c0
80102144:	00 00 00 
}
80102147:	83 c4 10             	add    $0x10,%esp
8010214a:	c9                   	leave  
8010214b:	c3                   	ret    

8010214c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(int pid)
{
8010214c:	55                   	push   %ebp
8010214d:	89 e5                	mov    %esp,%ebp
8010214f:	57                   	push   %edi
80102150:	56                   	push   %esi
80102151:	53                   	push   %ebx
80102152:	83 ec 1c             	sub    $0x1c,%esp
  struct run *r;

  if(kmem.use_lock)
80102155:	83 3d b4 26 12 80 00 	cmpl   $0x0,0x801226b4
8010215c:	75 1f                	jne    8010217d <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010215e:	8b 1d b8 26 12 80    	mov    0x801226b8,%ebx
  if (flag) {
80102164:	83 3d c0 a5 10 80 00 	cmpl   $0x0,0x8010a5c0
8010216b:	0f 85 bc 00 00 00    	jne    8010222d <kalloc+0xe1>
      } 
      head = head -> next;
    }
    update();
  } else {
    kmem.freelist = r->next;
80102171:	8b 03                	mov    (%ebx),%eax
80102173:	a3 b8 26 12 80       	mov    %eax,0x801226b8
80102178:	e9 9d 00 00 00       	jmp    8010221a <kalloc+0xce>
    acquire(&kmem.lock);
8010217d:	83 ec 0c             	sub    $0xc,%esp
80102180:	68 80 26 12 80       	push   $0x80122680
80102185:	e8 c4 1b 00 00       	call   80103d4e <acquire>
8010218a:	83 c4 10             	add    $0x10,%esp
8010218d:	eb cf                	jmp    8010215e <kalloc+0x12>
        if ((i == 0 || frame[i-1] == 0 || frame[i - 1] == pid) && (i == 16383 || frame[i + 1] == 0 || frame[i + 1] == pid)) {
8010218f:	81 fa ff 3f 00 00    	cmp    $0x3fff,%edx
80102195:	74 58                	je     801021ef <kalloc+0xa3>
80102197:	be 00 e0 00 00       	mov    $0xe000,%esi
8010219c:	29 c6                	sub    %eax,%esi
8010219e:	8b 04 b5 e0 a5 10 80 	mov    -0x7fef5a20(,%esi,4),%eax
801021a5:	85 c0                	test   %eax,%eax
801021a7:	74 46                	je     801021ef <kalloc+0xa3>
801021a9:	39 d8                	cmp    %ebx,%eax
801021ab:	74 42                	je     801021ef <kalloc+0xa3>
      head = head -> next;
801021ad:	8b 09                	mov    (%ecx),%ecx
    while (head) {
801021af:	85 c9                	test   %ecx,%ecx
801021b1:	0f 84 83 00 00 00    	je     8010223a <kalloc+0xee>
      int addr = (V2P((char*)head) >> 12);
801021b7:	8d 81 00 00 00 80    	lea    -0x80000000(%ecx),%eax
801021bd:	c1 e8 0c             	shr    $0xc,%eax
801021c0:	89 c7                	mov    %eax,%edi
      int i = 0xDFFF - addr;
801021c2:	ba ff df 00 00       	mov    $0xdfff,%edx
801021c7:	29 c2                	sub    %eax,%edx
      if (frame[i] == 0) {
801021c9:	83 3c 95 e0 a5 10 80 	cmpl   $0x0,-0x7fef5a20(,%edx,4)
801021d0:	00 
801021d1:	75 da                	jne    801021ad <kalloc+0x61>
        if ((i == 0 || frame[i-1] == 0 || frame[i - 1] == pid) && (i == 16383 || frame[i + 1] == 0 || frame[i + 1] == pid)) {
801021d3:	85 d2                	test   %edx,%edx
801021d5:	74 b8                	je     8010218f <kalloc+0x43>
801021d7:	be fe df 00 00       	mov    $0xdffe,%esi
801021dc:	29 c6                	sub    %eax,%esi
801021de:	8b 34 b5 e0 a5 10 80 	mov    -0x7fef5a20(,%esi,4),%esi
801021e5:	85 f6                	test   %esi,%esi
801021e7:	74 a6                	je     8010218f <kalloc+0x43>
801021e9:	39 de                	cmp    %ebx,%esi
801021eb:	75 c0                	jne    801021ad <kalloc+0x61>
801021ed:	eb a0                	jmp    8010218f <kalloc+0x43>
          r = P2V((0XDFFF - i) << 12);
801021ef:	c1 e7 0c             	shl    $0xc,%edi
801021f2:	8d 9f 00 00 00 80    	lea    -0x80000000(%edi),%ebx
          frame[i] = pid;
801021f8:	8b 45 08             	mov    0x8(%ebp),%eax
801021fb:	89 04 95 e0 a5 10 80 	mov    %eax,-0x7fef5a20(,%edx,4)
          size = i > size? i : size;
80102202:	39 15 c4 a5 10 80    	cmp    %edx,0x8010a5c4
80102208:	0f 4d 15 c4 a5 10 80 	cmovge 0x8010a5c4,%edx
8010220f:	89 15 c4 a5 10 80    	mov    %edx,0x8010a5c4
    update();
80102215:	e8 96 fd ff ff       	call   80101fb0 <update>
  //     kmem.freelist = r->next;
  //   }
  // } else {
  // }
  //
  if(kmem.use_lock)
8010221a:	83 3d b4 26 12 80 00 	cmpl   $0x0,0x801226b4
80102221:	75 1c                	jne    8010223f <kalloc+0xf3>
    release(&kmem.lock);
  return (char*)r;
}
80102223:	89 d8                	mov    %ebx,%eax
80102225:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102228:	5b                   	pop    %ebx
80102229:	5e                   	pop    %esi
8010222a:	5f                   	pop    %edi
8010222b:	5d                   	pop    %ebp
8010222c:	c3                   	ret    
    struct run *head = r;
8010222d:	89 d9                	mov    %ebx,%ecx
8010222f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80102232:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102235:	e9 75 ff ff ff       	jmp    801021af <kalloc+0x63>
8010223a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010223d:	eb d6                	jmp    80102215 <kalloc+0xc9>
    release(&kmem.lock);
8010223f:	83 ec 0c             	sub    $0xc,%esp
80102242:	68 80 26 12 80       	push   $0x80122680
80102247:	e8 67 1b 00 00       	call   80103db3 <release>
8010224c:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010224f:	eb d2                	jmp    80102223 <kalloc+0xd7>

80102251 <dump_physmem>:



int
dump_physmem(int *frames, int *pids, int numframes)
{
80102251:	55                   	push   %ebp
80102252:	89 e5                	mov    %esp,%ebp
80102254:	57                   	push   %edi
80102255:	56                   	push   %esi
80102256:	53                   	push   %ebx
80102257:	8b 75 08             	mov    0x8(%ebp),%esi
8010225a:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010225d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  if (frames == NULL || pids == NULL || numframes < 0) {
80102260:	85 f6                	test   %esi,%esi
80102262:	0f 94 c2             	sete   %dl
80102265:	85 ff                	test   %edi,%edi
80102267:	0f 94 c0             	sete   %al
8010226a:	08 c2                	or     %al,%dl
8010226c:	75 37                	jne    801022a5 <dump_physmem+0x54>
8010226e:	85 db                	test   %ebx,%ebx
80102270:	78 3a                	js     801022ac <dump_physmem+0x5b>
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
80102272:	b8 00 00 00 00       	mov    $0x0,%eax
80102277:	eb 1e                	jmp    80102297 <dump_physmem+0x46>
    //       release(&kmem.lock);
    // } else {
    //   frames[i] = -1;
    //   pids[i] = -1;
    // }
    frames[i] = r_frame[i];
80102279:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102280:	8b 0c 85 c0 26 13 80 	mov    -0x7fecd940(,%eax,4),%ecx
80102287:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
    pids[i] = r_pid[i];
8010228a:	8b 0c 85 c0 26 12 80 	mov    -0x7fedd940(,%eax,4),%ecx
80102291:	89 0c 17             	mov    %ecx,(%edi,%edx,1)
  for (int i = 0; i < numframes; i++) {
80102294:	83 c0 01             	add    $0x1,%eax
80102297:	39 d8                	cmp    %ebx,%eax
80102299:	7c de                	jl     80102279 <dump_physmem+0x28>
  }
  
  return 0;
8010229b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a0:	5b                   	pop    %ebx
801022a1:	5e                   	pop    %esi
801022a2:	5f                   	pop    %edi
801022a3:	5d                   	pop    %ebp
801022a4:	c3                   	ret    
      return -1;
801022a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022aa:	eb f4                	jmp    801022a0 <dump_physmem+0x4f>
801022ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022b1:	eb ed                	jmp    801022a0 <dump_physmem+0x4f>

801022b3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801022b3:	55                   	push   %ebp
801022b4:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022b6:	ba 64 00 00 00       	mov    $0x64,%edx
801022bb:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022bc:	a8 01                	test   $0x1,%al
801022be:	0f 84 b5 00 00 00    	je     80102379 <kbdgetc+0xc6>
801022c4:	ba 60 00 00 00       	mov    $0x60,%edx
801022c9:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801022ca:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801022cd:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801022d3:	74 5c                	je     80102331 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801022d5:	84 c0                	test   %al,%al
801022d7:	78 66                	js     8010233f <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801022d9:	8b 0d e0 a5 11 80    	mov    0x8011a5e0,%ecx
801022df:	f6 c1 40             	test   $0x40,%cl
801022e2:	74 0f                	je     801022f3 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801022e4:	83 c8 80             	or     $0xffffff80,%eax
801022e7:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801022ea:	83 e1 bf             	and    $0xffffffbf,%ecx
801022ed:	89 0d e0 a5 11 80    	mov    %ecx,0x8011a5e0
  }

  shift |= shiftcode[data];
801022f3:	0f b6 8a 20 6a 10 80 	movzbl -0x7fef95e0(%edx),%ecx
801022fa:	0b 0d e0 a5 11 80    	or     0x8011a5e0,%ecx
  shift ^= togglecode[data];
80102300:	0f b6 82 20 69 10 80 	movzbl -0x7fef96e0(%edx),%eax
80102307:	31 c1                	xor    %eax,%ecx
80102309:	89 0d e0 a5 11 80    	mov    %ecx,0x8011a5e0
  c = charcode[shift & (CTL | SHIFT)][data];
8010230f:	89 c8                	mov    %ecx,%eax
80102311:	83 e0 03             	and    $0x3,%eax
80102314:	8b 04 85 00 69 10 80 	mov    -0x7fef9700(,%eax,4),%eax
8010231b:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010231f:	f6 c1 08             	test   $0x8,%cl
80102322:	74 19                	je     8010233d <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102324:	8d 50 9f             	lea    -0x61(%eax),%edx
80102327:	83 fa 19             	cmp    $0x19,%edx
8010232a:	77 40                	ja     8010236c <kbdgetc+0xb9>
      c += 'A' - 'a';
8010232c:	83 e8 20             	sub    $0x20,%eax
8010232f:	eb 0c                	jmp    8010233d <kbdgetc+0x8a>
    shift |= E0ESC;
80102331:	83 0d e0 a5 11 80 40 	orl    $0x40,0x8011a5e0
    return 0;
80102338:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010233d:	5d                   	pop    %ebp
8010233e:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010233f:	8b 0d e0 a5 11 80    	mov    0x8011a5e0,%ecx
80102345:	f6 c1 40             	test   $0x40,%cl
80102348:	75 05                	jne    8010234f <kbdgetc+0x9c>
8010234a:	89 c2                	mov    %eax,%edx
8010234c:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
8010234f:	0f b6 82 20 6a 10 80 	movzbl -0x7fef95e0(%edx),%eax
80102356:	83 c8 40             	or     $0x40,%eax
80102359:	0f b6 c0             	movzbl %al,%eax
8010235c:	f7 d0                	not    %eax
8010235e:	21 c8                	and    %ecx,%eax
80102360:	a3 e0 a5 11 80       	mov    %eax,0x8011a5e0
    return 0;
80102365:	b8 00 00 00 00       	mov    $0x0,%eax
8010236a:	eb d1                	jmp    8010233d <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010236c:	8d 50 bf             	lea    -0x41(%eax),%edx
8010236f:	83 fa 19             	cmp    $0x19,%edx
80102372:	77 c9                	ja     8010233d <kbdgetc+0x8a>
      c += 'a' - 'A';
80102374:	83 c0 20             	add    $0x20,%eax
  return c;
80102377:	eb c4                	jmp    8010233d <kbdgetc+0x8a>
    return -1;
80102379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237e:	eb bd                	jmp    8010233d <kbdgetc+0x8a>

80102380 <kbdintr>:

void
kbdintr(void)
{
80102380:	55                   	push   %ebp
80102381:	89 e5                	mov    %esp,%ebp
80102383:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102386:	68 b3 22 10 80       	push   $0x801022b3
8010238b:	e8 ae e3 ff ff       	call   8010073e <consoleintr>
}
80102390:	83 c4 10             	add    $0x10,%esp
80102393:	c9                   	leave  
80102394:	c3                   	ret    

80102395 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102395:	55                   	push   %ebp
80102396:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102398:	8b 0d c0 26 14 80    	mov    0x801426c0,%ecx
8010239e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801023a1:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023a3:	a1 c0 26 14 80       	mov    0x801426c0,%eax
801023a8:	8b 40 20             	mov    0x20(%eax),%eax
}
801023ab:	5d                   	pop    %ebp
801023ac:	c3                   	ret    

801023ad <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801023ad:	55                   	push   %ebp
801023ae:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023b0:	ba 70 00 00 00       	mov    $0x70,%edx
801023b5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023b6:	ba 71 00 00 00       	mov    $0x71,%edx
801023bb:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801023bc:	0f b6 c0             	movzbl %al,%eax
}
801023bf:	5d                   	pop    %ebp
801023c0:	c3                   	ret    

801023c1 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801023c1:	55                   	push   %ebp
801023c2:	89 e5                	mov    %esp,%ebp
801023c4:	53                   	push   %ebx
801023c5:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801023c7:	b8 00 00 00 00       	mov    $0x0,%eax
801023cc:	e8 dc ff ff ff       	call   801023ad <cmos_read>
801023d1:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801023d3:	b8 02 00 00 00       	mov    $0x2,%eax
801023d8:	e8 d0 ff ff ff       	call   801023ad <cmos_read>
801023dd:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801023e0:	b8 04 00 00 00       	mov    $0x4,%eax
801023e5:	e8 c3 ff ff ff       	call   801023ad <cmos_read>
801023ea:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801023ed:	b8 07 00 00 00       	mov    $0x7,%eax
801023f2:	e8 b6 ff ff ff       	call   801023ad <cmos_read>
801023f7:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801023fa:	b8 08 00 00 00       	mov    $0x8,%eax
801023ff:	e8 a9 ff ff ff       	call   801023ad <cmos_read>
80102404:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102407:	b8 09 00 00 00       	mov    $0x9,%eax
8010240c:	e8 9c ff ff ff       	call   801023ad <cmos_read>
80102411:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102414:	5b                   	pop    %ebx
80102415:	5d                   	pop    %ebp
80102416:	c3                   	ret    

80102417 <lapicinit>:
  if(!lapic)
80102417:	83 3d c0 26 14 80 00 	cmpl   $0x0,0x801426c0
8010241e:	0f 84 fb 00 00 00    	je     8010251f <lapicinit+0x108>
{
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102427:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010242c:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102431:	e8 5f ff ff ff       	call   80102395 <lapicw>
  lapicw(TDCR, X1);
80102436:	ba 0b 00 00 00       	mov    $0xb,%edx
8010243b:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102440:	e8 50 ff ff ff       	call   80102395 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102445:	ba 20 00 02 00       	mov    $0x20020,%edx
8010244a:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010244f:	e8 41 ff ff ff       	call   80102395 <lapicw>
  lapicw(TICR, 10000000);
80102454:	ba 80 96 98 00       	mov    $0x989680,%edx
80102459:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010245e:	e8 32 ff ff ff       	call   80102395 <lapicw>
  lapicw(LINT0, MASKED);
80102463:	ba 00 00 01 00       	mov    $0x10000,%edx
80102468:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010246d:	e8 23 ff ff ff       	call   80102395 <lapicw>
  lapicw(LINT1, MASKED);
80102472:	ba 00 00 01 00       	mov    $0x10000,%edx
80102477:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010247c:	e8 14 ff ff ff       	call   80102395 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102481:	a1 c0 26 14 80       	mov    0x801426c0,%eax
80102486:	8b 40 30             	mov    0x30(%eax),%eax
80102489:	c1 e8 10             	shr    $0x10,%eax
8010248c:	3c 03                	cmp    $0x3,%al
8010248e:	77 7b                	ja     8010250b <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102490:	ba 33 00 00 00       	mov    $0x33,%edx
80102495:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010249a:	e8 f6 fe ff ff       	call   80102395 <lapicw>
  lapicw(ESR, 0);
8010249f:	ba 00 00 00 00       	mov    $0x0,%edx
801024a4:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024a9:	e8 e7 fe ff ff       	call   80102395 <lapicw>
  lapicw(ESR, 0);
801024ae:	ba 00 00 00 00       	mov    $0x0,%edx
801024b3:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024b8:	e8 d8 fe ff ff       	call   80102395 <lapicw>
  lapicw(EOI, 0);
801024bd:	ba 00 00 00 00       	mov    $0x0,%edx
801024c2:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024c7:	e8 c9 fe ff ff       	call   80102395 <lapicw>
  lapicw(ICRHI, 0);
801024cc:	ba 00 00 00 00       	mov    $0x0,%edx
801024d1:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024d6:	e8 ba fe ff ff       	call   80102395 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801024db:	ba 00 85 08 00       	mov    $0x88500,%edx
801024e0:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024e5:	e8 ab fe ff ff       	call   80102395 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801024ea:	a1 c0 26 14 80       	mov    0x801426c0,%eax
801024ef:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801024f5:	f6 c4 10             	test   $0x10,%ah
801024f8:	75 f0                	jne    801024ea <lapicinit+0xd3>
  lapicw(TPR, 0);
801024fa:	ba 00 00 00 00       	mov    $0x0,%edx
801024ff:	b8 20 00 00 00       	mov    $0x20,%eax
80102504:	e8 8c fe ff ff       	call   80102395 <lapicw>
}
80102509:	5d                   	pop    %ebp
8010250a:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010250b:	ba 00 00 01 00       	mov    $0x10000,%edx
80102510:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102515:	e8 7b fe ff ff       	call   80102395 <lapicw>
8010251a:	e9 71 ff ff ff       	jmp    80102490 <lapicinit+0x79>
8010251f:	f3 c3                	repz ret 

80102521 <lapicid>:
{
80102521:	55                   	push   %ebp
80102522:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102524:	a1 c0 26 14 80       	mov    0x801426c0,%eax
80102529:	85 c0                	test   %eax,%eax
8010252b:	74 08                	je     80102535 <lapicid+0x14>
  return lapic[ID] >> 24;
8010252d:	8b 40 20             	mov    0x20(%eax),%eax
80102530:	c1 e8 18             	shr    $0x18,%eax
}
80102533:	5d                   	pop    %ebp
80102534:	c3                   	ret    
    return 0;
80102535:	b8 00 00 00 00       	mov    $0x0,%eax
8010253a:	eb f7                	jmp    80102533 <lapicid+0x12>

8010253c <lapiceoi>:
  if(lapic)
8010253c:	83 3d c0 26 14 80 00 	cmpl   $0x0,0x801426c0
80102543:	74 14                	je     80102559 <lapiceoi+0x1d>
{
80102545:	55                   	push   %ebp
80102546:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102548:	ba 00 00 00 00       	mov    $0x0,%edx
8010254d:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102552:	e8 3e fe ff ff       	call   80102395 <lapicw>
}
80102557:	5d                   	pop    %ebp
80102558:	c3                   	ret    
80102559:	f3 c3                	repz ret 

8010255b <microdelay>:
{
8010255b:	55                   	push   %ebp
8010255c:	89 e5                	mov    %esp,%ebp
}
8010255e:	5d                   	pop    %ebp
8010255f:	c3                   	ret    

80102560 <lapicstartap>:
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
80102563:	57                   	push   %edi
80102564:	56                   	push   %esi
80102565:	53                   	push   %ebx
80102566:	8b 75 08             	mov    0x8(%ebp),%esi
80102569:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010256c:	b8 0f 00 00 00       	mov    $0xf,%eax
80102571:	ba 70 00 00 00       	mov    $0x70,%edx
80102576:	ee                   	out    %al,(%dx)
80102577:	b8 0a 00 00 00       	mov    $0xa,%eax
8010257c:	ba 71 00 00 00       	mov    $0x71,%edx
80102581:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102582:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102589:	00 00 
  wrv[1] = addr >> 4;
8010258b:	89 f8                	mov    %edi,%eax
8010258d:	c1 e8 04             	shr    $0x4,%eax
80102590:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102596:	c1 e6 18             	shl    $0x18,%esi
80102599:	89 f2                	mov    %esi,%edx
8010259b:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025a0:	e8 f0 fd ff ff       	call   80102395 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801025a5:	ba 00 c5 00 00       	mov    $0xc500,%edx
801025aa:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025af:	e8 e1 fd ff ff       	call   80102395 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801025b4:	ba 00 85 00 00       	mov    $0x8500,%edx
801025b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025be:	e8 d2 fd ff ff       	call   80102395 <lapicw>
  for(i = 0; i < 2; i++){
801025c3:	bb 00 00 00 00       	mov    $0x0,%ebx
801025c8:	eb 21                	jmp    801025eb <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801025ca:	89 f2                	mov    %esi,%edx
801025cc:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025d1:	e8 bf fd ff ff       	call   80102395 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801025d6:	89 fa                	mov    %edi,%edx
801025d8:	c1 ea 0c             	shr    $0xc,%edx
801025db:	80 ce 06             	or     $0x6,%dh
801025de:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025e3:	e8 ad fd ff ff       	call   80102395 <lapicw>
  for(i = 0; i < 2; i++){
801025e8:	83 c3 01             	add    $0x1,%ebx
801025eb:	83 fb 01             	cmp    $0x1,%ebx
801025ee:	7e da                	jle    801025ca <lapicstartap+0x6a>
}
801025f0:	5b                   	pop    %ebx
801025f1:	5e                   	pop    %esi
801025f2:	5f                   	pop    %edi
801025f3:	5d                   	pop    %ebp
801025f4:	c3                   	ret    

801025f5 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801025f5:	55                   	push   %ebp
801025f6:	89 e5                	mov    %esp,%ebp
801025f8:	57                   	push   %edi
801025f9:	56                   	push   %esi
801025fa:	53                   	push   %ebx
801025fb:	83 ec 3c             	sub    $0x3c,%esp
801025fe:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102601:	b8 0b 00 00 00       	mov    $0xb,%eax
80102606:	e8 a2 fd ff ff       	call   801023ad <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010260b:	83 e0 04             	and    $0x4,%eax
8010260e:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102610:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102613:	e8 a9 fd ff ff       	call   801023c1 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102618:	b8 0a 00 00 00       	mov    $0xa,%eax
8010261d:	e8 8b fd ff ff       	call   801023ad <cmos_read>
80102622:	a8 80                	test   $0x80,%al
80102624:	75 ea                	jne    80102610 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102626:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102629:	89 d8                	mov    %ebx,%eax
8010262b:	e8 91 fd ff ff       	call   801023c1 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102630:	83 ec 04             	sub    $0x4,%esp
80102633:	6a 18                	push   $0x18
80102635:	53                   	push   %ebx
80102636:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102639:	50                   	push   %eax
8010263a:	e8 01 18 00 00       	call   80103e40 <memcmp>
8010263f:	83 c4 10             	add    $0x10,%esp
80102642:	85 c0                	test   %eax,%eax
80102644:	75 ca                	jne    80102610 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102646:	85 ff                	test   %edi,%edi
80102648:	0f 85 84 00 00 00    	jne    801026d2 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010264e:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102651:	89 d0                	mov    %edx,%eax
80102653:	c1 e8 04             	shr    $0x4,%eax
80102656:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102659:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010265c:	83 e2 0f             	and    $0xf,%edx
8010265f:	01 d0                	add    %edx,%eax
80102661:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102664:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102667:	89 d0                	mov    %edx,%eax
80102669:	c1 e8 04             	shr    $0x4,%eax
8010266c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010266f:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102672:	83 e2 0f             	and    $0xf,%edx
80102675:	01 d0                	add    %edx,%eax
80102677:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010267a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010267d:	89 d0                	mov    %edx,%eax
8010267f:	c1 e8 04             	shr    $0x4,%eax
80102682:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102685:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102688:	83 e2 0f             	and    $0xf,%edx
8010268b:	01 d0                	add    %edx,%eax
8010268d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102690:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102693:	89 d0                	mov    %edx,%eax
80102695:	c1 e8 04             	shr    $0x4,%eax
80102698:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010269b:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010269e:	83 e2 0f             	and    $0xf,%edx
801026a1:	01 d0                	add    %edx,%eax
801026a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801026a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801026a9:	89 d0                	mov    %edx,%eax
801026ab:	c1 e8 04             	shr    $0x4,%eax
801026ae:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026b1:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026b4:	83 e2 0f             	and    $0xf,%edx
801026b7:	01 d0                	add    %edx,%eax
801026b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801026bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801026bf:	89 d0                	mov    %edx,%eax
801026c1:	c1 e8 04             	shr    $0x4,%eax
801026c4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026c7:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026ca:	83 e2 0f             	and    $0xf,%edx
801026cd:	01 d0                	add    %edx,%eax
801026cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801026d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801026d5:	89 06                	mov    %eax,(%esi)
801026d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801026da:	89 46 04             	mov    %eax,0x4(%esi)
801026dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801026e0:	89 46 08             	mov    %eax,0x8(%esi)
801026e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801026e6:	89 46 0c             	mov    %eax,0xc(%esi)
801026e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801026ec:	89 46 10             	mov    %eax,0x10(%esi)
801026ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801026f2:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801026f5:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801026fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026ff:	5b                   	pop    %ebx
80102700:	5e                   	pop    %esi
80102701:	5f                   	pop    %edi
80102702:	5d                   	pop    %ebp
80102703:	c3                   	ret    

80102704 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102704:	55                   	push   %ebp
80102705:	89 e5                	mov    %esp,%ebp
80102707:	53                   	push   %ebx
80102708:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010270b:	ff 35 14 27 14 80    	pushl  0x80142714
80102711:	ff 35 24 27 14 80    	pushl  0x80142724
80102717:	e8 50 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010271c:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010271f:	89 1d 28 27 14 80    	mov    %ebx,0x80142728
  for (i = 0; i < log.lh.n; i++) {
80102725:	83 c4 10             	add    $0x10,%esp
80102728:	ba 00 00 00 00       	mov    $0x0,%edx
8010272d:	eb 0e                	jmp    8010273d <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010272f:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102733:	89 0c 95 2c 27 14 80 	mov    %ecx,-0x7febd8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010273a:	83 c2 01             	add    $0x1,%edx
8010273d:	39 d3                	cmp    %edx,%ebx
8010273f:	7f ee                	jg     8010272f <read_head+0x2b>
  }
  brelse(buf);
80102741:	83 ec 0c             	sub    $0xc,%esp
80102744:	50                   	push   %eax
80102745:	e8 8b da ff ff       	call   801001d5 <brelse>
}
8010274a:	83 c4 10             	add    $0x10,%esp
8010274d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102750:	c9                   	leave  
80102751:	c3                   	ret    

80102752 <install_trans>:
{
80102752:	55                   	push   %ebp
80102753:	89 e5                	mov    %esp,%ebp
80102755:	57                   	push   %edi
80102756:	56                   	push   %esi
80102757:	53                   	push   %ebx
80102758:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010275b:	bb 00 00 00 00       	mov    $0x0,%ebx
80102760:	eb 66                	jmp    801027c8 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102762:	89 d8                	mov    %ebx,%eax
80102764:	03 05 14 27 14 80    	add    0x80142714,%eax
8010276a:	83 c0 01             	add    $0x1,%eax
8010276d:	83 ec 08             	sub    $0x8,%esp
80102770:	50                   	push   %eax
80102771:	ff 35 24 27 14 80    	pushl  0x80142724
80102777:	e8 f0 d9 ff ff       	call   8010016c <bread>
8010277c:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010277e:	83 c4 08             	add    $0x8,%esp
80102781:	ff 34 9d 2c 27 14 80 	pushl  -0x7febd8d4(,%ebx,4)
80102788:	ff 35 24 27 14 80    	pushl  0x80142724
8010278e:	e8 d9 d9 ff ff       	call   8010016c <bread>
80102793:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102795:	8d 57 5c             	lea    0x5c(%edi),%edx
80102798:	8d 40 5c             	lea    0x5c(%eax),%eax
8010279b:	83 c4 0c             	add    $0xc,%esp
8010279e:	68 00 02 00 00       	push   $0x200
801027a3:	52                   	push   %edx
801027a4:	50                   	push   %eax
801027a5:	e8 cb 16 00 00       	call   80103e75 <memmove>
    bwrite(dbuf);  // write dst to disk
801027aa:	89 34 24             	mov    %esi,(%esp)
801027ad:	e8 e8 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801027b2:	89 3c 24             	mov    %edi,(%esp)
801027b5:	e8 1b da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801027ba:	89 34 24             	mov    %esi,(%esp)
801027bd:	e8 13 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027c2:	83 c3 01             	add    $0x1,%ebx
801027c5:	83 c4 10             	add    $0x10,%esp
801027c8:	39 1d 28 27 14 80    	cmp    %ebx,0x80142728
801027ce:	7f 92                	jg     80102762 <install_trans+0x10>
}
801027d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027d3:	5b                   	pop    %ebx
801027d4:	5e                   	pop    %esi
801027d5:	5f                   	pop    %edi
801027d6:	5d                   	pop    %ebp
801027d7:	c3                   	ret    

801027d8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801027d8:	55                   	push   %ebp
801027d9:	89 e5                	mov    %esp,%ebp
801027db:	53                   	push   %ebx
801027dc:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801027df:	ff 35 14 27 14 80    	pushl  0x80142714
801027e5:	ff 35 24 27 14 80    	pushl  0x80142724
801027eb:	e8 7c d9 ff ff       	call   8010016c <bread>
801027f0:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801027f2:	8b 0d 28 27 14 80    	mov    0x80142728,%ecx
801027f8:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801027fb:	83 c4 10             	add    $0x10,%esp
801027fe:	b8 00 00 00 00       	mov    $0x0,%eax
80102803:	eb 0e                	jmp    80102813 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102805:	8b 14 85 2c 27 14 80 	mov    -0x7febd8d4(,%eax,4),%edx
8010280c:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102810:	83 c0 01             	add    $0x1,%eax
80102813:	39 c1                	cmp    %eax,%ecx
80102815:	7f ee                	jg     80102805 <write_head+0x2d>
  }
  bwrite(buf);
80102817:	83 ec 0c             	sub    $0xc,%esp
8010281a:	53                   	push   %ebx
8010281b:	e8 7a d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102820:	89 1c 24             	mov    %ebx,(%esp)
80102823:	e8 ad d9 ff ff       	call   801001d5 <brelse>
}
80102828:	83 c4 10             	add    $0x10,%esp
8010282b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010282e:	c9                   	leave  
8010282f:	c3                   	ret    

80102830 <recover_from_log>:

static void
recover_from_log(void)
{
80102830:	55                   	push   %ebp
80102831:	89 e5                	mov    %esp,%ebp
80102833:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102836:	e8 c9 fe ff ff       	call   80102704 <read_head>
  install_trans(); // if committed, copy from log to disk
8010283b:	e8 12 ff ff ff       	call   80102752 <install_trans>
  log.lh.n = 0;
80102840:	c7 05 28 27 14 80 00 	movl   $0x0,0x80142728
80102847:	00 00 00 
  write_head(); // clear the log
8010284a:	e8 89 ff ff ff       	call   801027d8 <write_head>
}
8010284f:	c9                   	leave  
80102850:	c3                   	ret    

80102851 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102851:	55                   	push   %ebp
80102852:	89 e5                	mov    %esp,%ebp
80102854:	57                   	push   %edi
80102855:	56                   	push   %esi
80102856:	53                   	push   %ebx
80102857:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010285a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010285f:	eb 66                	jmp    801028c7 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102861:	89 d8                	mov    %ebx,%eax
80102863:	03 05 14 27 14 80    	add    0x80142714,%eax
80102869:	83 c0 01             	add    $0x1,%eax
8010286c:	83 ec 08             	sub    $0x8,%esp
8010286f:	50                   	push   %eax
80102870:	ff 35 24 27 14 80    	pushl  0x80142724
80102876:	e8 f1 d8 ff ff       	call   8010016c <bread>
8010287b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010287d:	83 c4 08             	add    $0x8,%esp
80102880:	ff 34 9d 2c 27 14 80 	pushl  -0x7febd8d4(,%ebx,4)
80102887:	ff 35 24 27 14 80    	pushl  0x80142724
8010288d:	e8 da d8 ff ff       	call   8010016c <bread>
80102892:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102894:	8d 50 5c             	lea    0x5c(%eax),%edx
80102897:	8d 46 5c             	lea    0x5c(%esi),%eax
8010289a:	83 c4 0c             	add    $0xc,%esp
8010289d:	68 00 02 00 00       	push   $0x200
801028a2:	52                   	push   %edx
801028a3:	50                   	push   %eax
801028a4:	e8 cc 15 00 00       	call   80103e75 <memmove>
    bwrite(to);  // write the log
801028a9:	89 34 24             	mov    %esi,(%esp)
801028ac:	e8 e9 d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
801028b1:	89 3c 24             	mov    %edi,(%esp)
801028b4:	e8 1c d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
801028b9:	89 34 24             	mov    %esi,(%esp)
801028bc:	e8 14 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801028c1:	83 c3 01             	add    $0x1,%ebx
801028c4:	83 c4 10             	add    $0x10,%esp
801028c7:	39 1d 28 27 14 80    	cmp    %ebx,0x80142728
801028cd:	7f 92                	jg     80102861 <write_log+0x10>
  }
}
801028cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801028d2:	5b                   	pop    %ebx
801028d3:	5e                   	pop    %esi
801028d4:	5f                   	pop    %edi
801028d5:	5d                   	pop    %ebp
801028d6:	c3                   	ret    

801028d7 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801028d7:	83 3d 28 27 14 80 00 	cmpl   $0x0,0x80142728
801028de:	7e 26                	jle    80102906 <commit+0x2f>
{
801028e0:	55                   	push   %ebp
801028e1:	89 e5                	mov    %esp,%ebp
801028e3:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801028e6:	e8 66 ff ff ff       	call   80102851 <write_log>
    write_head();    // Write header to disk -- the real commit
801028eb:	e8 e8 fe ff ff       	call   801027d8 <write_head>
    install_trans(); // Now install writes to home locations
801028f0:	e8 5d fe ff ff       	call   80102752 <install_trans>
    log.lh.n = 0;
801028f5:	c7 05 28 27 14 80 00 	movl   $0x0,0x80142728
801028fc:	00 00 00 
    write_head();    // Erase the transaction from the log
801028ff:	e8 d4 fe ff ff       	call   801027d8 <write_head>
  }
}
80102904:	c9                   	leave  
80102905:	c3                   	ret    
80102906:	f3 c3                	repz ret 

80102908 <initlog>:
{
80102908:	55                   	push   %ebp
80102909:	89 e5                	mov    %esp,%ebp
8010290b:	53                   	push   %ebx
8010290c:	83 ec 2c             	sub    $0x2c,%esp
8010290f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102912:	68 20 6b 10 80       	push   $0x80106b20
80102917:	68 e0 26 14 80       	push   $0x801426e0
8010291c:	e8 f1 12 00 00       	call   80103c12 <initlock>
  readsb(dev, &sb);
80102921:	83 c4 08             	add    $0x8,%esp
80102924:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102927:	50                   	push   %eax
80102928:	53                   	push   %ebx
80102929:	e8 14 e9 ff ff       	call   80101242 <readsb>
  log.start = sb.logstart;
8010292e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102931:	a3 14 27 14 80       	mov    %eax,0x80142714
  log.size = sb.nlog;
80102936:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102939:	a3 18 27 14 80       	mov    %eax,0x80142718
  log.dev = dev;
8010293e:	89 1d 24 27 14 80    	mov    %ebx,0x80142724
  recover_from_log();
80102944:	e8 e7 fe ff ff       	call   80102830 <recover_from_log>
}
80102949:	83 c4 10             	add    $0x10,%esp
8010294c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010294f:	c9                   	leave  
80102950:	c3                   	ret    

80102951 <begin_op>:
{
80102951:	55                   	push   %ebp
80102952:	89 e5                	mov    %esp,%ebp
80102954:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102957:	68 e0 26 14 80       	push   $0x801426e0
8010295c:	e8 ed 13 00 00       	call   80103d4e <acquire>
80102961:	83 c4 10             	add    $0x10,%esp
80102964:	eb 15                	jmp    8010297b <begin_op+0x2a>
      sleep(&log, &log.lock);
80102966:	83 ec 08             	sub    $0x8,%esp
80102969:	68 e0 26 14 80       	push   $0x801426e0
8010296e:	68 e0 26 14 80       	push   $0x801426e0
80102973:	e8 db 0e 00 00       	call   80103853 <sleep>
80102978:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010297b:	83 3d 20 27 14 80 00 	cmpl   $0x0,0x80142720
80102982:	75 e2                	jne    80102966 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102984:	a1 1c 27 14 80       	mov    0x8014271c,%eax
80102989:	83 c0 01             	add    $0x1,%eax
8010298c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010298f:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102992:	03 15 28 27 14 80    	add    0x80142728,%edx
80102998:	83 fa 1e             	cmp    $0x1e,%edx
8010299b:	7e 17                	jle    801029b4 <begin_op+0x63>
      sleep(&log, &log.lock);
8010299d:	83 ec 08             	sub    $0x8,%esp
801029a0:	68 e0 26 14 80       	push   $0x801426e0
801029a5:	68 e0 26 14 80       	push   $0x801426e0
801029aa:	e8 a4 0e 00 00       	call   80103853 <sleep>
801029af:	83 c4 10             	add    $0x10,%esp
801029b2:	eb c7                	jmp    8010297b <begin_op+0x2a>
      log.outstanding += 1;
801029b4:	a3 1c 27 14 80       	mov    %eax,0x8014271c
      release(&log.lock);
801029b9:	83 ec 0c             	sub    $0xc,%esp
801029bc:	68 e0 26 14 80       	push   $0x801426e0
801029c1:	e8 ed 13 00 00       	call   80103db3 <release>
}
801029c6:	83 c4 10             	add    $0x10,%esp
801029c9:	c9                   	leave  
801029ca:	c3                   	ret    

801029cb <end_op>:
{
801029cb:	55                   	push   %ebp
801029cc:	89 e5                	mov    %esp,%ebp
801029ce:	53                   	push   %ebx
801029cf:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801029d2:	68 e0 26 14 80       	push   $0x801426e0
801029d7:	e8 72 13 00 00       	call   80103d4e <acquire>
  log.outstanding -= 1;
801029dc:	a1 1c 27 14 80       	mov    0x8014271c,%eax
801029e1:	83 e8 01             	sub    $0x1,%eax
801029e4:	a3 1c 27 14 80       	mov    %eax,0x8014271c
  if(log.committing)
801029e9:	8b 1d 20 27 14 80    	mov    0x80142720,%ebx
801029ef:	83 c4 10             	add    $0x10,%esp
801029f2:	85 db                	test   %ebx,%ebx
801029f4:	75 2c                	jne    80102a22 <end_op+0x57>
  if(log.outstanding == 0){
801029f6:	85 c0                	test   %eax,%eax
801029f8:	75 35                	jne    80102a2f <end_op+0x64>
    log.committing = 1;
801029fa:	c7 05 20 27 14 80 01 	movl   $0x1,0x80142720
80102a01:	00 00 00 
    do_commit = 1;
80102a04:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102a09:	83 ec 0c             	sub    $0xc,%esp
80102a0c:	68 e0 26 14 80       	push   $0x801426e0
80102a11:	e8 9d 13 00 00       	call   80103db3 <release>
  if(do_commit){
80102a16:	83 c4 10             	add    $0x10,%esp
80102a19:	85 db                	test   %ebx,%ebx
80102a1b:	75 24                	jne    80102a41 <end_op+0x76>
}
80102a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a20:	c9                   	leave  
80102a21:	c3                   	ret    
    panic("log.committing");
80102a22:	83 ec 0c             	sub    $0xc,%esp
80102a25:	68 24 6b 10 80       	push   $0x80106b24
80102a2a:	e8 19 d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102a2f:	83 ec 0c             	sub    $0xc,%esp
80102a32:	68 e0 26 14 80       	push   $0x801426e0
80102a37:	e8 7c 0f 00 00       	call   801039b8 <wakeup>
80102a3c:	83 c4 10             	add    $0x10,%esp
80102a3f:	eb c8                	jmp    80102a09 <end_op+0x3e>
    commit();
80102a41:	e8 91 fe ff ff       	call   801028d7 <commit>
    acquire(&log.lock);
80102a46:	83 ec 0c             	sub    $0xc,%esp
80102a49:	68 e0 26 14 80       	push   $0x801426e0
80102a4e:	e8 fb 12 00 00       	call   80103d4e <acquire>
    log.committing = 0;
80102a53:	c7 05 20 27 14 80 00 	movl   $0x0,0x80142720
80102a5a:	00 00 00 
    wakeup(&log);
80102a5d:	c7 04 24 e0 26 14 80 	movl   $0x801426e0,(%esp)
80102a64:	e8 4f 0f 00 00       	call   801039b8 <wakeup>
    release(&log.lock);
80102a69:	c7 04 24 e0 26 14 80 	movl   $0x801426e0,(%esp)
80102a70:	e8 3e 13 00 00       	call   80103db3 <release>
80102a75:	83 c4 10             	add    $0x10,%esp
}
80102a78:	eb a3                	jmp    80102a1d <end_op+0x52>

80102a7a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a7a:	55                   	push   %ebp
80102a7b:	89 e5                	mov    %esp,%ebp
80102a7d:	53                   	push   %ebx
80102a7e:	83 ec 04             	sub    $0x4,%esp
80102a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a84:	8b 15 28 27 14 80    	mov    0x80142728,%edx
80102a8a:	83 fa 1d             	cmp    $0x1d,%edx
80102a8d:	7f 45                	jg     80102ad4 <log_write+0x5a>
80102a8f:	a1 18 27 14 80       	mov    0x80142718,%eax
80102a94:	83 e8 01             	sub    $0x1,%eax
80102a97:	39 c2                	cmp    %eax,%edx
80102a99:	7d 39                	jge    80102ad4 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a9b:	83 3d 1c 27 14 80 00 	cmpl   $0x0,0x8014271c
80102aa2:	7e 3d                	jle    80102ae1 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102aa4:	83 ec 0c             	sub    $0xc,%esp
80102aa7:	68 e0 26 14 80       	push   $0x801426e0
80102aac:	e8 9d 12 00 00       	call   80103d4e <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102ab1:	83 c4 10             	add    $0x10,%esp
80102ab4:	b8 00 00 00 00       	mov    $0x0,%eax
80102ab9:	8b 15 28 27 14 80    	mov    0x80142728,%edx
80102abf:	39 c2                	cmp    %eax,%edx
80102ac1:	7e 2b                	jle    80102aee <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102ac3:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102ac6:	39 0c 85 2c 27 14 80 	cmp    %ecx,-0x7febd8d4(,%eax,4)
80102acd:	74 1f                	je     80102aee <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102acf:	83 c0 01             	add    $0x1,%eax
80102ad2:	eb e5                	jmp    80102ab9 <log_write+0x3f>
    panic("too big a transaction");
80102ad4:	83 ec 0c             	sub    $0xc,%esp
80102ad7:	68 33 6b 10 80       	push   $0x80106b33
80102adc:	e8 67 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102ae1:	83 ec 0c             	sub    $0xc,%esp
80102ae4:	68 49 6b 10 80       	push   $0x80106b49
80102ae9:	e8 5a d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102aee:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102af1:	89 0c 85 2c 27 14 80 	mov    %ecx,-0x7febd8d4(,%eax,4)
  if (i == log.lh.n)
80102af8:	39 c2                	cmp    %eax,%edx
80102afa:	74 18                	je     80102b14 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102afc:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102aff:	83 ec 0c             	sub    $0xc,%esp
80102b02:	68 e0 26 14 80       	push   $0x801426e0
80102b07:	e8 a7 12 00 00       	call   80103db3 <release>
}
80102b0c:	83 c4 10             	add    $0x10,%esp
80102b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b12:	c9                   	leave  
80102b13:	c3                   	ret    
    log.lh.n++;
80102b14:	83 c2 01             	add    $0x1,%edx
80102b17:	89 15 28 27 14 80    	mov    %edx,0x80142728
80102b1d:	eb dd                	jmp    80102afc <log_write+0x82>

80102b1f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102b1f:	55                   	push   %ebp
80102b20:	89 e5                	mov    %esp,%ebp
80102b22:	53                   	push   %ebx
80102b23:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b26:	68 8a 00 00 00       	push   $0x8a
80102b2b:	68 8c a4 10 80       	push   $0x8010a48c
80102b30:	68 00 70 00 80       	push   $0x80007000
80102b35:	e8 3b 13 00 00       	call   80103e75 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b3a:	83 c4 10             	add    $0x10,%esp
80102b3d:	bb e0 27 14 80       	mov    $0x801427e0,%ebx
80102b42:	eb 06                	jmp    80102b4a <startothers+0x2b>
80102b44:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b4a:	69 05 60 2d 14 80 b0 	imul   $0xb0,0x80142d60,%eax
80102b51:	00 00 00 
80102b54:	05 e0 27 14 80       	add    $0x801427e0,%eax
80102b59:	39 d8                	cmp    %ebx,%eax
80102b5b:	76 51                	jbe    80102bae <startothers+0x8f>
    if(c == mycpu())  // We've started already.
80102b5d:	e8 d3 07 00 00       	call   80103335 <mycpu>
80102b62:	39 d8                	cmp    %ebx,%eax
80102b64:	74 de                	je     80102b44 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc(-2);
80102b66:	83 ec 0c             	sub    $0xc,%esp
80102b69:	6a fe                	push   $0xfffffffe
80102b6b:	e8 dc f5 ff ff       	call   8010214c <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b70:	05 00 10 00 00       	add    $0x1000,%eax
80102b75:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b7a:	c7 05 f8 6f 00 80 f2 	movl   $0x80102bf2,0x80006ff8
80102b81:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b84:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b8b:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b8e:	83 c4 08             	add    $0x8,%esp
80102b91:	68 00 70 00 00       	push   $0x7000
80102b96:	0f b6 03             	movzbl (%ebx),%eax
80102b99:	50                   	push   %eax
80102b9a:	e8 c1 f9 ff ff       	call   80102560 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b9f:	83 c4 10             	add    $0x10,%esp
80102ba2:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102ba8:	85 c0                	test   %eax,%eax
80102baa:	74 f6                	je     80102ba2 <startothers+0x83>
80102bac:	eb 96                	jmp    80102b44 <startothers+0x25>
      ;
  }
}
80102bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102bb1:	c9                   	leave  
80102bb2:	c3                   	ret    

80102bb3 <mpmain>:
{
80102bb3:	55                   	push   %ebp
80102bb4:	89 e5                	mov    %esp,%ebp
80102bb6:	53                   	push   %ebx
80102bb7:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102bba:	e8 d2 07 00 00       	call   80103391 <cpuid>
80102bbf:	89 c3                	mov    %eax,%ebx
80102bc1:	e8 cb 07 00 00       	call   80103391 <cpuid>
80102bc6:	83 ec 04             	sub    $0x4,%esp
80102bc9:	53                   	push   %ebx
80102bca:	50                   	push   %eax
80102bcb:	68 64 6b 10 80       	push   $0x80106b64
80102bd0:	e8 36 da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102bd5:	e8 f2 23 00 00       	call   80104fcc <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102bda:	e8 56 07 00 00       	call   80103335 <mycpu>
80102bdf:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102be1:	b8 01 00 00 00       	mov    $0x1,%eax
80102be6:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102bed:	e8 3c 0a 00 00       	call   8010362e <scheduler>

80102bf2 <mpenter>:
{
80102bf2:	55                   	push   %ebp
80102bf3:	89 e5                	mov    %esp,%ebp
80102bf5:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102bf8:	e8 e0 33 00 00       	call   80105fdd <switchkvm>
  seginit();
80102bfd:	e8 8f 32 00 00       	call   80105e91 <seginit>
  lapicinit();
80102c02:	e8 10 f8 ff ff       	call   80102417 <lapicinit>
  mpmain();
80102c07:	e8 a7 ff ff ff       	call   80102bb3 <mpmain>

80102c0c <main>:
{
80102c0c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102c10:	83 e4 f0             	and    $0xfffffff0,%esp
80102c13:	ff 71 fc             	pushl  -0x4(%ecx)
80102c16:	55                   	push   %ebp
80102c17:	89 e5                	mov    %esp,%ebp
80102c19:	51                   	push   %ecx
80102c1a:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102c1d:	68 00 00 40 80       	push   $0x80400000
80102c22:	68 08 55 14 80       	push   $0x80145508
80102c27:	e8 c4 f4 ff ff       	call   801020f0 <kinit1>
  kvmalloc();      // kernel page table
80102c2c:	e8 4f 38 00 00       	call   80106480 <kvmalloc>
  mpinit();        // detect other processors
80102c31:	e8 c9 01 00 00       	call   80102dff <mpinit>
  lapicinit();     // interrupt controller
80102c36:	e8 dc f7 ff ff       	call   80102417 <lapicinit>
  seginit();       // segment descriptors
80102c3b:	e8 51 32 00 00       	call   80105e91 <seginit>
  picinit();       // disable pic
80102c40:	e8 82 02 00 00       	call   80102ec7 <picinit>
  ioapicinit();    // another interrupt controller
80102c45:	e8 bc f2 ff ff       	call   80101f06 <ioapicinit>
  consoleinit();   // console hardware
80102c4a:	e8 3f dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c4f:	e8 26 26 00 00       	call   8010527a <uartinit>
  pinit();         // process table
80102c54:	e8 c2 06 00 00       	call   8010331b <pinit>
  tvinit();        // trap vectors
80102c59:	e8 bd 22 00 00       	call   80104f1b <tvinit>
  binit();         // buffer cache
80102c5e:	e8 91 d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c63:	e8 b7 df ff ff       	call   80100c1f <fileinit>
  ideinit();       // disk 
80102c68:	e8 9f f0 ff ff       	call   80101d0c <ideinit>
  startothers();   // start other processors
80102c6d:	e8 ad fe ff ff       	call   80102b1f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c72:	83 c4 08             	add    $0x8,%esp
80102c75:	68 00 00 00 8e       	push   $0x8e000000
80102c7a:	68 00 00 40 80       	push   $0x80400000
80102c7f:	e8 9e f4 ff ff       	call   80102122 <kinit2>
  userinit();      // first user process
80102c84:	e8 47 07 00 00       	call   801033d0 <userinit>
  mpmain();        // finish this processor's setup
80102c89:	e8 25 ff ff ff       	call   80102bb3 <mpmain>

80102c8e <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c8e:	55                   	push   %ebp
80102c8f:	89 e5                	mov    %esp,%ebp
80102c91:	56                   	push   %esi
80102c92:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102c98:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c9d:	eb 09                	jmp    80102ca8 <sum+0x1a>
    sum += addr[i];
80102c9f:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102ca3:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102ca5:	83 c1 01             	add    $0x1,%ecx
80102ca8:	39 d1                	cmp    %edx,%ecx
80102caa:	7c f3                	jl     80102c9f <sum+0x11>
  return sum;
}
80102cac:	89 d8                	mov    %ebx,%eax
80102cae:	5b                   	pop    %ebx
80102caf:	5e                   	pop    %esi
80102cb0:	5d                   	pop    %ebp
80102cb1:	c3                   	ret    

80102cb2 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102cb2:	55                   	push   %ebp
80102cb3:	89 e5                	mov    %esp,%ebp
80102cb5:	56                   	push   %esi
80102cb6:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102cb7:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102cbd:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102cbf:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102cc1:	eb 03                	jmp    80102cc6 <mpsearch1+0x14>
80102cc3:	83 c3 10             	add    $0x10,%ebx
80102cc6:	39 f3                	cmp    %esi,%ebx
80102cc8:	73 29                	jae    80102cf3 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102cca:	83 ec 04             	sub    $0x4,%esp
80102ccd:	6a 04                	push   $0x4
80102ccf:	68 78 6b 10 80       	push   $0x80106b78
80102cd4:	53                   	push   %ebx
80102cd5:	e8 66 11 00 00       	call   80103e40 <memcmp>
80102cda:	83 c4 10             	add    $0x10,%esp
80102cdd:	85 c0                	test   %eax,%eax
80102cdf:	75 e2                	jne    80102cc3 <mpsearch1+0x11>
80102ce1:	ba 10 00 00 00       	mov    $0x10,%edx
80102ce6:	89 d8                	mov    %ebx,%eax
80102ce8:	e8 a1 ff ff ff       	call   80102c8e <sum>
80102ced:	84 c0                	test   %al,%al
80102cef:	75 d2                	jne    80102cc3 <mpsearch1+0x11>
80102cf1:	eb 05                	jmp    80102cf8 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102cf8:	89 d8                	mov    %ebx,%eax
80102cfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102cfd:	5b                   	pop    %ebx
80102cfe:	5e                   	pop    %esi
80102cff:	5d                   	pop    %ebp
80102d00:	c3                   	ret    

80102d01 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102d01:	55                   	push   %ebp
80102d02:	89 e5                	mov    %esp,%ebp
80102d04:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102d07:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102d0e:	c1 e0 08             	shl    $0x8,%eax
80102d11:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102d18:	09 d0                	or     %edx,%eax
80102d1a:	c1 e0 04             	shl    $0x4,%eax
80102d1d:	85 c0                	test   %eax,%eax
80102d1f:	74 1f                	je     80102d40 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102d21:	ba 00 04 00 00       	mov    $0x400,%edx
80102d26:	e8 87 ff ff ff       	call   80102cb2 <mpsearch1>
80102d2b:	85 c0                	test   %eax,%eax
80102d2d:	75 0f                	jne    80102d3e <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d2f:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d34:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d39:	e8 74 ff ff ff       	call   80102cb2 <mpsearch1>
}
80102d3e:	c9                   	leave  
80102d3f:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d40:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d47:	c1 e0 08             	shl    $0x8,%eax
80102d4a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d51:	09 d0                	or     %edx,%eax
80102d53:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d56:	2d 00 04 00 00       	sub    $0x400,%eax
80102d5b:	ba 00 04 00 00       	mov    $0x400,%edx
80102d60:	e8 4d ff ff ff       	call   80102cb2 <mpsearch1>
80102d65:	85 c0                	test   %eax,%eax
80102d67:	75 d5                	jne    80102d3e <mpsearch+0x3d>
80102d69:	eb c4                	jmp    80102d2f <mpsearch+0x2e>

80102d6b <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d6b:	55                   	push   %ebp
80102d6c:	89 e5                	mov    %esp,%ebp
80102d6e:	57                   	push   %edi
80102d6f:	56                   	push   %esi
80102d70:	53                   	push   %ebx
80102d71:	83 ec 1c             	sub    $0x1c,%esp
80102d74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d77:	e8 85 ff ff ff       	call   80102d01 <mpsearch>
80102d7c:	85 c0                	test   %eax,%eax
80102d7e:	74 5c                	je     80102ddc <mpconfig+0x71>
80102d80:	89 c7                	mov    %eax,%edi
80102d82:	8b 58 04             	mov    0x4(%eax),%ebx
80102d85:	85 db                	test   %ebx,%ebx
80102d87:	74 5a                	je     80102de3 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d89:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d8f:	83 ec 04             	sub    $0x4,%esp
80102d92:	6a 04                	push   $0x4
80102d94:	68 7d 6b 10 80       	push   $0x80106b7d
80102d99:	56                   	push   %esi
80102d9a:	e8 a1 10 00 00       	call   80103e40 <memcmp>
80102d9f:	83 c4 10             	add    $0x10,%esp
80102da2:	85 c0                	test   %eax,%eax
80102da4:	75 44                	jne    80102dea <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102da6:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102dad:	3c 01                	cmp    $0x1,%al
80102daf:	0f 95 c2             	setne  %dl
80102db2:	3c 04                	cmp    $0x4,%al
80102db4:	0f 95 c0             	setne  %al
80102db7:	84 c2                	test   %al,%dl
80102db9:	75 36                	jne    80102df1 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102dbb:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102dc2:	89 f0                	mov    %esi,%eax
80102dc4:	e8 c5 fe ff ff       	call   80102c8e <sum>
80102dc9:	84 c0                	test   %al,%al
80102dcb:	75 2b                	jne    80102df8 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dd0:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102dd2:	89 f0                	mov    %esi,%eax
80102dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dd7:	5b                   	pop    %ebx
80102dd8:	5e                   	pop    %esi
80102dd9:	5f                   	pop    %edi
80102dda:	5d                   	pop    %ebp
80102ddb:	c3                   	ret    
    return 0;
80102ddc:	be 00 00 00 00       	mov    $0x0,%esi
80102de1:	eb ef                	jmp    80102dd2 <mpconfig+0x67>
80102de3:	be 00 00 00 00       	mov    $0x0,%esi
80102de8:	eb e8                	jmp    80102dd2 <mpconfig+0x67>
    return 0;
80102dea:	be 00 00 00 00       	mov    $0x0,%esi
80102def:	eb e1                	jmp    80102dd2 <mpconfig+0x67>
    return 0;
80102df1:	be 00 00 00 00       	mov    $0x0,%esi
80102df6:	eb da                	jmp    80102dd2 <mpconfig+0x67>
    return 0;
80102df8:	be 00 00 00 00       	mov    $0x0,%esi
80102dfd:	eb d3                	jmp    80102dd2 <mpconfig+0x67>

80102dff <mpinit>:

void
mpinit(void)
{
80102dff:	55                   	push   %ebp
80102e00:	89 e5                	mov    %esp,%ebp
80102e02:	57                   	push   %edi
80102e03:	56                   	push   %esi
80102e04:	53                   	push   %ebx
80102e05:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102e08:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102e0b:	e8 5b ff ff ff       	call   80102d6b <mpconfig>
80102e10:	85 c0                	test   %eax,%eax
80102e12:	74 19                	je     80102e2d <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102e14:	8b 50 24             	mov    0x24(%eax),%edx
80102e17:	89 15 c0 26 14 80    	mov    %edx,0x801426c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e1d:	8d 50 2c             	lea    0x2c(%eax),%edx
80102e20:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102e24:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102e26:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e2b:	eb 34                	jmp    80102e61 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102e2d:	83 ec 0c             	sub    $0xc,%esp
80102e30:	68 82 6b 10 80       	push   $0x80106b82
80102e35:	e8 0e d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e3a:	8b 35 60 2d 14 80    	mov    0x80142d60,%esi
80102e40:	83 fe 07             	cmp    $0x7,%esi
80102e43:	7f 19                	jg     80102e5e <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e45:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e49:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e4f:	88 87 e0 27 14 80    	mov    %al,-0x7febd820(%edi)
        ncpu++;
80102e55:	83 c6 01             	add    $0x1,%esi
80102e58:	89 35 60 2d 14 80    	mov    %esi,0x80142d60
      }
      p += sizeof(struct mpproc);
80102e5e:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e61:	39 ca                	cmp    %ecx,%edx
80102e63:	73 2b                	jae    80102e90 <mpinit+0x91>
    switch(*p){
80102e65:	0f b6 02             	movzbl (%edx),%eax
80102e68:	3c 04                	cmp    $0x4,%al
80102e6a:	77 1d                	ja     80102e89 <mpinit+0x8a>
80102e6c:	0f b6 c0             	movzbl %al,%eax
80102e6f:	ff 24 85 bc 6b 10 80 	jmp    *-0x7fef9444(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e76:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e7a:	a2 c0 27 14 80       	mov    %al,0x801427c0
      p += sizeof(struct mpioapic);
80102e7f:	83 c2 08             	add    $0x8,%edx
      continue;
80102e82:	eb dd                	jmp    80102e61 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102e84:	83 c2 08             	add    $0x8,%edx
      continue;
80102e87:	eb d8                	jmp    80102e61 <mpinit+0x62>
    default:
      ismp = 0;
80102e89:	bb 00 00 00 00       	mov    $0x0,%ebx
80102e8e:	eb d1                	jmp    80102e61 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102e90:	85 db                	test   %ebx,%ebx
80102e92:	74 26                	je     80102eba <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e97:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e9b:	74 15                	je     80102eb2 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e9d:	b8 70 00 00 00       	mov    $0x70,%eax
80102ea2:	ba 22 00 00 00       	mov    $0x22,%edx
80102ea7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ea8:	ba 23 00 00 00       	mov    $0x23,%edx
80102ead:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102eae:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102eb1:	ee                   	out    %al,(%dx)
  }
}
80102eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102eb5:	5b                   	pop    %ebx
80102eb6:	5e                   	pop    %esi
80102eb7:	5f                   	pop    %edi
80102eb8:	5d                   	pop    %ebp
80102eb9:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102eba:	83 ec 0c             	sub    $0xc,%esp
80102ebd:	68 9c 6b 10 80       	push   $0x80106b9c
80102ec2:	e8 81 d4 ff ff       	call   80100348 <panic>

80102ec7 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102ec7:	55                   	push   %ebp
80102ec8:	89 e5                	mov    %esp,%ebp
80102eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ecf:	ba 21 00 00 00       	mov    $0x21,%edx
80102ed4:	ee                   	out    %al,(%dx)
80102ed5:	ba a1 00 00 00       	mov    $0xa1,%edx
80102eda:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102edb:	5d                   	pop    %ebp
80102edc:	c3                   	ret    

80102edd <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102edd:	55                   	push   %ebp
80102ede:	89 e5                	mov    %esp,%ebp
80102ee0:	57                   	push   %edi
80102ee1:	56                   	push   %esi
80102ee2:	53                   	push   %ebx
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102ee9:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102eec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102ef2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102ef8:	e8 3c dd ff ff       	call   80100c39 <filealloc>
80102efd:	89 03                	mov    %eax,(%ebx)
80102eff:	85 c0                	test   %eax,%eax
80102f01:	74 1e                	je     80102f21 <pipealloc+0x44>
80102f03:	e8 31 dd ff ff       	call   80100c39 <filealloc>
80102f08:	89 06                	mov    %eax,(%esi)
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	74 13                	je     80102f21 <pipealloc+0x44>
    goto bad;
  if((p = (struct pipe*)kalloc(-2)) == 0)
80102f0e:	83 ec 0c             	sub    $0xc,%esp
80102f11:	6a fe                	push   $0xfffffffe
80102f13:	e8 34 f2 ff ff       	call   8010214c <kalloc>
80102f18:	89 c7                	mov    %eax,%edi
80102f1a:	83 c4 10             	add    $0x10,%esp
80102f1d:	85 c0                	test   %eax,%eax
80102f1f:	75 35                	jne    80102f56 <pipealloc+0x79>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f21:	8b 03                	mov    (%ebx),%eax
80102f23:	85 c0                	test   %eax,%eax
80102f25:	74 0c                	je     80102f33 <pipealloc+0x56>
    fileclose(*f0);
80102f27:	83 ec 0c             	sub    $0xc,%esp
80102f2a:	50                   	push   %eax
80102f2b:	e8 af dd ff ff       	call   80100cdf <fileclose>
80102f30:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f33:	8b 06                	mov    (%esi),%eax
80102f35:	85 c0                	test   %eax,%eax
80102f37:	0f 84 8b 00 00 00    	je     80102fc8 <pipealloc+0xeb>
    fileclose(*f1);
80102f3d:	83 ec 0c             	sub    $0xc,%esp
80102f40:	50                   	push   %eax
80102f41:	e8 99 dd ff ff       	call   80100cdf <fileclose>
80102f46:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f51:	5b                   	pop    %ebx
80102f52:	5e                   	pop    %esi
80102f53:	5f                   	pop    %edi
80102f54:	5d                   	pop    %ebp
80102f55:	c3                   	ret    
  p->readopen = 1;
80102f56:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f5d:	00 00 00 
  p->writeopen = 1;
80102f60:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f67:	00 00 00 
  p->nwrite = 0;
80102f6a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f71:	00 00 00 
  p->nread = 0;
80102f74:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f7b:	00 00 00 
  initlock(&p->lock, "pipe");
80102f7e:	83 ec 08             	sub    $0x8,%esp
80102f81:	68 d0 6b 10 80       	push   $0x80106bd0
80102f86:	50                   	push   %eax
80102f87:	e8 86 0c 00 00       	call   80103c12 <initlock>
  (*f0)->type = FD_PIPE;
80102f8c:	8b 03                	mov    (%ebx),%eax
80102f8e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102f94:	8b 03                	mov    (%ebx),%eax
80102f96:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f9a:	8b 03                	mov    (%ebx),%eax
80102f9c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102fa0:	8b 03                	mov    (%ebx),%eax
80102fa2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102fa5:	8b 06                	mov    (%esi),%eax
80102fa7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102fad:	8b 06                	mov    (%esi),%eax
80102faf:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102fb3:	8b 06                	mov    (%esi),%eax
80102fb5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102fb9:	8b 06                	mov    (%esi),%eax
80102fbb:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102fbe:	83 c4 10             	add    $0x10,%esp
80102fc1:	b8 00 00 00 00       	mov    $0x0,%eax
80102fc6:	eb 86                	jmp    80102f4e <pipealloc+0x71>
  return -1;
80102fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fcd:	e9 7c ff ff ff       	jmp    80102f4e <pipealloc+0x71>

80102fd2 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102fd2:	55                   	push   %ebp
80102fd3:	89 e5                	mov    %esp,%ebp
80102fd5:	53                   	push   %ebx
80102fd6:	83 ec 10             	sub    $0x10,%esp
80102fd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102fdc:	53                   	push   %ebx
80102fdd:	e8 6c 0d 00 00       	call   80103d4e <acquire>
  if(writable){
80102fe2:	83 c4 10             	add    $0x10,%esp
80102fe5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102fe9:	74 3f                	je     8010302a <pipeclose+0x58>
    p->writeopen = 0;
80102feb:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102ff2:	00 00 00 
    wakeup(&p->nread);
80102ff5:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	50                   	push   %eax
80102fff:	e8 b4 09 00 00       	call   801039b8 <wakeup>
80103004:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103007:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
8010300e:	75 09                	jne    80103019 <pipeclose+0x47>
80103010:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80103017:	74 2f                	je     80103048 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80103019:	83 ec 0c             	sub    $0xc,%esp
8010301c:	53                   	push   %ebx
8010301d:	e8 91 0d 00 00       	call   80103db3 <release>
80103022:	83 c4 10             	add    $0x10,%esp
}
80103025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103028:	c9                   	leave  
80103029:	c3                   	ret    
    p->readopen = 0;
8010302a:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103031:	00 00 00 
    wakeup(&p->nwrite);
80103034:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010303a:	83 ec 0c             	sub    $0xc,%esp
8010303d:	50                   	push   %eax
8010303e:	e8 75 09 00 00       	call   801039b8 <wakeup>
80103043:	83 c4 10             	add    $0x10,%esp
80103046:	eb bf                	jmp    80103007 <pipeclose+0x35>
    release(&p->lock);
80103048:	83 ec 0c             	sub    $0xc,%esp
8010304b:	53                   	push   %ebx
8010304c:	e8 62 0d 00 00       	call   80103db3 <release>
    kfree((char*)p);
80103051:	89 1c 24             	mov    %ebx,(%esp)
80103054:	e8 ac ef ff ff       	call   80102005 <kfree>
80103059:	83 c4 10             	add    $0x10,%esp
8010305c:	eb c7                	jmp    80103025 <pipeclose+0x53>

8010305e <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
8010305e:	55                   	push   %ebp
8010305f:	89 e5                	mov    %esp,%ebp
80103061:	57                   	push   %edi
80103062:	56                   	push   %esi
80103063:	53                   	push   %ebx
80103064:	83 ec 18             	sub    $0x18,%esp
80103067:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010306a:	89 de                	mov    %ebx,%esi
8010306c:	53                   	push   %ebx
8010306d:	e8 dc 0c 00 00       	call   80103d4e <acquire>
  for(i = 0; i < n; i++){
80103072:	83 c4 10             	add    $0x10,%esp
80103075:	bf 00 00 00 00       	mov    $0x0,%edi
8010307a:	3b 7d 10             	cmp    0x10(%ebp),%edi
8010307d:	0f 8d 88 00 00 00    	jge    8010310b <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103083:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103089:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010308f:	05 00 02 00 00       	add    $0x200,%eax
80103094:	39 c2                	cmp    %eax,%edx
80103096:	75 51                	jne    801030e9 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80103098:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
8010309f:	74 2f                	je     801030d0 <pipewrite+0x72>
801030a1:	e8 06 03 00 00       	call   801033ac <myproc>
801030a6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801030aa:	75 24                	jne    801030d0 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801030ac:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030b2:	83 ec 0c             	sub    $0xc,%esp
801030b5:	50                   	push   %eax
801030b6:	e8 fd 08 00 00       	call   801039b8 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801030bb:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030c1:	83 c4 08             	add    $0x8,%esp
801030c4:	56                   	push   %esi
801030c5:	50                   	push   %eax
801030c6:	e8 88 07 00 00       	call   80103853 <sleep>
801030cb:	83 c4 10             	add    $0x10,%esp
801030ce:	eb b3                	jmp    80103083 <pipewrite+0x25>
        release(&p->lock);
801030d0:	83 ec 0c             	sub    $0xc,%esp
801030d3:	53                   	push   %ebx
801030d4:	e8 da 0c 00 00       	call   80103db3 <release>
        return -1;
801030d9:	83 c4 10             	add    $0x10,%esp
801030dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801030e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030e4:	5b                   	pop    %ebx
801030e5:	5e                   	pop    %esi
801030e6:	5f                   	pop    %edi
801030e7:	5d                   	pop    %ebp
801030e8:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801030e9:	8d 42 01             	lea    0x1(%edx),%eax
801030ec:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801030f2:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801030f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801030fb:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801030ff:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103103:	83 c7 01             	add    $0x1,%edi
80103106:	e9 6f ff ff ff       	jmp    8010307a <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010310b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103111:	83 ec 0c             	sub    $0xc,%esp
80103114:	50                   	push   %eax
80103115:	e8 9e 08 00 00       	call   801039b8 <wakeup>
  release(&p->lock);
8010311a:	89 1c 24             	mov    %ebx,(%esp)
8010311d:	e8 91 0c 00 00       	call   80103db3 <release>
  return n;
80103122:	83 c4 10             	add    $0x10,%esp
80103125:	8b 45 10             	mov    0x10(%ebp),%eax
80103128:	eb b7                	jmp    801030e1 <pipewrite+0x83>

8010312a <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010312a:	55                   	push   %ebp
8010312b:	89 e5                	mov    %esp,%ebp
8010312d:	57                   	push   %edi
8010312e:	56                   	push   %esi
8010312f:	53                   	push   %ebx
80103130:	83 ec 18             	sub    $0x18,%esp
80103133:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103136:	89 df                	mov    %ebx,%edi
80103138:	53                   	push   %ebx
80103139:	e8 10 0c 00 00       	call   80103d4e <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010313e:	83 c4 10             	add    $0x10,%esp
80103141:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103147:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
8010314d:	75 3d                	jne    8010318c <piperead+0x62>
8010314f:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103155:	85 f6                	test   %esi,%esi
80103157:	74 38                	je     80103191 <piperead+0x67>
    if(myproc()->killed){
80103159:	e8 4e 02 00 00       	call   801033ac <myproc>
8010315e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103162:	75 15                	jne    80103179 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103164:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010316a:	83 ec 08             	sub    $0x8,%esp
8010316d:	57                   	push   %edi
8010316e:	50                   	push   %eax
8010316f:	e8 df 06 00 00       	call   80103853 <sleep>
80103174:	83 c4 10             	add    $0x10,%esp
80103177:	eb c8                	jmp    80103141 <piperead+0x17>
      release(&p->lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	53                   	push   %ebx
8010317d:	e8 31 0c 00 00       	call   80103db3 <release>
      return -1;
80103182:	83 c4 10             	add    $0x10,%esp
80103185:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010318a:	eb 50                	jmp    801031dc <piperead+0xb2>
8010318c:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103191:	3b 75 10             	cmp    0x10(%ebp),%esi
80103194:	7d 2c                	jge    801031c2 <piperead+0x98>
    if(p->nread == p->nwrite)
80103196:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010319c:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801031a2:	74 1e                	je     801031c2 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801031a4:	8d 50 01             	lea    0x1(%eax),%edx
801031a7:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801031ad:	25 ff 01 00 00       	and    $0x1ff,%eax
801031b2:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801031b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801031ba:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031bd:	83 c6 01             	add    $0x1,%esi
801031c0:	eb cf                	jmp    80103191 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031c2:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031c8:	83 ec 0c             	sub    $0xc,%esp
801031cb:	50                   	push   %eax
801031cc:	e8 e7 07 00 00       	call   801039b8 <wakeup>
  release(&p->lock);
801031d1:	89 1c 24             	mov    %ebx,(%esp)
801031d4:	e8 da 0b 00 00       	call   80103db3 <release>
  return i;
801031d9:	83 c4 10             	add    $0x10,%esp
}
801031dc:	89 f0                	mov    %esi,%eax
801031de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031e1:	5b                   	pop    %ebx
801031e2:	5e                   	pop    %esi
801031e3:	5f                   	pop    %edi
801031e4:	5d                   	pop    %ebp
801031e5:	c3                   	ret    

801031e6 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801031e6:	55                   	push   %ebp
801031e7:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031e9:	ba b4 2d 14 80       	mov    $0x80142db4,%edx
801031ee:	eb 03                	jmp    801031f3 <wakeup1+0xd>
801031f0:	83 c2 7c             	add    $0x7c,%edx
801031f3:	81 fa b4 4c 14 80    	cmp    $0x80144cb4,%edx
801031f9:	73 14                	jae    8010320f <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801031fb:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801031ff:	75 ef                	jne    801031f0 <wakeup1+0xa>
80103201:	39 42 20             	cmp    %eax,0x20(%edx)
80103204:	75 ea                	jne    801031f0 <wakeup1+0xa>
      p->state = RUNNABLE;
80103206:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010320d:	eb e1                	jmp    801031f0 <wakeup1+0xa>
}
8010320f:	5d                   	pop    %ebp
80103210:	c3                   	ret    

80103211 <allocproc>:
{
80103211:	55                   	push   %ebp
80103212:	89 e5                	mov    %esp,%ebp
80103214:	53                   	push   %ebx
80103215:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103218:	68 80 2d 14 80       	push   $0x80142d80
8010321d:	e8 2c 0b 00 00       	call   80103d4e <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103222:	83 c4 10             	add    $0x10,%esp
80103225:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
8010322a:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
80103230:	73 0b                	jae    8010323d <allocproc+0x2c>
    if(p->state == UNUSED)
80103232:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103236:	74 1c                	je     80103254 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103238:	83 c3 7c             	add    $0x7c,%ebx
8010323b:	eb ed                	jmp    8010322a <allocproc+0x19>
  release(&ptable.lock);
8010323d:	83 ec 0c             	sub    $0xc,%esp
80103240:	68 80 2d 14 80       	push   $0x80142d80
80103245:	e8 69 0b 00 00       	call   80103db3 <release>
  return 0;
8010324a:	83 c4 10             	add    $0x10,%esp
8010324d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103252:	eb 6f                	jmp    801032c3 <allocproc+0xb2>
  p->state = EMBRYO;
80103254:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
8010325b:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103260:	8d 50 01             	lea    0x1(%eax),%edx
80103263:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103269:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010326c:	83 ec 0c             	sub    $0xc,%esp
8010326f:	68 80 2d 14 80       	push   $0x80142d80
80103274:	e8 3a 0b 00 00       	call   80103db3 <release>
  if((p->kstack = kalloc(p->pid)) == 0){
80103279:	83 c4 04             	add    $0x4,%esp
8010327c:	ff 73 10             	pushl  0x10(%ebx)
8010327f:	e8 c8 ee ff ff       	call   8010214c <kalloc>
80103284:	89 43 08             	mov    %eax,0x8(%ebx)
80103287:	83 c4 10             	add    $0x10,%esp
8010328a:	85 c0                	test   %eax,%eax
8010328c:	74 3c                	je     801032ca <allocproc+0xb9>
  sp -= sizeof *p->tf;
8010328e:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103294:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103297:	c7 80 b0 0f 00 00 10 	movl   $0x80104f10,0xfb0(%eax)
8010329e:	4f 10 80 
  sp -= sizeof *p->context;
801032a1:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801032a6:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801032a9:	83 ec 04             	sub    $0x4,%esp
801032ac:	6a 14                	push   $0x14
801032ae:	6a 00                	push   $0x0
801032b0:	50                   	push   %eax
801032b1:	e8 44 0b 00 00       	call   80103dfa <memset>
  p->context->eip = (uint)forkret;
801032b6:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032b9:	c7 40 10 d8 32 10 80 	movl   $0x801032d8,0x10(%eax)
  return p;
801032c0:	83 c4 10             	add    $0x10,%esp
}
801032c3:	89 d8                	mov    %ebx,%eax
801032c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032c8:	c9                   	leave  
801032c9:	c3                   	ret    
    p->state = UNUSED;
801032ca:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801032d1:	bb 00 00 00 00       	mov    $0x0,%ebx
801032d6:	eb eb                	jmp    801032c3 <allocproc+0xb2>

801032d8 <forkret>:
{
801032d8:	55                   	push   %ebp
801032d9:	89 e5                	mov    %esp,%ebp
801032db:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801032de:	68 80 2d 14 80       	push   $0x80142d80
801032e3:	e8 cb 0a 00 00       	call   80103db3 <release>
  if (first) {
801032e8:	83 c4 10             	add    $0x10,%esp
801032eb:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801032f2:	75 02                	jne    801032f6 <forkret+0x1e>
}
801032f4:	c9                   	leave  
801032f5:	c3                   	ret    
    first = 0;
801032f6:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801032fd:	00 00 00 
    iinit(ROOTDEV);
80103300:	83 ec 0c             	sub    $0xc,%esp
80103303:	6a 01                	push   $0x1
80103305:	e8 ee df ff ff       	call   801012f8 <iinit>
    initlog(ROOTDEV);
8010330a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103311:	e8 f2 f5 ff ff       	call   80102908 <initlog>
80103316:	83 c4 10             	add    $0x10,%esp
}
80103319:	eb d9                	jmp    801032f4 <forkret+0x1c>

8010331b <pinit>:
{
8010331b:	55                   	push   %ebp
8010331c:	89 e5                	mov    %esp,%ebp
8010331e:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103321:	68 d5 6b 10 80       	push   $0x80106bd5
80103326:	68 80 2d 14 80       	push   $0x80142d80
8010332b:	e8 e2 08 00 00       	call   80103c12 <initlock>
}
80103330:	83 c4 10             	add    $0x10,%esp
80103333:	c9                   	leave  
80103334:	c3                   	ret    

80103335 <mycpu>:
{
80103335:	55                   	push   %ebp
80103336:	89 e5                	mov    %esp,%ebp
80103338:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010333b:	9c                   	pushf  
8010333c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010333d:	f6 c4 02             	test   $0x2,%ah
80103340:	75 28                	jne    8010336a <mycpu+0x35>
  apicid = lapicid();
80103342:	e8 da f1 ff ff       	call   80102521 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103347:	ba 00 00 00 00       	mov    $0x0,%edx
8010334c:	39 15 60 2d 14 80    	cmp    %edx,0x80142d60
80103352:	7e 23                	jle    80103377 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103354:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010335a:	0f b6 89 e0 27 14 80 	movzbl -0x7febd820(%ecx),%ecx
80103361:	39 c1                	cmp    %eax,%ecx
80103363:	74 1f                	je     80103384 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103365:	83 c2 01             	add    $0x1,%edx
80103368:	eb e2                	jmp    8010334c <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010336a:	83 ec 0c             	sub    $0xc,%esp
8010336d:	68 b8 6c 10 80       	push   $0x80106cb8
80103372:	e8 d1 cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103377:	83 ec 0c             	sub    $0xc,%esp
8010337a:	68 dc 6b 10 80       	push   $0x80106bdc
8010337f:	e8 c4 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
80103384:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010338a:	05 e0 27 14 80       	add    $0x801427e0,%eax
}
8010338f:	c9                   	leave  
80103390:	c3                   	ret    

80103391 <cpuid>:
cpuid() {
80103391:	55                   	push   %ebp
80103392:	89 e5                	mov    %esp,%ebp
80103394:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103397:	e8 99 ff ff ff       	call   80103335 <mycpu>
8010339c:	2d e0 27 14 80       	sub    $0x801427e0,%eax
801033a1:	c1 f8 04             	sar    $0x4,%eax
801033a4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801033aa:	c9                   	leave  
801033ab:	c3                   	ret    

801033ac <myproc>:
myproc(void) {
801033ac:	55                   	push   %ebp
801033ad:	89 e5                	mov    %esp,%ebp
801033af:	53                   	push   %ebx
801033b0:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801033b3:	e8 b9 08 00 00       	call   80103c71 <pushcli>
  c = mycpu();
801033b8:	e8 78 ff ff ff       	call   80103335 <mycpu>
  p = c->proc;
801033bd:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801033c3:	e8 e6 08 00 00       	call   80103cae <popcli>
}
801033c8:	89 d8                	mov    %ebx,%eax
801033ca:	83 c4 04             	add    $0x4,%esp
801033cd:	5b                   	pop    %ebx
801033ce:	5d                   	pop    %ebp
801033cf:	c3                   	ret    

801033d0 <userinit>:
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
801033d3:	53                   	push   %ebx
801033d4:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801033d7:	e8 35 fe ff ff       	call   80103211 <allocproc>
801033dc:	89 c3                	mov    %eax,%ebx
  initproc = p;
801033de:	a3 e4 a5 11 80       	mov    %eax,0x8011a5e4
  if((p->pgdir = setupkvm()) == 0)
801033e3:	e8 22 30 00 00       	call   8010640a <setupkvm>
801033e8:	89 43 04             	mov    %eax,0x4(%ebx)
801033eb:	85 c0                	test   %eax,%eax
801033ed:	0f 84 b7 00 00 00    	je     801034aa <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801033f3:	83 ec 04             	sub    $0x4,%esp
801033f6:	68 2c 00 00 00       	push   $0x2c
801033fb:	68 60 a4 10 80       	push   $0x8010a460
80103400:	50                   	push   %eax
80103401:	e8 01 2d 00 00       	call   80106107 <inituvm>
  p->sz = PGSIZE;
80103406:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010340c:	83 c4 0c             	add    $0xc,%esp
8010340f:	6a 4c                	push   $0x4c
80103411:	6a 00                	push   $0x0
80103413:	ff 73 18             	pushl  0x18(%ebx)
80103416:	e8 df 09 00 00       	call   80103dfa <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010341b:	8b 43 18             	mov    0x18(%ebx),%eax
8010341e:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103424:	8b 43 18             	mov    0x18(%ebx),%eax
80103427:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010342d:	8b 43 18             	mov    0x18(%ebx),%eax
80103430:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103434:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103438:	8b 43 18             	mov    0x18(%ebx),%eax
8010343b:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010343f:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103443:	8b 43 18             	mov    0x18(%ebx),%eax
80103446:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010344d:	8b 43 18             	mov    0x18(%ebx),%eax
80103450:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103457:	8b 43 18             	mov    0x18(%ebx),%eax
8010345a:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103461:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103464:	83 c4 0c             	add    $0xc,%esp
80103467:	6a 10                	push   $0x10
80103469:	68 05 6c 10 80       	push   $0x80106c05
8010346e:	50                   	push   %eax
8010346f:	e8 ed 0a 00 00       	call   80103f61 <safestrcpy>
  p->cwd = namei("/");
80103474:	c7 04 24 0e 6c 10 80 	movl   $0x80106c0e,(%esp)
8010347b:	e8 6d e7 ff ff       	call   80101bed <namei>
80103480:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103483:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
8010348a:	e8 bf 08 00 00       	call   80103d4e <acquire>
  p->state = RUNNABLE;
8010348f:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103496:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
8010349d:	e8 11 09 00 00       	call   80103db3 <release>
}
801034a2:	83 c4 10             	add    $0x10,%esp
801034a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801034a8:	c9                   	leave  
801034a9:	c3                   	ret    
    panic("userinit: out of memory?");
801034aa:	83 ec 0c             	sub    $0xc,%esp
801034ad:	68 ec 6b 10 80       	push   $0x80106bec
801034b2:	e8 91 ce ff ff       	call   80100348 <panic>

801034b7 <growproc>:
{
801034b7:	55                   	push   %ebp
801034b8:	89 e5                	mov    %esp,%ebp
801034ba:	56                   	push   %esi
801034bb:	53                   	push   %ebx
801034bc:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801034bf:	e8 e8 fe ff ff       	call   801033ac <myproc>
801034c4:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801034c6:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801034c8:	85 f6                	test   %esi,%esi
801034ca:	7f 21                	jg     801034ed <growproc+0x36>
  } else if(n < 0){
801034cc:	85 f6                	test   %esi,%esi
801034ce:	79 33                	jns    80103503 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034d0:	83 ec 04             	sub    $0x4,%esp
801034d3:	01 c6                	add    %eax,%esi
801034d5:	56                   	push   %esi
801034d6:	50                   	push   %eax
801034d7:	ff 73 04             	pushl  0x4(%ebx)
801034da:	e8 36 2d 00 00       	call   80106215 <deallocuvm>
801034df:	83 c4 10             	add    $0x10,%esp
801034e2:	85 c0                	test   %eax,%eax
801034e4:	75 1d                	jne    80103503 <growproc+0x4c>
      return -1;
801034e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034eb:	eb 29                	jmp    80103516 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n, curproc->pid)) == 0)
801034ed:	ff 73 10             	pushl  0x10(%ebx)
801034f0:	01 c6                	add    %eax,%esi
801034f2:	56                   	push   %esi
801034f3:	50                   	push   %eax
801034f4:	ff 73 04             	pushl  0x4(%ebx)
801034f7:	e8 ab 2d 00 00       	call   801062a7 <allocuvm>
801034fc:	83 c4 10             	add    $0x10,%esp
801034ff:	85 c0                	test   %eax,%eax
80103501:	74 1a                	je     8010351d <growproc+0x66>
  curproc->sz = sz;
80103503:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103505:	83 ec 0c             	sub    $0xc,%esp
80103508:	53                   	push   %ebx
80103509:	e8 e1 2a 00 00       	call   80105fef <switchuvm>
  return 0;
8010350e:	83 c4 10             	add    $0x10,%esp
80103511:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103516:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103519:	5b                   	pop    %ebx
8010351a:	5e                   	pop    %esi
8010351b:	5d                   	pop    %ebp
8010351c:	c3                   	ret    
      return -1;
8010351d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103522:	eb f2                	jmp    80103516 <growproc+0x5f>

80103524 <fork>:
{
80103524:	55                   	push   %ebp
80103525:	89 e5                	mov    %esp,%ebp
80103527:	57                   	push   %edi
80103528:	56                   	push   %esi
80103529:	53                   	push   %ebx
8010352a:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010352d:	e8 7a fe ff ff       	call   801033ac <myproc>
80103532:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103534:	e8 d8 fc ff ff       	call   80103211 <allocproc>
80103539:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010353c:	85 c0                	test   %eax,%eax
8010353e:	0f 84 e3 00 00 00    	je     80103627 <fork+0x103>
80103544:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, np->pid)) == 0){
80103546:	83 ec 04             	sub    $0x4,%esp
80103549:	ff 70 10             	pushl  0x10(%eax)
8010354c:	ff 33                	pushl  (%ebx)
8010354e:	ff 73 04             	pushl  0x4(%ebx)
80103551:	e8 6d 2f 00 00       	call   801064c3 <copyuvm>
80103556:	89 47 04             	mov    %eax,0x4(%edi)
80103559:	83 c4 10             	add    $0x10,%esp
8010355c:	85 c0                	test   %eax,%eax
8010355e:	74 2a                	je     8010358a <fork+0x66>
  np->sz = curproc->sz;
80103560:	8b 03                	mov    (%ebx),%eax
80103562:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103565:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103567:	89 c8                	mov    %ecx,%eax
80103569:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010356c:	8b 73 18             	mov    0x18(%ebx),%esi
8010356f:	8b 79 18             	mov    0x18(%ecx),%edi
80103572:	b9 13 00 00 00       	mov    $0x13,%ecx
80103577:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103579:	8b 40 18             	mov    0x18(%eax),%eax
8010357c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103583:	be 00 00 00 00       	mov    $0x0,%esi
80103588:	eb 29                	jmp    801035b3 <fork+0x8f>
    kfree(np->kstack);
8010358a:	83 ec 0c             	sub    $0xc,%esp
8010358d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103590:	ff 73 08             	pushl  0x8(%ebx)
80103593:	e8 6d ea ff ff       	call   80102005 <kfree>
    np->kstack = 0;
80103598:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010359f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801035a6:	83 c4 10             	add    $0x10,%esp
801035a9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801035ae:	eb 6d                	jmp    8010361d <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
801035b0:	83 c6 01             	add    $0x1,%esi
801035b3:	83 fe 0f             	cmp    $0xf,%esi
801035b6:	7f 1d                	jg     801035d5 <fork+0xb1>
    if(curproc->ofile[i])
801035b8:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801035bc:	85 c0                	test   %eax,%eax
801035be:	74 f0                	je     801035b0 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801035c0:	83 ec 0c             	sub    $0xc,%esp
801035c3:	50                   	push   %eax
801035c4:	e8 d1 d6 ff ff       	call   80100c9a <filedup>
801035c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035cc:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801035d0:	83 c4 10             	add    $0x10,%esp
801035d3:	eb db                	jmp    801035b0 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
801035d5:	83 ec 0c             	sub    $0xc,%esp
801035d8:	ff 73 68             	pushl  0x68(%ebx)
801035db:	e8 7d df ff ff       	call   8010155d <idup>
801035e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801035e3:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801035e6:	83 c3 6c             	add    $0x6c,%ebx
801035e9:	8d 47 6c             	lea    0x6c(%edi),%eax
801035ec:	83 c4 0c             	add    $0xc,%esp
801035ef:	6a 10                	push   $0x10
801035f1:	53                   	push   %ebx
801035f2:	50                   	push   %eax
801035f3:	e8 69 09 00 00       	call   80103f61 <safestrcpy>
  pid = np->pid;
801035f8:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801035fb:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103602:	e8 47 07 00 00       	call   80103d4e <acquire>
  np->state = RUNNABLE;
80103607:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
8010360e:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103615:	e8 99 07 00 00       	call   80103db3 <release>
  return pid;
8010361a:	83 c4 10             	add    $0x10,%esp
}
8010361d:	89 d8                	mov    %ebx,%eax
8010361f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103622:	5b                   	pop    %ebx
80103623:	5e                   	pop    %esi
80103624:	5f                   	pop    %edi
80103625:	5d                   	pop    %ebp
80103626:	c3                   	ret    
    return -1;
80103627:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010362c:	eb ef                	jmp    8010361d <fork+0xf9>

8010362e <scheduler>:
{
8010362e:	55                   	push   %ebp
8010362f:	89 e5                	mov    %esp,%ebp
80103631:	56                   	push   %esi
80103632:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103633:	e8 fd fc ff ff       	call   80103335 <mycpu>
80103638:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010363a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103641:	00 00 00 
80103644:	eb 5a                	jmp    801036a0 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103646:	83 c3 7c             	add    $0x7c,%ebx
80103649:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
8010364f:	73 3f                	jae    80103690 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103651:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103655:	75 ef                	jne    80103646 <scheduler+0x18>
      c->proc = p;
80103657:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	53                   	push   %ebx
80103661:	e8 89 29 00 00       	call   80105fef <switchuvm>
      p->state = RUNNING;
80103666:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
8010366d:	83 c4 08             	add    $0x8,%esp
80103670:	ff 73 1c             	pushl  0x1c(%ebx)
80103673:	8d 46 04             	lea    0x4(%esi),%eax
80103676:	50                   	push   %eax
80103677:	e8 38 09 00 00       	call   80103fb4 <swtch>
      switchkvm();
8010367c:	e8 5c 29 00 00       	call   80105fdd <switchkvm>
      c->proc = 0;
80103681:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103688:	00 00 00 
8010368b:	83 c4 10             	add    $0x10,%esp
8010368e:	eb b6                	jmp    80103646 <scheduler+0x18>
    release(&ptable.lock);
80103690:	83 ec 0c             	sub    $0xc,%esp
80103693:	68 80 2d 14 80       	push   $0x80142d80
80103698:	e8 16 07 00 00       	call   80103db3 <release>
    sti();
8010369d:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801036a0:	fb                   	sti    
    acquire(&ptable.lock);
801036a1:	83 ec 0c             	sub    $0xc,%esp
801036a4:	68 80 2d 14 80       	push   $0x80142d80
801036a9:	e8 a0 06 00 00       	call   80103d4e <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036ae:	83 c4 10             	add    $0x10,%esp
801036b1:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
801036b6:	eb 91                	jmp    80103649 <scheduler+0x1b>

801036b8 <sched>:
{
801036b8:	55                   	push   %ebp
801036b9:	89 e5                	mov    %esp,%ebp
801036bb:	56                   	push   %esi
801036bc:	53                   	push   %ebx
  struct proc *p = myproc();
801036bd:	e8 ea fc ff ff       	call   801033ac <myproc>
801036c2:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801036c4:	83 ec 0c             	sub    $0xc,%esp
801036c7:	68 80 2d 14 80       	push   $0x80142d80
801036cc:	e8 3d 06 00 00       	call   80103d0e <holding>
801036d1:	83 c4 10             	add    $0x10,%esp
801036d4:	85 c0                	test   %eax,%eax
801036d6:	74 4f                	je     80103727 <sched+0x6f>
  if(mycpu()->ncli != 1)
801036d8:	e8 58 fc ff ff       	call   80103335 <mycpu>
801036dd:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801036e4:	75 4e                	jne    80103734 <sched+0x7c>
  if(p->state == RUNNING)
801036e6:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801036ea:	74 55                	je     80103741 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801036ec:	9c                   	pushf  
801036ed:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801036ee:	f6 c4 02             	test   $0x2,%ah
801036f1:	75 5b                	jne    8010374e <sched+0x96>
  intena = mycpu()->intena;
801036f3:	e8 3d fc ff ff       	call   80103335 <mycpu>
801036f8:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801036fe:	e8 32 fc ff ff       	call   80103335 <mycpu>
80103703:	83 ec 08             	sub    $0x8,%esp
80103706:	ff 70 04             	pushl  0x4(%eax)
80103709:	83 c3 1c             	add    $0x1c,%ebx
8010370c:	53                   	push   %ebx
8010370d:	e8 a2 08 00 00       	call   80103fb4 <swtch>
  mycpu()->intena = intena;
80103712:	e8 1e fc ff ff       	call   80103335 <mycpu>
80103717:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010371d:	83 c4 10             	add    $0x10,%esp
80103720:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103723:	5b                   	pop    %ebx
80103724:	5e                   	pop    %esi
80103725:	5d                   	pop    %ebp
80103726:	c3                   	ret    
    panic("sched ptable.lock");
80103727:	83 ec 0c             	sub    $0xc,%esp
8010372a:	68 10 6c 10 80       	push   $0x80106c10
8010372f:	e8 14 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
80103734:	83 ec 0c             	sub    $0xc,%esp
80103737:	68 22 6c 10 80       	push   $0x80106c22
8010373c:	e8 07 cc ff ff       	call   80100348 <panic>
    panic("sched running");
80103741:	83 ec 0c             	sub    $0xc,%esp
80103744:	68 2e 6c 10 80       	push   $0x80106c2e
80103749:	e8 fa cb ff ff       	call   80100348 <panic>
    panic("sched interruptible");
8010374e:	83 ec 0c             	sub    $0xc,%esp
80103751:	68 3c 6c 10 80       	push   $0x80106c3c
80103756:	e8 ed cb ff ff       	call   80100348 <panic>

8010375b <exit>:
{
8010375b:	55                   	push   %ebp
8010375c:	89 e5                	mov    %esp,%ebp
8010375e:	56                   	push   %esi
8010375f:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103760:	e8 47 fc ff ff       	call   801033ac <myproc>
  if(curproc == initproc)
80103765:	39 05 e4 a5 11 80    	cmp    %eax,0x8011a5e4
8010376b:	74 09                	je     80103776 <exit+0x1b>
8010376d:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
8010376f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103774:	eb 10                	jmp    80103786 <exit+0x2b>
    panic("init exiting");
80103776:	83 ec 0c             	sub    $0xc,%esp
80103779:	68 50 6c 10 80       	push   $0x80106c50
8010377e:	e8 c5 cb ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103783:	83 c3 01             	add    $0x1,%ebx
80103786:	83 fb 0f             	cmp    $0xf,%ebx
80103789:	7f 1e                	jg     801037a9 <exit+0x4e>
    if(curproc->ofile[fd]){
8010378b:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010378f:	85 c0                	test   %eax,%eax
80103791:	74 f0                	je     80103783 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103793:	83 ec 0c             	sub    $0xc,%esp
80103796:	50                   	push   %eax
80103797:	e8 43 d5 ff ff       	call   80100cdf <fileclose>
      curproc->ofile[fd] = 0;
8010379c:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801037a3:	00 
801037a4:	83 c4 10             	add    $0x10,%esp
801037a7:	eb da                	jmp    80103783 <exit+0x28>
  begin_op();
801037a9:	e8 a3 f1 ff ff       	call   80102951 <begin_op>
  iput(curproc->cwd);
801037ae:	83 ec 0c             	sub    $0xc,%esp
801037b1:	ff 76 68             	pushl  0x68(%esi)
801037b4:	e8 db de ff ff       	call   80101694 <iput>
  end_op();
801037b9:	e8 0d f2 ff ff       	call   801029cb <end_op>
  curproc->cwd = 0;
801037be:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801037c5:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
801037cc:	e8 7d 05 00 00       	call   80103d4e <acquire>
  wakeup1(curproc->parent);
801037d1:	8b 46 14             	mov    0x14(%esi),%eax
801037d4:	e8 0d fa ff ff       	call   801031e6 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037d9:	83 c4 10             	add    $0x10,%esp
801037dc:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
801037e1:	eb 03                	jmp    801037e6 <exit+0x8b>
801037e3:	83 c3 7c             	add    $0x7c,%ebx
801037e6:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
801037ec:	73 1a                	jae    80103808 <exit+0xad>
    if(p->parent == curproc){
801037ee:	39 73 14             	cmp    %esi,0x14(%ebx)
801037f1:	75 f0                	jne    801037e3 <exit+0x88>
      p->parent = initproc;
801037f3:	a1 e4 a5 11 80       	mov    0x8011a5e4,%eax
801037f8:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801037fb:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037ff:	75 e2                	jne    801037e3 <exit+0x88>
        wakeup1(initproc);
80103801:	e8 e0 f9 ff ff       	call   801031e6 <wakeup1>
80103806:	eb db                	jmp    801037e3 <exit+0x88>
  curproc->state = ZOMBIE;
80103808:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010380f:	e8 a4 fe ff ff       	call   801036b8 <sched>
  panic("zombie exit");
80103814:	83 ec 0c             	sub    $0xc,%esp
80103817:	68 5d 6c 10 80       	push   $0x80106c5d
8010381c:	e8 27 cb ff ff       	call   80100348 <panic>

80103821 <yield>:
{
80103821:	55                   	push   %ebp
80103822:	89 e5                	mov    %esp,%ebp
80103824:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103827:	68 80 2d 14 80       	push   $0x80142d80
8010382c:	e8 1d 05 00 00       	call   80103d4e <acquire>
  myproc()->state = RUNNABLE;
80103831:	e8 76 fb ff ff       	call   801033ac <myproc>
80103836:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010383d:	e8 76 fe ff ff       	call   801036b8 <sched>
  release(&ptable.lock);
80103842:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103849:	e8 65 05 00 00       	call   80103db3 <release>
}
8010384e:	83 c4 10             	add    $0x10,%esp
80103851:	c9                   	leave  
80103852:	c3                   	ret    

80103853 <sleep>:
{
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	56                   	push   %esi
80103857:	53                   	push   %ebx
80103858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
8010385b:	e8 4c fb ff ff       	call   801033ac <myproc>
  if(p == 0)
80103860:	85 c0                	test   %eax,%eax
80103862:	74 66                	je     801038ca <sleep+0x77>
80103864:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103866:	85 db                	test   %ebx,%ebx
80103868:	74 6d                	je     801038d7 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010386a:	81 fb 80 2d 14 80    	cmp    $0x80142d80,%ebx
80103870:	74 18                	je     8010388a <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103872:	83 ec 0c             	sub    $0xc,%esp
80103875:	68 80 2d 14 80       	push   $0x80142d80
8010387a:	e8 cf 04 00 00       	call   80103d4e <acquire>
    release(lk);
8010387f:	89 1c 24             	mov    %ebx,(%esp)
80103882:	e8 2c 05 00 00       	call   80103db3 <release>
80103887:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010388a:	8b 45 08             	mov    0x8(%ebp),%eax
8010388d:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103890:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103897:	e8 1c fe ff ff       	call   801036b8 <sched>
  p->chan = 0;
8010389c:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801038a3:	81 fb 80 2d 14 80    	cmp    $0x80142d80,%ebx
801038a9:	74 18                	je     801038c3 <sleep+0x70>
    release(&ptable.lock);
801038ab:	83 ec 0c             	sub    $0xc,%esp
801038ae:	68 80 2d 14 80       	push   $0x80142d80
801038b3:	e8 fb 04 00 00       	call   80103db3 <release>
    acquire(lk);
801038b8:	89 1c 24             	mov    %ebx,(%esp)
801038bb:	e8 8e 04 00 00       	call   80103d4e <acquire>
801038c0:	83 c4 10             	add    $0x10,%esp
}
801038c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038c6:	5b                   	pop    %ebx
801038c7:	5e                   	pop    %esi
801038c8:	5d                   	pop    %ebp
801038c9:	c3                   	ret    
    panic("sleep");
801038ca:	83 ec 0c             	sub    $0xc,%esp
801038cd:	68 69 6c 10 80       	push   $0x80106c69
801038d2:	e8 71 ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801038d7:	83 ec 0c             	sub    $0xc,%esp
801038da:	68 6f 6c 10 80       	push   $0x80106c6f
801038df:	e8 64 ca ff ff       	call   80100348 <panic>

801038e4 <wait>:
{
801038e4:	55                   	push   %ebp
801038e5:	89 e5                	mov    %esp,%ebp
801038e7:	56                   	push   %esi
801038e8:	53                   	push   %ebx
  struct proc *curproc = myproc();
801038e9:	e8 be fa ff ff       	call   801033ac <myproc>
801038ee:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801038f0:	83 ec 0c             	sub    $0xc,%esp
801038f3:	68 80 2d 14 80       	push   $0x80142d80
801038f8:	e8 51 04 00 00       	call   80103d4e <acquire>
801038fd:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103900:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103905:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
8010390a:	eb 5b                	jmp    80103967 <wait+0x83>
        pid = p->pid;
8010390c:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	ff 73 08             	pushl  0x8(%ebx)
80103915:	e8 eb e6 ff ff       	call   80102005 <kfree>
        p->kstack = 0;
8010391a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103921:	83 c4 04             	add    $0x4,%esp
80103924:	ff 73 04             	pushl  0x4(%ebx)
80103927:	e8 6e 2a 00 00       	call   8010639a <freevm>
        p->pid = 0;
8010392c:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103933:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010393a:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
8010393e:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103945:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010394c:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103953:	e8 5b 04 00 00       	call   80103db3 <release>
        return pid;
80103958:	83 c4 10             	add    $0x10,%esp
}
8010395b:	89 f0                	mov    %esi,%eax
8010395d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103960:	5b                   	pop    %ebx
80103961:	5e                   	pop    %esi
80103962:	5d                   	pop    %ebp
80103963:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103964:	83 c3 7c             	add    $0x7c,%ebx
80103967:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
8010396d:	73 12                	jae    80103981 <wait+0x9d>
      if(p->parent != curproc)
8010396f:	39 73 14             	cmp    %esi,0x14(%ebx)
80103972:	75 f0                	jne    80103964 <wait+0x80>
      if(p->state == ZOMBIE){
80103974:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103978:	74 92                	je     8010390c <wait+0x28>
      havekids = 1;
8010397a:	b8 01 00 00 00       	mov    $0x1,%eax
8010397f:	eb e3                	jmp    80103964 <wait+0x80>
    if(!havekids || curproc->killed){
80103981:	85 c0                	test   %eax,%eax
80103983:	74 06                	je     8010398b <wait+0xa7>
80103985:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103989:	74 17                	je     801039a2 <wait+0xbe>
      release(&ptable.lock);
8010398b:	83 ec 0c             	sub    $0xc,%esp
8010398e:	68 80 2d 14 80       	push   $0x80142d80
80103993:	e8 1b 04 00 00       	call   80103db3 <release>
      return -1;
80103998:	83 c4 10             	add    $0x10,%esp
8010399b:	be ff ff ff ff       	mov    $0xffffffff,%esi
801039a0:	eb b9                	jmp    8010395b <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801039a2:	83 ec 08             	sub    $0x8,%esp
801039a5:	68 80 2d 14 80       	push   $0x80142d80
801039aa:	56                   	push   %esi
801039ab:	e8 a3 fe ff ff       	call   80103853 <sleep>
    havekids = 0;
801039b0:	83 c4 10             	add    $0x10,%esp
801039b3:	e9 48 ff ff ff       	jmp    80103900 <wait+0x1c>

801039b8 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801039be:	68 80 2d 14 80       	push   $0x80142d80
801039c3:	e8 86 03 00 00       	call   80103d4e <acquire>
  wakeup1(chan);
801039c8:	8b 45 08             	mov    0x8(%ebp),%eax
801039cb:	e8 16 f8 ff ff       	call   801031e6 <wakeup1>
  release(&ptable.lock);
801039d0:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
801039d7:	e8 d7 03 00 00       	call   80103db3 <release>
}
801039dc:	83 c4 10             	add    $0x10,%esp
801039df:	c9                   	leave  
801039e0:	c3                   	ret    

801039e1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801039e1:	55                   	push   %ebp
801039e2:	89 e5                	mov    %esp,%ebp
801039e4:	53                   	push   %ebx
801039e5:	83 ec 10             	sub    $0x10,%esp
801039e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801039eb:	68 80 2d 14 80       	push   $0x80142d80
801039f0:	e8 59 03 00 00       	call   80103d4e <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039f5:	83 c4 10             	add    $0x10,%esp
801039f8:	b8 b4 2d 14 80       	mov    $0x80142db4,%eax
801039fd:	3d b4 4c 14 80       	cmp    $0x80144cb4,%eax
80103a02:	73 3a                	jae    80103a3e <kill+0x5d>
    if(p->pid == pid){
80103a04:	39 58 10             	cmp    %ebx,0x10(%eax)
80103a07:	74 05                	je     80103a0e <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a09:	83 c0 7c             	add    $0x7c,%eax
80103a0c:	eb ef                	jmp    801039fd <kill+0x1c>
      p->killed = 1;
80103a0e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103a15:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a19:	74 1a                	je     80103a35 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103a1b:	83 ec 0c             	sub    $0xc,%esp
80103a1e:	68 80 2d 14 80       	push   $0x80142d80
80103a23:	e8 8b 03 00 00       	call   80103db3 <release>
      return 0;
80103a28:	83 c4 10             	add    $0x10,%esp
80103a2b:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a33:	c9                   	leave  
80103a34:	c3                   	ret    
        p->state = RUNNABLE;
80103a35:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a3c:	eb dd                	jmp    80103a1b <kill+0x3a>
  release(&ptable.lock);
80103a3e:	83 ec 0c             	sub    $0xc,%esp
80103a41:	68 80 2d 14 80       	push   $0x80142d80
80103a46:	e8 68 03 00 00       	call   80103db3 <release>
  return -1;
80103a4b:	83 c4 10             	add    $0x10,%esp
80103a4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a53:	eb db                	jmp    80103a30 <kill+0x4f>

80103a55 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a55:	55                   	push   %ebp
80103a56:	89 e5                	mov    %esp,%ebp
80103a58:	56                   	push   %esi
80103a59:	53                   	push   %ebx
80103a5a:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a5d:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
80103a62:	eb 33                	jmp    80103a97 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a64:	b8 80 6c 10 80       	mov    $0x80106c80,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a69:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a6c:	52                   	push   %edx
80103a6d:	50                   	push   %eax
80103a6e:	ff 73 10             	pushl  0x10(%ebx)
80103a71:	68 84 6c 10 80       	push   $0x80106c84
80103a76:	e8 90 cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a7b:	83 c4 10             	add    $0x10,%esp
80103a7e:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a82:	74 39                	je     80103abd <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a84:	83 ec 0c             	sub    $0xc,%esp
80103a87:	68 fb 6f 10 80       	push   $0x80106ffb
80103a8c:	e8 7a cb ff ff       	call   8010060b <cprintf>
80103a91:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a94:	83 c3 7c             	add    $0x7c,%ebx
80103a97:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
80103a9d:	73 61                	jae    80103b00 <procdump+0xab>
    if(p->state == UNUSED)
80103a9f:	8b 43 0c             	mov    0xc(%ebx),%eax
80103aa2:	85 c0                	test   %eax,%eax
80103aa4:	74 ee                	je     80103a94 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103aa6:	83 f8 05             	cmp    $0x5,%eax
80103aa9:	77 b9                	ja     80103a64 <procdump+0xf>
80103aab:	8b 04 85 e0 6c 10 80 	mov    -0x7fef9320(,%eax,4),%eax
80103ab2:	85 c0                	test   %eax,%eax
80103ab4:	75 b3                	jne    80103a69 <procdump+0x14>
      state = "???";
80103ab6:	b8 80 6c 10 80       	mov    $0x80106c80,%eax
80103abb:	eb ac                	jmp    80103a69 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103abd:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ac0:	8b 40 0c             	mov    0xc(%eax),%eax
80103ac3:	83 c0 08             	add    $0x8,%eax
80103ac6:	83 ec 08             	sub    $0x8,%esp
80103ac9:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103acc:	52                   	push   %edx
80103acd:	50                   	push   %eax
80103ace:	e8 5a 01 00 00       	call   80103c2d <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103ad3:	83 c4 10             	add    $0x10,%esp
80103ad6:	be 00 00 00 00       	mov    $0x0,%esi
80103adb:	eb 14                	jmp    80103af1 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103add:	83 ec 08             	sub    $0x8,%esp
80103ae0:	50                   	push   %eax
80103ae1:	68 c1 66 10 80       	push   $0x801066c1
80103ae6:	e8 20 cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103aeb:	83 c6 01             	add    $0x1,%esi
80103aee:	83 c4 10             	add    $0x10,%esp
80103af1:	83 fe 09             	cmp    $0x9,%esi
80103af4:	7f 8e                	jg     80103a84 <procdump+0x2f>
80103af6:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103afa:	85 c0                	test   %eax,%eax
80103afc:	75 df                	jne    80103add <procdump+0x88>
80103afe:	eb 84                	jmp    80103a84 <procdump+0x2f>
  }
}
80103b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b03:	5b                   	pop    %ebx
80103b04:	5e                   	pop    %esi
80103b05:	5d                   	pop    %ebp
80103b06:	c3                   	ret    

80103b07 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103b07:	55                   	push   %ebp
80103b08:	89 e5                	mov    %esp,%ebp
80103b0a:	53                   	push   %ebx
80103b0b:	83 ec 0c             	sub    $0xc,%esp
80103b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103b11:	68 f8 6c 10 80       	push   $0x80106cf8
80103b16:	8d 43 04             	lea    0x4(%ebx),%eax
80103b19:	50                   	push   %eax
80103b1a:	e8 f3 00 00 00       	call   80103c12 <initlock>
  lk->name = name;
80103b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b22:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b2b:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b32:	83 c4 10             	add    $0x10,%esp
80103b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b38:	c9                   	leave  
80103b39:	c3                   	ret    

80103b3a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b3a:	55                   	push   %ebp
80103b3b:	89 e5                	mov    %esp,%ebp
80103b3d:	56                   	push   %esi
80103b3e:	53                   	push   %ebx
80103b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b42:	8d 73 04             	lea    0x4(%ebx),%esi
80103b45:	83 ec 0c             	sub    $0xc,%esp
80103b48:	56                   	push   %esi
80103b49:	e8 00 02 00 00       	call   80103d4e <acquire>
  while (lk->locked) {
80103b4e:	83 c4 10             	add    $0x10,%esp
80103b51:	eb 0d                	jmp    80103b60 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b53:	83 ec 08             	sub    $0x8,%esp
80103b56:	56                   	push   %esi
80103b57:	53                   	push   %ebx
80103b58:	e8 f6 fc ff ff       	call   80103853 <sleep>
80103b5d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b60:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b63:	75 ee                	jne    80103b53 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b65:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b6b:	e8 3c f8 ff ff       	call   801033ac <myproc>
80103b70:	8b 40 10             	mov    0x10(%eax),%eax
80103b73:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b76:	83 ec 0c             	sub    $0xc,%esp
80103b79:	56                   	push   %esi
80103b7a:	e8 34 02 00 00       	call   80103db3 <release>
}
80103b7f:	83 c4 10             	add    $0x10,%esp
80103b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b85:	5b                   	pop    %ebx
80103b86:	5e                   	pop    %esi
80103b87:	5d                   	pop    %ebp
80103b88:	c3                   	ret    

80103b89 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b89:	55                   	push   %ebp
80103b8a:	89 e5                	mov    %esp,%ebp
80103b8c:	56                   	push   %esi
80103b8d:	53                   	push   %ebx
80103b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b91:	8d 73 04             	lea    0x4(%ebx),%esi
80103b94:	83 ec 0c             	sub    $0xc,%esp
80103b97:	56                   	push   %esi
80103b98:	e8 b1 01 00 00       	call   80103d4e <acquire>
  lk->locked = 0;
80103b9d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ba3:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103baa:	89 1c 24             	mov    %ebx,(%esp)
80103bad:	e8 06 fe ff ff       	call   801039b8 <wakeup>
  release(&lk->lk);
80103bb2:	89 34 24             	mov    %esi,(%esp)
80103bb5:	e8 f9 01 00 00       	call   80103db3 <release>
}
80103bba:	83 c4 10             	add    $0x10,%esp
80103bbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bc0:	5b                   	pop    %ebx
80103bc1:	5e                   	pop    %esi
80103bc2:	5d                   	pop    %ebp
80103bc3:	c3                   	ret    

80103bc4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bc4:	55                   	push   %ebp
80103bc5:	89 e5                	mov    %esp,%ebp
80103bc7:	56                   	push   %esi
80103bc8:	53                   	push   %ebx
80103bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103bcc:	8d 73 04             	lea    0x4(%ebx),%esi
80103bcf:	83 ec 0c             	sub    $0xc,%esp
80103bd2:	56                   	push   %esi
80103bd3:	e8 76 01 00 00       	call   80103d4e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bd8:	83 c4 10             	add    $0x10,%esp
80103bdb:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bde:	75 17                	jne    80103bf7 <holdingsleep+0x33>
80103be0:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103be5:	83 ec 0c             	sub    $0xc,%esp
80103be8:	56                   	push   %esi
80103be9:	e8 c5 01 00 00       	call   80103db3 <release>
  return r;
}
80103bee:	89 d8                	mov    %ebx,%eax
80103bf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bf3:	5b                   	pop    %ebx
80103bf4:	5e                   	pop    %esi
80103bf5:	5d                   	pop    %ebp
80103bf6:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103bf7:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103bfa:	e8 ad f7 ff ff       	call   801033ac <myproc>
80103bff:	3b 58 10             	cmp    0x10(%eax),%ebx
80103c02:	74 07                	je     80103c0b <holdingsleep+0x47>
80103c04:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c09:	eb da                	jmp    80103be5 <holdingsleep+0x21>
80103c0b:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c10:	eb d3                	jmp    80103be5 <holdingsleep+0x21>

80103c12 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103c12:	55                   	push   %ebp
80103c13:	89 e5                	mov    %esp,%ebp
80103c15:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103c18:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c1b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c24:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c2b:	5d                   	pop    %ebp
80103c2c:	c3                   	ret    

80103c2d <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c2d:	55                   	push   %ebp
80103c2e:	89 e5                	mov    %esp,%ebp
80103c30:	53                   	push   %ebx
80103c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c34:	8b 45 08             	mov    0x8(%ebp),%eax
80103c37:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c3a:	b8 00 00 00 00       	mov    $0x0,%eax
80103c3f:	83 f8 09             	cmp    $0x9,%eax
80103c42:	7f 25                	jg     80103c69 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c44:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c4a:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c50:	77 17                	ja     80103c69 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c52:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c55:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c58:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c5a:	83 c0 01             	add    $0x1,%eax
80103c5d:	eb e0                	jmp    80103c3f <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c5f:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c66:	83 c0 01             	add    $0x1,%eax
80103c69:	83 f8 09             	cmp    $0x9,%eax
80103c6c:	7e f1                	jle    80103c5f <getcallerpcs+0x32>
}
80103c6e:	5b                   	pop    %ebx
80103c6f:	5d                   	pop    %ebp
80103c70:	c3                   	ret    

80103c71 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c71:	55                   	push   %ebp
80103c72:	89 e5                	mov    %esp,%ebp
80103c74:	53                   	push   %ebx
80103c75:	83 ec 04             	sub    $0x4,%esp
80103c78:	9c                   	pushf  
80103c79:	5b                   	pop    %ebx
  asm volatile("cli");
80103c7a:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c7b:	e8 b5 f6 ff ff       	call   80103335 <mycpu>
80103c80:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c87:	74 12                	je     80103c9b <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c89:	e8 a7 f6 ff ff       	call   80103335 <mycpu>
80103c8e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c95:	83 c4 04             	add    $0x4,%esp
80103c98:	5b                   	pop    %ebx
80103c99:	5d                   	pop    %ebp
80103c9a:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c9b:	e8 95 f6 ff ff       	call   80103335 <mycpu>
80103ca0:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ca6:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103cac:	eb db                	jmp    80103c89 <pushcli+0x18>

80103cae <popcli>:

void
popcli(void)
{
80103cae:	55                   	push   %ebp
80103caf:	89 e5                	mov    %esp,%ebp
80103cb1:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cb4:	9c                   	pushf  
80103cb5:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cb6:	f6 c4 02             	test   $0x2,%ah
80103cb9:	75 28                	jne    80103ce3 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103cbb:	e8 75 f6 ff ff       	call   80103335 <mycpu>
80103cc0:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cc6:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cc9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103ccf:	85 d2                	test   %edx,%edx
80103cd1:	78 1d                	js     80103cf0 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cd3:	e8 5d f6 ff ff       	call   80103335 <mycpu>
80103cd8:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cdf:	74 1c                	je     80103cfd <popcli+0x4f>
    sti();
}
80103ce1:	c9                   	leave  
80103ce2:	c3                   	ret    
    panic("popcli - interruptible");
80103ce3:	83 ec 0c             	sub    $0xc,%esp
80103ce6:	68 03 6d 10 80       	push   $0x80106d03
80103ceb:	e8 58 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103cf0:	83 ec 0c             	sub    $0xc,%esp
80103cf3:	68 1a 6d 10 80       	push   $0x80106d1a
80103cf8:	e8 4b c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cfd:	e8 33 f6 ff ff       	call   80103335 <mycpu>
80103d02:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103d09:	74 d6                	je     80103ce1 <popcli+0x33>
  asm volatile("sti");
80103d0b:	fb                   	sti    
}
80103d0c:	eb d3                	jmp    80103ce1 <popcli+0x33>

80103d0e <holding>:
{
80103d0e:	55                   	push   %ebp
80103d0f:	89 e5                	mov    %esp,%ebp
80103d11:	53                   	push   %ebx
80103d12:	83 ec 04             	sub    $0x4,%esp
80103d15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103d18:	e8 54 ff ff ff       	call   80103c71 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d1d:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d20:	75 12                	jne    80103d34 <holding+0x26>
80103d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d27:	e8 82 ff ff ff       	call   80103cae <popcli>
}
80103d2c:	89 d8                	mov    %ebx,%eax
80103d2e:	83 c4 04             	add    $0x4,%esp
80103d31:	5b                   	pop    %ebx
80103d32:	5d                   	pop    %ebp
80103d33:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d34:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d37:	e8 f9 f5 ff ff       	call   80103335 <mycpu>
80103d3c:	39 c3                	cmp    %eax,%ebx
80103d3e:	74 07                	je     80103d47 <holding+0x39>
80103d40:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d45:	eb e0                	jmp    80103d27 <holding+0x19>
80103d47:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d4c:	eb d9                	jmp    80103d27 <holding+0x19>

80103d4e <acquire>:
{
80103d4e:	55                   	push   %ebp
80103d4f:	89 e5                	mov    %esp,%ebp
80103d51:	53                   	push   %ebx
80103d52:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d55:	e8 17 ff ff ff       	call   80103c71 <pushcli>
  if(holding(lk))
80103d5a:	83 ec 0c             	sub    $0xc,%esp
80103d5d:	ff 75 08             	pushl  0x8(%ebp)
80103d60:	e8 a9 ff ff ff       	call   80103d0e <holding>
80103d65:	83 c4 10             	add    $0x10,%esp
80103d68:	85 c0                	test   %eax,%eax
80103d6a:	75 3a                	jne    80103da6 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d6f:	b8 01 00 00 00       	mov    $0x1,%eax
80103d74:	f0 87 02             	lock xchg %eax,(%edx)
80103d77:	85 c0                	test   %eax,%eax
80103d79:	75 f1                	jne    80103d6c <acquire+0x1e>
  __sync_synchronize();
80103d7b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d80:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d83:	e8 ad f5 ff ff       	call   80103335 <mycpu>
80103d88:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8e:	83 c0 0c             	add    $0xc,%eax
80103d91:	83 ec 08             	sub    $0x8,%esp
80103d94:	50                   	push   %eax
80103d95:	8d 45 08             	lea    0x8(%ebp),%eax
80103d98:	50                   	push   %eax
80103d99:	e8 8f fe ff ff       	call   80103c2d <getcallerpcs>
}
80103d9e:	83 c4 10             	add    $0x10,%esp
80103da1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103da4:	c9                   	leave  
80103da5:	c3                   	ret    
    panic("acquire");
80103da6:	83 ec 0c             	sub    $0xc,%esp
80103da9:	68 21 6d 10 80       	push   $0x80106d21
80103dae:	e8 95 c5 ff ff       	call   80100348 <panic>

80103db3 <release>:
{
80103db3:	55                   	push   %ebp
80103db4:	89 e5                	mov    %esp,%ebp
80103db6:	53                   	push   %ebx
80103db7:	83 ec 10             	sub    $0x10,%esp
80103dba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103dbd:	53                   	push   %ebx
80103dbe:	e8 4b ff ff ff       	call   80103d0e <holding>
80103dc3:	83 c4 10             	add    $0x10,%esp
80103dc6:	85 c0                	test   %eax,%eax
80103dc8:	74 23                	je     80103ded <release+0x3a>
  lk->pcs[0] = 0;
80103dca:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103dd1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dd8:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ddd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103de3:	e8 c6 fe ff ff       	call   80103cae <popcli>
}
80103de8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103deb:	c9                   	leave  
80103dec:	c3                   	ret    
    panic("release");
80103ded:	83 ec 0c             	sub    $0xc,%esp
80103df0:	68 29 6d 10 80       	push   $0x80106d29
80103df5:	e8 4e c5 ff ff       	call   80100348 <panic>

80103dfa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103dfa:	55                   	push   %ebp
80103dfb:	89 e5                	mov    %esp,%ebp
80103dfd:	57                   	push   %edi
80103dfe:	53                   	push   %ebx
80103dff:	8b 55 08             	mov    0x8(%ebp),%edx
80103e02:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103e05:	f6 c2 03             	test   $0x3,%dl
80103e08:	75 05                	jne    80103e0f <memset+0x15>
80103e0a:	f6 c1 03             	test   $0x3,%cl
80103e0d:	74 0e                	je     80103e1d <memset+0x23>
  asm volatile("cld; rep stosb" :
80103e0f:	89 d7                	mov    %edx,%edi
80103e11:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e14:	fc                   	cld    
80103e15:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103e17:	89 d0                	mov    %edx,%eax
80103e19:	5b                   	pop    %ebx
80103e1a:	5f                   	pop    %edi
80103e1b:	5d                   	pop    %ebp
80103e1c:	c3                   	ret    
    c &= 0xFF;
80103e1d:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e21:	c1 e9 02             	shr    $0x2,%ecx
80103e24:	89 f8                	mov    %edi,%eax
80103e26:	c1 e0 18             	shl    $0x18,%eax
80103e29:	89 fb                	mov    %edi,%ebx
80103e2b:	c1 e3 10             	shl    $0x10,%ebx
80103e2e:	09 d8                	or     %ebx,%eax
80103e30:	89 fb                	mov    %edi,%ebx
80103e32:	c1 e3 08             	shl    $0x8,%ebx
80103e35:	09 d8                	or     %ebx,%eax
80103e37:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103e39:	89 d7                	mov    %edx,%edi
80103e3b:	fc                   	cld    
80103e3c:	f3 ab                	rep stos %eax,%es:(%edi)
80103e3e:	eb d7                	jmp    80103e17 <memset+0x1d>

80103e40 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e40:	55                   	push   %ebp
80103e41:	89 e5                	mov    %esp,%ebp
80103e43:	56                   	push   %esi
80103e44:	53                   	push   %ebx
80103e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e48:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e4b:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e4e:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e51:	85 c0                	test   %eax,%eax
80103e53:	74 1c                	je     80103e71 <memcmp+0x31>
    if(*s1 != *s2)
80103e55:	0f b6 01             	movzbl (%ecx),%eax
80103e58:	0f b6 1a             	movzbl (%edx),%ebx
80103e5b:	38 d8                	cmp    %bl,%al
80103e5d:	75 0a                	jne    80103e69 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e5f:	83 c1 01             	add    $0x1,%ecx
80103e62:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e65:	89 f0                	mov    %esi,%eax
80103e67:	eb e5                	jmp    80103e4e <memcmp+0xe>
      return *s1 - *s2;
80103e69:	0f b6 c0             	movzbl %al,%eax
80103e6c:	0f b6 db             	movzbl %bl,%ebx
80103e6f:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e71:	5b                   	pop    %ebx
80103e72:	5e                   	pop    %esi
80103e73:	5d                   	pop    %ebp
80103e74:	c3                   	ret    

80103e75 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e75:	55                   	push   %ebp
80103e76:	89 e5                	mov    %esp,%ebp
80103e78:	56                   	push   %esi
80103e79:	53                   	push   %ebx
80103e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e80:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e83:	39 c1                	cmp    %eax,%ecx
80103e85:	73 3a                	jae    80103ec1 <memmove+0x4c>
80103e87:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e8a:	39 c3                	cmp    %eax,%ebx
80103e8c:	76 37                	jbe    80103ec5 <memmove+0x50>
    s += n;
    d += n;
80103e8e:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e91:	eb 0d                	jmp    80103ea0 <memmove+0x2b>
      *--d = *--s;
80103e93:	83 eb 01             	sub    $0x1,%ebx
80103e96:	83 e9 01             	sub    $0x1,%ecx
80103e99:	0f b6 13             	movzbl (%ebx),%edx
80103e9c:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e9e:	89 f2                	mov    %esi,%edx
80103ea0:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ea3:	85 d2                	test   %edx,%edx
80103ea5:	75 ec                	jne    80103e93 <memmove+0x1e>
80103ea7:	eb 14                	jmp    80103ebd <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103ea9:	0f b6 11             	movzbl (%ecx),%edx
80103eac:	88 13                	mov    %dl,(%ebx)
80103eae:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103eb1:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103eb4:	89 f2                	mov    %esi,%edx
80103eb6:	8d 72 ff             	lea    -0x1(%edx),%esi
80103eb9:	85 d2                	test   %edx,%edx
80103ebb:	75 ec                	jne    80103ea9 <memmove+0x34>

  return dst;
}
80103ebd:	5b                   	pop    %ebx
80103ebe:	5e                   	pop    %esi
80103ebf:	5d                   	pop    %ebp
80103ec0:	c3                   	ret    
80103ec1:	89 c3                	mov    %eax,%ebx
80103ec3:	eb f1                	jmp    80103eb6 <memmove+0x41>
80103ec5:	89 c3                	mov    %eax,%ebx
80103ec7:	eb ed                	jmp    80103eb6 <memmove+0x41>

80103ec9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103ec9:	55                   	push   %ebp
80103eca:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103ecc:	ff 75 10             	pushl  0x10(%ebp)
80103ecf:	ff 75 0c             	pushl  0xc(%ebp)
80103ed2:	ff 75 08             	pushl  0x8(%ebp)
80103ed5:	e8 9b ff ff ff       	call   80103e75 <memmove>
}
80103eda:	c9                   	leave  
80103edb:	c3                   	ret    

80103edc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103edc:	55                   	push   %ebp
80103edd:	89 e5                	mov    %esp,%ebp
80103edf:	53                   	push   %ebx
80103ee0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ee6:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103ee9:	eb 09                	jmp    80103ef4 <strncmp+0x18>
    n--, p++, q++;
80103eeb:	83 e8 01             	sub    $0x1,%eax
80103eee:	83 c2 01             	add    $0x1,%edx
80103ef1:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103ef4:	85 c0                	test   %eax,%eax
80103ef6:	74 0b                	je     80103f03 <strncmp+0x27>
80103ef8:	0f b6 1a             	movzbl (%edx),%ebx
80103efb:	84 db                	test   %bl,%bl
80103efd:	74 04                	je     80103f03 <strncmp+0x27>
80103eff:	3a 19                	cmp    (%ecx),%bl
80103f01:	74 e8                	je     80103eeb <strncmp+0xf>
  if(n == 0)
80103f03:	85 c0                	test   %eax,%eax
80103f05:	74 0b                	je     80103f12 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103f07:	0f b6 02             	movzbl (%edx),%eax
80103f0a:	0f b6 11             	movzbl (%ecx),%edx
80103f0d:	29 d0                	sub    %edx,%eax
}
80103f0f:	5b                   	pop    %ebx
80103f10:	5d                   	pop    %ebp
80103f11:	c3                   	ret    
    return 0;
80103f12:	b8 00 00 00 00       	mov    $0x0,%eax
80103f17:	eb f6                	jmp    80103f0f <strncmp+0x33>

80103f19 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f19:	55                   	push   %ebp
80103f1a:	89 e5                	mov    %esp,%ebp
80103f1c:	57                   	push   %edi
80103f1d:	56                   	push   %esi
80103f1e:	53                   	push   %ebx
80103f1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f22:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f25:	8b 45 08             	mov    0x8(%ebp),%eax
80103f28:	eb 04                	jmp    80103f2e <strncpy+0x15>
80103f2a:	89 fb                	mov    %edi,%ebx
80103f2c:	89 f0                	mov    %esi,%eax
80103f2e:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f31:	85 c9                	test   %ecx,%ecx
80103f33:	7e 1d                	jle    80103f52 <strncpy+0x39>
80103f35:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f38:	8d 70 01             	lea    0x1(%eax),%esi
80103f3b:	0f b6 1b             	movzbl (%ebx),%ebx
80103f3e:	88 18                	mov    %bl,(%eax)
80103f40:	89 d1                	mov    %edx,%ecx
80103f42:	84 db                	test   %bl,%bl
80103f44:	75 e4                	jne    80103f2a <strncpy+0x11>
80103f46:	89 f0                	mov    %esi,%eax
80103f48:	eb 08                	jmp    80103f52 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f4a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f4d:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f4f:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f52:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f55:	85 d2                	test   %edx,%edx
80103f57:	7f f1                	jg     80103f4a <strncpy+0x31>
  return os;
}
80103f59:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5c:	5b                   	pop    %ebx
80103f5d:	5e                   	pop    %esi
80103f5e:	5f                   	pop    %edi
80103f5f:	5d                   	pop    %ebp
80103f60:	c3                   	ret    

80103f61 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f61:	55                   	push   %ebp
80103f62:	89 e5                	mov    %esp,%ebp
80103f64:	57                   	push   %edi
80103f65:	56                   	push   %esi
80103f66:	53                   	push   %ebx
80103f67:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f6d:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f70:	85 d2                	test   %edx,%edx
80103f72:	7e 23                	jle    80103f97 <safestrcpy+0x36>
80103f74:	89 c1                	mov    %eax,%ecx
80103f76:	eb 04                	jmp    80103f7c <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f78:	89 fb                	mov    %edi,%ebx
80103f7a:	89 f1                	mov    %esi,%ecx
80103f7c:	83 ea 01             	sub    $0x1,%edx
80103f7f:	85 d2                	test   %edx,%edx
80103f81:	7e 11                	jle    80103f94 <safestrcpy+0x33>
80103f83:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f86:	8d 71 01             	lea    0x1(%ecx),%esi
80103f89:	0f b6 1b             	movzbl (%ebx),%ebx
80103f8c:	88 19                	mov    %bl,(%ecx)
80103f8e:	84 db                	test   %bl,%bl
80103f90:	75 e6                	jne    80103f78 <safestrcpy+0x17>
80103f92:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f94:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f97:	5b                   	pop    %ebx
80103f98:	5e                   	pop    %esi
80103f99:	5f                   	pop    %edi
80103f9a:	5d                   	pop    %ebp
80103f9b:	c3                   	ret    

80103f9c <strlen>:

int
strlen(const char *s)
{
80103f9c:	55                   	push   %ebp
80103f9d:	89 e5                	mov    %esp,%ebp
80103f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103fa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103fa7:	eb 03                	jmp    80103fac <strlen+0x10>
80103fa9:	83 c0 01             	add    $0x1,%eax
80103fac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103fb0:	75 f7                	jne    80103fa9 <strlen+0xd>
    ;
  return n;
}
80103fb2:	5d                   	pop    %ebp
80103fb3:	c3                   	ret    

80103fb4 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103fb4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103fb8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fbc:	55                   	push   %ebp
  pushl %ebx
80103fbd:	53                   	push   %ebx
  pushl %esi
80103fbe:	56                   	push   %esi
  pushl %edi
80103fbf:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fc0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fc2:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fc4:	5f                   	pop    %edi
  popl %esi
80103fc5:	5e                   	pop    %esi
  popl %ebx
80103fc6:	5b                   	pop    %ebx
  popl %ebp
80103fc7:	5d                   	pop    %ebp
  ret
80103fc8:	c3                   	ret    

80103fc9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fc9:	55                   	push   %ebp
80103fca:	89 e5                	mov    %esp,%ebp
80103fcc:	53                   	push   %ebx
80103fcd:	83 ec 04             	sub    $0x4,%esp
80103fd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fd3:	e8 d4 f3 ff ff       	call   801033ac <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fd8:	8b 00                	mov    (%eax),%eax
80103fda:	39 d8                	cmp    %ebx,%eax
80103fdc:	76 19                	jbe    80103ff7 <fetchint+0x2e>
80103fde:	8d 53 04             	lea    0x4(%ebx),%edx
80103fe1:	39 d0                	cmp    %edx,%eax
80103fe3:	72 19                	jb     80103ffe <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103fe5:	8b 13                	mov    (%ebx),%edx
80103fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fea:	89 10                	mov    %edx,(%eax)
  return 0;
80103fec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ff1:	83 c4 04             	add    $0x4,%esp
80103ff4:	5b                   	pop    %ebx
80103ff5:	5d                   	pop    %ebp
80103ff6:	c3                   	ret    
    return -1;
80103ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffc:	eb f3                	jmp    80103ff1 <fetchint+0x28>
80103ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104003:	eb ec                	jmp    80103ff1 <fetchint+0x28>

80104005 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104005:	55                   	push   %ebp
80104006:	89 e5                	mov    %esp,%ebp
80104008:	53                   	push   %ebx
80104009:	83 ec 04             	sub    $0x4,%esp
8010400c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010400f:	e8 98 f3 ff ff       	call   801033ac <myproc>

  if(addr >= curproc->sz)
80104014:	39 18                	cmp    %ebx,(%eax)
80104016:	76 26                	jbe    8010403e <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80104018:	8b 55 0c             	mov    0xc(%ebp),%edx
8010401b:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010401d:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010401f:	89 d8                	mov    %ebx,%eax
80104021:	39 d0                	cmp    %edx,%eax
80104023:	73 0e                	jae    80104033 <fetchstr+0x2e>
    if(*s == 0)
80104025:	80 38 00             	cmpb   $0x0,(%eax)
80104028:	74 05                	je     8010402f <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
8010402a:	83 c0 01             	add    $0x1,%eax
8010402d:	eb f2                	jmp    80104021 <fetchstr+0x1c>
      return s - *pp;
8010402f:	29 d8                	sub    %ebx,%eax
80104031:	eb 05                	jmp    80104038 <fetchstr+0x33>
  }
  return -1;
80104033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104038:	83 c4 04             	add    $0x4,%esp
8010403b:	5b                   	pop    %ebx
8010403c:	5d                   	pop    %ebp
8010403d:	c3                   	ret    
    return -1;
8010403e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104043:	eb f3                	jmp    80104038 <fetchstr+0x33>

80104045 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104045:	55                   	push   %ebp
80104046:	89 e5                	mov    %esp,%ebp
80104048:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010404b:	e8 5c f3 ff ff       	call   801033ac <myproc>
80104050:	8b 50 18             	mov    0x18(%eax),%edx
80104053:	8b 45 08             	mov    0x8(%ebp),%eax
80104056:	c1 e0 02             	shl    $0x2,%eax
80104059:	03 42 44             	add    0x44(%edx),%eax
8010405c:	83 ec 08             	sub    $0x8,%esp
8010405f:	ff 75 0c             	pushl  0xc(%ebp)
80104062:	83 c0 04             	add    $0x4,%eax
80104065:	50                   	push   %eax
80104066:	e8 5e ff ff ff       	call   80103fc9 <fetchint>
}
8010406b:	c9                   	leave  
8010406c:	c3                   	ret    

8010406d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010406d:	55                   	push   %ebp
8010406e:	89 e5                	mov    %esp,%ebp
80104070:	56                   	push   %esi
80104071:	53                   	push   %ebx
80104072:	83 ec 10             	sub    $0x10,%esp
80104075:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104078:	e8 2f f3 ff ff       	call   801033ac <myproc>
8010407d:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010407f:	83 ec 08             	sub    $0x8,%esp
80104082:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104085:	50                   	push   %eax
80104086:	ff 75 08             	pushl  0x8(%ebp)
80104089:	e8 b7 ff ff ff       	call   80104045 <argint>
8010408e:	83 c4 10             	add    $0x10,%esp
80104091:	85 c0                	test   %eax,%eax
80104093:	78 24                	js     801040b9 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104095:	85 db                	test   %ebx,%ebx
80104097:	78 27                	js     801040c0 <argptr+0x53>
80104099:	8b 16                	mov    (%esi),%edx
8010409b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409e:	39 c2                	cmp    %eax,%edx
801040a0:	76 25                	jbe    801040c7 <argptr+0x5a>
801040a2:	01 c3                	add    %eax,%ebx
801040a4:	39 da                	cmp    %ebx,%edx
801040a6:	72 26                	jb     801040ce <argptr+0x61>
    return -1;
  *pp = (char*)i;
801040a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801040ab:	89 02                	mov    %eax,(%edx)
  return 0;
801040ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040b5:	5b                   	pop    %ebx
801040b6:	5e                   	pop    %esi
801040b7:	5d                   	pop    %ebp
801040b8:	c3                   	ret    
    return -1;
801040b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040be:	eb f2                	jmp    801040b2 <argptr+0x45>
    return -1;
801040c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c5:	eb eb                	jmp    801040b2 <argptr+0x45>
801040c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cc:	eb e4                	jmp    801040b2 <argptr+0x45>
801040ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d3:	eb dd                	jmp    801040b2 <argptr+0x45>

801040d5 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040d5:	55                   	push   %ebp
801040d6:	89 e5                	mov    %esp,%ebp
801040d8:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040db:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040de:	50                   	push   %eax
801040df:	ff 75 08             	pushl  0x8(%ebp)
801040e2:	e8 5e ff ff ff       	call   80104045 <argint>
801040e7:	83 c4 10             	add    $0x10,%esp
801040ea:	85 c0                	test   %eax,%eax
801040ec:	78 13                	js     80104101 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801040ee:	83 ec 08             	sub    $0x8,%esp
801040f1:	ff 75 0c             	pushl  0xc(%ebp)
801040f4:	ff 75 f4             	pushl  -0xc(%ebp)
801040f7:	e8 09 ff ff ff       	call   80104005 <fetchstr>
801040fc:	83 c4 10             	add    $0x10,%esp
}
801040ff:	c9                   	leave  
80104100:	c3                   	ret    
    return -1;
80104101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104106:	eb f7                	jmp    801040ff <argstr+0x2a>

80104108 <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
80104108:	55                   	push   %ebp
80104109:	89 e5                	mov    %esp,%ebp
8010410b:	53                   	push   %ebx
8010410c:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010410f:	e8 98 f2 ff ff       	call   801033ac <myproc>
80104114:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104116:	8b 40 18             	mov    0x18(%eax),%eax
80104119:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010411c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010411f:	83 fa 15             	cmp    $0x15,%edx
80104122:	77 18                	ja     8010413c <syscall+0x34>
80104124:	8b 14 85 60 6d 10 80 	mov    -0x7fef92a0(,%eax,4),%edx
8010412b:	85 d2                	test   %edx,%edx
8010412d:	74 0d                	je     8010413c <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
8010412f:	ff d2                	call   *%edx
80104131:	8b 53 18             	mov    0x18(%ebx),%edx
80104134:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010413a:	c9                   	leave  
8010413b:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010413c:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010413f:	50                   	push   %eax
80104140:	52                   	push   %edx
80104141:	ff 73 10             	pushl  0x10(%ebx)
80104144:	68 31 6d 10 80       	push   $0x80106d31
80104149:	e8 bd c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
8010414e:	8b 43 18             	mov    0x18(%ebx),%eax
80104151:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104158:	83 c4 10             	add    $0x10,%esp
}
8010415b:	eb da                	jmp    80104137 <syscall+0x2f>

8010415d <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010415d:	55                   	push   %ebp
8010415e:	89 e5                	mov    %esp,%ebp
80104160:	56                   	push   %esi
80104161:	53                   	push   %ebx
80104162:	83 ec 18             	sub    $0x18,%esp
80104165:	89 d6                	mov    %edx,%esi
80104167:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104169:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010416c:	52                   	push   %edx
8010416d:	50                   	push   %eax
8010416e:	e8 d2 fe ff ff       	call   80104045 <argint>
80104173:	83 c4 10             	add    $0x10,%esp
80104176:	85 c0                	test   %eax,%eax
80104178:	78 2e                	js     801041a8 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010417a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010417e:	77 2f                	ja     801041af <argfd+0x52>
80104180:	e8 27 f2 ff ff       	call   801033ac <myproc>
80104185:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104188:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
8010418c:	85 c0                	test   %eax,%eax
8010418e:	74 26                	je     801041b6 <argfd+0x59>
    return -1;
  if(pfd)
80104190:	85 f6                	test   %esi,%esi
80104192:	74 02                	je     80104196 <argfd+0x39>
    *pfd = fd;
80104194:	89 16                	mov    %edx,(%esi)
  if(pf)
80104196:	85 db                	test   %ebx,%ebx
80104198:	74 23                	je     801041bd <argfd+0x60>
    *pf = f;
8010419a:	89 03                	mov    %eax,(%ebx)
  return 0;
8010419c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a4:	5b                   	pop    %ebx
801041a5:	5e                   	pop    %esi
801041a6:	5d                   	pop    %ebp
801041a7:	c3                   	ret    
    return -1;
801041a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ad:	eb f2                	jmp    801041a1 <argfd+0x44>
    return -1;
801041af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b4:	eb eb                	jmp    801041a1 <argfd+0x44>
801041b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041bb:	eb e4                	jmp    801041a1 <argfd+0x44>
  return 0;
801041bd:	b8 00 00 00 00       	mov    $0x0,%eax
801041c2:	eb dd                	jmp    801041a1 <argfd+0x44>

801041c4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041c4:	55                   	push   %ebp
801041c5:	89 e5                	mov    %esp,%ebp
801041c7:	53                   	push   %ebx
801041c8:	83 ec 04             	sub    $0x4,%esp
801041cb:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041cd:	e8 da f1 ff ff       	call   801033ac <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041d2:	ba 00 00 00 00       	mov    $0x0,%edx
801041d7:	83 fa 0f             	cmp    $0xf,%edx
801041da:	7f 18                	jg     801041f4 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801041dc:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801041e1:	74 05                	je     801041e8 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801041e3:	83 c2 01             	add    $0x1,%edx
801041e6:	eb ef                	jmp    801041d7 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801041e8:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801041ec:	89 d0                	mov    %edx,%eax
801041ee:	83 c4 04             	add    $0x4,%esp
801041f1:	5b                   	pop    %ebx
801041f2:	5d                   	pop    %ebp
801041f3:	c3                   	ret    
  return -1;
801041f4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801041f9:	eb f1                	jmp    801041ec <fdalloc+0x28>

801041fb <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801041fb:	55                   	push   %ebp
801041fc:	89 e5                	mov    %esp,%ebp
801041fe:	56                   	push   %esi
801041ff:	53                   	push   %ebx
80104200:	83 ec 10             	sub    $0x10,%esp
80104203:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104205:	b8 20 00 00 00       	mov    $0x20,%eax
8010420a:	89 c6                	mov    %eax,%esi
8010420c:	39 43 58             	cmp    %eax,0x58(%ebx)
8010420f:	76 2e                	jbe    8010423f <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104211:	6a 10                	push   $0x10
80104213:	50                   	push   %eax
80104214:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104217:	50                   	push   %eax
80104218:	53                   	push   %ebx
80104219:	e8 61 d5 ff ff       	call   8010177f <readi>
8010421e:	83 c4 10             	add    $0x10,%esp
80104221:	83 f8 10             	cmp    $0x10,%eax
80104224:	75 0c                	jne    80104232 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104226:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010422b:	75 1e                	jne    8010424b <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010422d:	8d 46 10             	lea    0x10(%esi),%eax
80104230:	eb d8                	jmp    8010420a <isdirempty+0xf>
      panic("isdirempty: readi");
80104232:	83 ec 0c             	sub    $0xc,%esp
80104235:	68 bc 6d 10 80       	push   $0x80106dbc
8010423a:	e8 09 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
8010423f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104244:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104247:	5b                   	pop    %ebx
80104248:	5e                   	pop    %esi
80104249:	5d                   	pop    %ebp
8010424a:	c3                   	ret    
      return 0;
8010424b:	b8 00 00 00 00       	mov    $0x0,%eax
80104250:	eb f2                	jmp    80104244 <isdirempty+0x49>

80104252 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104252:	55                   	push   %ebp
80104253:	89 e5                	mov    %esp,%ebp
80104255:	57                   	push   %edi
80104256:	56                   	push   %esi
80104257:	53                   	push   %ebx
80104258:	83 ec 44             	sub    $0x44,%esp
8010425b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
8010425e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104261:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104264:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104267:	52                   	push   %edx
80104268:	50                   	push   %eax
80104269:	e8 97 d9 ff ff       	call   80101c05 <nameiparent>
8010426e:	89 c6                	mov    %eax,%esi
80104270:	83 c4 10             	add    $0x10,%esp
80104273:	85 c0                	test   %eax,%eax
80104275:	0f 84 3a 01 00 00    	je     801043b5 <create+0x163>
    return 0;
  ilock(dp);
8010427b:	83 ec 0c             	sub    $0xc,%esp
8010427e:	50                   	push   %eax
8010427f:	e8 09 d3 ff ff       	call   8010158d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104284:	83 c4 0c             	add    $0xc,%esp
80104287:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010428a:	50                   	push   %eax
8010428b:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010428e:	50                   	push   %eax
8010428f:	56                   	push   %esi
80104290:	e8 27 d7 ff ff       	call   801019bc <dirlookup>
80104295:	89 c3                	mov    %eax,%ebx
80104297:	83 c4 10             	add    $0x10,%esp
8010429a:	85 c0                	test   %eax,%eax
8010429c:	74 3f                	je     801042dd <create+0x8b>
    iunlockput(dp);
8010429e:	83 ec 0c             	sub    $0xc,%esp
801042a1:	56                   	push   %esi
801042a2:	e8 8d d4 ff ff       	call   80101734 <iunlockput>
    ilock(ip);
801042a7:	89 1c 24             	mov    %ebx,(%esp)
801042aa:	e8 de d2 ff ff       	call   8010158d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042af:	83 c4 10             	add    $0x10,%esp
801042b2:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801042b7:	75 11                	jne    801042ca <create+0x78>
801042b9:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042be:	75 0a                	jne    801042ca <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042c0:	89 d8                	mov    %ebx,%eax
801042c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042c5:	5b                   	pop    %ebx
801042c6:	5e                   	pop    %esi
801042c7:	5f                   	pop    %edi
801042c8:	5d                   	pop    %ebp
801042c9:	c3                   	ret    
    iunlockput(ip);
801042ca:	83 ec 0c             	sub    $0xc,%esp
801042cd:	53                   	push   %ebx
801042ce:	e8 61 d4 ff ff       	call   80101734 <iunlockput>
    return 0;
801042d3:	83 c4 10             	add    $0x10,%esp
801042d6:	bb 00 00 00 00       	mov    $0x0,%ebx
801042db:	eb e3                	jmp    801042c0 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801042dd:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801042e1:	83 ec 08             	sub    $0x8,%esp
801042e4:	50                   	push   %eax
801042e5:	ff 36                	pushl  (%esi)
801042e7:	e8 9e d0 ff ff       	call   8010138a <ialloc>
801042ec:	89 c3                	mov    %eax,%ebx
801042ee:	83 c4 10             	add    $0x10,%esp
801042f1:	85 c0                	test   %eax,%eax
801042f3:	74 55                	je     8010434a <create+0xf8>
  ilock(ip);
801042f5:	83 ec 0c             	sub    $0xc,%esp
801042f8:	50                   	push   %eax
801042f9:	e8 8f d2 ff ff       	call   8010158d <ilock>
  ip->major = major;
801042fe:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104302:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104306:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010430a:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104310:	89 1c 24             	mov    %ebx,(%esp)
80104313:	e8 14 d1 ff ff       	call   8010142c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104318:	83 c4 10             	add    $0x10,%esp
8010431b:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104320:	74 35                	je     80104357 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104322:	83 ec 04             	sub    $0x4,%esp
80104325:	ff 73 04             	pushl  0x4(%ebx)
80104328:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010432b:	50                   	push   %eax
8010432c:	56                   	push   %esi
8010432d:	e8 0a d8 ff ff       	call   80101b3c <dirlink>
80104332:	83 c4 10             	add    $0x10,%esp
80104335:	85 c0                	test   %eax,%eax
80104337:	78 6f                	js     801043a8 <create+0x156>
  iunlockput(dp);
80104339:	83 ec 0c             	sub    $0xc,%esp
8010433c:	56                   	push   %esi
8010433d:	e8 f2 d3 ff ff       	call   80101734 <iunlockput>
  return ip;
80104342:	83 c4 10             	add    $0x10,%esp
80104345:	e9 76 ff ff ff       	jmp    801042c0 <create+0x6e>
    panic("create: ialloc");
8010434a:	83 ec 0c             	sub    $0xc,%esp
8010434d:	68 ce 6d 10 80       	push   $0x80106dce
80104352:	e8 f1 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104357:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010435b:	83 c0 01             	add    $0x1,%eax
8010435e:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104362:	83 ec 0c             	sub    $0xc,%esp
80104365:	56                   	push   %esi
80104366:	e8 c1 d0 ff ff       	call   8010142c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010436b:	83 c4 0c             	add    $0xc,%esp
8010436e:	ff 73 04             	pushl  0x4(%ebx)
80104371:	68 de 6d 10 80       	push   $0x80106dde
80104376:	53                   	push   %ebx
80104377:	e8 c0 d7 ff ff       	call   80101b3c <dirlink>
8010437c:	83 c4 10             	add    $0x10,%esp
8010437f:	85 c0                	test   %eax,%eax
80104381:	78 18                	js     8010439b <create+0x149>
80104383:	83 ec 04             	sub    $0x4,%esp
80104386:	ff 76 04             	pushl  0x4(%esi)
80104389:	68 dd 6d 10 80       	push   $0x80106ddd
8010438e:	53                   	push   %ebx
8010438f:	e8 a8 d7 ff ff       	call   80101b3c <dirlink>
80104394:	83 c4 10             	add    $0x10,%esp
80104397:	85 c0                	test   %eax,%eax
80104399:	79 87                	jns    80104322 <create+0xd0>
      panic("create dots");
8010439b:	83 ec 0c             	sub    $0xc,%esp
8010439e:	68 e0 6d 10 80       	push   $0x80106de0
801043a3:	e8 a0 bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801043a8:	83 ec 0c             	sub    $0xc,%esp
801043ab:	68 ec 6d 10 80       	push   $0x80106dec
801043b0:	e8 93 bf ff ff       	call   80100348 <panic>
    return 0;
801043b5:	89 c3                	mov    %eax,%ebx
801043b7:	e9 04 ff ff ff       	jmp    801042c0 <create+0x6e>

801043bc <sys_dup>:
{
801043bc:	55                   	push   %ebp
801043bd:	89 e5                	mov    %esp,%ebp
801043bf:	53                   	push   %ebx
801043c0:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043c3:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043c6:	ba 00 00 00 00       	mov    $0x0,%edx
801043cb:	b8 00 00 00 00       	mov    $0x0,%eax
801043d0:	e8 88 fd ff ff       	call   8010415d <argfd>
801043d5:	85 c0                	test   %eax,%eax
801043d7:	78 23                	js     801043fc <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043dc:	e8 e3 fd ff ff       	call   801041c4 <fdalloc>
801043e1:	89 c3                	mov    %eax,%ebx
801043e3:	85 c0                	test   %eax,%eax
801043e5:	78 1c                	js     80104403 <sys_dup+0x47>
  filedup(f);
801043e7:	83 ec 0c             	sub    $0xc,%esp
801043ea:	ff 75 f4             	pushl  -0xc(%ebp)
801043ed:	e8 a8 c8 ff ff       	call   80100c9a <filedup>
  return fd;
801043f2:	83 c4 10             	add    $0x10,%esp
}
801043f5:	89 d8                	mov    %ebx,%eax
801043f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043fa:	c9                   	leave  
801043fb:	c3                   	ret    
    return -1;
801043fc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104401:	eb f2                	jmp    801043f5 <sys_dup+0x39>
    return -1;
80104403:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104408:	eb eb                	jmp    801043f5 <sys_dup+0x39>

8010440a <sys_read>:
{
8010440a:	55                   	push   %ebp
8010440b:	89 e5                	mov    %esp,%ebp
8010440d:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104410:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104413:	ba 00 00 00 00       	mov    $0x0,%edx
80104418:	b8 00 00 00 00       	mov    $0x0,%eax
8010441d:	e8 3b fd ff ff       	call   8010415d <argfd>
80104422:	85 c0                	test   %eax,%eax
80104424:	78 43                	js     80104469 <sys_read+0x5f>
80104426:	83 ec 08             	sub    $0x8,%esp
80104429:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010442c:	50                   	push   %eax
8010442d:	6a 02                	push   $0x2
8010442f:	e8 11 fc ff ff       	call   80104045 <argint>
80104434:	83 c4 10             	add    $0x10,%esp
80104437:	85 c0                	test   %eax,%eax
80104439:	78 35                	js     80104470 <sys_read+0x66>
8010443b:	83 ec 04             	sub    $0x4,%esp
8010443e:	ff 75 f0             	pushl  -0x10(%ebp)
80104441:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104444:	50                   	push   %eax
80104445:	6a 01                	push   $0x1
80104447:	e8 21 fc ff ff       	call   8010406d <argptr>
8010444c:	83 c4 10             	add    $0x10,%esp
8010444f:	85 c0                	test   %eax,%eax
80104451:	78 24                	js     80104477 <sys_read+0x6d>
  return fileread(f, p, n);
80104453:	83 ec 04             	sub    $0x4,%esp
80104456:	ff 75 f0             	pushl  -0x10(%ebp)
80104459:	ff 75 ec             	pushl  -0x14(%ebp)
8010445c:	ff 75 f4             	pushl  -0xc(%ebp)
8010445f:	e8 7f c9 ff ff       	call   80100de3 <fileread>
80104464:	83 c4 10             	add    $0x10,%esp
}
80104467:	c9                   	leave  
80104468:	c3                   	ret    
    return -1;
80104469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010446e:	eb f7                	jmp    80104467 <sys_read+0x5d>
80104470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104475:	eb f0                	jmp    80104467 <sys_read+0x5d>
80104477:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010447c:	eb e9                	jmp    80104467 <sys_read+0x5d>

8010447e <sys_write>:
{
8010447e:	55                   	push   %ebp
8010447f:	89 e5                	mov    %esp,%ebp
80104481:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104484:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104487:	ba 00 00 00 00       	mov    $0x0,%edx
8010448c:	b8 00 00 00 00       	mov    $0x0,%eax
80104491:	e8 c7 fc ff ff       	call   8010415d <argfd>
80104496:	85 c0                	test   %eax,%eax
80104498:	78 43                	js     801044dd <sys_write+0x5f>
8010449a:	83 ec 08             	sub    $0x8,%esp
8010449d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044a0:	50                   	push   %eax
801044a1:	6a 02                	push   $0x2
801044a3:	e8 9d fb ff ff       	call   80104045 <argint>
801044a8:	83 c4 10             	add    $0x10,%esp
801044ab:	85 c0                	test   %eax,%eax
801044ad:	78 35                	js     801044e4 <sys_write+0x66>
801044af:	83 ec 04             	sub    $0x4,%esp
801044b2:	ff 75 f0             	pushl  -0x10(%ebp)
801044b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044b8:	50                   	push   %eax
801044b9:	6a 01                	push   $0x1
801044bb:	e8 ad fb ff ff       	call   8010406d <argptr>
801044c0:	83 c4 10             	add    $0x10,%esp
801044c3:	85 c0                	test   %eax,%eax
801044c5:	78 24                	js     801044eb <sys_write+0x6d>
  return filewrite(f, p, n);
801044c7:	83 ec 04             	sub    $0x4,%esp
801044ca:	ff 75 f0             	pushl  -0x10(%ebp)
801044cd:	ff 75 ec             	pushl  -0x14(%ebp)
801044d0:	ff 75 f4             	pushl  -0xc(%ebp)
801044d3:	e8 90 c9 ff ff       	call   80100e68 <filewrite>
801044d8:	83 c4 10             	add    $0x10,%esp
}
801044db:	c9                   	leave  
801044dc:	c3                   	ret    
    return -1;
801044dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e2:	eb f7                	jmp    801044db <sys_write+0x5d>
801044e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e9:	eb f0                	jmp    801044db <sys_write+0x5d>
801044eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044f0:	eb e9                	jmp    801044db <sys_write+0x5d>

801044f2 <sys_close>:
{
801044f2:	55                   	push   %ebp
801044f3:	89 e5                	mov    %esp,%ebp
801044f5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801044f8:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801044fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
801044fe:	b8 00 00 00 00       	mov    $0x0,%eax
80104503:	e8 55 fc ff ff       	call   8010415d <argfd>
80104508:	85 c0                	test   %eax,%eax
8010450a:	78 25                	js     80104531 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010450c:	e8 9b ee ff ff       	call   801033ac <myproc>
80104511:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104514:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010451b:	00 
  fileclose(f);
8010451c:	83 ec 0c             	sub    $0xc,%esp
8010451f:	ff 75 f0             	pushl  -0x10(%ebp)
80104522:	e8 b8 c7 ff ff       	call   80100cdf <fileclose>
  return 0;
80104527:	83 c4 10             	add    $0x10,%esp
8010452a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010452f:	c9                   	leave  
80104530:	c3                   	ret    
    return -1;
80104531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104536:	eb f7                	jmp    8010452f <sys_close+0x3d>

80104538 <sys_fstat>:
{
80104538:	55                   	push   %ebp
80104539:	89 e5                	mov    %esp,%ebp
8010453b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010453e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104541:	ba 00 00 00 00       	mov    $0x0,%edx
80104546:	b8 00 00 00 00       	mov    $0x0,%eax
8010454b:	e8 0d fc ff ff       	call   8010415d <argfd>
80104550:	85 c0                	test   %eax,%eax
80104552:	78 2a                	js     8010457e <sys_fstat+0x46>
80104554:	83 ec 04             	sub    $0x4,%esp
80104557:	6a 14                	push   $0x14
80104559:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010455c:	50                   	push   %eax
8010455d:	6a 01                	push   $0x1
8010455f:	e8 09 fb ff ff       	call   8010406d <argptr>
80104564:	83 c4 10             	add    $0x10,%esp
80104567:	85 c0                	test   %eax,%eax
80104569:	78 1a                	js     80104585 <sys_fstat+0x4d>
  return filestat(f, st);
8010456b:	83 ec 08             	sub    $0x8,%esp
8010456e:	ff 75 f0             	pushl  -0x10(%ebp)
80104571:	ff 75 f4             	pushl  -0xc(%ebp)
80104574:	e8 23 c8 ff ff       	call   80100d9c <filestat>
80104579:	83 c4 10             	add    $0x10,%esp
}
8010457c:	c9                   	leave  
8010457d:	c3                   	ret    
    return -1;
8010457e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104583:	eb f7                	jmp    8010457c <sys_fstat+0x44>
80104585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458a:	eb f0                	jmp    8010457c <sys_fstat+0x44>

8010458c <sys_link>:
{
8010458c:	55                   	push   %ebp
8010458d:	89 e5                	mov    %esp,%ebp
8010458f:	56                   	push   %esi
80104590:	53                   	push   %ebx
80104591:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104594:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104597:	50                   	push   %eax
80104598:	6a 00                	push   $0x0
8010459a:	e8 36 fb ff ff       	call   801040d5 <argstr>
8010459f:	83 c4 10             	add    $0x10,%esp
801045a2:	85 c0                	test   %eax,%eax
801045a4:	0f 88 32 01 00 00    	js     801046dc <sys_link+0x150>
801045aa:	83 ec 08             	sub    $0x8,%esp
801045ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045b0:	50                   	push   %eax
801045b1:	6a 01                	push   $0x1
801045b3:	e8 1d fb ff ff       	call   801040d5 <argstr>
801045b8:	83 c4 10             	add    $0x10,%esp
801045bb:	85 c0                	test   %eax,%eax
801045bd:	0f 88 20 01 00 00    	js     801046e3 <sys_link+0x157>
  begin_op();
801045c3:	e8 89 e3 ff ff       	call   80102951 <begin_op>
  if((ip = namei(old)) == 0){
801045c8:	83 ec 0c             	sub    $0xc,%esp
801045cb:	ff 75 e0             	pushl  -0x20(%ebp)
801045ce:	e8 1a d6 ff ff       	call   80101bed <namei>
801045d3:	89 c3                	mov    %eax,%ebx
801045d5:	83 c4 10             	add    $0x10,%esp
801045d8:	85 c0                	test   %eax,%eax
801045da:	0f 84 99 00 00 00    	je     80104679 <sys_link+0xed>
  ilock(ip);
801045e0:	83 ec 0c             	sub    $0xc,%esp
801045e3:	50                   	push   %eax
801045e4:	e8 a4 cf ff ff       	call   8010158d <ilock>
  if(ip->type == T_DIR){
801045e9:	83 c4 10             	add    $0x10,%esp
801045ec:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045f1:	0f 84 8e 00 00 00    	je     80104685 <sys_link+0xf9>
  ip->nlink++;
801045f7:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045fb:	83 c0 01             	add    $0x1,%eax
801045fe:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104602:	83 ec 0c             	sub    $0xc,%esp
80104605:	53                   	push   %ebx
80104606:	e8 21 ce ff ff       	call   8010142c <iupdate>
  iunlock(ip);
8010460b:	89 1c 24             	mov    %ebx,(%esp)
8010460e:	e8 3c d0 ff ff       	call   8010164f <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104613:	83 c4 08             	add    $0x8,%esp
80104616:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104619:	50                   	push   %eax
8010461a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010461d:	e8 e3 d5 ff ff       	call   80101c05 <nameiparent>
80104622:	89 c6                	mov    %eax,%esi
80104624:	83 c4 10             	add    $0x10,%esp
80104627:	85 c0                	test   %eax,%eax
80104629:	74 7e                	je     801046a9 <sys_link+0x11d>
  ilock(dp);
8010462b:	83 ec 0c             	sub    $0xc,%esp
8010462e:	50                   	push   %eax
8010462f:	e8 59 cf ff ff       	call   8010158d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104634:	83 c4 10             	add    $0x10,%esp
80104637:	8b 03                	mov    (%ebx),%eax
80104639:	39 06                	cmp    %eax,(%esi)
8010463b:	75 60                	jne    8010469d <sys_link+0x111>
8010463d:	83 ec 04             	sub    $0x4,%esp
80104640:	ff 73 04             	pushl  0x4(%ebx)
80104643:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104646:	50                   	push   %eax
80104647:	56                   	push   %esi
80104648:	e8 ef d4 ff ff       	call   80101b3c <dirlink>
8010464d:	83 c4 10             	add    $0x10,%esp
80104650:	85 c0                	test   %eax,%eax
80104652:	78 49                	js     8010469d <sys_link+0x111>
  iunlockput(dp);
80104654:	83 ec 0c             	sub    $0xc,%esp
80104657:	56                   	push   %esi
80104658:	e8 d7 d0 ff ff       	call   80101734 <iunlockput>
  iput(ip);
8010465d:	89 1c 24             	mov    %ebx,(%esp)
80104660:	e8 2f d0 ff ff       	call   80101694 <iput>
  end_op();
80104665:	e8 61 e3 ff ff       	call   801029cb <end_op>
  return 0;
8010466a:	83 c4 10             	add    $0x10,%esp
8010466d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104672:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104675:	5b                   	pop    %ebx
80104676:	5e                   	pop    %esi
80104677:	5d                   	pop    %ebp
80104678:	c3                   	ret    
    end_op();
80104679:	e8 4d e3 ff ff       	call   801029cb <end_op>
    return -1;
8010467e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104683:	eb ed                	jmp    80104672 <sys_link+0xe6>
    iunlockput(ip);
80104685:	83 ec 0c             	sub    $0xc,%esp
80104688:	53                   	push   %ebx
80104689:	e8 a6 d0 ff ff       	call   80101734 <iunlockput>
    end_op();
8010468e:	e8 38 e3 ff ff       	call   801029cb <end_op>
    return -1;
80104693:	83 c4 10             	add    $0x10,%esp
80104696:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010469b:	eb d5                	jmp    80104672 <sys_link+0xe6>
    iunlockput(dp);
8010469d:	83 ec 0c             	sub    $0xc,%esp
801046a0:	56                   	push   %esi
801046a1:	e8 8e d0 ff ff       	call   80101734 <iunlockput>
    goto bad;
801046a6:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046a9:	83 ec 0c             	sub    $0xc,%esp
801046ac:	53                   	push   %ebx
801046ad:	e8 db ce ff ff       	call   8010158d <ilock>
  ip->nlink--;
801046b2:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046b6:	83 e8 01             	sub    $0x1,%eax
801046b9:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046bd:	89 1c 24             	mov    %ebx,(%esp)
801046c0:	e8 67 cd ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801046c5:	89 1c 24             	mov    %ebx,(%esp)
801046c8:	e8 67 d0 ff ff       	call   80101734 <iunlockput>
  end_op();
801046cd:	e8 f9 e2 ff ff       	call   801029cb <end_op>
  return -1;
801046d2:	83 c4 10             	add    $0x10,%esp
801046d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046da:	eb 96                	jmp    80104672 <sys_link+0xe6>
    return -1;
801046dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e1:	eb 8f                	jmp    80104672 <sys_link+0xe6>
801046e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e8:	eb 88                	jmp    80104672 <sys_link+0xe6>

801046ea <sys_unlink>:
{
801046ea:	55                   	push   %ebp
801046eb:	89 e5                	mov    %esp,%ebp
801046ed:	57                   	push   %edi
801046ee:	56                   	push   %esi
801046ef:	53                   	push   %ebx
801046f0:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801046f3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046f6:	50                   	push   %eax
801046f7:	6a 00                	push   $0x0
801046f9:	e8 d7 f9 ff ff       	call   801040d5 <argstr>
801046fe:	83 c4 10             	add    $0x10,%esp
80104701:	85 c0                	test   %eax,%eax
80104703:	0f 88 83 01 00 00    	js     8010488c <sys_unlink+0x1a2>
  begin_op();
80104709:	e8 43 e2 ff ff       	call   80102951 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010470e:	83 ec 08             	sub    $0x8,%esp
80104711:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104714:	50                   	push   %eax
80104715:	ff 75 c4             	pushl  -0x3c(%ebp)
80104718:	e8 e8 d4 ff ff       	call   80101c05 <nameiparent>
8010471d:	89 c6                	mov    %eax,%esi
8010471f:	83 c4 10             	add    $0x10,%esp
80104722:	85 c0                	test   %eax,%eax
80104724:	0f 84 ed 00 00 00    	je     80104817 <sys_unlink+0x12d>
  ilock(dp);
8010472a:	83 ec 0c             	sub    $0xc,%esp
8010472d:	50                   	push   %eax
8010472e:	e8 5a ce ff ff       	call   8010158d <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104733:	83 c4 08             	add    $0x8,%esp
80104736:	68 de 6d 10 80       	push   $0x80106dde
8010473b:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010473e:	50                   	push   %eax
8010473f:	e8 63 d2 ff ff       	call   801019a7 <namecmp>
80104744:	83 c4 10             	add    $0x10,%esp
80104747:	85 c0                	test   %eax,%eax
80104749:	0f 84 fc 00 00 00    	je     8010484b <sys_unlink+0x161>
8010474f:	83 ec 08             	sub    $0x8,%esp
80104752:	68 dd 6d 10 80       	push   $0x80106ddd
80104757:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010475a:	50                   	push   %eax
8010475b:	e8 47 d2 ff ff       	call   801019a7 <namecmp>
80104760:	83 c4 10             	add    $0x10,%esp
80104763:	85 c0                	test   %eax,%eax
80104765:	0f 84 e0 00 00 00    	je     8010484b <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010476b:	83 ec 04             	sub    $0x4,%esp
8010476e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104771:	50                   	push   %eax
80104772:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104775:	50                   	push   %eax
80104776:	56                   	push   %esi
80104777:	e8 40 d2 ff ff       	call   801019bc <dirlookup>
8010477c:	89 c3                	mov    %eax,%ebx
8010477e:	83 c4 10             	add    $0x10,%esp
80104781:	85 c0                	test   %eax,%eax
80104783:	0f 84 c2 00 00 00    	je     8010484b <sys_unlink+0x161>
  ilock(ip);
80104789:	83 ec 0c             	sub    $0xc,%esp
8010478c:	50                   	push   %eax
8010478d:	e8 fb cd ff ff       	call   8010158d <ilock>
  if(ip->nlink < 1)
80104792:	83 c4 10             	add    $0x10,%esp
80104795:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010479a:	0f 8e 83 00 00 00    	jle    80104823 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047a0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047a5:	0f 84 85 00 00 00    	je     80104830 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801047ab:	83 ec 04             	sub    $0x4,%esp
801047ae:	6a 10                	push   $0x10
801047b0:	6a 00                	push   $0x0
801047b2:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047b5:	57                   	push   %edi
801047b6:	e8 3f f6 ff ff       	call   80103dfa <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047bb:	6a 10                	push   $0x10
801047bd:	ff 75 c0             	pushl  -0x40(%ebp)
801047c0:	57                   	push   %edi
801047c1:	56                   	push   %esi
801047c2:	e8 b5 d0 ff ff       	call   8010187c <writei>
801047c7:	83 c4 20             	add    $0x20,%esp
801047ca:	83 f8 10             	cmp    $0x10,%eax
801047cd:	0f 85 90 00 00 00    	jne    80104863 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047d3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047d8:	0f 84 92 00 00 00    	je     80104870 <sys_unlink+0x186>
  iunlockput(dp);
801047de:	83 ec 0c             	sub    $0xc,%esp
801047e1:	56                   	push   %esi
801047e2:	e8 4d cf ff ff       	call   80101734 <iunlockput>
  ip->nlink--;
801047e7:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801047eb:	83 e8 01             	sub    $0x1,%eax
801047ee:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801047f2:	89 1c 24             	mov    %ebx,(%esp)
801047f5:	e8 32 cc ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801047fa:	89 1c 24             	mov    %ebx,(%esp)
801047fd:	e8 32 cf ff ff       	call   80101734 <iunlockput>
  end_op();
80104802:	e8 c4 e1 ff ff       	call   801029cb <end_op>
  return 0;
80104807:	83 c4 10             	add    $0x10,%esp
8010480a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010480f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104812:	5b                   	pop    %ebx
80104813:	5e                   	pop    %esi
80104814:	5f                   	pop    %edi
80104815:	5d                   	pop    %ebp
80104816:	c3                   	ret    
    end_op();
80104817:	e8 af e1 ff ff       	call   801029cb <end_op>
    return -1;
8010481c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104821:	eb ec                	jmp    8010480f <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104823:	83 ec 0c             	sub    $0xc,%esp
80104826:	68 fc 6d 10 80       	push   $0x80106dfc
8010482b:	e8 18 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104830:	89 d8                	mov    %ebx,%eax
80104832:	e8 c4 f9 ff ff       	call   801041fb <isdirempty>
80104837:	85 c0                	test   %eax,%eax
80104839:	0f 85 6c ff ff ff    	jne    801047ab <sys_unlink+0xc1>
    iunlockput(ip);
8010483f:	83 ec 0c             	sub    $0xc,%esp
80104842:	53                   	push   %ebx
80104843:	e8 ec ce ff ff       	call   80101734 <iunlockput>
    goto bad;
80104848:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010484b:	83 ec 0c             	sub    $0xc,%esp
8010484e:	56                   	push   %esi
8010484f:	e8 e0 ce ff ff       	call   80101734 <iunlockput>
  end_op();
80104854:	e8 72 e1 ff ff       	call   801029cb <end_op>
  return -1;
80104859:	83 c4 10             	add    $0x10,%esp
8010485c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104861:	eb ac                	jmp    8010480f <sys_unlink+0x125>
    panic("unlink: writei");
80104863:	83 ec 0c             	sub    $0xc,%esp
80104866:	68 0e 6e 10 80       	push   $0x80106e0e
8010486b:	e8 d8 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104870:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104874:	83 e8 01             	sub    $0x1,%eax
80104877:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010487b:	83 ec 0c             	sub    $0xc,%esp
8010487e:	56                   	push   %esi
8010487f:	e8 a8 cb ff ff       	call   8010142c <iupdate>
80104884:	83 c4 10             	add    $0x10,%esp
80104887:	e9 52 ff ff ff       	jmp    801047de <sys_unlink+0xf4>
    return -1;
8010488c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104891:	e9 79 ff ff ff       	jmp    8010480f <sys_unlink+0x125>

80104896 <sys_open>:

int
sys_open(void)
{
80104896:	55                   	push   %ebp
80104897:	89 e5                	mov    %esp,%ebp
80104899:	57                   	push   %edi
8010489a:	56                   	push   %esi
8010489b:	53                   	push   %ebx
8010489c:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010489f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048a2:	50                   	push   %eax
801048a3:	6a 00                	push   $0x0
801048a5:	e8 2b f8 ff ff       	call   801040d5 <argstr>
801048aa:	83 c4 10             	add    $0x10,%esp
801048ad:	85 c0                	test   %eax,%eax
801048af:	0f 88 30 01 00 00    	js     801049e5 <sys_open+0x14f>
801048b5:	83 ec 08             	sub    $0x8,%esp
801048b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048bb:	50                   	push   %eax
801048bc:	6a 01                	push   $0x1
801048be:	e8 82 f7 ff ff       	call   80104045 <argint>
801048c3:	83 c4 10             	add    $0x10,%esp
801048c6:	85 c0                	test   %eax,%eax
801048c8:	0f 88 21 01 00 00    	js     801049ef <sys_open+0x159>
    return -1;

  begin_op();
801048ce:	e8 7e e0 ff ff       	call   80102951 <begin_op>

  if(omode & O_CREATE){
801048d3:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048d7:	0f 84 84 00 00 00    	je     80104961 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801048dd:	83 ec 0c             	sub    $0xc,%esp
801048e0:	6a 00                	push   $0x0
801048e2:	b9 00 00 00 00       	mov    $0x0,%ecx
801048e7:	ba 02 00 00 00       	mov    $0x2,%edx
801048ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801048ef:	e8 5e f9 ff ff       	call   80104252 <create>
801048f4:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801048f6:	83 c4 10             	add    $0x10,%esp
801048f9:	85 c0                	test   %eax,%eax
801048fb:	74 58                	je     80104955 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801048fd:	e8 37 c3 ff ff       	call   80100c39 <filealloc>
80104902:	89 c3                	mov    %eax,%ebx
80104904:	85 c0                	test   %eax,%eax
80104906:	0f 84 ae 00 00 00    	je     801049ba <sys_open+0x124>
8010490c:	e8 b3 f8 ff ff       	call   801041c4 <fdalloc>
80104911:	89 c7                	mov    %eax,%edi
80104913:	85 c0                	test   %eax,%eax
80104915:	0f 88 9f 00 00 00    	js     801049ba <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010491b:	83 ec 0c             	sub    $0xc,%esp
8010491e:	56                   	push   %esi
8010491f:	e8 2b cd ff ff       	call   8010164f <iunlock>
  end_op();
80104924:	e8 a2 e0 ff ff       	call   801029cb <end_op>

  f->type = FD_INODE;
80104929:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
8010492f:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104932:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104939:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010493c:	83 c4 10             	add    $0x10,%esp
8010493f:	a8 01                	test   $0x1,%al
80104941:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104945:	a8 03                	test   $0x3,%al
80104947:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010494b:	89 f8                	mov    %edi,%eax
8010494d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104950:	5b                   	pop    %ebx
80104951:	5e                   	pop    %esi
80104952:	5f                   	pop    %edi
80104953:	5d                   	pop    %ebp
80104954:	c3                   	ret    
      end_op();
80104955:	e8 71 e0 ff ff       	call   801029cb <end_op>
      return -1;
8010495a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010495f:	eb ea                	jmp    8010494b <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104961:	83 ec 0c             	sub    $0xc,%esp
80104964:	ff 75 e4             	pushl  -0x1c(%ebp)
80104967:	e8 81 d2 ff ff       	call   80101bed <namei>
8010496c:	89 c6                	mov    %eax,%esi
8010496e:	83 c4 10             	add    $0x10,%esp
80104971:	85 c0                	test   %eax,%eax
80104973:	74 39                	je     801049ae <sys_open+0x118>
    ilock(ip);
80104975:	83 ec 0c             	sub    $0xc,%esp
80104978:	50                   	push   %eax
80104979:	e8 0f cc ff ff       	call   8010158d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010497e:	83 c4 10             	add    $0x10,%esp
80104981:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104986:	0f 85 71 ff ff ff    	jne    801048fd <sys_open+0x67>
8010498c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104990:	0f 84 67 ff ff ff    	je     801048fd <sys_open+0x67>
      iunlockput(ip);
80104996:	83 ec 0c             	sub    $0xc,%esp
80104999:	56                   	push   %esi
8010499a:	e8 95 cd ff ff       	call   80101734 <iunlockput>
      end_op();
8010499f:	e8 27 e0 ff ff       	call   801029cb <end_op>
      return -1;
801049a4:	83 c4 10             	add    $0x10,%esp
801049a7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049ac:	eb 9d                	jmp    8010494b <sys_open+0xb5>
      end_op();
801049ae:	e8 18 e0 ff ff       	call   801029cb <end_op>
      return -1;
801049b3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049b8:	eb 91                	jmp    8010494b <sys_open+0xb5>
    if(f)
801049ba:	85 db                	test   %ebx,%ebx
801049bc:	74 0c                	je     801049ca <sys_open+0x134>
      fileclose(f);
801049be:	83 ec 0c             	sub    $0xc,%esp
801049c1:	53                   	push   %ebx
801049c2:	e8 18 c3 ff ff       	call   80100cdf <fileclose>
801049c7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049ca:	83 ec 0c             	sub    $0xc,%esp
801049cd:	56                   	push   %esi
801049ce:	e8 61 cd ff ff       	call   80101734 <iunlockput>
    end_op();
801049d3:	e8 f3 df ff ff       	call   801029cb <end_op>
    return -1;
801049d8:	83 c4 10             	add    $0x10,%esp
801049db:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049e0:	e9 66 ff ff ff       	jmp    8010494b <sys_open+0xb5>
    return -1;
801049e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049ea:	e9 5c ff ff ff       	jmp    8010494b <sys_open+0xb5>
801049ef:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049f4:	e9 52 ff ff ff       	jmp    8010494b <sys_open+0xb5>

801049f9 <sys_mkdir>:

int
sys_mkdir(void)
{
801049f9:	55                   	push   %ebp
801049fa:	89 e5                	mov    %esp,%ebp
801049fc:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801049ff:	e8 4d df ff ff       	call   80102951 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a04:	83 ec 08             	sub    $0x8,%esp
80104a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a0a:	50                   	push   %eax
80104a0b:	6a 00                	push   $0x0
80104a0d:	e8 c3 f6 ff ff       	call   801040d5 <argstr>
80104a12:	83 c4 10             	add    $0x10,%esp
80104a15:	85 c0                	test   %eax,%eax
80104a17:	78 36                	js     80104a4f <sys_mkdir+0x56>
80104a19:	83 ec 0c             	sub    $0xc,%esp
80104a1c:	6a 00                	push   $0x0
80104a1e:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a23:	ba 01 00 00 00       	mov    $0x1,%edx
80104a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2b:	e8 22 f8 ff ff       	call   80104252 <create>
80104a30:	83 c4 10             	add    $0x10,%esp
80104a33:	85 c0                	test   %eax,%eax
80104a35:	74 18                	je     80104a4f <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a37:	83 ec 0c             	sub    $0xc,%esp
80104a3a:	50                   	push   %eax
80104a3b:	e8 f4 cc ff ff       	call   80101734 <iunlockput>
  end_op();
80104a40:	e8 86 df ff ff       	call   801029cb <end_op>
  return 0;
80104a45:	83 c4 10             	add    $0x10,%esp
80104a48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a4d:	c9                   	leave  
80104a4e:	c3                   	ret    
    end_op();
80104a4f:	e8 77 df ff ff       	call   801029cb <end_op>
    return -1;
80104a54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a59:	eb f2                	jmp    80104a4d <sys_mkdir+0x54>

80104a5b <sys_mknod>:

int
sys_mknod(void)
{
80104a5b:	55                   	push   %ebp
80104a5c:	89 e5                	mov    %esp,%ebp
80104a5e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a61:	e8 eb de ff ff       	call   80102951 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a66:	83 ec 08             	sub    $0x8,%esp
80104a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a6c:	50                   	push   %eax
80104a6d:	6a 00                	push   $0x0
80104a6f:	e8 61 f6 ff ff       	call   801040d5 <argstr>
80104a74:	83 c4 10             	add    $0x10,%esp
80104a77:	85 c0                	test   %eax,%eax
80104a79:	78 62                	js     80104add <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a7b:	83 ec 08             	sub    $0x8,%esp
80104a7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a81:	50                   	push   %eax
80104a82:	6a 01                	push   $0x1
80104a84:	e8 bc f5 ff ff       	call   80104045 <argint>
  if((argstr(0, &path)) < 0 ||
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	85 c0                	test   %eax,%eax
80104a8e:	78 4d                	js     80104add <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a90:	83 ec 08             	sub    $0x8,%esp
80104a93:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a96:	50                   	push   %eax
80104a97:	6a 02                	push   $0x2
80104a99:	e8 a7 f5 ff ff       	call   80104045 <argint>
     argint(1, &major) < 0 ||
80104a9e:	83 c4 10             	add    $0x10,%esp
80104aa1:	85 c0                	test   %eax,%eax
80104aa3:	78 38                	js     80104add <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104aa5:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104aa9:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104aad:	83 ec 0c             	sub    $0xc,%esp
80104ab0:	50                   	push   %eax
80104ab1:	ba 03 00 00 00       	mov    $0x3,%edx
80104ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab9:	e8 94 f7 ff ff       	call   80104252 <create>
80104abe:	83 c4 10             	add    $0x10,%esp
80104ac1:	85 c0                	test   %eax,%eax
80104ac3:	74 18                	je     80104add <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ac5:	83 ec 0c             	sub    $0xc,%esp
80104ac8:	50                   	push   %eax
80104ac9:	e8 66 cc ff ff       	call   80101734 <iunlockput>
  end_op();
80104ace:	e8 f8 de ff ff       	call   801029cb <end_op>
  return 0;
80104ad3:	83 c4 10             	add    $0x10,%esp
80104ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104adb:	c9                   	leave  
80104adc:	c3                   	ret    
    end_op();
80104add:	e8 e9 de ff ff       	call   801029cb <end_op>
    return -1;
80104ae2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae7:	eb f2                	jmp    80104adb <sys_mknod+0x80>

80104ae9 <sys_chdir>:

int
sys_chdir(void)
{
80104ae9:	55                   	push   %ebp
80104aea:	89 e5                	mov    %esp,%ebp
80104aec:	56                   	push   %esi
80104aed:	53                   	push   %ebx
80104aee:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104af1:	e8 b6 e8 ff ff       	call   801033ac <myproc>
80104af6:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104af8:	e8 54 de ff ff       	call   80102951 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104afd:	83 ec 08             	sub    $0x8,%esp
80104b00:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b03:	50                   	push   %eax
80104b04:	6a 00                	push   $0x0
80104b06:	e8 ca f5 ff ff       	call   801040d5 <argstr>
80104b0b:	83 c4 10             	add    $0x10,%esp
80104b0e:	85 c0                	test   %eax,%eax
80104b10:	78 52                	js     80104b64 <sys_chdir+0x7b>
80104b12:	83 ec 0c             	sub    $0xc,%esp
80104b15:	ff 75 f4             	pushl  -0xc(%ebp)
80104b18:	e8 d0 d0 ff ff       	call   80101bed <namei>
80104b1d:	89 c3                	mov    %eax,%ebx
80104b1f:	83 c4 10             	add    $0x10,%esp
80104b22:	85 c0                	test   %eax,%eax
80104b24:	74 3e                	je     80104b64 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b26:	83 ec 0c             	sub    $0xc,%esp
80104b29:	50                   	push   %eax
80104b2a:	e8 5e ca ff ff       	call   8010158d <ilock>
  if(ip->type != T_DIR){
80104b2f:	83 c4 10             	add    $0x10,%esp
80104b32:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b37:	75 37                	jne    80104b70 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b39:	83 ec 0c             	sub    $0xc,%esp
80104b3c:	53                   	push   %ebx
80104b3d:	e8 0d cb ff ff       	call   8010164f <iunlock>
  iput(curproc->cwd);
80104b42:	83 c4 04             	add    $0x4,%esp
80104b45:	ff 76 68             	pushl  0x68(%esi)
80104b48:	e8 47 cb ff ff       	call   80101694 <iput>
  end_op();
80104b4d:	e8 79 de ff ff       	call   801029cb <end_op>
  curproc->cwd = ip;
80104b52:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b55:	83 c4 10             	add    $0x10,%esp
80104b58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b60:	5b                   	pop    %ebx
80104b61:	5e                   	pop    %esi
80104b62:	5d                   	pop    %ebp
80104b63:	c3                   	ret    
    end_op();
80104b64:	e8 62 de ff ff       	call   801029cb <end_op>
    return -1;
80104b69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6e:	eb ed                	jmp    80104b5d <sys_chdir+0x74>
    iunlockput(ip);
80104b70:	83 ec 0c             	sub    $0xc,%esp
80104b73:	53                   	push   %ebx
80104b74:	e8 bb cb ff ff       	call   80101734 <iunlockput>
    end_op();
80104b79:	e8 4d de ff ff       	call   801029cb <end_op>
    return -1;
80104b7e:	83 c4 10             	add    $0x10,%esp
80104b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b86:	eb d5                	jmp    80104b5d <sys_chdir+0x74>

80104b88 <sys_exec>:

int
sys_exec(void)
{
80104b88:	55                   	push   %ebp
80104b89:	89 e5                	mov    %esp,%ebp
80104b8b:	53                   	push   %ebx
80104b8c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b95:	50                   	push   %eax
80104b96:	6a 00                	push   $0x0
80104b98:	e8 38 f5 ff ff       	call   801040d5 <argstr>
80104b9d:	83 c4 10             	add    $0x10,%esp
80104ba0:	85 c0                	test   %eax,%eax
80104ba2:	0f 88 a8 00 00 00    	js     80104c50 <sys_exec+0xc8>
80104ba8:	83 ec 08             	sub    $0x8,%esp
80104bab:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bb1:	50                   	push   %eax
80104bb2:	6a 01                	push   $0x1
80104bb4:	e8 8c f4 ff ff       	call   80104045 <argint>
80104bb9:	83 c4 10             	add    $0x10,%esp
80104bbc:	85 c0                	test   %eax,%eax
80104bbe:	0f 88 93 00 00 00    	js     80104c57 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bc4:	83 ec 04             	sub    $0x4,%esp
80104bc7:	68 80 00 00 00       	push   $0x80
80104bcc:	6a 00                	push   $0x0
80104bce:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bd4:	50                   	push   %eax
80104bd5:	e8 20 f2 ff ff       	call   80103dfa <memset>
80104bda:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104be2:	83 fb 1f             	cmp    $0x1f,%ebx
80104be5:	77 77                	ja     80104c5e <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104be7:	83 ec 08             	sub    $0x8,%esp
80104bea:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104bf0:	50                   	push   %eax
80104bf1:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104bf7:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104bfa:	50                   	push   %eax
80104bfb:	e8 c9 f3 ff ff       	call   80103fc9 <fetchint>
80104c00:	83 c4 10             	add    $0x10,%esp
80104c03:	85 c0                	test   %eax,%eax
80104c05:	78 5e                	js     80104c65 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104c07:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c0d:	85 c0                	test   %eax,%eax
80104c0f:	74 1d                	je     80104c2e <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104c11:	83 ec 08             	sub    $0x8,%esp
80104c14:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c1b:	52                   	push   %edx
80104c1c:	50                   	push   %eax
80104c1d:	e8 e3 f3 ff ff       	call   80104005 <fetchstr>
80104c22:	83 c4 10             	add    $0x10,%esp
80104c25:	85 c0                	test   %eax,%eax
80104c27:	78 46                	js     80104c6f <sys_exec+0xe7>
  for(i=0;; i++){
80104c29:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c2c:	eb b4                	jmp    80104be2 <sys_exec+0x5a>
      argv[i] = 0;
80104c2e:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c35:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c39:	83 ec 08             	sub    $0x8,%esp
80104c3c:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c42:	50                   	push   %eax
80104c43:	ff 75 f4             	pushl  -0xc(%ebp)
80104c46:	e8 87 bc ff ff       	call   801008d2 <exec>
80104c4b:	83 c4 10             	add    $0x10,%esp
80104c4e:	eb 1a                	jmp    80104c6a <sys_exec+0xe2>
    return -1;
80104c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c55:	eb 13                	jmp    80104c6a <sys_exec+0xe2>
80104c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c5c:	eb 0c                	jmp    80104c6a <sys_exec+0xe2>
      return -1;
80104c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c63:	eb 05                	jmp    80104c6a <sys_exec+0xe2>
      return -1;
80104c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c6d:	c9                   	leave  
80104c6e:	c3                   	ret    
      return -1;
80104c6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c74:	eb f4                	jmp    80104c6a <sys_exec+0xe2>

80104c76 <sys_pipe>:

int
sys_pipe(void)
{
80104c76:	55                   	push   %ebp
80104c77:	89 e5                	mov    %esp,%ebp
80104c79:	53                   	push   %ebx
80104c7a:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c7d:	6a 08                	push   $0x8
80104c7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c82:	50                   	push   %eax
80104c83:	6a 00                	push   $0x0
80104c85:	e8 e3 f3 ff ff       	call   8010406d <argptr>
80104c8a:	83 c4 10             	add    $0x10,%esp
80104c8d:	85 c0                	test   %eax,%eax
80104c8f:	78 77                	js     80104d08 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c91:	83 ec 08             	sub    $0x8,%esp
80104c94:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c97:	50                   	push   %eax
80104c98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c9b:	50                   	push   %eax
80104c9c:	e8 3c e2 ff ff       	call   80102edd <pipealloc>
80104ca1:	83 c4 10             	add    $0x10,%esp
80104ca4:	85 c0                	test   %eax,%eax
80104ca6:	78 67                	js     80104d0f <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cab:	e8 14 f5 ff ff       	call   801041c4 <fdalloc>
80104cb0:	89 c3                	mov    %eax,%ebx
80104cb2:	85 c0                	test   %eax,%eax
80104cb4:	78 21                	js     80104cd7 <sys_pipe+0x61>
80104cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cb9:	e8 06 f5 ff ff       	call   801041c4 <fdalloc>
80104cbe:	85 c0                	test   %eax,%eax
80104cc0:	78 15                	js     80104cd7 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc5:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cca:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104ccd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cd5:	c9                   	leave  
80104cd6:	c3                   	ret    
    if(fd0 >= 0)
80104cd7:	85 db                	test   %ebx,%ebx
80104cd9:	78 0d                	js     80104ce8 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104cdb:	e8 cc e6 ff ff       	call   801033ac <myproc>
80104ce0:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104ce7:	00 
    fileclose(rf);
80104ce8:	83 ec 0c             	sub    $0xc,%esp
80104ceb:	ff 75 f0             	pushl  -0x10(%ebp)
80104cee:	e8 ec bf ff ff       	call   80100cdf <fileclose>
    fileclose(wf);
80104cf3:	83 c4 04             	add    $0x4,%esp
80104cf6:	ff 75 ec             	pushl  -0x14(%ebp)
80104cf9:	e8 e1 bf ff ff       	call   80100cdf <fileclose>
    return -1;
80104cfe:	83 c4 10             	add    $0x10,%esp
80104d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d06:	eb ca                	jmp    80104cd2 <sys_pipe+0x5c>
    return -1;
80104d08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d0d:	eb c3                	jmp    80104cd2 <sys_pipe+0x5c>
    return -1;
80104d0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d14:	eb bc                	jmp    80104cd2 <sys_pipe+0x5c>

80104d16 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d16:	55                   	push   %ebp
80104d17:	89 e5                	mov    %esp,%ebp
80104d19:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d1c:	e8 03 e8 ff ff       	call   80103524 <fork>
}
80104d21:	c9                   	leave  
80104d22:	c3                   	ret    

80104d23 <sys_exit>:

int
sys_exit(void)
{
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d29:	e8 2d ea ff ff       	call   8010375b <exit>
  return 0;  // not reached
}
80104d2e:	b8 00 00 00 00       	mov    $0x0,%eax
80104d33:	c9                   	leave  
80104d34:	c3                   	ret    

80104d35 <sys_wait>:

int
sys_wait(void)
{
80104d35:	55                   	push   %ebp
80104d36:	89 e5                	mov    %esp,%ebp
80104d38:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d3b:	e8 a4 eb ff ff       	call   801038e4 <wait>
}
80104d40:	c9                   	leave  
80104d41:	c3                   	ret    

80104d42 <sys_kill>:

int
sys_kill(void)
{
80104d42:	55                   	push   %ebp
80104d43:	89 e5                	mov    %esp,%ebp
80104d45:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4b:	50                   	push   %eax
80104d4c:	6a 00                	push   $0x0
80104d4e:	e8 f2 f2 ff ff       	call   80104045 <argint>
80104d53:	83 c4 10             	add    $0x10,%esp
80104d56:	85 c0                	test   %eax,%eax
80104d58:	78 10                	js     80104d6a <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d5a:	83 ec 0c             	sub    $0xc,%esp
80104d5d:	ff 75 f4             	pushl  -0xc(%ebp)
80104d60:	e8 7c ec ff ff       	call   801039e1 <kill>
80104d65:	83 c4 10             	add    $0x10,%esp
}
80104d68:	c9                   	leave  
80104d69:	c3                   	ret    
    return -1;
80104d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6f:	eb f7                	jmp    80104d68 <sys_kill+0x26>

80104d71 <sys_getpid>:

int
sys_getpid(void)
{
80104d71:	55                   	push   %ebp
80104d72:	89 e5                	mov    %esp,%ebp
80104d74:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104d77:	e8 30 e6 ff ff       	call   801033ac <myproc>
80104d7c:	8b 40 10             	mov    0x10(%eax),%eax
}
80104d7f:	c9                   	leave  
80104d80:	c3                   	ret    

80104d81 <sys_sbrk>:

int
sys_sbrk(void)
{
80104d81:	55                   	push   %ebp
80104d82:	89 e5                	mov    %esp,%ebp
80104d84:	53                   	push   %ebx
80104d85:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d88:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d8b:	50                   	push   %eax
80104d8c:	6a 00                	push   $0x0
80104d8e:	e8 b2 f2 ff ff       	call   80104045 <argint>
80104d93:	83 c4 10             	add    $0x10,%esp
80104d96:	85 c0                	test   %eax,%eax
80104d98:	78 27                	js     80104dc1 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104d9a:	e8 0d e6 ff ff       	call   801033ac <myproc>
80104d9f:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104da1:	83 ec 0c             	sub    $0xc,%esp
80104da4:	ff 75 f4             	pushl  -0xc(%ebp)
80104da7:	e8 0b e7 ff ff       	call   801034b7 <growproc>
80104dac:	83 c4 10             	add    $0x10,%esp
80104daf:	85 c0                	test   %eax,%eax
80104db1:	78 07                	js     80104dba <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104db3:	89 d8                	mov    %ebx,%eax
80104db5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104db8:	c9                   	leave  
80104db9:	c3                   	ret    
    return -1;
80104dba:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dbf:	eb f2                	jmp    80104db3 <sys_sbrk+0x32>
    return -1;
80104dc1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dc6:	eb eb                	jmp    80104db3 <sys_sbrk+0x32>

80104dc8 <sys_sleep>:

int
sys_sleep(void)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	53                   	push   %ebx
80104dcc:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104dcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd2:	50                   	push   %eax
80104dd3:	6a 00                	push   $0x0
80104dd5:	e8 6b f2 ff ff       	call   80104045 <argint>
80104dda:	83 c4 10             	add    $0x10,%esp
80104ddd:	85 c0                	test   %eax,%eax
80104ddf:	78 75                	js     80104e56 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104de1:	83 ec 0c             	sub    $0xc,%esp
80104de4:	68 c0 4c 14 80       	push   $0x80144cc0
80104de9:	e8 60 ef ff ff       	call   80103d4e <acquire>
  ticks0 = ticks;
80104dee:	8b 1d 00 55 14 80    	mov    0x80145500,%ebx
  while(ticks - ticks0 < n){
80104df4:	83 c4 10             	add    $0x10,%esp
80104df7:	a1 00 55 14 80       	mov    0x80145500,%eax
80104dfc:	29 d8                	sub    %ebx,%eax
80104dfe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e01:	73 39                	jae    80104e3c <sys_sleep+0x74>
    if(myproc()->killed){
80104e03:	e8 a4 e5 ff ff       	call   801033ac <myproc>
80104e08:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e0c:	75 17                	jne    80104e25 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e0e:	83 ec 08             	sub    $0x8,%esp
80104e11:	68 c0 4c 14 80       	push   $0x80144cc0
80104e16:	68 00 55 14 80       	push   $0x80145500
80104e1b:	e8 33 ea ff ff       	call   80103853 <sleep>
80104e20:	83 c4 10             	add    $0x10,%esp
80104e23:	eb d2                	jmp    80104df7 <sys_sleep+0x2f>
      release(&tickslock);
80104e25:	83 ec 0c             	sub    $0xc,%esp
80104e28:	68 c0 4c 14 80       	push   $0x80144cc0
80104e2d:	e8 81 ef ff ff       	call   80103db3 <release>
      return -1;
80104e32:	83 c4 10             	add    $0x10,%esp
80104e35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e3a:	eb 15                	jmp    80104e51 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e3c:	83 ec 0c             	sub    $0xc,%esp
80104e3f:	68 c0 4c 14 80       	push   $0x80144cc0
80104e44:	e8 6a ef ff ff       	call   80103db3 <release>
  return 0;
80104e49:	83 c4 10             	add    $0x10,%esp
80104e4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e54:	c9                   	leave  
80104e55:	c3                   	ret    
    return -1;
80104e56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e5b:	eb f4                	jmp    80104e51 <sys_sleep+0x89>

80104e5d <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e5d:	55                   	push   %ebp
80104e5e:	89 e5                	mov    %esp,%ebp
80104e60:	53                   	push   %ebx
80104e61:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e64:	68 c0 4c 14 80       	push   $0x80144cc0
80104e69:	e8 e0 ee ff ff       	call   80103d4e <acquire>
  xticks = ticks;
80104e6e:	8b 1d 00 55 14 80    	mov    0x80145500,%ebx
  release(&tickslock);
80104e74:	c7 04 24 c0 4c 14 80 	movl   $0x80144cc0,(%esp)
80104e7b:	e8 33 ef ff ff       	call   80103db3 <release>
  return xticks;
}
80104e80:	89 d8                	mov    %ebx,%eax
80104e82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e85:	c9                   	leave  
80104e86:	c3                   	ret    

80104e87 <sys_dump_physmem>:

int
sys_dump_physmem(void) {
80104e87:	55                   	push   %ebp
80104e88:	89 e5                	mov    %esp,%ebp
80104e8a:	83 ec 1c             	sub    $0x1c,%esp
    int* frames;
    int* pids;
    int numframes;
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104e8d:	6a 04                	push   $0x4
80104e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e92:	50                   	push   %eax
80104e93:	6a 00                	push   $0x0
80104e95:	e8 d3 f1 ff ff       	call   8010406d <argptr>
80104e9a:	83 c4 10             	add    $0x10,%esp
80104e9d:	85 c0                	test   %eax,%eax
80104e9f:	78 42                	js     80104ee3 <sys_dump_physmem+0x5c>
80104ea1:	83 ec 04             	sub    $0x4,%esp
80104ea4:	6a 04                	push   $0x4
80104ea6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ea9:	50                   	push   %eax
80104eaa:	6a 01                	push   $0x1
80104eac:	e8 bc f1 ff ff       	call   8010406d <argptr>
80104eb1:	83 c4 10             	add    $0x10,%esp
80104eb4:	85 c0                	test   %eax,%eax
80104eb6:	78 32                	js     80104eea <sys_dump_physmem+0x63>
    argint(2, &numframes) < 0) {
80104eb8:	83 ec 08             	sub    $0x8,%esp
80104ebb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ebe:	50                   	push   %eax
80104ebf:	6a 02                	push   $0x2
80104ec1:	e8 7f f1 ff ff       	call   80104045 <argint>
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104ec6:	83 c4 10             	add    $0x10,%esp
80104ec9:	85 c0                	test   %eax,%eax
80104ecb:	78 24                	js     80104ef1 <sys_dump_physmem+0x6a>
        return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104ecd:	83 ec 04             	sub    $0x4,%esp
80104ed0:	ff 75 ec             	pushl  -0x14(%ebp)
80104ed3:	ff 75 f0             	pushl  -0x10(%ebp)
80104ed6:	ff 75 f4             	pushl  -0xc(%ebp)
80104ed9:	e8 73 d3 ff ff       	call   80102251 <dump_physmem>
80104ede:	83 c4 10             	add    $0x10,%esp
80104ee1:	c9                   	leave  
80104ee2:	c3                   	ret    
        return -1;
80104ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee8:	eb f7                	jmp    80104ee1 <sys_dump_physmem+0x5a>
80104eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eef:	eb f0                	jmp    80104ee1 <sys_dump_physmem+0x5a>
80104ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef6:	eb e9                	jmp    80104ee1 <sys_dump_physmem+0x5a>

80104ef8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104ef8:	1e                   	push   %ds
  pushl %es
80104ef9:	06                   	push   %es
  pushl %fs
80104efa:	0f a0                	push   %fs
  pushl %gs
80104efc:	0f a8                	push   %gs
  pushal
80104efe:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104eff:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f03:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f05:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f07:	54                   	push   %esp
  call trap
80104f08:	e8 e3 00 00 00       	call   80104ff0 <trap>
  addl $4, %esp
80104f0d:	83 c4 04             	add    $0x4,%esp

80104f10 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f10:	61                   	popa   
  popl %gs
80104f11:	0f a9                	pop    %gs
  popl %fs
80104f13:	0f a1                	pop    %fs
  popl %es
80104f15:	07                   	pop    %es
  popl %ds
80104f16:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f17:	83 c4 08             	add    $0x8,%esp
  iret
80104f1a:	cf                   	iret   

80104f1b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f1b:	55                   	push   %ebp
80104f1c:	89 e5                	mov    %esp,%ebp
80104f1e:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f21:	b8 00 00 00 00       	mov    $0x0,%eax
80104f26:	eb 4a                	jmp    80104f72 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f28:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f2f:	66 89 0c c5 00 4d 14 	mov    %cx,-0x7febb300(,%eax,8)
80104f36:	80 
80104f37:	66 c7 04 c5 02 4d 14 	movw   $0x8,-0x7febb2fe(,%eax,8)
80104f3e:	80 08 00 
80104f41:	c6 04 c5 04 4d 14 80 	movb   $0x0,-0x7febb2fc(,%eax,8)
80104f48:	00 
80104f49:	0f b6 14 c5 05 4d 14 	movzbl -0x7febb2fb(,%eax,8),%edx
80104f50:	80 
80104f51:	83 e2 f0             	and    $0xfffffff0,%edx
80104f54:	83 ca 0e             	or     $0xe,%edx
80104f57:	83 e2 8f             	and    $0xffffff8f,%edx
80104f5a:	83 ca 80             	or     $0xffffff80,%edx
80104f5d:	88 14 c5 05 4d 14 80 	mov    %dl,-0x7febb2fb(,%eax,8)
80104f64:	c1 e9 10             	shr    $0x10,%ecx
80104f67:	66 89 0c c5 06 4d 14 	mov    %cx,-0x7febb2fa(,%eax,8)
80104f6e:	80 
  for(i = 0; i < 256; i++)
80104f6f:	83 c0 01             	add    $0x1,%eax
80104f72:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f77:	7e af                	jle    80104f28 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f79:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f7f:	66 89 15 00 4f 14 80 	mov    %dx,0x80144f00
80104f86:	66 c7 05 02 4f 14 80 	movw   $0x8,0x80144f02
80104f8d:	08 00 
80104f8f:	c6 05 04 4f 14 80 00 	movb   $0x0,0x80144f04
80104f96:	0f b6 05 05 4f 14 80 	movzbl 0x80144f05,%eax
80104f9d:	83 c8 0f             	or     $0xf,%eax
80104fa0:	83 e0 ef             	and    $0xffffffef,%eax
80104fa3:	83 c8 e0             	or     $0xffffffe0,%eax
80104fa6:	a2 05 4f 14 80       	mov    %al,0x80144f05
80104fab:	c1 ea 10             	shr    $0x10,%edx
80104fae:	66 89 15 06 4f 14 80 	mov    %dx,0x80144f06

  initlock(&tickslock, "time");
80104fb5:	83 ec 08             	sub    $0x8,%esp
80104fb8:	68 1d 6e 10 80       	push   $0x80106e1d
80104fbd:	68 c0 4c 14 80       	push   $0x80144cc0
80104fc2:	e8 4b ec ff ff       	call   80103c12 <initlock>
}
80104fc7:	83 c4 10             	add    $0x10,%esp
80104fca:	c9                   	leave  
80104fcb:	c3                   	ret    

80104fcc <idtinit>:

void
idtinit(void)
{
80104fcc:	55                   	push   %ebp
80104fcd:	89 e5                	mov    %esp,%ebp
80104fcf:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104fd2:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104fd8:	b8 00 4d 14 80       	mov    $0x80144d00,%eax
80104fdd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104fe1:	c1 e8 10             	shr    $0x10,%eax
80104fe4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104fe8:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104feb:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104fee:	c9                   	leave  
80104fef:	c3                   	ret    

80104ff0 <trap>:

void
trap(struct trapframe *tf)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	57                   	push   %edi
80104ff4:	56                   	push   %esi
80104ff5:	53                   	push   %ebx
80104ff6:	83 ec 1c             	sub    $0x1c,%esp
80104ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104ffc:	8b 43 30             	mov    0x30(%ebx),%eax
80104fff:	83 f8 40             	cmp    $0x40,%eax
80105002:	74 13                	je     80105017 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105004:	83 e8 20             	sub    $0x20,%eax
80105007:	83 f8 1f             	cmp    $0x1f,%eax
8010500a:	0f 87 3a 01 00 00    	ja     8010514a <trap+0x15a>
80105010:	ff 24 85 c4 6e 10 80 	jmp    *-0x7fef913c(,%eax,4)
    if(myproc()->killed)
80105017:	e8 90 e3 ff ff       	call   801033ac <myproc>
8010501c:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105020:	75 1f                	jne    80105041 <trap+0x51>
    myproc()->tf = tf;
80105022:	e8 85 e3 ff ff       	call   801033ac <myproc>
80105027:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
8010502a:	e8 d9 f0 ff ff       	call   80104108 <syscall>
    if(myproc()->killed)
8010502f:	e8 78 e3 ff ff       	call   801033ac <myproc>
80105034:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105038:	74 7e                	je     801050b8 <trap+0xc8>
      exit();
8010503a:	e8 1c e7 ff ff       	call   8010375b <exit>
8010503f:	eb 77                	jmp    801050b8 <trap+0xc8>
      exit();
80105041:	e8 15 e7 ff ff       	call   8010375b <exit>
80105046:	eb da                	jmp    80105022 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105048:	e8 44 e3 ff ff       	call   80103391 <cpuid>
8010504d:	85 c0                	test   %eax,%eax
8010504f:	74 6f                	je     801050c0 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105051:	e8 e6 d4 ff ff       	call   8010253c <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105056:	e8 51 e3 ff ff       	call   801033ac <myproc>
8010505b:	85 c0                	test   %eax,%eax
8010505d:	74 1c                	je     8010507b <trap+0x8b>
8010505f:	e8 48 e3 ff ff       	call   801033ac <myproc>
80105064:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105068:	74 11                	je     8010507b <trap+0x8b>
8010506a:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010506e:	83 e0 03             	and    $0x3,%eax
80105071:	66 83 f8 03          	cmp    $0x3,%ax
80105075:	0f 84 62 01 00 00    	je     801051dd <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010507b:	e8 2c e3 ff ff       	call   801033ac <myproc>
80105080:	85 c0                	test   %eax,%eax
80105082:	74 0f                	je     80105093 <trap+0xa3>
80105084:	e8 23 e3 ff ff       	call   801033ac <myproc>
80105089:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010508d:	0f 84 54 01 00 00    	je     801051e7 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105093:	e8 14 e3 ff ff       	call   801033ac <myproc>
80105098:	85 c0                	test   %eax,%eax
8010509a:	74 1c                	je     801050b8 <trap+0xc8>
8010509c:	e8 0b e3 ff ff       	call   801033ac <myproc>
801050a1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050a5:	74 11                	je     801050b8 <trap+0xc8>
801050a7:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050ab:	83 e0 03             	and    $0x3,%eax
801050ae:	66 83 f8 03          	cmp    $0x3,%ax
801050b2:	0f 84 43 01 00 00    	je     801051fb <trap+0x20b>
    exit();
}
801050b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050bb:	5b                   	pop    %ebx
801050bc:	5e                   	pop    %esi
801050bd:	5f                   	pop    %edi
801050be:	5d                   	pop    %ebp
801050bf:	c3                   	ret    
      acquire(&tickslock);
801050c0:	83 ec 0c             	sub    $0xc,%esp
801050c3:	68 c0 4c 14 80       	push   $0x80144cc0
801050c8:	e8 81 ec ff ff       	call   80103d4e <acquire>
      ticks++;
801050cd:	83 05 00 55 14 80 01 	addl   $0x1,0x80145500
      wakeup(&ticks);
801050d4:	c7 04 24 00 55 14 80 	movl   $0x80145500,(%esp)
801050db:	e8 d8 e8 ff ff       	call   801039b8 <wakeup>
      release(&tickslock);
801050e0:	c7 04 24 c0 4c 14 80 	movl   $0x80144cc0,(%esp)
801050e7:	e8 c7 ec ff ff       	call   80103db3 <release>
801050ec:	83 c4 10             	add    $0x10,%esp
801050ef:	e9 5d ff ff ff       	jmp    80105051 <trap+0x61>
    ideintr();
801050f4:	e8 86 cc ff ff       	call   80101d7f <ideintr>
    lapiceoi();
801050f9:	e8 3e d4 ff ff       	call   8010253c <lapiceoi>
    break;
801050fe:	e9 53 ff ff ff       	jmp    80105056 <trap+0x66>
    kbdintr();
80105103:	e8 78 d2 ff ff       	call   80102380 <kbdintr>
    lapiceoi();
80105108:	e8 2f d4 ff ff       	call   8010253c <lapiceoi>
    break;
8010510d:	e9 44 ff ff ff       	jmp    80105056 <trap+0x66>
    uartintr();
80105112:	e8 05 02 00 00       	call   8010531c <uartintr>
    lapiceoi();
80105117:	e8 20 d4 ff ff       	call   8010253c <lapiceoi>
    break;
8010511c:	e9 35 ff ff ff       	jmp    80105056 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105121:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105124:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105128:	e8 64 e2 ff ff       	call   80103391 <cpuid>
8010512d:	57                   	push   %edi
8010512e:	0f b7 f6             	movzwl %si,%esi
80105131:	56                   	push   %esi
80105132:	50                   	push   %eax
80105133:	68 28 6e 10 80       	push   $0x80106e28
80105138:	e8 ce b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
8010513d:	e8 fa d3 ff ff       	call   8010253c <lapiceoi>
    break;
80105142:	83 c4 10             	add    $0x10,%esp
80105145:	e9 0c ff ff ff       	jmp    80105056 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010514a:	e8 5d e2 ff ff       	call   801033ac <myproc>
8010514f:	85 c0                	test   %eax,%eax
80105151:	74 5f                	je     801051b2 <trap+0x1c2>
80105153:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105157:	74 59                	je     801051b2 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105159:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010515c:	8b 43 38             	mov    0x38(%ebx),%eax
8010515f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105162:	e8 2a e2 ff ff       	call   80103391 <cpuid>
80105167:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010516a:	8b 53 34             	mov    0x34(%ebx),%edx
8010516d:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105170:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105173:	e8 34 e2 ff ff       	call   801033ac <myproc>
80105178:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010517b:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010517e:	e8 29 e2 ff ff       	call   801033ac <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105183:	57                   	push   %edi
80105184:	ff 75 e4             	pushl  -0x1c(%ebp)
80105187:	ff 75 e0             	pushl  -0x20(%ebp)
8010518a:	ff 75 dc             	pushl  -0x24(%ebp)
8010518d:	56                   	push   %esi
8010518e:	ff 75 d8             	pushl  -0x28(%ebp)
80105191:	ff 70 10             	pushl  0x10(%eax)
80105194:	68 80 6e 10 80       	push   $0x80106e80
80105199:	e8 6d b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
8010519e:	83 c4 20             	add    $0x20,%esp
801051a1:	e8 06 e2 ff ff       	call   801033ac <myproc>
801051a6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801051ad:	e9 a4 fe ff ff       	jmp    80105056 <trap+0x66>
801051b2:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801051b5:	8b 73 38             	mov    0x38(%ebx),%esi
801051b8:	e8 d4 e1 ff ff       	call   80103391 <cpuid>
801051bd:	83 ec 0c             	sub    $0xc,%esp
801051c0:	57                   	push   %edi
801051c1:	56                   	push   %esi
801051c2:	50                   	push   %eax
801051c3:	ff 73 30             	pushl  0x30(%ebx)
801051c6:	68 4c 6e 10 80       	push   $0x80106e4c
801051cb:	e8 3b b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
801051d0:	83 c4 14             	add    $0x14,%esp
801051d3:	68 22 6e 10 80       	push   $0x80106e22
801051d8:	e8 6b b1 ff ff       	call   80100348 <panic>
    exit();
801051dd:	e8 79 e5 ff ff       	call   8010375b <exit>
801051e2:	e9 94 fe ff ff       	jmp    8010507b <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801051e7:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801051eb:	0f 85 a2 fe ff ff    	jne    80105093 <trap+0xa3>
    yield();
801051f1:	e8 2b e6 ff ff       	call   80103821 <yield>
801051f6:	e9 98 fe ff ff       	jmp    80105093 <trap+0xa3>
    exit();
801051fb:	e8 5b e5 ff ff       	call   8010375b <exit>
80105200:	e9 b3 fe ff ff       	jmp    801050b8 <trap+0xc8>

80105205 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105205:	55                   	push   %ebp
80105206:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105208:	83 3d e8 a5 11 80 00 	cmpl   $0x0,0x8011a5e8
8010520f:	74 15                	je     80105226 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105211:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105216:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105217:	a8 01                	test   $0x1,%al
80105219:	74 12                	je     8010522d <uartgetc+0x28>
8010521b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105220:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105221:	0f b6 c0             	movzbl %al,%eax
}
80105224:	5d                   	pop    %ebp
80105225:	c3                   	ret    
    return -1;
80105226:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522b:	eb f7                	jmp    80105224 <uartgetc+0x1f>
    return -1;
8010522d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105232:	eb f0                	jmp    80105224 <uartgetc+0x1f>

80105234 <uartputc>:
  if(!uart)
80105234:	83 3d e8 a5 11 80 00 	cmpl   $0x0,0x8011a5e8
8010523b:	74 3b                	je     80105278 <uartputc+0x44>
{
8010523d:	55                   	push   %ebp
8010523e:	89 e5                	mov    %esp,%ebp
80105240:	53                   	push   %ebx
80105241:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105244:	bb 00 00 00 00       	mov    $0x0,%ebx
80105249:	eb 10                	jmp    8010525b <uartputc+0x27>
    microdelay(10);
8010524b:	83 ec 0c             	sub    $0xc,%esp
8010524e:	6a 0a                	push   $0xa
80105250:	e8 06 d3 ff ff       	call   8010255b <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105255:	83 c3 01             	add    $0x1,%ebx
80105258:	83 c4 10             	add    $0x10,%esp
8010525b:	83 fb 7f             	cmp    $0x7f,%ebx
8010525e:	7f 0a                	jg     8010526a <uartputc+0x36>
80105260:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105265:	ec                   	in     (%dx),%al
80105266:	a8 20                	test   $0x20,%al
80105268:	74 e1                	je     8010524b <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010526a:	8b 45 08             	mov    0x8(%ebp),%eax
8010526d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105272:	ee                   	out    %al,(%dx)
}
80105273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105276:	c9                   	leave  
80105277:	c3                   	ret    
80105278:	f3 c3                	repz ret 

8010527a <uartinit>:
{
8010527a:	55                   	push   %ebp
8010527b:	89 e5                	mov    %esp,%ebp
8010527d:	56                   	push   %esi
8010527e:	53                   	push   %ebx
8010527f:	b9 00 00 00 00       	mov    $0x0,%ecx
80105284:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105289:	89 c8                	mov    %ecx,%eax
8010528b:	ee                   	out    %al,(%dx)
8010528c:	be fb 03 00 00       	mov    $0x3fb,%esi
80105291:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105296:	89 f2                	mov    %esi,%edx
80105298:	ee                   	out    %al,(%dx)
80105299:	b8 0c 00 00 00       	mov    $0xc,%eax
8010529e:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052a3:	ee                   	out    %al,(%dx)
801052a4:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801052a9:	89 c8                	mov    %ecx,%eax
801052ab:	89 da                	mov    %ebx,%edx
801052ad:	ee                   	out    %al,(%dx)
801052ae:	b8 03 00 00 00       	mov    $0x3,%eax
801052b3:	89 f2                	mov    %esi,%edx
801052b5:	ee                   	out    %al,(%dx)
801052b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
801052bb:	89 c8                	mov    %ecx,%eax
801052bd:	ee                   	out    %al,(%dx)
801052be:	b8 01 00 00 00       	mov    $0x1,%eax
801052c3:	89 da                	mov    %ebx,%edx
801052c5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052c6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052cb:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801052cc:	3c ff                	cmp    $0xff,%al
801052ce:	74 45                	je     80105315 <uartinit+0x9b>
  uart = 1;
801052d0:	c7 05 e8 a5 11 80 01 	movl   $0x1,0x8011a5e8
801052d7:	00 00 00 
801052da:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052df:	ec                   	in     (%dx),%al
801052e0:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052e5:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801052e6:	83 ec 08             	sub    $0x8,%esp
801052e9:	6a 00                	push   $0x0
801052eb:	6a 04                	push   $0x4
801052ed:	e8 98 cc ff ff       	call   80101f8a <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801052f2:	83 c4 10             	add    $0x10,%esp
801052f5:	bb 44 6f 10 80       	mov    $0x80106f44,%ebx
801052fa:	eb 12                	jmp    8010530e <uartinit+0x94>
    uartputc(*p);
801052fc:	83 ec 0c             	sub    $0xc,%esp
801052ff:	0f be c0             	movsbl %al,%eax
80105302:	50                   	push   %eax
80105303:	e8 2c ff ff ff       	call   80105234 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105308:	83 c3 01             	add    $0x1,%ebx
8010530b:	83 c4 10             	add    $0x10,%esp
8010530e:	0f b6 03             	movzbl (%ebx),%eax
80105311:	84 c0                	test   %al,%al
80105313:	75 e7                	jne    801052fc <uartinit+0x82>
}
80105315:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105318:	5b                   	pop    %ebx
80105319:	5e                   	pop    %esi
8010531a:	5d                   	pop    %ebp
8010531b:	c3                   	ret    

8010531c <uartintr>:

void
uartintr(void)
{
8010531c:	55                   	push   %ebp
8010531d:	89 e5                	mov    %esp,%ebp
8010531f:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105322:	68 05 52 10 80       	push   $0x80105205
80105327:	e8 12 b4 ff ff       	call   8010073e <consoleintr>
}
8010532c:	83 c4 10             	add    $0x10,%esp
8010532f:	c9                   	leave  
80105330:	c3                   	ret    

80105331 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105331:	6a 00                	push   $0x0
  pushl $0
80105333:	6a 00                	push   $0x0
  jmp alltraps
80105335:	e9 be fb ff ff       	jmp    80104ef8 <alltraps>

8010533a <vector1>:
.globl vector1
vector1:
  pushl $0
8010533a:	6a 00                	push   $0x0
  pushl $1
8010533c:	6a 01                	push   $0x1
  jmp alltraps
8010533e:	e9 b5 fb ff ff       	jmp    80104ef8 <alltraps>

80105343 <vector2>:
.globl vector2
vector2:
  pushl $0
80105343:	6a 00                	push   $0x0
  pushl $2
80105345:	6a 02                	push   $0x2
  jmp alltraps
80105347:	e9 ac fb ff ff       	jmp    80104ef8 <alltraps>

8010534c <vector3>:
.globl vector3
vector3:
  pushl $0
8010534c:	6a 00                	push   $0x0
  pushl $3
8010534e:	6a 03                	push   $0x3
  jmp alltraps
80105350:	e9 a3 fb ff ff       	jmp    80104ef8 <alltraps>

80105355 <vector4>:
.globl vector4
vector4:
  pushl $0
80105355:	6a 00                	push   $0x0
  pushl $4
80105357:	6a 04                	push   $0x4
  jmp alltraps
80105359:	e9 9a fb ff ff       	jmp    80104ef8 <alltraps>

8010535e <vector5>:
.globl vector5
vector5:
  pushl $0
8010535e:	6a 00                	push   $0x0
  pushl $5
80105360:	6a 05                	push   $0x5
  jmp alltraps
80105362:	e9 91 fb ff ff       	jmp    80104ef8 <alltraps>

80105367 <vector6>:
.globl vector6
vector6:
  pushl $0
80105367:	6a 00                	push   $0x0
  pushl $6
80105369:	6a 06                	push   $0x6
  jmp alltraps
8010536b:	e9 88 fb ff ff       	jmp    80104ef8 <alltraps>

80105370 <vector7>:
.globl vector7
vector7:
  pushl $0
80105370:	6a 00                	push   $0x0
  pushl $7
80105372:	6a 07                	push   $0x7
  jmp alltraps
80105374:	e9 7f fb ff ff       	jmp    80104ef8 <alltraps>

80105379 <vector8>:
.globl vector8
vector8:
  pushl $8
80105379:	6a 08                	push   $0x8
  jmp alltraps
8010537b:	e9 78 fb ff ff       	jmp    80104ef8 <alltraps>

80105380 <vector9>:
.globl vector9
vector9:
  pushl $0
80105380:	6a 00                	push   $0x0
  pushl $9
80105382:	6a 09                	push   $0x9
  jmp alltraps
80105384:	e9 6f fb ff ff       	jmp    80104ef8 <alltraps>

80105389 <vector10>:
.globl vector10
vector10:
  pushl $10
80105389:	6a 0a                	push   $0xa
  jmp alltraps
8010538b:	e9 68 fb ff ff       	jmp    80104ef8 <alltraps>

80105390 <vector11>:
.globl vector11
vector11:
  pushl $11
80105390:	6a 0b                	push   $0xb
  jmp alltraps
80105392:	e9 61 fb ff ff       	jmp    80104ef8 <alltraps>

80105397 <vector12>:
.globl vector12
vector12:
  pushl $12
80105397:	6a 0c                	push   $0xc
  jmp alltraps
80105399:	e9 5a fb ff ff       	jmp    80104ef8 <alltraps>

8010539e <vector13>:
.globl vector13
vector13:
  pushl $13
8010539e:	6a 0d                	push   $0xd
  jmp alltraps
801053a0:	e9 53 fb ff ff       	jmp    80104ef8 <alltraps>

801053a5 <vector14>:
.globl vector14
vector14:
  pushl $14
801053a5:	6a 0e                	push   $0xe
  jmp alltraps
801053a7:	e9 4c fb ff ff       	jmp    80104ef8 <alltraps>

801053ac <vector15>:
.globl vector15
vector15:
  pushl $0
801053ac:	6a 00                	push   $0x0
  pushl $15
801053ae:	6a 0f                	push   $0xf
  jmp alltraps
801053b0:	e9 43 fb ff ff       	jmp    80104ef8 <alltraps>

801053b5 <vector16>:
.globl vector16
vector16:
  pushl $0
801053b5:	6a 00                	push   $0x0
  pushl $16
801053b7:	6a 10                	push   $0x10
  jmp alltraps
801053b9:	e9 3a fb ff ff       	jmp    80104ef8 <alltraps>

801053be <vector17>:
.globl vector17
vector17:
  pushl $17
801053be:	6a 11                	push   $0x11
  jmp alltraps
801053c0:	e9 33 fb ff ff       	jmp    80104ef8 <alltraps>

801053c5 <vector18>:
.globl vector18
vector18:
  pushl $0
801053c5:	6a 00                	push   $0x0
  pushl $18
801053c7:	6a 12                	push   $0x12
  jmp alltraps
801053c9:	e9 2a fb ff ff       	jmp    80104ef8 <alltraps>

801053ce <vector19>:
.globl vector19
vector19:
  pushl $0
801053ce:	6a 00                	push   $0x0
  pushl $19
801053d0:	6a 13                	push   $0x13
  jmp alltraps
801053d2:	e9 21 fb ff ff       	jmp    80104ef8 <alltraps>

801053d7 <vector20>:
.globl vector20
vector20:
  pushl $0
801053d7:	6a 00                	push   $0x0
  pushl $20
801053d9:	6a 14                	push   $0x14
  jmp alltraps
801053db:	e9 18 fb ff ff       	jmp    80104ef8 <alltraps>

801053e0 <vector21>:
.globl vector21
vector21:
  pushl $0
801053e0:	6a 00                	push   $0x0
  pushl $21
801053e2:	6a 15                	push   $0x15
  jmp alltraps
801053e4:	e9 0f fb ff ff       	jmp    80104ef8 <alltraps>

801053e9 <vector22>:
.globl vector22
vector22:
  pushl $0
801053e9:	6a 00                	push   $0x0
  pushl $22
801053eb:	6a 16                	push   $0x16
  jmp alltraps
801053ed:	e9 06 fb ff ff       	jmp    80104ef8 <alltraps>

801053f2 <vector23>:
.globl vector23
vector23:
  pushl $0
801053f2:	6a 00                	push   $0x0
  pushl $23
801053f4:	6a 17                	push   $0x17
  jmp alltraps
801053f6:	e9 fd fa ff ff       	jmp    80104ef8 <alltraps>

801053fb <vector24>:
.globl vector24
vector24:
  pushl $0
801053fb:	6a 00                	push   $0x0
  pushl $24
801053fd:	6a 18                	push   $0x18
  jmp alltraps
801053ff:	e9 f4 fa ff ff       	jmp    80104ef8 <alltraps>

80105404 <vector25>:
.globl vector25
vector25:
  pushl $0
80105404:	6a 00                	push   $0x0
  pushl $25
80105406:	6a 19                	push   $0x19
  jmp alltraps
80105408:	e9 eb fa ff ff       	jmp    80104ef8 <alltraps>

8010540d <vector26>:
.globl vector26
vector26:
  pushl $0
8010540d:	6a 00                	push   $0x0
  pushl $26
8010540f:	6a 1a                	push   $0x1a
  jmp alltraps
80105411:	e9 e2 fa ff ff       	jmp    80104ef8 <alltraps>

80105416 <vector27>:
.globl vector27
vector27:
  pushl $0
80105416:	6a 00                	push   $0x0
  pushl $27
80105418:	6a 1b                	push   $0x1b
  jmp alltraps
8010541a:	e9 d9 fa ff ff       	jmp    80104ef8 <alltraps>

8010541f <vector28>:
.globl vector28
vector28:
  pushl $0
8010541f:	6a 00                	push   $0x0
  pushl $28
80105421:	6a 1c                	push   $0x1c
  jmp alltraps
80105423:	e9 d0 fa ff ff       	jmp    80104ef8 <alltraps>

80105428 <vector29>:
.globl vector29
vector29:
  pushl $0
80105428:	6a 00                	push   $0x0
  pushl $29
8010542a:	6a 1d                	push   $0x1d
  jmp alltraps
8010542c:	e9 c7 fa ff ff       	jmp    80104ef8 <alltraps>

80105431 <vector30>:
.globl vector30
vector30:
  pushl $0
80105431:	6a 00                	push   $0x0
  pushl $30
80105433:	6a 1e                	push   $0x1e
  jmp alltraps
80105435:	e9 be fa ff ff       	jmp    80104ef8 <alltraps>

8010543a <vector31>:
.globl vector31
vector31:
  pushl $0
8010543a:	6a 00                	push   $0x0
  pushl $31
8010543c:	6a 1f                	push   $0x1f
  jmp alltraps
8010543e:	e9 b5 fa ff ff       	jmp    80104ef8 <alltraps>

80105443 <vector32>:
.globl vector32
vector32:
  pushl $0
80105443:	6a 00                	push   $0x0
  pushl $32
80105445:	6a 20                	push   $0x20
  jmp alltraps
80105447:	e9 ac fa ff ff       	jmp    80104ef8 <alltraps>

8010544c <vector33>:
.globl vector33
vector33:
  pushl $0
8010544c:	6a 00                	push   $0x0
  pushl $33
8010544e:	6a 21                	push   $0x21
  jmp alltraps
80105450:	e9 a3 fa ff ff       	jmp    80104ef8 <alltraps>

80105455 <vector34>:
.globl vector34
vector34:
  pushl $0
80105455:	6a 00                	push   $0x0
  pushl $34
80105457:	6a 22                	push   $0x22
  jmp alltraps
80105459:	e9 9a fa ff ff       	jmp    80104ef8 <alltraps>

8010545e <vector35>:
.globl vector35
vector35:
  pushl $0
8010545e:	6a 00                	push   $0x0
  pushl $35
80105460:	6a 23                	push   $0x23
  jmp alltraps
80105462:	e9 91 fa ff ff       	jmp    80104ef8 <alltraps>

80105467 <vector36>:
.globl vector36
vector36:
  pushl $0
80105467:	6a 00                	push   $0x0
  pushl $36
80105469:	6a 24                	push   $0x24
  jmp alltraps
8010546b:	e9 88 fa ff ff       	jmp    80104ef8 <alltraps>

80105470 <vector37>:
.globl vector37
vector37:
  pushl $0
80105470:	6a 00                	push   $0x0
  pushl $37
80105472:	6a 25                	push   $0x25
  jmp alltraps
80105474:	e9 7f fa ff ff       	jmp    80104ef8 <alltraps>

80105479 <vector38>:
.globl vector38
vector38:
  pushl $0
80105479:	6a 00                	push   $0x0
  pushl $38
8010547b:	6a 26                	push   $0x26
  jmp alltraps
8010547d:	e9 76 fa ff ff       	jmp    80104ef8 <alltraps>

80105482 <vector39>:
.globl vector39
vector39:
  pushl $0
80105482:	6a 00                	push   $0x0
  pushl $39
80105484:	6a 27                	push   $0x27
  jmp alltraps
80105486:	e9 6d fa ff ff       	jmp    80104ef8 <alltraps>

8010548b <vector40>:
.globl vector40
vector40:
  pushl $0
8010548b:	6a 00                	push   $0x0
  pushl $40
8010548d:	6a 28                	push   $0x28
  jmp alltraps
8010548f:	e9 64 fa ff ff       	jmp    80104ef8 <alltraps>

80105494 <vector41>:
.globl vector41
vector41:
  pushl $0
80105494:	6a 00                	push   $0x0
  pushl $41
80105496:	6a 29                	push   $0x29
  jmp alltraps
80105498:	e9 5b fa ff ff       	jmp    80104ef8 <alltraps>

8010549d <vector42>:
.globl vector42
vector42:
  pushl $0
8010549d:	6a 00                	push   $0x0
  pushl $42
8010549f:	6a 2a                	push   $0x2a
  jmp alltraps
801054a1:	e9 52 fa ff ff       	jmp    80104ef8 <alltraps>

801054a6 <vector43>:
.globl vector43
vector43:
  pushl $0
801054a6:	6a 00                	push   $0x0
  pushl $43
801054a8:	6a 2b                	push   $0x2b
  jmp alltraps
801054aa:	e9 49 fa ff ff       	jmp    80104ef8 <alltraps>

801054af <vector44>:
.globl vector44
vector44:
  pushl $0
801054af:	6a 00                	push   $0x0
  pushl $44
801054b1:	6a 2c                	push   $0x2c
  jmp alltraps
801054b3:	e9 40 fa ff ff       	jmp    80104ef8 <alltraps>

801054b8 <vector45>:
.globl vector45
vector45:
  pushl $0
801054b8:	6a 00                	push   $0x0
  pushl $45
801054ba:	6a 2d                	push   $0x2d
  jmp alltraps
801054bc:	e9 37 fa ff ff       	jmp    80104ef8 <alltraps>

801054c1 <vector46>:
.globl vector46
vector46:
  pushl $0
801054c1:	6a 00                	push   $0x0
  pushl $46
801054c3:	6a 2e                	push   $0x2e
  jmp alltraps
801054c5:	e9 2e fa ff ff       	jmp    80104ef8 <alltraps>

801054ca <vector47>:
.globl vector47
vector47:
  pushl $0
801054ca:	6a 00                	push   $0x0
  pushl $47
801054cc:	6a 2f                	push   $0x2f
  jmp alltraps
801054ce:	e9 25 fa ff ff       	jmp    80104ef8 <alltraps>

801054d3 <vector48>:
.globl vector48
vector48:
  pushl $0
801054d3:	6a 00                	push   $0x0
  pushl $48
801054d5:	6a 30                	push   $0x30
  jmp alltraps
801054d7:	e9 1c fa ff ff       	jmp    80104ef8 <alltraps>

801054dc <vector49>:
.globl vector49
vector49:
  pushl $0
801054dc:	6a 00                	push   $0x0
  pushl $49
801054de:	6a 31                	push   $0x31
  jmp alltraps
801054e0:	e9 13 fa ff ff       	jmp    80104ef8 <alltraps>

801054e5 <vector50>:
.globl vector50
vector50:
  pushl $0
801054e5:	6a 00                	push   $0x0
  pushl $50
801054e7:	6a 32                	push   $0x32
  jmp alltraps
801054e9:	e9 0a fa ff ff       	jmp    80104ef8 <alltraps>

801054ee <vector51>:
.globl vector51
vector51:
  pushl $0
801054ee:	6a 00                	push   $0x0
  pushl $51
801054f0:	6a 33                	push   $0x33
  jmp alltraps
801054f2:	e9 01 fa ff ff       	jmp    80104ef8 <alltraps>

801054f7 <vector52>:
.globl vector52
vector52:
  pushl $0
801054f7:	6a 00                	push   $0x0
  pushl $52
801054f9:	6a 34                	push   $0x34
  jmp alltraps
801054fb:	e9 f8 f9 ff ff       	jmp    80104ef8 <alltraps>

80105500 <vector53>:
.globl vector53
vector53:
  pushl $0
80105500:	6a 00                	push   $0x0
  pushl $53
80105502:	6a 35                	push   $0x35
  jmp alltraps
80105504:	e9 ef f9 ff ff       	jmp    80104ef8 <alltraps>

80105509 <vector54>:
.globl vector54
vector54:
  pushl $0
80105509:	6a 00                	push   $0x0
  pushl $54
8010550b:	6a 36                	push   $0x36
  jmp alltraps
8010550d:	e9 e6 f9 ff ff       	jmp    80104ef8 <alltraps>

80105512 <vector55>:
.globl vector55
vector55:
  pushl $0
80105512:	6a 00                	push   $0x0
  pushl $55
80105514:	6a 37                	push   $0x37
  jmp alltraps
80105516:	e9 dd f9 ff ff       	jmp    80104ef8 <alltraps>

8010551b <vector56>:
.globl vector56
vector56:
  pushl $0
8010551b:	6a 00                	push   $0x0
  pushl $56
8010551d:	6a 38                	push   $0x38
  jmp alltraps
8010551f:	e9 d4 f9 ff ff       	jmp    80104ef8 <alltraps>

80105524 <vector57>:
.globl vector57
vector57:
  pushl $0
80105524:	6a 00                	push   $0x0
  pushl $57
80105526:	6a 39                	push   $0x39
  jmp alltraps
80105528:	e9 cb f9 ff ff       	jmp    80104ef8 <alltraps>

8010552d <vector58>:
.globl vector58
vector58:
  pushl $0
8010552d:	6a 00                	push   $0x0
  pushl $58
8010552f:	6a 3a                	push   $0x3a
  jmp alltraps
80105531:	e9 c2 f9 ff ff       	jmp    80104ef8 <alltraps>

80105536 <vector59>:
.globl vector59
vector59:
  pushl $0
80105536:	6a 00                	push   $0x0
  pushl $59
80105538:	6a 3b                	push   $0x3b
  jmp alltraps
8010553a:	e9 b9 f9 ff ff       	jmp    80104ef8 <alltraps>

8010553f <vector60>:
.globl vector60
vector60:
  pushl $0
8010553f:	6a 00                	push   $0x0
  pushl $60
80105541:	6a 3c                	push   $0x3c
  jmp alltraps
80105543:	e9 b0 f9 ff ff       	jmp    80104ef8 <alltraps>

80105548 <vector61>:
.globl vector61
vector61:
  pushl $0
80105548:	6a 00                	push   $0x0
  pushl $61
8010554a:	6a 3d                	push   $0x3d
  jmp alltraps
8010554c:	e9 a7 f9 ff ff       	jmp    80104ef8 <alltraps>

80105551 <vector62>:
.globl vector62
vector62:
  pushl $0
80105551:	6a 00                	push   $0x0
  pushl $62
80105553:	6a 3e                	push   $0x3e
  jmp alltraps
80105555:	e9 9e f9 ff ff       	jmp    80104ef8 <alltraps>

8010555a <vector63>:
.globl vector63
vector63:
  pushl $0
8010555a:	6a 00                	push   $0x0
  pushl $63
8010555c:	6a 3f                	push   $0x3f
  jmp alltraps
8010555e:	e9 95 f9 ff ff       	jmp    80104ef8 <alltraps>

80105563 <vector64>:
.globl vector64
vector64:
  pushl $0
80105563:	6a 00                	push   $0x0
  pushl $64
80105565:	6a 40                	push   $0x40
  jmp alltraps
80105567:	e9 8c f9 ff ff       	jmp    80104ef8 <alltraps>

8010556c <vector65>:
.globl vector65
vector65:
  pushl $0
8010556c:	6a 00                	push   $0x0
  pushl $65
8010556e:	6a 41                	push   $0x41
  jmp alltraps
80105570:	e9 83 f9 ff ff       	jmp    80104ef8 <alltraps>

80105575 <vector66>:
.globl vector66
vector66:
  pushl $0
80105575:	6a 00                	push   $0x0
  pushl $66
80105577:	6a 42                	push   $0x42
  jmp alltraps
80105579:	e9 7a f9 ff ff       	jmp    80104ef8 <alltraps>

8010557e <vector67>:
.globl vector67
vector67:
  pushl $0
8010557e:	6a 00                	push   $0x0
  pushl $67
80105580:	6a 43                	push   $0x43
  jmp alltraps
80105582:	e9 71 f9 ff ff       	jmp    80104ef8 <alltraps>

80105587 <vector68>:
.globl vector68
vector68:
  pushl $0
80105587:	6a 00                	push   $0x0
  pushl $68
80105589:	6a 44                	push   $0x44
  jmp alltraps
8010558b:	e9 68 f9 ff ff       	jmp    80104ef8 <alltraps>

80105590 <vector69>:
.globl vector69
vector69:
  pushl $0
80105590:	6a 00                	push   $0x0
  pushl $69
80105592:	6a 45                	push   $0x45
  jmp alltraps
80105594:	e9 5f f9 ff ff       	jmp    80104ef8 <alltraps>

80105599 <vector70>:
.globl vector70
vector70:
  pushl $0
80105599:	6a 00                	push   $0x0
  pushl $70
8010559b:	6a 46                	push   $0x46
  jmp alltraps
8010559d:	e9 56 f9 ff ff       	jmp    80104ef8 <alltraps>

801055a2 <vector71>:
.globl vector71
vector71:
  pushl $0
801055a2:	6a 00                	push   $0x0
  pushl $71
801055a4:	6a 47                	push   $0x47
  jmp alltraps
801055a6:	e9 4d f9 ff ff       	jmp    80104ef8 <alltraps>

801055ab <vector72>:
.globl vector72
vector72:
  pushl $0
801055ab:	6a 00                	push   $0x0
  pushl $72
801055ad:	6a 48                	push   $0x48
  jmp alltraps
801055af:	e9 44 f9 ff ff       	jmp    80104ef8 <alltraps>

801055b4 <vector73>:
.globl vector73
vector73:
  pushl $0
801055b4:	6a 00                	push   $0x0
  pushl $73
801055b6:	6a 49                	push   $0x49
  jmp alltraps
801055b8:	e9 3b f9 ff ff       	jmp    80104ef8 <alltraps>

801055bd <vector74>:
.globl vector74
vector74:
  pushl $0
801055bd:	6a 00                	push   $0x0
  pushl $74
801055bf:	6a 4a                	push   $0x4a
  jmp alltraps
801055c1:	e9 32 f9 ff ff       	jmp    80104ef8 <alltraps>

801055c6 <vector75>:
.globl vector75
vector75:
  pushl $0
801055c6:	6a 00                	push   $0x0
  pushl $75
801055c8:	6a 4b                	push   $0x4b
  jmp alltraps
801055ca:	e9 29 f9 ff ff       	jmp    80104ef8 <alltraps>

801055cf <vector76>:
.globl vector76
vector76:
  pushl $0
801055cf:	6a 00                	push   $0x0
  pushl $76
801055d1:	6a 4c                	push   $0x4c
  jmp alltraps
801055d3:	e9 20 f9 ff ff       	jmp    80104ef8 <alltraps>

801055d8 <vector77>:
.globl vector77
vector77:
  pushl $0
801055d8:	6a 00                	push   $0x0
  pushl $77
801055da:	6a 4d                	push   $0x4d
  jmp alltraps
801055dc:	e9 17 f9 ff ff       	jmp    80104ef8 <alltraps>

801055e1 <vector78>:
.globl vector78
vector78:
  pushl $0
801055e1:	6a 00                	push   $0x0
  pushl $78
801055e3:	6a 4e                	push   $0x4e
  jmp alltraps
801055e5:	e9 0e f9 ff ff       	jmp    80104ef8 <alltraps>

801055ea <vector79>:
.globl vector79
vector79:
  pushl $0
801055ea:	6a 00                	push   $0x0
  pushl $79
801055ec:	6a 4f                	push   $0x4f
  jmp alltraps
801055ee:	e9 05 f9 ff ff       	jmp    80104ef8 <alltraps>

801055f3 <vector80>:
.globl vector80
vector80:
  pushl $0
801055f3:	6a 00                	push   $0x0
  pushl $80
801055f5:	6a 50                	push   $0x50
  jmp alltraps
801055f7:	e9 fc f8 ff ff       	jmp    80104ef8 <alltraps>

801055fc <vector81>:
.globl vector81
vector81:
  pushl $0
801055fc:	6a 00                	push   $0x0
  pushl $81
801055fe:	6a 51                	push   $0x51
  jmp alltraps
80105600:	e9 f3 f8 ff ff       	jmp    80104ef8 <alltraps>

80105605 <vector82>:
.globl vector82
vector82:
  pushl $0
80105605:	6a 00                	push   $0x0
  pushl $82
80105607:	6a 52                	push   $0x52
  jmp alltraps
80105609:	e9 ea f8 ff ff       	jmp    80104ef8 <alltraps>

8010560e <vector83>:
.globl vector83
vector83:
  pushl $0
8010560e:	6a 00                	push   $0x0
  pushl $83
80105610:	6a 53                	push   $0x53
  jmp alltraps
80105612:	e9 e1 f8 ff ff       	jmp    80104ef8 <alltraps>

80105617 <vector84>:
.globl vector84
vector84:
  pushl $0
80105617:	6a 00                	push   $0x0
  pushl $84
80105619:	6a 54                	push   $0x54
  jmp alltraps
8010561b:	e9 d8 f8 ff ff       	jmp    80104ef8 <alltraps>

80105620 <vector85>:
.globl vector85
vector85:
  pushl $0
80105620:	6a 00                	push   $0x0
  pushl $85
80105622:	6a 55                	push   $0x55
  jmp alltraps
80105624:	e9 cf f8 ff ff       	jmp    80104ef8 <alltraps>

80105629 <vector86>:
.globl vector86
vector86:
  pushl $0
80105629:	6a 00                	push   $0x0
  pushl $86
8010562b:	6a 56                	push   $0x56
  jmp alltraps
8010562d:	e9 c6 f8 ff ff       	jmp    80104ef8 <alltraps>

80105632 <vector87>:
.globl vector87
vector87:
  pushl $0
80105632:	6a 00                	push   $0x0
  pushl $87
80105634:	6a 57                	push   $0x57
  jmp alltraps
80105636:	e9 bd f8 ff ff       	jmp    80104ef8 <alltraps>

8010563b <vector88>:
.globl vector88
vector88:
  pushl $0
8010563b:	6a 00                	push   $0x0
  pushl $88
8010563d:	6a 58                	push   $0x58
  jmp alltraps
8010563f:	e9 b4 f8 ff ff       	jmp    80104ef8 <alltraps>

80105644 <vector89>:
.globl vector89
vector89:
  pushl $0
80105644:	6a 00                	push   $0x0
  pushl $89
80105646:	6a 59                	push   $0x59
  jmp alltraps
80105648:	e9 ab f8 ff ff       	jmp    80104ef8 <alltraps>

8010564d <vector90>:
.globl vector90
vector90:
  pushl $0
8010564d:	6a 00                	push   $0x0
  pushl $90
8010564f:	6a 5a                	push   $0x5a
  jmp alltraps
80105651:	e9 a2 f8 ff ff       	jmp    80104ef8 <alltraps>

80105656 <vector91>:
.globl vector91
vector91:
  pushl $0
80105656:	6a 00                	push   $0x0
  pushl $91
80105658:	6a 5b                	push   $0x5b
  jmp alltraps
8010565a:	e9 99 f8 ff ff       	jmp    80104ef8 <alltraps>

8010565f <vector92>:
.globl vector92
vector92:
  pushl $0
8010565f:	6a 00                	push   $0x0
  pushl $92
80105661:	6a 5c                	push   $0x5c
  jmp alltraps
80105663:	e9 90 f8 ff ff       	jmp    80104ef8 <alltraps>

80105668 <vector93>:
.globl vector93
vector93:
  pushl $0
80105668:	6a 00                	push   $0x0
  pushl $93
8010566a:	6a 5d                	push   $0x5d
  jmp alltraps
8010566c:	e9 87 f8 ff ff       	jmp    80104ef8 <alltraps>

80105671 <vector94>:
.globl vector94
vector94:
  pushl $0
80105671:	6a 00                	push   $0x0
  pushl $94
80105673:	6a 5e                	push   $0x5e
  jmp alltraps
80105675:	e9 7e f8 ff ff       	jmp    80104ef8 <alltraps>

8010567a <vector95>:
.globl vector95
vector95:
  pushl $0
8010567a:	6a 00                	push   $0x0
  pushl $95
8010567c:	6a 5f                	push   $0x5f
  jmp alltraps
8010567e:	e9 75 f8 ff ff       	jmp    80104ef8 <alltraps>

80105683 <vector96>:
.globl vector96
vector96:
  pushl $0
80105683:	6a 00                	push   $0x0
  pushl $96
80105685:	6a 60                	push   $0x60
  jmp alltraps
80105687:	e9 6c f8 ff ff       	jmp    80104ef8 <alltraps>

8010568c <vector97>:
.globl vector97
vector97:
  pushl $0
8010568c:	6a 00                	push   $0x0
  pushl $97
8010568e:	6a 61                	push   $0x61
  jmp alltraps
80105690:	e9 63 f8 ff ff       	jmp    80104ef8 <alltraps>

80105695 <vector98>:
.globl vector98
vector98:
  pushl $0
80105695:	6a 00                	push   $0x0
  pushl $98
80105697:	6a 62                	push   $0x62
  jmp alltraps
80105699:	e9 5a f8 ff ff       	jmp    80104ef8 <alltraps>

8010569e <vector99>:
.globl vector99
vector99:
  pushl $0
8010569e:	6a 00                	push   $0x0
  pushl $99
801056a0:	6a 63                	push   $0x63
  jmp alltraps
801056a2:	e9 51 f8 ff ff       	jmp    80104ef8 <alltraps>

801056a7 <vector100>:
.globl vector100
vector100:
  pushl $0
801056a7:	6a 00                	push   $0x0
  pushl $100
801056a9:	6a 64                	push   $0x64
  jmp alltraps
801056ab:	e9 48 f8 ff ff       	jmp    80104ef8 <alltraps>

801056b0 <vector101>:
.globl vector101
vector101:
  pushl $0
801056b0:	6a 00                	push   $0x0
  pushl $101
801056b2:	6a 65                	push   $0x65
  jmp alltraps
801056b4:	e9 3f f8 ff ff       	jmp    80104ef8 <alltraps>

801056b9 <vector102>:
.globl vector102
vector102:
  pushl $0
801056b9:	6a 00                	push   $0x0
  pushl $102
801056bb:	6a 66                	push   $0x66
  jmp alltraps
801056bd:	e9 36 f8 ff ff       	jmp    80104ef8 <alltraps>

801056c2 <vector103>:
.globl vector103
vector103:
  pushl $0
801056c2:	6a 00                	push   $0x0
  pushl $103
801056c4:	6a 67                	push   $0x67
  jmp alltraps
801056c6:	e9 2d f8 ff ff       	jmp    80104ef8 <alltraps>

801056cb <vector104>:
.globl vector104
vector104:
  pushl $0
801056cb:	6a 00                	push   $0x0
  pushl $104
801056cd:	6a 68                	push   $0x68
  jmp alltraps
801056cf:	e9 24 f8 ff ff       	jmp    80104ef8 <alltraps>

801056d4 <vector105>:
.globl vector105
vector105:
  pushl $0
801056d4:	6a 00                	push   $0x0
  pushl $105
801056d6:	6a 69                	push   $0x69
  jmp alltraps
801056d8:	e9 1b f8 ff ff       	jmp    80104ef8 <alltraps>

801056dd <vector106>:
.globl vector106
vector106:
  pushl $0
801056dd:	6a 00                	push   $0x0
  pushl $106
801056df:	6a 6a                	push   $0x6a
  jmp alltraps
801056e1:	e9 12 f8 ff ff       	jmp    80104ef8 <alltraps>

801056e6 <vector107>:
.globl vector107
vector107:
  pushl $0
801056e6:	6a 00                	push   $0x0
  pushl $107
801056e8:	6a 6b                	push   $0x6b
  jmp alltraps
801056ea:	e9 09 f8 ff ff       	jmp    80104ef8 <alltraps>

801056ef <vector108>:
.globl vector108
vector108:
  pushl $0
801056ef:	6a 00                	push   $0x0
  pushl $108
801056f1:	6a 6c                	push   $0x6c
  jmp alltraps
801056f3:	e9 00 f8 ff ff       	jmp    80104ef8 <alltraps>

801056f8 <vector109>:
.globl vector109
vector109:
  pushl $0
801056f8:	6a 00                	push   $0x0
  pushl $109
801056fa:	6a 6d                	push   $0x6d
  jmp alltraps
801056fc:	e9 f7 f7 ff ff       	jmp    80104ef8 <alltraps>

80105701 <vector110>:
.globl vector110
vector110:
  pushl $0
80105701:	6a 00                	push   $0x0
  pushl $110
80105703:	6a 6e                	push   $0x6e
  jmp alltraps
80105705:	e9 ee f7 ff ff       	jmp    80104ef8 <alltraps>

8010570a <vector111>:
.globl vector111
vector111:
  pushl $0
8010570a:	6a 00                	push   $0x0
  pushl $111
8010570c:	6a 6f                	push   $0x6f
  jmp alltraps
8010570e:	e9 e5 f7 ff ff       	jmp    80104ef8 <alltraps>

80105713 <vector112>:
.globl vector112
vector112:
  pushl $0
80105713:	6a 00                	push   $0x0
  pushl $112
80105715:	6a 70                	push   $0x70
  jmp alltraps
80105717:	e9 dc f7 ff ff       	jmp    80104ef8 <alltraps>

8010571c <vector113>:
.globl vector113
vector113:
  pushl $0
8010571c:	6a 00                	push   $0x0
  pushl $113
8010571e:	6a 71                	push   $0x71
  jmp alltraps
80105720:	e9 d3 f7 ff ff       	jmp    80104ef8 <alltraps>

80105725 <vector114>:
.globl vector114
vector114:
  pushl $0
80105725:	6a 00                	push   $0x0
  pushl $114
80105727:	6a 72                	push   $0x72
  jmp alltraps
80105729:	e9 ca f7 ff ff       	jmp    80104ef8 <alltraps>

8010572e <vector115>:
.globl vector115
vector115:
  pushl $0
8010572e:	6a 00                	push   $0x0
  pushl $115
80105730:	6a 73                	push   $0x73
  jmp alltraps
80105732:	e9 c1 f7 ff ff       	jmp    80104ef8 <alltraps>

80105737 <vector116>:
.globl vector116
vector116:
  pushl $0
80105737:	6a 00                	push   $0x0
  pushl $116
80105739:	6a 74                	push   $0x74
  jmp alltraps
8010573b:	e9 b8 f7 ff ff       	jmp    80104ef8 <alltraps>

80105740 <vector117>:
.globl vector117
vector117:
  pushl $0
80105740:	6a 00                	push   $0x0
  pushl $117
80105742:	6a 75                	push   $0x75
  jmp alltraps
80105744:	e9 af f7 ff ff       	jmp    80104ef8 <alltraps>

80105749 <vector118>:
.globl vector118
vector118:
  pushl $0
80105749:	6a 00                	push   $0x0
  pushl $118
8010574b:	6a 76                	push   $0x76
  jmp alltraps
8010574d:	e9 a6 f7 ff ff       	jmp    80104ef8 <alltraps>

80105752 <vector119>:
.globl vector119
vector119:
  pushl $0
80105752:	6a 00                	push   $0x0
  pushl $119
80105754:	6a 77                	push   $0x77
  jmp alltraps
80105756:	e9 9d f7 ff ff       	jmp    80104ef8 <alltraps>

8010575b <vector120>:
.globl vector120
vector120:
  pushl $0
8010575b:	6a 00                	push   $0x0
  pushl $120
8010575d:	6a 78                	push   $0x78
  jmp alltraps
8010575f:	e9 94 f7 ff ff       	jmp    80104ef8 <alltraps>

80105764 <vector121>:
.globl vector121
vector121:
  pushl $0
80105764:	6a 00                	push   $0x0
  pushl $121
80105766:	6a 79                	push   $0x79
  jmp alltraps
80105768:	e9 8b f7 ff ff       	jmp    80104ef8 <alltraps>

8010576d <vector122>:
.globl vector122
vector122:
  pushl $0
8010576d:	6a 00                	push   $0x0
  pushl $122
8010576f:	6a 7a                	push   $0x7a
  jmp alltraps
80105771:	e9 82 f7 ff ff       	jmp    80104ef8 <alltraps>

80105776 <vector123>:
.globl vector123
vector123:
  pushl $0
80105776:	6a 00                	push   $0x0
  pushl $123
80105778:	6a 7b                	push   $0x7b
  jmp alltraps
8010577a:	e9 79 f7 ff ff       	jmp    80104ef8 <alltraps>

8010577f <vector124>:
.globl vector124
vector124:
  pushl $0
8010577f:	6a 00                	push   $0x0
  pushl $124
80105781:	6a 7c                	push   $0x7c
  jmp alltraps
80105783:	e9 70 f7 ff ff       	jmp    80104ef8 <alltraps>

80105788 <vector125>:
.globl vector125
vector125:
  pushl $0
80105788:	6a 00                	push   $0x0
  pushl $125
8010578a:	6a 7d                	push   $0x7d
  jmp alltraps
8010578c:	e9 67 f7 ff ff       	jmp    80104ef8 <alltraps>

80105791 <vector126>:
.globl vector126
vector126:
  pushl $0
80105791:	6a 00                	push   $0x0
  pushl $126
80105793:	6a 7e                	push   $0x7e
  jmp alltraps
80105795:	e9 5e f7 ff ff       	jmp    80104ef8 <alltraps>

8010579a <vector127>:
.globl vector127
vector127:
  pushl $0
8010579a:	6a 00                	push   $0x0
  pushl $127
8010579c:	6a 7f                	push   $0x7f
  jmp alltraps
8010579e:	e9 55 f7 ff ff       	jmp    80104ef8 <alltraps>

801057a3 <vector128>:
.globl vector128
vector128:
  pushl $0
801057a3:	6a 00                	push   $0x0
  pushl $128
801057a5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801057aa:	e9 49 f7 ff ff       	jmp    80104ef8 <alltraps>

801057af <vector129>:
.globl vector129
vector129:
  pushl $0
801057af:	6a 00                	push   $0x0
  pushl $129
801057b1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801057b6:	e9 3d f7 ff ff       	jmp    80104ef8 <alltraps>

801057bb <vector130>:
.globl vector130
vector130:
  pushl $0
801057bb:	6a 00                	push   $0x0
  pushl $130
801057bd:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801057c2:	e9 31 f7 ff ff       	jmp    80104ef8 <alltraps>

801057c7 <vector131>:
.globl vector131
vector131:
  pushl $0
801057c7:	6a 00                	push   $0x0
  pushl $131
801057c9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801057ce:	e9 25 f7 ff ff       	jmp    80104ef8 <alltraps>

801057d3 <vector132>:
.globl vector132
vector132:
  pushl $0
801057d3:	6a 00                	push   $0x0
  pushl $132
801057d5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801057da:	e9 19 f7 ff ff       	jmp    80104ef8 <alltraps>

801057df <vector133>:
.globl vector133
vector133:
  pushl $0
801057df:	6a 00                	push   $0x0
  pushl $133
801057e1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801057e6:	e9 0d f7 ff ff       	jmp    80104ef8 <alltraps>

801057eb <vector134>:
.globl vector134
vector134:
  pushl $0
801057eb:	6a 00                	push   $0x0
  pushl $134
801057ed:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801057f2:	e9 01 f7 ff ff       	jmp    80104ef8 <alltraps>

801057f7 <vector135>:
.globl vector135
vector135:
  pushl $0
801057f7:	6a 00                	push   $0x0
  pushl $135
801057f9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057fe:	e9 f5 f6 ff ff       	jmp    80104ef8 <alltraps>

80105803 <vector136>:
.globl vector136
vector136:
  pushl $0
80105803:	6a 00                	push   $0x0
  pushl $136
80105805:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010580a:	e9 e9 f6 ff ff       	jmp    80104ef8 <alltraps>

8010580f <vector137>:
.globl vector137
vector137:
  pushl $0
8010580f:	6a 00                	push   $0x0
  pushl $137
80105811:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105816:	e9 dd f6 ff ff       	jmp    80104ef8 <alltraps>

8010581b <vector138>:
.globl vector138
vector138:
  pushl $0
8010581b:	6a 00                	push   $0x0
  pushl $138
8010581d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105822:	e9 d1 f6 ff ff       	jmp    80104ef8 <alltraps>

80105827 <vector139>:
.globl vector139
vector139:
  pushl $0
80105827:	6a 00                	push   $0x0
  pushl $139
80105829:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010582e:	e9 c5 f6 ff ff       	jmp    80104ef8 <alltraps>

80105833 <vector140>:
.globl vector140
vector140:
  pushl $0
80105833:	6a 00                	push   $0x0
  pushl $140
80105835:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010583a:	e9 b9 f6 ff ff       	jmp    80104ef8 <alltraps>

8010583f <vector141>:
.globl vector141
vector141:
  pushl $0
8010583f:	6a 00                	push   $0x0
  pushl $141
80105841:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105846:	e9 ad f6 ff ff       	jmp    80104ef8 <alltraps>

8010584b <vector142>:
.globl vector142
vector142:
  pushl $0
8010584b:	6a 00                	push   $0x0
  pushl $142
8010584d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105852:	e9 a1 f6 ff ff       	jmp    80104ef8 <alltraps>

80105857 <vector143>:
.globl vector143
vector143:
  pushl $0
80105857:	6a 00                	push   $0x0
  pushl $143
80105859:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010585e:	e9 95 f6 ff ff       	jmp    80104ef8 <alltraps>

80105863 <vector144>:
.globl vector144
vector144:
  pushl $0
80105863:	6a 00                	push   $0x0
  pushl $144
80105865:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010586a:	e9 89 f6 ff ff       	jmp    80104ef8 <alltraps>

8010586f <vector145>:
.globl vector145
vector145:
  pushl $0
8010586f:	6a 00                	push   $0x0
  pushl $145
80105871:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105876:	e9 7d f6 ff ff       	jmp    80104ef8 <alltraps>

8010587b <vector146>:
.globl vector146
vector146:
  pushl $0
8010587b:	6a 00                	push   $0x0
  pushl $146
8010587d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105882:	e9 71 f6 ff ff       	jmp    80104ef8 <alltraps>

80105887 <vector147>:
.globl vector147
vector147:
  pushl $0
80105887:	6a 00                	push   $0x0
  pushl $147
80105889:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010588e:	e9 65 f6 ff ff       	jmp    80104ef8 <alltraps>

80105893 <vector148>:
.globl vector148
vector148:
  pushl $0
80105893:	6a 00                	push   $0x0
  pushl $148
80105895:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010589a:	e9 59 f6 ff ff       	jmp    80104ef8 <alltraps>

8010589f <vector149>:
.globl vector149
vector149:
  pushl $0
8010589f:	6a 00                	push   $0x0
  pushl $149
801058a1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801058a6:	e9 4d f6 ff ff       	jmp    80104ef8 <alltraps>

801058ab <vector150>:
.globl vector150
vector150:
  pushl $0
801058ab:	6a 00                	push   $0x0
  pushl $150
801058ad:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801058b2:	e9 41 f6 ff ff       	jmp    80104ef8 <alltraps>

801058b7 <vector151>:
.globl vector151
vector151:
  pushl $0
801058b7:	6a 00                	push   $0x0
  pushl $151
801058b9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801058be:	e9 35 f6 ff ff       	jmp    80104ef8 <alltraps>

801058c3 <vector152>:
.globl vector152
vector152:
  pushl $0
801058c3:	6a 00                	push   $0x0
  pushl $152
801058c5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801058ca:	e9 29 f6 ff ff       	jmp    80104ef8 <alltraps>

801058cf <vector153>:
.globl vector153
vector153:
  pushl $0
801058cf:	6a 00                	push   $0x0
  pushl $153
801058d1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801058d6:	e9 1d f6 ff ff       	jmp    80104ef8 <alltraps>

801058db <vector154>:
.globl vector154
vector154:
  pushl $0
801058db:	6a 00                	push   $0x0
  pushl $154
801058dd:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801058e2:	e9 11 f6 ff ff       	jmp    80104ef8 <alltraps>

801058e7 <vector155>:
.globl vector155
vector155:
  pushl $0
801058e7:	6a 00                	push   $0x0
  pushl $155
801058e9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801058ee:	e9 05 f6 ff ff       	jmp    80104ef8 <alltraps>

801058f3 <vector156>:
.globl vector156
vector156:
  pushl $0
801058f3:	6a 00                	push   $0x0
  pushl $156
801058f5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801058fa:	e9 f9 f5 ff ff       	jmp    80104ef8 <alltraps>

801058ff <vector157>:
.globl vector157
vector157:
  pushl $0
801058ff:	6a 00                	push   $0x0
  pushl $157
80105901:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105906:	e9 ed f5 ff ff       	jmp    80104ef8 <alltraps>

8010590b <vector158>:
.globl vector158
vector158:
  pushl $0
8010590b:	6a 00                	push   $0x0
  pushl $158
8010590d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105912:	e9 e1 f5 ff ff       	jmp    80104ef8 <alltraps>

80105917 <vector159>:
.globl vector159
vector159:
  pushl $0
80105917:	6a 00                	push   $0x0
  pushl $159
80105919:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010591e:	e9 d5 f5 ff ff       	jmp    80104ef8 <alltraps>

80105923 <vector160>:
.globl vector160
vector160:
  pushl $0
80105923:	6a 00                	push   $0x0
  pushl $160
80105925:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010592a:	e9 c9 f5 ff ff       	jmp    80104ef8 <alltraps>

8010592f <vector161>:
.globl vector161
vector161:
  pushl $0
8010592f:	6a 00                	push   $0x0
  pushl $161
80105931:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105936:	e9 bd f5 ff ff       	jmp    80104ef8 <alltraps>

8010593b <vector162>:
.globl vector162
vector162:
  pushl $0
8010593b:	6a 00                	push   $0x0
  pushl $162
8010593d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105942:	e9 b1 f5 ff ff       	jmp    80104ef8 <alltraps>

80105947 <vector163>:
.globl vector163
vector163:
  pushl $0
80105947:	6a 00                	push   $0x0
  pushl $163
80105949:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010594e:	e9 a5 f5 ff ff       	jmp    80104ef8 <alltraps>

80105953 <vector164>:
.globl vector164
vector164:
  pushl $0
80105953:	6a 00                	push   $0x0
  pushl $164
80105955:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010595a:	e9 99 f5 ff ff       	jmp    80104ef8 <alltraps>

8010595f <vector165>:
.globl vector165
vector165:
  pushl $0
8010595f:	6a 00                	push   $0x0
  pushl $165
80105961:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105966:	e9 8d f5 ff ff       	jmp    80104ef8 <alltraps>

8010596b <vector166>:
.globl vector166
vector166:
  pushl $0
8010596b:	6a 00                	push   $0x0
  pushl $166
8010596d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105972:	e9 81 f5 ff ff       	jmp    80104ef8 <alltraps>

80105977 <vector167>:
.globl vector167
vector167:
  pushl $0
80105977:	6a 00                	push   $0x0
  pushl $167
80105979:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010597e:	e9 75 f5 ff ff       	jmp    80104ef8 <alltraps>

80105983 <vector168>:
.globl vector168
vector168:
  pushl $0
80105983:	6a 00                	push   $0x0
  pushl $168
80105985:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010598a:	e9 69 f5 ff ff       	jmp    80104ef8 <alltraps>

8010598f <vector169>:
.globl vector169
vector169:
  pushl $0
8010598f:	6a 00                	push   $0x0
  pushl $169
80105991:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105996:	e9 5d f5 ff ff       	jmp    80104ef8 <alltraps>

8010599b <vector170>:
.globl vector170
vector170:
  pushl $0
8010599b:	6a 00                	push   $0x0
  pushl $170
8010599d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801059a2:	e9 51 f5 ff ff       	jmp    80104ef8 <alltraps>

801059a7 <vector171>:
.globl vector171
vector171:
  pushl $0
801059a7:	6a 00                	push   $0x0
  pushl $171
801059a9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801059ae:	e9 45 f5 ff ff       	jmp    80104ef8 <alltraps>

801059b3 <vector172>:
.globl vector172
vector172:
  pushl $0
801059b3:	6a 00                	push   $0x0
  pushl $172
801059b5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801059ba:	e9 39 f5 ff ff       	jmp    80104ef8 <alltraps>

801059bf <vector173>:
.globl vector173
vector173:
  pushl $0
801059bf:	6a 00                	push   $0x0
  pushl $173
801059c1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801059c6:	e9 2d f5 ff ff       	jmp    80104ef8 <alltraps>

801059cb <vector174>:
.globl vector174
vector174:
  pushl $0
801059cb:	6a 00                	push   $0x0
  pushl $174
801059cd:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801059d2:	e9 21 f5 ff ff       	jmp    80104ef8 <alltraps>

801059d7 <vector175>:
.globl vector175
vector175:
  pushl $0
801059d7:	6a 00                	push   $0x0
  pushl $175
801059d9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801059de:	e9 15 f5 ff ff       	jmp    80104ef8 <alltraps>

801059e3 <vector176>:
.globl vector176
vector176:
  pushl $0
801059e3:	6a 00                	push   $0x0
  pushl $176
801059e5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801059ea:	e9 09 f5 ff ff       	jmp    80104ef8 <alltraps>

801059ef <vector177>:
.globl vector177
vector177:
  pushl $0
801059ef:	6a 00                	push   $0x0
  pushl $177
801059f1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801059f6:	e9 fd f4 ff ff       	jmp    80104ef8 <alltraps>

801059fb <vector178>:
.globl vector178
vector178:
  pushl $0
801059fb:	6a 00                	push   $0x0
  pushl $178
801059fd:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a02:	e9 f1 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a07 <vector179>:
.globl vector179
vector179:
  pushl $0
80105a07:	6a 00                	push   $0x0
  pushl $179
80105a09:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a0e:	e9 e5 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a13 <vector180>:
.globl vector180
vector180:
  pushl $0
80105a13:	6a 00                	push   $0x0
  pushl $180
80105a15:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a1a:	e9 d9 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a1f <vector181>:
.globl vector181
vector181:
  pushl $0
80105a1f:	6a 00                	push   $0x0
  pushl $181
80105a21:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a26:	e9 cd f4 ff ff       	jmp    80104ef8 <alltraps>

80105a2b <vector182>:
.globl vector182
vector182:
  pushl $0
80105a2b:	6a 00                	push   $0x0
  pushl $182
80105a2d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a32:	e9 c1 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a37 <vector183>:
.globl vector183
vector183:
  pushl $0
80105a37:	6a 00                	push   $0x0
  pushl $183
80105a39:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a3e:	e9 b5 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a43 <vector184>:
.globl vector184
vector184:
  pushl $0
80105a43:	6a 00                	push   $0x0
  pushl $184
80105a45:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a4a:	e9 a9 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a4f <vector185>:
.globl vector185
vector185:
  pushl $0
80105a4f:	6a 00                	push   $0x0
  pushl $185
80105a51:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a56:	e9 9d f4 ff ff       	jmp    80104ef8 <alltraps>

80105a5b <vector186>:
.globl vector186
vector186:
  pushl $0
80105a5b:	6a 00                	push   $0x0
  pushl $186
80105a5d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a62:	e9 91 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a67 <vector187>:
.globl vector187
vector187:
  pushl $0
80105a67:	6a 00                	push   $0x0
  pushl $187
80105a69:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a6e:	e9 85 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a73 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a73:	6a 00                	push   $0x0
  pushl $188
80105a75:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a7a:	e9 79 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a7f <vector189>:
.globl vector189
vector189:
  pushl $0
80105a7f:	6a 00                	push   $0x0
  pushl $189
80105a81:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a86:	e9 6d f4 ff ff       	jmp    80104ef8 <alltraps>

80105a8b <vector190>:
.globl vector190
vector190:
  pushl $0
80105a8b:	6a 00                	push   $0x0
  pushl $190
80105a8d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a92:	e9 61 f4 ff ff       	jmp    80104ef8 <alltraps>

80105a97 <vector191>:
.globl vector191
vector191:
  pushl $0
80105a97:	6a 00                	push   $0x0
  pushl $191
80105a99:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a9e:	e9 55 f4 ff ff       	jmp    80104ef8 <alltraps>

80105aa3 <vector192>:
.globl vector192
vector192:
  pushl $0
80105aa3:	6a 00                	push   $0x0
  pushl $192
80105aa5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105aaa:	e9 49 f4 ff ff       	jmp    80104ef8 <alltraps>

80105aaf <vector193>:
.globl vector193
vector193:
  pushl $0
80105aaf:	6a 00                	push   $0x0
  pushl $193
80105ab1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105ab6:	e9 3d f4 ff ff       	jmp    80104ef8 <alltraps>

80105abb <vector194>:
.globl vector194
vector194:
  pushl $0
80105abb:	6a 00                	push   $0x0
  pushl $194
80105abd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105ac2:	e9 31 f4 ff ff       	jmp    80104ef8 <alltraps>

80105ac7 <vector195>:
.globl vector195
vector195:
  pushl $0
80105ac7:	6a 00                	push   $0x0
  pushl $195
80105ac9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105ace:	e9 25 f4 ff ff       	jmp    80104ef8 <alltraps>

80105ad3 <vector196>:
.globl vector196
vector196:
  pushl $0
80105ad3:	6a 00                	push   $0x0
  pushl $196
80105ad5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105ada:	e9 19 f4 ff ff       	jmp    80104ef8 <alltraps>

80105adf <vector197>:
.globl vector197
vector197:
  pushl $0
80105adf:	6a 00                	push   $0x0
  pushl $197
80105ae1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105ae6:	e9 0d f4 ff ff       	jmp    80104ef8 <alltraps>

80105aeb <vector198>:
.globl vector198
vector198:
  pushl $0
80105aeb:	6a 00                	push   $0x0
  pushl $198
80105aed:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105af2:	e9 01 f4 ff ff       	jmp    80104ef8 <alltraps>

80105af7 <vector199>:
.globl vector199
vector199:
  pushl $0
80105af7:	6a 00                	push   $0x0
  pushl $199
80105af9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105afe:	e9 f5 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b03 <vector200>:
.globl vector200
vector200:
  pushl $0
80105b03:	6a 00                	push   $0x0
  pushl $200
80105b05:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b0a:	e9 e9 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b0f <vector201>:
.globl vector201
vector201:
  pushl $0
80105b0f:	6a 00                	push   $0x0
  pushl $201
80105b11:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b16:	e9 dd f3 ff ff       	jmp    80104ef8 <alltraps>

80105b1b <vector202>:
.globl vector202
vector202:
  pushl $0
80105b1b:	6a 00                	push   $0x0
  pushl $202
80105b1d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b22:	e9 d1 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b27 <vector203>:
.globl vector203
vector203:
  pushl $0
80105b27:	6a 00                	push   $0x0
  pushl $203
80105b29:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b2e:	e9 c5 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b33 <vector204>:
.globl vector204
vector204:
  pushl $0
80105b33:	6a 00                	push   $0x0
  pushl $204
80105b35:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b3a:	e9 b9 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b3f <vector205>:
.globl vector205
vector205:
  pushl $0
80105b3f:	6a 00                	push   $0x0
  pushl $205
80105b41:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b46:	e9 ad f3 ff ff       	jmp    80104ef8 <alltraps>

80105b4b <vector206>:
.globl vector206
vector206:
  pushl $0
80105b4b:	6a 00                	push   $0x0
  pushl $206
80105b4d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b52:	e9 a1 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b57 <vector207>:
.globl vector207
vector207:
  pushl $0
80105b57:	6a 00                	push   $0x0
  pushl $207
80105b59:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b5e:	e9 95 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b63 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b63:	6a 00                	push   $0x0
  pushl $208
80105b65:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b6a:	e9 89 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b6f <vector209>:
.globl vector209
vector209:
  pushl $0
80105b6f:	6a 00                	push   $0x0
  pushl $209
80105b71:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b76:	e9 7d f3 ff ff       	jmp    80104ef8 <alltraps>

80105b7b <vector210>:
.globl vector210
vector210:
  pushl $0
80105b7b:	6a 00                	push   $0x0
  pushl $210
80105b7d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b82:	e9 71 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b87 <vector211>:
.globl vector211
vector211:
  pushl $0
80105b87:	6a 00                	push   $0x0
  pushl $211
80105b89:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b8e:	e9 65 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b93 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b93:	6a 00                	push   $0x0
  pushl $212
80105b95:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b9a:	e9 59 f3 ff ff       	jmp    80104ef8 <alltraps>

80105b9f <vector213>:
.globl vector213
vector213:
  pushl $0
80105b9f:	6a 00                	push   $0x0
  pushl $213
80105ba1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105ba6:	e9 4d f3 ff ff       	jmp    80104ef8 <alltraps>

80105bab <vector214>:
.globl vector214
vector214:
  pushl $0
80105bab:	6a 00                	push   $0x0
  pushl $214
80105bad:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105bb2:	e9 41 f3 ff ff       	jmp    80104ef8 <alltraps>

80105bb7 <vector215>:
.globl vector215
vector215:
  pushl $0
80105bb7:	6a 00                	push   $0x0
  pushl $215
80105bb9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105bbe:	e9 35 f3 ff ff       	jmp    80104ef8 <alltraps>

80105bc3 <vector216>:
.globl vector216
vector216:
  pushl $0
80105bc3:	6a 00                	push   $0x0
  pushl $216
80105bc5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105bca:	e9 29 f3 ff ff       	jmp    80104ef8 <alltraps>

80105bcf <vector217>:
.globl vector217
vector217:
  pushl $0
80105bcf:	6a 00                	push   $0x0
  pushl $217
80105bd1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105bd6:	e9 1d f3 ff ff       	jmp    80104ef8 <alltraps>

80105bdb <vector218>:
.globl vector218
vector218:
  pushl $0
80105bdb:	6a 00                	push   $0x0
  pushl $218
80105bdd:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105be2:	e9 11 f3 ff ff       	jmp    80104ef8 <alltraps>

80105be7 <vector219>:
.globl vector219
vector219:
  pushl $0
80105be7:	6a 00                	push   $0x0
  pushl $219
80105be9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105bee:	e9 05 f3 ff ff       	jmp    80104ef8 <alltraps>

80105bf3 <vector220>:
.globl vector220
vector220:
  pushl $0
80105bf3:	6a 00                	push   $0x0
  pushl $220
80105bf5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105bfa:	e9 f9 f2 ff ff       	jmp    80104ef8 <alltraps>

80105bff <vector221>:
.globl vector221
vector221:
  pushl $0
80105bff:	6a 00                	push   $0x0
  pushl $221
80105c01:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c06:	e9 ed f2 ff ff       	jmp    80104ef8 <alltraps>

80105c0b <vector222>:
.globl vector222
vector222:
  pushl $0
80105c0b:	6a 00                	push   $0x0
  pushl $222
80105c0d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c12:	e9 e1 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c17 <vector223>:
.globl vector223
vector223:
  pushl $0
80105c17:	6a 00                	push   $0x0
  pushl $223
80105c19:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c1e:	e9 d5 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c23 <vector224>:
.globl vector224
vector224:
  pushl $0
80105c23:	6a 00                	push   $0x0
  pushl $224
80105c25:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c2a:	e9 c9 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c2f <vector225>:
.globl vector225
vector225:
  pushl $0
80105c2f:	6a 00                	push   $0x0
  pushl $225
80105c31:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c36:	e9 bd f2 ff ff       	jmp    80104ef8 <alltraps>

80105c3b <vector226>:
.globl vector226
vector226:
  pushl $0
80105c3b:	6a 00                	push   $0x0
  pushl $226
80105c3d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c42:	e9 b1 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c47 <vector227>:
.globl vector227
vector227:
  pushl $0
80105c47:	6a 00                	push   $0x0
  pushl $227
80105c49:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c4e:	e9 a5 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c53 <vector228>:
.globl vector228
vector228:
  pushl $0
80105c53:	6a 00                	push   $0x0
  pushl $228
80105c55:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c5a:	e9 99 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c5f <vector229>:
.globl vector229
vector229:
  pushl $0
80105c5f:	6a 00                	push   $0x0
  pushl $229
80105c61:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c66:	e9 8d f2 ff ff       	jmp    80104ef8 <alltraps>

80105c6b <vector230>:
.globl vector230
vector230:
  pushl $0
80105c6b:	6a 00                	push   $0x0
  pushl $230
80105c6d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c72:	e9 81 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c77 <vector231>:
.globl vector231
vector231:
  pushl $0
80105c77:	6a 00                	push   $0x0
  pushl $231
80105c79:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c7e:	e9 75 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c83 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c83:	6a 00                	push   $0x0
  pushl $232
80105c85:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c8a:	e9 69 f2 ff ff       	jmp    80104ef8 <alltraps>

80105c8f <vector233>:
.globl vector233
vector233:
  pushl $0
80105c8f:	6a 00                	push   $0x0
  pushl $233
80105c91:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c96:	e9 5d f2 ff ff       	jmp    80104ef8 <alltraps>

80105c9b <vector234>:
.globl vector234
vector234:
  pushl $0
80105c9b:	6a 00                	push   $0x0
  pushl $234
80105c9d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105ca2:	e9 51 f2 ff ff       	jmp    80104ef8 <alltraps>

80105ca7 <vector235>:
.globl vector235
vector235:
  pushl $0
80105ca7:	6a 00                	push   $0x0
  pushl $235
80105ca9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105cae:	e9 45 f2 ff ff       	jmp    80104ef8 <alltraps>

80105cb3 <vector236>:
.globl vector236
vector236:
  pushl $0
80105cb3:	6a 00                	push   $0x0
  pushl $236
80105cb5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105cba:	e9 39 f2 ff ff       	jmp    80104ef8 <alltraps>

80105cbf <vector237>:
.globl vector237
vector237:
  pushl $0
80105cbf:	6a 00                	push   $0x0
  pushl $237
80105cc1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105cc6:	e9 2d f2 ff ff       	jmp    80104ef8 <alltraps>

80105ccb <vector238>:
.globl vector238
vector238:
  pushl $0
80105ccb:	6a 00                	push   $0x0
  pushl $238
80105ccd:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105cd2:	e9 21 f2 ff ff       	jmp    80104ef8 <alltraps>

80105cd7 <vector239>:
.globl vector239
vector239:
  pushl $0
80105cd7:	6a 00                	push   $0x0
  pushl $239
80105cd9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105cde:	e9 15 f2 ff ff       	jmp    80104ef8 <alltraps>

80105ce3 <vector240>:
.globl vector240
vector240:
  pushl $0
80105ce3:	6a 00                	push   $0x0
  pushl $240
80105ce5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105cea:	e9 09 f2 ff ff       	jmp    80104ef8 <alltraps>

80105cef <vector241>:
.globl vector241
vector241:
  pushl $0
80105cef:	6a 00                	push   $0x0
  pushl $241
80105cf1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105cf6:	e9 fd f1 ff ff       	jmp    80104ef8 <alltraps>

80105cfb <vector242>:
.globl vector242
vector242:
  pushl $0
80105cfb:	6a 00                	push   $0x0
  pushl $242
80105cfd:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d02:	e9 f1 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d07 <vector243>:
.globl vector243
vector243:
  pushl $0
80105d07:	6a 00                	push   $0x0
  pushl $243
80105d09:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d0e:	e9 e5 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d13 <vector244>:
.globl vector244
vector244:
  pushl $0
80105d13:	6a 00                	push   $0x0
  pushl $244
80105d15:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d1a:	e9 d9 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d1f <vector245>:
.globl vector245
vector245:
  pushl $0
80105d1f:	6a 00                	push   $0x0
  pushl $245
80105d21:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d26:	e9 cd f1 ff ff       	jmp    80104ef8 <alltraps>

80105d2b <vector246>:
.globl vector246
vector246:
  pushl $0
80105d2b:	6a 00                	push   $0x0
  pushl $246
80105d2d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d32:	e9 c1 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d37 <vector247>:
.globl vector247
vector247:
  pushl $0
80105d37:	6a 00                	push   $0x0
  pushl $247
80105d39:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d3e:	e9 b5 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d43 <vector248>:
.globl vector248
vector248:
  pushl $0
80105d43:	6a 00                	push   $0x0
  pushl $248
80105d45:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d4a:	e9 a9 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d4f <vector249>:
.globl vector249
vector249:
  pushl $0
80105d4f:	6a 00                	push   $0x0
  pushl $249
80105d51:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d56:	e9 9d f1 ff ff       	jmp    80104ef8 <alltraps>

80105d5b <vector250>:
.globl vector250
vector250:
  pushl $0
80105d5b:	6a 00                	push   $0x0
  pushl $250
80105d5d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d62:	e9 91 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d67 <vector251>:
.globl vector251
vector251:
  pushl $0
80105d67:	6a 00                	push   $0x0
  pushl $251
80105d69:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d6e:	e9 85 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d73 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d73:	6a 00                	push   $0x0
  pushl $252
80105d75:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d7a:	e9 79 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d7f <vector253>:
.globl vector253
vector253:
  pushl $0
80105d7f:	6a 00                	push   $0x0
  pushl $253
80105d81:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d86:	e9 6d f1 ff ff       	jmp    80104ef8 <alltraps>

80105d8b <vector254>:
.globl vector254
vector254:
  pushl $0
80105d8b:	6a 00                	push   $0x0
  pushl $254
80105d8d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d92:	e9 61 f1 ff ff       	jmp    80104ef8 <alltraps>

80105d97 <vector255>:
.globl vector255
vector255:
  pushl $0
80105d97:	6a 00                	push   $0x0
  pushl $255
80105d99:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d9e:	e9 55 f1 ff ff       	jmp    80104ef8 <alltraps>

80105da3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105da3:	55                   	push   %ebp
80105da4:	89 e5                	mov    %esp,%ebp
80105da6:	57                   	push   %edi
80105da7:	56                   	push   %esi
80105da8:	53                   	push   %ebx
80105da9:	83 ec 0c             	sub    $0xc,%esp
80105dac:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105dae:	c1 ea 16             	shr    $0x16,%edx
80105db1:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105db4:	8b 1f                	mov    (%edi),%ebx
80105db6:	f6 c3 01             	test   $0x1,%bl
80105db9:	74 22                	je     80105ddd <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105dbb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105dc1:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105dc7:	c1 ee 0c             	shr    $0xc,%esi
80105dca:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105dd0:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105dd3:	89 d8                	mov    %ebx,%eax
80105dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dd8:	5b                   	pop    %ebx
80105dd9:	5e                   	pop    %esi
80105dda:	5f                   	pop    %edi
80105ddb:	5d                   	pop    %ebp
80105ddc:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc(-2)) == 0)
80105ddd:	85 c9                	test   %ecx,%ecx
80105ddf:	74 33                	je     80105e14 <walkpgdir+0x71>
80105de1:	83 ec 0c             	sub    $0xc,%esp
80105de4:	6a fe                	push   $0xfffffffe
80105de6:	e8 61 c3 ff ff       	call   8010214c <kalloc>
80105deb:	89 c3                	mov    %eax,%ebx
80105ded:	83 c4 10             	add    $0x10,%esp
80105df0:	85 c0                	test   %eax,%eax
80105df2:	74 df                	je     80105dd3 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105df4:	83 ec 04             	sub    $0x4,%esp
80105df7:	68 00 10 00 00       	push   $0x1000
80105dfc:	6a 00                	push   $0x0
80105dfe:	50                   	push   %eax
80105dff:	e8 f6 df ff ff       	call   80103dfa <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e04:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105e0a:	83 c8 07             	or     $0x7,%eax
80105e0d:	89 07                	mov    %eax,(%edi)
80105e0f:	83 c4 10             	add    $0x10,%esp
80105e12:	eb b3                	jmp    80105dc7 <walkpgdir+0x24>
      return 0;
80105e14:	bb 00 00 00 00       	mov    $0x0,%ebx
80105e19:	eb b8                	jmp    80105dd3 <walkpgdir+0x30>

80105e1b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105e1b:	55                   	push   %ebp
80105e1c:	89 e5                	mov    %esp,%ebp
80105e1e:	57                   	push   %edi
80105e1f:	56                   	push   %esi
80105e20:	53                   	push   %ebx
80105e21:	83 ec 1c             	sub    $0x1c,%esp
80105e24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e27:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105e2a:	89 d3                	mov    %edx,%ebx
80105e2c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105e32:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105e36:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e3c:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e41:	89 da                	mov    %ebx,%edx
80105e43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e46:	e8 58 ff ff ff       	call   80105da3 <walkpgdir>
80105e4b:	85 c0                	test   %eax,%eax
80105e4d:	74 2e                	je     80105e7d <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e4f:	f6 00 01             	testb  $0x1,(%eax)
80105e52:	75 1c                	jne    80105e70 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e54:	89 f2                	mov    %esi,%edx
80105e56:	0b 55 0c             	or     0xc(%ebp),%edx
80105e59:	83 ca 01             	or     $0x1,%edx
80105e5c:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e5e:	39 fb                	cmp    %edi,%ebx
80105e60:	74 28                	je     80105e8a <mappages+0x6f>
      break;
    a += PGSIZE;
80105e62:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e68:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e6e:	eb cc                	jmp    80105e3c <mappages+0x21>
      panic("remap");
80105e70:	83 ec 0c             	sub    $0xc,%esp
80105e73:	68 4c 6f 10 80       	push   $0x80106f4c
80105e78:	e8 cb a4 ff ff       	call   80100348 <panic>
      return -1;
80105e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e85:	5b                   	pop    %ebx
80105e86:	5e                   	pop    %esi
80105e87:	5f                   	pop    %edi
80105e88:	5d                   	pop    %ebp
80105e89:	c3                   	ret    
  return 0;
80105e8a:	b8 00 00 00 00       	mov    $0x0,%eax
80105e8f:	eb f1                	jmp    80105e82 <mappages+0x67>

80105e91 <seginit>:
{
80105e91:	55                   	push   %ebp
80105e92:	89 e5                	mov    %esp,%ebp
80105e94:	53                   	push   %ebx
80105e95:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e98:	e8 f4 d4 ff ff       	call   80103391 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e9d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105ea3:	66 c7 80 58 28 14 80 	movw   $0xffff,-0x7febd7a8(%eax)
80105eaa:	ff ff 
80105eac:	66 c7 80 5a 28 14 80 	movw   $0x0,-0x7febd7a6(%eax)
80105eb3:	00 00 
80105eb5:	c6 80 5c 28 14 80 00 	movb   $0x0,-0x7febd7a4(%eax)
80105ebc:	0f b6 88 5d 28 14 80 	movzbl -0x7febd7a3(%eax),%ecx
80105ec3:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ec6:	83 c9 1a             	or     $0x1a,%ecx
80105ec9:	83 e1 9f             	and    $0xffffff9f,%ecx
80105ecc:	83 c9 80             	or     $0xffffff80,%ecx
80105ecf:	88 88 5d 28 14 80    	mov    %cl,-0x7febd7a3(%eax)
80105ed5:	0f b6 88 5e 28 14 80 	movzbl -0x7febd7a2(%eax),%ecx
80105edc:	83 c9 0f             	or     $0xf,%ecx
80105edf:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ee2:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ee5:	88 88 5e 28 14 80    	mov    %cl,-0x7febd7a2(%eax)
80105eeb:	c6 80 5f 28 14 80 00 	movb   $0x0,-0x7febd7a1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ef2:	66 c7 80 60 28 14 80 	movw   $0xffff,-0x7febd7a0(%eax)
80105ef9:	ff ff 
80105efb:	66 c7 80 62 28 14 80 	movw   $0x0,-0x7febd79e(%eax)
80105f02:	00 00 
80105f04:	c6 80 64 28 14 80 00 	movb   $0x0,-0x7febd79c(%eax)
80105f0b:	0f b6 88 65 28 14 80 	movzbl -0x7febd79b(%eax),%ecx
80105f12:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f15:	83 c9 12             	or     $0x12,%ecx
80105f18:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f1b:	83 c9 80             	or     $0xffffff80,%ecx
80105f1e:	88 88 65 28 14 80    	mov    %cl,-0x7febd79b(%eax)
80105f24:	0f b6 88 66 28 14 80 	movzbl -0x7febd79a(%eax),%ecx
80105f2b:	83 c9 0f             	or     $0xf,%ecx
80105f2e:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f31:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f34:	88 88 66 28 14 80    	mov    %cl,-0x7febd79a(%eax)
80105f3a:	c6 80 67 28 14 80 00 	movb   $0x0,-0x7febd799(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f41:	66 c7 80 68 28 14 80 	movw   $0xffff,-0x7febd798(%eax)
80105f48:	ff ff 
80105f4a:	66 c7 80 6a 28 14 80 	movw   $0x0,-0x7febd796(%eax)
80105f51:	00 00 
80105f53:	c6 80 6c 28 14 80 00 	movb   $0x0,-0x7febd794(%eax)
80105f5a:	c6 80 6d 28 14 80 fa 	movb   $0xfa,-0x7febd793(%eax)
80105f61:	0f b6 88 6e 28 14 80 	movzbl -0x7febd792(%eax),%ecx
80105f68:	83 c9 0f             	or     $0xf,%ecx
80105f6b:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f6e:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f71:	88 88 6e 28 14 80    	mov    %cl,-0x7febd792(%eax)
80105f77:	c6 80 6f 28 14 80 00 	movb   $0x0,-0x7febd791(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f7e:	66 c7 80 70 28 14 80 	movw   $0xffff,-0x7febd790(%eax)
80105f85:	ff ff 
80105f87:	66 c7 80 72 28 14 80 	movw   $0x0,-0x7febd78e(%eax)
80105f8e:	00 00 
80105f90:	c6 80 74 28 14 80 00 	movb   $0x0,-0x7febd78c(%eax)
80105f97:	c6 80 75 28 14 80 f2 	movb   $0xf2,-0x7febd78b(%eax)
80105f9e:	0f b6 88 76 28 14 80 	movzbl -0x7febd78a(%eax),%ecx
80105fa5:	83 c9 0f             	or     $0xf,%ecx
80105fa8:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fab:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fae:	88 88 76 28 14 80    	mov    %cl,-0x7febd78a(%eax)
80105fb4:	c6 80 77 28 14 80 00 	movb   $0x0,-0x7febd789(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105fbb:	05 50 28 14 80       	add    $0x80142850,%eax
  pd[0] = size-1;
80105fc0:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105fc6:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105fca:	c1 e8 10             	shr    $0x10,%eax
80105fcd:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fd1:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105fd4:	0f 01 10             	lgdtl  (%eax)
}
80105fd7:	83 c4 14             	add    $0x14,%esp
80105fda:	5b                   	pop    %ebx
80105fdb:	5d                   	pop    %ebp
80105fdc:	c3                   	ret    

80105fdd <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105fdd:	55                   	push   %ebp
80105fde:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105fe0:	a1 04 55 14 80       	mov    0x80145504,%eax
80105fe5:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fea:	0f 22 d8             	mov    %eax,%cr3
}
80105fed:	5d                   	pop    %ebp
80105fee:	c3                   	ret    

80105fef <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fef:	55                   	push   %ebp
80105ff0:	89 e5                	mov    %esp,%ebp
80105ff2:	57                   	push   %edi
80105ff3:	56                   	push   %esi
80105ff4:	53                   	push   %ebx
80105ff5:	83 ec 1c             	sub    $0x1c,%esp
80105ff8:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ffb:	85 f6                	test   %esi,%esi
80105ffd:	0f 84 dd 00 00 00    	je     801060e0 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106003:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106007:	0f 84 e0 00 00 00    	je     801060ed <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010600d:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106011:	0f 84 e3 00 00 00    	je     801060fa <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80106017:	e8 55 dc ff ff       	call   80103c71 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010601c:	e8 14 d3 ff ff       	call   80103335 <mycpu>
80106021:	89 c3                	mov    %eax,%ebx
80106023:	e8 0d d3 ff ff       	call   80103335 <mycpu>
80106028:	8d 78 08             	lea    0x8(%eax),%edi
8010602b:	e8 05 d3 ff ff       	call   80103335 <mycpu>
80106030:	83 c0 08             	add    $0x8,%eax
80106033:	c1 e8 10             	shr    $0x10,%eax
80106036:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106039:	e8 f7 d2 ff ff       	call   80103335 <mycpu>
8010603e:	83 c0 08             	add    $0x8,%eax
80106041:	c1 e8 18             	shr    $0x18,%eax
80106044:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010604b:	67 00 
8010604d:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106054:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106058:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010605e:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106065:	83 e2 f0             	and    $0xfffffff0,%edx
80106068:	83 ca 19             	or     $0x19,%edx
8010606b:	83 e2 9f             	and    $0xffffff9f,%edx
8010606e:	83 ca 80             	or     $0xffffff80,%edx
80106071:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106077:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
8010607e:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106084:	e8 ac d2 ff ff       	call   80103335 <mycpu>
80106089:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106090:	83 e2 ef             	and    $0xffffffef,%edx
80106093:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106099:	e8 97 d2 ff ff       	call   80103335 <mycpu>
8010609e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801060a4:	8b 5e 08             	mov    0x8(%esi),%ebx
801060a7:	e8 89 d2 ff ff       	call   80103335 <mycpu>
801060ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060b2:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801060b5:	e8 7b d2 ff ff       	call   80103335 <mycpu>
801060ba:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801060c0:	b8 28 00 00 00       	mov    $0x28,%eax
801060c5:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801060c8:	8b 46 04             	mov    0x4(%esi),%eax
801060cb:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060d0:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060d3:	e8 d6 db ff ff       	call   80103cae <popcli>
}
801060d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060db:	5b                   	pop    %ebx
801060dc:	5e                   	pop    %esi
801060dd:	5f                   	pop    %edi
801060de:	5d                   	pop    %ebp
801060df:	c3                   	ret    
    panic("switchuvm: no process");
801060e0:	83 ec 0c             	sub    $0xc,%esp
801060e3:	68 52 6f 10 80       	push   $0x80106f52
801060e8:	e8 5b a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801060ed:	83 ec 0c             	sub    $0xc,%esp
801060f0:	68 68 6f 10 80       	push   $0x80106f68
801060f5:	e8 4e a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060fa:	83 ec 0c             	sub    $0xc,%esp
801060fd:	68 7d 6f 10 80       	push   $0x80106f7d
80106102:	e8 41 a2 ff ff       	call   80100348 <panic>

80106107 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106107:	55                   	push   %ebp
80106108:	89 e5                	mov    %esp,%ebp
8010610a:	56                   	push   %esi
8010610b:	53                   	push   %ebx
8010610c:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010610f:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106115:	77 51                	ja     80106168 <inituvm+0x61>
    panic("inituvm: more than a page");
  mem = kalloc(-2);
80106117:	83 ec 0c             	sub    $0xc,%esp
8010611a:	6a fe                	push   $0xfffffffe
8010611c:	e8 2b c0 ff ff       	call   8010214c <kalloc>
80106121:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106123:	83 c4 0c             	add    $0xc,%esp
80106126:	68 00 10 00 00       	push   $0x1000
8010612b:	6a 00                	push   $0x0
8010612d:	50                   	push   %eax
8010612e:	e8 c7 dc ff ff       	call   80103dfa <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106133:	83 c4 08             	add    $0x8,%esp
80106136:	6a 06                	push   $0x6
80106138:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010613e:	50                   	push   %eax
8010613f:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106144:	ba 00 00 00 00       	mov    $0x0,%edx
80106149:	8b 45 08             	mov    0x8(%ebp),%eax
8010614c:	e8 ca fc ff ff       	call   80105e1b <mappages>
  memmove(mem, init, sz);
80106151:	83 c4 0c             	add    $0xc,%esp
80106154:	56                   	push   %esi
80106155:	ff 75 0c             	pushl  0xc(%ebp)
80106158:	53                   	push   %ebx
80106159:	e8 17 dd ff ff       	call   80103e75 <memmove>
}
8010615e:	83 c4 10             	add    $0x10,%esp
80106161:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106164:	5b                   	pop    %ebx
80106165:	5e                   	pop    %esi
80106166:	5d                   	pop    %ebp
80106167:	c3                   	ret    
    panic("inituvm: more than a page");
80106168:	83 ec 0c             	sub    $0xc,%esp
8010616b:	68 91 6f 10 80       	push   $0x80106f91
80106170:	e8 d3 a1 ff ff       	call   80100348 <panic>

80106175 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106175:	55                   	push   %ebp
80106176:	89 e5                	mov    %esp,%ebp
80106178:	57                   	push   %edi
80106179:	56                   	push   %esi
8010617a:	53                   	push   %ebx
8010617b:	83 ec 0c             	sub    $0xc,%esp
8010617e:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106181:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106188:	75 07                	jne    80106191 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010618a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010618f:	eb 3c                	jmp    801061cd <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106191:	83 ec 0c             	sub    $0xc,%esp
80106194:	68 4c 70 10 80       	push   $0x8010704c
80106199:	e8 aa a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010619e:	83 ec 0c             	sub    $0xc,%esp
801061a1:	68 ab 6f 10 80       	push   $0x80106fab
801061a6:	e8 9d a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801061ab:	05 00 00 00 80       	add    $0x80000000,%eax
801061b0:	56                   	push   %esi
801061b1:	89 da                	mov    %ebx,%edx
801061b3:	03 55 14             	add    0x14(%ebp),%edx
801061b6:	52                   	push   %edx
801061b7:	50                   	push   %eax
801061b8:	ff 75 10             	pushl  0x10(%ebp)
801061bb:	e8 bf b5 ff ff       	call   8010177f <readi>
801061c0:	83 c4 10             	add    $0x10,%esp
801061c3:	39 f0                	cmp    %esi,%eax
801061c5:	75 47                	jne    8010620e <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801061c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061cd:	39 fb                	cmp    %edi,%ebx
801061cf:	73 30                	jae    80106201 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061d1:	89 da                	mov    %ebx,%edx
801061d3:	03 55 0c             	add    0xc(%ebp),%edx
801061d6:	b9 00 00 00 00       	mov    $0x0,%ecx
801061db:	8b 45 08             	mov    0x8(%ebp),%eax
801061de:	e8 c0 fb ff ff       	call   80105da3 <walkpgdir>
801061e3:	85 c0                	test   %eax,%eax
801061e5:	74 b7                	je     8010619e <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061e7:	8b 00                	mov    (%eax),%eax
801061e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061ee:	89 fe                	mov    %edi,%esi
801061f0:	29 de                	sub    %ebx,%esi
801061f2:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061f8:	76 b1                	jbe    801061ab <loaduvm+0x36>
      n = PGSIZE;
801061fa:	be 00 10 00 00       	mov    $0x1000,%esi
801061ff:	eb aa                	jmp    801061ab <loaduvm+0x36>
      return -1;
  }
  return 0;
80106201:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106206:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106209:	5b                   	pop    %ebx
8010620a:	5e                   	pop    %esi
8010620b:	5f                   	pop    %edi
8010620c:	5d                   	pop    %ebp
8010620d:	c3                   	ret    
      return -1;
8010620e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106213:	eb f1                	jmp    80106206 <loaduvm+0x91>

80106215 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106215:	55                   	push   %ebp
80106216:	89 e5                	mov    %esp,%ebp
80106218:	57                   	push   %edi
80106219:	56                   	push   %esi
8010621a:	53                   	push   %ebx
8010621b:	83 ec 0c             	sub    $0xc,%esp
8010621e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106221:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106224:	73 11                	jae    80106237 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106226:	8b 45 10             	mov    0x10(%ebp),%eax
80106229:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010622f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106235:	eb 19                	jmp    80106250 <deallocuvm+0x3b>
    return oldsz;
80106237:	89 f8                	mov    %edi,%eax
80106239:	eb 64                	jmp    8010629f <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010623b:	c1 eb 16             	shr    $0x16,%ebx
8010623e:	83 c3 01             	add    $0x1,%ebx
80106241:	c1 e3 16             	shl    $0x16,%ebx
80106244:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010624a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106250:	39 fb                	cmp    %edi,%ebx
80106252:	73 48                	jae    8010629c <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106254:	b9 00 00 00 00       	mov    $0x0,%ecx
80106259:	89 da                	mov    %ebx,%edx
8010625b:	8b 45 08             	mov    0x8(%ebp),%eax
8010625e:	e8 40 fb ff ff       	call   80105da3 <walkpgdir>
80106263:	89 c6                	mov    %eax,%esi
    if(!pte)
80106265:	85 c0                	test   %eax,%eax
80106267:	74 d2                	je     8010623b <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106269:	8b 00                	mov    (%eax),%eax
8010626b:	a8 01                	test   $0x1,%al
8010626d:	74 db                	je     8010624a <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010626f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106274:	74 19                	je     8010628f <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106276:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010627b:	83 ec 0c             	sub    $0xc,%esp
8010627e:	50                   	push   %eax
8010627f:	e8 81 bd ff ff       	call   80102005 <kfree>
      *pte = 0;
80106284:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010628a:	83 c4 10             	add    $0x10,%esp
8010628d:	eb bb                	jmp    8010624a <deallocuvm+0x35>
        panic("kfree");
8010628f:	83 ec 0c             	sub    $0xc,%esp
80106292:	68 e6 68 10 80       	push   $0x801068e6
80106297:	e8 ac a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
8010629c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010629f:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062a2:	5b                   	pop    %ebx
801062a3:	5e                   	pop    %esi
801062a4:	5f                   	pop    %edi
801062a5:	5d                   	pop    %ebp
801062a6:	c3                   	ret    

801062a7 <allocuvm>:
{
801062a7:	55                   	push   %ebp
801062a8:	89 e5                	mov    %esp,%ebp
801062aa:	57                   	push   %edi
801062ab:	56                   	push   %esi
801062ac:	53                   	push   %ebx
801062ad:	83 ec 1c             	sub    $0x1c,%esp
801062b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801062b3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801062b6:	85 ff                	test   %edi,%edi
801062b8:	0f 88 ca 00 00 00    	js     80106388 <allocuvm+0xe1>
  if(newsz < oldsz)
801062be:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062c1:	72 65                	jb     80106328 <allocuvm+0x81>
  a = PGROUNDUP(oldsz);
801062c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801062c6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062cc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801062d2:	39 fb                	cmp    %edi,%ebx
801062d4:	0f 83 b5 00 00 00    	jae    8010638f <allocuvm+0xe8>
    mem = kalloc(pid);
801062da:	83 ec 0c             	sub    $0xc,%esp
801062dd:	ff 75 14             	pushl  0x14(%ebp)
801062e0:	e8 67 be ff ff       	call   8010214c <kalloc>
801062e5:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801062e7:	83 c4 10             	add    $0x10,%esp
801062ea:	85 c0                	test   %eax,%eax
801062ec:	74 42                	je     80106330 <allocuvm+0x89>
    memset(mem, 0, PGSIZE);
801062ee:	83 ec 04             	sub    $0x4,%esp
801062f1:	68 00 10 00 00       	push   $0x1000
801062f6:	6a 00                	push   $0x0
801062f8:	50                   	push   %eax
801062f9:	e8 fc da ff ff       	call   80103dfa <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801062fe:	83 c4 08             	add    $0x8,%esp
80106301:	6a 06                	push   $0x6
80106303:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106309:	50                   	push   %eax
8010630a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010630f:	89 da                	mov    %ebx,%edx
80106311:	8b 45 08             	mov    0x8(%ebp),%eax
80106314:	e8 02 fb ff ff       	call   80105e1b <mappages>
80106319:	83 c4 10             	add    $0x10,%esp
8010631c:	85 c0                	test   %eax,%eax
8010631e:	78 38                	js     80106358 <allocuvm+0xb1>
  for(; a < newsz; a += PGSIZE){
80106320:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106326:	eb aa                	jmp    801062d2 <allocuvm+0x2b>
    return oldsz;
80106328:	8b 45 0c             	mov    0xc(%ebp),%eax
8010632b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010632e:	eb 5f                	jmp    8010638f <allocuvm+0xe8>
      cprintf("allocuvm out of memory\n");
80106330:	83 ec 0c             	sub    $0xc,%esp
80106333:	68 c9 6f 10 80       	push   $0x80106fc9
80106338:	e8 ce a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010633d:	83 c4 0c             	add    $0xc,%esp
80106340:	ff 75 0c             	pushl  0xc(%ebp)
80106343:	57                   	push   %edi
80106344:	ff 75 08             	pushl  0x8(%ebp)
80106347:	e8 c9 fe ff ff       	call   80106215 <deallocuvm>
      return 0;
8010634c:	83 c4 10             	add    $0x10,%esp
8010634f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106356:	eb 37                	jmp    8010638f <allocuvm+0xe8>
      cprintf("allocuvm out of memory (2)\n");
80106358:	83 ec 0c             	sub    $0xc,%esp
8010635b:	68 e1 6f 10 80       	push   $0x80106fe1
80106360:	e8 a6 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106365:	83 c4 0c             	add    $0xc,%esp
80106368:	ff 75 0c             	pushl  0xc(%ebp)
8010636b:	57                   	push   %edi
8010636c:	ff 75 08             	pushl  0x8(%ebp)
8010636f:	e8 a1 fe ff ff       	call   80106215 <deallocuvm>
      kfree(mem);
80106374:	89 34 24             	mov    %esi,(%esp)
80106377:	e8 89 bc ff ff       	call   80102005 <kfree>
      return 0;
8010637c:	83 c4 10             	add    $0x10,%esp
8010637f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106386:	eb 07                	jmp    8010638f <allocuvm+0xe8>
    return 0;
80106388:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010638f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106392:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106395:	5b                   	pop    %ebx
80106396:	5e                   	pop    %esi
80106397:	5f                   	pop    %edi
80106398:	5d                   	pop    %ebp
80106399:	c3                   	ret    

8010639a <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010639a:	55                   	push   %ebp
8010639b:	89 e5                	mov    %esp,%ebp
8010639d:	56                   	push   %esi
8010639e:	53                   	push   %ebx
8010639f:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801063a2:	85 f6                	test   %esi,%esi
801063a4:	74 1a                	je     801063c0 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801063a6:	83 ec 04             	sub    $0x4,%esp
801063a9:	6a 00                	push   $0x0
801063ab:	68 00 00 00 80       	push   $0x80000000
801063b0:	56                   	push   %esi
801063b1:	e8 5f fe ff ff       	call   80106215 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801063b6:	83 c4 10             	add    $0x10,%esp
801063b9:	bb 00 00 00 00       	mov    $0x0,%ebx
801063be:	eb 10                	jmp    801063d0 <freevm+0x36>
    panic("freevm: no pgdir");
801063c0:	83 ec 0c             	sub    $0xc,%esp
801063c3:	68 fd 6f 10 80       	push   $0x80106ffd
801063c8:	e8 7b 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801063cd:	83 c3 01             	add    $0x1,%ebx
801063d0:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801063d6:	77 1f                	ja     801063f7 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801063d8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801063db:	a8 01                	test   $0x1,%al
801063dd:	74 ee                	je     801063cd <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801063df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063e4:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801063e9:	83 ec 0c             	sub    $0xc,%esp
801063ec:	50                   	push   %eax
801063ed:	e8 13 bc ff ff       	call   80102005 <kfree>
801063f2:	83 c4 10             	add    $0x10,%esp
801063f5:	eb d6                	jmp    801063cd <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	56                   	push   %esi
801063fb:	e8 05 bc ff ff       	call   80102005 <kfree>
}
80106400:	83 c4 10             	add    $0x10,%esp
80106403:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106406:	5b                   	pop    %ebx
80106407:	5e                   	pop    %esi
80106408:	5d                   	pop    %ebp
80106409:	c3                   	ret    

8010640a <setupkvm>:
{
8010640a:	55                   	push   %ebp
8010640b:	89 e5                	mov    %esp,%ebp
8010640d:	56                   	push   %esi
8010640e:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc(-2)) == 0)
8010640f:	83 ec 0c             	sub    $0xc,%esp
80106412:	6a fe                	push   $0xfffffffe
80106414:	e8 33 bd ff ff       	call   8010214c <kalloc>
80106419:	89 c6                	mov    %eax,%esi
8010641b:	83 c4 10             	add    $0x10,%esp
8010641e:	85 c0                	test   %eax,%eax
80106420:	74 55                	je     80106477 <setupkvm+0x6d>
  memset(pgdir, 0, PGSIZE);
80106422:	83 ec 04             	sub    $0x4,%esp
80106425:	68 00 10 00 00       	push   $0x1000
8010642a:	6a 00                	push   $0x0
8010642c:	50                   	push   %eax
8010642d:	e8 c8 d9 ff ff       	call   80103dfa <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106432:	83 c4 10             	add    $0x10,%esp
80106435:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010643a:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106440:	73 35                	jae    80106477 <setupkvm+0x6d>
                (uint)k->phys_start, k->perm) < 0) {
80106442:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106445:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106448:	29 c1                	sub    %eax,%ecx
8010644a:	83 ec 08             	sub    $0x8,%esp
8010644d:	ff 73 0c             	pushl  0xc(%ebx)
80106450:	50                   	push   %eax
80106451:	8b 13                	mov    (%ebx),%edx
80106453:	89 f0                	mov    %esi,%eax
80106455:	e8 c1 f9 ff ff       	call   80105e1b <mappages>
8010645a:	83 c4 10             	add    $0x10,%esp
8010645d:	85 c0                	test   %eax,%eax
8010645f:	78 05                	js     80106466 <setupkvm+0x5c>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106461:	83 c3 10             	add    $0x10,%ebx
80106464:	eb d4                	jmp    8010643a <setupkvm+0x30>
      freevm(pgdir);
80106466:	83 ec 0c             	sub    $0xc,%esp
80106469:	56                   	push   %esi
8010646a:	e8 2b ff ff ff       	call   8010639a <freevm>
      return 0;
8010646f:	83 c4 10             	add    $0x10,%esp
80106472:	be 00 00 00 00       	mov    $0x0,%esi
}
80106477:	89 f0                	mov    %esi,%eax
80106479:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010647c:	5b                   	pop    %ebx
8010647d:	5e                   	pop    %esi
8010647e:	5d                   	pop    %ebp
8010647f:	c3                   	ret    

80106480 <kvmalloc>:
{
80106480:	55                   	push   %ebp
80106481:	89 e5                	mov    %esp,%ebp
80106483:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106486:	e8 7f ff ff ff       	call   8010640a <setupkvm>
8010648b:	a3 04 55 14 80       	mov    %eax,0x80145504
  switchkvm();
80106490:	e8 48 fb ff ff       	call   80105fdd <switchkvm>
}
80106495:	c9                   	leave  
80106496:	c3                   	ret    

80106497 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106497:	55                   	push   %ebp
80106498:	89 e5                	mov    %esp,%ebp
8010649a:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010649d:	b9 00 00 00 00       	mov    $0x0,%ecx
801064a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801064a5:	8b 45 08             	mov    0x8(%ebp),%eax
801064a8:	e8 f6 f8 ff ff       	call   80105da3 <walkpgdir>
  if(pte == 0)
801064ad:	85 c0                	test   %eax,%eax
801064af:	74 05                	je     801064b6 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801064b1:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801064b4:	c9                   	leave  
801064b5:	c3                   	ret    
    panic("clearpteu");
801064b6:	83 ec 0c             	sub    $0xc,%esp
801064b9:	68 0e 70 10 80       	push   $0x8010700e
801064be:	e8 85 9e ff ff       	call   80100348 <panic>

801064c3 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, int pid)
{
801064c3:	55                   	push   %ebp
801064c4:	89 e5                	mov    %esp,%ebp
801064c6:	57                   	push   %edi
801064c7:	56                   	push   %esi
801064c8:	53                   	push   %ebx
801064c9:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801064cc:	e8 39 ff ff ff       	call   8010640a <setupkvm>
801064d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
801064d4:	85 c0                	test   %eax,%eax
801064d6:	0f 84 d1 00 00 00    	je     801065ad <copyuvm+0xea>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801064dc:	bf 00 00 00 00       	mov    $0x0,%edi
801064e1:	89 fe                	mov    %edi,%esi
801064e3:	3b 75 0c             	cmp    0xc(%ebp),%esi
801064e6:	0f 83 c1 00 00 00    	jae    801065ad <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801064ec:	89 75 e4             	mov    %esi,-0x1c(%ebp)
801064ef:	b9 00 00 00 00       	mov    $0x0,%ecx
801064f4:	89 f2                	mov    %esi,%edx
801064f6:	8b 45 08             	mov    0x8(%ebp),%eax
801064f9:	e8 a5 f8 ff ff       	call   80105da3 <walkpgdir>
801064fe:	85 c0                	test   %eax,%eax
80106500:	74 70                	je     80106572 <copyuvm+0xaf>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106502:	8b 18                	mov    (%eax),%ebx
80106504:	f6 c3 01             	test   $0x1,%bl
80106507:	74 76                	je     8010657f <copyuvm+0xbc>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106509:	89 df                	mov    %ebx,%edi
8010650b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    flags = PTE_FLAGS(*pte);
80106511:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106517:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    if((mem = kalloc(pid)) == 0)
8010651a:	83 ec 0c             	sub    $0xc,%esp
8010651d:	ff 75 10             	pushl  0x10(%ebp)
80106520:	e8 27 bc ff ff       	call   8010214c <kalloc>
80106525:	89 c3                	mov    %eax,%ebx
80106527:	83 c4 10             	add    $0x10,%esp
8010652a:	85 c0                	test   %eax,%eax
8010652c:	74 6a                	je     80106598 <copyuvm+0xd5>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010652e:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80106534:	83 ec 04             	sub    $0x4,%esp
80106537:	68 00 10 00 00       	push   $0x1000
8010653c:	57                   	push   %edi
8010653d:	50                   	push   %eax
8010653e:	e8 32 d9 ff ff       	call   80103e75 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106543:	83 c4 08             	add    $0x8,%esp
80106546:	ff 75 e0             	pushl  -0x20(%ebp)
80106549:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010654f:	50                   	push   %eax
80106550:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106555:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106558:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010655b:	e8 bb f8 ff ff       	call   80105e1b <mappages>
80106560:	83 c4 10             	add    $0x10,%esp
80106563:	85 c0                	test   %eax,%eax
80106565:	78 25                	js     8010658c <copyuvm+0xc9>
  for(i = 0; i < sz; i += PGSIZE){
80106567:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010656d:	e9 71 ff ff ff       	jmp    801064e3 <copyuvm+0x20>
      panic("copyuvm: pte should exist");
80106572:	83 ec 0c             	sub    $0xc,%esp
80106575:	68 18 70 10 80       	push   $0x80107018
8010657a:	e8 c9 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
8010657f:	83 ec 0c             	sub    $0xc,%esp
80106582:	68 32 70 10 80       	push   $0x80107032
80106587:	e8 bc 9d ff ff       	call   80100348 <panic>
      kfree(mem);
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	53                   	push   %ebx
80106590:	e8 70 ba ff ff       	call   80102005 <kfree>
      goto bad;
80106595:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106598:	83 ec 0c             	sub    $0xc,%esp
8010659b:	ff 75 dc             	pushl  -0x24(%ebp)
8010659e:	e8 f7 fd ff ff       	call   8010639a <freevm>
  return 0;
801065a3:	83 c4 10             	add    $0x10,%esp
801065a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801065ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065b3:	5b                   	pop    %ebx
801065b4:	5e                   	pop    %esi
801065b5:	5f                   	pop    %edi
801065b6:	5d                   	pop    %ebp
801065b7:	c3                   	ret    

801065b8 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801065b8:	55                   	push   %ebp
801065b9:	89 e5                	mov    %esp,%ebp
801065bb:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065be:	b9 00 00 00 00       	mov    $0x0,%ecx
801065c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801065c6:	8b 45 08             	mov    0x8(%ebp),%eax
801065c9:	e8 d5 f7 ff ff       	call   80105da3 <walkpgdir>
  if((*pte & PTE_P) == 0)
801065ce:	8b 00                	mov    (%eax),%eax
801065d0:	a8 01                	test   $0x1,%al
801065d2:	74 10                	je     801065e4 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801065d4:	a8 04                	test   $0x4,%al
801065d6:	74 13                	je     801065eb <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065dd:	05 00 00 00 80       	add    $0x80000000,%eax
}
801065e2:	c9                   	leave  
801065e3:	c3                   	ret    
    return 0;
801065e4:	b8 00 00 00 00       	mov    $0x0,%eax
801065e9:	eb f7                	jmp    801065e2 <uva2ka+0x2a>
    return 0;
801065eb:	b8 00 00 00 00       	mov    $0x0,%eax
801065f0:	eb f0                	jmp    801065e2 <uva2ka+0x2a>

801065f2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801065f2:	55                   	push   %ebp
801065f3:	89 e5                	mov    %esp,%ebp
801065f5:	57                   	push   %edi
801065f6:	56                   	push   %esi
801065f7:	53                   	push   %ebx
801065f8:	83 ec 0c             	sub    $0xc,%esp
801065fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801065fe:	eb 25                	jmp    80106625 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106600:	8b 55 0c             	mov    0xc(%ebp),%edx
80106603:	29 f2                	sub    %esi,%edx
80106605:	01 d0                	add    %edx,%eax
80106607:	83 ec 04             	sub    $0x4,%esp
8010660a:	53                   	push   %ebx
8010660b:	ff 75 10             	pushl  0x10(%ebp)
8010660e:	50                   	push   %eax
8010660f:	e8 61 d8 ff ff       	call   80103e75 <memmove>
    len -= n;
80106614:	29 df                	sub    %ebx,%edi
    buf += n;
80106616:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106619:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
8010661f:	89 45 0c             	mov    %eax,0xc(%ebp)
80106622:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106625:	85 ff                	test   %edi,%edi
80106627:	74 2f                	je     80106658 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106629:	8b 75 0c             	mov    0xc(%ebp),%esi
8010662c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106632:	83 ec 08             	sub    $0x8,%esp
80106635:	56                   	push   %esi
80106636:	ff 75 08             	pushl  0x8(%ebp)
80106639:	e8 7a ff ff ff       	call   801065b8 <uva2ka>
    if(pa0 == 0)
8010663e:	83 c4 10             	add    $0x10,%esp
80106641:	85 c0                	test   %eax,%eax
80106643:	74 20                	je     80106665 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106645:	89 f3                	mov    %esi,%ebx
80106647:	2b 5d 0c             	sub    0xc(%ebp),%ebx
8010664a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106650:	39 df                	cmp    %ebx,%edi
80106652:	73 ac                	jae    80106600 <copyout+0xe>
      n = len;
80106654:	89 fb                	mov    %edi,%ebx
80106656:	eb a8                	jmp    80106600 <copyout+0xe>
  }
  return 0;
80106658:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010665d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106660:	5b                   	pop    %ebx
80106661:	5e                   	pop    %esi
80106662:	5f                   	pop    %edi
80106663:	5d                   	pop    %ebp
80106664:	c3                   	ret    
      return -1;
80106665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666a:	eb f1                	jmp    8010665d <copyout+0x6b>

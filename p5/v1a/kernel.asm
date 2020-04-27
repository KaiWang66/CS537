
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:
8010000c:	0f 20 e0             	mov    %cr4,%eax
8010000f:	83 c8 10             	or     $0x10,%eax
80100012:	0f 22 e0             	mov    %eax,%cr4
80100015:	b8 00 80 12 00       	mov    $0x128000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc d0 a5 12 80       	mov    $0x8012a5d0,%esp
8010002d:	b8 11 2b 10 80       	mov    $0x80102b11,%eax
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
80100041:	68 e0 a5 12 80       	push   $0x8012a5e0
80100046:	e8 f7 3b 00 00       	call   80103c42 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 30 ed 12 80    	mov    0x8012ed30,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc ec 12 80    	cmp    $0x8012ecdc,%ebx
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
80100077:	68 e0 a5 12 80       	push   $0x8012a5e0
8010007c:	e8 26 3c 00 00       	call   80103ca7 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 a2 39 00 00       	call   80103a2e <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 2c ed 12 80    	mov    0x8012ed2c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc ec 12 80    	cmp    $0x8012ecdc,%ebx
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
801000c5:	68 e0 a5 12 80       	push   $0x8012a5e0
801000ca:	e8 d8 3b 00 00       	call   80103ca7 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 54 39 00 00       	call   80103a2e <acquiresleep>
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
801000ea:	68 40 65 10 80       	push   $0x80106540
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 51 65 10 80       	push   $0x80106551
80100100:	68 e0 a5 12 80       	push   $0x8012a5e0
80100105:	e8 fc 39 00 00       	call   80103b06 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 2c ed 12 80 dc 	movl   $0x8012ecdc,0x8012ed2c
80100111:	ec 12 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 30 ed 12 80 dc 	movl   $0x8012ecdc,0x8012ed30
8010011b:	ec 12 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 a6 12 80       	mov    $0x8012a614,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 dc ec 12 80 	movl   $0x8012ecdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 58 65 10 80       	push   $0x80106558
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 b3 38 00 00       	call   801039fb <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 30 ed 12 80    	mov    %ebx,0x8012ed30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc ec 12 80    	cmp    $0x8012ecdc,%ebx
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
80100190:	e8 77 1c 00 00       	call   80101e0c <iderw>
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
801001a8:	e8 0b 39 00 00       	call   80103ab8 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 4c 1c 00 00       	call   80101e0c <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 5f 65 10 80       	push   $0x8010655f
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
801001e4:	e8 cf 38 00 00       	call   80103ab8 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 84 38 00 00       	call   80103a7d <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 a5 12 80 	movl   $0x8012a5e0,(%esp)
80100200:	e8 3d 3a 00 00       	call   80103c42 <acquire>
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
80100227:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 dc ec 12 80 	movl   $0x8012ecdc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 30 ed 12 80       	mov    0x8012ed30,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 30 ed 12 80    	mov    %ebx,0x8012ed30
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 a5 12 80       	push   $0x8012a5e0
8010024c:	e8 56 3a 00 00       	call   80103ca7 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 66 65 10 80       	push   $0x80106566
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
8010027b:	e8 c3 13 00 00       	call   80101643 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 95 12 80 	movl   $0x80129520,(%esp)
8010028a:	e8 b3 39 00 00       	call   80103c42 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ef 12 80       	mov    0x8012efc0,%eax
8010029f:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 f7 2f 00 00       	call   801032a3 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 95 12 80       	push   $0x80129520
801002ba:	68 c0 ef 12 80       	push   $0x8012efc0
801002bf:	e8 83 34 00 00       	call   80103747 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 12 80       	push   $0x80129520
801002d1:	e8 d1 39 00 00       	call   80103ca7 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 a3 12 00 00       	call   80101581 <ilock>
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
801002f1:	89 15 c0 ef 12 80    	mov    %edx,0x8012efc0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 ef 12 80 	movzbl -0x7fed10c0(%edx),%ecx
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
80100324:	a3 c0 ef 12 80       	mov    %eax,0x8012efc0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 95 12 80       	push   $0x80129520
80100331:	e8 71 39 00 00       	call   80103ca7 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 43 12 00 00       	call   80101581 <ilock>
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
80100350:	c7 05 54 95 12 80 00 	movl   $0x0,0x80129554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 cc 20 00 00       	call   8010242b <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 6d 65 10 80       	push   $0x8010656d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 bb 6e 10 80 	movl   $0x80106ebb,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 8d 37 00 00       	call   80103b21 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 81 65 10 80       	push   $0x80106581
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 95 12 80 01 	movl   $0x1,0x80129558
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
8010049e:	68 85 65 10 80       	push   $0x80106585
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 aa 38 00 00       	call   80103d69 <memmove>
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
801004d9:	e8 10 38 00 00       	call   80103cee <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 95 12 80 00 	cmpl   $0x0,0x80129558
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
80100506:	e8 1d 4c 00 00       	call   80105128 <uartputc>
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
8010051f:	e8 04 4c 00 00       	call   80105128 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 f8 4b 00 00       	call   80105128 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 ec 4b 00 00       	call   80105128 <uartputc>
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
80100576:	0f b6 92 b0 65 10 80 	movzbl -0x7fef9a50(%edx),%edx
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
801005be:	e8 80 10 00 00       	call   80101643 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 95 12 80 	movl   $0x80129520,(%esp)
801005ca:	e8 73 36 00 00       	call   80103c42 <acquire>
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
801005ec:	68 20 95 12 80       	push   $0x80129520
801005f1:	e8 b1 36 00 00       	call   80103ca7 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 80 0f 00 00       	call   80101581 <ilock>

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
80100614:	a1 54 95 12 80       	mov    0x80129554,%eax
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
80100633:	68 20 95 12 80       	push   $0x80129520
80100638:	e8 05 36 00 00       	call   80103c42 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 9f 65 10 80       	push   $0x8010659f
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
801006ee:	be 98 65 10 80       	mov    $0x80106598,%esi
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
8010072f:	68 20 95 12 80       	push   $0x80129520
80100734:	e8 6e 35 00 00       	call   80103ca7 <release>
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
8010074a:	68 20 95 12 80       	push   $0x80129520
8010074f:	e8 ee 34 00 00       	call   80103c42 <acquire>
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
80100772:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 ef 12 80    	sub    0x8012efc0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 ef 12 80    	mov    %edx,0x8012efc8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 ef 12 80    	mov    %cl,-0x7fed10c0(%eax)
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
801007bc:	a1 c0 ef 12 80       	mov    0x8012efc0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 ef 12 80    	cmp    %eax,0x8012efc8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
801007d1:	a3 c4 ef 12 80       	mov    %eax,0x8012efc4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 ef 12 80       	push   $0x8012efc0
801007de:	e8 c9 30 00 00       	call   801038ac <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 c8 ef 12 80       	mov    %eax,0x8012efc8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
801007fc:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 40 ef 12 80 0a 	cmpb   $0xa,-0x7fed10c0(%edx)
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
8010084a:	a1 c8 ef 12 80       	mov    0x8012efc8,%eax
8010084f:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 ef 12 80       	mov    %eax,0x8012efc8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 95 12 80       	push   $0x80129520
80100873:	e8 2f 34 00 00       	call   80103ca7 <release>
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
80100887:	e8 bd 30 00 00       	call   80103949 <procdump>
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
80100894:	68 a8 65 10 80       	push   $0x801065a8
80100899:	68 20 95 12 80       	push   $0x80129520
8010089e:	e8 63 32 00 00       	call   80103b06 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 8c f9 12 80 ac 	movl   $0x801005ac,0x8012f98c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 88 f9 12 80 68 	movl   $0x80100268,0x8012f988
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 95 12 80 01 	movl   $0x1,0x80129554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 b1 16 00 00       	call   80101f7e <ioapicenable>
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
801008de:	e8 c0 29 00 00       	call   801032a3 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 6d 1f 00 00       	call   8010285b <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 e8 12 00 00       	call   80101be1 <namei>
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
80100906:	e8 76 0c 00 00       	call   80101581 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 57 0e 00 00       	call   80101773 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 dd 02 00 00    	je     80100c09 <exec+0x337>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 f3 0d 00 00       	call   80101728 <iunlockput>
    end_op();
80100935:	e8 9b 1f 00 00       	call   801028d5 <end_op>
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
8010094a:	e8 86 1f 00 00       	call   801028d5 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 c1 65 10 80       	push   $0x801065c1
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
80100972:	e8 71 59 00 00       	call   801062e8 <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 06 01 00 00    	je     80100a8b <exec+0x1b9>
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
801009ac:	0f 8e 98 00 00 00    	jle    80100a4a <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 ab 0d 00 00       	call   80101773 <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 b7 00 00 00    	jne    80100a8b <exec+0x1b9>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 9c 00 00 00    	jb     80100a8b <exec+0x1b9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 90 00 00 00    	jb     80100a8b <exec+0x1b9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009fb:	83 ec 04             	sub    $0x4,%esp
801009fe:	50                   	push   %eax
801009ff:	57                   	push   %edi
80100a00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a06:	e8 83 57 00 00       	call   8010618e <allocuvm>
80100a0b:	89 c7                	mov    %eax,%edi
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	85 c0                	test   %eax,%eax
80100a12:	74 77                	je     80100a8b <exec+0x1b9>
    if(ph.vaddr % PGSIZE != 0)
80100a14:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a1a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1f:	75 6a                	jne    80100a8b <exec+0x1b9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a21:	83 ec 0c             	sub    $0xc,%esp
80100a24:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a2a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a30:	53                   	push   %ebx
80100a31:	50                   	push   %eax
80100a32:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a38:	e8 1f 56 00 00       	call   8010605c <loaduvm>
80100a3d:	83 c4 20             	add    $0x20,%esp
80100a40:	85 c0                	test   %eax,%eax
80100a42:	0f 89 4f ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a48:	eb 41                	jmp    80100a8b <exec+0x1b9>
  iunlockput(ip);
80100a4a:	83 ec 0c             	sub    $0xc,%esp
80100a4d:	53                   	push   %ebx
80100a4e:	e8 d5 0c 00 00       	call   80101728 <iunlockput>
  end_op();
80100a53:	e8 7d 1e 00 00       	call   801028d5 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 15 57 00 00       	call   8010618e <allocuvm>
80100a79:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a7f:	83 c4 10             	add    $0x10,%esp
80100a82:	85 c0                	test   %eax,%eax
80100a84:	75 24                	jne    80100aaa <exec+0x1d8>
  ip = 0;
80100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a91:	85 c0                	test   %eax,%eax
80100a93:	0f 84 8b fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100a99:	83 ec 0c             	sub    $0xc,%esp
80100a9c:	50                   	push   %eax
80100a9d:	e8 d6 57 00 00       	call   80106278 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 ac 58 00 00       	call   8010636d <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	83 c4 10             	add    $0x10,%esp
80100ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100acc:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100acf:	8b 06                	mov    (%esi),%eax
80100ad1:	85 c0                	test   %eax,%eax
80100ad3:	74 4d                	je     80100b22 <exec+0x250>
    if(argc >= MAXARG)
80100ad5:	83 fb 1f             	cmp    $0x1f,%ebx
80100ad8:	0f 87 0d 01 00 00    	ja     80100beb <exec+0x319>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 a9 33 00 00       	call   80103e90 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 97 33 00 00       	call   80103e90 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 b0 59 00 00       	call   801064bb <copyout>
80100b0b:	83 c4 20             	add    $0x20,%esp
80100b0e:	85 c0                	test   %eax,%eax
80100b10:	0f 88 df 00 00 00    	js     80100bf5 <exec+0x323>
    ustack[3+argc] = sp;
80100b16:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b1d:	83 c3 01             	add    $0x1,%ebx
80100b20:	eb a7                	jmp    80100ac9 <exec+0x1f7>
  ustack[3+argc] = 0;
80100b22:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b29:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2d:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b34:	ff ff ff 
  ustack[1] = argc;
80100b37:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b44:	89 f9                	mov    %edi,%ecx
80100b46:	29 c1                	sub    %eax,%ecx
80100b48:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b4e:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b55:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b57:	50                   	push   %eax
80100b58:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b5e:	50                   	push   %eax
80100b5f:	57                   	push   %edi
80100b60:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b66:	e8 50 59 00 00       	call   801064bb <copyout>
80100b6b:	83 c4 10             	add    $0x10,%esp
80100b6e:	85 c0                	test   %eax,%eax
80100b70:	0f 88 89 00 00 00    	js     80100bff <exec+0x32d>
  for(last=s=path; *s; s++)
80100b76:	8b 55 08             	mov    0x8(%ebp),%edx
80100b79:	89 d0                	mov    %edx,%eax
80100b7b:	eb 03                	jmp    80100b80 <exec+0x2ae>
80100b7d:	83 c0 01             	add    $0x1,%eax
80100b80:	0f b6 08             	movzbl (%eax),%ecx
80100b83:	84 c9                	test   %cl,%cl
80100b85:	74 0a                	je     80100b91 <exec+0x2bf>
    if(*s == '/')
80100b87:	80 f9 2f             	cmp    $0x2f,%cl
80100b8a:	75 f1                	jne    80100b7d <exec+0x2ab>
      last = s+1;
80100b8c:	8d 50 01             	lea    0x1(%eax),%edx
80100b8f:	eb ec                	jmp    80100b7d <exec+0x2ab>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b91:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100b97:	89 f0                	mov    %esi,%eax
80100b99:	83 c0 6c             	add    $0x6c,%eax
80100b9c:	83 ec 04             	sub    $0x4,%esp
80100b9f:	6a 10                	push   $0x10
80100ba1:	52                   	push   %edx
80100ba2:	50                   	push   %eax
80100ba3:	e8 ad 32 00 00       	call   80103e55 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bab:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bb1:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bb4:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bba:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bbc:	8b 46 18             	mov    0x18(%esi),%eax
80100bbf:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bce:	89 34 24             	mov    %esi,(%esp)
80100bd1:	e8 05 53 00 00       	call   80105edb <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 9a 56 00 00       	call   80106278 <freevm>
  return 0;
80100bde:	83 c4 10             	add    $0x10,%esp
80100be1:	b8 00 00 00 00       	mov    $0x0,%eax
80100be6:	e9 57 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf0:	e9 96 fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfa:	e9 8c fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 82 fe ff ff       	jmp    80100a8b <exec+0x1b9>
  return -1;
80100c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0e:	e9 2f fd ff ff       	jmp    80100942 <exec+0x70>

80100c13 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c19:	68 cd 65 10 80       	push   $0x801065cd
80100c1e:	68 e0 ef 12 80       	push   $0x8012efe0
80100c23:	e8 de 2e 00 00       	call   80103b06 <initlock>
}
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	c9                   	leave  
80100c2c:	c3                   	ret    

80100c2d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c2d:	55                   	push   %ebp
80100c2e:	89 e5                	mov    %esp,%ebp
80100c30:	53                   	push   %ebx
80100c31:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c34:	68 e0 ef 12 80       	push   $0x8012efe0
80100c39:	e8 04 30 00 00       	call   80103c42 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb 14 f0 12 80       	mov    $0x8012f014,%ebx
80100c46:	81 fb 74 f9 12 80    	cmp    $0x8012f974,%ebx
80100c4c:	73 29                	jae    80100c77 <filealloc+0x4a>
    if(f->ref == 0){
80100c4e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c52:	74 05                	je     80100c59 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c54:	83 c3 18             	add    $0x18,%ebx
80100c57:	eb ed                	jmp    80100c46 <filealloc+0x19>
      f->ref = 1;
80100c59:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c60:	83 ec 0c             	sub    $0xc,%esp
80100c63:	68 e0 ef 12 80       	push   $0x8012efe0
80100c68:	e8 3a 30 00 00       	call   80103ca7 <release>
      return f;
80100c6d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c70:	89 d8                	mov    %ebx,%eax
80100c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c75:	c9                   	leave  
80100c76:	c3                   	ret    
  release(&ftable.lock);
80100c77:	83 ec 0c             	sub    $0xc,%esp
80100c7a:	68 e0 ef 12 80       	push   $0x8012efe0
80100c7f:	e8 23 30 00 00       	call   80103ca7 <release>
  return 0;
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c8c:	eb e2                	jmp    80100c70 <filealloc+0x43>

80100c8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	53                   	push   %ebx
80100c92:	83 ec 10             	sub    $0x10,%esp
80100c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c98:	68 e0 ef 12 80       	push   $0x8012efe0
80100c9d:	e8 a0 2f 00 00       	call   80103c42 <acquire>
  if(f->ref < 1)
80100ca2:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca5:	83 c4 10             	add    $0x10,%esp
80100ca8:	85 c0                	test   %eax,%eax
80100caa:	7e 1a                	jle    80100cc6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cac:	83 c0 01             	add    $0x1,%eax
80100caf:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cb2:	83 ec 0c             	sub    $0xc,%esp
80100cb5:	68 e0 ef 12 80       	push   $0x8012efe0
80100cba:	e8 e8 2f 00 00       	call   80103ca7 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 d4 65 10 80       	push   $0x801065d4
80100cce:	e8 75 f6 ff ff       	call   80100348 <panic>

80100cd3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cd3:	55                   	push   %ebp
80100cd4:	89 e5                	mov    %esp,%ebp
80100cd6:	53                   	push   %ebx
80100cd7:	83 ec 30             	sub    $0x30,%esp
80100cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cdd:	68 e0 ef 12 80       	push   $0x8012efe0
80100ce2:	e8 5b 2f 00 00       	call   80103c42 <acquire>
  if(f->ref < 1)
80100ce7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cea:	83 c4 10             	add    $0x10,%esp
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 1f                	jle    80100d10 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cf1:	83 e8 01             	sub    $0x1,%eax
80100cf4:	89 43 04             	mov    %eax,0x4(%ebx)
80100cf7:	85 c0                	test   %eax,%eax
80100cf9:	7e 22                	jle    80100d1d <fileclose+0x4a>
    release(&ftable.lock);
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	68 e0 ef 12 80       	push   $0x8012efe0
80100d03:	e8 9f 2f 00 00       	call   80103ca7 <release>
    return;
80100d08:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d0e:	c9                   	leave  
80100d0f:	c3                   	ret    
    panic("fileclose");
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 dc 65 10 80       	push   $0x801065dc
80100d18:	e8 2b f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d1d:	8b 03                	mov    (%ebx),%eax
80100d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d22:	8b 43 08             	mov    0x8(%ebx),%eax
80100d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d28:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d2e:	8b 43 10             	mov    0x10(%ebx),%eax
80100d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d34:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	68 e0 ef 12 80       	push   $0x8012efe0
80100d49:	e8 59 2f 00 00       	call   80103ca7 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 f8 1a 00 00       	call   8010285b <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 62 1b 00 00       	call   801028d5 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 47 21 00 00       	call   80102ecf <pipeclose>
80100d88:	83 c4 10             	add    $0x10,%esp
80100d8b:	e9 7b ff ff ff       	jmp    80100d0b <fileclose+0x38>

80100d90 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d90:	55                   	push   %ebp
80100d91:	89 e5                	mov    %esp,%ebp
80100d93:	53                   	push   %ebx
80100d94:	83 ec 04             	sub    $0x4,%esp
80100d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d9a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d9d:	75 31                	jne    80100dd0 <filestat+0x40>
    ilock(f->ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 73 10             	pushl  0x10(%ebx)
80100da5:	e8 d7 07 00 00       	call   80101581 <ilock>
    stati(f->ip, st);
80100daa:	83 c4 08             	add    $0x8,%esp
80100dad:	ff 75 0c             	pushl  0xc(%ebp)
80100db0:	ff 73 10             	pushl  0x10(%ebx)
80100db3:	e8 90 09 00 00       	call   80101748 <stati>
    iunlock(f->ip);
80100db8:	83 c4 04             	add    $0x4,%esp
80100dbb:	ff 73 10             	pushl  0x10(%ebx)
80100dbe:	e8 80 08 00 00       	call   80101643 <iunlock>
    return 0;
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dce:	c9                   	leave  
80100dcf:	c3                   	ret    
  return -1;
80100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dd5:	eb f4                	jmp    80100dcb <filestat+0x3b>

80100dd7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd7:	55                   	push   %ebp
80100dd8:	89 e5                	mov    %esp,%ebp
80100dda:	56                   	push   %esi
80100ddb:	53                   	push   %ebx
80100ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100ddf:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100de3:	74 70                	je     80100e55 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100de5:	8b 03                	mov    (%ebx),%eax
80100de7:	83 f8 01             	cmp    $0x1,%eax
80100dea:	74 44                	je     80100e30 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100dec:	83 f8 02             	cmp    $0x2,%eax
80100def:	75 57                	jne    80100e48 <fileread+0x71>
    ilock(f->ip);
80100df1:	83 ec 0c             	sub    $0xc,%esp
80100df4:	ff 73 10             	pushl  0x10(%ebx)
80100df7:	e8 85 07 00 00       	call   80101581 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dfc:	ff 75 10             	pushl  0x10(%ebp)
80100dff:	ff 73 14             	pushl  0x14(%ebx)
80100e02:	ff 75 0c             	pushl  0xc(%ebp)
80100e05:	ff 73 10             	pushl  0x10(%ebx)
80100e08:	e8 66 09 00 00       	call   80101773 <readi>
80100e0d:	89 c6                	mov    %eax,%esi
80100e0f:	83 c4 20             	add    $0x20,%esp
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7e 03                	jle    80100e19 <fileread+0x42>
      f->off += r;
80100e16:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 73 10             	pushl  0x10(%ebx)
80100e1f:	e8 1f 08 00 00       	call   80101643 <iunlock>
    return r;
80100e24:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e27:	89 f0                	mov    %esi,%eax
80100e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e2c:	5b                   	pop    %ebx
80100e2d:	5e                   	pop    %esi
80100e2e:	5d                   	pop    %ebp
80100e2f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e30:	83 ec 04             	sub    $0x4,%esp
80100e33:	ff 75 10             	pushl  0x10(%ebp)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 0c             	pushl  0xc(%ebx)
80100e3c:	e8 e6 21 00 00       	call   80103027 <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 e6 65 10 80       	push   $0x801065e6
80100e50:	e8 f3 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e55:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e5a:	eb cb                	jmp    80100e27 <fileread+0x50>

80100e5c <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	57                   	push   %edi
80100e60:	56                   	push   %esi
80100e61:	53                   	push   %ebx
80100e62:	83 ec 1c             	sub    $0x1c,%esp
80100e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e6c:	0f 84 c5 00 00 00    	je     80100f37 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e72:	8b 03                	mov    (%ebx),%eax
80100e74:	83 f8 01             	cmp    $0x1,%eax
80100e77:	74 10                	je     80100e89 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e79:	83 f8 02             	cmp    $0x2,%eax
80100e7c:	0f 85 a8 00 00 00    	jne    80100f2a <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e82:	bf 00 00 00 00       	mov    $0x0,%edi
80100e87:	eb 67                	jmp    80100ef0 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e89:	83 ec 04             	sub    $0x4,%esp
80100e8c:	ff 75 10             	pushl  0x10(%ebp)
80100e8f:	ff 75 0c             	pushl  0xc(%ebp)
80100e92:	ff 73 0c             	pushl  0xc(%ebx)
80100e95:	e8 c1 20 00 00       	call   80102f5b <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 b4 19 00 00       	call   8010285b <begin_op>
      ilock(f->ip);
80100ea7:	83 ec 0c             	sub    $0xc,%esp
80100eaa:	ff 73 10             	pushl  0x10(%ebx)
80100ead:	e8 cf 06 00 00       	call   80101581 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100eb2:	89 f8                	mov    %edi,%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eba:	ff 73 14             	pushl  0x14(%ebx)
80100ebd:	50                   	push   %eax
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 aa 09 00 00       	call   80101870 <writei>
80100ec6:	89 c6                	mov    %eax,%esi
80100ec8:	83 c4 20             	add    $0x20,%esp
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	7e 03                	jle    80100ed2 <filewrite+0x76>
        f->off += r;
80100ecf:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ed2:	83 ec 0c             	sub    $0xc,%esp
80100ed5:	ff 73 10             	pushl  0x10(%ebx)
80100ed8:	e8 66 07 00 00       	call   80101643 <iunlock>
      end_op();
80100edd:	e8 f3 19 00 00       	call   801028d5 <end_op>

      if(r < 0)
80100ee2:	83 c4 10             	add    $0x10,%esp
80100ee5:	85 f6                	test   %esi,%esi
80100ee7:	78 31                	js     80100f1a <filewrite+0xbe>
        break;
      if(r != n1)
80100ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100eec:	75 1f                	jne    80100f0d <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eee:	01 f7                	add    %esi,%edi
    while(i < n){
80100ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ef3:	7d 25                	jge    80100f1a <filewrite+0xbe>
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 9e                	jle    80100ea2 <filewrite+0x46>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f0b:	eb 95                	jmp    80100ea2 <filewrite+0x46>
        panic("short filewrite");
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	68 ef 65 10 80       	push   $0x801065ef
80100f15:	e8 2e f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f1d:	75 1f                	jne    80100f3e <filewrite+0xe2>
80100f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f25:	5b                   	pop    %ebx
80100f26:	5e                   	pop    %esi
80100f27:	5f                   	pop    %edi
80100f28:	5d                   	pop    %ebp
80100f29:	c3                   	ret    
  panic("filewrite");
80100f2a:	83 ec 0c             	sub    $0xc,%esp
80100f2d:	68 f5 65 10 80       	push   $0x801065f5
80100f32:	e8 11 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3c:	eb e4                	jmp    80100f22 <filewrite+0xc6>
    return i == n ? n : -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f43:	eb dd                	jmp    80100f22 <filewrite+0xc6>

80100f45 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	57                   	push   %edi
80100f49:	56                   	push   %esi
80100f4a:	53                   	push   %ebx
80100f4b:	83 ec 0c             	sub    $0xc,%esp
80100f4e:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f50:	eb 03                	jmp    80100f55 <skipelem+0x10>
    path++;
80100f52:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f55:	0f b6 10             	movzbl (%eax),%edx
80100f58:	80 fa 2f             	cmp    $0x2f,%dl
80100f5b:	74 f5                	je     80100f52 <skipelem+0xd>
  if(*path == 0)
80100f5d:	84 d2                	test   %dl,%dl
80100f5f:	74 59                	je     80100fba <skipelem+0x75>
80100f61:	89 c3                	mov    %eax,%ebx
80100f63:	eb 03                	jmp    80100f68 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f65:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f68:	0f b6 13             	movzbl (%ebx),%edx
80100f6b:	80 fa 2f             	cmp    $0x2f,%dl
80100f6e:	0f 95 c1             	setne  %cl
80100f71:	84 d2                	test   %dl,%dl
80100f73:	0f 95 c2             	setne  %dl
80100f76:	84 d1                	test   %dl,%cl
80100f78:	75 eb                	jne    80100f65 <skipelem+0x20>
  len = path - s;
80100f7a:	89 de                	mov    %ebx,%esi
80100f7c:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f7e:	83 fe 0d             	cmp    $0xd,%esi
80100f81:	7e 11                	jle    80100f94 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f83:	83 ec 04             	sub    $0x4,%esp
80100f86:	6a 0e                	push   $0xe
80100f88:	50                   	push   %eax
80100f89:	57                   	push   %edi
80100f8a:	e8 da 2d 00 00       	call   80103d69 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 ca 2d 00 00       	call   80103d69 <memmove>
    name[len] = 0;
80100f9f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 03                	jmp    80100fab <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fa8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fab:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fae:	74 f8                	je     80100fa8 <skipelem+0x63>
  return path;
}
80100fb0:	89 d8                	mov    %ebx,%eax
80100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb5:	5b                   	pop    %ebx
80100fb6:	5e                   	pop    %esi
80100fb7:	5f                   	pop    %edi
80100fb8:	5d                   	pop    %ebp
80100fb9:	c3                   	ret    
    return 0;
80100fba:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fbf:	eb ef                	jmp    80100fb0 <skipelem+0x6b>

80100fc1 <bzero>:
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	53                   	push   %ebx
80100fc5:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fc8:	52                   	push   %edx
80100fc9:	50                   	push   %eax
80100fca:	e8 9d f1 ff ff       	call   8010016c <bread>
80100fcf:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fd1:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fd4:	83 c4 0c             	add    $0xc,%esp
80100fd7:	68 00 02 00 00       	push   $0x200
80100fdc:	6a 00                	push   $0x0
80100fde:	50                   	push   %eax
80100fdf:	e8 0a 2d 00 00       	call   80103cee <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 98 19 00 00       	call   80102984 <log_write>
  brelse(bp);
80100fec:	89 1c 24             	mov    %ebx,(%esp)
80100fef:	e8 e1 f1 ff ff       	call   801001d5 <brelse>
}
80100ff4:	83 c4 10             	add    $0x10,%esp
80100ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <balloc>:
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	57                   	push   %edi
80101000:	56                   	push   %esi
80101001:	53                   	push   %ebx
80101002:	83 ec 1c             	sub    $0x1c,%esp
80101005:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101008:	be 00 00 00 00       	mov    $0x0,%esi
8010100d:	eb 14                	jmp    80101023 <balloc+0x27>
    brelse(bp);
8010100f:	83 ec 0c             	sub    $0xc,%esp
80101012:	ff 75 e4             	pushl  -0x1c(%ebp)
80101015:	e8 bb f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010101a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101020:	83 c4 10             	add    $0x10,%esp
80101023:	39 35 e0 f9 12 80    	cmp    %esi,0x8012f9e0
80101029:	76 75                	jbe    801010a0 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010102b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101031:	85 f6                	test   %esi,%esi
80101033:	0f 49 c6             	cmovns %esi,%eax
80101036:	c1 f8 0c             	sar    $0xc,%eax
80101039:	03 05 f8 f9 12 80    	add    0x8012f9f8,%eax
8010103f:	83 ec 08             	sub    $0x8,%esp
80101042:	50                   	push   %eax
80101043:	ff 75 d8             	pushl  -0x28(%ebp)
80101046:	e8 21 f1 ff ff       	call   8010016c <bread>
8010104b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010104e:	83 c4 10             	add    $0x10,%esp
80101051:	b8 00 00 00 00       	mov    $0x0,%eax
80101056:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010105b:	7f b2                	jg     8010100f <balloc+0x13>
8010105d:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80101060:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101063:	3b 1d e0 f9 12 80    	cmp    0x8012f9e0,%ebx
80101069:	73 a4                	jae    8010100f <balloc+0x13>
      m = 1 << (bi % 8);
8010106b:	99                   	cltd   
8010106c:	c1 ea 1d             	shr    $0x1d,%edx
8010106f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101072:	83 e1 07             	and    $0x7,%ecx
80101075:	29 d1                	sub    %edx,%ecx
80101077:	ba 01 00 00 00       	mov    $0x1,%edx
8010107c:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010107e:	8d 48 07             	lea    0x7(%eax),%ecx
80101081:	85 c0                	test   %eax,%eax
80101083:	0f 49 c8             	cmovns %eax,%ecx
80101086:	c1 f9 03             	sar    $0x3,%ecx
80101089:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010108c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010108f:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101094:	0f b6 f9             	movzbl %cl,%edi
80101097:	85 d7                	test   %edx,%edi
80101099:	74 12                	je     801010ad <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010109b:	83 c0 01             	add    $0x1,%eax
8010109e:	eb b6                	jmp    80101056 <balloc+0x5a>
  panic("balloc: out of blocks");
801010a0:	83 ec 0c             	sub    $0xc,%esp
801010a3:	68 ff 65 10 80       	push   $0x801065ff
801010a8:	e8 9b f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010ad:	09 ca                	or     %ecx,%edx
801010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b2:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010b5:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010b9:	83 ec 0c             	sub    $0xc,%esp
801010bc:	89 c6                	mov    %eax,%esi
801010be:	50                   	push   %eax
801010bf:	e8 c0 18 00 00       	call   80102984 <log_write>
        brelse(bp);
801010c4:	89 34 24             	mov    %esi,(%esp)
801010c7:	e8 09 f1 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010cc:	89 da                	mov    %ebx,%edx
801010ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010d1:	e8 eb fe ff ff       	call   80100fc1 <bzero>
}
801010d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010dc:	5b                   	pop    %ebx
801010dd:	5e                   	pop    %esi
801010de:	5f                   	pop    %edi
801010df:	5d                   	pop    %ebp
801010e0:	c3                   	ret    

801010e1 <bmap>:
{
801010e1:	55                   	push   %ebp
801010e2:	89 e5                	mov    %esp,%ebp
801010e4:	57                   	push   %edi
801010e5:	56                   	push   %esi
801010e6:	53                   	push   %ebx
801010e7:	83 ec 1c             	sub    $0x1c,%esp
801010ea:	89 c6                	mov    %eax,%esi
801010ec:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801010ee:	83 fa 0b             	cmp    $0xb,%edx
801010f1:	77 17                	ja     8010110a <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
801010f3:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
801010f7:	85 db                	test   %ebx,%ebx
801010f9:	75 4a                	jne    80101145 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010fb:	8b 00                	mov    (%eax),%eax
801010fd:	e8 fa fe ff ff       	call   80100ffc <balloc>
80101102:	89 c3                	mov    %eax,%ebx
80101104:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101108:	eb 3b                	jmp    80101145 <bmap+0x64>
  bn -= NDIRECT;
8010110a:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010110d:	83 fb 7f             	cmp    $0x7f,%ebx
80101110:	77 68                	ja     8010117a <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101112:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101118:	85 c0                	test   %eax,%eax
8010111a:	74 33                	je     8010114f <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010111c:	83 ec 08             	sub    $0x8,%esp
8010111f:	50                   	push   %eax
80101120:	ff 36                	pushl  (%esi)
80101122:	e8 45 f0 ff ff       	call   8010016c <bread>
80101127:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101129:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
8010112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101130:	8b 18                	mov    (%eax),%ebx
80101132:	83 c4 10             	add    $0x10,%esp
80101135:	85 db                	test   %ebx,%ebx
80101137:	74 25                	je     8010115e <bmap+0x7d>
    brelse(bp);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	57                   	push   %edi
8010113d:	e8 93 f0 ff ff       	call   801001d5 <brelse>
    return addr;
80101142:	83 c4 10             	add    $0x10,%esp
}
80101145:	89 d8                	mov    %ebx,%eax
80101147:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114a:	5b                   	pop    %ebx
8010114b:	5e                   	pop    %esi
8010114c:	5f                   	pop    %edi
8010114d:	5d                   	pop    %ebp
8010114e:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010114f:	8b 06                	mov    (%esi),%eax
80101151:	e8 a6 fe ff ff       	call   80100ffc <balloc>
80101156:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010115c:	eb be                	jmp    8010111c <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
8010115e:	8b 06                	mov    (%esi),%eax
80101160:	e8 97 fe ff ff       	call   80100ffc <balloc>
80101165:	89 c3                	mov    %eax,%ebx
80101167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010116a:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
8010116c:	83 ec 0c             	sub    $0xc,%esp
8010116f:	57                   	push   %edi
80101170:	e8 0f 18 00 00       	call   80102984 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 15 66 10 80       	push   $0x80106615
80101182:	e8 c1 f1 ff ff       	call   80100348 <panic>

80101187 <iget>:
{
80101187:	55                   	push   %ebp
80101188:	89 e5                	mov    %esp,%ebp
8010118a:	57                   	push   %edi
8010118b:	56                   	push   %esi
8010118c:	53                   	push   %ebx
8010118d:	83 ec 28             	sub    $0x28,%esp
80101190:	89 c7                	mov    %eax,%edi
80101192:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101195:	68 00 fa 12 80       	push   $0x8012fa00
8010119a:	e8 a3 2a 00 00       	call   80103c42 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010119f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011a7:	bb 34 fa 12 80       	mov    $0x8012fa34,%ebx
801011ac:	eb 0a                	jmp    801011b8 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ae:	85 f6                	test   %esi,%esi
801011b0:	74 3b                	je     801011ed <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011b8:	81 fb 54 16 13 80    	cmp    $0x80131654,%ebx
801011be:	73 35                	jae    801011f5 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011c0:	8b 43 08             	mov    0x8(%ebx),%eax
801011c3:	85 c0                	test   %eax,%eax
801011c5:	7e e7                	jle    801011ae <iget+0x27>
801011c7:	39 3b                	cmp    %edi,(%ebx)
801011c9:	75 e3                	jne    801011ae <iget+0x27>
801011cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011ce:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011d1:	75 db                	jne    801011ae <iget+0x27>
      ip->ref++;
801011d3:	83 c0 01             	add    $0x1,%eax
801011d6:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011d9:	83 ec 0c             	sub    $0xc,%esp
801011dc:	68 00 fa 12 80       	push   $0x8012fa00
801011e1:	e8 c1 2a 00 00       	call   80103ca7 <release>
      return ip;
801011e6:	83 c4 10             	add    $0x10,%esp
801011e9:	89 de                	mov    %ebx,%esi
801011eb:	eb 32                	jmp    8010121f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ed:	85 c0                	test   %eax,%eax
801011ef:	75 c1                	jne    801011b2 <iget+0x2b>
      empty = ip;
801011f1:	89 de                	mov    %ebx,%esi
801011f3:	eb bd                	jmp    801011b2 <iget+0x2b>
  if(empty == 0)
801011f5:	85 f6                	test   %esi,%esi
801011f7:	74 30                	je     80101229 <iget+0xa2>
  ip->dev = dev;
801011f9:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011fe:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101201:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101208:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010120f:	83 ec 0c             	sub    $0xc,%esp
80101212:	68 00 fa 12 80       	push   $0x8012fa00
80101217:	e8 8b 2a 00 00       	call   80103ca7 <release>
  return ip;
8010121c:	83 c4 10             	add    $0x10,%esp
}
8010121f:	89 f0                	mov    %esi,%eax
80101221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101224:	5b                   	pop    %ebx
80101225:	5e                   	pop    %esi
80101226:	5f                   	pop    %edi
80101227:	5d                   	pop    %ebp
80101228:	c3                   	ret    
    panic("iget: no inodes");
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	68 28 66 10 80       	push   $0x80106628
80101231:	e8 12 f1 ff ff       	call   80100348 <panic>

80101236 <readsb>:
{
80101236:	55                   	push   %ebp
80101237:	89 e5                	mov    %esp,%ebp
80101239:	53                   	push   %ebx
8010123a:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
8010123d:	6a 01                	push   $0x1
8010123f:	ff 75 08             	pushl  0x8(%ebp)
80101242:	e8 25 ef ff ff       	call   8010016c <bread>
80101247:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101249:	8d 40 5c             	lea    0x5c(%eax),%eax
8010124c:	83 c4 0c             	add    $0xc,%esp
8010124f:	6a 1c                	push   $0x1c
80101251:	50                   	push   %eax
80101252:	ff 75 0c             	pushl  0xc(%ebp)
80101255:	e8 0f 2b 00 00       	call   80103d69 <memmove>
  brelse(bp);
8010125a:	89 1c 24             	mov    %ebx,(%esp)
8010125d:	e8 73 ef ff ff       	call   801001d5 <brelse>
}
80101262:	83 c4 10             	add    $0x10,%esp
80101265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101268:	c9                   	leave  
80101269:	c3                   	ret    

8010126a <bfree>:
{
8010126a:	55                   	push   %ebp
8010126b:	89 e5                	mov    %esp,%ebp
8010126d:	56                   	push   %esi
8010126e:	53                   	push   %ebx
8010126f:	89 c6                	mov    %eax,%esi
80101271:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
80101273:	83 ec 08             	sub    $0x8,%esp
80101276:	68 e0 f9 12 80       	push   $0x8012f9e0
8010127b:	50                   	push   %eax
8010127c:	e8 b5 ff ff ff       	call   80101236 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101281:	89 d8                	mov    %ebx,%eax
80101283:	c1 e8 0c             	shr    $0xc,%eax
80101286:	03 05 f8 f9 12 80    	add    0x8012f9f8,%eax
8010128c:	83 c4 08             	add    $0x8,%esp
8010128f:	50                   	push   %eax
80101290:	56                   	push   %esi
80101291:	e8 d6 ee ff ff       	call   8010016c <bread>
80101296:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101298:	89 d9                	mov    %ebx,%ecx
8010129a:	83 e1 07             	and    $0x7,%ecx
8010129d:	b8 01 00 00 00       	mov    $0x1,%eax
801012a2:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012a4:	83 c4 10             	add    $0x10,%esp
801012a7:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012ad:	c1 fb 03             	sar    $0x3,%ebx
801012b0:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012b5:	0f b6 ca             	movzbl %dl,%ecx
801012b8:	85 c1                	test   %eax,%ecx
801012ba:	74 23                	je     801012df <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012bc:	f7 d0                	not    %eax
801012be:	21 d0                	and    %edx,%eax
801012c0:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012c4:	83 ec 0c             	sub    $0xc,%esp
801012c7:	56                   	push   %esi
801012c8:	e8 b7 16 00 00       	call   80102984 <log_write>
  brelse(bp);
801012cd:	89 34 24             	mov    %esi,(%esp)
801012d0:	e8 00 ef ff ff       	call   801001d5 <brelse>
}
801012d5:	83 c4 10             	add    $0x10,%esp
801012d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012db:	5b                   	pop    %ebx
801012dc:	5e                   	pop    %esi
801012dd:	5d                   	pop    %ebp
801012de:	c3                   	ret    
    panic("freeing free block");
801012df:	83 ec 0c             	sub    $0xc,%esp
801012e2:	68 38 66 10 80       	push   $0x80106638
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 4b 66 10 80       	push   $0x8010664b
801012f8:	68 00 fa 12 80       	push   $0x8012fa00
801012fd:	e8 04 28 00 00       	call   80103b06 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 52 66 10 80       	push   $0x80106652
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 40 fa 12 80       	add    $0x8012fa40,%eax
80101321:	50                   	push   %eax
80101322:	e8 d4 26 00 00       	call   801039fb <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101327:	83 c3 01             	add    $0x1,%ebx
8010132a:	83 c4 10             	add    $0x10,%esp
8010132d:	83 fb 31             	cmp    $0x31,%ebx
80101330:	7e da                	jle    8010130c <iinit+0x20>
  readsb(dev, &sb);
80101332:	83 ec 08             	sub    $0x8,%esp
80101335:	68 e0 f9 12 80       	push   $0x8012f9e0
8010133a:	ff 75 08             	pushl  0x8(%ebp)
8010133d:	e8 f4 fe ff ff       	call   80101236 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101342:	ff 35 f8 f9 12 80    	pushl  0x8012f9f8
80101348:	ff 35 f4 f9 12 80    	pushl  0x8012f9f4
8010134e:	ff 35 f0 f9 12 80    	pushl  0x8012f9f0
80101354:	ff 35 ec f9 12 80    	pushl  0x8012f9ec
8010135a:	ff 35 e8 f9 12 80    	pushl  0x8012f9e8
80101360:	ff 35 e4 f9 12 80    	pushl  0x8012f9e4
80101366:	ff 35 e0 f9 12 80    	pushl  0x8012f9e0
8010136c:	68 b8 66 10 80       	push   $0x801066b8
80101371:	e8 95 f2 ff ff       	call   8010060b <cprintf>
}
80101376:	83 c4 30             	add    $0x30,%esp
80101379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <ialloc>:
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	57                   	push   %edi
80101382:	56                   	push   %esi
80101383:	53                   	push   %ebx
80101384:	83 ec 1c             	sub    $0x1c,%esp
80101387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010138d:	bb 01 00 00 00       	mov    $0x1,%ebx
80101392:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101395:	39 1d e8 f9 12 80    	cmp    %ebx,0x8012f9e8
8010139b:	76 3f                	jbe    801013dc <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010139d:	89 d8                	mov    %ebx,%eax
8010139f:	c1 e8 03             	shr    $0x3,%eax
801013a2:	03 05 f4 f9 12 80    	add    0x8012f9f4,%eax
801013a8:	83 ec 08             	sub    $0x8,%esp
801013ab:	50                   	push   %eax
801013ac:	ff 75 08             	pushl  0x8(%ebp)
801013af:	e8 b8 ed ff ff       	call   8010016c <bread>
801013b4:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013b6:	89 d8                	mov    %ebx,%eax
801013b8:	83 e0 07             	and    $0x7,%eax
801013bb:	c1 e0 06             	shl    $0x6,%eax
801013be:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013c2:	83 c4 10             	add    $0x10,%esp
801013c5:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013c9:	74 1e                	je     801013e9 <ialloc+0x6b>
    brelse(bp);
801013cb:	83 ec 0c             	sub    $0xc,%esp
801013ce:	56                   	push   %esi
801013cf:	e8 01 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013d4:	83 c3 01             	add    $0x1,%ebx
801013d7:	83 c4 10             	add    $0x10,%esp
801013da:	eb b6                	jmp    80101392 <ialloc+0x14>
  panic("ialloc: no inodes");
801013dc:	83 ec 0c             	sub    $0xc,%esp
801013df:	68 58 66 10 80       	push   $0x80106658
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 f8 28 00 00       	call   80103cee <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 7f 15 00 00       	call   80102984 <log_write>
      brelse(bp);
80101405:	89 34 24             	mov    %esi,(%esp)
80101408:	e8 c8 ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
8010140d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	e8 6f fd ff ff       	call   80101187 <iget>
}
80101418:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010141b:	5b                   	pop    %ebx
8010141c:	5e                   	pop    %esi
8010141d:	5f                   	pop    %edi
8010141e:	5d                   	pop    %ebp
8010141f:	c3                   	ret    

80101420 <iupdate>:
{
80101420:	55                   	push   %ebp
80101421:	89 e5                	mov    %esp,%ebp
80101423:	56                   	push   %esi
80101424:	53                   	push   %ebx
80101425:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101428:	8b 43 04             	mov    0x4(%ebx),%eax
8010142b:	c1 e8 03             	shr    $0x3,%eax
8010142e:	03 05 f4 f9 12 80    	add    0x8012f9f4,%eax
80101434:	83 ec 08             	sub    $0x8,%esp
80101437:	50                   	push   %eax
80101438:	ff 33                	pushl  (%ebx)
8010143a:	e8 2d ed ff ff       	call   8010016c <bread>
8010143f:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101441:	8b 43 04             	mov    0x4(%ebx),%eax
80101444:	83 e0 07             	and    $0x7,%eax
80101447:	c1 e0 06             	shl    $0x6,%eax
8010144a:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010144e:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101452:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101455:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101459:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010145d:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101461:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101465:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101469:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010146d:	8b 53 58             	mov    0x58(%ebx),%edx
80101470:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101473:	83 c3 5c             	add    $0x5c,%ebx
80101476:	83 c0 0c             	add    $0xc,%eax
80101479:	83 c4 0c             	add    $0xc,%esp
8010147c:	6a 34                	push   $0x34
8010147e:	53                   	push   %ebx
8010147f:	50                   	push   %eax
80101480:	e8 e4 28 00 00       	call   80103d69 <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 f7 14 00 00       	call   80102984 <log_write>
  brelse(bp);
8010148d:	89 34 24             	mov    %esi,(%esp)
80101490:	e8 40 ed ff ff       	call   801001d5 <brelse>
}
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010149b:	5b                   	pop    %ebx
8010149c:	5e                   	pop    %esi
8010149d:	5d                   	pop    %ebp
8010149e:	c3                   	ret    

8010149f <itrunc>:
{
8010149f:	55                   	push   %ebp
801014a0:	89 e5                	mov    %esp,%ebp
801014a2:	57                   	push   %edi
801014a3:	56                   	push   %esi
801014a4:	53                   	push   %ebx
801014a5:	83 ec 1c             	sub    $0x1c,%esp
801014a8:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
801014af:	eb 03                	jmp    801014b4 <itrunc+0x15>
801014b1:	83 c3 01             	add    $0x1,%ebx
801014b4:	83 fb 0b             	cmp    $0xb,%ebx
801014b7:	7f 19                	jg     801014d2 <itrunc+0x33>
    if(ip->addrs[i]){
801014b9:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014bd:	85 d2                	test   %edx,%edx
801014bf:	74 f0                	je     801014b1 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014c1:	8b 06                	mov    (%esi),%eax
801014c3:	e8 a2 fd ff ff       	call   8010126a <bfree>
      ip->addrs[i] = 0;
801014c8:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014cf:	00 
801014d0:	eb df                	jmp    801014b1 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014d2:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014d8:	85 c0                	test   %eax,%eax
801014da:	75 1b                	jne    801014f7 <itrunc+0x58>
  ip->size = 0;
801014dc:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014e3:	83 ec 0c             	sub    $0xc,%esp
801014e6:	56                   	push   %esi
801014e7:	e8 34 ff ff ff       	call   80101420 <iupdate>
}
801014ec:	83 c4 10             	add    $0x10,%esp
801014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014f2:	5b                   	pop    %ebx
801014f3:	5e                   	pop    %esi
801014f4:	5f                   	pop    %edi
801014f5:	5d                   	pop    %ebp
801014f6:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014f7:	83 ec 08             	sub    $0x8,%esp
801014fa:	50                   	push   %eax
801014fb:	ff 36                	pushl  (%esi)
801014fd:	e8 6a ec ff ff       	call   8010016c <bread>
80101502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101505:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101508:	83 c4 10             	add    $0x10,%esp
8010150b:	bb 00 00 00 00       	mov    $0x0,%ebx
80101510:	eb 03                	jmp    80101515 <itrunc+0x76>
80101512:	83 c3 01             	add    $0x1,%ebx
80101515:	83 fb 7f             	cmp    $0x7f,%ebx
80101518:	77 10                	ja     8010152a <itrunc+0x8b>
      if(a[j])
8010151a:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010151d:	85 d2                	test   %edx,%edx
8010151f:	74 f1                	je     80101512 <itrunc+0x73>
        bfree(ip->dev, a[j]);
80101521:	8b 06                	mov    (%esi),%eax
80101523:	e8 42 fd ff ff       	call   8010126a <bfree>
80101528:	eb e8                	jmp    80101512 <itrunc+0x73>
    brelse(bp);
8010152a:	83 ec 0c             	sub    $0xc,%esp
8010152d:	ff 75 e4             	pushl  -0x1c(%ebp)
80101530:	e8 a0 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101535:	8b 06                	mov    (%esi),%eax
80101537:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010153d:	e8 28 fd ff ff       	call   8010126a <bfree>
    ip->addrs[NDIRECT] = 0;
80101542:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101549:	00 00 00 
8010154c:	83 c4 10             	add    $0x10,%esp
8010154f:	eb 8b                	jmp    801014dc <itrunc+0x3d>

80101551 <idup>:
{
80101551:	55                   	push   %ebp
80101552:	89 e5                	mov    %esp,%ebp
80101554:	53                   	push   %ebx
80101555:	83 ec 10             	sub    $0x10,%esp
80101558:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010155b:	68 00 fa 12 80       	push   $0x8012fa00
80101560:	e8 dd 26 00 00       	call   80103c42 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
80101575:	e8 2d 27 00 00       	call   80103ca7 <release>
}
8010157a:	89 d8                	mov    %ebx,%eax
8010157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010157f:	c9                   	leave  
80101580:	c3                   	ret    

80101581 <ilock>:
{
80101581:	55                   	push   %ebp
80101582:	89 e5                	mov    %esp,%ebp
80101584:	56                   	push   %esi
80101585:	53                   	push   %ebx
80101586:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101589:	85 db                	test   %ebx,%ebx
8010158b:	74 22                	je     801015af <ilock+0x2e>
8010158d:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101591:	7e 1c                	jle    801015af <ilock+0x2e>
  acquiresleep(&ip->lock);
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	8d 43 0c             	lea    0xc(%ebx),%eax
80101599:	50                   	push   %eax
8010159a:	e8 8f 24 00 00       	call   80103a2e <acquiresleep>
  if(ip->valid == 0){
8010159f:	83 c4 10             	add    $0x10,%esp
801015a2:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015a6:	74 14                	je     801015bc <ilock+0x3b>
}
801015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015ab:	5b                   	pop    %ebx
801015ac:	5e                   	pop    %esi
801015ad:	5d                   	pop    %ebp
801015ae:	c3                   	ret    
    panic("ilock");
801015af:	83 ec 0c             	sub    $0xc,%esp
801015b2:	68 6a 66 10 80       	push   $0x8010666a
801015b7:	e8 8c ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015bc:	8b 43 04             	mov    0x4(%ebx),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	03 05 f4 f9 12 80    	add    0x8012f9f4,%eax
801015c8:	83 ec 08             	sub    $0x8,%esp
801015cb:	50                   	push   %eax
801015cc:	ff 33                	pushl  (%ebx)
801015ce:	e8 99 eb ff ff       	call   8010016c <bread>
801015d3:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015d5:	8b 43 04             	mov    0x4(%ebx),%eax
801015d8:	83 e0 07             	and    $0x7,%eax
801015db:	c1 e0 06             	shl    $0x6,%eax
801015de:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015e2:	0f b7 10             	movzwl (%eax),%edx
801015e5:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015e9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015ed:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015f1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015f5:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015f9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015fd:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101601:	8b 50 08             	mov    0x8(%eax),%edx
80101604:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101607:	83 c0 0c             	add    $0xc,%eax
8010160a:	8d 53 5c             	lea    0x5c(%ebx),%edx
8010160d:	83 c4 0c             	add    $0xc,%esp
80101610:	6a 34                	push   $0x34
80101612:	50                   	push   %eax
80101613:	52                   	push   %edx
80101614:	e8 50 27 00 00       	call   80103d69 <memmove>
    brelse(bp);
80101619:	89 34 24             	mov    %esi,(%esp)
8010161c:	e8 b4 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
80101621:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101628:	83 c4 10             	add    $0x10,%esp
8010162b:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101630:	0f 85 72 ff ff ff    	jne    801015a8 <ilock+0x27>
      panic("ilock: no type");
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	68 70 66 10 80       	push   $0x80106670
8010163e:	e8 05 ed ff ff       	call   80100348 <panic>

80101643 <iunlock>:
{
80101643:	55                   	push   %ebp
80101644:	89 e5                	mov    %esp,%ebp
80101646:	56                   	push   %esi
80101647:	53                   	push   %ebx
80101648:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010164b:	85 db                	test   %ebx,%ebx
8010164d:	74 2c                	je     8010167b <iunlock+0x38>
8010164f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101652:	83 ec 0c             	sub    $0xc,%esp
80101655:	56                   	push   %esi
80101656:	e8 5d 24 00 00       	call   80103ab8 <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 0c 24 00 00       	call   80103a7d <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 7f 66 10 80       	push   $0x8010667f
80101683:	e8 c0 ec ff ff       	call   80100348 <panic>

80101688 <iput>:
{
80101688:	55                   	push   %ebp
80101689:	89 e5                	mov    %esp,%ebp
8010168b:	57                   	push   %edi
8010168c:	56                   	push   %esi
8010168d:	53                   	push   %ebx
8010168e:	83 ec 18             	sub    $0x18,%esp
80101691:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101694:	8d 73 0c             	lea    0xc(%ebx),%esi
80101697:	56                   	push   %esi
80101698:	e8 91 23 00 00       	call   80103a2e <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 c7 23 00 00       	call   80103a7d <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016bd:	e8 80 25 00 00       	call   80103c42 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016d2:	e8 d0 25 00 00       	call   80103ca7 <release>
}
801016d7:	83 c4 10             	add    $0x10,%esp
801016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016dd:	5b                   	pop    %ebx
801016de:	5e                   	pop    %esi
801016df:	5f                   	pop    %edi
801016e0:	5d                   	pop    %ebp
801016e1:	c3                   	ret    
    acquire(&icache.lock);
801016e2:	83 ec 0c             	sub    $0xc,%esp
801016e5:	68 00 fa 12 80       	push   $0x8012fa00
801016ea:	e8 53 25 00 00       	call   80103c42 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016f9:	e8 a9 25 00 00       	call   80103ca7 <release>
    if(r == 1){
801016fe:	83 c4 10             	add    $0x10,%esp
80101701:	83 ff 01             	cmp    $0x1,%edi
80101704:	75 a7                	jne    801016ad <iput+0x25>
      itrunc(ip);
80101706:	89 d8                	mov    %ebx,%eax
80101708:	e8 92 fd ff ff       	call   8010149f <itrunc>
      ip->type = 0;
8010170d:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101713:	83 ec 0c             	sub    $0xc,%esp
80101716:	53                   	push   %ebx
80101717:	e8 04 fd ff ff       	call   80101420 <iupdate>
      ip->valid = 0;
8010171c:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101723:	83 c4 10             	add    $0x10,%esp
80101726:	eb 85                	jmp    801016ad <iput+0x25>

80101728 <iunlockput>:
{
80101728:	55                   	push   %ebp
80101729:	89 e5                	mov    %esp,%ebp
8010172b:	53                   	push   %ebx
8010172c:	83 ec 10             	sub    $0x10,%esp
8010172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101732:	53                   	push   %ebx
80101733:	e8 0b ff ff ff       	call   80101643 <iunlock>
  iput(ip);
80101738:	89 1c 24             	mov    %ebx,(%esp)
8010173b:	e8 48 ff ff ff       	call   80101688 <iput>
}
80101740:	83 c4 10             	add    $0x10,%esp
80101743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101746:	c9                   	leave  
80101747:	c3                   	ret    

80101748 <stati>:
{
80101748:	55                   	push   %ebp
80101749:	89 e5                	mov    %esp,%ebp
8010174b:	8b 55 08             	mov    0x8(%ebp),%edx
8010174e:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101751:	8b 0a                	mov    (%edx),%ecx
80101753:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101756:	8b 4a 04             	mov    0x4(%edx),%ecx
80101759:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010175c:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101760:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101763:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101767:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010176b:	8b 52 58             	mov    0x58(%edx),%edx
8010176e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101771:	5d                   	pop    %ebp
80101772:	c3                   	ret    

80101773 <readi>:
{
80101773:	55                   	push   %ebp
80101774:	89 e5                	mov    %esp,%ebp
80101776:	57                   	push   %edi
80101777:	56                   	push   %esi
80101778:	53                   	push   %ebx
80101779:	83 ec 1c             	sub    $0x1c,%esp
8010177c:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010177f:	8b 45 08             	mov    0x8(%ebp),%eax
80101782:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101787:	74 2c                	je     801017b5 <readi+0x42>
  if(off > ip->size || off + n < off)
80101789:	8b 45 08             	mov    0x8(%ebp),%eax
8010178c:	8b 40 58             	mov    0x58(%eax),%eax
8010178f:	39 f8                	cmp    %edi,%eax
80101791:	0f 82 cb 00 00 00    	jb     80101862 <readi+0xef>
80101797:	89 fa                	mov    %edi,%edx
80101799:	03 55 14             	add    0x14(%ebp),%edx
8010179c:	0f 82 c7 00 00 00    	jb     80101869 <readi+0xf6>
  if(off + n > ip->size)
801017a2:	39 d0                	cmp    %edx,%eax
801017a4:	73 05                	jae    801017ab <readi+0x38>
    n = ip->size - off;
801017a6:	29 f8                	sub    %edi,%eax
801017a8:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017ab:	be 00 00 00 00       	mov    $0x0,%esi
801017b0:	e9 8f 00 00 00       	jmp    80101844 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017b5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017b9:	66 83 f8 09          	cmp    $0x9,%ax
801017bd:	0f 87 91 00 00 00    	ja     80101854 <readi+0xe1>
801017c3:	98                   	cwtl   
801017c4:	8b 04 c5 80 f9 12 80 	mov    -0x7fed0680(,%eax,8),%eax
801017cb:	85 c0                	test   %eax,%eax
801017cd:	0f 84 88 00 00 00    	je     8010185b <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017d3:	83 ec 04             	sub    $0x4,%esp
801017d6:	ff 75 14             	pushl  0x14(%ebp)
801017d9:	ff 75 0c             	pushl  0xc(%ebp)
801017dc:	ff 75 08             	pushl  0x8(%ebp)
801017df:	ff d0                	call   *%eax
801017e1:	83 c4 10             	add    $0x10,%esp
801017e4:	eb 66                	jmp    8010184c <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017e6:	89 fa                	mov    %edi,%edx
801017e8:	c1 ea 09             	shr    $0x9,%edx
801017eb:	8b 45 08             	mov    0x8(%ebp),%eax
801017ee:	e8 ee f8 ff ff       	call   801010e1 <bmap>
801017f3:	83 ec 08             	sub    $0x8,%esp
801017f6:	50                   	push   %eax
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	ff 30                	pushl  (%eax)
801017fc:	e8 6b e9 ff ff       	call   8010016c <bread>
80101801:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101803:	89 f8                	mov    %edi,%eax
80101805:	25 ff 01 00 00       	and    $0x1ff,%eax
8010180a:	bb 00 02 00 00       	mov    $0x200,%ebx
8010180f:	29 c3                	sub    %eax,%ebx
80101811:	8b 55 14             	mov    0x14(%ebp),%edx
80101814:	29 f2                	sub    %esi,%edx
80101816:	83 c4 0c             	add    $0xc,%esp
80101819:	39 d3                	cmp    %edx,%ebx
8010181b:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010181e:	53                   	push   %ebx
8010181f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101822:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101826:	50                   	push   %eax
80101827:	ff 75 0c             	pushl  0xc(%ebp)
8010182a:	e8 3a 25 00 00       	call   80103d69 <memmove>
    brelse(bp);
8010182f:	83 c4 04             	add    $0x4,%esp
80101832:	ff 75 e4             	pushl  -0x1c(%ebp)
80101835:	e8 9b e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010183a:	01 de                	add    %ebx,%esi
8010183c:	01 df                	add    %ebx,%edi
8010183e:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101841:	83 c4 10             	add    $0x10,%esp
80101844:	39 75 14             	cmp    %esi,0x14(%ebp)
80101847:	77 9d                	ja     801017e6 <readi+0x73>
  return n;
80101849:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010184c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010184f:	5b                   	pop    %ebx
80101850:	5e                   	pop    %esi
80101851:	5f                   	pop    %edi
80101852:	5d                   	pop    %ebp
80101853:	c3                   	ret    
      return -1;
80101854:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101859:	eb f1                	jmp    8010184c <readi+0xd9>
8010185b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101860:	eb ea                	jmp    8010184c <readi+0xd9>
    return -1;
80101862:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101867:	eb e3                	jmp    8010184c <readi+0xd9>
80101869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186e:	eb dc                	jmp    8010184c <readi+0xd9>

80101870 <writei>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	57                   	push   %edi
80101874:	56                   	push   %esi
80101875:	53                   	push   %ebx
80101876:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101879:	8b 45 08             	mov    0x8(%ebp),%eax
8010187c:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101881:	74 2f                	je     801018b2 <writei+0x42>
  if(off > ip->size || off + n < off)
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101889:	39 48 58             	cmp    %ecx,0x58(%eax)
8010188c:	0f 82 f4 00 00 00    	jb     80101986 <writei+0x116>
80101892:	89 c8                	mov    %ecx,%eax
80101894:	03 45 14             	add    0x14(%ebp),%eax
80101897:	0f 82 f0 00 00 00    	jb     8010198d <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
8010189d:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018a2:	0f 87 ec 00 00 00    	ja     80101994 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018a8:	be 00 00 00 00       	mov    $0x0,%esi
801018ad:	e9 94 00 00 00       	jmp    80101946 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018b2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018b6:	66 83 f8 09          	cmp    $0x9,%ax
801018ba:	0f 87 b8 00 00 00    	ja     80101978 <writei+0x108>
801018c0:	98                   	cwtl   
801018c1:	8b 04 c5 84 f9 12 80 	mov    -0x7fed067c(,%eax,8),%eax
801018c8:	85 c0                	test   %eax,%eax
801018ca:	0f 84 af 00 00 00    	je     8010197f <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018d0:	83 ec 04             	sub    $0x4,%esp
801018d3:	ff 75 14             	pushl  0x14(%ebp)
801018d6:	ff 75 0c             	pushl  0xc(%ebp)
801018d9:	ff 75 08             	pushl  0x8(%ebp)
801018dc:	ff d0                	call   *%eax
801018de:	83 c4 10             	add    $0x10,%esp
801018e1:	eb 7c                	jmp    8010195f <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018e3:	8b 55 10             	mov    0x10(%ebp),%edx
801018e6:	c1 ea 09             	shr    $0x9,%edx
801018e9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ec:	e8 f0 f7 ff ff       	call   801010e1 <bmap>
801018f1:	83 ec 08             	sub    $0x8,%esp
801018f4:	50                   	push   %eax
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	ff 30                	pushl  (%eax)
801018fa:	e8 6d e8 ff ff       	call   8010016c <bread>
801018ff:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101901:	8b 45 10             	mov    0x10(%ebp),%eax
80101904:	25 ff 01 00 00       	and    $0x1ff,%eax
80101909:	bb 00 02 00 00       	mov    $0x200,%ebx
8010190e:	29 c3                	sub    %eax,%ebx
80101910:	8b 55 14             	mov    0x14(%ebp),%edx
80101913:	29 f2                	sub    %esi,%edx
80101915:	83 c4 0c             	add    $0xc,%esp
80101918:	39 d3                	cmp    %edx,%ebx
8010191a:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010191d:	53                   	push   %ebx
8010191e:	ff 75 0c             	pushl  0xc(%ebp)
80101921:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101925:	50                   	push   %eax
80101926:	e8 3e 24 00 00       	call   80103d69 <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 51 10 00 00       	call   80102984 <log_write>
    brelse(bp);
80101933:	89 3c 24             	mov    %edi,(%esp)
80101936:	e8 9a e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010193b:	01 de                	add    %ebx,%esi
8010193d:	01 5d 10             	add    %ebx,0x10(%ebp)
80101940:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101943:	83 c4 10             	add    $0x10,%esp
80101946:	3b 75 14             	cmp    0x14(%ebp),%esi
80101949:	72 98                	jb     801018e3 <writei+0x73>
  if(n > 0 && off > ip->size){
8010194b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010194f:	74 0b                	je     8010195c <writei+0xec>
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101957:	39 48 58             	cmp    %ecx,0x58(%eax)
8010195a:	72 0b                	jb     80101967 <writei+0xf7>
  return n;
8010195c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010195f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101962:	5b                   	pop    %ebx
80101963:	5e                   	pop    %esi
80101964:	5f                   	pop    %edi
80101965:	5d                   	pop    %ebp
80101966:	c3                   	ret    
    ip->size = off;
80101967:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
8010196a:	83 ec 0c             	sub    $0xc,%esp
8010196d:	50                   	push   %eax
8010196e:	e8 ad fa ff ff       	call   80101420 <iupdate>
80101973:	83 c4 10             	add    $0x10,%esp
80101976:	eb e4                	jmp    8010195c <writei+0xec>
      return -1;
80101978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010197d:	eb e0                	jmp    8010195f <writei+0xef>
8010197f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101984:	eb d9                	jmp    8010195f <writei+0xef>
    return -1;
80101986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010198b:	eb d2                	jmp    8010195f <writei+0xef>
8010198d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101992:	eb cb                	jmp    8010195f <writei+0xef>
    return -1;
80101994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101999:	eb c4                	jmp    8010195f <writei+0xef>

8010199b <namecmp>:
{
8010199b:	55                   	push   %ebp
8010199c:	89 e5                	mov    %esp,%ebp
8010199e:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019a1:	6a 0e                	push   $0xe
801019a3:	ff 75 0c             	pushl  0xc(%ebp)
801019a6:	ff 75 08             	pushl  0x8(%ebp)
801019a9:	e8 22 24 00 00       	call   80103dd0 <strncmp>
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <dirlookup>:
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	57                   	push   %edi
801019b4:	56                   	push   %esi
801019b5:	53                   	push   %ebx
801019b6:	83 ec 1c             	sub    $0x1c,%esp
801019b9:	8b 75 08             	mov    0x8(%ebp),%esi
801019bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019bf:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019c4:	75 07                	jne    801019cd <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019c6:	bb 00 00 00 00       	mov    $0x0,%ebx
801019cb:	eb 1d                	jmp    801019ea <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019cd:	83 ec 0c             	sub    $0xc,%esp
801019d0:	68 87 66 10 80       	push   $0x80106687
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 99 66 10 80       	push   $0x80106699
801019e2:	e8 61 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019e7:	83 c3 10             	add    $0x10,%ebx
801019ea:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019ed:	76 48                	jbe    80101a37 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019ef:	6a 10                	push   $0x10
801019f1:	53                   	push   %ebx
801019f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019f5:	50                   	push   %eax
801019f6:	56                   	push   %esi
801019f7:	e8 77 fd ff ff       	call   80101773 <readi>
801019fc:	83 c4 10             	add    $0x10,%esp
801019ff:	83 f8 10             	cmp    $0x10,%eax
80101a02:	75 d6                	jne    801019da <dirlookup+0x2a>
    if(de.inum == 0)
80101a04:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a09:	74 dc                	je     801019e7 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a0b:	83 ec 08             	sub    $0x8,%esp
80101a0e:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a11:	50                   	push   %eax
80101a12:	57                   	push   %edi
80101a13:	e8 83 ff ff ff       	call   8010199b <namecmp>
80101a18:	83 c4 10             	add    $0x10,%esp
80101a1b:	85 c0                	test   %eax,%eax
80101a1d:	75 c8                	jne    801019e7 <dirlookup+0x37>
      if(poff)
80101a1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a23:	74 05                	je     80101a2a <dirlookup+0x7a>
        *poff = off;
80101a25:	8b 45 10             	mov    0x10(%ebp),%eax
80101a28:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a2a:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a2e:	8b 06                	mov    (%esi),%eax
80101a30:	e8 52 f7 ff ff       	call   80101187 <iget>
80101a35:	eb 05                	jmp    80101a3c <dirlookup+0x8c>
  return 0;
80101a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a3f:	5b                   	pop    %ebx
80101a40:	5e                   	pop    %esi
80101a41:	5f                   	pop    %edi
80101a42:	5d                   	pop    %ebp
80101a43:	c3                   	ret    

80101a44 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a44:	55                   	push   %ebp
80101a45:	89 e5                	mov    %esp,%ebp
80101a47:	57                   	push   %edi
80101a48:	56                   	push   %esi
80101a49:	53                   	push   %ebx
80101a4a:	83 ec 1c             	sub    $0x1c,%esp
80101a4d:	89 c6                	mov    %eax,%esi
80101a4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a55:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a58:	74 17                	je     80101a71 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a5a:	e8 44 18 00 00       	call   801032a3 <myproc>
80101a5f:	83 ec 0c             	sub    $0xc,%esp
80101a62:	ff 70 68             	pushl  0x68(%eax)
80101a65:	e8 e7 fa ff ff       	call   80101551 <idup>
80101a6a:	89 c3                	mov    %eax,%ebx
80101a6c:	83 c4 10             	add    $0x10,%esp
80101a6f:	eb 53                	jmp    80101ac4 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a71:	ba 01 00 00 00       	mov    $0x1,%edx
80101a76:	b8 01 00 00 00       	mov    $0x1,%eax
80101a7b:	e8 07 f7 ff ff       	call   80101187 <iget>
80101a80:	89 c3                	mov    %eax,%ebx
80101a82:	eb 40                	jmp    80101ac4 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	53                   	push   %ebx
80101a88:	e8 9b fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101a8d:	83 c4 10             	add    $0x10,%esp
80101a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a95:	89 d8                	mov    %ebx,%eax
80101a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a9a:	5b                   	pop    %ebx
80101a9b:	5e                   	pop    %esi
80101a9c:	5f                   	pop    %edi
80101a9d:	5d                   	pop    %ebp
80101a9e:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a9f:	83 ec 04             	sub    $0x4,%esp
80101aa2:	6a 00                	push   $0x0
80101aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
80101aa7:	53                   	push   %ebx
80101aa8:	e8 03 ff ff ff       	call   801019b0 <dirlookup>
80101aad:	89 c7                	mov    %eax,%edi
80101aaf:	83 c4 10             	add    $0x10,%esp
80101ab2:	85 c0                	test   %eax,%eax
80101ab4:	74 4a                	je     80101b00 <namex+0xbc>
    iunlockput(ip);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	53                   	push   %ebx
80101aba:	e8 69 fc ff ff       	call   80101728 <iunlockput>
    ip = next;
80101abf:	83 c4 10             	add    $0x10,%esp
80101ac2:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ac4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ac7:	89 f0                	mov    %esi,%eax
80101ac9:	e8 77 f4 ff ff       	call   80100f45 <skipelem>
80101ace:	89 c6                	mov    %eax,%esi
80101ad0:	85 c0                	test   %eax,%eax
80101ad2:	74 3c                	je     80101b10 <namex+0xcc>
    ilock(ip);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	53                   	push   %ebx
80101ad8:	e8 a4 fa ff ff       	call   80101581 <ilock>
    if(ip->type != T_DIR){
80101add:	83 c4 10             	add    $0x10,%esp
80101ae0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ae5:	75 9d                	jne    80101a84 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ae7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aeb:	74 b2                	je     80101a9f <namex+0x5b>
80101aed:	80 3e 00             	cmpb   $0x0,(%esi)
80101af0:	75 ad                	jne    80101a9f <namex+0x5b>
      iunlock(ip);
80101af2:	83 ec 0c             	sub    $0xc,%esp
80101af5:	53                   	push   %ebx
80101af6:	e8 48 fb ff ff       	call   80101643 <iunlock>
      return ip;
80101afb:	83 c4 10             	add    $0x10,%esp
80101afe:	eb 95                	jmp    80101a95 <namex+0x51>
      iunlockput(ip);
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	53                   	push   %ebx
80101b04:	e8 1f fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101b09:	83 c4 10             	add    $0x10,%esp
80101b0c:	89 fb                	mov    %edi,%ebx
80101b0e:	eb 85                	jmp    80101a95 <namex+0x51>
  if(nameiparent){
80101b10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b14:	0f 84 7b ff ff ff    	je     80101a95 <namex+0x51>
    iput(ip);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	53                   	push   %ebx
80101b1e:	e8 65 fb ff ff       	call   80101688 <iput>
    return 0;
80101b23:	83 c4 10             	add    $0x10,%esp
80101b26:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b2b:	e9 65 ff ff ff       	jmp    80101a95 <namex+0x51>

80101b30 <dirlink>:
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	57                   	push   %edi
80101b34:	56                   	push   %esi
80101b35:	53                   	push   %ebx
80101b36:	83 ec 20             	sub    $0x20,%esp
80101b39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b3f:	6a 00                	push   $0x0
80101b41:	57                   	push   %edi
80101b42:	53                   	push   %ebx
80101b43:	e8 68 fe ff ff       	call   801019b0 <dirlookup>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	75 2d                	jne    80101b7c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b4f:	b8 00 00 00 00       	mov    $0x0,%eax
80101b54:	89 c6                	mov    %eax,%esi
80101b56:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b59:	76 41                	jbe    80101b9c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b5b:	6a 10                	push   $0x10
80101b5d:	50                   	push   %eax
80101b5e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b61:	50                   	push   %eax
80101b62:	53                   	push   %ebx
80101b63:	e8 0b fc ff ff       	call   80101773 <readi>
80101b68:	83 c4 10             	add    $0x10,%esp
80101b6b:	83 f8 10             	cmp    $0x10,%eax
80101b6e:	75 1f                	jne    80101b8f <dirlink+0x5f>
    if(de.inum == 0)
80101b70:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b75:	74 25                	je     80101b9c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b77:	8d 46 10             	lea    0x10(%esi),%eax
80101b7a:	eb d8                	jmp    80101b54 <dirlink+0x24>
    iput(ip);
80101b7c:	83 ec 0c             	sub    $0xc,%esp
80101b7f:	50                   	push   %eax
80101b80:	e8 03 fb ff ff       	call   80101688 <iput>
    return -1;
80101b85:	83 c4 10             	add    $0x10,%esp
80101b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b8d:	eb 3d                	jmp    80101bcc <dirlink+0x9c>
      panic("dirlink read");
80101b8f:	83 ec 0c             	sub    $0xc,%esp
80101b92:	68 a8 66 10 80       	push   $0x801066a8
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 5f 22 00 00       	call   80103e0d <strncpy>
  de.inum = inum;
80101bae:	8b 45 10             	mov    0x10(%ebp),%eax
80101bb1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bb5:	6a 10                	push   $0x10
80101bb7:	56                   	push   %esi
80101bb8:	57                   	push   %edi
80101bb9:	53                   	push   %ebx
80101bba:	e8 b1 fc ff ff       	call   80101870 <writei>
80101bbf:	83 c4 20             	add    $0x20,%esp
80101bc2:	83 f8 10             	cmp    $0x10,%eax
80101bc5:	75 0d                	jne    80101bd4 <dirlink+0xa4>
  return 0;
80101bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bcf:	5b                   	pop    %ebx
80101bd0:	5e                   	pop    %esi
80101bd1:	5f                   	pop    %edi
80101bd2:	5d                   	pop    %ebp
80101bd3:	c3                   	ret    
    panic("dirlink");
80101bd4:	83 ec 0c             	sub    $0xc,%esp
80101bd7:	68 b4 6c 10 80       	push   $0x80106cb4
80101bdc:	e8 67 e7 ff ff       	call   80100348 <panic>

80101be1 <namei>:

struct inode*
namei(char *path)
{
80101be1:	55                   	push   %ebp
80101be2:	89 e5                	mov    %esp,%ebp
80101be4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101be7:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bea:	ba 00 00 00 00       	mov    $0x0,%edx
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	e8 4d fe ff ff       	call   80101a44 <namex>
}
80101bf7:	c9                   	leave  
80101bf8:	c3                   	ret    

80101bf9 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101bf9:	55                   	push   %ebp
80101bfa:	89 e5                	mov    %esp,%ebp
80101bfc:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c02:	ba 01 00 00 00       	mov    $0x1,%edx
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	e8 35 fe ff ff       	call   80101a44 <namex>
}
80101c0f:	c9                   	leave  
80101c10:	c3                   	ret    

80101c11 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c11:	55                   	push   %ebp
80101c12:	89 e5                	mov    %esp,%ebp
80101c14:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c16:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c1b:	ec                   	in     (%dx),%al
80101c1c:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c1e:	83 e0 c0             	and    $0xffffffc0,%eax
80101c21:	3c 40                	cmp    $0x40,%al
80101c23:	75 f1                	jne    80101c16 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c25:	85 c9                	test   %ecx,%ecx
80101c27:	74 0c                	je     80101c35 <idewait+0x24>
80101c29:	f6 c2 21             	test   $0x21,%dl
80101c2c:	75 0e                	jne    80101c3c <idewait+0x2b>
    return -1;
  return 0;
80101c2e:	b8 00 00 00 00       	mov    $0x0,%eax
80101c33:	eb 05                	jmp    80101c3a <idewait+0x29>
80101c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c3a:	5d                   	pop    %ebp
80101c3b:	c3                   	ret    
    return -1;
80101c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c41:	eb f7                	jmp    80101c3a <idewait+0x29>

80101c43 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c43:	55                   	push   %ebp
80101c44:	89 e5                	mov    %esp,%ebp
80101c46:	56                   	push   %esi
80101c47:	53                   	push   %ebx
  if(b == 0)
80101c48:	85 c0                	test   %eax,%eax
80101c4a:	74 7d                	je     80101cc9 <idestart+0x86>
80101c4c:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c4e:	8b 58 08             	mov    0x8(%eax),%ebx
80101c51:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c57:	77 7d                	ja     80101cd6 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c59:	b8 00 00 00 00       	mov    $0x0,%eax
80101c5e:	e8 ae ff ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c63:	b8 00 00 00 00       	mov    $0x0,%eax
80101c68:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c6d:	ee                   	out    %al,(%dx)
80101c6e:	b8 01 00 00 00       	mov    $0x1,%eax
80101c73:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c78:	ee                   	out    %al,(%dx)
80101c79:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c7e:	89 d8                	mov    %ebx,%eax
80101c80:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c81:	89 d8                	mov    %ebx,%eax
80101c83:	c1 f8 08             	sar    $0x8,%eax
80101c86:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c8b:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c8c:	89 d8                	mov    %ebx,%eax
80101c8e:	c1 f8 10             	sar    $0x10,%eax
80101c91:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c96:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c97:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c9b:	c1 e0 04             	shl    $0x4,%eax
80101c9e:	83 e0 10             	and    $0x10,%eax
80101ca1:	c1 fb 18             	sar    $0x18,%ebx
80101ca4:	83 e3 0f             	and    $0xf,%ebx
80101ca7:	09 d8                	or     %ebx,%eax
80101ca9:	83 c8 e0             	or     $0xffffffe0,%eax
80101cac:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cb1:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cb2:	f6 06 04             	testb  $0x4,(%esi)
80101cb5:	75 2c                	jne    80101ce3 <idestart+0xa0>
80101cb7:	b8 20 00 00 00       	mov    $0x20,%eax
80101cbc:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cc1:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cc5:	5b                   	pop    %ebx
80101cc6:	5e                   	pop    %esi
80101cc7:	5d                   	pop    %ebp
80101cc8:	c3                   	ret    
    panic("idestart");
80101cc9:	83 ec 0c             	sub    $0xc,%esp
80101ccc:	68 0b 67 10 80       	push   $0x8010670b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 14 67 10 80       	push   $0x80106714
80101cde:	e8 65 e6 ff ff       	call   80100348 <panic>
80101ce3:	b8 30 00 00 00       	mov    $0x30,%eax
80101ce8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ced:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cee:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cf1:	b9 80 00 00 00       	mov    $0x80,%ecx
80101cf6:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101cfb:	fc                   	cld    
80101cfc:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101cfe:	eb c2                	jmp    80101cc2 <idestart+0x7f>

80101d00 <ideinit>:
{
80101d00:	55                   	push   %ebp
80101d01:	89 e5                	mov    %esp,%ebp
80101d03:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d06:	68 26 67 10 80       	push   $0x80106726
80101d0b:	68 80 95 12 80       	push   $0x80129580
80101d10:	e8 f1 1d 00 00       	call   80103b06 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 20 1d 13 80       	mov    0x80131d20,%eax
80101d1d:	83 e8 01             	sub    $0x1,%eax
80101d20:	50                   	push   %eax
80101d21:	6a 0e                	push   $0xe
80101d23:	e8 56 02 00 00       	call   80101f7e <ioapicenable>
  idewait(0);
80101d28:	b8 00 00 00 00       	mov    $0x0,%eax
80101d2d:	e8 df fe ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d32:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d37:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d3c:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d3d:	83 c4 10             	add    $0x10,%esp
80101d40:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d45:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d4b:	7f 19                	jg     80101d66 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d4d:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d52:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d53:	84 c0                	test   %al,%al
80101d55:	75 05                	jne    80101d5c <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d57:	83 c1 01             	add    $0x1,%ecx
80101d5a:	eb e9                	jmp    80101d45 <ideinit+0x45>
      havedisk1 = 1;
80101d5c:	c7 05 60 95 12 80 01 	movl   $0x1,0x80129560
80101d63:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d66:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d6b:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d70:	ee                   	out    %al,(%dx)
}
80101d71:	c9                   	leave  
80101d72:	c3                   	ret    

80101d73 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	57                   	push   %edi
80101d77:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	68 80 95 12 80       	push   $0x80129580
80101d80:	e8 bd 1e 00 00       	call   80103c42 <acquire>

  if((b = idequeue) == 0){
80101d85:	8b 1d 64 95 12 80    	mov    0x80129564,%ebx
80101d8b:	83 c4 10             	add    $0x10,%esp
80101d8e:	85 db                	test   %ebx,%ebx
80101d90:	74 48                	je     80101dda <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d92:	8b 43 58             	mov    0x58(%ebx),%eax
80101d95:	a3 64 95 12 80       	mov    %eax,0x80129564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d9a:	f6 03 04             	testb  $0x4,(%ebx)
80101d9d:	74 4d                	je     80101dec <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d9f:	8b 03                	mov    (%ebx),%eax
80101da1:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101da4:	83 e0 fb             	and    $0xfffffffb,%eax
80101da7:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101da9:	83 ec 0c             	sub    $0xc,%esp
80101dac:	53                   	push   %ebx
80101dad:	e8 fa 1a 00 00       	call   801038ac <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101db2:	a1 64 95 12 80       	mov    0x80129564,%eax
80101db7:	83 c4 10             	add    $0x10,%esp
80101dba:	85 c0                	test   %eax,%eax
80101dbc:	74 05                	je     80101dc3 <ideintr+0x50>
    idestart(idequeue);
80101dbe:	e8 80 fe ff ff       	call   80101c43 <idestart>

  release(&idelock);
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	68 80 95 12 80       	push   $0x80129580
80101dcb:	e8 d7 1e 00 00       	call   80103ca7 <release>
80101dd0:	83 c4 10             	add    $0x10,%esp
}
80101dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dd6:	5b                   	pop    %ebx
80101dd7:	5f                   	pop    %edi
80101dd8:	5d                   	pop    %ebp
80101dd9:	c3                   	ret    
    release(&idelock);
80101dda:	83 ec 0c             	sub    $0xc,%esp
80101ddd:	68 80 95 12 80       	push   $0x80129580
80101de2:	e8 c0 1e 00 00       	call   80103ca7 <release>
    return;
80101de7:	83 c4 10             	add    $0x10,%esp
80101dea:	eb e7                	jmp    80101dd3 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dec:	b8 01 00 00 00       	mov    $0x1,%eax
80101df1:	e8 1b fe ff ff       	call   80101c11 <idewait>
80101df6:	85 c0                	test   %eax,%eax
80101df8:	78 a5                	js     80101d9f <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101dfa:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101dfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e07:	fc                   	cld    
80101e08:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e0a:	eb 93                	jmp    80101d9f <ideintr+0x2c>

80101e0c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e0c:	55                   	push   %ebp
80101e0d:	89 e5                	mov    %esp,%ebp
80101e0f:	53                   	push   %ebx
80101e10:	83 ec 10             	sub    $0x10,%esp
80101e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e16:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e19:	50                   	push   %eax
80101e1a:	e8 99 1c 00 00       	call   80103ab8 <holdingsleep>
80101e1f:	83 c4 10             	add    $0x10,%esp
80101e22:	85 c0                	test   %eax,%eax
80101e24:	74 37                	je     80101e5d <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e26:	8b 03                	mov    (%ebx),%eax
80101e28:	83 e0 06             	and    $0x6,%eax
80101e2b:	83 f8 02             	cmp    $0x2,%eax
80101e2e:	74 3a                	je     80101e6a <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e30:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e34:	74 09                	je     80101e3f <iderw+0x33>
80101e36:	83 3d 60 95 12 80 00 	cmpl   $0x0,0x80129560
80101e3d:	74 38                	je     80101e77 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	68 80 95 12 80       	push   $0x80129580
80101e47:	e8 f6 1d 00 00       	call   80103c42 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 95 12 80       	mov    $0x80129564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 2a 67 10 80       	push   $0x8010672a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 40 67 10 80       	push   $0x80106740
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 55 67 10 80       	push   $0x80106755
80101e7f:	e8 c4 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e84:	8d 50 58             	lea    0x58(%eax),%edx
80101e87:	8b 02                	mov    (%edx),%eax
80101e89:	85 c0                	test   %eax,%eax
80101e8b:	75 f7                	jne    80101e84 <iderw+0x78>
    ;
  *pp = b;
80101e8d:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e8f:	39 1d 64 95 12 80    	cmp    %ebx,0x80129564
80101e95:	75 1a                	jne    80101eb1 <iderw+0xa5>
    idestart(b);
80101e97:	89 d8                	mov    %ebx,%eax
80101e99:	e8 a5 fd ff ff       	call   80101c43 <idestart>
80101e9e:	eb 11                	jmp    80101eb1 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101ea0:	83 ec 08             	sub    $0x8,%esp
80101ea3:	68 80 95 12 80       	push   $0x80129580
80101ea8:	53                   	push   %ebx
80101ea9:	e8 99 18 00 00       	call   80103747 <sleep>
80101eae:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101eb1:	8b 03                	mov    (%ebx),%eax
80101eb3:	83 e0 06             	and    $0x6,%eax
80101eb6:	83 f8 02             	cmp    $0x2,%eax
80101eb9:	75 e5                	jne    80101ea0 <iderw+0x94>
  }


  release(&idelock);
80101ebb:	83 ec 0c             	sub    $0xc,%esp
80101ebe:	68 80 95 12 80       	push   $0x80129580
80101ec3:	e8 df 1d 00 00       	call   80103ca7 <release>
}
80101ec8:	83 c4 10             	add    $0x10,%esp
80101ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ece:	c9                   	leave  
80101ecf:	c3                   	ret    

80101ed0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ed0:	55                   	push   %ebp
80101ed1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ed3:	8b 15 54 16 13 80    	mov    0x80131654,%edx
80101ed9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101edb:	a1 54 16 13 80       	mov    0x80131654,%eax
80101ee0:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ee3:	5d                   	pop    %ebp
80101ee4:	c3                   	ret    

80101ee5 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ee5:	55                   	push   %ebp
80101ee6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ee8:	8b 0d 54 16 13 80    	mov    0x80131654,%ecx
80101eee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ef0:	a1 54 16 13 80       	mov    0x80131654,%eax
80101ef5:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ef8:	5d                   	pop    %ebp
80101ef9:	c3                   	ret    

80101efa <ioapicinit>:

void
ioapicinit(void)
{
80101efa:	55                   	push   %ebp
80101efb:	89 e5                	mov    %esp,%ebp
80101efd:	57                   	push   %edi
80101efe:	56                   	push   %esi
80101eff:	53                   	push   %ebx
80101f00:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f03:	c7 05 54 16 13 80 00 	movl   $0xfec00000,0x80131654
80101f0a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f0d:	b8 01 00 00 00       	mov    $0x1,%eax
80101f12:	e8 b9 ff ff ff       	call   80101ed0 <ioapicread>
80101f17:	c1 e8 10             	shr    $0x10,%eax
80101f1a:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80101f22:	e8 a9 ff ff ff       	call   80101ed0 <ioapicread>
80101f27:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f2a:	0f b6 15 80 17 13 80 	movzbl 0x80131780,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 74 67 10 80       	push   $0x80106774
80101f44:	e8 c2 e6 ff ff       	call   8010060b <cprintf>
80101f49:	83 c4 10             	add    $0x10,%esp
80101f4c:	eb e7                	jmp    80101f35 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f4e:	8d 53 20             	lea    0x20(%ebx),%edx
80101f51:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f57:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f5b:	89 f0                	mov    %esi,%eax
80101f5d:	e8 83 ff ff ff       	call   80101ee5 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f62:	8d 46 01             	lea    0x1(%esi),%eax
80101f65:	ba 00 00 00 00       	mov    $0x0,%edx
80101f6a:	e8 76 ff ff ff       	call   80101ee5 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f6f:	83 c3 01             	add    $0x1,%ebx
80101f72:	39 fb                	cmp    %edi,%ebx
80101f74:	7e d8                	jle    80101f4e <ioapicinit+0x54>
  }
}
80101f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f79:	5b                   	pop    %ebx
80101f7a:	5e                   	pop    %esi
80101f7b:	5f                   	pop    %edi
80101f7c:	5d                   	pop    %ebp
80101f7d:	c3                   	ret    

80101f7e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f7e:	55                   	push   %ebp
80101f7f:	89 e5                	mov    %esp,%ebp
80101f81:	53                   	push   %ebx
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f85:	8d 50 20             	lea    0x20(%eax),%edx
80101f88:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f8c:	89 d8                	mov    %ebx,%eax
80101f8e:	e8 52 ff ff ff       	call   80101ee5 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f96:	c1 e2 18             	shl    $0x18,%edx
80101f99:	8d 43 01             	lea    0x1(%ebx),%eax
80101f9c:	e8 44 ff ff ff       	call   80101ee5 <ioapicwrite>
}
80101fa1:	5b                   	pop    %ebx
80101fa2:	5d                   	pop    %ebp
80101fa3:	c3                   	ret    

80101fa4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fa4:	55                   	push   %ebp
80101fa5:	89 e5                	mov    %esp,%ebp
80101fa7:	53                   	push   %ebx
80101fa8:	83 ec 04             	sub    $0x4,%esp
80101fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fae:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fb4:	75 4c                	jne    80102002 <kfree+0x5e>
80101fb6:	81 fb c8 44 13 80    	cmp    $0x801344c8,%ebx
80101fbc:	72 44                	jb     80102002 <kfree+0x5e>
80101fbe:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fc4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fc9:	77 37                	ja     80102002 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fcb:	83 ec 04             	sub    $0x4,%esp
80101fce:	68 00 10 00 00       	push   $0x1000
80101fd3:	6a 01                	push   $0x1
80101fd5:	53                   	push   %ebx
80101fd6:	e8 13 1d 00 00       	call   80103cee <memset>

  if(kmem.use_lock)
80101fdb:	83 c4 10             	add    $0x10,%esp
80101fde:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
80101fe5:	75 28                	jne    8010200f <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fe7:	a1 98 16 13 80       	mov    0x80131698,%eax
80101fec:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fee:	89 1d 98 16 13 80    	mov    %ebx,0x80131698
  if(kmem.use_lock)
80101ff4:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
80101ffb:	75 24                	jne    80102021 <kfree+0x7d>
    release(&kmem.lock);
}
80101ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102000:	c9                   	leave  
80102001:	c3                   	ret    
    panic("kfree");
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	68 a6 67 10 80       	push   $0x801067a6
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 60 16 13 80       	push   $0x80131660
80102017:	e8 26 1c 00 00       	call   80103c42 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 16 13 80       	push   $0x80131660
80102029:	e8 79 1c 00 00       	call   80103ca7 <release>
8010202e:	83 c4 10             	add    $0x10,%esp
}
80102031:	eb ca                	jmp    80101ffd <kfree+0x59>

80102033 <freerange>:
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	56                   	push   %esi
80102037:	53                   	push   %ebx
80102038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102043:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102048:	eb 0e                	jmp    80102058 <freerange+0x25>
    kfree(p);
8010204a:	83 ec 0c             	sub    $0xc,%esp
8010204d:	50                   	push   %eax
8010204e:	e8 51 ff ff ff       	call   80101fa4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102053:	83 c4 10             	add    $0x10,%esp
80102056:	89 f0                	mov    %esi,%eax
80102058:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010205e:	39 de                	cmp    %ebx,%esi
80102060:	76 e8                	jbe    8010204a <freerange+0x17>
}
80102062:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102065:	5b                   	pop    %ebx
80102066:	5e                   	pop    %esi
80102067:	5d                   	pop    %ebp
80102068:	c3                   	ret    

80102069 <kinit1>:
{
80102069:	55                   	push   %ebp
8010206a:	89 e5                	mov    %esp,%ebp
8010206c:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010206f:	68 ac 67 10 80       	push   $0x801067ac
80102074:	68 60 16 13 80       	push   $0x80131660
80102079:	e8 88 1a 00 00       	call   80103b06 <initlock>
  kmem.use_lock = 0;
8010207e:	c7 05 94 16 13 80 00 	movl   $0x0,0x80131694
80102085:	00 00 00 
  freerange(vstart, vend);
80102088:	83 c4 08             	add    $0x8,%esp
8010208b:	ff 75 0c             	pushl  0xc(%ebp)
8010208e:	ff 75 08             	pushl  0x8(%ebp)
80102091:	e8 9d ff ff ff       	call   80102033 <freerange>
}
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	c9                   	leave  
8010209a:	c3                   	ret    

8010209b <kinit2>:
{
8010209b:	55                   	push   %ebp
8010209c:	89 e5                	mov    %esp,%ebp
8010209e:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	ff 75 08             	pushl  0x8(%ebp)
801020a7:	e8 87 ff ff ff       	call   80102033 <freerange>
  kmem.use_lock = 1;
801020ac:	c7 05 94 16 13 80 01 	movl   $0x1,0x80131694
801020b3:	00 00 00 
}
801020b6:	83 c4 10             	add    $0x10,%esp
801020b9:	c9                   	leave  
801020ba:	c3                   	ret    

801020bb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020bb:	55                   	push   %ebp
801020bc:	89 e5                	mov    %esp,%ebp
801020be:	53                   	push   %ebx
801020bf:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020c2:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
801020c9:	75 4d                	jne    80102118 <kalloc+0x5d>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020cb:	8b 1d 98 16 13 80    	mov    0x80131698,%ebx
  if(r) {
801020d1:	85 db                	test   %ebx,%ebx
801020d3:	74 0d                	je     801020e2 <kalloc+0x27>
    if (r->next) {
801020d5:	8b 03                	mov    (%ebx),%eax
801020d7:	85 c0                	test   %eax,%eax
801020d9:	74 4f                	je     8010212a <kalloc+0x6f>
      kmem.freelist = r->next->next;
801020db:	8b 00                	mov    (%eax),%eax
801020dd:	a3 98 16 13 80       	mov    %eax,0x80131698
    } else {
      kmem.freelist = r->next;
    }
  }
  //
  int addr = (V2P((char*)r) >> 12);
801020e2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801020e8:	c1 e8 0c             	shr    $0xc,%eax
  if (addr > 0x3FF) {
801020eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
801020f0:	7e 16                	jle    80102108 <kalloc+0x4d>
    frame[size++] = addr;
801020f2:	8b 15 b4 95 12 80    	mov    0x801295b4,%edx
801020f8:	8d 4a 01             	lea    0x1(%edx),%ecx
801020fb:	89 0d b4 95 12 80    	mov    %ecx,0x801295b4
80102101:	89 04 95 00 70 11 80 	mov    %eax,-0x7fee9000(,%edx,4)
  }
  //
  if(kmem.use_lock)
80102108:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
8010210f:	75 20                	jne    80102131 <kalloc+0x76>
    release(&kmem.lock);
  return (char*)r;
}
80102111:	89 d8                	mov    %ebx,%eax
80102113:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102116:	c9                   	leave  
80102117:	c3                   	ret    
    acquire(&kmem.lock);
80102118:	83 ec 0c             	sub    $0xc,%esp
8010211b:	68 60 16 13 80       	push   $0x80131660
80102120:	e8 1d 1b 00 00       	call   80103c42 <acquire>
80102125:	83 c4 10             	add    $0x10,%esp
80102128:	eb a1                	jmp    801020cb <kalloc+0x10>
      kmem.freelist = r->next;
8010212a:	a3 98 16 13 80       	mov    %eax,0x80131698
8010212f:	eb b1                	jmp    801020e2 <kalloc+0x27>
    release(&kmem.lock);
80102131:	83 ec 0c             	sub    $0xc,%esp
80102134:	68 60 16 13 80       	push   $0x80131660
80102139:	e8 69 1b 00 00       	call   80103ca7 <release>
8010213e:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102141:	eb ce                	jmp    80102111 <kalloc+0x56>

80102143 <dump_physmem>:

int
dump_physmem(int *frames, int *pids, int numframes)
{
80102143:	55                   	push   %ebp
80102144:	89 e5                	mov    %esp,%ebp
80102146:	57                   	push   %edi
80102147:	56                   	push   %esi
80102148:	53                   	push   %ebx
80102149:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010214c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010214f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if (frames == NULL || pids == NULL || numframes < 0) {
80102152:	85 db                	test   %ebx,%ebx
80102154:	0f 94 c2             	sete   %dl
80102157:	85 f6                	test   %esi,%esi
80102159:	0f 94 c0             	sete   %al
8010215c:	08 c2                	or     %al,%dl
8010215e:	75 4f                	jne    801021af <dump_physmem+0x6c>
80102160:	85 c9                	test   %ecx,%ecx
80102162:	78 52                	js     801021b6 <dump_physmem+0x73>
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
80102164:	b8 00 00 00 00       	mov    $0x0,%eax
80102169:	eb 18                	jmp    80102183 <dump_physmem+0x40>
    if (frame[i] != 0){
      frames[i] = frame[i];
      pids[i] = -2;
    }else{
      frames[i] = -1;
8010216b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102172:	c7 04 13 ff ff ff ff 	movl   $0xffffffff,(%ebx,%edx,1)
      pids[i] = -1;
80102179:	c7 04 16 ff ff ff ff 	movl   $0xffffffff,(%esi,%edx,1)
  for (int i = 0; i < numframes; i++) {
80102180:	83 c0 01             	add    $0x1,%eax
80102183:	39 c8                	cmp    %ecx,%eax
80102185:	7d 1e                	jge    801021a5 <dump_physmem+0x62>
    if (frame[i] != 0){
80102187:	8b 14 85 00 70 11 80 	mov    -0x7fee9000(,%eax,4),%edx
8010218e:	85 d2                	test   %edx,%edx
80102190:	74 d9                	je     8010216b <dump_physmem+0x28>
      frames[i] = frame[i];
80102192:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
80102199:	89 14 3b             	mov    %edx,(%ebx,%edi,1)
      pids[i] = -2;
8010219c:	c7 04 3e fe ff ff ff 	movl   $0xfffffffe,(%esi,%edi,1)
801021a3:	eb db                	jmp    80102180 <dump_physmem+0x3d>
    }
  }
  return 0;
801021a5:	b8 00 00 00 00       	mov    $0x0,%eax
801021aa:	5b                   	pop    %ebx
801021ab:	5e                   	pop    %esi
801021ac:	5f                   	pop    %edi
801021ad:	5d                   	pop    %ebp
801021ae:	c3                   	ret    
      return -1;
801021af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021b4:	eb f4                	jmp    801021aa <dump_physmem+0x67>
801021b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021bb:	eb ed                	jmp    801021aa <dump_physmem+0x67>

801021bd <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801021bd:	55                   	push   %ebp
801021be:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021c0:	ba 64 00 00 00       	mov    $0x64,%edx
801021c5:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801021c6:	a8 01                	test   $0x1,%al
801021c8:	0f 84 b5 00 00 00    	je     80102283 <kbdgetc+0xc6>
801021ce:	ba 60 00 00 00       	mov    $0x60,%edx
801021d3:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801021d4:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801021d7:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801021dd:	74 5c                	je     8010223b <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801021df:	84 c0                	test   %al,%al
801021e1:	78 66                	js     80102249 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801021e3:	8b 0d b8 95 12 80    	mov    0x801295b8,%ecx
801021e9:	f6 c1 40             	test   $0x40,%cl
801021ec:	74 0f                	je     801021fd <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801021ee:	83 c8 80             	or     $0xffffff80,%eax
801021f1:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801021f4:	83 e1 bf             	and    $0xffffffbf,%ecx
801021f7:	89 0d b8 95 12 80    	mov    %ecx,0x801295b8
  }

  shift |= shiftcode[data];
801021fd:	0f b6 8a e0 68 10 80 	movzbl -0x7fef9720(%edx),%ecx
80102204:	0b 0d b8 95 12 80    	or     0x801295b8,%ecx
  shift ^= togglecode[data];
8010220a:	0f b6 82 e0 67 10 80 	movzbl -0x7fef9820(%edx),%eax
80102211:	31 c1                	xor    %eax,%ecx
80102213:	89 0d b8 95 12 80    	mov    %ecx,0x801295b8
  c = charcode[shift & (CTL | SHIFT)][data];
80102219:	89 c8                	mov    %ecx,%eax
8010221b:	83 e0 03             	and    $0x3,%eax
8010221e:	8b 04 85 c0 67 10 80 	mov    -0x7fef9840(,%eax,4),%eax
80102225:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102229:	f6 c1 08             	test   $0x8,%cl
8010222c:	74 19                	je     80102247 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
8010222e:	8d 50 9f             	lea    -0x61(%eax),%edx
80102231:	83 fa 19             	cmp    $0x19,%edx
80102234:	77 40                	ja     80102276 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102236:	83 e8 20             	sub    $0x20,%eax
80102239:	eb 0c                	jmp    80102247 <kbdgetc+0x8a>
    shift |= E0ESC;
8010223b:	83 0d b8 95 12 80 40 	orl    $0x40,0x801295b8
    return 0;
80102242:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102247:	5d                   	pop    %ebp
80102248:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102249:	8b 0d b8 95 12 80    	mov    0x801295b8,%ecx
8010224f:	f6 c1 40             	test   $0x40,%cl
80102252:	75 05                	jne    80102259 <kbdgetc+0x9c>
80102254:	89 c2                	mov    %eax,%edx
80102256:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102259:	0f b6 82 e0 68 10 80 	movzbl -0x7fef9720(%edx),%eax
80102260:	83 c8 40             	or     $0x40,%eax
80102263:	0f b6 c0             	movzbl %al,%eax
80102266:	f7 d0                	not    %eax
80102268:	21 c8                	and    %ecx,%eax
8010226a:	a3 b8 95 12 80       	mov    %eax,0x801295b8
    return 0;
8010226f:	b8 00 00 00 00       	mov    $0x0,%eax
80102274:	eb d1                	jmp    80102247 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
80102276:	8d 50 bf             	lea    -0x41(%eax),%edx
80102279:	83 fa 19             	cmp    $0x19,%edx
8010227c:	77 c9                	ja     80102247 <kbdgetc+0x8a>
      c += 'a' - 'A';
8010227e:	83 c0 20             	add    $0x20,%eax
  return c;
80102281:	eb c4                	jmp    80102247 <kbdgetc+0x8a>
    return -1;
80102283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102288:	eb bd                	jmp    80102247 <kbdgetc+0x8a>

8010228a <kbdintr>:

void
kbdintr(void)
{
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102290:	68 bd 21 10 80       	push   $0x801021bd
80102295:	e8 a4 e4 ff ff       	call   8010073e <consoleintr>
}
8010229a:	83 c4 10             	add    $0x10,%esp
8010229d:	c9                   	leave  
8010229e:	c3                   	ret    

8010229f <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010229f:	55                   	push   %ebp
801022a0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801022a2:	8b 0d 9c 16 13 80    	mov    0x8013169c,%ecx
801022a8:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022ab:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801022ad:	a1 9c 16 13 80       	mov    0x8013169c,%eax
801022b2:	8b 40 20             	mov    0x20(%eax),%eax
}
801022b5:	5d                   	pop    %ebp
801022b6:	c3                   	ret    

801022b7 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801022b7:	55                   	push   %ebp
801022b8:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801022ba:	ba 70 00 00 00       	mov    $0x70,%edx
801022bf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022c0:	ba 71 00 00 00       	mov    $0x71,%edx
801022c5:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801022c6:	0f b6 c0             	movzbl %al,%eax
}
801022c9:	5d                   	pop    %ebp
801022ca:	c3                   	ret    

801022cb <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801022cb:	55                   	push   %ebp
801022cc:	89 e5                	mov    %esp,%ebp
801022ce:	53                   	push   %ebx
801022cf:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801022d1:	b8 00 00 00 00       	mov    $0x0,%eax
801022d6:	e8 dc ff ff ff       	call   801022b7 <cmos_read>
801022db:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801022dd:	b8 02 00 00 00       	mov    $0x2,%eax
801022e2:	e8 d0 ff ff ff       	call   801022b7 <cmos_read>
801022e7:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801022ea:	b8 04 00 00 00       	mov    $0x4,%eax
801022ef:	e8 c3 ff ff ff       	call   801022b7 <cmos_read>
801022f4:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801022f7:	b8 07 00 00 00       	mov    $0x7,%eax
801022fc:	e8 b6 ff ff ff       	call   801022b7 <cmos_read>
80102301:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102304:	b8 08 00 00 00       	mov    $0x8,%eax
80102309:	e8 a9 ff ff ff       	call   801022b7 <cmos_read>
8010230e:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102311:	b8 09 00 00 00       	mov    $0x9,%eax
80102316:	e8 9c ff ff ff       	call   801022b7 <cmos_read>
8010231b:	89 43 14             	mov    %eax,0x14(%ebx)
}
8010231e:	5b                   	pop    %ebx
8010231f:	5d                   	pop    %ebp
80102320:	c3                   	ret    

80102321 <lapicinit>:
  if(!lapic)
80102321:	83 3d 9c 16 13 80 00 	cmpl   $0x0,0x8013169c
80102328:	0f 84 fb 00 00 00    	je     80102429 <lapicinit+0x108>
{
8010232e:	55                   	push   %ebp
8010232f:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102331:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102336:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010233b:	e8 5f ff ff ff       	call   8010229f <lapicw>
  lapicw(TDCR, X1);
80102340:	ba 0b 00 00 00       	mov    $0xb,%edx
80102345:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010234a:	e8 50 ff ff ff       	call   8010229f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010234f:	ba 20 00 02 00       	mov    $0x20020,%edx
80102354:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102359:	e8 41 ff ff ff       	call   8010229f <lapicw>
  lapicw(TICR, 10000000);
8010235e:	ba 80 96 98 00       	mov    $0x989680,%edx
80102363:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102368:	e8 32 ff ff ff       	call   8010229f <lapicw>
  lapicw(LINT0, MASKED);
8010236d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102372:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102377:	e8 23 ff ff ff       	call   8010229f <lapicw>
  lapicw(LINT1, MASKED);
8010237c:	ba 00 00 01 00       	mov    $0x10000,%edx
80102381:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102386:	e8 14 ff ff ff       	call   8010229f <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010238b:	a1 9c 16 13 80       	mov    0x8013169c,%eax
80102390:	8b 40 30             	mov    0x30(%eax),%eax
80102393:	c1 e8 10             	shr    $0x10,%eax
80102396:	3c 03                	cmp    $0x3,%al
80102398:	77 7b                	ja     80102415 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010239a:	ba 33 00 00 00       	mov    $0x33,%edx
8010239f:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023a4:	e8 f6 fe ff ff       	call   8010229f <lapicw>
  lapicw(ESR, 0);
801023a9:	ba 00 00 00 00       	mov    $0x0,%edx
801023ae:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023b3:	e8 e7 fe ff ff       	call   8010229f <lapicw>
  lapicw(ESR, 0);
801023b8:	ba 00 00 00 00       	mov    $0x0,%edx
801023bd:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023c2:	e8 d8 fe ff ff       	call   8010229f <lapicw>
  lapicw(EOI, 0);
801023c7:	ba 00 00 00 00       	mov    $0x0,%edx
801023cc:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023d1:	e8 c9 fe ff ff       	call   8010229f <lapicw>
  lapicw(ICRHI, 0);
801023d6:	ba 00 00 00 00       	mov    $0x0,%edx
801023db:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023e0:	e8 ba fe ff ff       	call   8010229f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801023e5:	ba 00 85 08 00       	mov    $0x88500,%edx
801023ea:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023ef:	e8 ab fe ff ff       	call   8010229f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801023f4:	a1 9c 16 13 80       	mov    0x8013169c,%eax
801023f9:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801023ff:	f6 c4 10             	test   $0x10,%ah
80102402:	75 f0                	jne    801023f4 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102404:	ba 00 00 00 00       	mov    $0x0,%edx
80102409:	b8 20 00 00 00       	mov    $0x20,%eax
8010240e:	e8 8c fe ff ff       	call   8010229f <lapicw>
}
80102413:	5d                   	pop    %ebp
80102414:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102415:	ba 00 00 01 00       	mov    $0x10000,%edx
8010241a:	b8 d0 00 00 00       	mov    $0xd0,%eax
8010241f:	e8 7b fe ff ff       	call   8010229f <lapicw>
80102424:	e9 71 ff ff ff       	jmp    8010239a <lapicinit+0x79>
80102429:	f3 c3                	repz ret 

8010242b <lapicid>:
{
8010242b:	55                   	push   %ebp
8010242c:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010242e:	a1 9c 16 13 80       	mov    0x8013169c,%eax
80102433:	85 c0                	test   %eax,%eax
80102435:	74 08                	je     8010243f <lapicid+0x14>
  return lapic[ID] >> 24;
80102437:	8b 40 20             	mov    0x20(%eax),%eax
8010243a:	c1 e8 18             	shr    $0x18,%eax
}
8010243d:	5d                   	pop    %ebp
8010243e:	c3                   	ret    
    return 0;
8010243f:	b8 00 00 00 00       	mov    $0x0,%eax
80102444:	eb f7                	jmp    8010243d <lapicid+0x12>

80102446 <lapiceoi>:
  if(lapic)
80102446:	83 3d 9c 16 13 80 00 	cmpl   $0x0,0x8013169c
8010244d:	74 14                	je     80102463 <lapiceoi+0x1d>
{
8010244f:	55                   	push   %ebp
80102450:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102452:	ba 00 00 00 00       	mov    $0x0,%edx
80102457:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010245c:	e8 3e fe ff ff       	call   8010229f <lapicw>
}
80102461:	5d                   	pop    %ebp
80102462:	c3                   	ret    
80102463:	f3 c3                	repz ret 

80102465 <microdelay>:
{
80102465:	55                   	push   %ebp
80102466:	89 e5                	mov    %esp,%ebp
}
80102468:	5d                   	pop    %ebp
80102469:	c3                   	ret    

8010246a <lapicstartap>:
{
8010246a:	55                   	push   %ebp
8010246b:	89 e5                	mov    %esp,%ebp
8010246d:	57                   	push   %edi
8010246e:	56                   	push   %esi
8010246f:	53                   	push   %ebx
80102470:	8b 75 08             	mov    0x8(%ebp),%esi
80102473:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102476:	b8 0f 00 00 00       	mov    $0xf,%eax
8010247b:	ba 70 00 00 00       	mov    $0x70,%edx
80102480:	ee                   	out    %al,(%dx)
80102481:	b8 0a 00 00 00       	mov    $0xa,%eax
80102486:	ba 71 00 00 00       	mov    $0x71,%edx
8010248b:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
8010248c:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102493:	00 00 
  wrv[1] = addr >> 4;
80102495:	89 f8                	mov    %edi,%eax
80102497:	c1 e8 04             	shr    $0x4,%eax
8010249a:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801024a0:	c1 e6 18             	shl    $0x18,%esi
801024a3:	89 f2                	mov    %esi,%edx
801024a5:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024aa:	e8 f0 fd ff ff       	call   8010229f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801024af:	ba 00 c5 00 00       	mov    $0xc500,%edx
801024b4:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024b9:	e8 e1 fd ff ff       	call   8010229f <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801024be:	ba 00 85 00 00       	mov    $0x8500,%edx
801024c3:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024c8:	e8 d2 fd ff ff       	call   8010229f <lapicw>
  for(i = 0; i < 2; i++){
801024cd:	bb 00 00 00 00       	mov    $0x0,%ebx
801024d2:	eb 21                	jmp    801024f5 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801024d4:	89 f2                	mov    %esi,%edx
801024d6:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024db:	e8 bf fd ff ff       	call   8010229f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801024e0:	89 fa                	mov    %edi,%edx
801024e2:	c1 ea 0c             	shr    $0xc,%edx
801024e5:	80 ce 06             	or     $0x6,%dh
801024e8:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024ed:	e8 ad fd ff ff       	call   8010229f <lapicw>
  for(i = 0; i < 2; i++){
801024f2:	83 c3 01             	add    $0x1,%ebx
801024f5:	83 fb 01             	cmp    $0x1,%ebx
801024f8:	7e da                	jle    801024d4 <lapicstartap+0x6a>
}
801024fa:	5b                   	pop    %ebx
801024fb:	5e                   	pop    %esi
801024fc:	5f                   	pop    %edi
801024fd:	5d                   	pop    %ebp
801024fe:	c3                   	ret    

801024ff <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801024ff:	55                   	push   %ebp
80102500:	89 e5                	mov    %esp,%ebp
80102502:	57                   	push   %edi
80102503:	56                   	push   %esi
80102504:	53                   	push   %ebx
80102505:	83 ec 3c             	sub    $0x3c,%esp
80102508:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010250b:	b8 0b 00 00 00       	mov    $0xb,%eax
80102510:	e8 a2 fd ff ff       	call   801022b7 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102515:	83 e0 04             	and    $0x4,%eax
80102518:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010251a:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010251d:	e8 a9 fd ff ff       	call   801022cb <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102522:	b8 0a 00 00 00       	mov    $0xa,%eax
80102527:	e8 8b fd ff ff       	call   801022b7 <cmos_read>
8010252c:	a8 80                	test   $0x80,%al
8010252e:	75 ea                	jne    8010251a <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102530:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102533:	89 d8                	mov    %ebx,%eax
80102535:	e8 91 fd ff ff       	call   801022cb <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010253a:	83 ec 04             	sub    $0x4,%esp
8010253d:	6a 18                	push   $0x18
8010253f:	53                   	push   %ebx
80102540:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102543:	50                   	push   %eax
80102544:	e8 eb 17 00 00       	call   80103d34 <memcmp>
80102549:	83 c4 10             	add    $0x10,%esp
8010254c:	85 c0                	test   %eax,%eax
8010254e:	75 ca                	jne    8010251a <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102550:	85 ff                	test   %edi,%edi
80102552:	0f 85 84 00 00 00    	jne    801025dc <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102558:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010255b:	89 d0                	mov    %edx,%eax
8010255d:	c1 e8 04             	shr    $0x4,%eax
80102560:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102563:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102566:	83 e2 0f             	and    $0xf,%edx
80102569:	01 d0                	add    %edx,%eax
8010256b:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010256e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102571:	89 d0                	mov    %edx,%eax
80102573:	c1 e8 04             	shr    $0x4,%eax
80102576:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102579:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010257c:	83 e2 0f             	and    $0xf,%edx
8010257f:	01 d0                	add    %edx,%eax
80102581:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102584:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102587:	89 d0                	mov    %edx,%eax
80102589:	c1 e8 04             	shr    $0x4,%eax
8010258c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010258f:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102592:	83 e2 0f             	and    $0xf,%edx
80102595:	01 d0                	add    %edx,%eax
80102597:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
8010259a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010259d:	89 d0                	mov    %edx,%eax
8010259f:	c1 e8 04             	shr    $0x4,%eax
801025a2:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025a5:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025a8:	83 e2 0f             	and    $0xf,%edx
801025ab:	01 d0                	add    %edx,%eax
801025ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801025b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801025b3:	89 d0                	mov    %edx,%eax
801025b5:	c1 e8 04             	shr    $0x4,%eax
801025b8:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025bb:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025be:	83 e2 0f             	and    $0xf,%edx
801025c1:	01 d0                	add    %edx,%eax
801025c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801025c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801025c9:	89 d0                	mov    %edx,%eax
801025cb:	c1 e8 04             	shr    $0x4,%eax
801025ce:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025d1:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025d4:	83 e2 0f             	and    $0xf,%edx
801025d7:	01 d0                	add    %edx,%eax
801025d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801025dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801025df:	89 06                	mov    %eax,(%esi)
801025e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801025e4:	89 46 04             	mov    %eax,0x4(%esi)
801025e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801025ea:	89 46 08             	mov    %eax,0x8(%esi)
801025ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801025f0:	89 46 0c             	mov    %eax,0xc(%esi)
801025f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801025f6:	89 46 10             	mov    %eax,0x10(%esi)
801025f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801025fc:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801025ff:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102606:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102609:	5b                   	pop    %ebx
8010260a:	5e                   	pop    %esi
8010260b:	5f                   	pop    %edi
8010260c:	5d                   	pop    %ebp
8010260d:	c3                   	ret    

8010260e <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010260e:	55                   	push   %ebp
8010260f:	89 e5                	mov    %esp,%ebp
80102611:	53                   	push   %ebx
80102612:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102615:	ff 35 d4 16 13 80    	pushl  0x801316d4
8010261b:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102621:	e8 46 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102626:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102629:	89 1d e8 16 13 80    	mov    %ebx,0x801316e8
  for (i = 0; i < log.lh.n; i++) {
8010262f:	83 c4 10             	add    $0x10,%esp
80102632:	ba 00 00 00 00       	mov    $0x0,%edx
80102637:	eb 0e                	jmp    80102647 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102639:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
8010263d:	89 0c 95 ec 16 13 80 	mov    %ecx,-0x7fece914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102644:	83 c2 01             	add    $0x1,%edx
80102647:	39 d3                	cmp    %edx,%ebx
80102649:	7f ee                	jg     80102639 <read_head+0x2b>
  }
  brelse(buf);
8010264b:	83 ec 0c             	sub    $0xc,%esp
8010264e:	50                   	push   %eax
8010264f:	e8 81 db ff ff       	call   801001d5 <brelse>
}
80102654:	83 c4 10             	add    $0x10,%esp
80102657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010265a:	c9                   	leave  
8010265b:	c3                   	ret    

8010265c <install_trans>:
{
8010265c:	55                   	push   %ebp
8010265d:	89 e5                	mov    %esp,%ebp
8010265f:	57                   	push   %edi
80102660:	56                   	push   %esi
80102661:	53                   	push   %ebx
80102662:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102665:	bb 00 00 00 00       	mov    $0x0,%ebx
8010266a:	eb 66                	jmp    801026d2 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010266c:	89 d8                	mov    %ebx,%eax
8010266e:	03 05 d4 16 13 80    	add    0x801316d4,%eax
80102674:	83 c0 01             	add    $0x1,%eax
80102677:	83 ec 08             	sub    $0x8,%esp
8010267a:	50                   	push   %eax
8010267b:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102681:	e8 e6 da ff ff       	call   8010016c <bread>
80102686:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102688:	83 c4 08             	add    $0x8,%esp
8010268b:	ff 34 9d ec 16 13 80 	pushl  -0x7fece914(,%ebx,4)
80102692:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102698:	e8 cf da ff ff       	call   8010016c <bread>
8010269d:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010269f:	8d 57 5c             	lea    0x5c(%edi),%edx
801026a2:	8d 40 5c             	lea    0x5c(%eax),%eax
801026a5:	83 c4 0c             	add    $0xc,%esp
801026a8:	68 00 02 00 00       	push   $0x200
801026ad:	52                   	push   %edx
801026ae:	50                   	push   %eax
801026af:	e8 b5 16 00 00       	call   80103d69 <memmove>
    bwrite(dbuf);  // write dst to disk
801026b4:	89 34 24             	mov    %esi,(%esp)
801026b7:	e8 de da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801026bc:	89 3c 24             	mov    %edi,(%esp)
801026bf:	e8 11 db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801026c4:	89 34 24             	mov    %esi,(%esp)
801026c7:	e8 09 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801026cc:	83 c3 01             	add    $0x1,%ebx
801026cf:	83 c4 10             	add    $0x10,%esp
801026d2:	39 1d e8 16 13 80    	cmp    %ebx,0x801316e8
801026d8:	7f 92                	jg     8010266c <install_trans+0x10>
}
801026da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026dd:	5b                   	pop    %ebx
801026de:	5e                   	pop    %esi
801026df:	5f                   	pop    %edi
801026e0:	5d                   	pop    %ebp
801026e1:	c3                   	ret    

801026e2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801026e2:	55                   	push   %ebp
801026e3:	89 e5                	mov    %esp,%ebp
801026e5:	53                   	push   %ebx
801026e6:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801026e9:	ff 35 d4 16 13 80    	pushl  0x801316d4
801026ef:	ff 35 e4 16 13 80    	pushl  0x801316e4
801026f5:	e8 72 da ff ff       	call   8010016c <bread>
801026fa:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801026fc:	8b 0d e8 16 13 80    	mov    0x801316e8,%ecx
80102702:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102705:	83 c4 10             	add    $0x10,%esp
80102708:	b8 00 00 00 00       	mov    $0x0,%eax
8010270d:	eb 0e                	jmp    8010271d <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
8010270f:	8b 14 85 ec 16 13 80 	mov    -0x7fece914(,%eax,4),%edx
80102716:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010271a:	83 c0 01             	add    $0x1,%eax
8010271d:	39 c1                	cmp    %eax,%ecx
8010271f:	7f ee                	jg     8010270f <write_head+0x2d>
  }
  bwrite(buf);
80102721:	83 ec 0c             	sub    $0xc,%esp
80102724:	53                   	push   %ebx
80102725:	e8 70 da ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010272a:	89 1c 24             	mov    %ebx,(%esp)
8010272d:	e8 a3 da ff ff       	call   801001d5 <brelse>
}
80102732:	83 c4 10             	add    $0x10,%esp
80102735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102738:	c9                   	leave  
80102739:	c3                   	ret    

8010273a <recover_from_log>:

static void
recover_from_log(void)
{
8010273a:	55                   	push   %ebp
8010273b:	89 e5                	mov    %esp,%ebp
8010273d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102740:	e8 c9 fe ff ff       	call   8010260e <read_head>
  install_trans(); // if committed, copy from log to disk
80102745:	e8 12 ff ff ff       	call   8010265c <install_trans>
  log.lh.n = 0;
8010274a:	c7 05 e8 16 13 80 00 	movl   $0x0,0x801316e8
80102751:	00 00 00 
  write_head(); // clear the log
80102754:	e8 89 ff ff ff       	call   801026e2 <write_head>
}
80102759:	c9                   	leave  
8010275a:	c3                   	ret    

8010275b <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010275b:	55                   	push   %ebp
8010275c:	89 e5                	mov    %esp,%ebp
8010275e:	57                   	push   %edi
8010275f:	56                   	push   %esi
80102760:	53                   	push   %ebx
80102761:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102764:	bb 00 00 00 00       	mov    $0x0,%ebx
80102769:	eb 66                	jmp    801027d1 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010276b:	89 d8                	mov    %ebx,%eax
8010276d:	03 05 d4 16 13 80    	add    0x801316d4,%eax
80102773:	83 c0 01             	add    $0x1,%eax
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	50                   	push   %eax
8010277a:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102780:	e8 e7 d9 ff ff       	call   8010016c <bread>
80102785:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102787:	83 c4 08             	add    $0x8,%esp
8010278a:	ff 34 9d ec 16 13 80 	pushl  -0x7fece914(,%ebx,4)
80102791:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102797:	e8 d0 d9 ff ff       	call   8010016c <bread>
8010279c:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010279e:	8d 50 5c             	lea    0x5c(%eax),%edx
801027a1:	8d 46 5c             	lea    0x5c(%esi),%eax
801027a4:	83 c4 0c             	add    $0xc,%esp
801027a7:	68 00 02 00 00       	push   $0x200
801027ac:	52                   	push   %edx
801027ad:	50                   	push   %eax
801027ae:	e8 b6 15 00 00       	call   80103d69 <memmove>
    bwrite(to);  // write the log
801027b3:	89 34 24             	mov    %esi,(%esp)
801027b6:	e8 df d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
801027bb:	89 3c 24             	mov    %edi,(%esp)
801027be:	e8 12 da ff ff       	call   801001d5 <brelse>
    brelse(to);
801027c3:	89 34 24             	mov    %esi,(%esp)
801027c6:	e8 0a da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027cb:	83 c3 01             	add    $0x1,%ebx
801027ce:	83 c4 10             	add    $0x10,%esp
801027d1:	39 1d e8 16 13 80    	cmp    %ebx,0x801316e8
801027d7:	7f 92                	jg     8010276b <write_log+0x10>
  }
}
801027d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027dc:	5b                   	pop    %ebx
801027dd:	5e                   	pop    %esi
801027de:	5f                   	pop    %edi
801027df:	5d                   	pop    %ebp
801027e0:	c3                   	ret    

801027e1 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801027e1:	83 3d e8 16 13 80 00 	cmpl   $0x0,0x801316e8
801027e8:	7e 26                	jle    80102810 <commit+0x2f>
{
801027ea:	55                   	push   %ebp
801027eb:	89 e5                	mov    %esp,%ebp
801027ed:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801027f0:	e8 66 ff ff ff       	call   8010275b <write_log>
    write_head();    // Write header to disk -- the real commit
801027f5:	e8 e8 fe ff ff       	call   801026e2 <write_head>
    install_trans(); // Now install writes to home locations
801027fa:	e8 5d fe ff ff       	call   8010265c <install_trans>
    log.lh.n = 0;
801027ff:	c7 05 e8 16 13 80 00 	movl   $0x0,0x801316e8
80102806:	00 00 00 
    write_head();    // Erase the transaction from the log
80102809:	e8 d4 fe ff ff       	call   801026e2 <write_head>
  }
}
8010280e:	c9                   	leave  
8010280f:	c3                   	ret    
80102810:	f3 c3                	repz ret 

80102812 <initlog>:
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	53                   	push   %ebx
80102816:	83 ec 2c             	sub    $0x2c,%esp
80102819:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010281c:	68 e0 69 10 80       	push   $0x801069e0
80102821:	68 a0 16 13 80       	push   $0x801316a0
80102826:	e8 db 12 00 00       	call   80103b06 <initlock>
  readsb(dev, &sb);
8010282b:	83 c4 08             	add    $0x8,%esp
8010282e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102831:	50                   	push   %eax
80102832:	53                   	push   %ebx
80102833:	e8 fe e9 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
80102838:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010283b:	a3 d4 16 13 80       	mov    %eax,0x801316d4
  log.size = sb.nlog;
80102840:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102843:	a3 d8 16 13 80       	mov    %eax,0x801316d8
  log.dev = dev;
80102848:	89 1d e4 16 13 80    	mov    %ebx,0x801316e4
  recover_from_log();
8010284e:	e8 e7 fe ff ff       	call   8010273a <recover_from_log>
}
80102853:	83 c4 10             	add    $0x10,%esp
80102856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102859:	c9                   	leave  
8010285a:	c3                   	ret    

8010285b <begin_op>:
{
8010285b:	55                   	push   %ebp
8010285c:	89 e5                	mov    %esp,%ebp
8010285e:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102861:	68 a0 16 13 80       	push   $0x801316a0
80102866:	e8 d7 13 00 00       	call   80103c42 <acquire>
8010286b:	83 c4 10             	add    $0x10,%esp
8010286e:	eb 15                	jmp    80102885 <begin_op+0x2a>
      sleep(&log, &log.lock);
80102870:	83 ec 08             	sub    $0x8,%esp
80102873:	68 a0 16 13 80       	push   $0x801316a0
80102878:	68 a0 16 13 80       	push   $0x801316a0
8010287d:	e8 c5 0e 00 00       	call   80103747 <sleep>
80102882:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102885:	83 3d e0 16 13 80 00 	cmpl   $0x0,0x801316e0
8010288c:	75 e2                	jne    80102870 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010288e:	a1 dc 16 13 80       	mov    0x801316dc,%eax
80102893:	83 c0 01             	add    $0x1,%eax
80102896:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102899:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
8010289c:	03 15 e8 16 13 80    	add    0x801316e8,%edx
801028a2:	83 fa 1e             	cmp    $0x1e,%edx
801028a5:	7e 17                	jle    801028be <begin_op+0x63>
      sleep(&log, &log.lock);
801028a7:	83 ec 08             	sub    $0x8,%esp
801028aa:	68 a0 16 13 80       	push   $0x801316a0
801028af:	68 a0 16 13 80       	push   $0x801316a0
801028b4:	e8 8e 0e 00 00       	call   80103747 <sleep>
801028b9:	83 c4 10             	add    $0x10,%esp
801028bc:	eb c7                	jmp    80102885 <begin_op+0x2a>
      log.outstanding += 1;
801028be:	a3 dc 16 13 80       	mov    %eax,0x801316dc
      release(&log.lock);
801028c3:	83 ec 0c             	sub    $0xc,%esp
801028c6:	68 a0 16 13 80       	push   $0x801316a0
801028cb:	e8 d7 13 00 00       	call   80103ca7 <release>
}
801028d0:	83 c4 10             	add    $0x10,%esp
801028d3:	c9                   	leave  
801028d4:	c3                   	ret    

801028d5 <end_op>:
{
801028d5:	55                   	push   %ebp
801028d6:	89 e5                	mov    %esp,%ebp
801028d8:	53                   	push   %ebx
801028d9:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801028dc:	68 a0 16 13 80       	push   $0x801316a0
801028e1:	e8 5c 13 00 00       	call   80103c42 <acquire>
  log.outstanding -= 1;
801028e6:	a1 dc 16 13 80       	mov    0x801316dc,%eax
801028eb:	83 e8 01             	sub    $0x1,%eax
801028ee:	a3 dc 16 13 80       	mov    %eax,0x801316dc
  if(log.committing)
801028f3:	8b 1d e0 16 13 80    	mov    0x801316e0,%ebx
801028f9:	83 c4 10             	add    $0x10,%esp
801028fc:	85 db                	test   %ebx,%ebx
801028fe:	75 2c                	jne    8010292c <end_op+0x57>
  if(log.outstanding == 0){
80102900:	85 c0                	test   %eax,%eax
80102902:	75 35                	jne    80102939 <end_op+0x64>
    log.committing = 1;
80102904:	c7 05 e0 16 13 80 01 	movl   $0x1,0x801316e0
8010290b:	00 00 00 
    do_commit = 1;
8010290e:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102913:	83 ec 0c             	sub    $0xc,%esp
80102916:	68 a0 16 13 80       	push   $0x801316a0
8010291b:	e8 87 13 00 00       	call   80103ca7 <release>
  if(do_commit){
80102920:	83 c4 10             	add    $0x10,%esp
80102923:	85 db                	test   %ebx,%ebx
80102925:	75 24                	jne    8010294b <end_op+0x76>
}
80102927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010292a:	c9                   	leave  
8010292b:	c3                   	ret    
    panic("log.committing");
8010292c:	83 ec 0c             	sub    $0xc,%esp
8010292f:	68 e4 69 10 80       	push   $0x801069e4
80102934:	e8 0f da ff ff       	call   80100348 <panic>
    wakeup(&log);
80102939:	83 ec 0c             	sub    $0xc,%esp
8010293c:	68 a0 16 13 80       	push   $0x801316a0
80102941:	e8 66 0f 00 00       	call   801038ac <wakeup>
80102946:	83 c4 10             	add    $0x10,%esp
80102949:	eb c8                	jmp    80102913 <end_op+0x3e>
    commit();
8010294b:	e8 91 fe ff ff       	call   801027e1 <commit>
    acquire(&log.lock);
80102950:	83 ec 0c             	sub    $0xc,%esp
80102953:	68 a0 16 13 80       	push   $0x801316a0
80102958:	e8 e5 12 00 00       	call   80103c42 <acquire>
    log.committing = 0;
8010295d:	c7 05 e0 16 13 80 00 	movl   $0x0,0x801316e0
80102964:	00 00 00 
    wakeup(&log);
80102967:	c7 04 24 a0 16 13 80 	movl   $0x801316a0,(%esp)
8010296e:	e8 39 0f 00 00       	call   801038ac <wakeup>
    release(&log.lock);
80102973:	c7 04 24 a0 16 13 80 	movl   $0x801316a0,(%esp)
8010297a:	e8 28 13 00 00       	call   80103ca7 <release>
8010297f:	83 c4 10             	add    $0x10,%esp
}
80102982:	eb a3                	jmp    80102927 <end_op+0x52>

80102984 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102984:	55                   	push   %ebp
80102985:	89 e5                	mov    %esp,%ebp
80102987:	53                   	push   %ebx
80102988:	83 ec 04             	sub    $0x4,%esp
8010298b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010298e:	8b 15 e8 16 13 80    	mov    0x801316e8,%edx
80102994:	83 fa 1d             	cmp    $0x1d,%edx
80102997:	7f 45                	jg     801029de <log_write+0x5a>
80102999:	a1 d8 16 13 80       	mov    0x801316d8,%eax
8010299e:	83 e8 01             	sub    $0x1,%eax
801029a1:	39 c2                	cmp    %eax,%edx
801029a3:	7d 39                	jge    801029de <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
801029a5:	83 3d dc 16 13 80 00 	cmpl   $0x0,0x801316dc
801029ac:	7e 3d                	jle    801029eb <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
801029ae:	83 ec 0c             	sub    $0xc,%esp
801029b1:	68 a0 16 13 80       	push   $0x801316a0
801029b6:	e8 87 12 00 00       	call   80103c42 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029bb:	83 c4 10             	add    $0x10,%esp
801029be:	b8 00 00 00 00       	mov    $0x0,%eax
801029c3:	8b 15 e8 16 13 80    	mov    0x801316e8,%edx
801029c9:	39 c2                	cmp    %eax,%edx
801029cb:	7e 2b                	jle    801029f8 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029cd:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029d0:	39 0c 85 ec 16 13 80 	cmp    %ecx,-0x7fece914(,%eax,4)
801029d7:	74 1f                	je     801029f8 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
801029d9:	83 c0 01             	add    $0x1,%eax
801029dc:	eb e5                	jmp    801029c3 <log_write+0x3f>
    panic("too big a transaction");
801029de:	83 ec 0c             	sub    $0xc,%esp
801029e1:	68 f3 69 10 80       	push   $0x801069f3
801029e6:	e8 5d d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
801029eb:	83 ec 0c             	sub    $0xc,%esp
801029ee:	68 09 6a 10 80       	push   $0x80106a09
801029f3:	e8 50 d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
801029f8:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029fb:	89 0c 85 ec 16 13 80 	mov    %ecx,-0x7fece914(,%eax,4)
  if (i == log.lh.n)
80102a02:	39 c2                	cmp    %eax,%edx
80102a04:	74 18                	je     80102a1e <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102a06:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102a09:	83 ec 0c             	sub    $0xc,%esp
80102a0c:	68 a0 16 13 80       	push   $0x801316a0
80102a11:	e8 91 12 00 00       	call   80103ca7 <release>
}
80102a16:	83 c4 10             	add    $0x10,%esp
80102a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a1c:	c9                   	leave  
80102a1d:	c3                   	ret    
    log.lh.n++;
80102a1e:	83 c2 01             	add    $0x1,%edx
80102a21:	89 15 e8 16 13 80    	mov    %edx,0x801316e8
80102a27:	eb dd                	jmp    80102a06 <log_write+0x82>

80102a29 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102a29:	55                   	push   %ebp
80102a2a:	89 e5                	mov    %esp,%ebp
80102a2c:	53                   	push   %ebx
80102a2d:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102a30:	68 8a 00 00 00       	push   $0x8a
80102a35:	68 8c 94 12 80       	push   $0x8012948c
80102a3a:	68 00 70 00 80       	push   $0x80007000
80102a3f:	e8 25 13 00 00       	call   80103d69 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102a44:	83 c4 10             	add    $0x10,%esp
80102a47:	bb a0 17 13 80       	mov    $0x801317a0,%ebx
80102a4c:	eb 06                	jmp    80102a54 <startothers+0x2b>
80102a4e:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102a54:	69 05 20 1d 13 80 b0 	imul   $0xb0,0x80131d20,%eax
80102a5b:	00 00 00 
80102a5e:	05 a0 17 13 80       	add    $0x801317a0,%eax
80102a63:	39 d8                	cmp    %ebx,%eax
80102a65:	76 4c                	jbe    80102ab3 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102a67:	e8 c0 07 00 00       	call   8010322c <mycpu>
80102a6c:	39 d8                	cmp    %ebx,%eax
80102a6e:	74 de                	je     80102a4e <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102a70:	e8 46 f6 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102a75:	05 00 10 00 00       	add    $0x1000,%eax
80102a7a:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102a7f:	c7 05 f8 6f 00 80 f7 	movl   $0x80102af7,0x80006ff8
80102a86:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102a89:	c7 05 f4 6f 00 80 00 	movl   $0x128000,0x80006ff4
80102a90:	80 12 00 

    lapicstartap(c->apicid, V2P(code));
80102a93:	83 ec 08             	sub    $0x8,%esp
80102a96:	68 00 70 00 00       	push   $0x7000
80102a9b:	0f b6 03             	movzbl (%ebx),%eax
80102a9e:	50                   	push   %eax
80102a9f:	e8 c6 f9 ff ff       	call   8010246a <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102aa4:	83 c4 10             	add    $0x10,%esp
80102aa7:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102aad:	85 c0                	test   %eax,%eax
80102aaf:	74 f6                	je     80102aa7 <startothers+0x7e>
80102ab1:	eb 9b                	jmp    80102a4e <startothers+0x25>
      ;
  }
}
80102ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ab6:	c9                   	leave  
80102ab7:	c3                   	ret    

80102ab8 <mpmain>:
{
80102ab8:	55                   	push   %ebp
80102ab9:	89 e5                	mov    %esp,%ebp
80102abb:	53                   	push   %ebx
80102abc:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102abf:	e8 c4 07 00 00       	call   80103288 <cpuid>
80102ac4:	89 c3                	mov    %eax,%ebx
80102ac6:	e8 bd 07 00 00       	call   80103288 <cpuid>
80102acb:	83 ec 04             	sub    $0x4,%esp
80102ace:	53                   	push   %ebx
80102acf:	50                   	push   %eax
80102ad0:	68 24 6a 10 80       	push   $0x80106a24
80102ad5:	e8 31 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102ada:	e8 e1 23 00 00       	call   80104ec0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102adf:	e8 48 07 00 00       	call   8010322c <mycpu>
80102ae4:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102ae6:	b8 01 00 00 00       	mov    $0x1,%eax
80102aeb:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102af2:	e8 2b 0a 00 00       	call   80103522 <scheduler>

80102af7 <mpenter>:
{
80102af7:	55                   	push   %ebp
80102af8:	89 e5                	mov    %esp,%ebp
80102afa:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102afd:	e8 c7 33 00 00       	call   80105ec9 <switchkvm>
  seginit();
80102b02:	e8 76 32 00 00       	call   80105d7d <seginit>
  lapicinit();
80102b07:	e8 15 f8 ff ff       	call   80102321 <lapicinit>
  mpmain();
80102b0c:	e8 a7 ff ff ff       	call   80102ab8 <mpmain>

80102b11 <main>:
{
80102b11:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102b15:	83 e4 f0             	and    $0xfffffff0,%esp
80102b18:	ff 71 fc             	pushl  -0x4(%ecx)
80102b1b:	55                   	push   %ebp
80102b1c:	89 e5                	mov    %esp,%ebp
80102b1e:	51                   	push   %ecx
80102b1f:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b22:	68 00 00 40 80       	push   $0x80400000
80102b27:	68 c8 44 13 80       	push   $0x801344c8
80102b2c:	e8 38 f5 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102b31:	e8 20 38 00 00       	call   80106356 <kvmalloc>
  mpinit();        // detect other processors
80102b36:	e8 c9 01 00 00       	call   80102d04 <mpinit>
  lapicinit();     // interrupt controller
80102b3b:	e8 e1 f7 ff ff       	call   80102321 <lapicinit>
  seginit();       // segment descriptors
80102b40:	e8 38 32 00 00       	call   80105d7d <seginit>
  picinit();       // disable pic
80102b45:	e8 82 02 00 00       	call   80102dcc <picinit>
  ioapicinit();    // another interrupt controller
80102b4a:	e8 ab f3 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102b4f:	e8 3a dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102b54:	e8 15 26 00 00       	call   8010516e <uartinit>
  pinit();         // process table
80102b59:	e8 b4 06 00 00       	call   80103212 <pinit>
  tvinit();        // trap vectors
80102b5e:	e8 ac 22 00 00       	call   80104e0f <tvinit>
  binit();         // buffer cache
80102b63:	e8 8c d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102b68:	e8 a6 e0 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102b6d:	e8 8e f1 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102b72:	e8 b2 fe ff ff       	call   80102a29 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b77:	83 c4 08             	add    $0x8,%esp
80102b7a:	68 00 00 00 8e       	push   $0x8e000000
80102b7f:	68 00 00 40 80       	push   $0x80400000
80102b84:	e8 12 f5 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102b89:	e8 39 07 00 00       	call   801032c7 <userinit>
  mpmain();        // finish this processor's setup
80102b8e:	e8 25 ff ff ff       	call   80102ab8 <mpmain>

80102b93 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b93:	55                   	push   %ebp
80102b94:	89 e5                	mov    %esp,%ebp
80102b96:	56                   	push   %esi
80102b97:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102b98:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
80102ba2:	eb 09                	jmp    80102bad <sum+0x1a>
    sum += addr[i];
80102ba4:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102ba8:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102baa:	83 c1 01             	add    $0x1,%ecx
80102bad:	39 d1                	cmp    %edx,%ecx
80102baf:	7c f3                	jl     80102ba4 <sum+0x11>
  return sum;
}
80102bb1:	89 d8                	mov    %ebx,%eax
80102bb3:	5b                   	pop    %ebx
80102bb4:	5e                   	pop    %esi
80102bb5:	5d                   	pop    %ebp
80102bb6:	c3                   	ret    

80102bb7 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102bb7:	55                   	push   %ebp
80102bb8:	89 e5                	mov    %esp,%ebp
80102bba:	56                   	push   %esi
80102bbb:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102bbc:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102bc2:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102bc4:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102bc6:	eb 03                	jmp    80102bcb <mpsearch1+0x14>
80102bc8:	83 c3 10             	add    $0x10,%ebx
80102bcb:	39 f3                	cmp    %esi,%ebx
80102bcd:	73 29                	jae    80102bf8 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102bcf:	83 ec 04             	sub    $0x4,%esp
80102bd2:	6a 04                	push   $0x4
80102bd4:	68 38 6a 10 80       	push   $0x80106a38
80102bd9:	53                   	push   %ebx
80102bda:	e8 55 11 00 00       	call   80103d34 <memcmp>
80102bdf:	83 c4 10             	add    $0x10,%esp
80102be2:	85 c0                	test   %eax,%eax
80102be4:	75 e2                	jne    80102bc8 <mpsearch1+0x11>
80102be6:	ba 10 00 00 00       	mov    $0x10,%edx
80102beb:	89 d8                	mov    %ebx,%eax
80102bed:	e8 a1 ff ff ff       	call   80102b93 <sum>
80102bf2:	84 c0                	test   %al,%al
80102bf4:	75 d2                	jne    80102bc8 <mpsearch1+0x11>
80102bf6:	eb 05                	jmp    80102bfd <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102bf8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102bfd:	89 d8                	mov    %ebx,%eax
80102bff:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102c02:	5b                   	pop    %ebx
80102c03:	5e                   	pop    %esi
80102c04:	5d                   	pop    %ebp
80102c05:	c3                   	ret    

80102c06 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102c06:	55                   	push   %ebp
80102c07:	89 e5                	mov    %esp,%ebp
80102c09:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c0c:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c13:	c1 e0 08             	shl    $0x8,%eax
80102c16:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c1d:	09 d0                	or     %edx,%eax
80102c1f:	c1 e0 04             	shl    $0x4,%eax
80102c22:	85 c0                	test   %eax,%eax
80102c24:	74 1f                	je     80102c45 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102c26:	ba 00 04 00 00       	mov    $0x400,%edx
80102c2b:	e8 87 ff ff ff       	call   80102bb7 <mpsearch1>
80102c30:	85 c0                	test   %eax,%eax
80102c32:	75 0f                	jne    80102c43 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102c34:	ba 00 00 01 00       	mov    $0x10000,%edx
80102c39:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102c3e:	e8 74 ff ff ff       	call   80102bb7 <mpsearch1>
}
80102c43:	c9                   	leave  
80102c44:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102c45:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102c4c:	c1 e0 08             	shl    $0x8,%eax
80102c4f:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102c56:	09 d0                	or     %edx,%eax
80102c58:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102c5b:	2d 00 04 00 00       	sub    $0x400,%eax
80102c60:	ba 00 04 00 00       	mov    $0x400,%edx
80102c65:	e8 4d ff ff ff       	call   80102bb7 <mpsearch1>
80102c6a:	85 c0                	test   %eax,%eax
80102c6c:	75 d5                	jne    80102c43 <mpsearch+0x3d>
80102c6e:	eb c4                	jmp    80102c34 <mpsearch+0x2e>

80102c70 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102c70:	55                   	push   %ebp
80102c71:	89 e5                	mov    %esp,%ebp
80102c73:	57                   	push   %edi
80102c74:	56                   	push   %esi
80102c75:	53                   	push   %ebx
80102c76:	83 ec 1c             	sub    $0x1c,%esp
80102c79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c7c:	e8 85 ff ff ff       	call   80102c06 <mpsearch>
80102c81:	85 c0                	test   %eax,%eax
80102c83:	74 5c                	je     80102ce1 <mpconfig+0x71>
80102c85:	89 c7                	mov    %eax,%edi
80102c87:	8b 58 04             	mov    0x4(%eax),%ebx
80102c8a:	85 db                	test   %ebx,%ebx
80102c8c:	74 5a                	je     80102ce8 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102c8e:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102c94:	83 ec 04             	sub    $0x4,%esp
80102c97:	6a 04                	push   $0x4
80102c99:	68 3d 6a 10 80       	push   $0x80106a3d
80102c9e:	56                   	push   %esi
80102c9f:	e8 90 10 00 00       	call   80103d34 <memcmp>
80102ca4:	83 c4 10             	add    $0x10,%esp
80102ca7:	85 c0                	test   %eax,%eax
80102ca9:	75 44                	jne    80102cef <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102cab:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102cb2:	3c 01                	cmp    $0x1,%al
80102cb4:	0f 95 c2             	setne  %dl
80102cb7:	3c 04                	cmp    $0x4,%al
80102cb9:	0f 95 c0             	setne  %al
80102cbc:	84 c2                	test   %al,%dl
80102cbe:	75 36                	jne    80102cf6 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102cc0:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102cc7:	89 f0                	mov    %esi,%eax
80102cc9:	e8 c5 fe ff ff       	call   80102b93 <sum>
80102cce:	84 c0                	test   %al,%al
80102cd0:	75 2b                	jne    80102cfd <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102cd5:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102cd7:	89 f0                	mov    %esi,%eax
80102cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cdc:	5b                   	pop    %ebx
80102cdd:	5e                   	pop    %esi
80102cde:	5f                   	pop    %edi
80102cdf:	5d                   	pop    %ebp
80102ce0:	c3                   	ret    
    return 0;
80102ce1:	be 00 00 00 00       	mov    $0x0,%esi
80102ce6:	eb ef                	jmp    80102cd7 <mpconfig+0x67>
80102ce8:	be 00 00 00 00       	mov    $0x0,%esi
80102ced:	eb e8                	jmp    80102cd7 <mpconfig+0x67>
    return 0;
80102cef:	be 00 00 00 00       	mov    $0x0,%esi
80102cf4:	eb e1                	jmp    80102cd7 <mpconfig+0x67>
    return 0;
80102cf6:	be 00 00 00 00       	mov    $0x0,%esi
80102cfb:	eb da                	jmp    80102cd7 <mpconfig+0x67>
    return 0;
80102cfd:	be 00 00 00 00       	mov    $0x0,%esi
80102d02:	eb d3                	jmp    80102cd7 <mpconfig+0x67>

80102d04 <mpinit>:

void
mpinit(void)
{
80102d04:	55                   	push   %ebp
80102d05:	89 e5                	mov    %esp,%ebp
80102d07:	57                   	push   %edi
80102d08:	56                   	push   %esi
80102d09:	53                   	push   %ebx
80102d0a:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102d0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102d10:	e8 5b ff ff ff       	call   80102c70 <mpconfig>
80102d15:	85 c0                	test   %eax,%eax
80102d17:	74 19                	je     80102d32 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d19:	8b 50 24             	mov    0x24(%eax),%edx
80102d1c:	89 15 9c 16 13 80    	mov    %edx,0x8013169c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d22:	8d 50 2c             	lea    0x2c(%eax),%edx
80102d25:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102d29:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102d2b:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d30:	eb 34                	jmp    80102d66 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102d32:	83 ec 0c             	sub    $0xc,%esp
80102d35:	68 42 6a 10 80       	push   $0x80106a42
80102d3a:	e8 09 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102d3f:	8b 35 20 1d 13 80    	mov    0x80131d20,%esi
80102d45:	83 fe 07             	cmp    $0x7,%esi
80102d48:	7f 19                	jg     80102d63 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102d4a:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d4e:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102d54:	88 87 a0 17 13 80    	mov    %al,-0x7fece860(%edi)
        ncpu++;
80102d5a:	83 c6 01             	add    $0x1,%esi
80102d5d:	89 35 20 1d 13 80    	mov    %esi,0x80131d20
      }
      p += sizeof(struct mpproc);
80102d63:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d66:	39 ca                	cmp    %ecx,%edx
80102d68:	73 2b                	jae    80102d95 <mpinit+0x91>
    switch(*p){
80102d6a:	0f b6 02             	movzbl (%edx),%eax
80102d6d:	3c 04                	cmp    $0x4,%al
80102d6f:	77 1d                	ja     80102d8e <mpinit+0x8a>
80102d71:	0f b6 c0             	movzbl %al,%eax
80102d74:	ff 24 85 7c 6a 10 80 	jmp    *-0x7fef9584(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102d7b:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d7f:	a2 80 17 13 80       	mov    %al,0x80131780
      p += sizeof(struct mpioapic);
80102d84:	83 c2 08             	add    $0x8,%edx
      continue;
80102d87:	eb dd                	jmp    80102d66 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d89:	83 c2 08             	add    $0x8,%edx
      continue;
80102d8c:	eb d8                	jmp    80102d66 <mpinit+0x62>
    default:
      ismp = 0;
80102d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d93:	eb d1                	jmp    80102d66 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102d95:	85 db                	test   %ebx,%ebx
80102d97:	74 26                	je     80102dbf <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102da0:	74 15                	je     80102db7 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102da2:	b8 70 00 00 00       	mov    $0x70,%eax
80102da7:	ba 22 00 00 00       	mov    $0x22,%edx
80102dac:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dad:	ba 23 00 00 00       	mov    $0x23,%edx
80102db2:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102db3:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102db6:	ee                   	out    %al,(%dx)
  }
}
80102db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dba:	5b                   	pop    %ebx
80102dbb:	5e                   	pop    %esi
80102dbc:	5f                   	pop    %edi
80102dbd:	5d                   	pop    %ebp
80102dbe:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102dbf:	83 ec 0c             	sub    $0xc,%esp
80102dc2:	68 5c 6a 10 80       	push   $0x80106a5c
80102dc7:	e8 7c d5 ff ff       	call   80100348 <panic>

80102dcc <picinit>:
80102dcc:	55                   	push   %ebp
80102dcd:	89 e5                	mov    %esp,%ebp
80102dcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dd4:	ba 21 00 00 00       	mov    $0x21,%edx
80102dd9:	ee                   	out    %al,(%dx)
80102dda:	ba a1 00 00 00       	mov    $0xa1,%edx
80102ddf:	ee                   	out    %al,(%dx)
80102de0:	5d                   	pop    %ebp
80102de1:	c3                   	ret    

80102de2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102de2:	55                   	push   %ebp
80102de3:	89 e5                	mov    %esp,%ebp
80102de5:	57                   	push   %edi
80102de6:	56                   	push   %esi
80102de7:	53                   	push   %ebx
80102de8:	83 ec 0c             	sub    $0xc,%esp
80102deb:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102dee:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102df1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102df7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102dfd:	e8 2b de ff ff       	call   80100c2d <filealloc>
80102e02:	89 03                	mov    %eax,(%ebx)
80102e04:	85 c0                	test   %eax,%eax
80102e06:	74 16                	je     80102e1e <pipealloc+0x3c>
80102e08:	e8 20 de ff ff       	call   80100c2d <filealloc>
80102e0d:	89 06                	mov    %eax,(%esi)
80102e0f:	85 c0                	test   %eax,%eax
80102e11:	74 0b                	je     80102e1e <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102e13:	e8 a3 f2 ff ff       	call   801020bb <kalloc>
80102e18:	89 c7                	mov    %eax,%edi
80102e1a:	85 c0                	test   %eax,%eax
80102e1c:	75 35                	jne    80102e53 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102e1e:	8b 03                	mov    (%ebx),%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	74 0c                	je     80102e30 <pipealloc+0x4e>
    fileclose(*f0);
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	50                   	push   %eax
80102e28:	e8 a6 de ff ff       	call   80100cd3 <fileclose>
80102e2d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102e30:	8b 06                	mov    (%esi),%eax
80102e32:	85 c0                	test   %eax,%eax
80102e34:	0f 84 8b 00 00 00    	je     80102ec5 <pipealloc+0xe3>
    fileclose(*f1);
80102e3a:	83 ec 0c             	sub    $0xc,%esp
80102e3d:	50                   	push   %eax
80102e3e:	e8 90 de ff ff       	call   80100cd3 <fileclose>
80102e43:	83 c4 10             	add    $0x10,%esp
  return -1;
80102e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e4e:	5b                   	pop    %ebx
80102e4f:	5e                   	pop    %esi
80102e50:	5f                   	pop    %edi
80102e51:	5d                   	pop    %ebp
80102e52:	c3                   	ret    
  p->readopen = 1;
80102e53:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102e5a:	00 00 00 
  p->writeopen = 1;
80102e5d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102e64:	00 00 00 
  p->nwrite = 0;
80102e67:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e6e:	00 00 00 
  p->nread = 0;
80102e71:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e78:	00 00 00 
  initlock(&p->lock, "pipe");
80102e7b:	83 ec 08             	sub    $0x8,%esp
80102e7e:	68 90 6a 10 80       	push   $0x80106a90
80102e83:	50                   	push   %eax
80102e84:	e8 7d 0c 00 00       	call   80103b06 <initlock>
  (*f0)->type = FD_PIPE;
80102e89:	8b 03                	mov    (%ebx),%eax
80102e8b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102e91:	8b 03                	mov    (%ebx),%eax
80102e93:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102e97:	8b 03                	mov    (%ebx),%eax
80102e99:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102e9d:	8b 03                	mov    (%ebx),%eax
80102e9f:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102ea2:	8b 06                	mov    (%esi),%eax
80102ea4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102eaa:	8b 06                	mov    (%esi),%eax
80102eac:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102eb0:	8b 06                	mov    (%esi),%eax
80102eb2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102eb6:	8b 06                	mov    (%esi),%eax
80102eb8:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102ebb:	83 c4 10             	add    $0x10,%esp
80102ebe:	b8 00 00 00 00       	mov    $0x0,%eax
80102ec3:	eb 86                	jmp    80102e4b <pipealloc+0x69>
  return -1;
80102ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eca:	e9 7c ff ff ff       	jmp    80102e4b <pipealloc+0x69>

80102ecf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102ecf:	55                   	push   %ebp
80102ed0:	89 e5                	mov    %esp,%ebp
80102ed2:	53                   	push   %ebx
80102ed3:	83 ec 10             	sub    $0x10,%esp
80102ed6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102ed9:	53                   	push   %ebx
80102eda:	e8 63 0d 00 00       	call   80103c42 <acquire>
  if(writable){
80102edf:	83 c4 10             	add    $0x10,%esp
80102ee2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102ee6:	74 3f                	je     80102f27 <pipeclose+0x58>
    p->writeopen = 0;
80102ee8:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102eef:	00 00 00 
    wakeup(&p->nread);
80102ef2:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ef8:	83 ec 0c             	sub    $0xc,%esp
80102efb:	50                   	push   %eax
80102efc:	e8 ab 09 00 00       	call   801038ac <wakeup>
80102f01:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f04:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f0b:	75 09                	jne    80102f16 <pipeclose+0x47>
80102f0d:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f14:	74 2f                	je     80102f45 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102f16:	83 ec 0c             	sub    $0xc,%esp
80102f19:	53                   	push   %ebx
80102f1a:	e8 88 0d 00 00       	call   80103ca7 <release>
80102f1f:	83 c4 10             	add    $0x10,%esp
}
80102f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f25:	c9                   	leave  
80102f26:	c3                   	ret    
    p->readopen = 0;
80102f27:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f2e:	00 00 00 
    wakeup(&p->nwrite);
80102f31:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f37:	83 ec 0c             	sub    $0xc,%esp
80102f3a:	50                   	push   %eax
80102f3b:	e8 6c 09 00 00       	call   801038ac <wakeup>
80102f40:	83 c4 10             	add    $0x10,%esp
80102f43:	eb bf                	jmp    80102f04 <pipeclose+0x35>
    release(&p->lock);
80102f45:	83 ec 0c             	sub    $0xc,%esp
80102f48:	53                   	push   %ebx
80102f49:	e8 59 0d 00 00       	call   80103ca7 <release>
    kfree((char*)p);
80102f4e:	89 1c 24             	mov    %ebx,(%esp)
80102f51:	e8 4e f0 ff ff       	call   80101fa4 <kfree>
80102f56:	83 c4 10             	add    $0x10,%esp
80102f59:	eb c7                	jmp    80102f22 <pipeclose+0x53>

80102f5b <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102f5b:	55                   	push   %ebp
80102f5c:	89 e5                	mov    %esp,%ebp
80102f5e:	57                   	push   %edi
80102f5f:	56                   	push   %esi
80102f60:	53                   	push   %ebx
80102f61:	83 ec 18             	sub    $0x18,%esp
80102f64:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f67:	89 de                	mov    %ebx,%esi
80102f69:	53                   	push   %ebx
80102f6a:	e8 d3 0c 00 00       	call   80103c42 <acquire>
  for(i = 0; i < n; i++){
80102f6f:	83 c4 10             	add    $0x10,%esp
80102f72:	bf 00 00 00 00       	mov    $0x0,%edi
80102f77:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102f7a:	0f 8d 88 00 00 00    	jge    80103008 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f80:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102f86:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f8c:	05 00 02 00 00       	add    $0x200,%eax
80102f91:	39 c2                	cmp    %eax,%edx
80102f93:	75 51                	jne    80102fe6 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102f95:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f9c:	74 2f                	je     80102fcd <pipewrite+0x72>
80102f9e:	e8 00 03 00 00       	call   801032a3 <myproc>
80102fa3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fa7:	75 24                	jne    80102fcd <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102fa9:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102faf:	83 ec 0c             	sub    $0xc,%esp
80102fb2:	50                   	push   %eax
80102fb3:	e8 f4 08 00 00       	call   801038ac <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102fb8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fbe:	83 c4 08             	add    $0x8,%esp
80102fc1:	56                   	push   %esi
80102fc2:	50                   	push   %eax
80102fc3:	e8 7f 07 00 00       	call   80103747 <sleep>
80102fc8:	83 c4 10             	add    $0x10,%esp
80102fcb:	eb b3                	jmp    80102f80 <pipewrite+0x25>
        release(&p->lock);
80102fcd:	83 ec 0c             	sub    $0xc,%esp
80102fd0:	53                   	push   %ebx
80102fd1:	e8 d1 0c 00 00       	call   80103ca7 <release>
        return -1;
80102fd6:	83 c4 10             	add    $0x10,%esp
80102fd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102fe1:	5b                   	pop    %ebx
80102fe2:	5e                   	pop    %esi
80102fe3:	5f                   	pop    %edi
80102fe4:	5d                   	pop    %ebp
80102fe5:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102fe6:	8d 42 01             	lea    0x1(%edx),%eax
80102fe9:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102fef:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ff8:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102ffc:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103000:	83 c7 01             	add    $0x1,%edi
80103003:	e9 6f ff ff ff       	jmp    80102f77 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103008:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010300e:	83 ec 0c             	sub    $0xc,%esp
80103011:	50                   	push   %eax
80103012:	e8 95 08 00 00       	call   801038ac <wakeup>
  release(&p->lock);
80103017:	89 1c 24             	mov    %ebx,(%esp)
8010301a:	e8 88 0c 00 00       	call   80103ca7 <release>
  return n;
8010301f:	83 c4 10             	add    $0x10,%esp
80103022:	8b 45 10             	mov    0x10(%ebp),%eax
80103025:	eb b7                	jmp    80102fde <pipewrite+0x83>

80103027 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103027:	55                   	push   %ebp
80103028:	89 e5                	mov    %esp,%ebp
8010302a:	57                   	push   %edi
8010302b:	56                   	push   %esi
8010302c:	53                   	push   %ebx
8010302d:	83 ec 18             	sub    $0x18,%esp
80103030:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103033:	89 df                	mov    %ebx,%edi
80103035:	53                   	push   %ebx
80103036:	e8 07 0c 00 00       	call   80103c42 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010303b:	83 c4 10             	add    $0x10,%esp
8010303e:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103044:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
8010304a:	75 3d                	jne    80103089 <piperead+0x62>
8010304c:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103052:	85 f6                	test   %esi,%esi
80103054:	74 38                	je     8010308e <piperead+0x67>
    if(myproc()->killed){
80103056:	e8 48 02 00 00       	call   801032a3 <myproc>
8010305b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010305f:	75 15                	jne    80103076 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103061:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103067:	83 ec 08             	sub    $0x8,%esp
8010306a:	57                   	push   %edi
8010306b:	50                   	push   %eax
8010306c:	e8 d6 06 00 00       	call   80103747 <sleep>
80103071:	83 c4 10             	add    $0x10,%esp
80103074:	eb c8                	jmp    8010303e <piperead+0x17>
      release(&p->lock);
80103076:	83 ec 0c             	sub    $0xc,%esp
80103079:	53                   	push   %ebx
8010307a:	e8 28 0c 00 00       	call   80103ca7 <release>
      return -1;
8010307f:	83 c4 10             	add    $0x10,%esp
80103082:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103087:	eb 50                	jmp    801030d9 <piperead+0xb2>
80103089:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010308e:	3b 75 10             	cmp    0x10(%ebp),%esi
80103091:	7d 2c                	jge    801030bf <piperead+0x98>
    if(p->nread == p->nwrite)
80103093:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103099:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
8010309f:	74 1e                	je     801030bf <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801030a1:	8d 50 01             	lea    0x1(%eax),%edx
801030a4:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801030aa:	25 ff 01 00 00       	and    $0x1ff,%eax
801030af:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801030b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801030b7:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801030ba:	83 c6 01             	add    $0x1,%esi
801030bd:	eb cf                	jmp    8010308e <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801030bf:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030c5:	83 ec 0c             	sub    $0xc,%esp
801030c8:	50                   	push   %eax
801030c9:	e8 de 07 00 00       	call   801038ac <wakeup>
  release(&p->lock);
801030ce:	89 1c 24             	mov    %ebx,(%esp)
801030d1:	e8 d1 0b 00 00       	call   80103ca7 <release>
  return i;
801030d6:	83 c4 10             	add    $0x10,%esp
}
801030d9:	89 f0                	mov    %esi,%eax
801030db:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030de:	5b                   	pop    %ebx
801030df:	5e                   	pop    %esi
801030e0:	5f                   	pop    %edi
801030e1:	5d                   	pop    %ebp
801030e2:	c3                   	ret    

801030e3 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801030e3:	55                   	push   %ebp
801030e4:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030e6:	ba 74 1d 13 80       	mov    $0x80131d74,%edx
801030eb:	eb 03                	jmp    801030f0 <wakeup1+0xd>
801030ed:	83 c2 7c             	add    $0x7c,%edx
801030f0:	81 fa 74 3c 13 80    	cmp    $0x80133c74,%edx
801030f6:	73 14                	jae    8010310c <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801030f8:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801030fc:	75 ef                	jne    801030ed <wakeup1+0xa>
801030fe:	39 42 20             	cmp    %eax,0x20(%edx)
80103101:	75 ea                	jne    801030ed <wakeup1+0xa>
      p->state = RUNNABLE;
80103103:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010310a:	eb e1                	jmp    801030ed <wakeup1+0xa>
}
8010310c:	5d                   	pop    %ebp
8010310d:	c3                   	ret    

8010310e <allocproc>:
{
8010310e:	55                   	push   %ebp
8010310f:	89 e5                	mov    %esp,%ebp
80103111:	53                   	push   %ebx
80103112:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103115:	68 40 1d 13 80       	push   $0x80131d40
8010311a:	e8 23 0b 00 00       	call   80103c42 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010311f:	83 c4 10             	add    $0x10,%esp
80103122:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
80103127:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
8010312d:	73 0b                	jae    8010313a <allocproc+0x2c>
    if(p->state == UNUSED)
8010312f:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103133:	74 1c                	je     80103151 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103135:	83 c3 7c             	add    $0x7c,%ebx
80103138:	eb ed                	jmp    80103127 <allocproc+0x19>
  release(&ptable.lock);
8010313a:	83 ec 0c             	sub    $0xc,%esp
8010313d:	68 40 1d 13 80       	push   $0x80131d40
80103142:	e8 60 0b 00 00       	call   80103ca7 <release>
  return 0;
80103147:	83 c4 10             	add    $0x10,%esp
8010314a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010314f:	eb 69                	jmp    801031ba <allocproc+0xac>
  p->state = EMBRYO;
80103151:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103158:	a1 04 90 12 80       	mov    0x80129004,%eax
8010315d:	8d 50 01             	lea    0x1(%eax),%edx
80103160:	89 15 04 90 12 80    	mov    %edx,0x80129004
80103166:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 40 1d 13 80       	push   $0x80131d40
80103171:	e8 31 0b 00 00       	call   80103ca7 <release>
  if((p->kstack = kalloc()) == 0){
80103176:	e8 40 ef ff ff       	call   801020bb <kalloc>
8010317b:	89 43 08             	mov    %eax,0x8(%ebx)
8010317e:	83 c4 10             	add    $0x10,%esp
80103181:	85 c0                	test   %eax,%eax
80103183:	74 3c                	je     801031c1 <allocproc+0xb3>
  sp -= sizeof *p->tf;
80103185:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010318b:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010318e:	c7 80 b0 0f 00 00 04 	movl   $0x80104e04,0xfb0(%eax)
80103195:	4e 10 80 
  sp -= sizeof *p->context;
80103198:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010319d:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801031a0:	83 ec 04             	sub    $0x4,%esp
801031a3:	6a 14                	push   $0x14
801031a5:	6a 00                	push   $0x0
801031a7:	50                   	push   %eax
801031a8:	e8 41 0b 00 00       	call   80103cee <memset>
  p->context->eip = (uint)forkret;
801031ad:	8b 43 1c             	mov    0x1c(%ebx),%eax
801031b0:	c7 40 10 cf 31 10 80 	movl   $0x801031cf,0x10(%eax)
  return p;
801031b7:	83 c4 10             	add    $0x10,%esp
}
801031ba:	89 d8                	mov    %ebx,%eax
801031bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801031bf:	c9                   	leave  
801031c0:	c3                   	ret    
    p->state = UNUSED;
801031c1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031c8:	bb 00 00 00 00       	mov    $0x0,%ebx
801031cd:	eb eb                	jmp    801031ba <allocproc+0xac>

801031cf <forkret>:
{
801031cf:	55                   	push   %ebp
801031d0:	89 e5                	mov    %esp,%ebp
801031d2:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801031d5:	68 40 1d 13 80       	push   $0x80131d40
801031da:	e8 c8 0a 00 00       	call   80103ca7 <release>
  if (first) {
801031df:	83 c4 10             	add    $0x10,%esp
801031e2:	83 3d 00 90 12 80 00 	cmpl   $0x0,0x80129000
801031e9:	75 02                	jne    801031ed <forkret+0x1e>
}
801031eb:	c9                   	leave  
801031ec:	c3                   	ret    
    first = 0;
801031ed:	c7 05 00 90 12 80 00 	movl   $0x0,0x80129000
801031f4:	00 00 00 
    iinit(ROOTDEV);
801031f7:	83 ec 0c             	sub    $0xc,%esp
801031fa:	6a 01                	push   $0x1
801031fc:	e8 eb e0 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
80103201:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103208:	e8 05 f6 ff ff       	call   80102812 <initlog>
8010320d:	83 c4 10             	add    $0x10,%esp
}
80103210:	eb d9                	jmp    801031eb <forkret+0x1c>

80103212 <pinit>:
{
80103212:	55                   	push   %ebp
80103213:	89 e5                	mov    %esp,%ebp
80103215:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103218:	68 95 6a 10 80       	push   $0x80106a95
8010321d:	68 40 1d 13 80       	push   $0x80131d40
80103222:	e8 df 08 00 00       	call   80103b06 <initlock>
}
80103227:	83 c4 10             	add    $0x10,%esp
8010322a:	c9                   	leave  
8010322b:	c3                   	ret    

8010322c <mycpu>:
{
8010322c:	55                   	push   %ebp
8010322d:	89 e5                	mov    %esp,%ebp
8010322f:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103232:	9c                   	pushf  
80103233:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103234:	f6 c4 02             	test   $0x2,%ah
80103237:	75 28                	jne    80103261 <mycpu+0x35>
  apicid = lapicid();
80103239:	e8 ed f1 ff ff       	call   8010242b <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010323e:	ba 00 00 00 00       	mov    $0x0,%edx
80103243:	39 15 20 1d 13 80    	cmp    %edx,0x80131d20
80103249:	7e 23                	jle    8010326e <mycpu+0x42>
    if (cpus[i].apicid == apicid)
8010324b:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103251:	0f b6 89 a0 17 13 80 	movzbl -0x7fece860(%ecx),%ecx
80103258:	39 c1                	cmp    %eax,%ecx
8010325a:	74 1f                	je     8010327b <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010325c:	83 c2 01             	add    $0x1,%edx
8010325f:	eb e2                	jmp    80103243 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 78 6b 10 80       	push   $0x80106b78
80103269:	e8 da d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010326e:	83 ec 0c             	sub    $0xc,%esp
80103271:	68 9c 6a 10 80       	push   $0x80106a9c
80103276:	e8 cd d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
8010327b:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103281:	05 a0 17 13 80       	add    $0x801317a0,%eax
}
80103286:	c9                   	leave  
80103287:	c3                   	ret    

80103288 <cpuid>:
cpuid() {
80103288:	55                   	push   %ebp
80103289:	89 e5                	mov    %esp,%ebp
8010328b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010328e:	e8 99 ff ff ff       	call   8010322c <mycpu>
80103293:	2d a0 17 13 80       	sub    $0x801317a0,%eax
80103298:	c1 f8 04             	sar    $0x4,%eax
8010329b:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032a1:	c9                   	leave  
801032a2:	c3                   	ret    

801032a3 <myproc>:
myproc(void) {
801032a3:	55                   	push   %ebp
801032a4:	89 e5                	mov    %esp,%ebp
801032a6:	53                   	push   %ebx
801032a7:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032aa:	e8 b6 08 00 00       	call   80103b65 <pushcli>
  c = mycpu();
801032af:	e8 78 ff ff ff       	call   8010322c <mycpu>
  p = c->proc;
801032b4:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032ba:	e8 e3 08 00 00       	call   80103ba2 <popcli>
}
801032bf:	89 d8                	mov    %ebx,%eax
801032c1:	83 c4 04             	add    $0x4,%esp
801032c4:	5b                   	pop    %ebx
801032c5:	5d                   	pop    %ebp
801032c6:	c3                   	ret    

801032c7 <userinit>:
{
801032c7:	55                   	push   %ebp
801032c8:	89 e5                	mov    %esp,%ebp
801032ca:	53                   	push   %ebx
801032cb:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801032ce:	e8 3b fe ff ff       	call   8010310e <allocproc>
801032d3:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032d5:	a3 bc 95 12 80       	mov    %eax,0x801295bc
  if((p->pgdir = setupkvm()) == 0)
801032da:	e8 09 30 00 00       	call   801062e8 <setupkvm>
801032df:	89 43 04             	mov    %eax,0x4(%ebx)
801032e2:	85 c0                	test   %eax,%eax
801032e4:	0f 84 b7 00 00 00    	je     801033a1 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032ea:	83 ec 04             	sub    $0x4,%esp
801032ed:	68 2c 00 00 00       	push   $0x2c
801032f2:	68 60 94 12 80       	push   $0x80129460
801032f7:	50                   	push   %eax
801032f8:	e8 f6 2c 00 00       	call   80105ff3 <inituvm>
  p->sz = PGSIZE;
801032fd:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103303:	83 c4 0c             	add    $0xc,%esp
80103306:	6a 4c                	push   $0x4c
80103308:	6a 00                	push   $0x0
8010330a:	ff 73 18             	pushl  0x18(%ebx)
8010330d:	e8 dc 09 00 00       	call   80103cee <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103312:	8b 43 18             	mov    0x18(%ebx),%eax
80103315:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010331b:	8b 43 18             	mov    0x18(%ebx),%eax
8010331e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103324:	8b 43 18             	mov    0x18(%ebx),%eax
80103327:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010332b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010332f:	8b 43 18             	mov    0x18(%ebx),%eax
80103332:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103336:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010333a:	8b 43 18             	mov    0x18(%ebx),%eax
8010333d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103344:	8b 43 18             	mov    0x18(%ebx),%eax
80103347:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010334e:	8b 43 18             	mov    0x18(%ebx),%eax
80103351:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103358:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010335b:	83 c4 0c             	add    $0xc,%esp
8010335e:	6a 10                	push   $0x10
80103360:	68 c5 6a 10 80       	push   $0x80106ac5
80103365:	50                   	push   %eax
80103366:	e8 ea 0a 00 00       	call   80103e55 <safestrcpy>
  p->cwd = namei("/");
8010336b:	c7 04 24 ce 6a 10 80 	movl   $0x80106ace,(%esp)
80103372:	e8 6a e8 ff ff       	call   80101be1 <namei>
80103377:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010337a:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103381:	e8 bc 08 00 00       	call   80103c42 <acquire>
  p->state = RUNNABLE;
80103386:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010338d:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103394:	e8 0e 09 00 00       	call   80103ca7 <release>
}
80103399:	83 c4 10             	add    $0x10,%esp
8010339c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010339f:	c9                   	leave  
801033a0:	c3                   	ret    
    panic("userinit: out of memory?");
801033a1:	83 ec 0c             	sub    $0xc,%esp
801033a4:	68 ac 6a 10 80       	push   $0x80106aac
801033a9:	e8 9a cf ff ff       	call   80100348 <panic>

801033ae <growproc>:
{
801033ae:	55                   	push   %ebp
801033af:	89 e5                	mov    %esp,%ebp
801033b1:	56                   	push   %esi
801033b2:	53                   	push   %ebx
801033b3:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033b6:	e8 e8 fe ff ff       	call   801032a3 <myproc>
801033bb:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033bd:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033bf:	85 f6                	test   %esi,%esi
801033c1:	7f 21                	jg     801033e4 <growproc+0x36>
  } else if(n < 0){
801033c3:	85 f6                	test   %esi,%esi
801033c5:	79 33                	jns    801033fa <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033c7:	83 ec 04             	sub    $0x4,%esp
801033ca:	01 c6                	add    %eax,%esi
801033cc:	56                   	push   %esi
801033cd:	50                   	push   %eax
801033ce:	ff 73 04             	pushl  0x4(%ebx)
801033d1:	e8 26 2d 00 00       	call   801060fc <deallocuvm>
801033d6:	83 c4 10             	add    $0x10,%esp
801033d9:	85 c0                	test   %eax,%eax
801033db:	75 1d                	jne    801033fa <growproc+0x4c>
      return -1;
801033dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033e2:	eb 29                	jmp    8010340d <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033e4:	83 ec 04             	sub    $0x4,%esp
801033e7:	01 c6                	add    %eax,%esi
801033e9:	56                   	push   %esi
801033ea:	50                   	push   %eax
801033eb:	ff 73 04             	pushl  0x4(%ebx)
801033ee:	e8 9b 2d 00 00       	call   8010618e <allocuvm>
801033f3:	83 c4 10             	add    $0x10,%esp
801033f6:	85 c0                	test   %eax,%eax
801033f8:	74 1a                	je     80103414 <growproc+0x66>
  curproc->sz = sz;
801033fa:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801033fc:	83 ec 0c             	sub    $0xc,%esp
801033ff:	53                   	push   %ebx
80103400:	e8 d6 2a 00 00       	call   80105edb <switchuvm>
  return 0;
80103405:	83 c4 10             	add    $0x10,%esp
80103408:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010340d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103410:	5b                   	pop    %ebx
80103411:	5e                   	pop    %esi
80103412:	5d                   	pop    %ebp
80103413:	c3                   	ret    
      return -1;
80103414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103419:	eb f2                	jmp    8010340d <growproc+0x5f>

8010341b <fork>:
{
8010341b:	55                   	push   %ebp
8010341c:	89 e5                	mov    %esp,%ebp
8010341e:	57                   	push   %edi
8010341f:	56                   	push   %esi
80103420:	53                   	push   %ebx
80103421:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103424:	e8 7a fe ff ff       	call   801032a3 <myproc>
80103429:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
8010342b:	e8 de fc ff ff       	call   8010310e <allocproc>
80103430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103433:	85 c0                	test   %eax,%eax
80103435:	0f 84 e0 00 00 00    	je     8010351b <fork+0x100>
8010343b:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010343d:	83 ec 08             	sub    $0x8,%esp
80103440:	ff 33                	pushl  (%ebx)
80103442:	ff 73 04             	pushl  0x4(%ebx)
80103445:	e8 4f 2f 00 00       	call   80106399 <copyuvm>
8010344a:	89 47 04             	mov    %eax,0x4(%edi)
8010344d:	83 c4 10             	add    $0x10,%esp
80103450:	85 c0                	test   %eax,%eax
80103452:	74 2a                	je     8010347e <fork+0x63>
  np->sz = curproc->sz;
80103454:	8b 03                	mov    (%ebx),%eax
80103456:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103459:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010345b:	89 c8                	mov    %ecx,%eax
8010345d:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103460:	8b 73 18             	mov    0x18(%ebx),%esi
80103463:	8b 79 18             	mov    0x18(%ecx),%edi
80103466:	b9 13 00 00 00       	mov    $0x13,%ecx
8010346b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010346d:	8b 40 18             	mov    0x18(%eax),%eax
80103470:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103477:	be 00 00 00 00       	mov    $0x0,%esi
8010347c:	eb 29                	jmp    801034a7 <fork+0x8c>
    kfree(np->kstack);
8010347e:	83 ec 0c             	sub    $0xc,%esp
80103481:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103484:	ff 73 08             	pushl  0x8(%ebx)
80103487:	e8 18 eb ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
8010348c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103493:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010349a:	83 c4 10             	add    $0x10,%esp
8010349d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034a2:	eb 6d                	jmp    80103511 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
801034a4:	83 c6 01             	add    $0x1,%esi
801034a7:	83 fe 0f             	cmp    $0xf,%esi
801034aa:	7f 1d                	jg     801034c9 <fork+0xae>
    if(curproc->ofile[i])
801034ac:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034b0:	85 c0                	test   %eax,%eax
801034b2:	74 f0                	je     801034a4 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034b4:	83 ec 0c             	sub    $0xc,%esp
801034b7:	50                   	push   %eax
801034b8:	e8 d1 d7 ff ff       	call   80100c8e <filedup>
801034bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034c0:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801034c4:	83 c4 10             	add    $0x10,%esp
801034c7:	eb db                	jmp    801034a4 <fork+0x89>
  np->cwd = idup(curproc->cwd);
801034c9:	83 ec 0c             	sub    $0xc,%esp
801034cc:	ff 73 68             	pushl  0x68(%ebx)
801034cf:	e8 7d e0 ff ff       	call   80101551 <idup>
801034d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801034d7:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034da:	83 c3 6c             	add    $0x6c,%ebx
801034dd:	8d 47 6c             	lea    0x6c(%edi),%eax
801034e0:	83 c4 0c             	add    $0xc,%esp
801034e3:	6a 10                	push   $0x10
801034e5:	53                   	push   %ebx
801034e6:	50                   	push   %eax
801034e7:	e8 69 09 00 00       	call   80103e55 <safestrcpy>
  pid = np->pid;
801034ec:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801034ef:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801034f6:	e8 47 07 00 00       	call   80103c42 <acquire>
  np->state = RUNNABLE;
801034fb:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103502:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103509:	e8 99 07 00 00       	call   80103ca7 <release>
  return pid;
8010350e:	83 c4 10             	add    $0x10,%esp
}
80103511:	89 d8                	mov    %ebx,%eax
80103513:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103516:	5b                   	pop    %ebx
80103517:	5e                   	pop    %esi
80103518:	5f                   	pop    %edi
80103519:	5d                   	pop    %ebp
8010351a:	c3                   	ret    
    return -1;
8010351b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103520:	eb ef                	jmp    80103511 <fork+0xf6>

80103522 <scheduler>:
{
80103522:	55                   	push   %ebp
80103523:	89 e5                	mov    %esp,%ebp
80103525:	56                   	push   %esi
80103526:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103527:	e8 00 fd ff ff       	call   8010322c <mycpu>
8010352c:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010352e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103535:	00 00 00 
80103538:	eb 5a                	jmp    80103594 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010353a:	83 c3 7c             	add    $0x7c,%ebx
8010353d:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103543:	73 3f                	jae    80103584 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103545:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103549:	75 ef                	jne    8010353a <scheduler+0x18>
      c->proc = p;
8010354b:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103551:	83 ec 0c             	sub    $0xc,%esp
80103554:	53                   	push   %ebx
80103555:	e8 81 29 00 00       	call   80105edb <switchuvm>
      p->state = RUNNING;
8010355a:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103561:	83 c4 08             	add    $0x8,%esp
80103564:	ff 73 1c             	pushl  0x1c(%ebx)
80103567:	8d 46 04             	lea    0x4(%esi),%eax
8010356a:	50                   	push   %eax
8010356b:	e8 38 09 00 00       	call   80103ea8 <swtch>
      switchkvm();
80103570:	e8 54 29 00 00       	call   80105ec9 <switchkvm>
      c->proc = 0;
80103575:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010357c:	00 00 00 
8010357f:	83 c4 10             	add    $0x10,%esp
80103582:	eb b6                	jmp    8010353a <scheduler+0x18>
    release(&ptable.lock);
80103584:	83 ec 0c             	sub    $0xc,%esp
80103587:	68 40 1d 13 80       	push   $0x80131d40
8010358c:	e8 16 07 00 00       	call   80103ca7 <release>
    sti();
80103591:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103594:	fb                   	sti    
    acquire(&ptable.lock);
80103595:	83 ec 0c             	sub    $0xc,%esp
80103598:	68 40 1d 13 80       	push   $0x80131d40
8010359d:	e8 a0 06 00 00       	call   80103c42 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035a2:	83 c4 10             	add    $0x10,%esp
801035a5:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
801035aa:	eb 91                	jmp    8010353d <scheduler+0x1b>

801035ac <sched>:
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	56                   	push   %esi
801035b0:	53                   	push   %ebx
  struct proc *p = myproc();
801035b1:	e8 ed fc ff ff       	call   801032a3 <myproc>
801035b6:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801035b8:	83 ec 0c             	sub    $0xc,%esp
801035bb:	68 40 1d 13 80       	push   $0x80131d40
801035c0:	e8 3d 06 00 00       	call   80103c02 <holding>
801035c5:	83 c4 10             	add    $0x10,%esp
801035c8:	85 c0                	test   %eax,%eax
801035ca:	74 4f                	je     8010361b <sched+0x6f>
  if(mycpu()->ncli != 1)
801035cc:	e8 5b fc ff ff       	call   8010322c <mycpu>
801035d1:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801035d8:	75 4e                	jne    80103628 <sched+0x7c>
  if(p->state == RUNNING)
801035da:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801035de:	74 55                	je     80103635 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801035e0:	9c                   	pushf  
801035e1:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801035e2:	f6 c4 02             	test   $0x2,%ah
801035e5:	75 5b                	jne    80103642 <sched+0x96>
  intena = mycpu()->intena;
801035e7:	e8 40 fc ff ff       	call   8010322c <mycpu>
801035ec:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801035f2:	e8 35 fc ff ff       	call   8010322c <mycpu>
801035f7:	83 ec 08             	sub    $0x8,%esp
801035fa:	ff 70 04             	pushl  0x4(%eax)
801035fd:	83 c3 1c             	add    $0x1c,%ebx
80103600:	53                   	push   %ebx
80103601:	e8 a2 08 00 00       	call   80103ea8 <swtch>
  mycpu()->intena = intena;
80103606:	e8 21 fc ff ff       	call   8010322c <mycpu>
8010360b:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103611:	83 c4 10             	add    $0x10,%esp
80103614:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103617:	5b                   	pop    %ebx
80103618:	5e                   	pop    %esi
80103619:	5d                   	pop    %ebp
8010361a:	c3                   	ret    
    panic("sched ptable.lock");
8010361b:	83 ec 0c             	sub    $0xc,%esp
8010361e:	68 d0 6a 10 80       	push   $0x80106ad0
80103623:	e8 20 cd ff ff       	call   80100348 <panic>
    panic("sched locks");
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	68 e2 6a 10 80       	push   $0x80106ae2
80103630:	e8 13 cd ff ff       	call   80100348 <panic>
    panic("sched running");
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 ee 6a 10 80       	push   $0x80106aee
8010363d:	e8 06 cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103642:	83 ec 0c             	sub    $0xc,%esp
80103645:	68 fc 6a 10 80       	push   $0x80106afc
8010364a:	e8 f9 cc ff ff       	call   80100348 <panic>

8010364f <exit>:
{
8010364f:	55                   	push   %ebp
80103650:	89 e5                	mov    %esp,%ebp
80103652:	56                   	push   %esi
80103653:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103654:	e8 4a fc ff ff       	call   801032a3 <myproc>
  if(curproc == initproc)
80103659:	39 05 bc 95 12 80    	cmp    %eax,0x801295bc
8010365f:	74 09                	je     8010366a <exit+0x1b>
80103661:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103663:	bb 00 00 00 00       	mov    $0x0,%ebx
80103668:	eb 10                	jmp    8010367a <exit+0x2b>
    panic("init exiting");
8010366a:	83 ec 0c             	sub    $0xc,%esp
8010366d:	68 10 6b 10 80       	push   $0x80106b10
80103672:	e8 d1 cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103677:	83 c3 01             	add    $0x1,%ebx
8010367a:	83 fb 0f             	cmp    $0xf,%ebx
8010367d:	7f 1e                	jg     8010369d <exit+0x4e>
    if(curproc->ofile[fd]){
8010367f:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103683:	85 c0                	test   %eax,%eax
80103685:	74 f0                	je     80103677 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103687:	83 ec 0c             	sub    $0xc,%esp
8010368a:	50                   	push   %eax
8010368b:	e8 43 d6 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103690:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103697:	00 
80103698:	83 c4 10             	add    $0x10,%esp
8010369b:	eb da                	jmp    80103677 <exit+0x28>
  begin_op();
8010369d:	e8 b9 f1 ff ff       	call   8010285b <begin_op>
  iput(curproc->cwd);
801036a2:	83 ec 0c             	sub    $0xc,%esp
801036a5:	ff 76 68             	pushl  0x68(%esi)
801036a8:	e8 db df ff ff       	call   80101688 <iput>
  end_op();
801036ad:	e8 23 f2 ff ff       	call   801028d5 <end_op>
  curproc->cwd = 0;
801036b2:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801036b9:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801036c0:	e8 7d 05 00 00       	call   80103c42 <acquire>
  wakeup1(curproc->parent);
801036c5:	8b 46 14             	mov    0x14(%esi),%eax
801036c8:	e8 16 fa ff ff       	call   801030e3 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036cd:	83 c4 10             	add    $0x10,%esp
801036d0:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
801036d5:	eb 03                	jmp    801036da <exit+0x8b>
801036d7:	83 c3 7c             	add    $0x7c,%ebx
801036da:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
801036e0:	73 1a                	jae    801036fc <exit+0xad>
    if(p->parent == curproc){
801036e2:	39 73 14             	cmp    %esi,0x14(%ebx)
801036e5:	75 f0                	jne    801036d7 <exit+0x88>
      p->parent = initproc;
801036e7:	a1 bc 95 12 80       	mov    0x801295bc,%eax
801036ec:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801036ef:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801036f3:	75 e2                	jne    801036d7 <exit+0x88>
        wakeup1(initproc);
801036f5:	e8 e9 f9 ff ff       	call   801030e3 <wakeup1>
801036fa:	eb db                	jmp    801036d7 <exit+0x88>
  curproc->state = ZOMBIE;
801036fc:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103703:	e8 a4 fe ff ff       	call   801035ac <sched>
  panic("zombie exit");
80103708:	83 ec 0c             	sub    $0xc,%esp
8010370b:	68 1d 6b 10 80       	push   $0x80106b1d
80103710:	e8 33 cc ff ff       	call   80100348 <panic>

80103715 <yield>:
{
80103715:	55                   	push   %ebp
80103716:	89 e5                	mov    %esp,%ebp
80103718:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010371b:	68 40 1d 13 80       	push   $0x80131d40
80103720:	e8 1d 05 00 00       	call   80103c42 <acquire>
  myproc()->state = RUNNABLE;
80103725:	e8 79 fb ff ff       	call   801032a3 <myproc>
8010372a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103731:	e8 76 fe ff ff       	call   801035ac <sched>
  release(&ptable.lock);
80103736:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
8010373d:	e8 65 05 00 00       	call   80103ca7 <release>
}
80103742:	83 c4 10             	add    $0x10,%esp
80103745:	c9                   	leave  
80103746:	c3                   	ret    

80103747 <sleep>:
{
80103747:	55                   	push   %ebp
80103748:	89 e5                	mov    %esp,%ebp
8010374a:	56                   	push   %esi
8010374b:	53                   	push   %ebx
8010374c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
8010374f:	e8 4f fb ff ff       	call   801032a3 <myproc>
  if(p == 0)
80103754:	85 c0                	test   %eax,%eax
80103756:	74 66                	je     801037be <sleep+0x77>
80103758:	89 c6                	mov    %eax,%esi
  if(lk == 0)
8010375a:	85 db                	test   %ebx,%ebx
8010375c:	74 6d                	je     801037cb <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010375e:	81 fb 40 1d 13 80    	cmp    $0x80131d40,%ebx
80103764:	74 18                	je     8010377e <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103766:	83 ec 0c             	sub    $0xc,%esp
80103769:	68 40 1d 13 80       	push   $0x80131d40
8010376e:	e8 cf 04 00 00       	call   80103c42 <acquire>
    release(lk);
80103773:	89 1c 24             	mov    %ebx,(%esp)
80103776:	e8 2c 05 00 00       	call   80103ca7 <release>
8010377b:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010377e:	8b 45 08             	mov    0x8(%ebp),%eax
80103781:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103784:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010378b:	e8 1c fe ff ff       	call   801035ac <sched>
  p->chan = 0;
80103790:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103797:	81 fb 40 1d 13 80    	cmp    $0x80131d40,%ebx
8010379d:	74 18                	je     801037b7 <sleep+0x70>
    release(&ptable.lock);
8010379f:	83 ec 0c             	sub    $0xc,%esp
801037a2:	68 40 1d 13 80       	push   $0x80131d40
801037a7:	e8 fb 04 00 00       	call   80103ca7 <release>
    acquire(lk);
801037ac:	89 1c 24             	mov    %ebx,(%esp)
801037af:	e8 8e 04 00 00       	call   80103c42 <acquire>
801037b4:	83 c4 10             	add    $0x10,%esp
}
801037b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037ba:	5b                   	pop    %ebx
801037bb:	5e                   	pop    %esi
801037bc:	5d                   	pop    %ebp
801037bd:	c3                   	ret    
    panic("sleep");
801037be:	83 ec 0c             	sub    $0xc,%esp
801037c1:	68 29 6b 10 80       	push   $0x80106b29
801037c6:	e8 7d cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801037cb:	83 ec 0c             	sub    $0xc,%esp
801037ce:	68 2f 6b 10 80       	push   $0x80106b2f
801037d3:	e8 70 cb ff ff       	call   80100348 <panic>

801037d8 <wait>:
{
801037d8:	55                   	push   %ebp
801037d9:	89 e5                	mov    %esp,%ebp
801037db:	56                   	push   %esi
801037dc:	53                   	push   %ebx
  struct proc *curproc = myproc();
801037dd:	e8 c1 fa ff ff       	call   801032a3 <myproc>
801037e2:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801037e4:	83 ec 0c             	sub    $0xc,%esp
801037e7:	68 40 1d 13 80       	push   $0x80131d40
801037ec:	e8 51 04 00 00       	call   80103c42 <acquire>
801037f1:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801037f4:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037f9:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
801037fe:	eb 5b                	jmp    8010385b <wait+0x83>
        pid = p->pid;
80103800:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103803:	83 ec 0c             	sub    $0xc,%esp
80103806:	ff 73 08             	pushl  0x8(%ebx)
80103809:	e8 96 e7 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
8010380e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103815:	83 c4 04             	add    $0x4,%esp
80103818:	ff 73 04             	pushl  0x4(%ebx)
8010381b:	e8 58 2a 00 00       	call   80106278 <freevm>
        p->pid = 0;
80103820:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103827:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010382e:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103832:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103839:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103840:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103847:	e8 5b 04 00 00       	call   80103ca7 <release>
        return pid;
8010384c:	83 c4 10             	add    $0x10,%esp
}
8010384f:	89 f0                	mov    %esi,%eax
80103851:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103854:	5b                   	pop    %ebx
80103855:	5e                   	pop    %esi
80103856:	5d                   	pop    %ebp
80103857:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103858:	83 c3 7c             	add    $0x7c,%ebx
8010385b:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103861:	73 12                	jae    80103875 <wait+0x9d>
      if(p->parent != curproc)
80103863:	39 73 14             	cmp    %esi,0x14(%ebx)
80103866:	75 f0                	jne    80103858 <wait+0x80>
      if(p->state == ZOMBIE){
80103868:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010386c:	74 92                	je     80103800 <wait+0x28>
      havekids = 1;
8010386e:	b8 01 00 00 00       	mov    $0x1,%eax
80103873:	eb e3                	jmp    80103858 <wait+0x80>
    if(!havekids || curproc->killed){
80103875:	85 c0                	test   %eax,%eax
80103877:	74 06                	je     8010387f <wait+0xa7>
80103879:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010387d:	74 17                	je     80103896 <wait+0xbe>
      release(&ptable.lock);
8010387f:	83 ec 0c             	sub    $0xc,%esp
80103882:	68 40 1d 13 80       	push   $0x80131d40
80103887:	e8 1b 04 00 00       	call   80103ca7 <release>
      return -1;
8010388c:	83 c4 10             	add    $0x10,%esp
8010388f:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103894:	eb b9                	jmp    8010384f <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103896:	83 ec 08             	sub    $0x8,%esp
80103899:	68 40 1d 13 80       	push   $0x80131d40
8010389e:	56                   	push   %esi
8010389f:	e8 a3 fe ff ff       	call   80103747 <sleep>
    havekids = 0;
801038a4:	83 c4 10             	add    $0x10,%esp
801038a7:	e9 48 ff ff ff       	jmp    801037f4 <wait+0x1c>

801038ac <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801038ac:	55                   	push   %ebp
801038ad:	89 e5                	mov    %esp,%ebp
801038af:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801038b2:	68 40 1d 13 80       	push   $0x80131d40
801038b7:	e8 86 03 00 00       	call   80103c42 <acquire>
  wakeup1(chan);
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	e8 1f f8 ff ff       	call   801030e3 <wakeup1>
  release(&ptable.lock);
801038c4:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801038cb:	e8 d7 03 00 00       	call   80103ca7 <release>
}
801038d0:	83 c4 10             	add    $0x10,%esp
801038d3:	c9                   	leave  
801038d4:	c3                   	ret    

801038d5 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801038d5:	55                   	push   %ebp
801038d6:	89 e5                	mov    %esp,%ebp
801038d8:	53                   	push   %ebx
801038d9:	83 ec 10             	sub    $0x10,%esp
801038dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801038df:	68 40 1d 13 80       	push   $0x80131d40
801038e4:	e8 59 03 00 00       	call   80103c42 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038e9:	83 c4 10             	add    $0x10,%esp
801038ec:	b8 74 1d 13 80       	mov    $0x80131d74,%eax
801038f1:	3d 74 3c 13 80       	cmp    $0x80133c74,%eax
801038f6:	73 3a                	jae    80103932 <kill+0x5d>
    if(p->pid == pid){
801038f8:	39 58 10             	cmp    %ebx,0x10(%eax)
801038fb:	74 05                	je     80103902 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038fd:	83 c0 7c             	add    $0x7c,%eax
80103900:	eb ef                	jmp    801038f1 <kill+0x1c>
      p->killed = 1;
80103902:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103909:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010390d:	74 1a                	je     80103929 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	68 40 1d 13 80       	push   $0x80131d40
80103917:	e8 8b 03 00 00       	call   80103ca7 <release>
      return 0;
8010391c:	83 c4 10             	add    $0x10,%esp
8010391f:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103927:	c9                   	leave  
80103928:	c3                   	ret    
        p->state = RUNNABLE;
80103929:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103930:	eb dd                	jmp    8010390f <kill+0x3a>
  release(&ptable.lock);
80103932:	83 ec 0c             	sub    $0xc,%esp
80103935:	68 40 1d 13 80       	push   $0x80131d40
8010393a:	e8 68 03 00 00       	call   80103ca7 <release>
  return -1;
8010393f:	83 c4 10             	add    $0x10,%esp
80103942:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103947:	eb db                	jmp    80103924 <kill+0x4f>

80103949 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103949:	55                   	push   %ebp
8010394a:	89 e5                	mov    %esp,%ebp
8010394c:	56                   	push   %esi
8010394d:	53                   	push   %ebx
8010394e:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103951:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
80103956:	eb 33                	jmp    8010398b <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103958:	b8 40 6b 10 80       	mov    $0x80106b40,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010395d:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103960:	52                   	push   %edx
80103961:	50                   	push   %eax
80103962:	ff 73 10             	pushl  0x10(%ebx)
80103965:	68 44 6b 10 80       	push   $0x80106b44
8010396a:	e8 9c cc ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
8010396f:	83 c4 10             	add    $0x10,%esp
80103972:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103976:	74 39                	je     801039b1 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103978:	83 ec 0c             	sub    $0xc,%esp
8010397b:	68 bb 6e 10 80       	push   $0x80106ebb
80103980:	e8 86 cc ff ff       	call   8010060b <cprintf>
80103985:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103988:	83 c3 7c             	add    $0x7c,%ebx
8010398b:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103991:	73 61                	jae    801039f4 <procdump+0xab>
    if(p->state == UNUSED)
80103993:	8b 43 0c             	mov    0xc(%ebx),%eax
80103996:	85 c0                	test   %eax,%eax
80103998:	74 ee                	je     80103988 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010399a:	83 f8 05             	cmp    $0x5,%eax
8010399d:	77 b9                	ja     80103958 <procdump+0xf>
8010399f:	8b 04 85 a0 6b 10 80 	mov    -0x7fef9460(,%eax,4),%eax
801039a6:	85 c0                	test   %eax,%eax
801039a8:	75 b3                	jne    8010395d <procdump+0x14>
      state = "???";
801039aa:	b8 40 6b 10 80       	mov    $0x80106b40,%eax
801039af:	eb ac                	jmp    8010395d <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801039b1:	8b 43 1c             	mov    0x1c(%ebx),%eax
801039b4:	8b 40 0c             	mov    0xc(%eax),%eax
801039b7:	83 c0 08             	add    $0x8,%eax
801039ba:	83 ec 08             	sub    $0x8,%esp
801039bd:	8d 55 d0             	lea    -0x30(%ebp),%edx
801039c0:	52                   	push   %edx
801039c1:	50                   	push   %eax
801039c2:	e8 5a 01 00 00       	call   80103b21 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801039c7:	83 c4 10             	add    $0x10,%esp
801039ca:	be 00 00 00 00       	mov    $0x0,%esi
801039cf:	eb 14                	jmp    801039e5 <procdump+0x9c>
        cprintf(" %p", pc[i]);
801039d1:	83 ec 08             	sub    $0x8,%esp
801039d4:	50                   	push   %eax
801039d5:	68 81 65 10 80       	push   $0x80106581
801039da:	e8 2c cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801039df:	83 c6 01             	add    $0x1,%esi
801039e2:	83 c4 10             	add    $0x10,%esp
801039e5:	83 fe 09             	cmp    $0x9,%esi
801039e8:	7f 8e                	jg     80103978 <procdump+0x2f>
801039ea:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
801039ee:	85 c0                	test   %eax,%eax
801039f0:	75 df                	jne    801039d1 <procdump+0x88>
801039f2:	eb 84                	jmp    80103978 <procdump+0x2f>
  }
}
801039f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039f7:	5b                   	pop    %ebx
801039f8:	5e                   	pop    %esi
801039f9:	5d                   	pop    %ebp
801039fa:	c3                   	ret    

801039fb <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801039fb:	55                   	push   %ebp
801039fc:	89 e5                	mov    %esp,%ebp
801039fe:	53                   	push   %ebx
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103a05:	68 b8 6b 10 80       	push   $0x80106bb8
80103a0a:	8d 43 04             	lea    0x4(%ebx),%eax
80103a0d:	50                   	push   %eax
80103a0e:	e8 f3 00 00 00       	call   80103b06 <initlock>
  lk->name = name;
80103a13:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a16:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a1f:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a26:	83 c4 10             	add    $0x10,%esp
80103a29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a2c:	c9                   	leave  
80103a2d:	c3                   	ret    

80103a2e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a2e:	55                   	push   %ebp
80103a2f:	89 e5                	mov    %esp,%ebp
80103a31:	56                   	push   %esi
80103a32:	53                   	push   %ebx
80103a33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a36:	8d 73 04             	lea    0x4(%ebx),%esi
80103a39:	83 ec 0c             	sub    $0xc,%esp
80103a3c:	56                   	push   %esi
80103a3d:	e8 00 02 00 00       	call   80103c42 <acquire>
  while (lk->locked) {
80103a42:	83 c4 10             	add    $0x10,%esp
80103a45:	eb 0d                	jmp    80103a54 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103a47:	83 ec 08             	sub    $0x8,%esp
80103a4a:	56                   	push   %esi
80103a4b:	53                   	push   %ebx
80103a4c:	e8 f6 fc ff ff       	call   80103747 <sleep>
80103a51:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103a54:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a57:	75 ee                	jne    80103a47 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103a59:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103a5f:	e8 3f f8 ff ff       	call   801032a3 <myproc>
80103a64:	8b 40 10             	mov    0x10(%eax),%eax
80103a67:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103a6a:	83 ec 0c             	sub    $0xc,%esp
80103a6d:	56                   	push   %esi
80103a6e:	e8 34 02 00 00       	call   80103ca7 <release>
}
80103a73:	83 c4 10             	add    $0x10,%esp
80103a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a79:	5b                   	pop    %ebx
80103a7a:	5e                   	pop    %esi
80103a7b:	5d                   	pop    %ebp
80103a7c:	c3                   	ret    

80103a7d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103a7d:	55                   	push   %ebp
80103a7e:	89 e5                	mov    %esp,%ebp
80103a80:	56                   	push   %esi
80103a81:	53                   	push   %ebx
80103a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a85:	8d 73 04             	lea    0x4(%ebx),%esi
80103a88:	83 ec 0c             	sub    $0xc,%esp
80103a8b:	56                   	push   %esi
80103a8c:	e8 b1 01 00 00       	call   80103c42 <acquire>
  lk->locked = 0;
80103a91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a97:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103a9e:	89 1c 24             	mov    %ebx,(%esp)
80103aa1:	e8 06 fe ff ff       	call   801038ac <wakeup>
  release(&lk->lk);
80103aa6:	89 34 24             	mov    %esi,(%esp)
80103aa9:	e8 f9 01 00 00       	call   80103ca7 <release>
}
80103aae:	83 c4 10             	add    $0x10,%esp
80103ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ab4:	5b                   	pop    %ebx
80103ab5:	5e                   	pop    %esi
80103ab6:	5d                   	pop    %ebp
80103ab7:	c3                   	ret    

80103ab8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ab8:	55                   	push   %ebp
80103ab9:	89 e5                	mov    %esp,%ebp
80103abb:	56                   	push   %esi
80103abc:	53                   	push   %ebx
80103abd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103ac0:	8d 73 04             	lea    0x4(%ebx),%esi
80103ac3:	83 ec 0c             	sub    $0xc,%esp
80103ac6:	56                   	push   %esi
80103ac7:	e8 76 01 00 00       	call   80103c42 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103acc:	83 c4 10             	add    $0x10,%esp
80103acf:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ad2:	75 17                	jne    80103aeb <holdingsleep+0x33>
80103ad4:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103ad9:	83 ec 0c             	sub    $0xc,%esp
80103adc:	56                   	push   %esi
80103add:	e8 c5 01 00 00       	call   80103ca7 <release>
  return r;
}
80103ae2:	89 d8                	mov    %ebx,%eax
80103ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ae7:	5b                   	pop    %ebx
80103ae8:	5e                   	pop    %esi
80103ae9:	5d                   	pop    %ebp
80103aea:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103aeb:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103aee:	e8 b0 f7 ff ff       	call   801032a3 <myproc>
80103af3:	3b 58 10             	cmp    0x10(%eax),%ebx
80103af6:	74 07                	je     80103aff <holdingsleep+0x47>
80103af8:	bb 00 00 00 00       	mov    $0x0,%ebx
80103afd:	eb da                	jmp    80103ad9 <holdingsleep+0x21>
80103aff:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b04:	eb d3                	jmp    80103ad9 <holdingsleep+0x21>

80103b06 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103b06:	55                   	push   %ebp
80103b07:	89 e5                	mov    %esp,%ebp
80103b09:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b0f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b1f:	5d                   	pop    %ebp
80103b20:	c3                   	ret    

80103b21 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b21:	55                   	push   %ebp
80103b22:	89 e5                	mov    %esp,%ebp
80103b24:	53                   	push   %ebx
80103b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b28:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2b:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b2e:	b8 00 00 00 00       	mov    $0x0,%eax
80103b33:	83 f8 09             	cmp    $0x9,%eax
80103b36:	7f 25                	jg     80103b5d <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b38:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b3e:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b44:	77 17                	ja     80103b5d <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b46:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b49:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b4c:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b4e:	83 c0 01             	add    $0x1,%eax
80103b51:	eb e0                	jmp    80103b33 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b53:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b5a:	83 c0 01             	add    $0x1,%eax
80103b5d:	83 f8 09             	cmp    $0x9,%eax
80103b60:	7e f1                	jle    80103b53 <getcallerpcs+0x32>
}
80103b62:	5b                   	pop    %ebx
80103b63:	5d                   	pop    %ebp
80103b64:	c3                   	ret    

80103b65 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b65:	55                   	push   %ebp
80103b66:	89 e5                	mov    %esp,%ebp
80103b68:	53                   	push   %ebx
80103b69:	83 ec 04             	sub    $0x4,%esp
80103b6c:	9c                   	pushf  
80103b6d:	5b                   	pop    %ebx
  asm volatile("cli");
80103b6e:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b6f:	e8 b8 f6 ff ff       	call   8010322c <mycpu>
80103b74:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b7b:	74 12                	je     80103b8f <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103b7d:	e8 aa f6 ff ff       	call   8010322c <mycpu>
80103b82:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103b89:	83 c4 04             	add    $0x4,%esp
80103b8c:	5b                   	pop    %ebx
80103b8d:	5d                   	pop    %ebp
80103b8e:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103b8f:	e8 98 f6 ff ff       	call   8010322c <mycpu>
80103b94:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103b9a:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103ba0:	eb db                	jmp    80103b7d <pushcli+0x18>

80103ba2 <popcli>:

void
popcli(void)
{
80103ba2:	55                   	push   %ebp
80103ba3:	89 e5                	mov    %esp,%ebp
80103ba5:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ba8:	9c                   	pushf  
80103ba9:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103baa:	f6 c4 02             	test   $0x2,%ah
80103bad:	75 28                	jne    80103bd7 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103baf:	e8 78 f6 ff ff       	call   8010322c <mycpu>
80103bb4:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103bba:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103bbd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103bc3:	85 d2                	test   %edx,%edx
80103bc5:	78 1d                	js     80103be4 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bc7:	e8 60 f6 ff ff       	call   8010322c <mycpu>
80103bcc:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bd3:	74 1c                	je     80103bf1 <popcli+0x4f>
    sti();
}
80103bd5:	c9                   	leave  
80103bd6:	c3                   	ret    
    panic("popcli - interruptible");
80103bd7:	83 ec 0c             	sub    $0xc,%esp
80103bda:	68 c3 6b 10 80       	push   $0x80106bc3
80103bdf:	e8 64 c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103be4:	83 ec 0c             	sub    $0xc,%esp
80103be7:	68 da 6b 10 80       	push   $0x80106bda
80103bec:	e8 57 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bf1:	e8 36 f6 ff ff       	call   8010322c <mycpu>
80103bf6:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103bfd:	74 d6                	je     80103bd5 <popcli+0x33>
  asm volatile("sti");
80103bff:	fb                   	sti    
}
80103c00:	eb d3                	jmp    80103bd5 <popcli+0x33>

80103c02 <holding>:
{
80103c02:	55                   	push   %ebp
80103c03:	89 e5                	mov    %esp,%ebp
80103c05:	53                   	push   %ebx
80103c06:	83 ec 04             	sub    $0x4,%esp
80103c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c0c:	e8 54 ff ff ff       	call   80103b65 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c11:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c14:	75 12                	jne    80103c28 <holding+0x26>
80103c16:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c1b:	e8 82 ff ff ff       	call   80103ba2 <popcli>
}
80103c20:	89 d8                	mov    %ebx,%eax
80103c22:	83 c4 04             	add    $0x4,%esp
80103c25:	5b                   	pop    %ebx
80103c26:	5d                   	pop    %ebp
80103c27:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c28:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c2b:	e8 fc f5 ff ff       	call   8010322c <mycpu>
80103c30:	39 c3                	cmp    %eax,%ebx
80103c32:	74 07                	je     80103c3b <holding+0x39>
80103c34:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c39:	eb e0                	jmp    80103c1b <holding+0x19>
80103c3b:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c40:	eb d9                	jmp    80103c1b <holding+0x19>

80103c42 <acquire>:
{
80103c42:	55                   	push   %ebp
80103c43:	89 e5                	mov    %esp,%ebp
80103c45:	53                   	push   %ebx
80103c46:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c49:	e8 17 ff ff ff       	call   80103b65 <pushcli>
  if(holding(lk))
80103c4e:	83 ec 0c             	sub    $0xc,%esp
80103c51:	ff 75 08             	pushl  0x8(%ebp)
80103c54:	e8 a9 ff ff ff       	call   80103c02 <holding>
80103c59:	83 c4 10             	add    $0x10,%esp
80103c5c:	85 c0                	test   %eax,%eax
80103c5e:	75 3a                	jne    80103c9a <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103c60:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103c63:	b8 01 00 00 00       	mov    $0x1,%eax
80103c68:	f0 87 02             	lock xchg %eax,(%edx)
80103c6b:	85 c0                	test   %eax,%eax
80103c6d:	75 f1                	jne    80103c60 <acquire+0x1e>
  __sync_synchronize();
80103c6f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103c74:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c77:	e8 b0 f5 ff ff       	call   8010322c <mycpu>
80103c7c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c82:	83 c0 0c             	add    $0xc,%eax
80103c85:	83 ec 08             	sub    $0x8,%esp
80103c88:	50                   	push   %eax
80103c89:	8d 45 08             	lea    0x8(%ebp),%eax
80103c8c:	50                   	push   %eax
80103c8d:	e8 8f fe ff ff       	call   80103b21 <getcallerpcs>
}
80103c92:	83 c4 10             	add    $0x10,%esp
80103c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c98:	c9                   	leave  
80103c99:	c3                   	ret    
    panic("acquire");
80103c9a:	83 ec 0c             	sub    $0xc,%esp
80103c9d:	68 e1 6b 10 80       	push   $0x80106be1
80103ca2:	e8 a1 c6 ff ff       	call   80100348 <panic>

80103ca7 <release>:
{
80103ca7:	55                   	push   %ebp
80103ca8:	89 e5                	mov    %esp,%ebp
80103caa:	53                   	push   %ebx
80103cab:	83 ec 10             	sub    $0x10,%esp
80103cae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103cb1:	53                   	push   %ebx
80103cb2:	e8 4b ff ff ff       	call   80103c02 <holding>
80103cb7:	83 c4 10             	add    $0x10,%esp
80103cba:	85 c0                	test   %eax,%eax
80103cbc:	74 23                	je     80103ce1 <release+0x3a>
  lk->pcs[0] = 0;
80103cbe:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103cc5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103ccc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103cd1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103cd7:	e8 c6 fe ff ff       	call   80103ba2 <popcli>
}
80103cdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cdf:	c9                   	leave  
80103ce0:	c3                   	ret    
    panic("release");
80103ce1:	83 ec 0c             	sub    $0xc,%esp
80103ce4:	68 e9 6b 10 80       	push   $0x80106be9
80103ce9:	e8 5a c6 ff ff       	call   80100348 <panic>

80103cee <memset>:
80103cee:	55                   	push   %ebp
80103cef:	89 e5                	mov    %esp,%ebp
80103cf1:	57                   	push   %edi
80103cf2:	53                   	push   %ebx
80103cf3:	8b 55 08             	mov    0x8(%ebp),%edx
80103cf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103cf9:	f6 c2 03             	test   $0x3,%dl
80103cfc:	75 05                	jne    80103d03 <memset+0x15>
80103cfe:	f6 c1 03             	test   $0x3,%cl
80103d01:	74 0e                	je     80103d11 <memset+0x23>
80103d03:	89 d7                	mov    %edx,%edi
80103d05:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d08:	fc                   	cld    
80103d09:	f3 aa                	rep stos %al,%es:(%edi)
80103d0b:	89 d0                	mov    %edx,%eax
80103d0d:	5b                   	pop    %ebx
80103d0e:	5f                   	pop    %edi
80103d0f:	5d                   	pop    %ebp
80103d10:	c3                   	ret    
80103d11:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
80103d15:	c1 e9 02             	shr    $0x2,%ecx
80103d18:	89 f8                	mov    %edi,%eax
80103d1a:	c1 e0 18             	shl    $0x18,%eax
80103d1d:	89 fb                	mov    %edi,%ebx
80103d1f:	c1 e3 10             	shl    $0x10,%ebx
80103d22:	09 d8                	or     %ebx,%eax
80103d24:	89 fb                	mov    %edi,%ebx
80103d26:	c1 e3 08             	shl    $0x8,%ebx
80103d29:	09 d8                	or     %ebx,%eax
80103d2b:	09 f8                	or     %edi,%eax
80103d2d:	89 d7                	mov    %edx,%edi
80103d2f:	fc                   	cld    
80103d30:	f3 ab                	rep stos %eax,%es:(%edi)
80103d32:	eb d7                	jmp    80103d0b <memset+0x1d>

80103d34 <memcmp>:
80103d34:	55                   	push   %ebp
80103d35:	89 e5                	mov    %esp,%ebp
80103d37:	56                   	push   %esi
80103d38:	53                   	push   %ebx
80103d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d3f:	8b 45 10             	mov    0x10(%ebp),%eax
80103d42:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d45:	85 c0                	test   %eax,%eax
80103d47:	74 1c                	je     80103d65 <memcmp+0x31>
80103d49:	0f b6 01             	movzbl (%ecx),%eax
80103d4c:	0f b6 1a             	movzbl (%edx),%ebx
80103d4f:	38 d8                	cmp    %bl,%al
80103d51:	75 0a                	jne    80103d5d <memcmp+0x29>
80103d53:	83 c1 01             	add    $0x1,%ecx
80103d56:	83 c2 01             	add    $0x1,%edx
80103d59:	89 f0                	mov    %esi,%eax
80103d5b:	eb e5                	jmp    80103d42 <memcmp+0xe>
80103d5d:	0f b6 c0             	movzbl %al,%eax
80103d60:	0f b6 db             	movzbl %bl,%ebx
80103d63:	29 d8                	sub    %ebx,%eax
80103d65:	5b                   	pop    %ebx
80103d66:	5e                   	pop    %esi
80103d67:	5d                   	pop    %ebp
80103d68:	c3                   	ret    

80103d69 <memmove>:
80103d69:	55                   	push   %ebp
80103d6a:	89 e5                	mov    %esp,%ebp
80103d6c:	56                   	push   %esi
80103d6d:	53                   	push   %ebx
80103d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d74:	8b 55 10             	mov    0x10(%ebp),%edx
80103d77:	39 c1                	cmp    %eax,%ecx
80103d79:	73 3a                	jae    80103db5 <memmove+0x4c>
80103d7b:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103d7e:	39 c3                	cmp    %eax,%ebx
80103d80:	76 37                	jbe    80103db9 <memmove+0x50>
80103d82:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80103d85:	eb 0d                	jmp    80103d94 <memmove+0x2b>
80103d87:	83 eb 01             	sub    $0x1,%ebx
80103d8a:	83 e9 01             	sub    $0x1,%ecx
80103d8d:	0f b6 13             	movzbl (%ebx),%edx
80103d90:	88 11                	mov    %dl,(%ecx)
80103d92:	89 f2                	mov    %esi,%edx
80103d94:	8d 72 ff             	lea    -0x1(%edx),%esi
80103d97:	85 d2                	test   %edx,%edx
80103d99:	75 ec                	jne    80103d87 <memmove+0x1e>
80103d9b:	eb 14                	jmp    80103db1 <memmove+0x48>
80103d9d:	0f b6 11             	movzbl (%ecx),%edx
80103da0:	88 13                	mov    %dl,(%ebx)
80103da2:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103da5:	8d 49 01             	lea    0x1(%ecx),%ecx
80103da8:	89 f2                	mov    %esi,%edx
80103daa:	8d 72 ff             	lea    -0x1(%edx),%esi
80103dad:	85 d2                	test   %edx,%edx
80103daf:	75 ec                	jne    80103d9d <memmove+0x34>
80103db1:	5b                   	pop    %ebx
80103db2:	5e                   	pop    %esi
80103db3:	5d                   	pop    %ebp
80103db4:	c3                   	ret    
80103db5:	89 c3                	mov    %eax,%ebx
80103db7:	eb f1                	jmp    80103daa <memmove+0x41>
80103db9:	89 c3                	mov    %eax,%ebx
80103dbb:	eb ed                	jmp    80103daa <memmove+0x41>

80103dbd <memcpy>:
80103dbd:	55                   	push   %ebp
80103dbe:	89 e5                	mov    %esp,%ebp
80103dc0:	ff 75 10             	pushl  0x10(%ebp)
80103dc3:	ff 75 0c             	pushl  0xc(%ebp)
80103dc6:	ff 75 08             	pushl  0x8(%ebp)
80103dc9:	e8 9b ff ff ff       	call   80103d69 <memmove>
80103dce:	c9                   	leave  
80103dcf:	c3                   	ret    

80103dd0 <strncmp>:
80103dd0:	55                   	push   %ebp
80103dd1:	89 e5                	mov    %esp,%ebp
80103dd3:	53                   	push   %ebx
80103dd4:	8b 55 08             	mov    0x8(%ebp),%edx
80103dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103dda:	8b 45 10             	mov    0x10(%ebp),%eax
80103ddd:	eb 09                	jmp    80103de8 <strncmp+0x18>
80103ddf:	83 e8 01             	sub    $0x1,%eax
80103de2:	83 c2 01             	add    $0x1,%edx
80103de5:	83 c1 01             	add    $0x1,%ecx
80103de8:	85 c0                	test   %eax,%eax
80103dea:	74 0b                	je     80103df7 <strncmp+0x27>
80103dec:	0f b6 1a             	movzbl (%edx),%ebx
80103def:	84 db                	test   %bl,%bl
80103df1:	74 04                	je     80103df7 <strncmp+0x27>
80103df3:	3a 19                	cmp    (%ecx),%bl
80103df5:	74 e8                	je     80103ddf <strncmp+0xf>
80103df7:	85 c0                	test   %eax,%eax
80103df9:	74 0b                	je     80103e06 <strncmp+0x36>
80103dfb:	0f b6 02             	movzbl (%edx),%eax
80103dfe:	0f b6 11             	movzbl (%ecx),%edx
80103e01:	29 d0                	sub    %edx,%eax
80103e03:	5b                   	pop    %ebx
80103e04:	5d                   	pop    %ebp
80103e05:	c3                   	ret    
80103e06:	b8 00 00 00 00       	mov    $0x0,%eax
80103e0b:	eb f6                	jmp    80103e03 <strncmp+0x33>

80103e0d <strncpy>:
80103e0d:	55                   	push   %ebp
80103e0e:	89 e5                	mov    %esp,%ebp
80103e10:	57                   	push   %edi
80103e11:	56                   	push   %esi
80103e12:	53                   	push   %ebx
80103e13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e16:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103e19:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1c:	eb 04                	jmp    80103e22 <strncpy+0x15>
80103e1e:	89 fb                	mov    %edi,%ebx
80103e20:	89 f0                	mov    %esi,%eax
80103e22:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e25:	85 c9                	test   %ecx,%ecx
80103e27:	7e 1d                	jle    80103e46 <strncpy+0x39>
80103e29:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e2c:	8d 70 01             	lea    0x1(%eax),%esi
80103e2f:	0f b6 1b             	movzbl (%ebx),%ebx
80103e32:	88 18                	mov    %bl,(%eax)
80103e34:	89 d1                	mov    %edx,%ecx
80103e36:	84 db                	test   %bl,%bl
80103e38:	75 e4                	jne    80103e1e <strncpy+0x11>
80103e3a:	89 f0                	mov    %esi,%eax
80103e3c:	eb 08                	jmp    80103e46 <strncpy+0x39>
80103e3e:	c6 00 00             	movb   $0x0,(%eax)
80103e41:	89 ca                	mov    %ecx,%edx
80103e43:	8d 40 01             	lea    0x1(%eax),%eax
80103e46:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e49:	85 d2                	test   %edx,%edx
80103e4b:	7f f1                	jg     80103e3e <strncpy+0x31>
80103e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e50:	5b                   	pop    %ebx
80103e51:	5e                   	pop    %esi
80103e52:	5f                   	pop    %edi
80103e53:	5d                   	pop    %ebp
80103e54:	c3                   	ret    

80103e55 <safestrcpy>:
80103e55:	55                   	push   %ebp
80103e56:	89 e5                	mov    %esp,%ebp
80103e58:	57                   	push   %edi
80103e59:	56                   	push   %esi
80103e5a:	53                   	push   %ebx
80103e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e61:	8b 55 10             	mov    0x10(%ebp),%edx
80103e64:	85 d2                	test   %edx,%edx
80103e66:	7e 23                	jle    80103e8b <safestrcpy+0x36>
80103e68:	89 c1                	mov    %eax,%ecx
80103e6a:	eb 04                	jmp    80103e70 <safestrcpy+0x1b>
80103e6c:	89 fb                	mov    %edi,%ebx
80103e6e:	89 f1                	mov    %esi,%ecx
80103e70:	83 ea 01             	sub    $0x1,%edx
80103e73:	85 d2                	test   %edx,%edx
80103e75:	7e 11                	jle    80103e88 <safestrcpy+0x33>
80103e77:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e7a:	8d 71 01             	lea    0x1(%ecx),%esi
80103e7d:	0f b6 1b             	movzbl (%ebx),%ebx
80103e80:	88 19                	mov    %bl,(%ecx)
80103e82:	84 db                	test   %bl,%bl
80103e84:	75 e6                	jne    80103e6c <safestrcpy+0x17>
80103e86:	89 f1                	mov    %esi,%ecx
80103e88:	c6 01 00             	movb   $0x0,(%ecx)
80103e8b:	5b                   	pop    %ebx
80103e8c:	5e                   	pop    %esi
80103e8d:	5f                   	pop    %edi
80103e8e:	5d                   	pop    %ebp
80103e8f:	c3                   	ret    

80103e90 <strlen>:
80103e90:	55                   	push   %ebp
80103e91:	89 e5                	mov    %esp,%ebp
80103e93:	8b 55 08             	mov    0x8(%ebp),%edx
80103e96:	b8 00 00 00 00       	mov    $0x0,%eax
80103e9b:	eb 03                	jmp    80103ea0 <strlen+0x10>
80103e9d:	83 c0 01             	add    $0x1,%eax
80103ea0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103ea4:	75 f7                	jne    80103e9d <strlen+0xd>
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret    

80103ea8 <swtch>:
80103ea8:	8b 44 24 04          	mov    0x4(%esp),%eax
80103eac:	8b 54 24 08          	mov    0x8(%esp),%edx
80103eb0:	55                   	push   %ebp
80103eb1:	53                   	push   %ebx
80103eb2:	56                   	push   %esi
80103eb3:	57                   	push   %edi
80103eb4:	89 20                	mov    %esp,(%eax)
80103eb6:	89 d4                	mov    %edx,%esp
80103eb8:	5f                   	pop    %edi
80103eb9:	5e                   	pop    %esi
80103eba:	5b                   	pop    %ebx
80103ebb:	5d                   	pop    %ebp
80103ebc:	c3                   	ret    

80103ebd <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103ebd:	55                   	push   %ebp
80103ebe:	89 e5                	mov    %esp,%ebp
80103ec0:	53                   	push   %ebx
80103ec1:	83 ec 04             	sub    $0x4,%esp
80103ec4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ec7:	e8 d7 f3 ff ff       	call   801032a3 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103ecc:	8b 00                	mov    (%eax),%eax
80103ece:	39 d8                	cmp    %ebx,%eax
80103ed0:	76 19                	jbe    80103eeb <fetchint+0x2e>
80103ed2:	8d 53 04             	lea    0x4(%ebx),%edx
80103ed5:	39 d0                	cmp    %edx,%eax
80103ed7:	72 19                	jb     80103ef2 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103ed9:	8b 13                	mov    (%ebx),%edx
80103edb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ede:	89 10                	mov    %edx,(%eax)
  return 0;
80103ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ee5:	83 c4 04             	add    $0x4,%esp
80103ee8:	5b                   	pop    %ebx
80103ee9:	5d                   	pop    %ebp
80103eea:	c3                   	ret    
    return -1;
80103eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef0:	eb f3                	jmp    80103ee5 <fetchint+0x28>
80103ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef7:	eb ec                	jmp    80103ee5 <fetchint+0x28>

80103ef9 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103ef9:	55                   	push   %ebp
80103efa:	89 e5                	mov    %esp,%ebp
80103efc:	53                   	push   %ebx
80103efd:	83 ec 04             	sub    $0x4,%esp
80103f00:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103f03:	e8 9b f3 ff ff       	call   801032a3 <myproc>

  if(addr >= curproc->sz)
80103f08:	39 18                	cmp    %ebx,(%eax)
80103f0a:	76 26                	jbe    80103f32 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f0f:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f11:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103f13:	89 d8                	mov    %ebx,%eax
80103f15:	39 d0                	cmp    %edx,%eax
80103f17:	73 0e                	jae    80103f27 <fetchstr+0x2e>
    if(*s == 0)
80103f19:	80 38 00             	cmpb   $0x0,(%eax)
80103f1c:	74 05                	je     80103f23 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103f1e:	83 c0 01             	add    $0x1,%eax
80103f21:	eb f2                	jmp    80103f15 <fetchstr+0x1c>
      return s - *pp;
80103f23:	29 d8                	sub    %ebx,%eax
80103f25:	eb 05                	jmp    80103f2c <fetchstr+0x33>
  }
  return -1;
80103f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f2c:	83 c4 04             	add    $0x4,%esp
80103f2f:	5b                   	pop    %ebx
80103f30:	5d                   	pop    %ebp
80103f31:	c3                   	ret    
    return -1;
80103f32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f37:	eb f3                	jmp    80103f2c <fetchstr+0x33>

80103f39 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f39:	55                   	push   %ebp
80103f3a:	89 e5                	mov    %esp,%ebp
80103f3c:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f3f:	e8 5f f3 ff ff       	call   801032a3 <myproc>
80103f44:	8b 50 18             	mov    0x18(%eax),%edx
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	c1 e0 02             	shl    $0x2,%eax
80103f4d:	03 42 44             	add    0x44(%edx),%eax
80103f50:	83 ec 08             	sub    $0x8,%esp
80103f53:	ff 75 0c             	pushl  0xc(%ebp)
80103f56:	83 c0 04             	add    $0x4,%eax
80103f59:	50                   	push   %eax
80103f5a:	e8 5e ff ff ff       	call   80103ebd <fetchint>
}
80103f5f:	c9                   	leave  
80103f60:	c3                   	ret    

80103f61 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f61:	55                   	push   %ebp
80103f62:	89 e5                	mov    %esp,%ebp
80103f64:	56                   	push   %esi
80103f65:	53                   	push   %ebx
80103f66:	83 ec 10             	sub    $0x10,%esp
80103f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103f6c:	e8 32 f3 ff ff       	call   801032a3 <myproc>
80103f71:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103f73:	83 ec 08             	sub    $0x8,%esp
80103f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f79:	50                   	push   %eax
80103f7a:	ff 75 08             	pushl  0x8(%ebp)
80103f7d:	e8 b7 ff ff ff       	call   80103f39 <argint>
80103f82:	83 c4 10             	add    $0x10,%esp
80103f85:	85 c0                	test   %eax,%eax
80103f87:	78 24                	js     80103fad <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103f89:	85 db                	test   %ebx,%ebx
80103f8b:	78 27                	js     80103fb4 <argptr+0x53>
80103f8d:	8b 16                	mov    (%esi),%edx
80103f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f92:	39 c2                	cmp    %eax,%edx
80103f94:	76 25                	jbe    80103fbb <argptr+0x5a>
80103f96:	01 c3                	add    %eax,%ebx
80103f98:	39 da                	cmp    %ebx,%edx
80103f9a:	72 26                	jb     80103fc2 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f9f:	89 02                	mov    %eax,(%edx)
  return 0;
80103fa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fa9:	5b                   	pop    %ebx
80103faa:	5e                   	pop    %esi
80103fab:	5d                   	pop    %ebp
80103fac:	c3                   	ret    
    return -1;
80103fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fb2:	eb f2                	jmp    80103fa6 <argptr+0x45>
    return -1;
80103fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fb9:	eb eb                	jmp    80103fa6 <argptr+0x45>
80103fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fc0:	eb e4                	jmp    80103fa6 <argptr+0x45>
80103fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fc7:	eb dd                	jmp    80103fa6 <argptr+0x45>

80103fc9 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103fc9:	55                   	push   %ebp
80103fca:	89 e5                	mov    %esp,%ebp
80103fcc:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fd2:	50                   	push   %eax
80103fd3:	ff 75 08             	pushl  0x8(%ebp)
80103fd6:	e8 5e ff ff ff       	call   80103f39 <argint>
80103fdb:	83 c4 10             	add    $0x10,%esp
80103fde:	85 c0                	test   %eax,%eax
80103fe0:	78 13                	js     80103ff5 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103fe2:	83 ec 08             	sub    $0x8,%esp
80103fe5:	ff 75 0c             	pushl  0xc(%ebp)
80103fe8:	ff 75 f4             	pushl  -0xc(%ebp)
80103feb:	e8 09 ff ff ff       	call   80103ef9 <fetchstr>
80103ff0:	83 c4 10             	add    $0x10,%esp
}
80103ff3:	c9                   	leave  
80103ff4:	c3                   	ret    
    return -1;
80103ff5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffa:	eb f7                	jmp    80103ff3 <argstr+0x2a>

80103ffc <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
80103ffc:	55                   	push   %ebp
80103ffd:	89 e5                	mov    %esp,%ebp
80103fff:	53                   	push   %ebx
80104000:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104003:	e8 9b f2 ff ff       	call   801032a3 <myproc>
80104008:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010400a:	8b 40 18             	mov    0x18(%eax),%eax
8010400d:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104010:	8d 50 ff             	lea    -0x1(%eax),%edx
80104013:	83 fa 15             	cmp    $0x15,%edx
80104016:	77 18                	ja     80104030 <syscall+0x34>
80104018:	8b 14 85 20 6c 10 80 	mov    -0x7fef93e0(,%eax,4),%edx
8010401f:	85 d2                	test   %edx,%edx
80104021:	74 0d                	je     80104030 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104023:	ff d2                	call   *%edx
80104025:	8b 53 18             	mov    0x18(%ebx),%edx
80104028:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010402b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010402e:	c9                   	leave  
8010402f:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104030:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104033:	50                   	push   %eax
80104034:	52                   	push   %edx
80104035:	ff 73 10             	pushl  0x10(%ebx)
80104038:	68 f1 6b 10 80       	push   $0x80106bf1
8010403d:	e8 c9 c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104042:	8b 43 18             	mov    0x18(%ebx),%eax
80104045:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010404c:	83 c4 10             	add    $0x10,%esp
}
8010404f:	eb da                	jmp    8010402b <syscall+0x2f>

80104051 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104051:	55                   	push   %ebp
80104052:	89 e5                	mov    %esp,%ebp
80104054:	56                   	push   %esi
80104055:	53                   	push   %ebx
80104056:	83 ec 18             	sub    $0x18,%esp
80104059:	89 d6                	mov    %edx,%esi
8010405b:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010405d:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104060:	52                   	push   %edx
80104061:	50                   	push   %eax
80104062:	e8 d2 fe ff ff       	call   80103f39 <argint>
80104067:	83 c4 10             	add    $0x10,%esp
8010406a:	85 c0                	test   %eax,%eax
8010406c:	78 2e                	js     8010409c <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010406e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104072:	77 2f                	ja     801040a3 <argfd+0x52>
80104074:	e8 2a f2 ff ff       	call   801032a3 <myproc>
80104079:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010407c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104080:	85 c0                	test   %eax,%eax
80104082:	74 26                	je     801040aa <argfd+0x59>
    return -1;
  if(pfd)
80104084:	85 f6                	test   %esi,%esi
80104086:	74 02                	je     8010408a <argfd+0x39>
    *pfd = fd;
80104088:	89 16                	mov    %edx,(%esi)
  if(pf)
8010408a:	85 db                	test   %ebx,%ebx
8010408c:	74 23                	je     801040b1 <argfd+0x60>
    *pf = f;
8010408e:	89 03                	mov    %eax,(%ebx)
  return 0;
80104090:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104095:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104098:	5b                   	pop    %ebx
80104099:	5e                   	pop    %esi
8010409a:	5d                   	pop    %ebp
8010409b:	c3                   	ret    
    return -1;
8010409c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a1:	eb f2                	jmp    80104095 <argfd+0x44>
    return -1;
801040a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a8:	eb eb                	jmp    80104095 <argfd+0x44>
801040aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040af:	eb e4                	jmp    80104095 <argfd+0x44>
  return 0;
801040b1:	b8 00 00 00 00       	mov    $0x0,%eax
801040b6:	eb dd                	jmp    80104095 <argfd+0x44>

801040b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801040b8:	55                   	push   %ebp
801040b9:	89 e5                	mov    %esp,%ebp
801040bb:	53                   	push   %ebx
801040bc:	83 ec 04             	sub    $0x4,%esp
801040bf:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801040c1:	e8 dd f1 ff ff       	call   801032a3 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801040c6:	ba 00 00 00 00       	mov    $0x0,%edx
801040cb:	83 fa 0f             	cmp    $0xf,%edx
801040ce:	7f 18                	jg     801040e8 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801040d0:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801040d5:	74 05                	je     801040dc <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801040d7:	83 c2 01             	add    $0x1,%edx
801040da:	eb ef                	jmp    801040cb <fdalloc+0x13>
      curproc->ofile[fd] = f;
801040dc:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801040e0:	89 d0                	mov    %edx,%eax
801040e2:	83 c4 04             	add    $0x4,%esp
801040e5:	5b                   	pop    %ebx
801040e6:	5d                   	pop    %ebp
801040e7:	c3                   	ret    
  return -1;
801040e8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801040ed:	eb f1                	jmp    801040e0 <fdalloc+0x28>

801040ef <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801040ef:	55                   	push   %ebp
801040f0:	89 e5                	mov    %esp,%ebp
801040f2:	56                   	push   %esi
801040f3:	53                   	push   %ebx
801040f4:	83 ec 10             	sub    $0x10,%esp
801040f7:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801040f9:	b8 20 00 00 00       	mov    $0x20,%eax
801040fe:	89 c6                	mov    %eax,%esi
80104100:	39 43 58             	cmp    %eax,0x58(%ebx)
80104103:	76 2e                	jbe    80104133 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104105:	6a 10                	push   $0x10
80104107:	50                   	push   %eax
80104108:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010410b:	50                   	push   %eax
8010410c:	53                   	push   %ebx
8010410d:	e8 61 d6 ff ff       	call   80101773 <readi>
80104112:	83 c4 10             	add    $0x10,%esp
80104115:	83 f8 10             	cmp    $0x10,%eax
80104118:	75 0c                	jne    80104126 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010411a:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010411f:	75 1e                	jne    8010413f <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104121:	8d 46 10             	lea    0x10(%esi),%eax
80104124:	eb d8                	jmp    801040fe <isdirempty+0xf>
      panic("isdirempty: readi");
80104126:	83 ec 0c             	sub    $0xc,%esp
80104129:	68 7c 6c 10 80       	push   $0x80106c7c
8010412e:	e8 15 c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104133:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104138:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010413b:	5b                   	pop    %ebx
8010413c:	5e                   	pop    %esi
8010413d:	5d                   	pop    %ebp
8010413e:	c3                   	ret    
      return 0;
8010413f:	b8 00 00 00 00       	mov    $0x0,%eax
80104144:	eb f2                	jmp    80104138 <isdirempty+0x49>

80104146 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104146:	55                   	push   %ebp
80104147:	89 e5                	mov    %esp,%ebp
80104149:	57                   	push   %edi
8010414a:	56                   	push   %esi
8010414b:	53                   	push   %ebx
8010414c:	83 ec 44             	sub    $0x44,%esp
8010414f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104152:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104155:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104158:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010415b:	52                   	push   %edx
8010415c:	50                   	push   %eax
8010415d:	e8 97 da ff ff       	call   80101bf9 <nameiparent>
80104162:	89 c6                	mov    %eax,%esi
80104164:	83 c4 10             	add    $0x10,%esp
80104167:	85 c0                	test   %eax,%eax
80104169:	0f 84 3a 01 00 00    	je     801042a9 <create+0x163>
    return 0;
  ilock(dp);
8010416f:	83 ec 0c             	sub    $0xc,%esp
80104172:	50                   	push   %eax
80104173:	e8 09 d4 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104178:	83 c4 0c             	add    $0xc,%esp
8010417b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010417e:	50                   	push   %eax
8010417f:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104182:	50                   	push   %eax
80104183:	56                   	push   %esi
80104184:	e8 27 d8 ff ff       	call   801019b0 <dirlookup>
80104189:	89 c3                	mov    %eax,%ebx
8010418b:	83 c4 10             	add    $0x10,%esp
8010418e:	85 c0                	test   %eax,%eax
80104190:	74 3f                	je     801041d1 <create+0x8b>
    iunlockput(dp);
80104192:	83 ec 0c             	sub    $0xc,%esp
80104195:	56                   	push   %esi
80104196:	e8 8d d5 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
8010419b:	89 1c 24             	mov    %ebx,(%esp)
8010419e:	e8 de d3 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801041a3:	83 c4 10             	add    $0x10,%esp
801041a6:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801041ab:	75 11                	jne    801041be <create+0x78>
801041ad:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041b2:	75 0a                	jne    801041be <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041b4:	89 d8                	mov    %ebx,%eax
801041b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801041b9:	5b                   	pop    %ebx
801041ba:	5e                   	pop    %esi
801041bb:	5f                   	pop    %edi
801041bc:	5d                   	pop    %ebp
801041bd:	c3                   	ret    
    iunlockput(ip);
801041be:	83 ec 0c             	sub    $0xc,%esp
801041c1:	53                   	push   %ebx
801041c2:	e8 61 d5 ff ff       	call   80101728 <iunlockput>
    return 0;
801041c7:	83 c4 10             	add    $0x10,%esp
801041ca:	bb 00 00 00 00       	mov    $0x0,%ebx
801041cf:	eb e3                	jmp    801041b4 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801041d1:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801041d5:	83 ec 08             	sub    $0x8,%esp
801041d8:	50                   	push   %eax
801041d9:	ff 36                	pushl  (%esi)
801041db:	e8 9e d1 ff ff       	call   8010137e <ialloc>
801041e0:	89 c3                	mov    %eax,%ebx
801041e2:	83 c4 10             	add    $0x10,%esp
801041e5:	85 c0                	test   %eax,%eax
801041e7:	74 55                	je     8010423e <create+0xf8>
  ilock(ip);
801041e9:	83 ec 0c             	sub    $0xc,%esp
801041ec:	50                   	push   %eax
801041ed:	e8 8f d3 ff ff       	call   80101581 <ilock>
  ip->major = major;
801041f2:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801041f6:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801041fa:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801041fe:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104204:	89 1c 24             	mov    %ebx,(%esp)
80104207:	e8 14 d2 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010420c:	83 c4 10             	add    $0x10,%esp
8010420f:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104214:	74 35                	je     8010424b <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104216:	83 ec 04             	sub    $0x4,%esp
80104219:	ff 73 04             	pushl  0x4(%ebx)
8010421c:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010421f:	50                   	push   %eax
80104220:	56                   	push   %esi
80104221:	e8 0a d9 ff ff       	call   80101b30 <dirlink>
80104226:	83 c4 10             	add    $0x10,%esp
80104229:	85 c0                	test   %eax,%eax
8010422b:	78 6f                	js     8010429c <create+0x156>
  iunlockput(dp);
8010422d:	83 ec 0c             	sub    $0xc,%esp
80104230:	56                   	push   %esi
80104231:	e8 f2 d4 ff ff       	call   80101728 <iunlockput>
  return ip;
80104236:	83 c4 10             	add    $0x10,%esp
80104239:	e9 76 ff ff ff       	jmp    801041b4 <create+0x6e>
    panic("create: ialloc");
8010423e:	83 ec 0c             	sub    $0xc,%esp
80104241:	68 8e 6c 10 80       	push   $0x80106c8e
80104246:	e8 fd c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010424b:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010424f:	83 c0 01             	add    $0x1,%eax
80104252:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104256:	83 ec 0c             	sub    $0xc,%esp
80104259:	56                   	push   %esi
8010425a:	e8 c1 d1 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010425f:	83 c4 0c             	add    $0xc,%esp
80104262:	ff 73 04             	pushl  0x4(%ebx)
80104265:	68 9e 6c 10 80       	push   $0x80106c9e
8010426a:	53                   	push   %ebx
8010426b:	e8 c0 d8 ff ff       	call   80101b30 <dirlink>
80104270:	83 c4 10             	add    $0x10,%esp
80104273:	85 c0                	test   %eax,%eax
80104275:	78 18                	js     8010428f <create+0x149>
80104277:	83 ec 04             	sub    $0x4,%esp
8010427a:	ff 76 04             	pushl  0x4(%esi)
8010427d:	68 9d 6c 10 80       	push   $0x80106c9d
80104282:	53                   	push   %ebx
80104283:	e8 a8 d8 ff ff       	call   80101b30 <dirlink>
80104288:	83 c4 10             	add    $0x10,%esp
8010428b:	85 c0                	test   %eax,%eax
8010428d:	79 87                	jns    80104216 <create+0xd0>
      panic("create dots");
8010428f:	83 ec 0c             	sub    $0xc,%esp
80104292:	68 a0 6c 10 80       	push   $0x80106ca0
80104297:	e8 ac c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010429c:	83 ec 0c             	sub    $0xc,%esp
8010429f:	68 ac 6c 10 80       	push   $0x80106cac
801042a4:	e8 9f c0 ff ff       	call   80100348 <panic>
    return 0;
801042a9:	89 c3                	mov    %eax,%ebx
801042ab:	e9 04 ff ff ff       	jmp    801041b4 <create+0x6e>

801042b0 <sys_dup>:
{
801042b0:	55                   	push   %ebp
801042b1:	89 e5                	mov    %esp,%ebp
801042b3:	53                   	push   %ebx
801042b4:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042b7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042ba:	ba 00 00 00 00       	mov    $0x0,%edx
801042bf:	b8 00 00 00 00       	mov    $0x0,%eax
801042c4:	e8 88 fd ff ff       	call   80104051 <argfd>
801042c9:	85 c0                	test   %eax,%eax
801042cb:	78 23                	js     801042f0 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	e8 e3 fd ff ff       	call   801040b8 <fdalloc>
801042d5:	89 c3                	mov    %eax,%ebx
801042d7:	85 c0                	test   %eax,%eax
801042d9:	78 1c                	js     801042f7 <sys_dup+0x47>
  filedup(f);
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	ff 75 f4             	pushl  -0xc(%ebp)
801042e1:	e8 a8 c9 ff ff       	call   80100c8e <filedup>
  return fd;
801042e6:	83 c4 10             	add    $0x10,%esp
}
801042e9:	89 d8                	mov    %ebx,%eax
801042eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042ee:	c9                   	leave  
801042ef:	c3                   	ret    
    return -1;
801042f0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042f5:	eb f2                	jmp    801042e9 <sys_dup+0x39>
    return -1;
801042f7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042fc:	eb eb                	jmp    801042e9 <sys_dup+0x39>

801042fe <sys_read>:
{
801042fe:	55                   	push   %ebp
801042ff:	89 e5                	mov    %esp,%ebp
80104301:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104304:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104307:	ba 00 00 00 00       	mov    $0x0,%edx
8010430c:	b8 00 00 00 00       	mov    $0x0,%eax
80104311:	e8 3b fd ff ff       	call   80104051 <argfd>
80104316:	85 c0                	test   %eax,%eax
80104318:	78 43                	js     8010435d <sys_read+0x5f>
8010431a:	83 ec 08             	sub    $0x8,%esp
8010431d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104320:	50                   	push   %eax
80104321:	6a 02                	push   $0x2
80104323:	e8 11 fc ff ff       	call   80103f39 <argint>
80104328:	83 c4 10             	add    $0x10,%esp
8010432b:	85 c0                	test   %eax,%eax
8010432d:	78 35                	js     80104364 <sys_read+0x66>
8010432f:	83 ec 04             	sub    $0x4,%esp
80104332:	ff 75 f0             	pushl  -0x10(%ebp)
80104335:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104338:	50                   	push   %eax
80104339:	6a 01                	push   $0x1
8010433b:	e8 21 fc ff ff       	call   80103f61 <argptr>
80104340:	83 c4 10             	add    $0x10,%esp
80104343:	85 c0                	test   %eax,%eax
80104345:	78 24                	js     8010436b <sys_read+0x6d>
  return fileread(f, p, n);
80104347:	83 ec 04             	sub    $0x4,%esp
8010434a:	ff 75 f0             	pushl  -0x10(%ebp)
8010434d:	ff 75 ec             	pushl  -0x14(%ebp)
80104350:	ff 75 f4             	pushl  -0xc(%ebp)
80104353:	e8 7f ca ff ff       	call   80100dd7 <fileread>
80104358:	83 c4 10             	add    $0x10,%esp
}
8010435b:	c9                   	leave  
8010435c:	c3                   	ret    
    return -1;
8010435d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104362:	eb f7                	jmp    8010435b <sys_read+0x5d>
80104364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104369:	eb f0                	jmp    8010435b <sys_read+0x5d>
8010436b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104370:	eb e9                	jmp    8010435b <sys_read+0x5d>

80104372 <sys_write>:
{
80104372:	55                   	push   %ebp
80104373:	89 e5                	mov    %esp,%ebp
80104375:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104378:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010437b:	ba 00 00 00 00       	mov    $0x0,%edx
80104380:	b8 00 00 00 00       	mov    $0x0,%eax
80104385:	e8 c7 fc ff ff       	call   80104051 <argfd>
8010438a:	85 c0                	test   %eax,%eax
8010438c:	78 43                	js     801043d1 <sys_write+0x5f>
8010438e:	83 ec 08             	sub    $0x8,%esp
80104391:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104394:	50                   	push   %eax
80104395:	6a 02                	push   $0x2
80104397:	e8 9d fb ff ff       	call   80103f39 <argint>
8010439c:	83 c4 10             	add    $0x10,%esp
8010439f:	85 c0                	test   %eax,%eax
801043a1:	78 35                	js     801043d8 <sys_write+0x66>
801043a3:	83 ec 04             	sub    $0x4,%esp
801043a6:	ff 75 f0             	pushl  -0x10(%ebp)
801043a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043ac:	50                   	push   %eax
801043ad:	6a 01                	push   $0x1
801043af:	e8 ad fb ff ff       	call   80103f61 <argptr>
801043b4:	83 c4 10             	add    $0x10,%esp
801043b7:	85 c0                	test   %eax,%eax
801043b9:	78 24                	js     801043df <sys_write+0x6d>
  return filewrite(f, p, n);
801043bb:	83 ec 04             	sub    $0x4,%esp
801043be:	ff 75 f0             	pushl  -0x10(%ebp)
801043c1:	ff 75 ec             	pushl  -0x14(%ebp)
801043c4:	ff 75 f4             	pushl  -0xc(%ebp)
801043c7:	e8 90 ca ff ff       	call   80100e5c <filewrite>
801043cc:	83 c4 10             	add    $0x10,%esp
}
801043cf:	c9                   	leave  
801043d0:	c3                   	ret    
    return -1;
801043d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d6:	eb f7                	jmp    801043cf <sys_write+0x5d>
801043d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043dd:	eb f0                	jmp    801043cf <sys_write+0x5d>
801043df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043e4:	eb e9                	jmp    801043cf <sys_write+0x5d>

801043e6 <sys_close>:
{
801043e6:	55                   	push   %ebp
801043e7:	89 e5                	mov    %esp,%ebp
801043e9:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801043ec:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801043ef:	8d 55 f4             	lea    -0xc(%ebp),%edx
801043f2:	b8 00 00 00 00       	mov    $0x0,%eax
801043f7:	e8 55 fc ff ff       	call   80104051 <argfd>
801043fc:	85 c0                	test   %eax,%eax
801043fe:	78 25                	js     80104425 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104400:	e8 9e ee ff ff       	call   801032a3 <myproc>
80104405:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104408:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010440f:	00 
  fileclose(f);
80104410:	83 ec 0c             	sub    $0xc,%esp
80104413:	ff 75 f0             	pushl  -0x10(%ebp)
80104416:	e8 b8 c8 ff ff       	call   80100cd3 <fileclose>
  return 0;
8010441b:	83 c4 10             	add    $0x10,%esp
8010441e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104423:	c9                   	leave  
80104424:	c3                   	ret    
    return -1;
80104425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010442a:	eb f7                	jmp    80104423 <sys_close+0x3d>

8010442c <sys_fstat>:
{
8010442c:	55                   	push   %ebp
8010442d:	89 e5                	mov    %esp,%ebp
8010442f:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104432:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104435:	ba 00 00 00 00       	mov    $0x0,%edx
8010443a:	b8 00 00 00 00       	mov    $0x0,%eax
8010443f:	e8 0d fc ff ff       	call   80104051 <argfd>
80104444:	85 c0                	test   %eax,%eax
80104446:	78 2a                	js     80104472 <sys_fstat+0x46>
80104448:	83 ec 04             	sub    $0x4,%esp
8010444b:	6a 14                	push   $0x14
8010444d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104450:	50                   	push   %eax
80104451:	6a 01                	push   $0x1
80104453:	e8 09 fb ff ff       	call   80103f61 <argptr>
80104458:	83 c4 10             	add    $0x10,%esp
8010445b:	85 c0                	test   %eax,%eax
8010445d:	78 1a                	js     80104479 <sys_fstat+0x4d>
  return filestat(f, st);
8010445f:	83 ec 08             	sub    $0x8,%esp
80104462:	ff 75 f0             	pushl  -0x10(%ebp)
80104465:	ff 75 f4             	pushl  -0xc(%ebp)
80104468:	e8 23 c9 ff ff       	call   80100d90 <filestat>
8010446d:	83 c4 10             	add    $0x10,%esp
}
80104470:	c9                   	leave  
80104471:	c3                   	ret    
    return -1;
80104472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104477:	eb f7                	jmp    80104470 <sys_fstat+0x44>
80104479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010447e:	eb f0                	jmp    80104470 <sys_fstat+0x44>

80104480 <sys_link>:
{
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	56                   	push   %esi
80104484:	53                   	push   %ebx
80104485:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104488:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010448b:	50                   	push   %eax
8010448c:	6a 00                	push   $0x0
8010448e:	e8 36 fb ff ff       	call   80103fc9 <argstr>
80104493:	83 c4 10             	add    $0x10,%esp
80104496:	85 c0                	test   %eax,%eax
80104498:	0f 88 32 01 00 00    	js     801045d0 <sys_link+0x150>
8010449e:	83 ec 08             	sub    $0x8,%esp
801044a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801044a4:	50                   	push   %eax
801044a5:	6a 01                	push   $0x1
801044a7:	e8 1d fb ff ff       	call   80103fc9 <argstr>
801044ac:	83 c4 10             	add    $0x10,%esp
801044af:	85 c0                	test   %eax,%eax
801044b1:	0f 88 20 01 00 00    	js     801045d7 <sys_link+0x157>
  begin_op();
801044b7:	e8 9f e3 ff ff       	call   8010285b <begin_op>
  if((ip = namei(old)) == 0){
801044bc:	83 ec 0c             	sub    $0xc,%esp
801044bf:	ff 75 e0             	pushl  -0x20(%ebp)
801044c2:	e8 1a d7 ff ff       	call   80101be1 <namei>
801044c7:	89 c3                	mov    %eax,%ebx
801044c9:	83 c4 10             	add    $0x10,%esp
801044cc:	85 c0                	test   %eax,%eax
801044ce:	0f 84 99 00 00 00    	je     8010456d <sys_link+0xed>
  ilock(ip);
801044d4:	83 ec 0c             	sub    $0xc,%esp
801044d7:	50                   	push   %eax
801044d8:	e8 a4 d0 ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801044dd:	83 c4 10             	add    $0x10,%esp
801044e0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801044e5:	0f 84 8e 00 00 00    	je     80104579 <sys_link+0xf9>
  ip->nlink++;
801044eb:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801044ef:	83 c0 01             	add    $0x1,%eax
801044f2:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044f6:	83 ec 0c             	sub    $0xc,%esp
801044f9:	53                   	push   %ebx
801044fa:	e8 21 cf ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801044ff:	89 1c 24             	mov    %ebx,(%esp)
80104502:	e8 3c d1 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104507:	83 c4 08             	add    $0x8,%esp
8010450a:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010450d:	50                   	push   %eax
8010450e:	ff 75 e4             	pushl  -0x1c(%ebp)
80104511:	e8 e3 d6 ff ff       	call   80101bf9 <nameiparent>
80104516:	89 c6                	mov    %eax,%esi
80104518:	83 c4 10             	add    $0x10,%esp
8010451b:	85 c0                	test   %eax,%eax
8010451d:	74 7e                	je     8010459d <sys_link+0x11d>
  ilock(dp);
8010451f:	83 ec 0c             	sub    $0xc,%esp
80104522:	50                   	push   %eax
80104523:	e8 59 d0 ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104528:	83 c4 10             	add    $0x10,%esp
8010452b:	8b 03                	mov    (%ebx),%eax
8010452d:	39 06                	cmp    %eax,(%esi)
8010452f:	75 60                	jne    80104591 <sys_link+0x111>
80104531:	83 ec 04             	sub    $0x4,%esp
80104534:	ff 73 04             	pushl  0x4(%ebx)
80104537:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010453a:	50                   	push   %eax
8010453b:	56                   	push   %esi
8010453c:	e8 ef d5 ff ff       	call   80101b30 <dirlink>
80104541:	83 c4 10             	add    $0x10,%esp
80104544:	85 c0                	test   %eax,%eax
80104546:	78 49                	js     80104591 <sys_link+0x111>
  iunlockput(dp);
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	56                   	push   %esi
8010454c:	e8 d7 d1 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104551:	89 1c 24             	mov    %ebx,(%esp)
80104554:	e8 2f d1 ff ff       	call   80101688 <iput>
  end_op();
80104559:	e8 77 e3 ff ff       	call   801028d5 <end_op>
  return 0;
8010455e:	83 c4 10             	add    $0x10,%esp
80104561:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104566:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104569:	5b                   	pop    %ebx
8010456a:	5e                   	pop    %esi
8010456b:	5d                   	pop    %ebp
8010456c:	c3                   	ret    
    end_op();
8010456d:	e8 63 e3 ff ff       	call   801028d5 <end_op>
    return -1;
80104572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104577:	eb ed                	jmp    80104566 <sys_link+0xe6>
    iunlockput(ip);
80104579:	83 ec 0c             	sub    $0xc,%esp
8010457c:	53                   	push   %ebx
8010457d:	e8 a6 d1 ff ff       	call   80101728 <iunlockput>
    end_op();
80104582:	e8 4e e3 ff ff       	call   801028d5 <end_op>
    return -1;
80104587:	83 c4 10             	add    $0x10,%esp
8010458a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010458f:	eb d5                	jmp    80104566 <sys_link+0xe6>
    iunlockput(dp);
80104591:	83 ec 0c             	sub    $0xc,%esp
80104594:	56                   	push   %esi
80104595:	e8 8e d1 ff ff       	call   80101728 <iunlockput>
    goto bad;
8010459a:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010459d:	83 ec 0c             	sub    $0xc,%esp
801045a0:	53                   	push   %ebx
801045a1:	e8 db cf ff ff       	call   80101581 <ilock>
  ip->nlink--;
801045a6:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045aa:	83 e8 01             	sub    $0x1,%eax
801045ad:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045b1:	89 1c 24             	mov    %ebx,(%esp)
801045b4:	e8 67 ce ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801045b9:	89 1c 24             	mov    %ebx,(%esp)
801045bc:	e8 67 d1 ff ff       	call   80101728 <iunlockput>
  end_op();
801045c1:	e8 0f e3 ff ff       	call   801028d5 <end_op>
  return -1;
801045c6:	83 c4 10             	add    $0x10,%esp
801045c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ce:	eb 96                	jmp    80104566 <sys_link+0xe6>
    return -1;
801045d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d5:	eb 8f                	jmp    80104566 <sys_link+0xe6>
801045d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045dc:	eb 88                	jmp    80104566 <sys_link+0xe6>

801045de <sys_unlink>:
{
801045de:	55                   	push   %ebp
801045df:	89 e5                	mov    %esp,%ebp
801045e1:	57                   	push   %edi
801045e2:	56                   	push   %esi
801045e3:	53                   	push   %ebx
801045e4:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801045e7:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801045ea:	50                   	push   %eax
801045eb:	6a 00                	push   $0x0
801045ed:	e8 d7 f9 ff ff       	call   80103fc9 <argstr>
801045f2:	83 c4 10             	add    $0x10,%esp
801045f5:	85 c0                	test   %eax,%eax
801045f7:	0f 88 83 01 00 00    	js     80104780 <sys_unlink+0x1a2>
  begin_op();
801045fd:	e8 59 e2 ff ff       	call   8010285b <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104602:	83 ec 08             	sub    $0x8,%esp
80104605:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104608:	50                   	push   %eax
80104609:	ff 75 c4             	pushl  -0x3c(%ebp)
8010460c:	e8 e8 d5 ff ff       	call   80101bf9 <nameiparent>
80104611:	89 c6                	mov    %eax,%esi
80104613:	83 c4 10             	add    $0x10,%esp
80104616:	85 c0                	test   %eax,%eax
80104618:	0f 84 ed 00 00 00    	je     8010470b <sys_unlink+0x12d>
  ilock(dp);
8010461e:	83 ec 0c             	sub    $0xc,%esp
80104621:	50                   	push   %eax
80104622:	e8 5a cf ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104627:	83 c4 08             	add    $0x8,%esp
8010462a:	68 9e 6c 10 80       	push   $0x80106c9e
8010462f:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104632:	50                   	push   %eax
80104633:	e8 63 d3 ff ff       	call   8010199b <namecmp>
80104638:	83 c4 10             	add    $0x10,%esp
8010463b:	85 c0                	test   %eax,%eax
8010463d:	0f 84 fc 00 00 00    	je     8010473f <sys_unlink+0x161>
80104643:	83 ec 08             	sub    $0x8,%esp
80104646:	68 9d 6c 10 80       	push   $0x80106c9d
8010464b:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010464e:	50                   	push   %eax
8010464f:	e8 47 d3 ff ff       	call   8010199b <namecmp>
80104654:	83 c4 10             	add    $0x10,%esp
80104657:	85 c0                	test   %eax,%eax
80104659:	0f 84 e0 00 00 00    	je     8010473f <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010465f:	83 ec 04             	sub    $0x4,%esp
80104662:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104665:	50                   	push   %eax
80104666:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104669:	50                   	push   %eax
8010466a:	56                   	push   %esi
8010466b:	e8 40 d3 ff ff       	call   801019b0 <dirlookup>
80104670:	89 c3                	mov    %eax,%ebx
80104672:	83 c4 10             	add    $0x10,%esp
80104675:	85 c0                	test   %eax,%eax
80104677:	0f 84 c2 00 00 00    	je     8010473f <sys_unlink+0x161>
  ilock(ip);
8010467d:	83 ec 0c             	sub    $0xc,%esp
80104680:	50                   	push   %eax
80104681:	e8 fb ce ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104686:	83 c4 10             	add    $0x10,%esp
80104689:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010468e:	0f 8e 83 00 00 00    	jle    80104717 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104694:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104699:	0f 84 85 00 00 00    	je     80104724 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
8010469f:	83 ec 04             	sub    $0x4,%esp
801046a2:	6a 10                	push   $0x10
801046a4:	6a 00                	push   $0x0
801046a6:	8d 7d d8             	lea    -0x28(%ebp),%edi
801046a9:	57                   	push   %edi
801046aa:	e8 3f f6 ff ff       	call   80103cee <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046af:	6a 10                	push   $0x10
801046b1:	ff 75 c0             	pushl  -0x40(%ebp)
801046b4:	57                   	push   %edi
801046b5:	56                   	push   %esi
801046b6:	e8 b5 d1 ff ff       	call   80101870 <writei>
801046bb:	83 c4 20             	add    $0x20,%esp
801046be:	83 f8 10             	cmp    $0x10,%eax
801046c1:	0f 85 90 00 00 00    	jne    80104757 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801046c7:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046cc:	0f 84 92 00 00 00    	je     80104764 <sys_unlink+0x186>
  iunlockput(dp);
801046d2:	83 ec 0c             	sub    $0xc,%esp
801046d5:	56                   	push   %esi
801046d6:	e8 4d d0 ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801046db:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046df:	83 e8 01             	sub    $0x1,%eax
801046e2:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046e6:	89 1c 24             	mov    %ebx,(%esp)
801046e9:	e8 32 cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801046ee:	89 1c 24             	mov    %ebx,(%esp)
801046f1:	e8 32 d0 ff ff       	call   80101728 <iunlockput>
  end_op();
801046f6:	e8 da e1 ff ff       	call   801028d5 <end_op>
  return 0;
801046fb:	83 c4 10             	add    $0x10,%esp
801046fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104703:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104706:	5b                   	pop    %ebx
80104707:	5e                   	pop    %esi
80104708:	5f                   	pop    %edi
80104709:	5d                   	pop    %ebp
8010470a:	c3                   	ret    
    end_op();
8010470b:	e8 c5 e1 ff ff       	call   801028d5 <end_op>
    return -1;
80104710:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104715:	eb ec                	jmp    80104703 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104717:	83 ec 0c             	sub    $0xc,%esp
8010471a:	68 bc 6c 10 80       	push   $0x80106cbc
8010471f:	e8 24 bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104724:	89 d8                	mov    %ebx,%eax
80104726:	e8 c4 f9 ff ff       	call   801040ef <isdirempty>
8010472b:	85 c0                	test   %eax,%eax
8010472d:	0f 85 6c ff ff ff    	jne    8010469f <sys_unlink+0xc1>
    iunlockput(ip);
80104733:	83 ec 0c             	sub    $0xc,%esp
80104736:	53                   	push   %ebx
80104737:	e8 ec cf ff ff       	call   80101728 <iunlockput>
    goto bad;
8010473c:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010473f:	83 ec 0c             	sub    $0xc,%esp
80104742:	56                   	push   %esi
80104743:	e8 e0 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104748:	e8 88 e1 ff ff       	call   801028d5 <end_op>
  return -1;
8010474d:	83 c4 10             	add    $0x10,%esp
80104750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104755:	eb ac                	jmp    80104703 <sys_unlink+0x125>
    panic("unlink: writei");
80104757:	83 ec 0c             	sub    $0xc,%esp
8010475a:	68 ce 6c 10 80       	push   $0x80106cce
8010475f:	e8 e4 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
80104764:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104768:	83 e8 01             	sub    $0x1,%eax
8010476b:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010476f:	83 ec 0c             	sub    $0xc,%esp
80104772:	56                   	push   %esi
80104773:	e8 a8 cc ff ff       	call   80101420 <iupdate>
80104778:	83 c4 10             	add    $0x10,%esp
8010477b:	e9 52 ff ff ff       	jmp    801046d2 <sys_unlink+0xf4>
    return -1;
80104780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104785:	e9 79 ff ff ff       	jmp    80104703 <sys_unlink+0x125>

8010478a <sys_open>:

int
sys_open(void)
{
8010478a:	55                   	push   %ebp
8010478b:	89 e5                	mov    %esp,%ebp
8010478d:	57                   	push   %edi
8010478e:	56                   	push   %esi
8010478f:	53                   	push   %ebx
80104790:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104793:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104796:	50                   	push   %eax
80104797:	6a 00                	push   $0x0
80104799:	e8 2b f8 ff ff       	call   80103fc9 <argstr>
8010479e:	83 c4 10             	add    $0x10,%esp
801047a1:	85 c0                	test   %eax,%eax
801047a3:	0f 88 30 01 00 00    	js     801048d9 <sys_open+0x14f>
801047a9:	83 ec 08             	sub    $0x8,%esp
801047ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047af:	50                   	push   %eax
801047b0:	6a 01                	push   $0x1
801047b2:	e8 82 f7 ff ff       	call   80103f39 <argint>
801047b7:	83 c4 10             	add    $0x10,%esp
801047ba:	85 c0                	test   %eax,%eax
801047bc:	0f 88 21 01 00 00    	js     801048e3 <sys_open+0x159>
    return -1;

  begin_op();
801047c2:	e8 94 e0 ff ff       	call   8010285b <begin_op>

  if(omode & O_CREATE){
801047c7:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801047cb:	0f 84 84 00 00 00    	je     80104855 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801047d1:	83 ec 0c             	sub    $0xc,%esp
801047d4:	6a 00                	push   $0x0
801047d6:	b9 00 00 00 00       	mov    $0x0,%ecx
801047db:	ba 02 00 00 00       	mov    $0x2,%edx
801047e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047e3:	e8 5e f9 ff ff       	call   80104146 <create>
801047e8:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801047ea:	83 c4 10             	add    $0x10,%esp
801047ed:	85 c0                	test   %eax,%eax
801047ef:	74 58                	je     80104849 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801047f1:	e8 37 c4 ff ff       	call   80100c2d <filealloc>
801047f6:	89 c3                	mov    %eax,%ebx
801047f8:	85 c0                	test   %eax,%eax
801047fa:	0f 84 ae 00 00 00    	je     801048ae <sys_open+0x124>
80104800:	e8 b3 f8 ff ff       	call   801040b8 <fdalloc>
80104805:	89 c7                	mov    %eax,%edi
80104807:	85 c0                	test   %eax,%eax
80104809:	0f 88 9f 00 00 00    	js     801048ae <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010480f:	83 ec 0c             	sub    $0xc,%esp
80104812:	56                   	push   %esi
80104813:	e8 2b ce ff ff       	call   80101643 <iunlock>
  end_op();
80104818:	e8 b8 e0 ff ff       	call   801028d5 <end_op>

  f->type = FD_INODE;
8010481d:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104823:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104826:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010482d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104830:	83 c4 10             	add    $0x10,%esp
80104833:	a8 01                	test   $0x1,%al
80104835:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104839:	a8 03                	test   $0x3,%al
8010483b:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010483f:	89 f8                	mov    %edi,%eax
80104841:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104844:	5b                   	pop    %ebx
80104845:	5e                   	pop    %esi
80104846:	5f                   	pop    %edi
80104847:	5d                   	pop    %ebp
80104848:	c3                   	ret    
      end_op();
80104849:	e8 87 e0 ff ff       	call   801028d5 <end_op>
      return -1;
8010484e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104853:	eb ea                	jmp    8010483f <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104855:	83 ec 0c             	sub    $0xc,%esp
80104858:	ff 75 e4             	pushl  -0x1c(%ebp)
8010485b:	e8 81 d3 ff ff       	call   80101be1 <namei>
80104860:	89 c6                	mov    %eax,%esi
80104862:	83 c4 10             	add    $0x10,%esp
80104865:	85 c0                	test   %eax,%eax
80104867:	74 39                	je     801048a2 <sys_open+0x118>
    ilock(ip);
80104869:	83 ec 0c             	sub    $0xc,%esp
8010486c:	50                   	push   %eax
8010486d:	e8 0f cd ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104872:	83 c4 10             	add    $0x10,%esp
80104875:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010487a:	0f 85 71 ff ff ff    	jne    801047f1 <sys_open+0x67>
80104880:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104884:	0f 84 67 ff ff ff    	je     801047f1 <sys_open+0x67>
      iunlockput(ip);
8010488a:	83 ec 0c             	sub    $0xc,%esp
8010488d:	56                   	push   %esi
8010488e:	e8 95 ce ff ff       	call   80101728 <iunlockput>
      end_op();
80104893:	e8 3d e0 ff ff       	call   801028d5 <end_op>
      return -1;
80104898:	83 c4 10             	add    $0x10,%esp
8010489b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048a0:	eb 9d                	jmp    8010483f <sys_open+0xb5>
      end_op();
801048a2:	e8 2e e0 ff ff       	call   801028d5 <end_op>
      return -1;
801048a7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048ac:	eb 91                	jmp    8010483f <sys_open+0xb5>
    if(f)
801048ae:	85 db                	test   %ebx,%ebx
801048b0:	74 0c                	je     801048be <sys_open+0x134>
      fileclose(f);
801048b2:	83 ec 0c             	sub    $0xc,%esp
801048b5:	53                   	push   %ebx
801048b6:	e8 18 c4 ff ff       	call   80100cd3 <fileclose>
801048bb:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	56                   	push   %esi
801048c2:	e8 61 ce ff ff       	call   80101728 <iunlockput>
    end_op();
801048c7:	e8 09 e0 ff ff       	call   801028d5 <end_op>
    return -1;
801048cc:	83 c4 10             	add    $0x10,%esp
801048cf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048d4:	e9 66 ff ff ff       	jmp    8010483f <sys_open+0xb5>
    return -1;
801048d9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048de:	e9 5c ff ff ff       	jmp    8010483f <sys_open+0xb5>
801048e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048e8:	e9 52 ff ff ff       	jmp    8010483f <sys_open+0xb5>

801048ed <sys_mkdir>:

int
sys_mkdir(void)
{
801048ed:	55                   	push   %ebp
801048ee:	89 e5                	mov    %esp,%ebp
801048f0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801048f3:	e8 63 df ff ff       	call   8010285b <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801048f8:	83 ec 08             	sub    $0x8,%esp
801048fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048fe:	50                   	push   %eax
801048ff:	6a 00                	push   $0x0
80104901:	e8 c3 f6 ff ff       	call   80103fc9 <argstr>
80104906:	83 c4 10             	add    $0x10,%esp
80104909:	85 c0                	test   %eax,%eax
8010490b:	78 36                	js     80104943 <sys_mkdir+0x56>
8010490d:	83 ec 0c             	sub    $0xc,%esp
80104910:	6a 00                	push   $0x0
80104912:	b9 00 00 00 00       	mov    $0x0,%ecx
80104917:	ba 01 00 00 00       	mov    $0x1,%edx
8010491c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491f:	e8 22 f8 ff ff       	call   80104146 <create>
80104924:	83 c4 10             	add    $0x10,%esp
80104927:	85 c0                	test   %eax,%eax
80104929:	74 18                	je     80104943 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010492b:	83 ec 0c             	sub    $0xc,%esp
8010492e:	50                   	push   %eax
8010492f:	e8 f4 cd ff ff       	call   80101728 <iunlockput>
  end_op();
80104934:	e8 9c df ff ff       	call   801028d5 <end_op>
  return 0;
80104939:	83 c4 10             	add    $0x10,%esp
8010493c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104941:	c9                   	leave  
80104942:	c3                   	ret    
    end_op();
80104943:	e8 8d df ff ff       	call   801028d5 <end_op>
    return -1;
80104948:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010494d:	eb f2                	jmp    80104941 <sys_mkdir+0x54>

8010494f <sys_mknod>:

int
sys_mknod(void)
{
8010494f:	55                   	push   %ebp
80104950:	89 e5                	mov    %esp,%ebp
80104952:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104955:	e8 01 df ff ff       	call   8010285b <begin_op>
  if((argstr(0, &path)) < 0 ||
8010495a:	83 ec 08             	sub    $0x8,%esp
8010495d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104960:	50                   	push   %eax
80104961:	6a 00                	push   $0x0
80104963:	e8 61 f6 ff ff       	call   80103fc9 <argstr>
80104968:	83 c4 10             	add    $0x10,%esp
8010496b:	85 c0                	test   %eax,%eax
8010496d:	78 62                	js     801049d1 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
8010496f:	83 ec 08             	sub    $0x8,%esp
80104972:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104975:	50                   	push   %eax
80104976:	6a 01                	push   $0x1
80104978:	e8 bc f5 ff ff       	call   80103f39 <argint>
  if((argstr(0, &path)) < 0 ||
8010497d:	83 c4 10             	add    $0x10,%esp
80104980:	85 c0                	test   %eax,%eax
80104982:	78 4d                	js     801049d1 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104984:	83 ec 08             	sub    $0x8,%esp
80104987:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010498a:	50                   	push   %eax
8010498b:	6a 02                	push   $0x2
8010498d:	e8 a7 f5 ff ff       	call   80103f39 <argint>
     argint(1, &major) < 0 ||
80104992:	83 c4 10             	add    $0x10,%esp
80104995:	85 c0                	test   %eax,%eax
80104997:	78 38                	js     801049d1 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104999:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
8010499d:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801049a1:	83 ec 0c             	sub    $0xc,%esp
801049a4:	50                   	push   %eax
801049a5:	ba 03 00 00 00       	mov    $0x3,%edx
801049aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ad:	e8 94 f7 ff ff       	call   80104146 <create>
801049b2:	83 c4 10             	add    $0x10,%esp
801049b5:	85 c0                	test   %eax,%eax
801049b7:	74 18                	je     801049d1 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049b9:	83 ec 0c             	sub    $0xc,%esp
801049bc:	50                   	push   %eax
801049bd:	e8 66 cd ff ff       	call   80101728 <iunlockput>
  end_op();
801049c2:	e8 0e df ff ff       	call   801028d5 <end_op>
  return 0;
801049c7:	83 c4 10             	add    $0x10,%esp
801049ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049cf:	c9                   	leave  
801049d0:	c3                   	ret    
    end_op();
801049d1:	e8 ff de ff ff       	call   801028d5 <end_op>
    return -1;
801049d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049db:	eb f2                	jmp    801049cf <sys_mknod+0x80>

801049dd <sys_chdir>:

int
sys_chdir(void)
{
801049dd:	55                   	push   %ebp
801049de:	89 e5                	mov    %esp,%ebp
801049e0:	56                   	push   %esi
801049e1:	53                   	push   %ebx
801049e2:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801049e5:	e8 b9 e8 ff ff       	call   801032a3 <myproc>
801049ea:	89 c6                	mov    %eax,%esi
  
  begin_op();
801049ec:	e8 6a de ff ff       	call   8010285b <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801049f1:	83 ec 08             	sub    $0x8,%esp
801049f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049f7:	50                   	push   %eax
801049f8:	6a 00                	push   $0x0
801049fa:	e8 ca f5 ff ff       	call   80103fc9 <argstr>
801049ff:	83 c4 10             	add    $0x10,%esp
80104a02:	85 c0                	test   %eax,%eax
80104a04:	78 52                	js     80104a58 <sys_chdir+0x7b>
80104a06:	83 ec 0c             	sub    $0xc,%esp
80104a09:	ff 75 f4             	pushl  -0xc(%ebp)
80104a0c:	e8 d0 d1 ff ff       	call   80101be1 <namei>
80104a11:	89 c3                	mov    %eax,%ebx
80104a13:	83 c4 10             	add    $0x10,%esp
80104a16:	85 c0                	test   %eax,%eax
80104a18:	74 3e                	je     80104a58 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104a1a:	83 ec 0c             	sub    $0xc,%esp
80104a1d:	50                   	push   %eax
80104a1e:	e8 5e cb ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104a23:	83 c4 10             	add    $0x10,%esp
80104a26:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a2b:	75 37                	jne    80104a64 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a2d:	83 ec 0c             	sub    $0xc,%esp
80104a30:	53                   	push   %ebx
80104a31:	e8 0d cc ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104a36:	83 c4 04             	add    $0x4,%esp
80104a39:	ff 76 68             	pushl  0x68(%esi)
80104a3c:	e8 47 cc ff ff       	call   80101688 <iput>
  end_op();
80104a41:	e8 8f de ff ff       	call   801028d5 <end_op>
  curproc->cwd = ip;
80104a46:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a49:	83 c4 10             	add    $0x10,%esp
80104a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a54:	5b                   	pop    %ebx
80104a55:	5e                   	pop    %esi
80104a56:	5d                   	pop    %ebp
80104a57:	c3                   	ret    
    end_op();
80104a58:	e8 78 de ff ff       	call   801028d5 <end_op>
    return -1;
80104a5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a62:	eb ed                	jmp    80104a51 <sys_chdir+0x74>
    iunlockput(ip);
80104a64:	83 ec 0c             	sub    $0xc,%esp
80104a67:	53                   	push   %ebx
80104a68:	e8 bb cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104a6d:	e8 63 de ff ff       	call   801028d5 <end_op>
    return -1;
80104a72:	83 c4 10             	add    $0x10,%esp
80104a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a7a:	eb d5                	jmp    80104a51 <sys_chdir+0x74>

80104a7c <sys_exec>:

int
sys_exec(void)
{
80104a7c:	55                   	push   %ebp
80104a7d:	89 e5                	mov    %esp,%ebp
80104a7f:	53                   	push   %ebx
80104a80:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a89:	50                   	push   %eax
80104a8a:	6a 00                	push   $0x0
80104a8c:	e8 38 f5 ff ff       	call   80103fc9 <argstr>
80104a91:	83 c4 10             	add    $0x10,%esp
80104a94:	85 c0                	test   %eax,%eax
80104a96:	0f 88 a8 00 00 00    	js     80104b44 <sys_exec+0xc8>
80104a9c:	83 ec 08             	sub    $0x8,%esp
80104a9f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104aa5:	50                   	push   %eax
80104aa6:	6a 01                	push   $0x1
80104aa8:	e8 8c f4 ff ff       	call   80103f39 <argint>
80104aad:	83 c4 10             	add    $0x10,%esp
80104ab0:	85 c0                	test   %eax,%eax
80104ab2:	0f 88 93 00 00 00    	js     80104b4b <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ab8:	83 ec 04             	sub    $0x4,%esp
80104abb:	68 80 00 00 00       	push   $0x80
80104ac0:	6a 00                	push   $0x0
80104ac2:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104ac8:	50                   	push   %eax
80104ac9:	e8 20 f2 ff ff       	call   80103cee <memset>
80104ace:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104ad1:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104ad6:	83 fb 1f             	cmp    $0x1f,%ebx
80104ad9:	77 77                	ja     80104b52 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104adb:	83 ec 08             	sub    $0x8,%esp
80104ade:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104ae4:	50                   	push   %eax
80104ae5:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104aeb:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104aee:	50                   	push   %eax
80104aef:	e8 c9 f3 ff ff       	call   80103ebd <fetchint>
80104af4:	83 c4 10             	add    $0x10,%esp
80104af7:	85 c0                	test   %eax,%eax
80104af9:	78 5e                	js     80104b59 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104afb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b01:	85 c0                	test   %eax,%eax
80104b03:	74 1d                	je     80104b22 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104b05:	83 ec 08             	sub    $0x8,%esp
80104b08:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b0f:	52                   	push   %edx
80104b10:	50                   	push   %eax
80104b11:	e8 e3 f3 ff ff       	call   80103ef9 <fetchstr>
80104b16:	83 c4 10             	add    $0x10,%esp
80104b19:	85 c0                	test   %eax,%eax
80104b1b:	78 46                	js     80104b63 <sys_exec+0xe7>
  for(i=0;; i++){
80104b1d:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104b20:	eb b4                	jmp    80104ad6 <sys_exec+0x5a>
      argv[i] = 0;
80104b22:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b29:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104b2d:	83 ec 08             	sub    $0x8,%esp
80104b30:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b36:	50                   	push   %eax
80104b37:	ff 75 f4             	pushl  -0xc(%ebp)
80104b3a:	e8 93 bd ff ff       	call   801008d2 <exec>
80104b3f:	83 c4 10             	add    $0x10,%esp
80104b42:	eb 1a                	jmp    80104b5e <sys_exec+0xe2>
    return -1;
80104b44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b49:	eb 13                	jmp    80104b5e <sys_exec+0xe2>
80104b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b50:	eb 0c                	jmp    80104b5e <sys_exec+0xe2>
      return -1;
80104b52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b57:	eb 05                	jmp    80104b5e <sys_exec+0xe2>
      return -1;
80104b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b61:	c9                   	leave  
80104b62:	c3                   	ret    
      return -1;
80104b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b68:	eb f4                	jmp    80104b5e <sys_exec+0xe2>

80104b6a <sys_pipe>:

int
sys_pipe(void)
{
80104b6a:	55                   	push   %ebp
80104b6b:	89 e5                	mov    %esp,%ebp
80104b6d:	53                   	push   %ebx
80104b6e:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b71:	6a 08                	push   $0x8
80104b73:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b76:	50                   	push   %eax
80104b77:	6a 00                	push   $0x0
80104b79:	e8 e3 f3 ff ff       	call   80103f61 <argptr>
80104b7e:	83 c4 10             	add    $0x10,%esp
80104b81:	85 c0                	test   %eax,%eax
80104b83:	78 77                	js     80104bfc <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104b85:	83 ec 08             	sub    $0x8,%esp
80104b88:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b8b:	50                   	push   %eax
80104b8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b8f:	50                   	push   %eax
80104b90:	e8 4d e2 ff ff       	call   80102de2 <pipealloc>
80104b95:	83 c4 10             	add    $0x10,%esp
80104b98:	85 c0                	test   %eax,%eax
80104b9a:	78 67                	js     80104c03 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b9f:	e8 14 f5 ff ff       	call   801040b8 <fdalloc>
80104ba4:	89 c3                	mov    %eax,%ebx
80104ba6:	85 c0                	test   %eax,%eax
80104ba8:	78 21                	js     80104bcb <sys_pipe+0x61>
80104baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bad:	e8 06 f5 ff ff       	call   801040b8 <fdalloc>
80104bb2:	85 c0                	test   %eax,%eax
80104bb4:	78 15                	js     80104bcb <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bb9:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104bbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bbe:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104bc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bc9:	c9                   	leave  
80104bca:	c3                   	ret    
    if(fd0 >= 0)
80104bcb:	85 db                	test   %ebx,%ebx
80104bcd:	78 0d                	js     80104bdc <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104bcf:	e8 cf e6 ff ff       	call   801032a3 <myproc>
80104bd4:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104bdb:	00 
    fileclose(rf);
80104bdc:	83 ec 0c             	sub    $0xc,%esp
80104bdf:	ff 75 f0             	pushl  -0x10(%ebp)
80104be2:	e8 ec c0 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104be7:	83 c4 04             	add    $0x4,%esp
80104bea:	ff 75 ec             	pushl  -0x14(%ebp)
80104bed:	e8 e1 c0 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104bf2:	83 c4 10             	add    $0x10,%esp
80104bf5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfa:	eb ca                	jmp    80104bc6 <sys_pipe+0x5c>
    return -1;
80104bfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c01:	eb c3                	jmp    80104bc6 <sys_pipe+0x5c>
    return -1;
80104c03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c08:	eb bc                	jmp    80104bc6 <sys_pipe+0x5c>

80104c0a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104c0a:	55                   	push   %ebp
80104c0b:	89 e5                	mov    %esp,%ebp
80104c0d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c10:	e8 06 e8 ff ff       	call   8010341b <fork>
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <sys_exit>:

int
sys_exit(void)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c1d:	e8 2d ea ff ff       	call   8010364f <exit>
  return 0;  // not reached
}
80104c22:	b8 00 00 00 00       	mov    $0x0,%eax
80104c27:	c9                   	leave  
80104c28:	c3                   	ret    

80104c29 <sys_wait>:

int
sys_wait(void)
{
80104c29:	55                   	push   %ebp
80104c2a:	89 e5                	mov    %esp,%ebp
80104c2c:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c2f:	e8 a4 eb ff ff       	call   801037d8 <wait>
}
80104c34:	c9                   	leave  
80104c35:	c3                   	ret    

80104c36 <sys_kill>:

int
sys_kill(void)
{
80104c36:	55                   	push   %ebp
80104c37:	89 e5                	mov    %esp,%ebp
80104c39:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c3f:	50                   	push   %eax
80104c40:	6a 00                	push   $0x0
80104c42:	e8 f2 f2 ff ff       	call   80103f39 <argint>
80104c47:	83 c4 10             	add    $0x10,%esp
80104c4a:	85 c0                	test   %eax,%eax
80104c4c:	78 10                	js     80104c5e <sys_kill+0x28>
    return -1;
  return kill(pid);
80104c4e:	83 ec 0c             	sub    $0xc,%esp
80104c51:	ff 75 f4             	pushl  -0xc(%ebp)
80104c54:	e8 7c ec ff ff       	call   801038d5 <kill>
80104c59:	83 c4 10             	add    $0x10,%esp
}
80104c5c:	c9                   	leave  
80104c5d:	c3                   	ret    
    return -1;
80104c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c63:	eb f7                	jmp    80104c5c <sys_kill+0x26>

80104c65 <sys_getpid>:

int
sys_getpid(void)
{
80104c65:	55                   	push   %ebp
80104c66:	89 e5                	mov    %esp,%ebp
80104c68:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c6b:	e8 33 e6 ff ff       	call   801032a3 <myproc>
80104c70:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c73:	c9                   	leave  
80104c74:	c3                   	ret    

80104c75 <sys_sbrk>:

int
sys_sbrk(void)
{
80104c75:	55                   	push   %ebp
80104c76:	89 e5                	mov    %esp,%ebp
80104c78:	53                   	push   %ebx
80104c79:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c7f:	50                   	push   %eax
80104c80:	6a 00                	push   $0x0
80104c82:	e8 b2 f2 ff ff       	call   80103f39 <argint>
80104c87:	83 c4 10             	add    $0x10,%esp
80104c8a:	85 c0                	test   %eax,%eax
80104c8c:	78 27                	js     80104cb5 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104c8e:	e8 10 e6 ff ff       	call   801032a3 <myproc>
80104c93:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104c95:	83 ec 0c             	sub    $0xc,%esp
80104c98:	ff 75 f4             	pushl  -0xc(%ebp)
80104c9b:	e8 0e e7 ff ff       	call   801033ae <growproc>
80104ca0:	83 c4 10             	add    $0x10,%esp
80104ca3:	85 c0                	test   %eax,%eax
80104ca5:	78 07                	js     80104cae <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104ca7:	89 d8                	mov    %ebx,%eax
80104ca9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cac:	c9                   	leave  
80104cad:	c3                   	ret    
    return -1;
80104cae:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cb3:	eb f2                	jmp    80104ca7 <sys_sbrk+0x32>
    return -1;
80104cb5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cba:	eb eb                	jmp    80104ca7 <sys_sbrk+0x32>

80104cbc <sys_sleep>:

int
sys_sleep(void)
{
80104cbc:	55                   	push   %ebp
80104cbd:	89 e5                	mov    %esp,%ebp
80104cbf:	53                   	push   %ebx
80104cc0:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104cc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cc6:	50                   	push   %eax
80104cc7:	6a 00                	push   $0x0
80104cc9:	e8 6b f2 ff ff       	call   80103f39 <argint>
80104cce:	83 c4 10             	add    $0x10,%esp
80104cd1:	85 c0                	test   %eax,%eax
80104cd3:	78 75                	js     80104d4a <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104cd5:	83 ec 0c             	sub    $0xc,%esp
80104cd8:	68 80 3c 13 80       	push   $0x80133c80
80104cdd:	e8 60 ef ff ff       	call   80103c42 <acquire>
  ticks0 = ticks;
80104ce2:	8b 1d c0 44 13 80    	mov    0x801344c0,%ebx
  while(ticks - ticks0 < n){
80104ce8:	83 c4 10             	add    $0x10,%esp
80104ceb:	a1 c0 44 13 80       	mov    0x801344c0,%eax
80104cf0:	29 d8                	sub    %ebx,%eax
80104cf2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104cf5:	73 39                	jae    80104d30 <sys_sleep+0x74>
    if(myproc()->killed){
80104cf7:	e8 a7 e5 ff ff       	call   801032a3 <myproc>
80104cfc:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104d00:	75 17                	jne    80104d19 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104d02:	83 ec 08             	sub    $0x8,%esp
80104d05:	68 80 3c 13 80       	push   $0x80133c80
80104d0a:	68 c0 44 13 80       	push   $0x801344c0
80104d0f:	e8 33 ea ff ff       	call   80103747 <sleep>
80104d14:	83 c4 10             	add    $0x10,%esp
80104d17:	eb d2                	jmp    80104ceb <sys_sleep+0x2f>
      release(&tickslock);
80104d19:	83 ec 0c             	sub    $0xc,%esp
80104d1c:	68 80 3c 13 80       	push   $0x80133c80
80104d21:	e8 81 ef ff ff       	call   80103ca7 <release>
      return -1;
80104d26:	83 c4 10             	add    $0x10,%esp
80104d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2e:	eb 15                	jmp    80104d45 <sys_sleep+0x89>
  }
  release(&tickslock);
80104d30:	83 ec 0c             	sub    $0xc,%esp
80104d33:	68 80 3c 13 80       	push   $0x80133c80
80104d38:	e8 6a ef ff ff       	call   80103ca7 <release>
  return 0;
80104d3d:	83 c4 10             	add    $0x10,%esp
80104d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d48:	c9                   	leave  
80104d49:	c3                   	ret    
    return -1;
80104d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4f:	eb f4                	jmp    80104d45 <sys_sleep+0x89>

80104d51 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d51:	55                   	push   %ebp
80104d52:	89 e5                	mov    %esp,%ebp
80104d54:	53                   	push   %ebx
80104d55:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104d58:	68 80 3c 13 80       	push   $0x80133c80
80104d5d:	e8 e0 ee ff ff       	call   80103c42 <acquire>
  xticks = ticks;
80104d62:	8b 1d c0 44 13 80    	mov    0x801344c0,%ebx
  release(&tickslock);
80104d68:	c7 04 24 80 3c 13 80 	movl   $0x80133c80,(%esp)
80104d6f:	e8 33 ef ff ff       	call   80103ca7 <release>
  return xticks;
}
80104d74:	89 d8                	mov    %ebx,%eax
80104d76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d79:	c9                   	leave  
80104d7a:	c3                   	ret    

80104d7b <sys_dump_physmem>:

int
sys_dump_physmem(void) {
80104d7b:	55                   	push   %ebp
80104d7c:	89 e5                	mov    %esp,%ebp
80104d7e:	83 ec 1c             	sub    $0x1c,%esp
    int* frames;
    int* pids;
    int numframes;
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104d81:	6a 04                	push   $0x4
80104d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d86:	50                   	push   %eax
80104d87:	6a 00                	push   $0x0
80104d89:	e8 d3 f1 ff ff       	call   80103f61 <argptr>
80104d8e:	83 c4 10             	add    $0x10,%esp
80104d91:	85 c0                	test   %eax,%eax
80104d93:	78 42                	js     80104dd7 <sys_dump_physmem+0x5c>
80104d95:	83 ec 04             	sub    $0x4,%esp
80104d98:	6a 04                	push   $0x4
80104d9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d9d:	50                   	push   %eax
80104d9e:	6a 01                	push   $0x1
80104da0:	e8 bc f1 ff ff       	call   80103f61 <argptr>
80104da5:	83 c4 10             	add    $0x10,%esp
80104da8:	85 c0                	test   %eax,%eax
80104daa:	78 32                	js     80104dde <sys_dump_physmem+0x63>
    argint(2, &numframes) < 0) {
80104dac:	83 ec 08             	sub    $0x8,%esp
80104daf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104db2:	50                   	push   %eax
80104db3:	6a 02                	push   $0x2
80104db5:	e8 7f f1 ff ff       	call   80103f39 <argint>
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104dba:	83 c4 10             	add    $0x10,%esp
80104dbd:	85 c0                	test   %eax,%eax
80104dbf:	78 24                	js     80104de5 <sys_dump_physmem+0x6a>
        return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104dc1:	83 ec 04             	sub    $0x4,%esp
80104dc4:	ff 75 ec             	pushl  -0x14(%ebp)
80104dc7:	ff 75 f0             	pushl  -0x10(%ebp)
80104dca:	ff 75 f4             	pushl  -0xc(%ebp)
80104dcd:	e8 71 d3 ff ff       	call   80102143 <dump_physmem>
80104dd2:	83 c4 10             	add    $0x10,%esp
80104dd5:	c9                   	leave  
80104dd6:	c3                   	ret    
        return -1;
80104dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ddc:	eb f7                	jmp    80104dd5 <sys_dump_physmem+0x5a>
80104dde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de3:	eb f0                	jmp    80104dd5 <sys_dump_physmem+0x5a>
80104de5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dea:	eb e9                	jmp    80104dd5 <sys_dump_physmem+0x5a>

80104dec <alltraps>:
80104dec:	1e                   	push   %ds
80104ded:	06                   	push   %es
80104dee:	0f a0                	push   %fs
80104df0:	0f a8                	push   %gs
80104df2:	60                   	pusha  
80104df3:	66 b8 10 00          	mov    $0x10,%ax
80104df7:	8e d8                	mov    %eax,%ds
80104df9:	8e c0                	mov    %eax,%es
80104dfb:	54                   	push   %esp
80104dfc:	e8 e3 00 00 00       	call   80104ee4 <trap>
80104e01:	83 c4 04             	add    $0x4,%esp

80104e04 <trapret>:
80104e04:	61                   	popa   
80104e05:	0f a9                	pop    %gs
80104e07:	0f a1                	pop    %fs
80104e09:	07                   	pop    %es
80104e0a:	1f                   	pop    %ds
80104e0b:	83 c4 08             	add    $0x8,%esp
80104e0e:	cf                   	iret   

80104e0f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104e0f:	55                   	push   %ebp
80104e10:	89 e5                	mov    %esp,%ebp
80104e12:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104e15:	b8 00 00 00 00       	mov    $0x0,%eax
80104e1a:	eb 4a                	jmp    80104e66 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104e1c:	8b 0c 85 08 90 12 80 	mov    -0x7fed6ff8(,%eax,4),%ecx
80104e23:	66 89 0c c5 c0 3c 13 	mov    %cx,-0x7fecc340(,%eax,8)
80104e2a:	80 
80104e2b:	66 c7 04 c5 c2 3c 13 	movw   $0x8,-0x7fecc33e(,%eax,8)
80104e32:	80 08 00 
80104e35:	c6 04 c5 c4 3c 13 80 	movb   $0x0,-0x7fecc33c(,%eax,8)
80104e3c:	00 
80104e3d:	0f b6 14 c5 c5 3c 13 	movzbl -0x7fecc33b(,%eax,8),%edx
80104e44:	80 
80104e45:	83 e2 f0             	and    $0xfffffff0,%edx
80104e48:	83 ca 0e             	or     $0xe,%edx
80104e4b:	83 e2 8f             	and    $0xffffff8f,%edx
80104e4e:	83 ca 80             	or     $0xffffff80,%edx
80104e51:	88 14 c5 c5 3c 13 80 	mov    %dl,-0x7fecc33b(,%eax,8)
80104e58:	c1 e9 10             	shr    $0x10,%ecx
80104e5b:	66 89 0c c5 c6 3c 13 	mov    %cx,-0x7fecc33a(,%eax,8)
80104e62:	80 
  for(i = 0; i < 256; i++)
80104e63:	83 c0 01             	add    $0x1,%eax
80104e66:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e6b:	7e af                	jle    80104e1c <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e6d:	8b 15 08 91 12 80    	mov    0x80129108,%edx
80104e73:	66 89 15 c0 3e 13 80 	mov    %dx,0x80133ec0
80104e7a:	66 c7 05 c2 3e 13 80 	movw   $0x8,0x80133ec2
80104e81:	08 00 
80104e83:	c6 05 c4 3e 13 80 00 	movb   $0x0,0x80133ec4
80104e8a:	0f b6 05 c5 3e 13 80 	movzbl 0x80133ec5,%eax
80104e91:	83 c8 0f             	or     $0xf,%eax
80104e94:	83 e0 ef             	and    $0xffffffef,%eax
80104e97:	83 c8 e0             	or     $0xffffffe0,%eax
80104e9a:	a2 c5 3e 13 80       	mov    %al,0x80133ec5
80104e9f:	c1 ea 10             	shr    $0x10,%edx
80104ea2:	66 89 15 c6 3e 13 80 	mov    %dx,0x80133ec6

  initlock(&tickslock, "time");
80104ea9:	83 ec 08             	sub    $0x8,%esp
80104eac:	68 dd 6c 10 80       	push   $0x80106cdd
80104eb1:	68 80 3c 13 80       	push   $0x80133c80
80104eb6:	e8 4b ec ff ff       	call   80103b06 <initlock>
}
80104ebb:	83 c4 10             	add    $0x10,%esp
80104ebe:	c9                   	leave  
80104ebf:	c3                   	ret    

80104ec0 <idtinit>:

void
idtinit(void)
{
80104ec0:	55                   	push   %ebp
80104ec1:	89 e5                	mov    %esp,%ebp
80104ec3:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104ec6:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104ecc:	b8 c0 3c 13 80       	mov    $0x80133cc0,%eax
80104ed1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104ed5:	c1 e8 10             	shr    $0x10,%eax
80104ed8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104edc:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104edf:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104ee2:	c9                   	leave  
80104ee3:	c3                   	ret    

80104ee4 <trap>:

void
trap(struct trapframe *tf)
{
80104ee4:	55                   	push   %ebp
80104ee5:	89 e5                	mov    %esp,%ebp
80104ee7:	57                   	push   %edi
80104ee8:	56                   	push   %esi
80104ee9:	53                   	push   %ebx
80104eea:	83 ec 1c             	sub    $0x1c,%esp
80104eed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104ef0:	8b 43 30             	mov    0x30(%ebx),%eax
80104ef3:	83 f8 40             	cmp    $0x40,%eax
80104ef6:	74 13                	je     80104f0b <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104ef8:	83 e8 20             	sub    $0x20,%eax
80104efb:	83 f8 1f             	cmp    $0x1f,%eax
80104efe:	0f 87 3a 01 00 00    	ja     8010503e <trap+0x15a>
80104f04:	ff 24 85 84 6d 10 80 	jmp    *-0x7fef927c(,%eax,4)
    if(myproc()->killed)
80104f0b:	e8 93 e3 ff ff       	call   801032a3 <myproc>
80104f10:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f14:	75 1f                	jne    80104f35 <trap+0x51>
    myproc()->tf = tf;
80104f16:	e8 88 e3 ff ff       	call   801032a3 <myproc>
80104f1b:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104f1e:	e8 d9 f0 ff ff       	call   80103ffc <syscall>
    if(myproc()->killed)
80104f23:	e8 7b e3 ff ff       	call   801032a3 <myproc>
80104f28:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f2c:	74 7e                	je     80104fac <trap+0xc8>
      exit();
80104f2e:	e8 1c e7 ff ff       	call   8010364f <exit>
80104f33:	eb 77                	jmp    80104fac <trap+0xc8>
      exit();
80104f35:	e8 15 e7 ff ff       	call   8010364f <exit>
80104f3a:	eb da                	jmp    80104f16 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104f3c:	e8 47 e3 ff ff       	call   80103288 <cpuid>
80104f41:	85 c0                	test   %eax,%eax
80104f43:	74 6f                	je     80104fb4 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104f45:	e8 fc d4 ff ff       	call   80102446 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f4a:	e8 54 e3 ff ff       	call   801032a3 <myproc>
80104f4f:	85 c0                	test   %eax,%eax
80104f51:	74 1c                	je     80104f6f <trap+0x8b>
80104f53:	e8 4b e3 ff ff       	call   801032a3 <myproc>
80104f58:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f5c:	74 11                	je     80104f6f <trap+0x8b>
80104f5e:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f62:	83 e0 03             	and    $0x3,%eax
80104f65:	66 83 f8 03          	cmp    $0x3,%ax
80104f69:	0f 84 62 01 00 00    	je     801050d1 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f6f:	e8 2f e3 ff ff       	call   801032a3 <myproc>
80104f74:	85 c0                	test   %eax,%eax
80104f76:	74 0f                	je     80104f87 <trap+0xa3>
80104f78:	e8 26 e3 ff ff       	call   801032a3 <myproc>
80104f7d:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f81:	0f 84 54 01 00 00    	je     801050db <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f87:	e8 17 e3 ff ff       	call   801032a3 <myproc>
80104f8c:	85 c0                	test   %eax,%eax
80104f8e:	74 1c                	je     80104fac <trap+0xc8>
80104f90:	e8 0e e3 ff ff       	call   801032a3 <myproc>
80104f95:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f99:	74 11                	je     80104fac <trap+0xc8>
80104f9b:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f9f:	83 e0 03             	and    $0x3,%eax
80104fa2:	66 83 f8 03          	cmp    $0x3,%ax
80104fa6:	0f 84 43 01 00 00    	je     801050ef <trap+0x20b>
    exit();
}
80104fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104faf:	5b                   	pop    %ebx
80104fb0:	5e                   	pop    %esi
80104fb1:	5f                   	pop    %edi
80104fb2:	5d                   	pop    %ebp
80104fb3:	c3                   	ret    
      acquire(&tickslock);
80104fb4:	83 ec 0c             	sub    $0xc,%esp
80104fb7:	68 80 3c 13 80       	push   $0x80133c80
80104fbc:	e8 81 ec ff ff       	call   80103c42 <acquire>
      ticks++;
80104fc1:	83 05 c0 44 13 80 01 	addl   $0x1,0x801344c0
      wakeup(&ticks);
80104fc8:	c7 04 24 c0 44 13 80 	movl   $0x801344c0,(%esp)
80104fcf:	e8 d8 e8 ff ff       	call   801038ac <wakeup>
      release(&tickslock);
80104fd4:	c7 04 24 80 3c 13 80 	movl   $0x80133c80,(%esp)
80104fdb:	e8 c7 ec ff ff       	call   80103ca7 <release>
80104fe0:	83 c4 10             	add    $0x10,%esp
80104fe3:	e9 5d ff ff ff       	jmp    80104f45 <trap+0x61>
    ideintr();
80104fe8:	e8 86 cd ff ff       	call   80101d73 <ideintr>
    lapiceoi();
80104fed:	e8 54 d4 ff ff       	call   80102446 <lapiceoi>
    break;
80104ff2:	e9 53 ff ff ff       	jmp    80104f4a <trap+0x66>
    kbdintr();
80104ff7:	e8 8e d2 ff ff       	call   8010228a <kbdintr>
    lapiceoi();
80104ffc:	e8 45 d4 ff ff       	call   80102446 <lapiceoi>
    break;
80105001:	e9 44 ff ff ff       	jmp    80104f4a <trap+0x66>
    uartintr();
80105006:	e8 05 02 00 00       	call   80105210 <uartintr>
    lapiceoi();
8010500b:	e8 36 d4 ff ff       	call   80102446 <lapiceoi>
    break;
80105010:	e9 35 ff ff ff       	jmp    80104f4a <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105015:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105018:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010501c:	e8 67 e2 ff ff       	call   80103288 <cpuid>
80105021:	57                   	push   %edi
80105022:	0f b7 f6             	movzwl %si,%esi
80105025:	56                   	push   %esi
80105026:	50                   	push   %eax
80105027:	68 e8 6c 10 80       	push   $0x80106ce8
8010502c:	e8 da b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105031:	e8 10 d4 ff ff       	call   80102446 <lapiceoi>
    break;
80105036:	83 c4 10             	add    $0x10,%esp
80105039:	e9 0c ff ff ff       	jmp    80104f4a <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010503e:	e8 60 e2 ff ff       	call   801032a3 <myproc>
80105043:	85 c0                	test   %eax,%eax
80105045:	74 5f                	je     801050a6 <trap+0x1c2>
80105047:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010504b:	74 59                	je     801050a6 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010504d:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105050:	8b 43 38             	mov    0x38(%ebx),%eax
80105053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105056:	e8 2d e2 ff ff       	call   80103288 <cpuid>
8010505b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010505e:	8b 53 34             	mov    0x34(%ebx),%edx
80105061:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105064:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105067:	e8 37 e2 ff ff       	call   801032a3 <myproc>
8010506c:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010506f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105072:	e8 2c e2 ff ff       	call   801032a3 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105077:	57                   	push   %edi
80105078:	ff 75 e4             	pushl  -0x1c(%ebp)
8010507b:	ff 75 e0             	pushl  -0x20(%ebp)
8010507e:	ff 75 dc             	pushl  -0x24(%ebp)
80105081:	56                   	push   %esi
80105082:	ff 75 d8             	pushl  -0x28(%ebp)
80105085:	ff 70 10             	pushl  0x10(%eax)
80105088:	68 40 6d 10 80       	push   $0x80106d40
8010508d:	e8 79 b5 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105092:	83 c4 20             	add    $0x20,%esp
80105095:	e8 09 e2 ff ff       	call   801032a3 <myproc>
8010509a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801050a1:	e9 a4 fe ff ff       	jmp    80104f4a <trap+0x66>
801050a6:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801050a9:	8b 73 38             	mov    0x38(%ebx),%esi
801050ac:	e8 d7 e1 ff ff       	call   80103288 <cpuid>
801050b1:	83 ec 0c             	sub    $0xc,%esp
801050b4:	57                   	push   %edi
801050b5:	56                   	push   %esi
801050b6:	50                   	push   %eax
801050b7:	ff 73 30             	pushl  0x30(%ebx)
801050ba:	68 0c 6d 10 80       	push   $0x80106d0c
801050bf:	e8 47 b5 ff ff       	call   8010060b <cprintf>
      panic("trap");
801050c4:	83 c4 14             	add    $0x14,%esp
801050c7:	68 e2 6c 10 80       	push   $0x80106ce2
801050cc:	e8 77 b2 ff ff       	call   80100348 <panic>
    exit();
801050d1:	e8 79 e5 ff ff       	call   8010364f <exit>
801050d6:	e9 94 fe ff ff       	jmp    80104f6f <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801050db:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801050df:	0f 85 a2 fe ff ff    	jne    80104f87 <trap+0xa3>
    yield();
801050e5:	e8 2b e6 ff ff       	call   80103715 <yield>
801050ea:	e9 98 fe ff ff       	jmp    80104f87 <trap+0xa3>
    exit();
801050ef:	e8 5b e5 ff ff       	call   8010364f <exit>
801050f4:	e9 b3 fe ff ff       	jmp    80104fac <trap+0xc8>

801050f9 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801050f9:	55                   	push   %ebp
801050fa:	89 e5                	mov    %esp,%ebp
  if(!uart)
801050fc:	83 3d c0 95 12 80 00 	cmpl   $0x0,0x801295c0
80105103:	74 15                	je     8010511a <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105105:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010510a:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010510b:	a8 01                	test   $0x1,%al
8010510d:	74 12                	je     80105121 <uartgetc+0x28>
8010510f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105114:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105115:	0f b6 c0             	movzbl %al,%eax
}
80105118:	5d                   	pop    %ebp
80105119:	c3                   	ret    
    return -1;
8010511a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511f:	eb f7                	jmp    80105118 <uartgetc+0x1f>
    return -1;
80105121:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105126:	eb f0                	jmp    80105118 <uartgetc+0x1f>

80105128 <uartputc>:
  if(!uart)
80105128:	83 3d c0 95 12 80 00 	cmpl   $0x0,0x801295c0
8010512f:	74 3b                	je     8010516c <uartputc+0x44>
{
80105131:	55                   	push   %ebp
80105132:	89 e5                	mov    %esp,%ebp
80105134:	53                   	push   %ebx
80105135:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105138:	bb 00 00 00 00       	mov    $0x0,%ebx
8010513d:	eb 10                	jmp    8010514f <uartputc+0x27>
    microdelay(10);
8010513f:	83 ec 0c             	sub    $0xc,%esp
80105142:	6a 0a                	push   $0xa
80105144:	e8 1c d3 ff ff       	call   80102465 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105149:	83 c3 01             	add    $0x1,%ebx
8010514c:	83 c4 10             	add    $0x10,%esp
8010514f:	83 fb 7f             	cmp    $0x7f,%ebx
80105152:	7f 0a                	jg     8010515e <uartputc+0x36>
80105154:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105159:	ec                   	in     (%dx),%al
8010515a:	a8 20                	test   $0x20,%al
8010515c:	74 e1                	je     8010513f <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010515e:	8b 45 08             	mov    0x8(%ebp),%eax
80105161:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105166:	ee                   	out    %al,(%dx)
}
80105167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010516a:	c9                   	leave  
8010516b:	c3                   	ret    
8010516c:	f3 c3                	repz ret 

8010516e <uartinit>:
{
8010516e:	55                   	push   %ebp
8010516f:	89 e5                	mov    %esp,%ebp
80105171:	56                   	push   %esi
80105172:	53                   	push   %ebx
80105173:	b9 00 00 00 00       	mov    $0x0,%ecx
80105178:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010517d:	89 c8                	mov    %ecx,%eax
8010517f:	ee                   	out    %al,(%dx)
80105180:	be fb 03 00 00       	mov    $0x3fb,%esi
80105185:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010518a:	89 f2                	mov    %esi,%edx
8010518c:	ee                   	out    %al,(%dx)
8010518d:	b8 0c 00 00 00       	mov    $0xc,%eax
80105192:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105197:	ee                   	out    %al,(%dx)
80105198:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010519d:	89 c8                	mov    %ecx,%eax
8010519f:	89 da                	mov    %ebx,%edx
801051a1:	ee                   	out    %al,(%dx)
801051a2:	b8 03 00 00 00       	mov    $0x3,%eax
801051a7:	89 f2                	mov    %esi,%edx
801051a9:	ee                   	out    %al,(%dx)
801051aa:	ba fc 03 00 00       	mov    $0x3fc,%edx
801051af:	89 c8                	mov    %ecx,%eax
801051b1:	ee                   	out    %al,(%dx)
801051b2:	b8 01 00 00 00       	mov    $0x1,%eax
801051b7:	89 da                	mov    %ebx,%edx
801051b9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051ba:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051bf:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801051c0:	3c ff                	cmp    $0xff,%al
801051c2:	74 45                	je     80105209 <uartinit+0x9b>
  uart = 1;
801051c4:	c7 05 c0 95 12 80 01 	movl   $0x1,0x801295c0
801051cb:	00 00 00 
801051ce:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051d3:	ec                   	in     (%dx),%al
801051d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051d9:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801051da:	83 ec 08             	sub    $0x8,%esp
801051dd:	6a 00                	push   $0x0
801051df:	6a 04                	push   $0x4
801051e1:	e8 98 cd ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801051e6:	83 c4 10             	add    $0x10,%esp
801051e9:	bb 04 6e 10 80       	mov    $0x80106e04,%ebx
801051ee:	eb 12                	jmp    80105202 <uartinit+0x94>
    uartputc(*p);
801051f0:	83 ec 0c             	sub    $0xc,%esp
801051f3:	0f be c0             	movsbl %al,%eax
801051f6:	50                   	push   %eax
801051f7:	e8 2c ff ff ff       	call   80105128 <uartputc>
  for(p="xv6...\n"; *p; p++)
801051fc:	83 c3 01             	add    $0x1,%ebx
801051ff:	83 c4 10             	add    $0x10,%esp
80105202:	0f b6 03             	movzbl (%ebx),%eax
80105205:	84 c0                	test   %al,%al
80105207:	75 e7                	jne    801051f0 <uartinit+0x82>
}
80105209:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010520c:	5b                   	pop    %ebx
8010520d:	5e                   	pop    %esi
8010520e:	5d                   	pop    %ebp
8010520f:	c3                   	ret    

80105210 <uartintr>:

void
uartintr(void)
{
80105210:	55                   	push   %ebp
80105211:	89 e5                	mov    %esp,%ebp
80105213:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105216:	68 f9 50 10 80       	push   $0x801050f9
8010521b:	e8 1e b5 ff ff       	call   8010073e <consoleintr>
}
80105220:	83 c4 10             	add    $0x10,%esp
80105223:	c9                   	leave  
80105224:	c3                   	ret    

80105225 <vector0>:
80105225:	6a 00                	push   $0x0
80105227:	6a 00                	push   $0x0
80105229:	e9 be fb ff ff       	jmp    80104dec <alltraps>

8010522e <vector1>:
8010522e:	6a 00                	push   $0x0
80105230:	6a 01                	push   $0x1
80105232:	e9 b5 fb ff ff       	jmp    80104dec <alltraps>

80105237 <vector2>:
80105237:	6a 00                	push   $0x0
80105239:	6a 02                	push   $0x2
8010523b:	e9 ac fb ff ff       	jmp    80104dec <alltraps>

80105240 <vector3>:
80105240:	6a 00                	push   $0x0
80105242:	6a 03                	push   $0x3
80105244:	e9 a3 fb ff ff       	jmp    80104dec <alltraps>

80105249 <vector4>:
80105249:	6a 00                	push   $0x0
8010524b:	6a 04                	push   $0x4
8010524d:	e9 9a fb ff ff       	jmp    80104dec <alltraps>

80105252 <vector5>:
80105252:	6a 00                	push   $0x0
80105254:	6a 05                	push   $0x5
80105256:	e9 91 fb ff ff       	jmp    80104dec <alltraps>

8010525b <vector6>:
8010525b:	6a 00                	push   $0x0
8010525d:	6a 06                	push   $0x6
8010525f:	e9 88 fb ff ff       	jmp    80104dec <alltraps>

80105264 <vector7>:
80105264:	6a 00                	push   $0x0
80105266:	6a 07                	push   $0x7
80105268:	e9 7f fb ff ff       	jmp    80104dec <alltraps>

8010526d <vector8>:
8010526d:	6a 08                	push   $0x8
8010526f:	e9 78 fb ff ff       	jmp    80104dec <alltraps>

80105274 <vector9>:
80105274:	6a 00                	push   $0x0
80105276:	6a 09                	push   $0x9
80105278:	e9 6f fb ff ff       	jmp    80104dec <alltraps>

8010527d <vector10>:
8010527d:	6a 0a                	push   $0xa
8010527f:	e9 68 fb ff ff       	jmp    80104dec <alltraps>

80105284 <vector11>:
80105284:	6a 0b                	push   $0xb
80105286:	e9 61 fb ff ff       	jmp    80104dec <alltraps>

8010528b <vector12>:
8010528b:	6a 0c                	push   $0xc
8010528d:	e9 5a fb ff ff       	jmp    80104dec <alltraps>

80105292 <vector13>:
80105292:	6a 0d                	push   $0xd
80105294:	e9 53 fb ff ff       	jmp    80104dec <alltraps>

80105299 <vector14>:
80105299:	6a 0e                	push   $0xe
8010529b:	e9 4c fb ff ff       	jmp    80104dec <alltraps>

801052a0 <vector15>:
801052a0:	6a 00                	push   $0x0
801052a2:	6a 0f                	push   $0xf
801052a4:	e9 43 fb ff ff       	jmp    80104dec <alltraps>

801052a9 <vector16>:
801052a9:	6a 00                	push   $0x0
801052ab:	6a 10                	push   $0x10
801052ad:	e9 3a fb ff ff       	jmp    80104dec <alltraps>

801052b2 <vector17>:
801052b2:	6a 11                	push   $0x11
801052b4:	e9 33 fb ff ff       	jmp    80104dec <alltraps>

801052b9 <vector18>:
801052b9:	6a 00                	push   $0x0
801052bb:	6a 12                	push   $0x12
801052bd:	e9 2a fb ff ff       	jmp    80104dec <alltraps>

801052c2 <vector19>:
801052c2:	6a 00                	push   $0x0
801052c4:	6a 13                	push   $0x13
801052c6:	e9 21 fb ff ff       	jmp    80104dec <alltraps>

801052cb <vector20>:
801052cb:	6a 00                	push   $0x0
801052cd:	6a 14                	push   $0x14
801052cf:	e9 18 fb ff ff       	jmp    80104dec <alltraps>

801052d4 <vector21>:
801052d4:	6a 00                	push   $0x0
801052d6:	6a 15                	push   $0x15
801052d8:	e9 0f fb ff ff       	jmp    80104dec <alltraps>

801052dd <vector22>:
801052dd:	6a 00                	push   $0x0
801052df:	6a 16                	push   $0x16
801052e1:	e9 06 fb ff ff       	jmp    80104dec <alltraps>

801052e6 <vector23>:
801052e6:	6a 00                	push   $0x0
801052e8:	6a 17                	push   $0x17
801052ea:	e9 fd fa ff ff       	jmp    80104dec <alltraps>

801052ef <vector24>:
801052ef:	6a 00                	push   $0x0
801052f1:	6a 18                	push   $0x18
801052f3:	e9 f4 fa ff ff       	jmp    80104dec <alltraps>

801052f8 <vector25>:
801052f8:	6a 00                	push   $0x0
801052fa:	6a 19                	push   $0x19
801052fc:	e9 eb fa ff ff       	jmp    80104dec <alltraps>

80105301 <vector26>:
80105301:	6a 00                	push   $0x0
80105303:	6a 1a                	push   $0x1a
80105305:	e9 e2 fa ff ff       	jmp    80104dec <alltraps>

8010530a <vector27>:
8010530a:	6a 00                	push   $0x0
8010530c:	6a 1b                	push   $0x1b
8010530e:	e9 d9 fa ff ff       	jmp    80104dec <alltraps>

80105313 <vector28>:
80105313:	6a 00                	push   $0x0
80105315:	6a 1c                	push   $0x1c
80105317:	e9 d0 fa ff ff       	jmp    80104dec <alltraps>

8010531c <vector29>:
8010531c:	6a 00                	push   $0x0
8010531e:	6a 1d                	push   $0x1d
80105320:	e9 c7 fa ff ff       	jmp    80104dec <alltraps>

80105325 <vector30>:
80105325:	6a 00                	push   $0x0
80105327:	6a 1e                	push   $0x1e
80105329:	e9 be fa ff ff       	jmp    80104dec <alltraps>

8010532e <vector31>:
8010532e:	6a 00                	push   $0x0
80105330:	6a 1f                	push   $0x1f
80105332:	e9 b5 fa ff ff       	jmp    80104dec <alltraps>

80105337 <vector32>:
80105337:	6a 00                	push   $0x0
80105339:	6a 20                	push   $0x20
8010533b:	e9 ac fa ff ff       	jmp    80104dec <alltraps>

80105340 <vector33>:
80105340:	6a 00                	push   $0x0
80105342:	6a 21                	push   $0x21
80105344:	e9 a3 fa ff ff       	jmp    80104dec <alltraps>

80105349 <vector34>:
80105349:	6a 00                	push   $0x0
8010534b:	6a 22                	push   $0x22
8010534d:	e9 9a fa ff ff       	jmp    80104dec <alltraps>

80105352 <vector35>:
80105352:	6a 00                	push   $0x0
80105354:	6a 23                	push   $0x23
80105356:	e9 91 fa ff ff       	jmp    80104dec <alltraps>

8010535b <vector36>:
8010535b:	6a 00                	push   $0x0
8010535d:	6a 24                	push   $0x24
8010535f:	e9 88 fa ff ff       	jmp    80104dec <alltraps>

80105364 <vector37>:
80105364:	6a 00                	push   $0x0
80105366:	6a 25                	push   $0x25
80105368:	e9 7f fa ff ff       	jmp    80104dec <alltraps>

8010536d <vector38>:
8010536d:	6a 00                	push   $0x0
8010536f:	6a 26                	push   $0x26
80105371:	e9 76 fa ff ff       	jmp    80104dec <alltraps>

80105376 <vector39>:
80105376:	6a 00                	push   $0x0
80105378:	6a 27                	push   $0x27
8010537a:	e9 6d fa ff ff       	jmp    80104dec <alltraps>

8010537f <vector40>:
8010537f:	6a 00                	push   $0x0
80105381:	6a 28                	push   $0x28
80105383:	e9 64 fa ff ff       	jmp    80104dec <alltraps>

80105388 <vector41>:
80105388:	6a 00                	push   $0x0
8010538a:	6a 29                	push   $0x29
8010538c:	e9 5b fa ff ff       	jmp    80104dec <alltraps>

80105391 <vector42>:
80105391:	6a 00                	push   $0x0
80105393:	6a 2a                	push   $0x2a
80105395:	e9 52 fa ff ff       	jmp    80104dec <alltraps>

8010539a <vector43>:
8010539a:	6a 00                	push   $0x0
8010539c:	6a 2b                	push   $0x2b
8010539e:	e9 49 fa ff ff       	jmp    80104dec <alltraps>

801053a3 <vector44>:
801053a3:	6a 00                	push   $0x0
801053a5:	6a 2c                	push   $0x2c
801053a7:	e9 40 fa ff ff       	jmp    80104dec <alltraps>

801053ac <vector45>:
801053ac:	6a 00                	push   $0x0
801053ae:	6a 2d                	push   $0x2d
801053b0:	e9 37 fa ff ff       	jmp    80104dec <alltraps>

801053b5 <vector46>:
801053b5:	6a 00                	push   $0x0
801053b7:	6a 2e                	push   $0x2e
801053b9:	e9 2e fa ff ff       	jmp    80104dec <alltraps>

801053be <vector47>:
801053be:	6a 00                	push   $0x0
801053c0:	6a 2f                	push   $0x2f
801053c2:	e9 25 fa ff ff       	jmp    80104dec <alltraps>

801053c7 <vector48>:
801053c7:	6a 00                	push   $0x0
801053c9:	6a 30                	push   $0x30
801053cb:	e9 1c fa ff ff       	jmp    80104dec <alltraps>

801053d0 <vector49>:
801053d0:	6a 00                	push   $0x0
801053d2:	6a 31                	push   $0x31
801053d4:	e9 13 fa ff ff       	jmp    80104dec <alltraps>

801053d9 <vector50>:
801053d9:	6a 00                	push   $0x0
801053db:	6a 32                	push   $0x32
801053dd:	e9 0a fa ff ff       	jmp    80104dec <alltraps>

801053e2 <vector51>:
801053e2:	6a 00                	push   $0x0
801053e4:	6a 33                	push   $0x33
801053e6:	e9 01 fa ff ff       	jmp    80104dec <alltraps>

801053eb <vector52>:
801053eb:	6a 00                	push   $0x0
801053ed:	6a 34                	push   $0x34
801053ef:	e9 f8 f9 ff ff       	jmp    80104dec <alltraps>

801053f4 <vector53>:
801053f4:	6a 00                	push   $0x0
801053f6:	6a 35                	push   $0x35
801053f8:	e9 ef f9 ff ff       	jmp    80104dec <alltraps>

801053fd <vector54>:
801053fd:	6a 00                	push   $0x0
801053ff:	6a 36                	push   $0x36
80105401:	e9 e6 f9 ff ff       	jmp    80104dec <alltraps>

80105406 <vector55>:
80105406:	6a 00                	push   $0x0
80105408:	6a 37                	push   $0x37
8010540a:	e9 dd f9 ff ff       	jmp    80104dec <alltraps>

8010540f <vector56>:
8010540f:	6a 00                	push   $0x0
80105411:	6a 38                	push   $0x38
80105413:	e9 d4 f9 ff ff       	jmp    80104dec <alltraps>

80105418 <vector57>:
80105418:	6a 00                	push   $0x0
8010541a:	6a 39                	push   $0x39
8010541c:	e9 cb f9 ff ff       	jmp    80104dec <alltraps>

80105421 <vector58>:
80105421:	6a 00                	push   $0x0
80105423:	6a 3a                	push   $0x3a
80105425:	e9 c2 f9 ff ff       	jmp    80104dec <alltraps>

8010542a <vector59>:
8010542a:	6a 00                	push   $0x0
8010542c:	6a 3b                	push   $0x3b
8010542e:	e9 b9 f9 ff ff       	jmp    80104dec <alltraps>

80105433 <vector60>:
80105433:	6a 00                	push   $0x0
80105435:	6a 3c                	push   $0x3c
80105437:	e9 b0 f9 ff ff       	jmp    80104dec <alltraps>

8010543c <vector61>:
8010543c:	6a 00                	push   $0x0
8010543e:	6a 3d                	push   $0x3d
80105440:	e9 a7 f9 ff ff       	jmp    80104dec <alltraps>

80105445 <vector62>:
80105445:	6a 00                	push   $0x0
80105447:	6a 3e                	push   $0x3e
80105449:	e9 9e f9 ff ff       	jmp    80104dec <alltraps>

8010544e <vector63>:
8010544e:	6a 00                	push   $0x0
80105450:	6a 3f                	push   $0x3f
80105452:	e9 95 f9 ff ff       	jmp    80104dec <alltraps>

80105457 <vector64>:
80105457:	6a 00                	push   $0x0
80105459:	6a 40                	push   $0x40
8010545b:	e9 8c f9 ff ff       	jmp    80104dec <alltraps>

80105460 <vector65>:
80105460:	6a 00                	push   $0x0
80105462:	6a 41                	push   $0x41
80105464:	e9 83 f9 ff ff       	jmp    80104dec <alltraps>

80105469 <vector66>:
80105469:	6a 00                	push   $0x0
8010546b:	6a 42                	push   $0x42
8010546d:	e9 7a f9 ff ff       	jmp    80104dec <alltraps>

80105472 <vector67>:
80105472:	6a 00                	push   $0x0
80105474:	6a 43                	push   $0x43
80105476:	e9 71 f9 ff ff       	jmp    80104dec <alltraps>

8010547b <vector68>:
8010547b:	6a 00                	push   $0x0
8010547d:	6a 44                	push   $0x44
8010547f:	e9 68 f9 ff ff       	jmp    80104dec <alltraps>

80105484 <vector69>:
80105484:	6a 00                	push   $0x0
80105486:	6a 45                	push   $0x45
80105488:	e9 5f f9 ff ff       	jmp    80104dec <alltraps>

8010548d <vector70>:
8010548d:	6a 00                	push   $0x0
8010548f:	6a 46                	push   $0x46
80105491:	e9 56 f9 ff ff       	jmp    80104dec <alltraps>

80105496 <vector71>:
80105496:	6a 00                	push   $0x0
80105498:	6a 47                	push   $0x47
8010549a:	e9 4d f9 ff ff       	jmp    80104dec <alltraps>

8010549f <vector72>:
8010549f:	6a 00                	push   $0x0
801054a1:	6a 48                	push   $0x48
801054a3:	e9 44 f9 ff ff       	jmp    80104dec <alltraps>

801054a8 <vector73>:
801054a8:	6a 00                	push   $0x0
801054aa:	6a 49                	push   $0x49
801054ac:	e9 3b f9 ff ff       	jmp    80104dec <alltraps>

801054b1 <vector74>:
801054b1:	6a 00                	push   $0x0
801054b3:	6a 4a                	push   $0x4a
801054b5:	e9 32 f9 ff ff       	jmp    80104dec <alltraps>

801054ba <vector75>:
801054ba:	6a 00                	push   $0x0
801054bc:	6a 4b                	push   $0x4b
801054be:	e9 29 f9 ff ff       	jmp    80104dec <alltraps>

801054c3 <vector76>:
801054c3:	6a 00                	push   $0x0
801054c5:	6a 4c                	push   $0x4c
801054c7:	e9 20 f9 ff ff       	jmp    80104dec <alltraps>

801054cc <vector77>:
801054cc:	6a 00                	push   $0x0
801054ce:	6a 4d                	push   $0x4d
801054d0:	e9 17 f9 ff ff       	jmp    80104dec <alltraps>

801054d5 <vector78>:
801054d5:	6a 00                	push   $0x0
801054d7:	6a 4e                	push   $0x4e
801054d9:	e9 0e f9 ff ff       	jmp    80104dec <alltraps>

801054de <vector79>:
801054de:	6a 00                	push   $0x0
801054e0:	6a 4f                	push   $0x4f
801054e2:	e9 05 f9 ff ff       	jmp    80104dec <alltraps>

801054e7 <vector80>:
801054e7:	6a 00                	push   $0x0
801054e9:	6a 50                	push   $0x50
801054eb:	e9 fc f8 ff ff       	jmp    80104dec <alltraps>

801054f0 <vector81>:
801054f0:	6a 00                	push   $0x0
801054f2:	6a 51                	push   $0x51
801054f4:	e9 f3 f8 ff ff       	jmp    80104dec <alltraps>

801054f9 <vector82>:
801054f9:	6a 00                	push   $0x0
801054fb:	6a 52                	push   $0x52
801054fd:	e9 ea f8 ff ff       	jmp    80104dec <alltraps>

80105502 <vector83>:
80105502:	6a 00                	push   $0x0
80105504:	6a 53                	push   $0x53
80105506:	e9 e1 f8 ff ff       	jmp    80104dec <alltraps>

8010550b <vector84>:
8010550b:	6a 00                	push   $0x0
8010550d:	6a 54                	push   $0x54
8010550f:	e9 d8 f8 ff ff       	jmp    80104dec <alltraps>

80105514 <vector85>:
80105514:	6a 00                	push   $0x0
80105516:	6a 55                	push   $0x55
80105518:	e9 cf f8 ff ff       	jmp    80104dec <alltraps>

8010551d <vector86>:
8010551d:	6a 00                	push   $0x0
8010551f:	6a 56                	push   $0x56
80105521:	e9 c6 f8 ff ff       	jmp    80104dec <alltraps>

80105526 <vector87>:
80105526:	6a 00                	push   $0x0
80105528:	6a 57                	push   $0x57
8010552a:	e9 bd f8 ff ff       	jmp    80104dec <alltraps>

8010552f <vector88>:
8010552f:	6a 00                	push   $0x0
80105531:	6a 58                	push   $0x58
80105533:	e9 b4 f8 ff ff       	jmp    80104dec <alltraps>

80105538 <vector89>:
80105538:	6a 00                	push   $0x0
8010553a:	6a 59                	push   $0x59
8010553c:	e9 ab f8 ff ff       	jmp    80104dec <alltraps>

80105541 <vector90>:
80105541:	6a 00                	push   $0x0
80105543:	6a 5a                	push   $0x5a
80105545:	e9 a2 f8 ff ff       	jmp    80104dec <alltraps>

8010554a <vector91>:
8010554a:	6a 00                	push   $0x0
8010554c:	6a 5b                	push   $0x5b
8010554e:	e9 99 f8 ff ff       	jmp    80104dec <alltraps>

80105553 <vector92>:
80105553:	6a 00                	push   $0x0
80105555:	6a 5c                	push   $0x5c
80105557:	e9 90 f8 ff ff       	jmp    80104dec <alltraps>

8010555c <vector93>:
8010555c:	6a 00                	push   $0x0
8010555e:	6a 5d                	push   $0x5d
80105560:	e9 87 f8 ff ff       	jmp    80104dec <alltraps>

80105565 <vector94>:
80105565:	6a 00                	push   $0x0
80105567:	6a 5e                	push   $0x5e
80105569:	e9 7e f8 ff ff       	jmp    80104dec <alltraps>

8010556e <vector95>:
8010556e:	6a 00                	push   $0x0
80105570:	6a 5f                	push   $0x5f
80105572:	e9 75 f8 ff ff       	jmp    80104dec <alltraps>

80105577 <vector96>:
80105577:	6a 00                	push   $0x0
80105579:	6a 60                	push   $0x60
8010557b:	e9 6c f8 ff ff       	jmp    80104dec <alltraps>

80105580 <vector97>:
80105580:	6a 00                	push   $0x0
80105582:	6a 61                	push   $0x61
80105584:	e9 63 f8 ff ff       	jmp    80104dec <alltraps>

80105589 <vector98>:
80105589:	6a 00                	push   $0x0
8010558b:	6a 62                	push   $0x62
8010558d:	e9 5a f8 ff ff       	jmp    80104dec <alltraps>

80105592 <vector99>:
80105592:	6a 00                	push   $0x0
80105594:	6a 63                	push   $0x63
80105596:	e9 51 f8 ff ff       	jmp    80104dec <alltraps>

8010559b <vector100>:
8010559b:	6a 00                	push   $0x0
8010559d:	6a 64                	push   $0x64
8010559f:	e9 48 f8 ff ff       	jmp    80104dec <alltraps>

801055a4 <vector101>:
801055a4:	6a 00                	push   $0x0
801055a6:	6a 65                	push   $0x65
801055a8:	e9 3f f8 ff ff       	jmp    80104dec <alltraps>

801055ad <vector102>:
801055ad:	6a 00                	push   $0x0
801055af:	6a 66                	push   $0x66
801055b1:	e9 36 f8 ff ff       	jmp    80104dec <alltraps>

801055b6 <vector103>:
801055b6:	6a 00                	push   $0x0
801055b8:	6a 67                	push   $0x67
801055ba:	e9 2d f8 ff ff       	jmp    80104dec <alltraps>

801055bf <vector104>:
801055bf:	6a 00                	push   $0x0
801055c1:	6a 68                	push   $0x68
801055c3:	e9 24 f8 ff ff       	jmp    80104dec <alltraps>

801055c8 <vector105>:
801055c8:	6a 00                	push   $0x0
801055ca:	6a 69                	push   $0x69
801055cc:	e9 1b f8 ff ff       	jmp    80104dec <alltraps>

801055d1 <vector106>:
801055d1:	6a 00                	push   $0x0
801055d3:	6a 6a                	push   $0x6a
801055d5:	e9 12 f8 ff ff       	jmp    80104dec <alltraps>

801055da <vector107>:
801055da:	6a 00                	push   $0x0
801055dc:	6a 6b                	push   $0x6b
801055de:	e9 09 f8 ff ff       	jmp    80104dec <alltraps>

801055e3 <vector108>:
801055e3:	6a 00                	push   $0x0
801055e5:	6a 6c                	push   $0x6c
801055e7:	e9 00 f8 ff ff       	jmp    80104dec <alltraps>

801055ec <vector109>:
801055ec:	6a 00                	push   $0x0
801055ee:	6a 6d                	push   $0x6d
801055f0:	e9 f7 f7 ff ff       	jmp    80104dec <alltraps>

801055f5 <vector110>:
801055f5:	6a 00                	push   $0x0
801055f7:	6a 6e                	push   $0x6e
801055f9:	e9 ee f7 ff ff       	jmp    80104dec <alltraps>

801055fe <vector111>:
801055fe:	6a 00                	push   $0x0
80105600:	6a 6f                	push   $0x6f
80105602:	e9 e5 f7 ff ff       	jmp    80104dec <alltraps>

80105607 <vector112>:
80105607:	6a 00                	push   $0x0
80105609:	6a 70                	push   $0x70
8010560b:	e9 dc f7 ff ff       	jmp    80104dec <alltraps>

80105610 <vector113>:
80105610:	6a 00                	push   $0x0
80105612:	6a 71                	push   $0x71
80105614:	e9 d3 f7 ff ff       	jmp    80104dec <alltraps>

80105619 <vector114>:
80105619:	6a 00                	push   $0x0
8010561b:	6a 72                	push   $0x72
8010561d:	e9 ca f7 ff ff       	jmp    80104dec <alltraps>

80105622 <vector115>:
80105622:	6a 00                	push   $0x0
80105624:	6a 73                	push   $0x73
80105626:	e9 c1 f7 ff ff       	jmp    80104dec <alltraps>

8010562b <vector116>:
8010562b:	6a 00                	push   $0x0
8010562d:	6a 74                	push   $0x74
8010562f:	e9 b8 f7 ff ff       	jmp    80104dec <alltraps>

80105634 <vector117>:
80105634:	6a 00                	push   $0x0
80105636:	6a 75                	push   $0x75
80105638:	e9 af f7 ff ff       	jmp    80104dec <alltraps>

8010563d <vector118>:
8010563d:	6a 00                	push   $0x0
8010563f:	6a 76                	push   $0x76
80105641:	e9 a6 f7 ff ff       	jmp    80104dec <alltraps>

80105646 <vector119>:
80105646:	6a 00                	push   $0x0
80105648:	6a 77                	push   $0x77
8010564a:	e9 9d f7 ff ff       	jmp    80104dec <alltraps>

8010564f <vector120>:
8010564f:	6a 00                	push   $0x0
80105651:	6a 78                	push   $0x78
80105653:	e9 94 f7 ff ff       	jmp    80104dec <alltraps>

80105658 <vector121>:
80105658:	6a 00                	push   $0x0
8010565a:	6a 79                	push   $0x79
8010565c:	e9 8b f7 ff ff       	jmp    80104dec <alltraps>

80105661 <vector122>:
80105661:	6a 00                	push   $0x0
80105663:	6a 7a                	push   $0x7a
80105665:	e9 82 f7 ff ff       	jmp    80104dec <alltraps>

8010566a <vector123>:
8010566a:	6a 00                	push   $0x0
8010566c:	6a 7b                	push   $0x7b
8010566e:	e9 79 f7 ff ff       	jmp    80104dec <alltraps>

80105673 <vector124>:
80105673:	6a 00                	push   $0x0
80105675:	6a 7c                	push   $0x7c
80105677:	e9 70 f7 ff ff       	jmp    80104dec <alltraps>

8010567c <vector125>:
8010567c:	6a 00                	push   $0x0
8010567e:	6a 7d                	push   $0x7d
80105680:	e9 67 f7 ff ff       	jmp    80104dec <alltraps>

80105685 <vector126>:
80105685:	6a 00                	push   $0x0
80105687:	6a 7e                	push   $0x7e
80105689:	e9 5e f7 ff ff       	jmp    80104dec <alltraps>

8010568e <vector127>:
8010568e:	6a 00                	push   $0x0
80105690:	6a 7f                	push   $0x7f
80105692:	e9 55 f7 ff ff       	jmp    80104dec <alltraps>

80105697 <vector128>:
80105697:	6a 00                	push   $0x0
80105699:	68 80 00 00 00       	push   $0x80
8010569e:	e9 49 f7 ff ff       	jmp    80104dec <alltraps>

801056a3 <vector129>:
801056a3:	6a 00                	push   $0x0
801056a5:	68 81 00 00 00       	push   $0x81
801056aa:	e9 3d f7 ff ff       	jmp    80104dec <alltraps>

801056af <vector130>:
801056af:	6a 00                	push   $0x0
801056b1:	68 82 00 00 00       	push   $0x82
801056b6:	e9 31 f7 ff ff       	jmp    80104dec <alltraps>

801056bb <vector131>:
801056bb:	6a 00                	push   $0x0
801056bd:	68 83 00 00 00       	push   $0x83
801056c2:	e9 25 f7 ff ff       	jmp    80104dec <alltraps>

801056c7 <vector132>:
801056c7:	6a 00                	push   $0x0
801056c9:	68 84 00 00 00       	push   $0x84
801056ce:	e9 19 f7 ff ff       	jmp    80104dec <alltraps>

801056d3 <vector133>:
801056d3:	6a 00                	push   $0x0
801056d5:	68 85 00 00 00       	push   $0x85
801056da:	e9 0d f7 ff ff       	jmp    80104dec <alltraps>

801056df <vector134>:
801056df:	6a 00                	push   $0x0
801056e1:	68 86 00 00 00       	push   $0x86
801056e6:	e9 01 f7 ff ff       	jmp    80104dec <alltraps>

801056eb <vector135>:
801056eb:	6a 00                	push   $0x0
801056ed:	68 87 00 00 00       	push   $0x87
801056f2:	e9 f5 f6 ff ff       	jmp    80104dec <alltraps>

801056f7 <vector136>:
801056f7:	6a 00                	push   $0x0
801056f9:	68 88 00 00 00       	push   $0x88
801056fe:	e9 e9 f6 ff ff       	jmp    80104dec <alltraps>

80105703 <vector137>:
80105703:	6a 00                	push   $0x0
80105705:	68 89 00 00 00       	push   $0x89
8010570a:	e9 dd f6 ff ff       	jmp    80104dec <alltraps>

8010570f <vector138>:
8010570f:	6a 00                	push   $0x0
80105711:	68 8a 00 00 00       	push   $0x8a
80105716:	e9 d1 f6 ff ff       	jmp    80104dec <alltraps>

8010571b <vector139>:
8010571b:	6a 00                	push   $0x0
8010571d:	68 8b 00 00 00       	push   $0x8b
80105722:	e9 c5 f6 ff ff       	jmp    80104dec <alltraps>

80105727 <vector140>:
80105727:	6a 00                	push   $0x0
80105729:	68 8c 00 00 00       	push   $0x8c
8010572e:	e9 b9 f6 ff ff       	jmp    80104dec <alltraps>

80105733 <vector141>:
80105733:	6a 00                	push   $0x0
80105735:	68 8d 00 00 00       	push   $0x8d
8010573a:	e9 ad f6 ff ff       	jmp    80104dec <alltraps>

8010573f <vector142>:
8010573f:	6a 00                	push   $0x0
80105741:	68 8e 00 00 00       	push   $0x8e
80105746:	e9 a1 f6 ff ff       	jmp    80104dec <alltraps>

8010574b <vector143>:
8010574b:	6a 00                	push   $0x0
8010574d:	68 8f 00 00 00       	push   $0x8f
80105752:	e9 95 f6 ff ff       	jmp    80104dec <alltraps>

80105757 <vector144>:
80105757:	6a 00                	push   $0x0
80105759:	68 90 00 00 00       	push   $0x90
8010575e:	e9 89 f6 ff ff       	jmp    80104dec <alltraps>

80105763 <vector145>:
80105763:	6a 00                	push   $0x0
80105765:	68 91 00 00 00       	push   $0x91
8010576a:	e9 7d f6 ff ff       	jmp    80104dec <alltraps>

8010576f <vector146>:
8010576f:	6a 00                	push   $0x0
80105771:	68 92 00 00 00       	push   $0x92
80105776:	e9 71 f6 ff ff       	jmp    80104dec <alltraps>

8010577b <vector147>:
8010577b:	6a 00                	push   $0x0
8010577d:	68 93 00 00 00       	push   $0x93
80105782:	e9 65 f6 ff ff       	jmp    80104dec <alltraps>

80105787 <vector148>:
80105787:	6a 00                	push   $0x0
80105789:	68 94 00 00 00       	push   $0x94
8010578e:	e9 59 f6 ff ff       	jmp    80104dec <alltraps>

80105793 <vector149>:
80105793:	6a 00                	push   $0x0
80105795:	68 95 00 00 00       	push   $0x95
8010579a:	e9 4d f6 ff ff       	jmp    80104dec <alltraps>

8010579f <vector150>:
8010579f:	6a 00                	push   $0x0
801057a1:	68 96 00 00 00       	push   $0x96
801057a6:	e9 41 f6 ff ff       	jmp    80104dec <alltraps>

801057ab <vector151>:
801057ab:	6a 00                	push   $0x0
801057ad:	68 97 00 00 00       	push   $0x97
801057b2:	e9 35 f6 ff ff       	jmp    80104dec <alltraps>

801057b7 <vector152>:
801057b7:	6a 00                	push   $0x0
801057b9:	68 98 00 00 00       	push   $0x98
801057be:	e9 29 f6 ff ff       	jmp    80104dec <alltraps>

801057c3 <vector153>:
801057c3:	6a 00                	push   $0x0
801057c5:	68 99 00 00 00       	push   $0x99
801057ca:	e9 1d f6 ff ff       	jmp    80104dec <alltraps>

801057cf <vector154>:
801057cf:	6a 00                	push   $0x0
801057d1:	68 9a 00 00 00       	push   $0x9a
801057d6:	e9 11 f6 ff ff       	jmp    80104dec <alltraps>

801057db <vector155>:
801057db:	6a 00                	push   $0x0
801057dd:	68 9b 00 00 00       	push   $0x9b
801057e2:	e9 05 f6 ff ff       	jmp    80104dec <alltraps>

801057e7 <vector156>:
801057e7:	6a 00                	push   $0x0
801057e9:	68 9c 00 00 00       	push   $0x9c
801057ee:	e9 f9 f5 ff ff       	jmp    80104dec <alltraps>

801057f3 <vector157>:
801057f3:	6a 00                	push   $0x0
801057f5:	68 9d 00 00 00       	push   $0x9d
801057fa:	e9 ed f5 ff ff       	jmp    80104dec <alltraps>

801057ff <vector158>:
801057ff:	6a 00                	push   $0x0
80105801:	68 9e 00 00 00       	push   $0x9e
80105806:	e9 e1 f5 ff ff       	jmp    80104dec <alltraps>

8010580b <vector159>:
8010580b:	6a 00                	push   $0x0
8010580d:	68 9f 00 00 00       	push   $0x9f
80105812:	e9 d5 f5 ff ff       	jmp    80104dec <alltraps>

80105817 <vector160>:
80105817:	6a 00                	push   $0x0
80105819:	68 a0 00 00 00       	push   $0xa0
8010581e:	e9 c9 f5 ff ff       	jmp    80104dec <alltraps>

80105823 <vector161>:
80105823:	6a 00                	push   $0x0
80105825:	68 a1 00 00 00       	push   $0xa1
8010582a:	e9 bd f5 ff ff       	jmp    80104dec <alltraps>

8010582f <vector162>:
8010582f:	6a 00                	push   $0x0
80105831:	68 a2 00 00 00       	push   $0xa2
80105836:	e9 b1 f5 ff ff       	jmp    80104dec <alltraps>

8010583b <vector163>:
8010583b:	6a 00                	push   $0x0
8010583d:	68 a3 00 00 00       	push   $0xa3
80105842:	e9 a5 f5 ff ff       	jmp    80104dec <alltraps>

80105847 <vector164>:
80105847:	6a 00                	push   $0x0
80105849:	68 a4 00 00 00       	push   $0xa4
8010584e:	e9 99 f5 ff ff       	jmp    80104dec <alltraps>

80105853 <vector165>:
80105853:	6a 00                	push   $0x0
80105855:	68 a5 00 00 00       	push   $0xa5
8010585a:	e9 8d f5 ff ff       	jmp    80104dec <alltraps>

8010585f <vector166>:
8010585f:	6a 00                	push   $0x0
80105861:	68 a6 00 00 00       	push   $0xa6
80105866:	e9 81 f5 ff ff       	jmp    80104dec <alltraps>

8010586b <vector167>:
8010586b:	6a 00                	push   $0x0
8010586d:	68 a7 00 00 00       	push   $0xa7
80105872:	e9 75 f5 ff ff       	jmp    80104dec <alltraps>

80105877 <vector168>:
80105877:	6a 00                	push   $0x0
80105879:	68 a8 00 00 00       	push   $0xa8
8010587e:	e9 69 f5 ff ff       	jmp    80104dec <alltraps>

80105883 <vector169>:
80105883:	6a 00                	push   $0x0
80105885:	68 a9 00 00 00       	push   $0xa9
8010588a:	e9 5d f5 ff ff       	jmp    80104dec <alltraps>

8010588f <vector170>:
8010588f:	6a 00                	push   $0x0
80105891:	68 aa 00 00 00       	push   $0xaa
80105896:	e9 51 f5 ff ff       	jmp    80104dec <alltraps>

8010589b <vector171>:
8010589b:	6a 00                	push   $0x0
8010589d:	68 ab 00 00 00       	push   $0xab
801058a2:	e9 45 f5 ff ff       	jmp    80104dec <alltraps>

801058a7 <vector172>:
801058a7:	6a 00                	push   $0x0
801058a9:	68 ac 00 00 00       	push   $0xac
801058ae:	e9 39 f5 ff ff       	jmp    80104dec <alltraps>

801058b3 <vector173>:
801058b3:	6a 00                	push   $0x0
801058b5:	68 ad 00 00 00       	push   $0xad
801058ba:	e9 2d f5 ff ff       	jmp    80104dec <alltraps>

801058bf <vector174>:
801058bf:	6a 00                	push   $0x0
801058c1:	68 ae 00 00 00       	push   $0xae
801058c6:	e9 21 f5 ff ff       	jmp    80104dec <alltraps>

801058cb <vector175>:
801058cb:	6a 00                	push   $0x0
801058cd:	68 af 00 00 00       	push   $0xaf
801058d2:	e9 15 f5 ff ff       	jmp    80104dec <alltraps>

801058d7 <vector176>:
801058d7:	6a 00                	push   $0x0
801058d9:	68 b0 00 00 00       	push   $0xb0
801058de:	e9 09 f5 ff ff       	jmp    80104dec <alltraps>

801058e3 <vector177>:
801058e3:	6a 00                	push   $0x0
801058e5:	68 b1 00 00 00       	push   $0xb1
801058ea:	e9 fd f4 ff ff       	jmp    80104dec <alltraps>

801058ef <vector178>:
801058ef:	6a 00                	push   $0x0
801058f1:	68 b2 00 00 00       	push   $0xb2
801058f6:	e9 f1 f4 ff ff       	jmp    80104dec <alltraps>

801058fb <vector179>:
801058fb:	6a 00                	push   $0x0
801058fd:	68 b3 00 00 00       	push   $0xb3
80105902:	e9 e5 f4 ff ff       	jmp    80104dec <alltraps>

80105907 <vector180>:
80105907:	6a 00                	push   $0x0
80105909:	68 b4 00 00 00       	push   $0xb4
8010590e:	e9 d9 f4 ff ff       	jmp    80104dec <alltraps>

80105913 <vector181>:
80105913:	6a 00                	push   $0x0
80105915:	68 b5 00 00 00       	push   $0xb5
8010591a:	e9 cd f4 ff ff       	jmp    80104dec <alltraps>

8010591f <vector182>:
8010591f:	6a 00                	push   $0x0
80105921:	68 b6 00 00 00       	push   $0xb6
80105926:	e9 c1 f4 ff ff       	jmp    80104dec <alltraps>

8010592b <vector183>:
8010592b:	6a 00                	push   $0x0
8010592d:	68 b7 00 00 00       	push   $0xb7
80105932:	e9 b5 f4 ff ff       	jmp    80104dec <alltraps>

80105937 <vector184>:
80105937:	6a 00                	push   $0x0
80105939:	68 b8 00 00 00       	push   $0xb8
8010593e:	e9 a9 f4 ff ff       	jmp    80104dec <alltraps>

80105943 <vector185>:
80105943:	6a 00                	push   $0x0
80105945:	68 b9 00 00 00       	push   $0xb9
8010594a:	e9 9d f4 ff ff       	jmp    80104dec <alltraps>

8010594f <vector186>:
8010594f:	6a 00                	push   $0x0
80105951:	68 ba 00 00 00       	push   $0xba
80105956:	e9 91 f4 ff ff       	jmp    80104dec <alltraps>

8010595b <vector187>:
8010595b:	6a 00                	push   $0x0
8010595d:	68 bb 00 00 00       	push   $0xbb
80105962:	e9 85 f4 ff ff       	jmp    80104dec <alltraps>

80105967 <vector188>:
80105967:	6a 00                	push   $0x0
80105969:	68 bc 00 00 00       	push   $0xbc
8010596e:	e9 79 f4 ff ff       	jmp    80104dec <alltraps>

80105973 <vector189>:
80105973:	6a 00                	push   $0x0
80105975:	68 bd 00 00 00       	push   $0xbd
8010597a:	e9 6d f4 ff ff       	jmp    80104dec <alltraps>

8010597f <vector190>:
8010597f:	6a 00                	push   $0x0
80105981:	68 be 00 00 00       	push   $0xbe
80105986:	e9 61 f4 ff ff       	jmp    80104dec <alltraps>

8010598b <vector191>:
8010598b:	6a 00                	push   $0x0
8010598d:	68 bf 00 00 00       	push   $0xbf
80105992:	e9 55 f4 ff ff       	jmp    80104dec <alltraps>

80105997 <vector192>:
80105997:	6a 00                	push   $0x0
80105999:	68 c0 00 00 00       	push   $0xc0
8010599e:	e9 49 f4 ff ff       	jmp    80104dec <alltraps>

801059a3 <vector193>:
801059a3:	6a 00                	push   $0x0
801059a5:	68 c1 00 00 00       	push   $0xc1
801059aa:	e9 3d f4 ff ff       	jmp    80104dec <alltraps>

801059af <vector194>:
801059af:	6a 00                	push   $0x0
801059b1:	68 c2 00 00 00       	push   $0xc2
801059b6:	e9 31 f4 ff ff       	jmp    80104dec <alltraps>

801059bb <vector195>:
801059bb:	6a 00                	push   $0x0
801059bd:	68 c3 00 00 00       	push   $0xc3
801059c2:	e9 25 f4 ff ff       	jmp    80104dec <alltraps>

801059c7 <vector196>:
801059c7:	6a 00                	push   $0x0
801059c9:	68 c4 00 00 00       	push   $0xc4
801059ce:	e9 19 f4 ff ff       	jmp    80104dec <alltraps>

801059d3 <vector197>:
801059d3:	6a 00                	push   $0x0
801059d5:	68 c5 00 00 00       	push   $0xc5
801059da:	e9 0d f4 ff ff       	jmp    80104dec <alltraps>

801059df <vector198>:
801059df:	6a 00                	push   $0x0
801059e1:	68 c6 00 00 00       	push   $0xc6
801059e6:	e9 01 f4 ff ff       	jmp    80104dec <alltraps>

801059eb <vector199>:
801059eb:	6a 00                	push   $0x0
801059ed:	68 c7 00 00 00       	push   $0xc7
801059f2:	e9 f5 f3 ff ff       	jmp    80104dec <alltraps>

801059f7 <vector200>:
801059f7:	6a 00                	push   $0x0
801059f9:	68 c8 00 00 00       	push   $0xc8
801059fe:	e9 e9 f3 ff ff       	jmp    80104dec <alltraps>

80105a03 <vector201>:
80105a03:	6a 00                	push   $0x0
80105a05:	68 c9 00 00 00       	push   $0xc9
80105a0a:	e9 dd f3 ff ff       	jmp    80104dec <alltraps>

80105a0f <vector202>:
80105a0f:	6a 00                	push   $0x0
80105a11:	68 ca 00 00 00       	push   $0xca
80105a16:	e9 d1 f3 ff ff       	jmp    80104dec <alltraps>

80105a1b <vector203>:
80105a1b:	6a 00                	push   $0x0
80105a1d:	68 cb 00 00 00       	push   $0xcb
80105a22:	e9 c5 f3 ff ff       	jmp    80104dec <alltraps>

80105a27 <vector204>:
80105a27:	6a 00                	push   $0x0
80105a29:	68 cc 00 00 00       	push   $0xcc
80105a2e:	e9 b9 f3 ff ff       	jmp    80104dec <alltraps>

80105a33 <vector205>:
80105a33:	6a 00                	push   $0x0
80105a35:	68 cd 00 00 00       	push   $0xcd
80105a3a:	e9 ad f3 ff ff       	jmp    80104dec <alltraps>

80105a3f <vector206>:
80105a3f:	6a 00                	push   $0x0
80105a41:	68 ce 00 00 00       	push   $0xce
80105a46:	e9 a1 f3 ff ff       	jmp    80104dec <alltraps>

80105a4b <vector207>:
80105a4b:	6a 00                	push   $0x0
80105a4d:	68 cf 00 00 00       	push   $0xcf
80105a52:	e9 95 f3 ff ff       	jmp    80104dec <alltraps>

80105a57 <vector208>:
80105a57:	6a 00                	push   $0x0
80105a59:	68 d0 00 00 00       	push   $0xd0
80105a5e:	e9 89 f3 ff ff       	jmp    80104dec <alltraps>

80105a63 <vector209>:
80105a63:	6a 00                	push   $0x0
80105a65:	68 d1 00 00 00       	push   $0xd1
80105a6a:	e9 7d f3 ff ff       	jmp    80104dec <alltraps>

80105a6f <vector210>:
80105a6f:	6a 00                	push   $0x0
80105a71:	68 d2 00 00 00       	push   $0xd2
80105a76:	e9 71 f3 ff ff       	jmp    80104dec <alltraps>

80105a7b <vector211>:
80105a7b:	6a 00                	push   $0x0
80105a7d:	68 d3 00 00 00       	push   $0xd3
80105a82:	e9 65 f3 ff ff       	jmp    80104dec <alltraps>

80105a87 <vector212>:
80105a87:	6a 00                	push   $0x0
80105a89:	68 d4 00 00 00       	push   $0xd4
80105a8e:	e9 59 f3 ff ff       	jmp    80104dec <alltraps>

80105a93 <vector213>:
80105a93:	6a 00                	push   $0x0
80105a95:	68 d5 00 00 00       	push   $0xd5
80105a9a:	e9 4d f3 ff ff       	jmp    80104dec <alltraps>

80105a9f <vector214>:
80105a9f:	6a 00                	push   $0x0
80105aa1:	68 d6 00 00 00       	push   $0xd6
80105aa6:	e9 41 f3 ff ff       	jmp    80104dec <alltraps>

80105aab <vector215>:
80105aab:	6a 00                	push   $0x0
80105aad:	68 d7 00 00 00       	push   $0xd7
80105ab2:	e9 35 f3 ff ff       	jmp    80104dec <alltraps>

80105ab7 <vector216>:
80105ab7:	6a 00                	push   $0x0
80105ab9:	68 d8 00 00 00       	push   $0xd8
80105abe:	e9 29 f3 ff ff       	jmp    80104dec <alltraps>

80105ac3 <vector217>:
80105ac3:	6a 00                	push   $0x0
80105ac5:	68 d9 00 00 00       	push   $0xd9
80105aca:	e9 1d f3 ff ff       	jmp    80104dec <alltraps>

80105acf <vector218>:
80105acf:	6a 00                	push   $0x0
80105ad1:	68 da 00 00 00       	push   $0xda
80105ad6:	e9 11 f3 ff ff       	jmp    80104dec <alltraps>

80105adb <vector219>:
80105adb:	6a 00                	push   $0x0
80105add:	68 db 00 00 00       	push   $0xdb
80105ae2:	e9 05 f3 ff ff       	jmp    80104dec <alltraps>

80105ae7 <vector220>:
80105ae7:	6a 00                	push   $0x0
80105ae9:	68 dc 00 00 00       	push   $0xdc
80105aee:	e9 f9 f2 ff ff       	jmp    80104dec <alltraps>

80105af3 <vector221>:
80105af3:	6a 00                	push   $0x0
80105af5:	68 dd 00 00 00       	push   $0xdd
80105afa:	e9 ed f2 ff ff       	jmp    80104dec <alltraps>

80105aff <vector222>:
80105aff:	6a 00                	push   $0x0
80105b01:	68 de 00 00 00       	push   $0xde
80105b06:	e9 e1 f2 ff ff       	jmp    80104dec <alltraps>

80105b0b <vector223>:
80105b0b:	6a 00                	push   $0x0
80105b0d:	68 df 00 00 00       	push   $0xdf
80105b12:	e9 d5 f2 ff ff       	jmp    80104dec <alltraps>

80105b17 <vector224>:
80105b17:	6a 00                	push   $0x0
80105b19:	68 e0 00 00 00       	push   $0xe0
80105b1e:	e9 c9 f2 ff ff       	jmp    80104dec <alltraps>

80105b23 <vector225>:
80105b23:	6a 00                	push   $0x0
80105b25:	68 e1 00 00 00       	push   $0xe1
80105b2a:	e9 bd f2 ff ff       	jmp    80104dec <alltraps>

80105b2f <vector226>:
80105b2f:	6a 00                	push   $0x0
80105b31:	68 e2 00 00 00       	push   $0xe2
80105b36:	e9 b1 f2 ff ff       	jmp    80104dec <alltraps>

80105b3b <vector227>:
80105b3b:	6a 00                	push   $0x0
80105b3d:	68 e3 00 00 00       	push   $0xe3
80105b42:	e9 a5 f2 ff ff       	jmp    80104dec <alltraps>

80105b47 <vector228>:
80105b47:	6a 00                	push   $0x0
80105b49:	68 e4 00 00 00       	push   $0xe4
80105b4e:	e9 99 f2 ff ff       	jmp    80104dec <alltraps>

80105b53 <vector229>:
80105b53:	6a 00                	push   $0x0
80105b55:	68 e5 00 00 00       	push   $0xe5
80105b5a:	e9 8d f2 ff ff       	jmp    80104dec <alltraps>

80105b5f <vector230>:
80105b5f:	6a 00                	push   $0x0
80105b61:	68 e6 00 00 00       	push   $0xe6
80105b66:	e9 81 f2 ff ff       	jmp    80104dec <alltraps>

80105b6b <vector231>:
80105b6b:	6a 00                	push   $0x0
80105b6d:	68 e7 00 00 00       	push   $0xe7
80105b72:	e9 75 f2 ff ff       	jmp    80104dec <alltraps>

80105b77 <vector232>:
80105b77:	6a 00                	push   $0x0
80105b79:	68 e8 00 00 00       	push   $0xe8
80105b7e:	e9 69 f2 ff ff       	jmp    80104dec <alltraps>

80105b83 <vector233>:
80105b83:	6a 00                	push   $0x0
80105b85:	68 e9 00 00 00       	push   $0xe9
80105b8a:	e9 5d f2 ff ff       	jmp    80104dec <alltraps>

80105b8f <vector234>:
80105b8f:	6a 00                	push   $0x0
80105b91:	68 ea 00 00 00       	push   $0xea
80105b96:	e9 51 f2 ff ff       	jmp    80104dec <alltraps>

80105b9b <vector235>:
80105b9b:	6a 00                	push   $0x0
80105b9d:	68 eb 00 00 00       	push   $0xeb
80105ba2:	e9 45 f2 ff ff       	jmp    80104dec <alltraps>

80105ba7 <vector236>:
80105ba7:	6a 00                	push   $0x0
80105ba9:	68 ec 00 00 00       	push   $0xec
80105bae:	e9 39 f2 ff ff       	jmp    80104dec <alltraps>

80105bb3 <vector237>:
80105bb3:	6a 00                	push   $0x0
80105bb5:	68 ed 00 00 00       	push   $0xed
80105bba:	e9 2d f2 ff ff       	jmp    80104dec <alltraps>

80105bbf <vector238>:
80105bbf:	6a 00                	push   $0x0
80105bc1:	68 ee 00 00 00       	push   $0xee
80105bc6:	e9 21 f2 ff ff       	jmp    80104dec <alltraps>

80105bcb <vector239>:
80105bcb:	6a 00                	push   $0x0
80105bcd:	68 ef 00 00 00       	push   $0xef
80105bd2:	e9 15 f2 ff ff       	jmp    80104dec <alltraps>

80105bd7 <vector240>:
80105bd7:	6a 00                	push   $0x0
80105bd9:	68 f0 00 00 00       	push   $0xf0
80105bde:	e9 09 f2 ff ff       	jmp    80104dec <alltraps>

80105be3 <vector241>:
80105be3:	6a 00                	push   $0x0
80105be5:	68 f1 00 00 00       	push   $0xf1
80105bea:	e9 fd f1 ff ff       	jmp    80104dec <alltraps>

80105bef <vector242>:
80105bef:	6a 00                	push   $0x0
80105bf1:	68 f2 00 00 00       	push   $0xf2
80105bf6:	e9 f1 f1 ff ff       	jmp    80104dec <alltraps>

80105bfb <vector243>:
80105bfb:	6a 00                	push   $0x0
80105bfd:	68 f3 00 00 00       	push   $0xf3
80105c02:	e9 e5 f1 ff ff       	jmp    80104dec <alltraps>

80105c07 <vector244>:
80105c07:	6a 00                	push   $0x0
80105c09:	68 f4 00 00 00       	push   $0xf4
80105c0e:	e9 d9 f1 ff ff       	jmp    80104dec <alltraps>

80105c13 <vector245>:
80105c13:	6a 00                	push   $0x0
80105c15:	68 f5 00 00 00       	push   $0xf5
80105c1a:	e9 cd f1 ff ff       	jmp    80104dec <alltraps>

80105c1f <vector246>:
80105c1f:	6a 00                	push   $0x0
80105c21:	68 f6 00 00 00       	push   $0xf6
80105c26:	e9 c1 f1 ff ff       	jmp    80104dec <alltraps>

80105c2b <vector247>:
80105c2b:	6a 00                	push   $0x0
80105c2d:	68 f7 00 00 00       	push   $0xf7
80105c32:	e9 b5 f1 ff ff       	jmp    80104dec <alltraps>

80105c37 <vector248>:
80105c37:	6a 00                	push   $0x0
80105c39:	68 f8 00 00 00       	push   $0xf8
80105c3e:	e9 a9 f1 ff ff       	jmp    80104dec <alltraps>

80105c43 <vector249>:
80105c43:	6a 00                	push   $0x0
80105c45:	68 f9 00 00 00       	push   $0xf9
80105c4a:	e9 9d f1 ff ff       	jmp    80104dec <alltraps>

80105c4f <vector250>:
80105c4f:	6a 00                	push   $0x0
80105c51:	68 fa 00 00 00       	push   $0xfa
80105c56:	e9 91 f1 ff ff       	jmp    80104dec <alltraps>

80105c5b <vector251>:
80105c5b:	6a 00                	push   $0x0
80105c5d:	68 fb 00 00 00       	push   $0xfb
80105c62:	e9 85 f1 ff ff       	jmp    80104dec <alltraps>

80105c67 <vector252>:
80105c67:	6a 00                	push   $0x0
80105c69:	68 fc 00 00 00       	push   $0xfc
80105c6e:	e9 79 f1 ff ff       	jmp    80104dec <alltraps>

80105c73 <vector253>:
80105c73:	6a 00                	push   $0x0
80105c75:	68 fd 00 00 00       	push   $0xfd
80105c7a:	e9 6d f1 ff ff       	jmp    80104dec <alltraps>

80105c7f <vector254>:
80105c7f:	6a 00                	push   $0x0
80105c81:	68 fe 00 00 00       	push   $0xfe
80105c86:	e9 61 f1 ff ff       	jmp    80104dec <alltraps>

80105c8b <vector255>:
80105c8b:	6a 00                	push   $0x0
80105c8d:	68 ff 00 00 00       	push   $0xff
80105c92:	e9 55 f1 ff ff       	jmp    80104dec <alltraps>

80105c97 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c97:	55                   	push   %ebp
80105c98:	89 e5                	mov    %esp,%ebp
80105c9a:	57                   	push   %edi
80105c9b:	56                   	push   %esi
80105c9c:	53                   	push   %ebx
80105c9d:	83 ec 0c             	sub    $0xc,%esp
80105ca0:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105ca2:	c1 ea 16             	shr    $0x16,%edx
80105ca5:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105ca8:	8b 1f                	mov    (%edi),%ebx
80105caa:	f6 c3 01             	test   $0x1,%bl
80105cad:	74 22                	je     80105cd1 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105caf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105cb5:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105cbb:	c1 ee 0c             	shr    $0xc,%esi
80105cbe:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105cc4:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105cc7:	89 d8                	mov    %ebx,%eax
80105cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ccc:	5b                   	pop    %ebx
80105ccd:	5e                   	pop    %esi
80105cce:	5f                   	pop    %edi
80105ccf:	5d                   	pop    %ebp
80105cd0:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105cd1:	85 c9                	test   %ecx,%ecx
80105cd3:	74 2b                	je     80105d00 <walkpgdir+0x69>
80105cd5:	e8 e1 c3 ff ff       	call   801020bb <kalloc>
80105cda:	89 c3                	mov    %eax,%ebx
80105cdc:	85 c0                	test   %eax,%eax
80105cde:	74 e7                	je     80105cc7 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105ce0:	83 ec 04             	sub    $0x4,%esp
80105ce3:	68 00 10 00 00       	push   $0x1000
80105ce8:	6a 00                	push   $0x0
80105cea:	50                   	push   %eax
80105ceb:	e8 fe df ff ff       	call   80103cee <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105cf0:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105cf6:	83 c8 07             	or     $0x7,%eax
80105cf9:	89 07                	mov    %eax,(%edi)
80105cfb:	83 c4 10             	add    $0x10,%esp
80105cfe:	eb bb                	jmp    80105cbb <walkpgdir+0x24>
      return 0;
80105d00:	bb 00 00 00 00       	mov    $0x0,%ebx
80105d05:	eb c0                	jmp    80105cc7 <walkpgdir+0x30>

80105d07 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105d07:	55                   	push   %ebp
80105d08:	89 e5                	mov    %esp,%ebp
80105d0a:	57                   	push   %edi
80105d0b:	56                   	push   %esi
80105d0c:	53                   	push   %ebx
80105d0d:	83 ec 1c             	sub    $0x1c,%esp
80105d10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105d13:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105d16:	89 d3                	mov    %edx,%ebx
80105d18:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105d1e:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105d22:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d28:	b9 01 00 00 00       	mov    $0x1,%ecx
80105d2d:	89 da                	mov    %ebx,%edx
80105d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d32:	e8 60 ff ff ff       	call   80105c97 <walkpgdir>
80105d37:	85 c0                	test   %eax,%eax
80105d39:	74 2e                	je     80105d69 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105d3b:	f6 00 01             	testb  $0x1,(%eax)
80105d3e:	75 1c                	jne    80105d5c <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105d40:	89 f2                	mov    %esi,%edx
80105d42:	0b 55 0c             	or     0xc(%ebp),%edx
80105d45:	83 ca 01             	or     $0x1,%edx
80105d48:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d4a:	39 fb                	cmp    %edi,%ebx
80105d4c:	74 28                	je     80105d76 <mappages+0x6f>
      break;
    a += PGSIZE;
80105d4e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d54:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d5a:	eb cc                	jmp    80105d28 <mappages+0x21>
      panic("remap");
80105d5c:	83 ec 0c             	sub    $0xc,%esp
80105d5f:	68 0c 6e 10 80       	push   $0x80106e0c
80105d64:	e8 df a5 ff ff       	call   80100348 <panic>
      return -1;
80105d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d71:	5b                   	pop    %ebx
80105d72:	5e                   	pop    %esi
80105d73:	5f                   	pop    %edi
80105d74:	5d                   	pop    %ebp
80105d75:	c3                   	ret    
  return 0;
80105d76:	b8 00 00 00 00       	mov    $0x0,%eax
80105d7b:	eb f1                	jmp    80105d6e <mappages+0x67>

80105d7d <seginit>:
{
80105d7d:	55                   	push   %ebp
80105d7e:	89 e5                	mov    %esp,%ebp
80105d80:	53                   	push   %ebx
80105d81:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105d84:	e8 ff d4 ff ff       	call   80103288 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d89:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105d8f:	66 c7 80 18 18 13 80 	movw   $0xffff,-0x7fece7e8(%eax)
80105d96:	ff ff 
80105d98:	66 c7 80 1a 18 13 80 	movw   $0x0,-0x7fece7e6(%eax)
80105d9f:	00 00 
80105da1:	c6 80 1c 18 13 80 00 	movb   $0x0,-0x7fece7e4(%eax)
80105da8:	0f b6 88 1d 18 13 80 	movzbl -0x7fece7e3(%eax),%ecx
80105daf:	83 e1 f0             	and    $0xfffffff0,%ecx
80105db2:	83 c9 1a             	or     $0x1a,%ecx
80105db5:	83 e1 9f             	and    $0xffffff9f,%ecx
80105db8:	83 c9 80             	or     $0xffffff80,%ecx
80105dbb:	88 88 1d 18 13 80    	mov    %cl,-0x7fece7e3(%eax)
80105dc1:	0f b6 88 1e 18 13 80 	movzbl -0x7fece7e2(%eax),%ecx
80105dc8:	83 c9 0f             	or     $0xf,%ecx
80105dcb:	83 e1 cf             	and    $0xffffffcf,%ecx
80105dce:	83 c9 c0             	or     $0xffffffc0,%ecx
80105dd1:	88 88 1e 18 13 80    	mov    %cl,-0x7fece7e2(%eax)
80105dd7:	c6 80 1f 18 13 80 00 	movb   $0x0,-0x7fece7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105dde:	66 c7 80 20 18 13 80 	movw   $0xffff,-0x7fece7e0(%eax)
80105de5:	ff ff 
80105de7:	66 c7 80 22 18 13 80 	movw   $0x0,-0x7fece7de(%eax)
80105dee:	00 00 
80105df0:	c6 80 24 18 13 80 00 	movb   $0x0,-0x7fece7dc(%eax)
80105df7:	0f b6 88 25 18 13 80 	movzbl -0x7fece7db(%eax),%ecx
80105dfe:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e01:	83 c9 12             	or     $0x12,%ecx
80105e04:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e07:	83 c9 80             	or     $0xffffff80,%ecx
80105e0a:	88 88 25 18 13 80    	mov    %cl,-0x7fece7db(%eax)
80105e10:	0f b6 88 26 18 13 80 	movzbl -0x7fece7da(%eax),%ecx
80105e17:	83 c9 0f             	or     $0xf,%ecx
80105e1a:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e1d:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e20:	88 88 26 18 13 80    	mov    %cl,-0x7fece7da(%eax)
80105e26:	c6 80 27 18 13 80 00 	movb   $0x0,-0x7fece7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105e2d:	66 c7 80 28 18 13 80 	movw   $0xffff,-0x7fece7d8(%eax)
80105e34:	ff ff 
80105e36:	66 c7 80 2a 18 13 80 	movw   $0x0,-0x7fece7d6(%eax)
80105e3d:	00 00 
80105e3f:	c6 80 2c 18 13 80 00 	movb   $0x0,-0x7fece7d4(%eax)
80105e46:	c6 80 2d 18 13 80 fa 	movb   $0xfa,-0x7fece7d3(%eax)
80105e4d:	0f b6 88 2e 18 13 80 	movzbl -0x7fece7d2(%eax),%ecx
80105e54:	83 c9 0f             	or     $0xf,%ecx
80105e57:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e5a:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e5d:	88 88 2e 18 13 80    	mov    %cl,-0x7fece7d2(%eax)
80105e63:	c6 80 2f 18 13 80 00 	movb   $0x0,-0x7fece7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105e6a:	66 c7 80 30 18 13 80 	movw   $0xffff,-0x7fece7d0(%eax)
80105e71:	ff ff 
80105e73:	66 c7 80 32 18 13 80 	movw   $0x0,-0x7fece7ce(%eax)
80105e7a:	00 00 
80105e7c:	c6 80 34 18 13 80 00 	movb   $0x0,-0x7fece7cc(%eax)
80105e83:	c6 80 35 18 13 80 f2 	movb   $0xf2,-0x7fece7cb(%eax)
80105e8a:	0f b6 88 36 18 13 80 	movzbl -0x7fece7ca(%eax),%ecx
80105e91:	83 c9 0f             	or     $0xf,%ecx
80105e94:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e97:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e9a:	88 88 36 18 13 80    	mov    %cl,-0x7fece7ca(%eax)
80105ea0:	c6 80 37 18 13 80 00 	movb   $0x0,-0x7fece7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105ea7:	05 10 18 13 80       	add    $0x80131810,%eax
  pd[0] = size-1;
80105eac:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105eb2:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105eb6:	c1 e8 10             	shr    $0x10,%eax
80105eb9:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105ebd:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105ec0:	0f 01 10             	lgdtl  (%eax)
}
80105ec3:	83 c4 14             	add    $0x14,%esp
80105ec6:	5b                   	pop    %ebx
80105ec7:	5d                   	pop    %ebp
80105ec8:	c3                   	ret    

80105ec9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105ec9:	55                   	push   %ebp
80105eca:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105ecc:	a1 c4 44 13 80       	mov    0x801344c4,%eax
80105ed1:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105ed6:	0f 22 d8             	mov    %eax,%cr3
}
80105ed9:	5d                   	pop    %ebp
80105eda:	c3                   	ret    

80105edb <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105edb:	55                   	push   %ebp
80105edc:	89 e5                	mov    %esp,%ebp
80105ede:	57                   	push   %edi
80105edf:	56                   	push   %esi
80105ee0:	53                   	push   %ebx
80105ee1:	83 ec 1c             	sub    $0x1c,%esp
80105ee4:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ee7:	85 f6                	test   %esi,%esi
80105ee9:	0f 84 dd 00 00 00    	je     80105fcc <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105eef:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105ef3:	0f 84 e0 00 00 00    	je     80105fd9 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105ef9:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105efd:	0f 84 e3 00 00 00    	je     80105fe6 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105f03:	e8 5d dc ff ff       	call   80103b65 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105f08:	e8 1f d3 ff ff       	call   8010322c <mycpu>
80105f0d:	89 c3                	mov    %eax,%ebx
80105f0f:	e8 18 d3 ff ff       	call   8010322c <mycpu>
80105f14:	8d 78 08             	lea    0x8(%eax),%edi
80105f17:	e8 10 d3 ff ff       	call   8010322c <mycpu>
80105f1c:	83 c0 08             	add    $0x8,%eax
80105f1f:	c1 e8 10             	shr    $0x10,%eax
80105f22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f25:	e8 02 d3 ff ff       	call   8010322c <mycpu>
80105f2a:	83 c0 08             	add    $0x8,%eax
80105f2d:	c1 e8 18             	shr    $0x18,%eax
80105f30:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105f37:	67 00 
80105f39:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105f40:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105f44:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105f4a:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105f51:	83 e2 f0             	and    $0xfffffff0,%edx
80105f54:	83 ca 19             	or     $0x19,%edx
80105f57:	83 e2 9f             	and    $0xffffff9f,%edx
80105f5a:	83 ca 80             	or     $0xffffff80,%edx
80105f5d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105f63:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105f6a:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105f70:	e8 b7 d2 ff ff       	call   8010322c <mycpu>
80105f75:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105f7c:	83 e2 ef             	and    $0xffffffef,%edx
80105f7f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105f85:	e8 a2 d2 ff ff       	call   8010322c <mycpu>
80105f8a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105f90:	8b 5e 08             	mov    0x8(%esi),%ebx
80105f93:	e8 94 d2 ff ff       	call   8010322c <mycpu>
80105f98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105f9e:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105fa1:	e8 86 d2 ff ff       	call   8010322c <mycpu>
80105fa6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105fac:	b8 28 00 00 00       	mov    $0x28,%eax
80105fb1:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105fb4:	8b 46 04             	mov    0x4(%esi),%eax
80105fb7:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fbc:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105fbf:	e8 de db ff ff       	call   80103ba2 <popcli>
}
80105fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105fc7:	5b                   	pop    %ebx
80105fc8:	5e                   	pop    %esi
80105fc9:	5f                   	pop    %edi
80105fca:	5d                   	pop    %ebp
80105fcb:	c3                   	ret    
    panic("switchuvm: no process");
80105fcc:	83 ec 0c             	sub    $0xc,%esp
80105fcf:	68 12 6e 10 80       	push   $0x80106e12
80105fd4:	e8 6f a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80105fd9:	83 ec 0c             	sub    $0xc,%esp
80105fdc:	68 28 6e 10 80       	push   $0x80106e28
80105fe1:	e8 62 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80105fe6:	83 ec 0c             	sub    $0xc,%esp
80105fe9:	68 3d 6e 10 80       	push   $0x80106e3d
80105fee:	e8 55 a3 ff ff       	call   80100348 <panic>

80105ff3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105ff3:	55                   	push   %ebp
80105ff4:	89 e5                	mov    %esp,%ebp
80105ff6:	56                   	push   %esi
80105ff7:	53                   	push   %ebx
80105ff8:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105ffb:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106001:	77 4c                	ja     8010604f <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80106003:	e8 b3 c0 ff ff       	call   801020bb <kalloc>
80106008:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010600a:	83 ec 04             	sub    $0x4,%esp
8010600d:	68 00 10 00 00       	push   $0x1000
80106012:	6a 00                	push   $0x0
80106014:	50                   	push   %eax
80106015:	e8 d4 dc ff ff       	call   80103cee <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010601a:	83 c4 08             	add    $0x8,%esp
8010601d:	6a 06                	push   $0x6
8010601f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106025:	50                   	push   %eax
80106026:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010602b:	ba 00 00 00 00       	mov    $0x0,%edx
80106030:	8b 45 08             	mov    0x8(%ebp),%eax
80106033:	e8 cf fc ff ff       	call   80105d07 <mappages>
  memmove(mem, init, sz);
80106038:	83 c4 0c             	add    $0xc,%esp
8010603b:	56                   	push   %esi
8010603c:	ff 75 0c             	pushl  0xc(%ebp)
8010603f:	53                   	push   %ebx
80106040:	e8 24 dd ff ff       	call   80103d69 <memmove>
}
80106045:	83 c4 10             	add    $0x10,%esp
80106048:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010604b:	5b                   	pop    %ebx
8010604c:	5e                   	pop    %esi
8010604d:	5d                   	pop    %ebp
8010604e:	c3                   	ret    
    panic("inituvm: more than a page");
8010604f:	83 ec 0c             	sub    $0xc,%esp
80106052:	68 51 6e 10 80       	push   $0x80106e51
80106057:	e8 ec a2 ff ff       	call   80100348 <panic>

8010605c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010605c:	55                   	push   %ebp
8010605d:	89 e5                	mov    %esp,%ebp
8010605f:	57                   	push   %edi
80106060:	56                   	push   %esi
80106061:	53                   	push   %ebx
80106062:	83 ec 0c             	sub    $0xc,%esp
80106065:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106068:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010606f:	75 07                	jne    80106078 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106071:	bb 00 00 00 00       	mov    $0x0,%ebx
80106076:	eb 3c                	jmp    801060b4 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106078:	83 ec 0c             	sub    $0xc,%esp
8010607b:	68 0c 6f 10 80       	push   $0x80106f0c
80106080:	e8 c3 a2 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106085:	83 ec 0c             	sub    $0xc,%esp
80106088:	68 6b 6e 10 80       	push   $0x80106e6b
8010608d:	e8 b6 a2 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106092:	05 00 00 00 80       	add    $0x80000000,%eax
80106097:	56                   	push   %esi
80106098:	89 da                	mov    %ebx,%edx
8010609a:	03 55 14             	add    0x14(%ebp),%edx
8010609d:	52                   	push   %edx
8010609e:	50                   	push   %eax
8010609f:	ff 75 10             	pushl  0x10(%ebp)
801060a2:	e8 cc b6 ff ff       	call   80101773 <readi>
801060a7:	83 c4 10             	add    $0x10,%esp
801060aa:	39 f0                	cmp    %esi,%eax
801060ac:	75 47                	jne    801060f5 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801060ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060b4:	39 fb                	cmp    %edi,%ebx
801060b6:	73 30                	jae    801060e8 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801060b8:	89 da                	mov    %ebx,%edx
801060ba:	03 55 0c             	add    0xc(%ebp),%edx
801060bd:	b9 00 00 00 00       	mov    $0x0,%ecx
801060c2:	8b 45 08             	mov    0x8(%ebp),%eax
801060c5:	e8 cd fb ff ff       	call   80105c97 <walkpgdir>
801060ca:	85 c0                	test   %eax,%eax
801060cc:	74 b7                	je     80106085 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801060ce:	8b 00                	mov    (%eax),%eax
801060d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801060d5:	89 fe                	mov    %edi,%esi
801060d7:	29 de                	sub    %ebx,%esi
801060d9:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060df:	76 b1                	jbe    80106092 <loaduvm+0x36>
      n = PGSIZE;
801060e1:	be 00 10 00 00       	mov    $0x1000,%esi
801060e6:	eb aa                	jmp    80106092 <loaduvm+0x36>
      return -1;
  }
  return 0;
801060e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060f0:	5b                   	pop    %ebx
801060f1:	5e                   	pop    %esi
801060f2:	5f                   	pop    %edi
801060f3:	5d                   	pop    %ebp
801060f4:	c3                   	ret    
      return -1;
801060f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060fa:	eb f1                	jmp    801060ed <loaduvm+0x91>

801060fc <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801060fc:	55                   	push   %ebp
801060fd:	89 e5                	mov    %esp,%ebp
801060ff:	57                   	push   %edi
80106100:	56                   	push   %esi
80106101:	53                   	push   %ebx
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106108:	39 7d 10             	cmp    %edi,0x10(%ebp)
8010610b:	73 11                	jae    8010611e <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010610d:	8b 45 10             	mov    0x10(%ebp),%eax
80106110:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106116:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010611c:	eb 19                	jmp    80106137 <deallocuvm+0x3b>
    return oldsz;
8010611e:	89 f8                	mov    %edi,%eax
80106120:	eb 64                	jmp    80106186 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106122:	c1 eb 16             	shr    $0x16,%ebx
80106125:	83 c3 01             	add    $0x1,%ebx
80106128:	c1 e3 16             	shl    $0x16,%ebx
8010612b:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106131:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106137:	39 fb                	cmp    %edi,%ebx
80106139:	73 48                	jae    80106183 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010613b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106140:	89 da                	mov    %ebx,%edx
80106142:	8b 45 08             	mov    0x8(%ebp),%eax
80106145:	e8 4d fb ff ff       	call   80105c97 <walkpgdir>
8010614a:	89 c6                	mov    %eax,%esi
    if(!pte)
8010614c:	85 c0                	test   %eax,%eax
8010614e:	74 d2                	je     80106122 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106150:	8b 00                	mov    (%eax),%eax
80106152:	a8 01                	test   $0x1,%al
80106154:	74 db                	je     80106131 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106156:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010615b:	74 19                	je     80106176 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010615d:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106162:	83 ec 0c             	sub    $0xc,%esp
80106165:	50                   	push   %eax
80106166:	e8 39 be ff ff       	call   80101fa4 <kfree>
      *pte = 0;
8010616b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106171:	83 c4 10             	add    $0x10,%esp
80106174:	eb bb                	jmp    80106131 <deallocuvm+0x35>
        panic("kfree");
80106176:	83 ec 0c             	sub    $0xc,%esp
80106179:	68 a6 67 10 80       	push   $0x801067a6
8010617e:	e8 c5 a1 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106183:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106186:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106189:	5b                   	pop    %ebx
8010618a:	5e                   	pop    %esi
8010618b:	5f                   	pop    %edi
8010618c:	5d                   	pop    %ebp
8010618d:	c3                   	ret    

8010618e <allocuvm>:
{
8010618e:	55                   	push   %ebp
8010618f:	89 e5                	mov    %esp,%ebp
80106191:	57                   	push   %edi
80106192:	56                   	push   %esi
80106193:	53                   	push   %ebx
80106194:	83 ec 1c             	sub    $0x1c,%esp
80106197:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010619a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010619d:	85 ff                	test   %edi,%edi
8010619f:	0f 88 c1 00 00 00    	js     80106266 <allocuvm+0xd8>
  if(newsz < oldsz)
801061a5:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801061a8:	72 5c                	jb     80106206 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
801061aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ad:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801061b3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801061b9:	39 fb                	cmp    %edi,%ebx
801061bb:	0f 83 ac 00 00 00    	jae    8010626d <allocuvm+0xdf>
    mem = kalloc();
801061c1:	e8 f5 be ff ff       	call   801020bb <kalloc>
801061c6:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801061c8:	85 c0                	test   %eax,%eax
801061ca:	74 42                	je     8010620e <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
801061cc:	83 ec 04             	sub    $0x4,%esp
801061cf:	68 00 10 00 00       	push   $0x1000
801061d4:	6a 00                	push   $0x0
801061d6:	50                   	push   %eax
801061d7:	e8 12 db ff ff       	call   80103cee <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801061dc:	83 c4 08             	add    $0x8,%esp
801061df:	6a 06                	push   $0x6
801061e1:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801061e7:	50                   	push   %eax
801061e8:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061ed:	89 da                	mov    %ebx,%edx
801061ef:	8b 45 08             	mov    0x8(%ebp),%eax
801061f2:	e8 10 fb ff ff       	call   80105d07 <mappages>
801061f7:	83 c4 10             	add    $0x10,%esp
801061fa:	85 c0                	test   %eax,%eax
801061fc:	78 38                	js     80106236 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801061fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106204:	eb b3                	jmp    801061b9 <allocuvm+0x2b>
    return oldsz;
80106206:	8b 45 0c             	mov    0xc(%ebp),%eax
80106209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010620c:	eb 5f                	jmp    8010626d <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
8010620e:	83 ec 0c             	sub    $0xc,%esp
80106211:	68 89 6e 10 80       	push   $0x80106e89
80106216:	e8 f0 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010621b:	83 c4 0c             	add    $0xc,%esp
8010621e:	ff 75 0c             	pushl  0xc(%ebp)
80106221:	57                   	push   %edi
80106222:	ff 75 08             	pushl  0x8(%ebp)
80106225:	e8 d2 fe ff ff       	call   801060fc <deallocuvm>
      return 0;
8010622a:	83 c4 10             	add    $0x10,%esp
8010622d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106234:	eb 37                	jmp    8010626d <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106236:	83 ec 0c             	sub    $0xc,%esp
80106239:	68 a1 6e 10 80       	push   $0x80106ea1
8010623e:	e8 c8 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106243:	83 c4 0c             	add    $0xc,%esp
80106246:	ff 75 0c             	pushl  0xc(%ebp)
80106249:	57                   	push   %edi
8010624a:	ff 75 08             	pushl  0x8(%ebp)
8010624d:	e8 aa fe ff ff       	call   801060fc <deallocuvm>
      kfree(mem);
80106252:	89 34 24             	mov    %esi,(%esp)
80106255:	e8 4a bd ff ff       	call   80101fa4 <kfree>
      return 0;
8010625a:	83 c4 10             	add    $0x10,%esp
8010625d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106264:	eb 07                	jmp    8010626d <allocuvm+0xdf>
    return 0;
80106266:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010626d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106270:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106273:	5b                   	pop    %ebx
80106274:	5e                   	pop    %esi
80106275:	5f                   	pop    %edi
80106276:	5d                   	pop    %ebp
80106277:	c3                   	ret    

80106278 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106278:	55                   	push   %ebp
80106279:	89 e5                	mov    %esp,%ebp
8010627b:	56                   	push   %esi
8010627c:	53                   	push   %ebx
8010627d:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106280:	85 f6                	test   %esi,%esi
80106282:	74 1a                	je     8010629e <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106284:	83 ec 04             	sub    $0x4,%esp
80106287:	6a 00                	push   $0x0
80106289:	68 00 00 00 80       	push   $0x80000000
8010628e:	56                   	push   %esi
8010628f:	e8 68 fe ff ff       	call   801060fc <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106294:	83 c4 10             	add    $0x10,%esp
80106297:	bb 00 00 00 00       	mov    $0x0,%ebx
8010629c:	eb 10                	jmp    801062ae <freevm+0x36>
    panic("freevm: no pgdir");
8010629e:	83 ec 0c             	sub    $0xc,%esp
801062a1:	68 bd 6e 10 80       	push   $0x80106ebd
801062a6:	e8 9d a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801062ab:	83 c3 01             	add    $0x1,%ebx
801062ae:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801062b4:	77 1f                	ja     801062d5 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801062b6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801062b9:	a8 01                	test   $0x1,%al
801062bb:	74 ee                	je     801062ab <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801062bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801062c2:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801062c7:	83 ec 0c             	sub    $0xc,%esp
801062ca:	50                   	push   %eax
801062cb:	e8 d4 bc ff ff       	call   80101fa4 <kfree>
801062d0:	83 c4 10             	add    $0x10,%esp
801062d3:	eb d6                	jmp    801062ab <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801062d5:	83 ec 0c             	sub    $0xc,%esp
801062d8:	56                   	push   %esi
801062d9:	e8 c6 bc ff ff       	call   80101fa4 <kfree>
}
801062de:	83 c4 10             	add    $0x10,%esp
801062e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801062e4:	5b                   	pop    %ebx
801062e5:	5e                   	pop    %esi
801062e6:	5d                   	pop    %ebp
801062e7:	c3                   	ret    

801062e8 <setupkvm>:
{
801062e8:	55                   	push   %ebp
801062e9:	89 e5                	mov    %esp,%ebp
801062eb:	56                   	push   %esi
801062ec:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801062ed:	e8 c9 bd ff ff       	call   801020bb <kalloc>
801062f2:	89 c6                	mov    %eax,%esi
801062f4:	85 c0                	test   %eax,%eax
801062f6:	74 55                	je     8010634d <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801062f8:	83 ec 04             	sub    $0x4,%esp
801062fb:	68 00 10 00 00       	push   $0x1000
80106300:	6a 00                	push   $0x0
80106302:	50                   	push   %eax
80106303:	e8 e6 d9 ff ff       	call   80103cee <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106308:	83 c4 10             	add    $0x10,%esp
8010630b:	bb 20 94 12 80       	mov    $0x80129420,%ebx
80106310:	81 fb 60 94 12 80    	cmp    $0x80129460,%ebx
80106316:	73 35                	jae    8010634d <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106318:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010631b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010631e:	29 c1                	sub    %eax,%ecx
80106320:	83 ec 08             	sub    $0x8,%esp
80106323:	ff 73 0c             	pushl  0xc(%ebx)
80106326:	50                   	push   %eax
80106327:	8b 13                	mov    (%ebx),%edx
80106329:	89 f0                	mov    %esi,%eax
8010632b:	e8 d7 f9 ff ff       	call   80105d07 <mappages>
80106330:	83 c4 10             	add    $0x10,%esp
80106333:	85 c0                	test   %eax,%eax
80106335:	78 05                	js     8010633c <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106337:	83 c3 10             	add    $0x10,%ebx
8010633a:	eb d4                	jmp    80106310 <setupkvm+0x28>
      freevm(pgdir);
8010633c:	83 ec 0c             	sub    $0xc,%esp
8010633f:	56                   	push   %esi
80106340:	e8 33 ff ff ff       	call   80106278 <freevm>
      return 0;
80106345:	83 c4 10             	add    $0x10,%esp
80106348:	be 00 00 00 00       	mov    $0x0,%esi
}
8010634d:	89 f0                	mov    %esi,%eax
8010634f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106352:	5b                   	pop    %ebx
80106353:	5e                   	pop    %esi
80106354:	5d                   	pop    %ebp
80106355:	c3                   	ret    

80106356 <kvmalloc>:
{
80106356:	55                   	push   %ebp
80106357:	89 e5                	mov    %esp,%ebp
80106359:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010635c:	e8 87 ff ff ff       	call   801062e8 <setupkvm>
80106361:	a3 c4 44 13 80       	mov    %eax,0x801344c4
  switchkvm();
80106366:	e8 5e fb ff ff       	call   80105ec9 <switchkvm>
}
8010636b:	c9                   	leave  
8010636c:	c3                   	ret    

8010636d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010636d:	55                   	push   %ebp
8010636e:	89 e5                	mov    %esp,%ebp
80106370:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106373:	b9 00 00 00 00       	mov    $0x0,%ecx
80106378:	8b 55 0c             	mov    0xc(%ebp),%edx
8010637b:	8b 45 08             	mov    0x8(%ebp),%eax
8010637e:	e8 14 f9 ff ff       	call   80105c97 <walkpgdir>
  if(pte == 0)
80106383:	85 c0                	test   %eax,%eax
80106385:	74 05                	je     8010638c <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106387:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010638a:	c9                   	leave  
8010638b:	c3                   	ret    
    panic("clearpteu");
8010638c:	83 ec 0c             	sub    $0xc,%esp
8010638f:	68 ce 6e 10 80       	push   $0x80106ece
80106394:	e8 af 9f ff ff       	call   80100348 <panic>

80106399 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106399:	55                   	push   %ebp
8010639a:	89 e5                	mov    %esp,%ebp
8010639c:	57                   	push   %edi
8010639d:	56                   	push   %esi
8010639e:	53                   	push   %ebx
8010639f:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801063a2:	e8 41 ff ff ff       	call   801062e8 <setupkvm>
801063a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
801063aa:	85 c0                	test   %eax,%eax
801063ac:	0f 84 c4 00 00 00    	je     80106476 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801063b2:	bf 00 00 00 00       	mov    $0x0,%edi
801063b7:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063ba:	0f 83 b6 00 00 00    	jae    80106476 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801063c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801063c3:	b9 00 00 00 00       	mov    $0x0,%ecx
801063c8:	89 fa                	mov    %edi,%edx
801063ca:	8b 45 08             	mov    0x8(%ebp),%eax
801063cd:	e8 c5 f8 ff ff       	call   80105c97 <walkpgdir>
801063d2:	85 c0                	test   %eax,%eax
801063d4:	74 65                	je     8010643b <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801063d6:	8b 00                	mov    (%eax),%eax
801063d8:	a8 01                	test   $0x1,%al
801063da:	74 6c                	je     80106448 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801063dc:	89 c6                	mov    %eax,%esi
801063de:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801063e4:	25 ff 0f 00 00       	and    $0xfff,%eax
801063e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801063ec:	e8 ca bc ff ff       	call   801020bb <kalloc>
801063f1:	89 c3                	mov    %eax,%ebx
801063f3:	85 c0                	test   %eax,%eax
801063f5:	74 6a                	je     80106461 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801063f7:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801063fd:	83 ec 04             	sub    $0x4,%esp
80106400:	68 00 10 00 00       	push   $0x1000
80106405:	56                   	push   %esi
80106406:	50                   	push   %eax
80106407:	e8 5d d9 ff ff       	call   80103d69 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010640c:	83 c4 08             	add    $0x8,%esp
8010640f:	ff 75 e0             	pushl  -0x20(%ebp)
80106412:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106418:	50                   	push   %eax
80106419:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010641e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106421:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106424:	e8 de f8 ff ff       	call   80105d07 <mappages>
80106429:	83 c4 10             	add    $0x10,%esp
8010642c:	85 c0                	test   %eax,%eax
8010642e:	78 25                	js     80106455 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106430:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106436:	e9 7c ff ff ff       	jmp    801063b7 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
8010643b:	83 ec 0c             	sub    $0xc,%esp
8010643e:	68 d8 6e 10 80       	push   $0x80106ed8
80106443:	e8 00 9f ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106448:	83 ec 0c             	sub    $0xc,%esp
8010644b:	68 f2 6e 10 80       	push   $0x80106ef2
80106450:	e8 f3 9e ff ff       	call   80100348 <panic>
      kfree(mem);
80106455:	83 ec 0c             	sub    $0xc,%esp
80106458:	53                   	push   %ebx
80106459:	e8 46 bb ff ff       	call   80101fa4 <kfree>
      goto bad;
8010645e:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106461:	83 ec 0c             	sub    $0xc,%esp
80106464:	ff 75 dc             	pushl  -0x24(%ebp)
80106467:	e8 0c fe ff ff       	call   80106278 <freevm>
  return 0;
8010646c:	83 c4 10             	add    $0x10,%esp
8010646f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106476:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106479:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010647c:	5b                   	pop    %ebx
8010647d:	5e                   	pop    %esi
8010647e:	5f                   	pop    %edi
8010647f:	5d                   	pop    %ebp
80106480:	c3                   	ret    

80106481 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106481:	55                   	push   %ebp
80106482:	89 e5                	mov    %esp,%ebp
80106484:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106487:	b9 00 00 00 00       	mov    $0x0,%ecx
8010648c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010648f:	8b 45 08             	mov    0x8(%ebp),%eax
80106492:	e8 00 f8 ff ff       	call   80105c97 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106497:	8b 00                	mov    (%eax),%eax
80106499:	a8 01                	test   $0x1,%al
8010649b:	74 10                	je     801064ad <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010649d:	a8 04                	test   $0x4,%al
8010649f:	74 13                	je     801064b4 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801064a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064a6:	05 00 00 00 80       	add    $0x80000000,%eax
}
801064ab:	c9                   	leave  
801064ac:	c3                   	ret    
    return 0;
801064ad:	b8 00 00 00 00       	mov    $0x0,%eax
801064b2:	eb f7                	jmp    801064ab <uva2ka+0x2a>
    return 0;
801064b4:	b8 00 00 00 00       	mov    $0x0,%eax
801064b9:	eb f0                	jmp    801064ab <uva2ka+0x2a>

801064bb <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801064bb:	55                   	push   %ebp
801064bc:	89 e5                	mov    %esp,%ebp
801064be:	57                   	push   %edi
801064bf:	56                   	push   %esi
801064c0:	53                   	push   %ebx
801064c1:	83 ec 0c             	sub    $0xc,%esp
801064c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801064c7:	eb 25                	jmp    801064ee <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801064c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801064cc:	29 f2                	sub    %esi,%edx
801064ce:	01 d0                	add    %edx,%eax
801064d0:	83 ec 04             	sub    $0x4,%esp
801064d3:	53                   	push   %ebx
801064d4:	ff 75 10             	pushl  0x10(%ebp)
801064d7:	50                   	push   %eax
801064d8:	e8 8c d8 ff ff       	call   80103d69 <memmove>
    len -= n;
801064dd:	29 df                	sub    %ebx,%edi
    buf += n;
801064df:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801064e2:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801064e8:	89 45 0c             	mov    %eax,0xc(%ebp)
801064eb:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801064ee:	85 ff                	test   %edi,%edi
801064f0:	74 2f                	je     80106521 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801064f2:	8b 75 0c             	mov    0xc(%ebp),%esi
801064f5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801064fb:	83 ec 08             	sub    $0x8,%esp
801064fe:	56                   	push   %esi
801064ff:	ff 75 08             	pushl  0x8(%ebp)
80106502:	e8 7a ff ff ff       	call   80106481 <uva2ka>
    if(pa0 == 0)
80106507:	83 c4 10             	add    $0x10,%esp
8010650a:	85 c0                	test   %eax,%eax
8010650c:	74 20                	je     8010652e <copyout+0x73>
    n = PGSIZE - (va - va0);
8010650e:	89 f3                	mov    %esi,%ebx
80106510:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106513:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106519:	39 df                	cmp    %ebx,%edi
8010651b:	73 ac                	jae    801064c9 <copyout+0xe>
      n = len;
8010651d:	89 fb                	mov    %edi,%ebx
8010651f:	eb a8                	jmp    801064c9 <copyout+0xe>
  }
  return 0;
80106521:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106526:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106529:	5b                   	pop    %ebx
8010652a:	5e                   	pop    %esi
8010652b:	5f                   	pop    %edi
8010652c:	5d                   	pop    %ebp
8010652d:	c3                   	ret    
      return -1;
8010652e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106533:	eb f1                	jmp    80106526 <copyout+0x6b>

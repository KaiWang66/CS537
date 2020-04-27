
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
80100015:	b8 00 80 10 00       	mov    $0x108000,%eax
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
80100028:	bc d0 a5 12 80       	mov    $0x8012a5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 75 2a 10 80       	mov    $0x80102a75,%eax
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
80100041:	68 e0 a5 12 80       	push   $0x8012a5e0
80100046:	e8 ed 3b 00 00       	call   80103c38 <acquire>

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
8010007c:	e8 1c 3c 00 00       	call   80103c9d <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 98 39 00 00       	call   80103a24 <acquiresleep>
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
801000ca:	e8 ce 3b 00 00       	call   80103c9d <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 4a 39 00 00       	call   80103a24 <acquiresleep>
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
80100105:	e8 f2 39 00 00       	call   80103afc <initlock>
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
80100143:	e8 a9 38 00 00       	call   801039f1 <initsleeplock>
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
801001a8:	e8 01 39 00 00       	call   80103aae <holdingsleep>
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
801001e4:	e8 c5 38 00 00       	call   80103aae <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 7a 38 00 00       	call   80103a73 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 a5 12 80 	movl   $0x8012a5e0,(%esp)
80100200:	e8 33 3a 00 00       	call   80103c38 <acquire>
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
8010024c:	e8 4c 3a 00 00       	call   80103c9d <release>
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
8010028a:	e8 a9 39 00 00       	call   80103c38 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ef 12 80       	mov    0x8012efc0,%eax
8010029f:	3b 05 c4 ef 12 80    	cmp    0x8012efc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 8e 2f 00 00       	call   8010323a <myproc>
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
801002bf:	e8 1a 34 00 00       	call   801036de <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 12 80       	push   $0x80129520
801002d1:	e8 c7 39 00 00       	call   80103c9d <release>
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
80100331:	e8 67 39 00 00       	call   80103c9d <release>
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
8010035a:	e8 30 20 00 00       	call   8010238f <lapicid>
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
8010038f:	e8 83 37 00 00       	call   80103b17 <getcallerpcs>
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
801004ba:	e8 a0 38 00 00       	call   80103d5f <memmove>
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
801004d9:	e8 06 38 00 00       	call   80103ce4 <memset>
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
80100506:	e8 13 4c 00 00       	call   8010511e <uartputc>
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
8010051f:	e8 fa 4b 00 00       	call   8010511e <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 ee 4b 00 00       	call   8010511e <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 e2 4b 00 00       	call   8010511e <uartputc>
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
801005ca:	e8 69 36 00 00       	call   80103c38 <acquire>
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
801005f1:	e8 a7 36 00 00       	call   80103c9d <release>
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
80100638:	e8 fb 35 00 00       	call   80103c38 <acquire>
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
80100734:	e8 64 35 00 00       	call   80103c9d <release>
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
8010074f:	e8 e4 34 00 00       	call   80103c38 <acquire>
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
801007de:	e8 60 30 00 00       	call   80103843 <wakeup>
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
80100873:	e8 25 34 00 00       	call   80103c9d <release>
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
80100887:	e8 54 30 00 00       	call   801038e0 <procdump>
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
8010089e:	e8 59 32 00 00       	call   80103afc <initlock>

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
801008de:	e8 57 29 00 00       	call   8010323a <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 d1 1e 00 00       	call   801027bf <begin_op>

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
80100935:	e8 ff 1e 00 00       	call   80102839 <end_op>
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
8010094a:	e8 ea 1e 00 00       	call   80102839 <end_op>
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
80100972:	e8 67 59 00 00       	call   801062de <setupkvm>
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
80100a06:	e8 79 57 00 00       	call   80106184 <allocuvm>
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
80100a38:	e8 15 56 00 00       	call   80106052 <loaduvm>
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
80100a53:	e8 e1 1d 00 00       	call   80102839 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 0b 57 00 00       	call   80106184 <allocuvm>
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
80100a9d:	e8 cc 57 00 00       	call   8010626e <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 a2 58 00 00       	call   80106363 <clearpteu>
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
80100ae2:	e8 9f 33 00 00       	call   80103e86 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 8d 33 00 00       	call   80103e86 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 a6 59 00 00       	call   801064b1 <copyout>
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
80100b66:	e8 46 59 00 00       	call   801064b1 <copyout>
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
80100ba3:	e8 a3 32 00 00       	call   80103e4b <safestrcpy>
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
80100bd1:	e8 fb 52 00 00       	call   80105ed1 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 90 56 00 00       	call   8010626e <freevm>
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
80100c23:	e8 d4 2e 00 00       	call   80103afc <initlock>
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
80100c39:	e8 fa 2f 00 00       	call   80103c38 <acquire>
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
80100c68:	e8 30 30 00 00       	call   80103c9d <release>
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
80100c7f:	e8 19 30 00 00       	call   80103c9d <release>
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
80100c9d:	e8 96 2f 00 00       	call   80103c38 <acquire>
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
80100cba:	e8 de 2f 00 00       	call   80103c9d <release>
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
80100ce2:	e8 51 2f 00 00       	call   80103c38 <acquire>
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
80100d03:	e8 95 2f 00 00       	call   80103c9d <release>
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
80100d49:	e8 4f 2f 00 00       	call   80103c9d <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 5c 1a 00 00       	call   801027bf <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 c6 1a 00 00       	call   80102839 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 ab 20 00 00       	call   80102e33 <pipeclose>
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
80100e3c:	e8 4a 21 00 00       	call   80102f8b <piperead>
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
80100e95:	e8 25 20 00 00       	call   80102ebf <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 18 19 00 00       	call   801027bf <begin_op>
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
80100edd:	e8 57 19 00 00       	call   80102839 <end_op>

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
80100f8a:	e8 d0 2d 00 00       	call   80103d5f <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 c0 2d 00 00       	call   80103d5f <memmove>
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
80100fdf:	e8 00 2d 00 00       	call   80103ce4 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 fc 18 00 00       	call   801028e8 <log_write>
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
801010bf:	e8 24 18 00 00       	call   801028e8 <log_write>
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
80101170:	e8 73 17 00 00       	call   801028e8 <log_write>
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
8010119a:	e8 99 2a 00 00       	call   80103c38 <acquire>
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
801011e1:	e8 b7 2a 00 00       	call   80103c9d <release>
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
80101217:	e8 81 2a 00 00       	call   80103c9d <release>
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
80101255:	e8 05 2b 00 00       	call   80103d5f <memmove>
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
801012c8:	e8 1b 16 00 00       	call   801028e8 <log_write>
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
801012fd:	e8 fa 27 00 00       	call   80103afc <initlock>
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
80101322:	e8 ca 26 00 00       	call   801039f1 <initsleeplock>
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
801013f1:	e8 ee 28 00 00       	call   80103ce4 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 e3 14 00 00       	call   801028e8 <log_write>
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
80101480:	e8 da 28 00 00       	call   80103d5f <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 5b 14 00 00       	call   801028e8 <log_write>
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
80101560:	e8 d3 26 00 00       	call   80103c38 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
80101575:	e8 23 27 00 00       	call   80103c9d <release>
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
8010159a:	e8 85 24 00 00       	call   80103a24 <acquiresleep>
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
80101614:	e8 46 27 00 00       	call   80103d5f <memmove>
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
80101656:	e8 53 24 00 00       	call   80103aae <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 02 24 00 00       	call   80103a73 <releasesleep>
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
80101698:	e8 87 23 00 00       	call   80103a24 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 bd 23 00 00       	call   80103a73 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016bd:	e8 76 25 00 00       	call   80103c38 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016d2:	e8 c6 25 00 00       	call   80103c9d <release>
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
801016ea:	e8 49 25 00 00       	call   80103c38 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 fa 12 80 	movl   $0x8012fa00,(%esp)
801016f9:	e8 9f 25 00 00       	call   80103c9d <release>
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
8010182a:	e8 30 25 00 00       	call   80103d5f <memmove>
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
80101926:	e8 34 24 00 00       	call   80103d5f <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 b5 0f 00 00       	call   801028e8 <log_write>
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
801019a9:	e8 18 24 00 00       	call   80103dc6 <strncmp>
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
80101a5a:	e8 db 17 00 00       	call   8010323a <myproc>
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
80101ba9:	e8 55 22 00 00       	call   80103e03 <strncpy>
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
80101d10:	e8 e7 1d 00 00       	call   80103afc <initlock>
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
80101d80:	e8 b3 1e 00 00       	call   80103c38 <acquire>

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
80101dad:	e8 91 1a 00 00       	call   80103843 <wakeup>

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
80101dcb:	e8 cd 1e 00 00       	call   80103c9d <release>
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
80101de2:	e8 b6 1e 00 00       	call   80103c9d <release>
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
80101e1a:	e8 8f 1c 00 00       	call   80103aae <holdingsleep>
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
80101e47:	e8 ec 1d 00 00       	call   80103c38 <acquire>

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
80101ea9:	e8 30 18 00 00       	call   801036de <sleep>
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
80101ec3:	e8 d5 1d 00 00       	call   80103c9d <release>
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
80101fd6:	e8 09 1d 00 00       	call   80103ce4 <memset>

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
80102017:	e8 1c 1c 00 00       	call   80103c38 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 16 13 80       	push   $0x80131660
80102029:	e8 6f 1c 00 00       	call   80103c9d <release>
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
80102079:	e8 7e 1a 00 00       	call   80103afc <initlock>
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
801020c9:	75 32                	jne    801020fd <kalloc+0x42>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020cb:	8b 1d 98 16 13 80    	mov    0x80131698,%ebx
  if(r)
801020d1:	85 db                	test   %ebx,%ebx
801020d3:	74 07                	je     801020dc <kalloc+0x21>
    kmem.freelist = r->next;
801020d5:	8b 03                	mov    (%ebx),%eax
801020d7:	a3 98 16 13 80       	mov    %eax,0x80131698
  //
  if(r && r->next) {
801020dc:	85 db                	test   %ebx,%ebx
801020de:	74 0d                	je     801020ed <kalloc+0x32>
801020e0:	8b 03                	mov    (%ebx),%eax
801020e2:	85 c0                	test   %eax,%eax
801020e4:	74 07                	je     801020ed <kalloc+0x32>
    kmem.freelist = r->next->next;
801020e6:	8b 00                	mov    (%eax),%eax
801020e8:	a3 98 16 13 80       	mov    %eax,0x80131698
  }
  //
  if(kmem.use_lock)
801020ed:	83 3d 94 16 13 80 00 	cmpl   $0x0,0x80131694
801020f4:	75 19                	jne    8010210f <kalloc+0x54>
    release(&kmem.lock);
  return (char*)r;
}
801020f6:	89 d8                	mov    %ebx,%eax
801020f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020fb:	c9                   	leave  
801020fc:	c3                   	ret    
    acquire(&kmem.lock);
801020fd:	83 ec 0c             	sub    $0xc,%esp
80102100:	68 60 16 13 80       	push   $0x80131660
80102105:	e8 2e 1b 00 00       	call   80103c38 <acquire>
8010210a:	83 c4 10             	add    $0x10,%esp
8010210d:	eb bc                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
8010210f:	83 ec 0c             	sub    $0xc,%esp
80102112:	68 60 16 13 80       	push   $0x80131660
80102117:	e8 81 1b 00 00       	call   80103c9d <release>
8010211c:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010211f:	eb d5                	jmp    801020f6 <kalloc+0x3b>

80102121 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102121:	55                   	push   %ebp
80102122:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102124:	ba 64 00 00 00       	mov    $0x64,%edx
80102129:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010212a:	a8 01                	test   $0x1,%al
8010212c:	0f 84 b5 00 00 00    	je     801021e7 <kbdgetc+0xc6>
80102132:	ba 60 00 00 00       	mov    $0x60,%edx
80102137:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102138:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010213b:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102141:	74 5c                	je     8010219f <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102143:	84 c0                	test   %al,%al
80102145:	78 66                	js     801021ad <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102147:	8b 0d b4 95 12 80    	mov    0x801295b4,%ecx
8010214d:	f6 c1 40             	test   $0x40,%cl
80102150:	74 0f                	je     80102161 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102152:	83 c8 80             	or     $0xffffff80,%eax
80102155:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102158:	83 e1 bf             	and    $0xffffffbf,%ecx
8010215b:	89 0d b4 95 12 80    	mov    %ecx,0x801295b4
  }

  shift |= shiftcode[data];
80102161:	0f b6 8a e0 68 10 80 	movzbl -0x7fef9720(%edx),%ecx
80102168:	0b 0d b4 95 12 80    	or     0x801295b4,%ecx
  shift ^= togglecode[data];
8010216e:	0f b6 82 e0 67 10 80 	movzbl -0x7fef9820(%edx),%eax
80102175:	31 c1                	xor    %eax,%ecx
80102177:	89 0d b4 95 12 80    	mov    %ecx,0x801295b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010217d:	89 c8                	mov    %ecx,%eax
8010217f:	83 e0 03             	and    $0x3,%eax
80102182:	8b 04 85 c0 67 10 80 	mov    -0x7fef9840(,%eax,4),%eax
80102189:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010218d:	f6 c1 08             	test   $0x8,%cl
80102190:	74 19                	je     801021ab <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102192:	8d 50 9f             	lea    -0x61(%eax),%edx
80102195:	83 fa 19             	cmp    $0x19,%edx
80102198:	77 40                	ja     801021da <kbdgetc+0xb9>
      c += 'A' - 'a';
8010219a:	83 e8 20             	sub    $0x20,%eax
8010219d:	eb 0c                	jmp    801021ab <kbdgetc+0x8a>
    shift |= E0ESC;
8010219f:	83 0d b4 95 12 80 40 	orl    $0x40,0x801295b4
    return 0;
801021a6:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801021ab:	5d                   	pop    %ebp
801021ac:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021ad:	8b 0d b4 95 12 80    	mov    0x801295b4,%ecx
801021b3:	f6 c1 40             	test   $0x40,%cl
801021b6:	75 05                	jne    801021bd <kbdgetc+0x9c>
801021b8:	89 c2                	mov    %eax,%edx
801021ba:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801021bd:	0f b6 82 e0 68 10 80 	movzbl -0x7fef9720(%edx),%eax
801021c4:	83 c8 40             	or     $0x40,%eax
801021c7:	0f b6 c0             	movzbl %al,%eax
801021ca:	f7 d0                	not    %eax
801021cc:	21 c8                	and    %ecx,%eax
801021ce:	a3 b4 95 12 80       	mov    %eax,0x801295b4
    return 0;
801021d3:	b8 00 00 00 00       	mov    $0x0,%eax
801021d8:	eb d1                	jmp    801021ab <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801021da:	8d 50 bf             	lea    -0x41(%eax),%edx
801021dd:	83 fa 19             	cmp    $0x19,%edx
801021e0:	77 c9                	ja     801021ab <kbdgetc+0x8a>
      c += 'a' - 'A';
801021e2:	83 c0 20             	add    $0x20,%eax
  return c;
801021e5:	eb c4                	jmp    801021ab <kbdgetc+0x8a>
    return -1;
801021e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ec:	eb bd                	jmp    801021ab <kbdgetc+0x8a>

801021ee <kbdintr>:

void
kbdintr(void)
{
801021ee:	55                   	push   %ebp
801021ef:	89 e5                	mov    %esp,%ebp
801021f1:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021f4:	68 21 21 10 80       	push   $0x80102121
801021f9:	e8 40 e5 ff ff       	call   8010073e <consoleintr>
}
801021fe:	83 c4 10             	add    $0x10,%esp
80102201:	c9                   	leave  
80102202:	c3                   	ret    

80102203 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102203:	55                   	push   %ebp
80102204:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102206:	8b 0d 9c 16 13 80    	mov    0x8013169c,%ecx
8010220c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
8010220f:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102211:	a1 9c 16 13 80       	mov    0x8013169c,%eax
80102216:	8b 40 20             	mov    0x20(%eax),%eax
}
80102219:	5d                   	pop    %ebp
8010221a:	c3                   	ret    

8010221b <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010221b:	55                   	push   %ebp
8010221c:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010221e:	ba 70 00 00 00       	mov    $0x70,%edx
80102223:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102224:	ba 71 00 00 00       	mov    $0x71,%edx
80102229:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010222a:	0f b6 c0             	movzbl %al,%eax
}
8010222d:	5d                   	pop    %ebp
8010222e:	c3                   	ret    

8010222f <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010222f:	55                   	push   %ebp
80102230:	89 e5                	mov    %esp,%ebp
80102232:	53                   	push   %ebx
80102233:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102235:	b8 00 00 00 00       	mov    $0x0,%eax
8010223a:	e8 dc ff ff ff       	call   8010221b <cmos_read>
8010223f:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102241:	b8 02 00 00 00       	mov    $0x2,%eax
80102246:	e8 d0 ff ff ff       	call   8010221b <cmos_read>
8010224b:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010224e:	b8 04 00 00 00       	mov    $0x4,%eax
80102253:	e8 c3 ff ff ff       	call   8010221b <cmos_read>
80102258:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010225b:	b8 07 00 00 00       	mov    $0x7,%eax
80102260:	e8 b6 ff ff ff       	call   8010221b <cmos_read>
80102265:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102268:	b8 08 00 00 00       	mov    $0x8,%eax
8010226d:	e8 a9 ff ff ff       	call   8010221b <cmos_read>
80102272:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102275:	b8 09 00 00 00       	mov    $0x9,%eax
8010227a:	e8 9c ff ff ff       	call   8010221b <cmos_read>
8010227f:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102282:	5b                   	pop    %ebx
80102283:	5d                   	pop    %ebp
80102284:	c3                   	ret    

80102285 <lapicinit>:
  if(!lapic)
80102285:	83 3d 9c 16 13 80 00 	cmpl   $0x0,0x8013169c
8010228c:	0f 84 fb 00 00 00    	je     8010238d <lapicinit+0x108>
{
80102292:	55                   	push   %ebp
80102293:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102295:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010229a:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010229f:	e8 5f ff ff ff       	call   80102203 <lapicw>
  lapicw(TDCR, X1);
801022a4:	ba 0b 00 00 00       	mov    $0xb,%edx
801022a9:	b8 f8 00 00 00       	mov    $0xf8,%eax
801022ae:	e8 50 ff ff ff       	call   80102203 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022b3:	ba 20 00 02 00       	mov    $0x20020,%edx
801022b8:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022bd:	e8 41 ff ff ff       	call   80102203 <lapicw>
  lapicw(TICR, 10000000);
801022c2:	ba 80 96 98 00       	mov    $0x989680,%edx
801022c7:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022cc:	e8 32 ff ff ff       	call   80102203 <lapicw>
  lapicw(LINT0, MASKED);
801022d1:	ba 00 00 01 00       	mov    $0x10000,%edx
801022d6:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022db:	e8 23 ff ff ff       	call   80102203 <lapicw>
  lapicw(LINT1, MASKED);
801022e0:	ba 00 00 01 00       	mov    $0x10000,%edx
801022e5:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022ea:	e8 14 ff ff ff       	call   80102203 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801022ef:	a1 9c 16 13 80       	mov    0x8013169c,%eax
801022f4:	8b 40 30             	mov    0x30(%eax),%eax
801022f7:	c1 e8 10             	shr    $0x10,%eax
801022fa:	3c 03                	cmp    $0x3,%al
801022fc:	77 7b                	ja     80102379 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801022fe:	ba 33 00 00 00       	mov    $0x33,%edx
80102303:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102308:	e8 f6 fe ff ff       	call   80102203 <lapicw>
  lapicw(ESR, 0);
8010230d:	ba 00 00 00 00       	mov    $0x0,%edx
80102312:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102317:	e8 e7 fe ff ff       	call   80102203 <lapicw>
  lapicw(ESR, 0);
8010231c:	ba 00 00 00 00       	mov    $0x0,%edx
80102321:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102326:	e8 d8 fe ff ff       	call   80102203 <lapicw>
  lapicw(EOI, 0);
8010232b:	ba 00 00 00 00       	mov    $0x0,%edx
80102330:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102335:	e8 c9 fe ff ff       	call   80102203 <lapicw>
  lapicw(ICRHI, 0);
8010233a:	ba 00 00 00 00       	mov    $0x0,%edx
8010233f:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102344:	e8 ba fe ff ff       	call   80102203 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102349:	ba 00 85 08 00       	mov    $0x88500,%edx
8010234e:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102353:	e8 ab fe ff ff       	call   80102203 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102358:	a1 9c 16 13 80       	mov    0x8013169c,%eax
8010235d:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102363:	f6 c4 10             	test   $0x10,%ah
80102366:	75 f0                	jne    80102358 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102368:	ba 00 00 00 00       	mov    $0x0,%edx
8010236d:	b8 20 00 00 00       	mov    $0x20,%eax
80102372:	e8 8c fe ff ff       	call   80102203 <lapicw>
}
80102377:	5d                   	pop    %ebp
80102378:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102379:	ba 00 00 01 00       	mov    $0x10000,%edx
8010237e:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102383:	e8 7b fe ff ff       	call   80102203 <lapicw>
80102388:	e9 71 ff ff ff       	jmp    801022fe <lapicinit+0x79>
8010238d:	f3 c3                	repz ret 

8010238f <lapicid>:
{
8010238f:	55                   	push   %ebp
80102390:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102392:	a1 9c 16 13 80       	mov    0x8013169c,%eax
80102397:	85 c0                	test   %eax,%eax
80102399:	74 08                	je     801023a3 <lapicid+0x14>
  return lapic[ID] >> 24;
8010239b:	8b 40 20             	mov    0x20(%eax),%eax
8010239e:	c1 e8 18             	shr    $0x18,%eax
}
801023a1:	5d                   	pop    %ebp
801023a2:	c3                   	ret    
    return 0;
801023a3:	b8 00 00 00 00       	mov    $0x0,%eax
801023a8:	eb f7                	jmp    801023a1 <lapicid+0x12>

801023aa <lapiceoi>:
  if(lapic)
801023aa:	83 3d 9c 16 13 80 00 	cmpl   $0x0,0x8013169c
801023b1:	74 14                	je     801023c7 <lapiceoi+0x1d>
{
801023b3:	55                   	push   %ebp
801023b4:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801023b6:	ba 00 00 00 00       	mov    $0x0,%edx
801023bb:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023c0:	e8 3e fe ff ff       	call   80102203 <lapicw>
}
801023c5:	5d                   	pop    %ebp
801023c6:	c3                   	ret    
801023c7:	f3 c3                	repz ret 

801023c9 <microdelay>:
{
801023c9:	55                   	push   %ebp
801023ca:	89 e5                	mov    %esp,%ebp
}
801023cc:	5d                   	pop    %ebp
801023cd:	c3                   	ret    

801023ce <lapicstartap>:
{
801023ce:	55                   	push   %ebp
801023cf:	89 e5                	mov    %esp,%ebp
801023d1:	57                   	push   %edi
801023d2:	56                   	push   %esi
801023d3:	53                   	push   %ebx
801023d4:	8b 75 08             	mov    0x8(%ebp),%esi
801023d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023da:	b8 0f 00 00 00       	mov    $0xf,%eax
801023df:	ba 70 00 00 00       	mov    $0x70,%edx
801023e4:	ee                   	out    %al,(%dx)
801023e5:	b8 0a 00 00 00       	mov    $0xa,%eax
801023ea:	ba 71 00 00 00       	mov    $0x71,%edx
801023ef:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801023f0:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801023f7:	00 00 
  wrv[1] = addr >> 4;
801023f9:	89 f8                	mov    %edi,%eax
801023fb:	c1 e8 04             	shr    $0x4,%eax
801023fe:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102404:	c1 e6 18             	shl    $0x18,%esi
80102407:	89 f2                	mov    %esi,%edx
80102409:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010240e:	e8 f0 fd ff ff       	call   80102203 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102413:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102418:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010241d:	e8 e1 fd ff ff       	call   80102203 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102422:	ba 00 85 00 00       	mov    $0x8500,%edx
80102427:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010242c:	e8 d2 fd ff ff       	call   80102203 <lapicw>
  for(i = 0; i < 2; i++){
80102431:	bb 00 00 00 00       	mov    $0x0,%ebx
80102436:	eb 21                	jmp    80102459 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102438:	89 f2                	mov    %esi,%edx
8010243a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010243f:	e8 bf fd ff ff       	call   80102203 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102444:	89 fa                	mov    %edi,%edx
80102446:	c1 ea 0c             	shr    $0xc,%edx
80102449:	80 ce 06             	or     $0x6,%dh
8010244c:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102451:	e8 ad fd ff ff       	call   80102203 <lapicw>
  for(i = 0; i < 2; i++){
80102456:	83 c3 01             	add    $0x1,%ebx
80102459:	83 fb 01             	cmp    $0x1,%ebx
8010245c:	7e da                	jle    80102438 <lapicstartap+0x6a>
}
8010245e:	5b                   	pop    %ebx
8010245f:	5e                   	pop    %esi
80102460:	5f                   	pop    %edi
80102461:	5d                   	pop    %ebp
80102462:	c3                   	ret    

80102463 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102463:	55                   	push   %ebp
80102464:	89 e5                	mov    %esp,%ebp
80102466:	57                   	push   %edi
80102467:	56                   	push   %esi
80102468:	53                   	push   %ebx
80102469:	83 ec 3c             	sub    $0x3c,%esp
8010246c:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010246f:	b8 0b 00 00 00       	mov    $0xb,%eax
80102474:	e8 a2 fd ff ff       	call   8010221b <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102479:	83 e0 04             	and    $0x4,%eax
8010247c:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010247e:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102481:	e8 a9 fd ff ff       	call   8010222f <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102486:	b8 0a 00 00 00       	mov    $0xa,%eax
8010248b:	e8 8b fd ff ff       	call   8010221b <cmos_read>
80102490:	a8 80                	test   $0x80,%al
80102492:	75 ea                	jne    8010247e <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102494:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102497:	89 d8                	mov    %ebx,%eax
80102499:	e8 91 fd ff ff       	call   8010222f <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010249e:	83 ec 04             	sub    $0x4,%esp
801024a1:	6a 18                	push   $0x18
801024a3:	53                   	push   %ebx
801024a4:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024a7:	50                   	push   %eax
801024a8:	e8 7d 18 00 00       	call   80103d2a <memcmp>
801024ad:	83 c4 10             	add    $0x10,%esp
801024b0:	85 c0                	test   %eax,%eax
801024b2:	75 ca                	jne    8010247e <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024b4:	85 ff                	test   %edi,%edi
801024b6:	0f 85 84 00 00 00    	jne    80102540 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024bc:	8b 55 d0             	mov    -0x30(%ebp),%edx
801024bf:	89 d0                	mov    %edx,%eax
801024c1:	c1 e8 04             	shr    $0x4,%eax
801024c4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024c7:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024ca:	83 e2 0f             	and    $0xf,%edx
801024cd:	01 d0                	add    %edx,%eax
801024cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801024d5:	89 d0                	mov    %edx,%eax
801024d7:	c1 e8 04             	shr    $0x4,%eax
801024da:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024dd:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024e0:	83 e2 0f             	and    $0xf,%edx
801024e3:	01 d0                	add    %edx,%eax
801024e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
801024eb:	89 d0                	mov    %edx,%eax
801024ed:	c1 e8 04             	shr    $0x4,%eax
801024f0:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024f3:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024f6:	83 e2 0f             	and    $0xf,%edx
801024f9:	01 d0                	add    %edx,%eax
801024fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801024fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102501:	89 d0                	mov    %edx,%eax
80102503:	c1 e8 04             	shr    $0x4,%eax
80102506:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102509:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010250c:	83 e2 0f             	and    $0xf,%edx
8010250f:	01 d0                	add    %edx,%eax
80102511:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102514:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102517:	89 d0                	mov    %edx,%eax
80102519:	c1 e8 04             	shr    $0x4,%eax
8010251c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010251f:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102522:	83 e2 0f             	and    $0xf,%edx
80102525:	01 d0                	add    %edx,%eax
80102527:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010252a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010252d:	89 d0                	mov    %edx,%eax
8010252f:	c1 e8 04             	shr    $0x4,%eax
80102532:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102535:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102538:	83 e2 0f             	and    $0xf,%edx
8010253b:	01 d0                	add    %edx,%eax
8010253d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102540:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102543:	89 06                	mov    %eax,(%esi)
80102545:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102548:	89 46 04             	mov    %eax,0x4(%esi)
8010254b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010254e:	89 46 08             	mov    %eax,0x8(%esi)
80102551:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102554:	89 46 0c             	mov    %eax,0xc(%esi)
80102557:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010255a:	89 46 10             	mov    %eax,0x10(%esi)
8010255d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102560:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102563:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010256a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010256d:	5b                   	pop    %ebx
8010256e:	5e                   	pop    %esi
8010256f:	5f                   	pop    %edi
80102570:	5d                   	pop    %ebp
80102571:	c3                   	ret    

80102572 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102572:	55                   	push   %ebp
80102573:	89 e5                	mov    %esp,%ebp
80102575:	53                   	push   %ebx
80102576:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102579:	ff 35 d4 16 13 80    	pushl  0x801316d4
8010257f:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102585:	e8 e2 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010258a:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010258d:	89 1d e8 16 13 80    	mov    %ebx,0x801316e8
  for (i = 0; i < log.lh.n; i++) {
80102593:	83 c4 10             	add    $0x10,%esp
80102596:	ba 00 00 00 00       	mov    $0x0,%edx
8010259b:	eb 0e                	jmp    801025ab <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010259d:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801025a1:	89 0c 95 ec 16 13 80 	mov    %ecx,-0x7fece914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801025a8:	83 c2 01             	add    $0x1,%edx
801025ab:	39 d3                	cmp    %edx,%ebx
801025ad:	7f ee                	jg     8010259d <read_head+0x2b>
  }
  brelse(buf);
801025af:	83 ec 0c             	sub    $0xc,%esp
801025b2:	50                   	push   %eax
801025b3:	e8 1d dc ff ff       	call   801001d5 <brelse>
}
801025b8:	83 c4 10             	add    $0x10,%esp
801025bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025be:	c9                   	leave  
801025bf:	c3                   	ret    

801025c0 <install_trans>:
{
801025c0:	55                   	push   %ebp
801025c1:	89 e5                	mov    %esp,%ebp
801025c3:	57                   	push   %edi
801025c4:	56                   	push   %esi
801025c5:	53                   	push   %ebx
801025c6:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025c9:	bb 00 00 00 00       	mov    $0x0,%ebx
801025ce:	eb 66                	jmp    80102636 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025d0:	89 d8                	mov    %ebx,%eax
801025d2:	03 05 d4 16 13 80    	add    0x801316d4,%eax
801025d8:	83 c0 01             	add    $0x1,%eax
801025db:	83 ec 08             	sub    $0x8,%esp
801025de:	50                   	push   %eax
801025df:	ff 35 e4 16 13 80    	pushl  0x801316e4
801025e5:	e8 82 db ff ff       	call   8010016c <bread>
801025ea:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025ec:	83 c4 08             	add    $0x8,%esp
801025ef:	ff 34 9d ec 16 13 80 	pushl  -0x7fece914(,%ebx,4)
801025f6:	ff 35 e4 16 13 80    	pushl  0x801316e4
801025fc:	e8 6b db ff ff       	call   8010016c <bread>
80102601:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102603:	8d 57 5c             	lea    0x5c(%edi),%edx
80102606:	8d 40 5c             	lea    0x5c(%eax),%eax
80102609:	83 c4 0c             	add    $0xc,%esp
8010260c:	68 00 02 00 00       	push   $0x200
80102611:	52                   	push   %edx
80102612:	50                   	push   %eax
80102613:	e8 47 17 00 00       	call   80103d5f <memmove>
    bwrite(dbuf);  // write dst to disk
80102618:	89 34 24             	mov    %esi,(%esp)
8010261b:	e8 7a db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102620:	89 3c 24             	mov    %edi,(%esp)
80102623:	e8 ad db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102628:	89 34 24             	mov    %esi,(%esp)
8010262b:	e8 a5 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102630:	83 c3 01             	add    $0x1,%ebx
80102633:	83 c4 10             	add    $0x10,%esp
80102636:	39 1d e8 16 13 80    	cmp    %ebx,0x801316e8
8010263c:	7f 92                	jg     801025d0 <install_trans+0x10>
}
8010263e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102641:	5b                   	pop    %ebx
80102642:	5e                   	pop    %esi
80102643:	5f                   	pop    %edi
80102644:	5d                   	pop    %ebp
80102645:	c3                   	ret    

80102646 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102646:	55                   	push   %ebp
80102647:	89 e5                	mov    %esp,%ebp
80102649:	53                   	push   %ebx
8010264a:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010264d:	ff 35 d4 16 13 80    	pushl  0x801316d4
80102653:	ff 35 e4 16 13 80    	pushl  0x801316e4
80102659:	e8 0e db ff ff       	call   8010016c <bread>
8010265e:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102660:	8b 0d e8 16 13 80    	mov    0x801316e8,%ecx
80102666:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102669:	83 c4 10             	add    $0x10,%esp
8010266c:	b8 00 00 00 00       	mov    $0x0,%eax
80102671:	eb 0e                	jmp    80102681 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102673:	8b 14 85 ec 16 13 80 	mov    -0x7fece914(,%eax,4),%edx
8010267a:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010267e:	83 c0 01             	add    $0x1,%eax
80102681:	39 c1                	cmp    %eax,%ecx
80102683:	7f ee                	jg     80102673 <write_head+0x2d>
  }
  bwrite(buf);
80102685:	83 ec 0c             	sub    $0xc,%esp
80102688:	53                   	push   %ebx
80102689:	e8 0c db ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010268e:	89 1c 24             	mov    %ebx,(%esp)
80102691:	e8 3f db ff ff       	call   801001d5 <brelse>
}
80102696:	83 c4 10             	add    $0x10,%esp
80102699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010269c:	c9                   	leave  
8010269d:	c3                   	ret    

8010269e <recover_from_log>:

static void
recover_from_log(void)
{
8010269e:	55                   	push   %ebp
8010269f:	89 e5                	mov    %esp,%ebp
801026a1:	83 ec 08             	sub    $0x8,%esp
  read_head();
801026a4:	e8 c9 fe ff ff       	call   80102572 <read_head>
  install_trans(); // if committed, copy from log to disk
801026a9:	e8 12 ff ff ff       	call   801025c0 <install_trans>
  log.lh.n = 0;
801026ae:	c7 05 e8 16 13 80 00 	movl   $0x0,0x801316e8
801026b5:	00 00 00 
  write_head(); // clear the log
801026b8:	e8 89 ff ff ff       	call   80102646 <write_head>
}
801026bd:	c9                   	leave  
801026be:	c3                   	ret    

801026bf <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026bf:	55                   	push   %ebp
801026c0:	89 e5                	mov    %esp,%ebp
801026c2:	57                   	push   %edi
801026c3:	56                   	push   %esi
801026c4:	53                   	push   %ebx
801026c5:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026c8:	bb 00 00 00 00       	mov    $0x0,%ebx
801026cd:	eb 66                	jmp    80102735 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026cf:	89 d8                	mov    %ebx,%eax
801026d1:	03 05 d4 16 13 80    	add    0x801316d4,%eax
801026d7:	83 c0 01             	add    $0x1,%eax
801026da:	83 ec 08             	sub    $0x8,%esp
801026dd:	50                   	push   %eax
801026de:	ff 35 e4 16 13 80    	pushl  0x801316e4
801026e4:	e8 83 da ff ff       	call   8010016c <bread>
801026e9:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026eb:	83 c4 08             	add    $0x8,%esp
801026ee:	ff 34 9d ec 16 13 80 	pushl  -0x7fece914(,%ebx,4)
801026f5:	ff 35 e4 16 13 80    	pushl  0x801316e4
801026fb:	e8 6c da ff ff       	call   8010016c <bread>
80102700:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102702:	8d 50 5c             	lea    0x5c(%eax),%edx
80102705:	8d 46 5c             	lea    0x5c(%esi),%eax
80102708:	83 c4 0c             	add    $0xc,%esp
8010270b:	68 00 02 00 00       	push   $0x200
80102710:	52                   	push   %edx
80102711:	50                   	push   %eax
80102712:	e8 48 16 00 00       	call   80103d5f <memmove>
    bwrite(to);  // write the log
80102717:	89 34 24             	mov    %esi,(%esp)
8010271a:	e8 7b da ff ff       	call   8010019a <bwrite>
    brelse(from);
8010271f:	89 3c 24             	mov    %edi,(%esp)
80102722:	e8 ae da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102727:	89 34 24             	mov    %esi,(%esp)
8010272a:	e8 a6 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010272f:	83 c3 01             	add    $0x1,%ebx
80102732:	83 c4 10             	add    $0x10,%esp
80102735:	39 1d e8 16 13 80    	cmp    %ebx,0x801316e8
8010273b:	7f 92                	jg     801026cf <write_log+0x10>
  }
}
8010273d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102740:	5b                   	pop    %ebx
80102741:	5e                   	pop    %esi
80102742:	5f                   	pop    %edi
80102743:	5d                   	pop    %ebp
80102744:	c3                   	ret    

80102745 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102745:	83 3d e8 16 13 80 00 	cmpl   $0x0,0x801316e8
8010274c:	7e 26                	jle    80102774 <commit+0x2f>
{
8010274e:	55                   	push   %ebp
8010274f:	89 e5                	mov    %esp,%ebp
80102751:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102754:	e8 66 ff ff ff       	call   801026bf <write_log>
    write_head();    // Write header to disk -- the real commit
80102759:	e8 e8 fe ff ff       	call   80102646 <write_head>
    install_trans(); // Now install writes to home locations
8010275e:	e8 5d fe ff ff       	call   801025c0 <install_trans>
    log.lh.n = 0;
80102763:	c7 05 e8 16 13 80 00 	movl   $0x0,0x801316e8
8010276a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010276d:	e8 d4 fe ff ff       	call   80102646 <write_head>
  }
}
80102772:	c9                   	leave  
80102773:	c3                   	ret    
80102774:	f3 c3                	repz ret 

80102776 <initlog>:
{
80102776:	55                   	push   %ebp
80102777:	89 e5                	mov    %esp,%ebp
80102779:	53                   	push   %ebx
8010277a:	83 ec 2c             	sub    $0x2c,%esp
8010277d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102780:	68 e0 69 10 80       	push   $0x801069e0
80102785:	68 a0 16 13 80       	push   $0x801316a0
8010278a:	e8 6d 13 00 00       	call   80103afc <initlock>
  readsb(dev, &sb);
8010278f:	83 c4 08             	add    $0x8,%esp
80102792:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102795:	50                   	push   %eax
80102796:	53                   	push   %ebx
80102797:	e8 9a ea ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
8010279c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010279f:	a3 d4 16 13 80       	mov    %eax,0x801316d4
  log.size = sb.nlog;
801027a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027a7:	a3 d8 16 13 80       	mov    %eax,0x801316d8
  log.dev = dev;
801027ac:	89 1d e4 16 13 80    	mov    %ebx,0x801316e4
  recover_from_log();
801027b2:	e8 e7 fe ff ff       	call   8010269e <recover_from_log>
}
801027b7:	83 c4 10             	add    $0x10,%esp
801027ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027bd:	c9                   	leave  
801027be:	c3                   	ret    

801027bf <begin_op>:
{
801027bf:	55                   	push   %ebp
801027c0:	89 e5                	mov    %esp,%ebp
801027c2:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027c5:	68 a0 16 13 80       	push   $0x801316a0
801027ca:	e8 69 14 00 00       	call   80103c38 <acquire>
801027cf:	83 c4 10             	add    $0x10,%esp
801027d2:	eb 15                	jmp    801027e9 <begin_op+0x2a>
      sleep(&log, &log.lock);
801027d4:	83 ec 08             	sub    $0x8,%esp
801027d7:	68 a0 16 13 80       	push   $0x801316a0
801027dc:	68 a0 16 13 80       	push   $0x801316a0
801027e1:	e8 f8 0e 00 00       	call   801036de <sleep>
801027e6:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027e9:	83 3d e0 16 13 80 00 	cmpl   $0x0,0x801316e0
801027f0:	75 e2                	jne    801027d4 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027f2:	a1 dc 16 13 80       	mov    0x801316dc,%eax
801027f7:	83 c0 01             	add    $0x1,%eax
801027fa:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027fd:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102800:	03 15 e8 16 13 80    	add    0x801316e8,%edx
80102806:	83 fa 1e             	cmp    $0x1e,%edx
80102809:	7e 17                	jle    80102822 <begin_op+0x63>
      sleep(&log, &log.lock);
8010280b:	83 ec 08             	sub    $0x8,%esp
8010280e:	68 a0 16 13 80       	push   $0x801316a0
80102813:	68 a0 16 13 80       	push   $0x801316a0
80102818:	e8 c1 0e 00 00       	call   801036de <sleep>
8010281d:	83 c4 10             	add    $0x10,%esp
80102820:	eb c7                	jmp    801027e9 <begin_op+0x2a>
      log.outstanding += 1;
80102822:	a3 dc 16 13 80       	mov    %eax,0x801316dc
      release(&log.lock);
80102827:	83 ec 0c             	sub    $0xc,%esp
8010282a:	68 a0 16 13 80       	push   $0x801316a0
8010282f:	e8 69 14 00 00       	call   80103c9d <release>
}
80102834:	83 c4 10             	add    $0x10,%esp
80102837:	c9                   	leave  
80102838:	c3                   	ret    

80102839 <end_op>:
{
80102839:	55                   	push   %ebp
8010283a:	89 e5                	mov    %esp,%ebp
8010283c:	53                   	push   %ebx
8010283d:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102840:	68 a0 16 13 80       	push   $0x801316a0
80102845:	e8 ee 13 00 00       	call   80103c38 <acquire>
  log.outstanding -= 1;
8010284a:	a1 dc 16 13 80       	mov    0x801316dc,%eax
8010284f:	83 e8 01             	sub    $0x1,%eax
80102852:	a3 dc 16 13 80       	mov    %eax,0x801316dc
  if(log.committing)
80102857:	8b 1d e0 16 13 80    	mov    0x801316e0,%ebx
8010285d:	83 c4 10             	add    $0x10,%esp
80102860:	85 db                	test   %ebx,%ebx
80102862:	75 2c                	jne    80102890 <end_op+0x57>
  if(log.outstanding == 0){
80102864:	85 c0                	test   %eax,%eax
80102866:	75 35                	jne    8010289d <end_op+0x64>
    log.committing = 1;
80102868:	c7 05 e0 16 13 80 01 	movl   $0x1,0x801316e0
8010286f:	00 00 00 
    do_commit = 1;
80102872:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102877:	83 ec 0c             	sub    $0xc,%esp
8010287a:	68 a0 16 13 80       	push   $0x801316a0
8010287f:	e8 19 14 00 00       	call   80103c9d <release>
  if(do_commit){
80102884:	83 c4 10             	add    $0x10,%esp
80102887:	85 db                	test   %ebx,%ebx
80102889:	75 24                	jne    801028af <end_op+0x76>
}
8010288b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010288e:	c9                   	leave  
8010288f:	c3                   	ret    
    panic("log.committing");
80102890:	83 ec 0c             	sub    $0xc,%esp
80102893:	68 e4 69 10 80       	push   $0x801069e4
80102898:	e8 ab da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010289d:	83 ec 0c             	sub    $0xc,%esp
801028a0:	68 a0 16 13 80       	push   $0x801316a0
801028a5:	e8 99 0f 00 00       	call   80103843 <wakeup>
801028aa:	83 c4 10             	add    $0x10,%esp
801028ad:	eb c8                	jmp    80102877 <end_op+0x3e>
    commit();
801028af:	e8 91 fe ff ff       	call   80102745 <commit>
    acquire(&log.lock);
801028b4:	83 ec 0c             	sub    $0xc,%esp
801028b7:	68 a0 16 13 80       	push   $0x801316a0
801028bc:	e8 77 13 00 00       	call   80103c38 <acquire>
    log.committing = 0;
801028c1:	c7 05 e0 16 13 80 00 	movl   $0x0,0x801316e0
801028c8:	00 00 00 
    wakeup(&log);
801028cb:	c7 04 24 a0 16 13 80 	movl   $0x801316a0,(%esp)
801028d2:	e8 6c 0f 00 00       	call   80103843 <wakeup>
    release(&log.lock);
801028d7:	c7 04 24 a0 16 13 80 	movl   $0x801316a0,(%esp)
801028de:	e8 ba 13 00 00       	call   80103c9d <release>
801028e3:	83 c4 10             	add    $0x10,%esp
}
801028e6:	eb a3                	jmp    8010288b <end_op+0x52>

801028e8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028e8:	55                   	push   %ebp
801028e9:	89 e5                	mov    %esp,%ebp
801028eb:	53                   	push   %ebx
801028ec:	83 ec 04             	sub    $0x4,%esp
801028ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801028f2:	8b 15 e8 16 13 80    	mov    0x801316e8,%edx
801028f8:	83 fa 1d             	cmp    $0x1d,%edx
801028fb:	7f 45                	jg     80102942 <log_write+0x5a>
801028fd:	a1 d8 16 13 80       	mov    0x801316d8,%eax
80102902:	83 e8 01             	sub    $0x1,%eax
80102905:	39 c2                	cmp    %eax,%edx
80102907:	7d 39                	jge    80102942 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102909:	83 3d dc 16 13 80 00 	cmpl   $0x0,0x801316dc
80102910:	7e 3d                	jle    8010294f <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102912:	83 ec 0c             	sub    $0xc,%esp
80102915:	68 a0 16 13 80       	push   $0x801316a0
8010291a:	e8 19 13 00 00       	call   80103c38 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010291f:	83 c4 10             	add    $0x10,%esp
80102922:	b8 00 00 00 00       	mov    $0x0,%eax
80102927:	8b 15 e8 16 13 80    	mov    0x801316e8,%edx
8010292d:	39 c2                	cmp    %eax,%edx
8010292f:	7e 2b                	jle    8010295c <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102931:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102934:	39 0c 85 ec 16 13 80 	cmp    %ecx,-0x7fece914(,%eax,4)
8010293b:	74 1f                	je     8010295c <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
8010293d:	83 c0 01             	add    $0x1,%eax
80102940:	eb e5                	jmp    80102927 <log_write+0x3f>
    panic("too big a transaction");
80102942:	83 ec 0c             	sub    $0xc,%esp
80102945:	68 f3 69 10 80       	push   $0x801069f3
8010294a:	e8 f9 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
8010294f:	83 ec 0c             	sub    $0xc,%esp
80102952:	68 09 6a 10 80       	push   $0x80106a09
80102957:	e8 ec d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
8010295c:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010295f:	89 0c 85 ec 16 13 80 	mov    %ecx,-0x7fece914(,%eax,4)
  if (i == log.lh.n)
80102966:	39 c2                	cmp    %eax,%edx
80102968:	74 18                	je     80102982 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010296a:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010296d:	83 ec 0c             	sub    $0xc,%esp
80102970:	68 a0 16 13 80       	push   $0x801316a0
80102975:	e8 23 13 00 00       	call   80103c9d <release>
}
8010297a:	83 c4 10             	add    $0x10,%esp
8010297d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102980:	c9                   	leave  
80102981:	c3                   	ret    
    log.lh.n++;
80102982:	83 c2 01             	add    $0x1,%edx
80102985:	89 15 e8 16 13 80    	mov    %edx,0x801316e8
8010298b:	eb dd                	jmp    8010296a <log_write+0x82>

8010298d <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010298d:	55                   	push   %ebp
8010298e:	89 e5                	mov    %esp,%ebp
80102990:	53                   	push   %ebx
80102991:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102994:	68 8a 00 00 00       	push   $0x8a
80102999:	68 8c 94 12 80       	push   $0x8012948c
8010299e:	68 00 70 00 80       	push   $0x80007000
801029a3:	e8 b7 13 00 00       	call   80103d5f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801029a8:	83 c4 10             	add    $0x10,%esp
801029ab:	bb a0 17 13 80       	mov    $0x801317a0,%ebx
801029b0:	eb 06                	jmp    801029b8 <startothers+0x2b>
801029b2:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029b8:	69 05 20 1d 13 80 b0 	imul   $0xb0,0x80131d20,%eax
801029bf:	00 00 00 
801029c2:	05 a0 17 13 80       	add    $0x801317a0,%eax
801029c7:	39 d8                	cmp    %ebx,%eax
801029c9:	76 4c                	jbe    80102a17 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
801029cb:	e8 f3 07 00 00       	call   801031c3 <mycpu>
801029d0:	39 d8                	cmp    %ebx,%eax
801029d2:	74 de                	je     801029b2 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029d4:	e8 e2 f6 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029d9:	05 00 10 00 00       	add    $0x1000,%eax
801029de:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
801029e3:	c7 05 f8 6f 00 80 5b 	movl   $0x80102a5b,0x80006ff8
801029ea:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029ed:	c7 05 f4 6f 00 80 00 	movl   $0x108000,0x80006ff4
801029f4:	80 10 00 

    lapicstartap(c->apicid, V2P(code));
801029f7:	83 ec 08             	sub    $0x8,%esp
801029fa:	68 00 70 00 00       	push   $0x7000
801029ff:	0f b6 03             	movzbl (%ebx),%eax
80102a02:	50                   	push   %eax
80102a03:	e8 c6 f9 ff ff       	call   801023ce <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a08:	83 c4 10             	add    $0x10,%esp
80102a0b:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a11:	85 c0                	test   %eax,%eax
80102a13:	74 f6                	je     80102a0b <startothers+0x7e>
80102a15:	eb 9b                	jmp    801029b2 <startothers+0x25>
      ;
  }
}
80102a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a1a:	c9                   	leave  
80102a1b:	c3                   	ret    

80102a1c <mpmain>:
{
80102a1c:	55                   	push   %ebp
80102a1d:	89 e5                	mov    %esp,%ebp
80102a1f:	53                   	push   %ebx
80102a20:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a23:	e8 f7 07 00 00       	call   8010321f <cpuid>
80102a28:	89 c3                	mov    %eax,%ebx
80102a2a:	e8 f0 07 00 00       	call   8010321f <cpuid>
80102a2f:	83 ec 04             	sub    $0x4,%esp
80102a32:	53                   	push   %ebx
80102a33:	50                   	push   %eax
80102a34:	68 24 6a 10 80       	push   $0x80106a24
80102a39:	e8 cd db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a3e:	e8 73 24 00 00       	call   80104eb6 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a43:	e8 7b 07 00 00       	call   801031c3 <mycpu>
80102a48:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a4a:	b8 01 00 00 00       	mov    $0x1,%eax
80102a4f:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a56:	e8 5e 0a 00 00       	call   801034b9 <scheduler>

80102a5b <mpenter>:
{
80102a5b:	55                   	push   %ebp
80102a5c:	89 e5                	mov    %esp,%ebp
80102a5e:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a61:	e8 59 34 00 00       	call   80105ebf <switchkvm>
  seginit();
80102a66:	e8 08 33 00 00       	call   80105d73 <seginit>
  lapicinit();
80102a6b:	e8 15 f8 ff ff       	call   80102285 <lapicinit>
  mpmain();
80102a70:	e8 a7 ff ff ff       	call   80102a1c <mpmain>

80102a75 <main>:
{
80102a75:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a79:	83 e4 f0             	and    $0xfffffff0,%esp
80102a7c:	ff 71 fc             	pushl  -0x4(%ecx)
80102a7f:	55                   	push   %ebp
80102a80:	89 e5                	mov    %esp,%ebp
80102a82:	51                   	push   %ecx
80102a83:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a86:	68 00 00 40 80       	push   $0x80400000
80102a8b:	68 c8 44 13 80       	push   $0x801344c8
80102a90:	e8 d4 f5 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102a95:	e8 b2 38 00 00       	call   8010634c <kvmalloc>
  mpinit();        // detect other processors
80102a9a:	e8 c9 01 00 00       	call   80102c68 <mpinit>
  lapicinit();     // interrupt controller
80102a9f:	e8 e1 f7 ff ff       	call   80102285 <lapicinit>
  seginit();       // segment descriptors
80102aa4:	e8 ca 32 00 00       	call   80105d73 <seginit>
  picinit();       // disable pic
80102aa9:	e8 82 02 00 00       	call   80102d30 <picinit>
  ioapicinit();    // another interrupt controller
80102aae:	e8 47 f4 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102ab3:	e8 d6 dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102ab8:	e8 a7 26 00 00       	call   80105164 <uartinit>
  pinit();         // process table
80102abd:	e8 e7 06 00 00       	call   801031a9 <pinit>
  tvinit();        // trap vectors
80102ac2:	e8 3e 23 00 00       	call   80104e05 <tvinit>
  binit();         // buffer cache
80102ac7:	e8 28 d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102acc:	e8 42 e1 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102ad1:	e8 2a f2 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102ad6:	e8 b2 fe ff ff       	call   8010298d <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102adb:	83 c4 08             	add    $0x8,%esp
80102ade:	68 00 00 00 8e       	push   $0x8e000000
80102ae3:	68 00 00 40 80       	push   $0x80400000
80102ae8:	e8 ae f5 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102aed:	e8 6c 07 00 00       	call   8010325e <userinit>
  mpmain();        // finish this processor's setup
80102af2:	e8 25 ff ff ff       	call   80102a1c <mpmain>

80102af7 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102af7:	55                   	push   %ebp
80102af8:	89 e5                	mov    %esp,%ebp
80102afa:	56                   	push   %esi
80102afb:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102afc:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102b01:	b9 00 00 00 00       	mov    $0x0,%ecx
80102b06:	eb 09                	jmp    80102b11 <sum+0x1a>
    sum += addr[i];
80102b08:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102b0c:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102b0e:	83 c1 01             	add    $0x1,%ecx
80102b11:	39 d1                	cmp    %edx,%ecx
80102b13:	7c f3                	jl     80102b08 <sum+0x11>
  return sum;
}
80102b15:	89 d8                	mov    %ebx,%eax
80102b17:	5b                   	pop    %ebx
80102b18:	5e                   	pop    %esi
80102b19:	5d                   	pop    %ebp
80102b1a:	c3                   	ret    

80102b1b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b1b:	55                   	push   %ebp
80102b1c:	89 e5                	mov    %esp,%ebp
80102b1e:	56                   	push   %esi
80102b1f:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102b20:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102b26:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102b28:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b2a:	eb 03                	jmp    80102b2f <mpsearch1+0x14>
80102b2c:	83 c3 10             	add    $0x10,%ebx
80102b2f:	39 f3                	cmp    %esi,%ebx
80102b31:	73 29                	jae    80102b5c <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b33:	83 ec 04             	sub    $0x4,%esp
80102b36:	6a 04                	push   $0x4
80102b38:	68 38 6a 10 80       	push   $0x80106a38
80102b3d:	53                   	push   %ebx
80102b3e:	e8 e7 11 00 00       	call   80103d2a <memcmp>
80102b43:	83 c4 10             	add    $0x10,%esp
80102b46:	85 c0                	test   %eax,%eax
80102b48:	75 e2                	jne    80102b2c <mpsearch1+0x11>
80102b4a:	ba 10 00 00 00       	mov    $0x10,%edx
80102b4f:	89 d8                	mov    %ebx,%eax
80102b51:	e8 a1 ff ff ff       	call   80102af7 <sum>
80102b56:	84 c0                	test   %al,%al
80102b58:	75 d2                	jne    80102b2c <mpsearch1+0x11>
80102b5a:	eb 05                	jmp    80102b61 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102b5c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b61:	89 d8                	mov    %ebx,%eax
80102b63:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b66:	5b                   	pop    %ebx
80102b67:	5e                   	pop    %esi
80102b68:	5d                   	pop    %ebp
80102b69:	c3                   	ret    

80102b6a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b6a:	55                   	push   %ebp
80102b6b:	89 e5                	mov    %esp,%ebp
80102b6d:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b70:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b77:	c1 e0 08             	shl    $0x8,%eax
80102b7a:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102b81:	09 d0                	or     %edx,%eax
80102b83:	c1 e0 04             	shl    $0x4,%eax
80102b86:	85 c0                	test   %eax,%eax
80102b88:	74 1f                	je     80102ba9 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102b8a:	ba 00 04 00 00       	mov    $0x400,%edx
80102b8f:	e8 87 ff ff ff       	call   80102b1b <mpsearch1>
80102b94:	85 c0                	test   %eax,%eax
80102b96:	75 0f                	jne    80102ba7 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102b98:	ba 00 00 01 00       	mov    $0x10000,%edx
80102b9d:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ba2:	e8 74 ff ff ff       	call   80102b1b <mpsearch1>
}
80102ba7:	c9                   	leave  
80102ba8:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ba9:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102bb0:	c1 e0 08             	shl    $0x8,%eax
80102bb3:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102bba:	09 d0                	or     %edx,%eax
80102bbc:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bbf:	2d 00 04 00 00       	sub    $0x400,%eax
80102bc4:	ba 00 04 00 00       	mov    $0x400,%edx
80102bc9:	e8 4d ff ff ff       	call   80102b1b <mpsearch1>
80102bce:	85 c0                	test   %eax,%eax
80102bd0:	75 d5                	jne    80102ba7 <mpsearch+0x3d>
80102bd2:	eb c4                	jmp    80102b98 <mpsearch+0x2e>

80102bd4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bd4:	55                   	push   %ebp
80102bd5:	89 e5                	mov    %esp,%ebp
80102bd7:	57                   	push   %edi
80102bd8:	56                   	push   %esi
80102bd9:	53                   	push   %ebx
80102bda:	83 ec 1c             	sub    $0x1c,%esp
80102bdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102be0:	e8 85 ff ff ff       	call   80102b6a <mpsearch>
80102be5:	85 c0                	test   %eax,%eax
80102be7:	74 5c                	je     80102c45 <mpconfig+0x71>
80102be9:	89 c7                	mov    %eax,%edi
80102beb:	8b 58 04             	mov    0x4(%eax),%ebx
80102bee:	85 db                	test   %ebx,%ebx
80102bf0:	74 5a                	je     80102c4c <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102bf2:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102bf8:	83 ec 04             	sub    $0x4,%esp
80102bfb:	6a 04                	push   $0x4
80102bfd:	68 3d 6a 10 80       	push   $0x80106a3d
80102c02:	56                   	push   %esi
80102c03:	e8 22 11 00 00       	call   80103d2a <memcmp>
80102c08:	83 c4 10             	add    $0x10,%esp
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 44                	jne    80102c53 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c0f:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102c16:	3c 01                	cmp    $0x1,%al
80102c18:	0f 95 c2             	setne  %dl
80102c1b:	3c 04                	cmp    $0x4,%al
80102c1d:	0f 95 c0             	setne  %al
80102c20:	84 c2                	test   %al,%dl
80102c22:	75 36                	jne    80102c5a <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c24:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102c2b:	89 f0                	mov    %esi,%eax
80102c2d:	e8 c5 fe ff ff       	call   80102af7 <sum>
80102c32:	84 c0                	test   %al,%al
80102c34:	75 2b                	jne    80102c61 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102c36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c39:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102c3b:	89 f0                	mov    %esi,%eax
80102c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c40:	5b                   	pop    %ebx
80102c41:	5e                   	pop    %esi
80102c42:	5f                   	pop    %edi
80102c43:	5d                   	pop    %ebp
80102c44:	c3                   	ret    
    return 0;
80102c45:	be 00 00 00 00       	mov    $0x0,%esi
80102c4a:	eb ef                	jmp    80102c3b <mpconfig+0x67>
80102c4c:	be 00 00 00 00       	mov    $0x0,%esi
80102c51:	eb e8                	jmp    80102c3b <mpconfig+0x67>
    return 0;
80102c53:	be 00 00 00 00       	mov    $0x0,%esi
80102c58:	eb e1                	jmp    80102c3b <mpconfig+0x67>
    return 0;
80102c5a:	be 00 00 00 00       	mov    $0x0,%esi
80102c5f:	eb da                	jmp    80102c3b <mpconfig+0x67>
    return 0;
80102c61:	be 00 00 00 00       	mov    $0x0,%esi
80102c66:	eb d3                	jmp    80102c3b <mpconfig+0x67>

80102c68 <mpinit>:

void
mpinit(void)
{
80102c68:	55                   	push   %ebp
80102c69:	89 e5                	mov    %esp,%ebp
80102c6b:	57                   	push   %edi
80102c6c:	56                   	push   %esi
80102c6d:	53                   	push   %ebx
80102c6e:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c74:	e8 5b ff ff ff       	call   80102bd4 <mpconfig>
80102c79:	85 c0                	test   %eax,%eax
80102c7b:	74 19                	je     80102c96 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102c7d:	8b 50 24             	mov    0x24(%eax),%edx
80102c80:	89 15 9c 16 13 80    	mov    %edx,0x8013169c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c86:	8d 50 2c             	lea    0x2c(%eax),%edx
80102c89:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102c8d:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102c8f:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c94:	eb 34                	jmp    80102cca <mpinit+0x62>
    panic("Expect to run on an SMP");
80102c96:	83 ec 0c             	sub    $0xc,%esp
80102c99:	68 42 6a 10 80       	push   $0x80106a42
80102c9e:	e8 a5 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102ca3:	8b 35 20 1d 13 80    	mov    0x80131d20,%esi
80102ca9:	83 fe 07             	cmp    $0x7,%esi
80102cac:	7f 19                	jg     80102cc7 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cae:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cb2:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102cb8:	88 87 a0 17 13 80    	mov    %al,-0x7fece860(%edi)
        ncpu++;
80102cbe:	83 c6 01             	add    $0x1,%esi
80102cc1:	89 35 20 1d 13 80    	mov    %esi,0x80131d20
      }
      p += sizeof(struct mpproc);
80102cc7:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cca:	39 ca                	cmp    %ecx,%edx
80102ccc:	73 2b                	jae    80102cf9 <mpinit+0x91>
    switch(*p){
80102cce:	0f b6 02             	movzbl (%edx),%eax
80102cd1:	3c 04                	cmp    $0x4,%al
80102cd3:	77 1d                	ja     80102cf2 <mpinit+0x8a>
80102cd5:	0f b6 c0             	movzbl %al,%eax
80102cd8:	ff 24 85 7c 6a 10 80 	jmp    *-0x7fef9584(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102cdf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102ce3:	a2 80 17 13 80       	mov    %al,0x80131780
      p += sizeof(struct mpioapic);
80102ce8:	83 c2 08             	add    $0x8,%edx
      continue;
80102ceb:	eb dd                	jmp    80102cca <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102ced:	83 c2 08             	add    $0x8,%edx
      continue;
80102cf0:	eb d8                	jmp    80102cca <mpinit+0x62>
    default:
      ismp = 0;
80102cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
80102cf7:	eb d1                	jmp    80102cca <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102cf9:	85 db                	test   %ebx,%ebx
80102cfb:	74 26                	je     80102d23 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d00:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d04:	74 15                	je     80102d1b <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d06:	b8 70 00 00 00       	mov    $0x70,%eax
80102d0b:	ba 22 00 00 00       	mov    $0x22,%edx
80102d10:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d11:	ba 23 00 00 00       	mov    $0x23,%edx
80102d16:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d17:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d1a:	ee                   	out    %al,(%dx)
  }
}
80102d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d1e:	5b                   	pop    %ebx
80102d1f:	5e                   	pop    %esi
80102d20:	5f                   	pop    %edi
80102d21:	5d                   	pop    %ebp
80102d22:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d23:	83 ec 0c             	sub    $0xc,%esp
80102d26:	68 5c 6a 10 80       	push   $0x80106a5c
80102d2b:	e8 18 d6 ff ff       	call   80100348 <panic>

80102d30 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d38:	ba 21 00 00 00       	mov    $0x21,%edx
80102d3d:	ee                   	out    %al,(%dx)
80102d3e:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d43:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d44:	5d                   	pop    %ebp
80102d45:	c3                   	ret    

80102d46 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d46:	55                   	push   %ebp
80102d47:	89 e5                	mov    %esp,%ebp
80102d49:	57                   	push   %edi
80102d4a:	56                   	push   %esi
80102d4b:	53                   	push   %ebx
80102d4c:	83 ec 0c             	sub    $0xc,%esp
80102d4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d52:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d55:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d5b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d61:	e8 c7 de ff ff       	call   80100c2d <filealloc>
80102d66:	89 03                	mov    %eax,(%ebx)
80102d68:	85 c0                	test   %eax,%eax
80102d6a:	74 16                	je     80102d82 <pipealloc+0x3c>
80102d6c:	e8 bc de ff ff       	call   80100c2d <filealloc>
80102d71:	89 06                	mov    %eax,(%esi)
80102d73:	85 c0                	test   %eax,%eax
80102d75:	74 0b                	je     80102d82 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102d77:	e8 3f f3 ff ff       	call   801020bb <kalloc>
80102d7c:	89 c7                	mov    %eax,%edi
80102d7e:	85 c0                	test   %eax,%eax
80102d80:	75 35                	jne    80102db7 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d82:	8b 03                	mov    (%ebx),%eax
80102d84:	85 c0                	test   %eax,%eax
80102d86:	74 0c                	je     80102d94 <pipealloc+0x4e>
    fileclose(*f0);
80102d88:	83 ec 0c             	sub    $0xc,%esp
80102d8b:	50                   	push   %eax
80102d8c:	e8 42 df ff ff       	call   80100cd3 <fileclose>
80102d91:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d94:	8b 06                	mov    (%esi),%eax
80102d96:	85 c0                	test   %eax,%eax
80102d98:	0f 84 8b 00 00 00    	je     80102e29 <pipealloc+0xe3>
    fileclose(*f1);
80102d9e:	83 ec 0c             	sub    $0xc,%esp
80102da1:	50                   	push   %eax
80102da2:	e8 2c df ff ff       	call   80100cd3 <fileclose>
80102da7:	83 c4 10             	add    $0x10,%esp
  return -1;
80102daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102db2:	5b                   	pop    %ebx
80102db3:	5e                   	pop    %esi
80102db4:	5f                   	pop    %edi
80102db5:	5d                   	pop    %ebp
80102db6:	c3                   	ret    
  p->readopen = 1;
80102db7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102dbe:	00 00 00 
  p->writeopen = 1;
80102dc1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102dc8:	00 00 00 
  p->nwrite = 0;
80102dcb:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102dd2:	00 00 00 
  p->nread = 0;
80102dd5:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102ddc:	00 00 00 
  initlock(&p->lock, "pipe");
80102ddf:	83 ec 08             	sub    $0x8,%esp
80102de2:	68 90 6a 10 80       	push   $0x80106a90
80102de7:	50                   	push   %eax
80102de8:	e8 0f 0d 00 00       	call   80103afc <initlock>
  (*f0)->type = FD_PIPE;
80102ded:	8b 03                	mov    (%ebx),%eax
80102def:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102df5:	8b 03                	mov    (%ebx),%eax
80102df7:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102dfb:	8b 03                	mov    (%ebx),%eax
80102dfd:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102e01:	8b 03                	mov    (%ebx),%eax
80102e03:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102e06:	8b 06                	mov    (%esi),%eax
80102e08:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e0e:	8b 06                	mov    (%esi),%eax
80102e10:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e14:	8b 06                	mov    (%esi),%eax
80102e16:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e1a:	8b 06                	mov    (%esi),%eax
80102e1c:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e1f:	83 c4 10             	add    $0x10,%esp
80102e22:	b8 00 00 00 00       	mov    $0x0,%eax
80102e27:	eb 86                	jmp    80102daf <pipealloc+0x69>
  return -1;
80102e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e2e:	e9 7c ff ff ff       	jmp    80102daf <pipealloc+0x69>

80102e33 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e33:	55                   	push   %ebp
80102e34:	89 e5                	mov    %esp,%ebp
80102e36:	53                   	push   %ebx
80102e37:	83 ec 10             	sub    $0x10,%esp
80102e3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e3d:	53                   	push   %ebx
80102e3e:	e8 f5 0d 00 00       	call   80103c38 <acquire>
  if(writable){
80102e43:	83 c4 10             	add    $0x10,%esp
80102e46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e4a:	74 3f                	je     80102e8b <pipeclose+0x58>
    p->writeopen = 0;
80102e4c:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e53:	00 00 00 
    wakeup(&p->nread);
80102e56:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e5c:	83 ec 0c             	sub    $0xc,%esp
80102e5f:	50                   	push   %eax
80102e60:	e8 de 09 00 00       	call   80103843 <wakeup>
80102e65:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e68:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e6f:	75 09                	jne    80102e7a <pipeclose+0x47>
80102e71:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e78:	74 2f                	je     80102ea9 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e7a:	83 ec 0c             	sub    $0xc,%esp
80102e7d:	53                   	push   %ebx
80102e7e:	e8 1a 0e 00 00       	call   80103c9d <release>
80102e83:	83 c4 10             	add    $0x10,%esp
}
80102e86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e89:	c9                   	leave  
80102e8a:	c3                   	ret    
    p->readopen = 0;
80102e8b:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102e92:	00 00 00 
    wakeup(&p->nwrite);
80102e95:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e9b:	83 ec 0c             	sub    $0xc,%esp
80102e9e:	50                   	push   %eax
80102e9f:	e8 9f 09 00 00       	call   80103843 <wakeup>
80102ea4:	83 c4 10             	add    $0x10,%esp
80102ea7:	eb bf                	jmp    80102e68 <pipeclose+0x35>
    release(&p->lock);
80102ea9:	83 ec 0c             	sub    $0xc,%esp
80102eac:	53                   	push   %ebx
80102ead:	e8 eb 0d 00 00       	call   80103c9d <release>
    kfree((char*)p);
80102eb2:	89 1c 24             	mov    %ebx,(%esp)
80102eb5:	e8 ea f0 ff ff       	call   80101fa4 <kfree>
80102eba:	83 c4 10             	add    $0x10,%esp
80102ebd:	eb c7                	jmp    80102e86 <pipeclose+0x53>

80102ebf <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
80102ec2:	57                   	push   %edi
80102ec3:	56                   	push   %esi
80102ec4:	53                   	push   %ebx
80102ec5:	83 ec 18             	sub    $0x18,%esp
80102ec8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102ecb:	89 de                	mov    %ebx,%esi
80102ecd:	53                   	push   %ebx
80102ece:	e8 65 0d 00 00       	call   80103c38 <acquire>
  for(i = 0; i < n; i++){
80102ed3:	83 c4 10             	add    $0x10,%esp
80102ed6:	bf 00 00 00 00       	mov    $0x0,%edi
80102edb:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102ede:	0f 8d 88 00 00 00    	jge    80102f6c <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ee4:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102eea:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102ef0:	05 00 02 00 00       	add    $0x200,%eax
80102ef5:	39 c2                	cmp    %eax,%edx
80102ef7:	75 51                	jne    80102f4a <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102ef9:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f00:	74 2f                	je     80102f31 <pipewrite+0x72>
80102f02:	e8 33 03 00 00       	call   8010323a <myproc>
80102f07:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f0b:	75 24                	jne    80102f31 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f0d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f13:	83 ec 0c             	sub    $0xc,%esp
80102f16:	50                   	push   %eax
80102f17:	e8 27 09 00 00       	call   80103843 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f1c:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f22:	83 c4 08             	add    $0x8,%esp
80102f25:	56                   	push   %esi
80102f26:	50                   	push   %eax
80102f27:	e8 b2 07 00 00       	call   801036de <sleep>
80102f2c:	83 c4 10             	add    $0x10,%esp
80102f2f:	eb b3                	jmp    80102ee4 <pipewrite+0x25>
        release(&p->lock);
80102f31:	83 ec 0c             	sub    $0xc,%esp
80102f34:	53                   	push   %ebx
80102f35:	e8 63 0d 00 00       	call   80103c9d <release>
        return -1;
80102f3a:	83 c4 10             	add    $0x10,%esp
80102f3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f45:	5b                   	pop    %ebx
80102f46:	5e                   	pop    %esi
80102f47:	5f                   	pop    %edi
80102f48:	5d                   	pop    %ebp
80102f49:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f4a:	8d 42 01             	lea    0x1(%edx),%eax
80102f4d:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f53:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f59:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f5c:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f60:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f64:	83 c7 01             	add    $0x1,%edi
80102f67:	e9 6f ff ff ff       	jmp    80102edb <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f6c:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f72:	83 ec 0c             	sub    $0xc,%esp
80102f75:	50                   	push   %eax
80102f76:	e8 c8 08 00 00       	call   80103843 <wakeup>
  release(&p->lock);
80102f7b:	89 1c 24             	mov    %ebx,(%esp)
80102f7e:	e8 1a 0d 00 00       	call   80103c9d <release>
  return n;
80102f83:	83 c4 10             	add    $0x10,%esp
80102f86:	8b 45 10             	mov    0x10(%ebp),%eax
80102f89:	eb b7                	jmp    80102f42 <pipewrite+0x83>

80102f8b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102f8b:	55                   	push   %ebp
80102f8c:	89 e5                	mov    %esp,%ebp
80102f8e:	57                   	push   %edi
80102f8f:	56                   	push   %esi
80102f90:	53                   	push   %ebx
80102f91:	83 ec 18             	sub    $0x18,%esp
80102f94:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f97:	89 df                	mov    %ebx,%edi
80102f99:	53                   	push   %ebx
80102f9a:	e8 99 0c 00 00       	call   80103c38 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102f9f:	83 c4 10             	add    $0x10,%esp
80102fa2:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fa8:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102fae:	75 3d                	jne    80102fed <piperead+0x62>
80102fb0:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fb6:	85 f6                	test   %esi,%esi
80102fb8:	74 38                	je     80102ff2 <piperead+0x67>
    if(myproc()->killed){
80102fba:	e8 7b 02 00 00       	call   8010323a <myproc>
80102fbf:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fc3:	75 15                	jne    80102fda <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fc5:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fcb:	83 ec 08             	sub    $0x8,%esp
80102fce:	57                   	push   %edi
80102fcf:	50                   	push   %eax
80102fd0:	e8 09 07 00 00       	call   801036de <sleep>
80102fd5:	83 c4 10             	add    $0x10,%esp
80102fd8:	eb c8                	jmp    80102fa2 <piperead+0x17>
      release(&p->lock);
80102fda:	83 ec 0c             	sub    $0xc,%esp
80102fdd:	53                   	push   %ebx
80102fde:	e8 ba 0c 00 00       	call   80103c9d <release>
      return -1;
80102fe3:	83 c4 10             	add    $0x10,%esp
80102fe6:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102feb:	eb 50                	jmp    8010303d <piperead+0xb2>
80102fed:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102ff2:	3b 75 10             	cmp    0x10(%ebp),%esi
80102ff5:	7d 2c                	jge    80103023 <piperead+0x98>
    if(p->nread == p->nwrite)
80102ff7:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102ffd:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103003:	74 1e                	je     80103023 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103005:	8d 50 01             	lea    0x1(%eax),%edx
80103008:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
8010300e:	25 ff 01 00 00       	and    $0x1ff,%eax
80103013:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010301b:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010301e:	83 c6 01             	add    $0x1,%esi
80103021:	eb cf                	jmp    80102ff2 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103023:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103029:	83 ec 0c             	sub    $0xc,%esp
8010302c:	50                   	push   %eax
8010302d:	e8 11 08 00 00       	call   80103843 <wakeup>
  release(&p->lock);
80103032:	89 1c 24             	mov    %ebx,(%esp)
80103035:	e8 63 0c 00 00       	call   80103c9d <release>
  return i;
8010303a:	83 c4 10             	add    $0x10,%esp
}
8010303d:	89 f0                	mov    %esi,%eax
8010303f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103042:	5b                   	pop    %ebx
80103043:	5e                   	pop    %esi
80103044:	5f                   	pop    %edi
80103045:	5d                   	pop    %ebp
80103046:	c3                   	ret    

80103047 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103047:	55                   	push   %ebp
80103048:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010304a:	ba 74 1d 13 80       	mov    $0x80131d74,%edx
8010304f:	eb 03                	jmp    80103054 <wakeup1+0xd>
80103051:	83 c2 7c             	add    $0x7c,%edx
80103054:	81 fa 74 3c 13 80    	cmp    $0x80133c74,%edx
8010305a:	73 14                	jae    80103070 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010305c:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103060:	75 ef                	jne    80103051 <wakeup1+0xa>
80103062:	39 42 20             	cmp    %eax,0x20(%edx)
80103065:	75 ea                	jne    80103051 <wakeup1+0xa>
      p->state = RUNNABLE;
80103067:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010306e:	eb e1                	jmp    80103051 <wakeup1+0xa>
}
80103070:	5d                   	pop    %ebp
80103071:	c3                   	ret    

80103072 <allocproc>:
{
80103072:	55                   	push   %ebp
80103073:	89 e5                	mov    %esp,%ebp
80103075:	56                   	push   %esi
80103076:	53                   	push   %ebx
  acquire(&ptable.lock);
80103077:	83 ec 0c             	sub    $0xc,%esp
8010307a:	68 40 1d 13 80       	push   $0x80131d40
8010307f:	e8 b4 0b 00 00       	call   80103c38 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103084:	83 c4 10             	add    $0x10,%esp
80103087:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
8010308c:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103092:	73 0b                	jae    8010309f <allocproc+0x2d>
    if(p->state == UNUSED)
80103094:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103098:	74 1f                	je     801030b9 <allocproc+0x47>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010309a:	83 c3 7c             	add    $0x7c,%ebx
8010309d:	eb ed                	jmp    8010308c <allocproc+0x1a>
  release(&ptable.lock);
8010309f:	83 ec 0c             	sub    $0xc,%esp
801030a2:	68 40 1d 13 80       	push   $0x80131d40
801030a7:	e8 f1 0b 00 00       	call   80103c9d <release>
  return 0;
801030ac:	83 c4 10             	add    $0x10,%esp
801030af:	bb 00 00 00 00       	mov    $0x0,%ebx
801030b4:	e9 96 00 00 00       	jmp    8010314f <allocproc+0xdd>
  p->state = EMBRYO;
801030b9:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030c0:	a1 04 90 10 80       	mov    0x80109004,%eax
801030c5:	8d 50 01             	lea    0x1(%eax),%edx
801030c8:	89 15 04 90 10 80    	mov    %edx,0x80109004
801030ce:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801030d1:	83 ec 0c             	sub    $0xc,%esp
801030d4:	68 40 1d 13 80       	push   $0x80131d40
801030d9:	e8 bf 0b 00 00       	call   80103c9d <release>
  if((p->kstack = kalloc()) == 0){
801030de:	e8 d8 ef ff ff       	call   801020bb <kalloc>
801030e3:	89 43 08             	mov    %eax,0x8(%ebx)
801030e6:	83 c4 10             	add    $0x10,%esp
801030e9:	85 c0                	test   %eax,%eax
801030eb:	74 6b                	je     80103158 <allocproc+0xe6>
  frame[size] = (PDX(p->kstack) << 10) + PTX(p->kstack);
801030ed:	89 c2                	mov    %eax,%edx
801030ef:	c1 ea 16             	shr    $0x16,%edx
801030f2:	89 d1                	mov    %edx,%ecx
801030f4:	c1 e1 0a             	shl    $0xa,%ecx
801030f7:	89 c2                	mov    %eax,%edx
801030f9:	c1 ea 0c             	shr    $0xc,%edx
801030fc:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
80103102:	8b 35 b8 95 12 80    	mov    0x801295b8,%esi
80103108:	01 ca                	add    %ecx,%edx
8010310a:	89 14 b5 20 90 11 80 	mov    %edx,-0x7fee6fe0(,%esi,4)
  size++;
80103111:	83 c6 01             	add    $0x1,%esi
80103114:	89 35 b8 95 12 80    	mov    %esi,0x801295b8
  sp -= sizeof *p->tf;
8010311a:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103120:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103123:	c7 80 b0 0f 00 00 fa 	movl   $0x80104dfa,0xfb0(%eax)
8010312a:	4d 10 80 
  sp -= sizeof *p->context;
8010312d:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103132:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103135:	83 ec 04             	sub    $0x4,%esp
80103138:	6a 14                	push   $0x14
8010313a:	6a 00                	push   $0x0
8010313c:	50                   	push   %eax
8010313d:	e8 a2 0b 00 00       	call   80103ce4 <memset>
  p->context->eip = (uint)forkret;
80103142:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103145:	c7 40 10 66 31 10 80 	movl   $0x80103166,0x10(%eax)
  return p;
8010314c:	83 c4 10             	add    $0x10,%esp
}
8010314f:	89 d8                	mov    %ebx,%eax
80103151:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103154:	5b                   	pop    %ebx
80103155:	5e                   	pop    %esi
80103156:	5d                   	pop    %ebp
80103157:	c3                   	ret    
    p->state = UNUSED;
80103158:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
8010315f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103164:	eb e9                	jmp    8010314f <allocproc+0xdd>

80103166 <forkret>:
{
80103166:	55                   	push   %ebp
80103167:	89 e5                	mov    %esp,%ebp
80103169:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010316c:	68 40 1d 13 80       	push   $0x80131d40
80103171:	e8 27 0b 00 00       	call   80103c9d <release>
  if (first) {
80103176:	83 c4 10             	add    $0x10,%esp
80103179:	83 3d 00 90 10 80 00 	cmpl   $0x0,0x80109000
80103180:	75 02                	jne    80103184 <forkret+0x1e>
}
80103182:	c9                   	leave  
80103183:	c3                   	ret    
    first = 0;
80103184:	c7 05 00 90 10 80 00 	movl   $0x0,0x80109000
8010318b:	00 00 00 
    iinit(ROOTDEV);
8010318e:	83 ec 0c             	sub    $0xc,%esp
80103191:	6a 01                	push   $0x1
80103193:	e8 54 e1 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
80103198:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010319f:	e8 d2 f5 ff ff       	call   80102776 <initlog>
801031a4:	83 c4 10             	add    $0x10,%esp
}
801031a7:	eb d9                	jmp    80103182 <forkret+0x1c>

801031a9 <pinit>:
{
801031a9:	55                   	push   %ebp
801031aa:	89 e5                	mov    %esp,%ebp
801031ac:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801031af:	68 95 6a 10 80       	push   $0x80106a95
801031b4:	68 40 1d 13 80       	push   $0x80131d40
801031b9:	e8 3e 09 00 00       	call   80103afc <initlock>
}
801031be:	83 c4 10             	add    $0x10,%esp
801031c1:	c9                   	leave  
801031c2:	c3                   	ret    

801031c3 <mycpu>:
{
801031c3:	55                   	push   %ebp
801031c4:	89 e5                	mov    %esp,%ebp
801031c6:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031c9:	9c                   	pushf  
801031ca:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801031cb:	f6 c4 02             	test   $0x2,%ah
801031ce:	75 28                	jne    801031f8 <mycpu+0x35>
  apicid = lapicid();
801031d0:	e8 ba f1 ff ff       	call   8010238f <lapicid>
  for (i = 0; i < ncpu; ++i) {
801031d5:	ba 00 00 00 00       	mov    $0x0,%edx
801031da:	39 15 20 1d 13 80    	cmp    %edx,0x80131d20
801031e0:	7e 23                	jle    80103205 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801031e2:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801031e8:	0f b6 89 a0 17 13 80 	movzbl -0x7fece860(%ecx),%ecx
801031ef:	39 c1                	cmp    %eax,%ecx
801031f1:	74 1f                	je     80103212 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801031f3:	83 c2 01             	add    $0x1,%edx
801031f6:	eb e2                	jmp    801031da <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801031f8:	83 ec 0c             	sub    $0xc,%esp
801031fb:	68 78 6b 10 80       	push   $0x80106b78
80103200:	e8 43 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	68 9c 6a 10 80       	push   $0x80106a9c
8010320d:	e8 36 d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
80103212:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103218:	05 a0 17 13 80       	add    $0x801317a0,%eax
}
8010321d:	c9                   	leave  
8010321e:	c3                   	ret    

8010321f <cpuid>:
cpuid() {
8010321f:	55                   	push   %ebp
80103220:	89 e5                	mov    %esp,%ebp
80103222:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103225:	e8 99 ff ff ff       	call   801031c3 <mycpu>
8010322a:	2d a0 17 13 80       	sub    $0x801317a0,%eax
8010322f:	c1 f8 04             	sar    $0x4,%eax
80103232:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103238:	c9                   	leave  
80103239:	c3                   	ret    

8010323a <myproc>:
myproc(void) {
8010323a:	55                   	push   %ebp
8010323b:	89 e5                	mov    %esp,%ebp
8010323d:	53                   	push   %ebx
8010323e:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103241:	e8 15 09 00 00       	call   80103b5b <pushcli>
  c = mycpu();
80103246:	e8 78 ff ff ff       	call   801031c3 <mycpu>
  p = c->proc;
8010324b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103251:	e8 42 09 00 00       	call   80103b98 <popcli>
}
80103256:	89 d8                	mov    %ebx,%eax
80103258:	83 c4 04             	add    $0x4,%esp
8010325b:	5b                   	pop    %ebx
8010325c:	5d                   	pop    %ebp
8010325d:	c3                   	ret    

8010325e <userinit>:
{
8010325e:	55                   	push   %ebp
8010325f:	89 e5                	mov    %esp,%ebp
80103261:	53                   	push   %ebx
80103262:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103265:	e8 08 fe ff ff       	call   80103072 <allocproc>
8010326a:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010326c:	a3 bc 95 12 80       	mov    %eax,0x801295bc
  if((p->pgdir = setupkvm()) == 0)
80103271:	e8 68 30 00 00       	call   801062de <setupkvm>
80103276:	89 43 04             	mov    %eax,0x4(%ebx)
80103279:	85 c0                	test   %eax,%eax
8010327b:	0f 84 b7 00 00 00    	je     80103338 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103281:	83 ec 04             	sub    $0x4,%esp
80103284:	68 2c 00 00 00       	push   $0x2c
80103289:	68 60 94 12 80       	push   $0x80129460
8010328e:	50                   	push   %eax
8010328f:	e8 55 2d 00 00       	call   80105fe9 <inituvm>
  p->sz = PGSIZE;
80103294:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010329a:	83 c4 0c             	add    $0xc,%esp
8010329d:	6a 4c                	push   $0x4c
8010329f:	6a 00                	push   $0x0
801032a1:	ff 73 18             	pushl  0x18(%ebx)
801032a4:	e8 3b 0a 00 00       	call   80103ce4 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801032a9:	8b 43 18             	mov    0x18(%ebx),%eax
801032ac:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801032b2:	8b 43 18             	mov    0x18(%ebx),%eax
801032b5:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801032bb:	8b 43 18             	mov    0x18(%ebx),%eax
801032be:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032c2:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801032c6:	8b 43 18             	mov    0x18(%ebx),%eax
801032c9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032cd:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801032d1:	8b 43 18             	mov    0x18(%ebx),%eax
801032d4:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801032db:	8b 43 18             	mov    0x18(%ebx),%eax
801032de:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801032e5:	8b 43 18             	mov    0x18(%ebx),%eax
801032e8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801032ef:	8d 43 6c             	lea    0x6c(%ebx),%eax
801032f2:	83 c4 0c             	add    $0xc,%esp
801032f5:	6a 10                	push   $0x10
801032f7:	68 c5 6a 10 80       	push   $0x80106ac5
801032fc:	50                   	push   %eax
801032fd:	e8 49 0b 00 00       	call   80103e4b <safestrcpy>
  p->cwd = namei("/");
80103302:	c7 04 24 ce 6a 10 80 	movl   $0x80106ace,(%esp)
80103309:	e8 d3 e8 ff ff       	call   80101be1 <namei>
8010330e:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103311:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103318:	e8 1b 09 00 00       	call   80103c38 <acquire>
  p->state = RUNNABLE;
8010331d:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103324:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
8010332b:	e8 6d 09 00 00       	call   80103c9d <release>
}
80103330:	83 c4 10             	add    $0x10,%esp
80103333:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103336:	c9                   	leave  
80103337:	c3                   	ret    
    panic("userinit: out of memory?");
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 ac 6a 10 80       	push   $0x80106aac
80103340:	e8 03 d0 ff ff       	call   80100348 <panic>

80103345 <growproc>:
{
80103345:	55                   	push   %ebp
80103346:	89 e5                	mov    %esp,%ebp
80103348:	56                   	push   %esi
80103349:	53                   	push   %ebx
8010334a:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010334d:	e8 e8 fe ff ff       	call   8010323a <myproc>
80103352:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103354:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103356:	85 f6                	test   %esi,%esi
80103358:	7f 21                	jg     8010337b <growproc+0x36>
  } else if(n < 0){
8010335a:	85 f6                	test   %esi,%esi
8010335c:	79 33                	jns    80103391 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010335e:	83 ec 04             	sub    $0x4,%esp
80103361:	01 c6                	add    %eax,%esi
80103363:	56                   	push   %esi
80103364:	50                   	push   %eax
80103365:	ff 73 04             	pushl  0x4(%ebx)
80103368:	e8 85 2d 00 00       	call   801060f2 <deallocuvm>
8010336d:	83 c4 10             	add    $0x10,%esp
80103370:	85 c0                	test   %eax,%eax
80103372:	75 1d                	jne    80103391 <growproc+0x4c>
      return -1;
80103374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103379:	eb 29                	jmp    801033a4 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010337b:	83 ec 04             	sub    $0x4,%esp
8010337e:	01 c6                	add    %eax,%esi
80103380:	56                   	push   %esi
80103381:	50                   	push   %eax
80103382:	ff 73 04             	pushl  0x4(%ebx)
80103385:	e8 fa 2d 00 00       	call   80106184 <allocuvm>
8010338a:	83 c4 10             	add    $0x10,%esp
8010338d:	85 c0                	test   %eax,%eax
8010338f:	74 1a                	je     801033ab <growproc+0x66>
  curproc->sz = sz;
80103391:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103393:	83 ec 0c             	sub    $0xc,%esp
80103396:	53                   	push   %ebx
80103397:	e8 35 2b 00 00       	call   80105ed1 <switchuvm>
  return 0;
8010339c:	83 c4 10             	add    $0x10,%esp
8010339f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033a7:	5b                   	pop    %ebx
801033a8:	5e                   	pop    %esi
801033a9:	5d                   	pop    %ebp
801033aa:	c3                   	ret    
      return -1;
801033ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033b0:	eb f2                	jmp    801033a4 <growproc+0x5f>

801033b2 <fork>:
{
801033b2:	55                   	push   %ebp
801033b3:	89 e5                	mov    %esp,%ebp
801033b5:	57                   	push   %edi
801033b6:	56                   	push   %esi
801033b7:	53                   	push   %ebx
801033b8:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801033bb:	e8 7a fe ff ff       	call   8010323a <myproc>
801033c0:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033c2:	e8 ab fc ff ff       	call   80103072 <allocproc>
801033c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033ca:	85 c0                	test   %eax,%eax
801033cc:	0f 84 e0 00 00 00    	je     801034b2 <fork+0x100>
801033d2:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801033d4:	83 ec 08             	sub    $0x8,%esp
801033d7:	ff 33                	pushl  (%ebx)
801033d9:	ff 73 04             	pushl  0x4(%ebx)
801033dc:	e8 ae 2f 00 00       	call   8010638f <copyuvm>
801033e1:	89 47 04             	mov    %eax,0x4(%edi)
801033e4:	83 c4 10             	add    $0x10,%esp
801033e7:	85 c0                	test   %eax,%eax
801033e9:	74 2a                	je     80103415 <fork+0x63>
  np->sz = curproc->sz;
801033eb:	8b 03                	mov    (%ebx),%eax
801033ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801033f0:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801033f2:	89 c8                	mov    %ecx,%eax
801033f4:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801033f7:	8b 73 18             	mov    0x18(%ebx),%esi
801033fa:	8b 79 18             	mov    0x18(%ecx),%edi
801033fd:	b9 13 00 00 00       	mov    $0x13,%ecx
80103402:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103404:	8b 40 18             	mov    0x18(%eax),%eax
80103407:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010340e:	be 00 00 00 00       	mov    $0x0,%esi
80103413:	eb 29                	jmp    8010343e <fork+0x8c>
    kfree(np->kstack);
80103415:	83 ec 0c             	sub    $0xc,%esp
80103418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010341b:	ff 73 08             	pushl  0x8(%ebx)
8010341e:	e8 81 eb ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80103423:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010342a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103431:	83 c4 10             	add    $0x10,%esp
80103434:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103439:	eb 6d                	jmp    801034a8 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
8010343b:	83 c6 01             	add    $0x1,%esi
8010343e:	83 fe 0f             	cmp    $0xf,%esi
80103441:	7f 1d                	jg     80103460 <fork+0xae>
    if(curproc->ofile[i])
80103443:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103447:	85 c0                	test   %eax,%eax
80103449:	74 f0                	je     8010343b <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010344b:	83 ec 0c             	sub    $0xc,%esp
8010344e:	50                   	push   %eax
8010344f:	e8 3a d8 ff ff       	call   80100c8e <filedup>
80103454:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103457:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
8010345b:	83 c4 10             	add    $0x10,%esp
8010345e:	eb db                	jmp    8010343b <fork+0x89>
  np->cwd = idup(curproc->cwd);
80103460:	83 ec 0c             	sub    $0xc,%esp
80103463:	ff 73 68             	pushl  0x68(%ebx)
80103466:	e8 e6 e0 ff ff       	call   80101551 <idup>
8010346b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010346e:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103471:	83 c3 6c             	add    $0x6c,%ebx
80103474:	8d 47 6c             	lea    0x6c(%edi),%eax
80103477:	83 c4 0c             	add    $0xc,%esp
8010347a:	6a 10                	push   $0x10
8010347c:	53                   	push   %ebx
8010347d:	50                   	push   %eax
8010347e:	e8 c8 09 00 00       	call   80103e4b <safestrcpy>
  pid = np->pid;
80103483:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103486:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
8010348d:	e8 a6 07 00 00       	call   80103c38 <acquire>
  np->state = RUNNABLE;
80103492:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103499:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801034a0:	e8 f8 07 00 00       	call   80103c9d <release>
  return pid;
801034a5:	83 c4 10             	add    $0x10,%esp
}
801034a8:	89 d8                	mov    %ebx,%eax
801034aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034ad:	5b                   	pop    %ebx
801034ae:	5e                   	pop    %esi
801034af:	5f                   	pop    %edi
801034b0:	5d                   	pop    %ebp
801034b1:	c3                   	ret    
    return -1;
801034b2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034b7:	eb ef                	jmp    801034a8 <fork+0xf6>

801034b9 <scheduler>:
{
801034b9:	55                   	push   %ebp
801034ba:	89 e5                	mov    %esp,%ebp
801034bc:	56                   	push   %esi
801034bd:	53                   	push   %ebx
  struct cpu *c = mycpu();
801034be:	e8 00 fd ff ff       	call   801031c3 <mycpu>
801034c3:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801034c5:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801034cc:	00 00 00 
801034cf:	eb 5a                	jmp    8010352b <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034d1:	83 c3 7c             	add    $0x7c,%ebx
801034d4:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
801034da:	73 3f                	jae    8010351b <scheduler+0x62>
      if(p->state != RUNNABLE)
801034dc:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801034e0:	75 ef                	jne    801034d1 <scheduler+0x18>
      c->proc = p;
801034e2:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801034e8:	83 ec 0c             	sub    $0xc,%esp
801034eb:	53                   	push   %ebx
801034ec:	e8 e0 29 00 00       	call   80105ed1 <switchuvm>
      p->state = RUNNING;
801034f1:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801034f8:	83 c4 08             	add    $0x8,%esp
801034fb:	ff 73 1c             	pushl  0x1c(%ebx)
801034fe:	8d 46 04             	lea    0x4(%esi),%eax
80103501:	50                   	push   %eax
80103502:	e8 97 09 00 00       	call   80103e9e <swtch>
      switchkvm();
80103507:	e8 b3 29 00 00       	call   80105ebf <switchkvm>
      c->proc = 0;
8010350c:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103513:	00 00 00 
80103516:	83 c4 10             	add    $0x10,%esp
80103519:	eb b6                	jmp    801034d1 <scheduler+0x18>
    release(&ptable.lock);
8010351b:	83 ec 0c             	sub    $0xc,%esp
8010351e:	68 40 1d 13 80       	push   $0x80131d40
80103523:	e8 75 07 00 00       	call   80103c9d <release>
    sti();
80103528:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
8010352b:	fb                   	sti    
    acquire(&ptable.lock);
8010352c:	83 ec 0c             	sub    $0xc,%esp
8010352f:	68 40 1d 13 80       	push   $0x80131d40
80103534:	e8 ff 06 00 00       	call   80103c38 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103539:	83 c4 10             	add    $0x10,%esp
8010353c:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
80103541:	eb 91                	jmp    801034d4 <scheduler+0x1b>

80103543 <sched>:
{
80103543:	55                   	push   %ebp
80103544:	89 e5                	mov    %esp,%ebp
80103546:	56                   	push   %esi
80103547:	53                   	push   %ebx
  struct proc *p = myproc();
80103548:	e8 ed fc ff ff       	call   8010323a <myproc>
8010354d:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010354f:	83 ec 0c             	sub    $0xc,%esp
80103552:	68 40 1d 13 80       	push   $0x80131d40
80103557:	e8 9c 06 00 00       	call   80103bf8 <holding>
8010355c:	83 c4 10             	add    $0x10,%esp
8010355f:	85 c0                	test   %eax,%eax
80103561:	74 4f                	je     801035b2 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103563:	e8 5b fc ff ff       	call   801031c3 <mycpu>
80103568:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010356f:	75 4e                	jne    801035bf <sched+0x7c>
  if(p->state == RUNNING)
80103571:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103575:	74 55                	je     801035cc <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103577:	9c                   	pushf  
80103578:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103579:	f6 c4 02             	test   $0x2,%ah
8010357c:	75 5b                	jne    801035d9 <sched+0x96>
  intena = mycpu()->intena;
8010357e:	e8 40 fc ff ff       	call   801031c3 <mycpu>
80103583:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103589:	e8 35 fc ff ff       	call   801031c3 <mycpu>
8010358e:	83 ec 08             	sub    $0x8,%esp
80103591:	ff 70 04             	pushl  0x4(%eax)
80103594:	83 c3 1c             	add    $0x1c,%ebx
80103597:	53                   	push   %ebx
80103598:	e8 01 09 00 00       	call   80103e9e <swtch>
  mycpu()->intena = intena;
8010359d:	e8 21 fc ff ff       	call   801031c3 <mycpu>
801035a2:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801035a8:	83 c4 10             	add    $0x10,%esp
801035ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035ae:	5b                   	pop    %ebx
801035af:	5e                   	pop    %esi
801035b0:	5d                   	pop    %ebp
801035b1:	c3                   	ret    
    panic("sched ptable.lock");
801035b2:	83 ec 0c             	sub    $0xc,%esp
801035b5:	68 d0 6a 10 80       	push   $0x80106ad0
801035ba:	e8 89 cd ff ff       	call   80100348 <panic>
    panic("sched locks");
801035bf:	83 ec 0c             	sub    $0xc,%esp
801035c2:	68 e2 6a 10 80       	push   $0x80106ae2
801035c7:	e8 7c cd ff ff       	call   80100348 <panic>
    panic("sched running");
801035cc:	83 ec 0c             	sub    $0xc,%esp
801035cf:	68 ee 6a 10 80       	push   $0x80106aee
801035d4:	e8 6f cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801035d9:	83 ec 0c             	sub    $0xc,%esp
801035dc:	68 fc 6a 10 80       	push   $0x80106afc
801035e1:	e8 62 cd ff ff       	call   80100348 <panic>

801035e6 <exit>:
{
801035e6:	55                   	push   %ebp
801035e7:	89 e5                	mov    %esp,%ebp
801035e9:	56                   	push   %esi
801035ea:	53                   	push   %ebx
  struct proc *curproc = myproc();
801035eb:	e8 4a fc ff ff       	call   8010323a <myproc>
  if(curproc == initproc)
801035f0:	39 05 bc 95 12 80    	cmp    %eax,0x801295bc
801035f6:	74 09                	je     80103601 <exit+0x1b>
801035f8:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801035fa:	bb 00 00 00 00       	mov    $0x0,%ebx
801035ff:	eb 10                	jmp    80103611 <exit+0x2b>
    panic("init exiting");
80103601:	83 ec 0c             	sub    $0xc,%esp
80103604:	68 10 6b 10 80       	push   $0x80106b10
80103609:	e8 3a cd ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010360e:	83 c3 01             	add    $0x1,%ebx
80103611:	83 fb 0f             	cmp    $0xf,%ebx
80103614:	7f 1e                	jg     80103634 <exit+0x4e>
    if(curproc->ofile[fd]){
80103616:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010361a:	85 c0                	test   %eax,%eax
8010361c:	74 f0                	je     8010360e <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010361e:	83 ec 0c             	sub    $0xc,%esp
80103621:	50                   	push   %eax
80103622:	e8 ac d6 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103627:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010362e:	00 
8010362f:	83 c4 10             	add    $0x10,%esp
80103632:	eb da                	jmp    8010360e <exit+0x28>
  begin_op();
80103634:	e8 86 f1 ff ff       	call   801027bf <begin_op>
  iput(curproc->cwd);
80103639:	83 ec 0c             	sub    $0xc,%esp
8010363c:	ff 76 68             	pushl  0x68(%esi)
8010363f:	e8 44 e0 ff ff       	call   80101688 <iput>
  end_op();
80103644:	e8 f0 f1 ff ff       	call   80102839 <end_op>
  curproc->cwd = 0;
80103649:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103650:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103657:	e8 dc 05 00 00       	call   80103c38 <acquire>
  wakeup1(curproc->parent);
8010365c:	8b 46 14             	mov    0x14(%esi),%eax
8010365f:	e8 e3 f9 ff ff       	call   80103047 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103664:	83 c4 10             	add    $0x10,%esp
80103667:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
8010366c:	eb 03                	jmp    80103671 <exit+0x8b>
8010366e:	83 c3 7c             	add    $0x7c,%ebx
80103671:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103677:	73 1a                	jae    80103693 <exit+0xad>
    if(p->parent == curproc){
80103679:	39 73 14             	cmp    %esi,0x14(%ebx)
8010367c:	75 f0                	jne    8010366e <exit+0x88>
      p->parent = initproc;
8010367e:	a1 bc 95 12 80       	mov    0x801295bc,%eax
80103683:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103686:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010368a:	75 e2                	jne    8010366e <exit+0x88>
        wakeup1(initproc);
8010368c:	e8 b6 f9 ff ff       	call   80103047 <wakeup1>
80103691:	eb db                	jmp    8010366e <exit+0x88>
  curproc->state = ZOMBIE;
80103693:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010369a:	e8 a4 fe ff ff       	call   80103543 <sched>
  panic("zombie exit");
8010369f:	83 ec 0c             	sub    $0xc,%esp
801036a2:	68 1d 6b 10 80       	push   $0x80106b1d
801036a7:	e8 9c cc ff ff       	call   80100348 <panic>

801036ac <yield>:
{
801036ac:	55                   	push   %ebp
801036ad:	89 e5                	mov    %esp,%ebp
801036af:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801036b2:	68 40 1d 13 80       	push   $0x80131d40
801036b7:	e8 7c 05 00 00       	call   80103c38 <acquire>
  myproc()->state = RUNNABLE;
801036bc:	e8 79 fb ff ff       	call   8010323a <myproc>
801036c1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801036c8:	e8 76 fe ff ff       	call   80103543 <sched>
  release(&ptable.lock);
801036cd:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801036d4:	e8 c4 05 00 00       	call   80103c9d <release>
}
801036d9:	83 c4 10             	add    $0x10,%esp
801036dc:	c9                   	leave  
801036dd:	c3                   	ret    

801036de <sleep>:
{
801036de:	55                   	push   %ebp
801036df:	89 e5                	mov    %esp,%ebp
801036e1:	56                   	push   %esi
801036e2:	53                   	push   %ebx
801036e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801036e6:	e8 4f fb ff ff       	call   8010323a <myproc>
  if(p == 0)
801036eb:	85 c0                	test   %eax,%eax
801036ed:	74 66                	je     80103755 <sleep+0x77>
801036ef:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801036f1:	85 db                	test   %ebx,%ebx
801036f3:	74 6d                	je     80103762 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801036f5:	81 fb 40 1d 13 80    	cmp    $0x80131d40,%ebx
801036fb:	74 18                	je     80103715 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801036fd:	83 ec 0c             	sub    $0xc,%esp
80103700:	68 40 1d 13 80       	push   $0x80131d40
80103705:	e8 2e 05 00 00       	call   80103c38 <acquire>
    release(lk);
8010370a:	89 1c 24             	mov    %ebx,(%esp)
8010370d:	e8 8b 05 00 00       	call   80103c9d <release>
80103712:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103715:	8b 45 08             	mov    0x8(%ebp),%eax
80103718:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
8010371b:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103722:	e8 1c fe ff ff       	call   80103543 <sched>
  p->chan = 0;
80103727:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010372e:	81 fb 40 1d 13 80    	cmp    $0x80131d40,%ebx
80103734:	74 18                	je     8010374e <sleep+0x70>
    release(&ptable.lock);
80103736:	83 ec 0c             	sub    $0xc,%esp
80103739:	68 40 1d 13 80       	push   $0x80131d40
8010373e:	e8 5a 05 00 00       	call   80103c9d <release>
    acquire(lk);
80103743:	89 1c 24             	mov    %ebx,(%esp)
80103746:	e8 ed 04 00 00       	call   80103c38 <acquire>
8010374b:	83 c4 10             	add    $0x10,%esp
}
8010374e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103751:	5b                   	pop    %ebx
80103752:	5e                   	pop    %esi
80103753:	5d                   	pop    %ebp
80103754:	c3                   	ret    
    panic("sleep");
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	68 29 6b 10 80       	push   $0x80106b29
8010375d:	e8 e6 cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103762:	83 ec 0c             	sub    $0xc,%esp
80103765:	68 2f 6b 10 80       	push   $0x80106b2f
8010376a:	e8 d9 cb ff ff       	call   80100348 <panic>

8010376f <wait>:
{
8010376f:	55                   	push   %ebp
80103770:	89 e5                	mov    %esp,%ebp
80103772:	56                   	push   %esi
80103773:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103774:	e8 c1 fa ff ff       	call   8010323a <myproc>
80103779:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 40 1d 13 80       	push   $0x80131d40
80103783:	e8 b0 04 00 00       	call   80103c38 <acquire>
80103788:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010378b:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103790:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
80103795:	eb 5b                	jmp    801037f2 <wait+0x83>
        pid = p->pid;
80103797:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010379a:	83 ec 0c             	sub    $0xc,%esp
8010379d:	ff 73 08             	pushl  0x8(%ebx)
801037a0:	e8 ff e7 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
801037a5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801037ac:	83 c4 04             	add    $0x4,%esp
801037af:	ff 73 04             	pushl  0x4(%ebx)
801037b2:	e8 b7 2a 00 00       	call   8010626e <freevm>
        p->pid = 0;
801037b7:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801037be:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801037c5:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801037c9:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801037d0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801037d7:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
801037de:	e8 ba 04 00 00       	call   80103c9d <release>
        return pid;
801037e3:	83 c4 10             	add    $0x10,%esp
}
801037e6:	89 f0                	mov    %esi,%eax
801037e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037eb:	5b                   	pop    %ebx
801037ec:	5e                   	pop    %esi
801037ed:	5d                   	pop    %ebp
801037ee:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037ef:	83 c3 7c             	add    $0x7c,%ebx
801037f2:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
801037f8:	73 12                	jae    8010380c <wait+0x9d>
      if(p->parent != curproc)
801037fa:	39 73 14             	cmp    %esi,0x14(%ebx)
801037fd:	75 f0                	jne    801037ef <wait+0x80>
      if(p->state == ZOMBIE){
801037ff:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103803:	74 92                	je     80103797 <wait+0x28>
      havekids = 1;
80103805:	b8 01 00 00 00       	mov    $0x1,%eax
8010380a:	eb e3                	jmp    801037ef <wait+0x80>
    if(!havekids || curproc->killed){
8010380c:	85 c0                	test   %eax,%eax
8010380e:	74 06                	je     80103816 <wait+0xa7>
80103810:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103814:	74 17                	je     8010382d <wait+0xbe>
      release(&ptable.lock);
80103816:	83 ec 0c             	sub    $0xc,%esp
80103819:	68 40 1d 13 80       	push   $0x80131d40
8010381e:	e8 7a 04 00 00       	call   80103c9d <release>
      return -1;
80103823:	83 c4 10             	add    $0x10,%esp
80103826:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010382b:	eb b9                	jmp    801037e6 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010382d:	83 ec 08             	sub    $0x8,%esp
80103830:	68 40 1d 13 80       	push   $0x80131d40
80103835:	56                   	push   %esi
80103836:	e8 a3 fe ff ff       	call   801036de <sleep>
    havekids = 0;
8010383b:	83 c4 10             	add    $0x10,%esp
8010383e:	e9 48 ff ff ff       	jmp    8010378b <wait+0x1c>

80103843 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103843:	55                   	push   %ebp
80103844:	89 e5                	mov    %esp,%ebp
80103846:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103849:	68 40 1d 13 80       	push   $0x80131d40
8010384e:	e8 e5 03 00 00       	call   80103c38 <acquire>
  wakeup1(chan);
80103853:	8b 45 08             	mov    0x8(%ebp),%eax
80103856:	e8 ec f7 ff ff       	call   80103047 <wakeup1>
  release(&ptable.lock);
8010385b:	c7 04 24 40 1d 13 80 	movl   $0x80131d40,(%esp)
80103862:	e8 36 04 00 00       	call   80103c9d <release>
}
80103867:	83 c4 10             	add    $0x10,%esp
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	53                   	push   %ebx
80103870:	83 ec 10             	sub    $0x10,%esp
80103873:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103876:	68 40 1d 13 80       	push   $0x80131d40
8010387b:	e8 b8 03 00 00       	call   80103c38 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103880:	83 c4 10             	add    $0x10,%esp
80103883:	b8 74 1d 13 80       	mov    $0x80131d74,%eax
80103888:	3d 74 3c 13 80       	cmp    $0x80133c74,%eax
8010388d:	73 3a                	jae    801038c9 <kill+0x5d>
    if(p->pid == pid){
8010388f:	39 58 10             	cmp    %ebx,0x10(%eax)
80103892:	74 05                	je     80103899 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103894:	83 c0 7c             	add    $0x7c,%eax
80103897:	eb ef                	jmp    80103888 <kill+0x1c>
      p->killed = 1;
80103899:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801038a0:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801038a4:	74 1a                	je     801038c0 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801038a6:	83 ec 0c             	sub    $0xc,%esp
801038a9:	68 40 1d 13 80       	push   $0x80131d40
801038ae:	e8 ea 03 00 00       	call   80103c9d <release>
      return 0;
801038b3:	83 c4 10             	add    $0x10,%esp
801038b6:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801038bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038be:	c9                   	leave  
801038bf:	c3                   	ret    
        p->state = RUNNABLE;
801038c0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801038c7:	eb dd                	jmp    801038a6 <kill+0x3a>
  release(&ptable.lock);
801038c9:	83 ec 0c             	sub    $0xc,%esp
801038cc:	68 40 1d 13 80       	push   $0x80131d40
801038d1:	e8 c7 03 00 00       	call   80103c9d <release>
  return -1;
801038d6:	83 c4 10             	add    $0x10,%esp
801038d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038de:	eb db                	jmp    801038bb <kill+0x4f>

801038e0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801038e0:	55                   	push   %ebp
801038e1:	89 e5                	mov    %esp,%ebp
801038e3:	56                   	push   %esi
801038e4:	53                   	push   %ebx
801038e5:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038e8:	bb 74 1d 13 80       	mov    $0x80131d74,%ebx
801038ed:	eb 33                	jmp    80103922 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801038ef:	b8 40 6b 10 80       	mov    $0x80106b40,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801038f4:	8d 53 6c             	lea    0x6c(%ebx),%edx
801038f7:	52                   	push   %edx
801038f8:	50                   	push   %eax
801038f9:	ff 73 10             	pushl  0x10(%ebx)
801038fc:	68 44 6b 10 80       	push   $0x80106b44
80103901:	e8 05 cd ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103906:	83 c4 10             	add    $0x10,%esp
80103909:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
8010390d:	74 39                	je     80103948 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	68 bb 6e 10 80       	push   $0x80106ebb
80103917:	e8 ef cc ff ff       	call   8010060b <cprintf>
8010391c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010391f:	83 c3 7c             	add    $0x7c,%ebx
80103922:	81 fb 74 3c 13 80    	cmp    $0x80133c74,%ebx
80103928:	73 61                	jae    8010398b <procdump+0xab>
    if(p->state == UNUSED)
8010392a:	8b 43 0c             	mov    0xc(%ebx),%eax
8010392d:	85 c0                	test   %eax,%eax
8010392f:	74 ee                	je     8010391f <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103931:	83 f8 05             	cmp    $0x5,%eax
80103934:	77 b9                	ja     801038ef <procdump+0xf>
80103936:	8b 04 85 a0 6b 10 80 	mov    -0x7fef9460(,%eax,4),%eax
8010393d:	85 c0                	test   %eax,%eax
8010393f:	75 b3                	jne    801038f4 <procdump+0x14>
      state = "???";
80103941:	b8 40 6b 10 80       	mov    $0x80106b40,%eax
80103946:	eb ac                	jmp    801038f4 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103948:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010394b:	8b 40 0c             	mov    0xc(%eax),%eax
8010394e:	83 c0 08             	add    $0x8,%eax
80103951:	83 ec 08             	sub    $0x8,%esp
80103954:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103957:	52                   	push   %edx
80103958:	50                   	push   %eax
80103959:	e8 b9 01 00 00       	call   80103b17 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010395e:	83 c4 10             	add    $0x10,%esp
80103961:	be 00 00 00 00       	mov    $0x0,%esi
80103966:	eb 14                	jmp    8010397c <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103968:	83 ec 08             	sub    $0x8,%esp
8010396b:	50                   	push   %eax
8010396c:	68 81 65 10 80       	push   $0x80106581
80103971:	e8 95 cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103976:	83 c6 01             	add    $0x1,%esi
80103979:	83 c4 10             	add    $0x10,%esp
8010397c:	83 fe 09             	cmp    $0x9,%esi
8010397f:	7f 8e                	jg     8010390f <procdump+0x2f>
80103981:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103985:	85 c0                	test   %eax,%eax
80103987:	75 df                	jne    80103968 <procdump+0x88>
80103989:	eb 84                	jmp    8010390f <procdump+0x2f>
  }
}
8010398b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010398e:	5b                   	pop    %ebx
8010398f:	5e                   	pop    %esi
80103990:	5d                   	pop    %ebp
80103991:	c3                   	ret    

80103992 <dump_physmem>:

int
dump_physmem(int *frames, int *pids, int numframes)
{
80103992:	55                   	push   %ebp
80103993:	89 e5                	mov    %esp,%ebp
80103995:	57                   	push   %edi
80103996:	56                   	push   %esi
80103997:	53                   	push   %ebx
80103998:	8b 75 08             	mov    0x8(%ebp),%esi
8010399b:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010399e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  if (frames == NULL || pids == NULL || numframes < 0) {
801039a1:	85 f6                	test   %esi,%esi
801039a3:	0f 94 c2             	sete   %dl
801039a6:	85 ff                	test   %edi,%edi
801039a8:	0f 94 c0             	sete   %al
801039ab:	08 c2                	or     %al,%dl
801039ad:	75 34                	jne    801039e3 <dump_physmem+0x51>
801039af:	85 db                	test   %ebx,%ebx
801039b1:	78 37                	js     801039ea <dump_physmem+0x58>
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
801039b3:	b8 00 00 00 00       	mov    $0x0,%eax
801039b8:	eb 1b                	jmp    801039d5 <dump_physmem+0x43>
    frames[i] = frame[i];
801039ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801039c1:	8b 0c 85 20 90 11 80 	mov    -0x7fee6fe0(,%eax,4),%ecx
801039c8:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
    pids[i] = -2;
801039cb:	c7 04 17 fe ff ff ff 	movl   $0xfffffffe,(%edi,%edx,1)
  for (int i = 0; i < numframes; i++) {
801039d2:	83 c0 01             	add    $0x1,%eax
801039d5:	39 d8                	cmp    %ebx,%eax
801039d7:	7c e1                	jl     801039ba <dump_physmem+0x28>
  }
  return 0;
801039d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801039de:	5b                   	pop    %ebx
801039df:	5e                   	pop    %esi
801039e0:	5f                   	pop    %edi
801039e1:	5d                   	pop    %ebp
801039e2:	c3                   	ret    
      return -1;
801039e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039e8:	eb f4                	jmp    801039de <dump_physmem+0x4c>
801039ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039ef:	eb ed                	jmp    801039de <dump_physmem+0x4c>

801039f1 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801039f1:	55                   	push   %ebp
801039f2:	89 e5                	mov    %esp,%ebp
801039f4:	53                   	push   %ebx
801039f5:	83 ec 0c             	sub    $0xc,%esp
801039f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801039fb:	68 b8 6b 10 80       	push   $0x80106bb8
80103a00:	8d 43 04             	lea    0x4(%ebx),%eax
80103a03:	50                   	push   %eax
80103a04:	e8 f3 00 00 00       	call   80103afc <initlock>
  lk->name = name;
80103a09:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a0c:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103a0f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a15:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103a1c:	83 c4 10             	add    $0x10,%esp
80103a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a22:	c9                   	leave  
80103a23:	c3                   	ret    

80103a24 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103a24:	55                   	push   %ebp
80103a25:	89 e5                	mov    %esp,%ebp
80103a27:	56                   	push   %esi
80103a28:	53                   	push   %ebx
80103a29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a2c:	8d 73 04             	lea    0x4(%ebx),%esi
80103a2f:	83 ec 0c             	sub    $0xc,%esp
80103a32:	56                   	push   %esi
80103a33:	e8 00 02 00 00       	call   80103c38 <acquire>
  while (lk->locked) {
80103a38:	83 c4 10             	add    $0x10,%esp
80103a3b:	eb 0d                	jmp    80103a4a <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103a3d:	83 ec 08             	sub    $0x8,%esp
80103a40:	56                   	push   %esi
80103a41:	53                   	push   %ebx
80103a42:	e8 97 fc ff ff       	call   801036de <sleep>
80103a47:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103a4a:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a4d:	75 ee                	jne    80103a3d <acquiresleep+0x19>
  }
  lk->locked = 1;
80103a4f:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103a55:	e8 e0 f7 ff ff       	call   8010323a <myproc>
80103a5a:	8b 40 10             	mov    0x10(%eax),%eax
80103a5d:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103a60:	83 ec 0c             	sub    $0xc,%esp
80103a63:	56                   	push   %esi
80103a64:	e8 34 02 00 00       	call   80103c9d <release>
}
80103a69:	83 c4 10             	add    $0x10,%esp
80103a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a6f:	5b                   	pop    %ebx
80103a70:	5e                   	pop    %esi
80103a71:	5d                   	pop    %ebp
80103a72:	c3                   	ret    

80103a73 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103a73:	55                   	push   %ebp
80103a74:	89 e5                	mov    %esp,%ebp
80103a76:	56                   	push   %esi
80103a77:	53                   	push   %ebx
80103a78:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a7b:	8d 73 04             	lea    0x4(%ebx),%esi
80103a7e:	83 ec 0c             	sub    $0xc,%esp
80103a81:	56                   	push   %esi
80103a82:	e8 b1 01 00 00       	call   80103c38 <acquire>
  lk->locked = 0;
80103a87:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a8d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103a94:	89 1c 24             	mov    %ebx,(%esp)
80103a97:	e8 a7 fd ff ff       	call   80103843 <wakeup>
  release(&lk->lk);
80103a9c:	89 34 24             	mov    %esi,(%esp)
80103a9f:	e8 f9 01 00 00       	call   80103c9d <release>
}
80103aa4:	83 c4 10             	add    $0x10,%esp
80103aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103aaa:	5b                   	pop    %ebx
80103aab:	5e                   	pop    %esi
80103aac:	5d                   	pop    %ebp
80103aad:	c3                   	ret    

80103aae <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103aae:	55                   	push   %ebp
80103aaf:	89 e5                	mov    %esp,%ebp
80103ab1:	56                   	push   %esi
80103ab2:	53                   	push   %ebx
80103ab3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103ab6:	8d 73 04             	lea    0x4(%ebx),%esi
80103ab9:	83 ec 0c             	sub    $0xc,%esp
80103abc:	56                   	push   %esi
80103abd:	e8 76 01 00 00       	call   80103c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103ac2:	83 c4 10             	add    $0x10,%esp
80103ac5:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ac8:	75 17                	jne    80103ae1 <holdingsleep+0x33>
80103aca:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103acf:	83 ec 0c             	sub    $0xc,%esp
80103ad2:	56                   	push   %esi
80103ad3:	e8 c5 01 00 00       	call   80103c9d <release>
  return r;
}
80103ad8:	89 d8                	mov    %ebx,%eax
80103ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103add:	5b                   	pop    %ebx
80103ade:	5e                   	pop    %esi
80103adf:	5d                   	pop    %ebp
80103ae0:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103ae1:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103ae4:	e8 51 f7 ff ff       	call   8010323a <myproc>
80103ae9:	3b 58 10             	cmp    0x10(%eax),%ebx
80103aec:	74 07                	je     80103af5 <holdingsleep+0x47>
80103aee:	bb 00 00 00 00       	mov    $0x0,%ebx
80103af3:	eb da                	jmp    80103acf <holdingsleep+0x21>
80103af5:	bb 01 00 00 00       	mov    $0x1,%ebx
80103afa:	eb d3                	jmp    80103acf <holdingsleep+0x21>

80103afc <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103afc:	55                   	push   %ebp
80103afd:	89 e5                	mov    %esp,%ebp
80103aff:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103b02:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b05:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103b08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103b0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103b15:	5d                   	pop    %ebp
80103b16:	c3                   	ret    

80103b17 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103b17:	55                   	push   %ebp
80103b18:	89 e5                	mov    %esp,%ebp
80103b1a:	53                   	push   %ebx
80103b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b21:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103b24:	b8 00 00 00 00       	mov    $0x0,%eax
80103b29:	83 f8 09             	cmp    $0x9,%eax
80103b2c:	7f 25                	jg     80103b53 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103b2e:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103b34:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103b3a:	77 17                	ja     80103b53 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103b3c:	8b 5a 04             	mov    0x4(%edx),%ebx
80103b3f:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103b42:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103b44:	83 c0 01             	add    $0x1,%eax
80103b47:	eb e0                	jmp    80103b29 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103b49:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103b50:	83 c0 01             	add    $0x1,%eax
80103b53:	83 f8 09             	cmp    $0x9,%eax
80103b56:	7e f1                	jle    80103b49 <getcallerpcs+0x32>
}
80103b58:	5b                   	pop    %ebx
80103b59:	5d                   	pop    %ebp
80103b5a:	c3                   	ret    

80103b5b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103b5b:	55                   	push   %ebp
80103b5c:	89 e5                	mov    %esp,%ebp
80103b5e:	53                   	push   %ebx
80103b5f:	83 ec 04             	sub    $0x4,%esp
80103b62:	9c                   	pushf  
80103b63:	5b                   	pop    %ebx
  asm volatile("cli");
80103b64:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b65:	e8 59 f6 ff ff       	call   801031c3 <mycpu>
80103b6a:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b71:	74 12                	je     80103b85 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103b73:	e8 4b f6 ff ff       	call   801031c3 <mycpu>
80103b78:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103b7f:	83 c4 04             	add    $0x4,%esp
80103b82:	5b                   	pop    %ebx
80103b83:	5d                   	pop    %ebp
80103b84:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103b85:	e8 39 f6 ff ff       	call   801031c3 <mycpu>
80103b8a:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103b90:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103b96:	eb db                	jmp    80103b73 <pushcli+0x18>

80103b98 <popcli>:

void
popcli(void)
{
80103b98:	55                   	push   %ebp
80103b99:	89 e5                	mov    %esp,%ebp
80103b9b:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b9e:	9c                   	pushf  
80103b9f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103ba0:	f6 c4 02             	test   $0x2,%ah
80103ba3:	75 28                	jne    80103bcd <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103ba5:	e8 19 f6 ff ff       	call   801031c3 <mycpu>
80103baa:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103bb0:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103bb3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103bb9:	85 d2                	test   %edx,%edx
80103bbb:	78 1d                	js     80103bda <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103bbd:	e8 01 f6 ff ff       	call   801031c3 <mycpu>
80103bc2:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103bc9:	74 1c                	je     80103be7 <popcli+0x4f>
    sti();
}
80103bcb:	c9                   	leave  
80103bcc:	c3                   	ret    
    panic("popcli - interruptible");
80103bcd:	83 ec 0c             	sub    $0xc,%esp
80103bd0:	68 c3 6b 10 80       	push   $0x80106bc3
80103bd5:	e8 6e c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103bda:	83 ec 0c             	sub    $0xc,%esp
80103bdd:	68 da 6b 10 80       	push   $0x80106bda
80103be2:	e8 61 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103be7:	e8 d7 f5 ff ff       	call   801031c3 <mycpu>
80103bec:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103bf3:	74 d6                	je     80103bcb <popcli+0x33>
  asm volatile("sti");
80103bf5:	fb                   	sti    
}
80103bf6:	eb d3                	jmp    80103bcb <popcli+0x33>

80103bf8 <holding>:
{
80103bf8:	55                   	push   %ebp
80103bf9:	89 e5                	mov    %esp,%ebp
80103bfb:	53                   	push   %ebx
80103bfc:	83 ec 04             	sub    $0x4,%esp
80103bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103c02:	e8 54 ff ff ff       	call   80103b5b <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103c07:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c0a:	75 12                	jne    80103c1e <holding+0x26>
80103c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103c11:	e8 82 ff ff ff       	call   80103b98 <popcli>
}
80103c16:	89 d8                	mov    %ebx,%eax
80103c18:	83 c4 04             	add    $0x4,%esp
80103c1b:	5b                   	pop    %ebx
80103c1c:	5d                   	pop    %ebp
80103c1d:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103c1e:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c21:	e8 9d f5 ff ff       	call   801031c3 <mycpu>
80103c26:	39 c3                	cmp    %eax,%ebx
80103c28:	74 07                	je     80103c31 <holding+0x39>
80103c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c2f:	eb e0                	jmp    80103c11 <holding+0x19>
80103c31:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c36:	eb d9                	jmp    80103c11 <holding+0x19>

80103c38 <acquire>:
{
80103c38:	55                   	push   %ebp
80103c39:	89 e5                	mov    %esp,%ebp
80103c3b:	53                   	push   %ebx
80103c3c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103c3f:	e8 17 ff ff ff       	call   80103b5b <pushcli>
  if(holding(lk))
80103c44:	83 ec 0c             	sub    $0xc,%esp
80103c47:	ff 75 08             	pushl  0x8(%ebp)
80103c4a:	e8 a9 ff ff ff       	call   80103bf8 <holding>
80103c4f:	83 c4 10             	add    $0x10,%esp
80103c52:	85 c0                	test   %eax,%eax
80103c54:	75 3a                	jne    80103c90 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103c56:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103c59:	b8 01 00 00 00       	mov    $0x1,%eax
80103c5e:	f0 87 02             	lock xchg %eax,(%edx)
80103c61:	85 c0                	test   %eax,%eax
80103c63:	75 f1                	jne    80103c56 <acquire+0x1e>
  __sync_synchronize();
80103c65:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103c6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c6d:	e8 51 f5 ff ff       	call   801031c3 <mycpu>
80103c72:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103c75:	8b 45 08             	mov    0x8(%ebp),%eax
80103c78:	83 c0 0c             	add    $0xc,%eax
80103c7b:	83 ec 08             	sub    $0x8,%esp
80103c7e:	50                   	push   %eax
80103c7f:	8d 45 08             	lea    0x8(%ebp),%eax
80103c82:	50                   	push   %eax
80103c83:	e8 8f fe ff ff       	call   80103b17 <getcallerpcs>
}
80103c88:	83 c4 10             	add    $0x10,%esp
80103c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c8e:	c9                   	leave  
80103c8f:	c3                   	ret    
    panic("acquire");
80103c90:	83 ec 0c             	sub    $0xc,%esp
80103c93:	68 e1 6b 10 80       	push   $0x80106be1
80103c98:	e8 ab c6 ff ff       	call   80100348 <panic>

80103c9d <release>:
{
80103c9d:	55                   	push   %ebp
80103c9e:	89 e5                	mov    %esp,%ebp
80103ca0:	53                   	push   %ebx
80103ca1:	83 ec 10             	sub    $0x10,%esp
80103ca4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103ca7:	53                   	push   %ebx
80103ca8:	e8 4b ff ff ff       	call   80103bf8 <holding>
80103cad:	83 c4 10             	add    $0x10,%esp
80103cb0:	85 c0                	test   %eax,%eax
80103cb2:	74 23                	je     80103cd7 <release+0x3a>
  lk->pcs[0] = 0;
80103cb4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103cbb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103cc2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103cc7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103ccd:	e8 c6 fe ff ff       	call   80103b98 <popcli>
}
80103cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cd5:	c9                   	leave  
80103cd6:	c3                   	ret    
    panic("release");
80103cd7:	83 ec 0c             	sub    $0xc,%esp
80103cda:	68 e9 6b 10 80       	push   $0x80106be9
80103cdf:	e8 64 c6 ff ff       	call   80100348 <panic>

80103ce4 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ce4:	55                   	push   %ebp
80103ce5:	89 e5                	mov    %esp,%ebp
80103ce7:	57                   	push   %edi
80103ce8:	53                   	push   %ebx
80103ce9:	8b 55 08             	mov    0x8(%ebp),%edx
80103cec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103cef:	f6 c2 03             	test   $0x3,%dl
80103cf2:	75 05                	jne    80103cf9 <memset+0x15>
80103cf4:	f6 c1 03             	test   $0x3,%cl
80103cf7:	74 0e                	je     80103d07 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103cf9:	89 d7                	mov    %edx,%edi
80103cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfe:	fc                   	cld    
80103cff:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103d01:	89 d0                	mov    %edx,%eax
80103d03:	5b                   	pop    %ebx
80103d04:	5f                   	pop    %edi
80103d05:	5d                   	pop    %ebp
80103d06:	c3                   	ret    
    c &= 0xFF;
80103d07:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103d0b:	c1 e9 02             	shr    $0x2,%ecx
80103d0e:	89 f8                	mov    %edi,%eax
80103d10:	c1 e0 18             	shl    $0x18,%eax
80103d13:	89 fb                	mov    %edi,%ebx
80103d15:	c1 e3 10             	shl    $0x10,%ebx
80103d18:	09 d8                	or     %ebx,%eax
80103d1a:	89 fb                	mov    %edi,%ebx
80103d1c:	c1 e3 08             	shl    $0x8,%ebx
80103d1f:	09 d8                	or     %ebx,%eax
80103d21:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103d23:	89 d7                	mov    %edx,%edi
80103d25:	fc                   	cld    
80103d26:	f3 ab                	rep stos %eax,%es:(%edi)
80103d28:	eb d7                	jmp    80103d01 <memset+0x1d>

80103d2a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103d2a:	55                   	push   %ebp
80103d2b:	89 e5                	mov    %esp,%ebp
80103d2d:	56                   	push   %esi
80103d2e:	53                   	push   %ebx
80103d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103d32:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d35:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103d38:	8d 70 ff             	lea    -0x1(%eax),%esi
80103d3b:	85 c0                	test   %eax,%eax
80103d3d:	74 1c                	je     80103d5b <memcmp+0x31>
    if(*s1 != *s2)
80103d3f:	0f b6 01             	movzbl (%ecx),%eax
80103d42:	0f b6 1a             	movzbl (%edx),%ebx
80103d45:	38 d8                	cmp    %bl,%al
80103d47:	75 0a                	jne    80103d53 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103d49:	83 c1 01             	add    $0x1,%ecx
80103d4c:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103d4f:	89 f0                	mov    %esi,%eax
80103d51:	eb e5                	jmp    80103d38 <memcmp+0xe>
      return *s1 - *s2;
80103d53:	0f b6 c0             	movzbl %al,%eax
80103d56:	0f b6 db             	movzbl %bl,%ebx
80103d59:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103d5b:	5b                   	pop    %ebx
80103d5c:	5e                   	pop    %esi
80103d5d:	5d                   	pop    %ebp
80103d5e:	c3                   	ret    

80103d5f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103d5f:	55                   	push   %ebp
80103d60:	89 e5                	mov    %esp,%ebp
80103d62:	56                   	push   %esi
80103d63:	53                   	push   %ebx
80103d64:	8b 45 08             	mov    0x8(%ebp),%eax
80103d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d6a:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103d6d:	39 c1                	cmp    %eax,%ecx
80103d6f:	73 3a                	jae    80103dab <memmove+0x4c>
80103d71:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103d74:	39 c3                	cmp    %eax,%ebx
80103d76:	76 37                	jbe    80103daf <memmove+0x50>
    s += n;
    d += n;
80103d78:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103d7b:	eb 0d                	jmp    80103d8a <memmove+0x2b>
      *--d = *--s;
80103d7d:	83 eb 01             	sub    $0x1,%ebx
80103d80:	83 e9 01             	sub    $0x1,%ecx
80103d83:	0f b6 13             	movzbl (%ebx),%edx
80103d86:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103d88:	89 f2                	mov    %esi,%edx
80103d8a:	8d 72 ff             	lea    -0x1(%edx),%esi
80103d8d:	85 d2                	test   %edx,%edx
80103d8f:	75 ec                	jne    80103d7d <memmove+0x1e>
80103d91:	eb 14                	jmp    80103da7 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103d93:	0f b6 11             	movzbl (%ecx),%edx
80103d96:	88 13                	mov    %dl,(%ebx)
80103d98:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103d9b:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103d9e:	89 f2                	mov    %esi,%edx
80103da0:	8d 72 ff             	lea    -0x1(%edx),%esi
80103da3:	85 d2                	test   %edx,%edx
80103da5:	75 ec                	jne    80103d93 <memmove+0x34>

  return dst;
}
80103da7:	5b                   	pop    %ebx
80103da8:	5e                   	pop    %esi
80103da9:	5d                   	pop    %ebp
80103daa:	c3                   	ret    
80103dab:	89 c3                	mov    %eax,%ebx
80103dad:	eb f1                	jmp    80103da0 <memmove+0x41>
80103daf:	89 c3                	mov    %eax,%ebx
80103db1:	eb ed                	jmp    80103da0 <memmove+0x41>

80103db3 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103db3:	55                   	push   %ebp
80103db4:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103db6:	ff 75 10             	pushl  0x10(%ebp)
80103db9:	ff 75 0c             	pushl  0xc(%ebp)
80103dbc:	ff 75 08             	pushl  0x8(%ebp)
80103dbf:	e8 9b ff ff ff       	call   80103d5f <memmove>
}
80103dc4:	c9                   	leave  
80103dc5:	c3                   	ret    

80103dc6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103dc6:	55                   	push   %ebp
80103dc7:	89 e5                	mov    %esp,%ebp
80103dc9:	53                   	push   %ebx
80103dca:	8b 55 08             	mov    0x8(%ebp),%edx
80103dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103dd0:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103dd3:	eb 09                	jmp    80103dde <strncmp+0x18>
    n--, p++, q++;
80103dd5:	83 e8 01             	sub    $0x1,%eax
80103dd8:	83 c2 01             	add    $0x1,%edx
80103ddb:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103dde:	85 c0                	test   %eax,%eax
80103de0:	74 0b                	je     80103ded <strncmp+0x27>
80103de2:	0f b6 1a             	movzbl (%edx),%ebx
80103de5:	84 db                	test   %bl,%bl
80103de7:	74 04                	je     80103ded <strncmp+0x27>
80103de9:	3a 19                	cmp    (%ecx),%bl
80103deb:	74 e8                	je     80103dd5 <strncmp+0xf>
  if(n == 0)
80103ded:	85 c0                	test   %eax,%eax
80103def:	74 0b                	je     80103dfc <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103df1:	0f b6 02             	movzbl (%edx),%eax
80103df4:	0f b6 11             	movzbl (%ecx),%edx
80103df7:	29 d0                	sub    %edx,%eax
}
80103df9:	5b                   	pop    %ebx
80103dfa:	5d                   	pop    %ebp
80103dfb:	c3                   	ret    
    return 0;
80103dfc:	b8 00 00 00 00       	mov    $0x0,%eax
80103e01:	eb f6                	jmp    80103df9 <strncmp+0x33>

80103e03 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103e03:	55                   	push   %ebp
80103e04:	89 e5                	mov    %esp,%ebp
80103e06:	57                   	push   %edi
80103e07:	56                   	push   %esi
80103e08:	53                   	push   %ebx
80103e09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e12:	eb 04                	jmp    80103e18 <strncpy+0x15>
80103e14:	89 fb                	mov    %edi,%ebx
80103e16:	89 f0                	mov    %esi,%eax
80103e18:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e1b:	85 c9                	test   %ecx,%ecx
80103e1d:	7e 1d                	jle    80103e3c <strncpy+0x39>
80103e1f:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e22:	8d 70 01             	lea    0x1(%eax),%esi
80103e25:	0f b6 1b             	movzbl (%ebx),%ebx
80103e28:	88 18                	mov    %bl,(%eax)
80103e2a:	89 d1                	mov    %edx,%ecx
80103e2c:	84 db                	test   %bl,%bl
80103e2e:	75 e4                	jne    80103e14 <strncpy+0x11>
80103e30:	89 f0                	mov    %esi,%eax
80103e32:	eb 08                	jmp    80103e3c <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103e34:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103e37:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103e39:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103e3c:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103e3f:	85 d2                	test   %edx,%edx
80103e41:	7f f1                	jg     80103e34 <strncpy+0x31>
  return os;
}
80103e43:	8b 45 08             	mov    0x8(%ebp),%eax
80103e46:	5b                   	pop    %ebx
80103e47:	5e                   	pop    %esi
80103e48:	5f                   	pop    %edi
80103e49:	5d                   	pop    %ebp
80103e4a:	c3                   	ret    

80103e4b <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103e4b:	55                   	push   %ebp
80103e4c:	89 e5                	mov    %esp,%ebp
80103e4e:	57                   	push   %edi
80103e4f:	56                   	push   %esi
80103e50:	53                   	push   %ebx
80103e51:	8b 45 08             	mov    0x8(%ebp),%eax
80103e54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e57:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103e5a:	85 d2                	test   %edx,%edx
80103e5c:	7e 23                	jle    80103e81 <safestrcpy+0x36>
80103e5e:	89 c1                	mov    %eax,%ecx
80103e60:	eb 04                	jmp    80103e66 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103e62:	89 fb                	mov    %edi,%ebx
80103e64:	89 f1                	mov    %esi,%ecx
80103e66:	83 ea 01             	sub    $0x1,%edx
80103e69:	85 d2                	test   %edx,%edx
80103e6b:	7e 11                	jle    80103e7e <safestrcpy+0x33>
80103e6d:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e70:	8d 71 01             	lea    0x1(%ecx),%esi
80103e73:	0f b6 1b             	movzbl (%ebx),%ebx
80103e76:	88 19                	mov    %bl,(%ecx)
80103e78:	84 db                	test   %bl,%bl
80103e7a:	75 e6                	jne    80103e62 <safestrcpy+0x17>
80103e7c:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103e7e:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103e81:	5b                   	pop    %ebx
80103e82:	5e                   	pop    %esi
80103e83:	5f                   	pop    %edi
80103e84:	5d                   	pop    %ebp
80103e85:	c3                   	ret    

80103e86 <strlen>:

int
strlen(const char *s)
{
80103e86:	55                   	push   %ebp
80103e87:	89 e5                	mov    %esp,%ebp
80103e89:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103e8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103e91:	eb 03                	jmp    80103e96 <strlen+0x10>
80103e93:	83 c0 01             	add    $0x1,%eax
80103e96:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103e9a:	75 f7                	jne    80103e93 <strlen+0xd>
    ;
  return n;
}
80103e9c:	5d                   	pop    %ebp
80103e9d:	c3                   	ret    

80103e9e <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103e9e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103ea2:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103ea6:	55                   	push   %ebp
  pushl %ebx
80103ea7:	53                   	push   %ebx
  pushl %esi
80103ea8:	56                   	push   %esi
  pushl %edi
80103ea9:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103eaa:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103eac:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103eae:	5f                   	pop    %edi
  popl %esi
80103eaf:	5e                   	pop    %esi
  popl %ebx
80103eb0:	5b                   	pop    %ebx
  popl %ebp
80103eb1:	5d                   	pop    %ebp
  ret
80103eb2:	c3                   	ret    

80103eb3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103eb3:	55                   	push   %ebp
80103eb4:	89 e5                	mov    %esp,%ebp
80103eb6:	53                   	push   %ebx
80103eb7:	83 ec 04             	sub    $0x4,%esp
80103eba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ebd:	e8 78 f3 ff ff       	call   8010323a <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103ec2:	8b 00                	mov    (%eax),%eax
80103ec4:	39 d8                	cmp    %ebx,%eax
80103ec6:	76 19                	jbe    80103ee1 <fetchint+0x2e>
80103ec8:	8d 53 04             	lea    0x4(%ebx),%edx
80103ecb:	39 d0                	cmp    %edx,%eax
80103ecd:	72 19                	jb     80103ee8 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103ecf:	8b 13                	mov    (%ebx),%edx
80103ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed4:	89 10                	mov    %edx,(%eax)
  return 0;
80103ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103edb:	83 c4 04             	add    $0x4,%esp
80103ede:	5b                   	pop    %ebx
80103edf:	5d                   	pop    %ebp
80103ee0:	c3                   	ret    
    return -1;
80103ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee6:	eb f3                	jmp    80103edb <fetchint+0x28>
80103ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eed:	eb ec                	jmp    80103edb <fetchint+0x28>

80103eef <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103eef:	55                   	push   %ebp
80103ef0:	89 e5                	mov    %esp,%ebp
80103ef2:	53                   	push   %ebx
80103ef3:	83 ec 04             	sub    $0x4,%esp
80103ef6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103ef9:	e8 3c f3 ff ff       	call   8010323a <myproc>

  if(addr >= curproc->sz)
80103efe:	39 18                	cmp    %ebx,(%eax)
80103f00:	76 26                	jbe    80103f28 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103f02:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f05:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103f07:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103f09:	89 d8                	mov    %ebx,%eax
80103f0b:	39 d0                	cmp    %edx,%eax
80103f0d:	73 0e                	jae    80103f1d <fetchstr+0x2e>
    if(*s == 0)
80103f0f:	80 38 00             	cmpb   $0x0,(%eax)
80103f12:	74 05                	je     80103f19 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103f14:	83 c0 01             	add    $0x1,%eax
80103f17:	eb f2                	jmp    80103f0b <fetchstr+0x1c>
      return s - *pp;
80103f19:	29 d8                	sub    %ebx,%eax
80103f1b:	eb 05                	jmp    80103f22 <fetchstr+0x33>
  }
  return -1;
80103f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f22:	83 c4 04             	add    $0x4,%esp
80103f25:	5b                   	pop    %ebx
80103f26:	5d                   	pop    %ebp
80103f27:	c3                   	ret    
    return -1;
80103f28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f2d:	eb f3                	jmp    80103f22 <fetchstr+0x33>

80103f2f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103f2f:	55                   	push   %ebp
80103f30:	89 e5                	mov    %esp,%ebp
80103f32:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103f35:	e8 00 f3 ff ff       	call   8010323a <myproc>
80103f3a:	8b 50 18             	mov    0x18(%eax),%edx
80103f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f40:	c1 e0 02             	shl    $0x2,%eax
80103f43:	03 42 44             	add    0x44(%edx),%eax
80103f46:	83 ec 08             	sub    $0x8,%esp
80103f49:	ff 75 0c             	pushl  0xc(%ebp)
80103f4c:	83 c0 04             	add    $0x4,%eax
80103f4f:	50                   	push   %eax
80103f50:	e8 5e ff ff ff       	call   80103eb3 <fetchint>
}
80103f55:	c9                   	leave  
80103f56:	c3                   	ret    

80103f57 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103f57:	55                   	push   %ebp
80103f58:	89 e5                	mov    %esp,%ebp
80103f5a:	56                   	push   %esi
80103f5b:	53                   	push   %ebx
80103f5c:	83 ec 10             	sub    $0x10,%esp
80103f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103f62:	e8 d3 f2 ff ff       	call   8010323a <myproc>
80103f67:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103f69:	83 ec 08             	sub    $0x8,%esp
80103f6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f6f:	50                   	push   %eax
80103f70:	ff 75 08             	pushl  0x8(%ebp)
80103f73:	e8 b7 ff ff ff       	call   80103f2f <argint>
80103f78:	83 c4 10             	add    $0x10,%esp
80103f7b:	85 c0                	test   %eax,%eax
80103f7d:	78 24                	js     80103fa3 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103f7f:	85 db                	test   %ebx,%ebx
80103f81:	78 27                	js     80103faa <argptr+0x53>
80103f83:	8b 16                	mov    (%esi),%edx
80103f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f88:	39 c2                	cmp    %eax,%edx
80103f8a:	76 25                	jbe    80103fb1 <argptr+0x5a>
80103f8c:	01 c3                	add    %eax,%ebx
80103f8e:	39 da                	cmp    %ebx,%edx
80103f90:	72 26                	jb     80103fb8 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103f92:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f95:	89 02                	mov    %eax,(%edx)
  return 0;
80103f97:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f9f:	5b                   	pop    %ebx
80103fa0:	5e                   	pop    %esi
80103fa1:	5d                   	pop    %ebp
80103fa2:	c3                   	ret    
    return -1;
80103fa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa8:	eb f2                	jmp    80103f9c <argptr+0x45>
    return -1;
80103faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103faf:	eb eb                	jmp    80103f9c <argptr+0x45>
80103fb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fb6:	eb e4                	jmp    80103f9c <argptr+0x45>
80103fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fbd:	eb dd                	jmp    80103f9c <argptr+0x45>

80103fbf <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103fbf:	55                   	push   %ebp
80103fc0:	89 e5                	mov    %esp,%ebp
80103fc2:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fc8:	50                   	push   %eax
80103fc9:	ff 75 08             	pushl  0x8(%ebp)
80103fcc:	e8 5e ff ff ff       	call   80103f2f <argint>
80103fd1:	83 c4 10             	add    $0x10,%esp
80103fd4:	85 c0                	test   %eax,%eax
80103fd6:	78 13                	js     80103feb <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103fd8:	83 ec 08             	sub    $0x8,%esp
80103fdb:	ff 75 0c             	pushl  0xc(%ebp)
80103fde:	ff 75 f4             	pushl  -0xc(%ebp)
80103fe1:	e8 09 ff ff ff       	call   80103eef <fetchstr>
80103fe6:	83 c4 10             	add    $0x10,%esp
}
80103fe9:	c9                   	leave  
80103fea:	c3                   	ret    
    return -1;
80103feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff0:	eb f7                	jmp    80103fe9 <argstr+0x2a>

80103ff2 <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
80103ff2:	55                   	push   %ebp
80103ff3:	89 e5                	mov    %esp,%ebp
80103ff5:	53                   	push   %ebx
80103ff6:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103ff9:	e8 3c f2 ff ff       	call   8010323a <myproc>
80103ffe:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104000:	8b 40 18             	mov    0x18(%eax),%eax
80104003:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104006:	8d 50 ff             	lea    -0x1(%eax),%edx
80104009:	83 fa 15             	cmp    $0x15,%edx
8010400c:	77 18                	ja     80104026 <syscall+0x34>
8010400e:	8b 14 85 20 6c 10 80 	mov    -0x7fef93e0(,%eax,4),%edx
80104015:	85 d2                	test   %edx,%edx
80104017:	74 0d                	je     80104026 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104019:	ff d2                	call   *%edx
8010401b:	8b 53 18             	mov    0x18(%ebx),%edx
8010401e:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104021:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104024:	c9                   	leave  
80104025:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104026:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104029:	50                   	push   %eax
8010402a:	52                   	push   %edx
8010402b:	ff 73 10             	pushl  0x10(%ebx)
8010402e:	68 f1 6b 10 80       	push   $0x80106bf1
80104033:	e8 d3 c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104038:	8b 43 18             	mov    0x18(%ebx),%eax
8010403b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104042:	83 c4 10             	add    $0x10,%esp
}
80104045:	eb da                	jmp    80104021 <syscall+0x2f>

80104047 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104047:	55                   	push   %ebp
80104048:	89 e5                	mov    %esp,%ebp
8010404a:	56                   	push   %esi
8010404b:	53                   	push   %ebx
8010404c:	83 ec 18             	sub    $0x18,%esp
8010404f:	89 d6                	mov    %edx,%esi
80104051:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104053:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104056:	52                   	push   %edx
80104057:	50                   	push   %eax
80104058:	e8 d2 fe ff ff       	call   80103f2f <argint>
8010405d:	83 c4 10             	add    $0x10,%esp
80104060:	85 c0                	test   %eax,%eax
80104062:	78 2e                	js     80104092 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104064:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104068:	77 2f                	ja     80104099 <argfd+0x52>
8010406a:	e8 cb f1 ff ff       	call   8010323a <myproc>
8010406f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104072:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104076:	85 c0                	test   %eax,%eax
80104078:	74 26                	je     801040a0 <argfd+0x59>
    return -1;
  if(pfd)
8010407a:	85 f6                	test   %esi,%esi
8010407c:	74 02                	je     80104080 <argfd+0x39>
    *pfd = fd;
8010407e:	89 16                	mov    %edx,(%esi)
  if(pf)
80104080:	85 db                	test   %ebx,%ebx
80104082:	74 23                	je     801040a7 <argfd+0x60>
    *pf = f;
80104084:	89 03                	mov    %eax,(%ebx)
  return 0;
80104086:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010408b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010408e:	5b                   	pop    %ebx
8010408f:	5e                   	pop    %esi
80104090:	5d                   	pop    %ebp
80104091:	c3                   	ret    
    return -1;
80104092:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104097:	eb f2                	jmp    8010408b <argfd+0x44>
    return -1;
80104099:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010409e:	eb eb                	jmp    8010408b <argfd+0x44>
801040a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a5:	eb e4                	jmp    8010408b <argfd+0x44>
  return 0;
801040a7:	b8 00 00 00 00       	mov    $0x0,%eax
801040ac:	eb dd                	jmp    8010408b <argfd+0x44>

801040ae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801040ae:	55                   	push   %ebp
801040af:	89 e5                	mov    %esp,%ebp
801040b1:	53                   	push   %ebx
801040b2:	83 ec 04             	sub    $0x4,%esp
801040b5:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801040b7:	e8 7e f1 ff ff       	call   8010323a <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801040bc:	ba 00 00 00 00       	mov    $0x0,%edx
801040c1:	83 fa 0f             	cmp    $0xf,%edx
801040c4:	7f 18                	jg     801040de <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801040c6:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801040cb:	74 05                	je     801040d2 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801040cd:	83 c2 01             	add    $0x1,%edx
801040d0:	eb ef                	jmp    801040c1 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801040d2:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801040d6:	89 d0                	mov    %edx,%eax
801040d8:	83 c4 04             	add    $0x4,%esp
801040db:	5b                   	pop    %ebx
801040dc:	5d                   	pop    %ebp
801040dd:	c3                   	ret    
  return -1;
801040de:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801040e3:	eb f1                	jmp    801040d6 <fdalloc+0x28>

801040e5 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801040e5:	55                   	push   %ebp
801040e6:	89 e5                	mov    %esp,%ebp
801040e8:	56                   	push   %esi
801040e9:	53                   	push   %ebx
801040ea:	83 ec 10             	sub    $0x10,%esp
801040ed:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801040ef:	b8 20 00 00 00       	mov    $0x20,%eax
801040f4:	89 c6                	mov    %eax,%esi
801040f6:	39 43 58             	cmp    %eax,0x58(%ebx)
801040f9:	76 2e                	jbe    80104129 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801040fb:	6a 10                	push   $0x10
801040fd:	50                   	push   %eax
801040fe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104101:	50                   	push   %eax
80104102:	53                   	push   %ebx
80104103:	e8 6b d6 ff ff       	call   80101773 <readi>
80104108:	83 c4 10             	add    $0x10,%esp
8010410b:	83 f8 10             	cmp    $0x10,%eax
8010410e:	75 0c                	jne    8010411c <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104110:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104115:	75 1e                	jne    80104135 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104117:	8d 46 10             	lea    0x10(%esi),%eax
8010411a:	eb d8                	jmp    801040f4 <isdirempty+0xf>
      panic("isdirempty: readi");
8010411c:	83 ec 0c             	sub    $0xc,%esp
8010411f:	68 7c 6c 10 80       	push   $0x80106c7c
80104124:	e8 1f c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104129:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010412e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104131:	5b                   	pop    %ebx
80104132:	5e                   	pop    %esi
80104133:	5d                   	pop    %ebp
80104134:	c3                   	ret    
      return 0;
80104135:	b8 00 00 00 00       	mov    $0x0,%eax
8010413a:	eb f2                	jmp    8010412e <isdirempty+0x49>

8010413c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
8010413c:	55                   	push   %ebp
8010413d:	89 e5                	mov    %esp,%ebp
8010413f:	57                   	push   %edi
80104140:	56                   	push   %esi
80104141:	53                   	push   %ebx
80104142:	83 ec 44             	sub    $0x44,%esp
80104145:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104148:	89 4d c0             	mov    %ecx,-0x40(%ebp)
8010414b:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010414e:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104151:	52                   	push   %edx
80104152:	50                   	push   %eax
80104153:	e8 a1 da ff ff       	call   80101bf9 <nameiparent>
80104158:	89 c6                	mov    %eax,%esi
8010415a:	83 c4 10             	add    $0x10,%esp
8010415d:	85 c0                	test   %eax,%eax
8010415f:	0f 84 3a 01 00 00    	je     8010429f <create+0x163>
    return 0;
  ilock(dp);
80104165:	83 ec 0c             	sub    $0xc,%esp
80104168:	50                   	push   %eax
80104169:	e8 13 d4 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010416e:	83 c4 0c             	add    $0xc,%esp
80104171:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104174:	50                   	push   %eax
80104175:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104178:	50                   	push   %eax
80104179:	56                   	push   %esi
8010417a:	e8 31 d8 ff ff       	call   801019b0 <dirlookup>
8010417f:	89 c3                	mov    %eax,%ebx
80104181:	83 c4 10             	add    $0x10,%esp
80104184:	85 c0                	test   %eax,%eax
80104186:	74 3f                	je     801041c7 <create+0x8b>
    iunlockput(dp);
80104188:	83 ec 0c             	sub    $0xc,%esp
8010418b:	56                   	push   %esi
8010418c:	e8 97 d5 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
80104191:	89 1c 24             	mov    %ebx,(%esp)
80104194:	e8 e8 d3 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104199:	83 c4 10             	add    $0x10,%esp
8010419c:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801041a1:	75 11                	jne    801041b4 <create+0x78>
801041a3:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041a8:	75 0a                	jne    801041b4 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041aa:	89 d8                	mov    %ebx,%eax
801041ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801041af:	5b                   	pop    %ebx
801041b0:	5e                   	pop    %esi
801041b1:	5f                   	pop    %edi
801041b2:	5d                   	pop    %ebp
801041b3:	c3                   	ret    
    iunlockput(ip);
801041b4:	83 ec 0c             	sub    $0xc,%esp
801041b7:	53                   	push   %ebx
801041b8:	e8 6b d5 ff ff       	call   80101728 <iunlockput>
    return 0;
801041bd:	83 c4 10             	add    $0x10,%esp
801041c0:	bb 00 00 00 00       	mov    $0x0,%ebx
801041c5:	eb e3                	jmp    801041aa <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801041c7:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801041cb:	83 ec 08             	sub    $0x8,%esp
801041ce:	50                   	push   %eax
801041cf:	ff 36                	pushl  (%esi)
801041d1:	e8 a8 d1 ff ff       	call   8010137e <ialloc>
801041d6:	89 c3                	mov    %eax,%ebx
801041d8:	83 c4 10             	add    $0x10,%esp
801041db:	85 c0                	test   %eax,%eax
801041dd:	74 55                	je     80104234 <create+0xf8>
  ilock(ip);
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	50                   	push   %eax
801041e3:	e8 99 d3 ff ff       	call   80101581 <ilock>
  ip->major = major;
801041e8:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801041ec:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801041f0:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801041f4:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801041fa:	89 1c 24             	mov    %ebx,(%esp)
801041fd:	e8 1e d2 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104202:	83 c4 10             	add    $0x10,%esp
80104205:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010420a:	74 35                	je     80104241 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
8010420c:	83 ec 04             	sub    $0x4,%esp
8010420f:	ff 73 04             	pushl  0x4(%ebx)
80104212:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104215:	50                   	push   %eax
80104216:	56                   	push   %esi
80104217:	e8 14 d9 ff ff       	call   80101b30 <dirlink>
8010421c:	83 c4 10             	add    $0x10,%esp
8010421f:	85 c0                	test   %eax,%eax
80104221:	78 6f                	js     80104292 <create+0x156>
  iunlockput(dp);
80104223:	83 ec 0c             	sub    $0xc,%esp
80104226:	56                   	push   %esi
80104227:	e8 fc d4 ff ff       	call   80101728 <iunlockput>
  return ip;
8010422c:	83 c4 10             	add    $0x10,%esp
8010422f:	e9 76 ff ff ff       	jmp    801041aa <create+0x6e>
    panic("create: ialloc");
80104234:	83 ec 0c             	sub    $0xc,%esp
80104237:	68 8e 6c 10 80       	push   $0x80106c8e
8010423c:	e8 07 c1 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104241:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104245:	83 c0 01             	add    $0x1,%eax
80104248:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010424c:	83 ec 0c             	sub    $0xc,%esp
8010424f:	56                   	push   %esi
80104250:	e8 cb d1 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104255:	83 c4 0c             	add    $0xc,%esp
80104258:	ff 73 04             	pushl  0x4(%ebx)
8010425b:	68 9e 6c 10 80       	push   $0x80106c9e
80104260:	53                   	push   %ebx
80104261:	e8 ca d8 ff ff       	call   80101b30 <dirlink>
80104266:	83 c4 10             	add    $0x10,%esp
80104269:	85 c0                	test   %eax,%eax
8010426b:	78 18                	js     80104285 <create+0x149>
8010426d:	83 ec 04             	sub    $0x4,%esp
80104270:	ff 76 04             	pushl  0x4(%esi)
80104273:	68 9d 6c 10 80       	push   $0x80106c9d
80104278:	53                   	push   %ebx
80104279:	e8 b2 d8 ff ff       	call   80101b30 <dirlink>
8010427e:	83 c4 10             	add    $0x10,%esp
80104281:	85 c0                	test   %eax,%eax
80104283:	79 87                	jns    8010420c <create+0xd0>
      panic("create dots");
80104285:	83 ec 0c             	sub    $0xc,%esp
80104288:	68 a0 6c 10 80       	push   $0x80106ca0
8010428d:	e8 b6 c0 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104292:	83 ec 0c             	sub    $0xc,%esp
80104295:	68 ac 6c 10 80       	push   $0x80106cac
8010429a:	e8 a9 c0 ff ff       	call   80100348 <panic>
    return 0;
8010429f:	89 c3                	mov    %eax,%ebx
801042a1:	e9 04 ff ff ff       	jmp    801041aa <create+0x6e>

801042a6 <sys_dup>:
{
801042a6:	55                   	push   %ebp
801042a7:	89 e5                	mov    %esp,%ebp
801042a9:	53                   	push   %ebx
801042aa:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801042ad:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042b0:	ba 00 00 00 00       	mov    $0x0,%edx
801042b5:	b8 00 00 00 00       	mov    $0x0,%eax
801042ba:	e8 88 fd ff ff       	call   80104047 <argfd>
801042bf:	85 c0                	test   %eax,%eax
801042c1:	78 23                	js     801042e6 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801042c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c6:	e8 e3 fd ff ff       	call   801040ae <fdalloc>
801042cb:	89 c3                	mov    %eax,%ebx
801042cd:	85 c0                	test   %eax,%eax
801042cf:	78 1c                	js     801042ed <sys_dup+0x47>
  filedup(f);
801042d1:	83 ec 0c             	sub    $0xc,%esp
801042d4:	ff 75 f4             	pushl  -0xc(%ebp)
801042d7:	e8 b2 c9 ff ff       	call   80100c8e <filedup>
  return fd;
801042dc:	83 c4 10             	add    $0x10,%esp
}
801042df:	89 d8                	mov    %ebx,%eax
801042e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042e4:	c9                   	leave  
801042e5:	c3                   	ret    
    return -1;
801042e6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042eb:	eb f2                	jmp    801042df <sys_dup+0x39>
    return -1;
801042ed:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042f2:	eb eb                	jmp    801042df <sys_dup+0x39>

801042f4 <sys_read>:
{
801042f4:	55                   	push   %ebp
801042f5:	89 e5                	mov    %esp,%ebp
801042f7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801042fa:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042fd:	ba 00 00 00 00       	mov    $0x0,%edx
80104302:	b8 00 00 00 00       	mov    $0x0,%eax
80104307:	e8 3b fd ff ff       	call   80104047 <argfd>
8010430c:	85 c0                	test   %eax,%eax
8010430e:	78 43                	js     80104353 <sys_read+0x5f>
80104310:	83 ec 08             	sub    $0x8,%esp
80104313:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104316:	50                   	push   %eax
80104317:	6a 02                	push   $0x2
80104319:	e8 11 fc ff ff       	call   80103f2f <argint>
8010431e:	83 c4 10             	add    $0x10,%esp
80104321:	85 c0                	test   %eax,%eax
80104323:	78 35                	js     8010435a <sys_read+0x66>
80104325:	83 ec 04             	sub    $0x4,%esp
80104328:	ff 75 f0             	pushl  -0x10(%ebp)
8010432b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010432e:	50                   	push   %eax
8010432f:	6a 01                	push   $0x1
80104331:	e8 21 fc ff ff       	call   80103f57 <argptr>
80104336:	83 c4 10             	add    $0x10,%esp
80104339:	85 c0                	test   %eax,%eax
8010433b:	78 24                	js     80104361 <sys_read+0x6d>
  return fileread(f, p, n);
8010433d:	83 ec 04             	sub    $0x4,%esp
80104340:	ff 75 f0             	pushl  -0x10(%ebp)
80104343:	ff 75 ec             	pushl  -0x14(%ebp)
80104346:	ff 75 f4             	pushl  -0xc(%ebp)
80104349:	e8 89 ca ff ff       	call   80100dd7 <fileread>
8010434e:	83 c4 10             	add    $0x10,%esp
}
80104351:	c9                   	leave  
80104352:	c3                   	ret    
    return -1;
80104353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104358:	eb f7                	jmp    80104351 <sys_read+0x5d>
8010435a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010435f:	eb f0                	jmp    80104351 <sys_read+0x5d>
80104361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104366:	eb e9                	jmp    80104351 <sys_read+0x5d>

80104368 <sys_write>:
{
80104368:	55                   	push   %ebp
80104369:	89 e5                	mov    %esp,%ebp
8010436b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010436e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104371:	ba 00 00 00 00       	mov    $0x0,%edx
80104376:	b8 00 00 00 00       	mov    $0x0,%eax
8010437b:	e8 c7 fc ff ff       	call   80104047 <argfd>
80104380:	85 c0                	test   %eax,%eax
80104382:	78 43                	js     801043c7 <sys_write+0x5f>
80104384:	83 ec 08             	sub    $0x8,%esp
80104387:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010438a:	50                   	push   %eax
8010438b:	6a 02                	push   $0x2
8010438d:	e8 9d fb ff ff       	call   80103f2f <argint>
80104392:	83 c4 10             	add    $0x10,%esp
80104395:	85 c0                	test   %eax,%eax
80104397:	78 35                	js     801043ce <sys_write+0x66>
80104399:	83 ec 04             	sub    $0x4,%esp
8010439c:	ff 75 f0             	pushl  -0x10(%ebp)
8010439f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043a2:	50                   	push   %eax
801043a3:	6a 01                	push   $0x1
801043a5:	e8 ad fb ff ff       	call   80103f57 <argptr>
801043aa:	83 c4 10             	add    $0x10,%esp
801043ad:	85 c0                	test   %eax,%eax
801043af:	78 24                	js     801043d5 <sys_write+0x6d>
  return filewrite(f, p, n);
801043b1:	83 ec 04             	sub    $0x4,%esp
801043b4:	ff 75 f0             	pushl  -0x10(%ebp)
801043b7:	ff 75 ec             	pushl  -0x14(%ebp)
801043ba:	ff 75 f4             	pushl  -0xc(%ebp)
801043bd:	e8 9a ca ff ff       	call   80100e5c <filewrite>
801043c2:	83 c4 10             	add    $0x10,%esp
}
801043c5:	c9                   	leave  
801043c6:	c3                   	ret    
    return -1;
801043c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043cc:	eb f7                	jmp    801043c5 <sys_write+0x5d>
801043ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d3:	eb f0                	jmp    801043c5 <sys_write+0x5d>
801043d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043da:	eb e9                	jmp    801043c5 <sys_write+0x5d>

801043dc <sys_close>:
{
801043dc:	55                   	push   %ebp
801043dd:	89 e5                	mov    %esp,%ebp
801043df:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801043e2:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801043e5:	8d 55 f4             	lea    -0xc(%ebp),%edx
801043e8:	b8 00 00 00 00       	mov    $0x0,%eax
801043ed:	e8 55 fc ff ff       	call   80104047 <argfd>
801043f2:	85 c0                	test   %eax,%eax
801043f4:	78 25                	js     8010441b <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801043f6:	e8 3f ee ff ff       	call   8010323a <myproc>
801043fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043fe:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104405:	00 
  fileclose(f);
80104406:	83 ec 0c             	sub    $0xc,%esp
80104409:	ff 75 f0             	pushl  -0x10(%ebp)
8010440c:	e8 c2 c8 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104411:	83 c4 10             	add    $0x10,%esp
80104414:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104419:	c9                   	leave  
8010441a:	c3                   	ret    
    return -1;
8010441b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104420:	eb f7                	jmp    80104419 <sys_close+0x3d>

80104422 <sys_fstat>:
{
80104422:	55                   	push   %ebp
80104423:	89 e5                	mov    %esp,%ebp
80104425:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104428:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010442b:	ba 00 00 00 00       	mov    $0x0,%edx
80104430:	b8 00 00 00 00       	mov    $0x0,%eax
80104435:	e8 0d fc ff ff       	call   80104047 <argfd>
8010443a:	85 c0                	test   %eax,%eax
8010443c:	78 2a                	js     80104468 <sys_fstat+0x46>
8010443e:	83 ec 04             	sub    $0x4,%esp
80104441:	6a 14                	push   $0x14
80104443:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104446:	50                   	push   %eax
80104447:	6a 01                	push   $0x1
80104449:	e8 09 fb ff ff       	call   80103f57 <argptr>
8010444e:	83 c4 10             	add    $0x10,%esp
80104451:	85 c0                	test   %eax,%eax
80104453:	78 1a                	js     8010446f <sys_fstat+0x4d>
  return filestat(f, st);
80104455:	83 ec 08             	sub    $0x8,%esp
80104458:	ff 75 f0             	pushl  -0x10(%ebp)
8010445b:	ff 75 f4             	pushl  -0xc(%ebp)
8010445e:	e8 2d c9 ff ff       	call   80100d90 <filestat>
80104463:	83 c4 10             	add    $0x10,%esp
}
80104466:	c9                   	leave  
80104467:	c3                   	ret    
    return -1;
80104468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010446d:	eb f7                	jmp    80104466 <sys_fstat+0x44>
8010446f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104474:	eb f0                	jmp    80104466 <sys_fstat+0x44>

80104476 <sys_link>:
{
80104476:	55                   	push   %ebp
80104477:	89 e5                	mov    %esp,%ebp
80104479:	56                   	push   %esi
8010447a:	53                   	push   %ebx
8010447b:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010447e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104481:	50                   	push   %eax
80104482:	6a 00                	push   $0x0
80104484:	e8 36 fb ff ff       	call   80103fbf <argstr>
80104489:	83 c4 10             	add    $0x10,%esp
8010448c:	85 c0                	test   %eax,%eax
8010448e:	0f 88 32 01 00 00    	js     801045c6 <sys_link+0x150>
80104494:	83 ec 08             	sub    $0x8,%esp
80104497:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010449a:	50                   	push   %eax
8010449b:	6a 01                	push   $0x1
8010449d:	e8 1d fb ff ff       	call   80103fbf <argstr>
801044a2:	83 c4 10             	add    $0x10,%esp
801044a5:	85 c0                	test   %eax,%eax
801044a7:	0f 88 20 01 00 00    	js     801045cd <sys_link+0x157>
  begin_op();
801044ad:	e8 0d e3 ff ff       	call   801027bf <begin_op>
  if((ip = namei(old)) == 0){
801044b2:	83 ec 0c             	sub    $0xc,%esp
801044b5:	ff 75 e0             	pushl  -0x20(%ebp)
801044b8:	e8 24 d7 ff ff       	call   80101be1 <namei>
801044bd:	89 c3                	mov    %eax,%ebx
801044bf:	83 c4 10             	add    $0x10,%esp
801044c2:	85 c0                	test   %eax,%eax
801044c4:	0f 84 99 00 00 00    	je     80104563 <sys_link+0xed>
  ilock(ip);
801044ca:	83 ec 0c             	sub    $0xc,%esp
801044cd:	50                   	push   %eax
801044ce:	e8 ae d0 ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801044d3:	83 c4 10             	add    $0x10,%esp
801044d6:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801044db:	0f 84 8e 00 00 00    	je     8010456f <sys_link+0xf9>
  ip->nlink++;
801044e1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801044e5:	83 c0 01             	add    $0x1,%eax
801044e8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044ec:	83 ec 0c             	sub    $0xc,%esp
801044ef:	53                   	push   %ebx
801044f0:	e8 2b cf ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801044f5:	89 1c 24             	mov    %ebx,(%esp)
801044f8:	e8 46 d1 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801044fd:	83 c4 08             	add    $0x8,%esp
80104500:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104503:	50                   	push   %eax
80104504:	ff 75 e4             	pushl  -0x1c(%ebp)
80104507:	e8 ed d6 ff ff       	call   80101bf9 <nameiparent>
8010450c:	89 c6                	mov    %eax,%esi
8010450e:	83 c4 10             	add    $0x10,%esp
80104511:	85 c0                	test   %eax,%eax
80104513:	74 7e                	je     80104593 <sys_link+0x11d>
  ilock(dp);
80104515:	83 ec 0c             	sub    $0xc,%esp
80104518:	50                   	push   %eax
80104519:	e8 63 d0 ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010451e:	83 c4 10             	add    $0x10,%esp
80104521:	8b 03                	mov    (%ebx),%eax
80104523:	39 06                	cmp    %eax,(%esi)
80104525:	75 60                	jne    80104587 <sys_link+0x111>
80104527:	83 ec 04             	sub    $0x4,%esp
8010452a:	ff 73 04             	pushl  0x4(%ebx)
8010452d:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104530:	50                   	push   %eax
80104531:	56                   	push   %esi
80104532:	e8 f9 d5 ff ff       	call   80101b30 <dirlink>
80104537:	83 c4 10             	add    $0x10,%esp
8010453a:	85 c0                	test   %eax,%eax
8010453c:	78 49                	js     80104587 <sys_link+0x111>
  iunlockput(dp);
8010453e:	83 ec 0c             	sub    $0xc,%esp
80104541:	56                   	push   %esi
80104542:	e8 e1 d1 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104547:	89 1c 24             	mov    %ebx,(%esp)
8010454a:	e8 39 d1 ff ff       	call   80101688 <iput>
  end_op();
8010454f:	e8 e5 e2 ff ff       	call   80102839 <end_op>
  return 0;
80104554:	83 c4 10             	add    $0x10,%esp
80104557:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010455c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010455f:	5b                   	pop    %ebx
80104560:	5e                   	pop    %esi
80104561:	5d                   	pop    %ebp
80104562:	c3                   	ret    
    end_op();
80104563:	e8 d1 e2 ff ff       	call   80102839 <end_op>
    return -1;
80104568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010456d:	eb ed                	jmp    8010455c <sys_link+0xe6>
    iunlockput(ip);
8010456f:	83 ec 0c             	sub    $0xc,%esp
80104572:	53                   	push   %ebx
80104573:	e8 b0 d1 ff ff       	call   80101728 <iunlockput>
    end_op();
80104578:	e8 bc e2 ff ff       	call   80102839 <end_op>
    return -1;
8010457d:	83 c4 10             	add    $0x10,%esp
80104580:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104585:	eb d5                	jmp    8010455c <sys_link+0xe6>
    iunlockput(dp);
80104587:	83 ec 0c             	sub    $0xc,%esp
8010458a:	56                   	push   %esi
8010458b:	e8 98 d1 ff ff       	call   80101728 <iunlockput>
    goto bad;
80104590:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104593:	83 ec 0c             	sub    $0xc,%esp
80104596:	53                   	push   %ebx
80104597:	e8 e5 cf ff ff       	call   80101581 <ilock>
  ip->nlink--;
8010459c:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045a0:	83 e8 01             	sub    $0x1,%eax
801045a3:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045a7:	89 1c 24             	mov    %ebx,(%esp)
801045aa:	e8 71 ce ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801045af:	89 1c 24             	mov    %ebx,(%esp)
801045b2:	e8 71 d1 ff ff       	call   80101728 <iunlockput>
  end_op();
801045b7:	e8 7d e2 ff ff       	call   80102839 <end_op>
  return -1;
801045bc:	83 c4 10             	add    $0x10,%esp
801045bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c4:	eb 96                	jmp    8010455c <sys_link+0xe6>
    return -1;
801045c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045cb:	eb 8f                	jmp    8010455c <sys_link+0xe6>
801045cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d2:	eb 88                	jmp    8010455c <sys_link+0xe6>

801045d4 <sys_unlink>:
{
801045d4:	55                   	push   %ebp
801045d5:	89 e5                	mov    %esp,%ebp
801045d7:	57                   	push   %edi
801045d8:	56                   	push   %esi
801045d9:	53                   	push   %ebx
801045da:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801045dd:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801045e0:	50                   	push   %eax
801045e1:	6a 00                	push   $0x0
801045e3:	e8 d7 f9 ff ff       	call   80103fbf <argstr>
801045e8:	83 c4 10             	add    $0x10,%esp
801045eb:	85 c0                	test   %eax,%eax
801045ed:	0f 88 83 01 00 00    	js     80104776 <sys_unlink+0x1a2>
  begin_op();
801045f3:	e8 c7 e1 ff ff       	call   801027bf <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801045f8:	83 ec 08             	sub    $0x8,%esp
801045fb:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045fe:	50                   	push   %eax
801045ff:	ff 75 c4             	pushl  -0x3c(%ebp)
80104602:	e8 f2 d5 ff ff       	call   80101bf9 <nameiparent>
80104607:	89 c6                	mov    %eax,%esi
80104609:	83 c4 10             	add    $0x10,%esp
8010460c:	85 c0                	test   %eax,%eax
8010460e:	0f 84 ed 00 00 00    	je     80104701 <sys_unlink+0x12d>
  ilock(dp);
80104614:	83 ec 0c             	sub    $0xc,%esp
80104617:	50                   	push   %eax
80104618:	e8 64 cf ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010461d:	83 c4 08             	add    $0x8,%esp
80104620:	68 9e 6c 10 80       	push   $0x80106c9e
80104625:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104628:	50                   	push   %eax
80104629:	e8 6d d3 ff ff       	call   8010199b <namecmp>
8010462e:	83 c4 10             	add    $0x10,%esp
80104631:	85 c0                	test   %eax,%eax
80104633:	0f 84 fc 00 00 00    	je     80104735 <sys_unlink+0x161>
80104639:	83 ec 08             	sub    $0x8,%esp
8010463c:	68 9d 6c 10 80       	push   $0x80106c9d
80104641:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104644:	50                   	push   %eax
80104645:	e8 51 d3 ff ff       	call   8010199b <namecmp>
8010464a:	83 c4 10             	add    $0x10,%esp
8010464d:	85 c0                	test   %eax,%eax
8010464f:	0f 84 e0 00 00 00    	je     80104735 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104655:	83 ec 04             	sub    $0x4,%esp
80104658:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010465b:	50                   	push   %eax
8010465c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010465f:	50                   	push   %eax
80104660:	56                   	push   %esi
80104661:	e8 4a d3 ff ff       	call   801019b0 <dirlookup>
80104666:	89 c3                	mov    %eax,%ebx
80104668:	83 c4 10             	add    $0x10,%esp
8010466b:	85 c0                	test   %eax,%eax
8010466d:	0f 84 c2 00 00 00    	je     80104735 <sys_unlink+0x161>
  ilock(ip);
80104673:	83 ec 0c             	sub    $0xc,%esp
80104676:	50                   	push   %eax
80104677:	e8 05 cf ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
8010467c:	83 c4 10             	add    $0x10,%esp
8010467f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104684:	0f 8e 83 00 00 00    	jle    8010470d <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010468a:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010468f:	0f 84 85 00 00 00    	je     8010471a <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104695:	83 ec 04             	sub    $0x4,%esp
80104698:	6a 10                	push   $0x10
8010469a:	6a 00                	push   $0x0
8010469c:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010469f:	57                   	push   %edi
801046a0:	e8 3f f6 ff ff       	call   80103ce4 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046a5:	6a 10                	push   $0x10
801046a7:	ff 75 c0             	pushl  -0x40(%ebp)
801046aa:	57                   	push   %edi
801046ab:	56                   	push   %esi
801046ac:	e8 bf d1 ff ff       	call   80101870 <writei>
801046b1:	83 c4 20             	add    $0x20,%esp
801046b4:	83 f8 10             	cmp    $0x10,%eax
801046b7:	0f 85 90 00 00 00    	jne    8010474d <sys_unlink+0x179>
  if(ip->type == T_DIR){
801046bd:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046c2:	0f 84 92 00 00 00    	je     8010475a <sys_unlink+0x186>
  iunlockput(dp);
801046c8:	83 ec 0c             	sub    $0xc,%esp
801046cb:	56                   	push   %esi
801046cc:	e8 57 d0 ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801046d1:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046d5:	83 e8 01             	sub    $0x1,%eax
801046d8:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046dc:	89 1c 24             	mov    %ebx,(%esp)
801046df:	e8 3c cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801046e4:	89 1c 24             	mov    %ebx,(%esp)
801046e7:	e8 3c d0 ff ff       	call   80101728 <iunlockput>
  end_op();
801046ec:	e8 48 e1 ff ff       	call   80102839 <end_op>
  return 0;
801046f1:	83 c4 10             	add    $0x10,%esp
801046f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046fc:	5b                   	pop    %ebx
801046fd:	5e                   	pop    %esi
801046fe:	5f                   	pop    %edi
801046ff:	5d                   	pop    %ebp
80104700:	c3                   	ret    
    end_op();
80104701:	e8 33 e1 ff ff       	call   80102839 <end_op>
    return -1;
80104706:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010470b:	eb ec                	jmp    801046f9 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
8010470d:	83 ec 0c             	sub    $0xc,%esp
80104710:	68 bc 6c 10 80       	push   $0x80106cbc
80104715:	e8 2e bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010471a:	89 d8                	mov    %ebx,%eax
8010471c:	e8 c4 f9 ff ff       	call   801040e5 <isdirempty>
80104721:	85 c0                	test   %eax,%eax
80104723:	0f 85 6c ff ff ff    	jne    80104695 <sys_unlink+0xc1>
    iunlockput(ip);
80104729:	83 ec 0c             	sub    $0xc,%esp
8010472c:	53                   	push   %ebx
8010472d:	e8 f6 cf ff ff       	call   80101728 <iunlockput>
    goto bad;
80104732:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104735:	83 ec 0c             	sub    $0xc,%esp
80104738:	56                   	push   %esi
80104739:	e8 ea cf ff ff       	call   80101728 <iunlockput>
  end_op();
8010473e:	e8 f6 e0 ff ff       	call   80102839 <end_op>
  return -1;
80104743:	83 c4 10             	add    $0x10,%esp
80104746:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474b:	eb ac                	jmp    801046f9 <sys_unlink+0x125>
    panic("unlink: writei");
8010474d:	83 ec 0c             	sub    $0xc,%esp
80104750:	68 ce 6c 10 80       	push   $0x80106cce
80104755:	e8 ee bb ff ff       	call   80100348 <panic>
    dp->nlink--;
8010475a:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010475e:	83 e8 01             	sub    $0x1,%eax
80104761:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	56                   	push   %esi
80104769:	e8 b2 cc ff ff       	call   80101420 <iupdate>
8010476e:	83 c4 10             	add    $0x10,%esp
80104771:	e9 52 ff ff ff       	jmp    801046c8 <sys_unlink+0xf4>
    return -1;
80104776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010477b:	e9 79 ff ff ff       	jmp    801046f9 <sys_unlink+0x125>

80104780 <sys_open>:

int
sys_open(void)
{
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	57                   	push   %edi
80104784:	56                   	push   %esi
80104785:	53                   	push   %ebx
80104786:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104789:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010478c:	50                   	push   %eax
8010478d:	6a 00                	push   $0x0
8010478f:	e8 2b f8 ff ff       	call   80103fbf <argstr>
80104794:	83 c4 10             	add    $0x10,%esp
80104797:	85 c0                	test   %eax,%eax
80104799:	0f 88 30 01 00 00    	js     801048cf <sys_open+0x14f>
8010479f:	83 ec 08             	sub    $0x8,%esp
801047a2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801047a5:	50                   	push   %eax
801047a6:	6a 01                	push   $0x1
801047a8:	e8 82 f7 ff ff       	call   80103f2f <argint>
801047ad:	83 c4 10             	add    $0x10,%esp
801047b0:	85 c0                	test   %eax,%eax
801047b2:	0f 88 21 01 00 00    	js     801048d9 <sys_open+0x159>
    return -1;

  begin_op();
801047b8:	e8 02 e0 ff ff       	call   801027bf <begin_op>

  if(omode & O_CREATE){
801047bd:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801047c1:	0f 84 84 00 00 00    	je     8010484b <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801047c7:	83 ec 0c             	sub    $0xc,%esp
801047ca:	6a 00                	push   $0x0
801047cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801047d1:	ba 02 00 00 00       	mov    $0x2,%edx
801047d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047d9:	e8 5e f9 ff ff       	call   8010413c <create>
801047de:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801047e0:	83 c4 10             	add    $0x10,%esp
801047e3:	85 c0                	test   %eax,%eax
801047e5:	74 58                	je     8010483f <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801047e7:	e8 41 c4 ff ff       	call   80100c2d <filealloc>
801047ec:	89 c3                	mov    %eax,%ebx
801047ee:	85 c0                	test   %eax,%eax
801047f0:	0f 84 ae 00 00 00    	je     801048a4 <sys_open+0x124>
801047f6:	e8 b3 f8 ff ff       	call   801040ae <fdalloc>
801047fb:	89 c7                	mov    %eax,%edi
801047fd:	85 c0                	test   %eax,%eax
801047ff:	0f 88 9f 00 00 00    	js     801048a4 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104805:	83 ec 0c             	sub    $0xc,%esp
80104808:	56                   	push   %esi
80104809:	e8 35 ce ff ff       	call   80101643 <iunlock>
  end_op();
8010480e:	e8 26 e0 ff ff       	call   80102839 <end_op>

  f->type = FD_INODE;
80104813:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104819:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010481c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104823:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104826:	83 c4 10             	add    $0x10,%esp
80104829:	a8 01                	test   $0x1,%al
8010482b:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010482f:	a8 03                	test   $0x3,%al
80104831:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104835:	89 f8                	mov    %edi,%eax
80104837:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010483a:	5b                   	pop    %ebx
8010483b:	5e                   	pop    %esi
8010483c:	5f                   	pop    %edi
8010483d:	5d                   	pop    %ebp
8010483e:	c3                   	ret    
      end_op();
8010483f:	e8 f5 df ff ff       	call   80102839 <end_op>
      return -1;
80104844:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104849:	eb ea                	jmp    80104835 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
8010484b:	83 ec 0c             	sub    $0xc,%esp
8010484e:	ff 75 e4             	pushl  -0x1c(%ebp)
80104851:	e8 8b d3 ff ff       	call   80101be1 <namei>
80104856:	89 c6                	mov    %eax,%esi
80104858:	83 c4 10             	add    $0x10,%esp
8010485b:	85 c0                	test   %eax,%eax
8010485d:	74 39                	je     80104898 <sys_open+0x118>
    ilock(ip);
8010485f:	83 ec 0c             	sub    $0xc,%esp
80104862:	50                   	push   %eax
80104863:	e8 19 cd ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104868:	83 c4 10             	add    $0x10,%esp
8010486b:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104870:	0f 85 71 ff ff ff    	jne    801047e7 <sys_open+0x67>
80104876:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010487a:	0f 84 67 ff ff ff    	je     801047e7 <sys_open+0x67>
      iunlockput(ip);
80104880:	83 ec 0c             	sub    $0xc,%esp
80104883:	56                   	push   %esi
80104884:	e8 9f ce ff ff       	call   80101728 <iunlockput>
      end_op();
80104889:	e8 ab df ff ff       	call   80102839 <end_op>
      return -1;
8010488e:	83 c4 10             	add    $0x10,%esp
80104891:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104896:	eb 9d                	jmp    80104835 <sys_open+0xb5>
      end_op();
80104898:	e8 9c df ff ff       	call   80102839 <end_op>
      return -1;
8010489d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048a2:	eb 91                	jmp    80104835 <sys_open+0xb5>
    if(f)
801048a4:	85 db                	test   %ebx,%ebx
801048a6:	74 0c                	je     801048b4 <sys_open+0x134>
      fileclose(f);
801048a8:	83 ec 0c             	sub    $0xc,%esp
801048ab:	53                   	push   %ebx
801048ac:	e8 22 c4 ff ff       	call   80100cd3 <fileclose>
801048b1:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801048b4:	83 ec 0c             	sub    $0xc,%esp
801048b7:	56                   	push   %esi
801048b8:	e8 6b ce ff ff       	call   80101728 <iunlockput>
    end_op();
801048bd:	e8 77 df ff ff       	call   80102839 <end_op>
    return -1;
801048c2:	83 c4 10             	add    $0x10,%esp
801048c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048ca:	e9 66 ff ff ff       	jmp    80104835 <sys_open+0xb5>
    return -1;
801048cf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048d4:	e9 5c ff ff ff       	jmp    80104835 <sys_open+0xb5>
801048d9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048de:	e9 52 ff ff ff       	jmp    80104835 <sys_open+0xb5>

801048e3 <sys_mkdir>:

int
sys_mkdir(void)
{
801048e3:	55                   	push   %ebp
801048e4:	89 e5                	mov    %esp,%ebp
801048e6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801048e9:	e8 d1 de ff ff       	call   801027bf <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801048ee:	83 ec 08             	sub    $0x8,%esp
801048f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048f4:	50                   	push   %eax
801048f5:	6a 00                	push   $0x0
801048f7:	e8 c3 f6 ff ff       	call   80103fbf <argstr>
801048fc:	83 c4 10             	add    $0x10,%esp
801048ff:	85 c0                	test   %eax,%eax
80104901:	78 36                	js     80104939 <sys_mkdir+0x56>
80104903:	83 ec 0c             	sub    $0xc,%esp
80104906:	6a 00                	push   $0x0
80104908:	b9 00 00 00 00       	mov    $0x0,%ecx
8010490d:	ba 01 00 00 00       	mov    $0x1,%edx
80104912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104915:	e8 22 f8 ff ff       	call   8010413c <create>
8010491a:	83 c4 10             	add    $0x10,%esp
8010491d:	85 c0                	test   %eax,%eax
8010491f:	74 18                	je     80104939 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104921:	83 ec 0c             	sub    $0xc,%esp
80104924:	50                   	push   %eax
80104925:	e8 fe cd ff ff       	call   80101728 <iunlockput>
  end_op();
8010492a:	e8 0a df ff ff       	call   80102839 <end_op>
  return 0;
8010492f:	83 c4 10             	add    $0x10,%esp
80104932:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104937:	c9                   	leave  
80104938:	c3                   	ret    
    end_op();
80104939:	e8 fb de ff ff       	call   80102839 <end_op>
    return -1;
8010493e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104943:	eb f2                	jmp    80104937 <sys_mkdir+0x54>

80104945 <sys_mknod>:

int
sys_mknod(void)
{
80104945:	55                   	push   %ebp
80104946:	89 e5                	mov    %esp,%ebp
80104948:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010494b:	e8 6f de ff ff       	call   801027bf <begin_op>
  if((argstr(0, &path)) < 0 ||
80104950:	83 ec 08             	sub    $0x8,%esp
80104953:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104956:	50                   	push   %eax
80104957:	6a 00                	push   $0x0
80104959:	e8 61 f6 ff ff       	call   80103fbf <argstr>
8010495e:	83 c4 10             	add    $0x10,%esp
80104961:	85 c0                	test   %eax,%eax
80104963:	78 62                	js     801049c7 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104965:	83 ec 08             	sub    $0x8,%esp
80104968:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010496b:	50                   	push   %eax
8010496c:	6a 01                	push   $0x1
8010496e:	e8 bc f5 ff ff       	call   80103f2f <argint>
  if((argstr(0, &path)) < 0 ||
80104973:	83 c4 10             	add    $0x10,%esp
80104976:	85 c0                	test   %eax,%eax
80104978:	78 4d                	js     801049c7 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
8010497a:	83 ec 08             	sub    $0x8,%esp
8010497d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104980:	50                   	push   %eax
80104981:	6a 02                	push   $0x2
80104983:	e8 a7 f5 ff ff       	call   80103f2f <argint>
     argint(1, &major) < 0 ||
80104988:	83 c4 10             	add    $0x10,%esp
8010498b:	85 c0                	test   %eax,%eax
8010498d:	78 38                	js     801049c7 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010498f:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104993:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104997:	83 ec 0c             	sub    $0xc,%esp
8010499a:	50                   	push   %eax
8010499b:	ba 03 00 00 00       	mov    $0x3,%edx
801049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a3:	e8 94 f7 ff ff       	call   8010413c <create>
801049a8:	83 c4 10             	add    $0x10,%esp
801049ab:	85 c0                	test   %eax,%eax
801049ad:	74 18                	je     801049c7 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	50                   	push   %eax
801049b3:	e8 70 cd ff ff       	call   80101728 <iunlockput>
  end_op();
801049b8:	e8 7c de ff ff       	call   80102839 <end_op>
  return 0;
801049bd:	83 c4 10             	add    $0x10,%esp
801049c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049c5:	c9                   	leave  
801049c6:	c3                   	ret    
    end_op();
801049c7:	e8 6d de ff ff       	call   80102839 <end_op>
    return -1;
801049cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049d1:	eb f2                	jmp    801049c5 <sys_mknod+0x80>

801049d3 <sys_chdir>:

int
sys_chdir(void)
{
801049d3:	55                   	push   %ebp
801049d4:	89 e5                	mov    %esp,%ebp
801049d6:	56                   	push   %esi
801049d7:	53                   	push   %ebx
801049d8:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801049db:	e8 5a e8 ff ff       	call   8010323a <myproc>
801049e0:	89 c6                	mov    %eax,%esi
  
  begin_op();
801049e2:	e8 d8 dd ff ff       	call   801027bf <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801049e7:	83 ec 08             	sub    $0x8,%esp
801049ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049ed:	50                   	push   %eax
801049ee:	6a 00                	push   $0x0
801049f0:	e8 ca f5 ff ff       	call   80103fbf <argstr>
801049f5:	83 c4 10             	add    $0x10,%esp
801049f8:	85 c0                	test   %eax,%eax
801049fa:	78 52                	js     80104a4e <sys_chdir+0x7b>
801049fc:	83 ec 0c             	sub    $0xc,%esp
801049ff:	ff 75 f4             	pushl  -0xc(%ebp)
80104a02:	e8 da d1 ff ff       	call   80101be1 <namei>
80104a07:	89 c3                	mov    %eax,%ebx
80104a09:	83 c4 10             	add    $0x10,%esp
80104a0c:	85 c0                	test   %eax,%eax
80104a0e:	74 3e                	je     80104a4e <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104a10:	83 ec 0c             	sub    $0xc,%esp
80104a13:	50                   	push   %eax
80104a14:	e8 68 cb ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104a19:	83 c4 10             	add    $0x10,%esp
80104a1c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a21:	75 37                	jne    80104a5a <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a23:	83 ec 0c             	sub    $0xc,%esp
80104a26:	53                   	push   %ebx
80104a27:	e8 17 cc ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104a2c:	83 c4 04             	add    $0x4,%esp
80104a2f:	ff 76 68             	pushl  0x68(%esi)
80104a32:	e8 51 cc ff ff       	call   80101688 <iput>
  end_op();
80104a37:	e8 fd dd ff ff       	call   80102839 <end_op>
  curproc->cwd = ip;
80104a3c:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104a3f:	83 c4 10             	add    $0x10,%esp
80104a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a47:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a4a:	5b                   	pop    %ebx
80104a4b:	5e                   	pop    %esi
80104a4c:	5d                   	pop    %ebp
80104a4d:	c3                   	ret    
    end_op();
80104a4e:	e8 e6 dd ff ff       	call   80102839 <end_op>
    return -1;
80104a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a58:	eb ed                	jmp    80104a47 <sys_chdir+0x74>
    iunlockput(ip);
80104a5a:	83 ec 0c             	sub    $0xc,%esp
80104a5d:	53                   	push   %ebx
80104a5e:	e8 c5 cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104a63:	e8 d1 dd ff ff       	call   80102839 <end_op>
    return -1;
80104a68:	83 c4 10             	add    $0x10,%esp
80104a6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a70:	eb d5                	jmp    80104a47 <sys_chdir+0x74>

80104a72 <sys_exec>:

int
sys_exec(void)
{
80104a72:	55                   	push   %ebp
80104a73:	89 e5                	mov    %esp,%ebp
80104a75:	53                   	push   %ebx
80104a76:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a7f:	50                   	push   %eax
80104a80:	6a 00                	push   $0x0
80104a82:	e8 38 f5 ff ff       	call   80103fbf <argstr>
80104a87:	83 c4 10             	add    $0x10,%esp
80104a8a:	85 c0                	test   %eax,%eax
80104a8c:	0f 88 a8 00 00 00    	js     80104b3a <sys_exec+0xc8>
80104a92:	83 ec 08             	sub    $0x8,%esp
80104a95:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104a9b:	50                   	push   %eax
80104a9c:	6a 01                	push   $0x1
80104a9e:	e8 8c f4 ff ff       	call   80103f2f <argint>
80104aa3:	83 c4 10             	add    $0x10,%esp
80104aa6:	85 c0                	test   %eax,%eax
80104aa8:	0f 88 93 00 00 00    	js     80104b41 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104aae:	83 ec 04             	sub    $0x4,%esp
80104ab1:	68 80 00 00 00       	push   $0x80
80104ab6:	6a 00                	push   $0x0
80104ab8:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104abe:	50                   	push   %eax
80104abf:	e8 20 f2 ff ff       	call   80103ce4 <memset>
80104ac4:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104ac7:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104acc:	83 fb 1f             	cmp    $0x1f,%ebx
80104acf:	77 77                	ja     80104b48 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104ad1:	83 ec 08             	sub    $0x8,%esp
80104ad4:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104ada:	50                   	push   %eax
80104adb:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104ae1:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104ae4:	50                   	push   %eax
80104ae5:	e8 c9 f3 ff ff       	call   80103eb3 <fetchint>
80104aea:	83 c4 10             	add    $0x10,%esp
80104aed:	85 c0                	test   %eax,%eax
80104aef:	78 5e                	js     80104b4f <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104af1:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104af7:	85 c0                	test   %eax,%eax
80104af9:	74 1d                	je     80104b18 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104afb:	83 ec 08             	sub    $0x8,%esp
80104afe:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b05:	52                   	push   %edx
80104b06:	50                   	push   %eax
80104b07:	e8 e3 f3 ff ff       	call   80103eef <fetchstr>
80104b0c:	83 c4 10             	add    $0x10,%esp
80104b0f:	85 c0                	test   %eax,%eax
80104b11:	78 46                	js     80104b59 <sys_exec+0xe7>
  for(i=0;; i++){
80104b13:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104b16:	eb b4                	jmp    80104acc <sys_exec+0x5a>
      argv[i] = 0;
80104b18:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b1f:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104b23:	83 ec 08             	sub    $0x8,%esp
80104b26:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b2c:	50                   	push   %eax
80104b2d:	ff 75 f4             	pushl  -0xc(%ebp)
80104b30:	e8 9d bd ff ff       	call   801008d2 <exec>
80104b35:	83 c4 10             	add    $0x10,%esp
80104b38:	eb 1a                	jmp    80104b54 <sys_exec+0xe2>
    return -1;
80104b3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3f:	eb 13                	jmp    80104b54 <sys_exec+0xe2>
80104b41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b46:	eb 0c                	jmp    80104b54 <sys_exec+0xe2>
      return -1;
80104b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b4d:	eb 05                	jmp    80104b54 <sys_exec+0xe2>
      return -1;
80104b4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b57:	c9                   	leave  
80104b58:	c3                   	ret    
      return -1;
80104b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5e:	eb f4                	jmp    80104b54 <sys_exec+0xe2>

80104b60 <sys_pipe>:

int
sys_pipe(void)
{
80104b60:	55                   	push   %ebp
80104b61:	89 e5                	mov    %esp,%ebp
80104b63:	53                   	push   %ebx
80104b64:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b67:	6a 08                	push   $0x8
80104b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b6c:	50                   	push   %eax
80104b6d:	6a 00                	push   $0x0
80104b6f:	e8 e3 f3 ff ff       	call   80103f57 <argptr>
80104b74:	83 c4 10             	add    $0x10,%esp
80104b77:	85 c0                	test   %eax,%eax
80104b79:	78 77                	js     80104bf2 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104b7b:	83 ec 08             	sub    $0x8,%esp
80104b7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b81:	50                   	push   %eax
80104b82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b85:	50                   	push   %eax
80104b86:	e8 bb e1 ff ff       	call   80102d46 <pipealloc>
80104b8b:	83 c4 10             	add    $0x10,%esp
80104b8e:	85 c0                	test   %eax,%eax
80104b90:	78 67                	js     80104bf9 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b95:	e8 14 f5 ff ff       	call   801040ae <fdalloc>
80104b9a:	89 c3                	mov    %eax,%ebx
80104b9c:	85 c0                	test   %eax,%eax
80104b9e:	78 21                	js     80104bc1 <sys_pipe+0x61>
80104ba0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ba3:	e8 06 f5 ff ff       	call   801040ae <fdalloc>
80104ba8:	85 c0                	test   %eax,%eax
80104baa:	78 15                	js     80104bc1 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104bac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104baf:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104bb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bb4:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bbf:	c9                   	leave  
80104bc0:	c3                   	ret    
    if(fd0 >= 0)
80104bc1:	85 db                	test   %ebx,%ebx
80104bc3:	78 0d                	js     80104bd2 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104bc5:	e8 70 e6 ff ff       	call   8010323a <myproc>
80104bca:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104bd1:	00 
    fileclose(rf);
80104bd2:	83 ec 0c             	sub    $0xc,%esp
80104bd5:	ff 75 f0             	pushl  -0x10(%ebp)
80104bd8:	e8 f6 c0 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104bdd:	83 c4 04             	add    $0x4,%esp
80104be0:	ff 75 ec             	pushl  -0x14(%ebp)
80104be3:	e8 eb c0 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104be8:	83 c4 10             	add    $0x10,%esp
80104beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf0:	eb ca                	jmp    80104bbc <sys_pipe+0x5c>
    return -1;
80104bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf7:	eb c3                	jmp    80104bbc <sys_pipe+0x5c>
    return -1;
80104bf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfe:	eb bc                	jmp    80104bbc <sys_pipe+0x5c>

80104c00 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104c00:	55                   	push   %ebp
80104c01:	89 e5                	mov    %esp,%ebp
80104c03:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104c06:	e8 a7 e7 ff ff       	call   801033b2 <fork>
}
80104c0b:	c9                   	leave  
80104c0c:	c3                   	ret    

80104c0d <sys_exit>:

int
sys_exit(void)
{
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
80104c10:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c13:	e8 ce e9 ff ff       	call   801035e6 <exit>
  return 0;  // not reached
}
80104c18:	b8 00 00 00 00       	mov    $0x0,%eax
80104c1d:	c9                   	leave  
80104c1e:	c3                   	ret    

80104c1f <sys_wait>:

int
sys_wait(void)
{
80104c1f:	55                   	push   %ebp
80104c20:	89 e5                	mov    %esp,%ebp
80104c22:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104c25:	e8 45 eb ff ff       	call   8010376f <wait>
}
80104c2a:	c9                   	leave  
80104c2b:	c3                   	ret    

80104c2c <sys_kill>:

int
sys_kill(void)
{
80104c2c:	55                   	push   %ebp
80104c2d:	89 e5                	mov    %esp,%ebp
80104c2f:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c35:	50                   	push   %eax
80104c36:	6a 00                	push   $0x0
80104c38:	e8 f2 f2 ff ff       	call   80103f2f <argint>
80104c3d:	83 c4 10             	add    $0x10,%esp
80104c40:	85 c0                	test   %eax,%eax
80104c42:	78 10                	js     80104c54 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104c44:	83 ec 0c             	sub    $0xc,%esp
80104c47:	ff 75 f4             	pushl  -0xc(%ebp)
80104c4a:	e8 1d ec ff ff       	call   8010386c <kill>
80104c4f:	83 c4 10             	add    $0x10,%esp
}
80104c52:	c9                   	leave  
80104c53:	c3                   	ret    
    return -1;
80104c54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c59:	eb f7                	jmp    80104c52 <sys_kill+0x26>

80104c5b <sys_getpid>:

int
sys_getpid(void)
{
80104c5b:	55                   	push   %ebp
80104c5c:	89 e5                	mov    %esp,%ebp
80104c5e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c61:	e8 d4 e5 ff ff       	call   8010323a <myproc>
80104c66:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c69:	c9                   	leave  
80104c6a:	c3                   	ret    

80104c6b <sys_sbrk>:

int
sys_sbrk(void)
{
80104c6b:	55                   	push   %ebp
80104c6c:	89 e5                	mov    %esp,%ebp
80104c6e:	53                   	push   %ebx
80104c6f:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c75:	50                   	push   %eax
80104c76:	6a 00                	push   $0x0
80104c78:	e8 b2 f2 ff ff       	call   80103f2f <argint>
80104c7d:	83 c4 10             	add    $0x10,%esp
80104c80:	85 c0                	test   %eax,%eax
80104c82:	78 27                	js     80104cab <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104c84:	e8 b1 e5 ff ff       	call   8010323a <myproc>
80104c89:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104c8b:	83 ec 0c             	sub    $0xc,%esp
80104c8e:	ff 75 f4             	pushl  -0xc(%ebp)
80104c91:	e8 af e6 ff ff       	call   80103345 <growproc>
80104c96:	83 c4 10             	add    $0x10,%esp
80104c99:	85 c0                	test   %eax,%eax
80104c9b:	78 07                	js     80104ca4 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104c9d:	89 d8                	mov    %ebx,%eax
80104c9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ca2:	c9                   	leave  
80104ca3:	c3                   	ret    
    return -1;
80104ca4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ca9:	eb f2                	jmp    80104c9d <sys_sbrk+0x32>
    return -1;
80104cab:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104cb0:	eb eb                	jmp    80104c9d <sys_sbrk+0x32>

80104cb2 <sys_sleep>:

int
sys_sleep(void)
{
80104cb2:	55                   	push   %ebp
80104cb3:	89 e5                	mov    %esp,%ebp
80104cb5:	53                   	push   %ebx
80104cb6:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cbc:	50                   	push   %eax
80104cbd:	6a 00                	push   $0x0
80104cbf:	e8 6b f2 ff ff       	call   80103f2f <argint>
80104cc4:	83 c4 10             	add    $0x10,%esp
80104cc7:	85 c0                	test   %eax,%eax
80104cc9:	78 75                	js     80104d40 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104ccb:	83 ec 0c             	sub    $0xc,%esp
80104cce:	68 80 3c 13 80       	push   $0x80133c80
80104cd3:	e8 60 ef ff ff       	call   80103c38 <acquire>
  ticks0 = ticks;
80104cd8:	8b 1d c0 44 13 80    	mov    0x801344c0,%ebx
  while(ticks - ticks0 < n){
80104cde:	83 c4 10             	add    $0x10,%esp
80104ce1:	a1 c0 44 13 80       	mov    0x801344c0,%eax
80104ce6:	29 d8                	sub    %ebx,%eax
80104ce8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ceb:	73 39                	jae    80104d26 <sys_sleep+0x74>
    if(myproc()->killed){
80104ced:	e8 48 e5 ff ff       	call   8010323a <myproc>
80104cf2:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104cf6:	75 17                	jne    80104d0f <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104cf8:	83 ec 08             	sub    $0x8,%esp
80104cfb:	68 80 3c 13 80       	push   $0x80133c80
80104d00:	68 c0 44 13 80       	push   $0x801344c0
80104d05:	e8 d4 e9 ff ff       	call   801036de <sleep>
80104d0a:	83 c4 10             	add    $0x10,%esp
80104d0d:	eb d2                	jmp    80104ce1 <sys_sleep+0x2f>
      release(&tickslock);
80104d0f:	83 ec 0c             	sub    $0xc,%esp
80104d12:	68 80 3c 13 80       	push   $0x80133c80
80104d17:	e8 81 ef ff ff       	call   80103c9d <release>
      return -1;
80104d1c:	83 c4 10             	add    $0x10,%esp
80104d1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d24:	eb 15                	jmp    80104d3b <sys_sleep+0x89>
  }
  release(&tickslock);
80104d26:	83 ec 0c             	sub    $0xc,%esp
80104d29:	68 80 3c 13 80       	push   $0x80133c80
80104d2e:	e8 6a ef ff ff       	call   80103c9d <release>
  return 0;
80104d33:	83 c4 10             	add    $0x10,%esp
80104d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d3e:	c9                   	leave  
80104d3f:	c3                   	ret    
    return -1;
80104d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d45:	eb f4                	jmp    80104d3b <sys_sleep+0x89>

80104d47 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d47:	55                   	push   %ebp
80104d48:	89 e5                	mov    %esp,%ebp
80104d4a:	53                   	push   %ebx
80104d4b:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104d4e:	68 80 3c 13 80       	push   $0x80133c80
80104d53:	e8 e0 ee ff ff       	call   80103c38 <acquire>
  xticks = ticks;
80104d58:	8b 1d c0 44 13 80    	mov    0x801344c0,%ebx
  release(&tickslock);
80104d5e:	c7 04 24 80 3c 13 80 	movl   $0x80133c80,(%esp)
80104d65:	e8 33 ef ff ff       	call   80103c9d <release>
  return xticks;
}
80104d6a:	89 d8                	mov    %ebx,%eax
80104d6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d6f:	c9                   	leave  
80104d70:	c3                   	ret    

80104d71 <sys_dump_physmem>:

int
sys_dump_physmem(void) {
80104d71:	55                   	push   %ebp
80104d72:	89 e5                	mov    %esp,%ebp
80104d74:	83 ec 1c             	sub    $0x1c,%esp
    int* frames;
    int* pids;
    int numframes;
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104d77:	6a 04                	push   $0x4
80104d79:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d7c:	50                   	push   %eax
80104d7d:	6a 00                	push   $0x0
80104d7f:	e8 d3 f1 ff ff       	call   80103f57 <argptr>
80104d84:	83 c4 10             	add    $0x10,%esp
80104d87:	85 c0                	test   %eax,%eax
80104d89:	78 42                	js     80104dcd <sys_dump_physmem+0x5c>
80104d8b:	83 ec 04             	sub    $0x4,%esp
80104d8e:	6a 04                	push   $0x4
80104d90:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d93:	50                   	push   %eax
80104d94:	6a 01                	push   $0x1
80104d96:	e8 bc f1 ff ff       	call   80103f57 <argptr>
80104d9b:	83 c4 10             	add    $0x10,%esp
80104d9e:	85 c0                	test   %eax,%eax
80104da0:	78 32                	js     80104dd4 <sys_dump_physmem+0x63>
    argint(2, &numframes) < 0) {
80104da2:	83 ec 08             	sub    $0x8,%esp
80104da5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104da8:	50                   	push   %eax
80104da9:	6a 02                	push   $0x2
80104dab:	e8 7f f1 ff ff       	call   80103f2f <argint>
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104db0:	83 c4 10             	add    $0x10,%esp
80104db3:	85 c0                	test   %eax,%eax
80104db5:	78 24                	js     80104ddb <sys_dump_physmem+0x6a>
        return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104db7:	83 ec 04             	sub    $0x4,%esp
80104dba:	ff 75 ec             	pushl  -0x14(%ebp)
80104dbd:	ff 75 f0             	pushl  -0x10(%ebp)
80104dc0:	ff 75 f4             	pushl  -0xc(%ebp)
80104dc3:	e8 ca eb ff ff       	call   80103992 <dump_physmem>
80104dc8:	83 c4 10             	add    $0x10,%esp
80104dcb:	c9                   	leave  
80104dcc:	c3                   	ret    
        return -1;
80104dcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd2:	eb f7                	jmp    80104dcb <sys_dump_physmem+0x5a>
80104dd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd9:	eb f0                	jmp    80104dcb <sys_dump_physmem+0x5a>
80104ddb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de0:	eb e9                	jmp    80104dcb <sys_dump_physmem+0x5a>

80104de2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104de2:	1e                   	push   %ds
  pushl %es
80104de3:	06                   	push   %es
  pushl %fs
80104de4:	0f a0                	push   %fs
  pushl %gs
80104de6:	0f a8                	push   %gs
  pushal
80104de8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104de9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104ded:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104def:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104df1:	54                   	push   %esp
  call trap
80104df2:	e8 e3 00 00 00       	call   80104eda <trap>
  addl $4, %esp
80104df7:	83 c4 04             	add    $0x4,%esp

80104dfa <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104dfa:	61                   	popa   
  popl %gs
80104dfb:	0f a9                	pop    %gs
  popl %fs
80104dfd:	0f a1                	pop    %fs
  popl %es
80104dff:	07                   	pop    %es
  popl %ds
80104e00:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104e01:	83 c4 08             	add    $0x8,%esp
  iret
80104e04:	cf                   	iret   

80104e05 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104e05:	55                   	push   %ebp
80104e06:	89 e5                	mov    %esp,%ebp
80104e08:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104e0b:	b8 00 00 00 00       	mov    $0x0,%eax
80104e10:	eb 4a                	jmp    80104e5c <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104e12:	8b 0c 85 20 90 12 80 	mov    -0x7fed6fe0(,%eax,4),%ecx
80104e19:	66 89 0c c5 c0 3c 13 	mov    %cx,-0x7fecc340(,%eax,8)
80104e20:	80 
80104e21:	66 c7 04 c5 c2 3c 13 	movw   $0x8,-0x7fecc33e(,%eax,8)
80104e28:	80 08 00 
80104e2b:	c6 04 c5 c4 3c 13 80 	movb   $0x0,-0x7fecc33c(,%eax,8)
80104e32:	00 
80104e33:	0f b6 14 c5 c5 3c 13 	movzbl -0x7fecc33b(,%eax,8),%edx
80104e3a:	80 
80104e3b:	83 e2 f0             	and    $0xfffffff0,%edx
80104e3e:	83 ca 0e             	or     $0xe,%edx
80104e41:	83 e2 8f             	and    $0xffffff8f,%edx
80104e44:	83 ca 80             	or     $0xffffff80,%edx
80104e47:	88 14 c5 c5 3c 13 80 	mov    %dl,-0x7fecc33b(,%eax,8)
80104e4e:	c1 e9 10             	shr    $0x10,%ecx
80104e51:	66 89 0c c5 c6 3c 13 	mov    %cx,-0x7fecc33a(,%eax,8)
80104e58:	80 
  for(i = 0; i < 256; i++)
80104e59:	83 c0 01             	add    $0x1,%eax
80104e5c:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e61:	7e af                	jle    80104e12 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e63:	8b 15 20 91 12 80    	mov    0x80129120,%edx
80104e69:	66 89 15 c0 3e 13 80 	mov    %dx,0x80133ec0
80104e70:	66 c7 05 c2 3e 13 80 	movw   $0x8,0x80133ec2
80104e77:	08 00 
80104e79:	c6 05 c4 3e 13 80 00 	movb   $0x0,0x80133ec4
80104e80:	0f b6 05 c5 3e 13 80 	movzbl 0x80133ec5,%eax
80104e87:	83 c8 0f             	or     $0xf,%eax
80104e8a:	83 e0 ef             	and    $0xffffffef,%eax
80104e8d:	83 c8 e0             	or     $0xffffffe0,%eax
80104e90:	a2 c5 3e 13 80       	mov    %al,0x80133ec5
80104e95:	c1 ea 10             	shr    $0x10,%edx
80104e98:	66 89 15 c6 3e 13 80 	mov    %dx,0x80133ec6

  initlock(&tickslock, "time");
80104e9f:	83 ec 08             	sub    $0x8,%esp
80104ea2:	68 dd 6c 10 80       	push   $0x80106cdd
80104ea7:	68 80 3c 13 80       	push   $0x80133c80
80104eac:	e8 4b ec ff ff       	call   80103afc <initlock>
}
80104eb1:	83 c4 10             	add    $0x10,%esp
80104eb4:	c9                   	leave  
80104eb5:	c3                   	ret    

80104eb6 <idtinit>:

void
idtinit(void)
{
80104eb6:	55                   	push   %ebp
80104eb7:	89 e5                	mov    %esp,%ebp
80104eb9:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104ebc:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104ec2:	b8 c0 3c 13 80       	mov    $0x80133cc0,%eax
80104ec7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104ecb:	c1 e8 10             	shr    $0x10,%eax
80104ece:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104ed2:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104ed5:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104ed8:	c9                   	leave  
80104ed9:	c3                   	ret    

80104eda <trap>:

void
trap(struct trapframe *tf)
{
80104eda:	55                   	push   %ebp
80104edb:	89 e5                	mov    %esp,%ebp
80104edd:	57                   	push   %edi
80104ede:	56                   	push   %esi
80104edf:	53                   	push   %ebx
80104ee0:	83 ec 1c             	sub    $0x1c,%esp
80104ee3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104ee6:	8b 43 30             	mov    0x30(%ebx),%eax
80104ee9:	83 f8 40             	cmp    $0x40,%eax
80104eec:	74 13                	je     80104f01 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104eee:	83 e8 20             	sub    $0x20,%eax
80104ef1:	83 f8 1f             	cmp    $0x1f,%eax
80104ef4:	0f 87 3a 01 00 00    	ja     80105034 <trap+0x15a>
80104efa:	ff 24 85 84 6d 10 80 	jmp    *-0x7fef927c(,%eax,4)
    if(myproc()->killed)
80104f01:	e8 34 e3 ff ff       	call   8010323a <myproc>
80104f06:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f0a:	75 1f                	jne    80104f2b <trap+0x51>
    myproc()->tf = tf;
80104f0c:	e8 29 e3 ff ff       	call   8010323a <myproc>
80104f11:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104f14:	e8 d9 f0 ff ff       	call   80103ff2 <syscall>
    if(myproc()->killed)
80104f19:	e8 1c e3 ff ff       	call   8010323a <myproc>
80104f1e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f22:	74 7e                	je     80104fa2 <trap+0xc8>
      exit();
80104f24:	e8 bd e6 ff ff       	call   801035e6 <exit>
80104f29:	eb 77                	jmp    80104fa2 <trap+0xc8>
      exit();
80104f2b:	e8 b6 e6 ff ff       	call   801035e6 <exit>
80104f30:	eb da                	jmp    80104f0c <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104f32:	e8 e8 e2 ff ff       	call   8010321f <cpuid>
80104f37:	85 c0                	test   %eax,%eax
80104f39:	74 6f                	je     80104faa <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104f3b:	e8 6a d4 ff ff       	call   801023aa <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f40:	e8 f5 e2 ff ff       	call   8010323a <myproc>
80104f45:	85 c0                	test   %eax,%eax
80104f47:	74 1c                	je     80104f65 <trap+0x8b>
80104f49:	e8 ec e2 ff ff       	call   8010323a <myproc>
80104f4e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f52:	74 11                	je     80104f65 <trap+0x8b>
80104f54:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f58:	83 e0 03             	and    $0x3,%eax
80104f5b:	66 83 f8 03          	cmp    $0x3,%ax
80104f5f:	0f 84 62 01 00 00    	je     801050c7 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f65:	e8 d0 e2 ff ff       	call   8010323a <myproc>
80104f6a:	85 c0                	test   %eax,%eax
80104f6c:	74 0f                	je     80104f7d <trap+0xa3>
80104f6e:	e8 c7 e2 ff ff       	call   8010323a <myproc>
80104f73:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f77:	0f 84 54 01 00 00    	je     801050d1 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f7d:	e8 b8 e2 ff ff       	call   8010323a <myproc>
80104f82:	85 c0                	test   %eax,%eax
80104f84:	74 1c                	je     80104fa2 <trap+0xc8>
80104f86:	e8 af e2 ff ff       	call   8010323a <myproc>
80104f8b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f8f:	74 11                	je     80104fa2 <trap+0xc8>
80104f91:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f95:	83 e0 03             	and    $0x3,%eax
80104f98:	66 83 f8 03          	cmp    $0x3,%ax
80104f9c:	0f 84 43 01 00 00    	je     801050e5 <trap+0x20b>
    exit();
}
80104fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104fa5:	5b                   	pop    %ebx
80104fa6:	5e                   	pop    %esi
80104fa7:	5f                   	pop    %edi
80104fa8:	5d                   	pop    %ebp
80104fa9:	c3                   	ret    
      acquire(&tickslock);
80104faa:	83 ec 0c             	sub    $0xc,%esp
80104fad:	68 80 3c 13 80       	push   $0x80133c80
80104fb2:	e8 81 ec ff ff       	call   80103c38 <acquire>
      ticks++;
80104fb7:	83 05 c0 44 13 80 01 	addl   $0x1,0x801344c0
      wakeup(&ticks);
80104fbe:	c7 04 24 c0 44 13 80 	movl   $0x801344c0,(%esp)
80104fc5:	e8 79 e8 ff ff       	call   80103843 <wakeup>
      release(&tickslock);
80104fca:	c7 04 24 80 3c 13 80 	movl   $0x80133c80,(%esp)
80104fd1:	e8 c7 ec ff ff       	call   80103c9d <release>
80104fd6:	83 c4 10             	add    $0x10,%esp
80104fd9:	e9 5d ff ff ff       	jmp    80104f3b <trap+0x61>
    ideintr();
80104fde:	e8 90 cd ff ff       	call   80101d73 <ideintr>
    lapiceoi();
80104fe3:	e8 c2 d3 ff ff       	call   801023aa <lapiceoi>
    break;
80104fe8:	e9 53 ff ff ff       	jmp    80104f40 <trap+0x66>
    kbdintr();
80104fed:	e8 fc d1 ff ff       	call   801021ee <kbdintr>
    lapiceoi();
80104ff2:	e8 b3 d3 ff ff       	call   801023aa <lapiceoi>
    break;
80104ff7:	e9 44 ff ff ff       	jmp    80104f40 <trap+0x66>
    uartintr();
80104ffc:	e8 05 02 00 00       	call   80105206 <uartintr>
    lapiceoi();
80105001:	e8 a4 d3 ff ff       	call   801023aa <lapiceoi>
    break;
80105006:	e9 35 ff ff ff       	jmp    80104f40 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010500b:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010500e:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105012:	e8 08 e2 ff ff       	call   8010321f <cpuid>
80105017:	57                   	push   %edi
80105018:	0f b7 f6             	movzwl %si,%esi
8010501b:	56                   	push   %esi
8010501c:	50                   	push   %eax
8010501d:	68 e8 6c 10 80       	push   $0x80106ce8
80105022:	e8 e4 b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105027:	e8 7e d3 ff ff       	call   801023aa <lapiceoi>
    break;
8010502c:	83 c4 10             	add    $0x10,%esp
8010502f:	e9 0c ff ff ff       	jmp    80104f40 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105034:	e8 01 e2 ff ff       	call   8010323a <myproc>
80105039:	85 c0                	test   %eax,%eax
8010503b:	74 5f                	je     8010509c <trap+0x1c2>
8010503d:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105041:	74 59                	je     8010509c <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105043:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105046:	8b 43 38             	mov    0x38(%ebx),%eax
80105049:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010504c:	e8 ce e1 ff ff       	call   8010321f <cpuid>
80105051:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105054:	8b 53 34             	mov    0x34(%ebx),%edx
80105057:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010505a:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
8010505d:	e8 d8 e1 ff ff       	call   8010323a <myproc>
80105062:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105065:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105068:	e8 cd e1 ff ff       	call   8010323a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010506d:	57                   	push   %edi
8010506e:	ff 75 e4             	pushl  -0x1c(%ebp)
80105071:	ff 75 e0             	pushl  -0x20(%ebp)
80105074:	ff 75 dc             	pushl  -0x24(%ebp)
80105077:	56                   	push   %esi
80105078:	ff 75 d8             	pushl  -0x28(%ebp)
8010507b:	ff 70 10             	pushl  0x10(%eax)
8010507e:	68 40 6d 10 80       	push   $0x80106d40
80105083:	e8 83 b5 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105088:	83 c4 20             	add    $0x20,%esp
8010508b:	e8 aa e1 ff ff       	call   8010323a <myproc>
80105090:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105097:	e9 a4 fe ff ff       	jmp    80104f40 <trap+0x66>
8010509c:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010509f:	8b 73 38             	mov    0x38(%ebx),%esi
801050a2:	e8 78 e1 ff ff       	call   8010321f <cpuid>
801050a7:	83 ec 0c             	sub    $0xc,%esp
801050aa:	57                   	push   %edi
801050ab:	56                   	push   %esi
801050ac:	50                   	push   %eax
801050ad:	ff 73 30             	pushl  0x30(%ebx)
801050b0:	68 0c 6d 10 80       	push   $0x80106d0c
801050b5:	e8 51 b5 ff ff       	call   8010060b <cprintf>
      panic("trap");
801050ba:	83 c4 14             	add    $0x14,%esp
801050bd:	68 e2 6c 10 80       	push   $0x80106ce2
801050c2:	e8 81 b2 ff ff       	call   80100348 <panic>
    exit();
801050c7:	e8 1a e5 ff ff       	call   801035e6 <exit>
801050cc:	e9 94 fe ff ff       	jmp    80104f65 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801050d1:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801050d5:	0f 85 a2 fe ff ff    	jne    80104f7d <trap+0xa3>
    yield();
801050db:	e8 cc e5 ff ff       	call   801036ac <yield>
801050e0:	e9 98 fe ff ff       	jmp    80104f7d <trap+0xa3>
    exit();
801050e5:	e8 fc e4 ff ff       	call   801035e6 <exit>
801050ea:	e9 b3 fe ff ff       	jmp    80104fa2 <trap+0xc8>

801050ef <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801050ef:	55                   	push   %ebp
801050f0:	89 e5                	mov    %esp,%ebp
  if(!uart)
801050f2:	83 3d c0 95 12 80 00 	cmpl   $0x0,0x801295c0
801050f9:	74 15                	je     80105110 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050fb:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105100:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105101:	a8 01                	test   $0x1,%al
80105103:	74 12                	je     80105117 <uartgetc+0x28>
80105105:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010510a:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010510b:	0f b6 c0             	movzbl %al,%eax
}
8010510e:	5d                   	pop    %ebp
8010510f:	c3                   	ret    
    return -1;
80105110:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105115:	eb f7                	jmp    8010510e <uartgetc+0x1f>
    return -1;
80105117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511c:	eb f0                	jmp    8010510e <uartgetc+0x1f>

8010511e <uartputc>:
  if(!uart)
8010511e:	83 3d c0 95 12 80 00 	cmpl   $0x0,0x801295c0
80105125:	74 3b                	je     80105162 <uartputc+0x44>
{
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
8010512a:	53                   	push   %ebx
8010512b:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010512e:	bb 00 00 00 00       	mov    $0x0,%ebx
80105133:	eb 10                	jmp    80105145 <uartputc+0x27>
    microdelay(10);
80105135:	83 ec 0c             	sub    $0xc,%esp
80105138:	6a 0a                	push   $0xa
8010513a:	e8 8a d2 ff ff       	call   801023c9 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010513f:	83 c3 01             	add    $0x1,%ebx
80105142:	83 c4 10             	add    $0x10,%esp
80105145:	83 fb 7f             	cmp    $0x7f,%ebx
80105148:	7f 0a                	jg     80105154 <uartputc+0x36>
8010514a:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010514f:	ec                   	in     (%dx),%al
80105150:	a8 20                	test   $0x20,%al
80105152:	74 e1                	je     80105135 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105154:	8b 45 08             	mov    0x8(%ebp),%eax
80105157:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010515c:	ee                   	out    %al,(%dx)
}
8010515d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105160:	c9                   	leave  
80105161:	c3                   	ret    
80105162:	f3 c3                	repz ret 

80105164 <uartinit>:
{
80105164:	55                   	push   %ebp
80105165:	89 e5                	mov    %esp,%ebp
80105167:	56                   	push   %esi
80105168:	53                   	push   %ebx
80105169:	b9 00 00 00 00       	mov    $0x0,%ecx
8010516e:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105173:	89 c8                	mov    %ecx,%eax
80105175:	ee                   	out    %al,(%dx)
80105176:	be fb 03 00 00       	mov    $0x3fb,%esi
8010517b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105180:	89 f2                	mov    %esi,%edx
80105182:	ee                   	out    %al,(%dx)
80105183:	b8 0c 00 00 00       	mov    $0xc,%eax
80105188:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010518d:	ee                   	out    %al,(%dx)
8010518e:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105193:	89 c8                	mov    %ecx,%eax
80105195:	89 da                	mov    %ebx,%edx
80105197:	ee                   	out    %al,(%dx)
80105198:	b8 03 00 00 00       	mov    $0x3,%eax
8010519d:	89 f2                	mov    %esi,%edx
8010519f:	ee                   	out    %al,(%dx)
801051a0:	ba fc 03 00 00       	mov    $0x3fc,%edx
801051a5:	89 c8                	mov    %ecx,%eax
801051a7:	ee                   	out    %al,(%dx)
801051a8:	b8 01 00 00 00       	mov    $0x1,%eax
801051ad:	89 da                	mov    %ebx,%edx
801051af:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051b0:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051b5:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801051b6:	3c ff                	cmp    $0xff,%al
801051b8:	74 45                	je     801051ff <uartinit+0x9b>
  uart = 1;
801051ba:	c7 05 c0 95 12 80 01 	movl   $0x1,0x801295c0
801051c1:	00 00 00 
801051c4:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051c9:	ec                   	in     (%dx),%al
801051ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051cf:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801051d0:	83 ec 08             	sub    $0x8,%esp
801051d3:	6a 00                	push   $0x0
801051d5:	6a 04                	push   $0x4
801051d7:	e8 a2 cd ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801051dc:	83 c4 10             	add    $0x10,%esp
801051df:	bb 04 6e 10 80       	mov    $0x80106e04,%ebx
801051e4:	eb 12                	jmp    801051f8 <uartinit+0x94>
    uartputc(*p);
801051e6:	83 ec 0c             	sub    $0xc,%esp
801051e9:	0f be c0             	movsbl %al,%eax
801051ec:	50                   	push   %eax
801051ed:	e8 2c ff ff ff       	call   8010511e <uartputc>
  for(p="xv6...\n"; *p; p++)
801051f2:	83 c3 01             	add    $0x1,%ebx
801051f5:	83 c4 10             	add    $0x10,%esp
801051f8:	0f b6 03             	movzbl (%ebx),%eax
801051fb:	84 c0                	test   %al,%al
801051fd:	75 e7                	jne    801051e6 <uartinit+0x82>
}
801051ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105202:	5b                   	pop    %ebx
80105203:	5e                   	pop    %esi
80105204:	5d                   	pop    %ebp
80105205:	c3                   	ret    

80105206 <uartintr>:

void
uartintr(void)
{
80105206:	55                   	push   %ebp
80105207:	89 e5                	mov    %esp,%ebp
80105209:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
8010520c:	68 ef 50 10 80       	push   $0x801050ef
80105211:	e8 28 b5 ff ff       	call   8010073e <consoleintr>
}
80105216:	83 c4 10             	add    $0x10,%esp
80105219:	c9                   	leave  
8010521a:	c3                   	ret    

8010521b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010521b:	6a 00                	push   $0x0
  pushl $0
8010521d:	6a 00                	push   $0x0
  jmp alltraps
8010521f:	e9 be fb ff ff       	jmp    80104de2 <alltraps>

80105224 <vector1>:
.globl vector1
vector1:
  pushl $0
80105224:	6a 00                	push   $0x0
  pushl $1
80105226:	6a 01                	push   $0x1
  jmp alltraps
80105228:	e9 b5 fb ff ff       	jmp    80104de2 <alltraps>

8010522d <vector2>:
.globl vector2
vector2:
  pushl $0
8010522d:	6a 00                	push   $0x0
  pushl $2
8010522f:	6a 02                	push   $0x2
  jmp alltraps
80105231:	e9 ac fb ff ff       	jmp    80104de2 <alltraps>

80105236 <vector3>:
.globl vector3
vector3:
  pushl $0
80105236:	6a 00                	push   $0x0
  pushl $3
80105238:	6a 03                	push   $0x3
  jmp alltraps
8010523a:	e9 a3 fb ff ff       	jmp    80104de2 <alltraps>

8010523f <vector4>:
.globl vector4
vector4:
  pushl $0
8010523f:	6a 00                	push   $0x0
  pushl $4
80105241:	6a 04                	push   $0x4
  jmp alltraps
80105243:	e9 9a fb ff ff       	jmp    80104de2 <alltraps>

80105248 <vector5>:
.globl vector5
vector5:
  pushl $0
80105248:	6a 00                	push   $0x0
  pushl $5
8010524a:	6a 05                	push   $0x5
  jmp alltraps
8010524c:	e9 91 fb ff ff       	jmp    80104de2 <alltraps>

80105251 <vector6>:
.globl vector6
vector6:
  pushl $0
80105251:	6a 00                	push   $0x0
  pushl $6
80105253:	6a 06                	push   $0x6
  jmp alltraps
80105255:	e9 88 fb ff ff       	jmp    80104de2 <alltraps>

8010525a <vector7>:
.globl vector7
vector7:
  pushl $0
8010525a:	6a 00                	push   $0x0
  pushl $7
8010525c:	6a 07                	push   $0x7
  jmp alltraps
8010525e:	e9 7f fb ff ff       	jmp    80104de2 <alltraps>

80105263 <vector8>:
.globl vector8
vector8:
  pushl $8
80105263:	6a 08                	push   $0x8
  jmp alltraps
80105265:	e9 78 fb ff ff       	jmp    80104de2 <alltraps>

8010526a <vector9>:
.globl vector9
vector9:
  pushl $0
8010526a:	6a 00                	push   $0x0
  pushl $9
8010526c:	6a 09                	push   $0x9
  jmp alltraps
8010526e:	e9 6f fb ff ff       	jmp    80104de2 <alltraps>

80105273 <vector10>:
.globl vector10
vector10:
  pushl $10
80105273:	6a 0a                	push   $0xa
  jmp alltraps
80105275:	e9 68 fb ff ff       	jmp    80104de2 <alltraps>

8010527a <vector11>:
.globl vector11
vector11:
  pushl $11
8010527a:	6a 0b                	push   $0xb
  jmp alltraps
8010527c:	e9 61 fb ff ff       	jmp    80104de2 <alltraps>

80105281 <vector12>:
.globl vector12
vector12:
  pushl $12
80105281:	6a 0c                	push   $0xc
  jmp alltraps
80105283:	e9 5a fb ff ff       	jmp    80104de2 <alltraps>

80105288 <vector13>:
.globl vector13
vector13:
  pushl $13
80105288:	6a 0d                	push   $0xd
  jmp alltraps
8010528a:	e9 53 fb ff ff       	jmp    80104de2 <alltraps>

8010528f <vector14>:
.globl vector14
vector14:
  pushl $14
8010528f:	6a 0e                	push   $0xe
  jmp alltraps
80105291:	e9 4c fb ff ff       	jmp    80104de2 <alltraps>

80105296 <vector15>:
.globl vector15
vector15:
  pushl $0
80105296:	6a 00                	push   $0x0
  pushl $15
80105298:	6a 0f                	push   $0xf
  jmp alltraps
8010529a:	e9 43 fb ff ff       	jmp    80104de2 <alltraps>

8010529f <vector16>:
.globl vector16
vector16:
  pushl $0
8010529f:	6a 00                	push   $0x0
  pushl $16
801052a1:	6a 10                	push   $0x10
  jmp alltraps
801052a3:	e9 3a fb ff ff       	jmp    80104de2 <alltraps>

801052a8 <vector17>:
.globl vector17
vector17:
  pushl $17
801052a8:	6a 11                	push   $0x11
  jmp alltraps
801052aa:	e9 33 fb ff ff       	jmp    80104de2 <alltraps>

801052af <vector18>:
.globl vector18
vector18:
  pushl $0
801052af:	6a 00                	push   $0x0
  pushl $18
801052b1:	6a 12                	push   $0x12
  jmp alltraps
801052b3:	e9 2a fb ff ff       	jmp    80104de2 <alltraps>

801052b8 <vector19>:
.globl vector19
vector19:
  pushl $0
801052b8:	6a 00                	push   $0x0
  pushl $19
801052ba:	6a 13                	push   $0x13
  jmp alltraps
801052bc:	e9 21 fb ff ff       	jmp    80104de2 <alltraps>

801052c1 <vector20>:
.globl vector20
vector20:
  pushl $0
801052c1:	6a 00                	push   $0x0
  pushl $20
801052c3:	6a 14                	push   $0x14
  jmp alltraps
801052c5:	e9 18 fb ff ff       	jmp    80104de2 <alltraps>

801052ca <vector21>:
.globl vector21
vector21:
  pushl $0
801052ca:	6a 00                	push   $0x0
  pushl $21
801052cc:	6a 15                	push   $0x15
  jmp alltraps
801052ce:	e9 0f fb ff ff       	jmp    80104de2 <alltraps>

801052d3 <vector22>:
.globl vector22
vector22:
  pushl $0
801052d3:	6a 00                	push   $0x0
  pushl $22
801052d5:	6a 16                	push   $0x16
  jmp alltraps
801052d7:	e9 06 fb ff ff       	jmp    80104de2 <alltraps>

801052dc <vector23>:
.globl vector23
vector23:
  pushl $0
801052dc:	6a 00                	push   $0x0
  pushl $23
801052de:	6a 17                	push   $0x17
  jmp alltraps
801052e0:	e9 fd fa ff ff       	jmp    80104de2 <alltraps>

801052e5 <vector24>:
.globl vector24
vector24:
  pushl $0
801052e5:	6a 00                	push   $0x0
  pushl $24
801052e7:	6a 18                	push   $0x18
  jmp alltraps
801052e9:	e9 f4 fa ff ff       	jmp    80104de2 <alltraps>

801052ee <vector25>:
.globl vector25
vector25:
  pushl $0
801052ee:	6a 00                	push   $0x0
  pushl $25
801052f0:	6a 19                	push   $0x19
  jmp alltraps
801052f2:	e9 eb fa ff ff       	jmp    80104de2 <alltraps>

801052f7 <vector26>:
.globl vector26
vector26:
  pushl $0
801052f7:	6a 00                	push   $0x0
  pushl $26
801052f9:	6a 1a                	push   $0x1a
  jmp alltraps
801052fb:	e9 e2 fa ff ff       	jmp    80104de2 <alltraps>

80105300 <vector27>:
.globl vector27
vector27:
  pushl $0
80105300:	6a 00                	push   $0x0
  pushl $27
80105302:	6a 1b                	push   $0x1b
  jmp alltraps
80105304:	e9 d9 fa ff ff       	jmp    80104de2 <alltraps>

80105309 <vector28>:
.globl vector28
vector28:
  pushl $0
80105309:	6a 00                	push   $0x0
  pushl $28
8010530b:	6a 1c                	push   $0x1c
  jmp alltraps
8010530d:	e9 d0 fa ff ff       	jmp    80104de2 <alltraps>

80105312 <vector29>:
.globl vector29
vector29:
  pushl $0
80105312:	6a 00                	push   $0x0
  pushl $29
80105314:	6a 1d                	push   $0x1d
  jmp alltraps
80105316:	e9 c7 fa ff ff       	jmp    80104de2 <alltraps>

8010531b <vector30>:
.globl vector30
vector30:
  pushl $0
8010531b:	6a 00                	push   $0x0
  pushl $30
8010531d:	6a 1e                	push   $0x1e
  jmp alltraps
8010531f:	e9 be fa ff ff       	jmp    80104de2 <alltraps>

80105324 <vector31>:
.globl vector31
vector31:
  pushl $0
80105324:	6a 00                	push   $0x0
  pushl $31
80105326:	6a 1f                	push   $0x1f
  jmp alltraps
80105328:	e9 b5 fa ff ff       	jmp    80104de2 <alltraps>

8010532d <vector32>:
.globl vector32
vector32:
  pushl $0
8010532d:	6a 00                	push   $0x0
  pushl $32
8010532f:	6a 20                	push   $0x20
  jmp alltraps
80105331:	e9 ac fa ff ff       	jmp    80104de2 <alltraps>

80105336 <vector33>:
.globl vector33
vector33:
  pushl $0
80105336:	6a 00                	push   $0x0
  pushl $33
80105338:	6a 21                	push   $0x21
  jmp alltraps
8010533a:	e9 a3 fa ff ff       	jmp    80104de2 <alltraps>

8010533f <vector34>:
.globl vector34
vector34:
  pushl $0
8010533f:	6a 00                	push   $0x0
  pushl $34
80105341:	6a 22                	push   $0x22
  jmp alltraps
80105343:	e9 9a fa ff ff       	jmp    80104de2 <alltraps>

80105348 <vector35>:
.globl vector35
vector35:
  pushl $0
80105348:	6a 00                	push   $0x0
  pushl $35
8010534a:	6a 23                	push   $0x23
  jmp alltraps
8010534c:	e9 91 fa ff ff       	jmp    80104de2 <alltraps>

80105351 <vector36>:
.globl vector36
vector36:
  pushl $0
80105351:	6a 00                	push   $0x0
  pushl $36
80105353:	6a 24                	push   $0x24
  jmp alltraps
80105355:	e9 88 fa ff ff       	jmp    80104de2 <alltraps>

8010535a <vector37>:
.globl vector37
vector37:
  pushl $0
8010535a:	6a 00                	push   $0x0
  pushl $37
8010535c:	6a 25                	push   $0x25
  jmp alltraps
8010535e:	e9 7f fa ff ff       	jmp    80104de2 <alltraps>

80105363 <vector38>:
.globl vector38
vector38:
  pushl $0
80105363:	6a 00                	push   $0x0
  pushl $38
80105365:	6a 26                	push   $0x26
  jmp alltraps
80105367:	e9 76 fa ff ff       	jmp    80104de2 <alltraps>

8010536c <vector39>:
.globl vector39
vector39:
  pushl $0
8010536c:	6a 00                	push   $0x0
  pushl $39
8010536e:	6a 27                	push   $0x27
  jmp alltraps
80105370:	e9 6d fa ff ff       	jmp    80104de2 <alltraps>

80105375 <vector40>:
.globl vector40
vector40:
  pushl $0
80105375:	6a 00                	push   $0x0
  pushl $40
80105377:	6a 28                	push   $0x28
  jmp alltraps
80105379:	e9 64 fa ff ff       	jmp    80104de2 <alltraps>

8010537e <vector41>:
.globl vector41
vector41:
  pushl $0
8010537e:	6a 00                	push   $0x0
  pushl $41
80105380:	6a 29                	push   $0x29
  jmp alltraps
80105382:	e9 5b fa ff ff       	jmp    80104de2 <alltraps>

80105387 <vector42>:
.globl vector42
vector42:
  pushl $0
80105387:	6a 00                	push   $0x0
  pushl $42
80105389:	6a 2a                	push   $0x2a
  jmp alltraps
8010538b:	e9 52 fa ff ff       	jmp    80104de2 <alltraps>

80105390 <vector43>:
.globl vector43
vector43:
  pushl $0
80105390:	6a 00                	push   $0x0
  pushl $43
80105392:	6a 2b                	push   $0x2b
  jmp alltraps
80105394:	e9 49 fa ff ff       	jmp    80104de2 <alltraps>

80105399 <vector44>:
.globl vector44
vector44:
  pushl $0
80105399:	6a 00                	push   $0x0
  pushl $44
8010539b:	6a 2c                	push   $0x2c
  jmp alltraps
8010539d:	e9 40 fa ff ff       	jmp    80104de2 <alltraps>

801053a2 <vector45>:
.globl vector45
vector45:
  pushl $0
801053a2:	6a 00                	push   $0x0
  pushl $45
801053a4:	6a 2d                	push   $0x2d
  jmp alltraps
801053a6:	e9 37 fa ff ff       	jmp    80104de2 <alltraps>

801053ab <vector46>:
.globl vector46
vector46:
  pushl $0
801053ab:	6a 00                	push   $0x0
  pushl $46
801053ad:	6a 2e                	push   $0x2e
  jmp alltraps
801053af:	e9 2e fa ff ff       	jmp    80104de2 <alltraps>

801053b4 <vector47>:
.globl vector47
vector47:
  pushl $0
801053b4:	6a 00                	push   $0x0
  pushl $47
801053b6:	6a 2f                	push   $0x2f
  jmp alltraps
801053b8:	e9 25 fa ff ff       	jmp    80104de2 <alltraps>

801053bd <vector48>:
.globl vector48
vector48:
  pushl $0
801053bd:	6a 00                	push   $0x0
  pushl $48
801053bf:	6a 30                	push   $0x30
  jmp alltraps
801053c1:	e9 1c fa ff ff       	jmp    80104de2 <alltraps>

801053c6 <vector49>:
.globl vector49
vector49:
  pushl $0
801053c6:	6a 00                	push   $0x0
  pushl $49
801053c8:	6a 31                	push   $0x31
  jmp alltraps
801053ca:	e9 13 fa ff ff       	jmp    80104de2 <alltraps>

801053cf <vector50>:
.globl vector50
vector50:
  pushl $0
801053cf:	6a 00                	push   $0x0
  pushl $50
801053d1:	6a 32                	push   $0x32
  jmp alltraps
801053d3:	e9 0a fa ff ff       	jmp    80104de2 <alltraps>

801053d8 <vector51>:
.globl vector51
vector51:
  pushl $0
801053d8:	6a 00                	push   $0x0
  pushl $51
801053da:	6a 33                	push   $0x33
  jmp alltraps
801053dc:	e9 01 fa ff ff       	jmp    80104de2 <alltraps>

801053e1 <vector52>:
.globl vector52
vector52:
  pushl $0
801053e1:	6a 00                	push   $0x0
  pushl $52
801053e3:	6a 34                	push   $0x34
  jmp alltraps
801053e5:	e9 f8 f9 ff ff       	jmp    80104de2 <alltraps>

801053ea <vector53>:
.globl vector53
vector53:
  pushl $0
801053ea:	6a 00                	push   $0x0
  pushl $53
801053ec:	6a 35                	push   $0x35
  jmp alltraps
801053ee:	e9 ef f9 ff ff       	jmp    80104de2 <alltraps>

801053f3 <vector54>:
.globl vector54
vector54:
  pushl $0
801053f3:	6a 00                	push   $0x0
  pushl $54
801053f5:	6a 36                	push   $0x36
  jmp alltraps
801053f7:	e9 e6 f9 ff ff       	jmp    80104de2 <alltraps>

801053fc <vector55>:
.globl vector55
vector55:
  pushl $0
801053fc:	6a 00                	push   $0x0
  pushl $55
801053fe:	6a 37                	push   $0x37
  jmp alltraps
80105400:	e9 dd f9 ff ff       	jmp    80104de2 <alltraps>

80105405 <vector56>:
.globl vector56
vector56:
  pushl $0
80105405:	6a 00                	push   $0x0
  pushl $56
80105407:	6a 38                	push   $0x38
  jmp alltraps
80105409:	e9 d4 f9 ff ff       	jmp    80104de2 <alltraps>

8010540e <vector57>:
.globl vector57
vector57:
  pushl $0
8010540e:	6a 00                	push   $0x0
  pushl $57
80105410:	6a 39                	push   $0x39
  jmp alltraps
80105412:	e9 cb f9 ff ff       	jmp    80104de2 <alltraps>

80105417 <vector58>:
.globl vector58
vector58:
  pushl $0
80105417:	6a 00                	push   $0x0
  pushl $58
80105419:	6a 3a                	push   $0x3a
  jmp alltraps
8010541b:	e9 c2 f9 ff ff       	jmp    80104de2 <alltraps>

80105420 <vector59>:
.globl vector59
vector59:
  pushl $0
80105420:	6a 00                	push   $0x0
  pushl $59
80105422:	6a 3b                	push   $0x3b
  jmp alltraps
80105424:	e9 b9 f9 ff ff       	jmp    80104de2 <alltraps>

80105429 <vector60>:
.globl vector60
vector60:
  pushl $0
80105429:	6a 00                	push   $0x0
  pushl $60
8010542b:	6a 3c                	push   $0x3c
  jmp alltraps
8010542d:	e9 b0 f9 ff ff       	jmp    80104de2 <alltraps>

80105432 <vector61>:
.globl vector61
vector61:
  pushl $0
80105432:	6a 00                	push   $0x0
  pushl $61
80105434:	6a 3d                	push   $0x3d
  jmp alltraps
80105436:	e9 a7 f9 ff ff       	jmp    80104de2 <alltraps>

8010543b <vector62>:
.globl vector62
vector62:
  pushl $0
8010543b:	6a 00                	push   $0x0
  pushl $62
8010543d:	6a 3e                	push   $0x3e
  jmp alltraps
8010543f:	e9 9e f9 ff ff       	jmp    80104de2 <alltraps>

80105444 <vector63>:
.globl vector63
vector63:
  pushl $0
80105444:	6a 00                	push   $0x0
  pushl $63
80105446:	6a 3f                	push   $0x3f
  jmp alltraps
80105448:	e9 95 f9 ff ff       	jmp    80104de2 <alltraps>

8010544d <vector64>:
.globl vector64
vector64:
  pushl $0
8010544d:	6a 00                	push   $0x0
  pushl $64
8010544f:	6a 40                	push   $0x40
  jmp alltraps
80105451:	e9 8c f9 ff ff       	jmp    80104de2 <alltraps>

80105456 <vector65>:
.globl vector65
vector65:
  pushl $0
80105456:	6a 00                	push   $0x0
  pushl $65
80105458:	6a 41                	push   $0x41
  jmp alltraps
8010545a:	e9 83 f9 ff ff       	jmp    80104de2 <alltraps>

8010545f <vector66>:
.globl vector66
vector66:
  pushl $0
8010545f:	6a 00                	push   $0x0
  pushl $66
80105461:	6a 42                	push   $0x42
  jmp alltraps
80105463:	e9 7a f9 ff ff       	jmp    80104de2 <alltraps>

80105468 <vector67>:
.globl vector67
vector67:
  pushl $0
80105468:	6a 00                	push   $0x0
  pushl $67
8010546a:	6a 43                	push   $0x43
  jmp alltraps
8010546c:	e9 71 f9 ff ff       	jmp    80104de2 <alltraps>

80105471 <vector68>:
.globl vector68
vector68:
  pushl $0
80105471:	6a 00                	push   $0x0
  pushl $68
80105473:	6a 44                	push   $0x44
  jmp alltraps
80105475:	e9 68 f9 ff ff       	jmp    80104de2 <alltraps>

8010547a <vector69>:
.globl vector69
vector69:
  pushl $0
8010547a:	6a 00                	push   $0x0
  pushl $69
8010547c:	6a 45                	push   $0x45
  jmp alltraps
8010547e:	e9 5f f9 ff ff       	jmp    80104de2 <alltraps>

80105483 <vector70>:
.globl vector70
vector70:
  pushl $0
80105483:	6a 00                	push   $0x0
  pushl $70
80105485:	6a 46                	push   $0x46
  jmp alltraps
80105487:	e9 56 f9 ff ff       	jmp    80104de2 <alltraps>

8010548c <vector71>:
.globl vector71
vector71:
  pushl $0
8010548c:	6a 00                	push   $0x0
  pushl $71
8010548e:	6a 47                	push   $0x47
  jmp alltraps
80105490:	e9 4d f9 ff ff       	jmp    80104de2 <alltraps>

80105495 <vector72>:
.globl vector72
vector72:
  pushl $0
80105495:	6a 00                	push   $0x0
  pushl $72
80105497:	6a 48                	push   $0x48
  jmp alltraps
80105499:	e9 44 f9 ff ff       	jmp    80104de2 <alltraps>

8010549e <vector73>:
.globl vector73
vector73:
  pushl $0
8010549e:	6a 00                	push   $0x0
  pushl $73
801054a0:	6a 49                	push   $0x49
  jmp alltraps
801054a2:	e9 3b f9 ff ff       	jmp    80104de2 <alltraps>

801054a7 <vector74>:
.globl vector74
vector74:
  pushl $0
801054a7:	6a 00                	push   $0x0
  pushl $74
801054a9:	6a 4a                	push   $0x4a
  jmp alltraps
801054ab:	e9 32 f9 ff ff       	jmp    80104de2 <alltraps>

801054b0 <vector75>:
.globl vector75
vector75:
  pushl $0
801054b0:	6a 00                	push   $0x0
  pushl $75
801054b2:	6a 4b                	push   $0x4b
  jmp alltraps
801054b4:	e9 29 f9 ff ff       	jmp    80104de2 <alltraps>

801054b9 <vector76>:
.globl vector76
vector76:
  pushl $0
801054b9:	6a 00                	push   $0x0
  pushl $76
801054bb:	6a 4c                	push   $0x4c
  jmp alltraps
801054bd:	e9 20 f9 ff ff       	jmp    80104de2 <alltraps>

801054c2 <vector77>:
.globl vector77
vector77:
  pushl $0
801054c2:	6a 00                	push   $0x0
  pushl $77
801054c4:	6a 4d                	push   $0x4d
  jmp alltraps
801054c6:	e9 17 f9 ff ff       	jmp    80104de2 <alltraps>

801054cb <vector78>:
.globl vector78
vector78:
  pushl $0
801054cb:	6a 00                	push   $0x0
  pushl $78
801054cd:	6a 4e                	push   $0x4e
  jmp alltraps
801054cf:	e9 0e f9 ff ff       	jmp    80104de2 <alltraps>

801054d4 <vector79>:
.globl vector79
vector79:
  pushl $0
801054d4:	6a 00                	push   $0x0
  pushl $79
801054d6:	6a 4f                	push   $0x4f
  jmp alltraps
801054d8:	e9 05 f9 ff ff       	jmp    80104de2 <alltraps>

801054dd <vector80>:
.globl vector80
vector80:
  pushl $0
801054dd:	6a 00                	push   $0x0
  pushl $80
801054df:	6a 50                	push   $0x50
  jmp alltraps
801054e1:	e9 fc f8 ff ff       	jmp    80104de2 <alltraps>

801054e6 <vector81>:
.globl vector81
vector81:
  pushl $0
801054e6:	6a 00                	push   $0x0
  pushl $81
801054e8:	6a 51                	push   $0x51
  jmp alltraps
801054ea:	e9 f3 f8 ff ff       	jmp    80104de2 <alltraps>

801054ef <vector82>:
.globl vector82
vector82:
  pushl $0
801054ef:	6a 00                	push   $0x0
  pushl $82
801054f1:	6a 52                	push   $0x52
  jmp alltraps
801054f3:	e9 ea f8 ff ff       	jmp    80104de2 <alltraps>

801054f8 <vector83>:
.globl vector83
vector83:
  pushl $0
801054f8:	6a 00                	push   $0x0
  pushl $83
801054fa:	6a 53                	push   $0x53
  jmp alltraps
801054fc:	e9 e1 f8 ff ff       	jmp    80104de2 <alltraps>

80105501 <vector84>:
.globl vector84
vector84:
  pushl $0
80105501:	6a 00                	push   $0x0
  pushl $84
80105503:	6a 54                	push   $0x54
  jmp alltraps
80105505:	e9 d8 f8 ff ff       	jmp    80104de2 <alltraps>

8010550a <vector85>:
.globl vector85
vector85:
  pushl $0
8010550a:	6a 00                	push   $0x0
  pushl $85
8010550c:	6a 55                	push   $0x55
  jmp alltraps
8010550e:	e9 cf f8 ff ff       	jmp    80104de2 <alltraps>

80105513 <vector86>:
.globl vector86
vector86:
  pushl $0
80105513:	6a 00                	push   $0x0
  pushl $86
80105515:	6a 56                	push   $0x56
  jmp alltraps
80105517:	e9 c6 f8 ff ff       	jmp    80104de2 <alltraps>

8010551c <vector87>:
.globl vector87
vector87:
  pushl $0
8010551c:	6a 00                	push   $0x0
  pushl $87
8010551e:	6a 57                	push   $0x57
  jmp alltraps
80105520:	e9 bd f8 ff ff       	jmp    80104de2 <alltraps>

80105525 <vector88>:
.globl vector88
vector88:
  pushl $0
80105525:	6a 00                	push   $0x0
  pushl $88
80105527:	6a 58                	push   $0x58
  jmp alltraps
80105529:	e9 b4 f8 ff ff       	jmp    80104de2 <alltraps>

8010552e <vector89>:
.globl vector89
vector89:
  pushl $0
8010552e:	6a 00                	push   $0x0
  pushl $89
80105530:	6a 59                	push   $0x59
  jmp alltraps
80105532:	e9 ab f8 ff ff       	jmp    80104de2 <alltraps>

80105537 <vector90>:
.globl vector90
vector90:
  pushl $0
80105537:	6a 00                	push   $0x0
  pushl $90
80105539:	6a 5a                	push   $0x5a
  jmp alltraps
8010553b:	e9 a2 f8 ff ff       	jmp    80104de2 <alltraps>

80105540 <vector91>:
.globl vector91
vector91:
  pushl $0
80105540:	6a 00                	push   $0x0
  pushl $91
80105542:	6a 5b                	push   $0x5b
  jmp alltraps
80105544:	e9 99 f8 ff ff       	jmp    80104de2 <alltraps>

80105549 <vector92>:
.globl vector92
vector92:
  pushl $0
80105549:	6a 00                	push   $0x0
  pushl $92
8010554b:	6a 5c                	push   $0x5c
  jmp alltraps
8010554d:	e9 90 f8 ff ff       	jmp    80104de2 <alltraps>

80105552 <vector93>:
.globl vector93
vector93:
  pushl $0
80105552:	6a 00                	push   $0x0
  pushl $93
80105554:	6a 5d                	push   $0x5d
  jmp alltraps
80105556:	e9 87 f8 ff ff       	jmp    80104de2 <alltraps>

8010555b <vector94>:
.globl vector94
vector94:
  pushl $0
8010555b:	6a 00                	push   $0x0
  pushl $94
8010555d:	6a 5e                	push   $0x5e
  jmp alltraps
8010555f:	e9 7e f8 ff ff       	jmp    80104de2 <alltraps>

80105564 <vector95>:
.globl vector95
vector95:
  pushl $0
80105564:	6a 00                	push   $0x0
  pushl $95
80105566:	6a 5f                	push   $0x5f
  jmp alltraps
80105568:	e9 75 f8 ff ff       	jmp    80104de2 <alltraps>

8010556d <vector96>:
.globl vector96
vector96:
  pushl $0
8010556d:	6a 00                	push   $0x0
  pushl $96
8010556f:	6a 60                	push   $0x60
  jmp alltraps
80105571:	e9 6c f8 ff ff       	jmp    80104de2 <alltraps>

80105576 <vector97>:
.globl vector97
vector97:
  pushl $0
80105576:	6a 00                	push   $0x0
  pushl $97
80105578:	6a 61                	push   $0x61
  jmp alltraps
8010557a:	e9 63 f8 ff ff       	jmp    80104de2 <alltraps>

8010557f <vector98>:
.globl vector98
vector98:
  pushl $0
8010557f:	6a 00                	push   $0x0
  pushl $98
80105581:	6a 62                	push   $0x62
  jmp alltraps
80105583:	e9 5a f8 ff ff       	jmp    80104de2 <alltraps>

80105588 <vector99>:
.globl vector99
vector99:
  pushl $0
80105588:	6a 00                	push   $0x0
  pushl $99
8010558a:	6a 63                	push   $0x63
  jmp alltraps
8010558c:	e9 51 f8 ff ff       	jmp    80104de2 <alltraps>

80105591 <vector100>:
.globl vector100
vector100:
  pushl $0
80105591:	6a 00                	push   $0x0
  pushl $100
80105593:	6a 64                	push   $0x64
  jmp alltraps
80105595:	e9 48 f8 ff ff       	jmp    80104de2 <alltraps>

8010559a <vector101>:
.globl vector101
vector101:
  pushl $0
8010559a:	6a 00                	push   $0x0
  pushl $101
8010559c:	6a 65                	push   $0x65
  jmp alltraps
8010559e:	e9 3f f8 ff ff       	jmp    80104de2 <alltraps>

801055a3 <vector102>:
.globl vector102
vector102:
  pushl $0
801055a3:	6a 00                	push   $0x0
  pushl $102
801055a5:	6a 66                	push   $0x66
  jmp alltraps
801055a7:	e9 36 f8 ff ff       	jmp    80104de2 <alltraps>

801055ac <vector103>:
.globl vector103
vector103:
  pushl $0
801055ac:	6a 00                	push   $0x0
  pushl $103
801055ae:	6a 67                	push   $0x67
  jmp alltraps
801055b0:	e9 2d f8 ff ff       	jmp    80104de2 <alltraps>

801055b5 <vector104>:
.globl vector104
vector104:
  pushl $0
801055b5:	6a 00                	push   $0x0
  pushl $104
801055b7:	6a 68                	push   $0x68
  jmp alltraps
801055b9:	e9 24 f8 ff ff       	jmp    80104de2 <alltraps>

801055be <vector105>:
.globl vector105
vector105:
  pushl $0
801055be:	6a 00                	push   $0x0
  pushl $105
801055c0:	6a 69                	push   $0x69
  jmp alltraps
801055c2:	e9 1b f8 ff ff       	jmp    80104de2 <alltraps>

801055c7 <vector106>:
.globl vector106
vector106:
  pushl $0
801055c7:	6a 00                	push   $0x0
  pushl $106
801055c9:	6a 6a                	push   $0x6a
  jmp alltraps
801055cb:	e9 12 f8 ff ff       	jmp    80104de2 <alltraps>

801055d0 <vector107>:
.globl vector107
vector107:
  pushl $0
801055d0:	6a 00                	push   $0x0
  pushl $107
801055d2:	6a 6b                	push   $0x6b
  jmp alltraps
801055d4:	e9 09 f8 ff ff       	jmp    80104de2 <alltraps>

801055d9 <vector108>:
.globl vector108
vector108:
  pushl $0
801055d9:	6a 00                	push   $0x0
  pushl $108
801055db:	6a 6c                	push   $0x6c
  jmp alltraps
801055dd:	e9 00 f8 ff ff       	jmp    80104de2 <alltraps>

801055e2 <vector109>:
.globl vector109
vector109:
  pushl $0
801055e2:	6a 00                	push   $0x0
  pushl $109
801055e4:	6a 6d                	push   $0x6d
  jmp alltraps
801055e6:	e9 f7 f7 ff ff       	jmp    80104de2 <alltraps>

801055eb <vector110>:
.globl vector110
vector110:
  pushl $0
801055eb:	6a 00                	push   $0x0
  pushl $110
801055ed:	6a 6e                	push   $0x6e
  jmp alltraps
801055ef:	e9 ee f7 ff ff       	jmp    80104de2 <alltraps>

801055f4 <vector111>:
.globl vector111
vector111:
  pushl $0
801055f4:	6a 00                	push   $0x0
  pushl $111
801055f6:	6a 6f                	push   $0x6f
  jmp alltraps
801055f8:	e9 e5 f7 ff ff       	jmp    80104de2 <alltraps>

801055fd <vector112>:
.globl vector112
vector112:
  pushl $0
801055fd:	6a 00                	push   $0x0
  pushl $112
801055ff:	6a 70                	push   $0x70
  jmp alltraps
80105601:	e9 dc f7 ff ff       	jmp    80104de2 <alltraps>

80105606 <vector113>:
.globl vector113
vector113:
  pushl $0
80105606:	6a 00                	push   $0x0
  pushl $113
80105608:	6a 71                	push   $0x71
  jmp alltraps
8010560a:	e9 d3 f7 ff ff       	jmp    80104de2 <alltraps>

8010560f <vector114>:
.globl vector114
vector114:
  pushl $0
8010560f:	6a 00                	push   $0x0
  pushl $114
80105611:	6a 72                	push   $0x72
  jmp alltraps
80105613:	e9 ca f7 ff ff       	jmp    80104de2 <alltraps>

80105618 <vector115>:
.globl vector115
vector115:
  pushl $0
80105618:	6a 00                	push   $0x0
  pushl $115
8010561a:	6a 73                	push   $0x73
  jmp alltraps
8010561c:	e9 c1 f7 ff ff       	jmp    80104de2 <alltraps>

80105621 <vector116>:
.globl vector116
vector116:
  pushl $0
80105621:	6a 00                	push   $0x0
  pushl $116
80105623:	6a 74                	push   $0x74
  jmp alltraps
80105625:	e9 b8 f7 ff ff       	jmp    80104de2 <alltraps>

8010562a <vector117>:
.globl vector117
vector117:
  pushl $0
8010562a:	6a 00                	push   $0x0
  pushl $117
8010562c:	6a 75                	push   $0x75
  jmp alltraps
8010562e:	e9 af f7 ff ff       	jmp    80104de2 <alltraps>

80105633 <vector118>:
.globl vector118
vector118:
  pushl $0
80105633:	6a 00                	push   $0x0
  pushl $118
80105635:	6a 76                	push   $0x76
  jmp alltraps
80105637:	e9 a6 f7 ff ff       	jmp    80104de2 <alltraps>

8010563c <vector119>:
.globl vector119
vector119:
  pushl $0
8010563c:	6a 00                	push   $0x0
  pushl $119
8010563e:	6a 77                	push   $0x77
  jmp alltraps
80105640:	e9 9d f7 ff ff       	jmp    80104de2 <alltraps>

80105645 <vector120>:
.globl vector120
vector120:
  pushl $0
80105645:	6a 00                	push   $0x0
  pushl $120
80105647:	6a 78                	push   $0x78
  jmp alltraps
80105649:	e9 94 f7 ff ff       	jmp    80104de2 <alltraps>

8010564e <vector121>:
.globl vector121
vector121:
  pushl $0
8010564e:	6a 00                	push   $0x0
  pushl $121
80105650:	6a 79                	push   $0x79
  jmp alltraps
80105652:	e9 8b f7 ff ff       	jmp    80104de2 <alltraps>

80105657 <vector122>:
.globl vector122
vector122:
  pushl $0
80105657:	6a 00                	push   $0x0
  pushl $122
80105659:	6a 7a                	push   $0x7a
  jmp alltraps
8010565b:	e9 82 f7 ff ff       	jmp    80104de2 <alltraps>

80105660 <vector123>:
.globl vector123
vector123:
  pushl $0
80105660:	6a 00                	push   $0x0
  pushl $123
80105662:	6a 7b                	push   $0x7b
  jmp alltraps
80105664:	e9 79 f7 ff ff       	jmp    80104de2 <alltraps>

80105669 <vector124>:
.globl vector124
vector124:
  pushl $0
80105669:	6a 00                	push   $0x0
  pushl $124
8010566b:	6a 7c                	push   $0x7c
  jmp alltraps
8010566d:	e9 70 f7 ff ff       	jmp    80104de2 <alltraps>

80105672 <vector125>:
.globl vector125
vector125:
  pushl $0
80105672:	6a 00                	push   $0x0
  pushl $125
80105674:	6a 7d                	push   $0x7d
  jmp alltraps
80105676:	e9 67 f7 ff ff       	jmp    80104de2 <alltraps>

8010567b <vector126>:
.globl vector126
vector126:
  pushl $0
8010567b:	6a 00                	push   $0x0
  pushl $126
8010567d:	6a 7e                	push   $0x7e
  jmp alltraps
8010567f:	e9 5e f7 ff ff       	jmp    80104de2 <alltraps>

80105684 <vector127>:
.globl vector127
vector127:
  pushl $0
80105684:	6a 00                	push   $0x0
  pushl $127
80105686:	6a 7f                	push   $0x7f
  jmp alltraps
80105688:	e9 55 f7 ff ff       	jmp    80104de2 <alltraps>

8010568d <vector128>:
.globl vector128
vector128:
  pushl $0
8010568d:	6a 00                	push   $0x0
  pushl $128
8010568f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105694:	e9 49 f7 ff ff       	jmp    80104de2 <alltraps>

80105699 <vector129>:
.globl vector129
vector129:
  pushl $0
80105699:	6a 00                	push   $0x0
  pushl $129
8010569b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801056a0:	e9 3d f7 ff ff       	jmp    80104de2 <alltraps>

801056a5 <vector130>:
.globl vector130
vector130:
  pushl $0
801056a5:	6a 00                	push   $0x0
  pushl $130
801056a7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801056ac:	e9 31 f7 ff ff       	jmp    80104de2 <alltraps>

801056b1 <vector131>:
.globl vector131
vector131:
  pushl $0
801056b1:	6a 00                	push   $0x0
  pushl $131
801056b3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801056b8:	e9 25 f7 ff ff       	jmp    80104de2 <alltraps>

801056bd <vector132>:
.globl vector132
vector132:
  pushl $0
801056bd:	6a 00                	push   $0x0
  pushl $132
801056bf:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801056c4:	e9 19 f7 ff ff       	jmp    80104de2 <alltraps>

801056c9 <vector133>:
.globl vector133
vector133:
  pushl $0
801056c9:	6a 00                	push   $0x0
  pushl $133
801056cb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801056d0:	e9 0d f7 ff ff       	jmp    80104de2 <alltraps>

801056d5 <vector134>:
.globl vector134
vector134:
  pushl $0
801056d5:	6a 00                	push   $0x0
  pushl $134
801056d7:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801056dc:	e9 01 f7 ff ff       	jmp    80104de2 <alltraps>

801056e1 <vector135>:
.globl vector135
vector135:
  pushl $0
801056e1:	6a 00                	push   $0x0
  pushl $135
801056e3:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801056e8:	e9 f5 f6 ff ff       	jmp    80104de2 <alltraps>

801056ed <vector136>:
.globl vector136
vector136:
  pushl $0
801056ed:	6a 00                	push   $0x0
  pushl $136
801056ef:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056f4:	e9 e9 f6 ff ff       	jmp    80104de2 <alltraps>

801056f9 <vector137>:
.globl vector137
vector137:
  pushl $0
801056f9:	6a 00                	push   $0x0
  pushl $137
801056fb:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105700:	e9 dd f6 ff ff       	jmp    80104de2 <alltraps>

80105705 <vector138>:
.globl vector138
vector138:
  pushl $0
80105705:	6a 00                	push   $0x0
  pushl $138
80105707:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010570c:	e9 d1 f6 ff ff       	jmp    80104de2 <alltraps>

80105711 <vector139>:
.globl vector139
vector139:
  pushl $0
80105711:	6a 00                	push   $0x0
  pushl $139
80105713:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105718:	e9 c5 f6 ff ff       	jmp    80104de2 <alltraps>

8010571d <vector140>:
.globl vector140
vector140:
  pushl $0
8010571d:	6a 00                	push   $0x0
  pushl $140
8010571f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105724:	e9 b9 f6 ff ff       	jmp    80104de2 <alltraps>

80105729 <vector141>:
.globl vector141
vector141:
  pushl $0
80105729:	6a 00                	push   $0x0
  pushl $141
8010572b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105730:	e9 ad f6 ff ff       	jmp    80104de2 <alltraps>

80105735 <vector142>:
.globl vector142
vector142:
  pushl $0
80105735:	6a 00                	push   $0x0
  pushl $142
80105737:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010573c:	e9 a1 f6 ff ff       	jmp    80104de2 <alltraps>

80105741 <vector143>:
.globl vector143
vector143:
  pushl $0
80105741:	6a 00                	push   $0x0
  pushl $143
80105743:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105748:	e9 95 f6 ff ff       	jmp    80104de2 <alltraps>

8010574d <vector144>:
.globl vector144
vector144:
  pushl $0
8010574d:	6a 00                	push   $0x0
  pushl $144
8010574f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105754:	e9 89 f6 ff ff       	jmp    80104de2 <alltraps>

80105759 <vector145>:
.globl vector145
vector145:
  pushl $0
80105759:	6a 00                	push   $0x0
  pushl $145
8010575b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105760:	e9 7d f6 ff ff       	jmp    80104de2 <alltraps>

80105765 <vector146>:
.globl vector146
vector146:
  pushl $0
80105765:	6a 00                	push   $0x0
  pushl $146
80105767:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010576c:	e9 71 f6 ff ff       	jmp    80104de2 <alltraps>

80105771 <vector147>:
.globl vector147
vector147:
  pushl $0
80105771:	6a 00                	push   $0x0
  pushl $147
80105773:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105778:	e9 65 f6 ff ff       	jmp    80104de2 <alltraps>

8010577d <vector148>:
.globl vector148
vector148:
  pushl $0
8010577d:	6a 00                	push   $0x0
  pushl $148
8010577f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105784:	e9 59 f6 ff ff       	jmp    80104de2 <alltraps>

80105789 <vector149>:
.globl vector149
vector149:
  pushl $0
80105789:	6a 00                	push   $0x0
  pushl $149
8010578b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105790:	e9 4d f6 ff ff       	jmp    80104de2 <alltraps>

80105795 <vector150>:
.globl vector150
vector150:
  pushl $0
80105795:	6a 00                	push   $0x0
  pushl $150
80105797:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010579c:	e9 41 f6 ff ff       	jmp    80104de2 <alltraps>

801057a1 <vector151>:
.globl vector151
vector151:
  pushl $0
801057a1:	6a 00                	push   $0x0
  pushl $151
801057a3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801057a8:	e9 35 f6 ff ff       	jmp    80104de2 <alltraps>

801057ad <vector152>:
.globl vector152
vector152:
  pushl $0
801057ad:	6a 00                	push   $0x0
  pushl $152
801057af:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801057b4:	e9 29 f6 ff ff       	jmp    80104de2 <alltraps>

801057b9 <vector153>:
.globl vector153
vector153:
  pushl $0
801057b9:	6a 00                	push   $0x0
  pushl $153
801057bb:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801057c0:	e9 1d f6 ff ff       	jmp    80104de2 <alltraps>

801057c5 <vector154>:
.globl vector154
vector154:
  pushl $0
801057c5:	6a 00                	push   $0x0
  pushl $154
801057c7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801057cc:	e9 11 f6 ff ff       	jmp    80104de2 <alltraps>

801057d1 <vector155>:
.globl vector155
vector155:
  pushl $0
801057d1:	6a 00                	push   $0x0
  pushl $155
801057d3:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801057d8:	e9 05 f6 ff ff       	jmp    80104de2 <alltraps>

801057dd <vector156>:
.globl vector156
vector156:
  pushl $0
801057dd:	6a 00                	push   $0x0
  pushl $156
801057df:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801057e4:	e9 f9 f5 ff ff       	jmp    80104de2 <alltraps>

801057e9 <vector157>:
.globl vector157
vector157:
  pushl $0
801057e9:	6a 00                	push   $0x0
  pushl $157
801057eb:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801057f0:	e9 ed f5 ff ff       	jmp    80104de2 <alltraps>

801057f5 <vector158>:
.globl vector158
vector158:
  pushl $0
801057f5:	6a 00                	push   $0x0
  pushl $158
801057f7:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057fc:	e9 e1 f5 ff ff       	jmp    80104de2 <alltraps>

80105801 <vector159>:
.globl vector159
vector159:
  pushl $0
80105801:	6a 00                	push   $0x0
  pushl $159
80105803:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105808:	e9 d5 f5 ff ff       	jmp    80104de2 <alltraps>

8010580d <vector160>:
.globl vector160
vector160:
  pushl $0
8010580d:	6a 00                	push   $0x0
  pushl $160
8010580f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105814:	e9 c9 f5 ff ff       	jmp    80104de2 <alltraps>

80105819 <vector161>:
.globl vector161
vector161:
  pushl $0
80105819:	6a 00                	push   $0x0
  pushl $161
8010581b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105820:	e9 bd f5 ff ff       	jmp    80104de2 <alltraps>

80105825 <vector162>:
.globl vector162
vector162:
  pushl $0
80105825:	6a 00                	push   $0x0
  pushl $162
80105827:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010582c:	e9 b1 f5 ff ff       	jmp    80104de2 <alltraps>

80105831 <vector163>:
.globl vector163
vector163:
  pushl $0
80105831:	6a 00                	push   $0x0
  pushl $163
80105833:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105838:	e9 a5 f5 ff ff       	jmp    80104de2 <alltraps>

8010583d <vector164>:
.globl vector164
vector164:
  pushl $0
8010583d:	6a 00                	push   $0x0
  pushl $164
8010583f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105844:	e9 99 f5 ff ff       	jmp    80104de2 <alltraps>

80105849 <vector165>:
.globl vector165
vector165:
  pushl $0
80105849:	6a 00                	push   $0x0
  pushl $165
8010584b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105850:	e9 8d f5 ff ff       	jmp    80104de2 <alltraps>

80105855 <vector166>:
.globl vector166
vector166:
  pushl $0
80105855:	6a 00                	push   $0x0
  pushl $166
80105857:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010585c:	e9 81 f5 ff ff       	jmp    80104de2 <alltraps>

80105861 <vector167>:
.globl vector167
vector167:
  pushl $0
80105861:	6a 00                	push   $0x0
  pushl $167
80105863:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105868:	e9 75 f5 ff ff       	jmp    80104de2 <alltraps>

8010586d <vector168>:
.globl vector168
vector168:
  pushl $0
8010586d:	6a 00                	push   $0x0
  pushl $168
8010586f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105874:	e9 69 f5 ff ff       	jmp    80104de2 <alltraps>

80105879 <vector169>:
.globl vector169
vector169:
  pushl $0
80105879:	6a 00                	push   $0x0
  pushl $169
8010587b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105880:	e9 5d f5 ff ff       	jmp    80104de2 <alltraps>

80105885 <vector170>:
.globl vector170
vector170:
  pushl $0
80105885:	6a 00                	push   $0x0
  pushl $170
80105887:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010588c:	e9 51 f5 ff ff       	jmp    80104de2 <alltraps>

80105891 <vector171>:
.globl vector171
vector171:
  pushl $0
80105891:	6a 00                	push   $0x0
  pushl $171
80105893:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105898:	e9 45 f5 ff ff       	jmp    80104de2 <alltraps>

8010589d <vector172>:
.globl vector172
vector172:
  pushl $0
8010589d:	6a 00                	push   $0x0
  pushl $172
8010589f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801058a4:	e9 39 f5 ff ff       	jmp    80104de2 <alltraps>

801058a9 <vector173>:
.globl vector173
vector173:
  pushl $0
801058a9:	6a 00                	push   $0x0
  pushl $173
801058ab:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801058b0:	e9 2d f5 ff ff       	jmp    80104de2 <alltraps>

801058b5 <vector174>:
.globl vector174
vector174:
  pushl $0
801058b5:	6a 00                	push   $0x0
  pushl $174
801058b7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801058bc:	e9 21 f5 ff ff       	jmp    80104de2 <alltraps>

801058c1 <vector175>:
.globl vector175
vector175:
  pushl $0
801058c1:	6a 00                	push   $0x0
  pushl $175
801058c3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801058c8:	e9 15 f5 ff ff       	jmp    80104de2 <alltraps>

801058cd <vector176>:
.globl vector176
vector176:
  pushl $0
801058cd:	6a 00                	push   $0x0
  pushl $176
801058cf:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801058d4:	e9 09 f5 ff ff       	jmp    80104de2 <alltraps>

801058d9 <vector177>:
.globl vector177
vector177:
  pushl $0
801058d9:	6a 00                	push   $0x0
  pushl $177
801058db:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801058e0:	e9 fd f4 ff ff       	jmp    80104de2 <alltraps>

801058e5 <vector178>:
.globl vector178
vector178:
  pushl $0
801058e5:	6a 00                	push   $0x0
  pushl $178
801058e7:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801058ec:	e9 f1 f4 ff ff       	jmp    80104de2 <alltraps>

801058f1 <vector179>:
.globl vector179
vector179:
  pushl $0
801058f1:	6a 00                	push   $0x0
  pushl $179
801058f3:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058f8:	e9 e5 f4 ff ff       	jmp    80104de2 <alltraps>

801058fd <vector180>:
.globl vector180
vector180:
  pushl $0
801058fd:	6a 00                	push   $0x0
  pushl $180
801058ff:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105904:	e9 d9 f4 ff ff       	jmp    80104de2 <alltraps>

80105909 <vector181>:
.globl vector181
vector181:
  pushl $0
80105909:	6a 00                	push   $0x0
  pushl $181
8010590b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105910:	e9 cd f4 ff ff       	jmp    80104de2 <alltraps>

80105915 <vector182>:
.globl vector182
vector182:
  pushl $0
80105915:	6a 00                	push   $0x0
  pushl $182
80105917:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010591c:	e9 c1 f4 ff ff       	jmp    80104de2 <alltraps>

80105921 <vector183>:
.globl vector183
vector183:
  pushl $0
80105921:	6a 00                	push   $0x0
  pushl $183
80105923:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105928:	e9 b5 f4 ff ff       	jmp    80104de2 <alltraps>

8010592d <vector184>:
.globl vector184
vector184:
  pushl $0
8010592d:	6a 00                	push   $0x0
  pushl $184
8010592f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105934:	e9 a9 f4 ff ff       	jmp    80104de2 <alltraps>

80105939 <vector185>:
.globl vector185
vector185:
  pushl $0
80105939:	6a 00                	push   $0x0
  pushl $185
8010593b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105940:	e9 9d f4 ff ff       	jmp    80104de2 <alltraps>

80105945 <vector186>:
.globl vector186
vector186:
  pushl $0
80105945:	6a 00                	push   $0x0
  pushl $186
80105947:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010594c:	e9 91 f4 ff ff       	jmp    80104de2 <alltraps>

80105951 <vector187>:
.globl vector187
vector187:
  pushl $0
80105951:	6a 00                	push   $0x0
  pushl $187
80105953:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105958:	e9 85 f4 ff ff       	jmp    80104de2 <alltraps>

8010595d <vector188>:
.globl vector188
vector188:
  pushl $0
8010595d:	6a 00                	push   $0x0
  pushl $188
8010595f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105964:	e9 79 f4 ff ff       	jmp    80104de2 <alltraps>

80105969 <vector189>:
.globl vector189
vector189:
  pushl $0
80105969:	6a 00                	push   $0x0
  pushl $189
8010596b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105970:	e9 6d f4 ff ff       	jmp    80104de2 <alltraps>

80105975 <vector190>:
.globl vector190
vector190:
  pushl $0
80105975:	6a 00                	push   $0x0
  pushl $190
80105977:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010597c:	e9 61 f4 ff ff       	jmp    80104de2 <alltraps>

80105981 <vector191>:
.globl vector191
vector191:
  pushl $0
80105981:	6a 00                	push   $0x0
  pushl $191
80105983:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105988:	e9 55 f4 ff ff       	jmp    80104de2 <alltraps>

8010598d <vector192>:
.globl vector192
vector192:
  pushl $0
8010598d:	6a 00                	push   $0x0
  pushl $192
8010598f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105994:	e9 49 f4 ff ff       	jmp    80104de2 <alltraps>

80105999 <vector193>:
.globl vector193
vector193:
  pushl $0
80105999:	6a 00                	push   $0x0
  pushl $193
8010599b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801059a0:	e9 3d f4 ff ff       	jmp    80104de2 <alltraps>

801059a5 <vector194>:
.globl vector194
vector194:
  pushl $0
801059a5:	6a 00                	push   $0x0
  pushl $194
801059a7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801059ac:	e9 31 f4 ff ff       	jmp    80104de2 <alltraps>

801059b1 <vector195>:
.globl vector195
vector195:
  pushl $0
801059b1:	6a 00                	push   $0x0
  pushl $195
801059b3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801059b8:	e9 25 f4 ff ff       	jmp    80104de2 <alltraps>

801059bd <vector196>:
.globl vector196
vector196:
  pushl $0
801059bd:	6a 00                	push   $0x0
  pushl $196
801059bf:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801059c4:	e9 19 f4 ff ff       	jmp    80104de2 <alltraps>

801059c9 <vector197>:
.globl vector197
vector197:
  pushl $0
801059c9:	6a 00                	push   $0x0
  pushl $197
801059cb:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801059d0:	e9 0d f4 ff ff       	jmp    80104de2 <alltraps>

801059d5 <vector198>:
.globl vector198
vector198:
  pushl $0
801059d5:	6a 00                	push   $0x0
  pushl $198
801059d7:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801059dc:	e9 01 f4 ff ff       	jmp    80104de2 <alltraps>

801059e1 <vector199>:
.globl vector199
vector199:
  pushl $0
801059e1:	6a 00                	push   $0x0
  pushl $199
801059e3:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801059e8:	e9 f5 f3 ff ff       	jmp    80104de2 <alltraps>

801059ed <vector200>:
.globl vector200
vector200:
  pushl $0
801059ed:	6a 00                	push   $0x0
  pushl $200
801059ef:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059f4:	e9 e9 f3 ff ff       	jmp    80104de2 <alltraps>

801059f9 <vector201>:
.globl vector201
vector201:
  pushl $0
801059f9:	6a 00                	push   $0x0
  pushl $201
801059fb:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105a00:	e9 dd f3 ff ff       	jmp    80104de2 <alltraps>

80105a05 <vector202>:
.globl vector202
vector202:
  pushl $0
80105a05:	6a 00                	push   $0x0
  pushl $202
80105a07:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105a0c:	e9 d1 f3 ff ff       	jmp    80104de2 <alltraps>

80105a11 <vector203>:
.globl vector203
vector203:
  pushl $0
80105a11:	6a 00                	push   $0x0
  pushl $203
80105a13:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105a18:	e9 c5 f3 ff ff       	jmp    80104de2 <alltraps>

80105a1d <vector204>:
.globl vector204
vector204:
  pushl $0
80105a1d:	6a 00                	push   $0x0
  pushl $204
80105a1f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105a24:	e9 b9 f3 ff ff       	jmp    80104de2 <alltraps>

80105a29 <vector205>:
.globl vector205
vector205:
  pushl $0
80105a29:	6a 00                	push   $0x0
  pushl $205
80105a2b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105a30:	e9 ad f3 ff ff       	jmp    80104de2 <alltraps>

80105a35 <vector206>:
.globl vector206
vector206:
  pushl $0
80105a35:	6a 00                	push   $0x0
  pushl $206
80105a37:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105a3c:	e9 a1 f3 ff ff       	jmp    80104de2 <alltraps>

80105a41 <vector207>:
.globl vector207
vector207:
  pushl $0
80105a41:	6a 00                	push   $0x0
  pushl $207
80105a43:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a48:	e9 95 f3 ff ff       	jmp    80104de2 <alltraps>

80105a4d <vector208>:
.globl vector208
vector208:
  pushl $0
80105a4d:	6a 00                	push   $0x0
  pushl $208
80105a4f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a54:	e9 89 f3 ff ff       	jmp    80104de2 <alltraps>

80105a59 <vector209>:
.globl vector209
vector209:
  pushl $0
80105a59:	6a 00                	push   $0x0
  pushl $209
80105a5b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a60:	e9 7d f3 ff ff       	jmp    80104de2 <alltraps>

80105a65 <vector210>:
.globl vector210
vector210:
  pushl $0
80105a65:	6a 00                	push   $0x0
  pushl $210
80105a67:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a6c:	e9 71 f3 ff ff       	jmp    80104de2 <alltraps>

80105a71 <vector211>:
.globl vector211
vector211:
  pushl $0
80105a71:	6a 00                	push   $0x0
  pushl $211
80105a73:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a78:	e9 65 f3 ff ff       	jmp    80104de2 <alltraps>

80105a7d <vector212>:
.globl vector212
vector212:
  pushl $0
80105a7d:	6a 00                	push   $0x0
  pushl $212
80105a7f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a84:	e9 59 f3 ff ff       	jmp    80104de2 <alltraps>

80105a89 <vector213>:
.globl vector213
vector213:
  pushl $0
80105a89:	6a 00                	push   $0x0
  pushl $213
80105a8b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a90:	e9 4d f3 ff ff       	jmp    80104de2 <alltraps>

80105a95 <vector214>:
.globl vector214
vector214:
  pushl $0
80105a95:	6a 00                	push   $0x0
  pushl $214
80105a97:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a9c:	e9 41 f3 ff ff       	jmp    80104de2 <alltraps>

80105aa1 <vector215>:
.globl vector215
vector215:
  pushl $0
80105aa1:	6a 00                	push   $0x0
  pushl $215
80105aa3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105aa8:	e9 35 f3 ff ff       	jmp    80104de2 <alltraps>

80105aad <vector216>:
.globl vector216
vector216:
  pushl $0
80105aad:	6a 00                	push   $0x0
  pushl $216
80105aaf:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105ab4:	e9 29 f3 ff ff       	jmp    80104de2 <alltraps>

80105ab9 <vector217>:
.globl vector217
vector217:
  pushl $0
80105ab9:	6a 00                	push   $0x0
  pushl $217
80105abb:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105ac0:	e9 1d f3 ff ff       	jmp    80104de2 <alltraps>

80105ac5 <vector218>:
.globl vector218
vector218:
  pushl $0
80105ac5:	6a 00                	push   $0x0
  pushl $218
80105ac7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105acc:	e9 11 f3 ff ff       	jmp    80104de2 <alltraps>

80105ad1 <vector219>:
.globl vector219
vector219:
  pushl $0
80105ad1:	6a 00                	push   $0x0
  pushl $219
80105ad3:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105ad8:	e9 05 f3 ff ff       	jmp    80104de2 <alltraps>

80105add <vector220>:
.globl vector220
vector220:
  pushl $0
80105add:	6a 00                	push   $0x0
  pushl $220
80105adf:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105ae4:	e9 f9 f2 ff ff       	jmp    80104de2 <alltraps>

80105ae9 <vector221>:
.globl vector221
vector221:
  pushl $0
80105ae9:	6a 00                	push   $0x0
  pushl $221
80105aeb:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105af0:	e9 ed f2 ff ff       	jmp    80104de2 <alltraps>

80105af5 <vector222>:
.globl vector222
vector222:
  pushl $0
80105af5:	6a 00                	push   $0x0
  pushl $222
80105af7:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105afc:	e9 e1 f2 ff ff       	jmp    80104de2 <alltraps>

80105b01 <vector223>:
.globl vector223
vector223:
  pushl $0
80105b01:	6a 00                	push   $0x0
  pushl $223
80105b03:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105b08:	e9 d5 f2 ff ff       	jmp    80104de2 <alltraps>

80105b0d <vector224>:
.globl vector224
vector224:
  pushl $0
80105b0d:	6a 00                	push   $0x0
  pushl $224
80105b0f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105b14:	e9 c9 f2 ff ff       	jmp    80104de2 <alltraps>

80105b19 <vector225>:
.globl vector225
vector225:
  pushl $0
80105b19:	6a 00                	push   $0x0
  pushl $225
80105b1b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105b20:	e9 bd f2 ff ff       	jmp    80104de2 <alltraps>

80105b25 <vector226>:
.globl vector226
vector226:
  pushl $0
80105b25:	6a 00                	push   $0x0
  pushl $226
80105b27:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105b2c:	e9 b1 f2 ff ff       	jmp    80104de2 <alltraps>

80105b31 <vector227>:
.globl vector227
vector227:
  pushl $0
80105b31:	6a 00                	push   $0x0
  pushl $227
80105b33:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105b38:	e9 a5 f2 ff ff       	jmp    80104de2 <alltraps>

80105b3d <vector228>:
.globl vector228
vector228:
  pushl $0
80105b3d:	6a 00                	push   $0x0
  pushl $228
80105b3f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105b44:	e9 99 f2 ff ff       	jmp    80104de2 <alltraps>

80105b49 <vector229>:
.globl vector229
vector229:
  pushl $0
80105b49:	6a 00                	push   $0x0
  pushl $229
80105b4b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b50:	e9 8d f2 ff ff       	jmp    80104de2 <alltraps>

80105b55 <vector230>:
.globl vector230
vector230:
  pushl $0
80105b55:	6a 00                	push   $0x0
  pushl $230
80105b57:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b5c:	e9 81 f2 ff ff       	jmp    80104de2 <alltraps>

80105b61 <vector231>:
.globl vector231
vector231:
  pushl $0
80105b61:	6a 00                	push   $0x0
  pushl $231
80105b63:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b68:	e9 75 f2 ff ff       	jmp    80104de2 <alltraps>

80105b6d <vector232>:
.globl vector232
vector232:
  pushl $0
80105b6d:	6a 00                	push   $0x0
  pushl $232
80105b6f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b74:	e9 69 f2 ff ff       	jmp    80104de2 <alltraps>

80105b79 <vector233>:
.globl vector233
vector233:
  pushl $0
80105b79:	6a 00                	push   $0x0
  pushl $233
80105b7b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b80:	e9 5d f2 ff ff       	jmp    80104de2 <alltraps>

80105b85 <vector234>:
.globl vector234
vector234:
  pushl $0
80105b85:	6a 00                	push   $0x0
  pushl $234
80105b87:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b8c:	e9 51 f2 ff ff       	jmp    80104de2 <alltraps>

80105b91 <vector235>:
.globl vector235
vector235:
  pushl $0
80105b91:	6a 00                	push   $0x0
  pushl $235
80105b93:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b98:	e9 45 f2 ff ff       	jmp    80104de2 <alltraps>

80105b9d <vector236>:
.globl vector236
vector236:
  pushl $0
80105b9d:	6a 00                	push   $0x0
  pushl $236
80105b9f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105ba4:	e9 39 f2 ff ff       	jmp    80104de2 <alltraps>

80105ba9 <vector237>:
.globl vector237
vector237:
  pushl $0
80105ba9:	6a 00                	push   $0x0
  pushl $237
80105bab:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105bb0:	e9 2d f2 ff ff       	jmp    80104de2 <alltraps>

80105bb5 <vector238>:
.globl vector238
vector238:
  pushl $0
80105bb5:	6a 00                	push   $0x0
  pushl $238
80105bb7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105bbc:	e9 21 f2 ff ff       	jmp    80104de2 <alltraps>

80105bc1 <vector239>:
.globl vector239
vector239:
  pushl $0
80105bc1:	6a 00                	push   $0x0
  pushl $239
80105bc3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105bc8:	e9 15 f2 ff ff       	jmp    80104de2 <alltraps>

80105bcd <vector240>:
.globl vector240
vector240:
  pushl $0
80105bcd:	6a 00                	push   $0x0
  pushl $240
80105bcf:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105bd4:	e9 09 f2 ff ff       	jmp    80104de2 <alltraps>

80105bd9 <vector241>:
.globl vector241
vector241:
  pushl $0
80105bd9:	6a 00                	push   $0x0
  pushl $241
80105bdb:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105be0:	e9 fd f1 ff ff       	jmp    80104de2 <alltraps>

80105be5 <vector242>:
.globl vector242
vector242:
  pushl $0
80105be5:	6a 00                	push   $0x0
  pushl $242
80105be7:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105bec:	e9 f1 f1 ff ff       	jmp    80104de2 <alltraps>

80105bf1 <vector243>:
.globl vector243
vector243:
  pushl $0
80105bf1:	6a 00                	push   $0x0
  pushl $243
80105bf3:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105bf8:	e9 e5 f1 ff ff       	jmp    80104de2 <alltraps>

80105bfd <vector244>:
.globl vector244
vector244:
  pushl $0
80105bfd:	6a 00                	push   $0x0
  pushl $244
80105bff:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105c04:	e9 d9 f1 ff ff       	jmp    80104de2 <alltraps>

80105c09 <vector245>:
.globl vector245
vector245:
  pushl $0
80105c09:	6a 00                	push   $0x0
  pushl $245
80105c0b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105c10:	e9 cd f1 ff ff       	jmp    80104de2 <alltraps>

80105c15 <vector246>:
.globl vector246
vector246:
  pushl $0
80105c15:	6a 00                	push   $0x0
  pushl $246
80105c17:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105c1c:	e9 c1 f1 ff ff       	jmp    80104de2 <alltraps>

80105c21 <vector247>:
.globl vector247
vector247:
  pushl $0
80105c21:	6a 00                	push   $0x0
  pushl $247
80105c23:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105c28:	e9 b5 f1 ff ff       	jmp    80104de2 <alltraps>

80105c2d <vector248>:
.globl vector248
vector248:
  pushl $0
80105c2d:	6a 00                	push   $0x0
  pushl $248
80105c2f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105c34:	e9 a9 f1 ff ff       	jmp    80104de2 <alltraps>

80105c39 <vector249>:
.globl vector249
vector249:
  pushl $0
80105c39:	6a 00                	push   $0x0
  pushl $249
80105c3b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105c40:	e9 9d f1 ff ff       	jmp    80104de2 <alltraps>

80105c45 <vector250>:
.globl vector250
vector250:
  pushl $0
80105c45:	6a 00                	push   $0x0
  pushl $250
80105c47:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c4c:	e9 91 f1 ff ff       	jmp    80104de2 <alltraps>

80105c51 <vector251>:
.globl vector251
vector251:
  pushl $0
80105c51:	6a 00                	push   $0x0
  pushl $251
80105c53:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c58:	e9 85 f1 ff ff       	jmp    80104de2 <alltraps>

80105c5d <vector252>:
.globl vector252
vector252:
  pushl $0
80105c5d:	6a 00                	push   $0x0
  pushl $252
80105c5f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c64:	e9 79 f1 ff ff       	jmp    80104de2 <alltraps>

80105c69 <vector253>:
.globl vector253
vector253:
  pushl $0
80105c69:	6a 00                	push   $0x0
  pushl $253
80105c6b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c70:	e9 6d f1 ff ff       	jmp    80104de2 <alltraps>

80105c75 <vector254>:
.globl vector254
vector254:
  pushl $0
80105c75:	6a 00                	push   $0x0
  pushl $254
80105c77:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c7c:	e9 61 f1 ff ff       	jmp    80104de2 <alltraps>

80105c81 <vector255>:
.globl vector255
vector255:
  pushl $0
80105c81:	6a 00                	push   $0x0
  pushl $255
80105c83:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c88:	e9 55 f1 ff ff       	jmp    80104de2 <alltraps>

80105c8d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c8d:	55                   	push   %ebp
80105c8e:	89 e5                	mov    %esp,%ebp
80105c90:	57                   	push   %edi
80105c91:	56                   	push   %esi
80105c92:	53                   	push   %ebx
80105c93:	83 ec 0c             	sub    $0xc,%esp
80105c96:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c98:	c1 ea 16             	shr    $0x16,%edx
80105c9b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c9e:	8b 1f                	mov    (%edi),%ebx
80105ca0:	f6 c3 01             	test   $0x1,%bl
80105ca3:	74 22                	je     80105cc7 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105ca5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105cab:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105cb1:	c1 ee 0c             	shr    $0xc,%esi
80105cb4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105cba:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105cbd:	89 d8                	mov    %ebx,%eax
80105cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105cc2:	5b                   	pop    %ebx
80105cc3:	5e                   	pop    %esi
80105cc4:	5f                   	pop    %edi
80105cc5:	5d                   	pop    %ebp
80105cc6:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105cc7:	85 c9                	test   %ecx,%ecx
80105cc9:	74 2b                	je     80105cf6 <walkpgdir+0x69>
80105ccb:	e8 eb c3 ff ff       	call   801020bb <kalloc>
80105cd0:	89 c3                	mov    %eax,%ebx
80105cd2:	85 c0                	test   %eax,%eax
80105cd4:	74 e7                	je     80105cbd <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105cd6:	83 ec 04             	sub    $0x4,%esp
80105cd9:	68 00 10 00 00       	push   $0x1000
80105cde:	6a 00                	push   $0x0
80105ce0:	50                   	push   %eax
80105ce1:	e8 fe df ff ff       	call   80103ce4 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ce6:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105cec:	83 c8 07             	or     $0x7,%eax
80105cef:	89 07                	mov    %eax,(%edi)
80105cf1:	83 c4 10             	add    $0x10,%esp
80105cf4:	eb bb                	jmp    80105cb1 <walkpgdir+0x24>
      return 0;
80105cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
80105cfb:	eb c0                	jmp    80105cbd <walkpgdir+0x30>

80105cfd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105cfd:	55                   	push   %ebp
80105cfe:	89 e5                	mov    %esp,%ebp
80105d00:	57                   	push   %edi
80105d01:	56                   	push   %esi
80105d02:	53                   	push   %ebx
80105d03:	83 ec 1c             	sub    $0x1c,%esp
80105d06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105d09:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105d0c:	89 d3                	mov    %edx,%ebx
80105d0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105d14:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105d18:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d1e:	b9 01 00 00 00       	mov    $0x1,%ecx
80105d23:	89 da                	mov    %ebx,%edx
80105d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d28:	e8 60 ff ff ff       	call   80105c8d <walkpgdir>
80105d2d:	85 c0                	test   %eax,%eax
80105d2f:	74 2e                	je     80105d5f <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105d31:	f6 00 01             	testb  $0x1,(%eax)
80105d34:	75 1c                	jne    80105d52 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105d36:	89 f2                	mov    %esi,%edx
80105d38:	0b 55 0c             	or     0xc(%ebp),%edx
80105d3b:	83 ca 01             	or     $0x1,%edx
80105d3e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d40:	39 fb                	cmp    %edi,%ebx
80105d42:	74 28                	je     80105d6c <mappages+0x6f>
      break;
    a += PGSIZE;
80105d44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d4a:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d50:	eb cc                	jmp    80105d1e <mappages+0x21>
      panic("remap");
80105d52:	83 ec 0c             	sub    $0xc,%esp
80105d55:	68 0c 6e 10 80       	push   $0x80106e0c
80105d5a:	e8 e9 a5 ff ff       	call   80100348 <panic>
      return -1;
80105d5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d67:	5b                   	pop    %ebx
80105d68:	5e                   	pop    %esi
80105d69:	5f                   	pop    %edi
80105d6a:	5d                   	pop    %ebp
80105d6b:	c3                   	ret    
  return 0;
80105d6c:	b8 00 00 00 00       	mov    $0x0,%eax
80105d71:	eb f1                	jmp    80105d64 <mappages+0x67>

80105d73 <seginit>:
{
80105d73:	55                   	push   %ebp
80105d74:	89 e5                	mov    %esp,%ebp
80105d76:	53                   	push   %ebx
80105d77:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105d7a:	e8 a0 d4 ff ff       	call   8010321f <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105d85:	66 c7 80 18 18 13 80 	movw   $0xffff,-0x7fece7e8(%eax)
80105d8c:	ff ff 
80105d8e:	66 c7 80 1a 18 13 80 	movw   $0x0,-0x7fece7e6(%eax)
80105d95:	00 00 
80105d97:	c6 80 1c 18 13 80 00 	movb   $0x0,-0x7fece7e4(%eax)
80105d9e:	0f b6 88 1d 18 13 80 	movzbl -0x7fece7e3(%eax),%ecx
80105da5:	83 e1 f0             	and    $0xfffffff0,%ecx
80105da8:	83 c9 1a             	or     $0x1a,%ecx
80105dab:	83 e1 9f             	and    $0xffffff9f,%ecx
80105dae:	83 c9 80             	or     $0xffffff80,%ecx
80105db1:	88 88 1d 18 13 80    	mov    %cl,-0x7fece7e3(%eax)
80105db7:	0f b6 88 1e 18 13 80 	movzbl -0x7fece7e2(%eax),%ecx
80105dbe:	83 c9 0f             	or     $0xf,%ecx
80105dc1:	83 e1 cf             	and    $0xffffffcf,%ecx
80105dc4:	83 c9 c0             	or     $0xffffffc0,%ecx
80105dc7:	88 88 1e 18 13 80    	mov    %cl,-0x7fece7e2(%eax)
80105dcd:	c6 80 1f 18 13 80 00 	movb   $0x0,-0x7fece7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105dd4:	66 c7 80 20 18 13 80 	movw   $0xffff,-0x7fece7e0(%eax)
80105ddb:	ff ff 
80105ddd:	66 c7 80 22 18 13 80 	movw   $0x0,-0x7fece7de(%eax)
80105de4:	00 00 
80105de6:	c6 80 24 18 13 80 00 	movb   $0x0,-0x7fece7dc(%eax)
80105ded:	0f b6 88 25 18 13 80 	movzbl -0x7fece7db(%eax),%ecx
80105df4:	83 e1 f0             	and    $0xfffffff0,%ecx
80105df7:	83 c9 12             	or     $0x12,%ecx
80105dfa:	83 e1 9f             	and    $0xffffff9f,%ecx
80105dfd:	83 c9 80             	or     $0xffffff80,%ecx
80105e00:	88 88 25 18 13 80    	mov    %cl,-0x7fece7db(%eax)
80105e06:	0f b6 88 26 18 13 80 	movzbl -0x7fece7da(%eax),%ecx
80105e0d:	83 c9 0f             	or     $0xf,%ecx
80105e10:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e13:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e16:	88 88 26 18 13 80    	mov    %cl,-0x7fece7da(%eax)
80105e1c:	c6 80 27 18 13 80 00 	movb   $0x0,-0x7fece7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105e23:	66 c7 80 28 18 13 80 	movw   $0xffff,-0x7fece7d8(%eax)
80105e2a:	ff ff 
80105e2c:	66 c7 80 2a 18 13 80 	movw   $0x0,-0x7fece7d6(%eax)
80105e33:	00 00 
80105e35:	c6 80 2c 18 13 80 00 	movb   $0x0,-0x7fece7d4(%eax)
80105e3c:	c6 80 2d 18 13 80 fa 	movb   $0xfa,-0x7fece7d3(%eax)
80105e43:	0f b6 88 2e 18 13 80 	movzbl -0x7fece7d2(%eax),%ecx
80105e4a:	83 c9 0f             	or     $0xf,%ecx
80105e4d:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e50:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e53:	88 88 2e 18 13 80    	mov    %cl,-0x7fece7d2(%eax)
80105e59:	c6 80 2f 18 13 80 00 	movb   $0x0,-0x7fece7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105e60:	66 c7 80 30 18 13 80 	movw   $0xffff,-0x7fece7d0(%eax)
80105e67:	ff ff 
80105e69:	66 c7 80 32 18 13 80 	movw   $0x0,-0x7fece7ce(%eax)
80105e70:	00 00 
80105e72:	c6 80 34 18 13 80 00 	movb   $0x0,-0x7fece7cc(%eax)
80105e79:	c6 80 35 18 13 80 f2 	movb   $0xf2,-0x7fece7cb(%eax)
80105e80:	0f b6 88 36 18 13 80 	movzbl -0x7fece7ca(%eax),%ecx
80105e87:	83 c9 0f             	or     $0xf,%ecx
80105e8a:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e8d:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e90:	88 88 36 18 13 80    	mov    %cl,-0x7fece7ca(%eax)
80105e96:	c6 80 37 18 13 80 00 	movb   $0x0,-0x7fece7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105e9d:	05 10 18 13 80       	add    $0x80131810,%eax
  pd[0] = size-1;
80105ea2:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105ea8:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105eac:	c1 e8 10             	shr    $0x10,%eax
80105eaf:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105eb3:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105eb6:	0f 01 10             	lgdtl  (%eax)
}
80105eb9:	83 c4 14             	add    $0x14,%esp
80105ebc:	5b                   	pop    %ebx
80105ebd:	5d                   	pop    %ebp
80105ebe:	c3                   	ret    

80105ebf <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105ebf:	55                   	push   %ebp
80105ec0:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105ec2:	a1 c4 44 13 80       	mov    0x801344c4,%eax
80105ec7:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105ecc:	0f 22 d8             	mov    %eax,%cr3
}
80105ecf:	5d                   	pop    %ebp
80105ed0:	c3                   	ret    

80105ed1 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105ed1:	55                   	push   %ebp
80105ed2:	89 e5                	mov    %esp,%ebp
80105ed4:	57                   	push   %edi
80105ed5:	56                   	push   %esi
80105ed6:	53                   	push   %ebx
80105ed7:	83 ec 1c             	sub    $0x1c,%esp
80105eda:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105edd:	85 f6                	test   %esi,%esi
80105edf:	0f 84 dd 00 00 00    	je     80105fc2 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105ee5:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105ee9:	0f 84 e0 00 00 00    	je     80105fcf <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105eef:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105ef3:	0f 84 e3 00 00 00    	je     80105fdc <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105ef9:	e8 5d dc ff ff       	call   80103b5b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105efe:	e8 c0 d2 ff ff       	call   801031c3 <mycpu>
80105f03:	89 c3                	mov    %eax,%ebx
80105f05:	e8 b9 d2 ff ff       	call   801031c3 <mycpu>
80105f0a:	8d 78 08             	lea    0x8(%eax),%edi
80105f0d:	e8 b1 d2 ff ff       	call   801031c3 <mycpu>
80105f12:	83 c0 08             	add    $0x8,%eax
80105f15:	c1 e8 10             	shr    $0x10,%eax
80105f18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f1b:	e8 a3 d2 ff ff       	call   801031c3 <mycpu>
80105f20:	83 c0 08             	add    $0x8,%eax
80105f23:	c1 e8 18             	shr    $0x18,%eax
80105f26:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105f2d:	67 00 
80105f2f:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105f36:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105f3a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105f40:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105f47:	83 e2 f0             	and    $0xfffffff0,%edx
80105f4a:	83 ca 19             	or     $0x19,%edx
80105f4d:	83 e2 9f             	and    $0xffffff9f,%edx
80105f50:	83 ca 80             	or     $0xffffff80,%edx
80105f53:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105f59:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105f60:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105f66:	e8 58 d2 ff ff       	call   801031c3 <mycpu>
80105f6b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105f72:	83 e2 ef             	and    $0xffffffef,%edx
80105f75:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105f7b:	e8 43 d2 ff ff       	call   801031c3 <mycpu>
80105f80:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105f86:	8b 5e 08             	mov    0x8(%esi),%ebx
80105f89:	e8 35 d2 ff ff       	call   801031c3 <mycpu>
80105f8e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105f94:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105f97:	e8 27 d2 ff ff       	call   801031c3 <mycpu>
80105f9c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105fa2:	b8 28 00 00 00       	mov    $0x28,%eax
80105fa7:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105faa:	8b 46 04             	mov    0x4(%esi),%eax
80105fad:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fb2:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105fb5:	e8 de db ff ff       	call   80103b98 <popcli>
}
80105fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105fbd:	5b                   	pop    %ebx
80105fbe:	5e                   	pop    %esi
80105fbf:	5f                   	pop    %edi
80105fc0:	5d                   	pop    %ebp
80105fc1:	c3                   	ret    
    panic("switchuvm: no process");
80105fc2:	83 ec 0c             	sub    $0xc,%esp
80105fc5:	68 12 6e 10 80       	push   $0x80106e12
80105fca:	e8 79 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80105fcf:	83 ec 0c             	sub    $0xc,%esp
80105fd2:	68 28 6e 10 80       	push   $0x80106e28
80105fd7:	e8 6c a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80105fdc:	83 ec 0c             	sub    $0xc,%esp
80105fdf:	68 3d 6e 10 80       	push   $0x80106e3d
80105fe4:	e8 5f a3 ff ff       	call   80100348 <panic>

80105fe9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105fe9:	55                   	push   %ebp
80105fea:	89 e5                	mov    %esp,%ebp
80105fec:	56                   	push   %esi
80105fed:	53                   	push   %ebx
80105fee:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105ff1:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80105ff7:	77 4c                	ja     80106045 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80105ff9:	e8 bd c0 ff ff       	call   801020bb <kalloc>
80105ffe:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106000:	83 ec 04             	sub    $0x4,%esp
80106003:	68 00 10 00 00       	push   $0x1000
80106008:	6a 00                	push   $0x0
8010600a:	50                   	push   %eax
8010600b:	e8 d4 dc ff ff       	call   80103ce4 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106010:	83 c4 08             	add    $0x8,%esp
80106013:	6a 06                	push   $0x6
80106015:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010601b:	50                   	push   %eax
8010601c:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106021:	ba 00 00 00 00       	mov    $0x0,%edx
80106026:	8b 45 08             	mov    0x8(%ebp),%eax
80106029:	e8 cf fc ff ff       	call   80105cfd <mappages>
  memmove(mem, init, sz);
8010602e:	83 c4 0c             	add    $0xc,%esp
80106031:	56                   	push   %esi
80106032:	ff 75 0c             	pushl  0xc(%ebp)
80106035:	53                   	push   %ebx
80106036:	e8 24 dd ff ff       	call   80103d5f <memmove>
}
8010603b:	83 c4 10             	add    $0x10,%esp
8010603e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106041:	5b                   	pop    %ebx
80106042:	5e                   	pop    %esi
80106043:	5d                   	pop    %ebp
80106044:	c3                   	ret    
    panic("inituvm: more than a page");
80106045:	83 ec 0c             	sub    $0xc,%esp
80106048:	68 51 6e 10 80       	push   $0x80106e51
8010604d:	e8 f6 a2 ff ff       	call   80100348 <panic>

80106052 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106052:	55                   	push   %ebp
80106053:	89 e5                	mov    %esp,%ebp
80106055:	57                   	push   %edi
80106056:	56                   	push   %esi
80106057:	53                   	push   %ebx
80106058:	83 ec 0c             	sub    $0xc,%esp
8010605b:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010605e:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106065:	75 07                	jne    8010606e <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106067:	bb 00 00 00 00       	mov    $0x0,%ebx
8010606c:	eb 3c                	jmp    801060aa <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
8010606e:	83 ec 0c             	sub    $0xc,%esp
80106071:	68 0c 6f 10 80       	push   $0x80106f0c
80106076:	e8 cd a2 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	68 6b 6e 10 80       	push   $0x80106e6b
80106083:	e8 c0 a2 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106088:	05 00 00 00 80       	add    $0x80000000,%eax
8010608d:	56                   	push   %esi
8010608e:	89 da                	mov    %ebx,%edx
80106090:	03 55 14             	add    0x14(%ebp),%edx
80106093:	52                   	push   %edx
80106094:	50                   	push   %eax
80106095:	ff 75 10             	pushl  0x10(%ebp)
80106098:	e8 d6 b6 ff ff       	call   80101773 <readi>
8010609d:	83 c4 10             	add    $0x10,%esp
801060a0:	39 f0                	cmp    %esi,%eax
801060a2:	75 47                	jne    801060eb <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801060a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060aa:	39 fb                	cmp    %edi,%ebx
801060ac:	73 30                	jae    801060de <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801060ae:	89 da                	mov    %ebx,%edx
801060b0:	03 55 0c             	add    0xc(%ebp),%edx
801060b3:	b9 00 00 00 00       	mov    $0x0,%ecx
801060b8:	8b 45 08             	mov    0x8(%ebp),%eax
801060bb:	e8 cd fb ff ff       	call   80105c8d <walkpgdir>
801060c0:	85 c0                	test   %eax,%eax
801060c2:	74 b7                	je     8010607b <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801060c4:	8b 00                	mov    (%eax),%eax
801060c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801060cb:	89 fe                	mov    %edi,%esi
801060cd:	29 de                	sub    %ebx,%esi
801060cf:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060d5:	76 b1                	jbe    80106088 <loaduvm+0x36>
      n = PGSIZE;
801060d7:	be 00 10 00 00       	mov    $0x1000,%esi
801060dc:	eb aa                	jmp    80106088 <loaduvm+0x36>
      return -1;
  }
  return 0;
801060de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060e6:	5b                   	pop    %ebx
801060e7:	5e                   	pop    %esi
801060e8:	5f                   	pop    %edi
801060e9:	5d                   	pop    %ebp
801060ea:	c3                   	ret    
      return -1;
801060eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f0:	eb f1                	jmp    801060e3 <loaduvm+0x91>

801060f2 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801060f2:	55                   	push   %ebp
801060f3:	89 e5                	mov    %esp,%ebp
801060f5:	57                   	push   %edi
801060f6:	56                   	push   %esi
801060f7:	53                   	push   %ebx
801060f8:	83 ec 0c             	sub    $0xc,%esp
801060fb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801060fe:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106101:	73 11                	jae    80106114 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106103:	8b 45 10             	mov    0x10(%ebp),%eax
80106106:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010610c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106112:	eb 19                	jmp    8010612d <deallocuvm+0x3b>
    return oldsz;
80106114:	89 f8                	mov    %edi,%eax
80106116:	eb 64                	jmp    8010617c <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106118:	c1 eb 16             	shr    $0x16,%ebx
8010611b:	83 c3 01             	add    $0x1,%ebx
8010611e:	c1 e3 16             	shl    $0x16,%ebx
80106121:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106127:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010612d:	39 fb                	cmp    %edi,%ebx
8010612f:	73 48                	jae    80106179 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106131:	b9 00 00 00 00       	mov    $0x0,%ecx
80106136:	89 da                	mov    %ebx,%edx
80106138:	8b 45 08             	mov    0x8(%ebp),%eax
8010613b:	e8 4d fb ff ff       	call   80105c8d <walkpgdir>
80106140:	89 c6                	mov    %eax,%esi
    if(!pte)
80106142:	85 c0                	test   %eax,%eax
80106144:	74 d2                	je     80106118 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106146:	8b 00                	mov    (%eax),%eax
80106148:	a8 01                	test   $0x1,%al
8010614a:	74 db                	je     80106127 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010614c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106151:	74 19                	je     8010616c <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106153:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106158:	83 ec 0c             	sub    $0xc,%esp
8010615b:	50                   	push   %eax
8010615c:	e8 43 be ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106161:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106167:	83 c4 10             	add    $0x10,%esp
8010616a:	eb bb                	jmp    80106127 <deallocuvm+0x35>
        panic("kfree");
8010616c:	83 ec 0c             	sub    $0xc,%esp
8010616f:	68 a6 67 10 80       	push   $0x801067a6
80106174:	e8 cf a1 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106179:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010617c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010617f:	5b                   	pop    %ebx
80106180:	5e                   	pop    %esi
80106181:	5f                   	pop    %edi
80106182:	5d                   	pop    %ebp
80106183:	c3                   	ret    

80106184 <allocuvm>:
{
80106184:	55                   	push   %ebp
80106185:	89 e5                	mov    %esp,%ebp
80106187:	57                   	push   %edi
80106188:	56                   	push   %esi
80106189:	53                   	push   %ebx
8010618a:	83 ec 1c             	sub    $0x1c,%esp
8010618d:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106190:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106193:	85 ff                	test   %edi,%edi
80106195:	0f 88 c1 00 00 00    	js     8010625c <allocuvm+0xd8>
  if(newsz < oldsz)
8010619b:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010619e:	72 5c                	jb     801061fc <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
801061a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a3:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801061a9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801061af:	39 fb                	cmp    %edi,%ebx
801061b1:	0f 83 ac 00 00 00    	jae    80106263 <allocuvm+0xdf>
    mem = kalloc();
801061b7:	e8 ff be ff ff       	call   801020bb <kalloc>
801061bc:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801061be:	85 c0                	test   %eax,%eax
801061c0:	74 42                	je     80106204 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
801061c2:	83 ec 04             	sub    $0x4,%esp
801061c5:	68 00 10 00 00       	push   $0x1000
801061ca:	6a 00                	push   $0x0
801061cc:	50                   	push   %eax
801061cd:	e8 12 db ff ff       	call   80103ce4 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801061d2:	83 c4 08             	add    $0x8,%esp
801061d5:	6a 06                	push   $0x6
801061d7:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801061dd:	50                   	push   %eax
801061de:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061e3:	89 da                	mov    %ebx,%edx
801061e5:	8b 45 08             	mov    0x8(%ebp),%eax
801061e8:	e8 10 fb ff ff       	call   80105cfd <mappages>
801061ed:	83 c4 10             	add    $0x10,%esp
801061f0:	85 c0                	test   %eax,%eax
801061f2:	78 38                	js     8010622c <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801061f4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061fa:	eb b3                	jmp    801061af <allocuvm+0x2b>
    return oldsz;
801061fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106202:	eb 5f                	jmp    80106263 <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
80106204:	83 ec 0c             	sub    $0xc,%esp
80106207:	68 89 6e 10 80       	push   $0x80106e89
8010620c:	e8 fa a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106211:	83 c4 0c             	add    $0xc,%esp
80106214:	ff 75 0c             	pushl  0xc(%ebp)
80106217:	57                   	push   %edi
80106218:	ff 75 08             	pushl  0x8(%ebp)
8010621b:	e8 d2 fe ff ff       	call   801060f2 <deallocuvm>
      return 0;
80106220:	83 c4 10             	add    $0x10,%esp
80106223:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010622a:	eb 37                	jmp    80106263 <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
8010622c:	83 ec 0c             	sub    $0xc,%esp
8010622f:	68 a1 6e 10 80       	push   $0x80106ea1
80106234:	e8 d2 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106239:	83 c4 0c             	add    $0xc,%esp
8010623c:	ff 75 0c             	pushl  0xc(%ebp)
8010623f:	57                   	push   %edi
80106240:	ff 75 08             	pushl  0x8(%ebp)
80106243:	e8 aa fe ff ff       	call   801060f2 <deallocuvm>
      kfree(mem);
80106248:	89 34 24             	mov    %esi,(%esp)
8010624b:	e8 54 bd ff ff       	call   80101fa4 <kfree>
      return 0;
80106250:	83 c4 10             	add    $0x10,%esp
80106253:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010625a:	eb 07                	jmp    80106263 <allocuvm+0xdf>
    return 0;
8010625c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106266:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106269:	5b                   	pop    %ebx
8010626a:	5e                   	pop    %esi
8010626b:	5f                   	pop    %edi
8010626c:	5d                   	pop    %ebp
8010626d:	c3                   	ret    

8010626e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010626e:	55                   	push   %ebp
8010626f:	89 e5                	mov    %esp,%ebp
80106271:	56                   	push   %esi
80106272:	53                   	push   %ebx
80106273:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106276:	85 f6                	test   %esi,%esi
80106278:	74 1a                	je     80106294 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010627a:	83 ec 04             	sub    $0x4,%esp
8010627d:	6a 00                	push   $0x0
8010627f:	68 00 00 00 80       	push   $0x80000000
80106284:	56                   	push   %esi
80106285:	e8 68 fe ff ff       	call   801060f2 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010628a:	83 c4 10             	add    $0x10,%esp
8010628d:	bb 00 00 00 00       	mov    $0x0,%ebx
80106292:	eb 10                	jmp    801062a4 <freevm+0x36>
    panic("freevm: no pgdir");
80106294:	83 ec 0c             	sub    $0xc,%esp
80106297:	68 bd 6e 10 80       	push   $0x80106ebd
8010629c:	e8 a7 a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801062a1:	83 c3 01             	add    $0x1,%ebx
801062a4:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801062aa:	77 1f                	ja     801062cb <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801062ac:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801062af:	a8 01                	test   $0x1,%al
801062b1:	74 ee                	je     801062a1 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801062b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801062b8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801062bd:	83 ec 0c             	sub    $0xc,%esp
801062c0:	50                   	push   %eax
801062c1:	e8 de bc ff ff       	call   80101fa4 <kfree>
801062c6:	83 c4 10             	add    $0x10,%esp
801062c9:	eb d6                	jmp    801062a1 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801062cb:	83 ec 0c             	sub    $0xc,%esp
801062ce:	56                   	push   %esi
801062cf:	e8 d0 bc ff ff       	call   80101fa4 <kfree>
}
801062d4:	83 c4 10             	add    $0x10,%esp
801062d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801062da:	5b                   	pop    %ebx
801062db:	5e                   	pop    %esi
801062dc:	5d                   	pop    %ebp
801062dd:	c3                   	ret    

801062de <setupkvm>:
{
801062de:	55                   	push   %ebp
801062df:	89 e5                	mov    %esp,%ebp
801062e1:	56                   	push   %esi
801062e2:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801062e3:	e8 d3 bd ff ff       	call   801020bb <kalloc>
801062e8:	89 c6                	mov    %eax,%esi
801062ea:	85 c0                	test   %eax,%eax
801062ec:	74 55                	je     80106343 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801062ee:	83 ec 04             	sub    $0x4,%esp
801062f1:	68 00 10 00 00       	push   $0x1000
801062f6:	6a 00                	push   $0x0
801062f8:	50                   	push   %eax
801062f9:	e8 e6 d9 ff ff       	call   80103ce4 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062fe:	83 c4 10             	add    $0x10,%esp
80106301:	bb 20 94 12 80       	mov    $0x80129420,%ebx
80106306:	81 fb 60 94 12 80    	cmp    $0x80129460,%ebx
8010630c:	73 35                	jae    80106343 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
8010630e:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106311:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106314:	29 c1                	sub    %eax,%ecx
80106316:	83 ec 08             	sub    $0x8,%esp
80106319:	ff 73 0c             	pushl  0xc(%ebx)
8010631c:	50                   	push   %eax
8010631d:	8b 13                	mov    (%ebx),%edx
8010631f:	89 f0                	mov    %esi,%eax
80106321:	e8 d7 f9 ff ff       	call   80105cfd <mappages>
80106326:	83 c4 10             	add    $0x10,%esp
80106329:	85 c0                	test   %eax,%eax
8010632b:	78 05                	js     80106332 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010632d:	83 c3 10             	add    $0x10,%ebx
80106330:	eb d4                	jmp    80106306 <setupkvm+0x28>
      freevm(pgdir);
80106332:	83 ec 0c             	sub    $0xc,%esp
80106335:	56                   	push   %esi
80106336:	e8 33 ff ff ff       	call   8010626e <freevm>
      return 0;
8010633b:	83 c4 10             	add    $0x10,%esp
8010633e:	be 00 00 00 00       	mov    $0x0,%esi
}
80106343:	89 f0                	mov    %esi,%eax
80106345:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106348:	5b                   	pop    %ebx
80106349:	5e                   	pop    %esi
8010634a:	5d                   	pop    %ebp
8010634b:	c3                   	ret    

8010634c <kvmalloc>:
{
8010634c:	55                   	push   %ebp
8010634d:	89 e5                	mov    %esp,%ebp
8010634f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106352:	e8 87 ff ff ff       	call   801062de <setupkvm>
80106357:	a3 c4 44 13 80       	mov    %eax,0x801344c4
  switchkvm();
8010635c:	e8 5e fb ff ff       	call   80105ebf <switchkvm>
}
80106361:	c9                   	leave  
80106362:	c3                   	ret    

80106363 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106363:	55                   	push   %ebp
80106364:	89 e5                	mov    %esp,%ebp
80106366:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106369:	b9 00 00 00 00       	mov    $0x0,%ecx
8010636e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106371:	8b 45 08             	mov    0x8(%ebp),%eax
80106374:	e8 14 f9 ff ff       	call   80105c8d <walkpgdir>
  if(pte == 0)
80106379:	85 c0                	test   %eax,%eax
8010637b:	74 05                	je     80106382 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010637d:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106380:	c9                   	leave  
80106381:	c3                   	ret    
    panic("clearpteu");
80106382:	83 ec 0c             	sub    $0xc,%esp
80106385:	68 ce 6e 10 80       	push   $0x80106ece
8010638a:	e8 b9 9f ff ff       	call   80100348 <panic>

8010638f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010638f:	55                   	push   %ebp
80106390:	89 e5                	mov    %esp,%ebp
80106392:	57                   	push   %edi
80106393:	56                   	push   %esi
80106394:	53                   	push   %ebx
80106395:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106398:	e8 41 ff ff ff       	call   801062de <setupkvm>
8010639d:	89 45 dc             	mov    %eax,-0x24(%ebp)
801063a0:	85 c0                	test   %eax,%eax
801063a2:	0f 84 c4 00 00 00    	je     8010646c <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801063a8:	bf 00 00 00 00       	mov    $0x0,%edi
801063ad:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063b0:	0f 83 b6 00 00 00    	jae    8010646c <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801063b6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801063b9:	b9 00 00 00 00       	mov    $0x0,%ecx
801063be:	89 fa                	mov    %edi,%edx
801063c0:	8b 45 08             	mov    0x8(%ebp),%eax
801063c3:	e8 c5 f8 ff ff       	call   80105c8d <walkpgdir>
801063c8:	85 c0                	test   %eax,%eax
801063ca:	74 65                	je     80106431 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801063cc:	8b 00                	mov    (%eax),%eax
801063ce:	a8 01                	test   $0x1,%al
801063d0:	74 6c                	je     8010643e <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801063d2:	89 c6                	mov    %eax,%esi
801063d4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801063da:	25 ff 0f 00 00       	and    $0xfff,%eax
801063df:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801063e2:	e8 d4 bc ff ff       	call   801020bb <kalloc>
801063e7:	89 c3                	mov    %eax,%ebx
801063e9:	85 c0                	test   %eax,%eax
801063eb:	74 6a                	je     80106457 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801063ed:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801063f3:	83 ec 04             	sub    $0x4,%esp
801063f6:	68 00 10 00 00       	push   $0x1000
801063fb:	56                   	push   %esi
801063fc:	50                   	push   %eax
801063fd:	e8 5d d9 ff ff       	call   80103d5f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106402:	83 c4 08             	add    $0x8,%esp
80106405:	ff 75 e0             	pushl  -0x20(%ebp)
80106408:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010640e:	50                   	push   %eax
8010640f:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106414:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106417:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010641a:	e8 de f8 ff ff       	call   80105cfd <mappages>
8010641f:	83 c4 10             	add    $0x10,%esp
80106422:	85 c0                	test   %eax,%eax
80106424:	78 25                	js     8010644b <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106426:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010642c:	e9 7c ff ff ff       	jmp    801063ad <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106431:	83 ec 0c             	sub    $0xc,%esp
80106434:	68 d8 6e 10 80       	push   $0x80106ed8
80106439:	e8 0a 9f ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
8010643e:	83 ec 0c             	sub    $0xc,%esp
80106441:	68 f2 6e 10 80       	push   $0x80106ef2
80106446:	e8 fd 9e ff ff       	call   80100348 <panic>
      kfree(mem);
8010644b:	83 ec 0c             	sub    $0xc,%esp
8010644e:	53                   	push   %ebx
8010644f:	e8 50 bb ff ff       	call   80101fa4 <kfree>
      goto bad;
80106454:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106457:	83 ec 0c             	sub    $0xc,%esp
8010645a:	ff 75 dc             	pushl  -0x24(%ebp)
8010645d:	e8 0c fe ff ff       	call   8010626e <freevm>
  return 0;
80106462:	83 c4 10             	add    $0x10,%esp
80106465:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010646c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010646f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106472:	5b                   	pop    %ebx
80106473:	5e                   	pop    %esi
80106474:	5f                   	pop    %edi
80106475:	5d                   	pop    %ebp
80106476:	c3                   	ret    

80106477 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106477:	55                   	push   %ebp
80106478:	89 e5                	mov    %esp,%ebp
8010647a:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010647d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106482:	8b 55 0c             	mov    0xc(%ebp),%edx
80106485:	8b 45 08             	mov    0x8(%ebp),%eax
80106488:	e8 00 f8 ff ff       	call   80105c8d <walkpgdir>
  if((*pte & PTE_P) == 0)
8010648d:	8b 00                	mov    (%eax),%eax
8010648f:	a8 01                	test   $0x1,%al
80106491:	74 10                	je     801064a3 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106493:	a8 04                	test   $0x4,%al
80106495:	74 13                	je     801064aa <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106497:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010649c:	05 00 00 00 80       	add    $0x80000000,%eax
}
801064a1:	c9                   	leave  
801064a2:	c3                   	ret    
    return 0;
801064a3:	b8 00 00 00 00       	mov    $0x0,%eax
801064a8:	eb f7                	jmp    801064a1 <uva2ka+0x2a>
    return 0;
801064aa:	b8 00 00 00 00       	mov    $0x0,%eax
801064af:	eb f0                	jmp    801064a1 <uva2ka+0x2a>

801064b1 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801064b1:	55                   	push   %ebp
801064b2:	89 e5                	mov    %esp,%ebp
801064b4:	57                   	push   %edi
801064b5:	56                   	push   %esi
801064b6:	53                   	push   %ebx
801064b7:	83 ec 0c             	sub    $0xc,%esp
801064ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801064bd:	eb 25                	jmp    801064e4 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801064bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801064c2:	29 f2                	sub    %esi,%edx
801064c4:	01 d0                	add    %edx,%eax
801064c6:	83 ec 04             	sub    $0x4,%esp
801064c9:	53                   	push   %ebx
801064ca:	ff 75 10             	pushl  0x10(%ebp)
801064cd:	50                   	push   %eax
801064ce:	e8 8c d8 ff ff       	call   80103d5f <memmove>
    len -= n;
801064d3:	29 df                	sub    %ebx,%edi
    buf += n;
801064d5:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801064d8:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801064de:	89 45 0c             	mov    %eax,0xc(%ebp)
801064e1:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801064e4:	85 ff                	test   %edi,%edi
801064e6:	74 2f                	je     80106517 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801064e8:	8b 75 0c             	mov    0xc(%ebp),%esi
801064eb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801064f1:	83 ec 08             	sub    $0x8,%esp
801064f4:	56                   	push   %esi
801064f5:	ff 75 08             	pushl  0x8(%ebp)
801064f8:	e8 7a ff ff ff       	call   80106477 <uva2ka>
    if(pa0 == 0)
801064fd:	83 c4 10             	add    $0x10,%esp
80106500:	85 c0                	test   %eax,%eax
80106502:	74 20                	je     80106524 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106504:	89 f3                	mov    %esi,%ebx
80106506:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106509:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
8010650f:	39 df                	cmp    %ebx,%edi
80106511:	73 ac                	jae    801064bf <copyout+0xe>
      n = len;
80106513:	89 fb                	mov    %edi,%ebx
80106515:	eb a8                	jmp    801064bf <copyout+0xe>
  }
  return 0;
80106517:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010651c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010651f:	5b                   	pop    %ebx
80106520:	5e                   	pop    %esi
80106521:	5f                   	pop    %edi
80106522:	5d                   	pop    %ebp
80106523:	c3                   	ret    
      return -1;
80106524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106529:	eb f1                	jmp    8010651c <copyout+0x6b>

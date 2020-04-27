
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
8010002d:	b8 f3 2b 10 80       	mov    $0x80102bf3,%eax
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
80100046:	e8 ea 3c 00 00       	call   80103d35 <acquire>

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
8010007c:	e8 19 3d 00 00       	call   80103d9a <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 95 3a 00 00       	call   80103b21 <acquiresleep>
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
801000ca:	e8 cb 3c 00 00       	call   80103d9a <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 47 3a 00 00       	call   80103b21 <acquiresleep>
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
801000ea:	68 60 66 10 80       	push   $0x80106660
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 71 66 10 80       	push   $0x80106671
80100100:	68 00 b6 11 80       	push   $0x8011b600
80100105:	e8 ef 3a 00 00       	call   80103bf9 <initlock>
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
8010013a:	68 78 66 10 80       	push   $0x80106678
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 a6 39 00 00       	call   80103aee <initsleeplock>
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
801001a8:	e8 fe 39 00 00       	call   80103bab <holdingsleep>
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
801001cb:	68 7f 66 10 80       	push   $0x8010667f
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
801001e4:	e8 c2 39 00 00       	call   80103bab <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 77 39 00 00       	call   80103b70 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 00 b6 11 80 	movl   $0x8011b600,(%esp)
80100200:	e8 30 3b 00 00       	call   80103d35 <acquire>
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
8010024c:	e8 49 3b 00 00       	call   80103d9a <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 86 66 10 80       	push   $0x80106686
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
8010028a:	e8 a6 3a 00 00       	call   80103d35 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 e0 ff 11 80       	mov    0x8011ffe0,%eax
8010029f:	3b 05 e4 ff 11 80    	cmp    0x8011ffe4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 e7 30 00 00       	call   80103393 <myproc>
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
801002bf:	e8 76 35 00 00       	call   8010383a <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 c4 3a 00 00       	call   80103d9a <release>
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
80100331:	e8 64 3a 00 00       	call   80103d9a <release>
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
8010035a:	e8 a9 21 00 00       	call   80102508 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 66 10 80       	push   $0x8010668d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 db 6f 10 80 	movl   $0x80106fdb,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 80 38 00 00       	call   80103c14 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 a1 66 10 80       	push   $0x801066a1
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
8010049e:	68 a5 66 10 80       	push   $0x801066a5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 9d 39 00 00       	call   80103e5c <memmove>
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
801004d9:	e8 03 39 00 00       	call   80103de1 <memset>
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
80100506:	e8 10 4d 00 00       	call   8010521b <uartputc>
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
8010051f:	e8 f7 4c 00 00       	call   8010521b <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 eb 4c 00 00       	call   8010521b <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 df 4c 00 00       	call   8010521b <uartputc>
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
80100576:	0f b6 92 d0 66 10 80 	movzbl -0x7fef9930(%edx),%edx
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
801005ca:	e8 66 37 00 00       	call   80103d35 <acquire>
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
801005f1:	e8 a4 37 00 00       	call   80103d9a <release>
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
80100638:	e8 f8 36 00 00       	call   80103d35 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 bf 66 10 80       	push   $0x801066bf
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
801006ee:	be b8 66 10 80       	mov    $0x801066b8,%esi
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
80100734:	e8 61 36 00 00       	call   80103d9a <release>
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
8010074f:	e8 e1 35 00 00       	call   80103d35 <acquire>
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
801007de:	e8 bc 31 00 00       	call   8010399f <wakeup>
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
80100873:	e8 22 35 00 00       	call   80103d9a <release>
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
80100887:	e8 b0 31 00 00       	call   80103a3c <procdump>
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
80100894:	68 c8 66 10 80       	push   $0x801066c8
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 56 33 00 00       	call   80103bf9 <initlock>

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
801008de:	e8 b0 2a 00 00       	call   80103393 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 4a 20 00 00       	call   80102938 <begin_op>

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
80100935:	e8 78 20 00 00       	call   801029b2 <end_op>
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
8010094a:	e8 63 20 00 00       	call   801029b2 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e1 66 10 80       	push   $0x801066e1
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
80100972:	e8 7a 5a 00 00       	call   801063f1 <setupkvm>
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
80100a0c:	e8 7d 58 00 00       	call   8010628e <allocuvm>
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
80100a3e:	e8 19 57 00 00       	call   8010615c <loaduvm>
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
80100a59:	e8 54 1f 00 00       	call   801029b2 <end_op>
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
80100a80:	e8 09 58 00 00       	call   8010628e <allocuvm>
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
80100aa9:	e8 d3 58 00 00       	call   80106381 <freevm>
80100aae:	83 c4 10             	add    $0x10,%esp
80100ab1:	e9 6e fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ab6:	89 c7                	mov    %eax,%edi
80100ab8:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100abe:	83 ec 08             	sub    $0x8,%esp
80100ac1:	50                   	push   %eax
80100ac2:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100ac8:	e8 b1 59 00 00       	call   8010647e <clearpteu>
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
80100aee:	e8 90 34 00 00       	call   80103f83 <strlen>
80100af3:	29 c7                	sub    %eax,%edi
80100af5:	83 ef 01             	sub    $0x1,%edi
80100af8:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100afb:	83 c4 04             	add    $0x4,%esp
80100afe:	ff 33                	pushl  (%ebx)
80100b00:	e8 7e 34 00 00       	call   80103f83 <strlen>
80100b05:	83 c0 01             	add    $0x1,%eax
80100b08:	50                   	push   %eax
80100b09:	ff 33                	pushl  (%ebx)
80100b0b:	57                   	push   %edi
80100b0c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b12:	e8 c2 5a 00 00       	call   801065d9 <copyout>
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
80100b72:	e8 62 5a 00 00       	call   801065d9 <copyout>
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
80100baf:	e8 94 33 00 00       	call   80103f48 <safestrcpy>
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
80100bdd:	e8 f4 53 00 00       	call   80105fd6 <switchuvm>
  freevm(oldpgdir);
80100be2:	89 1c 24             	mov    %ebx,(%esp)
80100be5:	e8 97 57 00 00       	call   80106381 <freevm>
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
80100c25:	68 ed 66 10 80       	push   $0x801066ed
80100c2a:	68 00 00 12 80       	push   $0x80120000
80100c2f:	e8 c5 2f 00 00       	call   80103bf9 <initlock>
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
80100c45:	e8 eb 30 00 00       	call   80103d35 <acquire>
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
80100c74:	e8 21 31 00 00       	call   80103d9a <release>
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
80100c8b:	e8 0a 31 00 00       	call   80103d9a <release>
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
80100ca9:	e8 87 30 00 00       	call   80103d35 <acquire>
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
80100cc6:	e8 cf 30 00 00       	call   80103d9a <release>
  return f;
}
80100ccb:	89 d8                	mov    %ebx,%eax
80100ccd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cd0:	c9                   	leave  
80100cd1:	c3                   	ret    
    panic("filedup");
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	68 f4 66 10 80       	push   $0x801066f4
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
80100cee:	e8 42 30 00 00       	call   80103d35 <acquire>
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
80100d0f:	e8 86 30 00 00       	call   80103d9a <release>
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
80100d1f:	68 fc 66 10 80       	push   $0x801066fc
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
80100d55:	e8 40 30 00 00       	call   80103d9a <release>
  if(ff.type == FD_PIPE)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	83 c4 10             	add    $0x10,%esp
80100d60:	83 f8 01             	cmp    $0x1,%eax
80100d63:	74 1f                	je     80100d84 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d65:	83 f8 02             	cmp    $0x2,%eax
80100d68:	75 ad                	jne    80100d17 <fileclose+0x38>
    begin_op();
80100d6a:	e8 c9 1b 00 00       	call   80102938 <begin_op>
    iput(ff.ip);
80100d6f:	83 ec 0c             	sub    $0xc,%esp
80100d72:	ff 75 f0             	pushl  -0x10(%ebp)
80100d75:	e8 1a 09 00 00       	call   80101694 <iput>
    end_op();
80100d7a:	e8 33 1c 00 00       	call   801029b2 <end_op>
80100d7f:	83 c4 10             	add    $0x10,%esp
80100d82:	eb 93                	jmp    80100d17 <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d84:	83 ec 08             	sub    $0x8,%esp
80100d87:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d8b:	50                   	push   %eax
80100d8c:	ff 75 ec             	pushl  -0x14(%ebp)
80100d8f:	e8 25 22 00 00       	call   80102fb9 <pipeclose>
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
80100e48:	e8 c4 22 00 00       	call   80103111 <piperead>
80100e4d:	89 c6                	mov    %eax,%esi
80100e4f:	83 c4 10             	add    $0x10,%esp
80100e52:	eb df                	jmp    80100e33 <fileread+0x50>
  panic("fileread");
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	68 06 67 10 80       	push   $0x80106706
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
80100ea1:	e8 9f 21 00 00       	call   80103045 <pipewrite>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	e9 80 00 00 00       	jmp    80100f2e <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100eae:	e8 85 1a 00 00       	call   80102938 <begin_op>
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
80100ee9:	e8 c4 1a 00 00       	call   801029b2 <end_op>

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
80100f1c:	68 0f 67 10 80       	push   $0x8010670f
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
80100f39:	68 15 67 10 80       	push   $0x80106715
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
80100f96:	e8 c1 2e 00 00       	call   80103e5c <memmove>
80100f9b:	83 c4 10             	add    $0x10,%esp
80100f9e:	eb 17                	jmp    80100fb7 <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fa0:	83 ec 04             	sub    $0x4,%esp
80100fa3:	56                   	push   %esi
80100fa4:	50                   	push   %eax
80100fa5:	57                   	push   %edi
80100fa6:	e8 b1 2e 00 00       	call   80103e5c <memmove>
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
80100feb:	e8 f1 2d 00 00       	call   80103de1 <memset>
  log_write(bp);
80100ff0:	89 1c 24             	mov    %ebx,(%esp)
80100ff3:	e8 69 1a 00 00       	call   80102a61 <log_write>
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
801010af:	68 1f 67 10 80       	push   $0x8010671f
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
801010cb:	e8 91 19 00 00       	call   80102a61 <log_write>
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
8010117c:	e8 e0 18 00 00       	call   80102a61 <log_write>
80101181:	83 c4 10             	add    $0x10,%esp
80101184:	eb bf                	jmp    80101145 <bmap+0x58>
  panic("bmap: out of range");
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	68 35 67 10 80       	push   $0x80106735
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
801011a6:	e8 8a 2b 00 00       	call   80103d35 <acquire>
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
801011ed:	e8 a8 2b 00 00       	call   80103d9a <release>
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
80101223:	e8 72 2b 00 00       	call   80103d9a <release>
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
80101238:	68 48 67 10 80       	push   $0x80106748
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
80101261:	e8 f6 2b 00 00       	call   80103e5c <memmove>
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
801012d4:	e8 88 17 00 00       	call   80102a61 <log_write>
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
801012ee:	68 58 67 10 80       	push   $0x80106758
801012f3:	e8 50 f0 ff ff       	call   80100348 <panic>

801012f8 <iinit>:
{
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	53                   	push   %ebx
801012fc:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012ff:	68 6b 67 10 80       	push   $0x8010676b
80101304:	68 20 0a 12 80       	push   $0x80120a20
80101309:	e8 eb 28 00 00       	call   80103bf9 <initlock>
  for(i = 0; i < NINODE; i++) {
8010130e:	83 c4 10             	add    $0x10,%esp
80101311:	bb 00 00 00 00       	mov    $0x0,%ebx
80101316:	eb 21                	jmp    80101339 <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
80101318:	83 ec 08             	sub    $0x8,%esp
8010131b:	68 72 67 10 80       	push   $0x80106772
80101320:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101323:	89 d0                	mov    %edx,%eax
80101325:	c1 e0 04             	shl    $0x4,%eax
80101328:	05 60 0a 12 80       	add    $0x80120a60,%eax
8010132d:	50                   	push   %eax
8010132e:	e8 bb 27 00 00       	call   80103aee <initsleeplock>
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
80101378:	68 d8 67 10 80       	push   $0x801067d8
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
801013eb:	68 78 67 10 80       	push   $0x80106778
801013f0:	e8 53 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013f5:	83 ec 04             	sub    $0x4,%esp
801013f8:	6a 40                	push   $0x40
801013fa:	6a 00                	push   $0x0
801013fc:	57                   	push   %edi
801013fd:	e8 df 29 00 00       	call   80103de1 <memset>
      dip->type = type;
80101402:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101406:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101409:	89 34 24             	mov    %esi,(%esp)
8010140c:	e8 50 16 00 00       	call   80102a61 <log_write>
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
8010148c:	e8 cb 29 00 00       	call   80103e5c <memmove>
  log_write(bp);
80101491:	89 34 24             	mov    %esi,(%esp)
80101494:	e8 c8 15 00 00       	call   80102a61 <log_write>
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
8010156c:	e8 c4 27 00 00       	call   80103d35 <acquire>
  ip->ref++;
80101571:	8b 43 08             	mov    0x8(%ebx),%eax
80101574:	83 c0 01             	add    $0x1,%eax
80101577:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010157a:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
80101581:	e8 14 28 00 00       	call   80103d9a <release>
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
801015a6:	e8 76 25 00 00       	call   80103b21 <acquiresleep>
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
801015be:	68 8a 67 10 80       	push   $0x8010678a
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
80101620:	e8 37 28 00 00       	call   80103e5c <memmove>
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
80101645:	68 90 67 10 80       	push   $0x80106790
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
80101662:	e8 44 25 00 00       	call   80103bab <holdingsleep>
80101667:	83 c4 10             	add    $0x10,%esp
8010166a:	85 c0                	test   %eax,%eax
8010166c:	74 19                	je     80101687 <iunlock+0x38>
8010166e:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101672:	7e 13                	jle    80101687 <iunlock+0x38>
  releasesleep(&ip->lock);
80101674:	83 ec 0c             	sub    $0xc,%esp
80101677:	56                   	push   %esi
80101678:	e8 f3 24 00 00       	call   80103b70 <releasesleep>
}
8010167d:	83 c4 10             	add    $0x10,%esp
80101680:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101683:	5b                   	pop    %ebx
80101684:	5e                   	pop    %esi
80101685:	5d                   	pop    %ebp
80101686:	c3                   	ret    
    panic("iunlock");
80101687:	83 ec 0c             	sub    $0xc,%esp
8010168a:	68 9f 67 10 80       	push   $0x8010679f
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
801016a4:	e8 78 24 00 00       	call   80103b21 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016a9:	83 c4 10             	add    $0x10,%esp
801016ac:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016b0:	74 07                	je     801016b9 <iput+0x25>
801016b2:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016b7:	74 35                	je     801016ee <iput+0x5a>
  releasesleep(&ip->lock);
801016b9:	83 ec 0c             	sub    $0xc,%esp
801016bc:	56                   	push   %esi
801016bd:	e8 ae 24 00 00       	call   80103b70 <releasesleep>
  acquire(&icache.lock);
801016c2:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
801016c9:	e8 67 26 00 00       	call   80103d35 <acquire>
  ip->ref--;
801016ce:	8b 43 08             	mov    0x8(%ebx),%eax
801016d1:	83 e8 01             	sub    $0x1,%eax
801016d4:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016d7:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
801016de:	e8 b7 26 00 00       	call   80103d9a <release>
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
801016f6:	e8 3a 26 00 00       	call   80103d35 <acquire>
    int r = ip->ref;
801016fb:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016fe:	c7 04 24 20 0a 12 80 	movl   $0x80120a20,(%esp)
80101705:	e8 90 26 00 00       	call   80103d9a <release>
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
80101836:	e8 21 26 00 00       	call   80103e5c <memmove>
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
80101932:	e8 25 25 00 00       	call   80103e5c <memmove>
    log_write(bp);
80101937:	89 3c 24             	mov    %edi,(%esp)
8010193a:	e8 22 11 00 00       	call   80102a61 <log_write>
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
801019b5:	e8 09 25 00 00       	call   80103ec3 <strncmp>
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
801019dc:	68 a7 67 10 80       	push   $0x801067a7
801019e1:	e8 62 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 b9 67 10 80       	push   $0x801067b9
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
80101a66:	e8 28 19 00 00       	call   80103393 <myproc>
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
80101b9e:	68 c8 67 10 80       	push   $0x801067c8
80101ba3:	e8 a0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101ba8:	83 ec 04             	sub    $0x4,%esp
80101bab:	6a 0e                	push   $0xe
80101bad:	57                   	push   %edi
80101bae:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bb1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bb4:	50                   	push   %eax
80101bb5:	e8 46 23 00 00       	call   80103f00 <strncpy>
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
80101be3:	68 d4 6d 10 80       	push   $0x80106dd4
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
80101cd8:	68 2b 68 10 80       	push   $0x8010682b
80101cdd:	e8 66 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	68 34 68 10 80       	push   $0x80106834
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
80101d12:	68 46 68 10 80       	push   $0x80106846
80101d17:	68 80 a5 10 80       	push   $0x8010a580
80101d1c:	e8 d8 1e 00 00       	call   80103bf9 <initlock>
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
80101d8c:	e8 a4 1f 00 00       	call   80103d35 <acquire>

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
80101db9:	e8 e1 1b 00 00       	call   8010399f <wakeup>

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
80101dd7:	e8 be 1f 00 00       	call   80103d9a <release>
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
80101dee:	e8 a7 1f 00 00       	call   80103d9a <release>
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
80101e26:	e8 80 1d 00 00       	call   80103bab <holdingsleep>
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
80101e53:	e8 dd 1e 00 00       	call   80103d35 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e58:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e5f:	83 c4 10             	add    $0x10,%esp
80101e62:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e67:	eb 2a                	jmp    80101e93 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e69:	83 ec 0c             	sub    $0xc,%esp
80101e6c:	68 4a 68 10 80       	push   $0x8010684a
80101e71:	e8 d2 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e76:	83 ec 0c             	sub    $0xc,%esp
80101e79:	68 60 68 10 80       	push   $0x80106860
80101e7e:	e8 c5 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e83:	83 ec 0c             	sub    $0xc,%esp
80101e86:	68 75 68 10 80       	push   $0x80106875
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
80101eb5:	e8 80 19 00 00       	call   8010383a <sleep>
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
80101ecf:	e8 c6 1e 00 00       	call   80103d9a <release>
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
80101f4b:	68 94 68 10 80       	push   $0x80106894
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
    if (i <= 16384) {
80101fda:	3d 00 40 00 00       	cmp    $0x4000,%eax
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
80102036:	e8 a6 1d 00 00       	call   80103de1 <memset>

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
80102057:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
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
80102073:	68 c6 68 10 80       	push   $0x801068c6
80102078:	e8 cb e2 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010207d:	83 ec 0c             	sub    $0xc,%esp
80102080:	68 80 26 12 80       	push   $0x80122680
80102085:	e8 ab 1c 00 00       	call   80103d35 <acquire>
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
801020b0:	e8 e5 1c 00 00       	call   80103d9a <release>
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
801020f6:	68 cc 68 10 80       	push   $0x801068cc
801020fb:	68 80 26 12 80       	push   $0x80122680
80102100:	e8 f4 1a 00 00       	call   80103bf9 <initlock>
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
8010213d:	c7 05 c4 a5 10 80 01 	movl   $0x1,0x8010a5c4
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
8010214f:	56                   	push   %esi
80102150:	53                   	push   %ebx
80102151:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if(kmem.use_lock)
80102154:	83 3d b4 26 12 80 00 	cmpl   $0x0,0x801226b4
8010215b:	75 1f                	jne    8010217c <kalloc+0x30>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010215d:	8b 35 b8 26 12 80    	mov    0x801226b8,%esi
  if (flag) {
80102163:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
8010216a:	0f 85 af 00 00 00    	jne    8010221f <kalloc+0xd3>
        }
      }
    }
    update();
  } else {
    kmem.freelist = r->next;
80102170:	8b 06                	mov    (%esi),%eax
80102172:	a3 b8 26 12 80       	mov    %eax,0x801226b8
80102177:	e9 91 00 00 00       	jmp    8010220d <kalloc+0xc1>
    acquire(&kmem.lock);
8010217c:	83 ec 0c             	sub    $0xc,%esp
8010217f:	68 80 26 12 80       	push   $0x80122680
80102184:	e8 ac 1b 00 00       	call   80103d35 <acquire>
80102189:	83 c4 10             	add    $0x10,%esp
8010218c:	eb cf                	jmp    8010215d <kalloc+0x11>
          && (i == 16383 || frame[i + 1] == 0 || frame[i + 1] == pid || frame[i - 1] == -2))) {
8010218e:	81 fa ff 3f 00 00    	cmp    $0x3fff,%edx
80102194:	74 48                	je     801021de <kalloc+0x92>
80102196:	8b 04 95 e4 a5 10 80 	mov    -0x7fef5a1c(,%edx,4),%eax
8010219d:	85 c0                	test   %eax,%eax
8010219f:	74 3d                	je     801021de <kalloc+0x92>
801021a1:	39 d8                	cmp    %ebx,%eax
801021a3:	74 39                	je     801021de <kalloc+0x92>
801021a5:	83 3c 95 dc a5 10 80 	cmpl   $0xfffffffe,-0x7fef5a24(,%edx,4)
801021ac:	fe 
801021ad:	74 2f                	je     801021de <kalloc+0x92>
    for (int i = 0; i < 16384; i++) {
801021af:	83 c2 01             	add    $0x1,%edx
801021b2:	81 fa ff 3f 00 00    	cmp    $0x3fff,%edx
801021b8:	7f 4e                	jg     80102208 <kalloc+0xbc>
      if (frame[i] == 0) {
801021ba:	83 3c 95 e0 a5 10 80 	cmpl   $0x0,-0x7fef5a20(,%edx,4)
801021c1:	00 
801021c2:	75 eb                	jne    801021af <kalloc+0x63>
        if (pid == -2  || (
801021c4:	83 fb fe             	cmp    $0xfffffffe,%ebx
801021c7:	74 15                	je     801021de <kalloc+0x92>
801021c9:	85 d2                	test   %edx,%edx
801021cb:	74 c1                	je     8010218e <kalloc+0x42>
          (i == 0 || frame[i-1] == 0 || frame[i - 1] == pid || frame[i - 1] == -2) 
801021cd:	8b 04 95 dc a5 10 80 	mov    -0x7fef5a24(,%edx,4),%eax
801021d4:	85 c0                	test   %eax,%eax
801021d6:	74 b6                	je     8010218e <kalloc+0x42>
801021d8:	39 d8                	cmp    %ebx,%eax
801021da:	75 c9                	jne    801021a5 <kalloc+0x59>
801021dc:	eb b0                	jmp    8010218e <kalloc+0x42>
          r = P2V((0XDFFF - i) << 12);
801021de:	be ff df 00 00       	mov    $0xdfff,%esi
801021e3:	29 d6                	sub    %edx,%esi
801021e5:	c1 e6 0c             	shl    $0xc,%esi
801021e8:	81 c6 00 00 00 80    	add    $0x80000000,%esi
          frame[i] = pid;
801021ee:	89 1c 95 e0 a5 10 80 	mov    %ebx,-0x7fef5a20(,%edx,4)
          size = i > size? i : size;
801021f5:	39 15 c8 a5 10 80    	cmp    %edx,0x8010a5c8
801021fb:	0f 4d 15 c8 a5 10 80 	cmovge 0x8010a5c8,%edx
80102202:	89 15 c8 a5 10 80    	mov    %edx,0x8010a5c8
    update();
80102208:	e8 a3 fd ff ff       	call   80101fb0 <update>
  //     kmem.freelist = r->next;
  //   }
  // } else {
  // }
  //
  if(kmem.use_lock)
8010220d:	83 3d b4 26 12 80 00 	cmpl   $0x0,0x801226b4
80102214:	75 10                	jne    80102226 <kalloc+0xda>
    release(&kmem.lock);
  return (char*)r;
}
80102216:	89 f0                	mov    %esi,%eax
80102218:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010221b:	5b                   	pop    %ebx
8010221c:	5e                   	pop    %esi
8010221d:	5d                   	pop    %ebp
8010221e:	c3                   	ret    
    for (int i = 0; i < 16384; i++) {
8010221f:	ba 00 00 00 00       	mov    $0x0,%edx
80102224:	eb 8c                	jmp    801021b2 <kalloc+0x66>
    release(&kmem.lock);
80102226:	83 ec 0c             	sub    $0xc,%esp
80102229:	68 80 26 12 80       	push   $0x80122680
8010222e:	e8 67 1b 00 00       	call   80103d9a <release>
80102233:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102236:	eb de                	jmp    80102216 <kalloc+0xca>

80102238 <dump_physmem>:



int
dump_physmem(int *frames, int *pids, int numframes)
{
80102238:	55                   	push   %ebp
80102239:	89 e5                	mov    %esp,%ebp
8010223b:	57                   	push   %edi
8010223c:	56                   	push   %esi
8010223d:	53                   	push   %ebx
8010223e:	8b 75 08             	mov    0x8(%ebp),%esi
80102241:	8b 7d 0c             	mov    0xc(%ebp),%edi
80102244:	8b 5d 10             	mov    0x10(%ebp),%ebx
  if (frames == NULL || pids == NULL || numframes < 0) {
80102247:	85 f6                	test   %esi,%esi
80102249:	0f 94 c2             	sete   %dl
8010224c:	85 ff                	test   %edi,%edi
8010224e:	0f 94 c0             	sete   %al
80102251:	08 c2                	or     %al,%dl
80102253:	75 37                	jne    8010228c <dump_physmem+0x54>
80102255:	85 db                	test   %ebx,%ebx
80102257:	78 3a                	js     80102293 <dump_physmem+0x5b>
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
80102259:	b8 00 00 00 00       	mov    $0x0,%eax
8010225e:	eb 1e                	jmp    8010227e <dump_physmem+0x46>
    //       release(&kmem.lock);
    // } else {
    //   frames[i] = -1;
    //   pids[i] = -1;
    // }
    frames[i] = r_frame[i];
80102260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102267:	8b 0c 85 c0 26 13 80 	mov    -0x7fecd940(,%eax,4),%ecx
8010226e:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
    pids[i] = r_pid[i];
80102271:	8b 0c 85 c0 26 12 80 	mov    -0x7fedd940(,%eax,4),%ecx
80102278:	89 0c 17             	mov    %ecx,(%edi,%edx,1)
  for (int i = 0; i < numframes; i++) {
8010227b:	83 c0 01             	add    $0x1,%eax
8010227e:	39 d8                	cmp    %ebx,%eax
80102280:	7c de                	jl     80102260 <dump_physmem+0x28>
  }
  
  return 0;
80102282:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102287:	5b                   	pop    %ebx
80102288:	5e                   	pop    %esi
80102289:	5f                   	pop    %edi
8010228a:	5d                   	pop    %ebp
8010228b:	c3                   	ret    
      return -1;
8010228c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102291:	eb f4                	jmp    80102287 <dump_physmem+0x4f>
80102293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102298:	eb ed                	jmp    80102287 <dump_physmem+0x4f>

8010229a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010229a:	55                   	push   %ebp
8010229b:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010229d:	ba 64 00 00 00       	mov    $0x64,%edx
801022a2:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022a3:	a8 01                	test   $0x1,%al
801022a5:	0f 84 b5 00 00 00    	je     80102360 <kbdgetc+0xc6>
801022ab:	ba 60 00 00 00       	mov    $0x60,%edx
801022b0:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801022b1:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801022b4:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801022ba:	74 5c                	je     80102318 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801022bc:	84 c0                	test   %al,%al
801022be:	78 66                	js     80102326 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801022c0:	8b 0d e0 a5 11 80    	mov    0x8011a5e0,%ecx
801022c6:	f6 c1 40             	test   $0x40,%cl
801022c9:	74 0f                	je     801022da <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801022cb:	83 c8 80             	or     $0xffffff80,%eax
801022ce:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801022d1:	83 e1 bf             	and    $0xffffffbf,%ecx
801022d4:	89 0d e0 a5 11 80    	mov    %ecx,0x8011a5e0
  }

  shift |= shiftcode[data];
801022da:	0f b6 8a 00 6a 10 80 	movzbl -0x7fef9600(%edx),%ecx
801022e1:	0b 0d e0 a5 11 80    	or     0x8011a5e0,%ecx
  shift ^= togglecode[data];
801022e7:	0f b6 82 00 69 10 80 	movzbl -0x7fef9700(%edx),%eax
801022ee:	31 c1                	xor    %eax,%ecx
801022f0:	89 0d e0 a5 11 80    	mov    %ecx,0x8011a5e0
  c = charcode[shift & (CTL | SHIFT)][data];
801022f6:	89 c8                	mov    %ecx,%eax
801022f8:	83 e0 03             	and    $0x3,%eax
801022fb:	8b 04 85 e0 68 10 80 	mov    -0x7fef9720(,%eax,4),%eax
80102302:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102306:	f6 c1 08             	test   $0x8,%cl
80102309:	74 19                	je     80102324 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
8010230b:	8d 50 9f             	lea    -0x61(%eax),%edx
8010230e:	83 fa 19             	cmp    $0x19,%edx
80102311:	77 40                	ja     80102353 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102313:	83 e8 20             	sub    $0x20,%eax
80102316:	eb 0c                	jmp    80102324 <kbdgetc+0x8a>
    shift |= E0ESC;
80102318:	83 0d e0 a5 11 80 40 	orl    $0x40,0x8011a5e0
    return 0;
8010231f:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102324:	5d                   	pop    %ebp
80102325:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102326:	8b 0d e0 a5 11 80    	mov    0x8011a5e0,%ecx
8010232c:	f6 c1 40             	test   $0x40,%cl
8010232f:	75 05                	jne    80102336 <kbdgetc+0x9c>
80102331:	89 c2                	mov    %eax,%edx
80102333:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102336:	0f b6 82 00 6a 10 80 	movzbl -0x7fef9600(%edx),%eax
8010233d:	83 c8 40             	or     $0x40,%eax
80102340:	0f b6 c0             	movzbl %al,%eax
80102343:	f7 d0                	not    %eax
80102345:	21 c8                	and    %ecx,%eax
80102347:	a3 e0 a5 11 80       	mov    %eax,0x8011a5e0
    return 0;
8010234c:	b8 00 00 00 00       	mov    $0x0,%eax
80102351:	eb d1                	jmp    80102324 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
80102353:	8d 50 bf             	lea    -0x41(%eax),%edx
80102356:	83 fa 19             	cmp    $0x19,%edx
80102359:	77 c9                	ja     80102324 <kbdgetc+0x8a>
      c += 'a' - 'A';
8010235b:	83 c0 20             	add    $0x20,%eax
  return c;
8010235e:	eb c4                	jmp    80102324 <kbdgetc+0x8a>
    return -1;
80102360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102365:	eb bd                	jmp    80102324 <kbdgetc+0x8a>

80102367 <kbdintr>:

void
kbdintr(void)
{
80102367:	55                   	push   %ebp
80102368:	89 e5                	mov    %esp,%ebp
8010236a:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010236d:	68 9a 22 10 80       	push   $0x8010229a
80102372:	e8 c7 e3 ff ff       	call   8010073e <consoleintr>
}
80102377:	83 c4 10             	add    $0x10,%esp
8010237a:	c9                   	leave  
8010237b:	c3                   	ret    

8010237c <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010237c:	55                   	push   %ebp
8010237d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010237f:	8b 0d c0 26 14 80    	mov    0x801426c0,%ecx
80102385:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102388:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010238a:	a1 c0 26 14 80       	mov    0x801426c0,%eax
8010238f:	8b 40 20             	mov    0x20(%eax),%eax
}
80102392:	5d                   	pop    %ebp
80102393:	c3                   	ret    

80102394 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80102394:	55                   	push   %ebp
80102395:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102397:	ba 70 00 00 00       	mov    $0x70,%edx
8010239c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010239d:	ba 71 00 00 00       	mov    $0x71,%edx
801023a2:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801023a3:	0f b6 c0             	movzbl %al,%eax
}
801023a6:	5d                   	pop    %ebp
801023a7:	c3                   	ret    

801023a8 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801023a8:	55                   	push   %ebp
801023a9:	89 e5                	mov    %esp,%ebp
801023ab:	53                   	push   %ebx
801023ac:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801023ae:	b8 00 00 00 00       	mov    $0x0,%eax
801023b3:	e8 dc ff ff ff       	call   80102394 <cmos_read>
801023b8:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801023ba:	b8 02 00 00 00       	mov    $0x2,%eax
801023bf:	e8 d0 ff ff ff       	call   80102394 <cmos_read>
801023c4:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801023c7:	b8 04 00 00 00       	mov    $0x4,%eax
801023cc:	e8 c3 ff ff ff       	call   80102394 <cmos_read>
801023d1:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801023d4:	b8 07 00 00 00       	mov    $0x7,%eax
801023d9:	e8 b6 ff ff ff       	call   80102394 <cmos_read>
801023de:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801023e1:	b8 08 00 00 00       	mov    $0x8,%eax
801023e6:	e8 a9 ff ff ff       	call   80102394 <cmos_read>
801023eb:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801023ee:	b8 09 00 00 00       	mov    $0x9,%eax
801023f3:	e8 9c ff ff ff       	call   80102394 <cmos_read>
801023f8:	89 43 14             	mov    %eax,0x14(%ebx)
}
801023fb:	5b                   	pop    %ebx
801023fc:	5d                   	pop    %ebp
801023fd:	c3                   	ret    

801023fe <lapicinit>:
  if(!lapic)
801023fe:	83 3d c0 26 14 80 00 	cmpl   $0x0,0x801426c0
80102405:	0f 84 fb 00 00 00    	je     80102506 <lapicinit+0x108>
{
8010240b:	55                   	push   %ebp
8010240c:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010240e:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102413:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102418:	e8 5f ff ff ff       	call   8010237c <lapicw>
  lapicw(TDCR, X1);
8010241d:	ba 0b 00 00 00       	mov    $0xb,%edx
80102422:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102427:	e8 50 ff ff ff       	call   8010237c <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010242c:	ba 20 00 02 00       	mov    $0x20020,%edx
80102431:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102436:	e8 41 ff ff ff       	call   8010237c <lapicw>
  lapicw(TICR, 10000000);
8010243b:	ba 80 96 98 00       	mov    $0x989680,%edx
80102440:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102445:	e8 32 ff ff ff       	call   8010237c <lapicw>
  lapicw(LINT0, MASKED);
8010244a:	ba 00 00 01 00       	mov    $0x10000,%edx
8010244f:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102454:	e8 23 ff ff ff       	call   8010237c <lapicw>
  lapicw(LINT1, MASKED);
80102459:	ba 00 00 01 00       	mov    $0x10000,%edx
8010245e:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102463:	e8 14 ff ff ff       	call   8010237c <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102468:	a1 c0 26 14 80       	mov    0x801426c0,%eax
8010246d:	8b 40 30             	mov    0x30(%eax),%eax
80102470:	c1 e8 10             	shr    $0x10,%eax
80102473:	3c 03                	cmp    $0x3,%al
80102475:	77 7b                	ja     801024f2 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102477:	ba 33 00 00 00       	mov    $0x33,%edx
8010247c:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102481:	e8 f6 fe ff ff       	call   8010237c <lapicw>
  lapicw(ESR, 0);
80102486:	ba 00 00 00 00       	mov    $0x0,%edx
8010248b:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102490:	e8 e7 fe ff ff       	call   8010237c <lapicw>
  lapicw(ESR, 0);
80102495:	ba 00 00 00 00       	mov    $0x0,%edx
8010249a:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010249f:	e8 d8 fe ff ff       	call   8010237c <lapicw>
  lapicw(EOI, 0);
801024a4:	ba 00 00 00 00       	mov    $0x0,%edx
801024a9:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024ae:	e8 c9 fe ff ff       	call   8010237c <lapicw>
  lapicw(ICRHI, 0);
801024b3:	ba 00 00 00 00       	mov    $0x0,%edx
801024b8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024bd:	e8 ba fe ff ff       	call   8010237c <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801024c2:	ba 00 85 08 00       	mov    $0x88500,%edx
801024c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024cc:	e8 ab fe ff ff       	call   8010237c <lapicw>
  while(lapic[ICRLO] & DELIVS)
801024d1:	a1 c0 26 14 80       	mov    0x801426c0,%eax
801024d6:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801024dc:	f6 c4 10             	test   $0x10,%ah
801024df:	75 f0                	jne    801024d1 <lapicinit+0xd3>
  lapicw(TPR, 0);
801024e1:	ba 00 00 00 00       	mov    $0x0,%edx
801024e6:	b8 20 00 00 00       	mov    $0x20,%eax
801024eb:	e8 8c fe ff ff       	call   8010237c <lapicw>
}
801024f0:	5d                   	pop    %ebp
801024f1:	c3                   	ret    
    lapicw(PCINT, MASKED);
801024f2:	ba 00 00 01 00       	mov    $0x10000,%edx
801024f7:	b8 d0 00 00 00       	mov    $0xd0,%eax
801024fc:	e8 7b fe ff ff       	call   8010237c <lapicw>
80102501:	e9 71 ff ff ff       	jmp    80102477 <lapicinit+0x79>
80102506:	f3 c3                	repz ret 

80102508 <lapicid>:
{
80102508:	55                   	push   %ebp
80102509:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010250b:	a1 c0 26 14 80       	mov    0x801426c0,%eax
80102510:	85 c0                	test   %eax,%eax
80102512:	74 08                	je     8010251c <lapicid+0x14>
  return lapic[ID] >> 24;
80102514:	8b 40 20             	mov    0x20(%eax),%eax
80102517:	c1 e8 18             	shr    $0x18,%eax
}
8010251a:	5d                   	pop    %ebp
8010251b:	c3                   	ret    
    return 0;
8010251c:	b8 00 00 00 00       	mov    $0x0,%eax
80102521:	eb f7                	jmp    8010251a <lapicid+0x12>

80102523 <lapiceoi>:
  if(lapic)
80102523:	83 3d c0 26 14 80 00 	cmpl   $0x0,0x801426c0
8010252a:	74 14                	je     80102540 <lapiceoi+0x1d>
{
8010252c:	55                   	push   %ebp
8010252d:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
8010252f:	ba 00 00 00 00       	mov    $0x0,%edx
80102534:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102539:	e8 3e fe ff ff       	call   8010237c <lapicw>
}
8010253e:	5d                   	pop    %ebp
8010253f:	c3                   	ret    
80102540:	f3 c3                	repz ret 

80102542 <microdelay>:
{
80102542:	55                   	push   %ebp
80102543:	89 e5                	mov    %esp,%ebp
}
80102545:	5d                   	pop    %ebp
80102546:	c3                   	ret    

80102547 <lapicstartap>:
{
80102547:	55                   	push   %ebp
80102548:	89 e5                	mov    %esp,%ebp
8010254a:	57                   	push   %edi
8010254b:	56                   	push   %esi
8010254c:	53                   	push   %ebx
8010254d:	8b 75 08             	mov    0x8(%ebp),%esi
80102550:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102553:	b8 0f 00 00 00       	mov    $0xf,%eax
80102558:	ba 70 00 00 00       	mov    $0x70,%edx
8010255d:	ee                   	out    %al,(%dx)
8010255e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102563:	ba 71 00 00 00       	mov    $0x71,%edx
80102568:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102569:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102570:	00 00 
  wrv[1] = addr >> 4;
80102572:	89 f8                	mov    %edi,%eax
80102574:	c1 e8 04             	shr    $0x4,%eax
80102577:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
8010257d:	c1 e6 18             	shl    $0x18,%esi
80102580:	89 f2                	mov    %esi,%edx
80102582:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102587:	e8 f0 fd ff ff       	call   8010237c <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010258c:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102591:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102596:	e8 e1 fd ff ff       	call   8010237c <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
8010259b:	ba 00 85 00 00       	mov    $0x8500,%edx
801025a0:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025a5:	e8 d2 fd ff ff       	call   8010237c <lapicw>
  for(i = 0; i < 2; i++){
801025aa:	bb 00 00 00 00       	mov    $0x0,%ebx
801025af:	eb 21                	jmp    801025d2 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801025b1:	89 f2                	mov    %esi,%edx
801025b3:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025b8:	e8 bf fd ff ff       	call   8010237c <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801025bd:	89 fa                	mov    %edi,%edx
801025bf:	c1 ea 0c             	shr    $0xc,%edx
801025c2:	80 ce 06             	or     $0x6,%dh
801025c5:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025ca:	e8 ad fd ff ff       	call   8010237c <lapicw>
  for(i = 0; i < 2; i++){
801025cf:	83 c3 01             	add    $0x1,%ebx
801025d2:	83 fb 01             	cmp    $0x1,%ebx
801025d5:	7e da                	jle    801025b1 <lapicstartap+0x6a>
}
801025d7:	5b                   	pop    %ebx
801025d8:	5e                   	pop    %esi
801025d9:	5f                   	pop    %edi
801025da:	5d                   	pop    %ebp
801025db:	c3                   	ret    

801025dc <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801025dc:	55                   	push   %ebp
801025dd:	89 e5                	mov    %esp,%ebp
801025df:	57                   	push   %edi
801025e0:	56                   	push   %esi
801025e1:	53                   	push   %ebx
801025e2:	83 ec 3c             	sub    $0x3c,%esp
801025e5:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801025e8:	b8 0b 00 00 00       	mov    $0xb,%eax
801025ed:	e8 a2 fd ff ff       	call   80102394 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801025f2:	83 e0 04             	and    $0x4,%eax
801025f5:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801025f7:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025fa:	e8 a9 fd ff ff       	call   801023a8 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801025ff:	b8 0a 00 00 00       	mov    $0xa,%eax
80102604:	e8 8b fd ff ff       	call   80102394 <cmos_read>
80102609:	a8 80                	test   $0x80,%al
8010260b:	75 ea                	jne    801025f7 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
8010260d:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102610:	89 d8                	mov    %ebx,%eax
80102612:	e8 91 fd ff ff       	call   801023a8 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102617:	83 ec 04             	sub    $0x4,%esp
8010261a:	6a 18                	push   $0x18
8010261c:	53                   	push   %ebx
8010261d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102620:	50                   	push   %eax
80102621:	e8 01 18 00 00       	call   80103e27 <memcmp>
80102626:	83 c4 10             	add    $0x10,%esp
80102629:	85 c0                	test   %eax,%eax
8010262b:	75 ca                	jne    801025f7 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
8010262d:	85 ff                	test   %edi,%edi
8010262f:	0f 85 84 00 00 00    	jne    801026b9 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102635:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102638:	89 d0                	mov    %edx,%eax
8010263a:	c1 e8 04             	shr    $0x4,%eax
8010263d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102640:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102643:	83 e2 0f             	and    $0xf,%edx
80102646:	01 d0                	add    %edx,%eax
80102648:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010264b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010264e:	89 d0                	mov    %edx,%eax
80102650:	c1 e8 04             	shr    $0x4,%eax
80102653:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102656:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102659:	83 e2 0f             	and    $0xf,%edx
8010265c:	01 d0                	add    %edx,%eax
8010265e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102661:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102664:	89 d0                	mov    %edx,%eax
80102666:	c1 e8 04             	shr    $0x4,%eax
80102669:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010266c:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010266f:	83 e2 0f             	and    $0xf,%edx
80102672:	01 d0                	add    %edx,%eax
80102674:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102677:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010267a:	89 d0                	mov    %edx,%eax
8010267c:	c1 e8 04             	shr    $0x4,%eax
8010267f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102682:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102685:	83 e2 0f             	and    $0xf,%edx
80102688:	01 d0                	add    %edx,%eax
8010268a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010268d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102690:	89 d0                	mov    %edx,%eax
80102692:	c1 e8 04             	shr    $0x4,%eax
80102695:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102698:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010269b:	83 e2 0f             	and    $0xf,%edx
8010269e:	01 d0                	add    %edx,%eax
801026a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801026a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801026a6:	89 d0                	mov    %edx,%eax
801026a8:	c1 e8 04             	shr    $0x4,%eax
801026ab:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026ae:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026b1:	83 e2 0f             	and    $0xf,%edx
801026b4:	01 d0                	add    %edx,%eax
801026b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801026b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801026bc:	89 06                	mov    %eax,(%esi)
801026be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801026c1:	89 46 04             	mov    %eax,0x4(%esi)
801026c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801026c7:	89 46 08             	mov    %eax,0x8(%esi)
801026ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
801026cd:	89 46 0c             	mov    %eax,0xc(%esi)
801026d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801026d3:	89 46 10             	mov    %eax,0x10(%esi)
801026d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801026d9:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801026dc:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801026e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026e6:	5b                   	pop    %ebx
801026e7:	5e                   	pop    %esi
801026e8:	5f                   	pop    %edi
801026e9:	5d                   	pop    %ebp
801026ea:	c3                   	ret    

801026eb <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801026eb:	55                   	push   %ebp
801026ec:	89 e5                	mov    %esp,%ebp
801026ee:	53                   	push   %ebx
801026ef:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801026f2:	ff 35 14 27 14 80    	pushl  0x80142714
801026f8:	ff 35 24 27 14 80    	pushl  0x80142724
801026fe:	e8 69 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102703:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102706:	89 1d 28 27 14 80    	mov    %ebx,0x80142728
  for (i = 0; i < log.lh.n; i++) {
8010270c:	83 c4 10             	add    $0x10,%esp
8010270f:	ba 00 00 00 00       	mov    $0x0,%edx
80102714:	eb 0e                	jmp    80102724 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102716:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
8010271a:	89 0c 95 2c 27 14 80 	mov    %ecx,-0x7febd8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102721:	83 c2 01             	add    $0x1,%edx
80102724:	39 d3                	cmp    %edx,%ebx
80102726:	7f ee                	jg     80102716 <read_head+0x2b>
  }
  brelse(buf);
80102728:	83 ec 0c             	sub    $0xc,%esp
8010272b:	50                   	push   %eax
8010272c:	e8 a4 da ff ff       	call   801001d5 <brelse>
}
80102731:	83 c4 10             	add    $0x10,%esp
80102734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102737:	c9                   	leave  
80102738:	c3                   	ret    

80102739 <install_trans>:
{
80102739:	55                   	push   %ebp
8010273a:	89 e5                	mov    %esp,%ebp
8010273c:	57                   	push   %edi
8010273d:	56                   	push   %esi
8010273e:	53                   	push   %ebx
8010273f:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102742:	bb 00 00 00 00       	mov    $0x0,%ebx
80102747:	eb 66                	jmp    801027af <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102749:	89 d8                	mov    %ebx,%eax
8010274b:	03 05 14 27 14 80    	add    0x80142714,%eax
80102751:	83 c0 01             	add    $0x1,%eax
80102754:	83 ec 08             	sub    $0x8,%esp
80102757:	50                   	push   %eax
80102758:	ff 35 24 27 14 80    	pushl  0x80142724
8010275e:	e8 09 da ff ff       	call   8010016c <bread>
80102763:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102765:	83 c4 08             	add    $0x8,%esp
80102768:	ff 34 9d 2c 27 14 80 	pushl  -0x7febd8d4(,%ebx,4)
8010276f:	ff 35 24 27 14 80    	pushl  0x80142724
80102775:	e8 f2 d9 ff ff       	call   8010016c <bread>
8010277a:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010277c:	8d 57 5c             	lea    0x5c(%edi),%edx
8010277f:	8d 40 5c             	lea    0x5c(%eax),%eax
80102782:	83 c4 0c             	add    $0xc,%esp
80102785:	68 00 02 00 00       	push   $0x200
8010278a:	52                   	push   %edx
8010278b:	50                   	push   %eax
8010278c:	e8 cb 16 00 00       	call   80103e5c <memmove>
    bwrite(dbuf);  // write dst to disk
80102791:	89 34 24             	mov    %esi,(%esp)
80102794:	e8 01 da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102799:	89 3c 24             	mov    %edi,(%esp)
8010279c:	e8 34 da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801027a1:	89 34 24             	mov    %esi,(%esp)
801027a4:	e8 2c da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027a9:	83 c3 01             	add    $0x1,%ebx
801027ac:	83 c4 10             	add    $0x10,%esp
801027af:	39 1d 28 27 14 80    	cmp    %ebx,0x80142728
801027b5:	7f 92                	jg     80102749 <install_trans+0x10>
}
801027b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027ba:	5b                   	pop    %ebx
801027bb:	5e                   	pop    %esi
801027bc:	5f                   	pop    %edi
801027bd:	5d                   	pop    %ebp
801027be:	c3                   	ret    

801027bf <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801027bf:	55                   	push   %ebp
801027c0:	89 e5                	mov    %esp,%ebp
801027c2:	53                   	push   %ebx
801027c3:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801027c6:	ff 35 14 27 14 80    	pushl  0x80142714
801027cc:	ff 35 24 27 14 80    	pushl  0x80142724
801027d2:	e8 95 d9 ff ff       	call   8010016c <bread>
801027d7:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801027d9:	8b 0d 28 27 14 80    	mov    0x80142728,%ecx
801027df:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801027e2:	83 c4 10             	add    $0x10,%esp
801027e5:	b8 00 00 00 00       	mov    $0x0,%eax
801027ea:	eb 0e                	jmp    801027fa <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801027ec:	8b 14 85 2c 27 14 80 	mov    -0x7febd8d4(,%eax,4),%edx
801027f3:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801027f7:	83 c0 01             	add    $0x1,%eax
801027fa:	39 c1                	cmp    %eax,%ecx
801027fc:	7f ee                	jg     801027ec <write_head+0x2d>
  }
  bwrite(buf);
801027fe:	83 ec 0c             	sub    $0xc,%esp
80102801:	53                   	push   %ebx
80102802:	e8 93 d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102807:	89 1c 24             	mov    %ebx,(%esp)
8010280a:	e8 c6 d9 ff ff       	call   801001d5 <brelse>
}
8010280f:	83 c4 10             	add    $0x10,%esp
80102812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102815:	c9                   	leave  
80102816:	c3                   	ret    

80102817 <recover_from_log>:

static void
recover_from_log(void)
{
80102817:	55                   	push   %ebp
80102818:	89 e5                	mov    %esp,%ebp
8010281a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010281d:	e8 c9 fe ff ff       	call   801026eb <read_head>
  install_trans(); // if committed, copy from log to disk
80102822:	e8 12 ff ff ff       	call   80102739 <install_trans>
  log.lh.n = 0;
80102827:	c7 05 28 27 14 80 00 	movl   $0x0,0x80142728
8010282e:	00 00 00 
  write_head(); // clear the log
80102831:	e8 89 ff ff ff       	call   801027bf <write_head>
}
80102836:	c9                   	leave  
80102837:	c3                   	ret    

80102838 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
8010283b:	57                   	push   %edi
8010283c:	56                   	push   %esi
8010283d:	53                   	push   %ebx
8010283e:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102841:	bb 00 00 00 00       	mov    $0x0,%ebx
80102846:	eb 66                	jmp    801028ae <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102848:	89 d8                	mov    %ebx,%eax
8010284a:	03 05 14 27 14 80    	add    0x80142714,%eax
80102850:	83 c0 01             	add    $0x1,%eax
80102853:	83 ec 08             	sub    $0x8,%esp
80102856:	50                   	push   %eax
80102857:	ff 35 24 27 14 80    	pushl  0x80142724
8010285d:	e8 0a d9 ff ff       	call   8010016c <bread>
80102862:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102864:	83 c4 08             	add    $0x8,%esp
80102867:	ff 34 9d 2c 27 14 80 	pushl  -0x7febd8d4(,%ebx,4)
8010286e:	ff 35 24 27 14 80    	pushl  0x80142724
80102874:	e8 f3 d8 ff ff       	call   8010016c <bread>
80102879:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010287b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010287e:	8d 46 5c             	lea    0x5c(%esi),%eax
80102881:	83 c4 0c             	add    $0xc,%esp
80102884:	68 00 02 00 00       	push   $0x200
80102889:	52                   	push   %edx
8010288a:	50                   	push   %eax
8010288b:	e8 cc 15 00 00       	call   80103e5c <memmove>
    bwrite(to);  // write the log
80102890:	89 34 24             	mov    %esi,(%esp)
80102893:	e8 02 d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
80102898:	89 3c 24             	mov    %edi,(%esp)
8010289b:	e8 35 d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
801028a0:	89 34 24             	mov    %esi,(%esp)
801028a3:	e8 2d d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801028a8:	83 c3 01             	add    $0x1,%ebx
801028ab:	83 c4 10             	add    $0x10,%esp
801028ae:	39 1d 28 27 14 80    	cmp    %ebx,0x80142728
801028b4:	7f 92                	jg     80102848 <write_log+0x10>
  }
}
801028b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801028b9:	5b                   	pop    %ebx
801028ba:	5e                   	pop    %esi
801028bb:	5f                   	pop    %edi
801028bc:	5d                   	pop    %ebp
801028bd:	c3                   	ret    

801028be <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801028be:	83 3d 28 27 14 80 00 	cmpl   $0x0,0x80142728
801028c5:	7e 26                	jle    801028ed <commit+0x2f>
{
801028c7:	55                   	push   %ebp
801028c8:	89 e5                	mov    %esp,%ebp
801028ca:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801028cd:	e8 66 ff ff ff       	call   80102838 <write_log>
    write_head();    // Write header to disk -- the real commit
801028d2:	e8 e8 fe ff ff       	call   801027bf <write_head>
    install_trans(); // Now install writes to home locations
801028d7:	e8 5d fe ff ff       	call   80102739 <install_trans>
    log.lh.n = 0;
801028dc:	c7 05 28 27 14 80 00 	movl   $0x0,0x80142728
801028e3:	00 00 00 
    write_head();    // Erase the transaction from the log
801028e6:	e8 d4 fe ff ff       	call   801027bf <write_head>
  }
}
801028eb:	c9                   	leave  
801028ec:	c3                   	ret    
801028ed:	f3 c3                	repz ret 

801028ef <initlog>:
{
801028ef:	55                   	push   %ebp
801028f0:	89 e5                	mov    %esp,%ebp
801028f2:	53                   	push   %ebx
801028f3:	83 ec 2c             	sub    $0x2c,%esp
801028f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801028f9:	68 00 6b 10 80       	push   $0x80106b00
801028fe:	68 e0 26 14 80       	push   $0x801426e0
80102903:	e8 f1 12 00 00       	call   80103bf9 <initlock>
  readsb(dev, &sb);
80102908:	83 c4 08             	add    $0x8,%esp
8010290b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010290e:	50                   	push   %eax
8010290f:	53                   	push   %ebx
80102910:	e8 2d e9 ff ff       	call   80101242 <readsb>
  log.start = sb.logstart;
80102915:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102918:	a3 14 27 14 80       	mov    %eax,0x80142714
  log.size = sb.nlog;
8010291d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102920:	a3 18 27 14 80       	mov    %eax,0x80142718
  log.dev = dev;
80102925:	89 1d 24 27 14 80    	mov    %ebx,0x80142724
  recover_from_log();
8010292b:	e8 e7 fe ff ff       	call   80102817 <recover_from_log>
}
80102930:	83 c4 10             	add    $0x10,%esp
80102933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102936:	c9                   	leave  
80102937:	c3                   	ret    

80102938 <begin_op>:
{
80102938:	55                   	push   %ebp
80102939:	89 e5                	mov    %esp,%ebp
8010293b:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
8010293e:	68 e0 26 14 80       	push   $0x801426e0
80102943:	e8 ed 13 00 00       	call   80103d35 <acquire>
80102948:	83 c4 10             	add    $0x10,%esp
8010294b:	eb 15                	jmp    80102962 <begin_op+0x2a>
      sleep(&log, &log.lock);
8010294d:	83 ec 08             	sub    $0x8,%esp
80102950:	68 e0 26 14 80       	push   $0x801426e0
80102955:	68 e0 26 14 80       	push   $0x801426e0
8010295a:	e8 db 0e 00 00       	call   8010383a <sleep>
8010295f:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102962:	83 3d 20 27 14 80 00 	cmpl   $0x0,0x80142720
80102969:	75 e2                	jne    8010294d <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010296b:	a1 1c 27 14 80       	mov    0x8014271c,%eax
80102970:	83 c0 01             	add    $0x1,%eax
80102973:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102976:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102979:	03 15 28 27 14 80    	add    0x80142728,%edx
8010297f:	83 fa 1e             	cmp    $0x1e,%edx
80102982:	7e 17                	jle    8010299b <begin_op+0x63>
      sleep(&log, &log.lock);
80102984:	83 ec 08             	sub    $0x8,%esp
80102987:	68 e0 26 14 80       	push   $0x801426e0
8010298c:	68 e0 26 14 80       	push   $0x801426e0
80102991:	e8 a4 0e 00 00       	call   8010383a <sleep>
80102996:	83 c4 10             	add    $0x10,%esp
80102999:	eb c7                	jmp    80102962 <begin_op+0x2a>
      log.outstanding += 1;
8010299b:	a3 1c 27 14 80       	mov    %eax,0x8014271c
      release(&log.lock);
801029a0:	83 ec 0c             	sub    $0xc,%esp
801029a3:	68 e0 26 14 80       	push   $0x801426e0
801029a8:	e8 ed 13 00 00       	call   80103d9a <release>
}
801029ad:	83 c4 10             	add    $0x10,%esp
801029b0:	c9                   	leave  
801029b1:	c3                   	ret    

801029b2 <end_op>:
{
801029b2:	55                   	push   %ebp
801029b3:	89 e5                	mov    %esp,%ebp
801029b5:	53                   	push   %ebx
801029b6:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801029b9:	68 e0 26 14 80       	push   $0x801426e0
801029be:	e8 72 13 00 00       	call   80103d35 <acquire>
  log.outstanding -= 1;
801029c3:	a1 1c 27 14 80       	mov    0x8014271c,%eax
801029c8:	83 e8 01             	sub    $0x1,%eax
801029cb:	a3 1c 27 14 80       	mov    %eax,0x8014271c
  if(log.committing)
801029d0:	8b 1d 20 27 14 80    	mov    0x80142720,%ebx
801029d6:	83 c4 10             	add    $0x10,%esp
801029d9:	85 db                	test   %ebx,%ebx
801029db:	75 2c                	jne    80102a09 <end_op+0x57>
  if(log.outstanding == 0){
801029dd:	85 c0                	test   %eax,%eax
801029df:	75 35                	jne    80102a16 <end_op+0x64>
    log.committing = 1;
801029e1:	c7 05 20 27 14 80 01 	movl   $0x1,0x80142720
801029e8:	00 00 00 
    do_commit = 1;
801029eb:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801029f0:	83 ec 0c             	sub    $0xc,%esp
801029f3:	68 e0 26 14 80       	push   $0x801426e0
801029f8:	e8 9d 13 00 00       	call   80103d9a <release>
  if(do_commit){
801029fd:	83 c4 10             	add    $0x10,%esp
80102a00:	85 db                	test   %ebx,%ebx
80102a02:	75 24                	jne    80102a28 <end_op+0x76>
}
80102a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a07:	c9                   	leave  
80102a08:	c3                   	ret    
    panic("log.committing");
80102a09:	83 ec 0c             	sub    $0xc,%esp
80102a0c:	68 04 6b 10 80       	push   $0x80106b04
80102a11:	e8 32 d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102a16:	83 ec 0c             	sub    $0xc,%esp
80102a19:	68 e0 26 14 80       	push   $0x801426e0
80102a1e:	e8 7c 0f 00 00       	call   8010399f <wakeup>
80102a23:	83 c4 10             	add    $0x10,%esp
80102a26:	eb c8                	jmp    801029f0 <end_op+0x3e>
    commit();
80102a28:	e8 91 fe ff ff       	call   801028be <commit>
    acquire(&log.lock);
80102a2d:	83 ec 0c             	sub    $0xc,%esp
80102a30:	68 e0 26 14 80       	push   $0x801426e0
80102a35:	e8 fb 12 00 00       	call   80103d35 <acquire>
    log.committing = 0;
80102a3a:	c7 05 20 27 14 80 00 	movl   $0x0,0x80142720
80102a41:	00 00 00 
    wakeup(&log);
80102a44:	c7 04 24 e0 26 14 80 	movl   $0x801426e0,(%esp)
80102a4b:	e8 4f 0f 00 00       	call   8010399f <wakeup>
    release(&log.lock);
80102a50:	c7 04 24 e0 26 14 80 	movl   $0x801426e0,(%esp)
80102a57:	e8 3e 13 00 00       	call   80103d9a <release>
80102a5c:	83 c4 10             	add    $0x10,%esp
}
80102a5f:	eb a3                	jmp    80102a04 <end_op+0x52>

80102a61 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a61:	55                   	push   %ebp
80102a62:	89 e5                	mov    %esp,%ebp
80102a64:	53                   	push   %ebx
80102a65:	83 ec 04             	sub    $0x4,%esp
80102a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a6b:	8b 15 28 27 14 80    	mov    0x80142728,%edx
80102a71:	83 fa 1d             	cmp    $0x1d,%edx
80102a74:	7f 45                	jg     80102abb <log_write+0x5a>
80102a76:	a1 18 27 14 80       	mov    0x80142718,%eax
80102a7b:	83 e8 01             	sub    $0x1,%eax
80102a7e:	39 c2                	cmp    %eax,%edx
80102a80:	7d 39                	jge    80102abb <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a82:	83 3d 1c 27 14 80 00 	cmpl   $0x0,0x8014271c
80102a89:	7e 3d                	jle    80102ac8 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a8b:	83 ec 0c             	sub    $0xc,%esp
80102a8e:	68 e0 26 14 80       	push   $0x801426e0
80102a93:	e8 9d 12 00 00       	call   80103d35 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102a98:	83 c4 10             	add    $0x10,%esp
80102a9b:	b8 00 00 00 00       	mov    $0x0,%eax
80102aa0:	8b 15 28 27 14 80    	mov    0x80142728,%edx
80102aa6:	39 c2                	cmp    %eax,%edx
80102aa8:	7e 2b                	jle    80102ad5 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102aaa:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102aad:	39 0c 85 2c 27 14 80 	cmp    %ecx,-0x7febd8d4(,%eax,4)
80102ab4:	74 1f                	je     80102ad5 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102ab6:	83 c0 01             	add    $0x1,%eax
80102ab9:	eb e5                	jmp    80102aa0 <log_write+0x3f>
    panic("too big a transaction");
80102abb:	83 ec 0c             	sub    $0xc,%esp
80102abe:	68 13 6b 10 80       	push   $0x80106b13
80102ac3:	e8 80 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102ac8:	83 ec 0c             	sub    $0xc,%esp
80102acb:	68 29 6b 10 80       	push   $0x80106b29
80102ad0:	e8 73 d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102ad5:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102ad8:	89 0c 85 2c 27 14 80 	mov    %ecx,-0x7febd8d4(,%eax,4)
  if (i == log.lh.n)
80102adf:	39 c2                	cmp    %eax,%edx
80102ae1:	74 18                	je     80102afb <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102ae3:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102ae6:	83 ec 0c             	sub    $0xc,%esp
80102ae9:	68 e0 26 14 80       	push   $0x801426e0
80102aee:	e8 a7 12 00 00       	call   80103d9a <release>
}
80102af3:	83 c4 10             	add    $0x10,%esp
80102af6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102af9:	c9                   	leave  
80102afa:	c3                   	ret    
    log.lh.n++;
80102afb:	83 c2 01             	add    $0x1,%edx
80102afe:	89 15 28 27 14 80    	mov    %edx,0x80142728
80102b04:	eb dd                	jmp    80102ae3 <log_write+0x82>

80102b06 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102b06:	55                   	push   %ebp
80102b07:	89 e5                	mov    %esp,%ebp
80102b09:	53                   	push   %ebx
80102b0a:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b0d:	68 8a 00 00 00       	push   $0x8a
80102b12:	68 8c a4 10 80       	push   $0x8010a48c
80102b17:	68 00 70 00 80       	push   $0x80007000
80102b1c:	e8 3b 13 00 00       	call   80103e5c <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b21:	83 c4 10             	add    $0x10,%esp
80102b24:	bb e0 27 14 80       	mov    $0x801427e0,%ebx
80102b29:	eb 06                	jmp    80102b31 <startothers+0x2b>
80102b2b:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b31:	69 05 60 2d 14 80 b0 	imul   $0xb0,0x80142d60,%eax
80102b38:	00 00 00 
80102b3b:	05 e0 27 14 80       	add    $0x801427e0,%eax
80102b40:	39 d8                	cmp    %ebx,%eax
80102b42:	76 51                	jbe    80102b95 <startothers+0x8f>
    if(c == mycpu())  // We've started already.
80102b44:	e8 d3 07 00 00       	call   8010331c <mycpu>
80102b49:	39 d8                	cmp    %ebx,%eax
80102b4b:	74 de                	je     80102b2b <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc(-2);
80102b4d:	83 ec 0c             	sub    $0xc,%esp
80102b50:	6a fe                	push   $0xfffffffe
80102b52:	e8 f5 f5 ff ff       	call   8010214c <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b57:	05 00 10 00 00       	add    $0x1000,%eax
80102b5c:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b61:	c7 05 f8 6f 00 80 d9 	movl   $0x80102bd9,0x80006ff8
80102b68:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b6b:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b72:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b75:	83 c4 08             	add    $0x8,%esp
80102b78:	68 00 70 00 00       	push   $0x7000
80102b7d:	0f b6 03             	movzbl (%ebx),%eax
80102b80:	50                   	push   %eax
80102b81:	e8 c1 f9 ff ff       	call   80102547 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b86:	83 c4 10             	add    $0x10,%esp
80102b89:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b8f:	85 c0                	test   %eax,%eax
80102b91:	74 f6                	je     80102b89 <startothers+0x83>
80102b93:	eb 96                	jmp    80102b2b <startothers+0x25>
      ;
  }
}
80102b95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b98:	c9                   	leave  
80102b99:	c3                   	ret    

80102b9a <mpmain>:
{
80102b9a:	55                   	push   %ebp
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	53                   	push   %ebx
80102b9e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102ba1:	e8 d2 07 00 00       	call   80103378 <cpuid>
80102ba6:	89 c3                	mov    %eax,%ebx
80102ba8:	e8 cb 07 00 00       	call   80103378 <cpuid>
80102bad:	83 ec 04             	sub    $0x4,%esp
80102bb0:	53                   	push   %ebx
80102bb1:	50                   	push   %eax
80102bb2:	68 44 6b 10 80       	push   $0x80106b44
80102bb7:	e8 4f da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102bbc:	e8 f2 23 00 00       	call   80104fb3 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102bc1:	e8 56 07 00 00       	call   8010331c <mycpu>
80102bc6:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102bc8:	b8 01 00 00 00       	mov    $0x1,%eax
80102bcd:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102bd4:	e8 3c 0a 00 00       	call   80103615 <scheduler>

80102bd9 <mpenter>:
{
80102bd9:	55                   	push   %ebp
80102bda:	89 e5                	mov    %esp,%ebp
80102bdc:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102bdf:	e8 e0 33 00 00       	call   80105fc4 <switchkvm>
  seginit();
80102be4:	e8 8f 32 00 00       	call   80105e78 <seginit>
  lapicinit();
80102be9:	e8 10 f8 ff ff       	call   801023fe <lapicinit>
  mpmain();
80102bee:	e8 a7 ff ff ff       	call   80102b9a <mpmain>

80102bf3 <main>:
{
80102bf3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102bf7:	83 e4 f0             	and    $0xfffffff0,%esp
80102bfa:	ff 71 fc             	pushl  -0x4(%ecx)
80102bfd:	55                   	push   %ebp
80102bfe:	89 e5                	mov    %esp,%ebp
80102c00:	51                   	push   %ecx
80102c01:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102c04:	68 00 00 40 80       	push   $0x80400000
80102c09:	68 08 55 14 80       	push   $0x80145508
80102c0e:	e8 dd f4 ff ff       	call   801020f0 <kinit1>
  kvmalloc();      // kernel page table
80102c13:	e8 4f 38 00 00       	call   80106467 <kvmalloc>
  mpinit();        // detect other processors
80102c18:	e8 c9 01 00 00       	call   80102de6 <mpinit>
  lapicinit();     // interrupt controller
80102c1d:	e8 dc f7 ff ff       	call   801023fe <lapicinit>
  seginit();       // segment descriptors
80102c22:	e8 51 32 00 00       	call   80105e78 <seginit>
  picinit();       // disable pic
80102c27:	e8 82 02 00 00       	call   80102eae <picinit>
  ioapicinit();    // another interrupt controller
80102c2c:	e8 d5 f2 ff ff       	call   80101f06 <ioapicinit>
  consoleinit();   // console hardware
80102c31:	e8 58 dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c36:	e8 26 26 00 00       	call   80105261 <uartinit>
  pinit();         // process table
80102c3b:	e8 c2 06 00 00       	call   80103302 <pinit>
  tvinit();        // trap vectors
80102c40:	e8 bd 22 00 00       	call   80104f02 <tvinit>
  binit();         // buffer cache
80102c45:	e8 aa d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c4a:	e8 d0 df ff ff       	call   80100c1f <fileinit>
  ideinit();       // disk 
80102c4f:	e8 b8 f0 ff ff       	call   80101d0c <ideinit>
  startothers();   // start other processors
80102c54:	e8 ad fe ff ff       	call   80102b06 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c59:	83 c4 08             	add    $0x8,%esp
80102c5c:	68 00 00 00 8e       	push   $0x8e000000
80102c61:	68 00 00 40 80       	push   $0x80400000
80102c66:	e8 b7 f4 ff ff       	call   80102122 <kinit2>
  userinit();      // first user process
80102c6b:	e8 47 07 00 00       	call   801033b7 <userinit>
  mpmain();        // finish this processor's setup
80102c70:	e8 25 ff ff ff       	call   80102b9a <mpmain>

80102c75 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c75:	55                   	push   %ebp
80102c76:	89 e5                	mov    %esp,%ebp
80102c78:	56                   	push   %esi
80102c79:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c84:	eb 09                	jmp    80102c8f <sum+0x1a>
    sum += addr[i];
80102c86:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102c8a:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102c8c:	83 c1 01             	add    $0x1,%ecx
80102c8f:	39 d1                	cmp    %edx,%ecx
80102c91:	7c f3                	jl     80102c86 <sum+0x11>
  return sum;
}
80102c93:	89 d8                	mov    %ebx,%eax
80102c95:	5b                   	pop    %ebx
80102c96:	5e                   	pop    %esi
80102c97:	5d                   	pop    %ebp
80102c98:	c3                   	ret    

80102c99 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c99:	55                   	push   %ebp
80102c9a:	89 e5                	mov    %esp,%ebp
80102c9c:	56                   	push   %esi
80102c9d:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102c9e:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102ca4:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102ca6:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102ca8:	eb 03                	jmp    80102cad <mpsearch1+0x14>
80102caa:	83 c3 10             	add    $0x10,%ebx
80102cad:	39 f3                	cmp    %esi,%ebx
80102caf:	73 29                	jae    80102cda <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102cb1:	83 ec 04             	sub    $0x4,%esp
80102cb4:	6a 04                	push   $0x4
80102cb6:	68 58 6b 10 80       	push   $0x80106b58
80102cbb:	53                   	push   %ebx
80102cbc:	e8 66 11 00 00       	call   80103e27 <memcmp>
80102cc1:	83 c4 10             	add    $0x10,%esp
80102cc4:	85 c0                	test   %eax,%eax
80102cc6:	75 e2                	jne    80102caa <mpsearch1+0x11>
80102cc8:	ba 10 00 00 00       	mov    $0x10,%edx
80102ccd:	89 d8                	mov    %ebx,%eax
80102ccf:	e8 a1 ff ff ff       	call   80102c75 <sum>
80102cd4:	84 c0                	test   %al,%al
80102cd6:	75 d2                	jne    80102caa <mpsearch1+0x11>
80102cd8:	eb 05                	jmp    80102cdf <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102cda:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102cdf:	89 d8                	mov    %ebx,%eax
80102ce1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102ce4:	5b                   	pop    %ebx
80102ce5:	5e                   	pop    %esi
80102ce6:	5d                   	pop    %ebp
80102ce7:	c3                   	ret    

80102ce8 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102ce8:	55                   	push   %ebp
80102ce9:	89 e5                	mov    %esp,%ebp
80102ceb:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102cee:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102cf5:	c1 e0 08             	shl    $0x8,%eax
80102cf8:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102cff:	09 d0                	or     %edx,%eax
80102d01:	c1 e0 04             	shl    $0x4,%eax
80102d04:	85 c0                	test   %eax,%eax
80102d06:	74 1f                	je     80102d27 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102d08:	ba 00 04 00 00       	mov    $0x400,%edx
80102d0d:	e8 87 ff ff ff       	call   80102c99 <mpsearch1>
80102d12:	85 c0                	test   %eax,%eax
80102d14:	75 0f                	jne    80102d25 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d16:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d1b:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d20:	e8 74 ff ff ff       	call   80102c99 <mpsearch1>
}
80102d25:	c9                   	leave  
80102d26:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d27:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d2e:	c1 e0 08             	shl    $0x8,%eax
80102d31:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d38:	09 d0                	or     %edx,%eax
80102d3a:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d3d:	2d 00 04 00 00       	sub    $0x400,%eax
80102d42:	ba 00 04 00 00       	mov    $0x400,%edx
80102d47:	e8 4d ff ff ff       	call   80102c99 <mpsearch1>
80102d4c:	85 c0                	test   %eax,%eax
80102d4e:	75 d5                	jne    80102d25 <mpsearch+0x3d>
80102d50:	eb c4                	jmp    80102d16 <mpsearch+0x2e>

80102d52 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d52:	55                   	push   %ebp
80102d53:	89 e5                	mov    %esp,%ebp
80102d55:	57                   	push   %edi
80102d56:	56                   	push   %esi
80102d57:	53                   	push   %ebx
80102d58:	83 ec 1c             	sub    $0x1c,%esp
80102d5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d5e:	e8 85 ff ff ff       	call   80102ce8 <mpsearch>
80102d63:	85 c0                	test   %eax,%eax
80102d65:	74 5c                	je     80102dc3 <mpconfig+0x71>
80102d67:	89 c7                	mov    %eax,%edi
80102d69:	8b 58 04             	mov    0x4(%eax),%ebx
80102d6c:	85 db                	test   %ebx,%ebx
80102d6e:	74 5a                	je     80102dca <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d70:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d76:	83 ec 04             	sub    $0x4,%esp
80102d79:	6a 04                	push   $0x4
80102d7b:	68 5d 6b 10 80       	push   $0x80106b5d
80102d80:	56                   	push   %esi
80102d81:	e8 a1 10 00 00       	call   80103e27 <memcmp>
80102d86:	83 c4 10             	add    $0x10,%esp
80102d89:	85 c0                	test   %eax,%eax
80102d8b:	75 44                	jne    80102dd1 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d8d:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102d94:	3c 01                	cmp    $0x1,%al
80102d96:	0f 95 c2             	setne  %dl
80102d99:	3c 04                	cmp    $0x4,%al
80102d9b:	0f 95 c0             	setne  %al
80102d9e:	84 c2                	test   %al,%dl
80102da0:	75 36                	jne    80102dd8 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102da2:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102da9:	89 f0                	mov    %esi,%eax
80102dab:	e8 c5 fe ff ff       	call   80102c75 <sum>
80102db0:	84 c0                	test   %al,%al
80102db2:	75 2b                	jne    80102ddf <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102db7:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102db9:	89 f0                	mov    %esi,%eax
80102dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dbe:	5b                   	pop    %ebx
80102dbf:	5e                   	pop    %esi
80102dc0:	5f                   	pop    %edi
80102dc1:	5d                   	pop    %ebp
80102dc2:	c3                   	ret    
    return 0;
80102dc3:	be 00 00 00 00       	mov    $0x0,%esi
80102dc8:	eb ef                	jmp    80102db9 <mpconfig+0x67>
80102dca:	be 00 00 00 00       	mov    $0x0,%esi
80102dcf:	eb e8                	jmp    80102db9 <mpconfig+0x67>
    return 0;
80102dd1:	be 00 00 00 00       	mov    $0x0,%esi
80102dd6:	eb e1                	jmp    80102db9 <mpconfig+0x67>
    return 0;
80102dd8:	be 00 00 00 00       	mov    $0x0,%esi
80102ddd:	eb da                	jmp    80102db9 <mpconfig+0x67>
    return 0;
80102ddf:	be 00 00 00 00       	mov    $0x0,%esi
80102de4:	eb d3                	jmp    80102db9 <mpconfig+0x67>

80102de6 <mpinit>:

void
mpinit(void)
{
80102de6:	55                   	push   %ebp
80102de7:	89 e5                	mov    %esp,%ebp
80102de9:	57                   	push   %edi
80102dea:	56                   	push   %esi
80102deb:	53                   	push   %ebx
80102dec:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102def:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102df2:	e8 5b ff ff ff       	call   80102d52 <mpconfig>
80102df7:	85 c0                	test   %eax,%eax
80102df9:	74 19                	je     80102e14 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102dfb:	8b 50 24             	mov    0x24(%eax),%edx
80102dfe:	89 15 c0 26 14 80    	mov    %edx,0x801426c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e04:	8d 50 2c             	lea    0x2c(%eax),%edx
80102e07:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102e0b:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102e0d:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e12:	eb 34                	jmp    80102e48 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102e14:	83 ec 0c             	sub    $0xc,%esp
80102e17:	68 62 6b 10 80       	push   $0x80106b62
80102e1c:	e8 27 d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e21:	8b 35 60 2d 14 80    	mov    0x80142d60,%esi
80102e27:	83 fe 07             	cmp    $0x7,%esi
80102e2a:	7f 19                	jg     80102e45 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e2c:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e30:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e36:	88 87 e0 27 14 80    	mov    %al,-0x7febd820(%edi)
        ncpu++;
80102e3c:	83 c6 01             	add    $0x1,%esi
80102e3f:	89 35 60 2d 14 80    	mov    %esi,0x80142d60
      }
      p += sizeof(struct mpproc);
80102e45:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e48:	39 ca                	cmp    %ecx,%edx
80102e4a:	73 2b                	jae    80102e77 <mpinit+0x91>
    switch(*p){
80102e4c:	0f b6 02             	movzbl (%edx),%eax
80102e4f:	3c 04                	cmp    $0x4,%al
80102e51:	77 1d                	ja     80102e70 <mpinit+0x8a>
80102e53:	0f b6 c0             	movzbl %al,%eax
80102e56:	ff 24 85 9c 6b 10 80 	jmp    *-0x7fef9464(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e5d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e61:	a2 c0 27 14 80       	mov    %al,0x801427c0
      p += sizeof(struct mpioapic);
80102e66:	83 c2 08             	add    $0x8,%edx
      continue;
80102e69:	eb dd                	jmp    80102e48 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102e6b:	83 c2 08             	add    $0x8,%edx
      continue;
80102e6e:	eb d8                	jmp    80102e48 <mpinit+0x62>
    default:
      ismp = 0;
80102e70:	bb 00 00 00 00       	mov    $0x0,%ebx
80102e75:	eb d1                	jmp    80102e48 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102e77:	85 db                	test   %ebx,%ebx
80102e79:	74 26                	je     80102ea1 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e7e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e82:	74 15                	je     80102e99 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e84:	b8 70 00 00 00       	mov    $0x70,%eax
80102e89:	ba 22 00 00 00       	mov    $0x22,%edx
80102e8e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e8f:	ba 23 00 00 00       	mov    $0x23,%edx
80102e94:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e95:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e98:	ee                   	out    %al,(%dx)
  }
}
80102e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e9c:	5b                   	pop    %ebx
80102e9d:	5e                   	pop    %esi
80102e9e:	5f                   	pop    %edi
80102e9f:	5d                   	pop    %ebp
80102ea0:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102ea1:	83 ec 0c             	sub    $0xc,%esp
80102ea4:	68 7c 6b 10 80       	push   $0x80106b7c
80102ea9:	e8 9a d4 ff ff       	call   80100348 <panic>

80102eae <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
80102eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eb6:	ba 21 00 00 00       	mov    $0x21,%edx
80102ebb:	ee                   	out    %al,(%dx)
80102ebc:	ba a1 00 00 00       	mov    $0xa1,%edx
80102ec1:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102ec2:	5d                   	pop    %ebp
80102ec3:	c3                   	ret    

80102ec4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102ec4:	55                   	push   %ebp
80102ec5:	89 e5                	mov    %esp,%ebp
80102ec7:	57                   	push   %edi
80102ec8:	56                   	push   %esi
80102ec9:	53                   	push   %ebx
80102eca:	83 ec 0c             	sub    $0xc,%esp
80102ecd:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102ed0:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102ed3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102ed9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102edf:	e8 55 dd ff ff       	call   80100c39 <filealloc>
80102ee4:	89 03                	mov    %eax,(%ebx)
80102ee6:	85 c0                	test   %eax,%eax
80102ee8:	74 1e                	je     80102f08 <pipealloc+0x44>
80102eea:	e8 4a dd ff ff       	call   80100c39 <filealloc>
80102eef:	89 06                	mov    %eax,(%esi)
80102ef1:	85 c0                	test   %eax,%eax
80102ef3:	74 13                	je     80102f08 <pipealloc+0x44>
    goto bad;
  if((p = (struct pipe*)kalloc(-2)) == 0)
80102ef5:	83 ec 0c             	sub    $0xc,%esp
80102ef8:	6a fe                	push   $0xfffffffe
80102efa:	e8 4d f2 ff ff       	call   8010214c <kalloc>
80102eff:	89 c7                	mov    %eax,%edi
80102f01:	83 c4 10             	add    $0x10,%esp
80102f04:	85 c0                	test   %eax,%eax
80102f06:	75 35                	jne    80102f3d <pipealloc+0x79>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f08:	8b 03                	mov    (%ebx),%eax
80102f0a:	85 c0                	test   %eax,%eax
80102f0c:	74 0c                	je     80102f1a <pipealloc+0x56>
    fileclose(*f0);
80102f0e:	83 ec 0c             	sub    $0xc,%esp
80102f11:	50                   	push   %eax
80102f12:	e8 c8 dd ff ff       	call   80100cdf <fileclose>
80102f17:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f1a:	8b 06                	mov    (%esi),%eax
80102f1c:	85 c0                	test   %eax,%eax
80102f1e:	0f 84 8b 00 00 00    	je     80102faf <pipealloc+0xeb>
    fileclose(*f1);
80102f24:	83 ec 0c             	sub    $0xc,%esp
80102f27:	50                   	push   %eax
80102f28:	e8 b2 dd ff ff       	call   80100cdf <fileclose>
80102f2d:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f38:	5b                   	pop    %ebx
80102f39:	5e                   	pop    %esi
80102f3a:	5f                   	pop    %edi
80102f3b:	5d                   	pop    %ebp
80102f3c:	c3                   	ret    
  p->readopen = 1;
80102f3d:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f44:	00 00 00 
  p->writeopen = 1;
80102f47:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f4e:	00 00 00 
  p->nwrite = 0;
80102f51:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f58:	00 00 00 
  p->nread = 0;
80102f5b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f62:	00 00 00 
  initlock(&p->lock, "pipe");
80102f65:	83 ec 08             	sub    $0x8,%esp
80102f68:	68 b0 6b 10 80       	push   $0x80106bb0
80102f6d:	50                   	push   %eax
80102f6e:	e8 86 0c 00 00       	call   80103bf9 <initlock>
  (*f0)->type = FD_PIPE;
80102f73:	8b 03                	mov    (%ebx),%eax
80102f75:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102f7b:	8b 03                	mov    (%ebx),%eax
80102f7d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f81:	8b 03                	mov    (%ebx),%eax
80102f83:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102f87:	8b 03                	mov    (%ebx),%eax
80102f89:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102f8c:	8b 06                	mov    (%esi),%eax
80102f8e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102f94:	8b 06                	mov    (%esi),%eax
80102f96:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102f9a:	8b 06                	mov    (%esi),%eax
80102f9c:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102fa0:	8b 06                	mov    (%esi),%eax
80102fa2:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102fa5:	83 c4 10             	add    $0x10,%esp
80102fa8:	b8 00 00 00 00       	mov    $0x0,%eax
80102fad:	eb 86                	jmp    80102f35 <pipealloc+0x71>
  return -1;
80102faf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fb4:	e9 7c ff ff ff       	jmp    80102f35 <pipealloc+0x71>

80102fb9 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102fb9:	55                   	push   %ebp
80102fba:	89 e5                	mov    %esp,%ebp
80102fbc:	53                   	push   %ebx
80102fbd:	83 ec 10             	sub    $0x10,%esp
80102fc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102fc3:	53                   	push   %ebx
80102fc4:	e8 6c 0d 00 00       	call   80103d35 <acquire>
  if(writable){
80102fc9:	83 c4 10             	add    $0x10,%esp
80102fcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102fd0:	74 3f                	je     80103011 <pipeclose+0x58>
    p->writeopen = 0;
80102fd2:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102fd9:	00 00 00 
    wakeup(&p->nread);
80102fdc:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fe2:	83 ec 0c             	sub    $0xc,%esp
80102fe5:	50                   	push   %eax
80102fe6:	e8 b4 09 00 00       	call   8010399f <wakeup>
80102feb:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102fee:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102ff5:	75 09                	jne    80103000 <pipeclose+0x47>
80102ff7:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102ffe:	74 2f                	je     8010302f <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80103000:	83 ec 0c             	sub    $0xc,%esp
80103003:	53                   	push   %ebx
80103004:	e8 91 0d 00 00       	call   80103d9a <release>
80103009:	83 c4 10             	add    $0x10,%esp
}
8010300c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010300f:	c9                   	leave  
80103010:	c3                   	ret    
    p->readopen = 0;
80103011:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103018:	00 00 00 
    wakeup(&p->nwrite);
8010301b:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103021:	83 ec 0c             	sub    $0xc,%esp
80103024:	50                   	push   %eax
80103025:	e8 75 09 00 00       	call   8010399f <wakeup>
8010302a:	83 c4 10             	add    $0x10,%esp
8010302d:	eb bf                	jmp    80102fee <pipeclose+0x35>
    release(&p->lock);
8010302f:	83 ec 0c             	sub    $0xc,%esp
80103032:	53                   	push   %ebx
80103033:	e8 62 0d 00 00       	call   80103d9a <release>
    kfree((char*)p);
80103038:	89 1c 24             	mov    %ebx,(%esp)
8010303b:	e8 c5 ef ff ff       	call   80102005 <kfree>
80103040:	83 c4 10             	add    $0x10,%esp
80103043:	eb c7                	jmp    8010300c <pipeclose+0x53>

80103045 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103045:	55                   	push   %ebp
80103046:	89 e5                	mov    %esp,%ebp
80103048:	57                   	push   %edi
80103049:	56                   	push   %esi
8010304a:	53                   	push   %ebx
8010304b:	83 ec 18             	sub    $0x18,%esp
8010304e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103051:	89 de                	mov    %ebx,%esi
80103053:	53                   	push   %ebx
80103054:	e8 dc 0c 00 00       	call   80103d35 <acquire>
  for(i = 0; i < n; i++){
80103059:	83 c4 10             	add    $0x10,%esp
8010305c:	bf 00 00 00 00       	mov    $0x0,%edi
80103061:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103064:	0f 8d 88 00 00 00    	jge    801030f2 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010306a:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103070:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103076:	05 00 02 00 00       	add    $0x200,%eax
8010307b:	39 c2                	cmp    %eax,%edx
8010307d:	75 51                	jne    801030d0 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
8010307f:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103086:	74 2f                	je     801030b7 <pipewrite+0x72>
80103088:	e8 06 03 00 00       	call   80103393 <myproc>
8010308d:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103091:	75 24                	jne    801030b7 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103093:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103099:	83 ec 0c             	sub    $0xc,%esp
8010309c:	50                   	push   %eax
8010309d:	e8 fd 08 00 00       	call   8010399f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801030a2:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030a8:	83 c4 08             	add    $0x8,%esp
801030ab:	56                   	push   %esi
801030ac:	50                   	push   %eax
801030ad:	e8 88 07 00 00       	call   8010383a <sleep>
801030b2:	83 c4 10             	add    $0x10,%esp
801030b5:	eb b3                	jmp    8010306a <pipewrite+0x25>
        release(&p->lock);
801030b7:	83 ec 0c             	sub    $0xc,%esp
801030ba:	53                   	push   %ebx
801030bb:	e8 da 0c 00 00       	call   80103d9a <release>
        return -1;
801030c0:	83 c4 10             	add    $0x10,%esp
801030c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801030c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030cb:	5b                   	pop    %ebx
801030cc:	5e                   	pop    %esi
801030cd:	5f                   	pop    %edi
801030ce:	5d                   	pop    %ebp
801030cf:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801030d0:	8d 42 01             	lea    0x1(%edx),%eax
801030d3:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801030d9:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801030df:	8b 45 0c             	mov    0xc(%ebp),%eax
801030e2:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801030e6:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801030ea:	83 c7 01             	add    $0x1,%edi
801030ed:	e9 6f ff ff ff       	jmp    80103061 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801030f2:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030f8:	83 ec 0c             	sub    $0xc,%esp
801030fb:	50                   	push   %eax
801030fc:	e8 9e 08 00 00       	call   8010399f <wakeup>
  release(&p->lock);
80103101:	89 1c 24             	mov    %ebx,(%esp)
80103104:	e8 91 0c 00 00       	call   80103d9a <release>
  return n;
80103109:	83 c4 10             	add    $0x10,%esp
8010310c:	8b 45 10             	mov    0x10(%ebp),%eax
8010310f:	eb b7                	jmp    801030c8 <pipewrite+0x83>

80103111 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103111:	55                   	push   %ebp
80103112:	89 e5                	mov    %esp,%ebp
80103114:	57                   	push   %edi
80103115:	56                   	push   %esi
80103116:	53                   	push   %ebx
80103117:	83 ec 18             	sub    $0x18,%esp
8010311a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010311d:	89 df                	mov    %ebx,%edi
8010311f:	53                   	push   %ebx
80103120:	e8 10 0c 00 00       	call   80103d35 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103125:	83 c4 10             	add    $0x10,%esp
80103128:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
8010312e:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103134:	75 3d                	jne    80103173 <piperead+0x62>
80103136:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
8010313c:	85 f6                	test   %esi,%esi
8010313e:	74 38                	je     80103178 <piperead+0x67>
    if(myproc()->killed){
80103140:	e8 4e 02 00 00       	call   80103393 <myproc>
80103145:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103149:	75 15                	jne    80103160 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010314b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103151:	83 ec 08             	sub    $0x8,%esp
80103154:	57                   	push   %edi
80103155:	50                   	push   %eax
80103156:	e8 df 06 00 00       	call   8010383a <sleep>
8010315b:	83 c4 10             	add    $0x10,%esp
8010315e:	eb c8                	jmp    80103128 <piperead+0x17>
      release(&p->lock);
80103160:	83 ec 0c             	sub    $0xc,%esp
80103163:	53                   	push   %ebx
80103164:	e8 31 0c 00 00       	call   80103d9a <release>
      return -1;
80103169:	83 c4 10             	add    $0x10,%esp
8010316c:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103171:	eb 50                	jmp    801031c3 <piperead+0xb2>
80103173:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103178:	3b 75 10             	cmp    0x10(%ebp),%esi
8010317b:	7d 2c                	jge    801031a9 <piperead+0x98>
    if(p->nread == p->nwrite)
8010317d:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103183:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103189:	74 1e                	je     801031a9 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010318b:	8d 50 01             	lea    0x1(%eax),%edx
8010318e:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103194:	25 ff 01 00 00       	and    $0x1ff,%eax
80103199:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010319e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801031a1:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031a4:	83 c6 01             	add    $0x1,%esi
801031a7:	eb cf                	jmp    80103178 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031a9:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031af:	83 ec 0c             	sub    $0xc,%esp
801031b2:	50                   	push   %eax
801031b3:	e8 e7 07 00 00       	call   8010399f <wakeup>
  release(&p->lock);
801031b8:	89 1c 24             	mov    %ebx,(%esp)
801031bb:	e8 da 0b 00 00       	call   80103d9a <release>
  return i;
801031c0:	83 c4 10             	add    $0x10,%esp
}
801031c3:	89 f0                	mov    %esi,%eax
801031c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031c8:	5b                   	pop    %ebx
801031c9:	5e                   	pop    %esi
801031ca:	5f                   	pop    %edi
801031cb:	5d                   	pop    %ebp
801031cc:	c3                   	ret    

801031cd <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801031cd:	55                   	push   %ebp
801031ce:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031d0:	ba b4 2d 14 80       	mov    $0x80142db4,%edx
801031d5:	eb 03                	jmp    801031da <wakeup1+0xd>
801031d7:	83 c2 7c             	add    $0x7c,%edx
801031da:	81 fa b4 4c 14 80    	cmp    $0x80144cb4,%edx
801031e0:	73 14                	jae    801031f6 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801031e2:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801031e6:	75 ef                	jne    801031d7 <wakeup1+0xa>
801031e8:	39 42 20             	cmp    %eax,0x20(%edx)
801031eb:	75 ea                	jne    801031d7 <wakeup1+0xa>
      p->state = RUNNABLE;
801031ed:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801031f4:	eb e1                	jmp    801031d7 <wakeup1+0xa>
}
801031f6:	5d                   	pop    %ebp
801031f7:	c3                   	ret    

801031f8 <allocproc>:
{
801031f8:	55                   	push   %ebp
801031f9:	89 e5                	mov    %esp,%ebp
801031fb:	53                   	push   %ebx
801031fc:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801031ff:	68 80 2d 14 80       	push   $0x80142d80
80103204:	e8 2c 0b 00 00       	call   80103d35 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103209:	83 c4 10             	add    $0x10,%esp
8010320c:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
80103211:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
80103217:	73 0b                	jae    80103224 <allocproc+0x2c>
    if(p->state == UNUSED)
80103219:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010321d:	74 1c                	je     8010323b <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010321f:	83 c3 7c             	add    $0x7c,%ebx
80103222:	eb ed                	jmp    80103211 <allocproc+0x19>
  release(&ptable.lock);
80103224:	83 ec 0c             	sub    $0xc,%esp
80103227:	68 80 2d 14 80       	push   $0x80142d80
8010322c:	e8 69 0b 00 00       	call   80103d9a <release>
  return 0;
80103231:	83 c4 10             	add    $0x10,%esp
80103234:	bb 00 00 00 00       	mov    $0x0,%ebx
80103239:	eb 6f                	jmp    801032aa <allocproc+0xb2>
  p->state = EMBRYO;
8010323b:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103242:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103247:	8d 50 01             	lea    0x1(%eax),%edx
8010324a:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103250:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103253:	83 ec 0c             	sub    $0xc,%esp
80103256:	68 80 2d 14 80       	push   $0x80142d80
8010325b:	e8 3a 0b 00 00       	call   80103d9a <release>
  if((p->kstack = kalloc(p->pid)) == 0){
80103260:	83 c4 04             	add    $0x4,%esp
80103263:	ff 73 10             	pushl  0x10(%ebx)
80103266:	e8 e1 ee ff ff       	call   8010214c <kalloc>
8010326b:	89 43 08             	mov    %eax,0x8(%ebx)
8010326e:	83 c4 10             	add    $0x10,%esp
80103271:	85 c0                	test   %eax,%eax
80103273:	74 3c                	je     801032b1 <allocproc+0xb9>
  sp -= sizeof *p->tf;
80103275:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010327b:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010327e:	c7 80 b0 0f 00 00 f7 	movl   $0x80104ef7,0xfb0(%eax)
80103285:	4e 10 80 
  sp -= sizeof *p->context;
80103288:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010328d:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103290:	83 ec 04             	sub    $0x4,%esp
80103293:	6a 14                	push   $0x14
80103295:	6a 00                	push   $0x0
80103297:	50                   	push   %eax
80103298:	e8 44 0b 00 00       	call   80103de1 <memset>
  p->context->eip = (uint)forkret;
8010329d:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032a0:	c7 40 10 bf 32 10 80 	movl   $0x801032bf,0x10(%eax)
  return p;
801032a7:	83 c4 10             	add    $0x10,%esp
}
801032aa:	89 d8                	mov    %ebx,%eax
801032ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032af:	c9                   	leave  
801032b0:	c3                   	ret    
    p->state = UNUSED;
801032b1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801032b8:	bb 00 00 00 00       	mov    $0x0,%ebx
801032bd:	eb eb                	jmp    801032aa <allocproc+0xb2>

801032bf <forkret>:
{
801032bf:	55                   	push   %ebp
801032c0:	89 e5                	mov    %esp,%ebp
801032c2:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801032c5:	68 80 2d 14 80       	push   $0x80142d80
801032ca:	e8 cb 0a 00 00       	call   80103d9a <release>
  if (first) {
801032cf:	83 c4 10             	add    $0x10,%esp
801032d2:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801032d9:	75 02                	jne    801032dd <forkret+0x1e>
}
801032db:	c9                   	leave  
801032dc:	c3                   	ret    
    first = 0;
801032dd:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801032e4:	00 00 00 
    iinit(ROOTDEV);
801032e7:	83 ec 0c             	sub    $0xc,%esp
801032ea:	6a 01                	push   $0x1
801032ec:	e8 07 e0 ff ff       	call   801012f8 <iinit>
    initlog(ROOTDEV);
801032f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032f8:	e8 f2 f5 ff ff       	call   801028ef <initlog>
801032fd:	83 c4 10             	add    $0x10,%esp
}
80103300:	eb d9                	jmp    801032db <forkret+0x1c>

80103302 <pinit>:
{
80103302:	55                   	push   %ebp
80103303:	89 e5                	mov    %esp,%ebp
80103305:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103308:	68 b5 6b 10 80       	push   $0x80106bb5
8010330d:	68 80 2d 14 80       	push   $0x80142d80
80103312:	e8 e2 08 00 00       	call   80103bf9 <initlock>
}
80103317:	83 c4 10             	add    $0x10,%esp
8010331a:	c9                   	leave  
8010331b:	c3                   	ret    

8010331c <mycpu>:
{
8010331c:	55                   	push   %ebp
8010331d:	89 e5                	mov    %esp,%ebp
8010331f:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103322:	9c                   	pushf  
80103323:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103324:	f6 c4 02             	test   $0x2,%ah
80103327:	75 28                	jne    80103351 <mycpu+0x35>
  apicid = lapicid();
80103329:	e8 da f1 ff ff       	call   80102508 <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010332e:	ba 00 00 00 00       	mov    $0x0,%edx
80103333:	39 15 60 2d 14 80    	cmp    %edx,0x80142d60
80103339:	7e 23                	jle    8010335e <mycpu+0x42>
    if (cpus[i].apicid == apicid)
8010333b:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103341:	0f b6 89 e0 27 14 80 	movzbl -0x7febd820(%ecx),%ecx
80103348:	39 c1                	cmp    %eax,%ecx
8010334a:	74 1f                	je     8010336b <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010334c:	83 c2 01             	add    $0x1,%edx
8010334f:	eb e2                	jmp    80103333 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103351:	83 ec 0c             	sub    $0xc,%esp
80103354:	68 98 6c 10 80       	push   $0x80106c98
80103359:	e8 ea cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010335e:	83 ec 0c             	sub    $0xc,%esp
80103361:	68 bc 6b 10 80       	push   $0x80106bbc
80103366:	e8 dd cf ff ff       	call   80100348 <panic>
      return &cpus[i];
8010336b:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103371:	05 e0 27 14 80       	add    $0x801427e0,%eax
}
80103376:	c9                   	leave  
80103377:	c3                   	ret    

80103378 <cpuid>:
cpuid() {
80103378:	55                   	push   %ebp
80103379:	89 e5                	mov    %esp,%ebp
8010337b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010337e:	e8 99 ff ff ff       	call   8010331c <mycpu>
80103383:	2d e0 27 14 80       	sub    $0x801427e0,%eax
80103388:	c1 f8 04             	sar    $0x4,%eax
8010338b:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103391:	c9                   	leave  
80103392:	c3                   	ret    

80103393 <myproc>:
myproc(void) {
80103393:	55                   	push   %ebp
80103394:	89 e5                	mov    %esp,%ebp
80103396:	53                   	push   %ebx
80103397:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010339a:	e8 b9 08 00 00       	call   80103c58 <pushcli>
  c = mycpu();
8010339f:	e8 78 ff ff ff       	call   8010331c <mycpu>
  p = c->proc;
801033a4:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801033aa:	e8 e6 08 00 00       	call   80103c95 <popcli>
}
801033af:	89 d8                	mov    %ebx,%eax
801033b1:	83 c4 04             	add    $0x4,%esp
801033b4:	5b                   	pop    %ebx
801033b5:	5d                   	pop    %ebp
801033b6:	c3                   	ret    

801033b7 <userinit>:
{
801033b7:	55                   	push   %ebp
801033b8:	89 e5                	mov    %esp,%ebp
801033ba:	53                   	push   %ebx
801033bb:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801033be:	e8 35 fe ff ff       	call   801031f8 <allocproc>
801033c3:	89 c3                	mov    %eax,%ebx
  initproc = p;
801033c5:	a3 e4 a5 11 80       	mov    %eax,0x8011a5e4
  if((p->pgdir = setupkvm()) == 0)
801033ca:	e8 22 30 00 00       	call   801063f1 <setupkvm>
801033cf:	89 43 04             	mov    %eax,0x4(%ebx)
801033d2:	85 c0                	test   %eax,%eax
801033d4:	0f 84 b7 00 00 00    	je     80103491 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801033da:	83 ec 04             	sub    $0x4,%esp
801033dd:	68 2c 00 00 00       	push   $0x2c
801033e2:	68 60 a4 10 80       	push   $0x8010a460
801033e7:	50                   	push   %eax
801033e8:	e8 01 2d 00 00       	call   801060ee <inituvm>
  p->sz = PGSIZE;
801033ed:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033f3:	83 c4 0c             	add    $0xc,%esp
801033f6:	6a 4c                	push   $0x4c
801033f8:	6a 00                	push   $0x0
801033fa:	ff 73 18             	pushl  0x18(%ebx)
801033fd:	e8 df 09 00 00       	call   80103de1 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103402:	8b 43 18             	mov    0x18(%ebx),%eax
80103405:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010340b:	8b 43 18             	mov    0x18(%ebx),%eax
8010340e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103414:	8b 43 18             	mov    0x18(%ebx),%eax
80103417:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010341b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010341f:	8b 43 18             	mov    0x18(%ebx),%eax
80103422:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103426:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010342a:	8b 43 18             	mov    0x18(%ebx),%eax
8010342d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103434:	8b 43 18             	mov    0x18(%ebx),%eax
80103437:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010343e:	8b 43 18             	mov    0x18(%ebx),%eax
80103441:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103448:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010344b:	83 c4 0c             	add    $0xc,%esp
8010344e:	6a 10                	push   $0x10
80103450:	68 e5 6b 10 80       	push   $0x80106be5
80103455:	50                   	push   %eax
80103456:	e8 ed 0a 00 00       	call   80103f48 <safestrcpy>
  p->cwd = namei("/");
8010345b:	c7 04 24 ee 6b 10 80 	movl   $0x80106bee,(%esp)
80103462:	e8 86 e7 ff ff       	call   80101bed <namei>
80103467:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010346a:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103471:	e8 bf 08 00 00       	call   80103d35 <acquire>
  p->state = RUNNABLE;
80103476:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010347d:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103484:	e8 11 09 00 00       	call   80103d9a <release>
}
80103489:	83 c4 10             	add    $0x10,%esp
8010348c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010348f:	c9                   	leave  
80103490:	c3                   	ret    
    panic("userinit: out of memory?");
80103491:	83 ec 0c             	sub    $0xc,%esp
80103494:	68 cc 6b 10 80       	push   $0x80106bcc
80103499:	e8 aa ce ff ff       	call   80100348 <panic>

8010349e <growproc>:
{
8010349e:	55                   	push   %ebp
8010349f:	89 e5                	mov    %esp,%ebp
801034a1:	56                   	push   %esi
801034a2:	53                   	push   %ebx
801034a3:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801034a6:	e8 e8 fe ff ff       	call   80103393 <myproc>
801034ab:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801034ad:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801034af:	85 f6                	test   %esi,%esi
801034b1:	7f 21                	jg     801034d4 <growproc+0x36>
  } else if(n < 0){
801034b3:	85 f6                	test   %esi,%esi
801034b5:	79 33                	jns    801034ea <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034b7:	83 ec 04             	sub    $0x4,%esp
801034ba:	01 c6                	add    %eax,%esi
801034bc:	56                   	push   %esi
801034bd:	50                   	push   %eax
801034be:	ff 73 04             	pushl  0x4(%ebx)
801034c1:	e8 36 2d 00 00       	call   801061fc <deallocuvm>
801034c6:	83 c4 10             	add    $0x10,%esp
801034c9:	85 c0                	test   %eax,%eax
801034cb:	75 1d                	jne    801034ea <growproc+0x4c>
      return -1;
801034cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034d2:	eb 29                	jmp    801034fd <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n, curproc->pid)) == 0)
801034d4:	ff 73 10             	pushl  0x10(%ebx)
801034d7:	01 c6                	add    %eax,%esi
801034d9:	56                   	push   %esi
801034da:	50                   	push   %eax
801034db:	ff 73 04             	pushl  0x4(%ebx)
801034de:	e8 ab 2d 00 00       	call   8010628e <allocuvm>
801034e3:	83 c4 10             	add    $0x10,%esp
801034e6:	85 c0                	test   %eax,%eax
801034e8:	74 1a                	je     80103504 <growproc+0x66>
  curproc->sz = sz;
801034ea:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801034ec:	83 ec 0c             	sub    $0xc,%esp
801034ef:	53                   	push   %ebx
801034f0:	e8 e1 2a 00 00       	call   80105fd6 <switchuvm>
  return 0;
801034f5:	83 c4 10             	add    $0x10,%esp
801034f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801034fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103500:	5b                   	pop    %ebx
80103501:	5e                   	pop    %esi
80103502:	5d                   	pop    %ebp
80103503:	c3                   	ret    
      return -1;
80103504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103509:	eb f2                	jmp    801034fd <growproc+0x5f>

8010350b <fork>:
{
8010350b:	55                   	push   %ebp
8010350c:	89 e5                	mov    %esp,%ebp
8010350e:	57                   	push   %edi
8010350f:	56                   	push   %esi
80103510:	53                   	push   %ebx
80103511:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103514:	e8 7a fe ff ff       	call   80103393 <myproc>
80103519:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
8010351b:	e8 d8 fc ff ff       	call   801031f8 <allocproc>
80103520:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103523:	85 c0                	test   %eax,%eax
80103525:	0f 84 e3 00 00 00    	je     8010360e <fork+0x103>
8010352b:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, np->pid)) == 0){
8010352d:	83 ec 04             	sub    $0x4,%esp
80103530:	ff 70 10             	pushl  0x10(%eax)
80103533:	ff 33                	pushl  (%ebx)
80103535:	ff 73 04             	pushl  0x4(%ebx)
80103538:	e8 6d 2f 00 00       	call   801064aa <copyuvm>
8010353d:	89 47 04             	mov    %eax,0x4(%edi)
80103540:	83 c4 10             	add    $0x10,%esp
80103543:	85 c0                	test   %eax,%eax
80103545:	74 2a                	je     80103571 <fork+0x66>
  np->sz = curproc->sz;
80103547:	8b 03                	mov    (%ebx),%eax
80103549:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010354c:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010354e:	89 c8                	mov    %ecx,%eax
80103550:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103553:	8b 73 18             	mov    0x18(%ebx),%esi
80103556:	8b 79 18             	mov    0x18(%ecx),%edi
80103559:	b9 13 00 00 00       	mov    $0x13,%ecx
8010355e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103560:	8b 40 18             	mov    0x18(%eax),%eax
80103563:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010356a:	be 00 00 00 00       	mov    $0x0,%esi
8010356f:	eb 29                	jmp    8010359a <fork+0x8f>
    kfree(np->kstack);
80103571:	83 ec 0c             	sub    $0xc,%esp
80103574:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103577:	ff 73 08             	pushl  0x8(%ebx)
8010357a:	e8 86 ea ff ff       	call   80102005 <kfree>
    np->kstack = 0;
8010357f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103586:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010358d:	83 c4 10             	add    $0x10,%esp
80103590:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103595:	eb 6d                	jmp    80103604 <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
80103597:	83 c6 01             	add    $0x1,%esi
8010359a:	83 fe 0f             	cmp    $0xf,%esi
8010359d:	7f 1d                	jg     801035bc <fork+0xb1>
    if(curproc->ofile[i])
8010359f:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801035a3:	85 c0                	test   %eax,%eax
801035a5:	74 f0                	je     80103597 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801035a7:	83 ec 0c             	sub    $0xc,%esp
801035aa:	50                   	push   %eax
801035ab:	e8 ea d6 ff ff       	call   80100c9a <filedup>
801035b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035b3:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801035b7:	83 c4 10             	add    $0x10,%esp
801035ba:	eb db                	jmp    80103597 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
801035bc:	83 ec 0c             	sub    $0xc,%esp
801035bf:	ff 73 68             	pushl  0x68(%ebx)
801035c2:	e8 96 df ff ff       	call   8010155d <idup>
801035c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801035ca:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801035cd:	83 c3 6c             	add    $0x6c,%ebx
801035d0:	8d 47 6c             	lea    0x6c(%edi),%eax
801035d3:	83 c4 0c             	add    $0xc,%esp
801035d6:	6a 10                	push   $0x10
801035d8:	53                   	push   %ebx
801035d9:	50                   	push   %eax
801035da:	e8 69 09 00 00       	call   80103f48 <safestrcpy>
  pid = np->pid;
801035df:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801035e2:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
801035e9:	e8 47 07 00 00       	call   80103d35 <acquire>
  np->state = RUNNABLE;
801035ee:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801035f5:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
801035fc:	e8 99 07 00 00       	call   80103d9a <release>
  return pid;
80103601:	83 c4 10             	add    $0x10,%esp
}
80103604:	89 d8                	mov    %ebx,%eax
80103606:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103609:	5b                   	pop    %ebx
8010360a:	5e                   	pop    %esi
8010360b:	5f                   	pop    %edi
8010360c:	5d                   	pop    %ebp
8010360d:	c3                   	ret    
    return -1;
8010360e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103613:	eb ef                	jmp    80103604 <fork+0xf9>

80103615 <scheduler>:
{
80103615:	55                   	push   %ebp
80103616:	89 e5                	mov    %esp,%ebp
80103618:	56                   	push   %esi
80103619:	53                   	push   %ebx
  struct cpu *c = mycpu();
8010361a:	e8 fd fc ff ff       	call   8010331c <mycpu>
8010361f:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103621:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103628:	00 00 00 
8010362b:	eb 5a                	jmp    80103687 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010362d:	83 c3 7c             	add    $0x7c,%ebx
80103630:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
80103636:	73 3f                	jae    80103677 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103638:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010363c:	75 ef                	jne    8010362d <scheduler+0x18>
      c->proc = p;
8010363e:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103644:	83 ec 0c             	sub    $0xc,%esp
80103647:	53                   	push   %ebx
80103648:	e8 89 29 00 00       	call   80105fd6 <switchuvm>
      p->state = RUNNING;
8010364d:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103654:	83 c4 08             	add    $0x8,%esp
80103657:	ff 73 1c             	pushl  0x1c(%ebx)
8010365a:	8d 46 04             	lea    0x4(%esi),%eax
8010365d:	50                   	push   %eax
8010365e:	e8 38 09 00 00       	call   80103f9b <swtch>
      switchkvm();
80103663:	e8 5c 29 00 00       	call   80105fc4 <switchkvm>
      c->proc = 0;
80103668:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010366f:	00 00 00 
80103672:	83 c4 10             	add    $0x10,%esp
80103675:	eb b6                	jmp    8010362d <scheduler+0x18>
    release(&ptable.lock);
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	68 80 2d 14 80       	push   $0x80142d80
8010367f:	e8 16 07 00 00       	call   80103d9a <release>
    sti();
80103684:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103687:	fb                   	sti    
    acquire(&ptable.lock);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	68 80 2d 14 80       	push   $0x80142d80
80103690:	e8 a0 06 00 00       	call   80103d35 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103695:	83 c4 10             	add    $0x10,%esp
80103698:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
8010369d:	eb 91                	jmp    80103630 <scheduler+0x1b>

8010369f <sched>:
{
8010369f:	55                   	push   %ebp
801036a0:	89 e5                	mov    %esp,%ebp
801036a2:	56                   	push   %esi
801036a3:	53                   	push   %ebx
  struct proc *p = myproc();
801036a4:	e8 ea fc ff ff       	call   80103393 <myproc>
801036a9:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801036ab:	83 ec 0c             	sub    $0xc,%esp
801036ae:	68 80 2d 14 80       	push   $0x80142d80
801036b3:	e8 3d 06 00 00       	call   80103cf5 <holding>
801036b8:	83 c4 10             	add    $0x10,%esp
801036bb:	85 c0                	test   %eax,%eax
801036bd:	74 4f                	je     8010370e <sched+0x6f>
  if(mycpu()->ncli != 1)
801036bf:	e8 58 fc ff ff       	call   8010331c <mycpu>
801036c4:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801036cb:	75 4e                	jne    8010371b <sched+0x7c>
  if(p->state == RUNNING)
801036cd:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801036d1:	74 55                	je     80103728 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801036d3:	9c                   	pushf  
801036d4:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801036d5:	f6 c4 02             	test   $0x2,%ah
801036d8:	75 5b                	jne    80103735 <sched+0x96>
  intena = mycpu()->intena;
801036da:	e8 3d fc ff ff       	call   8010331c <mycpu>
801036df:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801036e5:	e8 32 fc ff ff       	call   8010331c <mycpu>
801036ea:	83 ec 08             	sub    $0x8,%esp
801036ed:	ff 70 04             	pushl  0x4(%eax)
801036f0:	83 c3 1c             	add    $0x1c,%ebx
801036f3:	53                   	push   %ebx
801036f4:	e8 a2 08 00 00       	call   80103f9b <swtch>
  mycpu()->intena = intena;
801036f9:	e8 1e fc ff ff       	call   8010331c <mycpu>
801036fe:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103704:	83 c4 10             	add    $0x10,%esp
80103707:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010370a:	5b                   	pop    %ebx
8010370b:	5e                   	pop    %esi
8010370c:	5d                   	pop    %ebp
8010370d:	c3                   	ret    
    panic("sched ptable.lock");
8010370e:	83 ec 0c             	sub    $0xc,%esp
80103711:	68 f0 6b 10 80       	push   $0x80106bf0
80103716:	e8 2d cc ff ff       	call   80100348 <panic>
    panic("sched locks");
8010371b:	83 ec 0c             	sub    $0xc,%esp
8010371e:	68 02 6c 10 80       	push   $0x80106c02
80103723:	e8 20 cc ff ff       	call   80100348 <panic>
    panic("sched running");
80103728:	83 ec 0c             	sub    $0xc,%esp
8010372b:	68 0e 6c 10 80       	push   $0x80106c0e
80103730:	e8 13 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103735:	83 ec 0c             	sub    $0xc,%esp
80103738:	68 1c 6c 10 80       	push   $0x80106c1c
8010373d:	e8 06 cc ff ff       	call   80100348 <panic>

80103742 <exit>:
{
80103742:	55                   	push   %ebp
80103743:	89 e5                	mov    %esp,%ebp
80103745:	56                   	push   %esi
80103746:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103747:	e8 47 fc ff ff       	call   80103393 <myproc>
  if(curproc == initproc)
8010374c:	39 05 e4 a5 11 80    	cmp    %eax,0x8011a5e4
80103752:	74 09                	je     8010375d <exit+0x1b>
80103754:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103756:	bb 00 00 00 00       	mov    $0x0,%ebx
8010375b:	eb 10                	jmp    8010376d <exit+0x2b>
    panic("init exiting");
8010375d:	83 ec 0c             	sub    $0xc,%esp
80103760:	68 30 6c 10 80       	push   $0x80106c30
80103765:	e8 de cb ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010376a:	83 c3 01             	add    $0x1,%ebx
8010376d:	83 fb 0f             	cmp    $0xf,%ebx
80103770:	7f 1e                	jg     80103790 <exit+0x4e>
    if(curproc->ofile[fd]){
80103772:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103776:	85 c0                	test   %eax,%eax
80103778:	74 f0                	je     8010376a <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010377a:	83 ec 0c             	sub    $0xc,%esp
8010377d:	50                   	push   %eax
8010377e:	e8 5c d5 ff ff       	call   80100cdf <fileclose>
      curproc->ofile[fd] = 0;
80103783:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010378a:	00 
8010378b:	83 c4 10             	add    $0x10,%esp
8010378e:	eb da                	jmp    8010376a <exit+0x28>
  begin_op();
80103790:	e8 a3 f1 ff ff       	call   80102938 <begin_op>
  iput(curproc->cwd);
80103795:	83 ec 0c             	sub    $0xc,%esp
80103798:	ff 76 68             	pushl  0x68(%esi)
8010379b:	e8 f4 de ff ff       	call   80101694 <iput>
  end_op();
801037a0:	e8 0d f2 ff ff       	call   801029b2 <end_op>
  curproc->cwd = 0;
801037a5:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801037ac:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
801037b3:	e8 7d 05 00 00       	call   80103d35 <acquire>
  wakeup1(curproc->parent);
801037b8:	8b 46 14             	mov    0x14(%esi),%eax
801037bb:	e8 0d fa ff ff       	call   801031cd <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037c0:	83 c4 10             	add    $0x10,%esp
801037c3:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
801037c8:	eb 03                	jmp    801037cd <exit+0x8b>
801037ca:	83 c3 7c             	add    $0x7c,%ebx
801037cd:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
801037d3:	73 1a                	jae    801037ef <exit+0xad>
    if(p->parent == curproc){
801037d5:	39 73 14             	cmp    %esi,0x14(%ebx)
801037d8:	75 f0                	jne    801037ca <exit+0x88>
      p->parent = initproc;
801037da:	a1 e4 a5 11 80       	mov    0x8011a5e4,%eax
801037df:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801037e2:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037e6:	75 e2                	jne    801037ca <exit+0x88>
        wakeup1(initproc);
801037e8:	e8 e0 f9 ff ff       	call   801031cd <wakeup1>
801037ed:	eb db                	jmp    801037ca <exit+0x88>
  curproc->state = ZOMBIE;
801037ef:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801037f6:	e8 a4 fe ff ff       	call   8010369f <sched>
  panic("zombie exit");
801037fb:	83 ec 0c             	sub    $0xc,%esp
801037fe:	68 3d 6c 10 80       	push   $0x80106c3d
80103803:	e8 40 cb ff ff       	call   80100348 <panic>

80103808 <yield>:
{
80103808:	55                   	push   %ebp
80103809:	89 e5                	mov    %esp,%ebp
8010380b:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010380e:	68 80 2d 14 80       	push   $0x80142d80
80103813:	e8 1d 05 00 00       	call   80103d35 <acquire>
  myproc()->state = RUNNABLE;
80103818:	e8 76 fb ff ff       	call   80103393 <myproc>
8010381d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103824:	e8 76 fe ff ff       	call   8010369f <sched>
  release(&ptable.lock);
80103829:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
80103830:	e8 65 05 00 00       	call   80103d9a <release>
}
80103835:	83 c4 10             	add    $0x10,%esp
80103838:	c9                   	leave  
80103839:	c3                   	ret    

8010383a <sleep>:
{
8010383a:	55                   	push   %ebp
8010383b:	89 e5                	mov    %esp,%ebp
8010383d:	56                   	push   %esi
8010383e:	53                   	push   %ebx
8010383f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103842:	e8 4c fb ff ff       	call   80103393 <myproc>
  if(p == 0)
80103847:	85 c0                	test   %eax,%eax
80103849:	74 66                	je     801038b1 <sleep+0x77>
8010384b:	89 c6                	mov    %eax,%esi
  if(lk == 0)
8010384d:	85 db                	test   %ebx,%ebx
8010384f:	74 6d                	je     801038be <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103851:	81 fb 80 2d 14 80    	cmp    $0x80142d80,%ebx
80103857:	74 18                	je     80103871 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103859:	83 ec 0c             	sub    $0xc,%esp
8010385c:	68 80 2d 14 80       	push   $0x80142d80
80103861:	e8 cf 04 00 00       	call   80103d35 <acquire>
    release(lk);
80103866:	89 1c 24             	mov    %ebx,(%esp)
80103869:	e8 2c 05 00 00       	call   80103d9a <release>
8010386e:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103871:	8b 45 08             	mov    0x8(%ebp),%eax
80103874:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103877:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010387e:	e8 1c fe ff ff       	call   8010369f <sched>
  p->chan = 0;
80103883:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010388a:	81 fb 80 2d 14 80    	cmp    $0x80142d80,%ebx
80103890:	74 18                	je     801038aa <sleep+0x70>
    release(&ptable.lock);
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	68 80 2d 14 80       	push   $0x80142d80
8010389a:	e8 fb 04 00 00       	call   80103d9a <release>
    acquire(lk);
8010389f:	89 1c 24             	mov    %ebx,(%esp)
801038a2:	e8 8e 04 00 00       	call   80103d35 <acquire>
801038a7:	83 c4 10             	add    $0x10,%esp
}
801038aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038ad:	5b                   	pop    %ebx
801038ae:	5e                   	pop    %esi
801038af:	5d                   	pop    %ebp
801038b0:	c3                   	ret    
    panic("sleep");
801038b1:	83 ec 0c             	sub    $0xc,%esp
801038b4:	68 49 6c 10 80       	push   $0x80106c49
801038b9:	e8 8a ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801038be:	83 ec 0c             	sub    $0xc,%esp
801038c1:	68 4f 6c 10 80       	push   $0x80106c4f
801038c6:	e8 7d ca ff ff       	call   80100348 <panic>

801038cb <wait>:
{
801038cb:	55                   	push   %ebp
801038cc:	89 e5                	mov    %esp,%ebp
801038ce:	56                   	push   %esi
801038cf:	53                   	push   %ebx
  struct proc *curproc = myproc();
801038d0:	e8 be fa ff ff       	call   80103393 <myproc>
801038d5:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801038d7:	83 ec 0c             	sub    $0xc,%esp
801038da:	68 80 2d 14 80       	push   $0x80142d80
801038df:	e8 51 04 00 00       	call   80103d35 <acquire>
801038e4:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801038e7:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038ec:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
801038f1:	eb 5b                	jmp    8010394e <wait+0x83>
        pid = p->pid;
801038f3:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801038f6:	83 ec 0c             	sub    $0xc,%esp
801038f9:	ff 73 08             	pushl  0x8(%ebx)
801038fc:	e8 04 e7 ff ff       	call   80102005 <kfree>
        p->kstack = 0;
80103901:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103908:	83 c4 04             	add    $0x4,%esp
8010390b:	ff 73 04             	pushl  0x4(%ebx)
8010390e:	e8 6e 2a 00 00       	call   80106381 <freevm>
        p->pid = 0;
80103913:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010391a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103921:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103925:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
8010392c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103933:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
8010393a:	e8 5b 04 00 00       	call   80103d9a <release>
        return pid;
8010393f:	83 c4 10             	add    $0x10,%esp
}
80103942:	89 f0                	mov    %esi,%eax
80103944:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103947:	5b                   	pop    %ebx
80103948:	5e                   	pop    %esi
80103949:	5d                   	pop    %ebp
8010394a:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010394b:	83 c3 7c             	add    $0x7c,%ebx
8010394e:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
80103954:	73 12                	jae    80103968 <wait+0x9d>
      if(p->parent != curproc)
80103956:	39 73 14             	cmp    %esi,0x14(%ebx)
80103959:	75 f0                	jne    8010394b <wait+0x80>
      if(p->state == ZOMBIE){
8010395b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010395f:	74 92                	je     801038f3 <wait+0x28>
      havekids = 1;
80103961:	b8 01 00 00 00       	mov    $0x1,%eax
80103966:	eb e3                	jmp    8010394b <wait+0x80>
    if(!havekids || curproc->killed){
80103968:	85 c0                	test   %eax,%eax
8010396a:	74 06                	je     80103972 <wait+0xa7>
8010396c:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103970:	74 17                	je     80103989 <wait+0xbe>
      release(&ptable.lock);
80103972:	83 ec 0c             	sub    $0xc,%esp
80103975:	68 80 2d 14 80       	push   $0x80142d80
8010397a:	e8 1b 04 00 00       	call   80103d9a <release>
      return -1;
8010397f:	83 c4 10             	add    $0x10,%esp
80103982:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103987:	eb b9                	jmp    80103942 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103989:	83 ec 08             	sub    $0x8,%esp
8010398c:	68 80 2d 14 80       	push   $0x80142d80
80103991:	56                   	push   %esi
80103992:	e8 a3 fe ff ff       	call   8010383a <sleep>
    havekids = 0;
80103997:	83 c4 10             	add    $0x10,%esp
8010399a:	e9 48 ff ff ff       	jmp    801038e7 <wait+0x1c>

8010399f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010399f:	55                   	push   %ebp
801039a0:	89 e5                	mov    %esp,%ebp
801039a2:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801039a5:	68 80 2d 14 80       	push   $0x80142d80
801039aa:	e8 86 03 00 00       	call   80103d35 <acquire>
  wakeup1(chan);
801039af:	8b 45 08             	mov    0x8(%ebp),%eax
801039b2:	e8 16 f8 ff ff       	call   801031cd <wakeup1>
  release(&ptable.lock);
801039b7:	c7 04 24 80 2d 14 80 	movl   $0x80142d80,(%esp)
801039be:	e8 d7 03 00 00       	call   80103d9a <release>
}
801039c3:	83 c4 10             	add    $0x10,%esp
801039c6:	c9                   	leave  
801039c7:	c3                   	ret    

801039c8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801039c8:	55                   	push   %ebp
801039c9:	89 e5                	mov    %esp,%ebp
801039cb:	53                   	push   %ebx
801039cc:	83 ec 10             	sub    $0x10,%esp
801039cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801039d2:	68 80 2d 14 80       	push   $0x80142d80
801039d7:	e8 59 03 00 00       	call   80103d35 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039dc:	83 c4 10             	add    $0x10,%esp
801039df:	b8 b4 2d 14 80       	mov    $0x80142db4,%eax
801039e4:	3d b4 4c 14 80       	cmp    $0x80144cb4,%eax
801039e9:	73 3a                	jae    80103a25 <kill+0x5d>
    if(p->pid == pid){
801039eb:	39 58 10             	cmp    %ebx,0x10(%eax)
801039ee:	74 05                	je     801039f5 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039f0:	83 c0 7c             	add    $0x7c,%eax
801039f3:	eb ef                	jmp    801039e4 <kill+0x1c>
      p->killed = 1;
801039f5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801039fc:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a00:	74 1a                	je     80103a1c <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103a02:	83 ec 0c             	sub    $0xc,%esp
80103a05:	68 80 2d 14 80       	push   $0x80142d80
80103a0a:	e8 8b 03 00 00       	call   80103d9a <release>
      return 0;
80103a0f:	83 c4 10             	add    $0x10,%esp
80103a12:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a1a:	c9                   	leave  
80103a1b:	c3                   	ret    
        p->state = RUNNABLE;
80103a1c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a23:	eb dd                	jmp    80103a02 <kill+0x3a>
  release(&ptable.lock);
80103a25:	83 ec 0c             	sub    $0xc,%esp
80103a28:	68 80 2d 14 80       	push   $0x80142d80
80103a2d:	e8 68 03 00 00       	call   80103d9a <release>
  return -1;
80103a32:	83 c4 10             	add    $0x10,%esp
80103a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a3a:	eb db                	jmp    80103a17 <kill+0x4f>

80103a3c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a3c:	55                   	push   %ebp
80103a3d:	89 e5                	mov    %esp,%ebp
80103a3f:	56                   	push   %esi
80103a40:	53                   	push   %ebx
80103a41:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a44:	bb b4 2d 14 80       	mov    $0x80142db4,%ebx
80103a49:	eb 33                	jmp    80103a7e <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a4b:	b8 60 6c 10 80       	mov    $0x80106c60,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a50:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a53:	52                   	push   %edx
80103a54:	50                   	push   %eax
80103a55:	ff 73 10             	pushl  0x10(%ebx)
80103a58:	68 64 6c 10 80       	push   $0x80106c64
80103a5d:	e8 a9 cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a62:	83 c4 10             	add    $0x10,%esp
80103a65:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a69:	74 39                	je     80103aa4 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a6b:	83 ec 0c             	sub    $0xc,%esp
80103a6e:	68 db 6f 10 80       	push   $0x80106fdb
80103a73:	e8 93 cb ff ff       	call   8010060b <cprintf>
80103a78:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a7b:	83 c3 7c             	add    $0x7c,%ebx
80103a7e:	81 fb b4 4c 14 80    	cmp    $0x80144cb4,%ebx
80103a84:	73 61                	jae    80103ae7 <procdump+0xab>
    if(p->state == UNUSED)
80103a86:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a89:	85 c0                	test   %eax,%eax
80103a8b:	74 ee                	je     80103a7b <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a8d:	83 f8 05             	cmp    $0x5,%eax
80103a90:	77 b9                	ja     80103a4b <procdump+0xf>
80103a92:	8b 04 85 c0 6c 10 80 	mov    -0x7fef9340(,%eax,4),%eax
80103a99:	85 c0                	test   %eax,%eax
80103a9b:	75 b3                	jne    80103a50 <procdump+0x14>
      state = "???";
80103a9d:	b8 60 6c 10 80       	mov    $0x80106c60,%eax
80103aa2:	eb ac                	jmp    80103a50 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103aa4:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103aa7:	8b 40 0c             	mov    0xc(%eax),%eax
80103aaa:	83 c0 08             	add    $0x8,%eax
80103aad:	83 ec 08             	sub    $0x8,%esp
80103ab0:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103ab3:	52                   	push   %edx
80103ab4:	50                   	push   %eax
80103ab5:	e8 5a 01 00 00       	call   80103c14 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103aba:	83 c4 10             	add    $0x10,%esp
80103abd:	be 00 00 00 00       	mov    $0x0,%esi
80103ac2:	eb 14                	jmp    80103ad8 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103ac4:	83 ec 08             	sub    $0x8,%esp
80103ac7:	50                   	push   %eax
80103ac8:	68 a1 66 10 80       	push   $0x801066a1
80103acd:	e8 39 cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103ad2:	83 c6 01             	add    $0x1,%esi
80103ad5:	83 c4 10             	add    $0x10,%esp
80103ad8:	83 fe 09             	cmp    $0x9,%esi
80103adb:	7f 8e                	jg     80103a6b <procdump+0x2f>
80103add:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103ae1:	85 c0                	test   %eax,%eax
80103ae3:	75 df                	jne    80103ac4 <procdump+0x88>
80103ae5:	eb 84                	jmp    80103a6b <procdump+0x2f>
  }
}
80103ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103aea:	5b                   	pop    %ebx
80103aeb:	5e                   	pop    %esi
80103aec:	5d                   	pop    %ebp
80103aed:	c3                   	ret    

80103aee <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103aee:	55                   	push   %ebp
80103aef:	89 e5                	mov    %esp,%ebp
80103af1:	53                   	push   %ebx
80103af2:	83 ec 0c             	sub    $0xc,%esp
80103af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103af8:	68 d8 6c 10 80       	push   $0x80106cd8
80103afd:	8d 43 04             	lea    0x4(%ebx),%eax
80103b00:	50                   	push   %eax
80103b01:	e8 f3 00 00 00       	call   80103bf9 <initlock>
  lk->name = name;
80103b06:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b09:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b0c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b12:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b19:	83 c4 10             	add    $0x10,%esp
80103b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b1f:	c9                   	leave  
80103b20:	c3                   	ret    

80103b21 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b21:	55                   	push   %ebp
80103b22:	89 e5                	mov    %esp,%ebp
80103b24:	56                   	push   %esi
80103b25:	53                   	push   %ebx
80103b26:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b29:	8d 73 04             	lea    0x4(%ebx),%esi
80103b2c:	83 ec 0c             	sub    $0xc,%esp
80103b2f:	56                   	push   %esi
80103b30:	e8 00 02 00 00       	call   80103d35 <acquire>
  while (lk->locked) {
80103b35:	83 c4 10             	add    $0x10,%esp
80103b38:	eb 0d                	jmp    80103b47 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b3a:	83 ec 08             	sub    $0x8,%esp
80103b3d:	56                   	push   %esi
80103b3e:	53                   	push   %ebx
80103b3f:	e8 f6 fc ff ff       	call   8010383a <sleep>
80103b44:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b47:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b4a:	75 ee                	jne    80103b3a <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b4c:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b52:	e8 3c f8 ff ff       	call   80103393 <myproc>
80103b57:	8b 40 10             	mov    0x10(%eax),%eax
80103b5a:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b5d:	83 ec 0c             	sub    $0xc,%esp
80103b60:	56                   	push   %esi
80103b61:	e8 34 02 00 00       	call   80103d9a <release>
}
80103b66:	83 c4 10             	add    $0x10,%esp
80103b69:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b6c:	5b                   	pop    %ebx
80103b6d:	5e                   	pop    %esi
80103b6e:	5d                   	pop    %ebp
80103b6f:	c3                   	ret    

80103b70 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b70:	55                   	push   %ebp
80103b71:	89 e5                	mov    %esp,%ebp
80103b73:	56                   	push   %esi
80103b74:	53                   	push   %ebx
80103b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b78:	8d 73 04             	lea    0x4(%ebx),%esi
80103b7b:	83 ec 0c             	sub    $0xc,%esp
80103b7e:	56                   	push   %esi
80103b7f:	e8 b1 01 00 00       	call   80103d35 <acquire>
  lk->locked = 0;
80103b84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b8a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103b91:	89 1c 24             	mov    %ebx,(%esp)
80103b94:	e8 06 fe ff ff       	call   8010399f <wakeup>
  release(&lk->lk);
80103b99:	89 34 24             	mov    %esi,(%esp)
80103b9c:	e8 f9 01 00 00       	call   80103d9a <release>
}
80103ba1:	83 c4 10             	add    $0x10,%esp
80103ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ba7:	5b                   	pop    %ebx
80103ba8:	5e                   	pop    %esi
80103ba9:	5d                   	pop    %ebp
80103baa:	c3                   	ret    

80103bab <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bab:	55                   	push   %ebp
80103bac:	89 e5                	mov    %esp,%ebp
80103bae:	56                   	push   %esi
80103baf:	53                   	push   %ebx
80103bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103bb3:	8d 73 04             	lea    0x4(%ebx),%esi
80103bb6:	83 ec 0c             	sub    $0xc,%esp
80103bb9:	56                   	push   %esi
80103bba:	e8 76 01 00 00       	call   80103d35 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bbf:	83 c4 10             	add    $0x10,%esp
80103bc2:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bc5:	75 17                	jne    80103bde <holdingsleep+0x33>
80103bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103bcc:	83 ec 0c             	sub    $0xc,%esp
80103bcf:	56                   	push   %esi
80103bd0:	e8 c5 01 00 00       	call   80103d9a <release>
  return r;
}
80103bd5:	89 d8                	mov    %ebx,%eax
80103bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bda:	5b                   	pop    %ebx
80103bdb:	5e                   	pop    %esi
80103bdc:	5d                   	pop    %ebp
80103bdd:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103bde:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103be1:	e8 ad f7 ff ff       	call   80103393 <myproc>
80103be6:	3b 58 10             	cmp    0x10(%eax),%ebx
80103be9:	74 07                	je     80103bf2 <holdingsleep+0x47>
80103beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80103bf0:	eb da                	jmp    80103bcc <holdingsleep+0x21>
80103bf2:	bb 01 00 00 00       	mov    $0x1,%ebx
80103bf7:	eb d3                	jmp    80103bcc <holdingsleep+0x21>

80103bf9 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103bf9:	55                   	push   %ebp
80103bfa:	89 e5                	mov    %esp,%ebp
80103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103bff:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c02:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c12:	5d                   	pop    %ebp
80103c13:	c3                   	ret    

80103c14 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c14:	55                   	push   %ebp
80103c15:	89 e5                	mov    %esp,%ebp
80103c17:	53                   	push   %ebx
80103c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1e:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c21:	b8 00 00 00 00       	mov    $0x0,%eax
80103c26:	83 f8 09             	cmp    $0x9,%eax
80103c29:	7f 25                	jg     80103c50 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c2b:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c31:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c37:	77 17                	ja     80103c50 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c39:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c3c:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c3f:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c41:	83 c0 01             	add    $0x1,%eax
80103c44:	eb e0                	jmp    80103c26 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c46:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c4d:	83 c0 01             	add    $0x1,%eax
80103c50:	83 f8 09             	cmp    $0x9,%eax
80103c53:	7e f1                	jle    80103c46 <getcallerpcs+0x32>
}
80103c55:	5b                   	pop    %ebx
80103c56:	5d                   	pop    %ebp
80103c57:	c3                   	ret    

80103c58 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c58:	55                   	push   %ebp
80103c59:	89 e5                	mov    %esp,%ebp
80103c5b:	53                   	push   %ebx
80103c5c:	83 ec 04             	sub    $0x4,%esp
80103c5f:	9c                   	pushf  
80103c60:	5b                   	pop    %ebx
  asm volatile("cli");
80103c61:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c62:	e8 b5 f6 ff ff       	call   8010331c <mycpu>
80103c67:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c6e:	74 12                	je     80103c82 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c70:	e8 a7 f6 ff ff       	call   8010331c <mycpu>
80103c75:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c7c:	83 c4 04             	add    $0x4,%esp
80103c7f:	5b                   	pop    %ebx
80103c80:	5d                   	pop    %ebp
80103c81:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c82:	e8 95 f6 ff ff       	call   8010331c <mycpu>
80103c87:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103c8d:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103c93:	eb db                	jmp    80103c70 <pushcli+0x18>

80103c95 <popcli>:

void
popcli(void)
{
80103c95:	55                   	push   %ebp
80103c96:	89 e5                	mov    %esp,%ebp
80103c98:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c9b:	9c                   	pushf  
80103c9c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c9d:	f6 c4 02             	test   $0x2,%ah
80103ca0:	75 28                	jne    80103cca <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103ca2:	e8 75 f6 ff ff       	call   8010331c <mycpu>
80103ca7:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cad:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cb0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103cb6:	85 d2                	test   %edx,%edx
80103cb8:	78 1d                	js     80103cd7 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cba:	e8 5d f6 ff ff       	call   8010331c <mycpu>
80103cbf:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cc6:	74 1c                	je     80103ce4 <popcli+0x4f>
    sti();
}
80103cc8:	c9                   	leave  
80103cc9:	c3                   	ret    
    panic("popcli - interruptible");
80103cca:	83 ec 0c             	sub    $0xc,%esp
80103ccd:	68 e3 6c 10 80       	push   $0x80106ce3
80103cd2:	e8 71 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103cd7:	83 ec 0c             	sub    $0xc,%esp
80103cda:	68 fa 6c 10 80       	push   $0x80106cfa
80103cdf:	e8 64 c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103ce4:	e8 33 f6 ff ff       	call   8010331c <mycpu>
80103ce9:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103cf0:	74 d6                	je     80103cc8 <popcli+0x33>
  asm volatile("sti");
80103cf2:	fb                   	sti    
}
80103cf3:	eb d3                	jmp    80103cc8 <popcli+0x33>

80103cf5 <holding>:
{
80103cf5:	55                   	push   %ebp
80103cf6:	89 e5                	mov    %esp,%ebp
80103cf8:	53                   	push   %ebx
80103cf9:	83 ec 04             	sub    $0x4,%esp
80103cfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103cff:	e8 54 ff ff ff       	call   80103c58 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d04:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d07:	75 12                	jne    80103d1b <holding+0x26>
80103d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d0e:	e8 82 ff ff ff       	call   80103c95 <popcli>
}
80103d13:	89 d8                	mov    %ebx,%eax
80103d15:	83 c4 04             	add    $0x4,%esp
80103d18:	5b                   	pop    %ebx
80103d19:	5d                   	pop    %ebp
80103d1a:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d1b:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d1e:	e8 f9 f5 ff ff       	call   8010331c <mycpu>
80103d23:	39 c3                	cmp    %eax,%ebx
80103d25:	74 07                	je     80103d2e <holding+0x39>
80103d27:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d2c:	eb e0                	jmp    80103d0e <holding+0x19>
80103d2e:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d33:	eb d9                	jmp    80103d0e <holding+0x19>

80103d35 <acquire>:
{
80103d35:	55                   	push   %ebp
80103d36:	89 e5                	mov    %esp,%ebp
80103d38:	53                   	push   %ebx
80103d39:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d3c:	e8 17 ff ff ff       	call   80103c58 <pushcli>
  if(holding(lk))
80103d41:	83 ec 0c             	sub    $0xc,%esp
80103d44:	ff 75 08             	pushl  0x8(%ebp)
80103d47:	e8 a9 ff ff ff       	call   80103cf5 <holding>
80103d4c:	83 c4 10             	add    $0x10,%esp
80103d4f:	85 c0                	test   %eax,%eax
80103d51:	75 3a                	jne    80103d8d <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d53:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d56:	b8 01 00 00 00       	mov    $0x1,%eax
80103d5b:	f0 87 02             	lock xchg %eax,(%edx)
80103d5e:	85 c0                	test   %eax,%eax
80103d60:	75 f1                	jne    80103d53 <acquire+0x1e>
  __sync_synchronize();
80103d62:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d67:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d6a:	e8 ad f5 ff ff       	call   8010331c <mycpu>
80103d6f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d72:	8b 45 08             	mov    0x8(%ebp),%eax
80103d75:	83 c0 0c             	add    $0xc,%eax
80103d78:	83 ec 08             	sub    $0x8,%esp
80103d7b:	50                   	push   %eax
80103d7c:	8d 45 08             	lea    0x8(%ebp),%eax
80103d7f:	50                   	push   %eax
80103d80:	e8 8f fe ff ff       	call   80103c14 <getcallerpcs>
}
80103d85:	83 c4 10             	add    $0x10,%esp
80103d88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d8b:	c9                   	leave  
80103d8c:	c3                   	ret    
    panic("acquire");
80103d8d:	83 ec 0c             	sub    $0xc,%esp
80103d90:	68 01 6d 10 80       	push   $0x80106d01
80103d95:	e8 ae c5 ff ff       	call   80100348 <panic>

80103d9a <release>:
{
80103d9a:	55                   	push   %ebp
80103d9b:	89 e5                	mov    %esp,%ebp
80103d9d:	53                   	push   %ebx
80103d9e:	83 ec 10             	sub    $0x10,%esp
80103da1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103da4:	53                   	push   %ebx
80103da5:	e8 4b ff ff ff       	call   80103cf5 <holding>
80103daa:	83 c4 10             	add    $0x10,%esp
80103dad:	85 c0                	test   %eax,%eax
80103daf:	74 23                	je     80103dd4 <release+0x3a>
  lk->pcs[0] = 0;
80103db1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103db8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dbf:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103dc4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103dca:	e8 c6 fe ff ff       	call   80103c95 <popcli>
}
80103dcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dd2:	c9                   	leave  
80103dd3:	c3                   	ret    
    panic("release");
80103dd4:	83 ec 0c             	sub    $0xc,%esp
80103dd7:	68 09 6d 10 80       	push   $0x80106d09
80103ddc:	e8 67 c5 ff ff       	call   80100348 <panic>

80103de1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103de1:	55                   	push   %ebp
80103de2:	89 e5                	mov    %esp,%ebp
80103de4:	57                   	push   %edi
80103de5:	53                   	push   %ebx
80103de6:	8b 55 08             	mov    0x8(%ebp),%edx
80103de9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103dec:	f6 c2 03             	test   $0x3,%dl
80103def:	75 05                	jne    80103df6 <memset+0x15>
80103df1:	f6 c1 03             	test   $0x3,%cl
80103df4:	74 0e                	je     80103e04 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103df6:	89 d7                	mov    %edx,%edi
80103df8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dfb:	fc                   	cld    
80103dfc:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103dfe:	89 d0                	mov    %edx,%eax
80103e00:	5b                   	pop    %ebx
80103e01:	5f                   	pop    %edi
80103e02:	5d                   	pop    %ebp
80103e03:	c3                   	ret    
    c &= 0xFF;
80103e04:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e08:	c1 e9 02             	shr    $0x2,%ecx
80103e0b:	89 f8                	mov    %edi,%eax
80103e0d:	c1 e0 18             	shl    $0x18,%eax
80103e10:	89 fb                	mov    %edi,%ebx
80103e12:	c1 e3 10             	shl    $0x10,%ebx
80103e15:	09 d8                	or     %ebx,%eax
80103e17:	89 fb                	mov    %edi,%ebx
80103e19:	c1 e3 08             	shl    $0x8,%ebx
80103e1c:	09 d8                	or     %ebx,%eax
80103e1e:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103e20:	89 d7                	mov    %edx,%edi
80103e22:	fc                   	cld    
80103e23:	f3 ab                	rep stos %eax,%es:(%edi)
80103e25:	eb d7                	jmp    80103dfe <memset+0x1d>

80103e27 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e27:	55                   	push   %ebp
80103e28:	89 e5                	mov    %esp,%ebp
80103e2a:	56                   	push   %esi
80103e2b:	53                   	push   %ebx
80103e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e32:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e35:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e38:	85 c0                	test   %eax,%eax
80103e3a:	74 1c                	je     80103e58 <memcmp+0x31>
    if(*s1 != *s2)
80103e3c:	0f b6 01             	movzbl (%ecx),%eax
80103e3f:	0f b6 1a             	movzbl (%edx),%ebx
80103e42:	38 d8                	cmp    %bl,%al
80103e44:	75 0a                	jne    80103e50 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e46:	83 c1 01             	add    $0x1,%ecx
80103e49:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e4c:	89 f0                	mov    %esi,%eax
80103e4e:	eb e5                	jmp    80103e35 <memcmp+0xe>
      return *s1 - *s2;
80103e50:	0f b6 c0             	movzbl %al,%eax
80103e53:	0f b6 db             	movzbl %bl,%ebx
80103e56:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e58:	5b                   	pop    %ebx
80103e59:	5e                   	pop    %esi
80103e5a:	5d                   	pop    %ebp
80103e5b:	c3                   	ret    

80103e5c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e5c:	55                   	push   %ebp
80103e5d:	89 e5                	mov    %esp,%ebp
80103e5f:	56                   	push   %esi
80103e60:	53                   	push   %ebx
80103e61:	8b 45 08             	mov    0x8(%ebp),%eax
80103e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e67:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e6a:	39 c1                	cmp    %eax,%ecx
80103e6c:	73 3a                	jae    80103ea8 <memmove+0x4c>
80103e6e:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e71:	39 c3                	cmp    %eax,%ebx
80103e73:	76 37                	jbe    80103eac <memmove+0x50>
    s += n;
    d += n;
80103e75:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e78:	eb 0d                	jmp    80103e87 <memmove+0x2b>
      *--d = *--s;
80103e7a:	83 eb 01             	sub    $0x1,%ebx
80103e7d:	83 e9 01             	sub    $0x1,%ecx
80103e80:	0f b6 13             	movzbl (%ebx),%edx
80103e83:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e85:	89 f2                	mov    %esi,%edx
80103e87:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e8a:	85 d2                	test   %edx,%edx
80103e8c:	75 ec                	jne    80103e7a <memmove+0x1e>
80103e8e:	eb 14                	jmp    80103ea4 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103e90:	0f b6 11             	movzbl (%ecx),%edx
80103e93:	88 13                	mov    %dl,(%ebx)
80103e95:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103e98:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103e9b:	89 f2                	mov    %esi,%edx
80103e9d:	8d 72 ff             	lea    -0x1(%edx),%esi
80103ea0:	85 d2                	test   %edx,%edx
80103ea2:	75 ec                	jne    80103e90 <memmove+0x34>

  return dst;
}
80103ea4:	5b                   	pop    %ebx
80103ea5:	5e                   	pop    %esi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret    
80103ea8:	89 c3                	mov    %eax,%ebx
80103eaa:	eb f1                	jmp    80103e9d <memmove+0x41>
80103eac:	89 c3                	mov    %eax,%ebx
80103eae:	eb ed                	jmp    80103e9d <memmove+0x41>

80103eb0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103eb0:	55                   	push   %ebp
80103eb1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103eb3:	ff 75 10             	pushl  0x10(%ebp)
80103eb6:	ff 75 0c             	pushl  0xc(%ebp)
80103eb9:	ff 75 08             	pushl  0x8(%ebp)
80103ebc:	e8 9b ff ff ff       	call   80103e5c <memmove>
}
80103ec1:	c9                   	leave  
80103ec2:	c3                   	ret    

80103ec3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103ec3:	55                   	push   %ebp
80103ec4:	89 e5                	mov    %esp,%ebp
80103ec6:	53                   	push   %ebx
80103ec7:	8b 55 08             	mov    0x8(%ebp),%edx
80103eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ecd:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103ed0:	eb 09                	jmp    80103edb <strncmp+0x18>
    n--, p++, q++;
80103ed2:	83 e8 01             	sub    $0x1,%eax
80103ed5:	83 c2 01             	add    $0x1,%edx
80103ed8:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103edb:	85 c0                	test   %eax,%eax
80103edd:	74 0b                	je     80103eea <strncmp+0x27>
80103edf:	0f b6 1a             	movzbl (%edx),%ebx
80103ee2:	84 db                	test   %bl,%bl
80103ee4:	74 04                	je     80103eea <strncmp+0x27>
80103ee6:	3a 19                	cmp    (%ecx),%bl
80103ee8:	74 e8                	je     80103ed2 <strncmp+0xf>
  if(n == 0)
80103eea:	85 c0                	test   %eax,%eax
80103eec:	74 0b                	je     80103ef9 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103eee:	0f b6 02             	movzbl (%edx),%eax
80103ef1:	0f b6 11             	movzbl (%ecx),%edx
80103ef4:	29 d0                	sub    %edx,%eax
}
80103ef6:	5b                   	pop    %ebx
80103ef7:	5d                   	pop    %ebp
80103ef8:	c3                   	ret    
    return 0;
80103ef9:	b8 00 00 00 00       	mov    $0x0,%eax
80103efe:	eb f6                	jmp    80103ef6 <strncmp+0x33>

80103f00 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f00:	55                   	push   %ebp
80103f01:	89 e5                	mov    %esp,%ebp
80103f03:	57                   	push   %edi
80103f04:	56                   	push   %esi
80103f05:	53                   	push   %ebx
80103f06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0f:	eb 04                	jmp    80103f15 <strncpy+0x15>
80103f11:	89 fb                	mov    %edi,%ebx
80103f13:	89 f0                	mov    %esi,%eax
80103f15:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f18:	85 c9                	test   %ecx,%ecx
80103f1a:	7e 1d                	jle    80103f39 <strncpy+0x39>
80103f1c:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f1f:	8d 70 01             	lea    0x1(%eax),%esi
80103f22:	0f b6 1b             	movzbl (%ebx),%ebx
80103f25:	88 18                	mov    %bl,(%eax)
80103f27:	89 d1                	mov    %edx,%ecx
80103f29:	84 db                	test   %bl,%bl
80103f2b:	75 e4                	jne    80103f11 <strncpy+0x11>
80103f2d:	89 f0                	mov    %esi,%eax
80103f2f:	eb 08                	jmp    80103f39 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f31:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f34:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f36:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f39:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f3c:	85 d2                	test   %edx,%edx
80103f3e:	7f f1                	jg     80103f31 <strncpy+0x31>
  return os;
}
80103f40:	8b 45 08             	mov    0x8(%ebp),%eax
80103f43:	5b                   	pop    %ebx
80103f44:	5e                   	pop    %esi
80103f45:	5f                   	pop    %edi
80103f46:	5d                   	pop    %ebp
80103f47:	c3                   	ret    

80103f48 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f48:	55                   	push   %ebp
80103f49:	89 e5                	mov    %esp,%ebp
80103f4b:	57                   	push   %edi
80103f4c:	56                   	push   %esi
80103f4d:	53                   	push   %ebx
80103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f54:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f57:	85 d2                	test   %edx,%edx
80103f59:	7e 23                	jle    80103f7e <safestrcpy+0x36>
80103f5b:	89 c1                	mov    %eax,%ecx
80103f5d:	eb 04                	jmp    80103f63 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f5f:	89 fb                	mov    %edi,%ebx
80103f61:	89 f1                	mov    %esi,%ecx
80103f63:	83 ea 01             	sub    $0x1,%edx
80103f66:	85 d2                	test   %edx,%edx
80103f68:	7e 11                	jle    80103f7b <safestrcpy+0x33>
80103f6a:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f6d:	8d 71 01             	lea    0x1(%ecx),%esi
80103f70:	0f b6 1b             	movzbl (%ebx),%ebx
80103f73:	88 19                	mov    %bl,(%ecx)
80103f75:	84 db                	test   %bl,%bl
80103f77:	75 e6                	jne    80103f5f <safestrcpy+0x17>
80103f79:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f7b:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f7e:	5b                   	pop    %ebx
80103f7f:	5e                   	pop    %esi
80103f80:	5f                   	pop    %edi
80103f81:	5d                   	pop    %ebp
80103f82:	c3                   	ret    

80103f83 <strlen>:

int
strlen(const char *s)
{
80103f83:	55                   	push   %ebp
80103f84:	89 e5                	mov    %esp,%ebp
80103f86:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103f89:	b8 00 00 00 00       	mov    $0x0,%eax
80103f8e:	eb 03                	jmp    80103f93 <strlen+0x10>
80103f90:	83 c0 01             	add    $0x1,%eax
80103f93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103f97:	75 f7                	jne    80103f90 <strlen+0xd>
    ;
  return n;
}
80103f99:	5d                   	pop    %ebp
80103f9a:	c3                   	ret    

80103f9b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103f9b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103f9f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fa3:	55                   	push   %ebp
  pushl %ebx
80103fa4:	53                   	push   %ebx
  pushl %esi
80103fa5:	56                   	push   %esi
  pushl %edi
80103fa6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fa7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fa9:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fab:	5f                   	pop    %edi
  popl %esi
80103fac:	5e                   	pop    %esi
  popl %ebx
80103fad:	5b                   	pop    %ebx
  popl %ebp
80103fae:	5d                   	pop    %ebp
  ret
80103faf:	c3                   	ret    

80103fb0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fb0:	55                   	push   %ebp
80103fb1:	89 e5                	mov    %esp,%ebp
80103fb3:	53                   	push   %ebx
80103fb4:	83 ec 04             	sub    $0x4,%esp
80103fb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fba:	e8 d4 f3 ff ff       	call   80103393 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fbf:	8b 00                	mov    (%eax),%eax
80103fc1:	39 d8                	cmp    %ebx,%eax
80103fc3:	76 19                	jbe    80103fde <fetchint+0x2e>
80103fc5:	8d 53 04             	lea    0x4(%ebx),%edx
80103fc8:	39 d0                	cmp    %edx,%eax
80103fca:	72 19                	jb     80103fe5 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103fcc:	8b 13                	mov    (%ebx),%edx
80103fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd1:	89 10                	mov    %edx,(%eax)
  return 0;
80103fd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fd8:	83 c4 04             	add    $0x4,%esp
80103fdb:	5b                   	pop    %ebx
80103fdc:	5d                   	pop    %ebp
80103fdd:	c3                   	ret    
    return -1;
80103fde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe3:	eb f3                	jmp    80103fd8 <fetchint+0x28>
80103fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fea:	eb ec                	jmp    80103fd8 <fetchint+0x28>

80103fec <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103fec:	55                   	push   %ebp
80103fed:	89 e5                	mov    %esp,%ebp
80103fef:	53                   	push   %ebx
80103ff0:	83 ec 04             	sub    $0x4,%esp
80103ff3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103ff6:	e8 98 f3 ff ff       	call   80103393 <myproc>

  if(addr >= curproc->sz)
80103ffb:	39 18                	cmp    %ebx,(%eax)
80103ffd:	76 26                	jbe    80104025 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103fff:	8b 55 0c             	mov    0xc(%ebp),%edx
80104002:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104004:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104006:	89 d8                	mov    %ebx,%eax
80104008:	39 d0                	cmp    %edx,%eax
8010400a:	73 0e                	jae    8010401a <fetchstr+0x2e>
    if(*s == 0)
8010400c:	80 38 00             	cmpb   $0x0,(%eax)
8010400f:	74 05                	je     80104016 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104011:	83 c0 01             	add    $0x1,%eax
80104014:	eb f2                	jmp    80104008 <fetchstr+0x1c>
      return s - *pp;
80104016:	29 d8                	sub    %ebx,%eax
80104018:	eb 05                	jmp    8010401f <fetchstr+0x33>
  }
  return -1;
8010401a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010401f:	83 c4 04             	add    $0x4,%esp
80104022:	5b                   	pop    %ebx
80104023:	5d                   	pop    %ebp
80104024:	c3                   	ret    
    return -1;
80104025:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010402a:	eb f3                	jmp    8010401f <fetchstr+0x33>

8010402c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010402c:	55                   	push   %ebp
8010402d:	89 e5                	mov    %esp,%ebp
8010402f:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104032:	e8 5c f3 ff ff       	call   80103393 <myproc>
80104037:	8b 50 18             	mov    0x18(%eax),%edx
8010403a:	8b 45 08             	mov    0x8(%ebp),%eax
8010403d:	c1 e0 02             	shl    $0x2,%eax
80104040:	03 42 44             	add    0x44(%edx),%eax
80104043:	83 ec 08             	sub    $0x8,%esp
80104046:	ff 75 0c             	pushl  0xc(%ebp)
80104049:	83 c0 04             	add    $0x4,%eax
8010404c:	50                   	push   %eax
8010404d:	e8 5e ff ff ff       	call   80103fb0 <fetchint>
}
80104052:	c9                   	leave  
80104053:	c3                   	ret    

80104054 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104054:	55                   	push   %ebp
80104055:	89 e5                	mov    %esp,%ebp
80104057:	56                   	push   %esi
80104058:	53                   	push   %ebx
80104059:	83 ec 10             	sub    $0x10,%esp
8010405c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010405f:	e8 2f f3 ff ff       	call   80103393 <myproc>
80104064:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104066:	83 ec 08             	sub    $0x8,%esp
80104069:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010406c:	50                   	push   %eax
8010406d:	ff 75 08             	pushl  0x8(%ebp)
80104070:	e8 b7 ff ff ff       	call   8010402c <argint>
80104075:	83 c4 10             	add    $0x10,%esp
80104078:	85 c0                	test   %eax,%eax
8010407a:	78 24                	js     801040a0 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010407c:	85 db                	test   %ebx,%ebx
8010407e:	78 27                	js     801040a7 <argptr+0x53>
80104080:	8b 16                	mov    (%esi),%edx
80104082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104085:	39 c2                	cmp    %eax,%edx
80104087:	76 25                	jbe    801040ae <argptr+0x5a>
80104089:	01 c3                	add    %eax,%ebx
8010408b:	39 da                	cmp    %ebx,%edx
8010408d:	72 26                	jb     801040b5 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010408f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104092:	89 02                	mov    %eax,(%edx)
  return 0;
80104094:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104099:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010409c:	5b                   	pop    %ebx
8010409d:	5e                   	pop    %esi
8010409e:	5d                   	pop    %ebp
8010409f:	c3                   	ret    
    return -1;
801040a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a5:	eb f2                	jmp    80104099 <argptr+0x45>
    return -1;
801040a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ac:	eb eb                	jmp    80104099 <argptr+0x45>
801040ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040b3:	eb e4                	jmp    80104099 <argptr+0x45>
801040b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ba:	eb dd                	jmp    80104099 <argptr+0x45>

801040bc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040bc:	55                   	push   %ebp
801040bd:	89 e5                	mov    %esp,%ebp
801040bf:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040c5:	50                   	push   %eax
801040c6:	ff 75 08             	pushl  0x8(%ebp)
801040c9:	e8 5e ff ff ff       	call   8010402c <argint>
801040ce:	83 c4 10             	add    $0x10,%esp
801040d1:	85 c0                	test   %eax,%eax
801040d3:	78 13                	js     801040e8 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801040d5:	83 ec 08             	sub    $0x8,%esp
801040d8:	ff 75 0c             	pushl  0xc(%ebp)
801040db:	ff 75 f4             	pushl  -0xc(%ebp)
801040de:	e8 09 ff ff ff       	call   80103fec <fetchstr>
801040e3:	83 c4 10             	add    $0x10,%esp
}
801040e6:	c9                   	leave  
801040e7:	c3                   	ret    
    return -1;
801040e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ed:	eb f7                	jmp    801040e6 <argstr+0x2a>

801040ef <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
801040ef:	55                   	push   %ebp
801040f0:	89 e5                	mov    %esp,%ebp
801040f2:	53                   	push   %ebx
801040f3:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801040f6:	e8 98 f2 ff ff       	call   80103393 <myproc>
801040fb:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801040fd:	8b 40 18             	mov    0x18(%eax),%eax
80104100:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104103:	8d 50 ff             	lea    -0x1(%eax),%edx
80104106:	83 fa 15             	cmp    $0x15,%edx
80104109:	77 18                	ja     80104123 <syscall+0x34>
8010410b:	8b 14 85 40 6d 10 80 	mov    -0x7fef92c0(,%eax,4),%edx
80104112:	85 d2                	test   %edx,%edx
80104114:	74 0d                	je     80104123 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104116:	ff d2                	call   *%edx
80104118:	8b 53 18             	mov    0x18(%ebx),%edx
8010411b:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010411e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104121:	c9                   	leave  
80104122:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104123:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104126:	50                   	push   %eax
80104127:	52                   	push   %edx
80104128:	ff 73 10             	pushl  0x10(%ebx)
8010412b:	68 11 6d 10 80       	push   $0x80106d11
80104130:	e8 d6 c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104135:	8b 43 18             	mov    0x18(%ebx),%eax
80104138:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010413f:	83 c4 10             	add    $0x10,%esp
}
80104142:	eb da                	jmp    8010411e <syscall+0x2f>

80104144 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104144:	55                   	push   %ebp
80104145:	89 e5                	mov    %esp,%ebp
80104147:	56                   	push   %esi
80104148:	53                   	push   %ebx
80104149:	83 ec 18             	sub    $0x18,%esp
8010414c:	89 d6                	mov    %edx,%esi
8010414e:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104150:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104153:	52                   	push   %edx
80104154:	50                   	push   %eax
80104155:	e8 d2 fe ff ff       	call   8010402c <argint>
8010415a:	83 c4 10             	add    $0x10,%esp
8010415d:	85 c0                	test   %eax,%eax
8010415f:	78 2e                	js     8010418f <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104161:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104165:	77 2f                	ja     80104196 <argfd+0x52>
80104167:	e8 27 f2 ff ff       	call   80103393 <myproc>
8010416c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010416f:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104173:	85 c0                	test   %eax,%eax
80104175:	74 26                	je     8010419d <argfd+0x59>
    return -1;
  if(pfd)
80104177:	85 f6                	test   %esi,%esi
80104179:	74 02                	je     8010417d <argfd+0x39>
    *pfd = fd;
8010417b:	89 16                	mov    %edx,(%esi)
  if(pf)
8010417d:	85 db                	test   %ebx,%ebx
8010417f:	74 23                	je     801041a4 <argfd+0x60>
    *pf = f;
80104181:	89 03                	mov    %eax,(%ebx)
  return 0;
80104183:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104188:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010418b:	5b                   	pop    %ebx
8010418c:	5e                   	pop    %esi
8010418d:	5d                   	pop    %ebp
8010418e:	c3                   	ret    
    return -1;
8010418f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104194:	eb f2                	jmp    80104188 <argfd+0x44>
    return -1;
80104196:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010419b:	eb eb                	jmp    80104188 <argfd+0x44>
8010419d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041a2:	eb e4                	jmp    80104188 <argfd+0x44>
  return 0;
801041a4:	b8 00 00 00 00       	mov    $0x0,%eax
801041a9:	eb dd                	jmp    80104188 <argfd+0x44>

801041ab <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041ab:	55                   	push   %ebp
801041ac:	89 e5                	mov    %esp,%ebp
801041ae:	53                   	push   %ebx
801041af:	83 ec 04             	sub    $0x4,%esp
801041b2:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041b4:	e8 da f1 ff ff       	call   80103393 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041b9:	ba 00 00 00 00       	mov    $0x0,%edx
801041be:	83 fa 0f             	cmp    $0xf,%edx
801041c1:	7f 18                	jg     801041db <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801041c3:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801041c8:	74 05                	je     801041cf <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801041ca:	83 c2 01             	add    $0x1,%edx
801041cd:	eb ef                	jmp    801041be <fdalloc+0x13>
      curproc->ofile[fd] = f;
801041cf:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801041d3:	89 d0                	mov    %edx,%eax
801041d5:	83 c4 04             	add    $0x4,%esp
801041d8:	5b                   	pop    %ebx
801041d9:	5d                   	pop    %ebp
801041da:	c3                   	ret    
  return -1;
801041db:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801041e0:	eb f1                	jmp    801041d3 <fdalloc+0x28>

801041e2 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801041e2:	55                   	push   %ebp
801041e3:	89 e5                	mov    %esp,%ebp
801041e5:	56                   	push   %esi
801041e6:	53                   	push   %ebx
801041e7:	83 ec 10             	sub    $0x10,%esp
801041ea:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801041ec:	b8 20 00 00 00       	mov    $0x20,%eax
801041f1:	89 c6                	mov    %eax,%esi
801041f3:	39 43 58             	cmp    %eax,0x58(%ebx)
801041f6:	76 2e                	jbe    80104226 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801041f8:	6a 10                	push   $0x10
801041fa:	50                   	push   %eax
801041fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801041fe:	50                   	push   %eax
801041ff:	53                   	push   %ebx
80104200:	e8 7a d5 ff ff       	call   8010177f <readi>
80104205:	83 c4 10             	add    $0x10,%esp
80104208:	83 f8 10             	cmp    $0x10,%eax
8010420b:	75 0c                	jne    80104219 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010420d:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104212:	75 1e                	jne    80104232 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104214:	8d 46 10             	lea    0x10(%esi),%eax
80104217:	eb d8                	jmp    801041f1 <isdirempty+0xf>
      panic("isdirempty: readi");
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	68 9c 6d 10 80       	push   $0x80106d9c
80104221:	e8 22 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104226:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010422b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010422e:	5b                   	pop    %ebx
8010422f:	5e                   	pop    %esi
80104230:	5d                   	pop    %ebp
80104231:	c3                   	ret    
      return 0;
80104232:	b8 00 00 00 00       	mov    $0x0,%eax
80104237:	eb f2                	jmp    8010422b <isdirempty+0x49>

80104239 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104239:	55                   	push   %ebp
8010423a:	89 e5                	mov    %esp,%ebp
8010423c:	57                   	push   %edi
8010423d:	56                   	push   %esi
8010423e:	53                   	push   %ebx
8010423f:	83 ec 44             	sub    $0x44,%esp
80104242:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104245:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104248:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010424b:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010424e:	52                   	push   %edx
8010424f:	50                   	push   %eax
80104250:	e8 b0 d9 ff ff       	call   80101c05 <nameiparent>
80104255:	89 c6                	mov    %eax,%esi
80104257:	83 c4 10             	add    $0x10,%esp
8010425a:	85 c0                	test   %eax,%eax
8010425c:	0f 84 3a 01 00 00    	je     8010439c <create+0x163>
    return 0;
  ilock(dp);
80104262:	83 ec 0c             	sub    $0xc,%esp
80104265:	50                   	push   %eax
80104266:	e8 22 d3 ff ff       	call   8010158d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010426b:	83 c4 0c             	add    $0xc,%esp
8010426e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104271:	50                   	push   %eax
80104272:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104275:	50                   	push   %eax
80104276:	56                   	push   %esi
80104277:	e8 40 d7 ff ff       	call   801019bc <dirlookup>
8010427c:	89 c3                	mov    %eax,%ebx
8010427e:	83 c4 10             	add    $0x10,%esp
80104281:	85 c0                	test   %eax,%eax
80104283:	74 3f                	je     801042c4 <create+0x8b>
    iunlockput(dp);
80104285:	83 ec 0c             	sub    $0xc,%esp
80104288:	56                   	push   %esi
80104289:	e8 a6 d4 ff ff       	call   80101734 <iunlockput>
    ilock(ip);
8010428e:	89 1c 24             	mov    %ebx,(%esp)
80104291:	e8 f7 d2 ff ff       	call   8010158d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104296:	83 c4 10             	add    $0x10,%esp
80104299:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010429e:	75 11                	jne    801042b1 <create+0x78>
801042a0:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042a5:	75 0a                	jne    801042b1 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042a7:	89 d8                	mov    %ebx,%eax
801042a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042ac:	5b                   	pop    %ebx
801042ad:	5e                   	pop    %esi
801042ae:	5f                   	pop    %edi
801042af:	5d                   	pop    %ebp
801042b0:	c3                   	ret    
    iunlockput(ip);
801042b1:	83 ec 0c             	sub    $0xc,%esp
801042b4:	53                   	push   %ebx
801042b5:	e8 7a d4 ff ff       	call   80101734 <iunlockput>
    return 0;
801042ba:	83 c4 10             	add    $0x10,%esp
801042bd:	bb 00 00 00 00       	mov    $0x0,%ebx
801042c2:	eb e3                	jmp    801042a7 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801042c4:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801042c8:	83 ec 08             	sub    $0x8,%esp
801042cb:	50                   	push   %eax
801042cc:	ff 36                	pushl  (%esi)
801042ce:	e8 b7 d0 ff ff       	call   8010138a <ialloc>
801042d3:	89 c3                	mov    %eax,%ebx
801042d5:	83 c4 10             	add    $0x10,%esp
801042d8:	85 c0                	test   %eax,%eax
801042da:	74 55                	je     80104331 <create+0xf8>
  ilock(ip);
801042dc:	83 ec 0c             	sub    $0xc,%esp
801042df:	50                   	push   %eax
801042e0:	e8 a8 d2 ff ff       	call   8010158d <ilock>
  ip->major = major;
801042e5:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801042e9:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801042ed:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801042f1:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801042f7:	89 1c 24             	mov    %ebx,(%esp)
801042fa:	e8 2d d1 ff ff       	call   8010142c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801042ff:	83 c4 10             	add    $0x10,%esp
80104302:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104307:	74 35                	je     8010433e <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104309:	83 ec 04             	sub    $0x4,%esp
8010430c:	ff 73 04             	pushl  0x4(%ebx)
8010430f:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104312:	50                   	push   %eax
80104313:	56                   	push   %esi
80104314:	e8 23 d8 ff ff       	call   80101b3c <dirlink>
80104319:	83 c4 10             	add    $0x10,%esp
8010431c:	85 c0                	test   %eax,%eax
8010431e:	78 6f                	js     8010438f <create+0x156>
  iunlockput(dp);
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	56                   	push   %esi
80104324:	e8 0b d4 ff ff       	call   80101734 <iunlockput>
  return ip;
80104329:	83 c4 10             	add    $0x10,%esp
8010432c:	e9 76 ff ff ff       	jmp    801042a7 <create+0x6e>
    panic("create: ialloc");
80104331:	83 ec 0c             	sub    $0xc,%esp
80104334:	68 ae 6d 10 80       	push   $0x80106dae
80104339:	e8 0a c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010433e:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104342:	83 c0 01             	add    $0x1,%eax
80104345:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104349:	83 ec 0c             	sub    $0xc,%esp
8010434c:	56                   	push   %esi
8010434d:	e8 da d0 ff ff       	call   8010142c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104352:	83 c4 0c             	add    $0xc,%esp
80104355:	ff 73 04             	pushl  0x4(%ebx)
80104358:	68 be 6d 10 80       	push   $0x80106dbe
8010435d:	53                   	push   %ebx
8010435e:	e8 d9 d7 ff ff       	call   80101b3c <dirlink>
80104363:	83 c4 10             	add    $0x10,%esp
80104366:	85 c0                	test   %eax,%eax
80104368:	78 18                	js     80104382 <create+0x149>
8010436a:	83 ec 04             	sub    $0x4,%esp
8010436d:	ff 76 04             	pushl  0x4(%esi)
80104370:	68 bd 6d 10 80       	push   $0x80106dbd
80104375:	53                   	push   %ebx
80104376:	e8 c1 d7 ff ff       	call   80101b3c <dirlink>
8010437b:	83 c4 10             	add    $0x10,%esp
8010437e:	85 c0                	test   %eax,%eax
80104380:	79 87                	jns    80104309 <create+0xd0>
      panic("create dots");
80104382:	83 ec 0c             	sub    $0xc,%esp
80104385:	68 c0 6d 10 80       	push   $0x80106dc0
8010438a:	e8 b9 bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010438f:	83 ec 0c             	sub    $0xc,%esp
80104392:	68 cc 6d 10 80       	push   $0x80106dcc
80104397:	e8 ac bf ff ff       	call   80100348 <panic>
    return 0;
8010439c:	89 c3                	mov    %eax,%ebx
8010439e:	e9 04 ff ff ff       	jmp    801042a7 <create+0x6e>

801043a3 <sys_dup>:
{
801043a3:	55                   	push   %ebp
801043a4:	89 e5                	mov    %esp,%ebp
801043a6:	53                   	push   %ebx
801043a7:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043aa:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043ad:	ba 00 00 00 00       	mov    $0x0,%edx
801043b2:	b8 00 00 00 00       	mov    $0x0,%eax
801043b7:	e8 88 fd ff ff       	call   80104144 <argfd>
801043bc:	85 c0                	test   %eax,%eax
801043be:	78 23                	js     801043e3 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c3:	e8 e3 fd ff ff       	call   801041ab <fdalloc>
801043c8:	89 c3                	mov    %eax,%ebx
801043ca:	85 c0                	test   %eax,%eax
801043cc:	78 1c                	js     801043ea <sys_dup+0x47>
  filedup(f);
801043ce:	83 ec 0c             	sub    $0xc,%esp
801043d1:	ff 75 f4             	pushl  -0xc(%ebp)
801043d4:	e8 c1 c8 ff ff       	call   80100c9a <filedup>
  return fd;
801043d9:	83 c4 10             	add    $0x10,%esp
}
801043dc:	89 d8                	mov    %ebx,%eax
801043de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043e1:	c9                   	leave  
801043e2:	c3                   	ret    
    return -1;
801043e3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043e8:	eb f2                	jmp    801043dc <sys_dup+0x39>
    return -1;
801043ea:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043ef:	eb eb                	jmp    801043dc <sys_dup+0x39>

801043f1 <sys_read>:
{
801043f1:	55                   	push   %ebp
801043f2:	89 e5                	mov    %esp,%ebp
801043f4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043f7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043fa:	ba 00 00 00 00       	mov    $0x0,%edx
801043ff:	b8 00 00 00 00       	mov    $0x0,%eax
80104404:	e8 3b fd ff ff       	call   80104144 <argfd>
80104409:	85 c0                	test   %eax,%eax
8010440b:	78 43                	js     80104450 <sys_read+0x5f>
8010440d:	83 ec 08             	sub    $0x8,%esp
80104410:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104413:	50                   	push   %eax
80104414:	6a 02                	push   $0x2
80104416:	e8 11 fc ff ff       	call   8010402c <argint>
8010441b:	83 c4 10             	add    $0x10,%esp
8010441e:	85 c0                	test   %eax,%eax
80104420:	78 35                	js     80104457 <sys_read+0x66>
80104422:	83 ec 04             	sub    $0x4,%esp
80104425:	ff 75 f0             	pushl  -0x10(%ebp)
80104428:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010442b:	50                   	push   %eax
8010442c:	6a 01                	push   $0x1
8010442e:	e8 21 fc ff ff       	call   80104054 <argptr>
80104433:	83 c4 10             	add    $0x10,%esp
80104436:	85 c0                	test   %eax,%eax
80104438:	78 24                	js     8010445e <sys_read+0x6d>
  return fileread(f, p, n);
8010443a:	83 ec 04             	sub    $0x4,%esp
8010443d:	ff 75 f0             	pushl  -0x10(%ebp)
80104440:	ff 75 ec             	pushl  -0x14(%ebp)
80104443:	ff 75 f4             	pushl  -0xc(%ebp)
80104446:	e8 98 c9 ff ff       	call   80100de3 <fileread>
8010444b:	83 c4 10             	add    $0x10,%esp
}
8010444e:	c9                   	leave  
8010444f:	c3                   	ret    
    return -1;
80104450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104455:	eb f7                	jmp    8010444e <sys_read+0x5d>
80104457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010445c:	eb f0                	jmp    8010444e <sys_read+0x5d>
8010445e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104463:	eb e9                	jmp    8010444e <sys_read+0x5d>

80104465 <sys_write>:
{
80104465:	55                   	push   %ebp
80104466:	89 e5                	mov    %esp,%ebp
80104468:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010446b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010446e:	ba 00 00 00 00       	mov    $0x0,%edx
80104473:	b8 00 00 00 00       	mov    $0x0,%eax
80104478:	e8 c7 fc ff ff       	call   80104144 <argfd>
8010447d:	85 c0                	test   %eax,%eax
8010447f:	78 43                	js     801044c4 <sys_write+0x5f>
80104481:	83 ec 08             	sub    $0x8,%esp
80104484:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104487:	50                   	push   %eax
80104488:	6a 02                	push   $0x2
8010448a:	e8 9d fb ff ff       	call   8010402c <argint>
8010448f:	83 c4 10             	add    $0x10,%esp
80104492:	85 c0                	test   %eax,%eax
80104494:	78 35                	js     801044cb <sys_write+0x66>
80104496:	83 ec 04             	sub    $0x4,%esp
80104499:	ff 75 f0             	pushl  -0x10(%ebp)
8010449c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010449f:	50                   	push   %eax
801044a0:	6a 01                	push   $0x1
801044a2:	e8 ad fb ff ff       	call   80104054 <argptr>
801044a7:	83 c4 10             	add    $0x10,%esp
801044aa:	85 c0                	test   %eax,%eax
801044ac:	78 24                	js     801044d2 <sys_write+0x6d>
  return filewrite(f, p, n);
801044ae:	83 ec 04             	sub    $0x4,%esp
801044b1:	ff 75 f0             	pushl  -0x10(%ebp)
801044b4:	ff 75 ec             	pushl  -0x14(%ebp)
801044b7:	ff 75 f4             	pushl  -0xc(%ebp)
801044ba:	e8 a9 c9 ff ff       	call   80100e68 <filewrite>
801044bf:	83 c4 10             	add    $0x10,%esp
}
801044c2:	c9                   	leave  
801044c3:	c3                   	ret    
    return -1;
801044c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c9:	eb f7                	jmp    801044c2 <sys_write+0x5d>
801044cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d0:	eb f0                	jmp    801044c2 <sys_write+0x5d>
801044d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d7:	eb e9                	jmp    801044c2 <sys_write+0x5d>

801044d9 <sys_close>:
{
801044d9:	55                   	push   %ebp
801044da:	89 e5                	mov    %esp,%ebp
801044dc:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801044df:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801044e2:	8d 55 f4             	lea    -0xc(%ebp),%edx
801044e5:	b8 00 00 00 00       	mov    $0x0,%eax
801044ea:	e8 55 fc ff ff       	call   80104144 <argfd>
801044ef:	85 c0                	test   %eax,%eax
801044f1:	78 25                	js     80104518 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801044f3:	e8 9b ee ff ff       	call   80103393 <myproc>
801044f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044fb:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104502:	00 
  fileclose(f);
80104503:	83 ec 0c             	sub    $0xc,%esp
80104506:	ff 75 f0             	pushl  -0x10(%ebp)
80104509:	e8 d1 c7 ff ff       	call   80100cdf <fileclose>
  return 0;
8010450e:	83 c4 10             	add    $0x10,%esp
80104511:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104516:	c9                   	leave  
80104517:	c3                   	ret    
    return -1;
80104518:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010451d:	eb f7                	jmp    80104516 <sys_close+0x3d>

8010451f <sys_fstat>:
{
8010451f:	55                   	push   %ebp
80104520:	89 e5                	mov    %esp,%ebp
80104522:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104525:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104528:	ba 00 00 00 00       	mov    $0x0,%edx
8010452d:	b8 00 00 00 00       	mov    $0x0,%eax
80104532:	e8 0d fc ff ff       	call   80104144 <argfd>
80104537:	85 c0                	test   %eax,%eax
80104539:	78 2a                	js     80104565 <sys_fstat+0x46>
8010453b:	83 ec 04             	sub    $0x4,%esp
8010453e:	6a 14                	push   $0x14
80104540:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104543:	50                   	push   %eax
80104544:	6a 01                	push   $0x1
80104546:	e8 09 fb ff ff       	call   80104054 <argptr>
8010454b:	83 c4 10             	add    $0x10,%esp
8010454e:	85 c0                	test   %eax,%eax
80104550:	78 1a                	js     8010456c <sys_fstat+0x4d>
  return filestat(f, st);
80104552:	83 ec 08             	sub    $0x8,%esp
80104555:	ff 75 f0             	pushl  -0x10(%ebp)
80104558:	ff 75 f4             	pushl  -0xc(%ebp)
8010455b:	e8 3c c8 ff ff       	call   80100d9c <filestat>
80104560:	83 c4 10             	add    $0x10,%esp
}
80104563:	c9                   	leave  
80104564:	c3                   	ret    
    return -1;
80104565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010456a:	eb f7                	jmp    80104563 <sys_fstat+0x44>
8010456c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104571:	eb f0                	jmp    80104563 <sys_fstat+0x44>

80104573 <sys_link>:
{
80104573:	55                   	push   %ebp
80104574:	89 e5                	mov    %esp,%ebp
80104576:	56                   	push   %esi
80104577:	53                   	push   %ebx
80104578:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010457b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010457e:	50                   	push   %eax
8010457f:	6a 00                	push   $0x0
80104581:	e8 36 fb ff ff       	call   801040bc <argstr>
80104586:	83 c4 10             	add    $0x10,%esp
80104589:	85 c0                	test   %eax,%eax
8010458b:	0f 88 32 01 00 00    	js     801046c3 <sys_link+0x150>
80104591:	83 ec 08             	sub    $0x8,%esp
80104594:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104597:	50                   	push   %eax
80104598:	6a 01                	push   $0x1
8010459a:	e8 1d fb ff ff       	call   801040bc <argstr>
8010459f:	83 c4 10             	add    $0x10,%esp
801045a2:	85 c0                	test   %eax,%eax
801045a4:	0f 88 20 01 00 00    	js     801046ca <sys_link+0x157>
  begin_op();
801045aa:	e8 89 e3 ff ff       	call   80102938 <begin_op>
  if((ip = namei(old)) == 0){
801045af:	83 ec 0c             	sub    $0xc,%esp
801045b2:	ff 75 e0             	pushl  -0x20(%ebp)
801045b5:	e8 33 d6 ff ff       	call   80101bed <namei>
801045ba:	89 c3                	mov    %eax,%ebx
801045bc:	83 c4 10             	add    $0x10,%esp
801045bf:	85 c0                	test   %eax,%eax
801045c1:	0f 84 99 00 00 00    	je     80104660 <sys_link+0xed>
  ilock(ip);
801045c7:	83 ec 0c             	sub    $0xc,%esp
801045ca:	50                   	push   %eax
801045cb:	e8 bd cf ff ff       	call   8010158d <ilock>
  if(ip->type == T_DIR){
801045d0:	83 c4 10             	add    $0x10,%esp
801045d3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045d8:	0f 84 8e 00 00 00    	je     8010466c <sys_link+0xf9>
  ip->nlink++;
801045de:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045e2:	83 c0 01             	add    $0x1,%eax
801045e5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045e9:	83 ec 0c             	sub    $0xc,%esp
801045ec:	53                   	push   %ebx
801045ed:	e8 3a ce ff ff       	call   8010142c <iupdate>
  iunlock(ip);
801045f2:	89 1c 24             	mov    %ebx,(%esp)
801045f5:	e8 55 d0 ff ff       	call   8010164f <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801045fa:	83 c4 08             	add    $0x8,%esp
801045fd:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104600:	50                   	push   %eax
80104601:	ff 75 e4             	pushl  -0x1c(%ebp)
80104604:	e8 fc d5 ff ff       	call   80101c05 <nameiparent>
80104609:	89 c6                	mov    %eax,%esi
8010460b:	83 c4 10             	add    $0x10,%esp
8010460e:	85 c0                	test   %eax,%eax
80104610:	74 7e                	je     80104690 <sys_link+0x11d>
  ilock(dp);
80104612:	83 ec 0c             	sub    $0xc,%esp
80104615:	50                   	push   %eax
80104616:	e8 72 cf ff ff       	call   8010158d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010461b:	83 c4 10             	add    $0x10,%esp
8010461e:	8b 03                	mov    (%ebx),%eax
80104620:	39 06                	cmp    %eax,(%esi)
80104622:	75 60                	jne    80104684 <sys_link+0x111>
80104624:	83 ec 04             	sub    $0x4,%esp
80104627:	ff 73 04             	pushl  0x4(%ebx)
8010462a:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010462d:	50                   	push   %eax
8010462e:	56                   	push   %esi
8010462f:	e8 08 d5 ff ff       	call   80101b3c <dirlink>
80104634:	83 c4 10             	add    $0x10,%esp
80104637:	85 c0                	test   %eax,%eax
80104639:	78 49                	js     80104684 <sys_link+0x111>
  iunlockput(dp);
8010463b:	83 ec 0c             	sub    $0xc,%esp
8010463e:	56                   	push   %esi
8010463f:	e8 f0 d0 ff ff       	call   80101734 <iunlockput>
  iput(ip);
80104644:	89 1c 24             	mov    %ebx,(%esp)
80104647:	e8 48 d0 ff ff       	call   80101694 <iput>
  end_op();
8010464c:	e8 61 e3 ff ff       	call   801029b2 <end_op>
  return 0;
80104651:	83 c4 10             	add    $0x10,%esp
80104654:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104659:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010465c:	5b                   	pop    %ebx
8010465d:	5e                   	pop    %esi
8010465e:	5d                   	pop    %ebp
8010465f:	c3                   	ret    
    end_op();
80104660:	e8 4d e3 ff ff       	call   801029b2 <end_op>
    return -1;
80104665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010466a:	eb ed                	jmp    80104659 <sys_link+0xe6>
    iunlockput(ip);
8010466c:	83 ec 0c             	sub    $0xc,%esp
8010466f:	53                   	push   %ebx
80104670:	e8 bf d0 ff ff       	call   80101734 <iunlockput>
    end_op();
80104675:	e8 38 e3 ff ff       	call   801029b2 <end_op>
    return -1;
8010467a:	83 c4 10             	add    $0x10,%esp
8010467d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104682:	eb d5                	jmp    80104659 <sys_link+0xe6>
    iunlockput(dp);
80104684:	83 ec 0c             	sub    $0xc,%esp
80104687:	56                   	push   %esi
80104688:	e8 a7 d0 ff ff       	call   80101734 <iunlockput>
    goto bad;
8010468d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104690:	83 ec 0c             	sub    $0xc,%esp
80104693:	53                   	push   %ebx
80104694:	e8 f4 ce ff ff       	call   8010158d <ilock>
  ip->nlink--;
80104699:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010469d:	83 e8 01             	sub    $0x1,%eax
801046a0:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046a4:	89 1c 24             	mov    %ebx,(%esp)
801046a7:	e8 80 cd ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801046ac:	89 1c 24             	mov    %ebx,(%esp)
801046af:	e8 80 d0 ff ff       	call   80101734 <iunlockput>
  end_op();
801046b4:	e8 f9 e2 ff ff       	call   801029b2 <end_op>
  return -1;
801046b9:	83 c4 10             	add    $0x10,%esp
801046bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c1:	eb 96                	jmp    80104659 <sys_link+0xe6>
    return -1;
801046c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c8:	eb 8f                	jmp    80104659 <sys_link+0xe6>
801046ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046cf:	eb 88                	jmp    80104659 <sys_link+0xe6>

801046d1 <sys_unlink>:
{
801046d1:	55                   	push   %ebp
801046d2:	89 e5                	mov    %esp,%ebp
801046d4:	57                   	push   %edi
801046d5:	56                   	push   %esi
801046d6:	53                   	push   %ebx
801046d7:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801046da:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046dd:	50                   	push   %eax
801046de:	6a 00                	push   $0x0
801046e0:	e8 d7 f9 ff ff       	call   801040bc <argstr>
801046e5:	83 c4 10             	add    $0x10,%esp
801046e8:	85 c0                	test   %eax,%eax
801046ea:	0f 88 83 01 00 00    	js     80104873 <sys_unlink+0x1a2>
  begin_op();
801046f0:	e8 43 e2 ff ff       	call   80102938 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801046f5:	83 ec 08             	sub    $0x8,%esp
801046f8:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046fb:	50                   	push   %eax
801046fc:	ff 75 c4             	pushl  -0x3c(%ebp)
801046ff:	e8 01 d5 ff ff       	call   80101c05 <nameiparent>
80104704:	89 c6                	mov    %eax,%esi
80104706:	83 c4 10             	add    $0x10,%esp
80104709:	85 c0                	test   %eax,%eax
8010470b:	0f 84 ed 00 00 00    	je     801047fe <sys_unlink+0x12d>
  ilock(dp);
80104711:	83 ec 0c             	sub    $0xc,%esp
80104714:	50                   	push   %eax
80104715:	e8 73 ce ff ff       	call   8010158d <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010471a:	83 c4 08             	add    $0x8,%esp
8010471d:	68 be 6d 10 80       	push   $0x80106dbe
80104722:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104725:	50                   	push   %eax
80104726:	e8 7c d2 ff ff       	call   801019a7 <namecmp>
8010472b:	83 c4 10             	add    $0x10,%esp
8010472e:	85 c0                	test   %eax,%eax
80104730:	0f 84 fc 00 00 00    	je     80104832 <sys_unlink+0x161>
80104736:	83 ec 08             	sub    $0x8,%esp
80104739:	68 bd 6d 10 80       	push   $0x80106dbd
8010473e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104741:	50                   	push   %eax
80104742:	e8 60 d2 ff ff       	call   801019a7 <namecmp>
80104747:	83 c4 10             	add    $0x10,%esp
8010474a:	85 c0                	test   %eax,%eax
8010474c:	0f 84 e0 00 00 00    	je     80104832 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104752:	83 ec 04             	sub    $0x4,%esp
80104755:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104758:	50                   	push   %eax
80104759:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010475c:	50                   	push   %eax
8010475d:	56                   	push   %esi
8010475e:	e8 59 d2 ff ff       	call   801019bc <dirlookup>
80104763:	89 c3                	mov    %eax,%ebx
80104765:	83 c4 10             	add    $0x10,%esp
80104768:	85 c0                	test   %eax,%eax
8010476a:	0f 84 c2 00 00 00    	je     80104832 <sys_unlink+0x161>
  ilock(ip);
80104770:	83 ec 0c             	sub    $0xc,%esp
80104773:	50                   	push   %eax
80104774:	e8 14 ce ff ff       	call   8010158d <ilock>
  if(ip->nlink < 1)
80104779:	83 c4 10             	add    $0x10,%esp
8010477c:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104781:	0f 8e 83 00 00 00    	jle    8010480a <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104787:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010478c:	0f 84 85 00 00 00    	je     80104817 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104792:	83 ec 04             	sub    $0x4,%esp
80104795:	6a 10                	push   $0x10
80104797:	6a 00                	push   $0x0
80104799:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010479c:	57                   	push   %edi
8010479d:	e8 3f f6 ff ff       	call   80103de1 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047a2:	6a 10                	push   $0x10
801047a4:	ff 75 c0             	pushl  -0x40(%ebp)
801047a7:	57                   	push   %edi
801047a8:	56                   	push   %esi
801047a9:	e8 ce d0 ff ff       	call   8010187c <writei>
801047ae:	83 c4 20             	add    $0x20,%esp
801047b1:	83 f8 10             	cmp    $0x10,%eax
801047b4:	0f 85 90 00 00 00    	jne    8010484a <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047ba:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047bf:	0f 84 92 00 00 00    	je     80104857 <sys_unlink+0x186>
  iunlockput(dp);
801047c5:	83 ec 0c             	sub    $0xc,%esp
801047c8:	56                   	push   %esi
801047c9:	e8 66 cf ff ff       	call   80101734 <iunlockput>
  ip->nlink--;
801047ce:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801047d2:	83 e8 01             	sub    $0x1,%eax
801047d5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801047d9:	89 1c 24             	mov    %ebx,(%esp)
801047dc:	e8 4b cc ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801047e1:	89 1c 24             	mov    %ebx,(%esp)
801047e4:	e8 4b cf ff ff       	call   80101734 <iunlockput>
  end_op();
801047e9:	e8 c4 e1 ff ff       	call   801029b2 <end_op>
  return 0;
801047ee:	83 c4 10             	add    $0x10,%esp
801047f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047f9:	5b                   	pop    %ebx
801047fa:	5e                   	pop    %esi
801047fb:	5f                   	pop    %edi
801047fc:	5d                   	pop    %ebp
801047fd:	c3                   	ret    
    end_op();
801047fe:	e8 af e1 ff ff       	call   801029b2 <end_op>
    return -1;
80104803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104808:	eb ec                	jmp    801047f6 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
8010480a:	83 ec 0c             	sub    $0xc,%esp
8010480d:	68 dc 6d 10 80       	push   $0x80106ddc
80104812:	e8 31 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104817:	89 d8                	mov    %ebx,%eax
80104819:	e8 c4 f9 ff ff       	call   801041e2 <isdirempty>
8010481e:	85 c0                	test   %eax,%eax
80104820:	0f 85 6c ff ff ff    	jne    80104792 <sys_unlink+0xc1>
    iunlockput(ip);
80104826:	83 ec 0c             	sub    $0xc,%esp
80104829:	53                   	push   %ebx
8010482a:	e8 05 cf ff ff       	call   80101734 <iunlockput>
    goto bad;
8010482f:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104832:	83 ec 0c             	sub    $0xc,%esp
80104835:	56                   	push   %esi
80104836:	e8 f9 ce ff ff       	call   80101734 <iunlockput>
  end_op();
8010483b:	e8 72 e1 ff ff       	call   801029b2 <end_op>
  return -1;
80104840:	83 c4 10             	add    $0x10,%esp
80104843:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104848:	eb ac                	jmp    801047f6 <sys_unlink+0x125>
    panic("unlink: writei");
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	68 ee 6d 10 80       	push   $0x80106dee
80104852:	e8 f1 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104857:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010485b:	83 e8 01             	sub    $0x1,%eax
8010485e:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	56                   	push   %esi
80104866:	e8 c1 cb ff ff       	call   8010142c <iupdate>
8010486b:	83 c4 10             	add    $0x10,%esp
8010486e:	e9 52 ff ff ff       	jmp    801047c5 <sys_unlink+0xf4>
    return -1;
80104873:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104878:	e9 79 ff ff ff       	jmp    801047f6 <sys_unlink+0x125>

8010487d <sys_open>:

int
sys_open(void)
{
8010487d:	55                   	push   %ebp
8010487e:	89 e5                	mov    %esp,%ebp
80104880:	57                   	push   %edi
80104881:	56                   	push   %esi
80104882:	53                   	push   %ebx
80104883:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104886:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104889:	50                   	push   %eax
8010488a:	6a 00                	push   $0x0
8010488c:	e8 2b f8 ff ff       	call   801040bc <argstr>
80104891:	83 c4 10             	add    $0x10,%esp
80104894:	85 c0                	test   %eax,%eax
80104896:	0f 88 30 01 00 00    	js     801049cc <sys_open+0x14f>
8010489c:	83 ec 08             	sub    $0x8,%esp
8010489f:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048a2:	50                   	push   %eax
801048a3:	6a 01                	push   $0x1
801048a5:	e8 82 f7 ff ff       	call   8010402c <argint>
801048aa:	83 c4 10             	add    $0x10,%esp
801048ad:	85 c0                	test   %eax,%eax
801048af:	0f 88 21 01 00 00    	js     801049d6 <sys_open+0x159>
    return -1;

  begin_op();
801048b5:	e8 7e e0 ff ff       	call   80102938 <begin_op>

  if(omode & O_CREATE){
801048ba:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048be:	0f 84 84 00 00 00    	je     80104948 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801048c4:	83 ec 0c             	sub    $0xc,%esp
801048c7:	6a 00                	push   $0x0
801048c9:	b9 00 00 00 00       	mov    $0x0,%ecx
801048ce:	ba 02 00 00 00       	mov    $0x2,%edx
801048d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801048d6:	e8 5e f9 ff ff       	call   80104239 <create>
801048db:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801048dd:	83 c4 10             	add    $0x10,%esp
801048e0:	85 c0                	test   %eax,%eax
801048e2:	74 58                	je     8010493c <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801048e4:	e8 50 c3 ff ff       	call   80100c39 <filealloc>
801048e9:	89 c3                	mov    %eax,%ebx
801048eb:	85 c0                	test   %eax,%eax
801048ed:	0f 84 ae 00 00 00    	je     801049a1 <sys_open+0x124>
801048f3:	e8 b3 f8 ff ff       	call   801041ab <fdalloc>
801048f8:	89 c7                	mov    %eax,%edi
801048fa:	85 c0                	test   %eax,%eax
801048fc:	0f 88 9f 00 00 00    	js     801049a1 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104902:	83 ec 0c             	sub    $0xc,%esp
80104905:	56                   	push   %esi
80104906:	e8 44 cd ff ff       	call   8010164f <iunlock>
  end_op();
8010490b:	e8 a2 e0 ff ff       	call   801029b2 <end_op>

  f->type = FD_INODE;
80104910:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104916:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104919:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104920:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104923:	83 c4 10             	add    $0x10,%esp
80104926:	a8 01                	test   $0x1,%al
80104928:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010492c:	a8 03                	test   $0x3,%al
8010492e:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104932:	89 f8                	mov    %edi,%eax
80104934:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104937:	5b                   	pop    %ebx
80104938:	5e                   	pop    %esi
80104939:	5f                   	pop    %edi
8010493a:	5d                   	pop    %ebp
8010493b:	c3                   	ret    
      end_op();
8010493c:	e8 71 e0 ff ff       	call   801029b2 <end_op>
      return -1;
80104941:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104946:	eb ea                	jmp    80104932 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104948:	83 ec 0c             	sub    $0xc,%esp
8010494b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010494e:	e8 9a d2 ff ff       	call   80101bed <namei>
80104953:	89 c6                	mov    %eax,%esi
80104955:	83 c4 10             	add    $0x10,%esp
80104958:	85 c0                	test   %eax,%eax
8010495a:	74 39                	je     80104995 <sys_open+0x118>
    ilock(ip);
8010495c:	83 ec 0c             	sub    $0xc,%esp
8010495f:	50                   	push   %eax
80104960:	e8 28 cc ff ff       	call   8010158d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104965:	83 c4 10             	add    $0x10,%esp
80104968:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010496d:	0f 85 71 ff ff ff    	jne    801048e4 <sys_open+0x67>
80104973:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104977:	0f 84 67 ff ff ff    	je     801048e4 <sys_open+0x67>
      iunlockput(ip);
8010497d:	83 ec 0c             	sub    $0xc,%esp
80104980:	56                   	push   %esi
80104981:	e8 ae cd ff ff       	call   80101734 <iunlockput>
      end_op();
80104986:	e8 27 e0 ff ff       	call   801029b2 <end_op>
      return -1;
8010498b:	83 c4 10             	add    $0x10,%esp
8010498e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104993:	eb 9d                	jmp    80104932 <sys_open+0xb5>
      end_op();
80104995:	e8 18 e0 ff ff       	call   801029b2 <end_op>
      return -1;
8010499a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010499f:	eb 91                	jmp    80104932 <sys_open+0xb5>
    if(f)
801049a1:	85 db                	test   %ebx,%ebx
801049a3:	74 0c                	je     801049b1 <sys_open+0x134>
      fileclose(f);
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	53                   	push   %ebx
801049a9:	e8 31 c3 ff ff       	call   80100cdf <fileclose>
801049ae:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049b1:	83 ec 0c             	sub    $0xc,%esp
801049b4:	56                   	push   %esi
801049b5:	e8 7a cd ff ff       	call   80101734 <iunlockput>
    end_op();
801049ba:	e8 f3 df ff ff       	call   801029b2 <end_op>
    return -1;
801049bf:	83 c4 10             	add    $0x10,%esp
801049c2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049c7:	e9 66 ff ff ff       	jmp    80104932 <sys_open+0xb5>
    return -1;
801049cc:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049d1:	e9 5c ff ff ff       	jmp    80104932 <sys_open+0xb5>
801049d6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049db:	e9 52 ff ff ff       	jmp    80104932 <sys_open+0xb5>

801049e0 <sys_mkdir>:

int
sys_mkdir(void)
{
801049e0:	55                   	push   %ebp
801049e1:	89 e5                	mov    %esp,%ebp
801049e3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801049e6:	e8 4d df ff ff       	call   80102938 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801049eb:	83 ec 08             	sub    $0x8,%esp
801049ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049f1:	50                   	push   %eax
801049f2:	6a 00                	push   $0x0
801049f4:	e8 c3 f6 ff ff       	call   801040bc <argstr>
801049f9:	83 c4 10             	add    $0x10,%esp
801049fc:	85 c0                	test   %eax,%eax
801049fe:	78 36                	js     80104a36 <sys_mkdir+0x56>
80104a00:	83 ec 0c             	sub    $0xc,%esp
80104a03:	6a 00                	push   $0x0
80104a05:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a0a:	ba 01 00 00 00       	mov    $0x1,%edx
80104a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a12:	e8 22 f8 ff ff       	call   80104239 <create>
80104a17:	83 c4 10             	add    $0x10,%esp
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	74 18                	je     80104a36 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a1e:	83 ec 0c             	sub    $0xc,%esp
80104a21:	50                   	push   %eax
80104a22:	e8 0d cd ff ff       	call   80101734 <iunlockput>
  end_op();
80104a27:	e8 86 df ff ff       	call   801029b2 <end_op>
  return 0;
80104a2c:	83 c4 10             	add    $0x10,%esp
80104a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a34:	c9                   	leave  
80104a35:	c3                   	ret    
    end_op();
80104a36:	e8 77 df ff ff       	call   801029b2 <end_op>
    return -1;
80104a3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a40:	eb f2                	jmp    80104a34 <sys_mkdir+0x54>

80104a42 <sys_mknod>:

int
sys_mknod(void)
{
80104a42:	55                   	push   %ebp
80104a43:	89 e5                	mov    %esp,%ebp
80104a45:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a48:	e8 eb de ff ff       	call   80102938 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a4d:	83 ec 08             	sub    $0x8,%esp
80104a50:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a53:	50                   	push   %eax
80104a54:	6a 00                	push   $0x0
80104a56:	e8 61 f6 ff ff       	call   801040bc <argstr>
80104a5b:	83 c4 10             	add    $0x10,%esp
80104a5e:	85 c0                	test   %eax,%eax
80104a60:	78 62                	js     80104ac4 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a62:	83 ec 08             	sub    $0x8,%esp
80104a65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a68:	50                   	push   %eax
80104a69:	6a 01                	push   $0x1
80104a6b:	e8 bc f5 ff ff       	call   8010402c <argint>
  if((argstr(0, &path)) < 0 ||
80104a70:	83 c4 10             	add    $0x10,%esp
80104a73:	85 c0                	test   %eax,%eax
80104a75:	78 4d                	js     80104ac4 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a77:	83 ec 08             	sub    $0x8,%esp
80104a7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a7d:	50                   	push   %eax
80104a7e:	6a 02                	push   $0x2
80104a80:	e8 a7 f5 ff ff       	call   8010402c <argint>
     argint(1, &major) < 0 ||
80104a85:	83 c4 10             	add    $0x10,%esp
80104a88:	85 c0                	test   %eax,%eax
80104a8a:	78 38                	js     80104ac4 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104a8c:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104a90:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104a94:	83 ec 0c             	sub    $0xc,%esp
80104a97:	50                   	push   %eax
80104a98:	ba 03 00 00 00       	mov    $0x3,%edx
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	e8 94 f7 ff ff       	call   80104239 <create>
80104aa5:	83 c4 10             	add    $0x10,%esp
80104aa8:	85 c0                	test   %eax,%eax
80104aaa:	74 18                	je     80104ac4 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104aac:	83 ec 0c             	sub    $0xc,%esp
80104aaf:	50                   	push   %eax
80104ab0:	e8 7f cc ff ff       	call   80101734 <iunlockput>
  end_op();
80104ab5:	e8 f8 de ff ff       	call   801029b2 <end_op>
  return 0;
80104aba:	83 c4 10             	add    $0x10,%esp
80104abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ac2:	c9                   	leave  
80104ac3:	c3                   	ret    
    end_op();
80104ac4:	e8 e9 de ff ff       	call   801029b2 <end_op>
    return -1;
80104ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ace:	eb f2                	jmp    80104ac2 <sys_mknod+0x80>

80104ad0 <sys_chdir>:

int
sys_chdir(void)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	56                   	push   %esi
80104ad4:	53                   	push   %ebx
80104ad5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104ad8:	e8 b6 e8 ff ff       	call   80103393 <myproc>
80104add:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104adf:	e8 54 de ff ff       	call   80102938 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104ae4:	83 ec 08             	sub    $0x8,%esp
80104ae7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104aea:	50                   	push   %eax
80104aeb:	6a 00                	push   $0x0
80104aed:	e8 ca f5 ff ff       	call   801040bc <argstr>
80104af2:	83 c4 10             	add    $0x10,%esp
80104af5:	85 c0                	test   %eax,%eax
80104af7:	78 52                	js     80104b4b <sys_chdir+0x7b>
80104af9:	83 ec 0c             	sub    $0xc,%esp
80104afc:	ff 75 f4             	pushl  -0xc(%ebp)
80104aff:	e8 e9 d0 ff ff       	call   80101bed <namei>
80104b04:	89 c3                	mov    %eax,%ebx
80104b06:	83 c4 10             	add    $0x10,%esp
80104b09:	85 c0                	test   %eax,%eax
80104b0b:	74 3e                	je     80104b4b <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b0d:	83 ec 0c             	sub    $0xc,%esp
80104b10:	50                   	push   %eax
80104b11:	e8 77 ca ff ff       	call   8010158d <ilock>
  if(ip->type != T_DIR){
80104b16:	83 c4 10             	add    $0x10,%esp
80104b19:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b1e:	75 37                	jne    80104b57 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b20:	83 ec 0c             	sub    $0xc,%esp
80104b23:	53                   	push   %ebx
80104b24:	e8 26 cb ff ff       	call   8010164f <iunlock>
  iput(curproc->cwd);
80104b29:	83 c4 04             	add    $0x4,%esp
80104b2c:	ff 76 68             	pushl  0x68(%esi)
80104b2f:	e8 60 cb ff ff       	call   80101694 <iput>
  end_op();
80104b34:	e8 79 de ff ff       	call   801029b2 <end_op>
  curproc->cwd = ip;
80104b39:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b3c:	83 c4 10             	add    $0x10,%esp
80104b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b44:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b47:	5b                   	pop    %ebx
80104b48:	5e                   	pop    %esi
80104b49:	5d                   	pop    %ebp
80104b4a:	c3                   	ret    
    end_op();
80104b4b:	e8 62 de ff ff       	call   801029b2 <end_op>
    return -1;
80104b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b55:	eb ed                	jmp    80104b44 <sys_chdir+0x74>
    iunlockput(ip);
80104b57:	83 ec 0c             	sub    $0xc,%esp
80104b5a:	53                   	push   %ebx
80104b5b:	e8 d4 cb ff ff       	call   80101734 <iunlockput>
    end_op();
80104b60:	e8 4d de ff ff       	call   801029b2 <end_op>
    return -1;
80104b65:	83 c4 10             	add    $0x10,%esp
80104b68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6d:	eb d5                	jmp    80104b44 <sys_chdir+0x74>

80104b6f <sys_exec>:

int
sys_exec(void)
{
80104b6f:	55                   	push   %ebp
80104b70:	89 e5                	mov    %esp,%ebp
80104b72:	53                   	push   %ebx
80104b73:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b79:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b7c:	50                   	push   %eax
80104b7d:	6a 00                	push   $0x0
80104b7f:	e8 38 f5 ff ff       	call   801040bc <argstr>
80104b84:	83 c4 10             	add    $0x10,%esp
80104b87:	85 c0                	test   %eax,%eax
80104b89:	0f 88 a8 00 00 00    	js     80104c37 <sys_exec+0xc8>
80104b8f:	83 ec 08             	sub    $0x8,%esp
80104b92:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104b98:	50                   	push   %eax
80104b99:	6a 01                	push   $0x1
80104b9b:	e8 8c f4 ff ff       	call   8010402c <argint>
80104ba0:	83 c4 10             	add    $0x10,%esp
80104ba3:	85 c0                	test   %eax,%eax
80104ba5:	0f 88 93 00 00 00    	js     80104c3e <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bab:	83 ec 04             	sub    $0x4,%esp
80104bae:	68 80 00 00 00       	push   $0x80
80104bb3:	6a 00                	push   $0x0
80104bb5:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bbb:	50                   	push   %eax
80104bbc:	e8 20 f2 ff ff       	call   80103de1 <memset>
80104bc1:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104bc4:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104bc9:	83 fb 1f             	cmp    $0x1f,%ebx
80104bcc:	77 77                	ja     80104c45 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104bce:	83 ec 08             	sub    $0x8,%esp
80104bd1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104bd7:	50                   	push   %eax
80104bd8:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104bde:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104be1:	50                   	push   %eax
80104be2:	e8 c9 f3 ff ff       	call   80103fb0 <fetchint>
80104be7:	83 c4 10             	add    $0x10,%esp
80104bea:	85 c0                	test   %eax,%eax
80104bec:	78 5e                	js     80104c4c <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104bee:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104bf4:	85 c0                	test   %eax,%eax
80104bf6:	74 1d                	je     80104c15 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104bf8:	83 ec 08             	sub    $0x8,%esp
80104bfb:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c02:	52                   	push   %edx
80104c03:	50                   	push   %eax
80104c04:	e8 e3 f3 ff ff       	call   80103fec <fetchstr>
80104c09:	83 c4 10             	add    $0x10,%esp
80104c0c:	85 c0                	test   %eax,%eax
80104c0e:	78 46                	js     80104c56 <sys_exec+0xe7>
  for(i=0;; i++){
80104c10:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c13:	eb b4                	jmp    80104bc9 <sys_exec+0x5a>
      argv[i] = 0;
80104c15:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c1c:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c20:	83 ec 08             	sub    $0x8,%esp
80104c23:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c29:	50                   	push   %eax
80104c2a:	ff 75 f4             	pushl  -0xc(%ebp)
80104c2d:	e8 a0 bc ff ff       	call   801008d2 <exec>
80104c32:	83 c4 10             	add    $0x10,%esp
80104c35:	eb 1a                	jmp    80104c51 <sys_exec+0xe2>
    return -1;
80104c37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c3c:	eb 13                	jmp    80104c51 <sys_exec+0xe2>
80104c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c43:	eb 0c                	jmp    80104c51 <sys_exec+0xe2>
      return -1;
80104c45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c4a:	eb 05                	jmp    80104c51 <sys_exec+0xe2>
      return -1;
80104c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c54:	c9                   	leave  
80104c55:	c3                   	ret    
      return -1;
80104c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c5b:	eb f4                	jmp    80104c51 <sys_exec+0xe2>

80104c5d <sys_pipe>:

int
sys_pipe(void)
{
80104c5d:	55                   	push   %ebp
80104c5e:	89 e5                	mov    %esp,%ebp
80104c60:	53                   	push   %ebx
80104c61:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c64:	6a 08                	push   $0x8
80104c66:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c69:	50                   	push   %eax
80104c6a:	6a 00                	push   $0x0
80104c6c:	e8 e3 f3 ff ff       	call   80104054 <argptr>
80104c71:	83 c4 10             	add    $0x10,%esp
80104c74:	85 c0                	test   %eax,%eax
80104c76:	78 77                	js     80104cef <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c78:	83 ec 08             	sub    $0x8,%esp
80104c7b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c7e:	50                   	push   %eax
80104c7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c82:	50                   	push   %eax
80104c83:	e8 3c e2 ff ff       	call   80102ec4 <pipealloc>
80104c88:	83 c4 10             	add    $0x10,%esp
80104c8b:	85 c0                	test   %eax,%eax
80104c8d:	78 67                	js     80104cf6 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c92:	e8 14 f5 ff ff       	call   801041ab <fdalloc>
80104c97:	89 c3                	mov    %eax,%ebx
80104c99:	85 c0                	test   %eax,%eax
80104c9b:	78 21                	js     80104cbe <sys_pipe+0x61>
80104c9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ca0:	e8 06 f5 ff ff       	call   801041ab <fdalloc>
80104ca5:	85 c0                	test   %eax,%eax
80104ca7:	78 15                	js     80104cbe <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104ca9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cac:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cb1:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cbc:	c9                   	leave  
80104cbd:	c3                   	ret    
    if(fd0 >= 0)
80104cbe:	85 db                	test   %ebx,%ebx
80104cc0:	78 0d                	js     80104ccf <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104cc2:	e8 cc e6 ff ff       	call   80103393 <myproc>
80104cc7:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104cce:	00 
    fileclose(rf);
80104ccf:	83 ec 0c             	sub    $0xc,%esp
80104cd2:	ff 75 f0             	pushl  -0x10(%ebp)
80104cd5:	e8 05 c0 ff ff       	call   80100cdf <fileclose>
    fileclose(wf);
80104cda:	83 c4 04             	add    $0x4,%esp
80104cdd:	ff 75 ec             	pushl  -0x14(%ebp)
80104ce0:	e8 fa bf ff ff       	call   80100cdf <fileclose>
    return -1;
80104ce5:	83 c4 10             	add    $0x10,%esp
80104ce8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ced:	eb ca                	jmp    80104cb9 <sys_pipe+0x5c>
    return -1;
80104cef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf4:	eb c3                	jmp    80104cb9 <sys_pipe+0x5c>
    return -1;
80104cf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cfb:	eb bc                	jmp    80104cb9 <sys_pipe+0x5c>

80104cfd <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104cfd:	55                   	push   %ebp
80104cfe:	89 e5                	mov    %esp,%ebp
80104d00:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d03:	e8 03 e8 ff ff       	call   8010350b <fork>
}
80104d08:	c9                   	leave  
80104d09:	c3                   	ret    

80104d0a <sys_exit>:

int
sys_exit(void)
{
80104d0a:	55                   	push   %ebp
80104d0b:	89 e5                	mov    %esp,%ebp
80104d0d:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d10:	e8 2d ea ff ff       	call   80103742 <exit>
  return 0;  // not reached
}
80104d15:	b8 00 00 00 00       	mov    $0x0,%eax
80104d1a:	c9                   	leave  
80104d1b:	c3                   	ret    

80104d1c <sys_wait>:

int
sys_wait(void)
{
80104d1c:	55                   	push   %ebp
80104d1d:	89 e5                	mov    %esp,%ebp
80104d1f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d22:	e8 a4 eb ff ff       	call   801038cb <wait>
}
80104d27:	c9                   	leave  
80104d28:	c3                   	ret    

80104d29 <sys_kill>:

int
sys_kill(void)
{
80104d29:	55                   	push   %ebp
80104d2a:	89 e5                	mov    %esp,%ebp
80104d2c:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d32:	50                   	push   %eax
80104d33:	6a 00                	push   $0x0
80104d35:	e8 f2 f2 ff ff       	call   8010402c <argint>
80104d3a:	83 c4 10             	add    $0x10,%esp
80104d3d:	85 c0                	test   %eax,%eax
80104d3f:	78 10                	js     80104d51 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d41:	83 ec 0c             	sub    $0xc,%esp
80104d44:	ff 75 f4             	pushl  -0xc(%ebp)
80104d47:	e8 7c ec ff ff       	call   801039c8 <kill>
80104d4c:	83 c4 10             	add    $0x10,%esp
}
80104d4f:	c9                   	leave  
80104d50:	c3                   	ret    
    return -1;
80104d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d56:	eb f7                	jmp    80104d4f <sys_kill+0x26>

80104d58 <sys_getpid>:

int
sys_getpid(void)
{
80104d58:	55                   	push   %ebp
80104d59:	89 e5                	mov    %esp,%ebp
80104d5b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104d5e:	e8 30 e6 ff ff       	call   80103393 <myproc>
80104d63:	8b 40 10             	mov    0x10(%eax),%eax
}
80104d66:	c9                   	leave  
80104d67:	c3                   	ret    

80104d68 <sys_sbrk>:

int
sys_sbrk(void)
{
80104d68:	55                   	push   %ebp
80104d69:	89 e5                	mov    %esp,%ebp
80104d6b:	53                   	push   %ebx
80104d6c:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d72:	50                   	push   %eax
80104d73:	6a 00                	push   $0x0
80104d75:	e8 b2 f2 ff ff       	call   8010402c <argint>
80104d7a:	83 c4 10             	add    $0x10,%esp
80104d7d:	85 c0                	test   %eax,%eax
80104d7f:	78 27                	js     80104da8 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104d81:	e8 0d e6 ff ff       	call   80103393 <myproc>
80104d86:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104d88:	83 ec 0c             	sub    $0xc,%esp
80104d8b:	ff 75 f4             	pushl  -0xc(%ebp)
80104d8e:	e8 0b e7 ff ff       	call   8010349e <growproc>
80104d93:	83 c4 10             	add    $0x10,%esp
80104d96:	85 c0                	test   %eax,%eax
80104d98:	78 07                	js     80104da1 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104d9a:	89 d8                	mov    %ebx,%eax
80104d9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d9f:	c9                   	leave  
80104da0:	c3                   	ret    
    return -1;
80104da1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104da6:	eb f2                	jmp    80104d9a <sys_sbrk+0x32>
    return -1;
80104da8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dad:	eb eb                	jmp    80104d9a <sys_sbrk+0x32>

80104daf <sys_sleep>:

int
sys_sleep(void)
{
80104daf:	55                   	push   %ebp
80104db0:	89 e5                	mov    %esp,%ebp
80104db2:	53                   	push   %ebx
80104db3:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104db9:	50                   	push   %eax
80104dba:	6a 00                	push   $0x0
80104dbc:	e8 6b f2 ff ff       	call   8010402c <argint>
80104dc1:	83 c4 10             	add    $0x10,%esp
80104dc4:	85 c0                	test   %eax,%eax
80104dc6:	78 75                	js     80104e3d <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104dc8:	83 ec 0c             	sub    $0xc,%esp
80104dcb:	68 c0 4c 14 80       	push   $0x80144cc0
80104dd0:	e8 60 ef ff ff       	call   80103d35 <acquire>
  ticks0 = ticks;
80104dd5:	8b 1d 00 55 14 80    	mov    0x80145500,%ebx
  while(ticks - ticks0 < n){
80104ddb:	83 c4 10             	add    $0x10,%esp
80104dde:	a1 00 55 14 80       	mov    0x80145500,%eax
80104de3:	29 d8                	sub    %ebx,%eax
80104de5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104de8:	73 39                	jae    80104e23 <sys_sleep+0x74>
    if(myproc()->killed){
80104dea:	e8 a4 e5 ff ff       	call   80103393 <myproc>
80104def:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104df3:	75 17                	jne    80104e0c <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104df5:	83 ec 08             	sub    $0x8,%esp
80104df8:	68 c0 4c 14 80       	push   $0x80144cc0
80104dfd:	68 00 55 14 80       	push   $0x80145500
80104e02:	e8 33 ea ff ff       	call   8010383a <sleep>
80104e07:	83 c4 10             	add    $0x10,%esp
80104e0a:	eb d2                	jmp    80104dde <sys_sleep+0x2f>
      release(&tickslock);
80104e0c:	83 ec 0c             	sub    $0xc,%esp
80104e0f:	68 c0 4c 14 80       	push   $0x80144cc0
80104e14:	e8 81 ef ff ff       	call   80103d9a <release>
      return -1;
80104e19:	83 c4 10             	add    $0x10,%esp
80104e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e21:	eb 15                	jmp    80104e38 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e23:	83 ec 0c             	sub    $0xc,%esp
80104e26:	68 c0 4c 14 80       	push   $0x80144cc0
80104e2b:	e8 6a ef ff ff       	call   80103d9a <release>
  return 0;
80104e30:	83 c4 10             	add    $0x10,%esp
80104e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e3b:	c9                   	leave  
80104e3c:	c3                   	ret    
    return -1;
80104e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e42:	eb f4                	jmp    80104e38 <sys_sleep+0x89>

80104e44 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e44:	55                   	push   %ebp
80104e45:	89 e5                	mov    %esp,%ebp
80104e47:	53                   	push   %ebx
80104e48:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e4b:	68 c0 4c 14 80       	push   $0x80144cc0
80104e50:	e8 e0 ee ff ff       	call   80103d35 <acquire>
  xticks = ticks;
80104e55:	8b 1d 00 55 14 80    	mov    0x80145500,%ebx
  release(&tickslock);
80104e5b:	c7 04 24 c0 4c 14 80 	movl   $0x80144cc0,(%esp)
80104e62:	e8 33 ef ff ff       	call   80103d9a <release>
  return xticks;
}
80104e67:	89 d8                	mov    %ebx,%eax
80104e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e6c:	c9                   	leave  
80104e6d:	c3                   	ret    

80104e6e <sys_dump_physmem>:

int
sys_dump_physmem(void) {
80104e6e:	55                   	push   %ebp
80104e6f:	89 e5                	mov    %esp,%ebp
80104e71:	83 ec 1c             	sub    $0x1c,%esp
    int* frames;
    int* pids;
    int numframes;
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104e74:	6a 04                	push   $0x4
80104e76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e79:	50                   	push   %eax
80104e7a:	6a 00                	push   $0x0
80104e7c:	e8 d3 f1 ff ff       	call   80104054 <argptr>
80104e81:	83 c4 10             	add    $0x10,%esp
80104e84:	85 c0                	test   %eax,%eax
80104e86:	78 42                	js     80104eca <sys_dump_physmem+0x5c>
80104e88:	83 ec 04             	sub    $0x4,%esp
80104e8b:	6a 04                	push   $0x4
80104e8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e90:	50                   	push   %eax
80104e91:	6a 01                	push   $0x1
80104e93:	e8 bc f1 ff ff       	call   80104054 <argptr>
80104e98:	83 c4 10             	add    $0x10,%esp
80104e9b:	85 c0                	test   %eax,%eax
80104e9d:	78 32                	js     80104ed1 <sys_dump_physmem+0x63>
    argint(2, &numframes) < 0) {
80104e9f:	83 ec 08             	sub    $0x8,%esp
80104ea2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ea5:	50                   	push   %eax
80104ea6:	6a 02                	push   $0x2
80104ea8:	e8 7f f1 ff ff       	call   8010402c <argint>
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104ead:	83 c4 10             	add    $0x10,%esp
80104eb0:	85 c0                	test   %eax,%eax
80104eb2:	78 24                	js     80104ed8 <sys_dump_physmem+0x6a>
        return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104eb4:	83 ec 04             	sub    $0x4,%esp
80104eb7:	ff 75 ec             	pushl  -0x14(%ebp)
80104eba:	ff 75 f0             	pushl  -0x10(%ebp)
80104ebd:	ff 75 f4             	pushl  -0xc(%ebp)
80104ec0:	e8 73 d3 ff ff       	call   80102238 <dump_physmem>
80104ec5:	83 c4 10             	add    $0x10,%esp
80104ec8:	c9                   	leave  
80104ec9:	c3                   	ret    
        return -1;
80104eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ecf:	eb f7                	jmp    80104ec8 <sys_dump_physmem+0x5a>
80104ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed6:	eb f0                	jmp    80104ec8 <sys_dump_physmem+0x5a>
80104ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104edd:	eb e9                	jmp    80104ec8 <sys_dump_physmem+0x5a>

80104edf <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104edf:	1e                   	push   %ds
  pushl %es
80104ee0:	06                   	push   %es
  pushl %fs
80104ee1:	0f a0                	push   %fs
  pushl %gs
80104ee3:	0f a8                	push   %gs
  pushal
80104ee5:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104ee6:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104eea:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104eec:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104eee:	54                   	push   %esp
  call trap
80104eef:	e8 e3 00 00 00       	call   80104fd7 <trap>
  addl $4, %esp
80104ef4:	83 c4 04             	add    $0x4,%esp

80104ef7 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104ef7:	61                   	popa   
  popl %gs
80104ef8:	0f a9                	pop    %gs
  popl %fs
80104efa:	0f a1                	pop    %fs
  popl %es
80104efc:	07                   	pop    %es
  popl %ds
80104efd:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104efe:	83 c4 08             	add    $0x8,%esp
  iret
80104f01:	cf                   	iret   

80104f02 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f02:	55                   	push   %ebp
80104f03:	89 e5                	mov    %esp,%ebp
80104f05:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f08:	b8 00 00 00 00       	mov    $0x0,%eax
80104f0d:	eb 4a                	jmp    80104f59 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f0f:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f16:	66 89 0c c5 00 4d 14 	mov    %cx,-0x7febb300(,%eax,8)
80104f1d:	80 
80104f1e:	66 c7 04 c5 02 4d 14 	movw   $0x8,-0x7febb2fe(,%eax,8)
80104f25:	80 08 00 
80104f28:	c6 04 c5 04 4d 14 80 	movb   $0x0,-0x7febb2fc(,%eax,8)
80104f2f:	00 
80104f30:	0f b6 14 c5 05 4d 14 	movzbl -0x7febb2fb(,%eax,8),%edx
80104f37:	80 
80104f38:	83 e2 f0             	and    $0xfffffff0,%edx
80104f3b:	83 ca 0e             	or     $0xe,%edx
80104f3e:	83 e2 8f             	and    $0xffffff8f,%edx
80104f41:	83 ca 80             	or     $0xffffff80,%edx
80104f44:	88 14 c5 05 4d 14 80 	mov    %dl,-0x7febb2fb(,%eax,8)
80104f4b:	c1 e9 10             	shr    $0x10,%ecx
80104f4e:	66 89 0c c5 06 4d 14 	mov    %cx,-0x7febb2fa(,%eax,8)
80104f55:	80 
  for(i = 0; i < 256; i++)
80104f56:	83 c0 01             	add    $0x1,%eax
80104f59:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f5e:	7e af                	jle    80104f0f <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f60:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f66:	66 89 15 00 4f 14 80 	mov    %dx,0x80144f00
80104f6d:	66 c7 05 02 4f 14 80 	movw   $0x8,0x80144f02
80104f74:	08 00 
80104f76:	c6 05 04 4f 14 80 00 	movb   $0x0,0x80144f04
80104f7d:	0f b6 05 05 4f 14 80 	movzbl 0x80144f05,%eax
80104f84:	83 c8 0f             	or     $0xf,%eax
80104f87:	83 e0 ef             	and    $0xffffffef,%eax
80104f8a:	83 c8 e0             	or     $0xffffffe0,%eax
80104f8d:	a2 05 4f 14 80       	mov    %al,0x80144f05
80104f92:	c1 ea 10             	shr    $0x10,%edx
80104f95:	66 89 15 06 4f 14 80 	mov    %dx,0x80144f06

  initlock(&tickslock, "time");
80104f9c:	83 ec 08             	sub    $0x8,%esp
80104f9f:	68 fd 6d 10 80       	push   $0x80106dfd
80104fa4:	68 c0 4c 14 80       	push   $0x80144cc0
80104fa9:	e8 4b ec ff ff       	call   80103bf9 <initlock>
}
80104fae:	83 c4 10             	add    $0x10,%esp
80104fb1:	c9                   	leave  
80104fb2:	c3                   	ret    

80104fb3 <idtinit>:

void
idtinit(void)
{
80104fb3:	55                   	push   %ebp
80104fb4:	89 e5                	mov    %esp,%ebp
80104fb6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104fb9:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104fbf:	b8 00 4d 14 80       	mov    $0x80144d00,%eax
80104fc4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104fc8:	c1 e8 10             	shr    $0x10,%eax
80104fcb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104fcf:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104fd2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104fd5:	c9                   	leave  
80104fd6:	c3                   	ret    

80104fd7 <trap>:

void
trap(struct trapframe *tf)
{
80104fd7:	55                   	push   %ebp
80104fd8:	89 e5                	mov    %esp,%ebp
80104fda:	57                   	push   %edi
80104fdb:	56                   	push   %esi
80104fdc:	53                   	push   %ebx
80104fdd:	83 ec 1c             	sub    $0x1c,%esp
80104fe0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104fe3:	8b 43 30             	mov    0x30(%ebx),%eax
80104fe6:	83 f8 40             	cmp    $0x40,%eax
80104fe9:	74 13                	je     80104ffe <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104feb:	83 e8 20             	sub    $0x20,%eax
80104fee:	83 f8 1f             	cmp    $0x1f,%eax
80104ff1:	0f 87 3a 01 00 00    	ja     80105131 <trap+0x15a>
80104ff7:	ff 24 85 a4 6e 10 80 	jmp    *-0x7fef915c(,%eax,4)
    if(myproc()->killed)
80104ffe:	e8 90 e3 ff ff       	call   80103393 <myproc>
80105003:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105007:	75 1f                	jne    80105028 <trap+0x51>
    myproc()->tf = tf;
80105009:	e8 85 e3 ff ff       	call   80103393 <myproc>
8010500e:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105011:	e8 d9 f0 ff ff       	call   801040ef <syscall>
    if(myproc()->killed)
80105016:	e8 78 e3 ff ff       	call   80103393 <myproc>
8010501b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010501f:	74 7e                	je     8010509f <trap+0xc8>
      exit();
80105021:	e8 1c e7 ff ff       	call   80103742 <exit>
80105026:	eb 77                	jmp    8010509f <trap+0xc8>
      exit();
80105028:	e8 15 e7 ff ff       	call   80103742 <exit>
8010502d:	eb da                	jmp    80105009 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010502f:	e8 44 e3 ff ff       	call   80103378 <cpuid>
80105034:	85 c0                	test   %eax,%eax
80105036:	74 6f                	je     801050a7 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105038:	e8 e6 d4 ff ff       	call   80102523 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010503d:	e8 51 e3 ff ff       	call   80103393 <myproc>
80105042:	85 c0                	test   %eax,%eax
80105044:	74 1c                	je     80105062 <trap+0x8b>
80105046:	e8 48 e3 ff ff       	call   80103393 <myproc>
8010504b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010504f:	74 11                	je     80105062 <trap+0x8b>
80105051:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105055:	83 e0 03             	and    $0x3,%eax
80105058:	66 83 f8 03          	cmp    $0x3,%ax
8010505c:	0f 84 62 01 00 00    	je     801051c4 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105062:	e8 2c e3 ff ff       	call   80103393 <myproc>
80105067:	85 c0                	test   %eax,%eax
80105069:	74 0f                	je     8010507a <trap+0xa3>
8010506b:	e8 23 e3 ff ff       	call   80103393 <myproc>
80105070:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105074:	0f 84 54 01 00 00    	je     801051ce <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010507a:	e8 14 e3 ff ff       	call   80103393 <myproc>
8010507f:	85 c0                	test   %eax,%eax
80105081:	74 1c                	je     8010509f <trap+0xc8>
80105083:	e8 0b e3 ff ff       	call   80103393 <myproc>
80105088:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010508c:	74 11                	je     8010509f <trap+0xc8>
8010508e:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105092:	83 e0 03             	and    $0x3,%eax
80105095:	66 83 f8 03          	cmp    $0x3,%ax
80105099:	0f 84 43 01 00 00    	je     801051e2 <trap+0x20b>
    exit();
}
8010509f:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050a2:	5b                   	pop    %ebx
801050a3:	5e                   	pop    %esi
801050a4:	5f                   	pop    %edi
801050a5:	5d                   	pop    %ebp
801050a6:	c3                   	ret    
      acquire(&tickslock);
801050a7:	83 ec 0c             	sub    $0xc,%esp
801050aa:	68 c0 4c 14 80       	push   $0x80144cc0
801050af:	e8 81 ec ff ff       	call   80103d35 <acquire>
      ticks++;
801050b4:	83 05 00 55 14 80 01 	addl   $0x1,0x80145500
      wakeup(&ticks);
801050bb:	c7 04 24 00 55 14 80 	movl   $0x80145500,(%esp)
801050c2:	e8 d8 e8 ff ff       	call   8010399f <wakeup>
      release(&tickslock);
801050c7:	c7 04 24 c0 4c 14 80 	movl   $0x80144cc0,(%esp)
801050ce:	e8 c7 ec ff ff       	call   80103d9a <release>
801050d3:	83 c4 10             	add    $0x10,%esp
801050d6:	e9 5d ff ff ff       	jmp    80105038 <trap+0x61>
    ideintr();
801050db:	e8 9f cc ff ff       	call   80101d7f <ideintr>
    lapiceoi();
801050e0:	e8 3e d4 ff ff       	call   80102523 <lapiceoi>
    break;
801050e5:	e9 53 ff ff ff       	jmp    8010503d <trap+0x66>
    kbdintr();
801050ea:	e8 78 d2 ff ff       	call   80102367 <kbdintr>
    lapiceoi();
801050ef:	e8 2f d4 ff ff       	call   80102523 <lapiceoi>
    break;
801050f4:	e9 44 ff ff ff       	jmp    8010503d <trap+0x66>
    uartintr();
801050f9:	e8 05 02 00 00       	call   80105303 <uartintr>
    lapiceoi();
801050fe:	e8 20 d4 ff ff       	call   80102523 <lapiceoi>
    break;
80105103:	e9 35 ff ff ff       	jmp    8010503d <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105108:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010510b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010510f:	e8 64 e2 ff ff       	call   80103378 <cpuid>
80105114:	57                   	push   %edi
80105115:	0f b7 f6             	movzwl %si,%esi
80105118:	56                   	push   %esi
80105119:	50                   	push   %eax
8010511a:	68 08 6e 10 80       	push   $0x80106e08
8010511f:	e8 e7 b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105124:	e8 fa d3 ff ff       	call   80102523 <lapiceoi>
    break;
80105129:	83 c4 10             	add    $0x10,%esp
8010512c:	e9 0c ff ff ff       	jmp    8010503d <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105131:	e8 5d e2 ff ff       	call   80103393 <myproc>
80105136:	85 c0                	test   %eax,%eax
80105138:	74 5f                	je     80105199 <trap+0x1c2>
8010513a:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010513e:	74 59                	je     80105199 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105140:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105143:	8b 43 38             	mov    0x38(%ebx),%eax
80105146:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105149:	e8 2a e2 ff ff       	call   80103378 <cpuid>
8010514e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105151:	8b 53 34             	mov    0x34(%ebx),%edx
80105154:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105157:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
8010515a:	e8 34 e2 ff ff       	call   80103393 <myproc>
8010515f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105162:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105165:	e8 29 e2 ff ff       	call   80103393 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010516a:	57                   	push   %edi
8010516b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010516e:	ff 75 e0             	pushl  -0x20(%ebp)
80105171:	ff 75 dc             	pushl  -0x24(%ebp)
80105174:	56                   	push   %esi
80105175:	ff 75 d8             	pushl  -0x28(%ebp)
80105178:	ff 70 10             	pushl  0x10(%eax)
8010517b:	68 60 6e 10 80       	push   $0x80106e60
80105180:	e8 86 b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105185:	83 c4 20             	add    $0x20,%esp
80105188:	e8 06 e2 ff ff       	call   80103393 <myproc>
8010518d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105194:	e9 a4 fe ff ff       	jmp    8010503d <trap+0x66>
80105199:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010519c:	8b 73 38             	mov    0x38(%ebx),%esi
8010519f:	e8 d4 e1 ff ff       	call   80103378 <cpuid>
801051a4:	83 ec 0c             	sub    $0xc,%esp
801051a7:	57                   	push   %edi
801051a8:	56                   	push   %esi
801051a9:	50                   	push   %eax
801051aa:	ff 73 30             	pushl  0x30(%ebx)
801051ad:	68 2c 6e 10 80       	push   $0x80106e2c
801051b2:	e8 54 b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
801051b7:	83 c4 14             	add    $0x14,%esp
801051ba:	68 02 6e 10 80       	push   $0x80106e02
801051bf:	e8 84 b1 ff ff       	call   80100348 <panic>
    exit();
801051c4:	e8 79 e5 ff ff       	call   80103742 <exit>
801051c9:	e9 94 fe ff ff       	jmp    80105062 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801051ce:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801051d2:	0f 85 a2 fe ff ff    	jne    8010507a <trap+0xa3>
    yield();
801051d8:	e8 2b e6 ff ff       	call   80103808 <yield>
801051dd:	e9 98 fe ff ff       	jmp    8010507a <trap+0xa3>
    exit();
801051e2:	e8 5b e5 ff ff       	call   80103742 <exit>
801051e7:	e9 b3 fe ff ff       	jmp    8010509f <trap+0xc8>

801051ec <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801051ec:	55                   	push   %ebp
801051ed:	89 e5                	mov    %esp,%ebp
  if(!uart)
801051ef:	83 3d e8 a5 11 80 00 	cmpl   $0x0,0x8011a5e8
801051f6:	74 15                	je     8010520d <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051f8:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051fd:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051fe:	a8 01                	test   $0x1,%al
80105200:	74 12                	je     80105214 <uartgetc+0x28>
80105202:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105207:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105208:	0f b6 c0             	movzbl %al,%eax
}
8010520b:	5d                   	pop    %ebp
8010520c:	c3                   	ret    
    return -1;
8010520d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105212:	eb f7                	jmp    8010520b <uartgetc+0x1f>
    return -1;
80105214:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105219:	eb f0                	jmp    8010520b <uartgetc+0x1f>

8010521b <uartputc>:
  if(!uart)
8010521b:	83 3d e8 a5 11 80 00 	cmpl   $0x0,0x8011a5e8
80105222:	74 3b                	je     8010525f <uartputc+0x44>
{
80105224:	55                   	push   %ebp
80105225:	89 e5                	mov    %esp,%ebp
80105227:	53                   	push   %ebx
80105228:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010522b:	bb 00 00 00 00       	mov    $0x0,%ebx
80105230:	eb 10                	jmp    80105242 <uartputc+0x27>
    microdelay(10);
80105232:	83 ec 0c             	sub    $0xc,%esp
80105235:	6a 0a                	push   $0xa
80105237:	e8 06 d3 ff ff       	call   80102542 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010523c:	83 c3 01             	add    $0x1,%ebx
8010523f:	83 c4 10             	add    $0x10,%esp
80105242:	83 fb 7f             	cmp    $0x7f,%ebx
80105245:	7f 0a                	jg     80105251 <uartputc+0x36>
80105247:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010524c:	ec                   	in     (%dx),%al
8010524d:	a8 20                	test   $0x20,%al
8010524f:	74 e1                	je     80105232 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105251:	8b 45 08             	mov    0x8(%ebp),%eax
80105254:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105259:	ee                   	out    %al,(%dx)
}
8010525a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010525d:	c9                   	leave  
8010525e:	c3                   	ret    
8010525f:	f3 c3                	repz ret 

80105261 <uartinit>:
{
80105261:	55                   	push   %ebp
80105262:	89 e5                	mov    %esp,%ebp
80105264:	56                   	push   %esi
80105265:	53                   	push   %ebx
80105266:	b9 00 00 00 00       	mov    $0x0,%ecx
8010526b:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105270:	89 c8                	mov    %ecx,%eax
80105272:	ee                   	out    %al,(%dx)
80105273:	be fb 03 00 00       	mov    $0x3fb,%esi
80105278:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010527d:	89 f2                	mov    %esi,%edx
8010527f:	ee                   	out    %al,(%dx)
80105280:	b8 0c 00 00 00       	mov    $0xc,%eax
80105285:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010528a:	ee                   	out    %al,(%dx)
8010528b:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105290:	89 c8                	mov    %ecx,%eax
80105292:	89 da                	mov    %ebx,%edx
80105294:	ee                   	out    %al,(%dx)
80105295:	b8 03 00 00 00       	mov    $0x3,%eax
8010529a:	89 f2                	mov    %esi,%edx
8010529c:	ee                   	out    %al,(%dx)
8010529d:	ba fc 03 00 00       	mov    $0x3fc,%edx
801052a2:	89 c8                	mov    %ecx,%eax
801052a4:	ee                   	out    %al,(%dx)
801052a5:	b8 01 00 00 00       	mov    $0x1,%eax
801052aa:	89 da                	mov    %ebx,%edx
801052ac:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052ad:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052b2:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801052b3:	3c ff                	cmp    $0xff,%al
801052b5:	74 45                	je     801052fc <uartinit+0x9b>
  uart = 1;
801052b7:	c7 05 e8 a5 11 80 01 	movl   $0x1,0x8011a5e8
801052be:	00 00 00 
801052c1:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052c6:	ec                   	in     (%dx),%al
801052c7:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052cc:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801052cd:	83 ec 08             	sub    $0x8,%esp
801052d0:	6a 00                	push   $0x0
801052d2:	6a 04                	push   $0x4
801052d4:	e8 b1 cc ff ff       	call   80101f8a <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801052d9:	83 c4 10             	add    $0x10,%esp
801052dc:	bb 24 6f 10 80       	mov    $0x80106f24,%ebx
801052e1:	eb 12                	jmp    801052f5 <uartinit+0x94>
    uartputc(*p);
801052e3:	83 ec 0c             	sub    $0xc,%esp
801052e6:	0f be c0             	movsbl %al,%eax
801052e9:	50                   	push   %eax
801052ea:	e8 2c ff ff ff       	call   8010521b <uartputc>
  for(p="xv6...\n"; *p; p++)
801052ef:	83 c3 01             	add    $0x1,%ebx
801052f2:	83 c4 10             	add    $0x10,%esp
801052f5:	0f b6 03             	movzbl (%ebx),%eax
801052f8:	84 c0                	test   %al,%al
801052fa:	75 e7                	jne    801052e3 <uartinit+0x82>
}
801052fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052ff:	5b                   	pop    %ebx
80105300:	5e                   	pop    %esi
80105301:	5d                   	pop    %ebp
80105302:	c3                   	ret    

80105303 <uartintr>:

void
uartintr(void)
{
80105303:	55                   	push   %ebp
80105304:	89 e5                	mov    %esp,%ebp
80105306:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105309:	68 ec 51 10 80       	push   $0x801051ec
8010530e:	e8 2b b4 ff ff       	call   8010073e <consoleintr>
}
80105313:	83 c4 10             	add    $0x10,%esp
80105316:	c9                   	leave  
80105317:	c3                   	ret    

80105318 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105318:	6a 00                	push   $0x0
  pushl $0
8010531a:	6a 00                	push   $0x0
  jmp alltraps
8010531c:	e9 be fb ff ff       	jmp    80104edf <alltraps>

80105321 <vector1>:
.globl vector1
vector1:
  pushl $0
80105321:	6a 00                	push   $0x0
  pushl $1
80105323:	6a 01                	push   $0x1
  jmp alltraps
80105325:	e9 b5 fb ff ff       	jmp    80104edf <alltraps>

8010532a <vector2>:
.globl vector2
vector2:
  pushl $0
8010532a:	6a 00                	push   $0x0
  pushl $2
8010532c:	6a 02                	push   $0x2
  jmp alltraps
8010532e:	e9 ac fb ff ff       	jmp    80104edf <alltraps>

80105333 <vector3>:
.globl vector3
vector3:
  pushl $0
80105333:	6a 00                	push   $0x0
  pushl $3
80105335:	6a 03                	push   $0x3
  jmp alltraps
80105337:	e9 a3 fb ff ff       	jmp    80104edf <alltraps>

8010533c <vector4>:
.globl vector4
vector4:
  pushl $0
8010533c:	6a 00                	push   $0x0
  pushl $4
8010533e:	6a 04                	push   $0x4
  jmp alltraps
80105340:	e9 9a fb ff ff       	jmp    80104edf <alltraps>

80105345 <vector5>:
.globl vector5
vector5:
  pushl $0
80105345:	6a 00                	push   $0x0
  pushl $5
80105347:	6a 05                	push   $0x5
  jmp alltraps
80105349:	e9 91 fb ff ff       	jmp    80104edf <alltraps>

8010534e <vector6>:
.globl vector6
vector6:
  pushl $0
8010534e:	6a 00                	push   $0x0
  pushl $6
80105350:	6a 06                	push   $0x6
  jmp alltraps
80105352:	e9 88 fb ff ff       	jmp    80104edf <alltraps>

80105357 <vector7>:
.globl vector7
vector7:
  pushl $0
80105357:	6a 00                	push   $0x0
  pushl $7
80105359:	6a 07                	push   $0x7
  jmp alltraps
8010535b:	e9 7f fb ff ff       	jmp    80104edf <alltraps>

80105360 <vector8>:
.globl vector8
vector8:
  pushl $8
80105360:	6a 08                	push   $0x8
  jmp alltraps
80105362:	e9 78 fb ff ff       	jmp    80104edf <alltraps>

80105367 <vector9>:
.globl vector9
vector9:
  pushl $0
80105367:	6a 00                	push   $0x0
  pushl $9
80105369:	6a 09                	push   $0x9
  jmp alltraps
8010536b:	e9 6f fb ff ff       	jmp    80104edf <alltraps>

80105370 <vector10>:
.globl vector10
vector10:
  pushl $10
80105370:	6a 0a                	push   $0xa
  jmp alltraps
80105372:	e9 68 fb ff ff       	jmp    80104edf <alltraps>

80105377 <vector11>:
.globl vector11
vector11:
  pushl $11
80105377:	6a 0b                	push   $0xb
  jmp alltraps
80105379:	e9 61 fb ff ff       	jmp    80104edf <alltraps>

8010537e <vector12>:
.globl vector12
vector12:
  pushl $12
8010537e:	6a 0c                	push   $0xc
  jmp alltraps
80105380:	e9 5a fb ff ff       	jmp    80104edf <alltraps>

80105385 <vector13>:
.globl vector13
vector13:
  pushl $13
80105385:	6a 0d                	push   $0xd
  jmp alltraps
80105387:	e9 53 fb ff ff       	jmp    80104edf <alltraps>

8010538c <vector14>:
.globl vector14
vector14:
  pushl $14
8010538c:	6a 0e                	push   $0xe
  jmp alltraps
8010538e:	e9 4c fb ff ff       	jmp    80104edf <alltraps>

80105393 <vector15>:
.globl vector15
vector15:
  pushl $0
80105393:	6a 00                	push   $0x0
  pushl $15
80105395:	6a 0f                	push   $0xf
  jmp alltraps
80105397:	e9 43 fb ff ff       	jmp    80104edf <alltraps>

8010539c <vector16>:
.globl vector16
vector16:
  pushl $0
8010539c:	6a 00                	push   $0x0
  pushl $16
8010539e:	6a 10                	push   $0x10
  jmp alltraps
801053a0:	e9 3a fb ff ff       	jmp    80104edf <alltraps>

801053a5 <vector17>:
.globl vector17
vector17:
  pushl $17
801053a5:	6a 11                	push   $0x11
  jmp alltraps
801053a7:	e9 33 fb ff ff       	jmp    80104edf <alltraps>

801053ac <vector18>:
.globl vector18
vector18:
  pushl $0
801053ac:	6a 00                	push   $0x0
  pushl $18
801053ae:	6a 12                	push   $0x12
  jmp alltraps
801053b0:	e9 2a fb ff ff       	jmp    80104edf <alltraps>

801053b5 <vector19>:
.globl vector19
vector19:
  pushl $0
801053b5:	6a 00                	push   $0x0
  pushl $19
801053b7:	6a 13                	push   $0x13
  jmp alltraps
801053b9:	e9 21 fb ff ff       	jmp    80104edf <alltraps>

801053be <vector20>:
.globl vector20
vector20:
  pushl $0
801053be:	6a 00                	push   $0x0
  pushl $20
801053c0:	6a 14                	push   $0x14
  jmp alltraps
801053c2:	e9 18 fb ff ff       	jmp    80104edf <alltraps>

801053c7 <vector21>:
.globl vector21
vector21:
  pushl $0
801053c7:	6a 00                	push   $0x0
  pushl $21
801053c9:	6a 15                	push   $0x15
  jmp alltraps
801053cb:	e9 0f fb ff ff       	jmp    80104edf <alltraps>

801053d0 <vector22>:
.globl vector22
vector22:
  pushl $0
801053d0:	6a 00                	push   $0x0
  pushl $22
801053d2:	6a 16                	push   $0x16
  jmp alltraps
801053d4:	e9 06 fb ff ff       	jmp    80104edf <alltraps>

801053d9 <vector23>:
.globl vector23
vector23:
  pushl $0
801053d9:	6a 00                	push   $0x0
  pushl $23
801053db:	6a 17                	push   $0x17
  jmp alltraps
801053dd:	e9 fd fa ff ff       	jmp    80104edf <alltraps>

801053e2 <vector24>:
.globl vector24
vector24:
  pushl $0
801053e2:	6a 00                	push   $0x0
  pushl $24
801053e4:	6a 18                	push   $0x18
  jmp alltraps
801053e6:	e9 f4 fa ff ff       	jmp    80104edf <alltraps>

801053eb <vector25>:
.globl vector25
vector25:
  pushl $0
801053eb:	6a 00                	push   $0x0
  pushl $25
801053ed:	6a 19                	push   $0x19
  jmp alltraps
801053ef:	e9 eb fa ff ff       	jmp    80104edf <alltraps>

801053f4 <vector26>:
.globl vector26
vector26:
  pushl $0
801053f4:	6a 00                	push   $0x0
  pushl $26
801053f6:	6a 1a                	push   $0x1a
  jmp alltraps
801053f8:	e9 e2 fa ff ff       	jmp    80104edf <alltraps>

801053fd <vector27>:
.globl vector27
vector27:
  pushl $0
801053fd:	6a 00                	push   $0x0
  pushl $27
801053ff:	6a 1b                	push   $0x1b
  jmp alltraps
80105401:	e9 d9 fa ff ff       	jmp    80104edf <alltraps>

80105406 <vector28>:
.globl vector28
vector28:
  pushl $0
80105406:	6a 00                	push   $0x0
  pushl $28
80105408:	6a 1c                	push   $0x1c
  jmp alltraps
8010540a:	e9 d0 fa ff ff       	jmp    80104edf <alltraps>

8010540f <vector29>:
.globl vector29
vector29:
  pushl $0
8010540f:	6a 00                	push   $0x0
  pushl $29
80105411:	6a 1d                	push   $0x1d
  jmp alltraps
80105413:	e9 c7 fa ff ff       	jmp    80104edf <alltraps>

80105418 <vector30>:
.globl vector30
vector30:
  pushl $0
80105418:	6a 00                	push   $0x0
  pushl $30
8010541a:	6a 1e                	push   $0x1e
  jmp alltraps
8010541c:	e9 be fa ff ff       	jmp    80104edf <alltraps>

80105421 <vector31>:
.globl vector31
vector31:
  pushl $0
80105421:	6a 00                	push   $0x0
  pushl $31
80105423:	6a 1f                	push   $0x1f
  jmp alltraps
80105425:	e9 b5 fa ff ff       	jmp    80104edf <alltraps>

8010542a <vector32>:
.globl vector32
vector32:
  pushl $0
8010542a:	6a 00                	push   $0x0
  pushl $32
8010542c:	6a 20                	push   $0x20
  jmp alltraps
8010542e:	e9 ac fa ff ff       	jmp    80104edf <alltraps>

80105433 <vector33>:
.globl vector33
vector33:
  pushl $0
80105433:	6a 00                	push   $0x0
  pushl $33
80105435:	6a 21                	push   $0x21
  jmp alltraps
80105437:	e9 a3 fa ff ff       	jmp    80104edf <alltraps>

8010543c <vector34>:
.globl vector34
vector34:
  pushl $0
8010543c:	6a 00                	push   $0x0
  pushl $34
8010543e:	6a 22                	push   $0x22
  jmp alltraps
80105440:	e9 9a fa ff ff       	jmp    80104edf <alltraps>

80105445 <vector35>:
.globl vector35
vector35:
  pushl $0
80105445:	6a 00                	push   $0x0
  pushl $35
80105447:	6a 23                	push   $0x23
  jmp alltraps
80105449:	e9 91 fa ff ff       	jmp    80104edf <alltraps>

8010544e <vector36>:
.globl vector36
vector36:
  pushl $0
8010544e:	6a 00                	push   $0x0
  pushl $36
80105450:	6a 24                	push   $0x24
  jmp alltraps
80105452:	e9 88 fa ff ff       	jmp    80104edf <alltraps>

80105457 <vector37>:
.globl vector37
vector37:
  pushl $0
80105457:	6a 00                	push   $0x0
  pushl $37
80105459:	6a 25                	push   $0x25
  jmp alltraps
8010545b:	e9 7f fa ff ff       	jmp    80104edf <alltraps>

80105460 <vector38>:
.globl vector38
vector38:
  pushl $0
80105460:	6a 00                	push   $0x0
  pushl $38
80105462:	6a 26                	push   $0x26
  jmp alltraps
80105464:	e9 76 fa ff ff       	jmp    80104edf <alltraps>

80105469 <vector39>:
.globl vector39
vector39:
  pushl $0
80105469:	6a 00                	push   $0x0
  pushl $39
8010546b:	6a 27                	push   $0x27
  jmp alltraps
8010546d:	e9 6d fa ff ff       	jmp    80104edf <alltraps>

80105472 <vector40>:
.globl vector40
vector40:
  pushl $0
80105472:	6a 00                	push   $0x0
  pushl $40
80105474:	6a 28                	push   $0x28
  jmp alltraps
80105476:	e9 64 fa ff ff       	jmp    80104edf <alltraps>

8010547b <vector41>:
.globl vector41
vector41:
  pushl $0
8010547b:	6a 00                	push   $0x0
  pushl $41
8010547d:	6a 29                	push   $0x29
  jmp alltraps
8010547f:	e9 5b fa ff ff       	jmp    80104edf <alltraps>

80105484 <vector42>:
.globl vector42
vector42:
  pushl $0
80105484:	6a 00                	push   $0x0
  pushl $42
80105486:	6a 2a                	push   $0x2a
  jmp alltraps
80105488:	e9 52 fa ff ff       	jmp    80104edf <alltraps>

8010548d <vector43>:
.globl vector43
vector43:
  pushl $0
8010548d:	6a 00                	push   $0x0
  pushl $43
8010548f:	6a 2b                	push   $0x2b
  jmp alltraps
80105491:	e9 49 fa ff ff       	jmp    80104edf <alltraps>

80105496 <vector44>:
.globl vector44
vector44:
  pushl $0
80105496:	6a 00                	push   $0x0
  pushl $44
80105498:	6a 2c                	push   $0x2c
  jmp alltraps
8010549a:	e9 40 fa ff ff       	jmp    80104edf <alltraps>

8010549f <vector45>:
.globl vector45
vector45:
  pushl $0
8010549f:	6a 00                	push   $0x0
  pushl $45
801054a1:	6a 2d                	push   $0x2d
  jmp alltraps
801054a3:	e9 37 fa ff ff       	jmp    80104edf <alltraps>

801054a8 <vector46>:
.globl vector46
vector46:
  pushl $0
801054a8:	6a 00                	push   $0x0
  pushl $46
801054aa:	6a 2e                	push   $0x2e
  jmp alltraps
801054ac:	e9 2e fa ff ff       	jmp    80104edf <alltraps>

801054b1 <vector47>:
.globl vector47
vector47:
  pushl $0
801054b1:	6a 00                	push   $0x0
  pushl $47
801054b3:	6a 2f                	push   $0x2f
  jmp alltraps
801054b5:	e9 25 fa ff ff       	jmp    80104edf <alltraps>

801054ba <vector48>:
.globl vector48
vector48:
  pushl $0
801054ba:	6a 00                	push   $0x0
  pushl $48
801054bc:	6a 30                	push   $0x30
  jmp alltraps
801054be:	e9 1c fa ff ff       	jmp    80104edf <alltraps>

801054c3 <vector49>:
.globl vector49
vector49:
  pushl $0
801054c3:	6a 00                	push   $0x0
  pushl $49
801054c5:	6a 31                	push   $0x31
  jmp alltraps
801054c7:	e9 13 fa ff ff       	jmp    80104edf <alltraps>

801054cc <vector50>:
.globl vector50
vector50:
  pushl $0
801054cc:	6a 00                	push   $0x0
  pushl $50
801054ce:	6a 32                	push   $0x32
  jmp alltraps
801054d0:	e9 0a fa ff ff       	jmp    80104edf <alltraps>

801054d5 <vector51>:
.globl vector51
vector51:
  pushl $0
801054d5:	6a 00                	push   $0x0
  pushl $51
801054d7:	6a 33                	push   $0x33
  jmp alltraps
801054d9:	e9 01 fa ff ff       	jmp    80104edf <alltraps>

801054de <vector52>:
.globl vector52
vector52:
  pushl $0
801054de:	6a 00                	push   $0x0
  pushl $52
801054e0:	6a 34                	push   $0x34
  jmp alltraps
801054e2:	e9 f8 f9 ff ff       	jmp    80104edf <alltraps>

801054e7 <vector53>:
.globl vector53
vector53:
  pushl $0
801054e7:	6a 00                	push   $0x0
  pushl $53
801054e9:	6a 35                	push   $0x35
  jmp alltraps
801054eb:	e9 ef f9 ff ff       	jmp    80104edf <alltraps>

801054f0 <vector54>:
.globl vector54
vector54:
  pushl $0
801054f0:	6a 00                	push   $0x0
  pushl $54
801054f2:	6a 36                	push   $0x36
  jmp alltraps
801054f4:	e9 e6 f9 ff ff       	jmp    80104edf <alltraps>

801054f9 <vector55>:
.globl vector55
vector55:
  pushl $0
801054f9:	6a 00                	push   $0x0
  pushl $55
801054fb:	6a 37                	push   $0x37
  jmp alltraps
801054fd:	e9 dd f9 ff ff       	jmp    80104edf <alltraps>

80105502 <vector56>:
.globl vector56
vector56:
  pushl $0
80105502:	6a 00                	push   $0x0
  pushl $56
80105504:	6a 38                	push   $0x38
  jmp alltraps
80105506:	e9 d4 f9 ff ff       	jmp    80104edf <alltraps>

8010550b <vector57>:
.globl vector57
vector57:
  pushl $0
8010550b:	6a 00                	push   $0x0
  pushl $57
8010550d:	6a 39                	push   $0x39
  jmp alltraps
8010550f:	e9 cb f9 ff ff       	jmp    80104edf <alltraps>

80105514 <vector58>:
.globl vector58
vector58:
  pushl $0
80105514:	6a 00                	push   $0x0
  pushl $58
80105516:	6a 3a                	push   $0x3a
  jmp alltraps
80105518:	e9 c2 f9 ff ff       	jmp    80104edf <alltraps>

8010551d <vector59>:
.globl vector59
vector59:
  pushl $0
8010551d:	6a 00                	push   $0x0
  pushl $59
8010551f:	6a 3b                	push   $0x3b
  jmp alltraps
80105521:	e9 b9 f9 ff ff       	jmp    80104edf <alltraps>

80105526 <vector60>:
.globl vector60
vector60:
  pushl $0
80105526:	6a 00                	push   $0x0
  pushl $60
80105528:	6a 3c                	push   $0x3c
  jmp alltraps
8010552a:	e9 b0 f9 ff ff       	jmp    80104edf <alltraps>

8010552f <vector61>:
.globl vector61
vector61:
  pushl $0
8010552f:	6a 00                	push   $0x0
  pushl $61
80105531:	6a 3d                	push   $0x3d
  jmp alltraps
80105533:	e9 a7 f9 ff ff       	jmp    80104edf <alltraps>

80105538 <vector62>:
.globl vector62
vector62:
  pushl $0
80105538:	6a 00                	push   $0x0
  pushl $62
8010553a:	6a 3e                	push   $0x3e
  jmp alltraps
8010553c:	e9 9e f9 ff ff       	jmp    80104edf <alltraps>

80105541 <vector63>:
.globl vector63
vector63:
  pushl $0
80105541:	6a 00                	push   $0x0
  pushl $63
80105543:	6a 3f                	push   $0x3f
  jmp alltraps
80105545:	e9 95 f9 ff ff       	jmp    80104edf <alltraps>

8010554a <vector64>:
.globl vector64
vector64:
  pushl $0
8010554a:	6a 00                	push   $0x0
  pushl $64
8010554c:	6a 40                	push   $0x40
  jmp alltraps
8010554e:	e9 8c f9 ff ff       	jmp    80104edf <alltraps>

80105553 <vector65>:
.globl vector65
vector65:
  pushl $0
80105553:	6a 00                	push   $0x0
  pushl $65
80105555:	6a 41                	push   $0x41
  jmp alltraps
80105557:	e9 83 f9 ff ff       	jmp    80104edf <alltraps>

8010555c <vector66>:
.globl vector66
vector66:
  pushl $0
8010555c:	6a 00                	push   $0x0
  pushl $66
8010555e:	6a 42                	push   $0x42
  jmp alltraps
80105560:	e9 7a f9 ff ff       	jmp    80104edf <alltraps>

80105565 <vector67>:
.globl vector67
vector67:
  pushl $0
80105565:	6a 00                	push   $0x0
  pushl $67
80105567:	6a 43                	push   $0x43
  jmp alltraps
80105569:	e9 71 f9 ff ff       	jmp    80104edf <alltraps>

8010556e <vector68>:
.globl vector68
vector68:
  pushl $0
8010556e:	6a 00                	push   $0x0
  pushl $68
80105570:	6a 44                	push   $0x44
  jmp alltraps
80105572:	e9 68 f9 ff ff       	jmp    80104edf <alltraps>

80105577 <vector69>:
.globl vector69
vector69:
  pushl $0
80105577:	6a 00                	push   $0x0
  pushl $69
80105579:	6a 45                	push   $0x45
  jmp alltraps
8010557b:	e9 5f f9 ff ff       	jmp    80104edf <alltraps>

80105580 <vector70>:
.globl vector70
vector70:
  pushl $0
80105580:	6a 00                	push   $0x0
  pushl $70
80105582:	6a 46                	push   $0x46
  jmp alltraps
80105584:	e9 56 f9 ff ff       	jmp    80104edf <alltraps>

80105589 <vector71>:
.globl vector71
vector71:
  pushl $0
80105589:	6a 00                	push   $0x0
  pushl $71
8010558b:	6a 47                	push   $0x47
  jmp alltraps
8010558d:	e9 4d f9 ff ff       	jmp    80104edf <alltraps>

80105592 <vector72>:
.globl vector72
vector72:
  pushl $0
80105592:	6a 00                	push   $0x0
  pushl $72
80105594:	6a 48                	push   $0x48
  jmp alltraps
80105596:	e9 44 f9 ff ff       	jmp    80104edf <alltraps>

8010559b <vector73>:
.globl vector73
vector73:
  pushl $0
8010559b:	6a 00                	push   $0x0
  pushl $73
8010559d:	6a 49                	push   $0x49
  jmp alltraps
8010559f:	e9 3b f9 ff ff       	jmp    80104edf <alltraps>

801055a4 <vector74>:
.globl vector74
vector74:
  pushl $0
801055a4:	6a 00                	push   $0x0
  pushl $74
801055a6:	6a 4a                	push   $0x4a
  jmp alltraps
801055a8:	e9 32 f9 ff ff       	jmp    80104edf <alltraps>

801055ad <vector75>:
.globl vector75
vector75:
  pushl $0
801055ad:	6a 00                	push   $0x0
  pushl $75
801055af:	6a 4b                	push   $0x4b
  jmp alltraps
801055b1:	e9 29 f9 ff ff       	jmp    80104edf <alltraps>

801055b6 <vector76>:
.globl vector76
vector76:
  pushl $0
801055b6:	6a 00                	push   $0x0
  pushl $76
801055b8:	6a 4c                	push   $0x4c
  jmp alltraps
801055ba:	e9 20 f9 ff ff       	jmp    80104edf <alltraps>

801055bf <vector77>:
.globl vector77
vector77:
  pushl $0
801055bf:	6a 00                	push   $0x0
  pushl $77
801055c1:	6a 4d                	push   $0x4d
  jmp alltraps
801055c3:	e9 17 f9 ff ff       	jmp    80104edf <alltraps>

801055c8 <vector78>:
.globl vector78
vector78:
  pushl $0
801055c8:	6a 00                	push   $0x0
  pushl $78
801055ca:	6a 4e                	push   $0x4e
  jmp alltraps
801055cc:	e9 0e f9 ff ff       	jmp    80104edf <alltraps>

801055d1 <vector79>:
.globl vector79
vector79:
  pushl $0
801055d1:	6a 00                	push   $0x0
  pushl $79
801055d3:	6a 4f                	push   $0x4f
  jmp alltraps
801055d5:	e9 05 f9 ff ff       	jmp    80104edf <alltraps>

801055da <vector80>:
.globl vector80
vector80:
  pushl $0
801055da:	6a 00                	push   $0x0
  pushl $80
801055dc:	6a 50                	push   $0x50
  jmp alltraps
801055de:	e9 fc f8 ff ff       	jmp    80104edf <alltraps>

801055e3 <vector81>:
.globl vector81
vector81:
  pushl $0
801055e3:	6a 00                	push   $0x0
  pushl $81
801055e5:	6a 51                	push   $0x51
  jmp alltraps
801055e7:	e9 f3 f8 ff ff       	jmp    80104edf <alltraps>

801055ec <vector82>:
.globl vector82
vector82:
  pushl $0
801055ec:	6a 00                	push   $0x0
  pushl $82
801055ee:	6a 52                	push   $0x52
  jmp alltraps
801055f0:	e9 ea f8 ff ff       	jmp    80104edf <alltraps>

801055f5 <vector83>:
.globl vector83
vector83:
  pushl $0
801055f5:	6a 00                	push   $0x0
  pushl $83
801055f7:	6a 53                	push   $0x53
  jmp alltraps
801055f9:	e9 e1 f8 ff ff       	jmp    80104edf <alltraps>

801055fe <vector84>:
.globl vector84
vector84:
  pushl $0
801055fe:	6a 00                	push   $0x0
  pushl $84
80105600:	6a 54                	push   $0x54
  jmp alltraps
80105602:	e9 d8 f8 ff ff       	jmp    80104edf <alltraps>

80105607 <vector85>:
.globl vector85
vector85:
  pushl $0
80105607:	6a 00                	push   $0x0
  pushl $85
80105609:	6a 55                	push   $0x55
  jmp alltraps
8010560b:	e9 cf f8 ff ff       	jmp    80104edf <alltraps>

80105610 <vector86>:
.globl vector86
vector86:
  pushl $0
80105610:	6a 00                	push   $0x0
  pushl $86
80105612:	6a 56                	push   $0x56
  jmp alltraps
80105614:	e9 c6 f8 ff ff       	jmp    80104edf <alltraps>

80105619 <vector87>:
.globl vector87
vector87:
  pushl $0
80105619:	6a 00                	push   $0x0
  pushl $87
8010561b:	6a 57                	push   $0x57
  jmp alltraps
8010561d:	e9 bd f8 ff ff       	jmp    80104edf <alltraps>

80105622 <vector88>:
.globl vector88
vector88:
  pushl $0
80105622:	6a 00                	push   $0x0
  pushl $88
80105624:	6a 58                	push   $0x58
  jmp alltraps
80105626:	e9 b4 f8 ff ff       	jmp    80104edf <alltraps>

8010562b <vector89>:
.globl vector89
vector89:
  pushl $0
8010562b:	6a 00                	push   $0x0
  pushl $89
8010562d:	6a 59                	push   $0x59
  jmp alltraps
8010562f:	e9 ab f8 ff ff       	jmp    80104edf <alltraps>

80105634 <vector90>:
.globl vector90
vector90:
  pushl $0
80105634:	6a 00                	push   $0x0
  pushl $90
80105636:	6a 5a                	push   $0x5a
  jmp alltraps
80105638:	e9 a2 f8 ff ff       	jmp    80104edf <alltraps>

8010563d <vector91>:
.globl vector91
vector91:
  pushl $0
8010563d:	6a 00                	push   $0x0
  pushl $91
8010563f:	6a 5b                	push   $0x5b
  jmp alltraps
80105641:	e9 99 f8 ff ff       	jmp    80104edf <alltraps>

80105646 <vector92>:
.globl vector92
vector92:
  pushl $0
80105646:	6a 00                	push   $0x0
  pushl $92
80105648:	6a 5c                	push   $0x5c
  jmp alltraps
8010564a:	e9 90 f8 ff ff       	jmp    80104edf <alltraps>

8010564f <vector93>:
.globl vector93
vector93:
  pushl $0
8010564f:	6a 00                	push   $0x0
  pushl $93
80105651:	6a 5d                	push   $0x5d
  jmp alltraps
80105653:	e9 87 f8 ff ff       	jmp    80104edf <alltraps>

80105658 <vector94>:
.globl vector94
vector94:
  pushl $0
80105658:	6a 00                	push   $0x0
  pushl $94
8010565a:	6a 5e                	push   $0x5e
  jmp alltraps
8010565c:	e9 7e f8 ff ff       	jmp    80104edf <alltraps>

80105661 <vector95>:
.globl vector95
vector95:
  pushl $0
80105661:	6a 00                	push   $0x0
  pushl $95
80105663:	6a 5f                	push   $0x5f
  jmp alltraps
80105665:	e9 75 f8 ff ff       	jmp    80104edf <alltraps>

8010566a <vector96>:
.globl vector96
vector96:
  pushl $0
8010566a:	6a 00                	push   $0x0
  pushl $96
8010566c:	6a 60                	push   $0x60
  jmp alltraps
8010566e:	e9 6c f8 ff ff       	jmp    80104edf <alltraps>

80105673 <vector97>:
.globl vector97
vector97:
  pushl $0
80105673:	6a 00                	push   $0x0
  pushl $97
80105675:	6a 61                	push   $0x61
  jmp alltraps
80105677:	e9 63 f8 ff ff       	jmp    80104edf <alltraps>

8010567c <vector98>:
.globl vector98
vector98:
  pushl $0
8010567c:	6a 00                	push   $0x0
  pushl $98
8010567e:	6a 62                	push   $0x62
  jmp alltraps
80105680:	e9 5a f8 ff ff       	jmp    80104edf <alltraps>

80105685 <vector99>:
.globl vector99
vector99:
  pushl $0
80105685:	6a 00                	push   $0x0
  pushl $99
80105687:	6a 63                	push   $0x63
  jmp alltraps
80105689:	e9 51 f8 ff ff       	jmp    80104edf <alltraps>

8010568e <vector100>:
.globl vector100
vector100:
  pushl $0
8010568e:	6a 00                	push   $0x0
  pushl $100
80105690:	6a 64                	push   $0x64
  jmp alltraps
80105692:	e9 48 f8 ff ff       	jmp    80104edf <alltraps>

80105697 <vector101>:
.globl vector101
vector101:
  pushl $0
80105697:	6a 00                	push   $0x0
  pushl $101
80105699:	6a 65                	push   $0x65
  jmp alltraps
8010569b:	e9 3f f8 ff ff       	jmp    80104edf <alltraps>

801056a0 <vector102>:
.globl vector102
vector102:
  pushl $0
801056a0:	6a 00                	push   $0x0
  pushl $102
801056a2:	6a 66                	push   $0x66
  jmp alltraps
801056a4:	e9 36 f8 ff ff       	jmp    80104edf <alltraps>

801056a9 <vector103>:
.globl vector103
vector103:
  pushl $0
801056a9:	6a 00                	push   $0x0
  pushl $103
801056ab:	6a 67                	push   $0x67
  jmp alltraps
801056ad:	e9 2d f8 ff ff       	jmp    80104edf <alltraps>

801056b2 <vector104>:
.globl vector104
vector104:
  pushl $0
801056b2:	6a 00                	push   $0x0
  pushl $104
801056b4:	6a 68                	push   $0x68
  jmp alltraps
801056b6:	e9 24 f8 ff ff       	jmp    80104edf <alltraps>

801056bb <vector105>:
.globl vector105
vector105:
  pushl $0
801056bb:	6a 00                	push   $0x0
  pushl $105
801056bd:	6a 69                	push   $0x69
  jmp alltraps
801056bf:	e9 1b f8 ff ff       	jmp    80104edf <alltraps>

801056c4 <vector106>:
.globl vector106
vector106:
  pushl $0
801056c4:	6a 00                	push   $0x0
  pushl $106
801056c6:	6a 6a                	push   $0x6a
  jmp alltraps
801056c8:	e9 12 f8 ff ff       	jmp    80104edf <alltraps>

801056cd <vector107>:
.globl vector107
vector107:
  pushl $0
801056cd:	6a 00                	push   $0x0
  pushl $107
801056cf:	6a 6b                	push   $0x6b
  jmp alltraps
801056d1:	e9 09 f8 ff ff       	jmp    80104edf <alltraps>

801056d6 <vector108>:
.globl vector108
vector108:
  pushl $0
801056d6:	6a 00                	push   $0x0
  pushl $108
801056d8:	6a 6c                	push   $0x6c
  jmp alltraps
801056da:	e9 00 f8 ff ff       	jmp    80104edf <alltraps>

801056df <vector109>:
.globl vector109
vector109:
  pushl $0
801056df:	6a 00                	push   $0x0
  pushl $109
801056e1:	6a 6d                	push   $0x6d
  jmp alltraps
801056e3:	e9 f7 f7 ff ff       	jmp    80104edf <alltraps>

801056e8 <vector110>:
.globl vector110
vector110:
  pushl $0
801056e8:	6a 00                	push   $0x0
  pushl $110
801056ea:	6a 6e                	push   $0x6e
  jmp alltraps
801056ec:	e9 ee f7 ff ff       	jmp    80104edf <alltraps>

801056f1 <vector111>:
.globl vector111
vector111:
  pushl $0
801056f1:	6a 00                	push   $0x0
  pushl $111
801056f3:	6a 6f                	push   $0x6f
  jmp alltraps
801056f5:	e9 e5 f7 ff ff       	jmp    80104edf <alltraps>

801056fa <vector112>:
.globl vector112
vector112:
  pushl $0
801056fa:	6a 00                	push   $0x0
  pushl $112
801056fc:	6a 70                	push   $0x70
  jmp alltraps
801056fe:	e9 dc f7 ff ff       	jmp    80104edf <alltraps>

80105703 <vector113>:
.globl vector113
vector113:
  pushl $0
80105703:	6a 00                	push   $0x0
  pushl $113
80105705:	6a 71                	push   $0x71
  jmp alltraps
80105707:	e9 d3 f7 ff ff       	jmp    80104edf <alltraps>

8010570c <vector114>:
.globl vector114
vector114:
  pushl $0
8010570c:	6a 00                	push   $0x0
  pushl $114
8010570e:	6a 72                	push   $0x72
  jmp alltraps
80105710:	e9 ca f7 ff ff       	jmp    80104edf <alltraps>

80105715 <vector115>:
.globl vector115
vector115:
  pushl $0
80105715:	6a 00                	push   $0x0
  pushl $115
80105717:	6a 73                	push   $0x73
  jmp alltraps
80105719:	e9 c1 f7 ff ff       	jmp    80104edf <alltraps>

8010571e <vector116>:
.globl vector116
vector116:
  pushl $0
8010571e:	6a 00                	push   $0x0
  pushl $116
80105720:	6a 74                	push   $0x74
  jmp alltraps
80105722:	e9 b8 f7 ff ff       	jmp    80104edf <alltraps>

80105727 <vector117>:
.globl vector117
vector117:
  pushl $0
80105727:	6a 00                	push   $0x0
  pushl $117
80105729:	6a 75                	push   $0x75
  jmp alltraps
8010572b:	e9 af f7 ff ff       	jmp    80104edf <alltraps>

80105730 <vector118>:
.globl vector118
vector118:
  pushl $0
80105730:	6a 00                	push   $0x0
  pushl $118
80105732:	6a 76                	push   $0x76
  jmp alltraps
80105734:	e9 a6 f7 ff ff       	jmp    80104edf <alltraps>

80105739 <vector119>:
.globl vector119
vector119:
  pushl $0
80105739:	6a 00                	push   $0x0
  pushl $119
8010573b:	6a 77                	push   $0x77
  jmp alltraps
8010573d:	e9 9d f7 ff ff       	jmp    80104edf <alltraps>

80105742 <vector120>:
.globl vector120
vector120:
  pushl $0
80105742:	6a 00                	push   $0x0
  pushl $120
80105744:	6a 78                	push   $0x78
  jmp alltraps
80105746:	e9 94 f7 ff ff       	jmp    80104edf <alltraps>

8010574b <vector121>:
.globl vector121
vector121:
  pushl $0
8010574b:	6a 00                	push   $0x0
  pushl $121
8010574d:	6a 79                	push   $0x79
  jmp alltraps
8010574f:	e9 8b f7 ff ff       	jmp    80104edf <alltraps>

80105754 <vector122>:
.globl vector122
vector122:
  pushl $0
80105754:	6a 00                	push   $0x0
  pushl $122
80105756:	6a 7a                	push   $0x7a
  jmp alltraps
80105758:	e9 82 f7 ff ff       	jmp    80104edf <alltraps>

8010575d <vector123>:
.globl vector123
vector123:
  pushl $0
8010575d:	6a 00                	push   $0x0
  pushl $123
8010575f:	6a 7b                	push   $0x7b
  jmp alltraps
80105761:	e9 79 f7 ff ff       	jmp    80104edf <alltraps>

80105766 <vector124>:
.globl vector124
vector124:
  pushl $0
80105766:	6a 00                	push   $0x0
  pushl $124
80105768:	6a 7c                	push   $0x7c
  jmp alltraps
8010576a:	e9 70 f7 ff ff       	jmp    80104edf <alltraps>

8010576f <vector125>:
.globl vector125
vector125:
  pushl $0
8010576f:	6a 00                	push   $0x0
  pushl $125
80105771:	6a 7d                	push   $0x7d
  jmp alltraps
80105773:	e9 67 f7 ff ff       	jmp    80104edf <alltraps>

80105778 <vector126>:
.globl vector126
vector126:
  pushl $0
80105778:	6a 00                	push   $0x0
  pushl $126
8010577a:	6a 7e                	push   $0x7e
  jmp alltraps
8010577c:	e9 5e f7 ff ff       	jmp    80104edf <alltraps>

80105781 <vector127>:
.globl vector127
vector127:
  pushl $0
80105781:	6a 00                	push   $0x0
  pushl $127
80105783:	6a 7f                	push   $0x7f
  jmp alltraps
80105785:	e9 55 f7 ff ff       	jmp    80104edf <alltraps>

8010578a <vector128>:
.globl vector128
vector128:
  pushl $0
8010578a:	6a 00                	push   $0x0
  pushl $128
8010578c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105791:	e9 49 f7 ff ff       	jmp    80104edf <alltraps>

80105796 <vector129>:
.globl vector129
vector129:
  pushl $0
80105796:	6a 00                	push   $0x0
  pushl $129
80105798:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010579d:	e9 3d f7 ff ff       	jmp    80104edf <alltraps>

801057a2 <vector130>:
.globl vector130
vector130:
  pushl $0
801057a2:	6a 00                	push   $0x0
  pushl $130
801057a4:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801057a9:	e9 31 f7 ff ff       	jmp    80104edf <alltraps>

801057ae <vector131>:
.globl vector131
vector131:
  pushl $0
801057ae:	6a 00                	push   $0x0
  pushl $131
801057b0:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801057b5:	e9 25 f7 ff ff       	jmp    80104edf <alltraps>

801057ba <vector132>:
.globl vector132
vector132:
  pushl $0
801057ba:	6a 00                	push   $0x0
  pushl $132
801057bc:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801057c1:	e9 19 f7 ff ff       	jmp    80104edf <alltraps>

801057c6 <vector133>:
.globl vector133
vector133:
  pushl $0
801057c6:	6a 00                	push   $0x0
  pushl $133
801057c8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801057cd:	e9 0d f7 ff ff       	jmp    80104edf <alltraps>

801057d2 <vector134>:
.globl vector134
vector134:
  pushl $0
801057d2:	6a 00                	push   $0x0
  pushl $134
801057d4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801057d9:	e9 01 f7 ff ff       	jmp    80104edf <alltraps>

801057de <vector135>:
.globl vector135
vector135:
  pushl $0
801057de:	6a 00                	push   $0x0
  pushl $135
801057e0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057e5:	e9 f5 f6 ff ff       	jmp    80104edf <alltraps>

801057ea <vector136>:
.globl vector136
vector136:
  pushl $0
801057ea:	6a 00                	push   $0x0
  pushl $136
801057ec:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057f1:	e9 e9 f6 ff ff       	jmp    80104edf <alltraps>

801057f6 <vector137>:
.globl vector137
vector137:
  pushl $0
801057f6:	6a 00                	push   $0x0
  pushl $137
801057f8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057fd:	e9 dd f6 ff ff       	jmp    80104edf <alltraps>

80105802 <vector138>:
.globl vector138
vector138:
  pushl $0
80105802:	6a 00                	push   $0x0
  pushl $138
80105804:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105809:	e9 d1 f6 ff ff       	jmp    80104edf <alltraps>

8010580e <vector139>:
.globl vector139
vector139:
  pushl $0
8010580e:	6a 00                	push   $0x0
  pushl $139
80105810:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105815:	e9 c5 f6 ff ff       	jmp    80104edf <alltraps>

8010581a <vector140>:
.globl vector140
vector140:
  pushl $0
8010581a:	6a 00                	push   $0x0
  pushl $140
8010581c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105821:	e9 b9 f6 ff ff       	jmp    80104edf <alltraps>

80105826 <vector141>:
.globl vector141
vector141:
  pushl $0
80105826:	6a 00                	push   $0x0
  pushl $141
80105828:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010582d:	e9 ad f6 ff ff       	jmp    80104edf <alltraps>

80105832 <vector142>:
.globl vector142
vector142:
  pushl $0
80105832:	6a 00                	push   $0x0
  pushl $142
80105834:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105839:	e9 a1 f6 ff ff       	jmp    80104edf <alltraps>

8010583e <vector143>:
.globl vector143
vector143:
  pushl $0
8010583e:	6a 00                	push   $0x0
  pushl $143
80105840:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105845:	e9 95 f6 ff ff       	jmp    80104edf <alltraps>

8010584a <vector144>:
.globl vector144
vector144:
  pushl $0
8010584a:	6a 00                	push   $0x0
  pushl $144
8010584c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105851:	e9 89 f6 ff ff       	jmp    80104edf <alltraps>

80105856 <vector145>:
.globl vector145
vector145:
  pushl $0
80105856:	6a 00                	push   $0x0
  pushl $145
80105858:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010585d:	e9 7d f6 ff ff       	jmp    80104edf <alltraps>

80105862 <vector146>:
.globl vector146
vector146:
  pushl $0
80105862:	6a 00                	push   $0x0
  pushl $146
80105864:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105869:	e9 71 f6 ff ff       	jmp    80104edf <alltraps>

8010586e <vector147>:
.globl vector147
vector147:
  pushl $0
8010586e:	6a 00                	push   $0x0
  pushl $147
80105870:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105875:	e9 65 f6 ff ff       	jmp    80104edf <alltraps>

8010587a <vector148>:
.globl vector148
vector148:
  pushl $0
8010587a:	6a 00                	push   $0x0
  pushl $148
8010587c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105881:	e9 59 f6 ff ff       	jmp    80104edf <alltraps>

80105886 <vector149>:
.globl vector149
vector149:
  pushl $0
80105886:	6a 00                	push   $0x0
  pushl $149
80105888:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010588d:	e9 4d f6 ff ff       	jmp    80104edf <alltraps>

80105892 <vector150>:
.globl vector150
vector150:
  pushl $0
80105892:	6a 00                	push   $0x0
  pushl $150
80105894:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105899:	e9 41 f6 ff ff       	jmp    80104edf <alltraps>

8010589e <vector151>:
.globl vector151
vector151:
  pushl $0
8010589e:	6a 00                	push   $0x0
  pushl $151
801058a0:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801058a5:	e9 35 f6 ff ff       	jmp    80104edf <alltraps>

801058aa <vector152>:
.globl vector152
vector152:
  pushl $0
801058aa:	6a 00                	push   $0x0
  pushl $152
801058ac:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801058b1:	e9 29 f6 ff ff       	jmp    80104edf <alltraps>

801058b6 <vector153>:
.globl vector153
vector153:
  pushl $0
801058b6:	6a 00                	push   $0x0
  pushl $153
801058b8:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801058bd:	e9 1d f6 ff ff       	jmp    80104edf <alltraps>

801058c2 <vector154>:
.globl vector154
vector154:
  pushl $0
801058c2:	6a 00                	push   $0x0
  pushl $154
801058c4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801058c9:	e9 11 f6 ff ff       	jmp    80104edf <alltraps>

801058ce <vector155>:
.globl vector155
vector155:
  pushl $0
801058ce:	6a 00                	push   $0x0
  pushl $155
801058d0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801058d5:	e9 05 f6 ff ff       	jmp    80104edf <alltraps>

801058da <vector156>:
.globl vector156
vector156:
  pushl $0
801058da:	6a 00                	push   $0x0
  pushl $156
801058dc:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801058e1:	e9 f9 f5 ff ff       	jmp    80104edf <alltraps>

801058e6 <vector157>:
.globl vector157
vector157:
  pushl $0
801058e6:	6a 00                	push   $0x0
  pushl $157
801058e8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058ed:	e9 ed f5 ff ff       	jmp    80104edf <alltraps>

801058f2 <vector158>:
.globl vector158
vector158:
  pushl $0
801058f2:	6a 00                	push   $0x0
  pushl $158
801058f4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058f9:	e9 e1 f5 ff ff       	jmp    80104edf <alltraps>

801058fe <vector159>:
.globl vector159
vector159:
  pushl $0
801058fe:	6a 00                	push   $0x0
  pushl $159
80105900:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105905:	e9 d5 f5 ff ff       	jmp    80104edf <alltraps>

8010590a <vector160>:
.globl vector160
vector160:
  pushl $0
8010590a:	6a 00                	push   $0x0
  pushl $160
8010590c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105911:	e9 c9 f5 ff ff       	jmp    80104edf <alltraps>

80105916 <vector161>:
.globl vector161
vector161:
  pushl $0
80105916:	6a 00                	push   $0x0
  pushl $161
80105918:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010591d:	e9 bd f5 ff ff       	jmp    80104edf <alltraps>

80105922 <vector162>:
.globl vector162
vector162:
  pushl $0
80105922:	6a 00                	push   $0x0
  pushl $162
80105924:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105929:	e9 b1 f5 ff ff       	jmp    80104edf <alltraps>

8010592e <vector163>:
.globl vector163
vector163:
  pushl $0
8010592e:	6a 00                	push   $0x0
  pushl $163
80105930:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105935:	e9 a5 f5 ff ff       	jmp    80104edf <alltraps>

8010593a <vector164>:
.globl vector164
vector164:
  pushl $0
8010593a:	6a 00                	push   $0x0
  pushl $164
8010593c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105941:	e9 99 f5 ff ff       	jmp    80104edf <alltraps>

80105946 <vector165>:
.globl vector165
vector165:
  pushl $0
80105946:	6a 00                	push   $0x0
  pushl $165
80105948:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010594d:	e9 8d f5 ff ff       	jmp    80104edf <alltraps>

80105952 <vector166>:
.globl vector166
vector166:
  pushl $0
80105952:	6a 00                	push   $0x0
  pushl $166
80105954:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105959:	e9 81 f5 ff ff       	jmp    80104edf <alltraps>

8010595e <vector167>:
.globl vector167
vector167:
  pushl $0
8010595e:	6a 00                	push   $0x0
  pushl $167
80105960:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105965:	e9 75 f5 ff ff       	jmp    80104edf <alltraps>

8010596a <vector168>:
.globl vector168
vector168:
  pushl $0
8010596a:	6a 00                	push   $0x0
  pushl $168
8010596c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105971:	e9 69 f5 ff ff       	jmp    80104edf <alltraps>

80105976 <vector169>:
.globl vector169
vector169:
  pushl $0
80105976:	6a 00                	push   $0x0
  pushl $169
80105978:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010597d:	e9 5d f5 ff ff       	jmp    80104edf <alltraps>

80105982 <vector170>:
.globl vector170
vector170:
  pushl $0
80105982:	6a 00                	push   $0x0
  pushl $170
80105984:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105989:	e9 51 f5 ff ff       	jmp    80104edf <alltraps>

8010598e <vector171>:
.globl vector171
vector171:
  pushl $0
8010598e:	6a 00                	push   $0x0
  pushl $171
80105990:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105995:	e9 45 f5 ff ff       	jmp    80104edf <alltraps>

8010599a <vector172>:
.globl vector172
vector172:
  pushl $0
8010599a:	6a 00                	push   $0x0
  pushl $172
8010599c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801059a1:	e9 39 f5 ff ff       	jmp    80104edf <alltraps>

801059a6 <vector173>:
.globl vector173
vector173:
  pushl $0
801059a6:	6a 00                	push   $0x0
  pushl $173
801059a8:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801059ad:	e9 2d f5 ff ff       	jmp    80104edf <alltraps>

801059b2 <vector174>:
.globl vector174
vector174:
  pushl $0
801059b2:	6a 00                	push   $0x0
  pushl $174
801059b4:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801059b9:	e9 21 f5 ff ff       	jmp    80104edf <alltraps>

801059be <vector175>:
.globl vector175
vector175:
  pushl $0
801059be:	6a 00                	push   $0x0
  pushl $175
801059c0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801059c5:	e9 15 f5 ff ff       	jmp    80104edf <alltraps>

801059ca <vector176>:
.globl vector176
vector176:
  pushl $0
801059ca:	6a 00                	push   $0x0
  pushl $176
801059cc:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801059d1:	e9 09 f5 ff ff       	jmp    80104edf <alltraps>

801059d6 <vector177>:
.globl vector177
vector177:
  pushl $0
801059d6:	6a 00                	push   $0x0
  pushl $177
801059d8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801059dd:	e9 fd f4 ff ff       	jmp    80104edf <alltraps>

801059e2 <vector178>:
.globl vector178
vector178:
  pushl $0
801059e2:	6a 00                	push   $0x0
  pushl $178
801059e4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801059e9:	e9 f1 f4 ff ff       	jmp    80104edf <alltraps>

801059ee <vector179>:
.globl vector179
vector179:
  pushl $0
801059ee:	6a 00                	push   $0x0
  pushl $179
801059f0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059f5:	e9 e5 f4 ff ff       	jmp    80104edf <alltraps>

801059fa <vector180>:
.globl vector180
vector180:
  pushl $0
801059fa:	6a 00                	push   $0x0
  pushl $180
801059fc:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a01:	e9 d9 f4 ff ff       	jmp    80104edf <alltraps>

80105a06 <vector181>:
.globl vector181
vector181:
  pushl $0
80105a06:	6a 00                	push   $0x0
  pushl $181
80105a08:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a0d:	e9 cd f4 ff ff       	jmp    80104edf <alltraps>

80105a12 <vector182>:
.globl vector182
vector182:
  pushl $0
80105a12:	6a 00                	push   $0x0
  pushl $182
80105a14:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a19:	e9 c1 f4 ff ff       	jmp    80104edf <alltraps>

80105a1e <vector183>:
.globl vector183
vector183:
  pushl $0
80105a1e:	6a 00                	push   $0x0
  pushl $183
80105a20:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a25:	e9 b5 f4 ff ff       	jmp    80104edf <alltraps>

80105a2a <vector184>:
.globl vector184
vector184:
  pushl $0
80105a2a:	6a 00                	push   $0x0
  pushl $184
80105a2c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a31:	e9 a9 f4 ff ff       	jmp    80104edf <alltraps>

80105a36 <vector185>:
.globl vector185
vector185:
  pushl $0
80105a36:	6a 00                	push   $0x0
  pushl $185
80105a38:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a3d:	e9 9d f4 ff ff       	jmp    80104edf <alltraps>

80105a42 <vector186>:
.globl vector186
vector186:
  pushl $0
80105a42:	6a 00                	push   $0x0
  pushl $186
80105a44:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a49:	e9 91 f4 ff ff       	jmp    80104edf <alltraps>

80105a4e <vector187>:
.globl vector187
vector187:
  pushl $0
80105a4e:	6a 00                	push   $0x0
  pushl $187
80105a50:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a55:	e9 85 f4 ff ff       	jmp    80104edf <alltraps>

80105a5a <vector188>:
.globl vector188
vector188:
  pushl $0
80105a5a:	6a 00                	push   $0x0
  pushl $188
80105a5c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a61:	e9 79 f4 ff ff       	jmp    80104edf <alltraps>

80105a66 <vector189>:
.globl vector189
vector189:
  pushl $0
80105a66:	6a 00                	push   $0x0
  pushl $189
80105a68:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a6d:	e9 6d f4 ff ff       	jmp    80104edf <alltraps>

80105a72 <vector190>:
.globl vector190
vector190:
  pushl $0
80105a72:	6a 00                	push   $0x0
  pushl $190
80105a74:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a79:	e9 61 f4 ff ff       	jmp    80104edf <alltraps>

80105a7e <vector191>:
.globl vector191
vector191:
  pushl $0
80105a7e:	6a 00                	push   $0x0
  pushl $191
80105a80:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a85:	e9 55 f4 ff ff       	jmp    80104edf <alltraps>

80105a8a <vector192>:
.globl vector192
vector192:
  pushl $0
80105a8a:	6a 00                	push   $0x0
  pushl $192
80105a8c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a91:	e9 49 f4 ff ff       	jmp    80104edf <alltraps>

80105a96 <vector193>:
.globl vector193
vector193:
  pushl $0
80105a96:	6a 00                	push   $0x0
  pushl $193
80105a98:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a9d:	e9 3d f4 ff ff       	jmp    80104edf <alltraps>

80105aa2 <vector194>:
.globl vector194
vector194:
  pushl $0
80105aa2:	6a 00                	push   $0x0
  pushl $194
80105aa4:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105aa9:	e9 31 f4 ff ff       	jmp    80104edf <alltraps>

80105aae <vector195>:
.globl vector195
vector195:
  pushl $0
80105aae:	6a 00                	push   $0x0
  pushl $195
80105ab0:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105ab5:	e9 25 f4 ff ff       	jmp    80104edf <alltraps>

80105aba <vector196>:
.globl vector196
vector196:
  pushl $0
80105aba:	6a 00                	push   $0x0
  pushl $196
80105abc:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105ac1:	e9 19 f4 ff ff       	jmp    80104edf <alltraps>

80105ac6 <vector197>:
.globl vector197
vector197:
  pushl $0
80105ac6:	6a 00                	push   $0x0
  pushl $197
80105ac8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105acd:	e9 0d f4 ff ff       	jmp    80104edf <alltraps>

80105ad2 <vector198>:
.globl vector198
vector198:
  pushl $0
80105ad2:	6a 00                	push   $0x0
  pushl $198
80105ad4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105ad9:	e9 01 f4 ff ff       	jmp    80104edf <alltraps>

80105ade <vector199>:
.globl vector199
vector199:
  pushl $0
80105ade:	6a 00                	push   $0x0
  pushl $199
80105ae0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105ae5:	e9 f5 f3 ff ff       	jmp    80104edf <alltraps>

80105aea <vector200>:
.globl vector200
vector200:
  pushl $0
80105aea:	6a 00                	push   $0x0
  pushl $200
80105aec:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105af1:	e9 e9 f3 ff ff       	jmp    80104edf <alltraps>

80105af6 <vector201>:
.globl vector201
vector201:
  pushl $0
80105af6:	6a 00                	push   $0x0
  pushl $201
80105af8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105afd:	e9 dd f3 ff ff       	jmp    80104edf <alltraps>

80105b02 <vector202>:
.globl vector202
vector202:
  pushl $0
80105b02:	6a 00                	push   $0x0
  pushl $202
80105b04:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b09:	e9 d1 f3 ff ff       	jmp    80104edf <alltraps>

80105b0e <vector203>:
.globl vector203
vector203:
  pushl $0
80105b0e:	6a 00                	push   $0x0
  pushl $203
80105b10:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b15:	e9 c5 f3 ff ff       	jmp    80104edf <alltraps>

80105b1a <vector204>:
.globl vector204
vector204:
  pushl $0
80105b1a:	6a 00                	push   $0x0
  pushl $204
80105b1c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b21:	e9 b9 f3 ff ff       	jmp    80104edf <alltraps>

80105b26 <vector205>:
.globl vector205
vector205:
  pushl $0
80105b26:	6a 00                	push   $0x0
  pushl $205
80105b28:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b2d:	e9 ad f3 ff ff       	jmp    80104edf <alltraps>

80105b32 <vector206>:
.globl vector206
vector206:
  pushl $0
80105b32:	6a 00                	push   $0x0
  pushl $206
80105b34:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b39:	e9 a1 f3 ff ff       	jmp    80104edf <alltraps>

80105b3e <vector207>:
.globl vector207
vector207:
  pushl $0
80105b3e:	6a 00                	push   $0x0
  pushl $207
80105b40:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b45:	e9 95 f3 ff ff       	jmp    80104edf <alltraps>

80105b4a <vector208>:
.globl vector208
vector208:
  pushl $0
80105b4a:	6a 00                	push   $0x0
  pushl $208
80105b4c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b51:	e9 89 f3 ff ff       	jmp    80104edf <alltraps>

80105b56 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b56:	6a 00                	push   $0x0
  pushl $209
80105b58:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b5d:	e9 7d f3 ff ff       	jmp    80104edf <alltraps>

80105b62 <vector210>:
.globl vector210
vector210:
  pushl $0
80105b62:	6a 00                	push   $0x0
  pushl $210
80105b64:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b69:	e9 71 f3 ff ff       	jmp    80104edf <alltraps>

80105b6e <vector211>:
.globl vector211
vector211:
  pushl $0
80105b6e:	6a 00                	push   $0x0
  pushl $211
80105b70:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b75:	e9 65 f3 ff ff       	jmp    80104edf <alltraps>

80105b7a <vector212>:
.globl vector212
vector212:
  pushl $0
80105b7a:	6a 00                	push   $0x0
  pushl $212
80105b7c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b81:	e9 59 f3 ff ff       	jmp    80104edf <alltraps>

80105b86 <vector213>:
.globl vector213
vector213:
  pushl $0
80105b86:	6a 00                	push   $0x0
  pushl $213
80105b88:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b8d:	e9 4d f3 ff ff       	jmp    80104edf <alltraps>

80105b92 <vector214>:
.globl vector214
vector214:
  pushl $0
80105b92:	6a 00                	push   $0x0
  pushl $214
80105b94:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b99:	e9 41 f3 ff ff       	jmp    80104edf <alltraps>

80105b9e <vector215>:
.globl vector215
vector215:
  pushl $0
80105b9e:	6a 00                	push   $0x0
  pushl $215
80105ba0:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105ba5:	e9 35 f3 ff ff       	jmp    80104edf <alltraps>

80105baa <vector216>:
.globl vector216
vector216:
  pushl $0
80105baa:	6a 00                	push   $0x0
  pushl $216
80105bac:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105bb1:	e9 29 f3 ff ff       	jmp    80104edf <alltraps>

80105bb6 <vector217>:
.globl vector217
vector217:
  pushl $0
80105bb6:	6a 00                	push   $0x0
  pushl $217
80105bb8:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105bbd:	e9 1d f3 ff ff       	jmp    80104edf <alltraps>

80105bc2 <vector218>:
.globl vector218
vector218:
  pushl $0
80105bc2:	6a 00                	push   $0x0
  pushl $218
80105bc4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105bc9:	e9 11 f3 ff ff       	jmp    80104edf <alltraps>

80105bce <vector219>:
.globl vector219
vector219:
  pushl $0
80105bce:	6a 00                	push   $0x0
  pushl $219
80105bd0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105bd5:	e9 05 f3 ff ff       	jmp    80104edf <alltraps>

80105bda <vector220>:
.globl vector220
vector220:
  pushl $0
80105bda:	6a 00                	push   $0x0
  pushl $220
80105bdc:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105be1:	e9 f9 f2 ff ff       	jmp    80104edf <alltraps>

80105be6 <vector221>:
.globl vector221
vector221:
  pushl $0
80105be6:	6a 00                	push   $0x0
  pushl $221
80105be8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105bed:	e9 ed f2 ff ff       	jmp    80104edf <alltraps>

80105bf2 <vector222>:
.globl vector222
vector222:
  pushl $0
80105bf2:	6a 00                	push   $0x0
  pushl $222
80105bf4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105bf9:	e9 e1 f2 ff ff       	jmp    80104edf <alltraps>

80105bfe <vector223>:
.globl vector223
vector223:
  pushl $0
80105bfe:	6a 00                	push   $0x0
  pushl $223
80105c00:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c05:	e9 d5 f2 ff ff       	jmp    80104edf <alltraps>

80105c0a <vector224>:
.globl vector224
vector224:
  pushl $0
80105c0a:	6a 00                	push   $0x0
  pushl $224
80105c0c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c11:	e9 c9 f2 ff ff       	jmp    80104edf <alltraps>

80105c16 <vector225>:
.globl vector225
vector225:
  pushl $0
80105c16:	6a 00                	push   $0x0
  pushl $225
80105c18:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c1d:	e9 bd f2 ff ff       	jmp    80104edf <alltraps>

80105c22 <vector226>:
.globl vector226
vector226:
  pushl $0
80105c22:	6a 00                	push   $0x0
  pushl $226
80105c24:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c29:	e9 b1 f2 ff ff       	jmp    80104edf <alltraps>

80105c2e <vector227>:
.globl vector227
vector227:
  pushl $0
80105c2e:	6a 00                	push   $0x0
  pushl $227
80105c30:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c35:	e9 a5 f2 ff ff       	jmp    80104edf <alltraps>

80105c3a <vector228>:
.globl vector228
vector228:
  pushl $0
80105c3a:	6a 00                	push   $0x0
  pushl $228
80105c3c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c41:	e9 99 f2 ff ff       	jmp    80104edf <alltraps>

80105c46 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c46:	6a 00                	push   $0x0
  pushl $229
80105c48:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c4d:	e9 8d f2 ff ff       	jmp    80104edf <alltraps>

80105c52 <vector230>:
.globl vector230
vector230:
  pushl $0
80105c52:	6a 00                	push   $0x0
  pushl $230
80105c54:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c59:	e9 81 f2 ff ff       	jmp    80104edf <alltraps>

80105c5e <vector231>:
.globl vector231
vector231:
  pushl $0
80105c5e:	6a 00                	push   $0x0
  pushl $231
80105c60:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c65:	e9 75 f2 ff ff       	jmp    80104edf <alltraps>

80105c6a <vector232>:
.globl vector232
vector232:
  pushl $0
80105c6a:	6a 00                	push   $0x0
  pushl $232
80105c6c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c71:	e9 69 f2 ff ff       	jmp    80104edf <alltraps>

80105c76 <vector233>:
.globl vector233
vector233:
  pushl $0
80105c76:	6a 00                	push   $0x0
  pushl $233
80105c78:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c7d:	e9 5d f2 ff ff       	jmp    80104edf <alltraps>

80105c82 <vector234>:
.globl vector234
vector234:
  pushl $0
80105c82:	6a 00                	push   $0x0
  pushl $234
80105c84:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c89:	e9 51 f2 ff ff       	jmp    80104edf <alltraps>

80105c8e <vector235>:
.globl vector235
vector235:
  pushl $0
80105c8e:	6a 00                	push   $0x0
  pushl $235
80105c90:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c95:	e9 45 f2 ff ff       	jmp    80104edf <alltraps>

80105c9a <vector236>:
.globl vector236
vector236:
  pushl $0
80105c9a:	6a 00                	push   $0x0
  pushl $236
80105c9c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105ca1:	e9 39 f2 ff ff       	jmp    80104edf <alltraps>

80105ca6 <vector237>:
.globl vector237
vector237:
  pushl $0
80105ca6:	6a 00                	push   $0x0
  pushl $237
80105ca8:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105cad:	e9 2d f2 ff ff       	jmp    80104edf <alltraps>

80105cb2 <vector238>:
.globl vector238
vector238:
  pushl $0
80105cb2:	6a 00                	push   $0x0
  pushl $238
80105cb4:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105cb9:	e9 21 f2 ff ff       	jmp    80104edf <alltraps>

80105cbe <vector239>:
.globl vector239
vector239:
  pushl $0
80105cbe:	6a 00                	push   $0x0
  pushl $239
80105cc0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105cc5:	e9 15 f2 ff ff       	jmp    80104edf <alltraps>

80105cca <vector240>:
.globl vector240
vector240:
  pushl $0
80105cca:	6a 00                	push   $0x0
  pushl $240
80105ccc:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105cd1:	e9 09 f2 ff ff       	jmp    80104edf <alltraps>

80105cd6 <vector241>:
.globl vector241
vector241:
  pushl $0
80105cd6:	6a 00                	push   $0x0
  pushl $241
80105cd8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105cdd:	e9 fd f1 ff ff       	jmp    80104edf <alltraps>

80105ce2 <vector242>:
.globl vector242
vector242:
  pushl $0
80105ce2:	6a 00                	push   $0x0
  pushl $242
80105ce4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105ce9:	e9 f1 f1 ff ff       	jmp    80104edf <alltraps>

80105cee <vector243>:
.globl vector243
vector243:
  pushl $0
80105cee:	6a 00                	push   $0x0
  pushl $243
80105cf0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cf5:	e9 e5 f1 ff ff       	jmp    80104edf <alltraps>

80105cfa <vector244>:
.globl vector244
vector244:
  pushl $0
80105cfa:	6a 00                	push   $0x0
  pushl $244
80105cfc:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d01:	e9 d9 f1 ff ff       	jmp    80104edf <alltraps>

80105d06 <vector245>:
.globl vector245
vector245:
  pushl $0
80105d06:	6a 00                	push   $0x0
  pushl $245
80105d08:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d0d:	e9 cd f1 ff ff       	jmp    80104edf <alltraps>

80105d12 <vector246>:
.globl vector246
vector246:
  pushl $0
80105d12:	6a 00                	push   $0x0
  pushl $246
80105d14:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d19:	e9 c1 f1 ff ff       	jmp    80104edf <alltraps>

80105d1e <vector247>:
.globl vector247
vector247:
  pushl $0
80105d1e:	6a 00                	push   $0x0
  pushl $247
80105d20:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d25:	e9 b5 f1 ff ff       	jmp    80104edf <alltraps>

80105d2a <vector248>:
.globl vector248
vector248:
  pushl $0
80105d2a:	6a 00                	push   $0x0
  pushl $248
80105d2c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d31:	e9 a9 f1 ff ff       	jmp    80104edf <alltraps>

80105d36 <vector249>:
.globl vector249
vector249:
  pushl $0
80105d36:	6a 00                	push   $0x0
  pushl $249
80105d38:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d3d:	e9 9d f1 ff ff       	jmp    80104edf <alltraps>

80105d42 <vector250>:
.globl vector250
vector250:
  pushl $0
80105d42:	6a 00                	push   $0x0
  pushl $250
80105d44:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d49:	e9 91 f1 ff ff       	jmp    80104edf <alltraps>

80105d4e <vector251>:
.globl vector251
vector251:
  pushl $0
80105d4e:	6a 00                	push   $0x0
  pushl $251
80105d50:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d55:	e9 85 f1 ff ff       	jmp    80104edf <alltraps>

80105d5a <vector252>:
.globl vector252
vector252:
  pushl $0
80105d5a:	6a 00                	push   $0x0
  pushl $252
80105d5c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d61:	e9 79 f1 ff ff       	jmp    80104edf <alltraps>

80105d66 <vector253>:
.globl vector253
vector253:
  pushl $0
80105d66:	6a 00                	push   $0x0
  pushl $253
80105d68:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d6d:	e9 6d f1 ff ff       	jmp    80104edf <alltraps>

80105d72 <vector254>:
.globl vector254
vector254:
  pushl $0
80105d72:	6a 00                	push   $0x0
  pushl $254
80105d74:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d79:	e9 61 f1 ff ff       	jmp    80104edf <alltraps>

80105d7e <vector255>:
.globl vector255
vector255:
  pushl $0
80105d7e:	6a 00                	push   $0x0
  pushl $255
80105d80:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d85:	e9 55 f1 ff ff       	jmp    80104edf <alltraps>

80105d8a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	57                   	push   %edi
80105d8e:	56                   	push   %esi
80105d8f:	53                   	push   %ebx
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d95:	c1 ea 16             	shr    $0x16,%edx
80105d98:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d9b:	8b 1f                	mov    (%edi),%ebx
80105d9d:	f6 c3 01             	test   $0x1,%bl
80105da0:	74 22                	je     80105dc4 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105da2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105da8:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105dae:	c1 ee 0c             	shr    $0xc,%esi
80105db1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105db7:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105dba:	89 d8                	mov    %ebx,%eax
80105dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dbf:	5b                   	pop    %ebx
80105dc0:	5e                   	pop    %esi
80105dc1:	5f                   	pop    %edi
80105dc2:	5d                   	pop    %ebp
80105dc3:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc(-2)) == 0)
80105dc4:	85 c9                	test   %ecx,%ecx
80105dc6:	74 33                	je     80105dfb <walkpgdir+0x71>
80105dc8:	83 ec 0c             	sub    $0xc,%esp
80105dcb:	6a fe                	push   $0xfffffffe
80105dcd:	e8 7a c3 ff ff       	call   8010214c <kalloc>
80105dd2:	89 c3                	mov    %eax,%ebx
80105dd4:	83 c4 10             	add    $0x10,%esp
80105dd7:	85 c0                	test   %eax,%eax
80105dd9:	74 df                	je     80105dba <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105ddb:	83 ec 04             	sub    $0x4,%esp
80105dde:	68 00 10 00 00       	push   $0x1000
80105de3:	6a 00                	push   $0x0
80105de5:	50                   	push   %eax
80105de6:	e8 f6 df ff ff       	call   80103de1 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105deb:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105df1:	83 c8 07             	or     $0x7,%eax
80105df4:	89 07                	mov    %eax,(%edi)
80105df6:	83 c4 10             	add    $0x10,%esp
80105df9:	eb b3                	jmp    80105dae <walkpgdir+0x24>
      return 0;
80105dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
80105e00:	eb b8                	jmp    80105dba <walkpgdir+0x30>

80105e02 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105e02:	55                   	push   %ebp
80105e03:	89 e5                	mov    %esp,%ebp
80105e05:	57                   	push   %edi
80105e06:	56                   	push   %esi
80105e07:	53                   	push   %ebx
80105e08:	83 ec 1c             	sub    $0x1c,%esp
80105e0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e0e:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105e11:	89 d3                	mov    %edx,%ebx
80105e13:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105e19:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105e1d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e23:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e28:	89 da                	mov    %ebx,%edx
80105e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e2d:	e8 58 ff ff ff       	call   80105d8a <walkpgdir>
80105e32:	85 c0                	test   %eax,%eax
80105e34:	74 2e                	je     80105e64 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e36:	f6 00 01             	testb  $0x1,(%eax)
80105e39:	75 1c                	jne    80105e57 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e3b:	89 f2                	mov    %esi,%edx
80105e3d:	0b 55 0c             	or     0xc(%ebp),%edx
80105e40:	83 ca 01             	or     $0x1,%edx
80105e43:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e45:	39 fb                	cmp    %edi,%ebx
80105e47:	74 28                	je     80105e71 <mappages+0x6f>
      break;
    a += PGSIZE;
80105e49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e4f:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e55:	eb cc                	jmp    80105e23 <mappages+0x21>
      panic("remap");
80105e57:	83 ec 0c             	sub    $0xc,%esp
80105e5a:	68 2c 6f 10 80       	push   $0x80106f2c
80105e5f:	e8 e4 a4 ff ff       	call   80100348 <panic>
      return -1;
80105e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e6c:	5b                   	pop    %ebx
80105e6d:	5e                   	pop    %esi
80105e6e:	5f                   	pop    %edi
80105e6f:	5d                   	pop    %ebp
80105e70:	c3                   	ret    
  return 0;
80105e71:	b8 00 00 00 00       	mov    $0x0,%eax
80105e76:	eb f1                	jmp    80105e69 <mappages+0x67>

80105e78 <seginit>:
{
80105e78:	55                   	push   %ebp
80105e79:	89 e5                	mov    %esp,%ebp
80105e7b:	53                   	push   %ebx
80105e7c:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e7f:	e8 f4 d4 ff ff       	call   80103378 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e84:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e8a:	66 c7 80 58 28 14 80 	movw   $0xffff,-0x7febd7a8(%eax)
80105e91:	ff ff 
80105e93:	66 c7 80 5a 28 14 80 	movw   $0x0,-0x7febd7a6(%eax)
80105e9a:	00 00 
80105e9c:	c6 80 5c 28 14 80 00 	movb   $0x0,-0x7febd7a4(%eax)
80105ea3:	0f b6 88 5d 28 14 80 	movzbl -0x7febd7a3(%eax),%ecx
80105eaa:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ead:	83 c9 1a             	or     $0x1a,%ecx
80105eb0:	83 e1 9f             	and    $0xffffff9f,%ecx
80105eb3:	83 c9 80             	or     $0xffffff80,%ecx
80105eb6:	88 88 5d 28 14 80    	mov    %cl,-0x7febd7a3(%eax)
80105ebc:	0f b6 88 5e 28 14 80 	movzbl -0x7febd7a2(%eax),%ecx
80105ec3:	83 c9 0f             	or     $0xf,%ecx
80105ec6:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ec9:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ecc:	88 88 5e 28 14 80    	mov    %cl,-0x7febd7a2(%eax)
80105ed2:	c6 80 5f 28 14 80 00 	movb   $0x0,-0x7febd7a1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ed9:	66 c7 80 60 28 14 80 	movw   $0xffff,-0x7febd7a0(%eax)
80105ee0:	ff ff 
80105ee2:	66 c7 80 62 28 14 80 	movw   $0x0,-0x7febd79e(%eax)
80105ee9:	00 00 
80105eeb:	c6 80 64 28 14 80 00 	movb   $0x0,-0x7febd79c(%eax)
80105ef2:	0f b6 88 65 28 14 80 	movzbl -0x7febd79b(%eax),%ecx
80105ef9:	83 e1 f0             	and    $0xfffffff0,%ecx
80105efc:	83 c9 12             	or     $0x12,%ecx
80105eff:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f02:	83 c9 80             	or     $0xffffff80,%ecx
80105f05:	88 88 65 28 14 80    	mov    %cl,-0x7febd79b(%eax)
80105f0b:	0f b6 88 66 28 14 80 	movzbl -0x7febd79a(%eax),%ecx
80105f12:	83 c9 0f             	or     $0xf,%ecx
80105f15:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f18:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f1b:	88 88 66 28 14 80    	mov    %cl,-0x7febd79a(%eax)
80105f21:	c6 80 67 28 14 80 00 	movb   $0x0,-0x7febd799(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f28:	66 c7 80 68 28 14 80 	movw   $0xffff,-0x7febd798(%eax)
80105f2f:	ff ff 
80105f31:	66 c7 80 6a 28 14 80 	movw   $0x0,-0x7febd796(%eax)
80105f38:	00 00 
80105f3a:	c6 80 6c 28 14 80 00 	movb   $0x0,-0x7febd794(%eax)
80105f41:	c6 80 6d 28 14 80 fa 	movb   $0xfa,-0x7febd793(%eax)
80105f48:	0f b6 88 6e 28 14 80 	movzbl -0x7febd792(%eax),%ecx
80105f4f:	83 c9 0f             	or     $0xf,%ecx
80105f52:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f55:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f58:	88 88 6e 28 14 80    	mov    %cl,-0x7febd792(%eax)
80105f5e:	c6 80 6f 28 14 80 00 	movb   $0x0,-0x7febd791(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f65:	66 c7 80 70 28 14 80 	movw   $0xffff,-0x7febd790(%eax)
80105f6c:	ff ff 
80105f6e:	66 c7 80 72 28 14 80 	movw   $0x0,-0x7febd78e(%eax)
80105f75:	00 00 
80105f77:	c6 80 74 28 14 80 00 	movb   $0x0,-0x7febd78c(%eax)
80105f7e:	c6 80 75 28 14 80 f2 	movb   $0xf2,-0x7febd78b(%eax)
80105f85:	0f b6 88 76 28 14 80 	movzbl -0x7febd78a(%eax),%ecx
80105f8c:	83 c9 0f             	or     $0xf,%ecx
80105f8f:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f92:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f95:	88 88 76 28 14 80    	mov    %cl,-0x7febd78a(%eax)
80105f9b:	c6 80 77 28 14 80 00 	movb   $0x0,-0x7febd789(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105fa2:	05 50 28 14 80       	add    $0x80142850,%eax
  pd[0] = size-1;
80105fa7:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105fad:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105fb1:	c1 e8 10             	shr    $0x10,%eax
80105fb4:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fb8:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105fbb:	0f 01 10             	lgdtl  (%eax)
}
80105fbe:	83 c4 14             	add    $0x14,%esp
80105fc1:	5b                   	pop    %ebx
80105fc2:	5d                   	pop    %ebp
80105fc3:	c3                   	ret    

80105fc4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105fc4:	55                   	push   %ebp
80105fc5:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105fc7:	a1 04 55 14 80       	mov    0x80145504,%eax
80105fcc:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fd1:	0f 22 d8             	mov    %eax,%cr3
}
80105fd4:	5d                   	pop    %ebp
80105fd5:	c3                   	ret    

80105fd6 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fd6:	55                   	push   %ebp
80105fd7:	89 e5                	mov    %esp,%ebp
80105fd9:	57                   	push   %edi
80105fda:	56                   	push   %esi
80105fdb:	53                   	push   %ebx
80105fdc:	83 ec 1c             	sub    $0x1c,%esp
80105fdf:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105fe2:	85 f6                	test   %esi,%esi
80105fe4:	0f 84 dd 00 00 00    	je     801060c7 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105fea:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105fee:	0f 84 e0 00 00 00    	je     801060d4 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105ff4:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105ff8:	0f 84 e3 00 00 00    	je     801060e1 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105ffe:	e8 55 dc ff ff       	call   80103c58 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106003:	e8 14 d3 ff ff       	call   8010331c <mycpu>
80106008:	89 c3                	mov    %eax,%ebx
8010600a:	e8 0d d3 ff ff       	call   8010331c <mycpu>
8010600f:	8d 78 08             	lea    0x8(%eax),%edi
80106012:	e8 05 d3 ff ff       	call   8010331c <mycpu>
80106017:	83 c0 08             	add    $0x8,%eax
8010601a:	c1 e8 10             	shr    $0x10,%eax
8010601d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106020:	e8 f7 d2 ff ff       	call   8010331c <mycpu>
80106025:	83 c0 08             	add    $0x8,%eax
80106028:	c1 e8 18             	shr    $0x18,%eax
8010602b:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106032:	67 00 
80106034:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010603b:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010603f:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106045:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010604c:	83 e2 f0             	and    $0xfffffff0,%edx
8010604f:	83 ca 19             	or     $0x19,%edx
80106052:	83 e2 9f             	and    $0xffffff9f,%edx
80106055:	83 ca 80             	or     $0xffffff80,%edx
80106058:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010605e:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106065:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010606b:	e8 ac d2 ff ff       	call   8010331c <mycpu>
80106070:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106077:	83 e2 ef             	and    $0xffffffef,%edx
8010607a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106080:	e8 97 d2 ff ff       	call   8010331c <mycpu>
80106085:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010608b:	8b 5e 08             	mov    0x8(%esi),%ebx
8010608e:	e8 89 d2 ff ff       	call   8010331c <mycpu>
80106093:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106099:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010609c:	e8 7b d2 ff ff       	call   8010331c <mycpu>
801060a1:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801060a7:	b8 28 00 00 00       	mov    $0x28,%eax
801060ac:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801060af:	8b 46 04             	mov    0x4(%esi),%eax
801060b2:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060b7:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060ba:	e8 d6 db ff ff       	call   80103c95 <popcli>
}
801060bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060c2:	5b                   	pop    %ebx
801060c3:	5e                   	pop    %esi
801060c4:	5f                   	pop    %edi
801060c5:	5d                   	pop    %ebp
801060c6:	c3                   	ret    
    panic("switchuvm: no process");
801060c7:	83 ec 0c             	sub    $0xc,%esp
801060ca:	68 32 6f 10 80       	push   $0x80106f32
801060cf:	e8 74 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801060d4:	83 ec 0c             	sub    $0xc,%esp
801060d7:	68 48 6f 10 80       	push   $0x80106f48
801060dc:	e8 67 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060e1:	83 ec 0c             	sub    $0xc,%esp
801060e4:	68 5d 6f 10 80       	push   $0x80106f5d
801060e9:	e8 5a a2 ff ff       	call   80100348 <panic>

801060ee <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801060ee:	55                   	push   %ebp
801060ef:	89 e5                	mov    %esp,%ebp
801060f1:	56                   	push   %esi
801060f2:	53                   	push   %ebx
801060f3:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801060f6:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060fc:	77 51                	ja     8010614f <inituvm+0x61>
    panic("inituvm: more than a page");
  mem = kalloc(-2);
801060fe:	83 ec 0c             	sub    $0xc,%esp
80106101:	6a fe                	push   $0xfffffffe
80106103:	e8 44 c0 ff ff       	call   8010214c <kalloc>
80106108:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010610a:	83 c4 0c             	add    $0xc,%esp
8010610d:	68 00 10 00 00       	push   $0x1000
80106112:	6a 00                	push   $0x0
80106114:	50                   	push   %eax
80106115:	e8 c7 dc ff ff       	call   80103de1 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010611a:	83 c4 08             	add    $0x8,%esp
8010611d:	6a 06                	push   $0x6
8010611f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106125:	50                   	push   %eax
80106126:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010612b:	ba 00 00 00 00       	mov    $0x0,%edx
80106130:	8b 45 08             	mov    0x8(%ebp),%eax
80106133:	e8 ca fc ff ff       	call   80105e02 <mappages>
  memmove(mem, init, sz);
80106138:	83 c4 0c             	add    $0xc,%esp
8010613b:	56                   	push   %esi
8010613c:	ff 75 0c             	pushl  0xc(%ebp)
8010613f:	53                   	push   %ebx
80106140:	e8 17 dd ff ff       	call   80103e5c <memmove>
}
80106145:	83 c4 10             	add    $0x10,%esp
80106148:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010614b:	5b                   	pop    %ebx
8010614c:	5e                   	pop    %esi
8010614d:	5d                   	pop    %ebp
8010614e:	c3                   	ret    
    panic("inituvm: more than a page");
8010614f:	83 ec 0c             	sub    $0xc,%esp
80106152:	68 71 6f 10 80       	push   $0x80106f71
80106157:	e8 ec a1 ff ff       	call   80100348 <panic>

8010615c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010615c:	55                   	push   %ebp
8010615d:	89 e5                	mov    %esp,%ebp
8010615f:	57                   	push   %edi
80106160:	56                   	push   %esi
80106161:	53                   	push   %ebx
80106162:	83 ec 0c             	sub    $0xc,%esp
80106165:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106168:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010616f:	75 07                	jne    80106178 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106171:	bb 00 00 00 00       	mov    $0x0,%ebx
80106176:	eb 3c                	jmp    801061b4 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106178:	83 ec 0c             	sub    $0xc,%esp
8010617b:	68 2c 70 10 80       	push   $0x8010702c
80106180:	e8 c3 a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106185:	83 ec 0c             	sub    $0xc,%esp
80106188:	68 8b 6f 10 80       	push   $0x80106f8b
8010618d:	e8 b6 a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106192:	05 00 00 00 80       	add    $0x80000000,%eax
80106197:	56                   	push   %esi
80106198:	89 da                	mov    %ebx,%edx
8010619a:	03 55 14             	add    0x14(%ebp),%edx
8010619d:	52                   	push   %edx
8010619e:	50                   	push   %eax
8010619f:	ff 75 10             	pushl  0x10(%ebp)
801061a2:	e8 d8 b5 ff ff       	call   8010177f <readi>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	39 f0                	cmp    %esi,%eax
801061ac:	75 47                	jne    801061f5 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801061ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061b4:	39 fb                	cmp    %edi,%ebx
801061b6:	73 30                	jae    801061e8 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061b8:	89 da                	mov    %ebx,%edx
801061ba:	03 55 0c             	add    0xc(%ebp),%edx
801061bd:	b9 00 00 00 00       	mov    $0x0,%ecx
801061c2:	8b 45 08             	mov    0x8(%ebp),%eax
801061c5:	e8 c0 fb ff ff       	call   80105d8a <walkpgdir>
801061ca:	85 c0                	test   %eax,%eax
801061cc:	74 b7                	je     80106185 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061ce:	8b 00                	mov    (%eax),%eax
801061d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061d5:	89 fe                	mov    %edi,%esi
801061d7:	29 de                	sub    %ebx,%esi
801061d9:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061df:	76 b1                	jbe    80106192 <loaduvm+0x36>
      n = PGSIZE;
801061e1:	be 00 10 00 00       	mov    $0x1000,%esi
801061e6:	eb aa                	jmp    80106192 <loaduvm+0x36>
      return -1;
  }
  return 0;
801061e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061f0:	5b                   	pop    %ebx
801061f1:	5e                   	pop    %esi
801061f2:	5f                   	pop    %edi
801061f3:	5d                   	pop    %ebp
801061f4:	c3                   	ret    
      return -1;
801061f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fa:	eb f1                	jmp    801061ed <loaduvm+0x91>

801061fc <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801061fc:	55                   	push   %ebp
801061fd:	89 e5                	mov    %esp,%ebp
801061ff:	57                   	push   %edi
80106200:	56                   	push   %esi
80106201:	53                   	push   %ebx
80106202:	83 ec 0c             	sub    $0xc,%esp
80106205:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106208:	39 7d 10             	cmp    %edi,0x10(%ebp)
8010620b:	73 11                	jae    8010621e <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010620d:	8b 45 10             	mov    0x10(%ebp),%eax
80106210:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106216:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010621c:	eb 19                	jmp    80106237 <deallocuvm+0x3b>
    return oldsz;
8010621e:	89 f8                	mov    %edi,%eax
80106220:	eb 64                	jmp    80106286 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106222:	c1 eb 16             	shr    $0x16,%ebx
80106225:	83 c3 01             	add    $0x1,%ebx
80106228:	c1 e3 16             	shl    $0x16,%ebx
8010622b:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106231:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106237:	39 fb                	cmp    %edi,%ebx
80106239:	73 48                	jae    80106283 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010623b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106240:	89 da                	mov    %ebx,%edx
80106242:	8b 45 08             	mov    0x8(%ebp),%eax
80106245:	e8 40 fb ff ff       	call   80105d8a <walkpgdir>
8010624a:	89 c6                	mov    %eax,%esi
    if(!pte)
8010624c:	85 c0                	test   %eax,%eax
8010624e:	74 d2                	je     80106222 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106250:	8b 00                	mov    (%eax),%eax
80106252:	a8 01                	test   $0x1,%al
80106254:	74 db                	je     80106231 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106256:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010625b:	74 19                	je     80106276 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010625d:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106262:	83 ec 0c             	sub    $0xc,%esp
80106265:	50                   	push   %eax
80106266:	e8 9a bd ff ff       	call   80102005 <kfree>
      *pte = 0;
8010626b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106271:	83 c4 10             	add    $0x10,%esp
80106274:	eb bb                	jmp    80106231 <deallocuvm+0x35>
        panic("kfree");
80106276:	83 ec 0c             	sub    $0xc,%esp
80106279:	68 c6 68 10 80       	push   $0x801068c6
8010627e:	e8 c5 a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106283:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106286:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106289:	5b                   	pop    %ebx
8010628a:	5e                   	pop    %esi
8010628b:	5f                   	pop    %edi
8010628c:	5d                   	pop    %ebp
8010628d:	c3                   	ret    

8010628e <allocuvm>:
{
8010628e:	55                   	push   %ebp
8010628f:	89 e5                	mov    %esp,%ebp
80106291:	57                   	push   %edi
80106292:	56                   	push   %esi
80106293:	53                   	push   %ebx
80106294:	83 ec 1c             	sub    $0x1c,%esp
80106297:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010629a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010629d:	85 ff                	test   %edi,%edi
8010629f:	0f 88 ca 00 00 00    	js     8010636f <allocuvm+0xe1>
  if(newsz < oldsz)
801062a5:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062a8:	72 65                	jb     8010630f <allocuvm+0x81>
  a = PGROUNDUP(oldsz);
801062aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801062ad:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062b3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801062b9:	39 fb                	cmp    %edi,%ebx
801062bb:	0f 83 b5 00 00 00    	jae    80106376 <allocuvm+0xe8>
    mem = kalloc(pid);
801062c1:	83 ec 0c             	sub    $0xc,%esp
801062c4:	ff 75 14             	pushl  0x14(%ebp)
801062c7:	e8 80 be ff ff       	call   8010214c <kalloc>
801062cc:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801062ce:	83 c4 10             	add    $0x10,%esp
801062d1:	85 c0                	test   %eax,%eax
801062d3:	74 42                	je     80106317 <allocuvm+0x89>
    memset(mem, 0, PGSIZE);
801062d5:	83 ec 04             	sub    $0x4,%esp
801062d8:	68 00 10 00 00       	push   $0x1000
801062dd:	6a 00                	push   $0x0
801062df:	50                   	push   %eax
801062e0:	e8 fc da ff ff       	call   80103de1 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801062e5:	83 c4 08             	add    $0x8,%esp
801062e8:	6a 06                	push   $0x6
801062ea:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801062f0:	50                   	push   %eax
801062f1:	b9 00 10 00 00       	mov    $0x1000,%ecx
801062f6:	89 da                	mov    %ebx,%edx
801062f8:	8b 45 08             	mov    0x8(%ebp),%eax
801062fb:	e8 02 fb ff ff       	call   80105e02 <mappages>
80106300:	83 c4 10             	add    $0x10,%esp
80106303:	85 c0                	test   %eax,%eax
80106305:	78 38                	js     8010633f <allocuvm+0xb1>
  for(; a < newsz; a += PGSIZE){
80106307:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010630d:	eb aa                	jmp    801062b9 <allocuvm+0x2b>
    return oldsz;
8010630f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106312:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106315:	eb 5f                	jmp    80106376 <allocuvm+0xe8>
      cprintf("allocuvm out of memory\n");
80106317:	83 ec 0c             	sub    $0xc,%esp
8010631a:	68 a9 6f 10 80       	push   $0x80106fa9
8010631f:	e8 e7 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106324:	83 c4 0c             	add    $0xc,%esp
80106327:	ff 75 0c             	pushl  0xc(%ebp)
8010632a:	57                   	push   %edi
8010632b:	ff 75 08             	pushl  0x8(%ebp)
8010632e:	e8 c9 fe ff ff       	call   801061fc <deallocuvm>
      return 0;
80106333:	83 c4 10             	add    $0x10,%esp
80106336:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010633d:	eb 37                	jmp    80106376 <allocuvm+0xe8>
      cprintf("allocuvm out of memory (2)\n");
8010633f:	83 ec 0c             	sub    $0xc,%esp
80106342:	68 c1 6f 10 80       	push   $0x80106fc1
80106347:	e8 bf a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010634c:	83 c4 0c             	add    $0xc,%esp
8010634f:	ff 75 0c             	pushl  0xc(%ebp)
80106352:	57                   	push   %edi
80106353:	ff 75 08             	pushl  0x8(%ebp)
80106356:	e8 a1 fe ff ff       	call   801061fc <deallocuvm>
      kfree(mem);
8010635b:	89 34 24             	mov    %esi,(%esp)
8010635e:	e8 a2 bc ff ff       	call   80102005 <kfree>
      return 0;
80106363:	83 c4 10             	add    $0x10,%esp
80106366:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010636d:	eb 07                	jmp    80106376 <allocuvm+0xe8>
    return 0;
8010636f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106379:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010637c:	5b                   	pop    %ebx
8010637d:	5e                   	pop    %esi
8010637e:	5f                   	pop    %edi
8010637f:	5d                   	pop    %ebp
80106380:	c3                   	ret    

80106381 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106381:	55                   	push   %ebp
80106382:	89 e5                	mov    %esp,%ebp
80106384:	56                   	push   %esi
80106385:	53                   	push   %ebx
80106386:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106389:	85 f6                	test   %esi,%esi
8010638b:	74 1a                	je     801063a7 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010638d:	83 ec 04             	sub    $0x4,%esp
80106390:	6a 00                	push   $0x0
80106392:	68 00 00 00 80       	push   $0x80000000
80106397:	56                   	push   %esi
80106398:	e8 5f fe ff ff       	call   801061fc <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010639d:	83 c4 10             	add    $0x10,%esp
801063a0:	bb 00 00 00 00       	mov    $0x0,%ebx
801063a5:	eb 10                	jmp    801063b7 <freevm+0x36>
    panic("freevm: no pgdir");
801063a7:	83 ec 0c             	sub    $0xc,%esp
801063aa:	68 dd 6f 10 80       	push   $0x80106fdd
801063af:	e8 94 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801063b4:	83 c3 01             	add    $0x1,%ebx
801063b7:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801063bd:	77 1f                	ja     801063de <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801063bf:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801063c2:	a8 01                	test   $0x1,%al
801063c4:	74 ee                	je     801063b4 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801063c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063cb:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801063d0:	83 ec 0c             	sub    $0xc,%esp
801063d3:	50                   	push   %eax
801063d4:	e8 2c bc ff ff       	call   80102005 <kfree>
801063d9:	83 c4 10             	add    $0x10,%esp
801063dc:	eb d6                	jmp    801063b4 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801063de:	83 ec 0c             	sub    $0xc,%esp
801063e1:	56                   	push   %esi
801063e2:	e8 1e bc ff ff       	call   80102005 <kfree>
}
801063e7:	83 c4 10             	add    $0x10,%esp
801063ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063ed:	5b                   	pop    %ebx
801063ee:	5e                   	pop    %esi
801063ef:	5d                   	pop    %ebp
801063f0:	c3                   	ret    

801063f1 <setupkvm>:
{
801063f1:	55                   	push   %ebp
801063f2:	89 e5                	mov    %esp,%ebp
801063f4:	56                   	push   %esi
801063f5:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc(-2)) == 0)
801063f6:	83 ec 0c             	sub    $0xc,%esp
801063f9:	6a fe                	push   $0xfffffffe
801063fb:	e8 4c bd ff ff       	call   8010214c <kalloc>
80106400:	89 c6                	mov    %eax,%esi
80106402:	83 c4 10             	add    $0x10,%esp
80106405:	85 c0                	test   %eax,%eax
80106407:	74 55                	je     8010645e <setupkvm+0x6d>
  memset(pgdir, 0, PGSIZE);
80106409:	83 ec 04             	sub    $0x4,%esp
8010640c:	68 00 10 00 00       	push   $0x1000
80106411:	6a 00                	push   $0x0
80106413:	50                   	push   %eax
80106414:	e8 c8 d9 ff ff       	call   80103de1 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106419:	83 c4 10             	add    $0x10,%esp
8010641c:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106421:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106427:	73 35                	jae    8010645e <setupkvm+0x6d>
                (uint)k->phys_start, k->perm) < 0) {
80106429:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010642c:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010642f:	29 c1                	sub    %eax,%ecx
80106431:	83 ec 08             	sub    $0x8,%esp
80106434:	ff 73 0c             	pushl  0xc(%ebx)
80106437:	50                   	push   %eax
80106438:	8b 13                	mov    (%ebx),%edx
8010643a:	89 f0                	mov    %esi,%eax
8010643c:	e8 c1 f9 ff ff       	call   80105e02 <mappages>
80106441:	83 c4 10             	add    $0x10,%esp
80106444:	85 c0                	test   %eax,%eax
80106446:	78 05                	js     8010644d <setupkvm+0x5c>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106448:	83 c3 10             	add    $0x10,%ebx
8010644b:	eb d4                	jmp    80106421 <setupkvm+0x30>
      freevm(pgdir);
8010644d:	83 ec 0c             	sub    $0xc,%esp
80106450:	56                   	push   %esi
80106451:	e8 2b ff ff ff       	call   80106381 <freevm>
      return 0;
80106456:	83 c4 10             	add    $0x10,%esp
80106459:	be 00 00 00 00       	mov    $0x0,%esi
}
8010645e:	89 f0                	mov    %esi,%eax
80106460:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106463:	5b                   	pop    %ebx
80106464:	5e                   	pop    %esi
80106465:	5d                   	pop    %ebp
80106466:	c3                   	ret    

80106467 <kvmalloc>:
{
80106467:	55                   	push   %ebp
80106468:	89 e5                	mov    %esp,%ebp
8010646a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010646d:	e8 7f ff ff ff       	call   801063f1 <setupkvm>
80106472:	a3 04 55 14 80       	mov    %eax,0x80145504
  switchkvm();
80106477:	e8 48 fb ff ff       	call   80105fc4 <switchkvm>
}
8010647c:	c9                   	leave  
8010647d:	c3                   	ret    

8010647e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010647e:	55                   	push   %ebp
8010647f:	89 e5                	mov    %esp,%ebp
80106481:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106484:	b9 00 00 00 00       	mov    $0x0,%ecx
80106489:	8b 55 0c             	mov    0xc(%ebp),%edx
8010648c:	8b 45 08             	mov    0x8(%ebp),%eax
8010648f:	e8 f6 f8 ff ff       	call   80105d8a <walkpgdir>
  if(pte == 0)
80106494:	85 c0                	test   %eax,%eax
80106496:	74 05                	je     8010649d <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106498:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010649b:	c9                   	leave  
8010649c:	c3                   	ret    
    panic("clearpteu");
8010649d:	83 ec 0c             	sub    $0xc,%esp
801064a0:	68 ee 6f 10 80       	push   $0x80106fee
801064a5:	e8 9e 9e ff ff       	call   80100348 <panic>

801064aa <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, int pid)
{
801064aa:	55                   	push   %ebp
801064ab:	89 e5                	mov    %esp,%ebp
801064ad:	57                   	push   %edi
801064ae:	56                   	push   %esi
801064af:	53                   	push   %ebx
801064b0:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801064b3:	e8 39 ff ff ff       	call   801063f1 <setupkvm>
801064b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
801064bb:	85 c0                	test   %eax,%eax
801064bd:	0f 84 d1 00 00 00    	je     80106594 <copyuvm+0xea>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801064c3:	bf 00 00 00 00       	mov    $0x0,%edi
801064c8:	89 fe                	mov    %edi,%esi
801064ca:	3b 75 0c             	cmp    0xc(%ebp),%esi
801064cd:	0f 83 c1 00 00 00    	jae    80106594 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801064d3:	89 75 e4             	mov    %esi,-0x1c(%ebp)
801064d6:	b9 00 00 00 00       	mov    $0x0,%ecx
801064db:	89 f2                	mov    %esi,%edx
801064dd:	8b 45 08             	mov    0x8(%ebp),%eax
801064e0:	e8 a5 f8 ff ff       	call   80105d8a <walkpgdir>
801064e5:	85 c0                	test   %eax,%eax
801064e7:	74 70                	je     80106559 <copyuvm+0xaf>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801064e9:	8b 18                	mov    (%eax),%ebx
801064eb:	f6 c3 01             	test   $0x1,%bl
801064ee:	74 76                	je     80106566 <copyuvm+0xbc>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801064f0:	89 df                	mov    %ebx,%edi
801064f2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    flags = PTE_FLAGS(*pte);
801064f8:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801064fe:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    if((mem = kalloc(pid)) == 0)
80106501:	83 ec 0c             	sub    $0xc,%esp
80106504:	ff 75 10             	pushl  0x10(%ebp)
80106507:	e8 40 bc ff ff       	call   8010214c <kalloc>
8010650c:	89 c3                	mov    %eax,%ebx
8010650e:	83 c4 10             	add    $0x10,%esp
80106511:	85 c0                	test   %eax,%eax
80106513:	74 6a                	je     8010657f <copyuvm+0xd5>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106515:	81 c7 00 00 00 80    	add    $0x80000000,%edi
8010651b:	83 ec 04             	sub    $0x4,%esp
8010651e:	68 00 10 00 00       	push   $0x1000
80106523:	57                   	push   %edi
80106524:	50                   	push   %eax
80106525:	e8 32 d9 ff ff       	call   80103e5c <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010652a:	83 c4 08             	add    $0x8,%esp
8010652d:	ff 75 e0             	pushl  -0x20(%ebp)
80106530:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106536:	50                   	push   %eax
80106537:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010653c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010653f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106542:	e8 bb f8 ff ff       	call   80105e02 <mappages>
80106547:	83 c4 10             	add    $0x10,%esp
8010654a:	85 c0                	test   %eax,%eax
8010654c:	78 25                	js     80106573 <copyuvm+0xc9>
  for(i = 0; i < sz; i += PGSIZE){
8010654e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106554:	e9 71 ff ff ff       	jmp    801064ca <copyuvm+0x20>
      panic("copyuvm: pte should exist");
80106559:	83 ec 0c             	sub    $0xc,%esp
8010655c:	68 f8 6f 10 80       	push   $0x80106ff8
80106561:	e8 e2 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106566:	83 ec 0c             	sub    $0xc,%esp
80106569:	68 12 70 10 80       	push   $0x80107012
8010656e:	e8 d5 9d ff ff       	call   80100348 <panic>
      kfree(mem);
80106573:	83 ec 0c             	sub    $0xc,%esp
80106576:	53                   	push   %ebx
80106577:	e8 89 ba ff ff       	call   80102005 <kfree>
      goto bad;
8010657c:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010657f:	83 ec 0c             	sub    $0xc,%esp
80106582:	ff 75 dc             	pushl  -0x24(%ebp)
80106585:	e8 f7 fd ff ff       	call   80106381 <freevm>
  return 0;
8010658a:	83 c4 10             	add    $0x10,%esp
8010658d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106594:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106597:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010659a:	5b                   	pop    %ebx
8010659b:	5e                   	pop    %esi
8010659c:	5f                   	pop    %edi
8010659d:	5d                   	pop    %ebp
8010659e:	c3                   	ret    

8010659f <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010659f:	55                   	push   %ebp
801065a0:	89 e5                	mov    %esp,%ebp
801065a2:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065a5:	b9 00 00 00 00       	mov    $0x0,%ecx
801065aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801065ad:	8b 45 08             	mov    0x8(%ebp),%eax
801065b0:	e8 d5 f7 ff ff       	call   80105d8a <walkpgdir>
  if((*pte & PTE_P) == 0)
801065b5:	8b 00                	mov    (%eax),%eax
801065b7:	a8 01                	test   $0x1,%al
801065b9:	74 10                	je     801065cb <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801065bb:	a8 04                	test   $0x4,%al
801065bd:	74 13                	je     801065d2 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065c4:	05 00 00 00 80       	add    $0x80000000,%eax
}
801065c9:	c9                   	leave  
801065ca:	c3                   	ret    
    return 0;
801065cb:	b8 00 00 00 00       	mov    $0x0,%eax
801065d0:	eb f7                	jmp    801065c9 <uva2ka+0x2a>
    return 0;
801065d2:	b8 00 00 00 00       	mov    $0x0,%eax
801065d7:	eb f0                	jmp    801065c9 <uva2ka+0x2a>

801065d9 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801065d9:	55                   	push   %ebp
801065da:	89 e5                	mov    %esp,%ebp
801065dc:	57                   	push   %edi
801065dd:	56                   	push   %esi
801065de:	53                   	push   %ebx
801065df:	83 ec 0c             	sub    $0xc,%esp
801065e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801065e5:	eb 25                	jmp    8010660c <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801065e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801065ea:	29 f2                	sub    %esi,%edx
801065ec:	01 d0                	add    %edx,%eax
801065ee:	83 ec 04             	sub    $0x4,%esp
801065f1:	53                   	push   %ebx
801065f2:	ff 75 10             	pushl  0x10(%ebp)
801065f5:	50                   	push   %eax
801065f6:	e8 61 d8 ff ff       	call   80103e5c <memmove>
    len -= n;
801065fb:	29 df                	sub    %ebx,%edi
    buf += n;
801065fd:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106600:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106606:	89 45 0c             	mov    %eax,0xc(%ebp)
80106609:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010660c:	85 ff                	test   %edi,%edi
8010660e:	74 2f                	je     8010663f <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106610:	8b 75 0c             	mov    0xc(%ebp),%esi
80106613:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106619:	83 ec 08             	sub    $0x8,%esp
8010661c:	56                   	push   %esi
8010661d:	ff 75 08             	pushl  0x8(%ebp)
80106620:	e8 7a ff ff ff       	call   8010659f <uva2ka>
    if(pa0 == 0)
80106625:	83 c4 10             	add    $0x10,%esp
80106628:	85 c0                	test   %eax,%eax
8010662a:	74 20                	je     8010664c <copyout+0x73>
    n = PGSIZE - (va - va0);
8010662c:	89 f3                	mov    %esi,%ebx
8010662e:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106631:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106637:	39 df                	cmp    %ebx,%edi
80106639:	73 ac                	jae    801065e7 <copyout+0xe>
      n = len;
8010663b:	89 fb                	mov    %edi,%ebx
8010663d:	eb a8                	jmp    801065e7 <copyout+0xe>
  }
  return 0;
8010663f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106644:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106647:	5b                   	pop    %ebx
80106648:	5e                   	pop    %esi
80106649:	5f                   	pop    %edi
8010664a:	5d                   	pop    %ebp
8010664b:	c3                   	ret    
      return -1;
8010664c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106651:	eb f1                	jmp    80106644 <copyout+0x6b>

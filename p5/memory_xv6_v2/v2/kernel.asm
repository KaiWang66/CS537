
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
80100015:	b8 00 90 12 00       	mov    $0x129000,%eax
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
80100028:	bc d0 b5 12 80       	mov    $0x8012b5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f1 2c 10 80       	mov    $0x80102cf1,%eax
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
80100041:	68 e0 b5 12 80       	push   $0x8012b5e0
80100046:	e8 e8 3d 00 00       	call   80103e33 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 30 fd 12 80    	mov    0x8012fd30,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc fc 12 80    	cmp    $0x8012fcdc,%ebx
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
80100077:	68 e0 b5 12 80       	push   $0x8012b5e0
8010007c:	e8 17 3e 00 00       	call   80103e98 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 93 3b 00 00       	call   80103c1f <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 2c fd 12 80    	mov    0x8012fd2c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc fc 12 80    	cmp    $0x8012fcdc,%ebx
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
801000c5:	68 e0 b5 12 80       	push   $0x8012b5e0
801000ca:	e8 c9 3d 00 00       	call   80103e98 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 45 3b 00 00       	call   80103c1f <acquiresleep>
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
801000ea:	68 60 67 10 80       	push   $0x80106760
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 71 67 10 80       	push   $0x80106771
80100100:	68 e0 b5 12 80       	push   $0x8012b5e0
80100105:	e8 ed 3b 00 00       	call   80103cf7 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 2c fd 12 80 dc 	movl   $0x8012fcdc,0x8012fd2c
80100111:	fc 12 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 30 fd 12 80 dc 	movl   $0x8012fcdc,0x8012fd30
8010011b:	fc 12 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 b6 12 80       	mov    $0x8012b614,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 30 fd 12 80       	mov    0x8012fd30,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 dc fc 12 80 	movl   $0x8012fcdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 78 67 10 80       	push   $0x80106778
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 a4 3a 00 00       	call   80103bec <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 30 fd 12 80       	mov    0x8012fd30,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 30 fd 12 80    	mov    %ebx,0x8012fd30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc fc 12 80    	cmp    $0x8012fcdc,%ebx
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
801001a8:	e8 fc 3a 00 00       	call   80103ca9 <holdingsleep>
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
801001cb:	68 7f 67 10 80       	push   $0x8010677f
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
801001e4:	e8 c0 3a 00 00       	call   80103ca9 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 75 3a 00 00       	call   80103c6e <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 b5 12 80 	movl   $0x8012b5e0,(%esp)
80100200:	e8 2e 3c 00 00       	call   80103e33 <acquire>
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
80100227:	a1 30 fd 12 80       	mov    0x8012fd30,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 dc fc 12 80 	movl   $0x8012fcdc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 30 fd 12 80       	mov    0x8012fd30,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 30 fd 12 80    	mov    %ebx,0x8012fd30
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 b5 12 80       	push   $0x8012b5e0
8010024c:	e8 47 3c 00 00       	call   80103e98 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 86 67 10 80       	push   $0x80106786
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
80100283:	c7 04 24 20 a5 12 80 	movl   $0x8012a520,(%esp)
8010028a:	e8 a4 3b 00 00       	call   80103e33 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ff 12 80       	mov    0x8012ffc0,%eax
8010029f:	3b 05 c4 ff 12 80    	cmp    0x8012ffc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 e5 31 00 00       	call   80103491 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 12 80       	push   $0x8012a520
801002ba:	68 c0 ff 12 80       	push   $0x8012ffc0
801002bf:	e8 74 36 00 00       	call   80103938 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 12 80       	push   $0x8012a520
801002d1:	e8 c2 3b 00 00       	call   80103e98 <release>
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
801002f1:	89 15 c0 ff 12 80    	mov    %edx,0x8012ffc0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 ff 12 80 	movzbl -0x7fed00c0(%edx),%ecx
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
80100324:	a3 c0 ff 12 80       	mov    %eax,0x8012ffc0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 12 80       	push   $0x8012a520
80100331:	e8 62 3b 00 00       	call   80103e98 <release>
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
80100350:	c7 05 54 a5 12 80 00 	movl   $0x0,0x8012a554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 a7 22 00 00       	call   80102606 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 67 10 80       	push   $0x8010678d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 db 70 10 80 	movl   $0x801070db,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 7e 39 00 00       	call   80103d12 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 a1 67 10 80       	push   $0x801067a1
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 a5 12 80 01 	movl   $0x1,0x8012a558
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
8010049e:	68 a5 67 10 80       	push   $0x801067a5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 9b 3a 00 00       	call   80103f5a <memmove>
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
801004d9:	e8 01 3a 00 00       	call   80103edf <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 a5 12 80 00 	cmpl   $0x0,0x8012a558
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
80100506:	e8 0e 4e 00 00       	call   80105319 <uartputc>
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
8010051f:	e8 f5 4d 00 00       	call   80105319 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 e9 4d 00 00       	call   80105319 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 dd 4d 00 00       	call   80105319 <uartputc>
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
80100576:	0f b6 92 d0 67 10 80 	movzbl -0x7fef9830(%edx),%edx
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
801005c3:	c7 04 24 20 a5 12 80 	movl   $0x8012a520,(%esp)
801005ca:	e8 64 38 00 00       	call   80103e33 <acquire>
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
801005ec:	68 20 a5 12 80       	push   $0x8012a520
801005f1:	e8 a2 38 00 00       	call   80103e98 <release>
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
80100614:	a1 54 a5 12 80       	mov    0x8012a554,%eax
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
80100633:	68 20 a5 12 80       	push   $0x8012a520
80100638:	e8 f6 37 00 00       	call   80103e33 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 bf 67 10 80       	push   $0x801067bf
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
801006ee:	be b8 67 10 80       	mov    $0x801067b8,%esi
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
8010072f:	68 20 a5 12 80       	push   $0x8012a520
80100734:	e8 5f 37 00 00       	call   80103e98 <release>
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
8010074a:	68 20 a5 12 80       	push   $0x8012a520
8010074f:	e8 df 36 00 00       	call   80103e33 <acquire>
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
80100772:	a1 c8 ff 12 80       	mov    0x8012ffc8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 ff 12 80    	sub    0x8012ffc0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 ff 12 80    	mov    %edx,0x8012ffc8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 ff 12 80    	mov    %cl,-0x7fed00c0(%eax)
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
801007bc:	a1 c0 ff 12 80       	mov    0x8012ffc0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 ff 12 80    	cmp    %eax,0x8012ffc8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 c8 ff 12 80       	mov    0x8012ffc8,%eax
801007d1:	a3 c4 ff 12 80       	mov    %eax,0x8012ffc4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 ff 12 80       	push   $0x8012ffc0
801007de:	e8 ba 32 00 00       	call   80103a9d <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 c8 ff 12 80       	mov    %eax,0x8012ffc8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 c8 ff 12 80       	mov    0x8012ffc8,%eax
801007fc:	3b 05 c4 ff 12 80    	cmp    0x8012ffc4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 40 ff 12 80 0a 	cmpb   $0xa,-0x7fed00c0(%edx)
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
8010084a:	a1 c8 ff 12 80       	mov    0x8012ffc8,%eax
8010084f:	3b 05 c4 ff 12 80    	cmp    0x8012ffc4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 ff 12 80       	mov    %eax,0x8012ffc8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 12 80       	push   $0x8012a520
80100873:	e8 20 36 00 00       	call   80103e98 <release>
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
80100887:	e8 ae 32 00 00       	call   80103b3a <procdump>
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
80100894:	68 c8 67 10 80       	push   $0x801067c8
80100899:	68 20 a5 12 80       	push   $0x8012a520
8010089e:	e8 54 34 00 00       	call   80103cf7 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 8c 09 13 80 ac 	movl   $0x801005ac,0x8013098c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 88 09 13 80 68 	movl   $0x80100268,0x80130988
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 a5 12 80 01 	movl   $0x1,0x8012a554
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
801008de:	e8 ae 2b 00 00       	call   80103491 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 48 21 00 00       	call   80102a36 <begin_op>

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
80100935:	e8 76 21 00 00       	call   80102ab0 <end_op>
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
8010094a:	e8 61 21 00 00       	call   80102ab0 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e1 67 10 80       	push   $0x801067e1
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
80100972:	e8 78 5b 00 00       	call   801064ef <setupkvm>
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
80100a0c:	e8 7b 59 00 00       	call   8010638c <allocuvm>
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
80100a3e:	e8 17 58 00 00       	call   8010625a <loaduvm>
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
80100a59:	e8 52 20 00 00       	call   80102ab0 <end_op>
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
80100a80:	e8 07 59 00 00       	call   8010638c <allocuvm>
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
80100aa9:	e8 d1 59 00 00       	call   8010647f <freevm>
80100aae:	83 c4 10             	add    $0x10,%esp
80100ab1:	e9 6e fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ab6:	89 c7                	mov    %eax,%edi
80100ab8:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100abe:	83 ec 08             	sub    $0x8,%esp
80100ac1:	50                   	push   %eax
80100ac2:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100ac8:	e8 af 5a 00 00       	call   8010657c <clearpteu>
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
80100aee:	e8 8e 35 00 00       	call   80104081 <strlen>
80100af3:	29 c7                	sub    %eax,%edi
80100af5:	83 ef 01             	sub    $0x1,%edi
80100af8:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100afb:	83 c4 04             	add    $0x4,%esp
80100afe:	ff 33                	pushl  (%ebx)
80100b00:	e8 7c 35 00 00       	call   80104081 <strlen>
80100b05:	83 c0 01             	add    $0x1,%eax
80100b08:	50                   	push   %eax
80100b09:	ff 33                	pushl  (%ebx)
80100b0b:	57                   	push   %edi
80100b0c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b12:	e8 c0 5b 00 00       	call   801066d7 <copyout>
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
80100b72:	e8 60 5b 00 00       	call   801066d7 <copyout>
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
80100baf:	e8 92 34 00 00       	call   80104046 <safestrcpy>
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
80100bdd:	e8 f2 54 00 00       	call   801060d4 <switchuvm>
  freevm(oldpgdir);
80100be2:	89 1c 24             	mov    %ebx,(%esp)
80100be5:	e8 95 58 00 00       	call   8010647f <freevm>
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
80100c25:	68 ed 67 10 80       	push   $0x801067ed
80100c2a:	68 e0 ff 12 80       	push   $0x8012ffe0
80100c2f:	e8 c3 30 00 00       	call   80103cf7 <initlock>
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
80100c40:	68 e0 ff 12 80       	push   $0x8012ffe0
80100c45:	e8 e9 31 00 00       	call   80103e33 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c4a:	83 c4 10             	add    $0x10,%esp
80100c4d:	bb 14 00 13 80       	mov    $0x80130014,%ebx
80100c52:	81 fb 74 09 13 80    	cmp    $0x80130974,%ebx
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
80100c6f:	68 e0 ff 12 80       	push   $0x8012ffe0
80100c74:	e8 1f 32 00 00       	call   80103e98 <release>
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
80100c86:	68 e0 ff 12 80       	push   $0x8012ffe0
80100c8b:	e8 08 32 00 00       	call   80103e98 <release>
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
80100ca4:	68 e0 ff 12 80       	push   $0x8012ffe0
80100ca9:	e8 85 31 00 00       	call   80103e33 <acquire>
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
80100cc1:	68 e0 ff 12 80       	push   $0x8012ffe0
80100cc6:	e8 cd 31 00 00       	call   80103e98 <release>
  return f;
}
80100ccb:	89 d8                	mov    %ebx,%eax
80100ccd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cd0:	c9                   	leave  
80100cd1:	c3                   	ret    
    panic("filedup");
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	68 f4 67 10 80       	push   $0x801067f4
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
80100ce9:	68 e0 ff 12 80       	push   $0x8012ffe0
80100cee:	e8 40 31 00 00       	call   80103e33 <acquire>
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
80100d0a:	68 e0 ff 12 80       	push   $0x8012ffe0
80100d0f:	e8 84 31 00 00       	call   80103e98 <release>
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
80100d1f:	68 fc 67 10 80       	push   $0x801067fc
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
80100d50:	68 e0 ff 12 80       	push   $0x8012ffe0
80100d55:	e8 3e 31 00 00       	call   80103e98 <release>
  if(ff.type == FD_PIPE)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	83 c4 10             	add    $0x10,%esp
80100d60:	83 f8 01             	cmp    $0x1,%eax
80100d63:	74 1f                	je     80100d84 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d65:	83 f8 02             	cmp    $0x2,%eax
80100d68:	75 ad                	jne    80100d17 <fileclose+0x38>
    begin_op();
80100d6a:	e8 c7 1c 00 00       	call   80102a36 <begin_op>
    iput(ff.ip);
80100d6f:	83 ec 0c             	sub    $0xc,%esp
80100d72:	ff 75 f0             	pushl  -0x10(%ebp)
80100d75:	e8 1a 09 00 00       	call   80101694 <iput>
    end_op();
80100d7a:	e8 31 1d 00 00       	call   80102ab0 <end_op>
80100d7f:	83 c4 10             	add    $0x10,%esp
80100d82:	eb 93                	jmp    80100d17 <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d84:	83 ec 08             	sub    $0x8,%esp
80100d87:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d8b:	50                   	push   %eax
80100d8c:	ff 75 ec             	pushl  -0x14(%ebp)
80100d8f:	e8 23 23 00 00       	call   801030b7 <pipeclose>
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
80100e48:	e8 c2 23 00 00       	call   8010320f <piperead>
80100e4d:	89 c6                	mov    %eax,%esi
80100e4f:	83 c4 10             	add    $0x10,%esp
80100e52:	eb df                	jmp    80100e33 <fileread+0x50>
  panic("fileread");
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	68 06 68 10 80       	push   $0x80106806
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
80100ea1:	e8 9d 22 00 00       	call   80103143 <pipewrite>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	e9 80 00 00 00       	jmp    80100f2e <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100eae:	e8 83 1b 00 00       	call   80102a36 <begin_op>
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
80100ee9:	e8 c2 1b 00 00       	call   80102ab0 <end_op>

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
80100f1c:	68 0f 68 10 80       	push   $0x8010680f
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
80100f39:	68 15 68 10 80       	push   $0x80106815
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
80100f96:	e8 bf 2f 00 00       	call   80103f5a <memmove>
80100f9b:	83 c4 10             	add    $0x10,%esp
80100f9e:	eb 17                	jmp    80100fb7 <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fa0:	83 ec 04             	sub    $0x4,%esp
80100fa3:	56                   	push   %esi
80100fa4:	50                   	push   %eax
80100fa5:	57                   	push   %edi
80100fa6:	e8 af 2f 00 00       	call   80103f5a <memmove>
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
80100feb:	e8 ef 2e 00 00       	call   80103edf <memset>
  log_write(bp);
80100ff0:	89 1c 24             	mov    %ebx,(%esp)
80100ff3:	e8 67 1b 00 00       	call   80102b5f <log_write>
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
8010102f:	39 35 e0 09 13 80    	cmp    %esi,0x801309e0
80101035:	76 75                	jbe    801010ac <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
80101037:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
8010103d:	85 f6                	test   %esi,%esi
8010103f:	0f 49 c6             	cmovns %esi,%eax
80101042:	c1 f8 0c             	sar    $0xc,%eax
80101045:	03 05 f8 09 13 80    	add    0x801309f8,%eax
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
8010106f:	3b 1d e0 09 13 80    	cmp    0x801309e0,%ebx
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
801010af:	68 1f 68 10 80       	push   $0x8010681f
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
801010cb:	e8 8f 1a 00 00       	call   80102b5f <log_write>
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
8010117c:	e8 de 19 00 00       	call   80102b5f <log_write>
80101181:	83 c4 10             	add    $0x10,%esp
80101184:	eb bf                	jmp    80101145 <bmap+0x58>
  panic("bmap: out of range");
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	68 35 68 10 80       	push   $0x80106835
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
801011a1:	68 00 0a 13 80       	push   $0x80130a00
801011a6:	e8 88 2c 00 00       	call   80103e33 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011ab:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011ae:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b3:	bb 34 0a 13 80       	mov    $0x80130a34,%ebx
801011b8:	eb 0a                	jmp    801011c4 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ba:	85 f6                	test   %esi,%esi
801011bc:	74 3b                	je     801011f9 <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011be:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011c4:	81 fb 54 26 13 80    	cmp    $0x80132654,%ebx
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
801011e8:	68 00 0a 13 80       	push   $0x80130a00
801011ed:	e8 a6 2c 00 00       	call   80103e98 <release>
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
8010121e:	68 00 0a 13 80       	push   $0x80130a00
80101223:	e8 70 2c 00 00       	call   80103e98 <release>
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
80101238:	68 48 68 10 80       	push   $0x80106848
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
80101261:	e8 f4 2c 00 00       	call   80103f5a <memmove>
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
80101282:	68 e0 09 13 80       	push   $0x801309e0
80101287:	50                   	push   %eax
80101288:	e8 b5 ff ff ff       	call   80101242 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010128d:	89 d8                	mov    %ebx,%eax
8010128f:	c1 e8 0c             	shr    $0xc,%eax
80101292:	03 05 f8 09 13 80    	add    0x801309f8,%eax
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
801012d4:	e8 86 18 00 00       	call   80102b5f <log_write>
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
801012ee:	68 58 68 10 80       	push   $0x80106858
801012f3:	e8 50 f0 ff ff       	call   80100348 <panic>

801012f8 <iinit>:
{
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	53                   	push   %ebx
801012fc:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012ff:	68 6b 68 10 80       	push   $0x8010686b
80101304:	68 00 0a 13 80       	push   $0x80130a00
80101309:	e8 e9 29 00 00       	call   80103cf7 <initlock>
  for(i = 0; i < NINODE; i++) {
8010130e:	83 c4 10             	add    $0x10,%esp
80101311:	bb 00 00 00 00       	mov    $0x0,%ebx
80101316:	eb 21                	jmp    80101339 <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
80101318:	83 ec 08             	sub    $0x8,%esp
8010131b:	68 72 68 10 80       	push   $0x80106872
80101320:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101323:	89 d0                	mov    %edx,%eax
80101325:	c1 e0 04             	shl    $0x4,%eax
80101328:	05 40 0a 13 80       	add    $0x80130a40,%eax
8010132d:	50                   	push   %eax
8010132e:	e8 b9 28 00 00       	call   80103bec <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101333:	83 c3 01             	add    $0x1,%ebx
80101336:	83 c4 10             	add    $0x10,%esp
80101339:	83 fb 31             	cmp    $0x31,%ebx
8010133c:	7e da                	jle    80101318 <iinit+0x20>
  readsb(dev, &sb);
8010133e:	83 ec 08             	sub    $0x8,%esp
80101341:	68 e0 09 13 80       	push   $0x801309e0
80101346:	ff 75 08             	pushl  0x8(%ebp)
80101349:	e8 f4 fe ff ff       	call   80101242 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010134e:	ff 35 f8 09 13 80    	pushl  0x801309f8
80101354:	ff 35 f4 09 13 80    	pushl  0x801309f4
8010135a:	ff 35 f0 09 13 80    	pushl  0x801309f0
80101360:	ff 35 ec 09 13 80    	pushl  0x801309ec
80101366:	ff 35 e8 09 13 80    	pushl  0x801309e8
8010136c:	ff 35 e4 09 13 80    	pushl  0x801309e4
80101372:	ff 35 e0 09 13 80    	pushl  0x801309e0
80101378:	68 d8 68 10 80       	push   $0x801068d8
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
801013a1:	39 1d e8 09 13 80    	cmp    %ebx,0x801309e8
801013a7:	76 3f                	jbe    801013e8 <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
801013a9:	89 d8                	mov    %ebx,%eax
801013ab:	c1 e8 03             	shr    $0x3,%eax
801013ae:	03 05 f4 09 13 80    	add    0x801309f4,%eax
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
801013eb:	68 78 68 10 80       	push   $0x80106878
801013f0:	e8 53 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013f5:	83 ec 04             	sub    $0x4,%esp
801013f8:	6a 40                	push   $0x40
801013fa:	6a 00                	push   $0x0
801013fc:	57                   	push   %edi
801013fd:	e8 dd 2a 00 00       	call   80103edf <memset>
      dip->type = type;
80101402:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101406:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101409:	89 34 24             	mov    %esi,(%esp)
8010140c:	e8 4e 17 00 00       	call   80102b5f <log_write>
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
8010143a:	03 05 f4 09 13 80    	add    0x801309f4,%eax
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
8010148c:	e8 c9 2a 00 00       	call   80103f5a <memmove>
  log_write(bp);
80101491:	89 34 24             	mov    %esi,(%esp)
80101494:	e8 c6 16 00 00       	call   80102b5f <log_write>
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
80101567:	68 00 0a 13 80       	push   $0x80130a00
8010156c:	e8 c2 28 00 00       	call   80103e33 <acquire>
  ip->ref++;
80101571:	8b 43 08             	mov    0x8(%ebx),%eax
80101574:	83 c0 01             	add    $0x1,%eax
80101577:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010157a:	c7 04 24 00 0a 13 80 	movl   $0x80130a00,(%esp)
80101581:	e8 12 29 00 00       	call   80103e98 <release>
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
801015a6:	e8 74 26 00 00       	call   80103c1f <acquiresleep>
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
801015be:	68 8a 68 10 80       	push   $0x8010688a
801015c3:	e8 80 ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015c8:	8b 43 04             	mov    0x4(%ebx),%eax
801015cb:	c1 e8 03             	shr    $0x3,%eax
801015ce:	03 05 f4 09 13 80    	add    0x801309f4,%eax
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
80101620:	e8 35 29 00 00       	call   80103f5a <memmove>
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
80101645:	68 90 68 10 80       	push   $0x80106890
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
80101662:	e8 42 26 00 00       	call   80103ca9 <holdingsleep>
80101667:	83 c4 10             	add    $0x10,%esp
8010166a:	85 c0                	test   %eax,%eax
8010166c:	74 19                	je     80101687 <iunlock+0x38>
8010166e:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101672:	7e 13                	jle    80101687 <iunlock+0x38>
  releasesleep(&ip->lock);
80101674:	83 ec 0c             	sub    $0xc,%esp
80101677:	56                   	push   %esi
80101678:	e8 f1 25 00 00       	call   80103c6e <releasesleep>
}
8010167d:	83 c4 10             	add    $0x10,%esp
80101680:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101683:	5b                   	pop    %ebx
80101684:	5e                   	pop    %esi
80101685:	5d                   	pop    %ebp
80101686:	c3                   	ret    
    panic("iunlock");
80101687:	83 ec 0c             	sub    $0xc,%esp
8010168a:	68 9f 68 10 80       	push   $0x8010689f
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
801016a4:	e8 76 25 00 00       	call   80103c1f <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016a9:	83 c4 10             	add    $0x10,%esp
801016ac:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016b0:	74 07                	je     801016b9 <iput+0x25>
801016b2:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016b7:	74 35                	je     801016ee <iput+0x5a>
  releasesleep(&ip->lock);
801016b9:	83 ec 0c             	sub    $0xc,%esp
801016bc:	56                   	push   %esi
801016bd:	e8 ac 25 00 00       	call   80103c6e <releasesleep>
  acquire(&icache.lock);
801016c2:	c7 04 24 00 0a 13 80 	movl   $0x80130a00,(%esp)
801016c9:	e8 65 27 00 00       	call   80103e33 <acquire>
  ip->ref--;
801016ce:	8b 43 08             	mov    0x8(%ebx),%eax
801016d1:	83 e8 01             	sub    $0x1,%eax
801016d4:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016d7:	c7 04 24 00 0a 13 80 	movl   $0x80130a00,(%esp)
801016de:	e8 b5 27 00 00       	call   80103e98 <release>
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
801016f1:	68 00 0a 13 80       	push   $0x80130a00
801016f6:	e8 38 27 00 00       	call   80103e33 <acquire>
    int r = ip->ref;
801016fb:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016fe:	c7 04 24 00 0a 13 80 	movl   $0x80130a00,(%esp)
80101705:	e8 8e 27 00 00       	call   80103e98 <release>
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
801017d0:	8b 04 c5 80 09 13 80 	mov    -0x7fecf680(,%eax,8),%eax
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
80101836:	e8 1f 27 00 00       	call   80103f5a <memmove>
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
801018cd:	8b 04 c5 84 09 13 80 	mov    -0x7fecf67c(,%eax,8),%eax
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
80101932:	e8 23 26 00 00       	call   80103f5a <memmove>
    log_write(bp);
80101937:	89 3c 24             	mov    %edi,(%esp)
8010193a:	e8 20 12 00 00       	call   80102b5f <log_write>
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
801019b5:	e8 07 26 00 00       	call   80103fc1 <strncmp>
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
801019dc:	68 a7 68 10 80       	push   $0x801068a7
801019e1:	e8 62 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 b9 68 10 80       	push   $0x801068b9
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
80101a66:	e8 26 1a 00 00       	call   80103491 <myproc>
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
80101b9e:	68 c8 68 10 80       	push   $0x801068c8
80101ba3:	e8 a0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101ba8:	83 ec 04             	sub    $0x4,%esp
80101bab:	6a 0e                	push   $0xe
80101bad:	57                   	push   %edi
80101bae:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bb1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bb4:	50                   	push   %eax
80101bb5:	e8 44 24 00 00       	call   80103ffe <strncpy>
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
80101be3:	68 d4 6e 10 80       	push   $0x80106ed4
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
80101cd8:	68 2b 69 10 80       	push   $0x8010692b
80101cdd:	e8 66 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	68 34 69 10 80       	push   $0x80106934
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
80101d12:	68 46 69 10 80       	push   $0x80106946
80101d17:	68 80 a5 12 80       	push   $0x8012a580
80101d1c:	e8 d6 1f 00 00       	call   80103cf7 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d21:	83 c4 08             	add    $0x8,%esp
80101d24:	a1 20 2d 13 80       	mov    0x80132d20,%eax
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
80101d68:	c7 05 60 a5 12 80 01 	movl   $0x1,0x8012a560
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
80101d87:	68 80 a5 12 80       	push   $0x8012a580
80101d8c:	e8 a2 20 00 00       	call   80103e33 <acquire>

  if((b = idequeue) == 0){
80101d91:	8b 1d 64 a5 12 80    	mov    0x8012a564,%ebx
80101d97:	83 c4 10             	add    $0x10,%esp
80101d9a:	85 db                	test   %ebx,%ebx
80101d9c:	74 48                	je     80101de6 <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d9e:	8b 43 58             	mov    0x58(%ebx),%eax
80101da1:	a3 64 a5 12 80       	mov    %eax,0x8012a564

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
80101db9:	e8 df 1c 00 00       	call   80103a9d <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101dbe:	a1 64 a5 12 80       	mov    0x8012a564,%eax
80101dc3:	83 c4 10             	add    $0x10,%esp
80101dc6:	85 c0                	test   %eax,%eax
80101dc8:	74 05                	je     80101dcf <ideintr+0x50>
    idestart(idequeue);
80101dca:	e8 80 fe ff ff       	call   80101c4f <idestart>

  release(&idelock);
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	68 80 a5 12 80       	push   $0x8012a580
80101dd7:	e8 bc 20 00 00       	call   80103e98 <release>
80101ddc:	83 c4 10             	add    $0x10,%esp
}
80101ddf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101de2:	5b                   	pop    %ebx
80101de3:	5f                   	pop    %edi
80101de4:	5d                   	pop    %ebp
80101de5:	c3                   	ret    
    release(&idelock);
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 80 a5 12 80       	push   $0x8012a580
80101dee:	e8 a5 20 00 00       	call   80103e98 <release>
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
80101e26:	e8 7e 1e 00 00       	call   80103ca9 <holdingsleep>
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
80101e42:	83 3d 60 a5 12 80 00 	cmpl   $0x0,0x8012a560
80101e49:	74 38                	je     80101e83 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 80 a5 12 80       	push   $0x8012a580
80101e53:	e8 db 1f 00 00       	call   80103e33 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e58:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e5f:	83 c4 10             	add    $0x10,%esp
80101e62:	ba 64 a5 12 80       	mov    $0x8012a564,%edx
80101e67:	eb 2a                	jmp    80101e93 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e69:	83 ec 0c             	sub    $0xc,%esp
80101e6c:	68 4a 69 10 80       	push   $0x8010694a
80101e71:	e8 d2 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e76:	83 ec 0c             	sub    $0xc,%esp
80101e79:	68 60 69 10 80       	push   $0x80106960
80101e7e:	e8 c5 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e83:	83 ec 0c             	sub    $0xc,%esp
80101e86:	68 75 69 10 80       	push   $0x80106975
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
80101e9b:	39 1d 64 a5 12 80    	cmp    %ebx,0x8012a564
80101ea1:	75 1a                	jne    80101ebd <iderw+0xa5>
    idestart(b);
80101ea3:	89 d8                	mov    %ebx,%eax
80101ea5:	e8 a5 fd ff ff       	call   80101c4f <idestart>
80101eaa:	eb 11                	jmp    80101ebd <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101eac:	83 ec 08             	sub    $0x8,%esp
80101eaf:	68 80 a5 12 80       	push   $0x8012a580
80101eb4:	53                   	push   %ebx
80101eb5:	e8 7e 1a 00 00       	call   80103938 <sleep>
80101eba:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101ebd:	8b 03                	mov    (%ebx),%eax
80101ebf:	83 e0 06             	and    $0x6,%eax
80101ec2:	83 f8 02             	cmp    $0x2,%eax
80101ec5:	75 e5                	jne    80101eac <iderw+0x94>
  }


  release(&idelock);
80101ec7:	83 ec 0c             	sub    $0xc,%esp
80101eca:	68 80 a5 12 80       	push   $0x8012a580
80101ecf:	e8 c4 1f 00 00       	call   80103e98 <release>
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
80101edf:	8b 15 54 26 13 80    	mov    0x80132654,%edx
80101ee5:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ee7:	a1 54 26 13 80       	mov    0x80132654,%eax
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
80101ef4:	8b 0d 54 26 13 80    	mov    0x80132654,%ecx
80101efa:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101efc:	a1 54 26 13 80       	mov    0x80132654,%eax
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
80101f0f:	c7 05 54 26 13 80 00 	movl   $0xfec00000,0x80132654
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
80101f36:	0f b6 15 80 27 13 80 	movzbl 0x80132780,%edx
80101f3d:	39 c2                	cmp    %eax,%edx
80101f3f:	75 07                	jne    80101f48 <ioapicinit+0x42>
{
80101f41:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f46:	eb 36                	jmp    80101f7e <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f48:	83 ec 0c             	sub    $0xc,%esp
80101f4b:	68 94 69 10 80       	push   $0x80106994
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

80101fb0 <isValid>:
  int use_lock;
  struct run *freelist;
} kmem;

int 
isValid(struct run *r, int pid) {
80101fb0:	55                   	push   %ebp
80101fb1:	89 e5                	mov    %esp,%ebp
80101fb3:	56                   	push   %esi
80101fb4:	53                   	push   %ebx
80101fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  if (pid == -2) {
80101fb8:	83 fe fe             	cmp    $0xfffffffe,%esi
80101fbb:	74 6a                	je     80102027 <isValid+0x77>
    return 1;
  }
  int addr = (V2P((char*)r) >> 12);
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80101fc6:	c1 e9 0c             	shr    $0xc,%ecx
  for (int i = 0; i < size; i++) {
80101fc9:	b8 00 00 00 00       	mov    $0x0,%eax
80101fce:	eb 1a                	jmp    80101fea <isValid+0x3a>
    if (frame[i] == addr - 1 && mem_pid[i] != -2 && mem_pid[i] != pid) {
80101fd0:	8b 1c 85 00 80 10 80 	mov    -0x7fef8000(,%eax,4),%ebx
80101fd7:	83 fb fe             	cmp    $0xfffffffe,%ebx
80101fda:	74 24                	je     80102000 <isValid+0x50>
80101fdc:	39 f3                	cmp    %esi,%ebx
80101fde:	74 20                	je     80102000 <isValid+0x50>
      return 0;
80101fe0:	b8 00 00 00 00       	mov    $0x0,%eax
80101fe5:	eb 3c                	jmp    80102023 <isValid+0x73>
  for (int i = 0; i < size; i++) {
80101fe7:	83 c0 01             	add    $0x1,%eax
80101fea:	39 05 b8 a5 12 80    	cmp    %eax,0x8012a5b8
80101ff0:	7e 2c                	jle    8010201e <isValid+0x6e>
    if (frame[i] == addr - 1 && mem_pid[i] != -2 && mem_pid[i] != pid) {
80101ff2:	8b 14 85 00 80 11 80 	mov    -0x7fee8000(,%eax,4),%edx
80101ff9:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80101ffc:	39 da                	cmp    %ebx,%edx
80101ffe:	74 d0                	je     80101fd0 <isValid+0x20>
    } else if (frame[i] == addr + 1 && mem_pid[i] != -2 && mem_pid[i] != pid) {
80102000:	8d 59 01             	lea    0x1(%ecx),%ebx
80102003:	39 da                	cmp    %ebx,%edx
80102005:	75 e0                	jne    80101fe7 <isValid+0x37>
80102007:	8b 14 85 00 80 10 80 	mov    -0x7fef8000(,%eax,4),%edx
8010200e:	83 fa fe             	cmp    $0xfffffffe,%edx
80102011:	74 d4                	je     80101fe7 <isValid+0x37>
80102013:	39 f2                	cmp    %esi,%edx
80102015:	74 d0                	je     80101fe7 <isValid+0x37>
      return 0;
80102017:	b8 00 00 00 00       	mov    $0x0,%eax
8010201c:	eb 05                	jmp    80102023 <isValid+0x73>
    } 
    // else if (frame[i] < addr + 1) {
    //   return 1;
    // }
  }
  return 1;
8010201e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80102023:	5b                   	pop    %ebx
80102024:	5e                   	pop    %esi
80102025:	5d                   	pop    %ebp
80102026:	c3                   	ret    
    return 1;
80102027:	b8 01 00 00 00       	mov    $0x1,%eax
8010202c:	eb f5                	jmp    80102023 <isValid+0x73>

8010202e <add2frame>:

void
add2frame(struct run *r, int pid) {
8010202e:	55                   	push   %ebp
8010202f:	89 e5                	mov    %esp,%ebp
80102031:	56                   	push   %esi
80102032:	53                   	push   %ebx
  int addr = (V2P((char*)r) >> 12);
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
8010203c:	c1 eb 0c             	shr    $0xc,%ebx
8010203f:	89 d9                	mov    %ebx,%ecx
  int added = 0;
  // cprintf("add2frame : addr -> %d\n", addr);
  for (int i = 0; i < size; i++) {
80102041:	b8 00 00 00 00       	mov    $0x0,%eax
80102046:	8b 15 b8 a5 12 80    	mov    0x8012a5b8,%edx
8010204c:	39 c2                	cmp    %eax,%edx
8010204e:	7e 49                	jle    80102099 <add2frame+0x6b>
    if (frame[i] < addr) {
80102050:	39 0c 85 00 80 11 80 	cmp    %ecx,-0x7fee8000(,%eax,4)
80102057:	7c 26                	jl     8010207f <add2frame+0x51>
  for (int i = 0; i < size; i++) {
80102059:	83 c0 01             	add    $0x1,%eax
8010205c:	eb e8                	jmp    80102046 <add2frame+0x18>
      for (int j = size; j >= i + 1; j--) {
        frame[j] = frame[j - 1];
8010205e:	8d 4a ff             	lea    -0x1(%edx),%ecx
80102061:	8b 34 8d 00 80 11 80 	mov    -0x7fee8000(,%ecx,4),%esi
80102068:	89 34 95 00 80 11 80 	mov    %esi,-0x7fee8000(,%edx,4)
        mem_pid[j] = mem_pid[j - 1];
8010206f:	8b 34 8d 00 80 10 80 	mov    -0x7fef8000(,%ecx,4),%esi
80102076:	89 34 95 00 80 10 80 	mov    %esi,-0x7fef8000(,%edx,4)
      for (int j = size; j >= i + 1; j--) {
8010207d:	89 ca                	mov    %ecx,%edx
8010207f:	8d 48 01             	lea    0x1(%eax),%ecx
80102082:	39 d1                	cmp    %edx,%ecx
80102084:	7e d8                	jle    8010205e <add2frame+0x30>
      }
      frame[i] = addr;
80102086:	89 1c 85 00 80 11 80 	mov    %ebx,-0x7fee8000(,%eax,4)
      mem_pid[i] = pid;
8010208d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80102090:	89 1c 85 00 80 10 80 	mov    %ebx,-0x7fef8000(,%eax,4)
80102097:	eb 11                	jmp    801020aa <add2frame+0x7c>
      added = 1;
      break;
    }
  }
  if (added == 0) {
    frame[size] = addr;
80102099:	89 1c 95 00 80 11 80 	mov    %ebx,-0x7fee8000(,%edx,4)
    mem_pid[size] = pid;
801020a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a3:	89 04 95 00 80 10 80 	mov    %eax,-0x7fef8000(,%edx,4)
  }
}
801020aa:	5b                   	pop    %ebx
801020ab:	5e                   	pop    %esi
801020ac:	5d                   	pop    %ebp
801020ad:	c3                   	ret    

801020ae <insert>:


struct run*
insert(int pid) 
{
801020ae:	55                   	push   %ebp
801020af:	89 e5                	mov    %esp,%ebp
801020b1:	57                   	push   %edi
801020b2:	56                   	push   %esi
801020b3:	53                   	push   %ebx
801020b4:	83 ec 04             	sub    $0x4,%esp
801020b7:	8b 75 08             	mov    0x8(%ebp),%esi
  struct run *r = kmem.freelist;
801020ba:	a1 98 26 13 80       	mov    0x80132698,%eax
801020bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801020c2:	89 c3                	mov    %eax,%ebx
  struct run *prev = NULL;
801020c4:	bf 00 00 00 00       	mov    $0x0,%edi
  while (r) {
801020c9:	85 db                	test   %ebx,%ebx
801020cb:	74 2d                	je     801020fa <insert+0x4c>
    if (isValid(r, pid)) {
801020cd:	56                   	push   %esi
801020ce:	53                   	push   %ebx
801020cf:	e8 dc fe ff ff       	call   80101fb0 <isValid>
801020d4:	83 c4 08             	add    $0x8,%esp
801020d7:	85 c0                	test   %eax,%eax
801020d9:	75 06                	jne    801020e1 <insert+0x33>
      }
      add2frame(r, pid);
      size++;
      break;
    }
    prev = r;
801020db:	89 df                	mov    %ebx,%edi
    r = r->next;
801020dd:	8b 1b                	mov    (%ebx),%ebx
801020df:	eb e8                	jmp    801020c9 <insert+0x1b>
      if (prev == NULL) {
801020e1:	85 ff                	test   %edi,%edi
801020e3:	74 1f                	je     80102104 <insert+0x56>
        prev -> next = r -> next;
801020e5:	8b 03                	mov    (%ebx),%eax
801020e7:	89 07                	mov    %eax,(%edi)
      add2frame(r, pid);
801020e9:	56                   	push   %esi
801020ea:	53                   	push   %ebx
801020eb:	e8 3e ff ff ff       	call   8010202e <add2frame>
      size++;
801020f0:	83 05 b8 a5 12 80 01 	addl   $0x1,0x8012a5b8
      break;
801020f7:	83 c4 08             	add    $0x8,%esp
  }
  return r;
}
801020fa:	89 d8                	mov    %ebx,%eax
801020fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020ff:	5b                   	pop    %ebx
80102100:	5e                   	pop    %esi
80102101:	5f                   	pop    %edi
80102102:	5d                   	pop    %ebp
80102103:	c3                   	ret    
        kmem.freelist = kmem.freelist->next;
80102104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102107:	8b 00                	mov    (%eax),%eax
80102109:	a3 98 26 13 80       	mov    %eax,0x80132698
8010210e:	eb d9                	jmp    801020e9 <insert+0x3b>

80102110 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
80102113:	56                   	push   %esi
80102114:	53                   	push   %ebx
80102115:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102118:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
8010211e:	75 5e                	jne    8010217e <kfree+0x6e>
80102120:	81 fb c8 54 13 80    	cmp    $0x801354c8,%ebx
80102126:	72 56                	jb     8010217e <kfree+0x6e>
80102128:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
8010212e:	81 fe ff ff ff 0d    	cmp    $0xdffffff,%esi
80102134:	77 48                	ja     8010217e <kfree+0x6e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102136:	83 ec 04             	sub    $0x4,%esp
80102139:	68 00 10 00 00       	push   $0x1000
8010213e:	6a 01                	push   $0x1
80102140:	53                   	push   %ebx
80102141:	e8 99 1d 00 00       	call   80103edf <memset>

  if(kmem.use_lock)
80102146:	83 c4 10             	add    $0x10,%esp
80102149:	83 3d 94 26 13 80 00 	cmpl   $0x0,0x80132694
80102150:	75 39                	jne    8010218b <kfree+0x7b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102152:	a1 98 26 13 80       	mov    0x80132698,%eax
80102157:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102159:	89 1d 98 26 13 80    	mov    %ebx,0x80132698
  // update frame
  int found = 0;
  if (flag == 1) {
8010215f:	8b 1d b4 a5 12 80    	mov    0x8012a5b4,%ebx
80102165:	83 fb 01             	cmp    $0x1,%ebx
80102168:	74 33                	je     8010219d <kfree+0x8d>
    } else {
      size--;
    }
  }

  if(kmem.use_lock)
8010216a:	83 3d 94 26 13 80 00 	cmpl   $0x0,0x80132694
80102171:	0f 85 8d 00 00 00    	jne    80102204 <kfree+0xf4>
    release(&kmem.lock);
}
80102177:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010217a:	5b                   	pop    %ebx
8010217b:	5e                   	pop    %esi
8010217c:	5d                   	pop    %ebp
8010217d:	c3                   	ret    
    panic("kfree");
8010217e:	83 ec 0c             	sub    $0xc,%esp
80102181:	68 c6 69 10 80       	push   $0x801069c6
80102186:	e8 bd e1 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010218b:	83 ec 0c             	sub    $0xc,%esp
8010218e:	68 60 26 13 80       	push   $0x80132660
80102193:	e8 9b 1c 00 00       	call   80103e33 <acquire>
80102198:	83 c4 10             	add    $0x10,%esp
8010219b:	eb b5                	jmp    80102152 <kfree+0x42>
    int addr = (V2P((char*)r) >> 12);
8010219d:	c1 ee 0c             	shr    $0xc,%esi
801021a0:	89 f1                	mov    %esi,%ecx
    for (int i = 0; i < size; i++) {
801021a2:	b8 00 00 00 00       	mov    $0x0,%eax
801021a7:	8b 15 b8 a5 12 80    	mov    0x8012a5b8,%edx
801021ad:	39 c2                	cmp    %eax,%edx
801021af:	7e 38                	jle    801021e9 <kfree+0xd9>
      if (frame[i] == addr) {
801021b1:	39 0c 85 00 80 11 80 	cmp    %ecx,-0x7fee8000(,%eax,4)
801021b8:	74 26                	je     801021e0 <kfree+0xd0>
    for (int i = 0; i < size; i++) {
801021ba:	83 c0 01             	add    $0x1,%eax
801021bd:	eb e8                	jmp    801021a7 <kfree+0x97>
          frame[j] = frame[j + 1];
801021bf:	8d 48 01             	lea    0x1(%eax),%ecx
801021c2:	8b 34 8d 00 80 11 80 	mov    -0x7fee8000(,%ecx,4),%esi
801021c9:	89 34 85 00 80 11 80 	mov    %esi,-0x7fee8000(,%eax,4)
          mem_pid[j] = mem_pid[j + 1];
801021d0:	8b 34 8d 00 80 10 80 	mov    -0x7fef8000(,%ecx,4),%esi
801021d7:	89 34 85 00 80 10 80 	mov    %esi,-0x7fef8000(,%eax,4)
        for (int j = i; j < size - 1; j++) {
801021de:	89 c8                	mov    %ecx,%eax
801021e0:	8d 4a ff             	lea    -0x1(%edx),%ecx
801021e3:	39 c1                	cmp    %eax,%ecx
801021e5:	7f d8                	jg     801021bf <kfree+0xaf>
801021e7:	eb 05                	jmp    801021ee <kfree+0xde>
  int found = 0;
801021e9:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (found == 0) {
801021ee:	85 db                	test   %ebx,%ebx
801021f0:	0f 84 74 ff ff ff    	je     8010216a <kfree+0x5a>
      size--;
801021f6:	83 ea 01             	sub    $0x1,%edx
801021f9:	89 15 b8 a5 12 80    	mov    %edx,0x8012a5b8
801021ff:	e9 66 ff ff ff       	jmp    8010216a <kfree+0x5a>
    release(&kmem.lock);
80102204:	83 ec 0c             	sub    $0xc,%esp
80102207:	68 60 26 13 80       	push   $0x80132660
8010220c:	e8 87 1c 00 00       	call   80103e98 <release>
80102211:	83 c4 10             	add    $0x10,%esp
}
80102214:	e9 5e ff ff ff       	jmp    80102177 <kfree+0x67>

80102219 <freerange>:
{
80102219:	55                   	push   %ebp
8010221a:	89 e5                	mov    %esp,%ebp
8010221c:	56                   	push   %esi
8010221d:	53                   	push   %ebx
8010221e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102221:	8b 45 08             	mov    0x8(%ebp),%eax
80102224:	05 ff 0f 00 00       	add    $0xfff,%eax
80102229:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010222e:	eb 0e                	jmp    8010223e <freerange+0x25>
    kfree(p);
80102230:	83 ec 0c             	sub    $0xc,%esp
80102233:	50                   	push   %eax
80102234:	e8 d7 fe ff ff       	call   80102110 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102239:	83 c4 10             	add    $0x10,%esp
8010223c:	89 f0                	mov    %esi,%eax
8010223e:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80102244:	39 de                	cmp    %ebx,%esi
80102246:	76 e8                	jbe    80102230 <freerange+0x17>
}
80102248:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010224b:	5b                   	pop    %ebx
8010224c:	5e                   	pop    %esi
8010224d:	5d                   	pop    %ebp
8010224e:	c3                   	ret    

8010224f <kinit1>:
{
8010224f:	55                   	push   %ebp
80102250:	89 e5                	mov    %esp,%ebp
80102252:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80102255:	68 cc 69 10 80       	push   $0x801069cc
8010225a:	68 60 26 13 80       	push   $0x80132660
8010225f:	e8 93 1a 00 00       	call   80103cf7 <initlock>
  kmem.use_lock = 0;
80102264:	c7 05 94 26 13 80 00 	movl   $0x0,0x80132694
8010226b:	00 00 00 
  freerange(vstart, vend);
8010226e:	83 c4 08             	add    $0x8,%esp
80102271:	ff 75 0c             	pushl  0xc(%ebp)
80102274:	ff 75 08             	pushl  0x8(%ebp)
80102277:	e8 9d ff ff ff       	call   80102219 <freerange>
}
8010227c:	83 c4 10             	add    $0x10,%esp
8010227f:	c9                   	leave  
80102280:	c3                   	ret    

80102281 <kinit2>:
{
80102281:	55                   	push   %ebp
80102282:	89 e5                	mov    %esp,%ebp
80102284:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102287:	ff 75 0c             	pushl  0xc(%ebp)
8010228a:	ff 75 08             	pushl  0x8(%ebp)
8010228d:	e8 87 ff ff ff       	call   80102219 <freerange>
  kmem.use_lock = 1;
80102292:	c7 05 94 26 13 80 01 	movl   $0x1,0x80132694
80102299:	00 00 00 
  flag = 1;
8010229c:	c7 05 b4 a5 12 80 01 	movl   $0x1,0x8012a5b4
801022a3:	00 00 00 
}
801022a6:	83 c4 10             	add    $0x10,%esp
801022a9:	c9                   	leave  
801022aa:	c3                   	ret    

801022ab <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(int pid)
{
801022ab:	55                   	push   %ebp
801022ac:	89 e5                	mov    %esp,%ebp
801022ae:	53                   	push   %ebx
801022af:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801022b2:	83 3d 94 26 13 80 00 	cmpl   $0x0,0x80132694
801022b9:	75 2a                	jne    801022e5 <kalloc+0x3a>
    acquire(&kmem.lock);
  r = kmem.freelist;
801022bb:	8b 1d 98 26 13 80    	mov    0x80132698,%ebx

  if (flag == 0) {
801022c1:	83 3d b4 a5 12 80 00 	cmpl   $0x0,0x8012a5b4
801022c8:	75 2d                	jne    801022f7 <kalloc+0x4c>
    if (r) {
801022ca:	85 db                	test   %ebx,%ebx
801022cc:	74 07                	je     801022d5 <kalloc+0x2a>
      kmem.freelist = r->next;
801022ce:	8b 03                	mov    (%ebx),%eax
801022d0:	a3 98 26 13 80       	mov    %eax,0x80132698
    // insert the first valid free frame to frame[]
    r = insert(pid);
    // cprintf("kalloc : addr -> %d\n", (V2P((char*)r) >> 12));
  }
  
  if(kmem.use_lock)
801022d5:	83 3d 94 26 13 80 00 	cmpl   $0x0,0x80132694
801022dc:	75 2b                	jne    80102309 <kalloc+0x5e>
    release(&kmem.lock);
  return (char*)r;
}
801022de:	89 d8                	mov    %ebx,%eax
801022e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801022e3:	c9                   	leave  
801022e4:	c3                   	ret    
    acquire(&kmem.lock);
801022e5:	83 ec 0c             	sub    $0xc,%esp
801022e8:	68 60 26 13 80       	push   $0x80132660
801022ed:	e8 41 1b 00 00       	call   80103e33 <acquire>
801022f2:	83 c4 10             	add    $0x10,%esp
801022f5:	eb c4                	jmp    801022bb <kalloc+0x10>
    r = insert(pid);
801022f7:	83 ec 0c             	sub    $0xc,%esp
801022fa:	ff 75 08             	pushl  0x8(%ebp)
801022fd:	e8 ac fd ff ff       	call   801020ae <insert>
80102302:	89 c3                	mov    %eax,%ebx
80102304:	83 c4 10             	add    $0x10,%esp
80102307:	eb cc                	jmp    801022d5 <kalloc+0x2a>
    release(&kmem.lock);
80102309:	83 ec 0c             	sub    $0xc,%esp
8010230c:	68 60 26 13 80       	push   $0x80132660
80102311:	e8 82 1b 00 00       	call   80103e98 <release>
80102316:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102319:	eb c3                	jmp    801022de <kalloc+0x33>

8010231b <dump_physmem>:



int
dump_physmem(int *frames, int *pids, int numframes)
{
8010231b:	55                   	push   %ebp
8010231c:	89 e5                	mov    %esp,%ebp
8010231e:	57                   	push   %edi
8010231f:	56                   	push   %esi
80102320:	53                   	push   %ebx
80102321:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102324:	8b 75 0c             	mov    0xc(%ebp),%esi
80102327:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if (frames == NULL || pids == NULL || numframes < 0) {
8010232a:	85 db                	test   %ebx,%ebx
8010232c:	0f 94 c2             	sete   %dl
8010232f:	85 f6                	test   %esi,%esi
80102331:	0f 94 c0             	sete   %al
80102334:	08 c2                	or     %al,%dl
80102336:	75 52                	jne    8010238a <dump_physmem+0x6f>
80102338:	85 c9                	test   %ecx,%ecx
8010233a:	78 55                	js     80102391 <dump_physmem+0x76>
      return -1;
  }
  for (int i = 0; i < numframes; i++) { // size?
8010233c:	b8 00 00 00 00       	mov    $0x0,%eax
80102341:	eb 18                	jmp    8010235b <dump_physmem+0x40>
    if (frame[i] != 0){
      frames[i] = frame[i];
      pids[i] = mem_pid[i];
    } else {
      frames[i] = -1;
80102343:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010234a:	c7 04 13 ff ff ff ff 	movl   $0xffffffff,(%ebx,%edx,1)
      pids[i] = -1;
80102351:	c7 04 16 ff ff ff ff 	movl   $0xffffffff,(%esi,%edx,1)
  for (int i = 0; i < numframes; i++) { // size?
80102358:	83 c0 01             	add    $0x1,%eax
8010235b:	39 c8                	cmp    %ecx,%eax
8010235d:	7d 21                	jge    80102380 <dump_physmem+0x65>
    if (frame[i] != 0){
8010235f:	8b 14 85 00 80 11 80 	mov    -0x7fee8000(,%eax,4),%edx
80102366:	85 d2                	test   %edx,%edx
80102368:	74 d9                	je     80102343 <dump_physmem+0x28>
      frames[i] = frame[i];
8010236a:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
80102371:	89 14 3b             	mov    %edx,(%ebx,%edi,1)
      pids[i] = mem_pid[i];
80102374:	8b 14 85 00 80 10 80 	mov    -0x7fef8000(,%eax,4),%edx
8010237b:	89 14 3e             	mov    %edx,(%esi,%edi,1)
8010237e:	eb d8                	jmp    80102358 <dump_physmem+0x3d>
    }
  }
  return 0;
80102380:	b8 00 00 00 00       	mov    $0x0,%eax
80102385:	5b                   	pop    %ebx
80102386:	5e                   	pop    %esi
80102387:	5f                   	pop    %edi
80102388:	5d                   	pop    %ebp
80102389:	c3                   	ret    
      return -1;
8010238a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010238f:	eb f4                	jmp    80102385 <dump_physmem+0x6a>
80102391:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102396:	eb ed                	jmp    80102385 <dump_physmem+0x6a>

80102398 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102398:	55                   	push   %ebp
80102399:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010239b:	ba 64 00 00 00       	mov    $0x64,%edx
801023a0:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801023a1:	a8 01                	test   $0x1,%al
801023a3:	0f 84 b5 00 00 00    	je     8010245e <kbdgetc+0xc6>
801023a9:	ba 60 00 00 00       	mov    $0x60,%edx
801023ae:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801023af:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801023b2:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801023b8:	74 5c                	je     80102416 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801023ba:	84 c0                	test   %al,%al
801023bc:	78 66                	js     80102424 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801023be:	8b 0d bc a5 12 80    	mov    0x8012a5bc,%ecx
801023c4:	f6 c1 40             	test   $0x40,%cl
801023c7:	74 0f                	je     801023d8 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801023c9:	83 c8 80             	or     $0xffffff80,%eax
801023cc:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801023cf:	83 e1 bf             	and    $0xffffffbf,%ecx
801023d2:	89 0d bc a5 12 80    	mov    %ecx,0x8012a5bc
  }

  shift |= shiftcode[data];
801023d8:	0f b6 8a 00 6b 10 80 	movzbl -0x7fef9500(%edx),%ecx
801023df:	0b 0d bc a5 12 80    	or     0x8012a5bc,%ecx
  shift ^= togglecode[data];
801023e5:	0f b6 82 00 6a 10 80 	movzbl -0x7fef9600(%edx),%eax
801023ec:	31 c1                	xor    %eax,%ecx
801023ee:	89 0d bc a5 12 80    	mov    %ecx,0x8012a5bc
  c = charcode[shift & (CTL | SHIFT)][data];
801023f4:	89 c8                	mov    %ecx,%eax
801023f6:	83 e0 03             	and    $0x3,%eax
801023f9:	8b 04 85 e0 69 10 80 	mov    -0x7fef9620(,%eax,4),%eax
80102400:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102404:	f6 c1 08             	test   $0x8,%cl
80102407:	74 19                	je     80102422 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102409:	8d 50 9f             	lea    -0x61(%eax),%edx
8010240c:	83 fa 19             	cmp    $0x19,%edx
8010240f:	77 40                	ja     80102451 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102411:	83 e8 20             	sub    $0x20,%eax
80102414:	eb 0c                	jmp    80102422 <kbdgetc+0x8a>
    shift |= E0ESC;
80102416:	83 0d bc a5 12 80 40 	orl    $0x40,0x8012a5bc
    return 0;
8010241d:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102422:	5d                   	pop    %ebp
80102423:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102424:	8b 0d bc a5 12 80    	mov    0x8012a5bc,%ecx
8010242a:	f6 c1 40             	test   $0x40,%cl
8010242d:	75 05                	jne    80102434 <kbdgetc+0x9c>
8010242f:	89 c2                	mov    %eax,%edx
80102431:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102434:	0f b6 82 00 6b 10 80 	movzbl -0x7fef9500(%edx),%eax
8010243b:	83 c8 40             	or     $0x40,%eax
8010243e:	0f b6 c0             	movzbl %al,%eax
80102441:	f7 d0                	not    %eax
80102443:	21 c8                	and    %ecx,%eax
80102445:	a3 bc a5 12 80       	mov    %eax,0x8012a5bc
    return 0;
8010244a:	b8 00 00 00 00       	mov    $0x0,%eax
8010244f:	eb d1                	jmp    80102422 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
80102451:	8d 50 bf             	lea    -0x41(%eax),%edx
80102454:	83 fa 19             	cmp    $0x19,%edx
80102457:	77 c9                	ja     80102422 <kbdgetc+0x8a>
      c += 'a' - 'A';
80102459:	83 c0 20             	add    $0x20,%eax
  return c;
8010245c:	eb c4                	jmp    80102422 <kbdgetc+0x8a>
    return -1;
8010245e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102463:	eb bd                	jmp    80102422 <kbdgetc+0x8a>

80102465 <kbdintr>:

void
kbdintr(void)
{
80102465:	55                   	push   %ebp
80102466:	89 e5                	mov    %esp,%ebp
80102468:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010246b:	68 98 23 10 80       	push   $0x80102398
80102470:	e8 c9 e2 ff ff       	call   8010073e <consoleintr>
}
80102475:	83 c4 10             	add    $0x10,%esp
80102478:	c9                   	leave  
80102479:	c3                   	ret    

8010247a <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010247a:	55                   	push   %ebp
8010247b:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010247d:	8b 0d 9c 26 13 80    	mov    0x8013269c,%ecx
80102483:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102486:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102488:	a1 9c 26 13 80       	mov    0x8013269c,%eax
8010248d:	8b 40 20             	mov    0x20(%eax),%eax
}
80102490:	5d                   	pop    %ebp
80102491:	c3                   	ret    

80102492 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80102492:	55                   	push   %ebp
80102493:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102495:	ba 70 00 00 00       	mov    $0x70,%edx
8010249a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010249b:	ba 71 00 00 00       	mov    $0x71,%edx
801024a0:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801024a1:	0f b6 c0             	movzbl %al,%eax
}
801024a4:	5d                   	pop    %ebp
801024a5:	c3                   	ret    

801024a6 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801024a6:	55                   	push   %ebp
801024a7:	89 e5                	mov    %esp,%ebp
801024a9:	53                   	push   %ebx
801024aa:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801024ac:	b8 00 00 00 00       	mov    $0x0,%eax
801024b1:	e8 dc ff ff ff       	call   80102492 <cmos_read>
801024b6:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801024b8:	b8 02 00 00 00       	mov    $0x2,%eax
801024bd:	e8 d0 ff ff ff       	call   80102492 <cmos_read>
801024c2:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801024c5:	b8 04 00 00 00       	mov    $0x4,%eax
801024ca:	e8 c3 ff ff ff       	call   80102492 <cmos_read>
801024cf:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801024d2:	b8 07 00 00 00       	mov    $0x7,%eax
801024d7:	e8 b6 ff ff ff       	call   80102492 <cmos_read>
801024dc:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801024df:	b8 08 00 00 00       	mov    $0x8,%eax
801024e4:	e8 a9 ff ff ff       	call   80102492 <cmos_read>
801024e9:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801024ec:	b8 09 00 00 00       	mov    $0x9,%eax
801024f1:	e8 9c ff ff ff       	call   80102492 <cmos_read>
801024f6:	89 43 14             	mov    %eax,0x14(%ebx)
}
801024f9:	5b                   	pop    %ebx
801024fa:	5d                   	pop    %ebp
801024fb:	c3                   	ret    

801024fc <lapicinit>:
  if(!lapic)
801024fc:	83 3d 9c 26 13 80 00 	cmpl   $0x0,0x8013269c
80102503:	0f 84 fb 00 00 00    	je     80102604 <lapicinit+0x108>
{
80102509:	55                   	push   %ebp
8010250a:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010250c:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102511:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102516:	e8 5f ff ff ff       	call   8010247a <lapicw>
  lapicw(TDCR, X1);
8010251b:	ba 0b 00 00 00       	mov    $0xb,%edx
80102520:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102525:	e8 50 ff ff ff       	call   8010247a <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010252a:	ba 20 00 02 00       	mov    $0x20020,%edx
8010252f:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102534:	e8 41 ff ff ff       	call   8010247a <lapicw>
  lapicw(TICR, 10000000);
80102539:	ba 80 96 98 00       	mov    $0x989680,%edx
8010253e:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102543:	e8 32 ff ff ff       	call   8010247a <lapicw>
  lapicw(LINT0, MASKED);
80102548:	ba 00 00 01 00       	mov    $0x10000,%edx
8010254d:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102552:	e8 23 ff ff ff       	call   8010247a <lapicw>
  lapicw(LINT1, MASKED);
80102557:	ba 00 00 01 00       	mov    $0x10000,%edx
8010255c:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102561:	e8 14 ff ff ff       	call   8010247a <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102566:	a1 9c 26 13 80       	mov    0x8013269c,%eax
8010256b:	8b 40 30             	mov    0x30(%eax),%eax
8010256e:	c1 e8 10             	shr    $0x10,%eax
80102571:	3c 03                	cmp    $0x3,%al
80102573:	77 7b                	ja     801025f0 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102575:	ba 33 00 00 00       	mov    $0x33,%edx
8010257a:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010257f:	e8 f6 fe ff ff       	call   8010247a <lapicw>
  lapicw(ESR, 0);
80102584:	ba 00 00 00 00       	mov    $0x0,%edx
80102589:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010258e:	e8 e7 fe ff ff       	call   8010247a <lapicw>
  lapicw(ESR, 0);
80102593:	ba 00 00 00 00       	mov    $0x0,%edx
80102598:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010259d:	e8 d8 fe ff ff       	call   8010247a <lapicw>
  lapicw(EOI, 0);
801025a2:	ba 00 00 00 00       	mov    $0x0,%edx
801025a7:	b8 2c 00 00 00       	mov    $0x2c,%eax
801025ac:	e8 c9 fe ff ff       	call   8010247a <lapicw>
  lapicw(ICRHI, 0);
801025b1:	ba 00 00 00 00       	mov    $0x0,%edx
801025b6:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025bb:	e8 ba fe ff ff       	call   8010247a <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801025c0:	ba 00 85 08 00       	mov    $0x88500,%edx
801025c5:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025ca:	e8 ab fe ff ff       	call   8010247a <lapicw>
  while(lapic[ICRLO] & DELIVS)
801025cf:	a1 9c 26 13 80       	mov    0x8013269c,%eax
801025d4:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801025da:	f6 c4 10             	test   $0x10,%ah
801025dd:	75 f0                	jne    801025cf <lapicinit+0xd3>
  lapicw(TPR, 0);
801025df:	ba 00 00 00 00       	mov    $0x0,%edx
801025e4:	b8 20 00 00 00       	mov    $0x20,%eax
801025e9:	e8 8c fe ff ff       	call   8010247a <lapicw>
}
801025ee:	5d                   	pop    %ebp
801025ef:	c3                   	ret    
    lapicw(PCINT, MASKED);
801025f0:	ba 00 00 01 00       	mov    $0x10000,%edx
801025f5:	b8 d0 00 00 00       	mov    $0xd0,%eax
801025fa:	e8 7b fe ff ff       	call   8010247a <lapicw>
801025ff:	e9 71 ff ff ff       	jmp    80102575 <lapicinit+0x79>
80102604:	f3 c3                	repz ret 

80102606 <lapicid>:
{
80102606:	55                   	push   %ebp
80102607:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102609:	a1 9c 26 13 80       	mov    0x8013269c,%eax
8010260e:	85 c0                	test   %eax,%eax
80102610:	74 08                	je     8010261a <lapicid+0x14>
  return lapic[ID] >> 24;
80102612:	8b 40 20             	mov    0x20(%eax),%eax
80102615:	c1 e8 18             	shr    $0x18,%eax
}
80102618:	5d                   	pop    %ebp
80102619:	c3                   	ret    
    return 0;
8010261a:	b8 00 00 00 00       	mov    $0x0,%eax
8010261f:	eb f7                	jmp    80102618 <lapicid+0x12>

80102621 <lapiceoi>:
  if(lapic)
80102621:	83 3d 9c 26 13 80 00 	cmpl   $0x0,0x8013269c
80102628:	74 14                	je     8010263e <lapiceoi+0x1d>
{
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
8010262d:	ba 00 00 00 00       	mov    $0x0,%edx
80102632:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102637:	e8 3e fe ff ff       	call   8010247a <lapicw>
}
8010263c:	5d                   	pop    %ebp
8010263d:	c3                   	ret    
8010263e:	f3 c3                	repz ret 

80102640 <microdelay>:
{
80102640:	55                   	push   %ebp
80102641:	89 e5                	mov    %esp,%ebp
}
80102643:	5d                   	pop    %ebp
80102644:	c3                   	ret    

80102645 <lapicstartap>:
{
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
80102648:	57                   	push   %edi
80102649:	56                   	push   %esi
8010264a:	53                   	push   %ebx
8010264b:	8b 75 08             	mov    0x8(%ebp),%esi
8010264e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102651:	b8 0f 00 00 00       	mov    $0xf,%eax
80102656:	ba 70 00 00 00       	mov    $0x70,%edx
8010265b:	ee                   	out    %al,(%dx)
8010265c:	b8 0a 00 00 00       	mov    $0xa,%eax
80102661:	ba 71 00 00 00       	mov    $0x71,%edx
80102666:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102667:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010266e:	00 00 
  wrv[1] = addr >> 4;
80102670:	89 f8                	mov    %edi,%eax
80102672:	c1 e8 04             	shr    $0x4,%eax
80102675:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
8010267b:	c1 e6 18             	shl    $0x18,%esi
8010267e:	89 f2                	mov    %esi,%edx
80102680:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102685:	e8 f0 fd ff ff       	call   8010247a <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010268a:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010268f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102694:	e8 e1 fd ff ff       	call   8010247a <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102699:	ba 00 85 00 00       	mov    $0x8500,%edx
8010269e:	b8 c0 00 00 00       	mov    $0xc0,%eax
801026a3:	e8 d2 fd ff ff       	call   8010247a <lapicw>
  for(i = 0; i < 2; i++){
801026a8:	bb 00 00 00 00       	mov    $0x0,%ebx
801026ad:	eb 21                	jmp    801026d0 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801026af:	89 f2                	mov    %esi,%edx
801026b1:	b8 c4 00 00 00       	mov    $0xc4,%eax
801026b6:	e8 bf fd ff ff       	call   8010247a <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801026bb:	89 fa                	mov    %edi,%edx
801026bd:	c1 ea 0c             	shr    $0xc,%edx
801026c0:	80 ce 06             	or     $0x6,%dh
801026c3:	b8 c0 00 00 00       	mov    $0xc0,%eax
801026c8:	e8 ad fd ff ff       	call   8010247a <lapicw>
  for(i = 0; i < 2; i++){
801026cd:	83 c3 01             	add    $0x1,%ebx
801026d0:	83 fb 01             	cmp    $0x1,%ebx
801026d3:	7e da                	jle    801026af <lapicstartap+0x6a>
}
801026d5:	5b                   	pop    %ebx
801026d6:	5e                   	pop    %esi
801026d7:	5f                   	pop    %edi
801026d8:	5d                   	pop    %ebp
801026d9:	c3                   	ret    

801026da <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801026da:	55                   	push   %ebp
801026db:	89 e5                	mov    %esp,%ebp
801026dd:	57                   	push   %edi
801026de:	56                   	push   %esi
801026df:	53                   	push   %ebx
801026e0:	83 ec 3c             	sub    $0x3c,%esp
801026e3:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801026e6:	b8 0b 00 00 00       	mov    $0xb,%eax
801026eb:	e8 a2 fd ff ff       	call   80102492 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801026f0:	83 e0 04             	and    $0x4,%eax
801026f3:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801026f5:	8d 45 d0             	lea    -0x30(%ebp),%eax
801026f8:	e8 a9 fd ff ff       	call   801024a6 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801026fd:	b8 0a 00 00 00       	mov    $0xa,%eax
80102702:	e8 8b fd ff ff       	call   80102492 <cmos_read>
80102707:	a8 80                	test   $0x80,%al
80102709:	75 ea                	jne    801026f5 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
8010270b:	8d 5d b8             	lea    -0x48(%ebp),%ebx
8010270e:	89 d8                	mov    %ebx,%eax
80102710:	e8 91 fd ff ff       	call   801024a6 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102715:	83 ec 04             	sub    $0x4,%esp
80102718:	6a 18                	push   $0x18
8010271a:	53                   	push   %ebx
8010271b:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010271e:	50                   	push   %eax
8010271f:	e8 01 18 00 00       	call   80103f25 <memcmp>
80102724:	83 c4 10             	add    $0x10,%esp
80102727:	85 c0                	test   %eax,%eax
80102729:	75 ca                	jne    801026f5 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
8010272b:	85 ff                	test   %edi,%edi
8010272d:	0f 85 84 00 00 00    	jne    801027b7 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102733:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102736:	89 d0                	mov    %edx,%eax
80102738:	c1 e8 04             	shr    $0x4,%eax
8010273b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010273e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102741:	83 e2 0f             	and    $0xf,%edx
80102744:	01 d0                	add    %edx,%eax
80102746:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102749:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010274c:	89 d0                	mov    %edx,%eax
8010274e:	c1 e8 04             	shr    $0x4,%eax
80102751:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102754:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102757:	83 e2 0f             	and    $0xf,%edx
8010275a:	01 d0                	add    %edx,%eax
8010275c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010275f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102762:	89 d0                	mov    %edx,%eax
80102764:	c1 e8 04             	shr    $0x4,%eax
80102767:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010276a:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010276d:	83 e2 0f             	and    $0xf,%edx
80102770:	01 d0                	add    %edx,%eax
80102772:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102775:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102778:	89 d0                	mov    %edx,%eax
8010277a:	c1 e8 04             	shr    $0x4,%eax
8010277d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102780:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102783:	83 e2 0f             	and    $0xf,%edx
80102786:	01 d0                	add    %edx,%eax
80102788:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010278b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010278e:	89 d0                	mov    %edx,%eax
80102790:	c1 e8 04             	shr    $0x4,%eax
80102793:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102796:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102799:	83 e2 0f             	and    $0xf,%edx
8010279c:	01 d0                	add    %edx,%eax
8010279e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801027a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801027a4:	89 d0                	mov    %edx,%eax
801027a6:	c1 e8 04             	shr    $0x4,%eax
801027a9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ac:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801027af:	83 e2 0f             	and    $0xf,%edx
801027b2:	01 d0                	add    %edx,%eax
801027b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801027b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801027ba:	89 06                	mov    %eax,(%esi)
801027bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801027bf:	89 46 04             	mov    %eax,0x4(%esi)
801027c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801027c5:	89 46 08             	mov    %eax,0x8(%esi)
801027c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801027cb:	89 46 0c             	mov    %eax,0xc(%esi)
801027ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801027d1:	89 46 10             	mov    %eax,0x10(%esi)
801027d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801027d7:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801027da:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801027e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027e4:	5b                   	pop    %ebx
801027e5:	5e                   	pop    %esi
801027e6:	5f                   	pop    %edi
801027e7:	5d                   	pop    %ebp
801027e8:	c3                   	ret    

801027e9 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801027e9:	55                   	push   %ebp
801027ea:	89 e5                	mov    %esp,%ebp
801027ec:	53                   	push   %ebx
801027ed:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801027f0:	ff 35 d4 26 13 80    	pushl  0x801326d4
801027f6:	ff 35 e4 26 13 80    	pushl  0x801326e4
801027fc:	e8 6b d9 ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102801:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102804:	89 1d e8 26 13 80    	mov    %ebx,0x801326e8
  for (i = 0; i < log.lh.n; i++) {
8010280a:	83 c4 10             	add    $0x10,%esp
8010280d:	ba 00 00 00 00       	mov    $0x0,%edx
80102812:	eb 0e                	jmp    80102822 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102814:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102818:	89 0c 95 ec 26 13 80 	mov    %ecx,-0x7fecd914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010281f:	83 c2 01             	add    $0x1,%edx
80102822:	39 d3                	cmp    %edx,%ebx
80102824:	7f ee                	jg     80102814 <read_head+0x2b>
  }
  brelse(buf);
80102826:	83 ec 0c             	sub    $0xc,%esp
80102829:	50                   	push   %eax
8010282a:	e8 a6 d9 ff ff       	call   801001d5 <brelse>
}
8010282f:	83 c4 10             	add    $0x10,%esp
80102832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102835:	c9                   	leave  
80102836:	c3                   	ret    

80102837 <install_trans>:
{
80102837:	55                   	push   %ebp
80102838:	89 e5                	mov    %esp,%ebp
8010283a:	57                   	push   %edi
8010283b:	56                   	push   %esi
8010283c:	53                   	push   %ebx
8010283d:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102840:	bb 00 00 00 00       	mov    $0x0,%ebx
80102845:	eb 66                	jmp    801028ad <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102847:	89 d8                	mov    %ebx,%eax
80102849:	03 05 d4 26 13 80    	add    0x801326d4,%eax
8010284f:	83 c0 01             	add    $0x1,%eax
80102852:	83 ec 08             	sub    $0x8,%esp
80102855:	50                   	push   %eax
80102856:	ff 35 e4 26 13 80    	pushl  0x801326e4
8010285c:	e8 0b d9 ff ff       	call   8010016c <bread>
80102861:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102863:	83 c4 08             	add    $0x8,%esp
80102866:	ff 34 9d ec 26 13 80 	pushl  -0x7fecd914(,%ebx,4)
8010286d:	ff 35 e4 26 13 80    	pushl  0x801326e4
80102873:	e8 f4 d8 ff ff       	call   8010016c <bread>
80102878:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010287a:	8d 57 5c             	lea    0x5c(%edi),%edx
8010287d:	8d 40 5c             	lea    0x5c(%eax),%eax
80102880:	83 c4 0c             	add    $0xc,%esp
80102883:	68 00 02 00 00       	push   $0x200
80102888:	52                   	push   %edx
80102889:	50                   	push   %eax
8010288a:	e8 cb 16 00 00       	call   80103f5a <memmove>
    bwrite(dbuf);  // write dst to disk
8010288f:	89 34 24             	mov    %esi,(%esp)
80102892:	e8 03 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102897:	89 3c 24             	mov    %edi,(%esp)
8010289a:	e8 36 d9 ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
8010289f:	89 34 24             	mov    %esi,(%esp)
801028a2:	e8 2e d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801028a7:	83 c3 01             	add    $0x1,%ebx
801028aa:	83 c4 10             	add    $0x10,%esp
801028ad:	39 1d e8 26 13 80    	cmp    %ebx,0x801326e8
801028b3:	7f 92                	jg     80102847 <install_trans+0x10>
}
801028b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801028b8:	5b                   	pop    %ebx
801028b9:	5e                   	pop    %esi
801028ba:	5f                   	pop    %edi
801028bb:	5d                   	pop    %ebp
801028bc:	c3                   	ret    

801028bd <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801028bd:	55                   	push   %ebp
801028be:	89 e5                	mov    %esp,%ebp
801028c0:	53                   	push   %ebx
801028c1:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801028c4:	ff 35 d4 26 13 80    	pushl  0x801326d4
801028ca:	ff 35 e4 26 13 80    	pushl  0x801326e4
801028d0:	e8 97 d8 ff ff       	call   8010016c <bread>
801028d5:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801028d7:	8b 0d e8 26 13 80    	mov    0x801326e8,%ecx
801028dd:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801028e0:	83 c4 10             	add    $0x10,%esp
801028e3:	b8 00 00 00 00       	mov    $0x0,%eax
801028e8:	eb 0e                	jmp    801028f8 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801028ea:	8b 14 85 ec 26 13 80 	mov    -0x7fecd914(,%eax,4),%edx
801028f1:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801028f5:	83 c0 01             	add    $0x1,%eax
801028f8:	39 c1                	cmp    %eax,%ecx
801028fa:	7f ee                	jg     801028ea <write_head+0x2d>
  }
  bwrite(buf);
801028fc:	83 ec 0c             	sub    $0xc,%esp
801028ff:	53                   	push   %ebx
80102900:	e8 95 d8 ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102905:	89 1c 24             	mov    %ebx,(%esp)
80102908:	e8 c8 d8 ff ff       	call   801001d5 <brelse>
}
8010290d:	83 c4 10             	add    $0x10,%esp
80102910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102913:	c9                   	leave  
80102914:	c3                   	ret    

80102915 <recover_from_log>:

static void
recover_from_log(void)
{
80102915:	55                   	push   %ebp
80102916:	89 e5                	mov    %esp,%ebp
80102918:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010291b:	e8 c9 fe ff ff       	call   801027e9 <read_head>
  install_trans(); // if committed, copy from log to disk
80102920:	e8 12 ff ff ff       	call   80102837 <install_trans>
  log.lh.n = 0;
80102925:	c7 05 e8 26 13 80 00 	movl   $0x0,0x801326e8
8010292c:	00 00 00 
  write_head(); // clear the log
8010292f:	e8 89 ff ff ff       	call   801028bd <write_head>
}
80102934:	c9                   	leave  
80102935:	c3                   	ret    

80102936 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102936:	55                   	push   %ebp
80102937:	89 e5                	mov    %esp,%ebp
80102939:	57                   	push   %edi
8010293a:	56                   	push   %esi
8010293b:	53                   	push   %ebx
8010293c:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010293f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102944:	eb 66                	jmp    801029ac <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102946:	89 d8                	mov    %ebx,%eax
80102948:	03 05 d4 26 13 80    	add    0x801326d4,%eax
8010294e:	83 c0 01             	add    $0x1,%eax
80102951:	83 ec 08             	sub    $0x8,%esp
80102954:	50                   	push   %eax
80102955:	ff 35 e4 26 13 80    	pushl  0x801326e4
8010295b:	e8 0c d8 ff ff       	call   8010016c <bread>
80102960:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102962:	83 c4 08             	add    $0x8,%esp
80102965:	ff 34 9d ec 26 13 80 	pushl  -0x7fecd914(,%ebx,4)
8010296c:	ff 35 e4 26 13 80    	pushl  0x801326e4
80102972:	e8 f5 d7 ff ff       	call   8010016c <bread>
80102977:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102979:	8d 50 5c             	lea    0x5c(%eax),%edx
8010297c:	8d 46 5c             	lea    0x5c(%esi),%eax
8010297f:	83 c4 0c             	add    $0xc,%esp
80102982:	68 00 02 00 00       	push   $0x200
80102987:	52                   	push   %edx
80102988:	50                   	push   %eax
80102989:	e8 cc 15 00 00       	call   80103f5a <memmove>
    bwrite(to);  // write the log
8010298e:	89 34 24             	mov    %esi,(%esp)
80102991:	e8 04 d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
80102996:	89 3c 24             	mov    %edi,(%esp)
80102999:	e8 37 d8 ff ff       	call   801001d5 <brelse>
    brelse(to);
8010299e:	89 34 24             	mov    %esi,(%esp)
801029a1:	e8 2f d8 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801029a6:	83 c3 01             	add    $0x1,%ebx
801029a9:	83 c4 10             	add    $0x10,%esp
801029ac:	39 1d e8 26 13 80    	cmp    %ebx,0x801326e8
801029b2:	7f 92                	jg     80102946 <write_log+0x10>
  }
}
801029b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801029b7:	5b                   	pop    %ebx
801029b8:	5e                   	pop    %esi
801029b9:	5f                   	pop    %edi
801029ba:	5d                   	pop    %ebp
801029bb:	c3                   	ret    

801029bc <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801029bc:	83 3d e8 26 13 80 00 	cmpl   $0x0,0x801326e8
801029c3:	7e 26                	jle    801029eb <commit+0x2f>
{
801029c5:	55                   	push   %ebp
801029c6:	89 e5                	mov    %esp,%ebp
801029c8:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801029cb:	e8 66 ff ff ff       	call   80102936 <write_log>
    write_head();    // Write header to disk -- the real commit
801029d0:	e8 e8 fe ff ff       	call   801028bd <write_head>
    install_trans(); // Now install writes to home locations
801029d5:	e8 5d fe ff ff       	call   80102837 <install_trans>
    log.lh.n = 0;
801029da:	c7 05 e8 26 13 80 00 	movl   $0x0,0x801326e8
801029e1:	00 00 00 
    write_head();    // Erase the transaction from the log
801029e4:	e8 d4 fe ff ff       	call   801028bd <write_head>
  }
}
801029e9:	c9                   	leave  
801029ea:	c3                   	ret    
801029eb:	f3 c3                	repz ret 

801029ed <initlog>:
{
801029ed:	55                   	push   %ebp
801029ee:	89 e5                	mov    %esp,%ebp
801029f0:	53                   	push   %ebx
801029f1:	83 ec 2c             	sub    $0x2c,%esp
801029f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801029f7:	68 00 6c 10 80       	push   $0x80106c00
801029fc:	68 a0 26 13 80       	push   $0x801326a0
80102a01:	e8 f1 12 00 00       	call   80103cf7 <initlock>
  readsb(dev, &sb);
80102a06:	83 c4 08             	add    $0x8,%esp
80102a09:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102a0c:	50                   	push   %eax
80102a0d:	53                   	push   %ebx
80102a0e:	e8 2f e8 ff ff       	call   80101242 <readsb>
  log.start = sb.logstart;
80102a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a16:	a3 d4 26 13 80       	mov    %eax,0x801326d4
  log.size = sb.nlog;
80102a1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a1e:	a3 d8 26 13 80       	mov    %eax,0x801326d8
  log.dev = dev;
80102a23:	89 1d e4 26 13 80    	mov    %ebx,0x801326e4
  recover_from_log();
80102a29:	e8 e7 fe ff ff       	call   80102915 <recover_from_log>
}
80102a2e:	83 c4 10             	add    $0x10,%esp
80102a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a34:	c9                   	leave  
80102a35:	c3                   	ret    

80102a36 <begin_op>:
{
80102a36:	55                   	push   %ebp
80102a37:	89 e5                	mov    %esp,%ebp
80102a39:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102a3c:	68 a0 26 13 80       	push   $0x801326a0
80102a41:	e8 ed 13 00 00       	call   80103e33 <acquire>
80102a46:	83 c4 10             	add    $0x10,%esp
80102a49:	eb 15                	jmp    80102a60 <begin_op+0x2a>
      sleep(&log, &log.lock);
80102a4b:	83 ec 08             	sub    $0x8,%esp
80102a4e:	68 a0 26 13 80       	push   $0x801326a0
80102a53:	68 a0 26 13 80       	push   $0x801326a0
80102a58:	e8 db 0e 00 00       	call   80103938 <sleep>
80102a5d:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102a60:	83 3d e0 26 13 80 00 	cmpl   $0x0,0x801326e0
80102a67:	75 e2                	jne    80102a4b <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102a69:	a1 dc 26 13 80       	mov    0x801326dc,%eax
80102a6e:	83 c0 01             	add    $0x1,%eax
80102a71:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102a74:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102a77:	03 15 e8 26 13 80    	add    0x801326e8,%edx
80102a7d:	83 fa 1e             	cmp    $0x1e,%edx
80102a80:	7e 17                	jle    80102a99 <begin_op+0x63>
      sleep(&log, &log.lock);
80102a82:	83 ec 08             	sub    $0x8,%esp
80102a85:	68 a0 26 13 80       	push   $0x801326a0
80102a8a:	68 a0 26 13 80       	push   $0x801326a0
80102a8f:	e8 a4 0e 00 00       	call   80103938 <sleep>
80102a94:	83 c4 10             	add    $0x10,%esp
80102a97:	eb c7                	jmp    80102a60 <begin_op+0x2a>
      log.outstanding += 1;
80102a99:	a3 dc 26 13 80       	mov    %eax,0x801326dc
      release(&log.lock);
80102a9e:	83 ec 0c             	sub    $0xc,%esp
80102aa1:	68 a0 26 13 80       	push   $0x801326a0
80102aa6:	e8 ed 13 00 00       	call   80103e98 <release>
}
80102aab:	83 c4 10             	add    $0x10,%esp
80102aae:	c9                   	leave  
80102aaf:	c3                   	ret    

80102ab0 <end_op>:
{
80102ab0:	55                   	push   %ebp
80102ab1:	89 e5                	mov    %esp,%ebp
80102ab3:	53                   	push   %ebx
80102ab4:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102ab7:	68 a0 26 13 80       	push   $0x801326a0
80102abc:	e8 72 13 00 00       	call   80103e33 <acquire>
  log.outstanding -= 1;
80102ac1:	a1 dc 26 13 80       	mov    0x801326dc,%eax
80102ac6:	83 e8 01             	sub    $0x1,%eax
80102ac9:	a3 dc 26 13 80       	mov    %eax,0x801326dc
  if(log.committing)
80102ace:	8b 1d e0 26 13 80    	mov    0x801326e0,%ebx
80102ad4:	83 c4 10             	add    $0x10,%esp
80102ad7:	85 db                	test   %ebx,%ebx
80102ad9:	75 2c                	jne    80102b07 <end_op+0x57>
  if(log.outstanding == 0){
80102adb:	85 c0                	test   %eax,%eax
80102add:	75 35                	jne    80102b14 <end_op+0x64>
    log.committing = 1;
80102adf:	c7 05 e0 26 13 80 01 	movl   $0x1,0x801326e0
80102ae6:	00 00 00 
    do_commit = 1;
80102ae9:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102aee:	83 ec 0c             	sub    $0xc,%esp
80102af1:	68 a0 26 13 80       	push   $0x801326a0
80102af6:	e8 9d 13 00 00       	call   80103e98 <release>
  if(do_commit){
80102afb:	83 c4 10             	add    $0x10,%esp
80102afe:	85 db                	test   %ebx,%ebx
80102b00:	75 24                	jne    80102b26 <end_op+0x76>
}
80102b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b05:	c9                   	leave  
80102b06:	c3                   	ret    
    panic("log.committing");
80102b07:	83 ec 0c             	sub    $0xc,%esp
80102b0a:	68 04 6c 10 80       	push   $0x80106c04
80102b0f:	e8 34 d8 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102b14:	83 ec 0c             	sub    $0xc,%esp
80102b17:	68 a0 26 13 80       	push   $0x801326a0
80102b1c:	e8 7c 0f 00 00       	call   80103a9d <wakeup>
80102b21:	83 c4 10             	add    $0x10,%esp
80102b24:	eb c8                	jmp    80102aee <end_op+0x3e>
    commit();
80102b26:	e8 91 fe ff ff       	call   801029bc <commit>
    acquire(&log.lock);
80102b2b:	83 ec 0c             	sub    $0xc,%esp
80102b2e:	68 a0 26 13 80       	push   $0x801326a0
80102b33:	e8 fb 12 00 00       	call   80103e33 <acquire>
    log.committing = 0;
80102b38:	c7 05 e0 26 13 80 00 	movl   $0x0,0x801326e0
80102b3f:	00 00 00 
    wakeup(&log);
80102b42:	c7 04 24 a0 26 13 80 	movl   $0x801326a0,(%esp)
80102b49:	e8 4f 0f 00 00       	call   80103a9d <wakeup>
    release(&log.lock);
80102b4e:	c7 04 24 a0 26 13 80 	movl   $0x801326a0,(%esp)
80102b55:	e8 3e 13 00 00       	call   80103e98 <release>
80102b5a:	83 c4 10             	add    $0x10,%esp
}
80102b5d:	eb a3                	jmp    80102b02 <end_op+0x52>

80102b5f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102b5f:	55                   	push   %ebp
80102b60:	89 e5                	mov    %esp,%ebp
80102b62:	53                   	push   %ebx
80102b63:	83 ec 04             	sub    $0x4,%esp
80102b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102b69:	8b 15 e8 26 13 80    	mov    0x801326e8,%edx
80102b6f:	83 fa 1d             	cmp    $0x1d,%edx
80102b72:	7f 45                	jg     80102bb9 <log_write+0x5a>
80102b74:	a1 d8 26 13 80       	mov    0x801326d8,%eax
80102b79:	83 e8 01             	sub    $0x1,%eax
80102b7c:	39 c2                	cmp    %eax,%edx
80102b7e:	7d 39                	jge    80102bb9 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102b80:	83 3d dc 26 13 80 00 	cmpl   $0x0,0x801326dc
80102b87:	7e 3d                	jle    80102bc6 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102b89:	83 ec 0c             	sub    $0xc,%esp
80102b8c:	68 a0 26 13 80       	push   $0x801326a0
80102b91:	e8 9d 12 00 00       	call   80103e33 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102b96:	83 c4 10             	add    $0x10,%esp
80102b99:	b8 00 00 00 00       	mov    $0x0,%eax
80102b9e:	8b 15 e8 26 13 80    	mov    0x801326e8,%edx
80102ba4:	39 c2                	cmp    %eax,%edx
80102ba6:	7e 2b                	jle    80102bd3 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102ba8:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102bab:	39 0c 85 ec 26 13 80 	cmp    %ecx,-0x7fecd914(,%eax,4)
80102bb2:	74 1f                	je     80102bd3 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102bb4:	83 c0 01             	add    $0x1,%eax
80102bb7:	eb e5                	jmp    80102b9e <log_write+0x3f>
    panic("too big a transaction");
80102bb9:	83 ec 0c             	sub    $0xc,%esp
80102bbc:	68 13 6c 10 80       	push   $0x80106c13
80102bc1:	e8 82 d7 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102bc6:	83 ec 0c             	sub    $0xc,%esp
80102bc9:	68 29 6c 10 80       	push   $0x80106c29
80102bce:	e8 75 d7 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102bd3:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102bd6:	89 0c 85 ec 26 13 80 	mov    %ecx,-0x7fecd914(,%eax,4)
  if (i == log.lh.n)
80102bdd:	39 c2                	cmp    %eax,%edx
80102bdf:	74 18                	je     80102bf9 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102be1:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102be4:	83 ec 0c             	sub    $0xc,%esp
80102be7:	68 a0 26 13 80       	push   $0x801326a0
80102bec:	e8 a7 12 00 00       	call   80103e98 <release>
}
80102bf1:	83 c4 10             	add    $0x10,%esp
80102bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102bf7:	c9                   	leave  
80102bf8:	c3                   	ret    
    log.lh.n++;
80102bf9:	83 c2 01             	add    $0x1,%edx
80102bfc:	89 15 e8 26 13 80    	mov    %edx,0x801326e8
80102c02:	eb dd                	jmp    80102be1 <log_write+0x82>

80102c04 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102c04:	55                   	push   %ebp
80102c05:	89 e5                	mov    %esp,%ebp
80102c07:	53                   	push   %ebx
80102c08:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102c0b:	68 8a 00 00 00       	push   $0x8a
80102c10:	68 8c a4 12 80       	push   $0x8012a48c
80102c15:	68 00 70 00 80       	push   $0x80007000
80102c1a:	e8 3b 13 00 00       	call   80103f5a <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102c1f:	83 c4 10             	add    $0x10,%esp
80102c22:	bb a0 27 13 80       	mov    $0x801327a0,%ebx
80102c27:	eb 06                	jmp    80102c2f <startothers+0x2b>
80102c29:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102c2f:	69 05 20 2d 13 80 b0 	imul   $0xb0,0x80132d20,%eax
80102c36:	00 00 00 
80102c39:	05 a0 27 13 80       	add    $0x801327a0,%eax
80102c3e:	39 d8                	cmp    %ebx,%eax
80102c40:	76 51                	jbe    80102c93 <startothers+0x8f>
    if(c == mycpu())  // We've started already.
80102c42:	e8 d3 07 00 00       	call   8010341a <mycpu>
80102c47:	39 d8                	cmp    %ebx,%eax
80102c49:	74 de                	je     80102c29 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc(-2);
80102c4b:	83 ec 0c             	sub    $0xc,%esp
80102c4e:	6a fe                	push   $0xfffffffe
80102c50:	e8 56 f6 ff ff       	call   801022ab <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102c55:	05 00 10 00 00       	add    $0x1000,%eax
80102c5a:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102c5f:	c7 05 f8 6f 00 80 d7 	movl   $0x80102cd7,0x80006ff8
80102c66:	2c 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102c69:	c7 05 f4 6f 00 80 00 	movl   $0x129000,0x80006ff4
80102c70:	90 12 00 

    lapicstartap(c->apicid, V2P(code));
80102c73:	83 c4 08             	add    $0x8,%esp
80102c76:	68 00 70 00 00       	push   $0x7000
80102c7b:	0f b6 03             	movzbl (%ebx),%eax
80102c7e:	50                   	push   %eax
80102c7f:	e8 c1 f9 ff ff       	call   80102645 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102c84:	83 c4 10             	add    $0x10,%esp
80102c87:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102c8d:	85 c0                	test   %eax,%eax
80102c8f:	74 f6                	je     80102c87 <startothers+0x83>
80102c91:	eb 96                	jmp    80102c29 <startothers+0x25>
      ;
  }
}
80102c93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c96:	c9                   	leave  
80102c97:	c3                   	ret    

80102c98 <mpmain>:
{
80102c98:	55                   	push   %ebp
80102c99:	89 e5                	mov    %esp,%ebp
80102c9b:	53                   	push   %ebx
80102c9c:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102c9f:	e8 d2 07 00 00       	call   80103476 <cpuid>
80102ca4:	89 c3                	mov    %eax,%ebx
80102ca6:	e8 cb 07 00 00       	call   80103476 <cpuid>
80102cab:	83 ec 04             	sub    $0x4,%esp
80102cae:	53                   	push   %ebx
80102caf:	50                   	push   %eax
80102cb0:	68 44 6c 10 80       	push   $0x80106c44
80102cb5:	e8 51 d9 ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102cba:	e8 f2 23 00 00       	call   801050b1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102cbf:	e8 56 07 00 00       	call   8010341a <mycpu>
80102cc4:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102cc6:	b8 01 00 00 00       	mov    $0x1,%eax
80102ccb:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102cd2:	e8 3c 0a 00 00       	call   80103713 <scheduler>

80102cd7 <mpenter>:
{
80102cd7:	55                   	push   %ebp
80102cd8:	89 e5                	mov    %esp,%ebp
80102cda:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102cdd:	e8 e0 33 00 00       	call   801060c2 <switchkvm>
  seginit();
80102ce2:	e8 8f 32 00 00       	call   80105f76 <seginit>
  lapicinit();
80102ce7:	e8 10 f8 ff ff       	call   801024fc <lapicinit>
  mpmain();
80102cec:	e8 a7 ff ff ff       	call   80102c98 <mpmain>

80102cf1 <main>:
{
80102cf1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102cf5:	83 e4 f0             	and    $0xfffffff0,%esp
80102cf8:	ff 71 fc             	pushl  -0x4(%ecx)
80102cfb:	55                   	push   %ebp
80102cfc:	89 e5                	mov    %esp,%ebp
80102cfe:	51                   	push   %ecx
80102cff:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102d02:	68 00 00 40 80       	push   $0x80400000
80102d07:	68 c8 54 13 80       	push   $0x801354c8
80102d0c:	e8 3e f5 ff ff       	call   8010224f <kinit1>
  kvmalloc();      // kernel page table
80102d11:	e8 4f 38 00 00       	call   80106565 <kvmalloc>
  mpinit();        // detect other processors
80102d16:	e8 c9 01 00 00       	call   80102ee4 <mpinit>
  lapicinit();     // interrupt controller
80102d1b:	e8 dc f7 ff ff       	call   801024fc <lapicinit>
  seginit();       // segment descriptors
80102d20:	e8 51 32 00 00       	call   80105f76 <seginit>
  picinit();       // disable pic
80102d25:	e8 82 02 00 00       	call   80102fac <picinit>
  ioapicinit();    // another interrupt controller
80102d2a:	e8 d7 f1 ff ff       	call   80101f06 <ioapicinit>
  consoleinit();   // console hardware
80102d2f:	e8 5a db ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102d34:	e8 26 26 00 00       	call   8010535f <uartinit>
  pinit();         // process table
80102d39:	e8 c2 06 00 00       	call   80103400 <pinit>
  tvinit();        // trap vectors
80102d3e:	e8 bd 22 00 00       	call   80105000 <tvinit>
  binit();         // buffer cache
80102d43:	e8 ac d3 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102d48:	e8 d2 de ff ff       	call   80100c1f <fileinit>
  ideinit();       // disk 
80102d4d:	e8 ba ef ff ff       	call   80101d0c <ideinit>
  startothers();   // start other processors
80102d52:	e8 ad fe ff ff       	call   80102c04 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102d57:	83 c4 08             	add    $0x8,%esp
80102d5a:	68 00 00 00 8e       	push   $0x8e000000
80102d5f:	68 00 00 40 80       	push   $0x80400000
80102d64:	e8 18 f5 ff ff       	call   80102281 <kinit2>
  userinit();      // first user process
80102d69:	e8 47 07 00 00       	call   801034b5 <userinit>
  mpmain();        // finish this processor's setup
80102d6e:	e8 25 ff ff ff       	call   80102c98 <mpmain>

80102d73 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102d73:	55                   	push   %ebp
80102d74:	89 e5                	mov    %esp,%ebp
80102d76:	56                   	push   %esi
80102d77:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102d78:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
80102d82:	eb 09                	jmp    80102d8d <sum+0x1a>
    sum += addr[i];
80102d84:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102d88:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102d8a:	83 c1 01             	add    $0x1,%ecx
80102d8d:	39 d1                	cmp    %edx,%ecx
80102d8f:	7c f3                	jl     80102d84 <sum+0x11>
  return sum;
}
80102d91:	89 d8                	mov    %ebx,%eax
80102d93:	5b                   	pop    %ebx
80102d94:	5e                   	pop    %esi
80102d95:	5d                   	pop    %ebp
80102d96:	c3                   	ret    

80102d97 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102d97:	55                   	push   %ebp
80102d98:	89 e5                	mov    %esp,%ebp
80102d9a:	56                   	push   %esi
80102d9b:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102d9c:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102da2:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102da4:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102da6:	eb 03                	jmp    80102dab <mpsearch1+0x14>
80102da8:	83 c3 10             	add    $0x10,%ebx
80102dab:	39 f3                	cmp    %esi,%ebx
80102dad:	73 29                	jae    80102dd8 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102daf:	83 ec 04             	sub    $0x4,%esp
80102db2:	6a 04                	push   $0x4
80102db4:	68 58 6c 10 80       	push   $0x80106c58
80102db9:	53                   	push   %ebx
80102dba:	e8 66 11 00 00       	call   80103f25 <memcmp>
80102dbf:	83 c4 10             	add    $0x10,%esp
80102dc2:	85 c0                	test   %eax,%eax
80102dc4:	75 e2                	jne    80102da8 <mpsearch1+0x11>
80102dc6:	ba 10 00 00 00       	mov    $0x10,%edx
80102dcb:	89 d8                	mov    %ebx,%eax
80102dcd:	e8 a1 ff ff ff       	call   80102d73 <sum>
80102dd2:	84 c0                	test   %al,%al
80102dd4:	75 d2                	jne    80102da8 <mpsearch1+0x11>
80102dd6:	eb 05                	jmp    80102ddd <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102dd8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102ddd:	89 d8                	mov    %ebx,%eax
80102ddf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102de2:	5b                   	pop    %ebx
80102de3:	5e                   	pop    %esi
80102de4:	5d                   	pop    %ebp
80102de5:	c3                   	ret    

80102de6 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102de6:	55                   	push   %ebp
80102de7:	89 e5                	mov    %esp,%ebp
80102de9:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102dec:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102df3:	c1 e0 08             	shl    $0x8,%eax
80102df6:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102dfd:	09 d0                	or     %edx,%eax
80102dff:	c1 e0 04             	shl    $0x4,%eax
80102e02:	85 c0                	test   %eax,%eax
80102e04:	74 1f                	je     80102e25 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102e06:	ba 00 04 00 00       	mov    $0x400,%edx
80102e0b:	e8 87 ff ff ff       	call   80102d97 <mpsearch1>
80102e10:	85 c0                	test   %eax,%eax
80102e12:	75 0f                	jne    80102e23 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102e14:	ba 00 00 01 00       	mov    $0x10000,%edx
80102e19:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102e1e:	e8 74 ff ff ff       	call   80102d97 <mpsearch1>
}
80102e23:	c9                   	leave  
80102e24:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102e25:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102e2c:	c1 e0 08             	shl    $0x8,%eax
80102e2f:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102e36:	09 d0                	or     %edx,%eax
80102e38:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102e3b:	2d 00 04 00 00       	sub    $0x400,%eax
80102e40:	ba 00 04 00 00       	mov    $0x400,%edx
80102e45:	e8 4d ff ff ff       	call   80102d97 <mpsearch1>
80102e4a:	85 c0                	test   %eax,%eax
80102e4c:	75 d5                	jne    80102e23 <mpsearch+0x3d>
80102e4e:	eb c4                	jmp    80102e14 <mpsearch+0x2e>

80102e50 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102e50:	55                   	push   %ebp
80102e51:	89 e5                	mov    %esp,%ebp
80102e53:	57                   	push   %edi
80102e54:	56                   	push   %esi
80102e55:	53                   	push   %ebx
80102e56:	83 ec 1c             	sub    $0x1c,%esp
80102e59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102e5c:	e8 85 ff ff ff       	call   80102de6 <mpsearch>
80102e61:	85 c0                	test   %eax,%eax
80102e63:	74 5c                	je     80102ec1 <mpconfig+0x71>
80102e65:	89 c7                	mov    %eax,%edi
80102e67:	8b 58 04             	mov    0x4(%eax),%ebx
80102e6a:	85 db                	test   %ebx,%ebx
80102e6c:	74 5a                	je     80102ec8 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102e6e:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102e74:	83 ec 04             	sub    $0x4,%esp
80102e77:	6a 04                	push   $0x4
80102e79:	68 5d 6c 10 80       	push   $0x80106c5d
80102e7e:	56                   	push   %esi
80102e7f:	e8 a1 10 00 00       	call   80103f25 <memcmp>
80102e84:	83 c4 10             	add    $0x10,%esp
80102e87:	85 c0                	test   %eax,%eax
80102e89:	75 44                	jne    80102ecf <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102e8b:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102e92:	3c 01                	cmp    $0x1,%al
80102e94:	0f 95 c2             	setne  %dl
80102e97:	3c 04                	cmp    $0x4,%al
80102e99:	0f 95 c0             	setne  %al
80102e9c:	84 c2                	test   %al,%dl
80102e9e:	75 36                	jne    80102ed6 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102ea0:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102ea7:	89 f0                	mov    %esi,%eax
80102ea9:	e8 c5 fe ff ff       	call   80102d73 <sum>
80102eae:	84 c0                	test   %al,%al
80102eb0:	75 2b                	jne    80102edd <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eb5:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102eb7:	89 f0                	mov    %esi,%eax
80102eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ebc:	5b                   	pop    %ebx
80102ebd:	5e                   	pop    %esi
80102ebe:	5f                   	pop    %edi
80102ebf:	5d                   	pop    %ebp
80102ec0:	c3                   	ret    
    return 0;
80102ec1:	be 00 00 00 00       	mov    $0x0,%esi
80102ec6:	eb ef                	jmp    80102eb7 <mpconfig+0x67>
80102ec8:	be 00 00 00 00       	mov    $0x0,%esi
80102ecd:	eb e8                	jmp    80102eb7 <mpconfig+0x67>
    return 0;
80102ecf:	be 00 00 00 00       	mov    $0x0,%esi
80102ed4:	eb e1                	jmp    80102eb7 <mpconfig+0x67>
    return 0;
80102ed6:	be 00 00 00 00       	mov    $0x0,%esi
80102edb:	eb da                	jmp    80102eb7 <mpconfig+0x67>
    return 0;
80102edd:	be 00 00 00 00       	mov    $0x0,%esi
80102ee2:	eb d3                	jmp    80102eb7 <mpconfig+0x67>

80102ee4 <mpinit>:

void
mpinit(void)
{
80102ee4:	55                   	push   %ebp
80102ee5:	89 e5                	mov    %esp,%ebp
80102ee7:	57                   	push   %edi
80102ee8:	56                   	push   %esi
80102ee9:	53                   	push   %ebx
80102eea:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102eed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102ef0:	e8 5b ff ff ff       	call   80102e50 <mpconfig>
80102ef5:	85 c0                	test   %eax,%eax
80102ef7:	74 19                	je     80102f12 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102ef9:	8b 50 24             	mov    0x24(%eax),%edx
80102efc:	89 15 9c 26 13 80    	mov    %edx,0x8013269c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f02:	8d 50 2c             	lea    0x2c(%eax),%edx
80102f05:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102f09:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102f0b:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f10:	eb 34                	jmp    80102f46 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102f12:	83 ec 0c             	sub    $0xc,%esp
80102f15:	68 62 6c 10 80       	push   $0x80106c62
80102f1a:	e8 29 d4 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102f1f:	8b 35 20 2d 13 80    	mov    0x80132d20,%esi
80102f25:	83 fe 07             	cmp    $0x7,%esi
80102f28:	7f 19                	jg     80102f43 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102f2a:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102f2e:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102f34:	88 87 a0 27 13 80    	mov    %al,-0x7fecd860(%edi)
        ncpu++;
80102f3a:	83 c6 01             	add    $0x1,%esi
80102f3d:	89 35 20 2d 13 80    	mov    %esi,0x80132d20
      }
      p += sizeof(struct mpproc);
80102f43:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f46:	39 ca                	cmp    %ecx,%edx
80102f48:	73 2b                	jae    80102f75 <mpinit+0x91>
    switch(*p){
80102f4a:	0f b6 02             	movzbl (%edx),%eax
80102f4d:	3c 04                	cmp    $0x4,%al
80102f4f:	77 1d                	ja     80102f6e <mpinit+0x8a>
80102f51:	0f b6 c0             	movzbl %al,%eax
80102f54:	ff 24 85 9c 6c 10 80 	jmp    *-0x7fef9364(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102f5b:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102f5f:	a2 80 27 13 80       	mov    %al,0x80132780
      p += sizeof(struct mpioapic);
80102f64:	83 c2 08             	add    $0x8,%edx
      continue;
80102f67:	eb dd                	jmp    80102f46 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102f69:	83 c2 08             	add    $0x8,%edx
      continue;
80102f6c:	eb d8                	jmp    80102f46 <mpinit+0x62>
    default:
      ismp = 0;
80102f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
80102f73:	eb d1                	jmp    80102f46 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102f75:	85 db                	test   %ebx,%ebx
80102f77:	74 26                	je     80102f9f <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f7c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102f80:	74 15                	je     80102f97 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f82:	b8 70 00 00 00       	mov    $0x70,%eax
80102f87:	ba 22 00 00 00       	mov    $0x22,%edx
80102f8c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f8d:	ba 23 00 00 00       	mov    $0x23,%edx
80102f92:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102f93:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f96:	ee                   	out    %al,(%dx)
  }
}
80102f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f9a:	5b                   	pop    %ebx
80102f9b:	5e                   	pop    %esi
80102f9c:	5f                   	pop    %edi
80102f9d:	5d                   	pop    %ebp
80102f9e:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102f9f:	83 ec 0c             	sub    $0xc,%esp
80102fa2:	68 7c 6c 10 80       	push   $0x80106c7c
80102fa7:	e8 9c d3 ff ff       	call   80100348 <panic>

80102fac <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102fac:	55                   	push   %ebp
80102fad:	89 e5                	mov    %esp,%ebp
80102faf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fb4:	ba 21 00 00 00       	mov    $0x21,%edx
80102fb9:	ee                   	out    %al,(%dx)
80102fba:	ba a1 00 00 00       	mov    $0xa1,%edx
80102fbf:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102fc0:	5d                   	pop    %ebp
80102fc1:	c3                   	ret    

80102fc2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102fc2:	55                   	push   %ebp
80102fc3:	89 e5                	mov    %esp,%ebp
80102fc5:	57                   	push   %edi
80102fc6:	56                   	push   %esi
80102fc7:	53                   	push   %ebx
80102fc8:	83 ec 0c             	sub    $0xc,%esp
80102fcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102fce:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102fd1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102fd7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102fdd:	e8 57 dc ff ff       	call   80100c39 <filealloc>
80102fe2:	89 03                	mov    %eax,(%ebx)
80102fe4:	85 c0                	test   %eax,%eax
80102fe6:	74 1e                	je     80103006 <pipealloc+0x44>
80102fe8:	e8 4c dc ff ff       	call   80100c39 <filealloc>
80102fed:	89 06                	mov    %eax,(%esi)
80102fef:	85 c0                	test   %eax,%eax
80102ff1:	74 13                	je     80103006 <pipealloc+0x44>
    goto bad;
  if((p = (struct pipe*)kalloc(-2)) == 0)
80102ff3:	83 ec 0c             	sub    $0xc,%esp
80102ff6:	6a fe                	push   $0xfffffffe
80102ff8:	e8 ae f2 ff ff       	call   801022ab <kalloc>
80102ffd:	89 c7                	mov    %eax,%edi
80102fff:	83 c4 10             	add    $0x10,%esp
80103002:	85 c0                	test   %eax,%eax
80103004:	75 35                	jne    8010303b <pipealloc+0x79>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80103006:	8b 03                	mov    (%ebx),%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <pipealloc+0x56>
    fileclose(*f0);
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	50                   	push   %eax
80103010:	e8 ca dc ff ff       	call   80100cdf <fileclose>
80103015:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103018:	8b 06                	mov    (%esi),%eax
8010301a:	85 c0                	test   %eax,%eax
8010301c:	0f 84 8b 00 00 00    	je     801030ad <pipealloc+0xeb>
    fileclose(*f1);
80103022:	83 ec 0c             	sub    $0xc,%esp
80103025:	50                   	push   %eax
80103026:	e8 b4 dc ff ff       	call   80100cdf <fileclose>
8010302b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010302e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103033:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103036:	5b                   	pop    %ebx
80103037:	5e                   	pop    %esi
80103038:	5f                   	pop    %edi
80103039:	5d                   	pop    %ebp
8010303a:	c3                   	ret    
  p->readopen = 1;
8010303b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103042:	00 00 00 
  p->writeopen = 1;
80103045:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010304c:	00 00 00 
  p->nwrite = 0;
8010304f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103056:	00 00 00 
  p->nread = 0;
80103059:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103060:	00 00 00 
  initlock(&p->lock, "pipe");
80103063:	83 ec 08             	sub    $0x8,%esp
80103066:	68 b0 6c 10 80       	push   $0x80106cb0
8010306b:	50                   	push   %eax
8010306c:	e8 86 0c 00 00       	call   80103cf7 <initlock>
  (*f0)->type = FD_PIPE;
80103071:	8b 03                	mov    (%ebx),%eax
80103073:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103079:	8b 03                	mov    (%ebx),%eax
8010307b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010307f:	8b 03                	mov    (%ebx),%eax
80103081:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103085:	8b 03                	mov    (%ebx),%eax
80103087:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010308a:	8b 06                	mov    (%esi),%eax
8010308c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103092:	8b 06                	mov    (%esi),%eax
80103094:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103098:	8b 06                	mov    (%esi),%eax
8010309a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010309e:	8b 06                	mov    (%esi),%eax
801030a0:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
801030a3:	83 c4 10             	add    $0x10,%esp
801030a6:	b8 00 00 00 00       	mov    $0x0,%eax
801030ab:	eb 86                	jmp    80103033 <pipealloc+0x71>
  return -1;
801030ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801030b2:	e9 7c ff ff ff       	jmp    80103033 <pipealloc+0x71>

801030b7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801030b7:	55                   	push   %ebp
801030b8:	89 e5                	mov    %esp,%ebp
801030ba:	53                   	push   %ebx
801030bb:	83 ec 10             	sub    $0x10,%esp
801030be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
801030c1:	53                   	push   %ebx
801030c2:	e8 6c 0d 00 00       	call   80103e33 <acquire>
  if(writable){
801030c7:	83 c4 10             	add    $0x10,%esp
801030ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801030ce:	74 3f                	je     8010310f <pipeclose+0x58>
    p->writeopen = 0;
801030d0:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801030d7:	00 00 00 
    wakeup(&p->nread);
801030da:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030e0:	83 ec 0c             	sub    $0xc,%esp
801030e3:	50                   	push   %eax
801030e4:	e8 b4 09 00 00       	call   80103a9d <wakeup>
801030e9:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
801030ec:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
801030f3:	75 09                	jne    801030fe <pipeclose+0x47>
801030f5:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
801030fc:	74 2f                	je     8010312d <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
801030fe:	83 ec 0c             	sub    $0xc,%esp
80103101:	53                   	push   %ebx
80103102:	e8 91 0d 00 00       	call   80103e98 <release>
80103107:	83 c4 10             	add    $0x10,%esp
}
8010310a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010310d:	c9                   	leave  
8010310e:	c3                   	ret    
    p->readopen = 0;
8010310f:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103116:	00 00 00 
    wakeup(&p->nwrite);
80103119:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010311f:	83 ec 0c             	sub    $0xc,%esp
80103122:	50                   	push   %eax
80103123:	e8 75 09 00 00       	call   80103a9d <wakeup>
80103128:	83 c4 10             	add    $0x10,%esp
8010312b:	eb bf                	jmp    801030ec <pipeclose+0x35>
    release(&p->lock);
8010312d:	83 ec 0c             	sub    $0xc,%esp
80103130:	53                   	push   %ebx
80103131:	e8 62 0d 00 00       	call   80103e98 <release>
    kfree((char*)p);
80103136:	89 1c 24             	mov    %ebx,(%esp)
80103139:	e8 d2 ef ff ff       	call   80102110 <kfree>
8010313e:	83 c4 10             	add    $0x10,%esp
80103141:	eb c7                	jmp    8010310a <pipeclose+0x53>

80103143 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103143:	55                   	push   %ebp
80103144:	89 e5                	mov    %esp,%ebp
80103146:	57                   	push   %edi
80103147:	56                   	push   %esi
80103148:	53                   	push   %ebx
80103149:	83 ec 18             	sub    $0x18,%esp
8010314c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010314f:	89 de                	mov    %ebx,%esi
80103151:	53                   	push   %ebx
80103152:	e8 dc 0c 00 00       	call   80103e33 <acquire>
  for(i = 0; i < n; i++){
80103157:	83 c4 10             	add    $0x10,%esp
8010315a:	bf 00 00 00 00       	mov    $0x0,%edi
8010315f:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103162:	0f 8d 88 00 00 00    	jge    801031f0 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103168:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010316e:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103174:	05 00 02 00 00       	add    $0x200,%eax
80103179:	39 c2                	cmp    %eax,%edx
8010317b:	75 51                	jne    801031ce <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
8010317d:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103184:	74 2f                	je     801031b5 <pipewrite+0x72>
80103186:	e8 06 03 00 00       	call   80103491 <myproc>
8010318b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010318f:	75 24                	jne    801031b5 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103191:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103197:	83 ec 0c             	sub    $0xc,%esp
8010319a:	50                   	push   %eax
8010319b:	e8 fd 08 00 00       	call   80103a9d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801031a0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031a6:	83 c4 08             	add    $0x8,%esp
801031a9:	56                   	push   %esi
801031aa:	50                   	push   %eax
801031ab:	e8 88 07 00 00       	call   80103938 <sleep>
801031b0:	83 c4 10             	add    $0x10,%esp
801031b3:	eb b3                	jmp    80103168 <pipewrite+0x25>
        release(&p->lock);
801031b5:	83 ec 0c             	sub    $0xc,%esp
801031b8:	53                   	push   %ebx
801031b9:	e8 da 0c 00 00       	call   80103e98 <release>
        return -1;
801031be:	83 c4 10             	add    $0x10,%esp
801031c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801031c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031c9:	5b                   	pop    %ebx
801031ca:	5e                   	pop    %esi
801031cb:	5f                   	pop    %edi
801031cc:	5d                   	pop    %ebp
801031cd:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801031ce:	8d 42 01             	lea    0x1(%edx),%eax
801031d1:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801031d7:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801031dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801031e0:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801031e4:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801031e8:	83 c7 01             	add    $0x1,%edi
801031eb:	e9 6f ff ff ff       	jmp    8010315f <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801031f0:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801031f6:	83 ec 0c             	sub    $0xc,%esp
801031f9:	50                   	push   %eax
801031fa:	e8 9e 08 00 00       	call   80103a9d <wakeup>
  release(&p->lock);
801031ff:	89 1c 24             	mov    %ebx,(%esp)
80103202:	e8 91 0c 00 00       	call   80103e98 <release>
  return n;
80103207:	83 c4 10             	add    $0x10,%esp
8010320a:	8b 45 10             	mov    0x10(%ebp),%eax
8010320d:	eb b7                	jmp    801031c6 <pipewrite+0x83>

8010320f <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010320f:	55                   	push   %ebp
80103210:	89 e5                	mov    %esp,%ebp
80103212:	57                   	push   %edi
80103213:	56                   	push   %esi
80103214:	53                   	push   %ebx
80103215:	83 ec 18             	sub    $0x18,%esp
80103218:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010321b:	89 df                	mov    %ebx,%edi
8010321d:	53                   	push   %ebx
8010321e:	e8 10 0c 00 00       	call   80103e33 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103223:	83 c4 10             	add    $0x10,%esp
80103226:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
8010322c:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103232:	75 3d                	jne    80103271 <piperead+0x62>
80103234:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
8010323a:	85 f6                	test   %esi,%esi
8010323c:	74 38                	je     80103276 <piperead+0x67>
    if(myproc()->killed){
8010323e:	e8 4e 02 00 00       	call   80103491 <myproc>
80103243:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103247:	75 15                	jne    8010325e <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103249:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010324f:	83 ec 08             	sub    $0x8,%esp
80103252:	57                   	push   %edi
80103253:	50                   	push   %eax
80103254:	e8 df 06 00 00       	call   80103938 <sleep>
80103259:	83 c4 10             	add    $0x10,%esp
8010325c:	eb c8                	jmp    80103226 <piperead+0x17>
      release(&p->lock);
8010325e:	83 ec 0c             	sub    $0xc,%esp
80103261:	53                   	push   %ebx
80103262:	e8 31 0c 00 00       	call   80103e98 <release>
      return -1;
80103267:	83 c4 10             	add    $0x10,%esp
8010326a:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010326f:	eb 50                	jmp    801032c1 <piperead+0xb2>
80103271:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103276:	3b 75 10             	cmp    0x10(%ebp),%esi
80103279:	7d 2c                	jge    801032a7 <piperead+0x98>
    if(p->nread == p->nwrite)
8010327b:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103281:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103287:	74 1e                	je     801032a7 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103289:	8d 50 01             	lea    0x1(%eax),%edx
8010328c:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103292:	25 ff 01 00 00       	and    $0x1ff,%eax
80103297:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010329c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010329f:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801032a2:	83 c6 01             	add    $0x1,%esi
801032a5:	eb cf                	jmp    80103276 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801032a7:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	50                   	push   %eax
801032b1:	e8 e7 07 00 00       	call   80103a9d <wakeup>
  release(&p->lock);
801032b6:	89 1c 24             	mov    %ebx,(%esp)
801032b9:	e8 da 0b 00 00       	call   80103e98 <release>
  return i;
801032be:	83 c4 10             	add    $0x10,%esp
}
801032c1:	89 f0                	mov    %esi,%eax
801032c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801032c6:	5b                   	pop    %ebx
801032c7:	5e                   	pop    %esi
801032c8:	5f                   	pop    %edi
801032c9:	5d                   	pop    %ebp
801032ca:	c3                   	ret    

801032cb <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801032cb:	55                   	push   %ebp
801032cc:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801032ce:	ba 74 2d 13 80       	mov    $0x80132d74,%edx
801032d3:	eb 03                	jmp    801032d8 <wakeup1+0xd>
801032d5:	83 c2 7c             	add    $0x7c,%edx
801032d8:	81 fa 74 4c 13 80    	cmp    $0x80134c74,%edx
801032de:	73 14                	jae    801032f4 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801032e0:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801032e4:	75 ef                	jne    801032d5 <wakeup1+0xa>
801032e6:	39 42 20             	cmp    %eax,0x20(%edx)
801032e9:	75 ea                	jne    801032d5 <wakeup1+0xa>
      p->state = RUNNABLE;
801032eb:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801032f2:	eb e1                	jmp    801032d5 <wakeup1+0xa>
}
801032f4:	5d                   	pop    %ebp
801032f5:	c3                   	ret    

801032f6 <allocproc>:
{
801032f6:	55                   	push   %ebp
801032f7:	89 e5                	mov    %esp,%ebp
801032f9:	53                   	push   %ebx
801032fa:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801032fd:	68 40 2d 13 80       	push   $0x80132d40
80103302:	e8 2c 0b 00 00       	call   80103e33 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103307:	83 c4 10             	add    $0x10,%esp
8010330a:	bb 74 2d 13 80       	mov    $0x80132d74,%ebx
8010330f:	81 fb 74 4c 13 80    	cmp    $0x80134c74,%ebx
80103315:	73 0b                	jae    80103322 <allocproc+0x2c>
    if(p->state == UNUSED)
80103317:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010331b:	74 1c                	je     80103339 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010331d:	83 c3 7c             	add    $0x7c,%ebx
80103320:	eb ed                	jmp    8010330f <allocproc+0x19>
  release(&ptable.lock);
80103322:	83 ec 0c             	sub    $0xc,%esp
80103325:	68 40 2d 13 80       	push   $0x80132d40
8010332a:	e8 69 0b 00 00       	call   80103e98 <release>
  return 0;
8010332f:	83 c4 10             	add    $0x10,%esp
80103332:	bb 00 00 00 00       	mov    $0x0,%ebx
80103337:	eb 6f                	jmp    801033a8 <allocproc+0xb2>
  p->state = EMBRYO;
80103339:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103340:	a1 04 a0 12 80       	mov    0x8012a004,%eax
80103345:	8d 50 01             	lea    0x1(%eax),%edx
80103348:	89 15 04 a0 12 80    	mov    %edx,0x8012a004
8010334e:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103351:	83 ec 0c             	sub    $0xc,%esp
80103354:	68 40 2d 13 80       	push   $0x80132d40
80103359:	e8 3a 0b 00 00       	call   80103e98 <release>
  if((p->kstack = kalloc(p->pid)) == 0){
8010335e:	83 c4 04             	add    $0x4,%esp
80103361:	ff 73 10             	pushl  0x10(%ebx)
80103364:	e8 42 ef ff ff       	call   801022ab <kalloc>
80103369:	89 43 08             	mov    %eax,0x8(%ebx)
8010336c:	83 c4 10             	add    $0x10,%esp
8010336f:	85 c0                	test   %eax,%eax
80103371:	74 3c                	je     801033af <allocproc+0xb9>
  sp -= sizeof *p->tf;
80103373:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103379:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010337c:	c7 80 b0 0f 00 00 f5 	movl   $0x80104ff5,0xfb0(%eax)
80103383:	4f 10 80 
  sp -= sizeof *p->context;
80103386:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010338b:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010338e:	83 ec 04             	sub    $0x4,%esp
80103391:	6a 14                	push   $0x14
80103393:	6a 00                	push   $0x0
80103395:	50                   	push   %eax
80103396:	e8 44 0b 00 00       	call   80103edf <memset>
  p->context->eip = (uint)forkret;
8010339b:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010339e:	c7 40 10 bd 33 10 80 	movl   $0x801033bd,0x10(%eax)
  return p;
801033a5:	83 c4 10             	add    $0x10,%esp
}
801033a8:	89 d8                	mov    %ebx,%eax
801033aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033ad:	c9                   	leave  
801033ae:	c3                   	ret    
    p->state = UNUSED;
801033af:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801033b6:	bb 00 00 00 00       	mov    $0x0,%ebx
801033bb:	eb eb                	jmp    801033a8 <allocproc+0xb2>

801033bd <forkret>:
{
801033bd:	55                   	push   %ebp
801033be:	89 e5                	mov    %esp,%ebp
801033c0:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801033c3:	68 40 2d 13 80       	push   $0x80132d40
801033c8:	e8 cb 0a 00 00       	call   80103e98 <release>
  if (first) {
801033cd:	83 c4 10             	add    $0x10,%esp
801033d0:	83 3d 00 a0 12 80 00 	cmpl   $0x0,0x8012a000
801033d7:	75 02                	jne    801033db <forkret+0x1e>
}
801033d9:	c9                   	leave  
801033da:	c3                   	ret    
    first = 0;
801033db:	c7 05 00 a0 12 80 00 	movl   $0x0,0x8012a000
801033e2:	00 00 00 
    iinit(ROOTDEV);
801033e5:	83 ec 0c             	sub    $0xc,%esp
801033e8:	6a 01                	push   $0x1
801033ea:	e8 09 df ff ff       	call   801012f8 <iinit>
    initlog(ROOTDEV);
801033ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801033f6:	e8 f2 f5 ff ff       	call   801029ed <initlog>
801033fb:	83 c4 10             	add    $0x10,%esp
}
801033fe:	eb d9                	jmp    801033d9 <forkret+0x1c>

80103400 <pinit>:
{
80103400:	55                   	push   %ebp
80103401:	89 e5                	mov    %esp,%ebp
80103403:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103406:	68 b5 6c 10 80       	push   $0x80106cb5
8010340b:	68 40 2d 13 80       	push   $0x80132d40
80103410:	e8 e2 08 00 00       	call   80103cf7 <initlock>
}
80103415:	83 c4 10             	add    $0x10,%esp
80103418:	c9                   	leave  
80103419:	c3                   	ret    

8010341a <mycpu>:
{
8010341a:	55                   	push   %ebp
8010341b:	89 e5                	mov    %esp,%ebp
8010341d:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103420:	9c                   	pushf  
80103421:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103422:	f6 c4 02             	test   $0x2,%ah
80103425:	75 28                	jne    8010344f <mycpu+0x35>
  apicid = lapicid();
80103427:	e8 da f1 ff ff       	call   80102606 <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010342c:	ba 00 00 00 00       	mov    $0x0,%edx
80103431:	39 15 20 2d 13 80    	cmp    %edx,0x80132d20
80103437:	7e 23                	jle    8010345c <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103439:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010343f:	0f b6 89 a0 27 13 80 	movzbl -0x7fecd860(%ecx),%ecx
80103446:	39 c1                	cmp    %eax,%ecx
80103448:	74 1f                	je     80103469 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010344a:	83 c2 01             	add    $0x1,%edx
8010344d:	eb e2                	jmp    80103431 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010344f:	83 ec 0c             	sub    $0xc,%esp
80103452:	68 98 6d 10 80       	push   $0x80106d98
80103457:	e8 ec ce ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010345c:	83 ec 0c             	sub    $0xc,%esp
8010345f:	68 bc 6c 10 80       	push   $0x80106cbc
80103464:	e8 df ce ff ff       	call   80100348 <panic>
      return &cpus[i];
80103469:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010346f:	05 a0 27 13 80       	add    $0x801327a0,%eax
}
80103474:	c9                   	leave  
80103475:	c3                   	ret    

80103476 <cpuid>:
cpuid() {
80103476:	55                   	push   %ebp
80103477:	89 e5                	mov    %esp,%ebp
80103479:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010347c:	e8 99 ff ff ff       	call   8010341a <mycpu>
80103481:	2d a0 27 13 80       	sub    $0x801327a0,%eax
80103486:	c1 f8 04             	sar    $0x4,%eax
80103489:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010348f:	c9                   	leave  
80103490:	c3                   	ret    

80103491 <myproc>:
myproc(void) {
80103491:	55                   	push   %ebp
80103492:	89 e5                	mov    %esp,%ebp
80103494:	53                   	push   %ebx
80103495:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103498:	e8 b9 08 00 00       	call   80103d56 <pushcli>
  c = mycpu();
8010349d:	e8 78 ff ff ff       	call   8010341a <mycpu>
  p = c->proc;
801034a2:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801034a8:	e8 e6 08 00 00       	call   80103d93 <popcli>
}
801034ad:	89 d8                	mov    %ebx,%eax
801034af:	83 c4 04             	add    $0x4,%esp
801034b2:	5b                   	pop    %ebx
801034b3:	5d                   	pop    %ebp
801034b4:	c3                   	ret    

801034b5 <userinit>:
{
801034b5:	55                   	push   %ebp
801034b6:	89 e5                	mov    %esp,%ebp
801034b8:	53                   	push   %ebx
801034b9:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801034bc:	e8 35 fe ff ff       	call   801032f6 <allocproc>
801034c1:	89 c3                	mov    %eax,%ebx
  initproc = p;
801034c3:	a3 c0 a5 12 80       	mov    %eax,0x8012a5c0
  if((p->pgdir = setupkvm()) == 0)
801034c8:	e8 22 30 00 00       	call   801064ef <setupkvm>
801034cd:	89 43 04             	mov    %eax,0x4(%ebx)
801034d0:	85 c0                	test   %eax,%eax
801034d2:	0f 84 b7 00 00 00    	je     8010358f <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801034d8:	83 ec 04             	sub    $0x4,%esp
801034db:	68 2c 00 00 00       	push   $0x2c
801034e0:	68 60 a4 12 80       	push   $0x8012a460
801034e5:	50                   	push   %eax
801034e6:	e8 01 2d 00 00       	call   801061ec <inituvm>
  p->sz = PGSIZE;
801034eb:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801034f1:	83 c4 0c             	add    $0xc,%esp
801034f4:	6a 4c                	push   $0x4c
801034f6:	6a 00                	push   $0x0
801034f8:	ff 73 18             	pushl  0x18(%ebx)
801034fb:	e8 df 09 00 00       	call   80103edf <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103500:	8b 43 18             	mov    0x18(%ebx),%eax
80103503:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103509:	8b 43 18             	mov    0x18(%ebx),%eax
8010350c:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103512:	8b 43 18             	mov    0x18(%ebx),%eax
80103515:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103519:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010351d:	8b 43 18             	mov    0x18(%ebx),%eax
80103520:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103524:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103528:	8b 43 18             	mov    0x18(%ebx),%eax
8010352b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103532:	8b 43 18             	mov    0x18(%ebx),%eax
80103535:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010353c:	8b 43 18             	mov    0x18(%ebx),%eax
8010353f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103546:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103549:	83 c4 0c             	add    $0xc,%esp
8010354c:	6a 10                	push   $0x10
8010354e:	68 e5 6c 10 80       	push   $0x80106ce5
80103553:	50                   	push   %eax
80103554:	e8 ed 0a 00 00       	call   80104046 <safestrcpy>
  p->cwd = namei("/");
80103559:	c7 04 24 ee 6c 10 80 	movl   $0x80106cee,(%esp)
80103560:	e8 88 e6 ff ff       	call   80101bed <namei>
80103565:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103568:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
8010356f:	e8 bf 08 00 00       	call   80103e33 <acquire>
  p->state = RUNNABLE;
80103574:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010357b:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
80103582:	e8 11 09 00 00       	call   80103e98 <release>
}
80103587:	83 c4 10             	add    $0x10,%esp
8010358a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010358d:	c9                   	leave  
8010358e:	c3                   	ret    
    panic("userinit: out of memory?");
8010358f:	83 ec 0c             	sub    $0xc,%esp
80103592:	68 cc 6c 10 80       	push   $0x80106ccc
80103597:	e8 ac cd ff ff       	call   80100348 <panic>

8010359c <growproc>:
{
8010359c:	55                   	push   %ebp
8010359d:	89 e5                	mov    %esp,%ebp
8010359f:	56                   	push   %esi
801035a0:	53                   	push   %ebx
801035a1:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801035a4:	e8 e8 fe ff ff       	call   80103491 <myproc>
801035a9:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801035ab:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801035ad:	85 f6                	test   %esi,%esi
801035af:	7f 21                	jg     801035d2 <growproc+0x36>
  } else if(n < 0){
801035b1:	85 f6                	test   %esi,%esi
801035b3:	79 33                	jns    801035e8 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801035b5:	83 ec 04             	sub    $0x4,%esp
801035b8:	01 c6                	add    %eax,%esi
801035ba:	56                   	push   %esi
801035bb:	50                   	push   %eax
801035bc:	ff 73 04             	pushl  0x4(%ebx)
801035bf:	e8 36 2d 00 00       	call   801062fa <deallocuvm>
801035c4:	83 c4 10             	add    $0x10,%esp
801035c7:	85 c0                	test   %eax,%eax
801035c9:	75 1d                	jne    801035e8 <growproc+0x4c>
      return -1;
801035cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035d0:	eb 29                	jmp    801035fb <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n, curproc->pid)) == 0)
801035d2:	ff 73 10             	pushl  0x10(%ebx)
801035d5:	01 c6                	add    %eax,%esi
801035d7:	56                   	push   %esi
801035d8:	50                   	push   %eax
801035d9:	ff 73 04             	pushl  0x4(%ebx)
801035dc:	e8 ab 2d 00 00       	call   8010638c <allocuvm>
801035e1:	83 c4 10             	add    $0x10,%esp
801035e4:	85 c0                	test   %eax,%eax
801035e6:	74 1a                	je     80103602 <growproc+0x66>
  curproc->sz = sz;
801035e8:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801035ea:	83 ec 0c             	sub    $0xc,%esp
801035ed:	53                   	push   %ebx
801035ee:	e8 e1 2a 00 00       	call   801060d4 <switchuvm>
  return 0;
801035f3:	83 c4 10             	add    $0x10,%esp
801035f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801035fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035fe:	5b                   	pop    %ebx
801035ff:	5e                   	pop    %esi
80103600:	5d                   	pop    %ebp
80103601:	c3                   	ret    
      return -1;
80103602:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103607:	eb f2                	jmp    801035fb <growproc+0x5f>

80103609 <fork>:
{
80103609:	55                   	push   %ebp
8010360a:	89 e5                	mov    %esp,%ebp
8010360c:	57                   	push   %edi
8010360d:	56                   	push   %esi
8010360e:	53                   	push   %ebx
8010360f:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103612:	e8 7a fe ff ff       	call   80103491 <myproc>
80103617:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103619:	e8 d8 fc ff ff       	call   801032f6 <allocproc>
8010361e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103621:	85 c0                	test   %eax,%eax
80103623:	0f 84 e3 00 00 00    	je     8010370c <fork+0x103>
80103629:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, np->pid)) == 0){
8010362b:	83 ec 04             	sub    $0x4,%esp
8010362e:	ff 70 10             	pushl  0x10(%eax)
80103631:	ff 33                	pushl  (%ebx)
80103633:	ff 73 04             	pushl  0x4(%ebx)
80103636:	e8 6d 2f 00 00       	call   801065a8 <copyuvm>
8010363b:	89 47 04             	mov    %eax,0x4(%edi)
8010363e:	83 c4 10             	add    $0x10,%esp
80103641:	85 c0                	test   %eax,%eax
80103643:	74 2a                	je     8010366f <fork+0x66>
  np->sz = curproc->sz;
80103645:	8b 03                	mov    (%ebx),%eax
80103647:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010364a:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010364c:	89 c8                	mov    %ecx,%eax
8010364e:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103651:	8b 73 18             	mov    0x18(%ebx),%esi
80103654:	8b 79 18             	mov    0x18(%ecx),%edi
80103657:	b9 13 00 00 00       	mov    $0x13,%ecx
8010365c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010365e:	8b 40 18             	mov    0x18(%eax),%eax
80103661:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103668:	be 00 00 00 00       	mov    $0x0,%esi
8010366d:	eb 29                	jmp    80103698 <fork+0x8f>
    kfree(np->kstack);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103675:	ff 73 08             	pushl  0x8(%ebx)
80103678:	e8 93 ea ff ff       	call   80102110 <kfree>
    np->kstack = 0;
8010367d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103684:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010368b:	83 c4 10             	add    $0x10,%esp
8010368e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103693:	eb 6d                	jmp    80103702 <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
80103695:	83 c6 01             	add    $0x1,%esi
80103698:	83 fe 0f             	cmp    $0xf,%esi
8010369b:	7f 1d                	jg     801036ba <fork+0xb1>
    if(curproc->ofile[i])
8010369d:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801036a1:	85 c0                	test   %eax,%eax
801036a3:	74 f0                	je     80103695 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801036a5:	83 ec 0c             	sub    $0xc,%esp
801036a8:	50                   	push   %eax
801036a9:	e8 ec d5 ff ff       	call   80100c9a <filedup>
801036ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801036b1:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801036b5:	83 c4 10             	add    $0x10,%esp
801036b8:	eb db                	jmp    80103695 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
801036ba:	83 ec 0c             	sub    $0xc,%esp
801036bd:	ff 73 68             	pushl  0x68(%ebx)
801036c0:	e8 98 de ff ff       	call   8010155d <idup>
801036c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801036c8:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801036cb:	83 c3 6c             	add    $0x6c,%ebx
801036ce:	8d 47 6c             	lea    0x6c(%edi),%eax
801036d1:	83 c4 0c             	add    $0xc,%esp
801036d4:	6a 10                	push   $0x10
801036d6:	53                   	push   %ebx
801036d7:	50                   	push   %eax
801036d8:	e8 69 09 00 00       	call   80104046 <safestrcpy>
  pid = np->pid;
801036dd:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801036e0:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
801036e7:	e8 47 07 00 00       	call   80103e33 <acquire>
  np->state = RUNNABLE;
801036ec:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801036f3:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
801036fa:	e8 99 07 00 00       	call   80103e98 <release>
  return pid;
801036ff:	83 c4 10             	add    $0x10,%esp
}
80103702:	89 d8                	mov    %ebx,%eax
80103704:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103707:	5b                   	pop    %ebx
80103708:	5e                   	pop    %esi
80103709:	5f                   	pop    %edi
8010370a:	5d                   	pop    %ebp
8010370b:	c3                   	ret    
    return -1;
8010370c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103711:	eb ef                	jmp    80103702 <fork+0xf9>

80103713 <scheduler>:
{
80103713:	55                   	push   %ebp
80103714:	89 e5                	mov    %esp,%ebp
80103716:	56                   	push   %esi
80103717:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103718:	e8 fd fc ff ff       	call   8010341a <mycpu>
8010371d:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010371f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103726:	00 00 00 
80103729:	eb 5a                	jmp    80103785 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010372b:	83 c3 7c             	add    $0x7c,%ebx
8010372e:	81 fb 74 4c 13 80    	cmp    $0x80134c74,%ebx
80103734:	73 3f                	jae    80103775 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103736:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010373a:	75 ef                	jne    8010372b <scheduler+0x18>
      c->proc = p;
8010373c:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103742:	83 ec 0c             	sub    $0xc,%esp
80103745:	53                   	push   %ebx
80103746:	e8 89 29 00 00       	call   801060d4 <switchuvm>
      p->state = RUNNING;
8010374b:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103752:	83 c4 08             	add    $0x8,%esp
80103755:	ff 73 1c             	pushl  0x1c(%ebx)
80103758:	8d 46 04             	lea    0x4(%esi),%eax
8010375b:	50                   	push   %eax
8010375c:	e8 38 09 00 00       	call   80104099 <swtch>
      switchkvm();
80103761:	e8 5c 29 00 00       	call   801060c2 <switchkvm>
      c->proc = 0;
80103766:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010376d:	00 00 00 
80103770:	83 c4 10             	add    $0x10,%esp
80103773:	eb b6                	jmp    8010372b <scheduler+0x18>
    release(&ptable.lock);
80103775:	83 ec 0c             	sub    $0xc,%esp
80103778:	68 40 2d 13 80       	push   $0x80132d40
8010377d:	e8 16 07 00 00       	call   80103e98 <release>
    sti();
80103782:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103785:	fb                   	sti    
    acquire(&ptable.lock);
80103786:	83 ec 0c             	sub    $0xc,%esp
80103789:	68 40 2d 13 80       	push   $0x80132d40
8010378e:	e8 a0 06 00 00       	call   80103e33 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103793:	83 c4 10             	add    $0x10,%esp
80103796:	bb 74 2d 13 80       	mov    $0x80132d74,%ebx
8010379b:	eb 91                	jmp    8010372e <scheduler+0x1b>

8010379d <sched>:
{
8010379d:	55                   	push   %ebp
8010379e:	89 e5                	mov    %esp,%ebp
801037a0:	56                   	push   %esi
801037a1:	53                   	push   %ebx
  struct proc *p = myproc();
801037a2:	e8 ea fc ff ff       	call   80103491 <myproc>
801037a7:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801037a9:	83 ec 0c             	sub    $0xc,%esp
801037ac:	68 40 2d 13 80       	push   $0x80132d40
801037b1:	e8 3d 06 00 00       	call   80103df3 <holding>
801037b6:	83 c4 10             	add    $0x10,%esp
801037b9:	85 c0                	test   %eax,%eax
801037bb:	74 4f                	je     8010380c <sched+0x6f>
  if(mycpu()->ncli != 1)
801037bd:	e8 58 fc ff ff       	call   8010341a <mycpu>
801037c2:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801037c9:	75 4e                	jne    80103819 <sched+0x7c>
  if(p->state == RUNNING)
801037cb:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801037cf:	74 55                	je     80103826 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801037d1:	9c                   	pushf  
801037d2:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801037d3:	f6 c4 02             	test   $0x2,%ah
801037d6:	75 5b                	jne    80103833 <sched+0x96>
  intena = mycpu()->intena;
801037d8:	e8 3d fc ff ff       	call   8010341a <mycpu>
801037dd:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801037e3:	e8 32 fc ff ff       	call   8010341a <mycpu>
801037e8:	83 ec 08             	sub    $0x8,%esp
801037eb:	ff 70 04             	pushl  0x4(%eax)
801037ee:	83 c3 1c             	add    $0x1c,%ebx
801037f1:	53                   	push   %ebx
801037f2:	e8 a2 08 00 00       	call   80104099 <swtch>
  mycpu()->intena = intena;
801037f7:	e8 1e fc ff ff       	call   8010341a <mycpu>
801037fc:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103802:	83 c4 10             	add    $0x10,%esp
80103805:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103808:	5b                   	pop    %ebx
80103809:	5e                   	pop    %esi
8010380a:	5d                   	pop    %ebp
8010380b:	c3                   	ret    
    panic("sched ptable.lock");
8010380c:	83 ec 0c             	sub    $0xc,%esp
8010380f:	68 f0 6c 10 80       	push   $0x80106cf0
80103814:	e8 2f cb ff ff       	call   80100348 <panic>
    panic("sched locks");
80103819:	83 ec 0c             	sub    $0xc,%esp
8010381c:	68 02 6d 10 80       	push   $0x80106d02
80103821:	e8 22 cb ff ff       	call   80100348 <panic>
    panic("sched running");
80103826:	83 ec 0c             	sub    $0xc,%esp
80103829:	68 0e 6d 10 80       	push   $0x80106d0e
8010382e:	e8 15 cb ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103833:	83 ec 0c             	sub    $0xc,%esp
80103836:	68 1c 6d 10 80       	push   $0x80106d1c
8010383b:	e8 08 cb ff ff       	call   80100348 <panic>

80103840 <exit>:
{
80103840:	55                   	push   %ebp
80103841:	89 e5                	mov    %esp,%ebp
80103843:	56                   	push   %esi
80103844:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103845:	e8 47 fc ff ff       	call   80103491 <myproc>
  if(curproc == initproc)
8010384a:	39 05 c0 a5 12 80    	cmp    %eax,0x8012a5c0
80103850:	74 09                	je     8010385b <exit+0x1b>
80103852:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103854:	bb 00 00 00 00       	mov    $0x0,%ebx
80103859:	eb 10                	jmp    8010386b <exit+0x2b>
    panic("init exiting");
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 30 6d 10 80       	push   $0x80106d30
80103863:	e8 e0 ca ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103868:	83 c3 01             	add    $0x1,%ebx
8010386b:	83 fb 0f             	cmp    $0xf,%ebx
8010386e:	7f 1e                	jg     8010388e <exit+0x4e>
    if(curproc->ofile[fd]){
80103870:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103874:	85 c0                	test   %eax,%eax
80103876:	74 f0                	je     80103868 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103878:	83 ec 0c             	sub    $0xc,%esp
8010387b:	50                   	push   %eax
8010387c:	e8 5e d4 ff ff       	call   80100cdf <fileclose>
      curproc->ofile[fd] = 0;
80103881:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103888:	00 
80103889:	83 c4 10             	add    $0x10,%esp
8010388c:	eb da                	jmp    80103868 <exit+0x28>
  begin_op();
8010388e:	e8 a3 f1 ff ff       	call   80102a36 <begin_op>
  iput(curproc->cwd);
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	ff 76 68             	pushl  0x68(%esi)
80103899:	e8 f6 dd ff ff       	call   80101694 <iput>
  end_op();
8010389e:	e8 0d f2 ff ff       	call   80102ab0 <end_op>
  curproc->cwd = 0;
801038a3:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801038aa:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
801038b1:	e8 7d 05 00 00       	call   80103e33 <acquire>
  wakeup1(curproc->parent);
801038b6:	8b 46 14             	mov    0x14(%esi),%eax
801038b9:	e8 0d fa ff ff       	call   801032cb <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038be:	83 c4 10             	add    $0x10,%esp
801038c1:	bb 74 2d 13 80       	mov    $0x80132d74,%ebx
801038c6:	eb 03                	jmp    801038cb <exit+0x8b>
801038c8:	83 c3 7c             	add    $0x7c,%ebx
801038cb:	81 fb 74 4c 13 80    	cmp    $0x80134c74,%ebx
801038d1:	73 1a                	jae    801038ed <exit+0xad>
    if(p->parent == curproc){
801038d3:	39 73 14             	cmp    %esi,0x14(%ebx)
801038d6:	75 f0                	jne    801038c8 <exit+0x88>
      p->parent = initproc;
801038d8:	a1 c0 a5 12 80       	mov    0x8012a5c0,%eax
801038dd:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801038e0:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801038e4:	75 e2                	jne    801038c8 <exit+0x88>
        wakeup1(initproc);
801038e6:	e8 e0 f9 ff ff       	call   801032cb <wakeup1>
801038eb:	eb db                	jmp    801038c8 <exit+0x88>
  curproc->state = ZOMBIE;
801038ed:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801038f4:	e8 a4 fe ff ff       	call   8010379d <sched>
  panic("zombie exit");
801038f9:	83 ec 0c             	sub    $0xc,%esp
801038fc:	68 3d 6d 10 80       	push   $0x80106d3d
80103901:	e8 42 ca ff ff       	call   80100348 <panic>

80103906 <yield>:
{
80103906:	55                   	push   %ebp
80103907:	89 e5                	mov    %esp,%ebp
80103909:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010390c:	68 40 2d 13 80       	push   $0x80132d40
80103911:	e8 1d 05 00 00       	call   80103e33 <acquire>
  myproc()->state = RUNNABLE;
80103916:	e8 76 fb ff ff       	call   80103491 <myproc>
8010391b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103922:	e8 76 fe ff ff       	call   8010379d <sched>
  release(&ptable.lock);
80103927:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
8010392e:	e8 65 05 00 00       	call   80103e98 <release>
}
80103933:	83 c4 10             	add    $0x10,%esp
80103936:	c9                   	leave  
80103937:	c3                   	ret    

80103938 <sleep>:
{
80103938:	55                   	push   %ebp
80103939:	89 e5                	mov    %esp,%ebp
8010393b:	56                   	push   %esi
8010393c:	53                   	push   %ebx
8010393d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103940:	e8 4c fb ff ff       	call   80103491 <myproc>
  if(p == 0)
80103945:	85 c0                	test   %eax,%eax
80103947:	74 66                	je     801039af <sleep+0x77>
80103949:	89 c6                	mov    %eax,%esi
  if(lk == 0)
8010394b:	85 db                	test   %ebx,%ebx
8010394d:	74 6d                	je     801039bc <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010394f:	81 fb 40 2d 13 80    	cmp    $0x80132d40,%ebx
80103955:	74 18                	je     8010396f <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	68 40 2d 13 80       	push   $0x80132d40
8010395f:	e8 cf 04 00 00       	call   80103e33 <acquire>
    release(lk);
80103964:	89 1c 24             	mov    %ebx,(%esp)
80103967:	e8 2c 05 00 00       	call   80103e98 <release>
8010396c:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010396f:	8b 45 08             	mov    0x8(%ebp),%eax
80103972:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103975:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010397c:	e8 1c fe ff ff       	call   8010379d <sched>
  p->chan = 0;
80103981:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103988:	81 fb 40 2d 13 80    	cmp    $0x80132d40,%ebx
8010398e:	74 18                	je     801039a8 <sleep+0x70>
    release(&ptable.lock);
80103990:	83 ec 0c             	sub    $0xc,%esp
80103993:	68 40 2d 13 80       	push   $0x80132d40
80103998:	e8 fb 04 00 00       	call   80103e98 <release>
    acquire(lk);
8010399d:	89 1c 24             	mov    %ebx,(%esp)
801039a0:	e8 8e 04 00 00       	call   80103e33 <acquire>
801039a5:	83 c4 10             	add    $0x10,%esp
}
801039a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039ab:	5b                   	pop    %ebx
801039ac:	5e                   	pop    %esi
801039ad:	5d                   	pop    %ebp
801039ae:	c3                   	ret    
    panic("sleep");
801039af:	83 ec 0c             	sub    $0xc,%esp
801039b2:	68 49 6d 10 80       	push   $0x80106d49
801039b7:	e8 8c c9 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801039bc:	83 ec 0c             	sub    $0xc,%esp
801039bf:	68 4f 6d 10 80       	push   $0x80106d4f
801039c4:	e8 7f c9 ff ff       	call   80100348 <panic>

801039c9 <wait>:
{
801039c9:	55                   	push   %ebp
801039ca:	89 e5                	mov    %esp,%ebp
801039cc:	56                   	push   %esi
801039cd:	53                   	push   %ebx
  struct proc *curproc = myproc();
801039ce:	e8 be fa ff ff       	call   80103491 <myproc>
801039d3:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801039d5:	83 ec 0c             	sub    $0xc,%esp
801039d8:	68 40 2d 13 80       	push   $0x80132d40
801039dd:	e8 51 04 00 00       	call   80103e33 <acquire>
801039e2:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801039e5:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ea:	bb 74 2d 13 80       	mov    $0x80132d74,%ebx
801039ef:	eb 5b                	jmp    80103a4c <wait+0x83>
        pid = p->pid;
801039f1:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801039f4:	83 ec 0c             	sub    $0xc,%esp
801039f7:	ff 73 08             	pushl  0x8(%ebx)
801039fa:	e8 11 e7 ff ff       	call   80102110 <kfree>
        p->kstack = 0;
801039ff:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103a06:	83 c4 04             	add    $0x4,%esp
80103a09:	ff 73 04             	pushl  0x4(%ebx)
80103a0c:	e8 6e 2a 00 00       	call   8010647f <freevm>
        p->pid = 0;
80103a11:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103a18:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103a1f:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103a23:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103a2a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103a31:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
80103a38:	e8 5b 04 00 00       	call   80103e98 <release>
        return pid;
80103a3d:	83 c4 10             	add    $0x10,%esp
}
80103a40:	89 f0                	mov    %esi,%eax
80103a42:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a45:	5b                   	pop    %ebx
80103a46:	5e                   	pop    %esi
80103a47:	5d                   	pop    %ebp
80103a48:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a49:	83 c3 7c             	add    $0x7c,%ebx
80103a4c:	81 fb 74 4c 13 80    	cmp    $0x80134c74,%ebx
80103a52:	73 12                	jae    80103a66 <wait+0x9d>
      if(p->parent != curproc)
80103a54:	39 73 14             	cmp    %esi,0x14(%ebx)
80103a57:	75 f0                	jne    80103a49 <wait+0x80>
      if(p->state == ZOMBIE){
80103a59:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103a5d:	74 92                	je     801039f1 <wait+0x28>
      havekids = 1;
80103a5f:	b8 01 00 00 00       	mov    $0x1,%eax
80103a64:	eb e3                	jmp    80103a49 <wait+0x80>
    if(!havekids || curproc->killed){
80103a66:	85 c0                	test   %eax,%eax
80103a68:	74 06                	je     80103a70 <wait+0xa7>
80103a6a:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103a6e:	74 17                	je     80103a87 <wait+0xbe>
      release(&ptable.lock);
80103a70:	83 ec 0c             	sub    $0xc,%esp
80103a73:	68 40 2d 13 80       	push   $0x80132d40
80103a78:	e8 1b 04 00 00       	call   80103e98 <release>
      return -1;
80103a7d:	83 c4 10             	add    $0x10,%esp
80103a80:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103a85:	eb b9                	jmp    80103a40 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103a87:	83 ec 08             	sub    $0x8,%esp
80103a8a:	68 40 2d 13 80       	push   $0x80132d40
80103a8f:	56                   	push   %esi
80103a90:	e8 a3 fe ff ff       	call   80103938 <sleep>
    havekids = 0;
80103a95:	83 c4 10             	add    $0x10,%esp
80103a98:	e9 48 ff ff ff       	jmp    801039e5 <wait+0x1c>

80103a9d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103a9d:	55                   	push   %ebp
80103a9e:	89 e5                	mov    %esp,%ebp
80103aa0:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103aa3:	68 40 2d 13 80       	push   $0x80132d40
80103aa8:	e8 86 03 00 00       	call   80103e33 <acquire>
  wakeup1(chan);
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	e8 16 f8 ff ff       	call   801032cb <wakeup1>
  release(&ptable.lock);
80103ab5:	c7 04 24 40 2d 13 80 	movl   $0x80132d40,(%esp)
80103abc:	e8 d7 03 00 00       	call   80103e98 <release>
}
80103ac1:	83 c4 10             	add    $0x10,%esp
80103ac4:	c9                   	leave  
80103ac5:	c3                   	ret    

80103ac6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103ac6:	55                   	push   %ebp
80103ac7:	89 e5                	mov    %esp,%ebp
80103ac9:	53                   	push   %ebx
80103aca:	83 ec 10             	sub    $0x10,%esp
80103acd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103ad0:	68 40 2d 13 80       	push   $0x80132d40
80103ad5:	e8 59 03 00 00       	call   80103e33 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ada:	83 c4 10             	add    $0x10,%esp
80103add:	b8 74 2d 13 80       	mov    $0x80132d74,%eax
80103ae2:	3d 74 4c 13 80       	cmp    $0x80134c74,%eax
80103ae7:	73 3a                	jae    80103b23 <kill+0x5d>
    if(p->pid == pid){
80103ae9:	39 58 10             	cmp    %ebx,0x10(%eax)
80103aec:	74 05                	je     80103af3 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103aee:	83 c0 7c             	add    $0x7c,%eax
80103af1:	eb ef                	jmp    80103ae2 <kill+0x1c>
      p->killed = 1;
80103af3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103afa:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103afe:	74 1a                	je     80103b1a <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103b00:	83 ec 0c             	sub    $0xc,%esp
80103b03:	68 40 2d 13 80       	push   $0x80132d40
80103b08:	e8 8b 03 00 00       	call   80103e98 <release>
      return 0;
80103b0d:	83 c4 10             	add    $0x10,%esp
80103b10:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103b15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b18:	c9                   	leave  
80103b19:	c3                   	ret    
        p->state = RUNNABLE;
80103b1a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103b21:	eb dd                	jmp    80103b00 <kill+0x3a>
  release(&ptable.lock);
80103b23:	83 ec 0c             	sub    $0xc,%esp
80103b26:	68 40 2d 13 80       	push   $0x80132d40
80103b2b:	e8 68 03 00 00       	call   80103e98 <release>
  return -1;
80103b30:	83 c4 10             	add    $0x10,%esp
80103b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b38:	eb db                	jmp    80103b15 <kill+0x4f>

80103b3a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103b3a:	55                   	push   %ebp
80103b3b:	89 e5                	mov    %esp,%ebp
80103b3d:	56                   	push   %esi
80103b3e:	53                   	push   %ebx
80103b3f:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b42:	bb 74 2d 13 80       	mov    $0x80132d74,%ebx
80103b47:	eb 33                	jmp    80103b7c <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103b49:	b8 60 6d 10 80       	mov    $0x80106d60,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103b4e:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103b51:	52                   	push   %edx
80103b52:	50                   	push   %eax
80103b53:	ff 73 10             	pushl  0x10(%ebx)
80103b56:	68 64 6d 10 80       	push   $0x80106d64
80103b5b:	e8 ab ca ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103b60:	83 c4 10             	add    $0x10,%esp
80103b63:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103b67:	74 39                	je     80103ba2 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103b69:	83 ec 0c             	sub    $0xc,%esp
80103b6c:	68 db 70 10 80       	push   $0x801070db
80103b71:	e8 95 ca ff ff       	call   8010060b <cprintf>
80103b76:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b79:	83 c3 7c             	add    $0x7c,%ebx
80103b7c:	81 fb 74 4c 13 80    	cmp    $0x80134c74,%ebx
80103b82:	73 61                	jae    80103be5 <procdump+0xab>
    if(p->state == UNUSED)
80103b84:	8b 43 0c             	mov    0xc(%ebx),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	74 ee                	je     80103b79 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103b8b:	83 f8 05             	cmp    $0x5,%eax
80103b8e:	77 b9                	ja     80103b49 <procdump+0xf>
80103b90:	8b 04 85 c0 6d 10 80 	mov    -0x7fef9240(,%eax,4),%eax
80103b97:	85 c0                	test   %eax,%eax
80103b99:	75 b3                	jne    80103b4e <procdump+0x14>
      state = "???";
80103b9b:	b8 60 6d 10 80       	mov    $0x80106d60,%eax
80103ba0:	eb ac                	jmp    80103b4e <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103ba2:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ba5:	8b 40 0c             	mov    0xc(%eax),%eax
80103ba8:	83 c0 08             	add    $0x8,%eax
80103bab:	83 ec 08             	sub    $0x8,%esp
80103bae:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103bb1:	52                   	push   %edx
80103bb2:	50                   	push   %eax
80103bb3:	e8 5a 01 00 00       	call   80103d12 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103bb8:	83 c4 10             	add    $0x10,%esp
80103bbb:	be 00 00 00 00       	mov    $0x0,%esi
80103bc0:	eb 14                	jmp    80103bd6 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103bc2:	83 ec 08             	sub    $0x8,%esp
80103bc5:	50                   	push   %eax
80103bc6:	68 a1 67 10 80       	push   $0x801067a1
80103bcb:	e8 3b ca ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103bd0:	83 c6 01             	add    $0x1,%esi
80103bd3:	83 c4 10             	add    $0x10,%esp
80103bd6:	83 fe 09             	cmp    $0x9,%esi
80103bd9:	7f 8e                	jg     80103b69 <procdump+0x2f>
80103bdb:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103bdf:	85 c0                	test   %eax,%eax
80103be1:	75 df                	jne    80103bc2 <procdump+0x88>
80103be3:	eb 84                	jmp    80103b69 <procdump+0x2f>
  }
}
80103be5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103be8:	5b                   	pop    %ebx
80103be9:	5e                   	pop    %esi
80103bea:	5d                   	pop    %ebp
80103beb:	c3                   	ret    

80103bec <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103bec:	55                   	push   %ebp
80103bed:	89 e5                	mov    %esp,%ebp
80103bef:	53                   	push   %ebx
80103bf0:	83 ec 0c             	sub    $0xc,%esp
80103bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103bf6:	68 d8 6d 10 80       	push   $0x80106dd8
80103bfb:	8d 43 04             	lea    0x4(%ebx),%eax
80103bfe:	50                   	push   %eax
80103bff:	e8 f3 00 00 00       	call   80103cf7 <initlock>
  lk->name = name;
80103c04:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c07:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103c0a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c10:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103c17:	83 c4 10             	add    $0x10,%esp
80103c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c1d:	c9                   	leave  
80103c1e:	c3                   	ret    

80103c1f <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103c1f:	55                   	push   %ebp
80103c20:	89 e5                	mov    %esp,%ebp
80103c22:	56                   	push   %esi
80103c23:	53                   	push   %ebx
80103c24:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c27:	8d 73 04             	lea    0x4(%ebx),%esi
80103c2a:	83 ec 0c             	sub    $0xc,%esp
80103c2d:	56                   	push   %esi
80103c2e:	e8 00 02 00 00       	call   80103e33 <acquire>
  while (lk->locked) {
80103c33:	83 c4 10             	add    $0x10,%esp
80103c36:	eb 0d                	jmp    80103c45 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103c38:	83 ec 08             	sub    $0x8,%esp
80103c3b:	56                   	push   %esi
80103c3c:	53                   	push   %ebx
80103c3d:	e8 f6 fc ff ff       	call   80103938 <sleep>
80103c42:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103c45:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c48:	75 ee                	jne    80103c38 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103c4a:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c50:	e8 3c f8 ff ff       	call   80103491 <myproc>
80103c55:	8b 40 10             	mov    0x10(%eax),%eax
80103c58:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c5b:	83 ec 0c             	sub    $0xc,%esp
80103c5e:	56                   	push   %esi
80103c5f:	e8 34 02 00 00       	call   80103e98 <release>
}
80103c64:	83 c4 10             	add    $0x10,%esp
80103c67:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c6a:	5b                   	pop    %ebx
80103c6b:	5e                   	pop    %esi
80103c6c:	5d                   	pop    %ebp
80103c6d:	c3                   	ret    

80103c6e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103c6e:	55                   	push   %ebp
80103c6f:	89 e5                	mov    %esp,%ebp
80103c71:	56                   	push   %esi
80103c72:	53                   	push   %ebx
80103c73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c76:	8d 73 04             	lea    0x4(%ebx),%esi
80103c79:	83 ec 0c             	sub    $0xc,%esp
80103c7c:	56                   	push   %esi
80103c7d:	e8 b1 01 00 00       	call   80103e33 <acquire>
  lk->locked = 0;
80103c82:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c88:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103c8f:	89 1c 24             	mov    %ebx,(%esp)
80103c92:	e8 06 fe ff ff       	call   80103a9d <wakeup>
  release(&lk->lk);
80103c97:	89 34 24             	mov    %esi,(%esp)
80103c9a:	e8 f9 01 00 00       	call   80103e98 <release>
}
80103c9f:	83 c4 10             	add    $0x10,%esp
80103ca2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ca5:	5b                   	pop    %ebx
80103ca6:	5e                   	pop    %esi
80103ca7:	5d                   	pop    %ebp
80103ca8:	c3                   	ret    

80103ca9 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ca9:	55                   	push   %ebp
80103caa:	89 e5                	mov    %esp,%ebp
80103cac:	56                   	push   %esi
80103cad:	53                   	push   %ebx
80103cae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103cb1:	8d 73 04             	lea    0x4(%ebx),%esi
80103cb4:	83 ec 0c             	sub    $0xc,%esp
80103cb7:	56                   	push   %esi
80103cb8:	e8 76 01 00 00       	call   80103e33 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103cbd:	83 c4 10             	add    $0x10,%esp
80103cc0:	83 3b 00             	cmpl   $0x0,(%ebx)
80103cc3:	75 17                	jne    80103cdc <holdingsleep+0x33>
80103cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103cca:	83 ec 0c             	sub    $0xc,%esp
80103ccd:	56                   	push   %esi
80103cce:	e8 c5 01 00 00       	call   80103e98 <release>
  return r;
}
80103cd3:	89 d8                	mov    %ebx,%eax
80103cd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cd8:	5b                   	pop    %ebx
80103cd9:	5e                   	pop    %esi
80103cda:	5d                   	pop    %ebp
80103cdb:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103cdc:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103cdf:	e8 ad f7 ff ff       	call   80103491 <myproc>
80103ce4:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ce7:	74 07                	je     80103cf0 <holdingsleep+0x47>
80103ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cee:	eb da                	jmp    80103cca <holdingsleep+0x21>
80103cf0:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cf5:	eb d3                	jmp    80103cca <holdingsleep+0x21>

80103cf7 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103cf7:	55                   	push   %ebp
80103cf8:	89 e5                	mov    %esp,%ebp
80103cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d00:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103d03:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103d09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103d10:	5d                   	pop    %ebp
80103d11:	c3                   	ret    

80103d12 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103d12:	55                   	push   %ebp
80103d13:	89 e5                	mov    %esp,%ebp
80103d15:	53                   	push   %ebx
80103d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103d19:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1c:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103d1f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d24:	83 f8 09             	cmp    $0x9,%eax
80103d27:	7f 25                	jg     80103d4e <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d29:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d2f:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d35:	77 17                	ja     80103d4e <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d37:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d3a:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d3d:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d3f:	83 c0 01             	add    $0x1,%eax
80103d42:	eb e0                	jmp    80103d24 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d44:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d4b:	83 c0 01             	add    $0x1,%eax
80103d4e:	83 f8 09             	cmp    $0x9,%eax
80103d51:	7e f1                	jle    80103d44 <getcallerpcs+0x32>
}
80103d53:	5b                   	pop    %ebx
80103d54:	5d                   	pop    %ebp
80103d55:	c3                   	ret    

80103d56 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d56:	55                   	push   %ebp
80103d57:	89 e5                	mov    %esp,%ebp
80103d59:	53                   	push   %ebx
80103d5a:	83 ec 04             	sub    $0x4,%esp
80103d5d:	9c                   	pushf  
80103d5e:	5b                   	pop    %ebx
  asm volatile("cli");
80103d5f:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d60:	e8 b5 f6 ff ff       	call   8010341a <mycpu>
80103d65:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d6c:	74 12                	je     80103d80 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103d6e:	e8 a7 f6 ff ff       	call   8010341a <mycpu>
80103d73:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103d7a:	83 c4 04             	add    $0x4,%esp
80103d7d:	5b                   	pop    %ebx
80103d7e:	5d                   	pop    %ebp
80103d7f:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103d80:	e8 95 f6 ff ff       	call   8010341a <mycpu>
80103d85:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d8b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103d91:	eb db                	jmp    80103d6e <pushcli+0x18>

80103d93 <popcli>:

void
popcli(void)
{
80103d93:	55                   	push   %ebp
80103d94:	89 e5                	mov    %esp,%ebp
80103d96:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d99:	9c                   	pushf  
80103d9a:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d9b:	f6 c4 02             	test   $0x2,%ah
80103d9e:	75 28                	jne    80103dc8 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103da0:	e8 75 f6 ff ff       	call   8010341a <mycpu>
80103da5:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103dab:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103dae:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103db4:	85 d2                	test   %edx,%edx
80103db6:	78 1d                	js     80103dd5 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103db8:	e8 5d f6 ff ff       	call   8010341a <mycpu>
80103dbd:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103dc4:	74 1c                	je     80103de2 <popcli+0x4f>
    sti();
}
80103dc6:	c9                   	leave  
80103dc7:	c3                   	ret    
    panic("popcli - interruptible");
80103dc8:	83 ec 0c             	sub    $0xc,%esp
80103dcb:	68 e3 6d 10 80       	push   $0x80106de3
80103dd0:	e8 73 c5 ff ff       	call   80100348 <panic>
    panic("popcli");
80103dd5:	83 ec 0c             	sub    $0xc,%esp
80103dd8:	68 fa 6d 10 80       	push   $0x80106dfa
80103ddd:	e8 66 c5 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103de2:	e8 33 f6 ff ff       	call   8010341a <mycpu>
80103de7:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103dee:	74 d6                	je     80103dc6 <popcli+0x33>
  asm volatile("sti");
80103df0:	fb                   	sti    
}
80103df1:	eb d3                	jmp    80103dc6 <popcli+0x33>

80103df3 <holding>:
{
80103df3:	55                   	push   %ebp
80103df4:	89 e5                	mov    %esp,%ebp
80103df6:	53                   	push   %ebx
80103df7:	83 ec 04             	sub    $0x4,%esp
80103dfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103dfd:	e8 54 ff ff ff       	call   80103d56 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103e02:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e05:	75 12                	jne    80103e19 <holding+0x26>
80103e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103e0c:	e8 82 ff ff ff       	call   80103d93 <popcli>
}
80103e11:	89 d8                	mov    %ebx,%eax
80103e13:	83 c4 04             	add    $0x4,%esp
80103e16:	5b                   	pop    %ebx
80103e17:	5d                   	pop    %ebp
80103e18:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103e19:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103e1c:	e8 f9 f5 ff ff       	call   8010341a <mycpu>
80103e21:	39 c3                	cmp    %eax,%ebx
80103e23:	74 07                	je     80103e2c <holding+0x39>
80103e25:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e2a:	eb e0                	jmp    80103e0c <holding+0x19>
80103e2c:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e31:	eb d9                	jmp    80103e0c <holding+0x19>

80103e33 <acquire>:
{
80103e33:	55                   	push   %ebp
80103e34:	89 e5                	mov    %esp,%ebp
80103e36:	53                   	push   %ebx
80103e37:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e3a:	e8 17 ff ff ff       	call   80103d56 <pushcli>
  if(holding(lk))
80103e3f:	83 ec 0c             	sub    $0xc,%esp
80103e42:	ff 75 08             	pushl  0x8(%ebp)
80103e45:	e8 a9 ff ff ff       	call   80103df3 <holding>
80103e4a:	83 c4 10             	add    $0x10,%esp
80103e4d:	85 c0                	test   %eax,%eax
80103e4f:	75 3a                	jne    80103e8b <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103e51:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103e54:	b8 01 00 00 00       	mov    $0x1,%eax
80103e59:	f0 87 02             	lock xchg %eax,(%edx)
80103e5c:	85 c0                	test   %eax,%eax
80103e5e:	75 f1                	jne    80103e51 <acquire+0x1e>
  __sync_synchronize();
80103e60:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e68:	e8 ad f5 ff ff       	call   8010341a <mycpu>
80103e6d:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e70:	8b 45 08             	mov    0x8(%ebp),%eax
80103e73:	83 c0 0c             	add    $0xc,%eax
80103e76:	83 ec 08             	sub    $0x8,%esp
80103e79:	50                   	push   %eax
80103e7a:	8d 45 08             	lea    0x8(%ebp),%eax
80103e7d:	50                   	push   %eax
80103e7e:	e8 8f fe ff ff       	call   80103d12 <getcallerpcs>
}
80103e83:	83 c4 10             	add    $0x10,%esp
80103e86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e89:	c9                   	leave  
80103e8a:	c3                   	ret    
    panic("acquire");
80103e8b:	83 ec 0c             	sub    $0xc,%esp
80103e8e:	68 01 6e 10 80       	push   $0x80106e01
80103e93:	e8 b0 c4 ff ff       	call   80100348 <panic>

80103e98 <release>:
{
80103e98:	55                   	push   %ebp
80103e99:	89 e5                	mov    %esp,%ebp
80103e9b:	53                   	push   %ebx
80103e9c:	83 ec 10             	sub    $0x10,%esp
80103e9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103ea2:	53                   	push   %ebx
80103ea3:	e8 4b ff ff ff       	call   80103df3 <holding>
80103ea8:	83 c4 10             	add    $0x10,%esp
80103eab:	85 c0                	test   %eax,%eax
80103ead:	74 23                	je     80103ed2 <release+0x3a>
  lk->pcs[0] = 0;
80103eaf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103eb6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103ebd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ec2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103ec8:	e8 c6 fe ff ff       	call   80103d93 <popcli>
}
80103ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ed0:	c9                   	leave  
80103ed1:	c3                   	ret    
    panic("release");
80103ed2:	83 ec 0c             	sub    $0xc,%esp
80103ed5:	68 09 6e 10 80       	push   $0x80106e09
80103eda:	e8 69 c4 ff ff       	call   80100348 <panic>

80103edf <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103edf:	55                   	push   %ebp
80103ee0:	89 e5                	mov    %esp,%ebp
80103ee2:	57                   	push   %edi
80103ee3:	53                   	push   %ebx
80103ee4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103eea:	f6 c2 03             	test   $0x3,%dl
80103eed:	75 05                	jne    80103ef4 <memset+0x15>
80103eef:	f6 c1 03             	test   $0x3,%cl
80103ef2:	74 0e                	je     80103f02 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103ef4:	89 d7                	mov    %edx,%edi
80103ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef9:	fc                   	cld    
80103efa:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103efc:	89 d0                	mov    %edx,%eax
80103efe:	5b                   	pop    %ebx
80103eff:	5f                   	pop    %edi
80103f00:	5d                   	pop    %ebp
80103f01:	c3                   	ret    
    c &= 0xFF;
80103f02:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103f06:	c1 e9 02             	shr    $0x2,%ecx
80103f09:	89 f8                	mov    %edi,%eax
80103f0b:	c1 e0 18             	shl    $0x18,%eax
80103f0e:	89 fb                	mov    %edi,%ebx
80103f10:	c1 e3 10             	shl    $0x10,%ebx
80103f13:	09 d8                	or     %ebx,%eax
80103f15:	89 fb                	mov    %edi,%ebx
80103f17:	c1 e3 08             	shl    $0x8,%ebx
80103f1a:	09 d8                	or     %ebx,%eax
80103f1c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103f1e:	89 d7                	mov    %edx,%edi
80103f20:	fc                   	cld    
80103f21:	f3 ab                	rep stos %eax,%es:(%edi)
80103f23:	eb d7                	jmp    80103efc <memset+0x1d>

80103f25 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103f25:	55                   	push   %ebp
80103f26:	89 e5                	mov    %esp,%ebp
80103f28:	56                   	push   %esi
80103f29:	53                   	push   %ebx
80103f2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f30:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f33:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f36:	85 c0                	test   %eax,%eax
80103f38:	74 1c                	je     80103f56 <memcmp+0x31>
    if(*s1 != *s2)
80103f3a:	0f b6 01             	movzbl (%ecx),%eax
80103f3d:	0f b6 1a             	movzbl (%edx),%ebx
80103f40:	38 d8                	cmp    %bl,%al
80103f42:	75 0a                	jne    80103f4e <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103f44:	83 c1 01             	add    $0x1,%ecx
80103f47:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103f4a:	89 f0                	mov    %esi,%eax
80103f4c:	eb e5                	jmp    80103f33 <memcmp+0xe>
      return *s1 - *s2;
80103f4e:	0f b6 c0             	movzbl %al,%eax
80103f51:	0f b6 db             	movzbl %bl,%ebx
80103f54:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103f56:	5b                   	pop    %ebx
80103f57:	5e                   	pop    %esi
80103f58:	5d                   	pop    %ebp
80103f59:	c3                   	ret    

80103f5a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f5a:	55                   	push   %ebp
80103f5b:	89 e5                	mov    %esp,%ebp
80103f5d:	56                   	push   %esi
80103f5e:	53                   	push   %ebx
80103f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f65:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f68:	39 c1                	cmp    %eax,%ecx
80103f6a:	73 3a                	jae    80103fa6 <memmove+0x4c>
80103f6c:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103f6f:	39 c3                	cmp    %eax,%ebx
80103f71:	76 37                	jbe    80103faa <memmove+0x50>
    s += n;
    d += n;
80103f73:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103f76:	eb 0d                	jmp    80103f85 <memmove+0x2b>
      *--d = *--s;
80103f78:	83 eb 01             	sub    $0x1,%ebx
80103f7b:	83 e9 01             	sub    $0x1,%ecx
80103f7e:	0f b6 13             	movzbl (%ebx),%edx
80103f81:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103f83:	89 f2                	mov    %esi,%edx
80103f85:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f88:	85 d2                	test   %edx,%edx
80103f8a:	75 ec                	jne    80103f78 <memmove+0x1e>
80103f8c:	eb 14                	jmp    80103fa2 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103f8e:	0f b6 11             	movzbl (%ecx),%edx
80103f91:	88 13                	mov    %dl,(%ebx)
80103f93:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103f96:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103f99:	89 f2                	mov    %esi,%edx
80103f9b:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f9e:	85 d2                	test   %edx,%edx
80103fa0:	75 ec                	jne    80103f8e <memmove+0x34>

  return dst;
}
80103fa2:	5b                   	pop    %ebx
80103fa3:	5e                   	pop    %esi
80103fa4:	5d                   	pop    %ebp
80103fa5:	c3                   	ret    
80103fa6:	89 c3                	mov    %eax,%ebx
80103fa8:	eb f1                	jmp    80103f9b <memmove+0x41>
80103faa:	89 c3                	mov    %eax,%ebx
80103fac:	eb ed                	jmp    80103f9b <memmove+0x41>

80103fae <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103fae:	55                   	push   %ebp
80103faf:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103fb1:	ff 75 10             	pushl  0x10(%ebp)
80103fb4:	ff 75 0c             	pushl  0xc(%ebp)
80103fb7:	ff 75 08             	pushl  0x8(%ebp)
80103fba:	e8 9b ff ff ff       	call   80103f5a <memmove>
}
80103fbf:	c9                   	leave  
80103fc0:	c3                   	ret    

80103fc1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103fc1:	55                   	push   %ebp
80103fc2:	89 e5                	mov    %esp,%ebp
80103fc4:	53                   	push   %ebx
80103fc5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fcb:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103fce:	eb 09                	jmp    80103fd9 <strncmp+0x18>
    n--, p++, q++;
80103fd0:	83 e8 01             	sub    $0x1,%eax
80103fd3:	83 c2 01             	add    $0x1,%edx
80103fd6:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103fd9:	85 c0                	test   %eax,%eax
80103fdb:	74 0b                	je     80103fe8 <strncmp+0x27>
80103fdd:	0f b6 1a             	movzbl (%edx),%ebx
80103fe0:	84 db                	test   %bl,%bl
80103fe2:	74 04                	je     80103fe8 <strncmp+0x27>
80103fe4:	3a 19                	cmp    (%ecx),%bl
80103fe6:	74 e8                	je     80103fd0 <strncmp+0xf>
  if(n == 0)
80103fe8:	85 c0                	test   %eax,%eax
80103fea:	74 0b                	je     80103ff7 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103fec:	0f b6 02             	movzbl (%edx),%eax
80103fef:	0f b6 11             	movzbl (%ecx),%edx
80103ff2:	29 d0                	sub    %edx,%eax
}
80103ff4:	5b                   	pop    %ebx
80103ff5:	5d                   	pop    %ebp
80103ff6:	c3                   	ret    
    return 0;
80103ff7:	b8 00 00 00 00       	mov    $0x0,%eax
80103ffc:	eb f6                	jmp    80103ff4 <strncmp+0x33>

80103ffe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103ffe:	55                   	push   %ebp
80103fff:	89 e5                	mov    %esp,%ebp
80104001:	57                   	push   %edi
80104002:	56                   	push   %esi
80104003:	53                   	push   %ebx
80104004:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104007:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010400a:	8b 45 08             	mov    0x8(%ebp),%eax
8010400d:	eb 04                	jmp    80104013 <strncpy+0x15>
8010400f:	89 fb                	mov    %edi,%ebx
80104011:	89 f0                	mov    %esi,%eax
80104013:	8d 51 ff             	lea    -0x1(%ecx),%edx
80104016:	85 c9                	test   %ecx,%ecx
80104018:	7e 1d                	jle    80104037 <strncpy+0x39>
8010401a:	8d 7b 01             	lea    0x1(%ebx),%edi
8010401d:	8d 70 01             	lea    0x1(%eax),%esi
80104020:	0f b6 1b             	movzbl (%ebx),%ebx
80104023:	88 18                	mov    %bl,(%eax)
80104025:	89 d1                	mov    %edx,%ecx
80104027:	84 db                	test   %bl,%bl
80104029:	75 e4                	jne    8010400f <strncpy+0x11>
8010402b:	89 f0                	mov    %esi,%eax
8010402d:	eb 08                	jmp    80104037 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
8010402f:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104032:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104034:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80104037:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010403a:	85 d2                	test   %edx,%edx
8010403c:	7f f1                	jg     8010402f <strncpy+0x31>
  return os;
}
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	5b                   	pop    %ebx
80104042:	5e                   	pop    %esi
80104043:	5f                   	pop    %edi
80104044:	5d                   	pop    %ebp
80104045:	c3                   	ret    

80104046 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104046:	55                   	push   %ebp
80104047:	89 e5                	mov    %esp,%ebp
80104049:	57                   	push   %edi
8010404a:	56                   	push   %esi
8010404b:	53                   	push   %ebx
8010404c:	8b 45 08             	mov    0x8(%ebp),%eax
8010404f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104052:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104055:	85 d2                	test   %edx,%edx
80104057:	7e 23                	jle    8010407c <safestrcpy+0x36>
80104059:	89 c1                	mov    %eax,%ecx
8010405b:	eb 04                	jmp    80104061 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010405d:	89 fb                	mov    %edi,%ebx
8010405f:	89 f1                	mov    %esi,%ecx
80104061:	83 ea 01             	sub    $0x1,%edx
80104064:	85 d2                	test   %edx,%edx
80104066:	7e 11                	jle    80104079 <safestrcpy+0x33>
80104068:	8d 7b 01             	lea    0x1(%ebx),%edi
8010406b:	8d 71 01             	lea    0x1(%ecx),%esi
8010406e:	0f b6 1b             	movzbl (%ebx),%ebx
80104071:	88 19                	mov    %bl,(%ecx)
80104073:	84 db                	test   %bl,%bl
80104075:	75 e6                	jne    8010405d <safestrcpy+0x17>
80104077:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80104079:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
8010407c:	5b                   	pop    %ebx
8010407d:	5e                   	pop    %esi
8010407e:	5f                   	pop    %edi
8010407f:	5d                   	pop    %ebp
80104080:	c3                   	ret    

80104081 <strlen>:

int
strlen(const char *s)
{
80104081:	55                   	push   %ebp
80104082:	89 e5                	mov    %esp,%ebp
80104084:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104087:	b8 00 00 00 00       	mov    $0x0,%eax
8010408c:	eb 03                	jmp    80104091 <strlen+0x10>
8010408e:	83 c0 01             	add    $0x1,%eax
80104091:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104095:	75 f7                	jne    8010408e <strlen+0xd>
    ;
  return n;
}
80104097:	5d                   	pop    %ebp
80104098:	c3                   	ret    

80104099 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104099:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010409d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801040a1:	55                   	push   %ebp
  pushl %ebx
801040a2:	53                   	push   %ebx
  pushl %esi
801040a3:	56                   	push   %esi
  pushl %edi
801040a4:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801040a5:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801040a7:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801040a9:	5f                   	pop    %edi
  popl %esi
801040aa:	5e                   	pop    %esi
  popl %ebx
801040ab:	5b                   	pop    %ebx
  popl %ebp
801040ac:	5d                   	pop    %ebp
  ret
801040ad:	c3                   	ret    

801040ae <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801040ae:	55                   	push   %ebp
801040af:	89 e5                	mov    %esp,%ebp
801040b1:	53                   	push   %ebx
801040b2:	83 ec 04             	sub    $0x4,%esp
801040b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801040b8:	e8 d4 f3 ff ff       	call   80103491 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801040bd:	8b 00                	mov    (%eax),%eax
801040bf:	39 d8                	cmp    %ebx,%eax
801040c1:	76 19                	jbe    801040dc <fetchint+0x2e>
801040c3:	8d 53 04             	lea    0x4(%ebx),%edx
801040c6:	39 d0                	cmp    %edx,%eax
801040c8:	72 19                	jb     801040e3 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801040ca:	8b 13                	mov    (%ebx),%edx
801040cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cf:	89 10                	mov    %edx,(%eax)
  return 0;
801040d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040d6:	83 c4 04             	add    $0x4,%esp
801040d9:	5b                   	pop    %ebx
801040da:	5d                   	pop    %ebp
801040db:	c3                   	ret    
    return -1;
801040dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e1:	eb f3                	jmp    801040d6 <fetchint+0x28>
801040e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e8:	eb ec                	jmp    801040d6 <fetchint+0x28>

801040ea <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801040ea:	55                   	push   %ebp
801040eb:	89 e5                	mov    %esp,%ebp
801040ed:	53                   	push   %ebx
801040ee:	83 ec 04             	sub    $0x4,%esp
801040f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801040f4:	e8 98 f3 ff ff       	call   80103491 <myproc>

  if(addr >= curproc->sz)
801040f9:	39 18                	cmp    %ebx,(%eax)
801040fb:	76 26                	jbe    80104123 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
801040fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80104100:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104102:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104104:	89 d8                	mov    %ebx,%eax
80104106:	39 d0                	cmp    %edx,%eax
80104108:	73 0e                	jae    80104118 <fetchstr+0x2e>
    if(*s == 0)
8010410a:	80 38 00             	cmpb   $0x0,(%eax)
8010410d:	74 05                	je     80104114 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
8010410f:	83 c0 01             	add    $0x1,%eax
80104112:	eb f2                	jmp    80104106 <fetchstr+0x1c>
      return s - *pp;
80104114:	29 d8                	sub    %ebx,%eax
80104116:	eb 05                	jmp    8010411d <fetchstr+0x33>
  }
  return -1;
80104118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010411d:	83 c4 04             	add    $0x4,%esp
80104120:	5b                   	pop    %ebx
80104121:	5d                   	pop    %ebp
80104122:	c3                   	ret    
    return -1;
80104123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104128:	eb f3                	jmp    8010411d <fetchstr+0x33>

8010412a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010412a:	55                   	push   %ebp
8010412b:	89 e5                	mov    %esp,%ebp
8010412d:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104130:	e8 5c f3 ff ff       	call   80103491 <myproc>
80104135:	8b 50 18             	mov    0x18(%eax),%edx
80104138:	8b 45 08             	mov    0x8(%ebp),%eax
8010413b:	c1 e0 02             	shl    $0x2,%eax
8010413e:	03 42 44             	add    0x44(%edx),%eax
80104141:	83 ec 08             	sub    $0x8,%esp
80104144:	ff 75 0c             	pushl  0xc(%ebp)
80104147:	83 c0 04             	add    $0x4,%eax
8010414a:	50                   	push   %eax
8010414b:	e8 5e ff ff ff       	call   801040ae <fetchint>
}
80104150:	c9                   	leave  
80104151:	c3                   	ret    

80104152 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104152:	55                   	push   %ebp
80104153:	89 e5                	mov    %esp,%ebp
80104155:	56                   	push   %esi
80104156:	53                   	push   %ebx
80104157:	83 ec 10             	sub    $0x10,%esp
8010415a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010415d:	e8 2f f3 ff ff       	call   80103491 <myproc>
80104162:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104164:	83 ec 08             	sub    $0x8,%esp
80104167:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010416a:	50                   	push   %eax
8010416b:	ff 75 08             	pushl  0x8(%ebp)
8010416e:	e8 b7 ff ff ff       	call   8010412a <argint>
80104173:	83 c4 10             	add    $0x10,%esp
80104176:	85 c0                	test   %eax,%eax
80104178:	78 24                	js     8010419e <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010417a:	85 db                	test   %ebx,%ebx
8010417c:	78 27                	js     801041a5 <argptr+0x53>
8010417e:	8b 16                	mov    (%esi),%edx
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	39 c2                	cmp    %eax,%edx
80104185:	76 25                	jbe    801041ac <argptr+0x5a>
80104187:	01 c3                	add    %eax,%ebx
80104189:	39 da                	cmp    %ebx,%edx
8010418b:	72 26                	jb     801041b3 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010418d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104190:	89 02                	mov    %eax,(%edx)
  return 0;
80104192:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104197:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010419a:	5b                   	pop    %ebx
8010419b:	5e                   	pop    %esi
8010419c:	5d                   	pop    %ebp
8010419d:	c3                   	ret    
    return -1;
8010419e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041a3:	eb f2                	jmp    80104197 <argptr+0x45>
    return -1;
801041a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041aa:	eb eb                	jmp    80104197 <argptr+0x45>
801041ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b1:	eb e4                	jmp    80104197 <argptr+0x45>
801041b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b8:	eb dd                	jmp    80104197 <argptr+0x45>

801041ba <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801041ba:	55                   	push   %ebp
801041bb:	89 e5                	mov    %esp,%ebp
801041bd:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801041c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041c3:	50                   	push   %eax
801041c4:	ff 75 08             	pushl  0x8(%ebp)
801041c7:	e8 5e ff ff ff       	call   8010412a <argint>
801041cc:	83 c4 10             	add    $0x10,%esp
801041cf:	85 c0                	test   %eax,%eax
801041d1:	78 13                	js     801041e6 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801041d3:	83 ec 08             	sub    $0x8,%esp
801041d6:	ff 75 0c             	pushl  0xc(%ebp)
801041d9:	ff 75 f4             	pushl  -0xc(%ebp)
801041dc:	e8 09 ff ff ff       	call   801040ea <fetchstr>
801041e1:	83 c4 10             	add    $0x10,%esp
}
801041e4:	c9                   	leave  
801041e5:	c3                   	ret    
    return -1;
801041e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041eb:	eb f7                	jmp    801041e4 <argstr+0x2a>

801041ed <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
801041ed:	55                   	push   %ebp
801041ee:	89 e5                	mov    %esp,%ebp
801041f0:	53                   	push   %ebx
801041f1:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801041f4:	e8 98 f2 ff ff       	call   80103491 <myproc>
801041f9:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801041fb:	8b 40 18             	mov    0x18(%eax),%eax
801041fe:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104201:	8d 50 ff             	lea    -0x1(%eax),%edx
80104204:	83 fa 15             	cmp    $0x15,%edx
80104207:	77 18                	ja     80104221 <syscall+0x34>
80104209:	8b 14 85 40 6e 10 80 	mov    -0x7fef91c0(,%eax,4),%edx
80104210:	85 d2                	test   %edx,%edx
80104212:	74 0d                	je     80104221 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104214:	ff d2                	call   *%edx
80104216:	8b 53 18             	mov    0x18(%ebx),%edx
80104219:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010421c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010421f:	c9                   	leave  
80104220:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104221:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104224:	50                   	push   %eax
80104225:	52                   	push   %edx
80104226:	ff 73 10             	pushl  0x10(%ebx)
80104229:	68 11 6e 10 80       	push   $0x80106e11
8010422e:	e8 d8 c3 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104233:	8b 43 18             	mov    0x18(%ebx),%eax
80104236:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010423d:	83 c4 10             	add    $0x10,%esp
}
80104240:	eb da                	jmp    8010421c <syscall+0x2f>

80104242 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104242:	55                   	push   %ebp
80104243:	89 e5                	mov    %esp,%ebp
80104245:	56                   	push   %esi
80104246:	53                   	push   %ebx
80104247:	83 ec 18             	sub    $0x18,%esp
8010424a:	89 d6                	mov    %edx,%esi
8010424c:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010424e:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104251:	52                   	push   %edx
80104252:	50                   	push   %eax
80104253:	e8 d2 fe ff ff       	call   8010412a <argint>
80104258:	83 c4 10             	add    $0x10,%esp
8010425b:	85 c0                	test   %eax,%eax
8010425d:	78 2e                	js     8010428d <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010425f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104263:	77 2f                	ja     80104294 <argfd+0x52>
80104265:	e8 27 f2 ff ff       	call   80103491 <myproc>
8010426a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010426d:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104271:	85 c0                	test   %eax,%eax
80104273:	74 26                	je     8010429b <argfd+0x59>
    return -1;
  if(pfd)
80104275:	85 f6                	test   %esi,%esi
80104277:	74 02                	je     8010427b <argfd+0x39>
    *pfd = fd;
80104279:	89 16                	mov    %edx,(%esi)
  if(pf)
8010427b:	85 db                	test   %ebx,%ebx
8010427d:	74 23                	je     801042a2 <argfd+0x60>
    *pf = f;
8010427f:	89 03                	mov    %eax,(%ebx)
  return 0;
80104281:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104286:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104289:	5b                   	pop    %ebx
8010428a:	5e                   	pop    %esi
8010428b:	5d                   	pop    %ebp
8010428c:	c3                   	ret    
    return -1;
8010428d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104292:	eb f2                	jmp    80104286 <argfd+0x44>
    return -1;
80104294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104299:	eb eb                	jmp    80104286 <argfd+0x44>
8010429b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a0:	eb e4                	jmp    80104286 <argfd+0x44>
  return 0;
801042a2:	b8 00 00 00 00       	mov    $0x0,%eax
801042a7:	eb dd                	jmp    80104286 <argfd+0x44>

801042a9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801042a9:	55                   	push   %ebp
801042aa:	89 e5                	mov    %esp,%ebp
801042ac:	53                   	push   %ebx
801042ad:	83 ec 04             	sub    $0x4,%esp
801042b0:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801042b2:	e8 da f1 ff ff       	call   80103491 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801042b7:	ba 00 00 00 00       	mov    $0x0,%edx
801042bc:	83 fa 0f             	cmp    $0xf,%edx
801042bf:	7f 18                	jg     801042d9 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801042c1:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801042c6:	74 05                	je     801042cd <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801042c8:	83 c2 01             	add    $0x1,%edx
801042cb:	eb ef                	jmp    801042bc <fdalloc+0x13>
      curproc->ofile[fd] = f;
801042cd:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801042d1:	89 d0                	mov    %edx,%eax
801042d3:	83 c4 04             	add    $0x4,%esp
801042d6:	5b                   	pop    %ebx
801042d7:	5d                   	pop    %ebp
801042d8:	c3                   	ret    
  return -1;
801042d9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801042de:	eb f1                	jmp    801042d1 <fdalloc+0x28>

801042e0 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801042e0:	55                   	push   %ebp
801042e1:	89 e5                	mov    %esp,%ebp
801042e3:	56                   	push   %esi
801042e4:	53                   	push   %ebx
801042e5:	83 ec 10             	sub    $0x10,%esp
801042e8:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042ea:	b8 20 00 00 00       	mov    $0x20,%eax
801042ef:	89 c6                	mov    %eax,%esi
801042f1:	39 43 58             	cmp    %eax,0x58(%ebx)
801042f4:	76 2e                	jbe    80104324 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801042f6:	6a 10                	push   $0x10
801042f8:	50                   	push   %eax
801042f9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801042fc:	50                   	push   %eax
801042fd:	53                   	push   %ebx
801042fe:	e8 7c d4 ff ff       	call   8010177f <readi>
80104303:	83 c4 10             	add    $0x10,%esp
80104306:	83 f8 10             	cmp    $0x10,%eax
80104309:	75 0c                	jne    80104317 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010430b:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104310:	75 1e                	jne    80104330 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104312:	8d 46 10             	lea    0x10(%esi),%eax
80104315:	eb d8                	jmp    801042ef <isdirempty+0xf>
      panic("isdirempty: readi");
80104317:	83 ec 0c             	sub    $0xc,%esp
8010431a:	68 9c 6e 10 80       	push   $0x80106e9c
8010431f:	e8 24 c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104324:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104329:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010432c:	5b                   	pop    %ebx
8010432d:	5e                   	pop    %esi
8010432e:	5d                   	pop    %ebp
8010432f:	c3                   	ret    
      return 0;
80104330:	b8 00 00 00 00       	mov    $0x0,%eax
80104335:	eb f2                	jmp    80104329 <isdirempty+0x49>

80104337 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104337:	55                   	push   %ebp
80104338:	89 e5                	mov    %esp,%ebp
8010433a:	57                   	push   %edi
8010433b:	56                   	push   %esi
8010433c:	53                   	push   %ebx
8010433d:	83 ec 44             	sub    $0x44,%esp
80104340:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104343:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104346:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104349:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010434c:	52                   	push   %edx
8010434d:	50                   	push   %eax
8010434e:	e8 b2 d8 ff ff       	call   80101c05 <nameiparent>
80104353:	89 c6                	mov    %eax,%esi
80104355:	83 c4 10             	add    $0x10,%esp
80104358:	85 c0                	test   %eax,%eax
8010435a:	0f 84 3a 01 00 00    	je     8010449a <create+0x163>
    return 0;
  ilock(dp);
80104360:	83 ec 0c             	sub    $0xc,%esp
80104363:	50                   	push   %eax
80104364:	e8 24 d2 ff ff       	call   8010158d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104369:	83 c4 0c             	add    $0xc,%esp
8010436c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010436f:	50                   	push   %eax
80104370:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104373:	50                   	push   %eax
80104374:	56                   	push   %esi
80104375:	e8 42 d6 ff ff       	call   801019bc <dirlookup>
8010437a:	89 c3                	mov    %eax,%ebx
8010437c:	83 c4 10             	add    $0x10,%esp
8010437f:	85 c0                	test   %eax,%eax
80104381:	74 3f                	je     801043c2 <create+0x8b>
    iunlockput(dp);
80104383:	83 ec 0c             	sub    $0xc,%esp
80104386:	56                   	push   %esi
80104387:	e8 a8 d3 ff ff       	call   80101734 <iunlockput>
    ilock(ip);
8010438c:	89 1c 24             	mov    %ebx,(%esp)
8010438f:	e8 f9 d1 ff ff       	call   8010158d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104394:	83 c4 10             	add    $0x10,%esp
80104397:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010439c:	75 11                	jne    801043af <create+0x78>
8010439e:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801043a3:	75 0a                	jne    801043af <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801043a5:	89 d8                	mov    %ebx,%eax
801043a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043aa:	5b                   	pop    %ebx
801043ab:	5e                   	pop    %esi
801043ac:	5f                   	pop    %edi
801043ad:	5d                   	pop    %ebp
801043ae:	c3                   	ret    
    iunlockput(ip);
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	53                   	push   %ebx
801043b3:	e8 7c d3 ff ff       	call   80101734 <iunlockput>
    return 0;
801043b8:	83 c4 10             	add    $0x10,%esp
801043bb:	bb 00 00 00 00       	mov    $0x0,%ebx
801043c0:	eb e3                	jmp    801043a5 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801043c2:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801043c6:	83 ec 08             	sub    $0x8,%esp
801043c9:	50                   	push   %eax
801043ca:	ff 36                	pushl  (%esi)
801043cc:	e8 b9 cf ff ff       	call   8010138a <ialloc>
801043d1:	89 c3                	mov    %eax,%ebx
801043d3:	83 c4 10             	add    $0x10,%esp
801043d6:	85 c0                	test   %eax,%eax
801043d8:	74 55                	je     8010442f <create+0xf8>
  ilock(ip);
801043da:	83 ec 0c             	sub    $0xc,%esp
801043dd:	50                   	push   %eax
801043de:	e8 aa d1 ff ff       	call   8010158d <ilock>
  ip->major = major;
801043e3:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801043e7:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801043eb:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801043ef:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801043f5:	89 1c 24             	mov    %ebx,(%esp)
801043f8:	e8 2f d0 ff ff       	call   8010142c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801043fd:	83 c4 10             	add    $0x10,%esp
80104400:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104405:	74 35                	je     8010443c <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104407:	83 ec 04             	sub    $0x4,%esp
8010440a:	ff 73 04             	pushl  0x4(%ebx)
8010440d:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104410:	50                   	push   %eax
80104411:	56                   	push   %esi
80104412:	e8 25 d7 ff ff       	call   80101b3c <dirlink>
80104417:	83 c4 10             	add    $0x10,%esp
8010441a:	85 c0                	test   %eax,%eax
8010441c:	78 6f                	js     8010448d <create+0x156>
  iunlockput(dp);
8010441e:	83 ec 0c             	sub    $0xc,%esp
80104421:	56                   	push   %esi
80104422:	e8 0d d3 ff ff       	call   80101734 <iunlockput>
  return ip;
80104427:	83 c4 10             	add    $0x10,%esp
8010442a:	e9 76 ff ff ff       	jmp    801043a5 <create+0x6e>
    panic("create: ialloc");
8010442f:	83 ec 0c             	sub    $0xc,%esp
80104432:	68 ae 6e 10 80       	push   $0x80106eae
80104437:	e8 0c bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010443c:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104440:	83 c0 01             	add    $0x1,%eax
80104443:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104447:	83 ec 0c             	sub    $0xc,%esp
8010444a:	56                   	push   %esi
8010444b:	e8 dc cf ff ff       	call   8010142c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104450:	83 c4 0c             	add    $0xc,%esp
80104453:	ff 73 04             	pushl  0x4(%ebx)
80104456:	68 be 6e 10 80       	push   $0x80106ebe
8010445b:	53                   	push   %ebx
8010445c:	e8 db d6 ff ff       	call   80101b3c <dirlink>
80104461:	83 c4 10             	add    $0x10,%esp
80104464:	85 c0                	test   %eax,%eax
80104466:	78 18                	js     80104480 <create+0x149>
80104468:	83 ec 04             	sub    $0x4,%esp
8010446b:	ff 76 04             	pushl  0x4(%esi)
8010446e:	68 bd 6e 10 80       	push   $0x80106ebd
80104473:	53                   	push   %ebx
80104474:	e8 c3 d6 ff ff       	call   80101b3c <dirlink>
80104479:	83 c4 10             	add    $0x10,%esp
8010447c:	85 c0                	test   %eax,%eax
8010447e:	79 87                	jns    80104407 <create+0xd0>
      panic("create dots");
80104480:	83 ec 0c             	sub    $0xc,%esp
80104483:	68 c0 6e 10 80       	push   $0x80106ec0
80104488:	e8 bb be ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010448d:	83 ec 0c             	sub    $0xc,%esp
80104490:	68 cc 6e 10 80       	push   $0x80106ecc
80104495:	e8 ae be ff ff       	call   80100348 <panic>
    return 0;
8010449a:	89 c3                	mov    %eax,%ebx
8010449c:	e9 04 ff ff ff       	jmp    801043a5 <create+0x6e>

801044a1 <sys_dup>:
{
801044a1:	55                   	push   %ebp
801044a2:	89 e5                	mov    %esp,%ebp
801044a4:	53                   	push   %ebx
801044a5:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801044a8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044ab:	ba 00 00 00 00       	mov    $0x0,%edx
801044b0:	b8 00 00 00 00       	mov    $0x0,%eax
801044b5:	e8 88 fd ff ff       	call   80104242 <argfd>
801044ba:	85 c0                	test   %eax,%eax
801044bc:	78 23                	js     801044e1 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c1:	e8 e3 fd ff ff       	call   801042a9 <fdalloc>
801044c6:	89 c3                	mov    %eax,%ebx
801044c8:	85 c0                	test   %eax,%eax
801044ca:	78 1c                	js     801044e8 <sys_dup+0x47>
  filedup(f);
801044cc:	83 ec 0c             	sub    $0xc,%esp
801044cf:	ff 75 f4             	pushl  -0xc(%ebp)
801044d2:	e8 c3 c7 ff ff       	call   80100c9a <filedup>
  return fd;
801044d7:	83 c4 10             	add    $0x10,%esp
}
801044da:	89 d8                	mov    %ebx,%eax
801044dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044df:	c9                   	leave  
801044e0:	c3                   	ret    
    return -1;
801044e1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044e6:	eb f2                	jmp    801044da <sys_dup+0x39>
    return -1;
801044e8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044ed:	eb eb                	jmp    801044da <sys_dup+0x39>

801044ef <sys_read>:
{
801044ef:	55                   	push   %ebp
801044f0:	89 e5                	mov    %esp,%ebp
801044f2:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044f5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044f8:	ba 00 00 00 00       	mov    $0x0,%edx
801044fd:	b8 00 00 00 00       	mov    $0x0,%eax
80104502:	e8 3b fd ff ff       	call   80104242 <argfd>
80104507:	85 c0                	test   %eax,%eax
80104509:	78 43                	js     8010454e <sys_read+0x5f>
8010450b:	83 ec 08             	sub    $0x8,%esp
8010450e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104511:	50                   	push   %eax
80104512:	6a 02                	push   $0x2
80104514:	e8 11 fc ff ff       	call   8010412a <argint>
80104519:	83 c4 10             	add    $0x10,%esp
8010451c:	85 c0                	test   %eax,%eax
8010451e:	78 35                	js     80104555 <sys_read+0x66>
80104520:	83 ec 04             	sub    $0x4,%esp
80104523:	ff 75 f0             	pushl  -0x10(%ebp)
80104526:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104529:	50                   	push   %eax
8010452a:	6a 01                	push   $0x1
8010452c:	e8 21 fc ff ff       	call   80104152 <argptr>
80104531:	83 c4 10             	add    $0x10,%esp
80104534:	85 c0                	test   %eax,%eax
80104536:	78 24                	js     8010455c <sys_read+0x6d>
  return fileread(f, p, n);
80104538:	83 ec 04             	sub    $0x4,%esp
8010453b:	ff 75 f0             	pushl  -0x10(%ebp)
8010453e:	ff 75 ec             	pushl  -0x14(%ebp)
80104541:	ff 75 f4             	pushl  -0xc(%ebp)
80104544:	e8 9a c8 ff ff       	call   80100de3 <fileread>
80104549:	83 c4 10             	add    $0x10,%esp
}
8010454c:	c9                   	leave  
8010454d:	c3                   	ret    
    return -1;
8010454e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104553:	eb f7                	jmp    8010454c <sys_read+0x5d>
80104555:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010455a:	eb f0                	jmp    8010454c <sys_read+0x5d>
8010455c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104561:	eb e9                	jmp    8010454c <sys_read+0x5d>

80104563 <sys_write>:
{
80104563:	55                   	push   %ebp
80104564:	89 e5                	mov    %esp,%ebp
80104566:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104569:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010456c:	ba 00 00 00 00       	mov    $0x0,%edx
80104571:	b8 00 00 00 00       	mov    $0x0,%eax
80104576:	e8 c7 fc ff ff       	call   80104242 <argfd>
8010457b:	85 c0                	test   %eax,%eax
8010457d:	78 43                	js     801045c2 <sys_write+0x5f>
8010457f:	83 ec 08             	sub    $0x8,%esp
80104582:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104585:	50                   	push   %eax
80104586:	6a 02                	push   $0x2
80104588:	e8 9d fb ff ff       	call   8010412a <argint>
8010458d:	83 c4 10             	add    $0x10,%esp
80104590:	85 c0                	test   %eax,%eax
80104592:	78 35                	js     801045c9 <sys_write+0x66>
80104594:	83 ec 04             	sub    $0x4,%esp
80104597:	ff 75 f0             	pushl  -0x10(%ebp)
8010459a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010459d:	50                   	push   %eax
8010459e:	6a 01                	push   $0x1
801045a0:	e8 ad fb ff ff       	call   80104152 <argptr>
801045a5:	83 c4 10             	add    $0x10,%esp
801045a8:	85 c0                	test   %eax,%eax
801045aa:	78 24                	js     801045d0 <sys_write+0x6d>
  return filewrite(f, p, n);
801045ac:	83 ec 04             	sub    $0x4,%esp
801045af:	ff 75 f0             	pushl  -0x10(%ebp)
801045b2:	ff 75 ec             	pushl  -0x14(%ebp)
801045b5:	ff 75 f4             	pushl  -0xc(%ebp)
801045b8:	e8 ab c8 ff ff       	call   80100e68 <filewrite>
801045bd:	83 c4 10             	add    $0x10,%esp
}
801045c0:	c9                   	leave  
801045c1:	c3                   	ret    
    return -1;
801045c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c7:	eb f7                	jmp    801045c0 <sys_write+0x5d>
801045c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ce:	eb f0                	jmp    801045c0 <sys_write+0x5d>
801045d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d5:	eb e9                	jmp    801045c0 <sys_write+0x5d>

801045d7 <sys_close>:
{
801045d7:	55                   	push   %ebp
801045d8:	89 e5                	mov    %esp,%ebp
801045da:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801045dd:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801045e0:	8d 55 f4             	lea    -0xc(%ebp),%edx
801045e3:	b8 00 00 00 00       	mov    $0x0,%eax
801045e8:	e8 55 fc ff ff       	call   80104242 <argfd>
801045ed:	85 c0                	test   %eax,%eax
801045ef:	78 25                	js     80104616 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801045f1:	e8 9b ee ff ff       	call   80103491 <myproc>
801045f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f9:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104600:	00 
  fileclose(f);
80104601:	83 ec 0c             	sub    $0xc,%esp
80104604:	ff 75 f0             	pushl  -0x10(%ebp)
80104607:	e8 d3 c6 ff ff       	call   80100cdf <fileclose>
  return 0;
8010460c:	83 c4 10             	add    $0x10,%esp
8010460f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104614:	c9                   	leave  
80104615:	c3                   	ret    
    return -1;
80104616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010461b:	eb f7                	jmp    80104614 <sys_close+0x3d>

8010461d <sys_fstat>:
{
8010461d:	55                   	push   %ebp
8010461e:	89 e5                	mov    %esp,%ebp
80104620:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104623:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104626:	ba 00 00 00 00       	mov    $0x0,%edx
8010462b:	b8 00 00 00 00       	mov    $0x0,%eax
80104630:	e8 0d fc ff ff       	call   80104242 <argfd>
80104635:	85 c0                	test   %eax,%eax
80104637:	78 2a                	js     80104663 <sys_fstat+0x46>
80104639:	83 ec 04             	sub    $0x4,%esp
8010463c:	6a 14                	push   $0x14
8010463e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104641:	50                   	push   %eax
80104642:	6a 01                	push   $0x1
80104644:	e8 09 fb ff ff       	call   80104152 <argptr>
80104649:	83 c4 10             	add    $0x10,%esp
8010464c:	85 c0                	test   %eax,%eax
8010464e:	78 1a                	js     8010466a <sys_fstat+0x4d>
  return filestat(f, st);
80104650:	83 ec 08             	sub    $0x8,%esp
80104653:	ff 75 f0             	pushl  -0x10(%ebp)
80104656:	ff 75 f4             	pushl  -0xc(%ebp)
80104659:	e8 3e c7 ff ff       	call   80100d9c <filestat>
8010465e:	83 c4 10             	add    $0x10,%esp
}
80104661:	c9                   	leave  
80104662:	c3                   	ret    
    return -1;
80104663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104668:	eb f7                	jmp    80104661 <sys_fstat+0x44>
8010466a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010466f:	eb f0                	jmp    80104661 <sys_fstat+0x44>

80104671 <sys_link>:
{
80104671:	55                   	push   %ebp
80104672:	89 e5                	mov    %esp,%ebp
80104674:	56                   	push   %esi
80104675:	53                   	push   %ebx
80104676:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104679:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010467c:	50                   	push   %eax
8010467d:	6a 00                	push   $0x0
8010467f:	e8 36 fb ff ff       	call   801041ba <argstr>
80104684:	83 c4 10             	add    $0x10,%esp
80104687:	85 c0                	test   %eax,%eax
80104689:	0f 88 32 01 00 00    	js     801047c1 <sys_link+0x150>
8010468f:	83 ec 08             	sub    $0x8,%esp
80104692:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104695:	50                   	push   %eax
80104696:	6a 01                	push   $0x1
80104698:	e8 1d fb ff ff       	call   801041ba <argstr>
8010469d:	83 c4 10             	add    $0x10,%esp
801046a0:	85 c0                	test   %eax,%eax
801046a2:	0f 88 20 01 00 00    	js     801047c8 <sys_link+0x157>
  begin_op();
801046a8:	e8 89 e3 ff ff       	call   80102a36 <begin_op>
  if((ip = namei(old)) == 0){
801046ad:	83 ec 0c             	sub    $0xc,%esp
801046b0:	ff 75 e0             	pushl  -0x20(%ebp)
801046b3:	e8 35 d5 ff ff       	call   80101bed <namei>
801046b8:	89 c3                	mov    %eax,%ebx
801046ba:	83 c4 10             	add    $0x10,%esp
801046bd:	85 c0                	test   %eax,%eax
801046bf:	0f 84 99 00 00 00    	je     8010475e <sys_link+0xed>
  ilock(ip);
801046c5:	83 ec 0c             	sub    $0xc,%esp
801046c8:	50                   	push   %eax
801046c9:	e8 bf ce ff ff       	call   8010158d <ilock>
  if(ip->type == T_DIR){
801046ce:	83 c4 10             	add    $0x10,%esp
801046d1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046d6:	0f 84 8e 00 00 00    	je     8010476a <sys_link+0xf9>
  ip->nlink++;
801046dc:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046e0:	83 c0 01             	add    $0x1,%eax
801046e3:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046e7:	83 ec 0c             	sub    $0xc,%esp
801046ea:	53                   	push   %ebx
801046eb:	e8 3c cd ff ff       	call   8010142c <iupdate>
  iunlock(ip);
801046f0:	89 1c 24             	mov    %ebx,(%esp)
801046f3:	e8 57 cf ff ff       	call   8010164f <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801046f8:	83 c4 08             	add    $0x8,%esp
801046fb:	8d 45 ea             	lea    -0x16(%ebp),%eax
801046fe:	50                   	push   %eax
801046ff:	ff 75 e4             	pushl  -0x1c(%ebp)
80104702:	e8 fe d4 ff ff       	call   80101c05 <nameiparent>
80104707:	89 c6                	mov    %eax,%esi
80104709:	83 c4 10             	add    $0x10,%esp
8010470c:	85 c0                	test   %eax,%eax
8010470e:	74 7e                	je     8010478e <sys_link+0x11d>
  ilock(dp);
80104710:	83 ec 0c             	sub    $0xc,%esp
80104713:	50                   	push   %eax
80104714:	e8 74 ce ff ff       	call   8010158d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104719:	83 c4 10             	add    $0x10,%esp
8010471c:	8b 03                	mov    (%ebx),%eax
8010471e:	39 06                	cmp    %eax,(%esi)
80104720:	75 60                	jne    80104782 <sys_link+0x111>
80104722:	83 ec 04             	sub    $0x4,%esp
80104725:	ff 73 04             	pushl  0x4(%ebx)
80104728:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010472b:	50                   	push   %eax
8010472c:	56                   	push   %esi
8010472d:	e8 0a d4 ff ff       	call   80101b3c <dirlink>
80104732:	83 c4 10             	add    $0x10,%esp
80104735:	85 c0                	test   %eax,%eax
80104737:	78 49                	js     80104782 <sys_link+0x111>
  iunlockput(dp);
80104739:	83 ec 0c             	sub    $0xc,%esp
8010473c:	56                   	push   %esi
8010473d:	e8 f2 cf ff ff       	call   80101734 <iunlockput>
  iput(ip);
80104742:	89 1c 24             	mov    %ebx,(%esp)
80104745:	e8 4a cf ff ff       	call   80101694 <iput>
  end_op();
8010474a:	e8 61 e3 ff ff       	call   80102ab0 <end_op>
  return 0;
8010474f:	83 c4 10             	add    $0x10,%esp
80104752:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104757:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010475a:	5b                   	pop    %ebx
8010475b:	5e                   	pop    %esi
8010475c:	5d                   	pop    %ebp
8010475d:	c3                   	ret    
    end_op();
8010475e:	e8 4d e3 ff ff       	call   80102ab0 <end_op>
    return -1;
80104763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104768:	eb ed                	jmp    80104757 <sys_link+0xe6>
    iunlockput(ip);
8010476a:	83 ec 0c             	sub    $0xc,%esp
8010476d:	53                   	push   %ebx
8010476e:	e8 c1 cf ff ff       	call   80101734 <iunlockput>
    end_op();
80104773:	e8 38 e3 ff ff       	call   80102ab0 <end_op>
    return -1;
80104778:	83 c4 10             	add    $0x10,%esp
8010477b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104780:	eb d5                	jmp    80104757 <sys_link+0xe6>
    iunlockput(dp);
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	56                   	push   %esi
80104786:	e8 a9 cf ff ff       	call   80101734 <iunlockput>
    goto bad;
8010478b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010478e:	83 ec 0c             	sub    $0xc,%esp
80104791:	53                   	push   %ebx
80104792:	e8 f6 cd ff ff       	call   8010158d <ilock>
  ip->nlink--;
80104797:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010479b:	83 e8 01             	sub    $0x1,%eax
8010479e:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801047a2:	89 1c 24             	mov    %ebx,(%esp)
801047a5:	e8 82 cc ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801047aa:	89 1c 24             	mov    %ebx,(%esp)
801047ad:	e8 82 cf ff ff       	call   80101734 <iunlockput>
  end_op();
801047b2:	e8 f9 e2 ff ff       	call   80102ab0 <end_op>
  return -1;
801047b7:	83 c4 10             	add    $0x10,%esp
801047ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047bf:	eb 96                	jmp    80104757 <sys_link+0xe6>
    return -1;
801047c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c6:	eb 8f                	jmp    80104757 <sys_link+0xe6>
801047c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047cd:	eb 88                	jmp    80104757 <sys_link+0xe6>

801047cf <sys_unlink>:
{
801047cf:	55                   	push   %ebp
801047d0:	89 e5                	mov    %esp,%ebp
801047d2:	57                   	push   %edi
801047d3:	56                   	push   %esi
801047d4:	53                   	push   %ebx
801047d5:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801047d8:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047db:	50                   	push   %eax
801047dc:	6a 00                	push   $0x0
801047de:	e8 d7 f9 ff ff       	call   801041ba <argstr>
801047e3:	83 c4 10             	add    $0x10,%esp
801047e6:	85 c0                	test   %eax,%eax
801047e8:	0f 88 83 01 00 00    	js     80104971 <sys_unlink+0x1a2>
  begin_op();
801047ee:	e8 43 e2 ff ff       	call   80102a36 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801047f3:	83 ec 08             	sub    $0x8,%esp
801047f6:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047f9:	50                   	push   %eax
801047fa:	ff 75 c4             	pushl  -0x3c(%ebp)
801047fd:	e8 03 d4 ff ff       	call   80101c05 <nameiparent>
80104802:	89 c6                	mov    %eax,%esi
80104804:	83 c4 10             	add    $0x10,%esp
80104807:	85 c0                	test   %eax,%eax
80104809:	0f 84 ed 00 00 00    	je     801048fc <sys_unlink+0x12d>
  ilock(dp);
8010480f:	83 ec 0c             	sub    $0xc,%esp
80104812:	50                   	push   %eax
80104813:	e8 75 cd ff ff       	call   8010158d <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104818:	83 c4 08             	add    $0x8,%esp
8010481b:	68 be 6e 10 80       	push   $0x80106ebe
80104820:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104823:	50                   	push   %eax
80104824:	e8 7e d1 ff ff       	call   801019a7 <namecmp>
80104829:	83 c4 10             	add    $0x10,%esp
8010482c:	85 c0                	test   %eax,%eax
8010482e:	0f 84 fc 00 00 00    	je     80104930 <sys_unlink+0x161>
80104834:	83 ec 08             	sub    $0x8,%esp
80104837:	68 bd 6e 10 80       	push   $0x80106ebd
8010483c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010483f:	50                   	push   %eax
80104840:	e8 62 d1 ff ff       	call   801019a7 <namecmp>
80104845:	83 c4 10             	add    $0x10,%esp
80104848:	85 c0                	test   %eax,%eax
8010484a:	0f 84 e0 00 00 00    	je     80104930 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104850:	83 ec 04             	sub    $0x4,%esp
80104853:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104856:	50                   	push   %eax
80104857:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010485a:	50                   	push   %eax
8010485b:	56                   	push   %esi
8010485c:	e8 5b d1 ff ff       	call   801019bc <dirlookup>
80104861:	89 c3                	mov    %eax,%ebx
80104863:	83 c4 10             	add    $0x10,%esp
80104866:	85 c0                	test   %eax,%eax
80104868:	0f 84 c2 00 00 00    	je     80104930 <sys_unlink+0x161>
  ilock(ip);
8010486e:	83 ec 0c             	sub    $0xc,%esp
80104871:	50                   	push   %eax
80104872:	e8 16 cd ff ff       	call   8010158d <ilock>
  if(ip->nlink < 1)
80104877:	83 c4 10             	add    $0x10,%esp
8010487a:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010487f:	0f 8e 83 00 00 00    	jle    80104908 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104885:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010488a:	0f 84 85 00 00 00    	je     80104915 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104890:	83 ec 04             	sub    $0x4,%esp
80104893:	6a 10                	push   $0x10
80104895:	6a 00                	push   $0x0
80104897:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010489a:	57                   	push   %edi
8010489b:	e8 3f f6 ff ff       	call   80103edf <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801048a0:	6a 10                	push   $0x10
801048a2:	ff 75 c0             	pushl  -0x40(%ebp)
801048a5:	57                   	push   %edi
801048a6:	56                   	push   %esi
801048a7:	e8 d0 cf ff ff       	call   8010187c <writei>
801048ac:	83 c4 20             	add    $0x20,%esp
801048af:	83 f8 10             	cmp    $0x10,%eax
801048b2:	0f 85 90 00 00 00    	jne    80104948 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801048b8:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801048bd:	0f 84 92 00 00 00    	je     80104955 <sys_unlink+0x186>
  iunlockput(dp);
801048c3:	83 ec 0c             	sub    $0xc,%esp
801048c6:	56                   	push   %esi
801048c7:	e8 68 ce ff ff       	call   80101734 <iunlockput>
  ip->nlink--;
801048cc:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801048d0:	83 e8 01             	sub    $0x1,%eax
801048d3:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801048d7:	89 1c 24             	mov    %ebx,(%esp)
801048da:	e8 4d cb ff ff       	call   8010142c <iupdate>
  iunlockput(ip);
801048df:	89 1c 24             	mov    %ebx,(%esp)
801048e2:	e8 4d ce ff ff       	call   80101734 <iunlockput>
  end_op();
801048e7:	e8 c4 e1 ff ff       	call   80102ab0 <end_op>
  return 0;
801048ec:	83 c4 10             	add    $0x10,%esp
801048ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048f7:	5b                   	pop    %ebx
801048f8:	5e                   	pop    %esi
801048f9:	5f                   	pop    %edi
801048fa:	5d                   	pop    %ebp
801048fb:	c3                   	ret    
    end_op();
801048fc:	e8 af e1 ff ff       	call   80102ab0 <end_op>
    return -1;
80104901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104906:	eb ec                	jmp    801048f4 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104908:	83 ec 0c             	sub    $0xc,%esp
8010490b:	68 dc 6e 10 80       	push   $0x80106edc
80104910:	e8 33 ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104915:	89 d8                	mov    %ebx,%eax
80104917:	e8 c4 f9 ff ff       	call   801042e0 <isdirempty>
8010491c:	85 c0                	test   %eax,%eax
8010491e:	0f 85 6c ff ff ff    	jne    80104890 <sys_unlink+0xc1>
    iunlockput(ip);
80104924:	83 ec 0c             	sub    $0xc,%esp
80104927:	53                   	push   %ebx
80104928:	e8 07 ce ff ff       	call   80101734 <iunlockput>
    goto bad;
8010492d:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104930:	83 ec 0c             	sub    $0xc,%esp
80104933:	56                   	push   %esi
80104934:	e8 fb cd ff ff       	call   80101734 <iunlockput>
  end_op();
80104939:	e8 72 e1 ff ff       	call   80102ab0 <end_op>
  return -1;
8010493e:	83 c4 10             	add    $0x10,%esp
80104941:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104946:	eb ac                	jmp    801048f4 <sys_unlink+0x125>
    panic("unlink: writei");
80104948:	83 ec 0c             	sub    $0xc,%esp
8010494b:	68 ee 6e 10 80       	push   $0x80106eee
80104950:	e8 f3 b9 ff ff       	call   80100348 <panic>
    dp->nlink--;
80104955:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104959:	83 e8 01             	sub    $0x1,%eax
8010495c:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	56                   	push   %esi
80104964:	e8 c3 ca ff ff       	call   8010142c <iupdate>
80104969:	83 c4 10             	add    $0x10,%esp
8010496c:	e9 52 ff ff ff       	jmp    801048c3 <sys_unlink+0xf4>
    return -1;
80104971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104976:	e9 79 ff ff ff       	jmp    801048f4 <sys_unlink+0x125>

8010497b <sys_open>:

int
sys_open(void)
{
8010497b:	55                   	push   %ebp
8010497c:	89 e5                	mov    %esp,%ebp
8010497e:	57                   	push   %edi
8010497f:	56                   	push   %esi
80104980:	53                   	push   %ebx
80104981:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104984:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104987:	50                   	push   %eax
80104988:	6a 00                	push   $0x0
8010498a:	e8 2b f8 ff ff       	call   801041ba <argstr>
8010498f:	83 c4 10             	add    $0x10,%esp
80104992:	85 c0                	test   %eax,%eax
80104994:	0f 88 30 01 00 00    	js     80104aca <sys_open+0x14f>
8010499a:	83 ec 08             	sub    $0x8,%esp
8010499d:	8d 45 e0             	lea    -0x20(%ebp),%eax
801049a0:	50                   	push   %eax
801049a1:	6a 01                	push   $0x1
801049a3:	e8 82 f7 ff ff       	call   8010412a <argint>
801049a8:	83 c4 10             	add    $0x10,%esp
801049ab:	85 c0                	test   %eax,%eax
801049ad:	0f 88 21 01 00 00    	js     80104ad4 <sys_open+0x159>
    return -1;

  begin_op();
801049b3:	e8 7e e0 ff ff       	call   80102a36 <begin_op>

  if(omode & O_CREATE){
801049b8:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801049bc:	0f 84 84 00 00 00    	je     80104a46 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801049c2:	83 ec 0c             	sub    $0xc,%esp
801049c5:	6a 00                	push   $0x0
801049c7:	b9 00 00 00 00       	mov    $0x0,%ecx
801049cc:	ba 02 00 00 00       	mov    $0x2,%edx
801049d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801049d4:	e8 5e f9 ff ff       	call   80104337 <create>
801049d9:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801049db:	83 c4 10             	add    $0x10,%esp
801049de:	85 c0                	test   %eax,%eax
801049e0:	74 58                	je     80104a3a <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801049e2:	e8 52 c2 ff ff       	call   80100c39 <filealloc>
801049e7:	89 c3                	mov    %eax,%ebx
801049e9:	85 c0                	test   %eax,%eax
801049eb:	0f 84 ae 00 00 00    	je     80104a9f <sys_open+0x124>
801049f1:	e8 b3 f8 ff ff       	call   801042a9 <fdalloc>
801049f6:	89 c7                	mov    %eax,%edi
801049f8:	85 c0                	test   %eax,%eax
801049fa:	0f 88 9f 00 00 00    	js     80104a9f <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a00:	83 ec 0c             	sub    $0xc,%esp
80104a03:	56                   	push   %esi
80104a04:	e8 46 cc ff ff       	call   8010164f <iunlock>
  end_op();
80104a09:	e8 a2 e0 ff ff       	call   80102ab0 <end_op>

  f->type = FD_INODE;
80104a0e:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104a14:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104a17:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104a1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a21:	83 c4 10             	add    $0x10,%esp
80104a24:	a8 01                	test   $0x1,%al
80104a26:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104a2a:	a8 03                	test   $0x3,%al
80104a2c:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104a30:	89 f8                	mov    %edi,%eax
80104a32:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a35:	5b                   	pop    %ebx
80104a36:	5e                   	pop    %esi
80104a37:	5f                   	pop    %edi
80104a38:	5d                   	pop    %ebp
80104a39:	c3                   	ret    
      end_op();
80104a3a:	e8 71 e0 ff ff       	call   80102ab0 <end_op>
      return -1;
80104a3f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a44:	eb ea                	jmp    80104a30 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104a46:	83 ec 0c             	sub    $0xc,%esp
80104a49:	ff 75 e4             	pushl  -0x1c(%ebp)
80104a4c:	e8 9c d1 ff ff       	call   80101bed <namei>
80104a51:	89 c6                	mov    %eax,%esi
80104a53:	83 c4 10             	add    $0x10,%esp
80104a56:	85 c0                	test   %eax,%eax
80104a58:	74 39                	je     80104a93 <sys_open+0x118>
    ilock(ip);
80104a5a:	83 ec 0c             	sub    $0xc,%esp
80104a5d:	50                   	push   %eax
80104a5e:	e8 2a cb ff ff       	call   8010158d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a63:	83 c4 10             	add    $0x10,%esp
80104a66:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104a6b:	0f 85 71 ff ff ff    	jne    801049e2 <sys_open+0x67>
80104a71:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a75:	0f 84 67 ff ff ff    	je     801049e2 <sys_open+0x67>
      iunlockput(ip);
80104a7b:	83 ec 0c             	sub    $0xc,%esp
80104a7e:	56                   	push   %esi
80104a7f:	e8 b0 cc ff ff       	call   80101734 <iunlockput>
      end_op();
80104a84:	e8 27 e0 ff ff       	call   80102ab0 <end_op>
      return -1;
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a91:	eb 9d                	jmp    80104a30 <sys_open+0xb5>
      end_op();
80104a93:	e8 18 e0 ff ff       	call   80102ab0 <end_op>
      return -1;
80104a98:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a9d:	eb 91                	jmp    80104a30 <sys_open+0xb5>
    if(f)
80104a9f:	85 db                	test   %ebx,%ebx
80104aa1:	74 0c                	je     80104aaf <sys_open+0x134>
      fileclose(f);
80104aa3:	83 ec 0c             	sub    $0xc,%esp
80104aa6:	53                   	push   %ebx
80104aa7:	e8 33 c2 ff ff       	call   80100cdf <fileclose>
80104aac:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104aaf:	83 ec 0c             	sub    $0xc,%esp
80104ab2:	56                   	push   %esi
80104ab3:	e8 7c cc ff ff       	call   80101734 <iunlockput>
    end_op();
80104ab8:	e8 f3 df ff ff       	call   80102ab0 <end_op>
    return -1;
80104abd:	83 c4 10             	add    $0x10,%esp
80104ac0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ac5:	e9 66 ff ff ff       	jmp    80104a30 <sys_open+0xb5>
    return -1;
80104aca:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104acf:	e9 5c ff ff ff       	jmp    80104a30 <sys_open+0xb5>
80104ad4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ad9:	e9 52 ff ff ff       	jmp    80104a30 <sys_open+0xb5>

80104ade <sys_mkdir>:

int
sys_mkdir(void)
{
80104ade:	55                   	push   %ebp
80104adf:	89 e5                	mov    %esp,%ebp
80104ae1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104ae4:	e8 4d df ff ff       	call   80102a36 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104ae9:	83 ec 08             	sub    $0x8,%esp
80104aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104aef:	50                   	push   %eax
80104af0:	6a 00                	push   $0x0
80104af2:	e8 c3 f6 ff ff       	call   801041ba <argstr>
80104af7:	83 c4 10             	add    $0x10,%esp
80104afa:	85 c0                	test   %eax,%eax
80104afc:	78 36                	js     80104b34 <sys_mkdir+0x56>
80104afe:	83 ec 0c             	sub    $0xc,%esp
80104b01:	6a 00                	push   $0x0
80104b03:	b9 00 00 00 00       	mov    $0x0,%ecx
80104b08:	ba 01 00 00 00       	mov    $0x1,%edx
80104b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b10:	e8 22 f8 ff ff       	call   80104337 <create>
80104b15:	83 c4 10             	add    $0x10,%esp
80104b18:	85 c0                	test   %eax,%eax
80104b1a:	74 18                	je     80104b34 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b1c:	83 ec 0c             	sub    $0xc,%esp
80104b1f:	50                   	push   %eax
80104b20:	e8 0f cc ff ff       	call   80101734 <iunlockput>
  end_op();
80104b25:	e8 86 df ff ff       	call   80102ab0 <end_op>
  return 0;
80104b2a:	83 c4 10             	add    $0x10,%esp
80104b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b32:	c9                   	leave  
80104b33:	c3                   	ret    
    end_op();
80104b34:	e8 77 df ff ff       	call   80102ab0 <end_op>
    return -1;
80104b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3e:	eb f2                	jmp    80104b32 <sys_mkdir+0x54>

80104b40 <sys_mknod>:

int
sys_mknod(void)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104b46:	e8 eb de ff ff       	call   80102a36 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104b4b:	83 ec 08             	sub    $0x8,%esp
80104b4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b51:	50                   	push   %eax
80104b52:	6a 00                	push   $0x0
80104b54:	e8 61 f6 ff ff       	call   801041ba <argstr>
80104b59:	83 c4 10             	add    $0x10,%esp
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	78 62                	js     80104bc2 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104b60:	83 ec 08             	sub    $0x8,%esp
80104b63:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b66:	50                   	push   %eax
80104b67:	6a 01                	push   $0x1
80104b69:	e8 bc f5 ff ff       	call   8010412a <argint>
  if((argstr(0, &path)) < 0 ||
80104b6e:	83 c4 10             	add    $0x10,%esp
80104b71:	85 c0                	test   %eax,%eax
80104b73:	78 4d                	js     80104bc2 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104b75:	83 ec 08             	sub    $0x8,%esp
80104b78:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b7b:	50                   	push   %eax
80104b7c:	6a 02                	push   $0x2
80104b7e:	e8 a7 f5 ff ff       	call   8010412a <argint>
     argint(1, &major) < 0 ||
80104b83:	83 c4 10             	add    $0x10,%esp
80104b86:	85 c0                	test   %eax,%eax
80104b88:	78 38                	js     80104bc2 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b8a:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104b8e:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104b92:	83 ec 0c             	sub    $0xc,%esp
80104b95:	50                   	push   %eax
80104b96:	ba 03 00 00 00       	mov    $0x3,%edx
80104b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9e:	e8 94 f7 ff ff       	call   80104337 <create>
80104ba3:	83 c4 10             	add    $0x10,%esp
80104ba6:	85 c0                	test   %eax,%eax
80104ba8:	74 18                	je     80104bc2 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104baa:	83 ec 0c             	sub    $0xc,%esp
80104bad:	50                   	push   %eax
80104bae:	e8 81 cb ff ff       	call   80101734 <iunlockput>
  end_op();
80104bb3:	e8 f8 de ff ff       	call   80102ab0 <end_op>
  return 0;
80104bb8:	83 c4 10             	add    $0x10,%esp
80104bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bc0:	c9                   	leave  
80104bc1:	c3                   	ret    
    end_op();
80104bc2:	e8 e9 de ff ff       	call   80102ab0 <end_op>
    return -1;
80104bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bcc:	eb f2                	jmp    80104bc0 <sys_mknod+0x80>

80104bce <sys_chdir>:

int
sys_chdir(void)
{
80104bce:	55                   	push   %ebp
80104bcf:	89 e5                	mov    %esp,%ebp
80104bd1:	56                   	push   %esi
80104bd2:	53                   	push   %ebx
80104bd3:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104bd6:	e8 b6 e8 ff ff       	call   80103491 <myproc>
80104bdb:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104bdd:	e8 54 de ff ff       	call   80102a36 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104be2:	83 ec 08             	sub    $0x8,%esp
80104be5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104be8:	50                   	push   %eax
80104be9:	6a 00                	push   $0x0
80104beb:	e8 ca f5 ff ff       	call   801041ba <argstr>
80104bf0:	83 c4 10             	add    $0x10,%esp
80104bf3:	85 c0                	test   %eax,%eax
80104bf5:	78 52                	js     80104c49 <sys_chdir+0x7b>
80104bf7:	83 ec 0c             	sub    $0xc,%esp
80104bfa:	ff 75 f4             	pushl  -0xc(%ebp)
80104bfd:	e8 eb cf ff ff       	call   80101bed <namei>
80104c02:	89 c3                	mov    %eax,%ebx
80104c04:	83 c4 10             	add    $0x10,%esp
80104c07:	85 c0                	test   %eax,%eax
80104c09:	74 3e                	je     80104c49 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104c0b:	83 ec 0c             	sub    $0xc,%esp
80104c0e:	50                   	push   %eax
80104c0f:	e8 79 c9 ff ff       	call   8010158d <ilock>
  if(ip->type != T_DIR){
80104c14:	83 c4 10             	add    $0x10,%esp
80104c17:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104c1c:	75 37                	jne    80104c55 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104c1e:	83 ec 0c             	sub    $0xc,%esp
80104c21:	53                   	push   %ebx
80104c22:	e8 28 ca ff ff       	call   8010164f <iunlock>
  iput(curproc->cwd);
80104c27:	83 c4 04             	add    $0x4,%esp
80104c2a:	ff 76 68             	pushl  0x68(%esi)
80104c2d:	e8 62 ca ff ff       	call   80101694 <iput>
  end_op();
80104c32:	e8 79 de ff ff       	call   80102ab0 <end_op>
  curproc->cwd = ip;
80104c37:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104c3a:	83 c4 10             	add    $0x10,%esp
80104c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c42:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c45:	5b                   	pop    %ebx
80104c46:	5e                   	pop    %esi
80104c47:	5d                   	pop    %ebp
80104c48:	c3                   	ret    
    end_op();
80104c49:	e8 62 de ff ff       	call   80102ab0 <end_op>
    return -1;
80104c4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c53:	eb ed                	jmp    80104c42 <sys_chdir+0x74>
    iunlockput(ip);
80104c55:	83 ec 0c             	sub    $0xc,%esp
80104c58:	53                   	push   %ebx
80104c59:	e8 d6 ca ff ff       	call   80101734 <iunlockput>
    end_op();
80104c5e:	e8 4d de ff ff       	call   80102ab0 <end_op>
    return -1;
80104c63:	83 c4 10             	add    $0x10,%esp
80104c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6b:	eb d5                	jmp    80104c42 <sys_chdir+0x74>

80104c6d <sys_exec>:

int
sys_exec(void)
{
80104c6d:	55                   	push   %ebp
80104c6e:	89 e5                	mov    %esp,%ebp
80104c70:	53                   	push   %ebx
80104c71:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104c77:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c7a:	50                   	push   %eax
80104c7b:	6a 00                	push   $0x0
80104c7d:	e8 38 f5 ff ff       	call   801041ba <argstr>
80104c82:	83 c4 10             	add    $0x10,%esp
80104c85:	85 c0                	test   %eax,%eax
80104c87:	0f 88 a8 00 00 00    	js     80104d35 <sys_exec+0xc8>
80104c8d:	83 ec 08             	sub    $0x8,%esp
80104c90:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104c96:	50                   	push   %eax
80104c97:	6a 01                	push   $0x1
80104c99:	e8 8c f4 ff ff       	call   8010412a <argint>
80104c9e:	83 c4 10             	add    $0x10,%esp
80104ca1:	85 c0                	test   %eax,%eax
80104ca3:	0f 88 93 00 00 00    	js     80104d3c <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ca9:	83 ec 04             	sub    $0x4,%esp
80104cac:	68 80 00 00 00       	push   $0x80
80104cb1:	6a 00                	push   $0x0
80104cb3:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104cb9:	50                   	push   %eax
80104cba:	e8 20 f2 ff ff       	call   80103edf <memset>
80104cbf:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104cc7:	83 fb 1f             	cmp    $0x1f,%ebx
80104cca:	77 77                	ja     80104d43 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104ccc:	83 ec 08             	sub    $0x8,%esp
80104ccf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104cd5:	50                   	push   %eax
80104cd6:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104cdc:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104cdf:	50                   	push   %eax
80104ce0:	e8 c9 f3 ff ff       	call   801040ae <fetchint>
80104ce5:	83 c4 10             	add    $0x10,%esp
80104ce8:	85 c0                	test   %eax,%eax
80104cea:	78 5e                	js     80104d4a <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104cec:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104cf2:	85 c0                	test   %eax,%eax
80104cf4:	74 1d                	je     80104d13 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104cf6:	83 ec 08             	sub    $0x8,%esp
80104cf9:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104d00:	52                   	push   %edx
80104d01:	50                   	push   %eax
80104d02:	e8 e3 f3 ff ff       	call   801040ea <fetchstr>
80104d07:	83 c4 10             	add    $0x10,%esp
80104d0a:	85 c0                	test   %eax,%eax
80104d0c:	78 46                	js     80104d54 <sys_exec+0xe7>
  for(i=0;; i++){
80104d0e:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104d11:	eb b4                	jmp    80104cc7 <sys_exec+0x5a>
      argv[i] = 0;
80104d13:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104d1a:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104d1e:	83 ec 08             	sub    $0x8,%esp
80104d21:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104d27:	50                   	push   %eax
80104d28:	ff 75 f4             	pushl  -0xc(%ebp)
80104d2b:	e8 a2 bb ff ff       	call   801008d2 <exec>
80104d30:	83 c4 10             	add    $0x10,%esp
80104d33:	eb 1a                	jmp    80104d4f <sys_exec+0xe2>
    return -1;
80104d35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3a:	eb 13                	jmp    80104d4f <sys_exec+0xe2>
80104d3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d41:	eb 0c                	jmp    80104d4f <sys_exec+0xe2>
      return -1;
80104d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d48:	eb 05                	jmp    80104d4f <sys_exec+0xe2>
      return -1;
80104d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d52:	c9                   	leave  
80104d53:	c3                   	ret    
      return -1;
80104d54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d59:	eb f4                	jmp    80104d4f <sys_exec+0xe2>

80104d5b <sys_pipe>:

int
sys_pipe(void)
{
80104d5b:	55                   	push   %ebp
80104d5c:	89 e5                	mov    %esp,%ebp
80104d5e:	53                   	push   %ebx
80104d5f:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104d62:	6a 08                	push   $0x8
80104d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d67:	50                   	push   %eax
80104d68:	6a 00                	push   $0x0
80104d6a:	e8 e3 f3 ff ff       	call   80104152 <argptr>
80104d6f:	83 c4 10             	add    $0x10,%esp
80104d72:	85 c0                	test   %eax,%eax
80104d74:	78 77                	js     80104ded <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104d76:	83 ec 08             	sub    $0x8,%esp
80104d79:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d7c:	50                   	push   %eax
80104d7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d80:	50                   	push   %eax
80104d81:	e8 3c e2 ff ff       	call   80102fc2 <pipealloc>
80104d86:	83 c4 10             	add    $0x10,%esp
80104d89:	85 c0                	test   %eax,%eax
80104d8b:	78 67                	js     80104df4 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d90:	e8 14 f5 ff ff       	call   801042a9 <fdalloc>
80104d95:	89 c3                	mov    %eax,%ebx
80104d97:	85 c0                	test   %eax,%eax
80104d99:	78 21                	js     80104dbc <sys_pipe+0x61>
80104d9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d9e:	e8 06 f5 ff ff       	call   801042a9 <fdalloc>
80104da3:	85 c0                	test   %eax,%eax
80104da5:	78 15                	js     80104dbc <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104da7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104daa:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104dac:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104daf:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104db2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dba:	c9                   	leave  
80104dbb:	c3                   	ret    
    if(fd0 >= 0)
80104dbc:	85 db                	test   %ebx,%ebx
80104dbe:	78 0d                	js     80104dcd <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104dc0:	e8 cc e6 ff ff       	call   80103491 <myproc>
80104dc5:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104dcc:	00 
    fileclose(rf);
80104dcd:	83 ec 0c             	sub    $0xc,%esp
80104dd0:	ff 75 f0             	pushl  -0x10(%ebp)
80104dd3:	e8 07 bf ff ff       	call   80100cdf <fileclose>
    fileclose(wf);
80104dd8:	83 c4 04             	add    $0x4,%esp
80104ddb:	ff 75 ec             	pushl  -0x14(%ebp)
80104dde:	e8 fc be ff ff       	call   80100cdf <fileclose>
    return -1;
80104de3:	83 c4 10             	add    $0x10,%esp
80104de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104deb:	eb ca                	jmp    80104db7 <sys_pipe+0x5c>
    return -1;
80104ded:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104df2:	eb c3                	jmp    80104db7 <sys_pipe+0x5c>
    return -1;
80104df4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104df9:	eb bc                	jmp    80104db7 <sys_pipe+0x5c>

80104dfb <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104dfb:	55                   	push   %ebp
80104dfc:	89 e5                	mov    %esp,%ebp
80104dfe:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104e01:	e8 03 e8 ff ff       	call   80103609 <fork>
}
80104e06:	c9                   	leave  
80104e07:	c3                   	ret    

80104e08 <sys_exit>:

int
sys_exit(void)
{
80104e08:	55                   	push   %ebp
80104e09:	89 e5                	mov    %esp,%ebp
80104e0b:	83 ec 08             	sub    $0x8,%esp
  exit();
80104e0e:	e8 2d ea ff ff       	call   80103840 <exit>
  return 0;  // not reached
}
80104e13:	b8 00 00 00 00       	mov    $0x0,%eax
80104e18:	c9                   	leave  
80104e19:	c3                   	ret    

80104e1a <sys_wait>:

int
sys_wait(void)
{
80104e1a:	55                   	push   %ebp
80104e1b:	89 e5                	mov    %esp,%ebp
80104e1d:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104e20:	e8 a4 eb ff ff       	call   801039c9 <wait>
}
80104e25:	c9                   	leave  
80104e26:	c3                   	ret    

80104e27 <sys_kill>:

int
sys_kill(void)
{
80104e27:	55                   	push   %ebp
80104e28:	89 e5                	mov    %esp,%ebp
80104e2a:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e30:	50                   	push   %eax
80104e31:	6a 00                	push   $0x0
80104e33:	e8 f2 f2 ff ff       	call   8010412a <argint>
80104e38:	83 c4 10             	add    $0x10,%esp
80104e3b:	85 c0                	test   %eax,%eax
80104e3d:	78 10                	js     80104e4f <sys_kill+0x28>
    return -1;
  return kill(pid);
80104e3f:	83 ec 0c             	sub    $0xc,%esp
80104e42:	ff 75 f4             	pushl  -0xc(%ebp)
80104e45:	e8 7c ec ff ff       	call   80103ac6 <kill>
80104e4a:	83 c4 10             	add    $0x10,%esp
}
80104e4d:	c9                   	leave  
80104e4e:	c3                   	ret    
    return -1;
80104e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e54:	eb f7                	jmp    80104e4d <sys_kill+0x26>

80104e56 <sys_getpid>:

int
sys_getpid(void)
{
80104e56:	55                   	push   %ebp
80104e57:	89 e5                	mov    %esp,%ebp
80104e59:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104e5c:	e8 30 e6 ff ff       	call   80103491 <myproc>
80104e61:	8b 40 10             	mov    0x10(%eax),%eax
}
80104e64:	c9                   	leave  
80104e65:	c3                   	ret    

80104e66 <sys_sbrk>:

int
sys_sbrk(void)
{
80104e66:	55                   	push   %ebp
80104e67:	89 e5                	mov    %esp,%ebp
80104e69:	53                   	push   %ebx
80104e6a:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104e6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e70:	50                   	push   %eax
80104e71:	6a 00                	push   $0x0
80104e73:	e8 b2 f2 ff ff       	call   8010412a <argint>
80104e78:	83 c4 10             	add    $0x10,%esp
80104e7b:	85 c0                	test   %eax,%eax
80104e7d:	78 27                	js     80104ea6 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104e7f:	e8 0d e6 ff ff       	call   80103491 <myproc>
80104e84:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104e86:	83 ec 0c             	sub    $0xc,%esp
80104e89:	ff 75 f4             	pushl  -0xc(%ebp)
80104e8c:	e8 0b e7 ff ff       	call   8010359c <growproc>
80104e91:	83 c4 10             	add    $0x10,%esp
80104e94:	85 c0                	test   %eax,%eax
80104e96:	78 07                	js     80104e9f <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104e98:	89 d8                	mov    %ebx,%eax
80104e9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e9d:	c9                   	leave  
80104e9e:	c3                   	ret    
    return -1;
80104e9f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104ea4:	eb f2                	jmp    80104e98 <sys_sbrk+0x32>
    return -1;
80104ea6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104eab:	eb eb                	jmp    80104e98 <sys_sbrk+0x32>

80104ead <sys_sleep>:

int
sys_sleep(void)
{
80104ead:	55                   	push   %ebp
80104eae:	89 e5                	mov    %esp,%ebp
80104eb0:	53                   	push   %ebx
80104eb1:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104eb7:	50                   	push   %eax
80104eb8:	6a 00                	push   $0x0
80104eba:	e8 6b f2 ff ff       	call   8010412a <argint>
80104ebf:	83 c4 10             	add    $0x10,%esp
80104ec2:	85 c0                	test   %eax,%eax
80104ec4:	78 75                	js     80104f3b <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104ec6:	83 ec 0c             	sub    $0xc,%esp
80104ec9:	68 80 4c 13 80       	push   $0x80134c80
80104ece:	e8 60 ef ff ff       	call   80103e33 <acquire>
  ticks0 = ticks;
80104ed3:	8b 1d c0 54 13 80    	mov    0x801354c0,%ebx
  while(ticks - ticks0 < n){
80104ed9:	83 c4 10             	add    $0x10,%esp
80104edc:	a1 c0 54 13 80       	mov    0x801354c0,%eax
80104ee1:	29 d8                	sub    %ebx,%eax
80104ee3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ee6:	73 39                	jae    80104f21 <sys_sleep+0x74>
    if(myproc()->killed){
80104ee8:	e8 a4 e5 ff ff       	call   80103491 <myproc>
80104eed:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ef1:	75 17                	jne    80104f0a <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104ef3:	83 ec 08             	sub    $0x8,%esp
80104ef6:	68 80 4c 13 80       	push   $0x80134c80
80104efb:	68 c0 54 13 80       	push   $0x801354c0
80104f00:	e8 33 ea ff ff       	call   80103938 <sleep>
80104f05:	83 c4 10             	add    $0x10,%esp
80104f08:	eb d2                	jmp    80104edc <sys_sleep+0x2f>
      release(&tickslock);
80104f0a:	83 ec 0c             	sub    $0xc,%esp
80104f0d:	68 80 4c 13 80       	push   $0x80134c80
80104f12:	e8 81 ef ff ff       	call   80103e98 <release>
      return -1;
80104f17:	83 c4 10             	add    $0x10,%esp
80104f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f1f:	eb 15                	jmp    80104f36 <sys_sleep+0x89>
  }
  release(&tickslock);
80104f21:	83 ec 0c             	sub    $0xc,%esp
80104f24:	68 80 4c 13 80       	push   $0x80134c80
80104f29:	e8 6a ef ff ff       	call   80103e98 <release>
  return 0;
80104f2e:	83 c4 10             	add    $0x10,%esp
80104f31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f39:	c9                   	leave  
80104f3a:	c3                   	ret    
    return -1;
80104f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f40:	eb f4                	jmp    80104f36 <sys_sleep+0x89>

80104f42 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104f42:	55                   	push   %ebp
80104f43:	89 e5                	mov    %esp,%ebp
80104f45:	53                   	push   %ebx
80104f46:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104f49:	68 80 4c 13 80       	push   $0x80134c80
80104f4e:	e8 e0 ee ff ff       	call   80103e33 <acquire>
  xticks = ticks;
80104f53:	8b 1d c0 54 13 80    	mov    0x801354c0,%ebx
  release(&tickslock);
80104f59:	c7 04 24 80 4c 13 80 	movl   $0x80134c80,(%esp)
80104f60:	e8 33 ef ff ff       	call   80103e98 <release>
  return xticks;
}
80104f65:	89 d8                	mov    %ebx,%eax
80104f67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f6a:	c9                   	leave  
80104f6b:	c3                   	ret    

80104f6c <sys_dump_physmem>:

int
sys_dump_physmem(void) {
80104f6c:	55                   	push   %ebp
80104f6d:	89 e5                	mov    %esp,%ebp
80104f6f:	83 ec 1c             	sub    $0x1c,%esp
    int* frames;
    int* pids;
    int numframes;
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104f72:	6a 04                	push   $0x4
80104f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f77:	50                   	push   %eax
80104f78:	6a 00                	push   $0x0
80104f7a:	e8 d3 f1 ff ff       	call   80104152 <argptr>
80104f7f:	83 c4 10             	add    $0x10,%esp
80104f82:	85 c0                	test   %eax,%eax
80104f84:	78 42                	js     80104fc8 <sys_dump_physmem+0x5c>
80104f86:	83 ec 04             	sub    $0x4,%esp
80104f89:	6a 04                	push   $0x4
80104f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f8e:	50                   	push   %eax
80104f8f:	6a 01                	push   $0x1
80104f91:	e8 bc f1 ff ff       	call   80104152 <argptr>
80104f96:	83 c4 10             	add    $0x10,%esp
80104f99:	85 c0                	test   %eax,%eax
80104f9b:	78 32                	js     80104fcf <sys_dump_physmem+0x63>
    argint(2, &numframes) < 0) {
80104f9d:	83 ec 08             	sub    $0x8,%esp
80104fa0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fa3:	50                   	push   %eax
80104fa4:	6a 02                	push   $0x2
80104fa6:	e8 7f f1 ff ff       	call   8010412a <argint>
    if (argptr(0, (void*)&frames, sizeof(int*)) < 0 || argptr(1, (void*)&pids, sizeof(int*)) < 0 ||
80104fab:	83 c4 10             	add    $0x10,%esp
80104fae:	85 c0                	test   %eax,%eax
80104fb0:	78 24                	js     80104fd6 <sys_dump_physmem+0x6a>
        return -1;
    }
    return dump_physmem(frames, pids, numframes);
80104fb2:	83 ec 04             	sub    $0x4,%esp
80104fb5:	ff 75 ec             	pushl  -0x14(%ebp)
80104fb8:	ff 75 f0             	pushl  -0x10(%ebp)
80104fbb:	ff 75 f4             	pushl  -0xc(%ebp)
80104fbe:	e8 58 d3 ff ff       	call   8010231b <dump_physmem>
80104fc3:	83 c4 10             	add    $0x10,%esp
80104fc6:	c9                   	leave  
80104fc7:	c3                   	ret    
        return -1;
80104fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fcd:	eb f7                	jmp    80104fc6 <sys_dump_physmem+0x5a>
80104fcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd4:	eb f0                	jmp    80104fc6 <sys_dump_physmem+0x5a>
80104fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fdb:	eb e9                	jmp    80104fc6 <sys_dump_physmem+0x5a>

80104fdd <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104fdd:	1e                   	push   %ds
  pushl %es
80104fde:	06                   	push   %es
  pushl %fs
80104fdf:	0f a0                	push   %fs
  pushl %gs
80104fe1:	0f a8                	push   %gs
  pushal
80104fe3:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104fe4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104fe8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104fea:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104fec:	54                   	push   %esp
  call trap
80104fed:	e8 e3 00 00 00       	call   801050d5 <trap>
  addl $4, %esp
80104ff2:	83 c4 04             	add    $0x4,%esp

80104ff5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104ff5:	61                   	popa   
  popl %gs
80104ff6:	0f a9                	pop    %gs
  popl %fs
80104ff8:	0f a1                	pop    %fs
  popl %es
80104ffa:	07                   	pop    %es
  popl %ds
80104ffb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104ffc:	83 c4 08             	add    $0x8,%esp
  iret
80104fff:	cf                   	iret   

80105000 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105000:	55                   	push   %ebp
80105001:	89 e5                	mov    %esp,%ebp
80105003:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80105006:	b8 00 00 00 00       	mov    $0x0,%eax
8010500b:	eb 4a                	jmp    80105057 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010500d:	8b 0c 85 08 a0 12 80 	mov    -0x7fed5ff8(,%eax,4),%ecx
80105014:	66 89 0c c5 c0 4c 13 	mov    %cx,-0x7fecb340(,%eax,8)
8010501b:	80 
8010501c:	66 c7 04 c5 c2 4c 13 	movw   $0x8,-0x7fecb33e(,%eax,8)
80105023:	80 08 00 
80105026:	c6 04 c5 c4 4c 13 80 	movb   $0x0,-0x7fecb33c(,%eax,8)
8010502d:	00 
8010502e:	0f b6 14 c5 c5 4c 13 	movzbl -0x7fecb33b(,%eax,8),%edx
80105035:	80 
80105036:	83 e2 f0             	and    $0xfffffff0,%edx
80105039:	83 ca 0e             	or     $0xe,%edx
8010503c:	83 e2 8f             	and    $0xffffff8f,%edx
8010503f:	83 ca 80             	or     $0xffffff80,%edx
80105042:	88 14 c5 c5 4c 13 80 	mov    %dl,-0x7fecb33b(,%eax,8)
80105049:	c1 e9 10             	shr    $0x10,%ecx
8010504c:	66 89 0c c5 c6 4c 13 	mov    %cx,-0x7fecb33a(,%eax,8)
80105053:	80 
  for(i = 0; i < 256; i++)
80105054:	83 c0 01             	add    $0x1,%eax
80105057:	3d ff 00 00 00       	cmp    $0xff,%eax
8010505c:	7e af                	jle    8010500d <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010505e:	8b 15 08 a1 12 80    	mov    0x8012a108,%edx
80105064:	66 89 15 c0 4e 13 80 	mov    %dx,0x80134ec0
8010506b:	66 c7 05 c2 4e 13 80 	movw   $0x8,0x80134ec2
80105072:	08 00 
80105074:	c6 05 c4 4e 13 80 00 	movb   $0x0,0x80134ec4
8010507b:	0f b6 05 c5 4e 13 80 	movzbl 0x80134ec5,%eax
80105082:	83 c8 0f             	or     $0xf,%eax
80105085:	83 e0 ef             	and    $0xffffffef,%eax
80105088:	83 c8 e0             	or     $0xffffffe0,%eax
8010508b:	a2 c5 4e 13 80       	mov    %al,0x80134ec5
80105090:	c1 ea 10             	shr    $0x10,%edx
80105093:	66 89 15 c6 4e 13 80 	mov    %dx,0x80134ec6

  initlock(&tickslock, "time");
8010509a:	83 ec 08             	sub    $0x8,%esp
8010509d:	68 fd 6e 10 80       	push   $0x80106efd
801050a2:	68 80 4c 13 80       	push   $0x80134c80
801050a7:	e8 4b ec ff ff       	call   80103cf7 <initlock>
}
801050ac:	83 c4 10             	add    $0x10,%esp
801050af:	c9                   	leave  
801050b0:	c3                   	ret    

801050b1 <idtinit>:

void
idtinit(void)
{
801050b1:	55                   	push   %ebp
801050b2:	89 e5                	mov    %esp,%ebp
801050b4:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801050b7:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
801050bd:	b8 c0 4c 13 80       	mov    $0x80134cc0,%eax
801050c2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801050c6:	c1 e8 10             	shr    $0x10,%eax
801050c9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801050cd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801050d0:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801050d3:	c9                   	leave  
801050d4:	c3                   	ret    

801050d5 <trap>:

void
trap(struct trapframe *tf)
{
801050d5:	55                   	push   %ebp
801050d6:	89 e5                	mov    %esp,%ebp
801050d8:	57                   	push   %edi
801050d9:	56                   	push   %esi
801050da:	53                   	push   %ebx
801050db:	83 ec 1c             	sub    $0x1c,%esp
801050de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801050e1:	8b 43 30             	mov    0x30(%ebx),%eax
801050e4:	83 f8 40             	cmp    $0x40,%eax
801050e7:	74 13                	je     801050fc <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801050e9:	83 e8 20             	sub    $0x20,%eax
801050ec:	83 f8 1f             	cmp    $0x1f,%eax
801050ef:	0f 87 3a 01 00 00    	ja     8010522f <trap+0x15a>
801050f5:	ff 24 85 a4 6f 10 80 	jmp    *-0x7fef905c(,%eax,4)
    if(myproc()->killed)
801050fc:	e8 90 e3 ff ff       	call   80103491 <myproc>
80105101:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105105:	75 1f                	jne    80105126 <trap+0x51>
    myproc()->tf = tf;
80105107:	e8 85 e3 ff ff       	call   80103491 <myproc>
8010510c:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
8010510f:	e8 d9 f0 ff ff       	call   801041ed <syscall>
    if(myproc()->killed)
80105114:	e8 78 e3 ff ff       	call   80103491 <myproc>
80105119:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010511d:	74 7e                	je     8010519d <trap+0xc8>
      exit();
8010511f:	e8 1c e7 ff ff       	call   80103840 <exit>
80105124:	eb 77                	jmp    8010519d <trap+0xc8>
      exit();
80105126:	e8 15 e7 ff ff       	call   80103840 <exit>
8010512b:	eb da                	jmp    80105107 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010512d:	e8 44 e3 ff ff       	call   80103476 <cpuid>
80105132:	85 c0                	test   %eax,%eax
80105134:	74 6f                	je     801051a5 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105136:	e8 e6 d4 ff ff       	call   80102621 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010513b:	e8 51 e3 ff ff       	call   80103491 <myproc>
80105140:	85 c0                	test   %eax,%eax
80105142:	74 1c                	je     80105160 <trap+0x8b>
80105144:	e8 48 e3 ff ff       	call   80103491 <myproc>
80105149:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010514d:	74 11                	je     80105160 <trap+0x8b>
8010514f:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105153:	83 e0 03             	and    $0x3,%eax
80105156:	66 83 f8 03          	cmp    $0x3,%ax
8010515a:	0f 84 62 01 00 00    	je     801052c2 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105160:	e8 2c e3 ff ff       	call   80103491 <myproc>
80105165:	85 c0                	test   %eax,%eax
80105167:	74 0f                	je     80105178 <trap+0xa3>
80105169:	e8 23 e3 ff ff       	call   80103491 <myproc>
8010516e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105172:	0f 84 54 01 00 00    	je     801052cc <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105178:	e8 14 e3 ff ff       	call   80103491 <myproc>
8010517d:	85 c0                	test   %eax,%eax
8010517f:	74 1c                	je     8010519d <trap+0xc8>
80105181:	e8 0b e3 ff ff       	call   80103491 <myproc>
80105186:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010518a:	74 11                	je     8010519d <trap+0xc8>
8010518c:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105190:	83 e0 03             	and    $0x3,%eax
80105193:	66 83 f8 03          	cmp    $0x3,%ax
80105197:	0f 84 43 01 00 00    	je     801052e0 <trap+0x20b>
    exit();
}
8010519d:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051a0:	5b                   	pop    %ebx
801051a1:	5e                   	pop    %esi
801051a2:	5f                   	pop    %edi
801051a3:	5d                   	pop    %ebp
801051a4:	c3                   	ret    
      acquire(&tickslock);
801051a5:	83 ec 0c             	sub    $0xc,%esp
801051a8:	68 80 4c 13 80       	push   $0x80134c80
801051ad:	e8 81 ec ff ff       	call   80103e33 <acquire>
      ticks++;
801051b2:	83 05 c0 54 13 80 01 	addl   $0x1,0x801354c0
      wakeup(&ticks);
801051b9:	c7 04 24 c0 54 13 80 	movl   $0x801354c0,(%esp)
801051c0:	e8 d8 e8 ff ff       	call   80103a9d <wakeup>
      release(&tickslock);
801051c5:	c7 04 24 80 4c 13 80 	movl   $0x80134c80,(%esp)
801051cc:	e8 c7 ec ff ff       	call   80103e98 <release>
801051d1:	83 c4 10             	add    $0x10,%esp
801051d4:	e9 5d ff ff ff       	jmp    80105136 <trap+0x61>
    ideintr();
801051d9:	e8 a1 cb ff ff       	call   80101d7f <ideintr>
    lapiceoi();
801051de:	e8 3e d4 ff ff       	call   80102621 <lapiceoi>
    break;
801051e3:	e9 53 ff ff ff       	jmp    8010513b <trap+0x66>
    kbdintr();
801051e8:	e8 78 d2 ff ff       	call   80102465 <kbdintr>
    lapiceoi();
801051ed:	e8 2f d4 ff ff       	call   80102621 <lapiceoi>
    break;
801051f2:	e9 44 ff ff ff       	jmp    8010513b <trap+0x66>
    uartintr();
801051f7:	e8 05 02 00 00       	call   80105401 <uartintr>
    lapiceoi();
801051fc:	e8 20 d4 ff ff       	call   80102621 <lapiceoi>
    break;
80105201:	e9 35 ff ff ff       	jmp    8010513b <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105206:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105209:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010520d:	e8 64 e2 ff ff       	call   80103476 <cpuid>
80105212:	57                   	push   %edi
80105213:	0f b7 f6             	movzwl %si,%esi
80105216:	56                   	push   %esi
80105217:	50                   	push   %eax
80105218:	68 08 6f 10 80       	push   $0x80106f08
8010521d:	e8 e9 b3 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105222:	e8 fa d3 ff ff       	call   80102621 <lapiceoi>
    break;
80105227:	83 c4 10             	add    $0x10,%esp
8010522a:	e9 0c ff ff ff       	jmp    8010513b <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010522f:	e8 5d e2 ff ff       	call   80103491 <myproc>
80105234:	85 c0                	test   %eax,%eax
80105236:	74 5f                	je     80105297 <trap+0x1c2>
80105238:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010523c:	74 59                	je     80105297 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010523e:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105241:	8b 43 38             	mov    0x38(%ebx),%eax
80105244:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105247:	e8 2a e2 ff ff       	call   80103476 <cpuid>
8010524c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010524f:	8b 53 34             	mov    0x34(%ebx),%edx
80105252:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105255:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105258:	e8 34 e2 ff ff       	call   80103491 <myproc>
8010525d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105260:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105263:	e8 29 e2 ff ff       	call   80103491 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105268:	57                   	push   %edi
80105269:	ff 75 e4             	pushl  -0x1c(%ebp)
8010526c:	ff 75 e0             	pushl  -0x20(%ebp)
8010526f:	ff 75 dc             	pushl  -0x24(%ebp)
80105272:	56                   	push   %esi
80105273:	ff 75 d8             	pushl  -0x28(%ebp)
80105276:	ff 70 10             	pushl  0x10(%eax)
80105279:	68 60 6f 10 80       	push   $0x80106f60
8010527e:	e8 88 b3 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105283:	83 c4 20             	add    $0x20,%esp
80105286:	e8 06 e2 ff ff       	call   80103491 <myproc>
8010528b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105292:	e9 a4 fe ff ff       	jmp    8010513b <trap+0x66>
80105297:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010529a:	8b 73 38             	mov    0x38(%ebx),%esi
8010529d:	e8 d4 e1 ff ff       	call   80103476 <cpuid>
801052a2:	83 ec 0c             	sub    $0xc,%esp
801052a5:	57                   	push   %edi
801052a6:	56                   	push   %esi
801052a7:	50                   	push   %eax
801052a8:	ff 73 30             	pushl  0x30(%ebx)
801052ab:	68 2c 6f 10 80       	push   $0x80106f2c
801052b0:	e8 56 b3 ff ff       	call   8010060b <cprintf>
      panic("trap");
801052b5:	83 c4 14             	add    $0x14,%esp
801052b8:	68 02 6f 10 80       	push   $0x80106f02
801052bd:	e8 86 b0 ff ff       	call   80100348 <panic>
    exit();
801052c2:	e8 79 e5 ff ff       	call   80103840 <exit>
801052c7:	e9 94 fe ff ff       	jmp    80105160 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801052cc:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801052d0:	0f 85 a2 fe ff ff    	jne    80105178 <trap+0xa3>
    yield();
801052d6:	e8 2b e6 ff ff       	call   80103906 <yield>
801052db:	e9 98 fe ff ff       	jmp    80105178 <trap+0xa3>
    exit();
801052e0:	e8 5b e5 ff ff       	call   80103840 <exit>
801052e5:	e9 b3 fe ff ff       	jmp    8010519d <trap+0xc8>

801052ea <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801052ea:	55                   	push   %ebp
801052eb:	89 e5                	mov    %esp,%ebp
  if(!uart)
801052ed:	83 3d c4 a5 12 80 00 	cmpl   $0x0,0x8012a5c4
801052f4:	74 15                	je     8010530b <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052f6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052fb:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801052fc:	a8 01                	test   $0x1,%al
801052fe:	74 12                	je     80105312 <uartgetc+0x28>
80105300:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105305:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105306:	0f b6 c0             	movzbl %al,%eax
}
80105309:	5d                   	pop    %ebp
8010530a:	c3                   	ret    
    return -1;
8010530b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105310:	eb f7                	jmp    80105309 <uartgetc+0x1f>
    return -1;
80105312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105317:	eb f0                	jmp    80105309 <uartgetc+0x1f>

80105319 <uartputc>:
  if(!uart)
80105319:	83 3d c4 a5 12 80 00 	cmpl   $0x0,0x8012a5c4
80105320:	74 3b                	je     8010535d <uartputc+0x44>
{
80105322:	55                   	push   %ebp
80105323:	89 e5                	mov    %esp,%ebp
80105325:	53                   	push   %ebx
80105326:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105329:	bb 00 00 00 00       	mov    $0x0,%ebx
8010532e:	eb 10                	jmp    80105340 <uartputc+0x27>
    microdelay(10);
80105330:	83 ec 0c             	sub    $0xc,%esp
80105333:	6a 0a                	push   $0xa
80105335:	e8 06 d3 ff ff       	call   80102640 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010533a:	83 c3 01             	add    $0x1,%ebx
8010533d:	83 c4 10             	add    $0x10,%esp
80105340:	83 fb 7f             	cmp    $0x7f,%ebx
80105343:	7f 0a                	jg     8010534f <uartputc+0x36>
80105345:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010534a:	ec                   	in     (%dx),%al
8010534b:	a8 20                	test   $0x20,%al
8010534d:	74 e1                	je     80105330 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010534f:	8b 45 08             	mov    0x8(%ebp),%eax
80105352:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105357:	ee                   	out    %al,(%dx)
}
80105358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010535b:	c9                   	leave  
8010535c:	c3                   	ret    
8010535d:	f3 c3                	repz ret 

8010535f <uartinit>:
{
8010535f:	55                   	push   %ebp
80105360:	89 e5                	mov    %esp,%ebp
80105362:	56                   	push   %esi
80105363:	53                   	push   %ebx
80105364:	b9 00 00 00 00       	mov    $0x0,%ecx
80105369:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010536e:	89 c8                	mov    %ecx,%eax
80105370:	ee                   	out    %al,(%dx)
80105371:	be fb 03 00 00       	mov    $0x3fb,%esi
80105376:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010537b:	89 f2                	mov    %esi,%edx
8010537d:	ee                   	out    %al,(%dx)
8010537e:	b8 0c 00 00 00       	mov    $0xc,%eax
80105383:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105388:	ee                   	out    %al,(%dx)
80105389:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010538e:	89 c8                	mov    %ecx,%eax
80105390:	89 da                	mov    %ebx,%edx
80105392:	ee                   	out    %al,(%dx)
80105393:	b8 03 00 00 00       	mov    $0x3,%eax
80105398:	89 f2                	mov    %esi,%edx
8010539a:	ee                   	out    %al,(%dx)
8010539b:	ba fc 03 00 00       	mov    $0x3fc,%edx
801053a0:	89 c8                	mov    %ecx,%eax
801053a2:	ee                   	out    %al,(%dx)
801053a3:	b8 01 00 00 00       	mov    $0x1,%eax
801053a8:	89 da                	mov    %ebx,%edx
801053aa:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801053ab:	ba fd 03 00 00       	mov    $0x3fd,%edx
801053b0:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801053b1:	3c ff                	cmp    $0xff,%al
801053b3:	74 45                	je     801053fa <uartinit+0x9b>
  uart = 1;
801053b5:	c7 05 c4 a5 12 80 01 	movl   $0x1,0x8012a5c4
801053bc:	00 00 00 
801053bf:	ba fa 03 00 00       	mov    $0x3fa,%edx
801053c4:	ec                   	in     (%dx),%al
801053c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053ca:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801053cb:	83 ec 08             	sub    $0x8,%esp
801053ce:	6a 00                	push   $0x0
801053d0:	6a 04                	push   $0x4
801053d2:	e8 b3 cb ff ff       	call   80101f8a <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801053d7:	83 c4 10             	add    $0x10,%esp
801053da:	bb 24 70 10 80       	mov    $0x80107024,%ebx
801053df:	eb 12                	jmp    801053f3 <uartinit+0x94>
    uartputc(*p);
801053e1:	83 ec 0c             	sub    $0xc,%esp
801053e4:	0f be c0             	movsbl %al,%eax
801053e7:	50                   	push   %eax
801053e8:	e8 2c ff ff ff       	call   80105319 <uartputc>
  for(p="xv6...\n"; *p; p++)
801053ed:	83 c3 01             	add    $0x1,%ebx
801053f0:	83 c4 10             	add    $0x10,%esp
801053f3:	0f b6 03             	movzbl (%ebx),%eax
801053f6:	84 c0                	test   %al,%al
801053f8:	75 e7                	jne    801053e1 <uartinit+0x82>
}
801053fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801053fd:	5b                   	pop    %ebx
801053fe:	5e                   	pop    %esi
801053ff:	5d                   	pop    %ebp
80105400:	c3                   	ret    

80105401 <uartintr>:

void
uartintr(void)
{
80105401:	55                   	push   %ebp
80105402:	89 e5                	mov    %esp,%ebp
80105404:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105407:	68 ea 52 10 80       	push   $0x801052ea
8010540c:	e8 2d b3 ff ff       	call   8010073e <consoleintr>
}
80105411:	83 c4 10             	add    $0x10,%esp
80105414:	c9                   	leave  
80105415:	c3                   	ret    

80105416 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105416:	6a 00                	push   $0x0
  pushl $0
80105418:	6a 00                	push   $0x0
  jmp alltraps
8010541a:	e9 be fb ff ff       	jmp    80104fdd <alltraps>

8010541f <vector1>:
.globl vector1
vector1:
  pushl $0
8010541f:	6a 00                	push   $0x0
  pushl $1
80105421:	6a 01                	push   $0x1
  jmp alltraps
80105423:	e9 b5 fb ff ff       	jmp    80104fdd <alltraps>

80105428 <vector2>:
.globl vector2
vector2:
  pushl $0
80105428:	6a 00                	push   $0x0
  pushl $2
8010542a:	6a 02                	push   $0x2
  jmp alltraps
8010542c:	e9 ac fb ff ff       	jmp    80104fdd <alltraps>

80105431 <vector3>:
.globl vector3
vector3:
  pushl $0
80105431:	6a 00                	push   $0x0
  pushl $3
80105433:	6a 03                	push   $0x3
  jmp alltraps
80105435:	e9 a3 fb ff ff       	jmp    80104fdd <alltraps>

8010543a <vector4>:
.globl vector4
vector4:
  pushl $0
8010543a:	6a 00                	push   $0x0
  pushl $4
8010543c:	6a 04                	push   $0x4
  jmp alltraps
8010543e:	e9 9a fb ff ff       	jmp    80104fdd <alltraps>

80105443 <vector5>:
.globl vector5
vector5:
  pushl $0
80105443:	6a 00                	push   $0x0
  pushl $5
80105445:	6a 05                	push   $0x5
  jmp alltraps
80105447:	e9 91 fb ff ff       	jmp    80104fdd <alltraps>

8010544c <vector6>:
.globl vector6
vector6:
  pushl $0
8010544c:	6a 00                	push   $0x0
  pushl $6
8010544e:	6a 06                	push   $0x6
  jmp alltraps
80105450:	e9 88 fb ff ff       	jmp    80104fdd <alltraps>

80105455 <vector7>:
.globl vector7
vector7:
  pushl $0
80105455:	6a 00                	push   $0x0
  pushl $7
80105457:	6a 07                	push   $0x7
  jmp alltraps
80105459:	e9 7f fb ff ff       	jmp    80104fdd <alltraps>

8010545e <vector8>:
.globl vector8
vector8:
  pushl $8
8010545e:	6a 08                	push   $0x8
  jmp alltraps
80105460:	e9 78 fb ff ff       	jmp    80104fdd <alltraps>

80105465 <vector9>:
.globl vector9
vector9:
  pushl $0
80105465:	6a 00                	push   $0x0
  pushl $9
80105467:	6a 09                	push   $0x9
  jmp alltraps
80105469:	e9 6f fb ff ff       	jmp    80104fdd <alltraps>

8010546e <vector10>:
.globl vector10
vector10:
  pushl $10
8010546e:	6a 0a                	push   $0xa
  jmp alltraps
80105470:	e9 68 fb ff ff       	jmp    80104fdd <alltraps>

80105475 <vector11>:
.globl vector11
vector11:
  pushl $11
80105475:	6a 0b                	push   $0xb
  jmp alltraps
80105477:	e9 61 fb ff ff       	jmp    80104fdd <alltraps>

8010547c <vector12>:
.globl vector12
vector12:
  pushl $12
8010547c:	6a 0c                	push   $0xc
  jmp alltraps
8010547e:	e9 5a fb ff ff       	jmp    80104fdd <alltraps>

80105483 <vector13>:
.globl vector13
vector13:
  pushl $13
80105483:	6a 0d                	push   $0xd
  jmp alltraps
80105485:	e9 53 fb ff ff       	jmp    80104fdd <alltraps>

8010548a <vector14>:
.globl vector14
vector14:
  pushl $14
8010548a:	6a 0e                	push   $0xe
  jmp alltraps
8010548c:	e9 4c fb ff ff       	jmp    80104fdd <alltraps>

80105491 <vector15>:
.globl vector15
vector15:
  pushl $0
80105491:	6a 00                	push   $0x0
  pushl $15
80105493:	6a 0f                	push   $0xf
  jmp alltraps
80105495:	e9 43 fb ff ff       	jmp    80104fdd <alltraps>

8010549a <vector16>:
.globl vector16
vector16:
  pushl $0
8010549a:	6a 00                	push   $0x0
  pushl $16
8010549c:	6a 10                	push   $0x10
  jmp alltraps
8010549e:	e9 3a fb ff ff       	jmp    80104fdd <alltraps>

801054a3 <vector17>:
.globl vector17
vector17:
  pushl $17
801054a3:	6a 11                	push   $0x11
  jmp alltraps
801054a5:	e9 33 fb ff ff       	jmp    80104fdd <alltraps>

801054aa <vector18>:
.globl vector18
vector18:
  pushl $0
801054aa:	6a 00                	push   $0x0
  pushl $18
801054ac:	6a 12                	push   $0x12
  jmp alltraps
801054ae:	e9 2a fb ff ff       	jmp    80104fdd <alltraps>

801054b3 <vector19>:
.globl vector19
vector19:
  pushl $0
801054b3:	6a 00                	push   $0x0
  pushl $19
801054b5:	6a 13                	push   $0x13
  jmp alltraps
801054b7:	e9 21 fb ff ff       	jmp    80104fdd <alltraps>

801054bc <vector20>:
.globl vector20
vector20:
  pushl $0
801054bc:	6a 00                	push   $0x0
  pushl $20
801054be:	6a 14                	push   $0x14
  jmp alltraps
801054c0:	e9 18 fb ff ff       	jmp    80104fdd <alltraps>

801054c5 <vector21>:
.globl vector21
vector21:
  pushl $0
801054c5:	6a 00                	push   $0x0
  pushl $21
801054c7:	6a 15                	push   $0x15
  jmp alltraps
801054c9:	e9 0f fb ff ff       	jmp    80104fdd <alltraps>

801054ce <vector22>:
.globl vector22
vector22:
  pushl $0
801054ce:	6a 00                	push   $0x0
  pushl $22
801054d0:	6a 16                	push   $0x16
  jmp alltraps
801054d2:	e9 06 fb ff ff       	jmp    80104fdd <alltraps>

801054d7 <vector23>:
.globl vector23
vector23:
  pushl $0
801054d7:	6a 00                	push   $0x0
  pushl $23
801054d9:	6a 17                	push   $0x17
  jmp alltraps
801054db:	e9 fd fa ff ff       	jmp    80104fdd <alltraps>

801054e0 <vector24>:
.globl vector24
vector24:
  pushl $0
801054e0:	6a 00                	push   $0x0
  pushl $24
801054e2:	6a 18                	push   $0x18
  jmp alltraps
801054e4:	e9 f4 fa ff ff       	jmp    80104fdd <alltraps>

801054e9 <vector25>:
.globl vector25
vector25:
  pushl $0
801054e9:	6a 00                	push   $0x0
  pushl $25
801054eb:	6a 19                	push   $0x19
  jmp alltraps
801054ed:	e9 eb fa ff ff       	jmp    80104fdd <alltraps>

801054f2 <vector26>:
.globl vector26
vector26:
  pushl $0
801054f2:	6a 00                	push   $0x0
  pushl $26
801054f4:	6a 1a                	push   $0x1a
  jmp alltraps
801054f6:	e9 e2 fa ff ff       	jmp    80104fdd <alltraps>

801054fb <vector27>:
.globl vector27
vector27:
  pushl $0
801054fb:	6a 00                	push   $0x0
  pushl $27
801054fd:	6a 1b                	push   $0x1b
  jmp alltraps
801054ff:	e9 d9 fa ff ff       	jmp    80104fdd <alltraps>

80105504 <vector28>:
.globl vector28
vector28:
  pushl $0
80105504:	6a 00                	push   $0x0
  pushl $28
80105506:	6a 1c                	push   $0x1c
  jmp alltraps
80105508:	e9 d0 fa ff ff       	jmp    80104fdd <alltraps>

8010550d <vector29>:
.globl vector29
vector29:
  pushl $0
8010550d:	6a 00                	push   $0x0
  pushl $29
8010550f:	6a 1d                	push   $0x1d
  jmp alltraps
80105511:	e9 c7 fa ff ff       	jmp    80104fdd <alltraps>

80105516 <vector30>:
.globl vector30
vector30:
  pushl $0
80105516:	6a 00                	push   $0x0
  pushl $30
80105518:	6a 1e                	push   $0x1e
  jmp alltraps
8010551a:	e9 be fa ff ff       	jmp    80104fdd <alltraps>

8010551f <vector31>:
.globl vector31
vector31:
  pushl $0
8010551f:	6a 00                	push   $0x0
  pushl $31
80105521:	6a 1f                	push   $0x1f
  jmp alltraps
80105523:	e9 b5 fa ff ff       	jmp    80104fdd <alltraps>

80105528 <vector32>:
.globl vector32
vector32:
  pushl $0
80105528:	6a 00                	push   $0x0
  pushl $32
8010552a:	6a 20                	push   $0x20
  jmp alltraps
8010552c:	e9 ac fa ff ff       	jmp    80104fdd <alltraps>

80105531 <vector33>:
.globl vector33
vector33:
  pushl $0
80105531:	6a 00                	push   $0x0
  pushl $33
80105533:	6a 21                	push   $0x21
  jmp alltraps
80105535:	e9 a3 fa ff ff       	jmp    80104fdd <alltraps>

8010553a <vector34>:
.globl vector34
vector34:
  pushl $0
8010553a:	6a 00                	push   $0x0
  pushl $34
8010553c:	6a 22                	push   $0x22
  jmp alltraps
8010553e:	e9 9a fa ff ff       	jmp    80104fdd <alltraps>

80105543 <vector35>:
.globl vector35
vector35:
  pushl $0
80105543:	6a 00                	push   $0x0
  pushl $35
80105545:	6a 23                	push   $0x23
  jmp alltraps
80105547:	e9 91 fa ff ff       	jmp    80104fdd <alltraps>

8010554c <vector36>:
.globl vector36
vector36:
  pushl $0
8010554c:	6a 00                	push   $0x0
  pushl $36
8010554e:	6a 24                	push   $0x24
  jmp alltraps
80105550:	e9 88 fa ff ff       	jmp    80104fdd <alltraps>

80105555 <vector37>:
.globl vector37
vector37:
  pushl $0
80105555:	6a 00                	push   $0x0
  pushl $37
80105557:	6a 25                	push   $0x25
  jmp alltraps
80105559:	e9 7f fa ff ff       	jmp    80104fdd <alltraps>

8010555e <vector38>:
.globl vector38
vector38:
  pushl $0
8010555e:	6a 00                	push   $0x0
  pushl $38
80105560:	6a 26                	push   $0x26
  jmp alltraps
80105562:	e9 76 fa ff ff       	jmp    80104fdd <alltraps>

80105567 <vector39>:
.globl vector39
vector39:
  pushl $0
80105567:	6a 00                	push   $0x0
  pushl $39
80105569:	6a 27                	push   $0x27
  jmp alltraps
8010556b:	e9 6d fa ff ff       	jmp    80104fdd <alltraps>

80105570 <vector40>:
.globl vector40
vector40:
  pushl $0
80105570:	6a 00                	push   $0x0
  pushl $40
80105572:	6a 28                	push   $0x28
  jmp alltraps
80105574:	e9 64 fa ff ff       	jmp    80104fdd <alltraps>

80105579 <vector41>:
.globl vector41
vector41:
  pushl $0
80105579:	6a 00                	push   $0x0
  pushl $41
8010557b:	6a 29                	push   $0x29
  jmp alltraps
8010557d:	e9 5b fa ff ff       	jmp    80104fdd <alltraps>

80105582 <vector42>:
.globl vector42
vector42:
  pushl $0
80105582:	6a 00                	push   $0x0
  pushl $42
80105584:	6a 2a                	push   $0x2a
  jmp alltraps
80105586:	e9 52 fa ff ff       	jmp    80104fdd <alltraps>

8010558b <vector43>:
.globl vector43
vector43:
  pushl $0
8010558b:	6a 00                	push   $0x0
  pushl $43
8010558d:	6a 2b                	push   $0x2b
  jmp alltraps
8010558f:	e9 49 fa ff ff       	jmp    80104fdd <alltraps>

80105594 <vector44>:
.globl vector44
vector44:
  pushl $0
80105594:	6a 00                	push   $0x0
  pushl $44
80105596:	6a 2c                	push   $0x2c
  jmp alltraps
80105598:	e9 40 fa ff ff       	jmp    80104fdd <alltraps>

8010559d <vector45>:
.globl vector45
vector45:
  pushl $0
8010559d:	6a 00                	push   $0x0
  pushl $45
8010559f:	6a 2d                	push   $0x2d
  jmp alltraps
801055a1:	e9 37 fa ff ff       	jmp    80104fdd <alltraps>

801055a6 <vector46>:
.globl vector46
vector46:
  pushl $0
801055a6:	6a 00                	push   $0x0
  pushl $46
801055a8:	6a 2e                	push   $0x2e
  jmp alltraps
801055aa:	e9 2e fa ff ff       	jmp    80104fdd <alltraps>

801055af <vector47>:
.globl vector47
vector47:
  pushl $0
801055af:	6a 00                	push   $0x0
  pushl $47
801055b1:	6a 2f                	push   $0x2f
  jmp alltraps
801055b3:	e9 25 fa ff ff       	jmp    80104fdd <alltraps>

801055b8 <vector48>:
.globl vector48
vector48:
  pushl $0
801055b8:	6a 00                	push   $0x0
  pushl $48
801055ba:	6a 30                	push   $0x30
  jmp alltraps
801055bc:	e9 1c fa ff ff       	jmp    80104fdd <alltraps>

801055c1 <vector49>:
.globl vector49
vector49:
  pushl $0
801055c1:	6a 00                	push   $0x0
  pushl $49
801055c3:	6a 31                	push   $0x31
  jmp alltraps
801055c5:	e9 13 fa ff ff       	jmp    80104fdd <alltraps>

801055ca <vector50>:
.globl vector50
vector50:
  pushl $0
801055ca:	6a 00                	push   $0x0
  pushl $50
801055cc:	6a 32                	push   $0x32
  jmp alltraps
801055ce:	e9 0a fa ff ff       	jmp    80104fdd <alltraps>

801055d3 <vector51>:
.globl vector51
vector51:
  pushl $0
801055d3:	6a 00                	push   $0x0
  pushl $51
801055d5:	6a 33                	push   $0x33
  jmp alltraps
801055d7:	e9 01 fa ff ff       	jmp    80104fdd <alltraps>

801055dc <vector52>:
.globl vector52
vector52:
  pushl $0
801055dc:	6a 00                	push   $0x0
  pushl $52
801055de:	6a 34                	push   $0x34
  jmp alltraps
801055e0:	e9 f8 f9 ff ff       	jmp    80104fdd <alltraps>

801055e5 <vector53>:
.globl vector53
vector53:
  pushl $0
801055e5:	6a 00                	push   $0x0
  pushl $53
801055e7:	6a 35                	push   $0x35
  jmp alltraps
801055e9:	e9 ef f9 ff ff       	jmp    80104fdd <alltraps>

801055ee <vector54>:
.globl vector54
vector54:
  pushl $0
801055ee:	6a 00                	push   $0x0
  pushl $54
801055f0:	6a 36                	push   $0x36
  jmp alltraps
801055f2:	e9 e6 f9 ff ff       	jmp    80104fdd <alltraps>

801055f7 <vector55>:
.globl vector55
vector55:
  pushl $0
801055f7:	6a 00                	push   $0x0
  pushl $55
801055f9:	6a 37                	push   $0x37
  jmp alltraps
801055fb:	e9 dd f9 ff ff       	jmp    80104fdd <alltraps>

80105600 <vector56>:
.globl vector56
vector56:
  pushl $0
80105600:	6a 00                	push   $0x0
  pushl $56
80105602:	6a 38                	push   $0x38
  jmp alltraps
80105604:	e9 d4 f9 ff ff       	jmp    80104fdd <alltraps>

80105609 <vector57>:
.globl vector57
vector57:
  pushl $0
80105609:	6a 00                	push   $0x0
  pushl $57
8010560b:	6a 39                	push   $0x39
  jmp alltraps
8010560d:	e9 cb f9 ff ff       	jmp    80104fdd <alltraps>

80105612 <vector58>:
.globl vector58
vector58:
  pushl $0
80105612:	6a 00                	push   $0x0
  pushl $58
80105614:	6a 3a                	push   $0x3a
  jmp alltraps
80105616:	e9 c2 f9 ff ff       	jmp    80104fdd <alltraps>

8010561b <vector59>:
.globl vector59
vector59:
  pushl $0
8010561b:	6a 00                	push   $0x0
  pushl $59
8010561d:	6a 3b                	push   $0x3b
  jmp alltraps
8010561f:	e9 b9 f9 ff ff       	jmp    80104fdd <alltraps>

80105624 <vector60>:
.globl vector60
vector60:
  pushl $0
80105624:	6a 00                	push   $0x0
  pushl $60
80105626:	6a 3c                	push   $0x3c
  jmp alltraps
80105628:	e9 b0 f9 ff ff       	jmp    80104fdd <alltraps>

8010562d <vector61>:
.globl vector61
vector61:
  pushl $0
8010562d:	6a 00                	push   $0x0
  pushl $61
8010562f:	6a 3d                	push   $0x3d
  jmp alltraps
80105631:	e9 a7 f9 ff ff       	jmp    80104fdd <alltraps>

80105636 <vector62>:
.globl vector62
vector62:
  pushl $0
80105636:	6a 00                	push   $0x0
  pushl $62
80105638:	6a 3e                	push   $0x3e
  jmp alltraps
8010563a:	e9 9e f9 ff ff       	jmp    80104fdd <alltraps>

8010563f <vector63>:
.globl vector63
vector63:
  pushl $0
8010563f:	6a 00                	push   $0x0
  pushl $63
80105641:	6a 3f                	push   $0x3f
  jmp alltraps
80105643:	e9 95 f9 ff ff       	jmp    80104fdd <alltraps>

80105648 <vector64>:
.globl vector64
vector64:
  pushl $0
80105648:	6a 00                	push   $0x0
  pushl $64
8010564a:	6a 40                	push   $0x40
  jmp alltraps
8010564c:	e9 8c f9 ff ff       	jmp    80104fdd <alltraps>

80105651 <vector65>:
.globl vector65
vector65:
  pushl $0
80105651:	6a 00                	push   $0x0
  pushl $65
80105653:	6a 41                	push   $0x41
  jmp alltraps
80105655:	e9 83 f9 ff ff       	jmp    80104fdd <alltraps>

8010565a <vector66>:
.globl vector66
vector66:
  pushl $0
8010565a:	6a 00                	push   $0x0
  pushl $66
8010565c:	6a 42                	push   $0x42
  jmp alltraps
8010565e:	e9 7a f9 ff ff       	jmp    80104fdd <alltraps>

80105663 <vector67>:
.globl vector67
vector67:
  pushl $0
80105663:	6a 00                	push   $0x0
  pushl $67
80105665:	6a 43                	push   $0x43
  jmp alltraps
80105667:	e9 71 f9 ff ff       	jmp    80104fdd <alltraps>

8010566c <vector68>:
.globl vector68
vector68:
  pushl $0
8010566c:	6a 00                	push   $0x0
  pushl $68
8010566e:	6a 44                	push   $0x44
  jmp alltraps
80105670:	e9 68 f9 ff ff       	jmp    80104fdd <alltraps>

80105675 <vector69>:
.globl vector69
vector69:
  pushl $0
80105675:	6a 00                	push   $0x0
  pushl $69
80105677:	6a 45                	push   $0x45
  jmp alltraps
80105679:	e9 5f f9 ff ff       	jmp    80104fdd <alltraps>

8010567e <vector70>:
.globl vector70
vector70:
  pushl $0
8010567e:	6a 00                	push   $0x0
  pushl $70
80105680:	6a 46                	push   $0x46
  jmp alltraps
80105682:	e9 56 f9 ff ff       	jmp    80104fdd <alltraps>

80105687 <vector71>:
.globl vector71
vector71:
  pushl $0
80105687:	6a 00                	push   $0x0
  pushl $71
80105689:	6a 47                	push   $0x47
  jmp alltraps
8010568b:	e9 4d f9 ff ff       	jmp    80104fdd <alltraps>

80105690 <vector72>:
.globl vector72
vector72:
  pushl $0
80105690:	6a 00                	push   $0x0
  pushl $72
80105692:	6a 48                	push   $0x48
  jmp alltraps
80105694:	e9 44 f9 ff ff       	jmp    80104fdd <alltraps>

80105699 <vector73>:
.globl vector73
vector73:
  pushl $0
80105699:	6a 00                	push   $0x0
  pushl $73
8010569b:	6a 49                	push   $0x49
  jmp alltraps
8010569d:	e9 3b f9 ff ff       	jmp    80104fdd <alltraps>

801056a2 <vector74>:
.globl vector74
vector74:
  pushl $0
801056a2:	6a 00                	push   $0x0
  pushl $74
801056a4:	6a 4a                	push   $0x4a
  jmp alltraps
801056a6:	e9 32 f9 ff ff       	jmp    80104fdd <alltraps>

801056ab <vector75>:
.globl vector75
vector75:
  pushl $0
801056ab:	6a 00                	push   $0x0
  pushl $75
801056ad:	6a 4b                	push   $0x4b
  jmp alltraps
801056af:	e9 29 f9 ff ff       	jmp    80104fdd <alltraps>

801056b4 <vector76>:
.globl vector76
vector76:
  pushl $0
801056b4:	6a 00                	push   $0x0
  pushl $76
801056b6:	6a 4c                	push   $0x4c
  jmp alltraps
801056b8:	e9 20 f9 ff ff       	jmp    80104fdd <alltraps>

801056bd <vector77>:
.globl vector77
vector77:
  pushl $0
801056bd:	6a 00                	push   $0x0
  pushl $77
801056bf:	6a 4d                	push   $0x4d
  jmp alltraps
801056c1:	e9 17 f9 ff ff       	jmp    80104fdd <alltraps>

801056c6 <vector78>:
.globl vector78
vector78:
  pushl $0
801056c6:	6a 00                	push   $0x0
  pushl $78
801056c8:	6a 4e                	push   $0x4e
  jmp alltraps
801056ca:	e9 0e f9 ff ff       	jmp    80104fdd <alltraps>

801056cf <vector79>:
.globl vector79
vector79:
  pushl $0
801056cf:	6a 00                	push   $0x0
  pushl $79
801056d1:	6a 4f                	push   $0x4f
  jmp alltraps
801056d3:	e9 05 f9 ff ff       	jmp    80104fdd <alltraps>

801056d8 <vector80>:
.globl vector80
vector80:
  pushl $0
801056d8:	6a 00                	push   $0x0
  pushl $80
801056da:	6a 50                	push   $0x50
  jmp alltraps
801056dc:	e9 fc f8 ff ff       	jmp    80104fdd <alltraps>

801056e1 <vector81>:
.globl vector81
vector81:
  pushl $0
801056e1:	6a 00                	push   $0x0
  pushl $81
801056e3:	6a 51                	push   $0x51
  jmp alltraps
801056e5:	e9 f3 f8 ff ff       	jmp    80104fdd <alltraps>

801056ea <vector82>:
.globl vector82
vector82:
  pushl $0
801056ea:	6a 00                	push   $0x0
  pushl $82
801056ec:	6a 52                	push   $0x52
  jmp alltraps
801056ee:	e9 ea f8 ff ff       	jmp    80104fdd <alltraps>

801056f3 <vector83>:
.globl vector83
vector83:
  pushl $0
801056f3:	6a 00                	push   $0x0
  pushl $83
801056f5:	6a 53                	push   $0x53
  jmp alltraps
801056f7:	e9 e1 f8 ff ff       	jmp    80104fdd <alltraps>

801056fc <vector84>:
.globl vector84
vector84:
  pushl $0
801056fc:	6a 00                	push   $0x0
  pushl $84
801056fe:	6a 54                	push   $0x54
  jmp alltraps
80105700:	e9 d8 f8 ff ff       	jmp    80104fdd <alltraps>

80105705 <vector85>:
.globl vector85
vector85:
  pushl $0
80105705:	6a 00                	push   $0x0
  pushl $85
80105707:	6a 55                	push   $0x55
  jmp alltraps
80105709:	e9 cf f8 ff ff       	jmp    80104fdd <alltraps>

8010570e <vector86>:
.globl vector86
vector86:
  pushl $0
8010570e:	6a 00                	push   $0x0
  pushl $86
80105710:	6a 56                	push   $0x56
  jmp alltraps
80105712:	e9 c6 f8 ff ff       	jmp    80104fdd <alltraps>

80105717 <vector87>:
.globl vector87
vector87:
  pushl $0
80105717:	6a 00                	push   $0x0
  pushl $87
80105719:	6a 57                	push   $0x57
  jmp alltraps
8010571b:	e9 bd f8 ff ff       	jmp    80104fdd <alltraps>

80105720 <vector88>:
.globl vector88
vector88:
  pushl $0
80105720:	6a 00                	push   $0x0
  pushl $88
80105722:	6a 58                	push   $0x58
  jmp alltraps
80105724:	e9 b4 f8 ff ff       	jmp    80104fdd <alltraps>

80105729 <vector89>:
.globl vector89
vector89:
  pushl $0
80105729:	6a 00                	push   $0x0
  pushl $89
8010572b:	6a 59                	push   $0x59
  jmp alltraps
8010572d:	e9 ab f8 ff ff       	jmp    80104fdd <alltraps>

80105732 <vector90>:
.globl vector90
vector90:
  pushl $0
80105732:	6a 00                	push   $0x0
  pushl $90
80105734:	6a 5a                	push   $0x5a
  jmp alltraps
80105736:	e9 a2 f8 ff ff       	jmp    80104fdd <alltraps>

8010573b <vector91>:
.globl vector91
vector91:
  pushl $0
8010573b:	6a 00                	push   $0x0
  pushl $91
8010573d:	6a 5b                	push   $0x5b
  jmp alltraps
8010573f:	e9 99 f8 ff ff       	jmp    80104fdd <alltraps>

80105744 <vector92>:
.globl vector92
vector92:
  pushl $0
80105744:	6a 00                	push   $0x0
  pushl $92
80105746:	6a 5c                	push   $0x5c
  jmp alltraps
80105748:	e9 90 f8 ff ff       	jmp    80104fdd <alltraps>

8010574d <vector93>:
.globl vector93
vector93:
  pushl $0
8010574d:	6a 00                	push   $0x0
  pushl $93
8010574f:	6a 5d                	push   $0x5d
  jmp alltraps
80105751:	e9 87 f8 ff ff       	jmp    80104fdd <alltraps>

80105756 <vector94>:
.globl vector94
vector94:
  pushl $0
80105756:	6a 00                	push   $0x0
  pushl $94
80105758:	6a 5e                	push   $0x5e
  jmp alltraps
8010575a:	e9 7e f8 ff ff       	jmp    80104fdd <alltraps>

8010575f <vector95>:
.globl vector95
vector95:
  pushl $0
8010575f:	6a 00                	push   $0x0
  pushl $95
80105761:	6a 5f                	push   $0x5f
  jmp alltraps
80105763:	e9 75 f8 ff ff       	jmp    80104fdd <alltraps>

80105768 <vector96>:
.globl vector96
vector96:
  pushl $0
80105768:	6a 00                	push   $0x0
  pushl $96
8010576a:	6a 60                	push   $0x60
  jmp alltraps
8010576c:	e9 6c f8 ff ff       	jmp    80104fdd <alltraps>

80105771 <vector97>:
.globl vector97
vector97:
  pushl $0
80105771:	6a 00                	push   $0x0
  pushl $97
80105773:	6a 61                	push   $0x61
  jmp alltraps
80105775:	e9 63 f8 ff ff       	jmp    80104fdd <alltraps>

8010577a <vector98>:
.globl vector98
vector98:
  pushl $0
8010577a:	6a 00                	push   $0x0
  pushl $98
8010577c:	6a 62                	push   $0x62
  jmp alltraps
8010577e:	e9 5a f8 ff ff       	jmp    80104fdd <alltraps>

80105783 <vector99>:
.globl vector99
vector99:
  pushl $0
80105783:	6a 00                	push   $0x0
  pushl $99
80105785:	6a 63                	push   $0x63
  jmp alltraps
80105787:	e9 51 f8 ff ff       	jmp    80104fdd <alltraps>

8010578c <vector100>:
.globl vector100
vector100:
  pushl $0
8010578c:	6a 00                	push   $0x0
  pushl $100
8010578e:	6a 64                	push   $0x64
  jmp alltraps
80105790:	e9 48 f8 ff ff       	jmp    80104fdd <alltraps>

80105795 <vector101>:
.globl vector101
vector101:
  pushl $0
80105795:	6a 00                	push   $0x0
  pushl $101
80105797:	6a 65                	push   $0x65
  jmp alltraps
80105799:	e9 3f f8 ff ff       	jmp    80104fdd <alltraps>

8010579e <vector102>:
.globl vector102
vector102:
  pushl $0
8010579e:	6a 00                	push   $0x0
  pushl $102
801057a0:	6a 66                	push   $0x66
  jmp alltraps
801057a2:	e9 36 f8 ff ff       	jmp    80104fdd <alltraps>

801057a7 <vector103>:
.globl vector103
vector103:
  pushl $0
801057a7:	6a 00                	push   $0x0
  pushl $103
801057a9:	6a 67                	push   $0x67
  jmp alltraps
801057ab:	e9 2d f8 ff ff       	jmp    80104fdd <alltraps>

801057b0 <vector104>:
.globl vector104
vector104:
  pushl $0
801057b0:	6a 00                	push   $0x0
  pushl $104
801057b2:	6a 68                	push   $0x68
  jmp alltraps
801057b4:	e9 24 f8 ff ff       	jmp    80104fdd <alltraps>

801057b9 <vector105>:
.globl vector105
vector105:
  pushl $0
801057b9:	6a 00                	push   $0x0
  pushl $105
801057bb:	6a 69                	push   $0x69
  jmp alltraps
801057bd:	e9 1b f8 ff ff       	jmp    80104fdd <alltraps>

801057c2 <vector106>:
.globl vector106
vector106:
  pushl $0
801057c2:	6a 00                	push   $0x0
  pushl $106
801057c4:	6a 6a                	push   $0x6a
  jmp alltraps
801057c6:	e9 12 f8 ff ff       	jmp    80104fdd <alltraps>

801057cb <vector107>:
.globl vector107
vector107:
  pushl $0
801057cb:	6a 00                	push   $0x0
  pushl $107
801057cd:	6a 6b                	push   $0x6b
  jmp alltraps
801057cf:	e9 09 f8 ff ff       	jmp    80104fdd <alltraps>

801057d4 <vector108>:
.globl vector108
vector108:
  pushl $0
801057d4:	6a 00                	push   $0x0
  pushl $108
801057d6:	6a 6c                	push   $0x6c
  jmp alltraps
801057d8:	e9 00 f8 ff ff       	jmp    80104fdd <alltraps>

801057dd <vector109>:
.globl vector109
vector109:
  pushl $0
801057dd:	6a 00                	push   $0x0
  pushl $109
801057df:	6a 6d                	push   $0x6d
  jmp alltraps
801057e1:	e9 f7 f7 ff ff       	jmp    80104fdd <alltraps>

801057e6 <vector110>:
.globl vector110
vector110:
  pushl $0
801057e6:	6a 00                	push   $0x0
  pushl $110
801057e8:	6a 6e                	push   $0x6e
  jmp alltraps
801057ea:	e9 ee f7 ff ff       	jmp    80104fdd <alltraps>

801057ef <vector111>:
.globl vector111
vector111:
  pushl $0
801057ef:	6a 00                	push   $0x0
  pushl $111
801057f1:	6a 6f                	push   $0x6f
  jmp alltraps
801057f3:	e9 e5 f7 ff ff       	jmp    80104fdd <alltraps>

801057f8 <vector112>:
.globl vector112
vector112:
  pushl $0
801057f8:	6a 00                	push   $0x0
  pushl $112
801057fa:	6a 70                	push   $0x70
  jmp alltraps
801057fc:	e9 dc f7 ff ff       	jmp    80104fdd <alltraps>

80105801 <vector113>:
.globl vector113
vector113:
  pushl $0
80105801:	6a 00                	push   $0x0
  pushl $113
80105803:	6a 71                	push   $0x71
  jmp alltraps
80105805:	e9 d3 f7 ff ff       	jmp    80104fdd <alltraps>

8010580a <vector114>:
.globl vector114
vector114:
  pushl $0
8010580a:	6a 00                	push   $0x0
  pushl $114
8010580c:	6a 72                	push   $0x72
  jmp alltraps
8010580e:	e9 ca f7 ff ff       	jmp    80104fdd <alltraps>

80105813 <vector115>:
.globl vector115
vector115:
  pushl $0
80105813:	6a 00                	push   $0x0
  pushl $115
80105815:	6a 73                	push   $0x73
  jmp alltraps
80105817:	e9 c1 f7 ff ff       	jmp    80104fdd <alltraps>

8010581c <vector116>:
.globl vector116
vector116:
  pushl $0
8010581c:	6a 00                	push   $0x0
  pushl $116
8010581e:	6a 74                	push   $0x74
  jmp alltraps
80105820:	e9 b8 f7 ff ff       	jmp    80104fdd <alltraps>

80105825 <vector117>:
.globl vector117
vector117:
  pushl $0
80105825:	6a 00                	push   $0x0
  pushl $117
80105827:	6a 75                	push   $0x75
  jmp alltraps
80105829:	e9 af f7 ff ff       	jmp    80104fdd <alltraps>

8010582e <vector118>:
.globl vector118
vector118:
  pushl $0
8010582e:	6a 00                	push   $0x0
  pushl $118
80105830:	6a 76                	push   $0x76
  jmp alltraps
80105832:	e9 a6 f7 ff ff       	jmp    80104fdd <alltraps>

80105837 <vector119>:
.globl vector119
vector119:
  pushl $0
80105837:	6a 00                	push   $0x0
  pushl $119
80105839:	6a 77                	push   $0x77
  jmp alltraps
8010583b:	e9 9d f7 ff ff       	jmp    80104fdd <alltraps>

80105840 <vector120>:
.globl vector120
vector120:
  pushl $0
80105840:	6a 00                	push   $0x0
  pushl $120
80105842:	6a 78                	push   $0x78
  jmp alltraps
80105844:	e9 94 f7 ff ff       	jmp    80104fdd <alltraps>

80105849 <vector121>:
.globl vector121
vector121:
  pushl $0
80105849:	6a 00                	push   $0x0
  pushl $121
8010584b:	6a 79                	push   $0x79
  jmp alltraps
8010584d:	e9 8b f7 ff ff       	jmp    80104fdd <alltraps>

80105852 <vector122>:
.globl vector122
vector122:
  pushl $0
80105852:	6a 00                	push   $0x0
  pushl $122
80105854:	6a 7a                	push   $0x7a
  jmp alltraps
80105856:	e9 82 f7 ff ff       	jmp    80104fdd <alltraps>

8010585b <vector123>:
.globl vector123
vector123:
  pushl $0
8010585b:	6a 00                	push   $0x0
  pushl $123
8010585d:	6a 7b                	push   $0x7b
  jmp alltraps
8010585f:	e9 79 f7 ff ff       	jmp    80104fdd <alltraps>

80105864 <vector124>:
.globl vector124
vector124:
  pushl $0
80105864:	6a 00                	push   $0x0
  pushl $124
80105866:	6a 7c                	push   $0x7c
  jmp alltraps
80105868:	e9 70 f7 ff ff       	jmp    80104fdd <alltraps>

8010586d <vector125>:
.globl vector125
vector125:
  pushl $0
8010586d:	6a 00                	push   $0x0
  pushl $125
8010586f:	6a 7d                	push   $0x7d
  jmp alltraps
80105871:	e9 67 f7 ff ff       	jmp    80104fdd <alltraps>

80105876 <vector126>:
.globl vector126
vector126:
  pushl $0
80105876:	6a 00                	push   $0x0
  pushl $126
80105878:	6a 7e                	push   $0x7e
  jmp alltraps
8010587a:	e9 5e f7 ff ff       	jmp    80104fdd <alltraps>

8010587f <vector127>:
.globl vector127
vector127:
  pushl $0
8010587f:	6a 00                	push   $0x0
  pushl $127
80105881:	6a 7f                	push   $0x7f
  jmp alltraps
80105883:	e9 55 f7 ff ff       	jmp    80104fdd <alltraps>

80105888 <vector128>:
.globl vector128
vector128:
  pushl $0
80105888:	6a 00                	push   $0x0
  pushl $128
8010588a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010588f:	e9 49 f7 ff ff       	jmp    80104fdd <alltraps>

80105894 <vector129>:
.globl vector129
vector129:
  pushl $0
80105894:	6a 00                	push   $0x0
  pushl $129
80105896:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010589b:	e9 3d f7 ff ff       	jmp    80104fdd <alltraps>

801058a0 <vector130>:
.globl vector130
vector130:
  pushl $0
801058a0:	6a 00                	push   $0x0
  pushl $130
801058a2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801058a7:	e9 31 f7 ff ff       	jmp    80104fdd <alltraps>

801058ac <vector131>:
.globl vector131
vector131:
  pushl $0
801058ac:	6a 00                	push   $0x0
  pushl $131
801058ae:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801058b3:	e9 25 f7 ff ff       	jmp    80104fdd <alltraps>

801058b8 <vector132>:
.globl vector132
vector132:
  pushl $0
801058b8:	6a 00                	push   $0x0
  pushl $132
801058ba:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801058bf:	e9 19 f7 ff ff       	jmp    80104fdd <alltraps>

801058c4 <vector133>:
.globl vector133
vector133:
  pushl $0
801058c4:	6a 00                	push   $0x0
  pushl $133
801058c6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801058cb:	e9 0d f7 ff ff       	jmp    80104fdd <alltraps>

801058d0 <vector134>:
.globl vector134
vector134:
  pushl $0
801058d0:	6a 00                	push   $0x0
  pushl $134
801058d2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801058d7:	e9 01 f7 ff ff       	jmp    80104fdd <alltraps>

801058dc <vector135>:
.globl vector135
vector135:
  pushl $0
801058dc:	6a 00                	push   $0x0
  pushl $135
801058de:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801058e3:	e9 f5 f6 ff ff       	jmp    80104fdd <alltraps>

801058e8 <vector136>:
.globl vector136
vector136:
  pushl $0
801058e8:	6a 00                	push   $0x0
  pushl $136
801058ea:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801058ef:	e9 e9 f6 ff ff       	jmp    80104fdd <alltraps>

801058f4 <vector137>:
.globl vector137
vector137:
  pushl $0
801058f4:	6a 00                	push   $0x0
  pushl $137
801058f6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801058fb:	e9 dd f6 ff ff       	jmp    80104fdd <alltraps>

80105900 <vector138>:
.globl vector138
vector138:
  pushl $0
80105900:	6a 00                	push   $0x0
  pushl $138
80105902:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105907:	e9 d1 f6 ff ff       	jmp    80104fdd <alltraps>

8010590c <vector139>:
.globl vector139
vector139:
  pushl $0
8010590c:	6a 00                	push   $0x0
  pushl $139
8010590e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105913:	e9 c5 f6 ff ff       	jmp    80104fdd <alltraps>

80105918 <vector140>:
.globl vector140
vector140:
  pushl $0
80105918:	6a 00                	push   $0x0
  pushl $140
8010591a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010591f:	e9 b9 f6 ff ff       	jmp    80104fdd <alltraps>

80105924 <vector141>:
.globl vector141
vector141:
  pushl $0
80105924:	6a 00                	push   $0x0
  pushl $141
80105926:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010592b:	e9 ad f6 ff ff       	jmp    80104fdd <alltraps>

80105930 <vector142>:
.globl vector142
vector142:
  pushl $0
80105930:	6a 00                	push   $0x0
  pushl $142
80105932:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105937:	e9 a1 f6 ff ff       	jmp    80104fdd <alltraps>

8010593c <vector143>:
.globl vector143
vector143:
  pushl $0
8010593c:	6a 00                	push   $0x0
  pushl $143
8010593e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105943:	e9 95 f6 ff ff       	jmp    80104fdd <alltraps>

80105948 <vector144>:
.globl vector144
vector144:
  pushl $0
80105948:	6a 00                	push   $0x0
  pushl $144
8010594a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010594f:	e9 89 f6 ff ff       	jmp    80104fdd <alltraps>

80105954 <vector145>:
.globl vector145
vector145:
  pushl $0
80105954:	6a 00                	push   $0x0
  pushl $145
80105956:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010595b:	e9 7d f6 ff ff       	jmp    80104fdd <alltraps>

80105960 <vector146>:
.globl vector146
vector146:
  pushl $0
80105960:	6a 00                	push   $0x0
  pushl $146
80105962:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105967:	e9 71 f6 ff ff       	jmp    80104fdd <alltraps>

8010596c <vector147>:
.globl vector147
vector147:
  pushl $0
8010596c:	6a 00                	push   $0x0
  pushl $147
8010596e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105973:	e9 65 f6 ff ff       	jmp    80104fdd <alltraps>

80105978 <vector148>:
.globl vector148
vector148:
  pushl $0
80105978:	6a 00                	push   $0x0
  pushl $148
8010597a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010597f:	e9 59 f6 ff ff       	jmp    80104fdd <alltraps>

80105984 <vector149>:
.globl vector149
vector149:
  pushl $0
80105984:	6a 00                	push   $0x0
  pushl $149
80105986:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010598b:	e9 4d f6 ff ff       	jmp    80104fdd <alltraps>

80105990 <vector150>:
.globl vector150
vector150:
  pushl $0
80105990:	6a 00                	push   $0x0
  pushl $150
80105992:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105997:	e9 41 f6 ff ff       	jmp    80104fdd <alltraps>

8010599c <vector151>:
.globl vector151
vector151:
  pushl $0
8010599c:	6a 00                	push   $0x0
  pushl $151
8010599e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801059a3:	e9 35 f6 ff ff       	jmp    80104fdd <alltraps>

801059a8 <vector152>:
.globl vector152
vector152:
  pushl $0
801059a8:	6a 00                	push   $0x0
  pushl $152
801059aa:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801059af:	e9 29 f6 ff ff       	jmp    80104fdd <alltraps>

801059b4 <vector153>:
.globl vector153
vector153:
  pushl $0
801059b4:	6a 00                	push   $0x0
  pushl $153
801059b6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801059bb:	e9 1d f6 ff ff       	jmp    80104fdd <alltraps>

801059c0 <vector154>:
.globl vector154
vector154:
  pushl $0
801059c0:	6a 00                	push   $0x0
  pushl $154
801059c2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801059c7:	e9 11 f6 ff ff       	jmp    80104fdd <alltraps>

801059cc <vector155>:
.globl vector155
vector155:
  pushl $0
801059cc:	6a 00                	push   $0x0
  pushl $155
801059ce:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801059d3:	e9 05 f6 ff ff       	jmp    80104fdd <alltraps>

801059d8 <vector156>:
.globl vector156
vector156:
  pushl $0
801059d8:	6a 00                	push   $0x0
  pushl $156
801059da:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801059df:	e9 f9 f5 ff ff       	jmp    80104fdd <alltraps>

801059e4 <vector157>:
.globl vector157
vector157:
  pushl $0
801059e4:	6a 00                	push   $0x0
  pushl $157
801059e6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801059eb:	e9 ed f5 ff ff       	jmp    80104fdd <alltraps>

801059f0 <vector158>:
.globl vector158
vector158:
  pushl $0
801059f0:	6a 00                	push   $0x0
  pushl $158
801059f2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801059f7:	e9 e1 f5 ff ff       	jmp    80104fdd <alltraps>

801059fc <vector159>:
.globl vector159
vector159:
  pushl $0
801059fc:	6a 00                	push   $0x0
  pushl $159
801059fe:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105a03:	e9 d5 f5 ff ff       	jmp    80104fdd <alltraps>

80105a08 <vector160>:
.globl vector160
vector160:
  pushl $0
80105a08:	6a 00                	push   $0x0
  pushl $160
80105a0a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105a0f:	e9 c9 f5 ff ff       	jmp    80104fdd <alltraps>

80105a14 <vector161>:
.globl vector161
vector161:
  pushl $0
80105a14:	6a 00                	push   $0x0
  pushl $161
80105a16:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105a1b:	e9 bd f5 ff ff       	jmp    80104fdd <alltraps>

80105a20 <vector162>:
.globl vector162
vector162:
  pushl $0
80105a20:	6a 00                	push   $0x0
  pushl $162
80105a22:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105a27:	e9 b1 f5 ff ff       	jmp    80104fdd <alltraps>

80105a2c <vector163>:
.globl vector163
vector163:
  pushl $0
80105a2c:	6a 00                	push   $0x0
  pushl $163
80105a2e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105a33:	e9 a5 f5 ff ff       	jmp    80104fdd <alltraps>

80105a38 <vector164>:
.globl vector164
vector164:
  pushl $0
80105a38:	6a 00                	push   $0x0
  pushl $164
80105a3a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105a3f:	e9 99 f5 ff ff       	jmp    80104fdd <alltraps>

80105a44 <vector165>:
.globl vector165
vector165:
  pushl $0
80105a44:	6a 00                	push   $0x0
  pushl $165
80105a46:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105a4b:	e9 8d f5 ff ff       	jmp    80104fdd <alltraps>

80105a50 <vector166>:
.globl vector166
vector166:
  pushl $0
80105a50:	6a 00                	push   $0x0
  pushl $166
80105a52:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105a57:	e9 81 f5 ff ff       	jmp    80104fdd <alltraps>

80105a5c <vector167>:
.globl vector167
vector167:
  pushl $0
80105a5c:	6a 00                	push   $0x0
  pushl $167
80105a5e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105a63:	e9 75 f5 ff ff       	jmp    80104fdd <alltraps>

80105a68 <vector168>:
.globl vector168
vector168:
  pushl $0
80105a68:	6a 00                	push   $0x0
  pushl $168
80105a6a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105a6f:	e9 69 f5 ff ff       	jmp    80104fdd <alltraps>

80105a74 <vector169>:
.globl vector169
vector169:
  pushl $0
80105a74:	6a 00                	push   $0x0
  pushl $169
80105a76:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105a7b:	e9 5d f5 ff ff       	jmp    80104fdd <alltraps>

80105a80 <vector170>:
.globl vector170
vector170:
  pushl $0
80105a80:	6a 00                	push   $0x0
  pushl $170
80105a82:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a87:	e9 51 f5 ff ff       	jmp    80104fdd <alltraps>

80105a8c <vector171>:
.globl vector171
vector171:
  pushl $0
80105a8c:	6a 00                	push   $0x0
  pushl $171
80105a8e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a93:	e9 45 f5 ff ff       	jmp    80104fdd <alltraps>

80105a98 <vector172>:
.globl vector172
vector172:
  pushl $0
80105a98:	6a 00                	push   $0x0
  pushl $172
80105a9a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a9f:	e9 39 f5 ff ff       	jmp    80104fdd <alltraps>

80105aa4 <vector173>:
.globl vector173
vector173:
  pushl $0
80105aa4:	6a 00                	push   $0x0
  pushl $173
80105aa6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105aab:	e9 2d f5 ff ff       	jmp    80104fdd <alltraps>

80105ab0 <vector174>:
.globl vector174
vector174:
  pushl $0
80105ab0:	6a 00                	push   $0x0
  pushl $174
80105ab2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105ab7:	e9 21 f5 ff ff       	jmp    80104fdd <alltraps>

80105abc <vector175>:
.globl vector175
vector175:
  pushl $0
80105abc:	6a 00                	push   $0x0
  pushl $175
80105abe:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105ac3:	e9 15 f5 ff ff       	jmp    80104fdd <alltraps>

80105ac8 <vector176>:
.globl vector176
vector176:
  pushl $0
80105ac8:	6a 00                	push   $0x0
  pushl $176
80105aca:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105acf:	e9 09 f5 ff ff       	jmp    80104fdd <alltraps>

80105ad4 <vector177>:
.globl vector177
vector177:
  pushl $0
80105ad4:	6a 00                	push   $0x0
  pushl $177
80105ad6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105adb:	e9 fd f4 ff ff       	jmp    80104fdd <alltraps>

80105ae0 <vector178>:
.globl vector178
vector178:
  pushl $0
80105ae0:	6a 00                	push   $0x0
  pushl $178
80105ae2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105ae7:	e9 f1 f4 ff ff       	jmp    80104fdd <alltraps>

80105aec <vector179>:
.globl vector179
vector179:
  pushl $0
80105aec:	6a 00                	push   $0x0
  pushl $179
80105aee:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105af3:	e9 e5 f4 ff ff       	jmp    80104fdd <alltraps>

80105af8 <vector180>:
.globl vector180
vector180:
  pushl $0
80105af8:	6a 00                	push   $0x0
  pushl $180
80105afa:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105aff:	e9 d9 f4 ff ff       	jmp    80104fdd <alltraps>

80105b04 <vector181>:
.globl vector181
vector181:
  pushl $0
80105b04:	6a 00                	push   $0x0
  pushl $181
80105b06:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105b0b:	e9 cd f4 ff ff       	jmp    80104fdd <alltraps>

80105b10 <vector182>:
.globl vector182
vector182:
  pushl $0
80105b10:	6a 00                	push   $0x0
  pushl $182
80105b12:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105b17:	e9 c1 f4 ff ff       	jmp    80104fdd <alltraps>

80105b1c <vector183>:
.globl vector183
vector183:
  pushl $0
80105b1c:	6a 00                	push   $0x0
  pushl $183
80105b1e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105b23:	e9 b5 f4 ff ff       	jmp    80104fdd <alltraps>

80105b28 <vector184>:
.globl vector184
vector184:
  pushl $0
80105b28:	6a 00                	push   $0x0
  pushl $184
80105b2a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105b2f:	e9 a9 f4 ff ff       	jmp    80104fdd <alltraps>

80105b34 <vector185>:
.globl vector185
vector185:
  pushl $0
80105b34:	6a 00                	push   $0x0
  pushl $185
80105b36:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105b3b:	e9 9d f4 ff ff       	jmp    80104fdd <alltraps>

80105b40 <vector186>:
.globl vector186
vector186:
  pushl $0
80105b40:	6a 00                	push   $0x0
  pushl $186
80105b42:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105b47:	e9 91 f4 ff ff       	jmp    80104fdd <alltraps>

80105b4c <vector187>:
.globl vector187
vector187:
  pushl $0
80105b4c:	6a 00                	push   $0x0
  pushl $187
80105b4e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105b53:	e9 85 f4 ff ff       	jmp    80104fdd <alltraps>

80105b58 <vector188>:
.globl vector188
vector188:
  pushl $0
80105b58:	6a 00                	push   $0x0
  pushl $188
80105b5a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105b5f:	e9 79 f4 ff ff       	jmp    80104fdd <alltraps>

80105b64 <vector189>:
.globl vector189
vector189:
  pushl $0
80105b64:	6a 00                	push   $0x0
  pushl $189
80105b66:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105b6b:	e9 6d f4 ff ff       	jmp    80104fdd <alltraps>

80105b70 <vector190>:
.globl vector190
vector190:
  pushl $0
80105b70:	6a 00                	push   $0x0
  pushl $190
80105b72:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105b77:	e9 61 f4 ff ff       	jmp    80104fdd <alltraps>

80105b7c <vector191>:
.globl vector191
vector191:
  pushl $0
80105b7c:	6a 00                	push   $0x0
  pushl $191
80105b7e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105b83:	e9 55 f4 ff ff       	jmp    80104fdd <alltraps>

80105b88 <vector192>:
.globl vector192
vector192:
  pushl $0
80105b88:	6a 00                	push   $0x0
  pushl $192
80105b8a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b8f:	e9 49 f4 ff ff       	jmp    80104fdd <alltraps>

80105b94 <vector193>:
.globl vector193
vector193:
  pushl $0
80105b94:	6a 00                	push   $0x0
  pushl $193
80105b96:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b9b:	e9 3d f4 ff ff       	jmp    80104fdd <alltraps>

80105ba0 <vector194>:
.globl vector194
vector194:
  pushl $0
80105ba0:	6a 00                	push   $0x0
  pushl $194
80105ba2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105ba7:	e9 31 f4 ff ff       	jmp    80104fdd <alltraps>

80105bac <vector195>:
.globl vector195
vector195:
  pushl $0
80105bac:	6a 00                	push   $0x0
  pushl $195
80105bae:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105bb3:	e9 25 f4 ff ff       	jmp    80104fdd <alltraps>

80105bb8 <vector196>:
.globl vector196
vector196:
  pushl $0
80105bb8:	6a 00                	push   $0x0
  pushl $196
80105bba:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105bbf:	e9 19 f4 ff ff       	jmp    80104fdd <alltraps>

80105bc4 <vector197>:
.globl vector197
vector197:
  pushl $0
80105bc4:	6a 00                	push   $0x0
  pushl $197
80105bc6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105bcb:	e9 0d f4 ff ff       	jmp    80104fdd <alltraps>

80105bd0 <vector198>:
.globl vector198
vector198:
  pushl $0
80105bd0:	6a 00                	push   $0x0
  pushl $198
80105bd2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105bd7:	e9 01 f4 ff ff       	jmp    80104fdd <alltraps>

80105bdc <vector199>:
.globl vector199
vector199:
  pushl $0
80105bdc:	6a 00                	push   $0x0
  pushl $199
80105bde:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105be3:	e9 f5 f3 ff ff       	jmp    80104fdd <alltraps>

80105be8 <vector200>:
.globl vector200
vector200:
  pushl $0
80105be8:	6a 00                	push   $0x0
  pushl $200
80105bea:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105bef:	e9 e9 f3 ff ff       	jmp    80104fdd <alltraps>

80105bf4 <vector201>:
.globl vector201
vector201:
  pushl $0
80105bf4:	6a 00                	push   $0x0
  pushl $201
80105bf6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105bfb:	e9 dd f3 ff ff       	jmp    80104fdd <alltraps>

80105c00 <vector202>:
.globl vector202
vector202:
  pushl $0
80105c00:	6a 00                	push   $0x0
  pushl $202
80105c02:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105c07:	e9 d1 f3 ff ff       	jmp    80104fdd <alltraps>

80105c0c <vector203>:
.globl vector203
vector203:
  pushl $0
80105c0c:	6a 00                	push   $0x0
  pushl $203
80105c0e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105c13:	e9 c5 f3 ff ff       	jmp    80104fdd <alltraps>

80105c18 <vector204>:
.globl vector204
vector204:
  pushl $0
80105c18:	6a 00                	push   $0x0
  pushl $204
80105c1a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105c1f:	e9 b9 f3 ff ff       	jmp    80104fdd <alltraps>

80105c24 <vector205>:
.globl vector205
vector205:
  pushl $0
80105c24:	6a 00                	push   $0x0
  pushl $205
80105c26:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105c2b:	e9 ad f3 ff ff       	jmp    80104fdd <alltraps>

80105c30 <vector206>:
.globl vector206
vector206:
  pushl $0
80105c30:	6a 00                	push   $0x0
  pushl $206
80105c32:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105c37:	e9 a1 f3 ff ff       	jmp    80104fdd <alltraps>

80105c3c <vector207>:
.globl vector207
vector207:
  pushl $0
80105c3c:	6a 00                	push   $0x0
  pushl $207
80105c3e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105c43:	e9 95 f3 ff ff       	jmp    80104fdd <alltraps>

80105c48 <vector208>:
.globl vector208
vector208:
  pushl $0
80105c48:	6a 00                	push   $0x0
  pushl $208
80105c4a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105c4f:	e9 89 f3 ff ff       	jmp    80104fdd <alltraps>

80105c54 <vector209>:
.globl vector209
vector209:
  pushl $0
80105c54:	6a 00                	push   $0x0
  pushl $209
80105c56:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105c5b:	e9 7d f3 ff ff       	jmp    80104fdd <alltraps>

80105c60 <vector210>:
.globl vector210
vector210:
  pushl $0
80105c60:	6a 00                	push   $0x0
  pushl $210
80105c62:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105c67:	e9 71 f3 ff ff       	jmp    80104fdd <alltraps>

80105c6c <vector211>:
.globl vector211
vector211:
  pushl $0
80105c6c:	6a 00                	push   $0x0
  pushl $211
80105c6e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105c73:	e9 65 f3 ff ff       	jmp    80104fdd <alltraps>

80105c78 <vector212>:
.globl vector212
vector212:
  pushl $0
80105c78:	6a 00                	push   $0x0
  pushl $212
80105c7a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105c7f:	e9 59 f3 ff ff       	jmp    80104fdd <alltraps>

80105c84 <vector213>:
.globl vector213
vector213:
  pushl $0
80105c84:	6a 00                	push   $0x0
  pushl $213
80105c86:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c8b:	e9 4d f3 ff ff       	jmp    80104fdd <alltraps>

80105c90 <vector214>:
.globl vector214
vector214:
  pushl $0
80105c90:	6a 00                	push   $0x0
  pushl $214
80105c92:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c97:	e9 41 f3 ff ff       	jmp    80104fdd <alltraps>

80105c9c <vector215>:
.globl vector215
vector215:
  pushl $0
80105c9c:	6a 00                	push   $0x0
  pushl $215
80105c9e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105ca3:	e9 35 f3 ff ff       	jmp    80104fdd <alltraps>

80105ca8 <vector216>:
.globl vector216
vector216:
  pushl $0
80105ca8:	6a 00                	push   $0x0
  pushl $216
80105caa:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105caf:	e9 29 f3 ff ff       	jmp    80104fdd <alltraps>

80105cb4 <vector217>:
.globl vector217
vector217:
  pushl $0
80105cb4:	6a 00                	push   $0x0
  pushl $217
80105cb6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105cbb:	e9 1d f3 ff ff       	jmp    80104fdd <alltraps>

80105cc0 <vector218>:
.globl vector218
vector218:
  pushl $0
80105cc0:	6a 00                	push   $0x0
  pushl $218
80105cc2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105cc7:	e9 11 f3 ff ff       	jmp    80104fdd <alltraps>

80105ccc <vector219>:
.globl vector219
vector219:
  pushl $0
80105ccc:	6a 00                	push   $0x0
  pushl $219
80105cce:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105cd3:	e9 05 f3 ff ff       	jmp    80104fdd <alltraps>

80105cd8 <vector220>:
.globl vector220
vector220:
  pushl $0
80105cd8:	6a 00                	push   $0x0
  pushl $220
80105cda:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105cdf:	e9 f9 f2 ff ff       	jmp    80104fdd <alltraps>

80105ce4 <vector221>:
.globl vector221
vector221:
  pushl $0
80105ce4:	6a 00                	push   $0x0
  pushl $221
80105ce6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105ceb:	e9 ed f2 ff ff       	jmp    80104fdd <alltraps>

80105cf0 <vector222>:
.globl vector222
vector222:
  pushl $0
80105cf0:	6a 00                	push   $0x0
  pushl $222
80105cf2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105cf7:	e9 e1 f2 ff ff       	jmp    80104fdd <alltraps>

80105cfc <vector223>:
.globl vector223
vector223:
  pushl $0
80105cfc:	6a 00                	push   $0x0
  pushl $223
80105cfe:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105d03:	e9 d5 f2 ff ff       	jmp    80104fdd <alltraps>

80105d08 <vector224>:
.globl vector224
vector224:
  pushl $0
80105d08:	6a 00                	push   $0x0
  pushl $224
80105d0a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105d0f:	e9 c9 f2 ff ff       	jmp    80104fdd <alltraps>

80105d14 <vector225>:
.globl vector225
vector225:
  pushl $0
80105d14:	6a 00                	push   $0x0
  pushl $225
80105d16:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105d1b:	e9 bd f2 ff ff       	jmp    80104fdd <alltraps>

80105d20 <vector226>:
.globl vector226
vector226:
  pushl $0
80105d20:	6a 00                	push   $0x0
  pushl $226
80105d22:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105d27:	e9 b1 f2 ff ff       	jmp    80104fdd <alltraps>

80105d2c <vector227>:
.globl vector227
vector227:
  pushl $0
80105d2c:	6a 00                	push   $0x0
  pushl $227
80105d2e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105d33:	e9 a5 f2 ff ff       	jmp    80104fdd <alltraps>

80105d38 <vector228>:
.globl vector228
vector228:
  pushl $0
80105d38:	6a 00                	push   $0x0
  pushl $228
80105d3a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105d3f:	e9 99 f2 ff ff       	jmp    80104fdd <alltraps>

80105d44 <vector229>:
.globl vector229
vector229:
  pushl $0
80105d44:	6a 00                	push   $0x0
  pushl $229
80105d46:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105d4b:	e9 8d f2 ff ff       	jmp    80104fdd <alltraps>

80105d50 <vector230>:
.globl vector230
vector230:
  pushl $0
80105d50:	6a 00                	push   $0x0
  pushl $230
80105d52:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105d57:	e9 81 f2 ff ff       	jmp    80104fdd <alltraps>

80105d5c <vector231>:
.globl vector231
vector231:
  pushl $0
80105d5c:	6a 00                	push   $0x0
  pushl $231
80105d5e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105d63:	e9 75 f2 ff ff       	jmp    80104fdd <alltraps>

80105d68 <vector232>:
.globl vector232
vector232:
  pushl $0
80105d68:	6a 00                	push   $0x0
  pushl $232
80105d6a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105d6f:	e9 69 f2 ff ff       	jmp    80104fdd <alltraps>

80105d74 <vector233>:
.globl vector233
vector233:
  pushl $0
80105d74:	6a 00                	push   $0x0
  pushl $233
80105d76:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105d7b:	e9 5d f2 ff ff       	jmp    80104fdd <alltraps>

80105d80 <vector234>:
.globl vector234
vector234:
  pushl $0
80105d80:	6a 00                	push   $0x0
  pushl $234
80105d82:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d87:	e9 51 f2 ff ff       	jmp    80104fdd <alltraps>

80105d8c <vector235>:
.globl vector235
vector235:
  pushl $0
80105d8c:	6a 00                	push   $0x0
  pushl $235
80105d8e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d93:	e9 45 f2 ff ff       	jmp    80104fdd <alltraps>

80105d98 <vector236>:
.globl vector236
vector236:
  pushl $0
80105d98:	6a 00                	push   $0x0
  pushl $236
80105d9a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d9f:	e9 39 f2 ff ff       	jmp    80104fdd <alltraps>

80105da4 <vector237>:
.globl vector237
vector237:
  pushl $0
80105da4:	6a 00                	push   $0x0
  pushl $237
80105da6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105dab:	e9 2d f2 ff ff       	jmp    80104fdd <alltraps>

80105db0 <vector238>:
.globl vector238
vector238:
  pushl $0
80105db0:	6a 00                	push   $0x0
  pushl $238
80105db2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105db7:	e9 21 f2 ff ff       	jmp    80104fdd <alltraps>

80105dbc <vector239>:
.globl vector239
vector239:
  pushl $0
80105dbc:	6a 00                	push   $0x0
  pushl $239
80105dbe:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105dc3:	e9 15 f2 ff ff       	jmp    80104fdd <alltraps>

80105dc8 <vector240>:
.globl vector240
vector240:
  pushl $0
80105dc8:	6a 00                	push   $0x0
  pushl $240
80105dca:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105dcf:	e9 09 f2 ff ff       	jmp    80104fdd <alltraps>

80105dd4 <vector241>:
.globl vector241
vector241:
  pushl $0
80105dd4:	6a 00                	push   $0x0
  pushl $241
80105dd6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105ddb:	e9 fd f1 ff ff       	jmp    80104fdd <alltraps>

80105de0 <vector242>:
.globl vector242
vector242:
  pushl $0
80105de0:	6a 00                	push   $0x0
  pushl $242
80105de2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105de7:	e9 f1 f1 ff ff       	jmp    80104fdd <alltraps>

80105dec <vector243>:
.globl vector243
vector243:
  pushl $0
80105dec:	6a 00                	push   $0x0
  pushl $243
80105dee:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105df3:	e9 e5 f1 ff ff       	jmp    80104fdd <alltraps>

80105df8 <vector244>:
.globl vector244
vector244:
  pushl $0
80105df8:	6a 00                	push   $0x0
  pushl $244
80105dfa:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105dff:	e9 d9 f1 ff ff       	jmp    80104fdd <alltraps>

80105e04 <vector245>:
.globl vector245
vector245:
  pushl $0
80105e04:	6a 00                	push   $0x0
  pushl $245
80105e06:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105e0b:	e9 cd f1 ff ff       	jmp    80104fdd <alltraps>

80105e10 <vector246>:
.globl vector246
vector246:
  pushl $0
80105e10:	6a 00                	push   $0x0
  pushl $246
80105e12:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105e17:	e9 c1 f1 ff ff       	jmp    80104fdd <alltraps>

80105e1c <vector247>:
.globl vector247
vector247:
  pushl $0
80105e1c:	6a 00                	push   $0x0
  pushl $247
80105e1e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105e23:	e9 b5 f1 ff ff       	jmp    80104fdd <alltraps>

80105e28 <vector248>:
.globl vector248
vector248:
  pushl $0
80105e28:	6a 00                	push   $0x0
  pushl $248
80105e2a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105e2f:	e9 a9 f1 ff ff       	jmp    80104fdd <alltraps>

80105e34 <vector249>:
.globl vector249
vector249:
  pushl $0
80105e34:	6a 00                	push   $0x0
  pushl $249
80105e36:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105e3b:	e9 9d f1 ff ff       	jmp    80104fdd <alltraps>

80105e40 <vector250>:
.globl vector250
vector250:
  pushl $0
80105e40:	6a 00                	push   $0x0
  pushl $250
80105e42:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105e47:	e9 91 f1 ff ff       	jmp    80104fdd <alltraps>

80105e4c <vector251>:
.globl vector251
vector251:
  pushl $0
80105e4c:	6a 00                	push   $0x0
  pushl $251
80105e4e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105e53:	e9 85 f1 ff ff       	jmp    80104fdd <alltraps>

80105e58 <vector252>:
.globl vector252
vector252:
  pushl $0
80105e58:	6a 00                	push   $0x0
  pushl $252
80105e5a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105e5f:	e9 79 f1 ff ff       	jmp    80104fdd <alltraps>

80105e64 <vector253>:
.globl vector253
vector253:
  pushl $0
80105e64:	6a 00                	push   $0x0
  pushl $253
80105e66:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105e6b:	e9 6d f1 ff ff       	jmp    80104fdd <alltraps>

80105e70 <vector254>:
.globl vector254
vector254:
  pushl $0
80105e70:	6a 00                	push   $0x0
  pushl $254
80105e72:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105e77:	e9 61 f1 ff ff       	jmp    80104fdd <alltraps>

80105e7c <vector255>:
.globl vector255
vector255:
  pushl $0
80105e7c:	6a 00                	push   $0x0
  pushl $255
80105e7e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105e83:	e9 55 f1 ff ff       	jmp    80104fdd <alltraps>

80105e88 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e88:	55                   	push   %ebp
80105e89:	89 e5                	mov    %esp,%ebp
80105e8b:	57                   	push   %edi
80105e8c:	56                   	push   %esi
80105e8d:	53                   	push   %ebx
80105e8e:	83 ec 0c             	sub    $0xc,%esp
80105e91:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e93:	c1 ea 16             	shr    $0x16,%edx
80105e96:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105e99:	8b 1f                	mov    (%edi),%ebx
80105e9b:	f6 c3 01             	test   $0x1,%bl
80105e9e:	74 22                	je     80105ec2 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105ea0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105ea6:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105eac:	c1 ee 0c             	shr    $0xc,%esi
80105eaf:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105eb5:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105eb8:	89 d8                	mov    %ebx,%eax
80105eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ebd:	5b                   	pop    %ebx
80105ebe:	5e                   	pop    %esi
80105ebf:	5f                   	pop    %edi
80105ec0:	5d                   	pop    %ebp
80105ec1:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc(-2)) == 0)
80105ec2:	85 c9                	test   %ecx,%ecx
80105ec4:	74 33                	je     80105ef9 <walkpgdir+0x71>
80105ec6:	83 ec 0c             	sub    $0xc,%esp
80105ec9:	6a fe                	push   $0xfffffffe
80105ecb:	e8 db c3 ff ff       	call   801022ab <kalloc>
80105ed0:	89 c3                	mov    %eax,%ebx
80105ed2:	83 c4 10             	add    $0x10,%esp
80105ed5:	85 c0                	test   %eax,%eax
80105ed7:	74 df                	je     80105eb8 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105ed9:	83 ec 04             	sub    $0x4,%esp
80105edc:	68 00 10 00 00       	push   $0x1000
80105ee1:	6a 00                	push   $0x0
80105ee3:	50                   	push   %eax
80105ee4:	e8 f6 df ff ff       	call   80103edf <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ee9:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105eef:	83 c8 07             	or     $0x7,%eax
80105ef2:	89 07                	mov    %eax,(%edi)
80105ef4:	83 c4 10             	add    $0x10,%esp
80105ef7:	eb b3                	jmp    80105eac <walkpgdir+0x24>
      return 0;
80105ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
80105efe:	eb b8                	jmp    80105eb8 <walkpgdir+0x30>

80105f00 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105f00:	55                   	push   %ebp
80105f01:	89 e5                	mov    %esp,%ebp
80105f03:	57                   	push   %edi
80105f04:	56                   	push   %esi
80105f05:	53                   	push   %ebx
80105f06:	83 ec 1c             	sub    $0x1c,%esp
80105f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f0c:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105f0f:	89 d3                	mov    %edx,%ebx
80105f11:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105f17:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105f1b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f21:	b9 01 00 00 00       	mov    $0x1,%ecx
80105f26:	89 da                	mov    %ebx,%edx
80105f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f2b:	e8 58 ff ff ff       	call   80105e88 <walkpgdir>
80105f30:	85 c0                	test   %eax,%eax
80105f32:	74 2e                	je     80105f62 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105f34:	f6 00 01             	testb  $0x1,(%eax)
80105f37:	75 1c                	jne    80105f55 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105f39:	89 f2                	mov    %esi,%edx
80105f3b:	0b 55 0c             	or     0xc(%ebp),%edx
80105f3e:	83 ca 01             	or     $0x1,%edx
80105f41:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105f43:	39 fb                	cmp    %edi,%ebx
80105f45:	74 28                	je     80105f6f <mappages+0x6f>
      break;
    a += PGSIZE;
80105f47:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105f4d:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f53:	eb cc                	jmp    80105f21 <mappages+0x21>
      panic("remap");
80105f55:	83 ec 0c             	sub    $0xc,%esp
80105f58:	68 2c 70 10 80       	push   $0x8010702c
80105f5d:	e8 e6 a3 ff ff       	call   80100348 <panic>
      return -1;
80105f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f6a:	5b                   	pop    %ebx
80105f6b:	5e                   	pop    %esi
80105f6c:	5f                   	pop    %edi
80105f6d:	5d                   	pop    %ebp
80105f6e:	c3                   	ret    
  return 0;
80105f6f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f74:	eb f1                	jmp    80105f67 <mappages+0x67>

80105f76 <seginit>:
{
80105f76:	55                   	push   %ebp
80105f77:	89 e5                	mov    %esp,%ebp
80105f79:	53                   	push   %ebx
80105f7a:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105f7d:	e8 f4 d4 ff ff       	call   80103476 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f82:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f88:	66 c7 80 18 28 13 80 	movw   $0xffff,-0x7fecd7e8(%eax)
80105f8f:	ff ff 
80105f91:	66 c7 80 1a 28 13 80 	movw   $0x0,-0x7fecd7e6(%eax)
80105f98:	00 00 
80105f9a:	c6 80 1c 28 13 80 00 	movb   $0x0,-0x7fecd7e4(%eax)
80105fa1:	0f b6 88 1d 28 13 80 	movzbl -0x7fecd7e3(%eax),%ecx
80105fa8:	83 e1 f0             	and    $0xfffffff0,%ecx
80105fab:	83 c9 1a             	or     $0x1a,%ecx
80105fae:	83 e1 9f             	and    $0xffffff9f,%ecx
80105fb1:	83 c9 80             	or     $0xffffff80,%ecx
80105fb4:	88 88 1d 28 13 80    	mov    %cl,-0x7fecd7e3(%eax)
80105fba:	0f b6 88 1e 28 13 80 	movzbl -0x7fecd7e2(%eax),%ecx
80105fc1:	83 c9 0f             	or     $0xf,%ecx
80105fc4:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fc7:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fca:	88 88 1e 28 13 80    	mov    %cl,-0x7fecd7e2(%eax)
80105fd0:	c6 80 1f 28 13 80 00 	movb   $0x0,-0x7fecd7e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105fd7:	66 c7 80 20 28 13 80 	movw   $0xffff,-0x7fecd7e0(%eax)
80105fde:	ff ff 
80105fe0:	66 c7 80 22 28 13 80 	movw   $0x0,-0x7fecd7de(%eax)
80105fe7:	00 00 
80105fe9:	c6 80 24 28 13 80 00 	movb   $0x0,-0x7fecd7dc(%eax)
80105ff0:	0f b6 88 25 28 13 80 	movzbl -0x7fecd7db(%eax),%ecx
80105ff7:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ffa:	83 c9 12             	or     $0x12,%ecx
80105ffd:	83 e1 9f             	and    $0xffffff9f,%ecx
80106000:	83 c9 80             	or     $0xffffff80,%ecx
80106003:	88 88 25 28 13 80    	mov    %cl,-0x7fecd7db(%eax)
80106009:	0f b6 88 26 28 13 80 	movzbl -0x7fecd7da(%eax),%ecx
80106010:	83 c9 0f             	or     $0xf,%ecx
80106013:	83 e1 cf             	and    $0xffffffcf,%ecx
80106016:	83 c9 c0             	or     $0xffffffc0,%ecx
80106019:	88 88 26 28 13 80    	mov    %cl,-0x7fecd7da(%eax)
8010601f:	c6 80 27 28 13 80 00 	movb   $0x0,-0x7fecd7d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106026:	66 c7 80 28 28 13 80 	movw   $0xffff,-0x7fecd7d8(%eax)
8010602d:	ff ff 
8010602f:	66 c7 80 2a 28 13 80 	movw   $0x0,-0x7fecd7d6(%eax)
80106036:	00 00 
80106038:	c6 80 2c 28 13 80 00 	movb   $0x0,-0x7fecd7d4(%eax)
8010603f:	c6 80 2d 28 13 80 fa 	movb   $0xfa,-0x7fecd7d3(%eax)
80106046:	0f b6 88 2e 28 13 80 	movzbl -0x7fecd7d2(%eax),%ecx
8010604d:	83 c9 0f             	or     $0xf,%ecx
80106050:	83 e1 cf             	and    $0xffffffcf,%ecx
80106053:	83 c9 c0             	or     $0xffffffc0,%ecx
80106056:	88 88 2e 28 13 80    	mov    %cl,-0x7fecd7d2(%eax)
8010605c:	c6 80 2f 28 13 80 00 	movb   $0x0,-0x7fecd7d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106063:	66 c7 80 30 28 13 80 	movw   $0xffff,-0x7fecd7d0(%eax)
8010606a:	ff ff 
8010606c:	66 c7 80 32 28 13 80 	movw   $0x0,-0x7fecd7ce(%eax)
80106073:	00 00 
80106075:	c6 80 34 28 13 80 00 	movb   $0x0,-0x7fecd7cc(%eax)
8010607c:	c6 80 35 28 13 80 f2 	movb   $0xf2,-0x7fecd7cb(%eax)
80106083:	0f b6 88 36 28 13 80 	movzbl -0x7fecd7ca(%eax),%ecx
8010608a:	83 c9 0f             	or     $0xf,%ecx
8010608d:	83 e1 cf             	and    $0xffffffcf,%ecx
80106090:	83 c9 c0             	or     $0xffffffc0,%ecx
80106093:	88 88 36 28 13 80    	mov    %cl,-0x7fecd7ca(%eax)
80106099:	c6 80 37 28 13 80 00 	movb   $0x0,-0x7fecd7c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801060a0:	05 10 28 13 80       	add    $0x80132810,%eax
  pd[0] = size-1;
801060a5:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
801060ab:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
801060af:	c1 e8 10             	shr    $0x10,%eax
801060b2:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801060b6:	8d 45 f2             	lea    -0xe(%ebp),%eax
801060b9:	0f 01 10             	lgdtl  (%eax)
}
801060bc:	83 c4 14             	add    $0x14,%esp
801060bf:	5b                   	pop    %ebx
801060c0:	5d                   	pop    %ebp
801060c1:	c3                   	ret    

801060c2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801060c2:	55                   	push   %ebp
801060c3:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801060c5:	a1 c4 54 13 80       	mov    0x801354c4,%eax
801060ca:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060cf:	0f 22 d8             	mov    %eax,%cr3
}
801060d2:	5d                   	pop    %ebp
801060d3:	c3                   	ret    

801060d4 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801060d4:	55                   	push   %ebp
801060d5:	89 e5                	mov    %esp,%ebp
801060d7:	57                   	push   %edi
801060d8:	56                   	push   %esi
801060d9:	53                   	push   %ebx
801060da:	83 ec 1c             	sub    $0x1c,%esp
801060dd:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801060e0:	85 f6                	test   %esi,%esi
801060e2:	0f 84 dd 00 00 00    	je     801061c5 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801060e8:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801060ec:	0f 84 e0 00 00 00    	je     801061d2 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801060f2:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801060f6:	0f 84 e3 00 00 00    	je     801061df <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
801060fc:	e8 55 dc ff ff       	call   80103d56 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106101:	e8 14 d3 ff ff       	call   8010341a <mycpu>
80106106:	89 c3                	mov    %eax,%ebx
80106108:	e8 0d d3 ff ff       	call   8010341a <mycpu>
8010610d:	8d 78 08             	lea    0x8(%eax),%edi
80106110:	e8 05 d3 ff ff       	call   8010341a <mycpu>
80106115:	83 c0 08             	add    $0x8,%eax
80106118:	c1 e8 10             	shr    $0x10,%eax
8010611b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010611e:	e8 f7 d2 ff ff       	call   8010341a <mycpu>
80106123:	83 c0 08             	add    $0x8,%eax
80106126:	c1 e8 18             	shr    $0x18,%eax
80106129:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106130:	67 00 
80106132:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106139:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010613d:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106143:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010614a:	83 e2 f0             	and    $0xfffffff0,%edx
8010614d:	83 ca 19             	or     $0x19,%edx
80106150:	83 e2 9f             	and    $0xffffff9f,%edx
80106153:	83 ca 80             	or     $0xffffff80,%edx
80106156:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010615c:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106163:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106169:	e8 ac d2 ff ff       	call   8010341a <mycpu>
8010616e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106175:	83 e2 ef             	and    $0xffffffef,%edx
80106178:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010617e:	e8 97 d2 ff ff       	call   8010341a <mycpu>
80106183:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106189:	8b 5e 08             	mov    0x8(%esi),%ebx
8010618c:	e8 89 d2 ff ff       	call   8010341a <mycpu>
80106191:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106197:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010619a:	e8 7b d2 ff ff       	call   8010341a <mycpu>
8010619f:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801061a5:	b8 28 00 00 00       	mov    $0x28,%eax
801061aa:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801061ad:	8b 46 04             	mov    0x4(%esi),%eax
801061b0:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801061b5:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801061b8:	e8 d6 db ff ff       	call   80103d93 <popcli>
}
801061bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061c0:	5b                   	pop    %ebx
801061c1:	5e                   	pop    %esi
801061c2:	5f                   	pop    %edi
801061c3:	5d                   	pop    %ebp
801061c4:	c3                   	ret    
    panic("switchuvm: no process");
801061c5:	83 ec 0c             	sub    $0xc,%esp
801061c8:	68 32 70 10 80       	push   $0x80107032
801061cd:	e8 76 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801061d2:	83 ec 0c             	sub    $0xc,%esp
801061d5:	68 48 70 10 80       	push   $0x80107048
801061da:	e8 69 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801061df:	83 ec 0c             	sub    $0xc,%esp
801061e2:	68 5d 70 10 80       	push   $0x8010705d
801061e7:	e8 5c a1 ff ff       	call   80100348 <panic>

801061ec <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061ec:	55                   	push   %ebp
801061ed:	89 e5                	mov    %esp,%ebp
801061ef:	56                   	push   %esi
801061f0:	53                   	push   %ebx
801061f1:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061f4:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061fa:	77 51                	ja     8010624d <inituvm+0x61>
    panic("inituvm: more than a page");
  mem = kalloc(-2);
801061fc:	83 ec 0c             	sub    $0xc,%esp
801061ff:	6a fe                	push   $0xfffffffe
80106201:	e8 a5 c0 ff ff       	call   801022ab <kalloc>
80106206:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106208:	83 c4 0c             	add    $0xc,%esp
8010620b:	68 00 10 00 00       	push   $0x1000
80106210:	6a 00                	push   $0x0
80106212:	50                   	push   %eax
80106213:	e8 c7 dc ff ff       	call   80103edf <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106218:	83 c4 08             	add    $0x8,%esp
8010621b:	6a 06                	push   $0x6
8010621d:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106223:	50                   	push   %eax
80106224:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106229:	ba 00 00 00 00       	mov    $0x0,%edx
8010622e:	8b 45 08             	mov    0x8(%ebp),%eax
80106231:	e8 ca fc ff ff       	call   80105f00 <mappages>
  memmove(mem, init, sz);
80106236:	83 c4 0c             	add    $0xc,%esp
80106239:	56                   	push   %esi
8010623a:	ff 75 0c             	pushl  0xc(%ebp)
8010623d:	53                   	push   %ebx
8010623e:	e8 17 dd ff ff       	call   80103f5a <memmove>
}
80106243:	83 c4 10             	add    $0x10,%esp
80106246:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106249:	5b                   	pop    %ebx
8010624a:	5e                   	pop    %esi
8010624b:	5d                   	pop    %ebp
8010624c:	c3                   	ret    
    panic("inituvm: more than a page");
8010624d:	83 ec 0c             	sub    $0xc,%esp
80106250:	68 71 70 10 80       	push   $0x80107071
80106255:	e8 ee a0 ff ff       	call   80100348 <panic>

8010625a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010625a:	55                   	push   %ebp
8010625b:	89 e5                	mov    %esp,%ebp
8010625d:	57                   	push   %edi
8010625e:	56                   	push   %esi
8010625f:	53                   	push   %ebx
80106260:	83 ec 0c             	sub    $0xc,%esp
80106263:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106266:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010626d:	75 07                	jne    80106276 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010626f:	bb 00 00 00 00       	mov    $0x0,%ebx
80106274:	eb 3c                	jmp    801062b2 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106276:	83 ec 0c             	sub    $0xc,%esp
80106279:	68 2c 71 10 80       	push   $0x8010712c
8010627e:	e8 c5 a0 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106283:	83 ec 0c             	sub    $0xc,%esp
80106286:	68 8b 70 10 80       	push   $0x8010708b
8010628b:	e8 b8 a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106290:	05 00 00 00 80       	add    $0x80000000,%eax
80106295:	56                   	push   %esi
80106296:	89 da                	mov    %ebx,%edx
80106298:	03 55 14             	add    0x14(%ebp),%edx
8010629b:	52                   	push   %edx
8010629c:	50                   	push   %eax
8010629d:	ff 75 10             	pushl  0x10(%ebp)
801062a0:	e8 da b4 ff ff       	call   8010177f <readi>
801062a5:	83 c4 10             	add    $0x10,%esp
801062a8:	39 f0                	cmp    %esi,%eax
801062aa:	75 47                	jne    801062f3 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801062ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062b2:	39 fb                	cmp    %edi,%ebx
801062b4:	73 30                	jae    801062e6 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801062b6:	89 da                	mov    %ebx,%edx
801062b8:	03 55 0c             	add    0xc(%ebp),%edx
801062bb:	b9 00 00 00 00       	mov    $0x0,%ecx
801062c0:	8b 45 08             	mov    0x8(%ebp),%eax
801062c3:	e8 c0 fb ff ff       	call   80105e88 <walkpgdir>
801062c8:	85 c0                	test   %eax,%eax
801062ca:	74 b7                	je     80106283 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801062cc:	8b 00                	mov    (%eax),%eax
801062ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062d3:	89 fe                	mov    %edi,%esi
801062d5:	29 de                	sub    %ebx,%esi
801062d7:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062dd:	76 b1                	jbe    80106290 <loaduvm+0x36>
      n = PGSIZE;
801062df:	be 00 10 00 00       	mov    $0x1000,%esi
801062e4:	eb aa                	jmp    80106290 <loaduvm+0x36>
      return -1;
  }
  return 0;
801062e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062ee:	5b                   	pop    %ebx
801062ef:	5e                   	pop    %esi
801062f0:	5f                   	pop    %edi
801062f1:	5d                   	pop    %ebp
801062f2:	c3                   	ret    
      return -1;
801062f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f8:	eb f1                	jmp    801062eb <loaduvm+0x91>

801062fa <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062fa:	55                   	push   %ebp
801062fb:	89 e5                	mov    %esp,%ebp
801062fd:	57                   	push   %edi
801062fe:	56                   	push   %esi
801062ff:	53                   	push   %ebx
80106300:	83 ec 0c             	sub    $0xc,%esp
80106303:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106306:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106309:	73 11                	jae    8010631c <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010630b:	8b 45 10             	mov    0x10(%ebp),%eax
8010630e:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106314:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010631a:	eb 19                	jmp    80106335 <deallocuvm+0x3b>
    return oldsz;
8010631c:	89 f8                	mov    %edi,%eax
8010631e:	eb 64                	jmp    80106384 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106320:	c1 eb 16             	shr    $0x16,%ebx
80106323:	83 c3 01             	add    $0x1,%ebx
80106326:	c1 e3 16             	shl    $0x16,%ebx
80106329:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010632f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106335:	39 fb                	cmp    %edi,%ebx
80106337:	73 48                	jae    80106381 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106339:	b9 00 00 00 00       	mov    $0x0,%ecx
8010633e:	89 da                	mov    %ebx,%edx
80106340:	8b 45 08             	mov    0x8(%ebp),%eax
80106343:	e8 40 fb ff ff       	call   80105e88 <walkpgdir>
80106348:	89 c6                	mov    %eax,%esi
    if(!pte)
8010634a:	85 c0                	test   %eax,%eax
8010634c:	74 d2                	je     80106320 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010634e:	8b 00                	mov    (%eax),%eax
80106350:	a8 01                	test   $0x1,%al
80106352:	74 db                	je     8010632f <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106354:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106359:	74 19                	je     80106374 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010635b:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106360:	83 ec 0c             	sub    $0xc,%esp
80106363:	50                   	push   %eax
80106364:	e8 a7 bd ff ff       	call   80102110 <kfree>
      *pte = 0;
80106369:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010636f:	83 c4 10             	add    $0x10,%esp
80106372:	eb bb                	jmp    8010632f <deallocuvm+0x35>
        panic("kfree");
80106374:	83 ec 0c             	sub    $0xc,%esp
80106377:	68 c6 69 10 80       	push   $0x801069c6
8010637c:	e8 c7 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106381:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106384:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106387:	5b                   	pop    %ebx
80106388:	5e                   	pop    %esi
80106389:	5f                   	pop    %edi
8010638a:	5d                   	pop    %ebp
8010638b:	c3                   	ret    

8010638c <allocuvm>:
{
8010638c:	55                   	push   %ebp
8010638d:	89 e5                	mov    %esp,%ebp
8010638f:	57                   	push   %edi
80106390:	56                   	push   %esi
80106391:	53                   	push   %ebx
80106392:	83 ec 1c             	sub    $0x1c,%esp
80106395:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106398:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010639b:	85 ff                	test   %edi,%edi
8010639d:	0f 88 ca 00 00 00    	js     8010646d <allocuvm+0xe1>
  if(newsz < oldsz)
801063a3:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063a6:	72 65                	jb     8010640d <allocuvm+0x81>
  a = PGROUNDUP(oldsz);
801063a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801063ab:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801063b1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801063b7:	39 fb                	cmp    %edi,%ebx
801063b9:	0f 83 b5 00 00 00    	jae    80106474 <allocuvm+0xe8>
    mem = kalloc(pid);
801063bf:	83 ec 0c             	sub    $0xc,%esp
801063c2:	ff 75 14             	pushl  0x14(%ebp)
801063c5:	e8 e1 be ff ff       	call   801022ab <kalloc>
801063ca:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801063cc:	83 c4 10             	add    $0x10,%esp
801063cf:	85 c0                	test   %eax,%eax
801063d1:	74 42                	je     80106415 <allocuvm+0x89>
    memset(mem, 0, PGSIZE);
801063d3:	83 ec 04             	sub    $0x4,%esp
801063d6:	68 00 10 00 00       	push   $0x1000
801063db:	6a 00                	push   $0x0
801063dd:	50                   	push   %eax
801063de:	e8 fc da ff ff       	call   80103edf <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063e3:	83 c4 08             	add    $0x8,%esp
801063e6:	6a 06                	push   $0x6
801063e8:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801063ee:	50                   	push   %eax
801063ef:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063f4:	89 da                	mov    %ebx,%edx
801063f6:	8b 45 08             	mov    0x8(%ebp),%eax
801063f9:	e8 02 fb ff ff       	call   80105f00 <mappages>
801063fe:	83 c4 10             	add    $0x10,%esp
80106401:	85 c0                	test   %eax,%eax
80106403:	78 38                	js     8010643d <allocuvm+0xb1>
  for(; a < newsz; a += PGSIZE){
80106405:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010640b:	eb aa                	jmp    801063b7 <allocuvm+0x2b>
    return oldsz;
8010640d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106413:	eb 5f                	jmp    80106474 <allocuvm+0xe8>
      cprintf("allocuvm out of memory\n");
80106415:	83 ec 0c             	sub    $0xc,%esp
80106418:	68 a9 70 10 80       	push   $0x801070a9
8010641d:	e8 e9 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106422:	83 c4 0c             	add    $0xc,%esp
80106425:	ff 75 0c             	pushl  0xc(%ebp)
80106428:	57                   	push   %edi
80106429:	ff 75 08             	pushl  0x8(%ebp)
8010642c:	e8 c9 fe ff ff       	call   801062fa <deallocuvm>
      return 0;
80106431:	83 c4 10             	add    $0x10,%esp
80106434:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010643b:	eb 37                	jmp    80106474 <allocuvm+0xe8>
      cprintf("allocuvm out of memory (2)\n");
8010643d:	83 ec 0c             	sub    $0xc,%esp
80106440:	68 c1 70 10 80       	push   $0x801070c1
80106445:	e8 c1 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010644a:	83 c4 0c             	add    $0xc,%esp
8010644d:	ff 75 0c             	pushl  0xc(%ebp)
80106450:	57                   	push   %edi
80106451:	ff 75 08             	pushl  0x8(%ebp)
80106454:	e8 a1 fe ff ff       	call   801062fa <deallocuvm>
      kfree(mem);
80106459:	89 34 24             	mov    %esi,(%esp)
8010645c:	e8 af bc ff ff       	call   80102110 <kfree>
      return 0;
80106461:	83 c4 10             	add    $0x10,%esp
80106464:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010646b:	eb 07                	jmp    80106474 <allocuvm+0xe8>
    return 0;
8010646d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106477:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010647a:	5b                   	pop    %ebx
8010647b:	5e                   	pop    %esi
8010647c:	5f                   	pop    %edi
8010647d:	5d                   	pop    %ebp
8010647e:	c3                   	ret    

8010647f <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010647f:	55                   	push   %ebp
80106480:	89 e5                	mov    %esp,%ebp
80106482:	56                   	push   %esi
80106483:	53                   	push   %ebx
80106484:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106487:	85 f6                	test   %esi,%esi
80106489:	74 1a                	je     801064a5 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010648b:	83 ec 04             	sub    $0x4,%esp
8010648e:	6a 00                	push   $0x0
80106490:	68 00 00 00 80       	push   $0x80000000
80106495:	56                   	push   %esi
80106496:	e8 5f fe ff ff       	call   801062fa <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010649b:	83 c4 10             	add    $0x10,%esp
8010649e:	bb 00 00 00 00       	mov    $0x0,%ebx
801064a3:	eb 10                	jmp    801064b5 <freevm+0x36>
    panic("freevm: no pgdir");
801064a5:	83 ec 0c             	sub    $0xc,%esp
801064a8:	68 dd 70 10 80       	push   $0x801070dd
801064ad:	e8 96 9e ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801064b2:	83 c3 01             	add    $0x1,%ebx
801064b5:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801064bb:	77 1f                	ja     801064dc <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801064bd:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801064c0:	a8 01                	test   $0x1,%al
801064c2:	74 ee                	je     801064b2 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801064c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064c9:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801064ce:	83 ec 0c             	sub    $0xc,%esp
801064d1:	50                   	push   %eax
801064d2:	e8 39 bc ff ff       	call   80102110 <kfree>
801064d7:	83 c4 10             	add    $0x10,%esp
801064da:	eb d6                	jmp    801064b2 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801064dc:	83 ec 0c             	sub    $0xc,%esp
801064df:	56                   	push   %esi
801064e0:	e8 2b bc ff ff       	call   80102110 <kfree>
}
801064e5:	83 c4 10             	add    $0x10,%esp
801064e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064eb:	5b                   	pop    %ebx
801064ec:	5e                   	pop    %esi
801064ed:	5d                   	pop    %ebp
801064ee:	c3                   	ret    

801064ef <setupkvm>:
{
801064ef:	55                   	push   %ebp
801064f0:	89 e5                	mov    %esp,%ebp
801064f2:	56                   	push   %esi
801064f3:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc(-2)) == 0)
801064f4:	83 ec 0c             	sub    $0xc,%esp
801064f7:	6a fe                	push   $0xfffffffe
801064f9:	e8 ad bd ff ff       	call   801022ab <kalloc>
801064fe:	89 c6                	mov    %eax,%esi
80106500:	83 c4 10             	add    $0x10,%esp
80106503:	85 c0                	test   %eax,%eax
80106505:	74 55                	je     8010655c <setupkvm+0x6d>
  memset(pgdir, 0, PGSIZE);
80106507:	83 ec 04             	sub    $0x4,%esp
8010650a:	68 00 10 00 00       	push   $0x1000
8010650f:	6a 00                	push   $0x0
80106511:	50                   	push   %eax
80106512:	e8 c8 d9 ff ff       	call   80103edf <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106517:	83 c4 10             	add    $0x10,%esp
8010651a:	bb 20 a4 12 80       	mov    $0x8012a420,%ebx
8010651f:	81 fb 60 a4 12 80    	cmp    $0x8012a460,%ebx
80106525:	73 35                	jae    8010655c <setupkvm+0x6d>
                (uint)k->phys_start, k->perm) < 0) {
80106527:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010652a:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010652d:	29 c1                	sub    %eax,%ecx
8010652f:	83 ec 08             	sub    $0x8,%esp
80106532:	ff 73 0c             	pushl  0xc(%ebx)
80106535:	50                   	push   %eax
80106536:	8b 13                	mov    (%ebx),%edx
80106538:	89 f0                	mov    %esi,%eax
8010653a:	e8 c1 f9 ff ff       	call   80105f00 <mappages>
8010653f:	83 c4 10             	add    $0x10,%esp
80106542:	85 c0                	test   %eax,%eax
80106544:	78 05                	js     8010654b <setupkvm+0x5c>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106546:	83 c3 10             	add    $0x10,%ebx
80106549:	eb d4                	jmp    8010651f <setupkvm+0x30>
      freevm(pgdir);
8010654b:	83 ec 0c             	sub    $0xc,%esp
8010654e:	56                   	push   %esi
8010654f:	e8 2b ff ff ff       	call   8010647f <freevm>
      return 0;
80106554:	83 c4 10             	add    $0x10,%esp
80106557:	be 00 00 00 00       	mov    $0x0,%esi
}
8010655c:	89 f0                	mov    %esi,%eax
8010655e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106561:	5b                   	pop    %ebx
80106562:	5e                   	pop    %esi
80106563:	5d                   	pop    %ebp
80106564:	c3                   	ret    

80106565 <kvmalloc>:
{
80106565:	55                   	push   %ebp
80106566:	89 e5                	mov    %esp,%ebp
80106568:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010656b:	e8 7f ff ff ff       	call   801064ef <setupkvm>
80106570:	a3 c4 54 13 80       	mov    %eax,0x801354c4
  switchkvm();
80106575:	e8 48 fb ff ff       	call   801060c2 <switchkvm>
}
8010657a:	c9                   	leave  
8010657b:	c3                   	ret    

8010657c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010657c:	55                   	push   %ebp
8010657d:	89 e5                	mov    %esp,%ebp
8010657f:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106582:	b9 00 00 00 00       	mov    $0x0,%ecx
80106587:	8b 55 0c             	mov    0xc(%ebp),%edx
8010658a:	8b 45 08             	mov    0x8(%ebp),%eax
8010658d:	e8 f6 f8 ff ff       	call   80105e88 <walkpgdir>
  if(pte == 0)
80106592:	85 c0                	test   %eax,%eax
80106594:	74 05                	je     8010659b <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106596:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106599:	c9                   	leave  
8010659a:	c3                   	ret    
    panic("clearpteu");
8010659b:	83 ec 0c             	sub    $0xc,%esp
8010659e:	68 ee 70 10 80       	push   $0x801070ee
801065a3:	e8 a0 9d ff ff       	call   80100348 <panic>

801065a8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, int pid)
{
801065a8:	55                   	push   %ebp
801065a9:	89 e5                	mov    %esp,%ebp
801065ab:	57                   	push   %edi
801065ac:	56                   	push   %esi
801065ad:	53                   	push   %ebx
801065ae:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801065b1:	e8 39 ff ff ff       	call   801064ef <setupkvm>
801065b6:	89 45 dc             	mov    %eax,-0x24(%ebp)
801065b9:	85 c0                	test   %eax,%eax
801065bb:	0f 84 d1 00 00 00    	je     80106692 <copyuvm+0xea>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801065c1:	bf 00 00 00 00       	mov    $0x0,%edi
801065c6:	89 fe                	mov    %edi,%esi
801065c8:	3b 75 0c             	cmp    0xc(%ebp),%esi
801065cb:	0f 83 c1 00 00 00    	jae    80106692 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801065d1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
801065d4:	b9 00 00 00 00       	mov    $0x0,%ecx
801065d9:	89 f2                	mov    %esi,%edx
801065db:	8b 45 08             	mov    0x8(%ebp),%eax
801065de:	e8 a5 f8 ff ff       	call   80105e88 <walkpgdir>
801065e3:	85 c0                	test   %eax,%eax
801065e5:	74 70                	je     80106657 <copyuvm+0xaf>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801065e7:	8b 18                	mov    (%eax),%ebx
801065e9:	f6 c3 01             	test   $0x1,%bl
801065ec:	74 76                	je     80106664 <copyuvm+0xbc>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801065ee:	89 df                	mov    %ebx,%edi
801065f0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    flags = PTE_FLAGS(*pte);
801065f6:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801065fc:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    if((mem = kalloc(pid)) == 0)
801065ff:	83 ec 0c             	sub    $0xc,%esp
80106602:	ff 75 10             	pushl  0x10(%ebp)
80106605:	e8 a1 bc ff ff       	call   801022ab <kalloc>
8010660a:	89 c3                	mov    %eax,%ebx
8010660c:	83 c4 10             	add    $0x10,%esp
8010660f:	85 c0                	test   %eax,%eax
80106611:	74 6a                	je     8010667d <copyuvm+0xd5>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106613:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80106619:	83 ec 04             	sub    $0x4,%esp
8010661c:	68 00 10 00 00       	push   $0x1000
80106621:	57                   	push   %edi
80106622:	50                   	push   %eax
80106623:	e8 32 d9 ff ff       	call   80103f5a <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106628:	83 c4 08             	add    $0x8,%esp
8010662b:	ff 75 e0             	pushl  -0x20(%ebp)
8010662e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106634:	50                   	push   %eax
80106635:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010663a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010663d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106640:	e8 bb f8 ff ff       	call   80105f00 <mappages>
80106645:	83 c4 10             	add    $0x10,%esp
80106648:	85 c0                	test   %eax,%eax
8010664a:	78 25                	js     80106671 <copyuvm+0xc9>
  for(i = 0; i < sz; i += PGSIZE){
8010664c:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106652:	e9 71 ff ff ff       	jmp    801065c8 <copyuvm+0x20>
      panic("copyuvm: pte should exist");
80106657:	83 ec 0c             	sub    $0xc,%esp
8010665a:	68 f8 70 10 80       	push   $0x801070f8
8010665f:	e8 e4 9c ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106664:	83 ec 0c             	sub    $0xc,%esp
80106667:	68 12 71 10 80       	push   $0x80107112
8010666c:	e8 d7 9c ff ff       	call   80100348 <panic>
      kfree(mem);
80106671:	83 ec 0c             	sub    $0xc,%esp
80106674:	53                   	push   %ebx
80106675:	e8 96 ba ff ff       	call   80102110 <kfree>
      goto bad;
8010667a:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010667d:	83 ec 0c             	sub    $0xc,%esp
80106680:	ff 75 dc             	pushl  -0x24(%ebp)
80106683:	e8 f7 fd ff ff       	call   8010647f <freevm>
  return 0;
80106688:	83 c4 10             	add    $0x10,%esp
8010668b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106692:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106695:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106698:	5b                   	pop    %ebx
80106699:	5e                   	pop    %esi
8010669a:	5f                   	pop    %edi
8010669b:	5d                   	pop    %ebp
8010669c:	c3                   	ret    

8010669d <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010669d:	55                   	push   %ebp
8010669e:	89 e5                	mov    %esp,%ebp
801066a0:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801066a3:	b9 00 00 00 00       	mov    $0x0,%ecx
801066a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801066ab:	8b 45 08             	mov    0x8(%ebp),%eax
801066ae:	e8 d5 f7 ff ff       	call   80105e88 <walkpgdir>
  if((*pte & PTE_P) == 0)
801066b3:	8b 00                	mov    (%eax),%eax
801066b5:	a8 01                	test   $0x1,%al
801066b7:	74 10                	je     801066c9 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801066b9:	a8 04                	test   $0x4,%al
801066bb:	74 13                	je     801066d0 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801066bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066c2:	05 00 00 00 80       	add    $0x80000000,%eax
}
801066c7:	c9                   	leave  
801066c8:	c3                   	ret    
    return 0;
801066c9:	b8 00 00 00 00       	mov    $0x0,%eax
801066ce:	eb f7                	jmp    801066c7 <uva2ka+0x2a>
    return 0;
801066d0:	b8 00 00 00 00       	mov    $0x0,%eax
801066d5:	eb f0                	jmp    801066c7 <uva2ka+0x2a>

801066d7 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801066d7:	55                   	push   %ebp
801066d8:	89 e5                	mov    %esp,%ebp
801066da:	57                   	push   %edi
801066db:	56                   	push   %esi
801066dc:	53                   	push   %ebx
801066dd:	83 ec 0c             	sub    $0xc,%esp
801066e0:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801066e3:	eb 25                	jmp    8010670a <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801066e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801066e8:	29 f2                	sub    %esi,%edx
801066ea:	01 d0                	add    %edx,%eax
801066ec:	83 ec 04             	sub    $0x4,%esp
801066ef:	53                   	push   %ebx
801066f0:	ff 75 10             	pushl  0x10(%ebp)
801066f3:	50                   	push   %eax
801066f4:	e8 61 d8 ff ff       	call   80103f5a <memmove>
    len -= n;
801066f9:	29 df                	sub    %ebx,%edi
    buf += n;
801066fb:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801066fe:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106704:	89 45 0c             	mov    %eax,0xc(%ebp)
80106707:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010670a:	85 ff                	test   %edi,%edi
8010670c:	74 2f                	je     8010673d <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
8010670e:	8b 75 0c             	mov    0xc(%ebp),%esi
80106711:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106717:	83 ec 08             	sub    $0x8,%esp
8010671a:	56                   	push   %esi
8010671b:	ff 75 08             	pushl  0x8(%ebp)
8010671e:	e8 7a ff ff ff       	call   8010669d <uva2ka>
    if(pa0 == 0)
80106723:	83 c4 10             	add    $0x10,%esp
80106726:	85 c0                	test   %eax,%eax
80106728:	74 20                	je     8010674a <copyout+0x73>
    n = PGSIZE - (va - va0);
8010672a:	89 f3                	mov    %esi,%ebx
8010672c:	2b 5d 0c             	sub    0xc(%ebp),%ebx
8010672f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106735:	39 df                	cmp    %ebx,%edi
80106737:	73 ac                	jae    801066e5 <copyout+0xe>
      n = len;
80106739:	89 fb                	mov    %edi,%ebx
8010673b:	eb a8                	jmp    801066e5 <copyout+0xe>
  }
  return 0;
8010673d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106742:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106745:	5b                   	pop    %ebx
80106746:	5e                   	pop    %esi
80106747:	5f                   	pop    %edi
80106748:	5d                   	pop    %ebp
80106749:	c3                   	ret    
      return -1;
8010674a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674f:	eb f1                	jmp    80106742 <copyout+0x6b>


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
80100015:	b8 00 80 10 00       	mov    $0x108000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc d0 a5 11 80       	mov    $0x8011a5d0,%esp
8010002d:	b8 6b 2b 10 80       	mov    $0x80102b6b,%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
80100041:	68 e0 a5 11 80       	push   $0x8011a5e0
80100046:	e8 62 3c 00 00       	call   80103cad <acquire>
8010004b:	8b 1d 30 ed 11 80    	mov    0x8011ed30,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc ec 11 80    	cmp    $0x8011ecdc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 e0 a5 11 80       	push   $0x8011a5e0
8010007c:	e8 91 3c 00 00       	call   80103d12 <release>
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 0d 3a 00 00       	call   80103a99 <acquiresleep>
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
80100091:	8b 1d 2c ed 11 80    	mov    0x8011ed2c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc ec 11 80    	cmp    $0x8011ecdc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 e0 a5 11 80       	push   $0x8011a5e0
801000ca:	e8 43 3c 00 00       	call   80103d12 <release>
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 bf 39 00 00       	call   80103a99 <acquiresleep>
801000da:	83 c4 10             	add    $0x10,%esp
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 e0 65 10 80       	push   $0x801065e0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
801000fb:	68 f1 65 10 80       	push   $0x801065f1
80100100:	68 e0 a5 11 80       	push   $0x8011a5e0
80100105:	e8 67 3a 00 00       	call   80103b71 <initlock>
8010010a:	c7 05 2c ed 11 80 dc 	movl   $0x8011ecdc,0x8011ed2c
80100111:	ec 11 80 
80100114:	c7 05 30 ed 11 80 dc 	movl   $0x8011ecdc,0x8011ed30
8010011b:	ec 11 80 
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 a6 11 80       	mov    $0x8011a614,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
80100128:	a1 30 ed 11 80       	mov    0x8011ed30,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
80100130:	c7 43 50 dc ec 11 80 	movl   $0x8011ecdc,0x50(%ebx)
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 f8 65 10 80       	push   $0x801065f8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 1e 39 00 00       	call   80103a66 <initsleeplock>
80100148:	a1 30 ed 11 80       	mov    0x8011ed30,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
80100150:	89 1d 30 ed 11 80    	mov    %ebx,0x8011ed30
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc ec 11 80    	cmp    $0x8011ecdc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 83 1c 00 00       	call   80101e18 <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 76 39 00 00       	call   80103b23 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 58 1c 00 00       	call   80101e18 <iderw>
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 ff 65 10 80       	push   $0x801065ff
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 3a 39 00 00       	call   80103b23 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 ef 38 00 00       	call   80103ae8 <releasesleep>
801001f9:	c7 04 24 e0 a5 11 80 	movl   $0x8011a5e0,(%esp)
80100200:	e8 a8 3a 00 00       	call   80103cad <acquire>
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
80100227:	a1 30 ed 11 80       	mov    0x8011ed30,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
8010022f:	c7 43 50 dc ec 11 80 	movl   $0x8011ecdc,0x50(%ebx)
80100236:	a1 30 ed 11 80       	mov    0x8011ed30,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
8010023e:	89 1d 30 ed 11 80    	mov    %ebx,0x8011ed30
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 a5 11 80       	push   $0x8011a5e0
8010024c:	e8 c1 3a 00 00       	call   80103d12 <release>
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 06 66 10 80       	push   $0x80106606
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010027a:	57                   	push   %edi
8010027b:	e8 cf 13 00 00       	call   8010164f <iunlock>
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80100283:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010028a:	e8 1e 3a 00 00       	call   80103cad <acquire>
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
8010029a:	a1 c0 ef 11 80       	mov    0x8011efc0,%eax
8010029f:	3b 05 c4 ef 11 80    	cmp    0x8011efc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
801002a7:	e8 5f 30 00 00       	call   8010330b <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 95 10 80       	push   $0x80109520
801002ba:	68 c0 ef 11 80       	push   $0x8011efc0
801002bf:	e8 ee 34 00 00       	call   801037b2 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 10 80       	push   $0x80109520
801002d1:	e8 3c 3a 00 00       	call   80103d12 <release>
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 af 12 00 00       	call   8010158d <ilock>
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 c0 ef 11 80    	mov    %edx,0x8011efc0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 ef 11 80 	movzbl -0x7fee10c0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
80100310:	83 eb 01             	sub    $0x1,%ebx
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
80100324:	a3 c0 ef 11 80       	mov    %eax,0x8011efc0
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 95 10 80       	push   $0x80109520
80100331:	e8 dc 39 00 00       	call   80103d12 <release>
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 4f 12 00 00       	call   8010158d <ilock>
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
8010034f:	fa                   	cli    
80100350:	c7 05 54 95 10 80 00 	movl   $0x0,0x80109554
80100357:	00 00 00 
8010035a:	e8 21 21 00 00       	call   80102480 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 0d 66 10 80       	push   $0x8010660d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
80100378:	c7 04 24 5b 6f 10 80 	movl   $0x80106f5b,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 f8 37 00 00       	call   80103b8c <getcallerpcs>
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 21 66 10 80       	push   $0x80106621
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
801003ba:	c7 05 58 95 10 80 01 	movl   $0x1,0x80109558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
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
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
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
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 25 66 10 80       	push   $0x80106625
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 15 39 00 00       	call   80103dd4 <memmove>
801004bf:	83 eb 50             	sub    $0x50,%ebx
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 7b 38 00 00       	call   80103d59 <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
801004e6:	83 3d 58 95 10 80 00 	cmpl   $0x0,0x80109558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 88 4c 00 00       	call   80105193 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 6f 4c 00 00       	call   80105193 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 63 4c 00 00       	call   80105193 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 57 4c 00 00       	call   80105193 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
80100559:	89 c2                	mov    %eax,%edx
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 50 66 10 80 	movzbl -0x7fef99b0(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 8c 10 00 00       	call   8010164f <iunlock>
801005c3:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801005ca:	e8 de 36 00 00       	call   80103cad <acquire>
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 95 10 80       	push   $0x80109520
801005f1:	e8 1c 37 00 00       	call   80103d12 <release>
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 8c 0f 00 00       	call   8010158d <ilock>
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
80100614:	a1 54 95 10 80       	mov    0x80109554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 95 10 80       	push   $0x80109520
80100638:	e8 70 36 00 00       	call   80103cad <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 3f 66 10 80       	push   $0x8010663f
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
801006ee:	be 38 66 10 80       	mov    $0x80106638,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 95 10 80       	push   $0x80109520
80100734:	e8 d9 35 00 00       	call   80103d12 <release>
80100739:	83 c4 10             	add    $0x10,%esp
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010074a:	68 20 95 10 80       	push   $0x80109520
8010074f:	e8 59 35 00 00       	call   80103cad <acquire>
80100754:	83 c4 10             	add    $0x10,%esp
80100757:	be 00 00 00 00       	mov    $0x0,%esi
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 c8 ef 11 80       	mov    0x8011efc8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 ef 11 80    	sub    0x8011efc0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 ef 11 80    	mov    %edx,0x8011efc8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 ef 11 80    	mov    %cl,-0x7fee10c0(%eax)
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 c0 ef 11 80       	mov    0x8011efc0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 ef 11 80    	cmp    %eax,0x8011efc8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
801007cc:	a1 c8 ef 11 80       	mov    0x8011efc8,%eax
801007d1:	a3 c4 ef 11 80       	mov    %eax,0x8011efc4
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 ef 11 80       	push   $0x8011efc0
801007de:	e8 34 31 00 00       	call   80103917 <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
801007e8:	a3 c8 ef 11 80       	mov    %eax,0x8011efc8
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
801007f7:	a1 c8 ef 11 80       	mov    0x8011efc8,%eax
801007fc:	3b 05 c4 ef 11 80    	cmp    0x8011efc4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
8010080c:	80 ba 40 ef 11 80 0a 	cmpb   $0xa,-0x7fee10c0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
80100821:	be 01 00 00 00       	mov    $0x1,%esi
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
8010084a:	a1 c8 ef 11 80       	mov    0x8011efc8,%eax
8010084f:	3b 05 c4 ef 11 80    	cmp    0x8011efc4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 ef 11 80       	mov    %eax,0x8011efc8
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 95 10 80       	push   $0x80109520
80100873:	e8 9a 34 00 00       	call   80103d12 <release>
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
80100887:	e8 28 31 00 00       	call   801039b4 <procdump>
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
80100894:	68 48 66 10 80       	push   $0x80106648
80100899:	68 20 95 10 80       	push   $0x80109520
8010089e:	e8 ce 32 00 00       	call   80103b71 <initlock>
801008a3:	c7 05 8c f9 11 80 ac 	movl   $0x801005ac,0x8011f98c
801008aa:	05 10 80 
801008ad:	c7 05 88 f9 11 80 68 	movl   $0x80100268,0x8011f988
801008b4:	02 10 80 
801008b7:	c7 05 54 95 10 80 01 	movl   $0x1,0x80109554
801008be:	00 00 00 
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 bd 16 00 00       	call   80101f8a <ioapicenable>
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
801008de:	e8 28 2a 00 00       	call   8010330b <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
801008e9:	e8 c2 1f 00 00       	call   801028b0 <begin_op>
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 f4 12 00 00       	call   80101bed <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 82 0c 00 00       	call   8010158d <ilock>
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 63 0e 00 00       	call   8010177f <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 e9 02 00 00    	je     80100c15 <exec+0x343>
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 ff 0d 00 00       	call   80101734 <iunlockput>
80100935:	e8 f0 1f 00 00       	call   8010292a <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
8010094a:	e8 db 1f 00 00       	call   8010292a <end_op>
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 61 66 10 80       	push   $0x80106661
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
80100972:	e8 f2 59 00 00       	call   80106369 <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 12 01 00 00    	je     80100a97 <exec+0x1c5>
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 9e 00 00 00    	jle    80100a50 <exec+0x17e>
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
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 a8 00 00 00    	jb     80100a97 <exec+0x1c5>
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 9c 00 00 00    	jb     80100a97 <exec+0x1c5>
801009fb:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a01:	ff 71 10             	pushl  0x10(%ecx)
80100a04:	50                   	push   %eax
80100a05:	57                   	push   %edi
80100a06:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a0c:	e8 f5 57 00 00       	call   80106206 <allocuvm>
80100a11:	89 c7                	mov    %eax,%edi
80100a13:	83 c4 10             	add    $0x10,%esp
80100a16:	85 c0                	test   %eax,%eax
80100a18:	74 7d                	je     80100a97 <exec+0x1c5>
80100a1a:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a20:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a25:	75 70                	jne    80100a97 <exec+0x1c5>
80100a27:	83 ec 0c             	sub    $0xc,%esp
80100a2a:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a30:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a36:	53                   	push   %ebx
80100a37:	50                   	push   %eax
80100a38:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a3e:	e8 91 56 00 00       	call   801060d4 <loaduvm>
80100a43:	83 c4 20             	add    $0x20,%esp
80100a46:	85 c0                	test   %eax,%eax
80100a48:	0f 89 49 ff ff ff    	jns    80100997 <exec+0xc5>
80100a4e:	eb 47                	jmp    80100a97 <exec+0x1c5>
80100a50:	83 ec 0c             	sub    $0xc,%esp
80100a53:	53                   	push   %ebx
80100a54:	e8 db 0c 00 00       	call   80101734 <iunlockput>
80100a59:	e8 cc 1e 00 00       	call   8010292a <end_op>
80100a5e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100a69:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100a6f:	ff 71 10             	pushl  0x10(%ecx)
80100a72:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a78:	52                   	push   %edx
80100a79:	50                   	push   %eax
80100a7a:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a80:	e8 81 57 00 00       	call   80106206 <allocuvm>
80100a85:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a8b:	83 c4 20             	add    $0x20,%esp
80100a8e:	85 c0                	test   %eax,%eax
80100a90:	75 24                	jne    80100ab6 <exec+0x1e4>
80100a92:	bb 00 00 00 00       	mov    $0x0,%ebx
80100a97:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a9d:	85 c0                	test   %eax,%eax
80100a9f:	0f 84 7f fe ff ff    	je     80100924 <exec+0x52>
80100aa5:	83 ec 0c             	sub    $0xc,%esp
80100aa8:	50                   	push   %eax
80100aa9:	e8 4b 58 00 00       	call   801062f9 <freevm>
80100aae:	83 c4 10             	add    $0x10,%esp
80100ab1:	e9 6e fe ff ff       	jmp    80100924 <exec+0x52>
80100ab6:	89 c7                	mov    %eax,%edi
80100ab8:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100abe:	83 ec 08             	sub    $0x8,%esp
80100ac1:	50                   	push   %eax
80100ac2:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100ac8:	e8 29 59 00 00       	call   801063f6 <clearpteu>
80100acd:	83 c4 10             	add    $0x10,%esp
80100ad0:	be 00 00 00 00       	mov    $0x0,%esi
80100ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad8:	8d 1c b0             	lea    (%eax,%esi,4),%ebx
80100adb:	8b 03                	mov    (%ebx),%eax
80100add:	85 c0                	test   %eax,%eax
80100adf:	74 4d                	je     80100b2e <exec+0x25c>
80100ae1:	83 fe 1f             	cmp    $0x1f,%esi
80100ae4:	0f 87 0d 01 00 00    	ja     80100bf7 <exec+0x325>
80100aea:	83 ec 0c             	sub    $0xc,%esp
80100aed:	50                   	push   %eax
80100aee:	e8 08 34 00 00       	call   80103efb <strlen>
80100af3:	29 c7                	sub    %eax,%edi
80100af5:	83 ef 01             	sub    $0x1,%edi
80100af8:	83 e7 fc             	and    $0xfffffffc,%edi
80100afb:	83 c4 04             	add    $0x4,%esp
80100afe:	ff 33                	pushl  (%ebx)
80100b00:	e8 f6 33 00 00       	call   80103efb <strlen>
80100b05:	83 c0 01             	add    $0x1,%eax
80100b08:	50                   	push   %eax
80100b09:	ff 33                	pushl  (%ebx)
80100b0b:	57                   	push   %edi
80100b0c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b12:	e8 3a 5a 00 00       	call   80106551 <copyout>
80100b17:	83 c4 20             	add    $0x20,%esp
80100b1a:	85 c0                	test   %eax,%eax
80100b1c:	0f 88 df 00 00 00    	js     80100c01 <exec+0x32f>
80100b22:	89 bc b5 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%esi,4)
80100b29:	83 c6 01             	add    $0x1,%esi
80100b2c:	eb a7                	jmp    80100ad5 <exec+0x203>
80100b2e:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80100b35:	00 00 00 00 
80100b39:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b40:	ff ff ff 
80100b43:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
80100b49:	8d 04 b5 04 00 00 00 	lea    0x4(,%esi,4),%eax
80100b50:	89 f9                	mov    %edi,%ecx
80100b52:	29 c1                	sub    %eax,%ecx
80100b54:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
80100b5a:	8d 04 b5 10 00 00 00 	lea    0x10(,%esi,4),%eax
80100b61:	29 c7                	sub    %eax,%edi
80100b63:	50                   	push   %eax
80100b64:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b6a:	50                   	push   %eax
80100b6b:	57                   	push   %edi
80100b6c:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b72:	e8 da 59 00 00       	call   80106551 <copyout>
80100b77:	83 c4 10             	add    $0x10,%esp
80100b7a:	85 c0                	test   %eax,%eax
80100b7c:	0f 88 89 00 00 00    	js     80100c0b <exec+0x339>
80100b82:	8b 55 08             	mov    0x8(%ebp),%edx
80100b85:	89 d0                	mov    %edx,%eax
80100b87:	eb 03                	jmp    80100b8c <exec+0x2ba>
80100b89:	83 c0 01             	add    $0x1,%eax
80100b8c:	0f b6 08             	movzbl (%eax),%ecx
80100b8f:	84 c9                	test   %cl,%cl
80100b91:	74 0a                	je     80100b9d <exec+0x2cb>
80100b93:	80 f9 2f             	cmp    $0x2f,%cl
80100b96:	75 f1                	jne    80100b89 <exec+0x2b7>
80100b98:	8d 50 01             	lea    0x1(%eax),%edx
80100b9b:	eb ec                	jmp    80100b89 <exec+0x2b7>
80100b9d:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100ba3:	89 f0                	mov    %esi,%eax
80100ba5:	83 c0 6c             	add    $0x6c,%eax
80100ba8:	83 ec 04             	sub    $0x4,%esp
80100bab:	6a 10                	push   $0x10
80100bad:	52                   	push   %edx
80100bae:	50                   	push   %eax
80100baf:	e8 0c 33 00 00       	call   80103ec0 <safestrcpy>
80100bb4:	8b 5e 04             	mov    0x4(%esi),%ebx
80100bb7:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bbd:	89 4e 04             	mov    %ecx,0x4(%esi)
80100bc0:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bc6:	89 0e                	mov    %ecx,(%esi)
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bd1:	89 50 38             	mov    %edx,0x38(%eax)
80100bd4:	8b 46 18             	mov    0x18(%esi),%eax
80100bd7:	89 78 44             	mov    %edi,0x44(%eax)
80100bda:	89 34 24             	mov    %esi,(%esp)
80100bdd:	e8 6c 53 00 00       	call   80105f4e <switchuvm>
80100be2:	89 1c 24             	mov    %ebx,(%esp)
80100be5:	e8 0f 57 00 00       	call   801062f9 <freevm>
80100bea:	83 c4 10             	add    $0x10,%esp
80100bed:	b8 00 00 00 00       	mov    $0x0,%eax
80100bf2:	e9 4b fd ff ff       	jmp    80100942 <exec+0x70>
80100bf7:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfc:	e9 96 fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c01:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c06:	e9 8c fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c10:	e9 82 fe ff ff       	jmp    80100a97 <exec+0x1c5>
80100c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c1a:	e9 23 fd ff ff       	jmp    80100942 <exec+0x70>

80100c1f <fileinit>:
80100c1f:	55                   	push   %ebp
80100c20:	89 e5                	mov    %esp,%ebp
80100c22:	83 ec 10             	sub    $0x10,%esp
80100c25:	68 6d 66 10 80       	push   $0x8010666d
80100c2a:	68 e0 ef 11 80       	push   $0x8011efe0
80100c2f:	e8 3d 2f 00 00       	call   80103b71 <initlock>
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	c9                   	leave  
80100c38:	c3                   	ret    

80100c39 <filealloc>:
80100c39:	55                   	push   %ebp
80100c3a:	89 e5                	mov    %esp,%ebp
80100c3c:	53                   	push   %ebx
80100c3d:	83 ec 10             	sub    $0x10,%esp
80100c40:	68 e0 ef 11 80       	push   $0x8011efe0
80100c45:	e8 63 30 00 00       	call   80103cad <acquire>
80100c4a:	83 c4 10             	add    $0x10,%esp
80100c4d:	bb 14 f0 11 80       	mov    $0x8011f014,%ebx
80100c52:	81 fb 74 f9 11 80    	cmp    $0x8011f974,%ebx
80100c58:	73 29                	jae    80100c83 <filealloc+0x4a>
80100c5a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c5e:	74 05                	je     80100c65 <filealloc+0x2c>
80100c60:	83 c3 18             	add    $0x18,%ebx
80100c63:	eb ed                	jmp    80100c52 <filealloc+0x19>
80100c65:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
80100c6c:	83 ec 0c             	sub    $0xc,%esp
80100c6f:	68 e0 ef 11 80       	push   $0x8011efe0
80100c74:	e8 99 30 00 00       	call   80103d12 <release>
80100c79:	83 c4 10             	add    $0x10,%esp
80100c7c:	89 d8                	mov    %ebx,%eax
80100c7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c81:	c9                   	leave  
80100c82:	c3                   	ret    
80100c83:	83 ec 0c             	sub    $0xc,%esp
80100c86:	68 e0 ef 11 80       	push   $0x8011efe0
80100c8b:	e8 82 30 00 00       	call   80103d12 <release>
80100c90:	83 c4 10             	add    $0x10,%esp
80100c93:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c98:	eb e2                	jmp    80100c7c <filealloc+0x43>

80100c9a <filedup>:
80100c9a:	55                   	push   %ebp
80100c9b:	89 e5                	mov    %esp,%ebp
80100c9d:	53                   	push   %ebx
80100c9e:	83 ec 10             	sub    $0x10,%esp
80100ca1:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100ca4:	68 e0 ef 11 80       	push   $0x8011efe0
80100ca9:	e8 ff 2f 00 00       	call   80103cad <acquire>
80100cae:	8b 43 04             	mov    0x4(%ebx),%eax
80100cb1:	83 c4 10             	add    $0x10,%esp
80100cb4:	85 c0                	test   %eax,%eax
80100cb6:	7e 1a                	jle    80100cd2 <filedup+0x38>
80100cb8:	83 c0 01             	add    $0x1,%eax
80100cbb:	89 43 04             	mov    %eax,0x4(%ebx)
80100cbe:	83 ec 0c             	sub    $0xc,%esp
80100cc1:	68 e0 ef 11 80       	push   $0x8011efe0
80100cc6:	e8 47 30 00 00       	call   80103d12 <release>
80100ccb:	89 d8                	mov    %ebx,%eax
80100ccd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cd0:	c9                   	leave  
80100cd1:	c3                   	ret    
80100cd2:	83 ec 0c             	sub    $0xc,%esp
80100cd5:	68 74 66 10 80       	push   $0x80106674
80100cda:	e8 69 f6 ff ff       	call   80100348 <panic>

80100cdf <fileclose>:
80100cdf:	55                   	push   %ebp
80100ce0:	89 e5                	mov    %esp,%ebp
80100ce2:	53                   	push   %ebx
80100ce3:	83 ec 30             	sub    $0x30,%esp
80100ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100ce9:	68 e0 ef 11 80       	push   $0x8011efe0
80100cee:	e8 ba 2f 00 00       	call   80103cad <acquire>
80100cf3:	8b 43 04             	mov    0x4(%ebx),%eax
80100cf6:	83 c4 10             	add    $0x10,%esp
80100cf9:	85 c0                	test   %eax,%eax
80100cfb:	7e 1f                	jle    80100d1c <fileclose+0x3d>
80100cfd:	83 e8 01             	sub    $0x1,%eax
80100d00:	89 43 04             	mov    %eax,0x4(%ebx)
80100d03:	85 c0                	test   %eax,%eax
80100d05:	7e 22                	jle    80100d29 <fileclose+0x4a>
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	68 e0 ef 11 80       	push   $0x8011efe0
80100d0f:	e8 fe 2f 00 00       	call   80103d12 <release>
80100d14:	83 c4 10             	add    $0x10,%esp
80100d17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d1a:	c9                   	leave  
80100d1b:	c3                   	ret    
80100d1c:	83 ec 0c             	sub    $0xc,%esp
80100d1f:	68 7c 66 10 80       	push   $0x8010667c
80100d24:	e8 1f f6 ff ff       	call   80100348 <panic>
80100d29:	8b 03                	mov    (%ebx),%eax
80100d2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d2e:	8b 43 08             	mov    0x8(%ebx),%eax
80100d31:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d34:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d3a:	8b 43 10             	mov    0x10(%ebx),%eax
80100d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100d40:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
80100d47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80100d4d:	83 ec 0c             	sub    $0xc,%esp
80100d50:	68 e0 ef 11 80       	push   $0x8011efe0
80100d55:	e8 b8 2f 00 00       	call   80103d12 <release>
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	83 c4 10             	add    $0x10,%esp
80100d60:	83 f8 01             	cmp    $0x1,%eax
80100d63:	74 1f                	je     80100d84 <fileclose+0xa5>
80100d65:	83 f8 02             	cmp    $0x2,%eax
80100d68:	75 ad                	jne    80100d17 <fileclose+0x38>
80100d6a:	e8 41 1b 00 00       	call   801028b0 <begin_op>
80100d6f:	83 ec 0c             	sub    $0xc,%esp
80100d72:	ff 75 f0             	pushl  -0x10(%ebp)
80100d75:	e8 1a 09 00 00       	call   80101694 <iput>
80100d7a:	e8 ab 1b 00 00       	call   8010292a <end_op>
80100d7f:	83 c4 10             	add    $0x10,%esp
80100d82:	eb 93                	jmp    80100d17 <fileclose+0x38>
80100d84:	83 ec 08             	sub    $0x8,%esp
80100d87:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d8b:	50                   	push   %eax
80100d8c:	ff 75 ec             	pushl  -0x14(%ebp)
80100d8f:	e8 9d 21 00 00       	call   80102f31 <pipeclose>
80100d94:	83 c4 10             	add    $0x10,%esp
80100d97:	e9 7b ff ff ff       	jmp    80100d17 <fileclose+0x38>

80100d9c <filestat>:
80100d9c:	55                   	push   %ebp
80100d9d:	89 e5                	mov    %esp,%ebp
80100d9f:	53                   	push   %ebx
80100da0:	83 ec 04             	sub    $0x4,%esp
80100da3:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100da6:	83 3b 02             	cmpl   $0x2,(%ebx)
80100da9:	75 31                	jne    80100ddc <filestat+0x40>
80100dab:	83 ec 0c             	sub    $0xc,%esp
80100dae:	ff 73 10             	pushl  0x10(%ebx)
80100db1:	e8 d7 07 00 00       	call   8010158d <ilock>
80100db6:	83 c4 08             	add    $0x8,%esp
80100db9:	ff 75 0c             	pushl  0xc(%ebp)
80100dbc:	ff 73 10             	pushl  0x10(%ebx)
80100dbf:	e8 90 09 00 00       	call   80101754 <stati>
80100dc4:	83 c4 04             	add    $0x4,%esp
80100dc7:	ff 73 10             	pushl  0x10(%ebx)
80100dca:	e8 80 08 00 00       	call   8010164f <iunlock>
80100dcf:	83 c4 10             	add    $0x10,%esp
80100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
80100dd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dda:	c9                   	leave  
80100ddb:	c3                   	ret    
80100ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100de1:	eb f4                	jmp    80100dd7 <filestat+0x3b>

80100de3 <fileread>:
80100de3:	55                   	push   %ebp
80100de4:	89 e5                	mov    %esp,%ebp
80100de6:	56                   	push   %esi
80100de7:	53                   	push   %ebx
80100de8:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100deb:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100def:	74 70                	je     80100e61 <fileread+0x7e>
80100df1:	8b 03                	mov    (%ebx),%eax
80100df3:	83 f8 01             	cmp    $0x1,%eax
80100df6:	74 44                	je     80100e3c <fileread+0x59>
80100df8:	83 f8 02             	cmp    $0x2,%eax
80100dfb:	75 57                	jne    80100e54 <fileread+0x71>
80100dfd:	83 ec 0c             	sub    $0xc,%esp
80100e00:	ff 73 10             	pushl  0x10(%ebx)
80100e03:	e8 85 07 00 00       	call   8010158d <ilock>
80100e08:	ff 75 10             	pushl  0x10(%ebp)
80100e0b:	ff 73 14             	pushl  0x14(%ebx)
80100e0e:	ff 75 0c             	pushl  0xc(%ebp)
80100e11:	ff 73 10             	pushl  0x10(%ebx)
80100e14:	e8 66 09 00 00       	call   8010177f <readi>
80100e19:	89 c6                	mov    %eax,%esi
80100e1b:	83 c4 20             	add    $0x20,%esp
80100e1e:	85 c0                	test   %eax,%eax
80100e20:	7e 03                	jle    80100e25 <fileread+0x42>
80100e22:	01 43 14             	add    %eax,0x14(%ebx)
80100e25:	83 ec 0c             	sub    $0xc,%esp
80100e28:	ff 73 10             	pushl  0x10(%ebx)
80100e2b:	e8 1f 08 00 00       	call   8010164f <iunlock>
80100e30:	83 c4 10             	add    $0x10,%esp
80100e33:	89 f0                	mov    %esi,%eax
80100e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e38:	5b                   	pop    %ebx
80100e39:	5e                   	pop    %esi
80100e3a:	5d                   	pop    %ebp
80100e3b:	c3                   	ret    
80100e3c:	83 ec 04             	sub    $0x4,%esp
80100e3f:	ff 75 10             	pushl  0x10(%ebp)
80100e42:	ff 75 0c             	pushl  0xc(%ebp)
80100e45:	ff 73 0c             	pushl  0xc(%ebx)
80100e48:	e8 3c 22 00 00       	call   80103089 <piperead>
80100e4d:	89 c6                	mov    %eax,%esi
80100e4f:	83 c4 10             	add    $0x10,%esp
80100e52:	eb df                	jmp    80100e33 <fileread+0x50>
80100e54:	83 ec 0c             	sub    $0xc,%esp
80100e57:	68 86 66 10 80       	push   $0x80106686
80100e5c:	e8 e7 f4 ff ff       	call   80100348 <panic>
80100e61:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e66:	eb cb                	jmp    80100e33 <fileread+0x50>

80100e68 <filewrite>:
80100e68:	55                   	push   %ebp
80100e69:	89 e5                	mov    %esp,%ebp
80100e6b:	57                   	push   %edi
80100e6c:	56                   	push   %esi
80100e6d:	53                   	push   %ebx
80100e6e:	83 ec 1c             	sub    $0x1c,%esp
80100e71:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100e74:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e78:	0f 84 c5 00 00 00    	je     80100f43 <filewrite+0xdb>
80100e7e:	8b 03                	mov    (%ebx),%eax
80100e80:	83 f8 01             	cmp    $0x1,%eax
80100e83:	74 10                	je     80100e95 <filewrite+0x2d>
80100e85:	83 f8 02             	cmp    $0x2,%eax
80100e88:	0f 85 a8 00 00 00    	jne    80100f36 <filewrite+0xce>
80100e8e:	bf 00 00 00 00       	mov    $0x0,%edi
80100e93:	eb 67                	jmp    80100efc <filewrite+0x94>
80100e95:	83 ec 04             	sub    $0x4,%esp
80100e98:	ff 75 10             	pushl  0x10(%ebp)
80100e9b:	ff 75 0c             	pushl  0xc(%ebp)
80100e9e:	ff 73 0c             	pushl  0xc(%ebx)
80100ea1:	e8 17 21 00 00       	call   80102fbd <pipewrite>
80100ea6:	83 c4 10             	add    $0x10,%esp
80100ea9:	e9 80 00 00 00       	jmp    80100f2e <filewrite+0xc6>
80100eae:	e8 fd 19 00 00       	call   801028b0 <begin_op>
80100eb3:	83 ec 0c             	sub    $0xc,%esp
80100eb6:	ff 73 10             	pushl  0x10(%ebx)
80100eb9:	e8 cf 06 00 00       	call   8010158d <ilock>
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
80100edb:	01 43 14             	add    %eax,0x14(%ebx)
80100ede:	83 ec 0c             	sub    $0xc,%esp
80100ee1:	ff 73 10             	pushl  0x10(%ebx)
80100ee4:	e8 66 07 00 00       	call   8010164f <iunlock>
80100ee9:	e8 3c 1a 00 00       	call   8010292a <end_op>
80100eee:	83 c4 10             	add    $0x10,%esp
80100ef1:	85 f6                	test   %esi,%esi
80100ef3:	78 31                	js     80100f26 <filewrite+0xbe>
80100ef5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100ef8:	75 1f                	jne    80100f19 <filewrite+0xb1>
80100efa:	01 f7                	add    %esi,%edi
80100efc:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100eff:	7d 25                	jge    80100f26 <filewrite+0xbe>
80100f01:	8b 45 10             	mov    0x10(%ebp),%eax
80100f04:	29 f8                	sub    %edi,%eax
80100f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100f09:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f0e:	7e 9e                	jle    80100eae <filewrite+0x46>
80100f10:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f17:	eb 95                	jmp    80100eae <filewrite+0x46>
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	68 8f 66 10 80       	push   $0x8010668f
80100f21:	e8 22 f4 ff ff       	call   80100348 <panic>
80100f26:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f29:	75 1f                	jne    80100f4a <filewrite+0xe2>
80100f2b:	8b 45 10             	mov    0x10(%ebp),%eax
80100f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f31:	5b                   	pop    %ebx
80100f32:	5e                   	pop    %esi
80100f33:	5f                   	pop    %edi
80100f34:	5d                   	pop    %ebp
80100f35:	c3                   	ret    
80100f36:	83 ec 0c             	sub    $0xc,%esp
80100f39:	68 95 66 10 80       	push   $0x80106695
80100f3e:	e8 05 f4 ff ff       	call   80100348 <panic>
80100f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f48:	eb e4                	jmp    80100f2e <filewrite+0xc6>
80100f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f4f:	eb dd                	jmp    80100f2e <filewrite+0xc6>

80100f51 <skipelem>:
80100f51:	55                   	push   %ebp
80100f52:	89 e5                	mov    %esp,%ebp
80100f54:	57                   	push   %edi
80100f55:	56                   	push   %esi
80100f56:	53                   	push   %ebx
80100f57:	83 ec 0c             	sub    $0xc,%esp
80100f5a:	89 d7                	mov    %edx,%edi
80100f5c:	eb 03                	jmp    80100f61 <skipelem+0x10>
80100f5e:	83 c0 01             	add    $0x1,%eax
80100f61:	0f b6 10             	movzbl (%eax),%edx
80100f64:	80 fa 2f             	cmp    $0x2f,%dl
80100f67:	74 f5                	je     80100f5e <skipelem+0xd>
80100f69:	84 d2                	test   %dl,%dl
80100f6b:	74 59                	je     80100fc6 <skipelem+0x75>
80100f6d:	89 c3                	mov    %eax,%ebx
80100f6f:	eb 03                	jmp    80100f74 <skipelem+0x23>
80100f71:	83 c3 01             	add    $0x1,%ebx
80100f74:	0f b6 13             	movzbl (%ebx),%edx
80100f77:	80 fa 2f             	cmp    $0x2f,%dl
80100f7a:	0f 95 c1             	setne  %cl
80100f7d:	84 d2                	test   %dl,%dl
80100f7f:	0f 95 c2             	setne  %dl
80100f82:	84 d1                	test   %dl,%cl
80100f84:	75 eb                	jne    80100f71 <skipelem+0x20>
80100f86:	89 de                	mov    %ebx,%esi
80100f88:	29 c6                	sub    %eax,%esi
80100f8a:	83 fe 0d             	cmp    $0xd,%esi
80100f8d:	7e 11                	jle    80100fa0 <skipelem+0x4f>
80100f8f:	83 ec 04             	sub    $0x4,%esp
80100f92:	6a 0e                	push   $0xe
80100f94:	50                   	push   %eax
80100f95:	57                   	push   %edi
80100f96:	e8 39 2e 00 00       	call   80103dd4 <memmove>
80100f9b:	83 c4 10             	add    $0x10,%esp
80100f9e:	eb 17                	jmp    80100fb7 <skipelem+0x66>
80100fa0:	83 ec 04             	sub    $0x4,%esp
80100fa3:	56                   	push   %esi
80100fa4:	50                   	push   %eax
80100fa5:	57                   	push   %edi
80100fa6:	e8 29 2e 00 00       	call   80103dd4 <memmove>
80100fab:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100faf:	83 c4 10             	add    $0x10,%esp
80100fb2:	eb 03                	jmp    80100fb7 <skipelem+0x66>
80100fb4:	83 c3 01             	add    $0x1,%ebx
80100fb7:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fba:	74 f8                	je     80100fb4 <skipelem+0x63>
80100fbc:	89 d8                	mov    %ebx,%eax
80100fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc1:	5b                   	pop    %ebx
80100fc2:	5e                   	pop    %esi
80100fc3:	5f                   	pop    %edi
80100fc4:	5d                   	pop    %ebp
80100fc5:	c3                   	ret    
80100fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fcb:	eb ef                	jmp    80100fbc <skipelem+0x6b>

80100fcd <bzero>:
80100fcd:	55                   	push   %ebp
80100fce:	89 e5                	mov    %esp,%ebp
80100fd0:	53                   	push   %ebx
80100fd1:	83 ec 0c             	sub    $0xc,%esp
80100fd4:	52                   	push   %edx
80100fd5:	50                   	push   %eax
80100fd6:	e8 91 f1 ff ff       	call   8010016c <bread>
80100fdb:	89 c3                	mov    %eax,%ebx
80100fdd:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fe0:	83 c4 0c             	add    $0xc,%esp
80100fe3:	68 00 02 00 00       	push   $0x200
80100fe8:	6a 00                	push   $0x0
80100fea:	50                   	push   %eax
80100feb:	e8 69 2d 00 00       	call   80103d59 <memset>
80100ff0:	89 1c 24             	mov    %ebx,(%esp)
80100ff3:	e8 e1 19 00 00       	call   801029d9 <log_write>
80100ff8:	89 1c 24             	mov    %ebx,(%esp)
80100ffb:	e8 d5 f1 ff ff       	call   801001d5 <brelse>
80101000:	83 c4 10             	add    $0x10,%esp
80101003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101006:	c9                   	leave  
80101007:	c3                   	ret    

80101008 <balloc>:
80101008:	55                   	push   %ebp
80101009:	89 e5                	mov    %esp,%ebp
8010100b:	57                   	push   %edi
8010100c:	56                   	push   %esi
8010100d:	53                   	push   %ebx
8010100e:	83 ec 1c             	sub    $0x1c,%esp
80101011:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101014:	be 00 00 00 00       	mov    $0x0,%esi
80101019:	eb 14                	jmp    8010102f <balloc+0x27>
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101021:	e8 af f1 ff ff       	call   801001d5 <brelse>
80101026:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010102c:	83 c4 10             	add    $0x10,%esp
8010102f:	39 35 e0 f9 11 80    	cmp    %esi,0x8011f9e0
80101035:	76 75                	jbe    801010ac <balloc+0xa4>
80101037:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
8010103d:	85 f6                	test   %esi,%esi
8010103f:	0f 49 c6             	cmovns %esi,%eax
80101042:	c1 f8 0c             	sar    $0xc,%eax
80101045:	03 05 f8 f9 11 80    	add    0x8011f9f8,%eax
8010104b:	83 ec 08             	sub    $0x8,%esp
8010104e:	50                   	push   %eax
8010104f:	ff 75 d8             	pushl  -0x28(%ebp)
80101052:	e8 15 f1 ff ff       	call   8010016c <bread>
80101057:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010105a:	83 c4 10             	add    $0x10,%esp
8010105d:	b8 00 00 00 00       	mov    $0x0,%eax
80101062:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80101067:	7f b2                	jg     8010101b <balloc+0x13>
80101069:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
8010106c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
8010106f:	3b 1d e0 f9 11 80    	cmp    0x8011f9e0,%ebx
80101075:	73 a4                	jae    8010101b <balloc+0x13>
80101077:	99                   	cltd   
80101078:	c1 ea 1d             	shr    $0x1d,%edx
8010107b:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010107e:	83 e1 07             	and    $0x7,%ecx
80101081:	29 d1                	sub    %edx,%ecx
80101083:	ba 01 00 00 00       	mov    $0x1,%edx
80101088:	d3 e2                	shl    %cl,%edx
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
801010a7:	83 c0 01             	add    $0x1,%eax
801010aa:	eb b6                	jmp    80101062 <balloc+0x5a>
801010ac:	83 ec 0c             	sub    $0xc,%esp
801010af:	68 9f 66 10 80       	push   $0x8010669f
801010b4:	e8 8f f2 ff ff       	call   80100348 <panic>
801010b9:	09 ca                	or     %ecx,%edx
801010bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010be:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010c1:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	89 c6                	mov    %eax,%esi
801010ca:	50                   	push   %eax
801010cb:	e8 09 19 00 00       	call   801029d9 <log_write>
801010d0:	89 34 24             	mov    %esi,(%esp)
801010d3:	e8 fd f0 ff ff       	call   801001d5 <brelse>
801010d8:	89 da                	mov    %ebx,%edx
801010da:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010dd:	e8 eb fe ff ff       	call   80100fcd <bzero>
801010e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010e8:	5b                   	pop    %ebx
801010e9:	5e                   	pop    %esi
801010ea:	5f                   	pop    %edi
801010eb:	5d                   	pop    %ebp
801010ec:	c3                   	ret    

801010ed <bmap>:
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	57                   	push   %edi
801010f1:	56                   	push   %esi
801010f2:	53                   	push   %ebx
801010f3:	83 ec 1c             	sub    $0x1c,%esp
801010f6:	89 c6                	mov    %eax,%esi
801010f8:	89 d7                	mov    %edx,%edi
801010fa:	83 fa 0b             	cmp    $0xb,%edx
801010fd:	77 17                	ja     80101116 <bmap+0x29>
801010ff:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
80101103:	85 db                	test   %ebx,%ebx
80101105:	75 4a                	jne    80101151 <bmap+0x64>
80101107:	8b 00                	mov    (%eax),%eax
80101109:	e8 fa fe ff ff       	call   80101008 <balloc>
8010110e:	89 c3                	mov    %eax,%ebx
80101110:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101114:	eb 3b                	jmp    80101151 <bmap+0x64>
80101116:	8d 5a f4             	lea    -0xc(%edx),%ebx
80101119:	83 fb 7f             	cmp    $0x7f,%ebx
8010111c:	77 68                	ja     80101186 <bmap+0x99>
8010111e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101124:	85 c0                	test   %eax,%eax
80101126:	74 33                	je     8010115b <bmap+0x6e>
80101128:	83 ec 08             	sub    $0x8,%esp
8010112b:	50                   	push   %eax
8010112c:	ff 36                	pushl  (%esi)
8010112e:	e8 39 f0 ff ff       	call   8010016c <bread>
80101133:	89 c7                	mov    %eax,%edi
80101135:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
80101139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010113c:	8b 18                	mov    (%eax),%ebx
8010113e:	83 c4 10             	add    $0x10,%esp
80101141:	85 db                	test   %ebx,%ebx
80101143:	74 25                	je     8010116a <bmap+0x7d>
80101145:	83 ec 0c             	sub    $0xc,%esp
80101148:	57                   	push   %edi
80101149:	e8 87 f0 ff ff       	call   801001d5 <brelse>
8010114e:	83 c4 10             	add    $0x10,%esp
80101151:	89 d8                	mov    %ebx,%eax
80101153:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101156:	5b                   	pop    %ebx
80101157:	5e                   	pop    %esi
80101158:	5f                   	pop    %edi
80101159:	5d                   	pop    %ebp
8010115a:	c3                   	ret    
8010115b:	8b 06                	mov    (%esi),%eax
8010115d:	e8 a6 fe ff ff       	call   80101008 <balloc>
80101162:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101168:	eb be                	jmp    80101128 <bmap+0x3b>
8010116a:	8b 06                	mov    (%esi),%eax
8010116c:	e8 97 fe ff ff       	call   80101008 <balloc>
80101171:	89 c3                	mov    %eax,%ebx
80101173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101176:	89 18                	mov    %ebx,(%eax)
80101178:	83 ec 0c             	sub    $0xc,%esp
8010117b:	57                   	push   %edi
8010117c:	e8 58 18 00 00       	call   801029d9 <log_write>
80101181:	83 c4 10             	add    $0x10,%esp
80101184:	eb bf                	jmp    80101145 <bmap+0x58>
80101186:	83 ec 0c             	sub    $0xc,%esp
80101189:	68 b5 66 10 80       	push   $0x801066b5
8010118e:	e8 b5 f1 ff ff       	call   80100348 <panic>

80101193 <iget>:
80101193:	55                   	push   %ebp
80101194:	89 e5                	mov    %esp,%ebp
80101196:	57                   	push   %edi
80101197:	56                   	push   %esi
80101198:	53                   	push   %ebx
80101199:	83 ec 28             	sub    $0x28,%esp
8010119c:	89 c7                	mov    %eax,%edi
8010119e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011a1:	68 00 fa 11 80       	push   $0x8011fa00
801011a6:	e8 02 2b 00 00       	call   80103cad <acquire>
801011ab:	83 c4 10             	add    $0x10,%esp
801011ae:	be 00 00 00 00       	mov    $0x0,%esi
801011b3:	bb 34 fa 11 80       	mov    $0x8011fa34,%ebx
801011b8:	eb 0a                	jmp    801011c4 <iget+0x31>
801011ba:	85 f6                	test   %esi,%esi
801011bc:	74 3b                	je     801011f9 <iget+0x66>
801011be:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011c4:	81 fb 54 16 12 80    	cmp    $0x80121654,%ebx
801011ca:	73 35                	jae    80101201 <iget+0x6e>
801011cc:	8b 43 08             	mov    0x8(%ebx),%eax
801011cf:	85 c0                	test   %eax,%eax
801011d1:	7e e7                	jle    801011ba <iget+0x27>
801011d3:	39 3b                	cmp    %edi,(%ebx)
801011d5:	75 e3                	jne    801011ba <iget+0x27>
801011d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011da:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011dd:	75 db                	jne    801011ba <iget+0x27>
801011df:	83 c0 01             	add    $0x1,%eax
801011e2:	89 43 08             	mov    %eax,0x8(%ebx)
801011e5:	83 ec 0c             	sub    $0xc,%esp
801011e8:	68 00 fa 11 80       	push   $0x8011fa00
801011ed:	e8 20 2b 00 00       	call   80103d12 <release>
801011f2:	83 c4 10             	add    $0x10,%esp
801011f5:	89 de                	mov    %ebx,%esi
801011f7:	eb 32                	jmp    8010122b <iget+0x98>
801011f9:	85 c0                	test   %eax,%eax
801011fb:	75 c1                	jne    801011be <iget+0x2b>
801011fd:	89 de                	mov    %ebx,%esi
801011ff:	eb bd                	jmp    801011be <iget+0x2b>
80101201:	85 f6                	test   %esi,%esi
80101203:	74 30                	je     80101235 <iget+0xa2>
80101205:	89 3e                	mov    %edi,(%esi)
80101207:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010120a:	89 46 04             	mov    %eax,0x4(%esi)
8010120d:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
80101214:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
8010121b:	83 ec 0c             	sub    $0xc,%esp
8010121e:	68 00 fa 11 80       	push   $0x8011fa00
80101223:	e8 ea 2a 00 00       	call   80103d12 <release>
80101228:	83 c4 10             	add    $0x10,%esp
8010122b:	89 f0                	mov    %esi,%eax
8010122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101230:	5b                   	pop    %ebx
80101231:	5e                   	pop    %esi
80101232:	5f                   	pop    %edi
80101233:	5d                   	pop    %ebp
80101234:	c3                   	ret    
80101235:	83 ec 0c             	sub    $0xc,%esp
80101238:	68 c8 66 10 80       	push   $0x801066c8
8010123d:	e8 06 f1 ff ff       	call   80100348 <panic>

80101242 <readsb>:
80101242:	55                   	push   %ebp
80101243:	89 e5                	mov    %esp,%ebp
80101245:	53                   	push   %ebx
80101246:	83 ec 0c             	sub    $0xc,%esp
80101249:	6a 01                	push   $0x1
8010124b:	ff 75 08             	pushl  0x8(%ebp)
8010124e:	e8 19 ef ff ff       	call   8010016c <bread>
80101253:	89 c3                	mov    %eax,%ebx
80101255:	8d 40 5c             	lea    0x5c(%eax),%eax
80101258:	83 c4 0c             	add    $0xc,%esp
8010125b:	6a 1c                	push   $0x1c
8010125d:	50                   	push   %eax
8010125e:	ff 75 0c             	pushl  0xc(%ebp)
80101261:	e8 6e 2b 00 00       	call   80103dd4 <memmove>
80101266:	89 1c 24             	mov    %ebx,(%esp)
80101269:	e8 67 ef ff ff       	call   801001d5 <brelse>
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101274:	c9                   	leave  
80101275:	c3                   	ret    

80101276 <bfree>:
80101276:	55                   	push   %ebp
80101277:	89 e5                	mov    %esp,%ebp
80101279:	56                   	push   %esi
8010127a:	53                   	push   %ebx
8010127b:	89 c6                	mov    %eax,%esi
8010127d:	89 d3                	mov    %edx,%ebx
8010127f:	83 ec 08             	sub    $0x8,%esp
80101282:	68 e0 f9 11 80       	push   $0x8011f9e0
80101287:	50                   	push   %eax
80101288:	e8 b5 ff ff ff       	call   80101242 <readsb>
8010128d:	89 d8                	mov    %ebx,%eax
8010128f:	c1 e8 0c             	shr    $0xc,%eax
80101292:	03 05 f8 f9 11 80    	add    0x8011f9f8,%eax
80101298:	83 c4 08             	add    $0x8,%esp
8010129b:	50                   	push   %eax
8010129c:	56                   	push   %esi
8010129d:	e8 ca ee ff ff       	call   8010016c <bread>
801012a2:	89 c6                	mov    %eax,%esi
801012a4:	89 d9                	mov    %ebx,%ecx
801012a6:	83 e1 07             	and    $0x7,%ecx
801012a9:	b8 01 00 00 00       	mov    $0x1,%eax
801012ae:	d3 e0                	shl    %cl,%eax
801012b0:	83 c4 10             	add    $0x10,%esp
801012b3:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012b9:	c1 fb 03             	sar    $0x3,%ebx
801012bc:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012c1:	0f b6 ca             	movzbl %dl,%ecx
801012c4:	85 c1                	test   %eax,%ecx
801012c6:	74 23                	je     801012eb <bfree+0x75>
801012c8:	f7 d0                	not    %eax
801012ca:	21 d0                	and    %edx,%eax
801012cc:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
801012d0:	83 ec 0c             	sub    $0xc,%esp
801012d3:	56                   	push   %esi
801012d4:	e8 00 17 00 00       	call   801029d9 <log_write>
801012d9:	89 34 24             	mov    %esi,(%esp)
801012dc:	e8 f4 ee ff ff       	call   801001d5 <brelse>
801012e1:	83 c4 10             	add    $0x10,%esp
801012e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012e7:	5b                   	pop    %ebx
801012e8:	5e                   	pop    %esi
801012e9:	5d                   	pop    %ebp
801012ea:	c3                   	ret    
801012eb:	83 ec 0c             	sub    $0xc,%esp
801012ee:	68 d8 66 10 80       	push   $0x801066d8
801012f3:	e8 50 f0 ff ff       	call   80100348 <panic>

801012f8 <iinit>:
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	53                   	push   %ebx
801012fc:	83 ec 0c             	sub    $0xc,%esp
801012ff:	68 eb 66 10 80       	push   $0x801066eb
80101304:	68 00 fa 11 80       	push   $0x8011fa00
80101309:	e8 63 28 00 00       	call   80103b71 <initlock>
8010130e:	83 c4 10             	add    $0x10,%esp
80101311:	bb 00 00 00 00       	mov    $0x0,%ebx
80101316:	eb 21                	jmp    80101339 <iinit+0x41>
80101318:	83 ec 08             	sub    $0x8,%esp
8010131b:	68 f2 66 10 80       	push   $0x801066f2
80101320:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101323:	89 d0                	mov    %edx,%eax
80101325:	c1 e0 04             	shl    $0x4,%eax
80101328:	05 40 fa 11 80       	add    $0x8011fa40,%eax
8010132d:	50                   	push   %eax
8010132e:	e8 33 27 00 00       	call   80103a66 <initsleeplock>
80101333:	83 c3 01             	add    $0x1,%ebx
80101336:	83 c4 10             	add    $0x10,%esp
80101339:	83 fb 31             	cmp    $0x31,%ebx
8010133c:	7e da                	jle    80101318 <iinit+0x20>
8010133e:	83 ec 08             	sub    $0x8,%esp
80101341:	68 e0 f9 11 80       	push   $0x8011f9e0
80101346:	ff 75 08             	pushl  0x8(%ebp)
80101349:	e8 f4 fe ff ff       	call   80101242 <readsb>
8010134e:	ff 35 f8 f9 11 80    	pushl  0x8011f9f8
80101354:	ff 35 f4 f9 11 80    	pushl  0x8011f9f4
8010135a:	ff 35 f0 f9 11 80    	pushl  0x8011f9f0
80101360:	ff 35 ec f9 11 80    	pushl  0x8011f9ec
80101366:	ff 35 e8 f9 11 80    	pushl  0x8011f9e8
8010136c:	ff 35 e4 f9 11 80    	pushl  0x8011f9e4
80101372:	ff 35 e0 f9 11 80    	pushl  0x8011f9e0
80101378:	68 58 67 10 80       	push   $0x80106758
8010137d:	e8 89 f2 ff ff       	call   8010060b <cprintf>
80101382:	83 c4 30             	add    $0x30,%esp
80101385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101388:	c9                   	leave  
80101389:	c3                   	ret    

8010138a <ialloc>:
8010138a:	55                   	push   %ebp
8010138b:	89 e5                	mov    %esp,%ebp
8010138d:	57                   	push   %edi
8010138e:	56                   	push   %esi
8010138f:	53                   	push   %ebx
80101390:	83 ec 1c             	sub    $0x1c,%esp
80101393:	8b 45 0c             	mov    0xc(%ebp),%eax
80101396:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101399:	bb 01 00 00 00       	mov    $0x1,%ebx
8010139e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801013a1:	39 1d e8 f9 11 80    	cmp    %ebx,0x8011f9e8
801013a7:	76 3f                	jbe    801013e8 <ialloc+0x5e>
801013a9:	89 d8                	mov    %ebx,%eax
801013ab:	c1 e8 03             	shr    $0x3,%eax
801013ae:	03 05 f4 f9 11 80    	add    0x8011f9f4,%eax
801013b4:	83 ec 08             	sub    $0x8,%esp
801013b7:	50                   	push   %eax
801013b8:	ff 75 08             	pushl  0x8(%ebp)
801013bb:	e8 ac ed ff ff       	call   8010016c <bread>
801013c0:	89 c6                	mov    %eax,%esi
801013c2:	89 d8                	mov    %ebx,%eax
801013c4:	83 e0 07             	and    $0x7,%eax
801013c7:	c1 e0 06             	shl    $0x6,%eax
801013ca:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
801013ce:	83 c4 10             	add    $0x10,%esp
801013d1:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013d5:	74 1e                	je     801013f5 <ialloc+0x6b>
801013d7:	83 ec 0c             	sub    $0xc,%esp
801013da:	56                   	push   %esi
801013db:	e8 f5 ed ff ff       	call   801001d5 <brelse>
801013e0:	83 c3 01             	add    $0x1,%ebx
801013e3:	83 c4 10             	add    $0x10,%esp
801013e6:	eb b6                	jmp    8010139e <ialloc+0x14>
801013e8:	83 ec 0c             	sub    $0xc,%esp
801013eb:	68 f8 66 10 80       	push   $0x801066f8
801013f0:	e8 53 ef ff ff       	call   80100348 <panic>
801013f5:	83 ec 04             	sub    $0x4,%esp
801013f8:	6a 40                	push   $0x40
801013fa:	6a 00                	push   $0x0
801013fc:	57                   	push   %edi
801013fd:	e8 57 29 00 00       	call   80103d59 <memset>
80101402:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101406:	66 89 07             	mov    %ax,(%edi)
80101409:	89 34 24             	mov    %esi,(%esp)
8010140c:	e8 c8 15 00 00       	call   801029d9 <log_write>
80101411:	89 34 24             	mov    %esi,(%esp)
80101414:	e8 bc ed ff ff       	call   801001d5 <brelse>
80101419:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010141c:	8b 45 08             	mov    0x8(%ebp),%eax
8010141f:	e8 6f fd ff ff       	call   80101193 <iget>
80101424:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101427:	5b                   	pop    %ebx
80101428:	5e                   	pop    %esi
80101429:	5f                   	pop    %edi
8010142a:	5d                   	pop    %ebp
8010142b:	c3                   	ret    

8010142c <iupdate>:
8010142c:	55                   	push   %ebp
8010142d:	89 e5                	mov    %esp,%ebp
8010142f:	56                   	push   %esi
80101430:	53                   	push   %ebx
80101431:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101434:	8b 43 04             	mov    0x4(%ebx),%eax
80101437:	c1 e8 03             	shr    $0x3,%eax
8010143a:	03 05 f4 f9 11 80    	add    0x8011f9f4,%eax
80101440:	83 ec 08             	sub    $0x8,%esp
80101443:	50                   	push   %eax
80101444:	ff 33                	pushl  (%ebx)
80101446:	e8 21 ed ff ff       	call   8010016c <bread>
8010144b:	89 c6                	mov    %eax,%esi
8010144d:	8b 43 04             	mov    0x4(%ebx),%eax
80101450:	83 e0 07             	and    $0x7,%eax
80101453:	c1 e0 06             	shl    $0x6,%eax
80101456:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
8010145a:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
8010145e:	66 89 10             	mov    %dx,(%eax)
80101461:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101465:	66 89 50 02          	mov    %dx,0x2(%eax)
80101469:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010146d:	66 89 50 04          	mov    %dx,0x4(%eax)
80101471:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101475:	66 89 50 06          	mov    %dx,0x6(%eax)
80101479:	8b 53 58             	mov    0x58(%ebx),%edx
8010147c:	89 50 08             	mov    %edx,0x8(%eax)
8010147f:	83 c3 5c             	add    $0x5c,%ebx
80101482:	83 c0 0c             	add    $0xc,%eax
80101485:	83 c4 0c             	add    $0xc,%esp
80101488:	6a 34                	push   $0x34
8010148a:	53                   	push   %ebx
8010148b:	50                   	push   %eax
8010148c:	e8 43 29 00 00       	call   80103dd4 <memmove>
80101491:	89 34 24             	mov    %esi,(%esp)
80101494:	e8 40 15 00 00       	call   801029d9 <log_write>
80101499:	89 34 24             	mov    %esi,(%esp)
8010149c:	e8 34 ed ff ff       	call   801001d5 <brelse>
801014a1:	83 c4 10             	add    $0x10,%esp
801014a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014a7:	5b                   	pop    %ebx
801014a8:	5e                   	pop    %esi
801014a9:	5d                   	pop    %ebp
801014aa:	c3                   	ret    

801014ab <itrunc>:
801014ab:	55                   	push   %ebp
801014ac:	89 e5                	mov    %esp,%ebp
801014ae:	57                   	push   %edi
801014af:	56                   	push   %esi
801014b0:	53                   	push   %ebx
801014b1:	83 ec 1c             	sub    $0x1c,%esp
801014b4:	89 c6                	mov    %eax,%esi
801014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
801014bb:	eb 03                	jmp    801014c0 <itrunc+0x15>
801014bd:	83 c3 01             	add    $0x1,%ebx
801014c0:	83 fb 0b             	cmp    $0xb,%ebx
801014c3:	7f 19                	jg     801014de <itrunc+0x33>
801014c5:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014c9:	85 d2                	test   %edx,%edx
801014cb:	74 f0                	je     801014bd <itrunc+0x12>
801014cd:	8b 06                	mov    (%esi),%eax
801014cf:	e8 a2 fd ff ff       	call   80101276 <bfree>
801014d4:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014db:	00 
801014dc:	eb df                	jmp    801014bd <itrunc+0x12>
801014de:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014e4:	85 c0                	test   %eax,%eax
801014e6:	75 1b                	jne    80101503 <itrunc+0x58>
801014e8:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
801014ef:	83 ec 0c             	sub    $0xc,%esp
801014f2:	56                   	push   %esi
801014f3:	e8 34 ff ff ff       	call   8010142c <iupdate>
801014f8:	83 c4 10             	add    $0x10,%esp
801014fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014fe:	5b                   	pop    %ebx
801014ff:	5e                   	pop    %esi
80101500:	5f                   	pop    %edi
80101501:	5d                   	pop    %ebp
80101502:	c3                   	ret    
80101503:	83 ec 08             	sub    $0x8,%esp
80101506:	50                   	push   %eax
80101507:	ff 36                	pushl  (%esi)
80101509:	e8 5e ec ff ff       	call   8010016c <bread>
8010150e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101511:	8d 78 5c             	lea    0x5c(%eax),%edi
80101514:	83 c4 10             	add    $0x10,%esp
80101517:	bb 00 00 00 00       	mov    $0x0,%ebx
8010151c:	eb 03                	jmp    80101521 <itrunc+0x76>
8010151e:	83 c3 01             	add    $0x1,%ebx
80101521:	83 fb 7f             	cmp    $0x7f,%ebx
80101524:	77 10                	ja     80101536 <itrunc+0x8b>
80101526:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101529:	85 d2                	test   %edx,%edx
8010152b:	74 f1                	je     8010151e <itrunc+0x73>
8010152d:	8b 06                	mov    (%esi),%eax
8010152f:	e8 42 fd ff ff       	call   80101276 <bfree>
80101534:	eb e8                	jmp    8010151e <itrunc+0x73>
80101536:	83 ec 0c             	sub    $0xc,%esp
80101539:	ff 75 e4             	pushl  -0x1c(%ebp)
8010153c:	e8 94 ec ff ff       	call   801001d5 <brelse>
80101541:	8b 06                	mov    (%esi),%eax
80101543:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101549:	e8 28 fd ff ff       	call   80101276 <bfree>
8010154e:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101555:	00 00 00 
80101558:	83 c4 10             	add    $0x10,%esp
8010155b:	eb 8b                	jmp    801014e8 <itrunc+0x3d>

8010155d <idup>:
8010155d:	55                   	push   %ebp
8010155e:	89 e5                	mov    %esp,%ebp
80101560:	53                   	push   %ebx
80101561:	83 ec 10             	sub    $0x10,%esp
80101564:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101567:	68 00 fa 11 80       	push   $0x8011fa00
8010156c:	e8 3c 27 00 00       	call   80103cad <acquire>
80101571:	8b 43 08             	mov    0x8(%ebx),%eax
80101574:	83 c0 01             	add    $0x1,%eax
80101577:	89 43 08             	mov    %eax,0x8(%ebx)
8010157a:	c7 04 24 00 fa 11 80 	movl   $0x8011fa00,(%esp)
80101581:	e8 8c 27 00 00       	call   80103d12 <release>
80101586:	89 d8                	mov    %ebx,%eax
80101588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010158b:	c9                   	leave  
8010158c:	c3                   	ret    

8010158d <ilock>:
8010158d:	55                   	push   %ebp
8010158e:	89 e5                	mov    %esp,%ebp
80101590:	56                   	push   %esi
80101591:	53                   	push   %ebx
80101592:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101595:	85 db                	test   %ebx,%ebx
80101597:	74 22                	je     801015bb <ilock+0x2e>
80101599:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010159d:	7e 1c                	jle    801015bb <ilock+0x2e>
8010159f:	83 ec 0c             	sub    $0xc,%esp
801015a2:	8d 43 0c             	lea    0xc(%ebx),%eax
801015a5:	50                   	push   %eax
801015a6:	e8 ee 24 00 00       	call   80103a99 <acquiresleep>
801015ab:	83 c4 10             	add    $0x10,%esp
801015ae:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015b2:	74 14                	je     801015c8 <ilock+0x3b>
801015b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015b7:	5b                   	pop    %ebx
801015b8:	5e                   	pop    %esi
801015b9:	5d                   	pop    %ebp
801015ba:	c3                   	ret    
801015bb:	83 ec 0c             	sub    $0xc,%esp
801015be:	68 0a 67 10 80       	push   $0x8010670a
801015c3:	e8 80 ed ff ff       	call   80100348 <panic>
801015c8:	8b 43 04             	mov    0x4(%ebx),%eax
801015cb:	c1 e8 03             	shr    $0x3,%eax
801015ce:	03 05 f4 f9 11 80    	add    0x8011f9f4,%eax
801015d4:	83 ec 08             	sub    $0x8,%esp
801015d7:	50                   	push   %eax
801015d8:	ff 33                	pushl  (%ebx)
801015da:	e8 8d eb ff ff       	call   8010016c <bread>
801015df:	89 c6                	mov    %eax,%esi
801015e1:	8b 43 04             	mov    0x4(%ebx),%eax
801015e4:	83 e0 07             	and    $0x7,%eax
801015e7:	c1 e0 06             	shl    $0x6,%eax
801015ea:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
801015ee:	0f b7 10             	movzwl (%eax),%edx
801015f1:	66 89 53 50          	mov    %dx,0x50(%ebx)
801015f5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015f9:	66 89 53 52          	mov    %dx,0x52(%ebx)
801015fd:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101601:	66 89 53 54          	mov    %dx,0x54(%ebx)
80101605:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101609:	66 89 53 56          	mov    %dx,0x56(%ebx)
8010160d:	8b 50 08             	mov    0x8(%eax),%edx
80101610:	89 53 58             	mov    %edx,0x58(%ebx)
80101613:	83 c0 0c             	add    $0xc,%eax
80101616:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101619:	83 c4 0c             	add    $0xc,%esp
8010161c:	6a 34                	push   $0x34
8010161e:	50                   	push   %eax
8010161f:	52                   	push   %edx
80101620:	e8 af 27 00 00       	call   80103dd4 <memmove>
80101625:	89 34 24             	mov    %esi,(%esp)
80101628:	e8 a8 eb ff ff       	call   801001d5 <brelse>
8010162d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
80101634:	83 c4 10             	add    $0x10,%esp
80101637:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010163c:	0f 85 72 ff ff ff    	jne    801015b4 <ilock+0x27>
80101642:	83 ec 0c             	sub    $0xc,%esp
80101645:	68 10 67 10 80       	push   $0x80106710
8010164a:	e8 f9 ec ff ff       	call   80100348 <panic>

8010164f <iunlock>:
8010164f:	55                   	push   %ebp
80101650:	89 e5                	mov    %esp,%ebp
80101652:	56                   	push   %esi
80101653:	53                   	push   %ebx
80101654:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101657:	85 db                	test   %ebx,%ebx
80101659:	74 2c                	je     80101687 <iunlock+0x38>
8010165b:	8d 73 0c             	lea    0xc(%ebx),%esi
8010165e:	83 ec 0c             	sub    $0xc,%esp
80101661:	56                   	push   %esi
80101662:	e8 bc 24 00 00       	call   80103b23 <holdingsleep>
80101667:	83 c4 10             	add    $0x10,%esp
8010166a:	85 c0                	test   %eax,%eax
8010166c:	74 19                	je     80101687 <iunlock+0x38>
8010166e:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101672:	7e 13                	jle    80101687 <iunlock+0x38>
80101674:	83 ec 0c             	sub    $0xc,%esp
80101677:	56                   	push   %esi
80101678:	e8 6b 24 00 00       	call   80103ae8 <releasesleep>
8010167d:	83 c4 10             	add    $0x10,%esp
80101680:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101683:	5b                   	pop    %ebx
80101684:	5e                   	pop    %esi
80101685:	5d                   	pop    %ebp
80101686:	c3                   	ret    
80101687:	83 ec 0c             	sub    $0xc,%esp
8010168a:	68 1f 67 10 80       	push   $0x8010671f
8010168f:	e8 b4 ec ff ff       	call   80100348 <panic>

80101694 <iput>:
80101694:	55                   	push   %ebp
80101695:	89 e5                	mov    %esp,%ebp
80101697:	57                   	push   %edi
80101698:	56                   	push   %esi
80101699:	53                   	push   %ebx
8010169a:	83 ec 18             	sub    $0x18,%esp
8010169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
801016a0:	8d 73 0c             	lea    0xc(%ebx),%esi
801016a3:	56                   	push   %esi
801016a4:	e8 f0 23 00 00       	call   80103a99 <acquiresleep>
801016a9:	83 c4 10             	add    $0x10,%esp
801016ac:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016b0:	74 07                	je     801016b9 <iput+0x25>
801016b2:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016b7:	74 35                	je     801016ee <iput+0x5a>
801016b9:	83 ec 0c             	sub    $0xc,%esp
801016bc:	56                   	push   %esi
801016bd:	e8 26 24 00 00       	call   80103ae8 <releasesleep>
801016c2:	c7 04 24 00 fa 11 80 	movl   $0x8011fa00,(%esp)
801016c9:	e8 df 25 00 00       	call   80103cad <acquire>
801016ce:	8b 43 08             	mov    0x8(%ebx),%eax
801016d1:	83 e8 01             	sub    $0x1,%eax
801016d4:	89 43 08             	mov    %eax,0x8(%ebx)
801016d7:	c7 04 24 00 fa 11 80 	movl   $0x8011fa00,(%esp)
801016de:	e8 2f 26 00 00       	call   80103d12 <release>
801016e3:	83 c4 10             	add    $0x10,%esp
801016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016e9:	5b                   	pop    %ebx
801016ea:	5e                   	pop    %esi
801016eb:	5f                   	pop    %edi
801016ec:	5d                   	pop    %ebp
801016ed:	c3                   	ret    
801016ee:	83 ec 0c             	sub    $0xc,%esp
801016f1:	68 00 fa 11 80       	push   $0x8011fa00
801016f6:	e8 b2 25 00 00       	call   80103cad <acquire>
801016fb:	8b 7b 08             	mov    0x8(%ebx),%edi
801016fe:	c7 04 24 00 fa 11 80 	movl   $0x8011fa00,(%esp)
80101705:	e8 08 26 00 00       	call   80103d12 <release>
8010170a:	83 c4 10             	add    $0x10,%esp
8010170d:	83 ff 01             	cmp    $0x1,%edi
80101710:	75 a7                	jne    801016b9 <iput+0x25>
80101712:	89 d8                	mov    %ebx,%eax
80101714:	e8 92 fd ff ff       	call   801014ab <itrunc>
80101719:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
8010171f:	83 ec 0c             	sub    $0xc,%esp
80101722:	53                   	push   %ebx
80101723:	e8 04 fd ff ff       	call   8010142c <iupdate>
80101728:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
8010172f:	83 c4 10             	add    $0x10,%esp
80101732:	eb 85                	jmp    801016b9 <iput+0x25>

80101734 <iunlockput>:
80101734:	55                   	push   %ebp
80101735:	89 e5                	mov    %esp,%ebp
80101737:	53                   	push   %ebx
80101738:	83 ec 10             	sub    $0x10,%esp
8010173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010173e:	53                   	push   %ebx
8010173f:	e8 0b ff ff ff       	call   8010164f <iunlock>
80101744:	89 1c 24             	mov    %ebx,(%esp)
80101747:	e8 48 ff ff ff       	call   80101694 <iput>
8010174c:	83 c4 10             	add    $0x10,%esp
8010174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101752:	c9                   	leave  
80101753:	c3                   	ret    

80101754 <stati>:
80101754:	55                   	push   %ebp
80101755:	89 e5                	mov    %esp,%ebp
80101757:	8b 55 08             	mov    0x8(%ebp),%edx
8010175a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010175d:	8b 0a                	mov    (%edx),%ecx
8010175f:	89 48 04             	mov    %ecx,0x4(%eax)
80101762:	8b 4a 04             	mov    0x4(%edx),%ecx
80101765:	89 48 08             	mov    %ecx,0x8(%eax)
80101768:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010176c:	66 89 08             	mov    %cx,(%eax)
8010176f:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101773:	66 89 48 0c          	mov    %cx,0xc(%eax)
80101777:	8b 52 58             	mov    0x58(%edx),%edx
8010177a:	89 50 10             	mov    %edx,0x10(%eax)
8010177d:	5d                   	pop    %ebp
8010177e:	c3                   	ret    

8010177f <readi>:
8010177f:	55                   	push   %ebp
80101780:	89 e5                	mov    %esp,%ebp
80101782:	57                   	push   %edi
80101783:	56                   	push   %esi
80101784:	53                   	push   %ebx
80101785:	83 ec 1c             	sub    $0x1c,%esp
80101788:	8b 7d 10             	mov    0x10(%ebp),%edi
8010178b:	8b 45 08             	mov    0x8(%ebp),%eax
8010178e:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101793:	74 2c                	je     801017c1 <readi+0x42>
80101795:	8b 45 08             	mov    0x8(%ebp),%eax
80101798:	8b 40 58             	mov    0x58(%eax),%eax
8010179b:	39 f8                	cmp    %edi,%eax
8010179d:	0f 82 cb 00 00 00    	jb     8010186e <readi+0xef>
801017a3:	89 fa                	mov    %edi,%edx
801017a5:	03 55 14             	add    0x14(%ebp),%edx
801017a8:	0f 82 c7 00 00 00    	jb     80101875 <readi+0xf6>
801017ae:	39 d0                	cmp    %edx,%eax
801017b0:	73 05                	jae    801017b7 <readi+0x38>
801017b2:	29 f8                	sub    %edi,%eax
801017b4:	89 45 14             	mov    %eax,0x14(%ebp)
801017b7:	be 00 00 00 00       	mov    $0x0,%esi
801017bc:	e9 8f 00 00 00       	jmp    80101850 <readi+0xd1>
801017c1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017c5:	66 83 f8 09          	cmp    $0x9,%ax
801017c9:	0f 87 91 00 00 00    	ja     80101860 <readi+0xe1>
801017cf:	98                   	cwtl   
801017d0:	8b 04 c5 80 f9 11 80 	mov    -0x7fee0680(,%eax,8),%eax
801017d7:	85 c0                	test   %eax,%eax
801017d9:	0f 84 88 00 00 00    	je     80101867 <readi+0xe8>
801017df:	83 ec 04             	sub    $0x4,%esp
801017e2:	ff 75 14             	pushl  0x14(%ebp)
801017e5:	ff 75 0c             	pushl  0xc(%ebp)
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	ff d0                	call   *%eax
801017ed:	83 c4 10             	add    $0x10,%esp
801017f0:	eb 66                	jmp    80101858 <readi+0xd9>
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
8010180f:	89 f8                	mov    %edi,%eax
80101811:	25 ff 01 00 00       	and    $0x1ff,%eax
80101816:	bb 00 02 00 00       	mov    $0x200,%ebx
8010181b:	29 c3                	sub    %eax,%ebx
8010181d:	8b 55 14             	mov    0x14(%ebp),%edx
80101820:	29 f2                	sub    %esi,%edx
80101822:	83 c4 0c             	add    $0xc,%esp
80101825:	39 d3                	cmp    %edx,%ebx
80101827:	0f 47 da             	cmova  %edx,%ebx
8010182a:	53                   	push   %ebx
8010182b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010182e:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101832:	50                   	push   %eax
80101833:	ff 75 0c             	pushl  0xc(%ebp)
80101836:	e8 99 25 00 00       	call   80103dd4 <memmove>
8010183b:	83 c4 04             	add    $0x4,%esp
8010183e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101841:	e8 8f e9 ff ff       	call   801001d5 <brelse>
80101846:	01 de                	add    %ebx,%esi
80101848:	01 df                	add    %ebx,%edi
8010184a:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010184d:	83 c4 10             	add    $0x10,%esp
80101850:	39 75 14             	cmp    %esi,0x14(%ebp)
80101853:	77 9d                	ja     801017f2 <readi+0x73>
80101855:	8b 45 14             	mov    0x14(%ebp),%eax
80101858:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010185b:	5b                   	pop    %ebx
8010185c:	5e                   	pop    %esi
8010185d:	5f                   	pop    %edi
8010185e:	5d                   	pop    %ebp
8010185f:	c3                   	ret    
80101860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101865:	eb f1                	jmp    80101858 <readi+0xd9>
80101867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186c:	eb ea                	jmp    80101858 <readi+0xd9>
8010186e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101873:	eb e3                	jmp    80101858 <readi+0xd9>
80101875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010187a:	eb dc                	jmp    80101858 <readi+0xd9>

8010187c <writei>:
8010187c:	55                   	push   %ebp
8010187d:	89 e5                	mov    %esp,%ebp
8010187f:	57                   	push   %edi
80101880:	56                   	push   %esi
80101881:	53                   	push   %ebx
80101882:	83 ec 0c             	sub    $0xc,%esp
80101885:	8b 45 08             	mov    0x8(%ebp),%eax
80101888:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010188d:	74 2f                	je     801018be <writei+0x42>
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101895:	39 48 58             	cmp    %ecx,0x58(%eax)
80101898:	0f 82 f4 00 00 00    	jb     80101992 <writei+0x116>
8010189e:	89 c8                	mov    %ecx,%eax
801018a0:	03 45 14             	add    0x14(%ebp),%eax
801018a3:	0f 82 f0 00 00 00    	jb     80101999 <writei+0x11d>
801018a9:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018ae:	0f 87 ec 00 00 00    	ja     801019a0 <writei+0x124>
801018b4:	be 00 00 00 00       	mov    $0x0,%esi
801018b9:	e9 94 00 00 00       	jmp    80101952 <writei+0xd6>
801018be:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018c2:	66 83 f8 09          	cmp    $0x9,%ax
801018c6:	0f 87 b8 00 00 00    	ja     80101984 <writei+0x108>
801018cc:	98                   	cwtl   
801018cd:	8b 04 c5 84 f9 11 80 	mov    -0x7fee067c(,%eax,8),%eax
801018d4:	85 c0                	test   %eax,%eax
801018d6:	0f 84 af 00 00 00    	je     8010198b <writei+0x10f>
801018dc:	83 ec 04             	sub    $0x4,%esp
801018df:	ff 75 14             	pushl  0x14(%ebp)
801018e2:	ff 75 0c             	pushl  0xc(%ebp)
801018e5:	ff 75 08             	pushl  0x8(%ebp)
801018e8:	ff d0                	call   *%eax
801018ea:	83 c4 10             	add    $0x10,%esp
801018ed:	eb 7c                	jmp    8010196b <writei+0xef>
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
8010190d:	8b 45 10             	mov    0x10(%ebp),%eax
80101910:	25 ff 01 00 00       	and    $0x1ff,%eax
80101915:	bb 00 02 00 00       	mov    $0x200,%ebx
8010191a:	29 c3                	sub    %eax,%ebx
8010191c:	8b 55 14             	mov    0x14(%ebp),%edx
8010191f:	29 f2                	sub    %esi,%edx
80101921:	83 c4 0c             	add    $0xc,%esp
80101924:	39 d3                	cmp    %edx,%ebx
80101926:	0f 47 da             	cmova  %edx,%ebx
80101929:	53                   	push   %ebx
8010192a:	ff 75 0c             	pushl  0xc(%ebp)
8010192d:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101931:	50                   	push   %eax
80101932:	e8 9d 24 00 00       	call   80103dd4 <memmove>
80101937:	89 3c 24             	mov    %edi,(%esp)
8010193a:	e8 9a 10 00 00       	call   801029d9 <log_write>
8010193f:	89 3c 24             	mov    %edi,(%esp)
80101942:	e8 8e e8 ff ff       	call   801001d5 <brelse>
80101947:	01 de                	add    %ebx,%esi
80101949:	01 5d 10             	add    %ebx,0x10(%ebp)
8010194c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010194f:	83 c4 10             	add    $0x10,%esp
80101952:	3b 75 14             	cmp    0x14(%ebp),%esi
80101955:	72 98                	jb     801018ef <writei+0x73>
80101957:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010195b:	74 0b                	je     80101968 <writei+0xec>
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101963:	39 48 58             	cmp    %ecx,0x58(%eax)
80101966:	72 0b                	jb     80101973 <writei+0xf7>
80101968:	8b 45 14             	mov    0x14(%ebp),%eax
8010196b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010196e:	5b                   	pop    %ebx
8010196f:	5e                   	pop    %esi
80101970:	5f                   	pop    %edi
80101971:	5d                   	pop    %ebp
80101972:	c3                   	ret    
80101973:	89 48 58             	mov    %ecx,0x58(%eax)
80101976:	83 ec 0c             	sub    $0xc,%esp
80101979:	50                   	push   %eax
8010197a:	e8 ad fa ff ff       	call   8010142c <iupdate>
8010197f:	83 c4 10             	add    $0x10,%esp
80101982:	eb e4                	jmp    80101968 <writei+0xec>
80101984:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101989:	eb e0                	jmp    8010196b <writei+0xef>
8010198b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101990:	eb d9                	jmp    8010196b <writei+0xef>
80101992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101997:	eb d2                	jmp    8010196b <writei+0xef>
80101999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010199e:	eb cb                	jmp    8010196b <writei+0xef>
801019a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019a5:	eb c4                	jmp    8010196b <writei+0xef>

801019a7 <namecmp>:
801019a7:	55                   	push   %ebp
801019a8:	89 e5                	mov    %esp,%ebp
801019aa:	83 ec 0c             	sub    $0xc,%esp
801019ad:	6a 0e                	push   $0xe
801019af:	ff 75 0c             	pushl  0xc(%ebp)
801019b2:	ff 75 08             	pushl  0x8(%ebp)
801019b5:	e8 81 24 00 00       	call   80103e3b <strncmp>
801019ba:	c9                   	leave  
801019bb:	c3                   	ret    

801019bc <dirlookup>:
801019bc:	55                   	push   %ebp
801019bd:	89 e5                	mov    %esp,%ebp
801019bf:	57                   	push   %edi
801019c0:	56                   	push   %esi
801019c1:	53                   	push   %ebx
801019c2:	83 ec 1c             	sub    $0x1c,%esp
801019c5:	8b 75 08             	mov    0x8(%ebp),%esi
801019c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
801019cb:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019d0:	75 07                	jne    801019d9 <dirlookup+0x1d>
801019d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801019d7:	eb 1d                	jmp    801019f6 <dirlookup+0x3a>
801019d9:	83 ec 0c             	sub    $0xc,%esp
801019dc:	68 27 67 10 80       	push   $0x80106727
801019e1:	e8 62 e9 ff ff       	call   80100348 <panic>
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 39 67 10 80       	push   $0x80106739
801019ee:	e8 55 e9 ff ff       	call   80100348 <panic>
801019f3:	83 c3 10             	add    $0x10,%ebx
801019f6:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019f9:	76 48                	jbe    80101a43 <dirlookup+0x87>
801019fb:	6a 10                	push   $0x10
801019fd:	53                   	push   %ebx
801019fe:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101a01:	50                   	push   %eax
80101a02:	56                   	push   %esi
80101a03:	e8 77 fd ff ff       	call   8010177f <readi>
80101a08:	83 c4 10             	add    $0x10,%esp
80101a0b:	83 f8 10             	cmp    $0x10,%eax
80101a0e:	75 d6                	jne    801019e6 <dirlookup+0x2a>
80101a10:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a15:	74 dc                	je     801019f3 <dirlookup+0x37>
80101a17:	83 ec 08             	sub    $0x8,%esp
80101a1a:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a1d:	50                   	push   %eax
80101a1e:	57                   	push   %edi
80101a1f:	e8 83 ff ff ff       	call   801019a7 <namecmp>
80101a24:	83 c4 10             	add    $0x10,%esp
80101a27:	85 c0                	test   %eax,%eax
80101a29:	75 c8                	jne    801019f3 <dirlookup+0x37>
80101a2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a2f:	74 05                	je     80101a36 <dirlookup+0x7a>
80101a31:	8b 45 10             	mov    0x10(%ebp),%eax
80101a34:	89 18                	mov    %ebx,(%eax)
80101a36:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
80101a3a:	8b 06                	mov    (%esi),%eax
80101a3c:	e8 52 f7 ff ff       	call   80101193 <iget>
80101a41:	eb 05                	jmp    80101a48 <dirlookup+0x8c>
80101a43:	b8 00 00 00 00       	mov    $0x0,%eax
80101a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a4b:	5b                   	pop    %ebx
80101a4c:	5e                   	pop    %esi
80101a4d:	5f                   	pop    %edi
80101a4e:	5d                   	pop    %ebp
80101a4f:	c3                   	ret    

80101a50 <namex>:
80101a50:	55                   	push   %ebp
80101a51:	89 e5                	mov    %esp,%ebp
80101a53:	57                   	push   %edi
80101a54:	56                   	push   %esi
80101a55:	53                   	push   %ebx
80101a56:	83 ec 1c             	sub    $0x1c,%esp
80101a59:	89 c6                	mov    %eax,%esi
80101a5b:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101a61:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a64:	74 17                	je     80101a7d <namex+0x2d>
80101a66:	e8 a0 18 00 00       	call   8010330b <myproc>
80101a6b:	83 ec 0c             	sub    $0xc,%esp
80101a6e:	ff 70 68             	pushl  0x68(%eax)
80101a71:	e8 e7 fa ff ff       	call   8010155d <idup>
80101a76:	89 c3                	mov    %eax,%ebx
80101a78:	83 c4 10             	add    $0x10,%esp
80101a7b:	eb 53                	jmp    80101ad0 <namex+0x80>
80101a7d:	ba 01 00 00 00       	mov    $0x1,%edx
80101a82:	b8 01 00 00 00       	mov    $0x1,%eax
80101a87:	e8 07 f7 ff ff       	call   80101193 <iget>
80101a8c:	89 c3                	mov    %eax,%ebx
80101a8e:	eb 40                	jmp    80101ad0 <namex+0x80>
80101a90:	83 ec 0c             	sub    $0xc,%esp
80101a93:	53                   	push   %ebx
80101a94:	e8 9b fc ff ff       	call   80101734 <iunlockput>
80101a99:	83 c4 10             	add    $0x10,%esp
80101a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
80101aa1:	89 d8                	mov    %ebx,%eax
80101aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aa6:	5b                   	pop    %ebx
80101aa7:	5e                   	pop    %esi
80101aa8:	5f                   	pop    %edi
80101aa9:	5d                   	pop    %ebp
80101aaa:	c3                   	ret    
80101aab:	83 ec 04             	sub    $0x4,%esp
80101aae:	6a 00                	push   $0x0
80101ab0:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ab3:	53                   	push   %ebx
80101ab4:	e8 03 ff ff ff       	call   801019bc <dirlookup>
80101ab9:	89 c7                	mov    %eax,%edi
80101abb:	83 c4 10             	add    $0x10,%esp
80101abe:	85 c0                	test   %eax,%eax
80101ac0:	74 4a                	je     80101b0c <namex+0xbc>
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	53                   	push   %ebx
80101ac6:	e8 69 fc ff ff       	call   80101734 <iunlockput>
80101acb:	83 c4 10             	add    $0x10,%esp
80101ace:	89 fb                	mov    %edi,%ebx
80101ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ad3:	89 f0                	mov    %esi,%eax
80101ad5:	e8 77 f4 ff ff       	call   80100f51 <skipelem>
80101ada:	89 c6                	mov    %eax,%esi
80101adc:	85 c0                	test   %eax,%eax
80101ade:	74 3c                	je     80101b1c <namex+0xcc>
80101ae0:	83 ec 0c             	sub    $0xc,%esp
80101ae3:	53                   	push   %ebx
80101ae4:	e8 a4 fa ff ff       	call   8010158d <ilock>
80101ae9:	83 c4 10             	add    $0x10,%esp
80101aec:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101af1:	75 9d                	jne    80101a90 <namex+0x40>
80101af3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101af7:	74 b2                	je     80101aab <namex+0x5b>
80101af9:	80 3e 00             	cmpb   $0x0,(%esi)
80101afc:	75 ad                	jne    80101aab <namex+0x5b>
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	53                   	push   %ebx
80101b02:	e8 48 fb ff ff       	call   8010164f <iunlock>
80101b07:	83 c4 10             	add    $0x10,%esp
80101b0a:	eb 95                	jmp    80101aa1 <namex+0x51>
80101b0c:	83 ec 0c             	sub    $0xc,%esp
80101b0f:	53                   	push   %ebx
80101b10:	e8 1f fc ff ff       	call   80101734 <iunlockput>
80101b15:	83 c4 10             	add    $0x10,%esp
80101b18:	89 fb                	mov    %edi,%ebx
80101b1a:	eb 85                	jmp    80101aa1 <namex+0x51>
80101b1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b20:	0f 84 7b ff ff ff    	je     80101aa1 <namex+0x51>
80101b26:	83 ec 0c             	sub    $0xc,%esp
80101b29:	53                   	push   %ebx
80101b2a:	e8 65 fb ff ff       	call   80101694 <iput>
80101b2f:	83 c4 10             	add    $0x10,%esp
80101b32:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b37:	e9 65 ff ff ff       	jmp    80101aa1 <namex+0x51>

80101b3c <dirlink>:
80101b3c:	55                   	push   %ebp
80101b3d:	89 e5                	mov    %esp,%ebp
80101b3f:	57                   	push   %edi
80101b40:	56                   	push   %esi
80101b41:	53                   	push   %ebx
80101b42:	83 ec 20             	sub    $0x20,%esp
80101b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b48:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101b4b:	6a 00                	push   $0x0
80101b4d:	57                   	push   %edi
80101b4e:	53                   	push   %ebx
80101b4f:	e8 68 fe ff ff       	call   801019bc <dirlookup>
80101b54:	83 c4 10             	add    $0x10,%esp
80101b57:	85 c0                	test   %eax,%eax
80101b59:	75 2d                	jne    80101b88 <dirlink+0x4c>
80101b5b:	b8 00 00 00 00       	mov    $0x0,%eax
80101b60:	89 c6                	mov    %eax,%esi
80101b62:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b65:	76 41                	jbe    80101ba8 <dirlink+0x6c>
80101b67:	6a 10                	push   $0x10
80101b69:	50                   	push   %eax
80101b6a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b6d:	50                   	push   %eax
80101b6e:	53                   	push   %ebx
80101b6f:	e8 0b fc ff ff       	call   8010177f <readi>
80101b74:	83 c4 10             	add    $0x10,%esp
80101b77:	83 f8 10             	cmp    $0x10,%eax
80101b7a:	75 1f                	jne    80101b9b <dirlink+0x5f>
80101b7c:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b81:	74 25                	je     80101ba8 <dirlink+0x6c>
80101b83:	8d 46 10             	lea    0x10(%esi),%eax
80101b86:	eb d8                	jmp    80101b60 <dirlink+0x24>
80101b88:	83 ec 0c             	sub    $0xc,%esp
80101b8b:	50                   	push   %eax
80101b8c:	e8 03 fb ff ff       	call   80101694 <iput>
80101b91:	83 c4 10             	add    $0x10,%esp
80101b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b99:	eb 3d                	jmp    80101bd8 <dirlink+0x9c>
80101b9b:	83 ec 0c             	sub    $0xc,%esp
80101b9e:	68 48 67 10 80       	push   $0x80106748
80101ba3:	e8 a0 e7 ff ff       	call   80100348 <panic>
80101ba8:	83 ec 04             	sub    $0x4,%esp
80101bab:	6a 0e                	push   $0xe
80101bad:	57                   	push   %edi
80101bae:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bb1:	8d 45 da             	lea    -0x26(%ebp),%eax
80101bb4:	50                   	push   %eax
80101bb5:	e8 be 22 00 00       	call   80103e78 <strncpy>
80101bba:	8b 45 10             	mov    0x10(%ebp),%eax
80101bbd:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
80101bc1:	6a 10                	push   $0x10
80101bc3:	56                   	push   %esi
80101bc4:	57                   	push   %edi
80101bc5:	53                   	push   %ebx
80101bc6:	e8 b1 fc ff ff       	call   8010187c <writei>
80101bcb:	83 c4 20             	add    $0x20,%esp
80101bce:	83 f8 10             	cmp    $0x10,%eax
80101bd1:	75 0d                	jne    80101be0 <dirlink+0xa4>
80101bd3:	b8 00 00 00 00       	mov    $0x0,%eax
80101bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bdb:	5b                   	pop    %ebx
80101bdc:	5e                   	pop    %esi
80101bdd:	5f                   	pop    %edi
80101bde:	5d                   	pop    %ebp
80101bdf:	c3                   	ret    
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 54 6d 10 80       	push   $0x80106d54
80101be8:	e8 5b e7 ff ff       	call   80100348 <panic>

80101bed <namei>:
80101bed:	55                   	push   %ebp
80101bee:	89 e5                	mov    %esp,%ebp
80101bf0:	83 ec 18             	sub    $0x18,%esp
80101bf3:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bf6:	ba 00 00 00 00       	mov    $0x0,%edx
80101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfe:	e8 4d fe ff ff       	call   80101a50 <namex>
80101c03:	c9                   	leave  
80101c04:	c3                   	ret    

80101c05 <nameiparent>:
80101c05:	55                   	push   %ebp
80101c06:	89 e5                	mov    %esp,%ebp
80101c08:	83 ec 08             	sub    $0x8,%esp
80101c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c0e:	ba 01 00 00 00       	mov    $0x1,%edx
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	e8 35 fe ff ff       	call   80101a50 <namex>
80101c1b:	c9                   	leave  
80101c1c:	c3                   	ret    

80101c1d <idewait>:
80101c1d:	55                   	push   %ebp
80101c1e:	89 e5                	mov    %esp,%ebp
80101c20:	89 c1                	mov    %eax,%ecx
80101c22:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c27:	ec                   	in     (%dx),%al
80101c28:	89 c2                	mov    %eax,%edx
80101c2a:	83 e0 c0             	and    $0xffffffc0,%eax
80101c2d:	3c 40                	cmp    $0x40,%al
80101c2f:	75 f1                	jne    80101c22 <idewait+0x5>
80101c31:	85 c9                	test   %ecx,%ecx
80101c33:	74 0c                	je     80101c41 <idewait+0x24>
80101c35:	f6 c2 21             	test   $0x21,%dl
80101c38:	75 0e                	jne    80101c48 <idewait+0x2b>
80101c3a:	b8 00 00 00 00       	mov    $0x0,%eax
80101c3f:	eb 05                	jmp    80101c46 <idewait+0x29>
80101c41:	b8 00 00 00 00       	mov    $0x0,%eax
80101c46:	5d                   	pop    %ebp
80101c47:	c3                   	ret    
80101c48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c4d:	eb f7                	jmp    80101c46 <idewait+0x29>

80101c4f <idestart>:
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	56                   	push   %esi
80101c53:	53                   	push   %ebx
80101c54:	85 c0                	test   %eax,%eax
80101c56:	74 7d                	je     80101cd5 <idestart+0x86>
80101c58:	89 c6                	mov    %eax,%esi
80101c5a:	8b 58 08             	mov    0x8(%eax),%ebx
80101c5d:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c63:	77 7d                	ja     80101ce2 <idestart+0x93>
80101c65:	b8 00 00 00 00       	mov    $0x0,%eax
80101c6a:	e8 ae ff ff ff       	call   80101c1d <idewait>
80101c6f:	b8 00 00 00 00       	mov    $0x0,%eax
80101c74:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c79:	ee                   	out    %al,(%dx)
80101c7a:	b8 01 00 00 00       	mov    $0x1,%eax
80101c7f:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c84:	ee                   	out    %al,(%dx)
80101c85:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c8a:	89 d8                	mov    %ebx,%eax
80101c8c:	ee                   	out    %al,(%dx)
80101c8d:	89 d8                	mov    %ebx,%eax
80101c8f:	c1 f8 08             	sar    $0x8,%eax
80101c92:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c97:	ee                   	out    %al,(%dx)
80101c98:	89 d8                	mov    %ebx,%eax
80101c9a:	c1 f8 10             	sar    $0x10,%eax
80101c9d:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101ca2:	ee                   	out    %al,(%dx)
80101ca3:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101ca7:	c1 e0 04             	shl    $0x4,%eax
80101caa:	83 e0 10             	and    $0x10,%eax
80101cad:	c1 fb 18             	sar    $0x18,%ebx
80101cb0:	83 e3 0f             	and    $0xf,%ebx
80101cb3:	09 d8                	or     %ebx,%eax
80101cb5:	83 c8 e0             	or     $0xffffffe0,%eax
80101cb8:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cbd:	ee                   	out    %al,(%dx)
80101cbe:	f6 06 04             	testb  $0x4,(%esi)
80101cc1:	75 2c                	jne    80101cef <idestart+0xa0>
80101cc3:	b8 20 00 00 00       	mov    $0x20,%eax
80101cc8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ccd:	ee                   	out    %al,(%dx)
80101cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cd1:	5b                   	pop    %ebx
80101cd2:	5e                   	pop    %esi
80101cd3:	5d                   	pop    %ebp
80101cd4:	c3                   	ret    
80101cd5:	83 ec 0c             	sub    $0xc,%esp
80101cd8:	68 ab 67 10 80       	push   $0x801067ab
80101cdd:	e8 66 e6 ff ff       	call   80100348 <panic>
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	68 b4 67 10 80       	push   $0x801067b4
80101cea:	e8 59 e6 ff ff       	call   80100348 <panic>
80101cef:	b8 30 00 00 00       	mov    $0x30,%eax
80101cf4:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cf9:	ee                   	out    %al,(%dx)
80101cfa:	83 c6 5c             	add    $0x5c,%esi
80101cfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d07:	fc                   	cld    
80101d08:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d0a:	eb c2                	jmp    80101cce <idestart+0x7f>

80101d0c <ideinit>:
80101d0c:	55                   	push   %ebp
80101d0d:	89 e5                	mov    %esp,%ebp
80101d0f:	83 ec 10             	sub    $0x10,%esp
80101d12:	68 c6 67 10 80       	push   $0x801067c6
80101d17:	68 80 95 10 80       	push   $0x80109580
80101d1c:	e8 50 1e 00 00       	call   80103b71 <initlock>
80101d21:	83 c4 08             	add    $0x8,%esp
80101d24:	a1 20 1d 12 80       	mov    0x80121d20,%eax
80101d29:	83 e8 01             	sub    $0x1,%eax
80101d2c:	50                   	push   %eax
80101d2d:	6a 0e                	push   $0xe
80101d2f:	e8 56 02 00 00       	call   80101f8a <ioapicenable>
80101d34:	b8 00 00 00 00       	mov    $0x0,%eax
80101d39:	e8 df fe ff ff       	call   80101c1d <idewait>
80101d3e:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d43:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d48:	ee                   	out    %al,(%dx)
80101d49:	83 c4 10             	add    $0x10,%esp
80101d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d51:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d57:	7f 19                	jg     80101d72 <ideinit+0x66>
80101d59:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d5e:	ec                   	in     (%dx),%al
80101d5f:	84 c0                	test   %al,%al
80101d61:	75 05                	jne    80101d68 <ideinit+0x5c>
80101d63:	83 c1 01             	add    $0x1,%ecx
80101d66:	eb e9                	jmp    80101d51 <ideinit+0x45>
80101d68:	c7 05 60 95 10 80 01 	movl   $0x1,0x80109560
80101d6f:	00 00 00 
80101d72:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d77:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d7c:	ee                   	out    %al,(%dx)
80101d7d:	c9                   	leave  
80101d7e:	c3                   	ret    

80101d7f <ideintr>:
80101d7f:	55                   	push   %ebp
80101d80:	89 e5                	mov    %esp,%ebp
80101d82:	57                   	push   %edi
80101d83:	53                   	push   %ebx
80101d84:	83 ec 0c             	sub    $0xc,%esp
80101d87:	68 80 95 10 80       	push   $0x80109580
80101d8c:	e8 1c 1f 00 00       	call   80103cad <acquire>
80101d91:	8b 1d 64 95 10 80    	mov    0x80109564,%ebx
80101d97:	83 c4 10             	add    $0x10,%esp
80101d9a:	85 db                	test   %ebx,%ebx
80101d9c:	74 48                	je     80101de6 <ideintr+0x67>
80101d9e:	8b 43 58             	mov    0x58(%ebx),%eax
80101da1:	a3 64 95 10 80       	mov    %eax,0x80109564
80101da6:	f6 03 04             	testb  $0x4,(%ebx)
80101da9:	74 4d                	je     80101df8 <ideintr+0x79>
80101dab:	8b 03                	mov    (%ebx),%eax
80101dad:	83 c8 02             	or     $0x2,%eax
80101db0:	83 e0 fb             	and    $0xfffffffb,%eax
80101db3:	89 03                	mov    %eax,(%ebx)
80101db5:	83 ec 0c             	sub    $0xc,%esp
80101db8:	53                   	push   %ebx
80101db9:	e8 59 1b 00 00       	call   80103917 <wakeup>
80101dbe:	a1 64 95 10 80       	mov    0x80109564,%eax
80101dc3:	83 c4 10             	add    $0x10,%esp
80101dc6:	85 c0                	test   %eax,%eax
80101dc8:	74 05                	je     80101dcf <ideintr+0x50>
80101dca:	e8 80 fe ff ff       	call   80101c4f <idestart>
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	68 80 95 10 80       	push   $0x80109580
80101dd7:	e8 36 1f 00 00       	call   80103d12 <release>
80101ddc:	83 c4 10             	add    $0x10,%esp
80101ddf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101de2:	5b                   	pop    %ebx
80101de3:	5f                   	pop    %edi
80101de4:	5d                   	pop    %ebp
80101de5:	c3                   	ret    
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 80 95 10 80       	push   $0x80109580
80101dee:	e8 1f 1f 00 00       	call   80103d12 <release>
80101df3:	83 c4 10             	add    $0x10,%esp
80101df6:	eb e7                	jmp    80101ddf <ideintr+0x60>
80101df8:	b8 01 00 00 00       	mov    $0x1,%eax
80101dfd:	e8 1b fe ff ff       	call   80101c1d <idewait>
80101e02:	85 c0                	test   %eax,%eax
80101e04:	78 a5                	js     80101dab <ideintr+0x2c>
80101e06:	8d 7b 5c             	lea    0x5c(%ebx),%edi
80101e09:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e0e:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e13:	fc                   	cld    
80101e14:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e16:	eb 93                	jmp    80101dab <ideintr+0x2c>

80101e18 <iderw>:
80101e18:	55                   	push   %ebp
80101e19:	89 e5                	mov    %esp,%ebp
80101e1b:	53                   	push   %ebx
80101e1c:	83 ec 10             	sub    $0x10,%esp
80101e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101e22:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e25:	50                   	push   %eax
80101e26:	e8 f8 1c 00 00       	call   80103b23 <holdingsleep>
80101e2b:	83 c4 10             	add    $0x10,%esp
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 37                	je     80101e69 <iderw+0x51>
80101e32:	8b 03                	mov    (%ebx),%eax
80101e34:	83 e0 06             	and    $0x6,%eax
80101e37:	83 f8 02             	cmp    $0x2,%eax
80101e3a:	74 3a                	je     80101e76 <iderw+0x5e>
80101e3c:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e40:	74 09                	je     80101e4b <iderw+0x33>
80101e42:	83 3d 60 95 10 80 00 	cmpl   $0x0,0x80109560
80101e49:	74 38                	je     80101e83 <iderw+0x6b>
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 80 95 10 80       	push   $0x80109580
80101e53:	e8 55 1e 00 00       	call   80103cad <acquire>
80101e58:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
80101e5f:	83 c4 10             	add    $0x10,%esp
80101e62:	ba 64 95 10 80       	mov    $0x80109564,%edx
80101e67:	eb 2a                	jmp    80101e93 <iderw+0x7b>
80101e69:	83 ec 0c             	sub    $0xc,%esp
80101e6c:	68 ca 67 10 80       	push   $0x801067ca
80101e71:	e8 d2 e4 ff ff       	call   80100348 <panic>
80101e76:	83 ec 0c             	sub    $0xc,%esp
80101e79:	68 e0 67 10 80       	push   $0x801067e0
80101e7e:	e8 c5 e4 ff ff       	call   80100348 <panic>
80101e83:	83 ec 0c             	sub    $0xc,%esp
80101e86:	68 f5 67 10 80       	push   $0x801067f5
80101e8b:	e8 b8 e4 ff ff       	call   80100348 <panic>
80101e90:	8d 50 58             	lea    0x58(%eax),%edx
80101e93:	8b 02                	mov    (%edx),%eax
80101e95:	85 c0                	test   %eax,%eax
80101e97:	75 f7                	jne    80101e90 <iderw+0x78>
80101e99:	89 1a                	mov    %ebx,(%edx)
80101e9b:	39 1d 64 95 10 80    	cmp    %ebx,0x80109564
80101ea1:	75 1a                	jne    80101ebd <iderw+0xa5>
80101ea3:	89 d8                	mov    %ebx,%eax
80101ea5:	e8 a5 fd ff ff       	call   80101c4f <idestart>
80101eaa:	eb 11                	jmp    80101ebd <iderw+0xa5>
80101eac:	83 ec 08             	sub    $0x8,%esp
80101eaf:	68 80 95 10 80       	push   $0x80109580
80101eb4:	53                   	push   %ebx
80101eb5:	e8 f8 18 00 00       	call   801037b2 <sleep>
80101eba:	83 c4 10             	add    $0x10,%esp
80101ebd:	8b 03                	mov    (%ebx),%eax
80101ebf:	83 e0 06             	and    $0x6,%eax
80101ec2:	83 f8 02             	cmp    $0x2,%eax
80101ec5:	75 e5                	jne    80101eac <iderw+0x94>
80101ec7:	83 ec 0c             	sub    $0xc,%esp
80101eca:	68 80 95 10 80       	push   $0x80109580
80101ecf:	e8 3e 1e 00 00       	call   80103d12 <release>
80101ed4:	83 c4 10             	add    $0x10,%esp
80101ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101eda:	c9                   	leave  
80101edb:	c3                   	ret    

80101edc <ioapicread>:
80101edc:	55                   	push   %ebp
80101edd:	89 e5                	mov    %esp,%ebp
80101edf:	8b 15 54 16 12 80    	mov    0x80121654,%edx
80101ee5:	89 02                	mov    %eax,(%edx)
80101ee7:	a1 54 16 12 80       	mov    0x80121654,%eax
80101eec:	8b 40 10             	mov    0x10(%eax),%eax
80101eef:	5d                   	pop    %ebp
80101ef0:	c3                   	ret    

80101ef1 <ioapicwrite>:
80101ef1:	55                   	push   %ebp
80101ef2:	89 e5                	mov    %esp,%ebp
80101ef4:	8b 0d 54 16 12 80    	mov    0x80121654,%ecx
80101efa:	89 01                	mov    %eax,(%ecx)
80101efc:	a1 54 16 12 80       	mov    0x80121654,%eax
80101f01:	89 50 10             	mov    %edx,0x10(%eax)
80101f04:	5d                   	pop    %ebp
80101f05:	c3                   	ret    

80101f06 <ioapicinit>:
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	57                   	push   %edi
80101f0a:	56                   	push   %esi
80101f0b:	53                   	push   %ebx
80101f0c:	83 ec 0c             	sub    $0xc,%esp
80101f0f:	c7 05 54 16 12 80 00 	movl   $0xfec00000,0x80121654
80101f16:	00 c0 fe 
80101f19:	b8 01 00 00 00       	mov    $0x1,%eax
80101f1e:	e8 b9 ff ff ff       	call   80101edc <ioapicread>
80101f23:	c1 e8 10             	shr    $0x10,%eax
80101f26:	0f b6 f8             	movzbl %al,%edi
80101f29:	b8 00 00 00 00       	mov    $0x0,%eax
80101f2e:	e8 a9 ff ff ff       	call   80101edc <ioapicread>
80101f33:	c1 e8 18             	shr    $0x18,%eax
80101f36:	0f b6 15 80 17 12 80 	movzbl 0x80121780,%edx
80101f3d:	39 c2                	cmp    %eax,%edx
80101f3f:	75 07                	jne    80101f48 <ioapicinit+0x42>
80101f41:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f46:	eb 36                	jmp    80101f7e <ioapicinit+0x78>
80101f48:	83 ec 0c             	sub    $0xc,%esp
80101f4b:	68 14 68 10 80       	push   $0x80106814
80101f50:	e8 b6 e6 ff ff       	call   8010060b <cprintf>
80101f55:	83 c4 10             	add    $0x10,%esp
80101f58:	eb e7                	jmp    80101f41 <ioapicinit+0x3b>
80101f5a:	8d 53 20             	lea    0x20(%ebx),%edx
80101f5d:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f63:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f67:	89 f0                	mov    %esi,%eax
80101f69:	e8 83 ff ff ff       	call   80101ef1 <ioapicwrite>
80101f6e:	8d 46 01             	lea    0x1(%esi),%eax
80101f71:	ba 00 00 00 00       	mov    $0x0,%edx
80101f76:	e8 76 ff ff ff       	call   80101ef1 <ioapicwrite>
80101f7b:	83 c3 01             	add    $0x1,%ebx
80101f7e:	39 fb                	cmp    %edi,%ebx
80101f80:	7e d8                	jle    80101f5a <ioapicinit+0x54>
80101f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f85:	5b                   	pop    %ebx
80101f86:	5e                   	pop    %esi
80101f87:	5f                   	pop    %edi
80101f88:	5d                   	pop    %ebp
80101f89:	c3                   	ret    

80101f8a <ioapicenable>:
80101f8a:	55                   	push   %ebp
80101f8b:	89 e5                	mov    %esp,%ebp
80101f8d:	53                   	push   %ebx
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	8d 50 20             	lea    0x20(%eax),%edx
80101f94:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f98:	89 d8                	mov    %ebx,%eax
80101f9a:	e8 52 ff ff ff       	call   80101ef1 <ioapicwrite>
80101f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fa2:	c1 e2 18             	shl    $0x18,%edx
80101fa5:	8d 43 01             	lea    0x1(%ebx),%eax
80101fa8:	e8 44 ff ff ff       	call   80101ef1 <ioapicwrite>
80101fad:	5b                   	pop    %ebx
80101fae:	5d                   	pop    %ebp
80101faf:	c3                   	ret    

80101fb0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fb0:	55                   	push   %ebp
80101fb1:	89 e5                	mov    %esp,%ebp
80101fb3:	53                   	push   %ebx
80101fb4:	83 ec 04             	sub    $0x4,%esp
80101fb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fba:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fc0:	75 4c                	jne    8010200e <kfree+0x5e>
80101fc2:	81 fb c8 44 12 80    	cmp    $0x801244c8,%ebx
80101fc8:	72 44                	jb     8010200e <kfree+0x5e>
80101fca:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fd0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fd5:	77 37                	ja     8010200e <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fd7:	83 ec 04             	sub    $0x4,%esp
80101fda:	68 00 10 00 00       	push   $0x1000
80101fdf:	6a 01                	push   $0x1
80101fe1:	53                   	push   %ebx
80101fe2:	e8 72 1d 00 00       	call   80103d59 <memset>

  if(kmem.use_lock)
80101fe7:	83 c4 10             	add    $0x10,%esp
80101fea:	83 3d 94 16 12 80 00 	cmpl   $0x0,0x80121694
80101ff1:	75 28                	jne    8010201b <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  // int addr = (V2P((char*)r) >> 12);
  // if (addr <= 1200) {
    r->next = kmem.freelist;
80101ff3:	a1 98 16 12 80       	mov    0x80121698,%eax
80101ff8:	89 03                	mov    %eax,(%ebx)
    kmem.freelist = r;
80101ffa:	89 1d 98 16 12 80    	mov    %ebx,0x80121698
  // } else {
  //   int index = 0XDFFF - addr;
  //   frame[index] = 0;
  // }
  if(kmem.use_lock)
80102000:	83 3d 94 16 12 80 00 	cmpl   $0x0,0x80121694
80102007:	75 24                	jne    8010202d <kfree+0x7d>
    release(&kmem.lock);
}
80102009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010200c:	c9                   	leave  
8010200d:	c3                   	ret    
    panic("kfree");
8010200e:	83 ec 0c             	sub    $0xc,%esp
80102011:	68 46 68 10 80       	push   $0x80106846
80102016:	e8 2d e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010201b:	83 ec 0c             	sub    $0xc,%esp
8010201e:	68 60 16 12 80       	push   $0x80121660
80102023:	e8 85 1c 00 00       	call   80103cad <acquire>
80102028:	83 c4 10             	add    $0x10,%esp
8010202b:	eb c6                	jmp    80101ff3 <kfree+0x43>
    release(&kmem.lock);
8010202d:	83 ec 0c             	sub    $0xc,%esp
80102030:	68 60 16 12 80       	push   $0x80121660
80102035:	e8 d8 1c 00 00       	call   80103d12 <release>
8010203a:	83 c4 10             	add    $0x10,%esp
}
8010203d:	eb ca                	jmp    80102009 <kfree+0x59>

8010203f <freerange>:
{
8010203f:	55                   	push   %ebp
80102040:	89 e5                	mov    %esp,%ebp
80102042:	56                   	push   %esi
80102043:	53                   	push   %ebx
80102044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102047:	8b 45 08             	mov    0x8(%ebp),%eax
8010204a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010204f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102054:	eb 0e                	jmp    80102064 <freerange+0x25>
    kfree(p);
80102056:	83 ec 0c             	sub    $0xc,%esp
80102059:	50                   	push   %eax
8010205a:	e8 51 ff ff ff       	call   80101fb0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010205f:	83 c4 10             	add    $0x10,%esp
80102062:	89 f0                	mov    %esi,%eax
80102064:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010206a:	39 de                	cmp    %ebx,%esi
8010206c:	76 e8                	jbe    80102056 <freerange+0x17>
}
8010206e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102071:	5b                   	pop    %ebx
80102072:	5e                   	pop    %esi
80102073:	5d                   	pop    %ebp
80102074:	c3                   	ret    

80102075 <kinit1>:
{
80102075:	55                   	push   %ebp
80102076:	89 e5                	mov    %esp,%ebp
80102078:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010207b:	68 4c 68 10 80       	push   $0x8010684c
80102080:	68 60 16 12 80       	push   $0x80121660
80102085:	e8 e7 1a 00 00       	call   80103b71 <initlock>
  kmem.use_lock = 0;
8010208a:	c7 05 94 16 12 80 00 	movl   $0x0,0x80121694
80102091:	00 00 00 
  freerange(vstart, vend);
80102094:	83 c4 08             	add    $0x8,%esp
80102097:	ff 75 0c             	pushl  0xc(%ebp)
8010209a:	ff 75 08             	pushl  0x8(%ebp)
8010209d:	e8 9d ff ff ff       	call   8010203f <freerange>
}
801020a2:	83 c4 10             	add    $0x10,%esp
801020a5:	c9                   	leave  
801020a6:	c3                   	ret    

801020a7 <kinit2>:
{
801020a7:	55                   	push   %ebp
801020a8:	89 e5                	mov    %esp,%ebp
801020aa:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020ad:	ff 75 0c             	pushl  0xc(%ebp)
801020b0:	ff 75 08             	pushl  0x8(%ebp)
801020b3:	e8 87 ff ff ff       	call   8010203f <freerange>
  kmem.use_lock = 1;
801020b8:	c7 05 94 16 12 80 01 	movl   $0x1,0x80121694
801020bf:	00 00 00 
}
801020c2:	83 c4 10             	add    $0x10,%esp
801020c5:	c9                   	leave  
801020c6:	c3                   	ret    

801020c7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(int pid)
{
801020c7:	55                   	push   %ebp
801020c8:	89 e5                	mov    %esp,%ebp
801020ca:	56                   	push   %esi
801020cb:	53                   	push   %ebx
801020cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if(kmem.use_lock)
801020cf:	83 3d 94 16 12 80 00 	cmpl   $0x0,0x80121694
801020d6:	75 24                	jne    801020fc <kalloc+0x35>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020d8:	8b 35 98 16 12 80    	mov    0x80121698,%esi
  int addr = (V2P((char*)r) >> 12);
801020de:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if (addr <= 1024) {
801020e4:	3d ff 0f 40 00       	cmp    $0x400fff,%eax
801020e9:	0f 87 87 00 00 00    	ja     80102176 <kalloc+0xaf>
    if(r) {
801020ef:	85 f6                	test   %esi,%esi
801020f1:	74 71                	je     80102164 <kalloc+0x9d>
      kmem.freelist = r->next;
801020f3:	8b 06                	mov    (%esi),%eax
801020f5:	a3 98 16 12 80       	mov    %eax,0x80121698
801020fa:	eb 68                	jmp    80102164 <kalloc+0x9d>
    acquire(&kmem.lock);
801020fc:	83 ec 0c             	sub    $0xc,%esp
801020ff:	68 60 16 12 80       	push   $0x80121660
80102104:	e8 a4 1b 00 00       	call   80103cad <acquire>
80102109:	83 c4 10             	add    $0x10,%esp
8010210c:	eb ca                	jmp    801020d8 <kalloc+0x11>
    }
  } else {
    for (int i = 0; i < 16384; i++) {
      if (frame[i] == 0) {
        if ((i == 0 || frame[i-1] == 0 || frame[i - 1] == pid) && (i == 16383 || frame[i + 1] == 0 || frame[i + 1] == pid)) {
8010210e:	3d ff 3f 00 00       	cmp    $0x3fff,%eax
80102113:	74 38                	je     8010214d <kalloc+0x86>
80102115:	8b 14 85 c4 95 10 80 	mov    -0x7fef6a3c(,%eax,4),%edx
8010211c:	85 d2                	test   %edx,%edx
8010211e:	74 2d                	je     8010214d <kalloc+0x86>
80102120:	39 da                	cmp    %ebx,%edx
80102122:	74 29                	je     8010214d <kalloc+0x86>
    for (int i = 0; i < 16384; i++) {
80102124:	83 c0 01             	add    $0x1,%eax
80102127:	3d ff 3f 00 00       	cmp    $0x3fff,%eax
8010212c:	7f 36                	jg     80102164 <kalloc+0x9d>
      if (frame[i] == 0) {
8010212e:	83 3c 85 c0 95 10 80 	cmpl   $0x0,-0x7fef6a40(,%eax,4)
80102135:	00 
80102136:	75 ec                	jne    80102124 <kalloc+0x5d>
        if ((i == 0 || frame[i-1] == 0 || frame[i - 1] == pid) && (i == 16383 || frame[i + 1] == 0 || frame[i + 1] == pid)) {
80102138:	85 c0                	test   %eax,%eax
8010213a:	74 d2                	je     8010210e <kalloc+0x47>
8010213c:	8b 14 85 bc 95 10 80 	mov    -0x7fef6a44(,%eax,4),%edx
80102143:	85 d2                	test   %edx,%edx
80102145:	74 c7                	je     8010210e <kalloc+0x47>
80102147:	39 da                	cmp    %ebx,%edx
80102149:	75 d9                	jne    80102124 <kalloc+0x5d>
8010214b:	eb c1                	jmp    8010210e <kalloc+0x47>
          r = P2V((0XDFFF - i) << 12);
8010214d:	be ff df 00 00       	mov    $0xdfff,%esi
80102152:	29 c6                	sub    %eax,%esi
80102154:	c1 e6 0c             	shl    $0xc,%esi
80102157:	81 c6 00 00 00 80    	add    $0x80000000,%esi
          frame[i] = pid;
8010215d:	89 1c 85 c0 95 10 80 	mov    %ebx,-0x7fef6a40(,%eax,4)
        }
      }
    }
  }
  //
  if(kmem.use_lock)
80102164:	83 3d 94 16 12 80 00 	cmpl   $0x0,0x80121694
8010216b:	75 10                	jne    8010217d <kalloc+0xb6>
    release(&kmem.lock);
  return (char*)r;
}
8010216d:	89 f0                	mov    %esi,%eax
8010216f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102172:	5b                   	pop    %ebx
80102173:	5e                   	pop    %esi
80102174:	5d                   	pop    %ebp
80102175:	c3                   	ret    
    for (int i = 0; i < 16384; i++) {
80102176:	b8 00 00 00 00       	mov    $0x0,%eax
8010217b:	eb aa                	jmp    80102127 <kalloc+0x60>
    release(&kmem.lock);
8010217d:	83 ec 0c             	sub    $0xc,%esp
80102180:	68 60 16 12 80       	push   $0x80121660
80102185:	e8 88 1b 00 00       	call   80103d12 <release>
8010218a:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010218d:	eb de                	jmp    8010216d <kalloc+0xa6>

8010218f <dump_physmem>:



int
dump_physmem(int *frames, int *pids, int numframes)
{
8010218f:	55                   	push   %ebp
80102190:	89 e5                	mov    %esp,%ebp
80102192:	57                   	push   %edi
80102193:	56                   	push   %esi
80102194:	53                   	push   %ebx
80102195:	8b 75 08             	mov    0x8(%ebp),%esi
80102198:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010219b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if (frames == NULL || pids == NULL || numframes < 0) {
8010219e:	85 f6                	test   %esi,%esi
801021a0:	0f 94 c2             	sete   %dl
801021a3:	85 ff                	test   %edi,%edi
801021a5:	0f 94 c0             	sete   %al
801021a8:	08 c2                	or     %al,%dl
801021aa:	75 58                	jne    80102204 <dump_physmem+0x75>
801021ac:	85 c9                	test   %ecx,%ecx
801021ae:	78 5b                	js     8010220b <dump_physmem+0x7c>
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
801021b0:	b8 00 00 00 00       	mov    $0x0,%eax
801021b5:	eb 18                	jmp    801021cf <dump_physmem+0x40>
    if (frame[i] != 0){
      frames[i] = 0xDFFF - i;
      pids[i] = frame[i];
    } else {
      frames[i] = -1;
801021b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801021be:	c7 04 16 ff ff ff ff 	movl   $0xffffffff,(%esi,%edx,1)
      pids[i] = -1;
801021c5:	c7 04 17 ff ff ff ff 	movl   $0xffffffff,(%edi,%edx,1)
  for (int i = 0; i < numframes; i++) {
801021cc:	83 c0 01             	add    $0x1,%eax
801021cf:	39 c8                	cmp    %ecx,%eax
801021d1:	7d 27                	jge    801021fa <dump_physmem+0x6b>
    if (frame[i] != 0){
801021d3:	83 3c 85 c0 95 10 80 	cmpl   $0x0,-0x7fef6a40(,%eax,4)
801021da:	00 
801021db:	74 da                	je     801021b7 <dump_physmem+0x28>
      frames[i] = 0xDFFF - i;
801021dd:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
801021e4:	ba ff df 00 00       	mov    $0xdfff,%edx
801021e9:	29 c2                	sub    %eax,%edx
801021eb:	89 14 1e             	mov    %edx,(%esi,%ebx,1)
      pids[i] = frame[i];
801021ee:	8b 14 85 c0 95 10 80 	mov    -0x7fef6a40(,%eax,4),%edx
801021f5:	89 14 1f             	mov    %edx,(%edi,%ebx,1)
801021f8:	eb d2                	jmp    801021cc <dump_physmem+0x3d>
    }
  }
  return 0;
801021fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021ff:	5b                   	pop    %ebx
80102200:	5e                   	pop    %esi
80102201:	5f                   	pop    %edi
80102202:	5d                   	pop    %ebp
80102203:	c3                   	ret    
      return -1;
80102204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102209:	eb f4                	jmp    801021ff <dump_physmem+0x70>
8010220b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102210:	eb ed                	jmp    801021ff <dump_physmem+0x70>

80102212 <kbdgetc>:
80102212:	55                   	push   %ebp
80102213:	89 e5                	mov    %esp,%ebp
80102215:	ba 64 00 00 00       	mov    $0x64,%edx
8010221a:	ec                   	in     (%dx),%al
8010221b:	a8 01                	test   $0x1,%al
8010221d:	0f 84 b5 00 00 00    	je     801022d8 <kbdgetc+0xc6>
80102223:	ba 60 00 00 00       	mov    $0x60,%edx
80102228:	ec                   	in     (%dx),%al
80102229:	0f b6 d0             	movzbl %al,%edx
8010222c:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102232:	74 5c                	je     80102290 <kbdgetc+0x7e>
80102234:	84 c0                	test   %al,%al
80102236:	78 66                	js     8010229e <kbdgetc+0x8c>
80102238:	8b 0d c0 95 11 80    	mov    0x801195c0,%ecx
8010223e:	f6 c1 40             	test   $0x40,%cl
80102241:	74 0f                	je     80102252 <kbdgetc+0x40>
80102243:	83 c8 80             	or     $0xffffff80,%eax
80102246:	0f b6 d0             	movzbl %al,%edx
80102249:	83 e1 bf             	and    $0xffffffbf,%ecx
8010224c:	89 0d c0 95 11 80    	mov    %ecx,0x801195c0
80102252:	0f b6 8a 80 69 10 80 	movzbl -0x7fef9680(%edx),%ecx
80102259:	0b 0d c0 95 11 80    	or     0x801195c0,%ecx
8010225f:	0f b6 82 80 68 10 80 	movzbl -0x7fef9780(%edx),%eax
80102266:	31 c1                	xor    %eax,%ecx
80102268:	89 0d c0 95 11 80    	mov    %ecx,0x801195c0
8010226e:	89 c8                	mov    %ecx,%eax
80102270:	83 e0 03             	and    $0x3,%eax
80102273:	8b 04 85 60 68 10 80 	mov    -0x7fef97a0(,%eax,4),%eax
8010227a:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
8010227e:	f6 c1 08             	test   $0x8,%cl
80102281:	74 19                	je     8010229c <kbdgetc+0x8a>
80102283:	8d 50 9f             	lea    -0x61(%eax),%edx
80102286:	83 fa 19             	cmp    $0x19,%edx
80102289:	77 40                	ja     801022cb <kbdgetc+0xb9>
8010228b:	83 e8 20             	sub    $0x20,%eax
8010228e:	eb 0c                	jmp    8010229c <kbdgetc+0x8a>
80102290:	83 0d c0 95 11 80 40 	orl    $0x40,0x801195c0
80102297:	b8 00 00 00 00       	mov    $0x0,%eax
8010229c:	5d                   	pop    %ebp
8010229d:	c3                   	ret    
8010229e:	8b 0d c0 95 11 80    	mov    0x801195c0,%ecx
801022a4:	f6 c1 40             	test   $0x40,%cl
801022a7:	75 05                	jne    801022ae <kbdgetc+0x9c>
801022a9:	89 c2                	mov    %eax,%edx
801022ab:	83 e2 7f             	and    $0x7f,%edx
801022ae:	0f b6 82 80 69 10 80 	movzbl -0x7fef9680(%edx),%eax
801022b5:	83 c8 40             	or     $0x40,%eax
801022b8:	0f b6 c0             	movzbl %al,%eax
801022bb:	f7 d0                	not    %eax
801022bd:	21 c8                	and    %ecx,%eax
801022bf:	a3 c0 95 11 80       	mov    %eax,0x801195c0
801022c4:	b8 00 00 00 00       	mov    $0x0,%eax
801022c9:	eb d1                	jmp    8010229c <kbdgetc+0x8a>
801022cb:	8d 50 bf             	lea    -0x41(%eax),%edx
801022ce:	83 fa 19             	cmp    $0x19,%edx
801022d1:	77 c9                	ja     8010229c <kbdgetc+0x8a>
801022d3:	83 c0 20             	add    $0x20,%eax
801022d6:	eb c4                	jmp    8010229c <kbdgetc+0x8a>
801022d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022dd:	eb bd                	jmp    8010229c <kbdgetc+0x8a>

801022df <kbdintr>:
801022df:	55                   	push   %ebp
801022e0:	89 e5                	mov    %esp,%ebp
801022e2:	83 ec 14             	sub    $0x14,%esp
801022e5:	68 12 22 10 80       	push   $0x80102212
801022ea:	e8 4f e4 ff ff       	call   8010073e <consoleintr>
801022ef:	83 c4 10             	add    $0x10,%esp
801022f2:	c9                   	leave  
801022f3:	c3                   	ret    

801022f4 <lapicw>:
801022f4:	55                   	push   %ebp
801022f5:	89 e5                	mov    %esp,%ebp
801022f7:	8b 0d 9c 16 12 80    	mov    0x8012169c,%ecx
801022fd:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102300:	89 10                	mov    %edx,(%eax)
80102302:	a1 9c 16 12 80       	mov    0x8012169c,%eax
80102307:	8b 40 20             	mov    0x20(%eax),%eax
8010230a:	5d                   	pop    %ebp
8010230b:	c3                   	ret    

8010230c <cmos_read>:
8010230c:	55                   	push   %ebp
8010230d:	89 e5                	mov    %esp,%ebp
8010230f:	ba 70 00 00 00       	mov    $0x70,%edx
80102314:	ee                   	out    %al,(%dx)
80102315:	ba 71 00 00 00       	mov    $0x71,%edx
8010231a:	ec                   	in     (%dx),%al
8010231b:	0f b6 c0             	movzbl %al,%eax
8010231e:	5d                   	pop    %ebp
8010231f:	c3                   	ret    

80102320 <fill_rtcdate>:
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	53                   	push   %ebx
80102324:	89 c3                	mov    %eax,%ebx
80102326:	b8 00 00 00 00       	mov    $0x0,%eax
8010232b:	e8 dc ff ff ff       	call   8010230c <cmos_read>
80102330:	89 03                	mov    %eax,(%ebx)
80102332:	b8 02 00 00 00       	mov    $0x2,%eax
80102337:	e8 d0 ff ff ff       	call   8010230c <cmos_read>
8010233c:	89 43 04             	mov    %eax,0x4(%ebx)
8010233f:	b8 04 00 00 00       	mov    $0x4,%eax
80102344:	e8 c3 ff ff ff       	call   8010230c <cmos_read>
80102349:	89 43 08             	mov    %eax,0x8(%ebx)
8010234c:	b8 07 00 00 00       	mov    $0x7,%eax
80102351:	e8 b6 ff ff ff       	call   8010230c <cmos_read>
80102356:	89 43 0c             	mov    %eax,0xc(%ebx)
80102359:	b8 08 00 00 00       	mov    $0x8,%eax
8010235e:	e8 a9 ff ff ff       	call   8010230c <cmos_read>
80102363:	89 43 10             	mov    %eax,0x10(%ebx)
80102366:	b8 09 00 00 00       	mov    $0x9,%eax
8010236b:	e8 9c ff ff ff       	call   8010230c <cmos_read>
80102370:	89 43 14             	mov    %eax,0x14(%ebx)
80102373:	5b                   	pop    %ebx
80102374:	5d                   	pop    %ebp
80102375:	c3                   	ret    

80102376 <lapicinit>:
80102376:	83 3d 9c 16 12 80 00 	cmpl   $0x0,0x8012169c
8010237d:	0f 84 fb 00 00 00    	je     8010247e <lapicinit+0x108>
80102383:	55                   	push   %ebp
80102384:	89 e5                	mov    %esp,%ebp
80102386:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010238b:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102390:	e8 5f ff ff ff       	call   801022f4 <lapicw>
80102395:	ba 0b 00 00 00       	mov    $0xb,%edx
8010239a:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010239f:	e8 50 ff ff ff       	call   801022f4 <lapicw>
801023a4:	ba 20 00 02 00       	mov    $0x20020,%edx
801023a9:	b8 c8 00 00 00       	mov    $0xc8,%eax
801023ae:	e8 41 ff ff ff       	call   801022f4 <lapicw>
801023b3:	ba 80 96 98 00       	mov    $0x989680,%edx
801023b8:	b8 e0 00 00 00       	mov    $0xe0,%eax
801023bd:	e8 32 ff ff ff       	call   801022f4 <lapicw>
801023c2:	ba 00 00 01 00       	mov    $0x10000,%edx
801023c7:	b8 d4 00 00 00       	mov    $0xd4,%eax
801023cc:	e8 23 ff ff ff       	call   801022f4 <lapicw>
801023d1:	ba 00 00 01 00       	mov    $0x10000,%edx
801023d6:	b8 d8 00 00 00       	mov    $0xd8,%eax
801023db:	e8 14 ff ff ff       	call   801022f4 <lapicw>
801023e0:	a1 9c 16 12 80       	mov    0x8012169c,%eax
801023e5:	8b 40 30             	mov    0x30(%eax),%eax
801023e8:	c1 e8 10             	shr    $0x10,%eax
801023eb:	3c 03                	cmp    $0x3,%al
801023ed:	77 7b                	ja     8010246a <lapicinit+0xf4>
801023ef:	ba 33 00 00 00       	mov    $0x33,%edx
801023f4:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023f9:	e8 f6 fe ff ff       	call   801022f4 <lapicw>
801023fe:	ba 00 00 00 00       	mov    $0x0,%edx
80102403:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102408:	e8 e7 fe ff ff       	call   801022f4 <lapicw>
8010240d:	ba 00 00 00 00       	mov    $0x0,%edx
80102412:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102417:	e8 d8 fe ff ff       	call   801022f4 <lapicw>
8010241c:	ba 00 00 00 00       	mov    $0x0,%edx
80102421:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102426:	e8 c9 fe ff ff       	call   801022f4 <lapicw>
8010242b:	ba 00 00 00 00       	mov    $0x0,%edx
80102430:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102435:	e8 ba fe ff ff       	call   801022f4 <lapicw>
8010243a:	ba 00 85 08 00       	mov    $0x88500,%edx
8010243f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102444:	e8 ab fe ff ff       	call   801022f4 <lapicw>
80102449:	a1 9c 16 12 80       	mov    0x8012169c,%eax
8010244e:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102454:	f6 c4 10             	test   $0x10,%ah
80102457:	75 f0                	jne    80102449 <lapicinit+0xd3>
80102459:	ba 00 00 00 00       	mov    $0x0,%edx
8010245e:	b8 20 00 00 00       	mov    $0x20,%eax
80102463:	e8 8c fe ff ff       	call   801022f4 <lapicw>
80102468:	5d                   	pop    %ebp
80102469:	c3                   	ret    
8010246a:	ba 00 00 01 00       	mov    $0x10000,%edx
8010246f:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102474:	e8 7b fe ff ff       	call   801022f4 <lapicw>
80102479:	e9 71 ff ff ff       	jmp    801023ef <lapicinit+0x79>
8010247e:	f3 c3                	repz ret 

80102480 <lapicid>:
80102480:	55                   	push   %ebp
80102481:	89 e5                	mov    %esp,%ebp
80102483:	a1 9c 16 12 80       	mov    0x8012169c,%eax
80102488:	85 c0                	test   %eax,%eax
8010248a:	74 08                	je     80102494 <lapicid+0x14>
8010248c:	8b 40 20             	mov    0x20(%eax),%eax
8010248f:	c1 e8 18             	shr    $0x18,%eax
80102492:	5d                   	pop    %ebp
80102493:	c3                   	ret    
80102494:	b8 00 00 00 00       	mov    $0x0,%eax
80102499:	eb f7                	jmp    80102492 <lapicid+0x12>

8010249b <lapiceoi>:
8010249b:	83 3d 9c 16 12 80 00 	cmpl   $0x0,0x8012169c
801024a2:	74 14                	je     801024b8 <lapiceoi+0x1d>
801024a4:	55                   	push   %ebp
801024a5:	89 e5                	mov    %esp,%ebp
801024a7:	ba 00 00 00 00       	mov    $0x0,%edx
801024ac:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024b1:	e8 3e fe ff ff       	call   801022f4 <lapicw>
801024b6:	5d                   	pop    %ebp
801024b7:	c3                   	ret    
801024b8:	f3 c3                	repz ret 

801024ba <microdelay>:
801024ba:	55                   	push   %ebp
801024bb:	89 e5                	mov    %esp,%ebp
801024bd:	5d                   	pop    %ebp
801024be:	c3                   	ret    

801024bf <lapicstartap>:
801024bf:	55                   	push   %ebp
801024c0:	89 e5                	mov    %esp,%ebp
801024c2:	57                   	push   %edi
801024c3:	56                   	push   %esi
801024c4:	53                   	push   %ebx
801024c5:	8b 75 08             	mov    0x8(%ebp),%esi
801024c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
801024cb:	b8 0f 00 00 00       	mov    $0xf,%eax
801024d0:	ba 70 00 00 00       	mov    $0x70,%edx
801024d5:	ee                   	out    %al,(%dx)
801024d6:	b8 0a 00 00 00       	mov    $0xa,%eax
801024db:	ba 71 00 00 00       	mov    $0x71,%edx
801024e0:	ee                   	out    %al,(%dx)
801024e1:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801024e8:	00 00 
801024ea:	89 f8                	mov    %edi,%eax
801024ec:	c1 e8 04             	shr    $0x4,%eax
801024ef:	66 a3 69 04 00 80    	mov    %ax,0x80000469
801024f5:	c1 e6 18             	shl    $0x18,%esi
801024f8:	89 f2                	mov    %esi,%edx
801024fa:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024ff:	e8 f0 fd ff ff       	call   801022f4 <lapicw>
80102504:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102509:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010250e:	e8 e1 fd ff ff       	call   801022f4 <lapicw>
80102513:	ba 00 85 00 00       	mov    $0x8500,%edx
80102518:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010251d:	e8 d2 fd ff ff       	call   801022f4 <lapicw>
80102522:	bb 00 00 00 00       	mov    $0x0,%ebx
80102527:	eb 21                	jmp    8010254a <lapicstartap+0x8b>
80102529:	89 f2                	mov    %esi,%edx
8010252b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102530:	e8 bf fd ff ff       	call   801022f4 <lapicw>
80102535:	89 fa                	mov    %edi,%edx
80102537:	c1 ea 0c             	shr    $0xc,%edx
8010253a:	80 ce 06             	or     $0x6,%dh
8010253d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102542:	e8 ad fd ff ff       	call   801022f4 <lapicw>
80102547:	83 c3 01             	add    $0x1,%ebx
8010254a:	83 fb 01             	cmp    $0x1,%ebx
8010254d:	7e da                	jle    80102529 <lapicstartap+0x6a>
8010254f:	5b                   	pop    %ebx
80102550:	5e                   	pop    %esi
80102551:	5f                   	pop    %edi
80102552:	5d                   	pop    %ebp
80102553:	c3                   	ret    

80102554 <cmostime>:
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	57                   	push   %edi
80102558:	56                   	push   %esi
80102559:	53                   	push   %ebx
8010255a:	83 ec 3c             	sub    $0x3c,%esp
8010255d:	8b 75 08             	mov    0x8(%ebp),%esi
80102560:	b8 0b 00 00 00       	mov    $0xb,%eax
80102565:	e8 a2 fd ff ff       	call   8010230c <cmos_read>
8010256a:	83 e0 04             	and    $0x4,%eax
8010256d:	89 c7                	mov    %eax,%edi
8010256f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102572:	e8 a9 fd ff ff       	call   80102320 <fill_rtcdate>
80102577:	b8 0a 00 00 00       	mov    $0xa,%eax
8010257c:	e8 8b fd ff ff       	call   8010230c <cmos_read>
80102581:	a8 80                	test   $0x80,%al
80102583:	75 ea                	jne    8010256f <cmostime+0x1b>
80102585:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102588:	89 d8                	mov    %ebx,%eax
8010258a:	e8 91 fd ff ff       	call   80102320 <fill_rtcdate>
8010258f:	83 ec 04             	sub    $0x4,%esp
80102592:	6a 18                	push   $0x18
80102594:	53                   	push   %ebx
80102595:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102598:	50                   	push   %eax
80102599:	e8 01 18 00 00       	call   80103d9f <memcmp>
8010259e:	83 c4 10             	add    $0x10,%esp
801025a1:	85 c0                	test   %eax,%eax
801025a3:	75 ca                	jne    8010256f <cmostime+0x1b>
801025a5:	85 ff                	test   %edi,%edi
801025a7:	0f 85 84 00 00 00    	jne    80102631 <cmostime+0xdd>
801025ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
801025b0:	89 d0                	mov    %edx,%eax
801025b2:	c1 e8 04             	shr    $0x4,%eax
801025b5:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025b8:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025bb:	83 e2 0f             	and    $0xf,%edx
801025be:	01 d0                	add    %edx,%eax
801025c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
801025c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801025c6:	89 d0                	mov    %edx,%eax
801025c8:	c1 e8 04             	shr    $0x4,%eax
801025cb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025ce:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025d1:	83 e2 0f             	and    $0xf,%edx
801025d4:	01 d0                	add    %edx,%eax
801025d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801025d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801025dc:	89 d0                	mov    %edx,%eax
801025de:	c1 e8 04             	shr    $0x4,%eax
801025e1:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025e4:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025e7:	83 e2 0f             	and    $0xf,%edx
801025ea:	01 d0                	add    %edx,%eax
801025ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
801025ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
801025f2:	89 d0                	mov    %edx,%eax
801025f4:	c1 e8 04             	shr    $0x4,%eax
801025f7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801025fa:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801025fd:	83 e2 0f             	and    $0xf,%edx
80102600:	01 d0                	add    %edx,%eax
80102602:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102605:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102608:	89 d0                	mov    %edx,%eax
8010260a:	c1 e8 04             	shr    $0x4,%eax
8010260d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102610:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102613:	83 e2 0f             	and    $0xf,%edx
80102616:	01 d0                	add    %edx,%eax
80102618:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010261b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010261e:	89 d0                	mov    %edx,%eax
80102620:	c1 e8 04             	shr    $0x4,%eax
80102623:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102626:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102629:	83 e2 0f             	and    $0xf,%edx
8010262c:	01 d0                	add    %edx,%eax
8010262e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80102631:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102634:	89 06                	mov    %eax,(%esi)
80102636:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102639:	89 46 04             	mov    %eax,0x4(%esi)
8010263c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010263f:	89 46 08             	mov    %eax,0x8(%esi)
80102642:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102645:	89 46 0c             	mov    %eax,0xc(%esi)
80102648:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010264b:	89 46 10             	mov    %eax,0x10(%esi)
8010264e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102651:	89 46 14             	mov    %eax,0x14(%esi)
80102654:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
8010265b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010265e:	5b                   	pop    %ebx
8010265f:	5e                   	pop    %esi
80102660:	5f                   	pop    %edi
80102661:	5d                   	pop    %ebp
80102662:	c3                   	ret    

80102663 <read_head>:
80102663:	55                   	push   %ebp
80102664:	89 e5                	mov    %esp,%ebp
80102666:	53                   	push   %ebx
80102667:	83 ec 0c             	sub    $0xc,%esp
8010266a:	ff 35 d4 16 12 80    	pushl  0x801216d4
80102670:	ff 35 e4 16 12 80    	pushl  0x801216e4
80102676:	e8 f1 da ff ff       	call   8010016c <bread>
8010267b:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010267e:	89 1d e8 16 12 80    	mov    %ebx,0x801216e8
80102684:	83 c4 10             	add    $0x10,%esp
80102687:	ba 00 00 00 00       	mov    $0x0,%edx
8010268c:	eb 0e                	jmp    8010269c <read_head+0x39>
8010268e:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102692:	89 0c 95 ec 16 12 80 	mov    %ecx,-0x7fede914(,%edx,4)
80102699:	83 c2 01             	add    $0x1,%edx
8010269c:	39 d3                	cmp    %edx,%ebx
8010269e:	7f ee                	jg     8010268e <read_head+0x2b>
801026a0:	83 ec 0c             	sub    $0xc,%esp
801026a3:	50                   	push   %eax
801026a4:	e8 2c db ff ff       	call   801001d5 <brelse>
801026a9:	83 c4 10             	add    $0x10,%esp
801026ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026af:	c9                   	leave  
801026b0:	c3                   	ret    

801026b1 <install_trans>:
801026b1:	55                   	push   %ebp
801026b2:	89 e5                	mov    %esp,%ebp
801026b4:	57                   	push   %edi
801026b5:	56                   	push   %esi
801026b6:	53                   	push   %ebx
801026b7:	83 ec 0c             	sub    $0xc,%esp
801026ba:	bb 00 00 00 00       	mov    $0x0,%ebx
801026bf:	eb 66                	jmp    80102727 <install_trans+0x76>
801026c1:	89 d8                	mov    %ebx,%eax
801026c3:	03 05 d4 16 12 80    	add    0x801216d4,%eax
801026c9:	83 c0 01             	add    $0x1,%eax
801026cc:	83 ec 08             	sub    $0x8,%esp
801026cf:	50                   	push   %eax
801026d0:	ff 35 e4 16 12 80    	pushl  0x801216e4
801026d6:	e8 91 da ff ff       	call   8010016c <bread>
801026db:	89 c7                	mov    %eax,%edi
801026dd:	83 c4 08             	add    $0x8,%esp
801026e0:	ff 34 9d ec 16 12 80 	pushl  -0x7fede914(,%ebx,4)
801026e7:	ff 35 e4 16 12 80    	pushl  0x801216e4
801026ed:	e8 7a da ff ff       	call   8010016c <bread>
801026f2:	89 c6                	mov    %eax,%esi
801026f4:	8d 57 5c             	lea    0x5c(%edi),%edx
801026f7:	8d 40 5c             	lea    0x5c(%eax),%eax
801026fa:	83 c4 0c             	add    $0xc,%esp
801026fd:	68 00 02 00 00       	push   $0x200
80102702:	52                   	push   %edx
80102703:	50                   	push   %eax
80102704:	e8 cb 16 00 00       	call   80103dd4 <memmove>
80102709:	89 34 24             	mov    %esi,(%esp)
8010270c:	e8 89 da ff ff       	call   8010019a <bwrite>
80102711:	89 3c 24             	mov    %edi,(%esp)
80102714:	e8 bc da ff ff       	call   801001d5 <brelse>
80102719:	89 34 24             	mov    %esi,(%esp)
8010271c:	e8 b4 da ff ff       	call   801001d5 <brelse>
80102721:	83 c3 01             	add    $0x1,%ebx
80102724:	83 c4 10             	add    $0x10,%esp
80102727:	39 1d e8 16 12 80    	cmp    %ebx,0x801216e8
8010272d:	7f 92                	jg     801026c1 <install_trans+0x10>
8010272f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102732:	5b                   	pop    %ebx
80102733:	5e                   	pop    %esi
80102734:	5f                   	pop    %edi
80102735:	5d                   	pop    %ebp
80102736:	c3                   	ret    

80102737 <write_head>:
80102737:	55                   	push   %ebp
80102738:	89 e5                	mov    %esp,%ebp
8010273a:	53                   	push   %ebx
8010273b:	83 ec 0c             	sub    $0xc,%esp
8010273e:	ff 35 d4 16 12 80    	pushl  0x801216d4
80102744:	ff 35 e4 16 12 80    	pushl  0x801216e4
8010274a:	e8 1d da ff ff       	call   8010016c <bread>
8010274f:	89 c3                	mov    %eax,%ebx
80102751:	8b 0d e8 16 12 80    	mov    0x801216e8,%ecx
80102757:	89 48 5c             	mov    %ecx,0x5c(%eax)
8010275a:	83 c4 10             	add    $0x10,%esp
8010275d:	b8 00 00 00 00       	mov    $0x0,%eax
80102762:	eb 0e                	jmp    80102772 <write_head+0x3b>
80102764:	8b 14 85 ec 16 12 80 	mov    -0x7fede914(,%eax,4),%edx
8010276b:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
8010276f:	83 c0 01             	add    $0x1,%eax
80102772:	39 c1                	cmp    %eax,%ecx
80102774:	7f ee                	jg     80102764 <write_head+0x2d>
80102776:	83 ec 0c             	sub    $0xc,%esp
80102779:	53                   	push   %ebx
8010277a:	e8 1b da ff ff       	call   8010019a <bwrite>
8010277f:	89 1c 24             	mov    %ebx,(%esp)
80102782:	e8 4e da ff ff       	call   801001d5 <brelse>
80102787:	83 c4 10             	add    $0x10,%esp
8010278a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010278d:	c9                   	leave  
8010278e:	c3                   	ret    

8010278f <recover_from_log>:
8010278f:	55                   	push   %ebp
80102790:	89 e5                	mov    %esp,%ebp
80102792:	83 ec 08             	sub    $0x8,%esp
80102795:	e8 c9 fe ff ff       	call   80102663 <read_head>
8010279a:	e8 12 ff ff ff       	call   801026b1 <install_trans>
8010279f:	c7 05 e8 16 12 80 00 	movl   $0x0,0x801216e8
801027a6:	00 00 00 
801027a9:	e8 89 ff ff ff       	call   80102737 <write_head>
801027ae:	c9                   	leave  
801027af:	c3                   	ret    

801027b0 <write_log>:
801027b0:	55                   	push   %ebp
801027b1:	89 e5                	mov    %esp,%ebp
801027b3:	57                   	push   %edi
801027b4:	56                   	push   %esi
801027b5:	53                   	push   %ebx
801027b6:	83 ec 0c             	sub    $0xc,%esp
801027b9:	bb 00 00 00 00       	mov    $0x0,%ebx
801027be:	eb 66                	jmp    80102826 <write_log+0x76>
801027c0:	89 d8                	mov    %ebx,%eax
801027c2:	03 05 d4 16 12 80    	add    0x801216d4,%eax
801027c8:	83 c0 01             	add    $0x1,%eax
801027cb:	83 ec 08             	sub    $0x8,%esp
801027ce:	50                   	push   %eax
801027cf:	ff 35 e4 16 12 80    	pushl  0x801216e4
801027d5:	e8 92 d9 ff ff       	call   8010016c <bread>
801027da:	89 c6                	mov    %eax,%esi
801027dc:	83 c4 08             	add    $0x8,%esp
801027df:	ff 34 9d ec 16 12 80 	pushl  -0x7fede914(,%ebx,4)
801027e6:	ff 35 e4 16 12 80    	pushl  0x801216e4
801027ec:	e8 7b d9 ff ff       	call   8010016c <bread>
801027f1:	89 c7                	mov    %eax,%edi
801027f3:	8d 50 5c             	lea    0x5c(%eax),%edx
801027f6:	8d 46 5c             	lea    0x5c(%esi),%eax
801027f9:	83 c4 0c             	add    $0xc,%esp
801027fc:	68 00 02 00 00       	push   $0x200
80102801:	52                   	push   %edx
80102802:	50                   	push   %eax
80102803:	e8 cc 15 00 00       	call   80103dd4 <memmove>
80102808:	89 34 24             	mov    %esi,(%esp)
8010280b:	e8 8a d9 ff ff       	call   8010019a <bwrite>
80102810:	89 3c 24             	mov    %edi,(%esp)
80102813:	e8 bd d9 ff ff       	call   801001d5 <brelse>
80102818:	89 34 24             	mov    %esi,(%esp)
8010281b:	e8 b5 d9 ff ff       	call   801001d5 <brelse>
80102820:	83 c3 01             	add    $0x1,%ebx
80102823:	83 c4 10             	add    $0x10,%esp
80102826:	39 1d e8 16 12 80    	cmp    %ebx,0x801216e8
8010282c:	7f 92                	jg     801027c0 <write_log+0x10>
8010282e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102831:	5b                   	pop    %ebx
80102832:	5e                   	pop    %esi
80102833:	5f                   	pop    %edi
80102834:	5d                   	pop    %ebp
80102835:	c3                   	ret    

80102836 <commit>:
80102836:	83 3d e8 16 12 80 00 	cmpl   $0x0,0x801216e8
8010283d:	7e 26                	jle    80102865 <commit+0x2f>
8010283f:	55                   	push   %ebp
80102840:	89 e5                	mov    %esp,%ebp
80102842:	83 ec 08             	sub    $0x8,%esp
80102845:	e8 66 ff ff ff       	call   801027b0 <write_log>
8010284a:	e8 e8 fe ff ff       	call   80102737 <write_head>
8010284f:	e8 5d fe ff ff       	call   801026b1 <install_trans>
80102854:	c7 05 e8 16 12 80 00 	movl   $0x0,0x801216e8
8010285b:	00 00 00 
8010285e:	e8 d4 fe ff ff       	call   80102737 <write_head>
80102863:	c9                   	leave  
80102864:	c3                   	ret    
80102865:	f3 c3                	repz ret 

80102867 <initlog>:
80102867:	55                   	push   %ebp
80102868:	89 e5                	mov    %esp,%ebp
8010286a:	53                   	push   %ebx
8010286b:	83 ec 2c             	sub    $0x2c,%esp
8010286e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102871:	68 80 6a 10 80       	push   $0x80106a80
80102876:	68 a0 16 12 80       	push   $0x801216a0
8010287b:	e8 f1 12 00 00       	call   80103b71 <initlock>
80102880:	83 c4 08             	add    $0x8,%esp
80102883:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102886:	50                   	push   %eax
80102887:	53                   	push   %ebx
80102888:	e8 b5 e9 ff ff       	call   80101242 <readsb>
8010288d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102890:	a3 d4 16 12 80       	mov    %eax,0x801216d4
80102895:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102898:	a3 d8 16 12 80       	mov    %eax,0x801216d8
8010289d:	89 1d e4 16 12 80    	mov    %ebx,0x801216e4
801028a3:	e8 e7 fe ff ff       	call   8010278f <recover_from_log>
801028a8:	83 c4 10             	add    $0x10,%esp
801028ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028ae:	c9                   	leave  
801028af:	c3                   	ret    

801028b0 <begin_op>:
801028b0:	55                   	push   %ebp
801028b1:	89 e5                	mov    %esp,%ebp
801028b3:	83 ec 14             	sub    $0x14,%esp
801028b6:	68 a0 16 12 80       	push   $0x801216a0
801028bb:	e8 ed 13 00 00       	call   80103cad <acquire>
801028c0:	83 c4 10             	add    $0x10,%esp
801028c3:	eb 15                	jmp    801028da <begin_op+0x2a>
801028c5:	83 ec 08             	sub    $0x8,%esp
801028c8:	68 a0 16 12 80       	push   $0x801216a0
801028cd:	68 a0 16 12 80       	push   $0x801216a0
801028d2:	e8 db 0e 00 00       	call   801037b2 <sleep>
801028d7:	83 c4 10             	add    $0x10,%esp
801028da:	83 3d e0 16 12 80 00 	cmpl   $0x0,0x801216e0
801028e1:	75 e2                	jne    801028c5 <begin_op+0x15>
801028e3:	a1 dc 16 12 80       	mov    0x801216dc,%eax
801028e8:	83 c0 01             	add    $0x1,%eax
801028eb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801028ee:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801028f1:	03 15 e8 16 12 80    	add    0x801216e8,%edx
801028f7:	83 fa 1e             	cmp    $0x1e,%edx
801028fa:	7e 17                	jle    80102913 <begin_op+0x63>
801028fc:	83 ec 08             	sub    $0x8,%esp
801028ff:	68 a0 16 12 80       	push   $0x801216a0
80102904:	68 a0 16 12 80       	push   $0x801216a0
80102909:	e8 a4 0e 00 00       	call   801037b2 <sleep>
8010290e:	83 c4 10             	add    $0x10,%esp
80102911:	eb c7                	jmp    801028da <begin_op+0x2a>
80102913:	a3 dc 16 12 80       	mov    %eax,0x801216dc
80102918:	83 ec 0c             	sub    $0xc,%esp
8010291b:	68 a0 16 12 80       	push   $0x801216a0
80102920:	e8 ed 13 00 00       	call   80103d12 <release>
80102925:	83 c4 10             	add    $0x10,%esp
80102928:	c9                   	leave  
80102929:	c3                   	ret    

8010292a <end_op>:
8010292a:	55                   	push   %ebp
8010292b:	89 e5                	mov    %esp,%ebp
8010292d:	53                   	push   %ebx
8010292e:	83 ec 10             	sub    $0x10,%esp
80102931:	68 a0 16 12 80       	push   $0x801216a0
80102936:	e8 72 13 00 00       	call   80103cad <acquire>
8010293b:	a1 dc 16 12 80       	mov    0x801216dc,%eax
80102940:	83 e8 01             	sub    $0x1,%eax
80102943:	a3 dc 16 12 80       	mov    %eax,0x801216dc
80102948:	8b 1d e0 16 12 80    	mov    0x801216e0,%ebx
8010294e:	83 c4 10             	add    $0x10,%esp
80102951:	85 db                	test   %ebx,%ebx
80102953:	75 2c                	jne    80102981 <end_op+0x57>
80102955:	85 c0                	test   %eax,%eax
80102957:	75 35                	jne    8010298e <end_op+0x64>
80102959:	c7 05 e0 16 12 80 01 	movl   $0x1,0x801216e0
80102960:	00 00 00 
80102963:	bb 01 00 00 00       	mov    $0x1,%ebx
80102968:	83 ec 0c             	sub    $0xc,%esp
8010296b:	68 a0 16 12 80       	push   $0x801216a0
80102970:	e8 9d 13 00 00       	call   80103d12 <release>
80102975:	83 c4 10             	add    $0x10,%esp
80102978:	85 db                	test   %ebx,%ebx
8010297a:	75 24                	jne    801029a0 <end_op+0x76>
8010297c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010297f:	c9                   	leave  
80102980:	c3                   	ret    
80102981:	83 ec 0c             	sub    $0xc,%esp
80102984:	68 84 6a 10 80       	push   $0x80106a84
80102989:	e8 ba d9 ff ff       	call   80100348 <panic>
8010298e:	83 ec 0c             	sub    $0xc,%esp
80102991:	68 a0 16 12 80       	push   $0x801216a0
80102996:	e8 7c 0f 00 00       	call   80103917 <wakeup>
8010299b:	83 c4 10             	add    $0x10,%esp
8010299e:	eb c8                	jmp    80102968 <end_op+0x3e>
801029a0:	e8 91 fe ff ff       	call   80102836 <commit>
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	68 a0 16 12 80       	push   $0x801216a0
801029ad:	e8 fb 12 00 00       	call   80103cad <acquire>
801029b2:	c7 05 e0 16 12 80 00 	movl   $0x0,0x801216e0
801029b9:	00 00 00 
801029bc:	c7 04 24 a0 16 12 80 	movl   $0x801216a0,(%esp)
801029c3:	e8 4f 0f 00 00       	call   80103917 <wakeup>
801029c8:	c7 04 24 a0 16 12 80 	movl   $0x801216a0,(%esp)
801029cf:	e8 3e 13 00 00       	call   80103d12 <release>
801029d4:	83 c4 10             	add    $0x10,%esp
801029d7:	eb a3                	jmp    8010297c <end_op+0x52>

801029d9 <log_write>:
801029d9:	55                   	push   %ebp
801029da:	89 e5                	mov    %esp,%ebp
801029dc:	53                   	push   %ebx
801029dd:	83 ec 04             	sub    $0x4,%esp
801029e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
801029e3:	8b 15 e8 16 12 80    	mov    0x801216e8,%edx
801029e9:	83 fa 1d             	cmp    $0x1d,%edx
801029ec:	7f 45                	jg     80102a33 <log_write+0x5a>
801029ee:	a1 d8 16 12 80       	mov    0x801216d8,%eax
801029f3:	83 e8 01             	sub    $0x1,%eax
801029f6:	39 c2                	cmp    %eax,%edx
801029f8:	7d 39                	jge    80102a33 <log_write+0x5a>
801029fa:	83 3d dc 16 12 80 00 	cmpl   $0x0,0x801216dc
80102a01:	7e 3d                	jle    80102a40 <log_write+0x67>
80102a03:	83 ec 0c             	sub    $0xc,%esp
80102a06:	68 a0 16 12 80       	push   $0x801216a0
80102a0b:	e8 9d 12 00 00       	call   80103cad <acquire>
80102a10:	83 c4 10             	add    $0x10,%esp
80102a13:	b8 00 00 00 00       	mov    $0x0,%eax
80102a18:	8b 15 e8 16 12 80    	mov    0x801216e8,%edx
80102a1e:	39 c2                	cmp    %eax,%edx
80102a20:	7e 2b                	jle    80102a4d <log_write+0x74>
80102a22:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a25:	39 0c 85 ec 16 12 80 	cmp    %ecx,-0x7fede914(,%eax,4)
80102a2c:	74 1f                	je     80102a4d <log_write+0x74>
80102a2e:	83 c0 01             	add    $0x1,%eax
80102a31:	eb e5                	jmp    80102a18 <log_write+0x3f>
80102a33:	83 ec 0c             	sub    $0xc,%esp
80102a36:	68 93 6a 10 80       	push   $0x80106a93
80102a3b:	e8 08 d9 ff ff       	call   80100348 <panic>
80102a40:	83 ec 0c             	sub    $0xc,%esp
80102a43:	68 a9 6a 10 80       	push   $0x80106aa9
80102a48:	e8 fb d8 ff ff       	call   80100348 <panic>
80102a4d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a50:	89 0c 85 ec 16 12 80 	mov    %ecx,-0x7fede914(,%eax,4)
80102a57:	39 c2                	cmp    %eax,%edx
80102a59:	74 18                	je     80102a73 <log_write+0x9a>
80102a5b:	83 0b 04             	orl    $0x4,(%ebx)
80102a5e:	83 ec 0c             	sub    $0xc,%esp
80102a61:	68 a0 16 12 80       	push   $0x801216a0
80102a66:	e8 a7 12 00 00       	call   80103d12 <release>
80102a6b:	83 c4 10             	add    $0x10,%esp
80102a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a71:	c9                   	leave  
80102a72:	c3                   	ret    
80102a73:	83 c2 01             	add    $0x1,%edx
80102a76:	89 15 e8 16 12 80    	mov    %edx,0x801216e8
80102a7c:	eb dd                	jmp    80102a5b <log_write+0x82>

80102a7e <startothers>:
80102a7e:	55                   	push   %ebp
80102a7f:	89 e5                	mov    %esp,%ebp
80102a81:	53                   	push   %ebx
80102a82:	83 ec 08             	sub    $0x8,%esp
80102a85:	68 8a 00 00 00       	push   $0x8a
80102a8a:	68 8c 94 10 80       	push   $0x8010948c
80102a8f:	68 00 70 00 80       	push   $0x80007000
80102a94:	e8 3b 13 00 00       	call   80103dd4 <memmove>
80102a99:	83 c4 10             	add    $0x10,%esp
80102a9c:	bb a0 17 12 80       	mov    $0x801217a0,%ebx
80102aa1:	eb 06                	jmp    80102aa9 <startothers+0x2b>
80102aa3:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102aa9:	69 05 20 1d 12 80 b0 	imul   $0xb0,0x80121d20,%eax
80102ab0:	00 00 00 
80102ab3:	05 a0 17 12 80       	add    $0x801217a0,%eax
80102ab8:	39 d8                	cmp    %ebx,%eax
80102aba:	76 51                	jbe    80102b0d <startothers+0x8f>
80102abc:	e8 d3 07 00 00       	call   80103294 <mycpu>
80102ac1:	39 d8                	cmp    %ebx,%eax
80102ac3:	74 de                	je     80102aa3 <startothers+0x25>
80102ac5:	83 ec 0c             	sub    $0xc,%esp
80102ac8:	6a fe                	push   $0xfffffffe
80102aca:	e8 f8 f5 ff ff       	call   801020c7 <kalloc>
80102acf:	05 00 10 00 00       	add    $0x1000,%eax
80102ad4:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
80102ad9:	c7 05 f8 6f 00 80 51 	movl   $0x80102b51,0x80006ff8
80102ae0:	2b 10 80 
80102ae3:	c7 05 f4 6f 00 80 00 	movl   $0x108000,0x80006ff4
80102aea:	80 10 00 
80102aed:	83 c4 08             	add    $0x8,%esp
80102af0:	68 00 70 00 00       	push   $0x7000
80102af5:	0f b6 03             	movzbl (%ebx),%eax
80102af8:	50                   	push   %eax
80102af9:	e8 c1 f9 ff ff       	call   801024bf <lapicstartap>
80102afe:	83 c4 10             	add    $0x10,%esp
80102b01:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b07:	85 c0                	test   %eax,%eax
80102b09:	74 f6                	je     80102b01 <startothers+0x83>
80102b0b:	eb 96                	jmp    80102aa3 <startothers+0x25>
80102b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b10:	c9                   	leave  
80102b11:	c3                   	ret    

80102b12 <mpmain>:
80102b12:	55                   	push   %ebp
80102b13:	89 e5                	mov    %esp,%ebp
80102b15:	53                   	push   %ebx
80102b16:	83 ec 04             	sub    $0x4,%esp
80102b19:	e8 d2 07 00 00       	call   801032f0 <cpuid>
80102b1e:	89 c3                	mov    %eax,%ebx
80102b20:	e8 cb 07 00 00       	call   801032f0 <cpuid>
80102b25:	83 ec 04             	sub    $0x4,%esp
80102b28:	53                   	push   %ebx
80102b29:	50                   	push   %eax
80102b2a:	68 c4 6a 10 80       	push   $0x80106ac4
80102b2f:	e8 d7 da ff ff       	call   8010060b <cprintf>
80102b34:	e8 f2 23 00 00       	call   80104f2b <idtinit>
80102b39:	e8 56 07 00 00       	call   80103294 <mycpu>
80102b3e:	89 c2                	mov    %eax,%edx
80102b40:	b8 01 00 00 00       	mov    $0x1,%eax
80102b45:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
80102b4c:	e8 3c 0a 00 00       	call   8010358d <scheduler>

80102b51 <mpenter>:
80102b51:	55                   	push   %ebp
80102b52:	89 e5                	mov    %esp,%ebp
80102b54:	83 ec 08             	sub    $0x8,%esp
80102b57:	e8 e0 33 00 00       	call   80105f3c <switchkvm>
80102b5c:	e8 8f 32 00 00       	call   80105df0 <seginit>
80102b61:	e8 10 f8 ff ff       	call   80102376 <lapicinit>
80102b66:	e8 a7 ff ff ff       	call   80102b12 <mpmain>

80102b6b <main>:
80102b6b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102b6f:	83 e4 f0             	and    $0xfffffff0,%esp
80102b72:	ff 71 fc             	pushl  -0x4(%ecx)
80102b75:	55                   	push   %ebp
80102b76:	89 e5                	mov    %esp,%ebp
80102b78:	51                   	push   %ecx
80102b79:	83 ec 0c             	sub    $0xc,%esp
80102b7c:	68 00 00 40 80       	push   $0x80400000
80102b81:	68 c8 44 12 80       	push   $0x801244c8
80102b86:	e8 ea f4 ff ff       	call   80102075 <kinit1>
80102b8b:	e8 4f 38 00 00       	call   801063df <kvmalloc>
80102b90:	e8 c9 01 00 00       	call   80102d5e <mpinit>
80102b95:	e8 dc f7 ff ff       	call   80102376 <lapicinit>
80102b9a:	e8 51 32 00 00       	call   80105df0 <seginit>
80102b9f:	e8 82 02 00 00       	call   80102e26 <picinit>
80102ba4:	e8 5d f3 ff ff       	call   80101f06 <ioapicinit>
80102ba9:	e8 e0 dc ff ff       	call   8010088e <consoleinit>
80102bae:	e8 26 26 00 00       	call   801051d9 <uartinit>
80102bb3:	e8 c2 06 00 00       	call   8010327a <pinit>
80102bb8:	e8 bd 22 00 00       	call   80104e7a <tvinit>
80102bbd:	e8 32 d5 ff ff       	call   801000f4 <binit>
80102bc2:	e8 58 e0 ff ff       	call   80100c1f <fileinit>
80102bc7:	e8 40 f1 ff ff       	call   80101d0c <ideinit>
80102bcc:	e8 ad fe ff ff       	call   80102a7e <startothers>
80102bd1:	83 c4 08             	add    $0x8,%esp
80102bd4:	68 00 00 00 8e       	push   $0x8e000000
80102bd9:	68 00 00 40 80       	push   $0x80400000
80102bde:	e8 c4 f4 ff ff       	call   801020a7 <kinit2>
80102be3:	e8 47 07 00 00       	call   8010332f <userinit>
80102be8:	e8 25 ff ff ff       	call   80102b12 <mpmain>

80102bed <sum>:
80102bed:	55                   	push   %ebp
80102bee:	89 e5                	mov    %esp,%ebp
80102bf0:	56                   	push   %esi
80102bf1:	53                   	push   %ebx
80102bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
80102bf7:	b9 00 00 00 00       	mov    $0x0,%ecx
80102bfc:	eb 09                	jmp    80102c07 <sum+0x1a>
80102bfe:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102c02:	01 f3                	add    %esi,%ebx
80102c04:	83 c1 01             	add    $0x1,%ecx
80102c07:	39 d1                	cmp    %edx,%ecx
80102c09:	7c f3                	jl     80102bfe <sum+0x11>
80102c0b:	89 d8                	mov    %ebx,%eax
80102c0d:	5b                   	pop    %ebx
80102c0e:	5e                   	pop    %esi
80102c0f:	5d                   	pop    %ebp
80102c10:	c3                   	ret    

80102c11 <mpsearch1>:
80102c11:	55                   	push   %ebp
80102c12:	89 e5                	mov    %esp,%ebp
80102c14:	56                   	push   %esi
80102c15:	53                   	push   %ebx
80102c16:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102c1c:	89 f3                	mov    %esi,%ebx
80102c1e:	01 d6                	add    %edx,%esi
80102c20:	eb 03                	jmp    80102c25 <mpsearch1+0x14>
80102c22:	83 c3 10             	add    $0x10,%ebx
80102c25:	39 f3                	cmp    %esi,%ebx
80102c27:	73 29                	jae    80102c52 <mpsearch1+0x41>
80102c29:	83 ec 04             	sub    $0x4,%esp
80102c2c:	6a 04                	push   $0x4
80102c2e:	68 d8 6a 10 80       	push   $0x80106ad8
80102c33:	53                   	push   %ebx
80102c34:	e8 66 11 00 00       	call   80103d9f <memcmp>
80102c39:	83 c4 10             	add    $0x10,%esp
80102c3c:	85 c0                	test   %eax,%eax
80102c3e:	75 e2                	jne    80102c22 <mpsearch1+0x11>
80102c40:	ba 10 00 00 00       	mov    $0x10,%edx
80102c45:	89 d8                	mov    %ebx,%eax
80102c47:	e8 a1 ff ff ff       	call   80102bed <sum>
80102c4c:	84 c0                	test   %al,%al
80102c4e:	75 d2                	jne    80102c22 <mpsearch1+0x11>
80102c50:	eb 05                	jmp    80102c57 <mpsearch1+0x46>
80102c52:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c57:	89 d8                	mov    %ebx,%eax
80102c59:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102c5c:	5b                   	pop    %ebx
80102c5d:	5e                   	pop    %esi
80102c5e:	5d                   	pop    %ebp
80102c5f:	c3                   	ret    

80102c60 <mpsearch>:
80102c60:	55                   	push   %ebp
80102c61:	89 e5                	mov    %esp,%ebp
80102c63:	83 ec 08             	sub    $0x8,%esp
80102c66:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c6d:	c1 e0 08             	shl    $0x8,%eax
80102c70:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c77:	09 d0                	or     %edx,%eax
80102c79:	c1 e0 04             	shl    $0x4,%eax
80102c7c:	85 c0                	test   %eax,%eax
80102c7e:	74 1f                	je     80102c9f <mpsearch+0x3f>
80102c80:	ba 00 04 00 00       	mov    $0x400,%edx
80102c85:	e8 87 ff ff ff       	call   80102c11 <mpsearch1>
80102c8a:	85 c0                	test   %eax,%eax
80102c8c:	75 0f                	jne    80102c9d <mpsearch+0x3d>
80102c8e:	ba 00 00 01 00       	mov    $0x10000,%edx
80102c93:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102c98:	e8 74 ff ff ff       	call   80102c11 <mpsearch1>
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    
80102c9f:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102ca6:	c1 e0 08             	shl    $0x8,%eax
80102ca9:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102cb0:	09 d0                	or     %edx,%eax
80102cb2:	c1 e0 0a             	shl    $0xa,%eax
80102cb5:	2d 00 04 00 00       	sub    $0x400,%eax
80102cba:	ba 00 04 00 00       	mov    $0x400,%edx
80102cbf:	e8 4d ff ff ff       	call   80102c11 <mpsearch1>
80102cc4:	85 c0                	test   %eax,%eax
80102cc6:	75 d5                	jne    80102c9d <mpsearch+0x3d>
80102cc8:	eb c4                	jmp    80102c8e <mpsearch+0x2e>

80102cca <mpconfig>:
80102cca:	55                   	push   %ebp
80102ccb:	89 e5                	mov    %esp,%ebp
80102ccd:	57                   	push   %edi
80102cce:	56                   	push   %esi
80102ccf:	53                   	push   %ebx
80102cd0:	83 ec 1c             	sub    $0x1c,%esp
80102cd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80102cd6:	e8 85 ff ff ff       	call   80102c60 <mpsearch>
80102cdb:	85 c0                	test   %eax,%eax
80102cdd:	74 5c                	je     80102d3b <mpconfig+0x71>
80102cdf:	89 c7                	mov    %eax,%edi
80102ce1:	8b 58 04             	mov    0x4(%eax),%ebx
80102ce4:	85 db                	test   %ebx,%ebx
80102ce6:	74 5a                	je     80102d42 <mpconfig+0x78>
80102ce8:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80102cee:	83 ec 04             	sub    $0x4,%esp
80102cf1:	6a 04                	push   $0x4
80102cf3:	68 dd 6a 10 80       	push   $0x80106add
80102cf8:	56                   	push   %esi
80102cf9:	e8 a1 10 00 00       	call   80103d9f <memcmp>
80102cfe:	83 c4 10             	add    $0x10,%esp
80102d01:	85 c0                	test   %eax,%eax
80102d03:	75 44                	jne    80102d49 <mpconfig+0x7f>
80102d05:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102d0c:	3c 01                	cmp    $0x1,%al
80102d0e:	0f 95 c2             	setne  %dl
80102d11:	3c 04                	cmp    $0x4,%al
80102d13:	0f 95 c0             	setne  %al
80102d16:	84 c2                	test   %al,%dl
80102d18:	75 36                	jne    80102d50 <mpconfig+0x86>
80102d1a:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102d21:	89 f0                	mov    %esi,%eax
80102d23:	e8 c5 fe ff ff       	call   80102bed <sum>
80102d28:	84 c0                	test   %al,%al
80102d2a:	75 2b                	jne    80102d57 <mpconfig+0x8d>
80102d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d2f:	89 38                	mov    %edi,(%eax)
80102d31:	89 f0                	mov    %esi,%eax
80102d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d36:	5b                   	pop    %ebx
80102d37:	5e                   	pop    %esi
80102d38:	5f                   	pop    %edi
80102d39:	5d                   	pop    %ebp
80102d3a:	c3                   	ret    
80102d3b:	be 00 00 00 00       	mov    $0x0,%esi
80102d40:	eb ef                	jmp    80102d31 <mpconfig+0x67>
80102d42:	be 00 00 00 00       	mov    $0x0,%esi
80102d47:	eb e8                	jmp    80102d31 <mpconfig+0x67>
80102d49:	be 00 00 00 00       	mov    $0x0,%esi
80102d4e:	eb e1                	jmp    80102d31 <mpconfig+0x67>
80102d50:	be 00 00 00 00       	mov    $0x0,%esi
80102d55:	eb da                	jmp    80102d31 <mpconfig+0x67>
80102d57:	be 00 00 00 00       	mov    $0x0,%esi
80102d5c:	eb d3                	jmp    80102d31 <mpconfig+0x67>

80102d5e <mpinit>:
80102d5e:	55                   	push   %ebp
80102d5f:	89 e5                	mov    %esp,%ebp
80102d61:	57                   	push   %edi
80102d62:	56                   	push   %esi
80102d63:	53                   	push   %ebx
80102d64:	83 ec 1c             	sub    $0x1c,%esp
80102d67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102d6a:	e8 5b ff ff ff       	call   80102cca <mpconfig>
80102d6f:	85 c0                	test   %eax,%eax
80102d71:	74 19                	je     80102d8c <mpinit+0x2e>
80102d73:	8b 50 24             	mov    0x24(%eax),%edx
80102d76:	89 15 9c 16 12 80    	mov    %edx,0x8012169c
80102d7c:	8d 50 2c             	lea    0x2c(%eax),%edx
80102d7f:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102d83:	01 c1                	add    %eax,%ecx
80102d85:	bb 01 00 00 00       	mov    $0x1,%ebx
80102d8a:	eb 34                	jmp    80102dc0 <mpinit+0x62>
80102d8c:	83 ec 0c             	sub    $0xc,%esp
80102d8f:	68 e2 6a 10 80       	push   $0x80106ae2
80102d94:	e8 af d5 ff ff       	call   80100348 <panic>
80102d99:	8b 35 20 1d 12 80    	mov    0x80121d20,%esi
80102d9f:	83 fe 07             	cmp    $0x7,%esi
80102da2:	7f 19                	jg     80102dbd <mpinit+0x5f>
80102da4:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102da8:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102dae:	88 87 a0 17 12 80    	mov    %al,-0x7fede860(%edi)
80102db4:	83 c6 01             	add    $0x1,%esi
80102db7:	89 35 20 1d 12 80    	mov    %esi,0x80121d20
80102dbd:	83 c2 14             	add    $0x14,%edx
80102dc0:	39 ca                	cmp    %ecx,%edx
80102dc2:	73 2b                	jae    80102def <mpinit+0x91>
80102dc4:	0f b6 02             	movzbl (%edx),%eax
80102dc7:	3c 04                	cmp    $0x4,%al
80102dc9:	77 1d                	ja     80102de8 <mpinit+0x8a>
80102dcb:	0f b6 c0             	movzbl %al,%eax
80102dce:	ff 24 85 1c 6b 10 80 	jmp    *-0x7fef94e4(,%eax,4)
80102dd5:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102dd9:	a2 80 17 12 80       	mov    %al,0x80121780
80102dde:	83 c2 08             	add    $0x8,%edx
80102de1:	eb dd                	jmp    80102dc0 <mpinit+0x62>
80102de3:	83 c2 08             	add    $0x8,%edx
80102de6:	eb d8                	jmp    80102dc0 <mpinit+0x62>
80102de8:	bb 00 00 00 00       	mov    $0x0,%ebx
80102ded:	eb d1                	jmp    80102dc0 <mpinit+0x62>
80102def:	85 db                	test   %ebx,%ebx
80102df1:	74 26                	je     80102e19 <mpinit+0xbb>
80102df3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102df6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102dfa:	74 15                	je     80102e11 <mpinit+0xb3>
80102dfc:	b8 70 00 00 00       	mov    $0x70,%eax
80102e01:	ba 22 00 00 00       	mov    $0x22,%edx
80102e06:	ee                   	out    %al,(%dx)
80102e07:	ba 23 00 00 00       	mov    $0x23,%edx
80102e0c:	ec                   	in     (%dx),%al
80102e0d:	83 c8 01             	or     $0x1,%eax
80102e10:	ee                   	out    %al,(%dx)
80102e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e14:	5b                   	pop    %ebx
80102e15:	5e                   	pop    %esi
80102e16:	5f                   	pop    %edi
80102e17:	5d                   	pop    %ebp
80102e18:	c3                   	ret    
80102e19:	83 ec 0c             	sub    $0xc,%esp
80102e1c:	68 fc 6a 10 80       	push   $0x80106afc
80102e21:	e8 22 d5 ff ff       	call   80100348 <panic>

80102e26 <picinit>:
80102e26:	55                   	push   %ebp
80102e27:	89 e5                	mov    %esp,%ebp
80102e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e2e:	ba 21 00 00 00       	mov    $0x21,%edx
80102e33:	ee                   	out    %al,(%dx)
80102e34:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e39:	ee                   	out    %al,(%dx)
80102e3a:	5d                   	pop    %ebp
80102e3b:	c3                   	ret    

80102e3c <pipealloc>:
80102e3c:	55                   	push   %ebp
80102e3d:	89 e5                	mov    %esp,%ebp
80102e3f:	57                   	push   %edi
80102e40:	56                   	push   %esi
80102e41:	53                   	push   %ebx
80102e42:	83 ec 0c             	sub    $0xc,%esp
80102e45:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e48:	8b 75 0c             	mov    0xc(%ebp),%esi
80102e4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e51:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80102e57:	e8 dd dd ff ff       	call   80100c39 <filealloc>
80102e5c:	89 03                	mov    %eax,(%ebx)
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	74 1e                	je     80102e80 <pipealloc+0x44>
80102e62:	e8 d2 dd ff ff       	call   80100c39 <filealloc>
80102e67:	89 06                	mov    %eax,(%esi)
80102e69:	85 c0                	test   %eax,%eax
80102e6b:	74 13                	je     80102e80 <pipealloc+0x44>
80102e6d:	83 ec 0c             	sub    $0xc,%esp
80102e70:	6a fe                	push   $0xfffffffe
80102e72:	e8 50 f2 ff ff       	call   801020c7 <kalloc>
80102e77:	89 c7                	mov    %eax,%edi
80102e79:	83 c4 10             	add    $0x10,%esp
80102e7c:	85 c0                	test   %eax,%eax
80102e7e:	75 35                	jne    80102eb5 <pipealloc+0x79>
80102e80:	8b 03                	mov    (%ebx),%eax
80102e82:	85 c0                	test   %eax,%eax
80102e84:	74 0c                	je     80102e92 <pipealloc+0x56>
80102e86:	83 ec 0c             	sub    $0xc,%esp
80102e89:	50                   	push   %eax
80102e8a:	e8 50 de ff ff       	call   80100cdf <fileclose>
80102e8f:	83 c4 10             	add    $0x10,%esp
80102e92:	8b 06                	mov    (%esi),%eax
80102e94:	85 c0                	test   %eax,%eax
80102e96:	0f 84 8b 00 00 00    	je     80102f27 <pipealloc+0xeb>
80102e9c:	83 ec 0c             	sub    $0xc,%esp
80102e9f:	50                   	push   %eax
80102ea0:	e8 3a de ff ff       	call   80100cdf <fileclose>
80102ea5:	83 c4 10             	add    $0x10,%esp
80102ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102eb0:	5b                   	pop    %ebx
80102eb1:	5e                   	pop    %esi
80102eb2:	5f                   	pop    %edi
80102eb3:	5d                   	pop    %ebp
80102eb4:	c3                   	ret    
80102eb5:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102ebc:	00 00 00 
80102ebf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102ec6:	00 00 00 
80102ec9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102ed0:	00 00 00 
80102ed3:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102eda:	00 00 00 
80102edd:	83 ec 08             	sub    $0x8,%esp
80102ee0:	68 30 6b 10 80       	push   $0x80106b30
80102ee5:	50                   	push   %eax
80102ee6:	e8 86 0c 00 00       	call   80103b71 <initlock>
80102eeb:	8b 03                	mov    (%ebx),%eax
80102eed:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80102ef3:	8b 03                	mov    (%ebx),%eax
80102ef5:	c6 40 08 01          	movb   $0x1,0x8(%eax)
80102ef9:	8b 03                	mov    (%ebx),%eax
80102efb:	c6 40 09 00          	movb   $0x0,0x9(%eax)
80102eff:	8b 03                	mov    (%ebx),%eax
80102f01:	89 78 0c             	mov    %edi,0xc(%eax)
80102f04:	8b 06                	mov    (%esi),%eax
80102f06:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80102f0c:	8b 06                	mov    (%esi),%eax
80102f0e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
80102f12:	8b 06                	mov    (%esi),%eax
80102f14:	c6 40 09 01          	movb   $0x1,0x9(%eax)
80102f18:	8b 06                	mov    (%esi),%eax
80102f1a:	89 78 0c             	mov    %edi,0xc(%eax)
80102f1d:	83 c4 10             	add    $0x10,%esp
80102f20:	b8 00 00 00 00       	mov    $0x0,%eax
80102f25:	eb 86                	jmp    80102ead <pipealloc+0x71>
80102f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f2c:	e9 7c ff ff ff       	jmp    80102ead <pipealloc+0x71>

80102f31 <pipeclose>:
80102f31:	55                   	push   %ebp
80102f32:	89 e5                	mov    %esp,%ebp
80102f34:	53                   	push   %ebx
80102f35:	83 ec 10             	sub    $0x10,%esp
80102f38:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f3b:	53                   	push   %ebx
80102f3c:	e8 6c 0d 00 00       	call   80103cad <acquire>
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f48:	74 3f                	je     80102f89 <pipeclose+0x58>
80102f4a:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f51:	00 00 00 
80102f54:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f5a:	83 ec 0c             	sub    $0xc,%esp
80102f5d:	50                   	push   %eax
80102f5e:	e8 b4 09 00 00       	call   80103917 <wakeup>
80102f63:	83 c4 10             	add    $0x10,%esp
80102f66:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f6d:	75 09                	jne    80102f78 <pipeclose+0x47>
80102f6f:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102f76:	74 2f                	je     80102fa7 <pipeclose+0x76>
80102f78:	83 ec 0c             	sub    $0xc,%esp
80102f7b:	53                   	push   %ebx
80102f7c:	e8 91 0d 00 00       	call   80103d12 <release>
80102f81:	83 c4 10             	add    $0x10,%esp
80102f84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f87:	c9                   	leave  
80102f88:	c3                   	ret    
80102f89:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f90:	00 00 00 
80102f93:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f99:	83 ec 0c             	sub    $0xc,%esp
80102f9c:	50                   	push   %eax
80102f9d:	e8 75 09 00 00       	call   80103917 <wakeup>
80102fa2:	83 c4 10             	add    $0x10,%esp
80102fa5:	eb bf                	jmp    80102f66 <pipeclose+0x35>
80102fa7:	83 ec 0c             	sub    $0xc,%esp
80102faa:	53                   	push   %ebx
80102fab:	e8 62 0d 00 00       	call   80103d12 <release>
80102fb0:	89 1c 24             	mov    %ebx,(%esp)
80102fb3:	e8 f8 ef ff ff       	call   80101fb0 <kfree>
80102fb8:	83 c4 10             	add    $0x10,%esp
80102fbb:	eb c7                	jmp    80102f84 <pipeclose+0x53>

80102fbd <pipewrite>:
80102fbd:	55                   	push   %ebp
80102fbe:	89 e5                	mov    %esp,%ebp
80102fc0:	57                   	push   %edi
80102fc1:	56                   	push   %esi
80102fc2:	53                   	push   %ebx
80102fc3:	83 ec 18             	sub    $0x18,%esp
80102fc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102fc9:	89 de                	mov    %ebx,%esi
80102fcb:	53                   	push   %ebx
80102fcc:	e8 dc 0c 00 00       	call   80103cad <acquire>
80102fd1:	83 c4 10             	add    $0x10,%esp
80102fd4:	bf 00 00 00 00       	mov    $0x0,%edi
80102fd9:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102fdc:	0f 8d 88 00 00 00    	jge    8010306a <pipewrite+0xad>
80102fe2:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102fe8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102fee:	05 00 02 00 00       	add    $0x200,%eax
80102ff3:	39 c2                	cmp    %eax,%edx
80102ff5:	75 51                	jne    80103048 <pipewrite+0x8b>
80102ff7:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102ffe:	74 2f                	je     8010302f <pipewrite+0x72>
80103000:	e8 06 03 00 00       	call   8010330b <myproc>
80103005:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103009:	75 24                	jne    8010302f <pipewrite+0x72>
8010300b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103011:	83 ec 0c             	sub    $0xc,%esp
80103014:	50                   	push   %eax
80103015:	e8 fd 08 00 00       	call   80103917 <wakeup>
8010301a:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103020:	83 c4 08             	add    $0x8,%esp
80103023:	56                   	push   %esi
80103024:	50                   	push   %eax
80103025:	e8 88 07 00 00       	call   801037b2 <sleep>
8010302a:	83 c4 10             	add    $0x10,%esp
8010302d:	eb b3                	jmp    80102fe2 <pipewrite+0x25>
8010302f:	83 ec 0c             	sub    $0xc,%esp
80103032:	53                   	push   %ebx
80103033:	e8 da 0c 00 00       	call   80103d12 <release>
80103038:	83 c4 10             	add    $0x10,%esp
8010303b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103040:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103043:	5b                   	pop    %ebx
80103044:	5e                   	pop    %esi
80103045:	5f                   	pop    %edi
80103046:	5d                   	pop    %ebp
80103047:	c3                   	ret    
80103048:	8d 42 01             	lea    0x1(%edx),%eax
8010304b:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103051:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010305a:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
8010305e:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
80103062:	83 c7 01             	add    $0x1,%edi
80103065:	e9 6f ff ff ff       	jmp    80102fd9 <pipewrite+0x1c>
8010306a:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103070:	83 ec 0c             	sub    $0xc,%esp
80103073:	50                   	push   %eax
80103074:	e8 9e 08 00 00       	call   80103917 <wakeup>
80103079:	89 1c 24             	mov    %ebx,(%esp)
8010307c:	e8 91 0c 00 00       	call   80103d12 <release>
80103081:	83 c4 10             	add    $0x10,%esp
80103084:	8b 45 10             	mov    0x10(%ebp),%eax
80103087:	eb b7                	jmp    80103040 <pipewrite+0x83>

80103089 <piperead>:
80103089:	55                   	push   %ebp
8010308a:	89 e5                	mov    %esp,%ebp
8010308c:	57                   	push   %edi
8010308d:	56                   	push   %esi
8010308e:	53                   	push   %ebx
8010308f:	83 ec 18             	sub    $0x18,%esp
80103092:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103095:	89 df                	mov    %ebx,%edi
80103097:	53                   	push   %ebx
80103098:	e8 10 0c 00 00       	call   80103cad <acquire>
8010309d:	83 c4 10             	add    $0x10,%esp
801030a0:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801030a6:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801030ac:	75 3d                	jne    801030eb <piperead+0x62>
801030ae:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
801030b4:	85 f6                	test   %esi,%esi
801030b6:	74 38                	je     801030f0 <piperead+0x67>
801030b8:	e8 4e 02 00 00       	call   8010330b <myproc>
801030bd:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801030c1:	75 15                	jne    801030d8 <piperead+0x4f>
801030c3:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030c9:	83 ec 08             	sub    $0x8,%esp
801030cc:	57                   	push   %edi
801030cd:	50                   	push   %eax
801030ce:	e8 df 06 00 00       	call   801037b2 <sleep>
801030d3:	83 c4 10             	add    $0x10,%esp
801030d6:	eb c8                	jmp    801030a0 <piperead+0x17>
801030d8:	83 ec 0c             	sub    $0xc,%esp
801030db:	53                   	push   %ebx
801030dc:	e8 31 0c 00 00       	call   80103d12 <release>
801030e1:	83 c4 10             	add    $0x10,%esp
801030e4:	be ff ff ff ff       	mov    $0xffffffff,%esi
801030e9:	eb 50                	jmp    8010313b <piperead+0xb2>
801030eb:	be 00 00 00 00       	mov    $0x0,%esi
801030f0:	3b 75 10             	cmp    0x10(%ebp),%esi
801030f3:	7d 2c                	jge    80103121 <piperead+0x98>
801030f5:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030fb:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103101:	74 1e                	je     80103121 <piperead+0x98>
80103103:	8d 50 01             	lea    0x1(%eax),%edx
80103106:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
8010310c:	25 ff 01 00 00       	and    $0x1ff,%eax
80103111:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103119:	88 04 31             	mov    %al,(%ecx,%esi,1)
8010311c:	83 c6 01             	add    $0x1,%esi
8010311f:	eb cf                	jmp    801030f0 <piperead+0x67>
80103121:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103127:	83 ec 0c             	sub    $0xc,%esp
8010312a:	50                   	push   %eax
8010312b:	e8 e7 07 00 00       	call   80103917 <wakeup>
80103130:	89 1c 24             	mov    %ebx,(%esp)
80103133:	e8 da 0b 00 00       	call   80103d12 <release>
80103138:	83 c4 10             	add    $0x10,%esp
8010313b:	89 f0                	mov    %esi,%eax
8010313d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103140:	5b                   	pop    %ebx
80103141:	5e                   	pop    %esi
80103142:	5f                   	pop    %edi
80103143:	5d                   	pop    %ebp
80103144:	c3                   	ret    

80103145 <wakeup1>:
80103145:	55                   	push   %ebp
80103146:	89 e5                	mov    %esp,%ebp
80103148:	ba 74 1d 12 80       	mov    $0x80121d74,%edx
8010314d:	eb 03                	jmp    80103152 <wakeup1+0xd>
8010314f:	83 c2 7c             	add    $0x7c,%edx
80103152:	81 fa 74 3c 12 80    	cmp    $0x80123c74,%edx
80103158:	73 14                	jae    8010316e <wakeup1+0x29>
8010315a:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010315e:	75 ef                	jne    8010314f <wakeup1+0xa>
80103160:	39 42 20             	cmp    %eax,0x20(%edx)
80103163:	75 ea                	jne    8010314f <wakeup1+0xa>
80103165:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010316c:	eb e1                	jmp    8010314f <wakeup1+0xa>
8010316e:	5d                   	pop    %ebp
8010316f:	c3                   	ret    

80103170 <allocproc>:
80103170:	55                   	push   %ebp
80103171:	89 e5                	mov    %esp,%ebp
80103173:	53                   	push   %ebx
80103174:	83 ec 10             	sub    $0x10,%esp
80103177:	68 40 1d 12 80       	push   $0x80121d40
8010317c:	e8 2c 0b 00 00       	call   80103cad <acquire>
80103181:	83 c4 10             	add    $0x10,%esp
80103184:	bb 74 1d 12 80       	mov    $0x80121d74,%ebx
80103189:	81 fb 74 3c 12 80    	cmp    $0x80123c74,%ebx
8010318f:	73 0b                	jae    8010319c <allocproc+0x2c>
80103191:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103195:	74 1c                	je     801031b3 <allocproc+0x43>
80103197:	83 c3 7c             	add    $0x7c,%ebx
8010319a:	eb ed                	jmp    80103189 <allocproc+0x19>
8010319c:	83 ec 0c             	sub    $0xc,%esp
8010319f:	68 40 1d 12 80       	push   $0x80121d40
801031a4:	e8 69 0b 00 00       	call   80103d12 <release>
801031a9:	83 c4 10             	add    $0x10,%esp
801031ac:	bb 00 00 00 00       	mov    $0x0,%ebx
801031b1:	eb 6f                	jmp    80103222 <allocproc+0xb2>
801031b3:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
801031ba:	a1 04 90 10 80       	mov    0x80109004,%eax
801031bf:	8d 50 01             	lea    0x1(%eax),%edx
801031c2:	89 15 04 90 10 80    	mov    %edx,0x80109004
801031c8:	89 43 10             	mov    %eax,0x10(%ebx)
801031cb:	83 ec 0c             	sub    $0xc,%esp
801031ce:	68 40 1d 12 80       	push   $0x80121d40
801031d3:	e8 3a 0b 00 00       	call   80103d12 <release>
801031d8:	83 c4 04             	add    $0x4,%esp
801031db:	ff 73 10             	pushl  0x10(%ebx)
801031de:	e8 e4 ee ff ff       	call   801020c7 <kalloc>
801031e3:	89 43 08             	mov    %eax,0x8(%ebx)
801031e6:	83 c4 10             	add    $0x10,%esp
801031e9:	85 c0                	test   %eax,%eax
801031eb:	74 3c                	je     80103229 <allocproc+0xb9>
801031ed:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
801031f3:	89 53 18             	mov    %edx,0x18(%ebx)
801031f6:	c7 80 b0 0f 00 00 6f 	movl   $0x80104e6f,0xfb0(%eax)
801031fd:	4e 10 80 
80103200:	05 9c 0f 00 00       	add    $0xf9c,%eax
80103205:	89 43 1c             	mov    %eax,0x1c(%ebx)
80103208:	83 ec 04             	sub    $0x4,%esp
8010320b:	6a 14                	push   $0x14
8010320d:	6a 00                	push   $0x0
8010320f:	50                   	push   %eax
80103210:	e8 44 0b 00 00       	call   80103d59 <memset>
80103215:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103218:	c7 40 10 37 32 10 80 	movl   $0x80103237,0x10(%eax)
8010321f:	83 c4 10             	add    $0x10,%esp
80103222:	89 d8                	mov    %ebx,%eax
80103224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103227:	c9                   	leave  
80103228:	c3                   	ret    
80103229:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
80103230:	bb 00 00 00 00       	mov    $0x0,%ebx
80103235:	eb eb                	jmp    80103222 <allocproc+0xb2>

80103237 <forkret>:
80103237:	55                   	push   %ebp
80103238:	89 e5                	mov    %esp,%ebp
8010323a:	83 ec 14             	sub    $0x14,%esp
8010323d:	68 40 1d 12 80       	push   $0x80121d40
80103242:	e8 cb 0a 00 00       	call   80103d12 <release>
80103247:	83 c4 10             	add    $0x10,%esp
8010324a:	83 3d 00 90 10 80 00 	cmpl   $0x0,0x80109000
80103251:	75 02                	jne    80103255 <forkret+0x1e>
80103253:	c9                   	leave  
80103254:	c3                   	ret    
80103255:	c7 05 00 90 10 80 00 	movl   $0x0,0x80109000
8010325c:	00 00 00 
8010325f:	83 ec 0c             	sub    $0xc,%esp
80103262:	6a 01                	push   $0x1
80103264:	e8 8f e0 ff ff       	call   801012f8 <iinit>
80103269:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103270:	e8 f2 f5 ff ff       	call   80102867 <initlog>
80103275:	83 c4 10             	add    $0x10,%esp
80103278:	eb d9                	jmp    80103253 <forkret+0x1c>

8010327a <pinit>:
8010327a:	55                   	push   %ebp
8010327b:	89 e5                	mov    %esp,%ebp
8010327d:	83 ec 10             	sub    $0x10,%esp
80103280:	68 35 6b 10 80       	push   $0x80106b35
80103285:	68 40 1d 12 80       	push   $0x80121d40
8010328a:	e8 e2 08 00 00       	call   80103b71 <initlock>
8010328f:	83 c4 10             	add    $0x10,%esp
80103292:	c9                   	leave  
80103293:	c3                   	ret    

80103294 <mycpu>:
80103294:	55                   	push   %ebp
80103295:	89 e5                	mov    %esp,%ebp
80103297:	83 ec 08             	sub    $0x8,%esp
8010329a:	9c                   	pushf  
8010329b:	58                   	pop    %eax
8010329c:	f6 c4 02             	test   $0x2,%ah
8010329f:	75 28                	jne    801032c9 <mycpu+0x35>
801032a1:	e8 da f1 ff ff       	call   80102480 <lapicid>
801032a6:	ba 00 00 00 00       	mov    $0x0,%edx
801032ab:	39 15 20 1d 12 80    	cmp    %edx,0x80121d20
801032b1:	7e 23                	jle    801032d6 <mycpu+0x42>
801032b3:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801032b9:	0f b6 89 a0 17 12 80 	movzbl -0x7fede860(%ecx),%ecx
801032c0:	39 c1                	cmp    %eax,%ecx
801032c2:	74 1f                	je     801032e3 <mycpu+0x4f>
801032c4:	83 c2 01             	add    $0x1,%edx
801032c7:	eb e2                	jmp    801032ab <mycpu+0x17>
801032c9:	83 ec 0c             	sub    $0xc,%esp
801032cc:	68 18 6c 10 80       	push   $0x80106c18
801032d1:	e8 72 d0 ff ff       	call   80100348 <panic>
801032d6:	83 ec 0c             	sub    $0xc,%esp
801032d9:	68 3c 6b 10 80       	push   $0x80106b3c
801032de:	e8 65 d0 ff ff       	call   80100348 <panic>
801032e3:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801032e9:	05 a0 17 12 80       	add    $0x801217a0,%eax
801032ee:	c9                   	leave  
801032ef:	c3                   	ret    

801032f0 <cpuid>:
801032f0:	55                   	push   %ebp
801032f1:	89 e5                	mov    %esp,%ebp
801032f3:	83 ec 08             	sub    $0x8,%esp
801032f6:	e8 99 ff ff ff       	call   80103294 <mycpu>
801032fb:	2d a0 17 12 80       	sub    $0x801217a0,%eax
80103300:	c1 f8 04             	sar    $0x4,%eax
80103303:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
80103309:	c9                   	leave  
8010330a:	c3                   	ret    

8010330b <myproc>:
8010330b:	55                   	push   %ebp
8010330c:	89 e5                	mov    %esp,%ebp
8010330e:	53                   	push   %ebx
8010330f:	83 ec 04             	sub    $0x4,%esp
80103312:	e8 b9 08 00 00       	call   80103bd0 <pushcli>
80103317:	e8 78 ff ff ff       	call   80103294 <mycpu>
8010331c:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
80103322:	e8 e6 08 00 00       	call   80103c0d <popcli>
80103327:	89 d8                	mov    %ebx,%eax
80103329:	83 c4 04             	add    $0x4,%esp
8010332c:	5b                   	pop    %ebx
8010332d:	5d                   	pop    %ebp
8010332e:	c3                   	ret    

8010332f <userinit>:
8010332f:	55                   	push   %ebp
80103330:	89 e5                	mov    %esp,%ebp
80103332:	53                   	push   %ebx
80103333:	83 ec 04             	sub    $0x4,%esp
80103336:	e8 35 fe ff ff       	call   80103170 <allocproc>
8010333b:	89 c3                	mov    %eax,%ebx
8010333d:	a3 c4 95 11 80       	mov    %eax,0x801195c4
80103342:	e8 22 30 00 00       	call   80106369 <setupkvm>
80103347:	89 43 04             	mov    %eax,0x4(%ebx)
8010334a:	85 c0                	test   %eax,%eax
8010334c:	0f 84 b7 00 00 00    	je     80103409 <userinit+0xda>
80103352:	83 ec 04             	sub    $0x4,%esp
80103355:	68 2c 00 00 00       	push   $0x2c
8010335a:	68 60 94 10 80       	push   $0x80109460
8010335f:	50                   	push   %eax
80103360:	e8 01 2d 00 00       	call   80106066 <inituvm>
80103365:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
8010336b:	83 c4 0c             	add    $0xc,%esp
8010336e:	6a 4c                	push   $0x4c
80103370:	6a 00                	push   $0x0
80103372:	ff 73 18             	pushl  0x18(%ebx)
80103375:	e8 df 09 00 00       	call   80103d59 <memset>
8010337a:	8b 43 18             	mov    0x18(%ebx),%eax
8010337d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
80103383:	8b 43 18             	mov    0x18(%ebx),%eax
80103386:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
8010338c:	8b 43 18             	mov    0x18(%ebx),%eax
8010338f:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103393:	66 89 50 28          	mov    %dx,0x28(%eax)
80103397:	8b 43 18             	mov    0x18(%ebx),%eax
8010339a:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010339e:	66 89 50 48          	mov    %dx,0x48(%eax)
801033a2:	8b 43 18             	mov    0x18(%ebx),%eax
801033a5:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
801033ac:	8b 43 18             	mov    0x18(%ebx),%eax
801033af:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
801033b6:	8b 43 18             	mov    0x18(%ebx),%eax
801033b9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
801033c0:	8d 43 6c             	lea    0x6c(%ebx),%eax
801033c3:	83 c4 0c             	add    $0xc,%esp
801033c6:	6a 10                	push   $0x10
801033c8:	68 65 6b 10 80       	push   $0x80106b65
801033cd:	50                   	push   %eax
801033ce:	e8 ed 0a 00 00       	call   80103ec0 <safestrcpy>
801033d3:	c7 04 24 6e 6b 10 80 	movl   $0x80106b6e,(%esp)
801033da:	e8 0e e8 ff ff       	call   80101bed <namei>
801033df:	89 43 68             	mov    %eax,0x68(%ebx)
801033e2:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
801033e9:	e8 bf 08 00 00       	call   80103cad <acquire>
801033ee:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
801033f5:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
801033fc:	e8 11 09 00 00       	call   80103d12 <release>
80103401:	83 c4 10             	add    $0x10,%esp
80103404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103407:	c9                   	leave  
80103408:	c3                   	ret    
80103409:	83 ec 0c             	sub    $0xc,%esp
8010340c:	68 4c 6b 10 80       	push   $0x80106b4c
80103411:	e8 32 cf ff ff       	call   80100348 <panic>

80103416 <growproc>:
80103416:	55                   	push   %ebp
80103417:	89 e5                	mov    %esp,%ebp
80103419:	56                   	push   %esi
8010341a:	53                   	push   %ebx
8010341b:	8b 75 08             	mov    0x8(%ebp),%esi
8010341e:	e8 e8 fe ff ff       	call   8010330b <myproc>
80103423:	89 c3                	mov    %eax,%ebx
80103425:	8b 00                	mov    (%eax),%eax
80103427:	85 f6                	test   %esi,%esi
80103429:	7f 21                	jg     8010344c <growproc+0x36>
8010342b:	85 f6                	test   %esi,%esi
8010342d:	79 33                	jns    80103462 <growproc+0x4c>
8010342f:	83 ec 04             	sub    $0x4,%esp
80103432:	01 c6                	add    %eax,%esi
80103434:	56                   	push   %esi
80103435:	50                   	push   %eax
80103436:	ff 73 04             	pushl  0x4(%ebx)
80103439:	e8 36 2d 00 00       	call   80106174 <deallocuvm>
8010343e:	83 c4 10             	add    $0x10,%esp
80103441:	85 c0                	test   %eax,%eax
80103443:	75 1d                	jne    80103462 <growproc+0x4c>
80103445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010344a:	eb 29                	jmp    80103475 <growproc+0x5f>
8010344c:	ff 73 10             	pushl  0x10(%ebx)
8010344f:	01 c6                	add    %eax,%esi
80103451:	56                   	push   %esi
80103452:	50                   	push   %eax
80103453:	ff 73 04             	pushl  0x4(%ebx)
80103456:	e8 ab 2d 00 00       	call   80106206 <allocuvm>
8010345b:	83 c4 10             	add    $0x10,%esp
8010345e:	85 c0                	test   %eax,%eax
80103460:	74 1a                	je     8010347c <growproc+0x66>
80103462:	89 03                	mov    %eax,(%ebx)
80103464:	83 ec 0c             	sub    $0xc,%esp
80103467:	53                   	push   %ebx
80103468:	e8 e1 2a 00 00       	call   80105f4e <switchuvm>
8010346d:	83 c4 10             	add    $0x10,%esp
80103470:	b8 00 00 00 00       	mov    $0x0,%eax
80103475:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103478:	5b                   	pop    %ebx
80103479:	5e                   	pop    %esi
8010347a:	5d                   	pop    %ebp
8010347b:	c3                   	ret    
8010347c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103481:	eb f2                	jmp    80103475 <growproc+0x5f>

80103483 <fork>:
80103483:	55                   	push   %ebp
80103484:	89 e5                	mov    %esp,%ebp
80103486:	57                   	push   %edi
80103487:	56                   	push   %esi
80103488:	53                   	push   %ebx
80103489:	83 ec 1c             	sub    $0x1c,%esp
8010348c:	e8 7a fe ff ff       	call   8010330b <myproc>
80103491:	89 c3                	mov    %eax,%ebx
80103493:	e8 d8 fc ff ff       	call   80103170 <allocproc>
80103498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010349b:	85 c0                	test   %eax,%eax
8010349d:	0f 84 e3 00 00 00    	je     80103586 <fork+0x103>
801034a3:	89 c7                	mov    %eax,%edi
801034a5:	83 ec 04             	sub    $0x4,%esp
801034a8:	ff 70 10             	pushl  0x10(%eax)
801034ab:	ff 33                	pushl  (%ebx)
801034ad:	ff 73 04             	pushl  0x4(%ebx)
801034b0:	e8 6d 2f 00 00       	call   80106422 <copyuvm>
801034b5:	89 47 04             	mov    %eax,0x4(%edi)
801034b8:	83 c4 10             	add    $0x10,%esp
801034bb:	85 c0                	test   %eax,%eax
801034bd:	74 2a                	je     801034e9 <fork+0x66>
801034bf:	8b 03                	mov    (%ebx),%eax
801034c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801034c4:	89 01                	mov    %eax,(%ecx)
801034c6:	89 c8                	mov    %ecx,%eax
801034c8:	89 59 14             	mov    %ebx,0x14(%ecx)
801034cb:	8b 73 18             	mov    0x18(%ebx),%esi
801034ce:	8b 79 18             	mov    0x18(%ecx),%edi
801034d1:	b9 13 00 00 00       	mov    $0x13,%ecx
801034d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
801034d8:	8b 40 18             	mov    0x18(%eax),%eax
801034db:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
801034e2:	be 00 00 00 00       	mov    $0x0,%esi
801034e7:	eb 29                	jmp    80103512 <fork+0x8f>
801034e9:	83 ec 0c             	sub    $0xc,%esp
801034ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801034ef:	ff 73 08             	pushl  0x8(%ebx)
801034f2:	e8 b9 ea ff ff       	call   80101fb0 <kfree>
801034f7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
801034fe:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
80103505:	83 c4 10             	add    $0x10,%esp
80103508:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010350d:	eb 6d                	jmp    8010357c <fork+0xf9>
8010350f:	83 c6 01             	add    $0x1,%esi
80103512:	83 fe 0f             	cmp    $0xf,%esi
80103515:	7f 1d                	jg     80103534 <fork+0xb1>
80103517:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010351b:	85 c0                	test   %eax,%eax
8010351d:	74 f0                	je     8010350f <fork+0x8c>
8010351f:	83 ec 0c             	sub    $0xc,%esp
80103522:	50                   	push   %eax
80103523:	e8 72 d7 ff ff       	call   80100c9a <filedup>
80103528:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010352b:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
8010352f:	83 c4 10             	add    $0x10,%esp
80103532:	eb db                	jmp    8010350f <fork+0x8c>
80103534:	83 ec 0c             	sub    $0xc,%esp
80103537:	ff 73 68             	pushl  0x68(%ebx)
8010353a:	e8 1e e0 ff ff       	call   8010155d <idup>
8010353f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103542:	89 47 68             	mov    %eax,0x68(%edi)
80103545:	83 c3 6c             	add    $0x6c,%ebx
80103548:	8d 47 6c             	lea    0x6c(%edi),%eax
8010354b:	83 c4 0c             	add    $0xc,%esp
8010354e:	6a 10                	push   $0x10
80103550:	53                   	push   %ebx
80103551:	50                   	push   %eax
80103552:	e8 69 09 00 00       	call   80103ec0 <safestrcpy>
80103557:	8b 5f 10             	mov    0x10(%edi),%ebx
8010355a:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
80103561:	e8 47 07 00 00       	call   80103cad <acquire>
80103566:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
8010356d:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
80103574:	e8 99 07 00 00       	call   80103d12 <release>
80103579:	83 c4 10             	add    $0x10,%esp
8010357c:	89 d8                	mov    %ebx,%eax
8010357e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103581:	5b                   	pop    %ebx
80103582:	5e                   	pop    %esi
80103583:	5f                   	pop    %edi
80103584:	5d                   	pop    %ebp
80103585:	c3                   	ret    
80103586:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010358b:	eb ef                	jmp    8010357c <fork+0xf9>

8010358d <scheduler>:
8010358d:	55                   	push   %ebp
8010358e:	89 e5                	mov    %esp,%ebp
80103590:	56                   	push   %esi
80103591:	53                   	push   %ebx
80103592:	e8 fd fc ff ff       	call   80103294 <mycpu>
80103597:	89 c6                	mov    %eax,%esi
80103599:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801035a0:	00 00 00 
801035a3:	eb 5a                	jmp    801035ff <scheduler+0x72>
801035a5:	83 c3 7c             	add    $0x7c,%ebx
801035a8:	81 fb 74 3c 12 80    	cmp    $0x80123c74,%ebx
801035ae:	73 3f                	jae    801035ef <scheduler+0x62>
801035b0:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035b4:	75 ef                	jne    801035a5 <scheduler+0x18>
801035b6:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
801035bc:	83 ec 0c             	sub    $0xc,%esp
801035bf:	53                   	push   %ebx
801035c0:	e8 89 29 00 00       	call   80105f4e <switchuvm>
801035c5:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
801035cc:	83 c4 08             	add    $0x8,%esp
801035cf:	ff 73 1c             	pushl  0x1c(%ebx)
801035d2:	8d 46 04             	lea    0x4(%esi),%eax
801035d5:	50                   	push   %eax
801035d6:	e8 38 09 00 00       	call   80103f13 <swtch>
801035db:	e8 5c 29 00 00       	call   80105f3c <switchkvm>
801035e0:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035e7:	00 00 00 
801035ea:	83 c4 10             	add    $0x10,%esp
801035ed:	eb b6                	jmp    801035a5 <scheduler+0x18>
801035ef:	83 ec 0c             	sub    $0xc,%esp
801035f2:	68 40 1d 12 80       	push   $0x80121d40
801035f7:	e8 16 07 00 00       	call   80103d12 <release>
801035fc:	83 c4 10             	add    $0x10,%esp
801035ff:	fb                   	sti    
80103600:	83 ec 0c             	sub    $0xc,%esp
80103603:	68 40 1d 12 80       	push   $0x80121d40
80103608:	e8 a0 06 00 00       	call   80103cad <acquire>
8010360d:	83 c4 10             	add    $0x10,%esp
80103610:	bb 74 1d 12 80       	mov    $0x80121d74,%ebx
80103615:	eb 91                	jmp    801035a8 <scheduler+0x1b>

80103617 <sched>:
80103617:	55                   	push   %ebp
80103618:	89 e5                	mov    %esp,%ebp
8010361a:	56                   	push   %esi
8010361b:	53                   	push   %ebx
8010361c:	e8 ea fc ff ff       	call   8010330b <myproc>
80103621:	89 c3                	mov    %eax,%ebx
80103623:	83 ec 0c             	sub    $0xc,%esp
80103626:	68 40 1d 12 80       	push   $0x80121d40
8010362b:	e8 3d 06 00 00       	call   80103c6d <holding>
80103630:	83 c4 10             	add    $0x10,%esp
80103633:	85 c0                	test   %eax,%eax
80103635:	74 4f                	je     80103686 <sched+0x6f>
80103637:	e8 58 fc ff ff       	call   80103294 <mycpu>
8010363c:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103643:	75 4e                	jne    80103693 <sched+0x7c>
80103645:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103649:	74 55                	je     801036a0 <sched+0x89>
8010364b:	9c                   	pushf  
8010364c:	58                   	pop    %eax
8010364d:	f6 c4 02             	test   $0x2,%ah
80103650:	75 5b                	jne    801036ad <sched+0x96>
80103652:	e8 3d fc ff ff       	call   80103294 <mycpu>
80103657:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
8010365d:	e8 32 fc ff ff       	call   80103294 <mycpu>
80103662:	83 ec 08             	sub    $0x8,%esp
80103665:	ff 70 04             	pushl  0x4(%eax)
80103668:	83 c3 1c             	add    $0x1c,%ebx
8010366b:	53                   	push   %ebx
8010366c:	e8 a2 08 00 00       	call   80103f13 <swtch>
80103671:	e8 1e fc ff ff       	call   80103294 <mycpu>
80103676:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
8010367c:	83 c4 10             	add    $0x10,%esp
8010367f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103682:	5b                   	pop    %ebx
80103683:	5e                   	pop    %esi
80103684:	5d                   	pop    %ebp
80103685:	c3                   	ret    
80103686:	83 ec 0c             	sub    $0xc,%esp
80103689:	68 70 6b 10 80       	push   $0x80106b70
8010368e:	e8 b5 cc ff ff       	call   80100348 <panic>
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	68 82 6b 10 80       	push   $0x80106b82
8010369b:	e8 a8 cc ff ff       	call   80100348 <panic>
801036a0:	83 ec 0c             	sub    $0xc,%esp
801036a3:	68 8e 6b 10 80       	push   $0x80106b8e
801036a8:	e8 9b cc ff ff       	call   80100348 <panic>
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	68 9c 6b 10 80       	push   $0x80106b9c
801036b5:	e8 8e cc ff ff       	call   80100348 <panic>

801036ba <exit>:
801036ba:	55                   	push   %ebp
801036bb:	89 e5                	mov    %esp,%ebp
801036bd:	56                   	push   %esi
801036be:	53                   	push   %ebx
801036bf:	e8 47 fc ff ff       	call   8010330b <myproc>
801036c4:	39 05 c4 95 11 80    	cmp    %eax,0x801195c4
801036ca:	74 09                	je     801036d5 <exit+0x1b>
801036cc:	89 c6                	mov    %eax,%esi
801036ce:	bb 00 00 00 00       	mov    $0x0,%ebx
801036d3:	eb 10                	jmp    801036e5 <exit+0x2b>
801036d5:	83 ec 0c             	sub    $0xc,%esp
801036d8:	68 b0 6b 10 80       	push   $0x80106bb0
801036dd:	e8 66 cc ff ff       	call   80100348 <panic>
801036e2:	83 c3 01             	add    $0x1,%ebx
801036e5:	83 fb 0f             	cmp    $0xf,%ebx
801036e8:	7f 1e                	jg     80103708 <exit+0x4e>
801036ea:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801036ee:	85 c0                	test   %eax,%eax
801036f0:	74 f0                	je     801036e2 <exit+0x28>
801036f2:	83 ec 0c             	sub    $0xc,%esp
801036f5:	50                   	push   %eax
801036f6:	e8 e4 d5 ff ff       	call   80100cdf <fileclose>
801036fb:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103702:	00 
80103703:	83 c4 10             	add    $0x10,%esp
80103706:	eb da                	jmp    801036e2 <exit+0x28>
80103708:	e8 a3 f1 ff ff       	call   801028b0 <begin_op>
8010370d:	83 ec 0c             	sub    $0xc,%esp
80103710:	ff 76 68             	pushl  0x68(%esi)
80103713:	e8 7c df ff ff       	call   80101694 <iput>
80103718:	e8 0d f2 ff ff       	call   8010292a <end_op>
8010371d:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
80103724:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
8010372b:	e8 7d 05 00 00       	call   80103cad <acquire>
80103730:	8b 46 14             	mov    0x14(%esi),%eax
80103733:	e8 0d fa ff ff       	call   80103145 <wakeup1>
80103738:	83 c4 10             	add    $0x10,%esp
8010373b:	bb 74 1d 12 80       	mov    $0x80121d74,%ebx
80103740:	eb 03                	jmp    80103745 <exit+0x8b>
80103742:	83 c3 7c             	add    $0x7c,%ebx
80103745:	81 fb 74 3c 12 80    	cmp    $0x80123c74,%ebx
8010374b:	73 1a                	jae    80103767 <exit+0xad>
8010374d:	39 73 14             	cmp    %esi,0x14(%ebx)
80103750:	75 f0                	jne    80103742 <exit+0x88>
80103752:	a1 c4 95 11 80       	mov    0x801195c4,%eax
80103757:	89 43 14             	mov    %eax,0x14(%ebx)
8010375a:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010375e:	75 e2                	jne    80103742 <exit+0x88>
80103760:	e8 e0 f9 ff ff       	call   80103145 <wakeup1>
80103765:	eb db                	jmp    80103742 <exit+0x88>
80103767:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
8010376e:	e8 a4 fe ff ff       	call   80103617 <sched>
80103773:	83 ec 0c             	sub    $0xc,%esp
80103776:	68 bd 6b 10 80       	push   $0x80106bbd
8010377b:	e8 c8 cb ff ff       	call   80100348 <panic>

80103780 <yield>:
80103780:	55                   	push   %ebp
80103781:	89 e5                	mov    %esp,%ebp
80103783:	83 ec 14             	sub    $0x14,%esp
80103786:	68 40 1d 12 80       	push   $0x80121d40
8010378b:	e8 1d 05 00 00       	call   80103cad <acquire>
80103790:	e8 76 fb ff ff       	call   8010330b <myproc>
80103795:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
8010379c:	e8 76 fe ff ff       	call   80103617 <sched>
801037a1:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
801037a8:	e8 65 05 00 00       	call   80103d12 <release>
801037ad:	83 c4 10             	add    $0x10,%esp
801037b0:	c9                   	leave  
801037b1:	c3                   	ret    

801037b2 <sleep>:
801037b2:	55                   	push   %ebp
801037b3:	89 e5                	mov    %esp,%ebp
801037b5:	56                   	push   %esi
801037b6:	53                   	push   %ebx
801037b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801037ba:	e8 4c fb ff ff       	call   8010330b <myproc>
801037bf:	85 c0                	test   %eax,%eax
801037c1:	74 66                	je     80103829 <sleep+0x77>
801037c3:	89 c6                	mov    %eax,%esi
801037c5:	85 db                	test   %ebx,%ebx
801037c7:	74 6d                	je     80103836 <sleep+0x84>
801037c9:	81 fb 40 1d 12 80    	cmp    $0x80121d40,%ebx
801037cf:	74 18                	je     801037e9 <sleep+0x37>
801037d1:	83 ec 0c             	sub    $0xc,%esp
801037d4:	68 40 1d 12 80       	push   $0x80121d40
801037d9:	e8 cf 04 00 00       	call   80103cad <acquire>
801037de:	89 1c 24             	mov    %ebx,(%esp)
801037e1:	e8 2c 05 00 00       	call   80103d12 <release>
801037e6:	83 c4 10             	add    $0x10,%esp
801037e9:	8b 45 08             	mov    0x8(%ebp),%eax
801037ec:	89 46 20             	mov    %eax,0x20(%esi)
801037ef:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
801037f6:	e8 1c fe ff ff       	call   80103617 <sched>
801037fb:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
80103802:	81 fb 40 1d 12 80    	cmp    $0x80121d40,%ebx
80103808:	74 18                	je     80103822 <sleep+0x70>
8010380a:	83 ec 0c             	sub    $0xc,%esp
8010380d:	68 40 1d 12 80       	push   $0x80121d40
80103812:	e8 fb 04 00 00       	call   80103d12 <release>
80103817:	89 1c 24             	mov    %ebx,(%esp)
8010381a:	e8 8e 04 00 00       	call   80103cad <acquire>
8010381f:	83 c4 10             	add    $0x10,%esp
80103822:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103825:	5b                   	pop    %ebx
80103826:	5e                   	pop    %esi
80103827:	5d                   	pop    %ebp
80103828:	c3                   	ret    
80103829:	83 ec 0c             	sub    $0xc,%esp
8010382c:	68 c9 6b 10 80       	push   $0x80106bc9
80103831:	e8 12 cb ff ff       	call   80100348 <panic>
80103836:	83 ec 0c             	sub    $0xc,%esp
80103839:	68 cf 6b 10 80       	push   $0x80106bcf
8010383e:	e8 05 cb ff ff       	call   80100348 <panic>

80103843 <wait>:
80103843:	55                   	push   %ebp
80103844:	89 e5                	mov    %esp,%ebp
80103846:	56                   	push   %esi
80103847:	53                   	push   %ebx
80103848:	e8 be fa ff ff       	call   8010330b <myproc>
8010384d:	89 c6                	mov    %eax,%esi
8010384f:	83 ec 0c             	sub    $0xc,%esp
80103852:	68 40 1d 12 80       	push   $0x80121d40
80103857:	e8 51 04 00 00       	call   80103cad <acquire>
8010385c:	83 c4 10             	add    $0x10,%esp
8010385f:	b8 00 00 00 00       	mov    $0x0,%eax
80103864:	bb 74 1d 12 80       	mov    $0x80121d74,%ebx
80103869:	eb 5b                	jmp    801038c6 <wait+0x83>
8010386b:	8b 73 10             	mov    0x10(%ebx),%esi
8010386e:	83 ec 0c             	sub    $0xc,%esp
80103871:	ff 73 08             	pushl  0x8(%ebx)
80103874:	e8 37 e7 ff ff       	call   80101fb0 <kfree>
80103879:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
80103880:	83 c4 04             	add    $0x4,%esp
80103883:	ff 73 04             	pushl  0x4(%ebx)
80103886:	e8 6e 2a 00 00       	call   801062f9 <freevm>
8010388b:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
80103892:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
80103899:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
8010389d:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
801038a4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
801038ab:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
801038b2:	e8 5b 04 00 00       	call   80103d12 <release>
801038b7:	83 c4 10             	add    $0x10,%esp
801038ba:	89 f0                	mov    %esi,%eax
801038bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038bf:	5b                   	pop    %ebx
801038c0:	5e                   	pop    %esi
801038c1:	5d                   	pop    %ebp
801038c2:	c3                   	ret    
801038c3:	83 c3 7c             	add    $0x7c,%ebx
801038c6:	81 fb 74 3c 12 80    	cmp    $0x80123c74,%ebx
801038cc:	73 12                	jae    801038e0 <wait+0x9d>
801038ce:	39 73 14             	cmp    %esi,0x14(%ebx)
801038d1:	75 f0                	jne    801038c3 <wait+0x80>
801038d3:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801038d7:	74 92                	je     8010386b <wait+0x28>
801038d9:	b8 01 00 00 00       	mov    $0x1,%eax
801038de:	eb e3                	jmp    801038c3 <wait+0x80>
801038e0:	85 c0                	test   %eax,%eax
801038e2:	74 06                	je     801038ea <wait+0xa7>
801038e4:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801038e8:	74 17                	je     80103901 <wait+0xbe>
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	68 40 1d 12 80       	push   $0x80121d40
801038f2:	e8 1b 04 00 00       	call   80103d12 <release>
801038f7:	83 c4 10             	add    $0x10,%esp
801038fa:	be ff ff ff ff       	mov    $0xffffffff,%esi
801038ff:	eb b9                	jmp    801038ba <wait+0x77>
80103901:	83 ec 08             	sub    $0x8,%esp
80103904:	68 40 1d 12 80       	push   $0x80121d40
80103909:	56                   	push   %esi
8010390a:	e8 a3 fe ff ff       	call   801037b2 <sleep>
8010390f:	83 c4 10             	add    $0x10,%esp
80103912:	e9 48 ff ff ff       	jmp    8010385f <wait+0x1c>

80103917 <wakeup>:
80103917:	55                   	push   %ebp
80103918:	89 e5                	mov    %esp,%ebp
8010391a:	83 ec 14             	sub    $0x14,%esp
8010391d:	68 40 1d 12 80       	push   $0x80121d40
80103922:	e8 86 03 00 00       	call   80103cad <acquire>
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	e8 16 f8 ff ff       	call   80103145 <wakeup1>
8010392f:	c7 04 24 40 1d 12 80 	movl   $0x80121d40,(%esp)
80103936:	e8 d7 03 00 00       	call   80103d12 <release>
8010393b:	83 c4 10             	add    $0x10,%esp
8010393e:	c9                   	leave  
8010393f:	c3                   	ret    

80103940 <kill>:
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
80103943:	53                   	push   %ebx
80103944:	83 ec 10             	sub    $0x10,%esp
80103947:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010394a:	68 40 1d 12 80       	push   $0x80121d40
8010394f:	e8 59 03 00 00       	call   80103cad <acquire>
80103954:	83 c4 10             	add    $0x10,%esp
80103957:	b8 74 1d 12 80       	mov    $0x80121d74,%eax
8010395c:	3d 74 3c 12 80       	cmp    $0x80123c74,%eax
80103961:	73 3a                	jae    8010399d <kill+0x5d>
80103963:	39 58 10             	cmp    %ebx,0x10(%eax)
80103966:	74 05                	je     8010396d <kill+0x2d>
80103968:	83 c0 7c             	add    $0x7c,%eax
8010396b:	eb ef                	jmp    8010395c <kill+0x1c>
8010396d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80103974:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103978:	74 1a                	je     80103994 <kill+0x54>
8010397a:	83 ec 0c             	sub    $0xc,%esp
8010397d:	68 40 1d 12 80       	push   $0x80121d40
80103982:	e8 8b 03 00 00       	call   80103d12 <release>
80103987:	83 c4 10             	add    $0x10,%esp
8010398a:	b8 00 00 00 00       	mov    $0x0,%eax
8010398f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103992:	c9                   	leave  
80103993:	c3                   	ret    
80103994:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
8010399b:	eb dd                	jmp    8010397a <kill+0x3a>
8010399d:	83 ec 0c             	sub    $0xc,%esp
801039a0:	68 40 1d 12 80       	push   $0x80121d40
801039a5:	e8 68 03 00 00       	call   80103d12 <release>
801039aa:	83 c4 10             	add    $0x10,%esp
801039ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039b2:	eb db                	jmp    8010398f <kill+0x4f>

801039b4 <procdump>:
801039b4:	55                   	push   %ebp
801039b5:	89 e5                	mov    %esp,%ebp
801039b7:	56                   	push   %esi
801039b8:	53                   	push   %ebx
801039b9:	83 ec 30             	sub    $0x30,%esp
801039bc:	bb 74 1d 12 80       	mov    $0x80121d74,%ebx
801039c1:	eb 33                	jmp    801039f6 <procdump+0x42>
801039c3:	b8 e0 6b 10 80       	mov    $0x80106be0,%eax
801039c8:	8d 53 6c             	lea    0x6c(%ebx),%edx
801039cb:	52                   	push   %edx
801039cc:	50                   	push   %eax
801039cd:	ff 73 10             	pushl  0x10(%ebx)
801039d0:	68 e4 6b 10 80       	push   $0x80106be4
801039d5:	e8 31 cc ff ff       	call   8010060b <cprintf>
801039da:	83 c4 10             	add    $0x10,%esp
801039dd:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801039e1:	74 39                	je     80103a1c <procdump+0x68>
801039e3:	83 ec 0c             	sub    $0xc,%esp
801039e6:	68 5b 6f 10 80       	push   $0x80106f5b
801039eb:	e8 1b cc ff ff       	call   8010060b <cprintf>
801039f0:	83 c4 10             	add    $0x10,%esp
801039f3:	83 c3 7c             	add    $0x7c,%ebx
801039f6:	81 fb 74 3c 12 80    	cmp    $0x80123c74,%ebx
801039fc:	73 61                	jae    80103a5f <procdump+0xab>
801039fe:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a01:	85 c0                	test   %eax,%eax
80103a03:	74 ee                	je     801039f3 <procdump+0x3f>
80103a05:	83 f8 05             	cmp    $0x5,%eax
80103a08:	77 b9                	ja     801039c3 <procdump+0xf>
80103a0a:	8b 04 85 40 6c 10 80 	mov    -0x7fef93c0(,%eax,4),%eax
80103a11:	85 c0                	test   %eax,%eax
80103a13:	75 b3                	jne    801039c8 <procdump+0x14>
80103a15:	b8 e0 6b 10 80       	mov    $0x80106be0,%eax
80103a1a:	eb ac                	jmp    801039c8 <procdump+0x14>
80103a1c:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a1f:	8b 40 0c             	mov    0xc(%eax),%eax
80103a22:	83 c0 08             	add    $0x8,%eax
80103a25:	83 ec 08             	sub    $0x8,%esp
80103a28:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a2b:	52                   	push   %edx
80103a2c:	50                   	push   %eax
80103a2d:	e8 5a 01 00 00       	call   80103b8c <getcallerpcs>
80103a32:	83 c4 10             	add    $0x10,%esp
80103a35:	be 00 00 00 00       	mov    $0x0,%esi
80103a3a:	eb 14                	jmp    80103a50 <procdump+0x9c>
80103a3c:	83 ec 08             	sub    $0x8,%esp
80103a3f:	50                   	push   %eax
80103a40:	68 21 66 10 80       	push   $0x80106621
80103a45:	e8 c1 cb ff ff       	call   8010060b <cprintf>
80103a4a:	83 c6 01             	add    $0x1,%esi
80103a4d:	83 c4 10             	add    $0x10,%esp
80103a50:	83 fe 09             	cmp    $0x9,%esi
80103a53:	7f 8e                	jg     801039e3 <procdump+0x2f>
80103a55:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a59:	85 c0                	test   %eax,%eax
80103a5b:	75 df                	jne    80103a3c <procdump+0x88>
80103a5d:	eb 84                	jmp    801039e3 <procdump+0x2f>
80103a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a62:	5b                   	pop    %ebx
80103a63:	5e                   	pop    %esi
80103a64:	5d                   	pop    %ebp
80103a65:	c3                   	ret    

80103a66 <initsleeplock>:
80103a66:	55                   	push   %ebp
80103a67:	89 e5                	mov    %esp,%ebp
80103a69:	53                   	push   %ebx
80103a6a:	83 ec 0c             	sub    $0xc,%esp
80103a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103a70:	68 58 6c 10 80       	push   $0x80106c58
80103a75:	8d 43 04             	lea    0x4(%ebx),%eax
80103a78:	50                   	push   %eax
80103a79:	e8 f3 00 00 00       	call   80103b71 <initlock>
80103a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a81:	89 43 38             	mov    %eax,0x38(%ebx)
80103a84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103a8a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
80103a91:	83 c4 10             	add    $0x10,%esp
80103a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a97:	c9                   	leave  
80103a98:	c3                   	ret    

80103a99 <acquiresleep>:
80103a99:	55                   	push   %ebp
80103a9a:	89 e5                	mov    %esp,%ebp
80103a9c:	56                   	push   %esi
80103a9d:	53                   	push   %ebx
80103a9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103aa1:	8d 73 04             	lea    0x4(%ebx),%esi
80103aa4:	83 ec 0c             	sub    $0xc,%esp
80103aa7:	56                   	push   %esi
80103aa8:	e8 00 02 00 00       	call   80103cad <acquire>
80103aad:	83 c4 10             	add    $0x10,%esp
80103ab0:	eb 0d                	jmp    80103abf <acquiresleep+0x26>
80103ab2:	83 ec 08             	sub    $0x8,%esp
80103ab5:	56                   	push   %esi
80103ab6:	53                   	push   %ebx
80103ab7:	e8 f6 fc ff ff       	call   801037b2 <sleep>
80103abc:	83 c4 10             	add    $0x10,%esp
80103abf:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ac2:	75 ee                	jne    80103ab2 <acquiresleep+0x19>
80103ac4:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
80103aca:	e8 3c f8 ff ff       	call   8010330b <myproc>
80103acf:	8b 40 10             	mov    0x10(%eax),%eax
80103ad2:	89 43 3c             	mov    %eax,0x3c(%ebx)
80103ad5:	83 ec 0c             	sub    $0xc,%esp
80103ad8:	56                   	push   %esi
80103ad9:	e8 34 02 00 00       	call   80103d12 <release>
80103ade:	83 c4 10             	add    $0x10,%esp
80103ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ae4:	5b                   	pop    %ebx
80103ae5:	5e                   	pop    %esi
80103ae6:	5d                   	pop    %ebp
80103ae7:	c3                   	ret    

80103ae8 <releasesleep>:
80103ae8:	55                   	push   %ebp
80103ae9:	89 e5                	mov    %esp,%ebp
80103aeb:	56                   	push   %esi
80103aec:	53                   	push   %ebx
80103aed:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103af0:	8d 73 04             	lea    0x4(%ebx),%esi
80103af3:	83 ec 0c             	sub    $0xc,%esp
80103af6:	56                   	push   %esi
80103af7:	e8 b1 01 00 00       	call   80103cad <acquire>
80103afc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103b02:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
80103b09:	89 1c 24             	mov    %ebx,(%esp)
80103b0c:	e8 06 fe ff ff       	call   80103917 <wakeup>
80103b11:	89 34 24             	mov    %esi,(%esp)
80103b14:	e8 f9 01 00 00       	call   80103d12 <release>
80103b19:	83 c4 10             	add    $0x10,%esp
80103b1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b1f:	5b                   	pop    %ebx
80103b20:	5e                   	pop    %esi
80103b21:	5d                   	pop    %ebp
80103b22:	c3                   	ret    

80103b23 <holdingsleep>:
80103b23:	55                   	push   %ebp
80103b24:	89 e5                	mov    %esp,%ebp
80103b26:	56                   	push   %esi
80103b27:	53                   	push   %ebx
80103b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103b2b:	8d 73 04             	lea    0x4(%ebx),%esi
80103b2e:	83 ec 0c             	sub    $0xc,%esp
80103b31:	56                   	push   %esi
80103b32:	e8 76 01 00 00       	call   80103cad <acquire>
80103b37:	83 c4 10             	add    $0x10,%esp
80103b3a:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b3d:	75 17                	jne    80103b56 <holdingsleep+0x33>
80103b3f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b44:	83 ec 0c             	sub    $0xc,%esp
80103b47:	56                   	push   %esi
80103b48:	e8 c5 01 00 00       	call   80103d12 <release>
80103b4d:	89 d8                	mov    %ebx,%eax
80103b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b52:	5b                   	pop    %ebx
80103b53:	5e                   	pop    %esi
80103b54:	5d                   	pop    %ebp
80103b55:	c3                   	ret    
80103b56:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103b59:	e8 ad f7 ff ff       	call   8010330b <myproc>
80103b5e:	3b 58 10             	cmp    0x10(%eax),%ebx
80103b61:	74 07                	je     80103b6a <holdingsleep+0x47>
80103b63:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b68:	eb da                	jmp    80103b44 <holdingsleep+0x21>
80103b6a:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b6f:	eb d3                	jmp    80103b44 <holdingsleep+0x21>

80103b71 <initlock>:
80103b71:	55                   	push   %ebp
80103b72:	89 e5                	mov    %esp,%ebp
80103b74:	8b 45 08             	mov    0x8(%ebp),%eax
80103b77:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b7a:	89 50 04             	mov    %edx,0x4(%eax)
80103b7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103b83:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
80103b8a:	5d                   	pop    %ebp
80103b8b:	c3                   	ret    

80103b8c <getcallerpcs>:
80103b8c:	55                   	push   %ebp
80103b8d:	89 e5                	mov    %esp,%ebp
80103b8f:	53                   	push   %ebx
80103b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103b93:	8b 45 08             	mov    0x8(%ebp),%eax
80103b96:	8d 50 f8             	lea    -0x8(%eax),%edx
80103b99:	b8 00 00 00 00       	mov    $0x0,%eax
80103b9e:	83 f8 09             	cmp    $0x9,%eax
80103ba1:	7f 25                	jg     80103bc8 <getcallerpcs+0x3c>
80103ba3:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103ba9:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103baf:	77 17                	ja     80103bc8 <getcallerpcs+0x3c>
80103bb1:	8b 5a 04             	mov    0x4(%edx),%ebx
80103bb4:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
80103bb7:	8b 12                	mov    (%edx),%edx
80103bb9:	83 c0 01             	add    $0x1,%eax
80103bbc:	eb e0                	jmp    80103b9e <getcallerpcs+0x12>
80103bbe:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
80103bc5:	83 c0 01             	add    $0x1,%eax
80103bc8:	83 f8 09             	cmp    $0x9,%eax
80103bcb:	7e f1                	jle    80103bbe <getcallerpcs+0x32>
80103bcd:	5b                   	pop    %ebx
80103bce:	5d                   	pop    %ebp
80103bcf:	c3                   	ret    

80103bd0 <pushcli>:
80103bd0:	55                   	push   %ebp
80103bd1:	89 e5                	mov    %esp,%ebp
80103bd3:	53                   	push   %ebx
80103bd4:	83 ec 04             	sub    $0x4,%esp
80103bd7:	9c                   	pushf  
80103bd8:	5b                   	pop    %ebx
80103bd9:	fa                   	cli    
80103bda:	e8 b5 f6 ff ff       	call   80103294 <mycpu>
80103bdf:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103be6:	74 12                	je     80103bfa <pushcli+0x2a>
80103be8:	e8 a7 f6 ff ff       	call   80103294 <mycpu>
80103bed:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
80103bf4:	83 c4 04             	add    $0x4,%esp
80103bf7:	5b                   	pop    %ebx
80103bf8:	5d                   	pop    %ebp
80103bf9:	c3                   	ret    
80103bfa:	e8 95 f6 ff ff       	call   80103294 <mycpu>
80103bff:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103c05:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103c0b:	eb db                	jmp    80103be8 <pushcli+0x18>

80103c0d <popcli>:
80103c0d:	55                   	push   %ebp
80103c0e:	89 e5                	mov    %esp,%ebp
80103c10:	83 ec 08             	sub    $0x8,%esp
80103c13:	9c                   	pushf  
80103c14:	58                   	pop    %eax
80103c15:	f6 c4 02             	test   $0x2,%ah
80103c18:	75 28                	jne    80103c42 <popcli+0x35>
80103c1a:	e8 75 f6 ff ff       	call   80103294 <mycpu>
80103c1f:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103c25:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103c28:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103c2e:	85 d2                	test   %edx,%edx
80103c30:	78 1d                	js     80103c4f <popcli+0x42>
80103c32:	e8 5d f6 ff ff       	call   80103294 <mycpu>
80103c37:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c3e:	74 1c                	je     80103c5c <popcli+0x4f>
80103c40:	c9                   	leave  
80103c41:	c3                   	ret    
80103c42:	83 ec 0c             	sub    $0xc,%esp
80103c45:	68 63 6c 10 80       	push   $0x80106c63
80103c4a:	e8 f9 c6 ff ff       	call   80100348 <panic>
80103c4f:	83 ec 0c             	sub    $0xc,%esp
80103c52:	68 7a 6c 10 80       	push   $0x80106c7a
80103c57:	e8 ec c6 ff ff       	call   80100348 <panic>
80103c5c:	e8 33 f6 ff ff       	call   80103294 <mycpu>
80103c61:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103c68:	74 d6                	je     80103c40 <popcli+0x33>
80103c6a:	fb                   	sti    
80103c6b:	eb d3                	jmp    80103c40 <popcli+0x33>

80103c6d <holding>:
80103c6d:	55                   	push   %ebp
80103c6e:	89 e5                	mov    %esp,%ebp
80103c70:	53                   	push   %ebx
80103c71:	83 ec 04             	sub    $0x4,%esp
80103c74:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c77:	e8 54 ff ff ff       	call   80103bd0 <pushcli>
80103c7c:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c7f:	75 12                	jne    80103c93 <holding+0x26>
80103c81:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c86:	e8 82 ff ff ff       	call   80103c0d <popcli>
80103c8b:	89 d8                	mov    %ebx,%eax
80103c8d:	83 c4 04             	add    $0x4,%esp
80103c90:	5b                   	pop    %ebx
80103c91:	5d                   	pop    %ebp
80103c92:	c3                   	ret    
80103c93:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103c96:	e8 f9 f5 ff ff       	call   80103294 <mycpu>
80103c9b:	39 c3                	cmp    %eax,%ebx
80103c9d:	74 07                	je     80103ca6 <holding+0x39>
80103c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103ca4:	eb e0                	jmp    80103c86 <holding+0x19>
80103ca6:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cab:	eb d9                	jmp    80103c86 <holding+0x19>

80103cad <acquire>:
80103cad:	55                   	push   %ebp
80103cae:	89 e5                	mov    %esp,%ebp
80103cb0:	53                   	push   %ebx
80103cb1:	83 ec 04             	sub    $0x4,%esp
80103cb4:	e8 17 ff ff ff       	call   80103bd0 <pushcli>
80103cb9:	83 ec 0c             	sub    $0xc,%esp
80103cbc:	ff 75 08             	pushl  0x8(%ebp)
80103cbf:	e8 a9 ff ff ff       	call   80103c6d <holding>
80103cc4:	83 c4 10             	add    $0x10,%esp
80103cc7:	85 c0                	test   %eax,%eax
80103cc9:	75 3a                	jne    80103d05 <acquire+0x58>
80103ccb:	8b 55 08             	mov    0x8(%ebp),%edx
80103cce:	b8 01 00 00 00       	mov    $0x1,%eax
80103cd3:	f0 87 02             	lock xchg %eax,(%edx)
80103cd6:	85 c0                	test   %eax,%eax
80103cd8:	75 f1                	jne    80103ccb <acquire+0x1e>
80103cda:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
80103cdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103ce2:	e8 ad f5 ff ff       	call   80103294 <mycpu>
80103ce7:	89 43 08             	mov    %eax,0x8(%ebx)
80103cea:	8b 45 08             	mov    0x8(%ebp),%eax
80103ced:	83 c0 0c             	add    $0xc,%eax
80103cf0:	83 ec 08             	sub    $0x8,%esp
80103cf3:	50                   	push   %eax
80103cf4:	8d 45 08             	lea    0x8(%ebp),%eax
80103cf7:	50                   	push   %eax
80103cf8:	e8 8f fe ff ff       	call   80103b8c <getcallerpcs>
80103cfd:	83 c4 10             	add    $0x10,%esp
80103d00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d03:	c9                   	leave  
80103d04:	c3                   	ret    
80103d05:	83 ec 0c             	sub    $0xc,%esp
80103d08:	68 81 6c 10 80       	push   $0x80106c81
80103d0d:	e8 36 c6 ff ff       	call   80100348 <panic>

80103d12 <release>:
80103d12:	55                   	push   %ebp
80103d13:	89 e5                	mov    %esp,%ebp
80103d15:	53                   	push   %ebx
80103d16:	83 ec 10             	sub    $0x10,%esp
80103d19:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d1c:	53                   	push   %ebx
80103d1d:	e8 4b ff ff ff       	call   80103c6d <holding>
80103d22:	83 c4 10             	add    $0x10,%esp
80103d25:	85 c0                	test   %eax,%eax
80103d27:	74 23                	je     80103d4c <release+0x3a>
80103d29:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
80103d30:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
80103d37:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
80103d3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103d42:	e8 c6 fe ff ff       	call   80103c0d <popcli>
80103d47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4a:	c9                   	leave  
80103d4b:	c3                   	ret    
80103d4c:	83 ec 0c             	sub    $0xc,%esp
80103d4f:	68 89 6c 10 80       	push   $0x80106c89
80103d54:	e8 ef c5 ff ff       	call   80100348 <panic>

80103d59 <memset>:
80103d59:	55                   	push   %ebp
80103d5a:	89 e5                	mov    %esp,%ebp
80103d5c:	57                   	push   %edi
80103d5d:	53                   	push   %ebx
80103d5e:	8b 55 08             	mov    0x8(%ebp),%edx
80103d61:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103d64:	f6 c2 03             	test   $0x3,%dl
80103d67:	75 05                	jne    80103d6e <memset+0x15>
80103d69:	f6 c1 03             	test   $0x3,%cl
80103d6c:	74 0e                	je     80103d7c <memset+0x23>
80103d6e:	89 d7                	mov    %edx,%edi
80103d70:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d73:	fc                   	cld    
80103d74:	f3 aa                	rep stos %al,%es:(%edi)
80103d76:	89 d0                	mov    %edx,%eax
80103d78:	5b                   	pop    %ebx
80103d79:	5f                   	pop    %edi
80103d7a:	5d                   	pop    %ebp
80103d7b:	c3                   	ret    
80103d7c:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
80103d80:	c1 e9 02             	shr    $0x2,%ecx
80103d83:	89 f8                	mov    %edi,%eax
80103d85:	c1 e0 18             	shl    $0x18,%eax
80103d88:	89 fb                	mov    %edi,%ebx
80103d8a:	c1 e3 10             	shl    $0x10,%ebx
80103d8d:	09 d8                	or     %ebx,%eax
80103d8f:	89 fb                	mov    %edi,%ebx
80103d91:	c1 e3 08             	shl    $0x8,%ebx
80103d94:	09 d8                	or     %ebx,%eax
80103d96:	09 f8                	or     %edi,%eax
80103d98:	89 d7                	mov    %edx,%edi
80103d9a:	fc                   	cld    
80103d9b:	f3 ab                	rep stos %eax,%es:(%edi)
80103d9d:	eb d7                	jmp    80103d76 <memset+0x1d>

80103d9f <memcmp>:
80103d9f:	55                   	push   %ebp
80103da0:	89 e5                	mov    %esp,%ebp
80103da2:	56                   	push   %esi
80103da3:	53                   	push   %ebx
80103da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103da7:	8b 55 0c             	mov    0xc(%ebp),%edx
80103daa:	8b 45 10             	mov    0x10(%ebp),%eax
80103dad:	8d 70 ff             	lea    -0x1(%eax),%esi
80103db0:	85 c0                	test   %eax,%eax
80103db2:	74 1c                	je     80103dd0 <memcmp+0x31>
80103db4:	0f b6 01             	movzbl (%ecx),%eax
80103db7:	0f b6 1a             	movzbl (%edx),%ebx
80103dba:	38 d8                	cmp    %bl,%al
80103dbc:	75 0a                	jne    80103dc8 <memcmp+0x29>
80103dbe:	83 c1 01             	add    $0x1,%ecx
80103dc1:	83 c2 01             	add    $0x1,%edx
80103dc4:	89 f0                	mov    %esi,%eax
80103dc6:	eb e5                	jmp    80103dad <memcmp+0xe>
80103dc8:	0f b6 c0             	movzbl %al,%eax
80103dcb:	0f b6 db             	movzbl %bl,%ebx
80103dce:	29 d8                	sub    %ebx,%eax
80103dd0:	5b                   	pop    %ebx
80103dd1:	5e                   	pop    %esi
80103dd2:	5d                   	pop    %ebp
80103dd3:	c3                   	ret    

80103dd4 <memmove>:
80103dd4:	55                   	push   %ebp
80103dd5:	89 e5                	mov    %esp,%ebp
80103dd7:	56                   	push   %esi
80103dd8:	53                   	push   %ebx
80103dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ddf:	8b 55 10             	mov    0x10(%ebp),%edx
80103de2:	39 c1                	cmp    %eax,%ecx
80103de4:	73 3a                	jae    80103e20 <memmove+0x4c>
80103de6:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103de9:	39 c3                	cmp    %eax,%ebx
80103deb:	76 37                	jbe    80103e24 <memmove+0x50>
80103ded:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80103df0:	eb 0d                	jmp    80103dff <memmove+0x2b>
80103df2:	83 eb 01             	sub    $0x1,%ebx
80103df5:	83 e9 01             	sub    $0x1,%ecx
80103df8:	0f b6 13             	movzbl (%ebx),%edx
80103dfb:	88 11                	mov    %dl,(%ecx)
80103dfd:	89 f2                	mov    %esi,%edx
80103dff:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e02:	85 d2                	test   %edx,%edx
80103e04:	75 ec                	jne    80103df2 <memmove+0x1e>
80103e06:	eb 14                	jmp    80103e1c <memmove+0x48>
80103e08:	0f b6 11             	movzbl (%ecx),%edx
80103e0b:	88 13                	mov    %dl,(%ebx)
80103e0d:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103e10:	8d 49 01             	lea    0x1(%ecx),%ecx
80103e13:	89 f2                	mov    %esi,%edx
80103e15:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e18:	85 d2                	test   %edx,%edx
80103e1a:	75 ec                	jne    80103e08 <memmove+0x34>
80103e1c:	5b                   	pop    %ebx
80103e1d:	5e                   	pop    %esi
80103e1e:	5d                   	pop    %ebp
80103e1f:	c3                   	ret    
80103e20:	89 c3                	mov    %eax,%ebx
80103e22:	eb f1                	jmp    80103e15 <memmove+0x41>
80103e24:	89 c3                	mov    %eax,%ebx
80103e26:	eb ed                	jmp    80103e15 <memmove+0x41>

80103e28 <memcpy>:
80103e28:	55                   	push   %ebp
80103e29:	89 e5                	mov    %esp,%ebp
80103e2b:	ff 75 10             	pushl  0x10(%ebp)
80103e2e:	ff 75 0c             	pushl  0xc(%ebp)
80103e31:	ff 75 08             	pushl  0x8(%ebp)
80103e34:	e8 9b ff ff ff       	call   80103dd4 <memmove>
80103e39:	c9                   	leave  
80103e3a:	c3                   	ret    

80103e3b <strncmp>:
80103e3b:	55                   	push   %ebp
80103e3c:	89 e5                	mov    %esp,%ebp
80103e3e:	53                   	push   %ebx
80103e3f:	8b 55 08             	mov    0x8(%ebp),%edx
80103e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e45:	8b 45 10             	mov    0x10(%ebp),%eax
80103e48:	eb 09                	jmp    80103e53 <strncmp+0x18>
80103e4a:	83 e8 01             	sub    $0x1,%eax
80103e4d:	83 c2 01             	add    $0x1,%edx
80103e50:	83 c1 01             	add    $0x1,%ecx
80103e53:	85 c0                	test   %eax,%eax
80103e55:	74 0b                	je     80103e62 <strncmp+0x27>
80103e57:	0f b6 1a             	movzbl (%edx),%ebx
80103e5a:	84 db                	test   %bl,%bl
80103e5c:	74 04                	je     80103e62 <strncmp+0x27>
80103e5e:	3a 19                	cmp    (%ecx),%bl
80103e60:	74 e8                	je     80103e4a <strncmp+0xf>
80103e62:	85 c0                	test   %eax,%eax
80103e64:	74 0b                	je     80103e71 <strncmp+0x36>
80103e66:	0f b6 02             	movzbl (%edx),%eax
80103e69:	0f b6 11             	movzbl (%ecx),%edx
80103e6c:	29 d0                	sub    %edx,%eax
80103e6e:	5b                   	pop    %ebx
80103e6f:	5d                   	pop    %ebp
80103e70:	c3                   	ret    
80103e71:	b8 00 00 00 00       	mov    $0x0,%eax
80103e76:	eb f6                	jmp    80103e6e <strncmp+0x33>

80103e78 <strncpy>:
80103e78:	55                   	push   %ebp
80103e79:	89 e5                	mov    %esp,%ebp
80103e7b:	57                   	push   %edi
80103e7c:	56                   	push   %esi
80103e7d:	53                   	push   %ebx
80103e7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103e81:	8b 4d 10             	mov    0x10(%ebp),%ecx
80103e84:	8b 45 08             	mov    0x8(%ebp),%eax
80103e87:	eb 04                	jmp    80103e8d <strncpy+0x15>
80103e89:	89 fb                	mov    %edi,%ebx
80103e8b:	89 f0                	mov    %esi,%eax
80103e8d:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e90:	85 c9                	test   %ecx,%ecx
80103e92:	7e 1d                	jle    80103eb1 <strncpy+0x39>
80103e94:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e97:	8d 70 01             	lea    0x1(%eax),%esi
80103e9a:	0f b6 1b             	movzbl (%ebx),%ebx
80103e9d:	88 18                	mov    %bl,(%eax)
80103e9f:	89 d1                	mov    %edx,%ecx
80103ea1:	84 db                	test   %bl,%bl
80103ea3:	75 e4                	jne    80103e89 <strncpy+0x11>
80103ea5:	89 f0                	mov    %esi,%eax
80103ea7:	eb 08                	jmp    80103eb1 <strncpy+0x39>
80103ea9:	c6 00 00             	movb   $0x0,(%eax)
80103eac:	89 ca                	mov    %ecx,%edx
80103eae:	8d 40 01             	lea    0x1(%eax),%eax
80103eb1:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103eb4:	85 d2                	test   %edx,%edx
80103eb6:	7f f1                	jg     80103ea9 <strncpy+0x31>
80103eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ebb:	5b                   	pop    %ebx
80103ebc:	5e                   	pop    %esi
80103ebd:	5f                   	pop    %edi
80103ebe:	5d                   	pop    %ebp
80103ebf:	c3                   	ret    

80103ec0 <safestrcpy>:
80103ec0:	55                   	push   %ebp
80103ec1:	89 e5                	mov    %esp,%ebp
80103ec3:	57                   	push   %edi
80103ec4:	56                   	push   %esi
80103ec5:	53                   	push   %ebx
80103ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103ecc:	8b 55 10             	mov    0x10(%ebp),%edx
80103ecf:	85 d2                	test   %edx,%edx
80103ed1:	7e 23                	jle    80103ef6 <safestrcpy+0x36>
80103ed3:	89 c1                	mov    %eax,%ecx
80103ed5:	eb 04                	jmp    80103edb <safestrcpy+0x1b>
80103ed7:	89 fb                	mov    %edi,%ebx
80103ed9:	89 f1                	mov    %esi,%ecx
80103edb:	83 ea 01             	sub    $0x1,%edx
80103ede:	85 d2                	test   %edx,%edx
80103ee0:	7e 11                	jle    80103ef3 <safestrcpy+0x33>
80103ee2:	8d 7b 01             	lea    0x1(%ebx),%edi
80103ee5:	8d 71 01             	lea    0x1(%ecx),%esi
80103ee8:	0f b6 1b             	movzbl (%ebx),%ebx
80103eeb:	88 19                	mov    %bl,(%ecx)
80103eed:	84 db                	test   %bl,%bl
80103eef:	75 e6                	jne    80103ed7 <safestrcpy+0x17>
80103ef1:	89 f1                	mov    %esi,%ecx
80103ef3:	c6 01 00             	movb   $0x0,(%ecx)
80103ef6:	5b                   	pop    %ebx
80103ef7:	5e                   	pop    %esi
80103ef8:	5f                   	pop    %edi
80103ef9:	5d                   	pop    %ebp
80103efa:	c3                   	ret    

80103efb <strlen>:
80103efb:	55                   	push   %ebp
80103efc:	89 e5                	mov    %esp,%ebp
80103efe:	8b 55 08             	mov    0x8(%ebp),%edx
80103f01:	b8 00 00 00 00       	mov    $0x0,%eax
80103f06:	eb 03                	jmp    80103f0b <strlen+0x10>
80103f08:	83 c0 01             	add    $0x1,%eax
80103f0b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103f0f:	75 f7                	jne    80103f08 <strlen+0xd>
80103f11:	5d                   	pop    %ebp
80103f12:	c3                   	ret    

80103f13 <swtch>:
80103f13:	8b 44 24 04          	mov    0x4(%esp),%eax
80103f17:	8b 54 24 08          	mov    0x8(%esp),%edx
80103f1b:	55                   	push   %ebp
80103f1c:	53                   	push   %ebx
80103f1d:	56                   	push   %esi
80103f1e:	57                   	push   %edi
80103f1f:	89 20                	mov    %esp,(%eax)
80103f21:	89 d4                	mov    %edx,%esp
80103f23:	5f                   	pop    %edi
80103f24:	5e                   	pop    %esi
80103f25:	5b                   	pop    %ebx
80103f26:	5d                   	pop    %ebp
80103f27:	c3                   	ret    

80103f28 <fetchint>:
80103f28:	55                   	push   %ebp
80103f29:	89 e5                	mov    %esp,%ebp
80103f2b:	53                   	push   %ebx
80103f2c:	83 ec 04             	sub    $0x4,%esp
80103f2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103f32:	e8 d4 f3 ff ff       	call   8010330b <myproc>
80103f37:	8b 00                	mov    (%eax),%eax
80103f39:	39 d8                	cmp    %ebx,%eax
80103f3b:	76 19                	jbe    80103f56 <fetchint+0x2e>
80103f3d:	8d 53 04             	lea    0x4(%ebx),%edx
80103f40:	39 d0                	cmp    %edx,%eax
80103f42:	72 19                	jb     80103f5d <fetchint+0x35>
80103f44:	8b 13                	mov    (%ebx),%edx
80103f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f49:	89 10                	mov    %edx,(%eax)
80103f4b:	b8 00 00 00 00       	mov    $0x0,%eax
80103f50:	83 c4 04             	add    $0x4,%esp
80103f53:	5b                   	pop    %ebx
80103f54:	5d                   	pop    %ebp
80103f55:	c3                   	ret    
80103f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f5b:	eb f3                	jmp    80103f50 <fetchint+0x28>
80103f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f62:	eb ec                	jmp    80103f50 <fetchint+0x28>

80103f64 <fetchstr>:
80103f64:	55                   	push   %ebp
80103f65:	89 e5                	mov    %esp,%ebp
80103f67:	53                   	push   %ebx
80103f68:	83 ec 04             	sub    $0x4,%esp
80103f6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103f6e:	e8 98 f3 ff ff       	call   8010330b <myproc>
80103f73:	39 18                	cmp    %ebx,(%eax)
80103f75:	76 26                	jbe    80103f9d <fetchstr+0x39>
80103f77:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f7a:	89 1a                	mov    %ebx,(%edx)
80103f7c:	8b 10                	mov    (%eax),%edx
80103f7e:	89 d8                	mov    %ebx,%eax
80103f80:	39 d0                	cmp    %edx,%eax
80103f82:	73 0e                	jae    80103f92 <fetchstr+0x2e>
80103f84:	80 38 00             	cmpb   $0x0,(%eax)
80103f87:	74 05                	je     80103f8e <fetchstr+0x2a>
80103f89:	83 c0 01             	add    $0x1,%eax
80103f8c:	eb f2                	jmp    80103f80 <fetchstr+0x1c>
80103f8e:	29 d8                	sub    %ebx,%eax
80103f90:	eb 05                	jmp    80103f97 <fetchstr+0x33>
80103f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f97:	83 c4 04             	add    $0x4,%esp
80103f9a:	5b                   	pop    %ebx
80103f9b:	5d                   	pop    %ebp
80103f9c:	c3                   	ret    
80103f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa2:	eb f3                	jmp    80103f97 <fetchstr+0x33>

80103fa4 <argint>:
80103fa4:	55                   	push   %ebp
80103fa5:	89 e5                	mov    %esp,%ebp
80103fa7:	83 ec 08             	sub    $0x8,%esp
80103faa:	e8 5c f3 ff ff       	call   8010330b <myproc>
80103faf:	8b 50 18             	mov    0x18(%eax),%edx
80103fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb5:	c1 e0 02             	shl    $0x2,%eax
80103fb8:	03 42 44             	add    0x44(%edx),%eax
80103fbb:	83 ec 08             	sub    $0x8,%esp
80103fbe:	ff 75 0c             	pushl  0xc(%ebp)
80103fc1:	83 c0 04             	add    $0x4,%eax
80103fc4:	50                   	push   %eax
80103fc5:	e8 5e ff ff ff       	call   80103f28 <fetchint>
80103fca:	c9                   	leave  
80103fcb:	c3                   	ret    

80103fcc <argptr>:
80103fcc:	55                   	push   %ebp
80103fcd:	89 e5                	mov    %esp,%ebp
80103fcf:	56                   	push   %esi
80103fd0:	53                   	push   %ebx
80103fd1:	83 ec 10             	sub    $0x10,%esp
80103fd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
80103fd7:	e8 2f f3 ff ff       	call   8010330b <myproc>
80103fdc:	89 c6                	mov    %eax,%esi
80103fde:	83 ec 08             	sub    $0x8,%esp
80103fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103fe4:	50                   	push   %eax
80103fe5:	ff 75 08             	pushl  0x8(%ebp)
80103fe8:	e8 b7 ff ff ff       	call   80103fa4 <argint>
80103fed:	83 c4 10             	add    $0x10,%esp
80103ff0:	85 c0                	test   %eax,%eax
80103ff2:	78 24                	js     80104018 <argptr+0x4c>
80103ff4:	85 db                	test   %ebx,%ebx
80103ff6:	78 27                	js     8010401f <argptr+0x53>
80103ff8:	8b 16                	mov    (%esi),%edx
80103ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffd:	39 c2                	cmp    %eax,%edx
80103fff:	76 25                	jbe    80104026 <argptr+0x5a>
80104001:	01 c3                	add    %eax,%ebx
80104003:	39 da                	cmp    %ebx,%edx
80104005:	72 26                	jb     8010402d <argptr+0x61>
80104007:	8b 55 0c             	mov    0xc(%ebp),%edx
8010400a:	89 02                	mov    %eax,(%edx)
8010400c:	b8 00 00 00 00       	mov    $0x0,%eax
80104011:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104014:	5b                   	pop    %ebx
80104015:	5e                   	pop    %esi
80104016:	5d                   	pop    %ebp
80104017:	c3                   	ret    
80104018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010401d:	eb f2                	jmp    80104011 <argptr+0x45>
8010401f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104024:	eb eb                	jmp    80104011 <argptr+0x45>
80104026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010402b:	eb e4                	jmp    80104011 <argptr+0x45>
8010402d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104032:	eb dd                	jmp    80104011 <argptr+0x45>

80104034 <argstr>:
80104034:	55                   	push   %ebp
80104035:	89 e5                	mov    %esp,%ebp
80104037:	83 ec 20             	sub    $0x20,%esp
8010403a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010403d:	50                   	push   %eax
8010403e:	ff 75 08             	pushl  0x8(%ebp)
80104041:	e8 5e ff ff ff       	call   80103fa4 <argint>
80104046:	83 c4 10             	add    $0x10,%esp
80104049:	85 c0                	test   %eax,%eax
8010404b:	78 13                	js     80104060 <argstr+0x2c>
8010404d:	83 ec 08             	sub    $0x8,%esp
80104050:	ff 75 0c             	pushl  0xc(%ebp)
80104053:	ff 75 f4             	pushl  -0xc(%ebp)
80104056:	e8 09 ff ff ff       	call   80103f64 <fetchstr>
8010405b:	83 c4 10             	add    $0x10,%esp
8010405e:	c9                   	leave  
8010405f:	c3                   	ret    
80104060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104065:	eb f7                	jmp    8010405e <argstr+0x2a>

80104067 <syscall>:
80104067:	55                   	push   %ebp
80104068:	89 e5                	mov    %esp,%ebp
8010406a:	53                   	push   %ebx
8010406b:	83 ec 04             	sub    $0x4,%esp
8010406e:	e8 98 f2 ff ff       	call   8010330b <myproc>
80104073:	89 c3                	mov    %eax,%ebx
80104075:	8b 40 18             	mov    0x18(%eax),%eax
80104078:	8b 40 1c             	mov    0x1c(%eax),%eax
8010407b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010407e:	83 fa 15             	cmp    $0x15,%edx
80104081:	77 18                	ja     8010409b <syscall+0x34>
80104083:	8b 14 85 c0 6c 10 80 	mov    -0x7fef9340(,%eax,4),%edx
8010408a:	85 d2                	test   %edx,%edx
8010408c:	74 0d                	je     8010409b <syscall+0x34>
8010408e:	ff d2                	call   *%edx
80104090:	8b 53 18             	mov    0x18(%ebx),%edx
80104093:	89 42 1c             	mov    %eax,0x1c(%edx)
80104096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104099:	c9                   	leave  
8010409a:	c3                   	ret    
8010409b:	8d 53 6c             	lea    0x6c(%ebx),%edx
8010409e:	50                   	push   %eax
8010409f:	52                   	push   %edx
801040a0:	ff 73 10             	pushl  0x10(%ebx)
801040a3:	68 91 6c 10 80       	push   $0x80106c91
801040a8:	e8 5e c5 ff ff       	call   8010060b <cprintf>
801040ad:	8b 43 18             	mov    0x18(%ebx),%eax
801040b0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
801040b7:	83 c4 10             	add    $0x10,%esp
801040ba:	eb da                	jmp    80104096 <syscall+0x2f>

801040bc <argfd>:
801040bc:	55                   	push   %ebp
801040bd:	89 e5                	mov    %esp,%ebp
801040bf:	56                   	push   %esi
801040c0:	53                   	push   %ebx
801040c1:	83 ec 18             	sub    $0x18,%esp
801040c4:	89 d6                	mov    %edx,%esi
801040c6:	89 cb                	mov    %ecx,%ebx
801040c8:	8d 55 f4             	lea    -0xc(%ebp),%edx
801040cb:	52                   	push   %edx
801040cc:	50                   	push   %eax
801040cd:	e8 d2 fe ff ff       	call   80103fa4 <argint>
801040d2:	83 c4 10             	add    $0x10,%esp
801040d5:	85 c0                	test   %eax,%eax
801040d7:	78 2e                	js     80104107 <argfd+0x4b>
801040d9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801040dd:	77 2f                	ja     8010410e <argfd+0x52>
801040df:	e8 27 f2 ff ff       	call   8010330b <myproc>
801040e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e7:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801040eb:	85 c0                	test   %eax,%eax
801040ed:	74 26                	je     80104115 <argfd+0x59>
801040ef:	85 f6                	test   %esi,%esi
801040f1:	74 02                	je     801040f5 <argfd+0x39>
801040f3:	89 16                	mov    %edx,(%esi)
801040f5:	85 db                	test   %ebx,%ebx
801040f7:	74 23                	je     8010411c <argfd+0x60>
801040f9:	89 03                	mov    %eax,(%ebx)
801040fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104100:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104103:	5b                   	pop    %ebx
80104104:	5e                   	pop    %esi
80104105:	5d                   	pop    %ebp
80104106:	c3                   	ret    
80104107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410c:	eb f2                	jmp    80104100 <argfd+0x44>
8010410e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104113:	eb eb                	jmp    80104100 <argfd+0x44>
80104115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010411a:	eb e4                	jmp    80104100 <argfd+0x44>
8010411c:	b8 00 00 00 00       	mov    $0x0,%eax
80104121:	eb dd                	jmp    80104100 <argfd+0x44>

80104123 <fdalloc>:
80104123:	55                   	push   %ebp
80104124:	89 e5                	mov    %esp,%ebp
80104126:	53                   	push   %ebx
80104127:	83 ec 04             	sub    $0x4,%esp
8010412a:	89 c3                	mov    %eax,%ebx
8010412c:	e8 da f1 ff ff       	call   8010330b <myproc>
80104131:	ba 00 00 00 00       	mov    $0x0,%edx
80104136:	83 fa 0f             	cmp    $0xf,%edx
80104139:	7f 18                	jg     80104153 <fdalloc+0x30>
8010413b:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104140:	74 05                	je     80104147 <fdalloc+0x24>
80104142:	83 c2 01             	add    $0x1,%edx
80104145:	eb ef                	jmp    80104136 <fdalloc+0x13>
80104147:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
8010414b:	89 d0                	mov    %edx,%eax
8010414d:	83 c4 04             	add    $0x4,%esp
80104150:	5b                   	pop    %ebx
80104151:	5d                   	pop    %ebp
80104152:	c3                   	ret    
80104153:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80104158:	eb f1                	jmp    8010414b <fdalloc+0x28>

8010415a <isdirempty>:
8010415a:	55                   	push   %ebp
8010415b:	89 e5                	mov    %esp,%ebp
8010415d:	56                   	push   %esi
8010415e:	53                   	push   %ebx
8010415f:	83 ec 10             	sub    $0x10,%esp
80104162:	89 c3                	mov    %eax,%ebx
80104164:	b8 20 00 00 00       	mov    $0x20,%eax
80104169:	89 c6                	mov    %eax,%esi
8010416b:	39 43 58             	cmp    %eax,0x58(%ebx)
8010416e:	76 2e                	jbe    8010419e <isdirempty+0x44>
80104170:	6a 10                	push   $0x10
80104172:	50                   	push   %eax
80104173:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104176:	50                   	push   %eax
80104177:	53                   	push   %ebx
80104178:	e8 02 d6 ff ff       	call   8010177f <readi>
8010417d:	83 c4 10             	add    $0x10,%esp
80104180:	83 f8 10             	cmp    $0x10,%eax
80104183:	75 0c                	jne    80104191 <isdirempty+0x37>
80104185:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010418a:	75 1e                	jne    801041aa <isdirempty+0x50>
8010418c:	8d 46 10             	lea    0x10(%esi),%eax
8010418f:	eb d8                	jmp    80104169 <isdirempty+0xf>
80104191:	83 ec 0c             	sub    $0xc,%esp
80104194:	68 1c 6d 10 80       	push   $0x80106d1c
80104199:	e8 aa c1 ff ff       	call   80100348 <panic>
8010419e:	b8 01 00 00 00       	mov    $0x1,%eax
801041a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a6:	5b                   	pop    %ebx
801041a7:	5e                   	pop    %esi
801041a8:	5d                   	pop    %ebp
801041a9:	c3                   	ret    
801041aa:	b8 00 00 00 00       	mov    $0x0,%eax
801041af:	eb f2                	jmp    801041a3 <isdirempty+0x49>

801041b1 <create>:
801041b1:	55                   	push   %ebp
801041b2:	89 e5                	mov    %esp,%ebp
801041b4:	57                   	push   %edi
801041b5:	56                   	push   %esi
801041b6:	53                   	push   %ebx
801041b7:	83 ec 44             	sub    $0x44,%esp
801041ba:	89 55 c4             	mov    %edx,-0x3c(%ebp)
801041bd:	89 4d c0             	mov    %ecx,-0x40(%ebp)
801041c0:	8b 7d 08             	mov    0x8(%ebp),%edi
801041c3:	8d 55 d6             	lea    -0x2a(%ebp),%edx
801041c6:	52                   	push   %edx
801041c7:	50                   	push   %eax
801041c8:	e8 38 da ff ff       	call   80101c05 <nameiparent>
801041cd:	89 c6                	mov    %eax,%esi
801041cf:	83 c4 10             	add    $0x10,%esp
801041d2:	85 c0                	test   %eax,%eax
801041d4:	0f 84 3a 01 00 00    	je     80104314 <create+0x163>
801041da:	83 ec 0c             	sub    $0xc,%esp
801041dd:	50                   	push   %eax
801041de:	e8 aa d3 ff ff       	call   8010158d <ilock>
801041e3:	83 c4 0c             	add    $0xc,%esp
801041e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801041e9:	50                   	push   %eax
801041ea:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801041ed:	50                   	push   %eax
801041ee:	56                   	push   %esi
801041ef:	e8 c8 d7 ff ff       	call   801019bc <dirlookup>
801041f4:	89 c3                	mov    %eax,%ebx
801041f6:	83 c4 10             	add    $0x10,%esp
801041f9:	85 c0                	test   %eax,%eax
801041fb:	74 3f                	je     8010423c <create+0x8b>
801041fd:	83 ec 0c             	sub    $0xc,%esp
80104200:	56                   	push   %esi
80104201:	e8 2e d5 ff ff       	call   80101734 <iunlockput>
80104206:	89 1c 24             	mov    %ebx,(%esp)
80104209:	e8 7f d3 ff ff       	call   8010158d <ilock>
8010420e:	83 c4 10             	add    $0x10,%esp
80104211:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104216:	75 11                	jne    80104229 <create+0x78>
80104218:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
8010421d:	75 0a                	jne    80104229 <create+0x78>
8010421f:	89 d8                	mov    %ebx,%eax
80104221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104224:	5b                   	pop    %ebx
80104225:	5e                   	pop    %esi
80104226:	5f                   	pop    %edi
80104227:	5d                   	pop    %ebp
80104228:	c3                   	ret    
80104229:	83 ec 0c             	sub    $0xc,%esp
8010422c:	53                   	push   %ebx
8010422d:	e8 02 d5 ff ff       	call   80101734 <iunlockput>
80104232:	83 c4 10             	add    $0x10,%esp
80104235:	bb 00 00 00 00       	mov    $0x0,%ebx
8010423a:	eb e3                	jmp    8010421f <create+0x6e>
8010423c:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104240:	83 ec 08             	sub    $0x8,%esp
80104243:	50                   	push   %eax
80104244:	ff 36                	pushl  (%esi)
80104246:	e8 3f d1 ff ff       	call   8010138a <ialloc>
8010424b:	89 c3                	mov    %eax,%ebx
8010424d:	83 c4 10             	add    $0x10,%esp
80104250:	85 c0                	test   %eax,%eax
80104252:	74 55                	je     801042a9 <create+0xf8>
80104254:	83 ec 0c             	sub    $0xc,%esp
80104257:	50                   	push   %eax
80104258:	e8 30 d3 ff ff       	call   8010158d <ilock>
8010425d:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104261:	66 89 43 52          	mov    %ax,0x52(%ebx)
80104265:	66 89 7b 54          	mov    %di,0x54(%ebx)
80104269:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
8010426f:	89 1c 24             	mov    %ebx,(%esp)
80104272:	e8 b5 d1 ff ff       	call   8010142c <iupdate>
80104277:	83 c4 10             	add    $0x10,%esp
8010427a:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010427f:	74 35                	je     801042b6 <create+0x105>
80104281:	83 ec 04             	sub    $0x4,%esp
80104284:	ff 73 04             	pushl  0x4(%ebx)
80104287:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010428a:	50                   	push   %eax
8010428b:	56                   	push   %esi
8010428c:	e8 ab d8 ff ff       	call   80101b3c <dirlink>
80104291:	83 c4 10             	add    $0x10,%esp
80104294:	85 c0                	test   %eax,%eax
80104296:	78 6f                	js     80104307 <create+0x156>
80104298:	83 ec 0c             	sub    $0xc,%esp
8010429b:	56                   	push   %esi
8010429c:	e8 93 d4 ff ff       	call   80101734 <iunlockput>
801042a1:	83 c4 10             	add    $0x10,%esp
801042a4:	e9 76 ff ff ff       	jmp    8010421f <create+0x6e>
801042a9:	83 ec 0c             	sub    $0xc,%esp
801042ac:	68 2e 6d 10 80       	push   $0x80106d2e
801042b1:	e8 92 c0 ff ff       	call   80100348 <panic>
801042b6:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801042ba:	83 c0 01             	add    $0x1,%eax
801042bd:	66 89 46 56          	mov    %ax,0x56(%esi)
801042c1:	83 ec 0c             	sub    $0xc,%esp
801042c4:	56                   	push   %esi
801042c5:	e8 62 d1 ff ff       	call   8010142c <iupdate>
801042ca:	83 c4 0c             	add    $0xc,%esp
801042cd:	ff 73 04             	pushl  0x4(%ebx)
801042d0:	68 3e 6d 10 80       	push   $0x80106d3e
801042d5:	53                   	push   %ebx
801042d6:	e8 61 d8 ff ff       	call   80101b3c <dirlink>
801042db:	83 c4 10             	add    $0x10,%esp
801042de:	85 c0                	test   %eax,%eax
801042e0:	78 18                	js     801042fa <create+0x149>
801042e2:	83 ec 04             	sub    $0x4,%esp
801042e5:	ff 76 04             	pushl  0x4(%esi)
801042e8:	68 3d 6d 10 80       	push   $0x80106d3d
801042ed:	53                   	push   %ebx
801042ee:	e8 49 d8 ff ff       	call   80101b3c <dirlink>
801042f3:	83 c4 10             	add    $0x10,%esp
801042f6:	85 c0                	test   %eax,%eax
801042f8:	79 87                	jns    80104281 <create+0xd0>
801042fa:	83 ec 0c             	sub    $0xc,%esp
801042fd:	68 40 6d 10 80       	push   $0x80106d40
80104302:	e8 41 c0 ff ff       	call   80100348 <panic>
80104307:	83 ec 0c             	sub    $0xc,%esp
8010430a:	68 4c 6d 10 80       	push   $0x80106d4c
8010430f:	e8 34 c0 ff ff       	call   80100348 <panic>
80104314:	89 c3                	mov    %eax,%ebx
80104316:	e9 04 ff ff ff       	jmp    8010421f <create+0x6e>

8010431b <sys_dup>:
8010431b:	55                   	push   %ebp
8010431c:	89 e5                	mov    %esp,%ebp
8010431e:	53                   	push   %ebx
8010431f:	83 ec 14             	sub    $0x14,%esp
80104322:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104325:	ba 00 00 00 00       	mov    $0x0,%edx
8010432a:	b8 00 00 00 00       	mov    $0x0,%eax
8010432f:	e8 88 fd ff ff       	call   801040bc <argfd>
80104334:	85 c0                	test   %eax,%eax
80104336:	78 23                	js     8010435b <sys_dup+0x40>
80104338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433b:	e8 e3 fd ff ff       	call   80104123 <fdalloc>
80104340:	89 c3                	mov    %eax,%ebx
80104342:	85 c0                	test   %eax,%eax
80104344:	78 1c                	js     80104362 <sys_dup+0x47>
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	ff 75 f4             	pushl  -0xc(%ebp)
8010434c:	e8 49 c9 ff ff       	call   80100c9a <filedup>
80104351:	83 c4 10             	add    $0x10,%esp
80104354:	89 d8                	mov    %ebx,%eax
80104356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104359:	c9                   	leave  
8010435a:	c3                   	ret    
8010435b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104360:	eb f2                	jmp    80104354 <sys_dup+0x39>
80104362:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104367:	eb eb                	jmp    80104354 <sys_dup+0x39>

80104369 <sys_read>:
80104369:	55                   	push   %ebp
8010436a:	89 e5                	mov    %esp,%ebp
8010436c:	83 ec 18             	sub    $0x18,%esp
8010436f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104372:	ba 00 00 00 00       	mov    $0x0,%edx
80104377:	b8 00 00 00 00       	mov    $0x0,%eax
8010437c:	e8 3b fd ff ff       	call   801040bc <argfd>
80104381:	85 c0                	test   %eax,%eax
80104383:	78 43                	js     801043c8 <sys_read+0x5f>
80104385:	83 ec 08             	sub    $0x8,%esp
80104388:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010438b:	50                   	push   %eax
8010438c:	6a 02                	push   $0x2
8010438e:	e8 11 fc ff ff       	call   80103fa4 <argint>
80104393:	83 c4 10             	add    $0x10,%esp
80104396:	85 c0                	test   %eax,%eax
80104398:	78 35                	js     801043cf <sys_read+0x66>
8010439a:	83 ec 04             	sub    $0x4,%esp
8010439d:	ff 75 f0             	pushl  -0x10(%ebp)
801043a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043a3:	50                   	push   %eax
801043a4:	6a 01                	push   $0x1
801043a6:	e8 21 fc ff ff       	call   80103fcc <argptr>
801043ab:	83 c4 10             	add    $0x10,%esp
801043ae:	85 c0                	test   %eax,%eax
801043b0:	78 24                	js     801043d6 <sys_read+0x6d>
801043b2:	83 ec 04             	sub    $0x4,%esp
801043b5:	ff 75 f0             	pushl  -0x10(%ebp)
801043b8:	ff 75 ec             	pushl  -0x14(%ebp)
801043bb:	ff 75 f4             	pushl  -0xc(%ebp)
801043be:	e8 20 ca ff ff       	call   80100de3 <fileread>
801043c3:	83 c4 10             	add    $0x10,%esp
801043c6:	c9                   	leave  
801043c7:	c3                   	ret    
801043c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043cd:	eb f7                	jmp    801043c6 <sys_read+0x5d>
801043cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043d4:	eb f0                	jmp    801043c6 <sys_read+0x5d>
801043d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043db:	eb e9                	jmp    801043c6 <sys_read+0x5d>

801043dd <sys_write>:
801043dd:	55                   	push   %ebp
801043de:	89 e5                	mov    %esp,%ebp
801043e0:	83 ec 18             	sub    $0x18,%esp
801043e3:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043e6:	ba 00 00 00 00       	mov    $0x0,%edx
801043eb:	b8 00 00 00 00       	mov    $0x0,%eax
801043f0:	e8 c7 fc ff ff       	call   801040bc <argfd>
801043f5:	85 c0                	test   %eax,%eax
801043f7:	78 43                	js     8010443c <sys_write+0x5f>
801043f9:	83 ec 08             	sub    $0x8,%esp
801043fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043ff:	50                   	push   %eax
80104400:	6a 02                	push   $0x2
80104402:	e8 9d fb ff ff       	call   80103fa4 <argint>
80104407:	83 c4 10             	add    $0x10,%esp
8010440a:	85 c0                	test   %eax,%eax
8010440c:	78 35                	js     80104443 <sys_write+0x66>
8010440e:	83 ec 04             	sub    $0x4,%esp
80104411:	ff 75 f0             	pushl  -0x10(%ebp)
80104414:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104417:	50                   	push   %eax
80104418:	6a 01                	push   $0x1
8010441a:	e8 ad fb ff ff       	call   80103fcc <argptr>
8010441f:	83 c4 10             	add    $0x10,%esp
80104422:	85 c0                	test   %eax,%eax
80104424:	78 24                	js     8010444a <sys_write+0x6d>
80104426:	83 ec 04             	sub    $0x4,%esp
80104429:	ff 75 f0             	pushl  -0x10(%ebp)
8010442c:	ff 75 ec             	pushl  -0x14(%ebp)
8010442f:	ff 75 f4             	pushl  -0xc(%ebp)
80104432:	e8 31 ca ff ff       	call   80100e68 <filewrite>
80104437:	83 c4 10             	add    $0x10,%esp
8010443a:	c9                   	leave  
8010443b:	c3                   	ret    
8010443c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104441:	eb f7                	jmp    8010443a <sys_write+0x5d>
80104443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104448:	eb f0                	jmp    8010443a <sys_write+0x5d>
8010444a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010444f:	eb e9                	jmp    8010443a <sys_write+0x5d>

80104451 <sys_close>:
80104451:	55                   	push   %ebp
80104452:	89 e5                	mov    %esp,%ebp
80104454:	83 ec 18             	sub    $0x18,%esp
80104457:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010445a:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010445d:	b8 00 00 00 00       	mov    $0x0,%eax
80104462:	e8 55 fc ff ff       	call   801040bc <argfd>
80104467:	85 c0                	test   %eax,%eax
80104469:	78 25                	js     80104490 <sys_close+0x3f>
8010446b:	e8 9b ee ff ff       	call   8010330b <myproc>
80104470:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104473:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010447a:	00 
8010447b:	83 ec 0c             	sub    $0xc,%esp
8010447e:	ff 75 f0             	pushl  -0x10(%ebp)
80104481:	e8 59 c8 ff ff       	call   80100cdf <fileclose>
80104486:	83 c4 10             	add    $0x10,%esp
80104489:	b8 00 00 00 00       	mov    $0x0,%eax
8010448e:	c9                   	leave  
8010448f:	c3                   	ret    
80104490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104495:	eb f7                	jmp    8010448e <sys_close+0x3d>

80104497 <sys_fstat>:
80104497:	55                   	push   %ebp
80104498:	89 e5                	mov    %esp,%ebp
8010449a:	83 ec 18             	sub    $0x18,%esp
8010449d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044a0:	ba 00 00 00 00       	mov    $0x0,%edx
801044a5:	b8 00 00 00 00       	mov    $0x0,%eax
801044aa:	e8 0d fc ff ff       	call   801040bc <argfd>
801044af:	85 c0                	test   %eax,%eax
801044b1:	78 2a                	js     801044dd <sys_fstat+0x46>
801044b3:	83 ec 04             	sub    $0x4,%esp
801044b6:	6a 14                	push   $0x14
801044b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044bb:	50                   	push   %eax
801044bc:	6a 01                	push   $0x1
801044be:	e8 09 fb ff ff       	call   80103fcc <argptr>
801044c3:	83 c4 10             	add    $0x10,%esp
801044c6:	85 c0                	test   %eax,%eax
801044c8:	78 1a                	js     801044e4 <sys_fstat+0x4d>
801044ca:	83 ec 08             	sub    $0x8,%esp
801044cd:	ff 75 f0             	pushl  -0x10(%ebp)
801044d0:	ff 75 f4             	pushl  -0xc(%ebp)
801044d3:	e8 c4 c8 ff ff       	call   80100d9c <filestat>
801044d8:	83 c4 10             	add    $0x10,%esp
801044db:	c9                   	leave  
801044dc:	c3                   	ret    
801044dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e2:	eb f7                	jmp    801044db <sys_fstat+0x44>
801044e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044e9:	eb f0                	jmp    801044db <sys_fstat+0x44>

801044eb <sys_link>:
801044eb:	55                   	push   %ebp
801044ec:	89 e5                	mov    %esp,%ebp
801044ee:	56                   	push   %esi
801044ef:	53                   	push   %ebx
801044f0:	83 ec 28             	sub    $0x28,%esp
801044f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801044f6:	50                   	push   %eax
801044f7:	6a 00                	push   $0x0
801044f9:	e8 36 fb ff ff       	call   80104034 <argstr>
801044fe:	83 c4 10             	add    $0x10,%esp
80104501:	85 c0                	test   %eax,%eax
80104503:	0f 88 32 01 00 00    	js     8010463b <sys_link+0x150>
80104509:	83 ec 08             	sub    $0x8,%esp
8010450c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010450f:	50                   	push   %eax
80104510:	6a 01                	push   $0x1
80104512:	e8 1d fb ff ff       	call   80104034 <argstr>
80104517:	83 c4 10             	add    $0x10,%esp
8010451a:	85 c0                	test   %eax,%eax
8010451c:	0f 88 20 01 00 00    	js     80104642 <sys_link+0x157>
80104522:	e8 89 e3 ff ff       	call   801028b0 <begin_op>
80104527:	83 ec 0c             	sub    $0xc,%esp
8010452a:	ff 75 e0             	pushl  -0x20(%ebp)
8010452d:	e8 bb d6 ff ff       	call   80101bed <namei>
80104532:	89 c3                	mov    %eax,%ebx
80104534:	83 c4 10             	add    $0x10,%esp
80104537:	85 c0                	test   %eax,%eax
80104539:	0f 84 99 00 00 00    	je     801045d8 <sys_link+0xed>
8010453f:	83 ec 0c             	sub    $0xc,%esp
80104542:	50                   	push   %eax
80104543:	e8 45 d0 ff ff       	call   8010158d <ilock>
80104548:	83 c4 10             	add    $0x10,%esp
8010454b:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104550:	0f 84 8e 00 00 00    	je     801045e4 <sys_link+0xf9>
80104556:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010455a:	83 c0 01             	add    $0x1,%eax
8010455d:	66 89 43 56          	mov    %ax,0x56(%ebx)
80104561:	83 ec 0c             	sub    $0xc,%esp
80104564:	53                   	push   %ebx
80104565:	e8 c2 ce ff ff       	call   8010142c <iupdate>
8010456a:	89 1c 24             	mov    %ebx,(%esp)
8010456d:	e8 dd d0 ff ff       	call   8010164f <iunlock>
80104572:	83 c4 08             	add    $0x8,%esp
80104575:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104578:	50                   	push   %eax
80104579:	ff 75 e4             	pushl  -0x1c(%ebp)
8010457c:	e8 84 d6 ff ff       	call   80101c05 <nameiparent>
80104581:	89 c6                	mov    %eax,%esi
80104583:	83 c4 10             	add    $0x10,%esp
80104586:	85 c0                	test   %eax,%eax
80104588:	74 7e                	je     80104608 <sys_link+0x11d>
8010458a:	83 ec 0c             	sub    $0xc,%esp
8010458d:	50                   	push   %eax
8010458e:	e8 fa cf ff ff       	call   8010158d <ilock>
80104593:	83 c4 10             	add    $0x10,%esp
80104596:	8b 03                	mov    (%ebx),%eax
80104598:	39 06                	cmp    %eax,(%esi)
8010459a:	75 60                	jne    801045fc <sys_link+0x111>
8010459c:	83 ec 04             	sub    $0x4,%esp
8010459f:	ff 73 04             	pushl  0x4(%ebx)
801045a2:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045a5:	50                   	push   %eax
801045a6:	56                   	push   %esi
801045a7:	e8 90 d5 ff ff       	call   80101b3c <dirlink>
801045ac:	83 c4 10             	add    $0x10,%esp
801045af:	85 c0                	test   %eax,%eax
801045b1:	78 49                	js     801045fc <sys_link+0x111>
801045b3:	83 ec 0c             	sub    $0xc,%esp
801045b6:	56                   	push   %esi
801045b7:	e8 78 d1 ff ff       	call   80101734 <iunlockput>
801045bc:	89 1c 24             	mov    %ebx,(%esp)
801045bf:	e8 d0 d0 ff ff       	call   80101694 <iput>
801045c4:	e8 61 e3 ff ff       	call   8010292a <end_op>
801045c9:	83 c4 10             	add    $0x10,%esp
801045cc:	b8 00 00 00 00       	mov    $0x0,%eax
801045d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801045d4:	5b                   	pop    %ebx
801045d5:	5e                   	pop    %esi
801045d6:	5d                   	pop    %ebp
801045d7:	c3                   	ret    
801045d8:	e8 4d e3 ff ff       	call   8010292a <end_op>
801045dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e2:	eb ed                	jmp    801045d1 <sys_link+0xe6>
801045e4:	83 ec 0c             	sub    $0xc,%esp
801045e7:	53                   	push   %ebx
801045e8:	e8 47 d1 ff ff       	call   80101734 <iunlockput>
801045ed:	e8 38 e3 ff ff       	call   8010292a <end_op>
801045f2:	83 c4 10             	add    $0x10,%esp
801045f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fa:	eb d5                	jmp    801045d1 <sys_link+0xe6>
801045fc:	83 ec 0c             	sub    $0xc,%esp
801045ff:	56                   	push   %esi
80104600:	e8 2f d1 ff ff       	call   80101734 <iunlockput>
80104605:	83 c4 10             	add    $0x10,%esp
80104608:	83 ec 0c             	sub    $0xc,%esp
8010460b:	53                   	push   %ebx
8010460c:	e8 7c cf ff ff       	call   8010158d <ilock>
80104611:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104615:	83 e8 01             	sub    $0x1,%eax
80104618:	66 89 43 56          	mov    %ax,0x56(%ebx)
8010461c:	89 1c 24             	mov    %ebx,(%esp)
8010461f:	e8 08 ce ff ff       	call   8010142c <iupdate>
80104624:	89 1c 24             	mov    %ebx,(%esp)
80104627:	e8 08 d1 ff ff       	call   80101734 <iunlockput>
8010462c:	e8 f9 e2 ff ff       	call   8010292a <end_op>
80104631:	83 c4 10             	add    $0x10,%esp
80104634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104639:	eb 96                	jmp    801045d1 <sys_link+0xe6>
8010463b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104640:	eb 8f                	jmp    801045d1 <sys_link+0xe6>
80104642:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104647:	eb 88                	jmp    801045d1 <sys_link+0xe6>

80104649 <sys_unlink>:
80104649:	55                   	push   %ebp
8010464a:	89 e5                	mov    %esp,%ebp
8010464c:	57                   	push   %edi
8010464d:	56                   	push   %esi
8010464e:	53                   	push   %ebx
8010464f:	83 ec 44             	sub    $0x44,%esp
80104652:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104655:	50                   	push   %eax
80104656:	6a 00                	push   $0x0
80104658:	e8 d7 f9 ff ff       	call   80104034 <argstr>
8010465d:	83 c4 10             	add    $0x10,%esp
80104660:	85 c0                	test   %eax,%eax
80104662:	0f 88 83 01 00 00    	js     801047eb <sys_unlink+0x1a2>
80104668:	e8 43 e2 ff ff       	call   801028b0 <begin_op>
8010466d:	83 ec 08             	sub    $0x8,%esp
80104670:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104673:	50                   	push   %eax
80104674:	ff 75 c4             	pushl  -0x3c(%ebp)
80104677:	e8 89 d5 ff ff       	call   80101c05 <nameiparent>
8010467c:	89 c6                	mov    %eax,%esi
8010467e:	83 c4 10             	add    $0x10,%esp
80104681:	85 c0                	test   %eax,%eax
80104683:	0f 84 ed 00 00 00    	je     80104776 <sys_unlink+0x12d>
80104689:	83 ec 0c             	sub    $0xc,%esp
8010468c:	50                   	push   %eax
8010468d:	e8 fb ce ff ff       	call   8010158d <ilock>
80104692:	83 c4 08             	add    $0x8,%esp
80104695:	68 3e 6d 10 80       	push   $0x80106d3e
8010469a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010469d:	50                   	push   %eax
8010469e:	e8 04 d3 ff ff       	call   801019a7 <namecmp>
801046a3:	83 c4 10             	add    $0x10,%esp
801046a6:	85 c0                	test   %eax,%eax
801046a8:	0f 84 fc 00 00 00    	je     801047aa <sys_unlink+0x161>
801046ae:	83 ec 08             	sub    $0x8,%esp
801046b1:	68 3d 6d 10 80       	push   $0x80106d3d
801046b6:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046b9:	50                   	push   %eax
801046ba:	e8 e8 d2 ff ff       	call   801019a7 <namecmp>
801046bf:	83 c4 10             	add    $0x10,%esp
801046c2:	85 c0                	test   %eax,%eax
801046c4:	0f 84 e0 00 00 00    	je     801047aa <sys_unlink+0x161>
801046ca:	83 ec 04             	sub    $0x4,%esp
801046cd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801046d0:	50                   	push   %eax
801046d1:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046d4:	50                   	push   %eax
801046d5:	56                   	push   %esi
801046d6:	e8 e1 d2 ff ff       	call   801019bc <dirlookup>
801046db:	89 c3                	mov    %eax,%ebx
801046dd:	83 c4 10             	add    $0x10,%esp
801046e0:	85 c0                	test   %eax,%eax
801046e2:	0f 84 c2 00 00 00    	je     801047aa <sys_unlink+0x161>
801046e8:	83 ec 0c             	sub    $0xc,%esp
801046eb:	50                   	push   %eax
801046ec:	e8 9c ce ff ff       	call   8010158d <ilock>
801046f1:	83 c4 10             	add    $0x10,%esp
801046f4:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801046f9:	0f 8e 83 00 00 00    	jle    80104782 <sys_unlink+0x139>
801046ff:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104704:	0f 84 85 00 00 00    	je     8010478f <sys_unlink+0x146>
8010470a:	83 ec 04             	sub    $0x4,%esp
8010470d:	6a 10                	push   $0x10
8010470f:	6a 00                	push   $0x0
80104711:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104714:	57                   	push   %edi
80104715:	e8 3f f6 ff ff       	call   80103d59 <memset>
8010471a:	6a 10                	push   $0x10
8010471c:	ff 75 c0             	pushl  -0x40(%ebp)
8010471f:	57                   	push   %edi
80104720:	56                   	push   %esi
80104721:	e8 56 d1 ff ff       	call   8010187c <writei>
80104726:	83 c4 20             	add    $0x20,%esp
80104729:	83 f8 10             	cmp    $0x10,%eax
8010472c:	0f 85 90 00 00 00    	jne    801047c2 <sys_unlink+0x179>
80104732:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104737:	0f 84 92 00 00 00    	je     801047cf <sys_unlink+0x186>
8010473d:	83 ec 0c             	sub    $0xc,%esp
80104740:	56                   	push   %esi
80104741:	e8 ee cf ff ff       	call   80101734 <iunlockput>
80104746:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010474a:	83 e8 01             	sub    $0x1,%eax
8010474d:	66 89 43 56          	mov    %ax,0x56(%ebx)
80104751:	89 1c 24             	mov    %ebx,(%esp)
80104754:	e8 d3 cc ff ff       	call   8010142c <iupdate>
80104759:	89 1c 24             	mov    %ebx,(%esp)
8010475c:	e8 d3 cf ff ff       	call   80101734 <iunlockput>
80104761:	e8 c4 e1 ff ff       	call   8010292a <end_op>
80104766:	83 c4 10             	add    $0x10,%esp
80104769:	b8 00 00 00 00       	mov    $0x0,%eax
8010476e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104771:	5b                   	pop    %ebx
80104772:	5e                   	pop    %esi
80104773:	5f                   	pop    %edi
80104774:	5d                   	pop    %ebp
80104775:	c3                   	ret    
80104776:	e8 af e1 ff ff       	call   8010292a <end_op>
8010477b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104780:	eb ec                	jmp    8010476e <sys_unlink+0x125>
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	68 5c 6d 10 80       	push   $0x80106d5c
8010478a:	e8 b9 bb ff ff       	call   80100348 <panic>
8010478f:	89 d8                	mov    %ebx,%eax
80104791:	e8 c4 f9 ff ff       	call   8010415a <isdirempty>
80104796:	85 c0                	test   %eax,%eax
80104798:	0f 85 6c ff ff ff    	jne    8010470a <sys_unlink+0xc1>
8010479e:	83 ec 0c             	sub    $0xc,%esp
801047a1:	53                   	push   %ebx
801047a2:	e8 8d cf ff ff       	call   80101734 <iunlockput>
801047a7:	83 c4 10             	add    $0x10,%esp
801047aa:	83 ec 0c             	sub    $0xc,%esp
801047ad:	56                   	push   %esi
801047ae:	e8 81 cf ff ff       	call   80101734 <iunlockput>
801047b3:	e8 72 e1 ff ff       	call   8010292a <end_op>
801047b8:	83 c4 10             	add    $0x10,%esp
801047bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c0:	eb ac                	jmp    8010476e <sys_unlink+0x125>
801047c2:	83 ec 0c             	sub    $0xc,%esp
801047c5:	68 6e 6d 10 80       	push   $0x80106d6e
801047ca:	e8 79 bb ff ff       	call   80100348 <panic>
801047cf:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801047d3:	83 e8 01             	sub    $0x1,%eax
801047d6:	66 89 46 56          	mov    %ax,0x56(%esi)
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	56                   	push   %esi
801047de:	e8 49 cc ff ff       	call   8010142c <iupdate>
801047e3:	83 c4 10             	add    $0x10,%esp
801047e6:	e9 52 ff ff ff       	jmp    8010473d <sys_unlink+0xf4>
801047eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f0:	e9 79 ff ff ff       	jmp    8010476e <sys_unlink+0x125>

801047f5 <sys_open>:
801047f5:	55                   	push   %ebp
801047f6:	89 e5                	mov    %esp,%ebp
801047f8:	57                   	push   %edi
801047f9:	56                   	push   %esi
801047fa:	53                   	push   %ebx
801047fb:	83 ec 24             	sub    $0x24,%esp
801047fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104801:	50                   	push   %eax
80104802:	6a 00                	push   $0x0
80104804:	e8 2b f8 ff ff       	call   80104034 <argstr>
80104809:	83 c4 10             	add    $0x10,%esp
8010480c:	85 c0                	test   %eax,%eax
8010480e:	0f 88 30 01 00 00    	js     80104944 <sys_open+0x14f>
80104814:	83 ec 08             	sub    $0x8,%esp
80104817:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010481a:	50                   	push   %eax
8010481b:	6a 01                	push   $0x1
8010481d:	e8 82 f7 ff ff       	call   80103fa4 <argint>
80104822:	83 c4 10             	add    $0x10,%esp
80104825:	85 c0                	test   %eax,%eax
80104827:	0f 88 21 01 00 00    	js     8010494e <sys_open+0x159>
8010482d:	e8 7e e0 ff ff       	call   801028b0 <begin_op>
80104832:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104836:	0f 84 84 00 00 00    	je     801048c0 <sys_open+0xcb>
8010483c:	83 ec 0c             	sub    $0xc,%esp
8010483f:	6a 00                	push   $0x0
80104841:	b9 00 00 00 00       	mov    $0x0,%ecx
80104846:	ba 02 00 00 00       	mov    $0x2,%edx
8010484b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010484e:	e8 5e f9 ff ff       	call   801041b1 <create>
80104853:	89 c6                	mov    %eax,%esi
80104855:	83 c4 10             	add    $0x10,%esp
80104858:	85 c0                	test   %eax,%eax
8010485a:	74 58                	je     801048b4 <sys_open+0xbf>
8010485c:	e8 d8 c3 ff ff       	call   80100c39 <filealloc>
80104861:	89 c3                	mov    %eax,%ebx
80104863:	85 c0                	test   %eax,%eax
80104865:	0f 84 ae 00 00 00    	je     80104919 <sys_open+0x124>
8010486b:	e8 b3 f8 ff ff       	call   80104123 <fdalloc>
80104870:	89 c7                	mov    %eax,%edi
80104872:	85 c0                	test   %eax,%eax
80104874:	0f 88 9f 00 00 00    	js     80104919 <sys_open+0x124>
8010487a:	83 ec 0c             	sub    $0xc,%esp
8010487d:	56                   	push   %esi
8010487e:	e8 cc cd ff ff       	call   8010164f <iunlock>
80104883:	e8 a2 e0 ff ff       	call   8010292a <end_op>
80104888:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
8010488e:	89 73 10             	mov    %esi,0x10(%ebx)
80104891:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
80104898:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010489b:	83 c4 10             	add    $0x10,%esp
8010489e:	a8 01                	test   $0x1,%al
801048a0:	0f 94 43 08          	sete   0x8(%ebx)
801048a4:	a8 03                	test   $0x3,%al
801048a6:	0f 95 43 09          	setne  0x9(%ebx)
801048aa:	89 f8                	mov    %edi,%eax
801048ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048af:	5b                   	pop    %ebx
801048b0:	5e                   	pop    %esi
801048b1:	5f                   	pop    %edi
801048b2:	5d                   	pop    %ebp
801048b3:	c3                   	ret    
801048b4:	e8 71 e0 ff ff       	call   8010292a <end_op>
801048b9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801048be:	eb ea                	jmp    801048aa <sys_open+0xb5>
801048c0:	83 ec 0c             	sub    $0xc,%esp
801048c3:	ff 75 e4             	pushl  -0x1c(%ebp)
801048c6:	e8 22 d3 ff ff       	call   80101bed <namei>
801048cb:	89 c6                	mov    %eax,%esi
801048cd:	83 c4 10             	add    $0x10,%esp
801048d0:	85 c0                	test   %eax,%eax
801048d2:	74 39                	je     8010490d <sys_open+0x118>
801048d4:	83 ec 0c             	sub    $0xc,%esp
801048d7:	50                   	push   %eax
801048d8:	e8 b0 cc ff ff       	call   8010158d <ilock>
801048dd:	83 c4 10             	add    $0x10,%esp
801048e0:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801048e5:	0f 85 71 ff ff ff    	jne    8010485c <sys_open+0x67>
801048eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048ef:	0f 84 67 ff ff ff    	je     8010485c <sys_open+0x67>
801048f5:	83 ec 0c             	sub    $0xc,%esp
801048f8:	56                   	push   %esi
801048f9:	e8 36 ce ff ff       	call   80101734 <iunlockput>
801048fe:	e8 27 e0 ff ff       	call   8010292a <end_op>
80104903:	83 c4 10             	add    $0x10,%esp
80104906:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010490b:	eb 9d                	jmp    801048aa <sys_open+0xb5>
8010490d:	e8 18 e0 ff ff       	call   8010292a <end_op>
80104912:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104917:	eb 91                	jmp    801048aa <sys_open+0xb5>
80104919:	85 db                	test   %ebx,%ebx
8010491b:	74 0c                	je     80104929 <sys_open+0x134>
8010491d:	83 ec 0c             	sub    $0xc,%esp
80104920:	53                   	push   %ebx
80104921:	e8 b9 c3 ff ff       	call   80100cdf <fileclose>
80104926:	83 c4 10             	add    $0x10,%esp
80104929:	83 ec 0c             	sub    $0xc,%esp
8010492c:	56                   	push   %esi
8010492d:	e8 02 ce ff ff       	call   80101734 <iunlockput>
80104932:	e8 f3 df ff ff       	call   8010292a <end_op>
80104937:	83 c4 10             	add    $0x10,%esp
8010493a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010493f:	e9 66 ff ff ff       	jmp    801048aa <sys_open+0xb5>
80104944:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104949:	e9 5c ff ff ff       	jmp    801048aa <sys_open+0xb5>
8010494e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104953:	e9 52 ff ff ff       	jmp    801048aa <sys_open+0xb5>

80104958 <sys_mkdir>:
80104958:	55                   	push   %ebp
80104959:	89 e5                	mov    %esp,%ebp
8010495b:	83 ec 18             	sub    $0x18,%esp
8010495e:	e8 4d df ff ff       	call   801028b0 <begin_op>
80104963:	83 ec 08             	sub    $0x8,%esp
80104966:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104969:	50                   	push   %eax
8010496a:	6a 00                	push   $0x0
8010496c:	e8 c3 f6 ff ff       	call   80104034 <argstr>
80104971:	83 c4 10             	add    $0x10,%esp
80104974:	85 c0                	test   %eax,%eax
80104976:	78 36                	js     801049ae <sys_mkdir+0x56>
80104978:	83 ec 0c             	sub    $0xc,%esp
8010497b:	6a 00                	push   $0x0
8010497d:	b9 00 00 00 00       	mov    $0x0,%ecx
80104982:	ba 01 00 00 00       	mov    $0x1,%edx
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	e8 22 f8 ff ff       	call   801041b1 <create>
8010498f:	83 c4 10             	add    $0x10,%esp
80104992:	85 c0                	test   %eax,%eax
80104994:	74 18                	je     801049ae <sys_mkdir+0x56>
80104996:	83 ec 0c             	sub    $0xc,%esp
80104999:	50                   	push   %eax
8010499a:	e8 95 cd ff ff       	call   80101734 <iunlockput>
8010499f:	e8 86 df ff ff       	call   8010292a <end_op>
801049a4:	83 c4 10             	add    $0x10,%esp
801049a7:	b8 00 00 00 00       	mov    $0x0,%eax
801049ac:	c9                   	leave  
801049ad:	c3                   	ret    
801049ae:	e8 77 df ff ff       	call   8010292a <end_op>
801049b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b8:	eb f2                	jmp    801049ac <sys_mkdir+0x54>

801049ba <sys_mknod>:
801049ba:	55                   	push   %ebp
801049bb:	89 e5                	mov    %esp,%ebp
801049bd:	83 ec 18             	sub    $0x18,%esp
801049c0:	e8 eb de ff ff       	call   801028b0 <begin_op>
801049c5:	83 ec 08             	sub    $0x8,%esp
801049c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049cb:	50                   	push   %eax
801049cc:	6a 00                	push   $0x0
801049ce:	e8 61 f6 ff ff       	call   80104034 <argstr>
801049d3:	83 c4 10             	add    $0x10,%esp
801049d6:	85 c0                	test   %eax,%eax
801049d8:	78 62                	js     80104a3c <sys_mknod+0x82>
801049da:	83 ec 08             	sub    $0x8,%esp
801049dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801049e0:	50                   	push   %eax
801049e1:	6a 01                	push   $0x1
801049e3:	e8 bc f5 ff ff       	call   80103fa4 <argint>
801049e8:	83 c4 10             	add    $0x10,%esp
801049eb:	85 c0                	test   %eax,%eax
801049ed:	78 4d                	js     80104a3c <sys_mknod+0x82>
801049ef:	83 ec 08             	sub    $0x8,%esp
801049f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801049f5:	50                   	push   %eax
801049f6:	6a 02                	push   $0x2
801049f8:	e8 a7 f5 ff ff       	call   80103fa4 <argint>
801049fd:	83 c4 10             	add    $0x10,%esp
80104a00:	85 c0                	test   %eax,%eax
80104a02:	78 38                	js     80104a3c <sys_mknod+0x82>
80104a04:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104a08:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104a0c:	83 ec 0c             	sub    $0xc,%esp
80104a0f:	50                   	push   %eax
80104a10:	ba 03 00 00 00       	mov    $0x3,%edx
80104a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a18:	e8 94 f7 ff ff       	call   801041b1 <create>
80104a1d:	83 c4 10             	add    $0x10,%esp
80104a20:	85 c0                	test   %eax,%eax
80104a22:	74 18                	je     80104a3c <sys_mknod+0x82>
80104a24:	83 ec 0c             	sub    $0xc,%esp
80104a27:	50                   	push   %eax
80104a28:	e8 07 cd ff ff       	call   80101734 <iunlockput>
80104a2d:	e8 f8 de ff ff       	call   8010292a <end_op>
80104a32:	83 c4 10             	add    $0x10,%esp
80104a35:	b8 00 00 00 00       	mov    $0x0,%eax
80104a3a:	c9                   	leave  
80104a3b:	c3                   	ret    
80104a3c:	e8 e9 de ff ff       	call   8010292a <end_op>
80104a41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a46:	eb f2                	jmp    80104a3a <sys_mknod+0x80>

80104a48 <sys_chdir>:
80104a48:	55                   	push   %ebp
80104a49:	89 e5                	mov    %esp,%ebp
80104a4b:	56                   	push   %esi
80104a4c:	53                   	push   %ebx
80104a4d:	83 ec 10             	sub    $0x10,%esp
80104a50:	e8 b6 e8 ff ff       	call   8010330b <myproc>
80104a55:	89 c6                	mov    %eax,%esi
80104a57:	e8 54 de ff ff       	call   801028b0 <begin_op>
80104a5c:	83 ec 08             	sub    $0x8,%esp
80104a5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a62:	50                   	push   %eax
80104a63:	6a 00                	push   $0x0
80104a65:	e8 ca f5 ff ff       	call   80104034 <argstr>
80104a6a:	83 c4 10             	add    $0x10,%esp
80104a6d:	85 c0                	test   %eax,%eax
80104a6f:	78 52                	js     80104ac3 <sys_chdir+0x7b>
80104a71:	83 ec 0c             	sub    $0xc,%esp
80104a74:	ff 75 f4             	pushl  -0xc(%ebp)
80104a77:	e8 71 d1 ff ff       	call   80101bed <namei>
80104a7c:	89 c3                	mov    %eax,%ebx
80104a7e:	83 c4 10             	add    $0x10,%esp
80104a81:	85 c0                	test   %eax,%eax
80104a83:	74 3e                	je     80104ac3 <sys_chdir+0x7b>
80104a85:	83 ec 0c             	sub    $0xc,%esp
80104a88:	50                   	push   %eax
80104a89:	e8 ff ca ff ff       	call   8010158d <ilock>
80104a8e:	83 c4 10             	add    $0x10,%esp
80104a91:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a96:	75 37                	jne    80104acf <sys_chdir+0x87>
80104a98:	83 ec 0c             	sub    $0xc,%esp
80104a9b:	53                   	push   %ebx
80104a9c:	e8 ae cb ff ff       	call   8010164f <iunlock>
80104aa1:	83 c4 04             	add    $0x4,%esp
80104aa4:	ff 76 68             	pushl  0x68(%esi)
80104aa7:	e8 e8 cb ff ff       	call   80101694 <iput>
80104aac:	e8 79 de ff ff       	call   8010292a <end_op>
80104ab1:	89 5e 68             	mov    %ebx,0x68(%esi)
80104ab4:	83 c4 10             	add    $0x10,%esp
80104ab7:	b8 00 00 00 00       	mov    $0x0,%eax
80104abc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104abf:	5b                   	pop    %ebx
80104ac0:	5e                   	pop    %esi
80104ac1:	5d                   	pop    %ebp
80104ac2:	c3                   	ret    
80104ac3:	e8 62 de ff ff       	call   8010292a <end_op>
80104ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104acd:	eb ed                	jmp    80104abc <sys_chdir+0x74>
80104acf:	83 ec 0c             	sub    $0xc,%esp
80104ad2:	53                   	push   %ebx
80104ad3:	e8 5c cc ff ff       	call   80101734 <iunlockput>
80104ad8:	e8 4d de ff ff       	call   8010292a <end_op>
80104add:	83 c4 10             	add    $0x10,%esp
80104ae0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae5:	eb d5                	jmp    80104abc <sys_chdir+0x74>

80104ae7 <sys_exec>:
80104ae7:	55                   	push   %ebp
80104ae8:	89 e5                	mov    %esp,%ebp
80104aea:	53                   	push   %ebx
80104aeb:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
80104af1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104af4:	50                   	push   %eax
80104af5:	6a 00                	push   $0x0
80104af7:	e8 38 f5 ff ff       	call   80104034 <argstr>
80104afc:	83 c4 10             	add    $0x10,%esp
80104aff:	85 c0                	test   %eax,%eax
80104b01:	0f 88 a8 00 00 00    	js     80104baf <sys_exec+0xc8>
80104b07:	83 ec 08             	sub    $0x8,%esp
80104b0a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104b10:	50                   	push   %eax
80104b11:	6a 01                	push   $0x1
80104b13:	e8 8c f4 ff ff       	call   80103fa4 <argint>
80104b18:	83 c4 10             	add    $0x10,%esp
80104b1b:	85 c0                	test   %eax,%eax
80104b1d:	0f 88 93 00 00 00    	js     80104bb6 <sys_exec+0xcf>
80104b23:	83 ec 04             	sub    $0x4,%esp
80104b26:	68 80 00 00 00       	push   $0x80
80104b2b:	6a 00                	push   $0x0
80104b2d:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b33:	50                   	push   %eax
80104b34:	e8 20 f2 ff ff       	call   80103d59 <memset>
80104b39:	83 c4 10             	add    $0x10,%esp
80104b3c:	bb 00 00 00 00       	mov    $0x0,%ebx
80104b41:	83 fb 1f             	cmp    $0x1f,%ebx
80104b44:	77 77                	ja     80104bbd <sys_exec+0xd6>
80104b46:	83 ec 08             	sub    $0x8,%esp
80104b49:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b4f:	50                   	push   %eax
80104b50:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b56:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b59:	50                   	push   %eax
80104b5a:	e8 c9 f3 ff ff       	call   80103f28 <fetchint>
80104b5f:	83 c4 10             	add    $0x10,%esp
80104b62:	85 c0                	test   %eax,%eax
80104b64:	78 5e                	js     80104bc4 <sys_exec+0xdd>
80104b66:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104b6c:	85 c0                	test   %eax,%eax
80104b6e:	74 1d                	je     80104b8d <sys_exec+0xa6>
80104b70:	83 ec 08             	sub    $0x8,%esp
80104b73:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104b7a:	52                   	push   %edx
80104b7b:	50                   	push   %eax
80104b7c:	e8 e3 f3 ff ff       	call   80103f64 <fetchstr>
80104b81:	83 c4 10             	add    $0x10,%esp
80104b84:	85 c0                	test   %eax,%eax
80104b86:	78 46                	js     80104bce <sys_exec+0xe7>
80104b88:	83 c3 01             	add    $0x1,%ebx
80104b8b:	eb b4                	jmp    80104b41 <sys_exec+0x5a>
80104b8d:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104b94:	00 00 00 00 
80104b98:	83 ec 08             	sub    $0x8,%esp
80104b9b:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104ba1:	50                   	push   %eax
80104ba2:	ff 75 f4             	pushl  -0xc(%ebp)
80104ba5:	e8 28 bd ff ff       	call   801008d2 <exec>
80104baa:	83 c4 10             	add    $0x10,%esp
80104bad:	eb 1a                	jmp    80104bc9 <sys_exec+0xe2>
80104baf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb4:	eb 13                	jmp    80104bc9 <sys_exec+0xe2>
80104bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bbb:	eb 0c                	jmp    80104bc9 <sys_exec+0xe2>
80104bbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bc2:	eb 05                	jmp    80104bc9 <sys_exec+0xe2>
80104bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bcc:	c9                   	leave  
80104bcd:	c3                   	ret    
80104bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bd3:	eb f4                	jmp    80104bc9 <sys_exec+0xe2>

80104bd5 <sys_pipe>:
80104bd5:	55                   	push   %ebp
80104bd6:	89 e5                	mov    %esp,%ebp
80104bd8:	53                   	push   %ebx
80104bd9:	83 ec 18             	sub    $0x18,%esp
80104bdc:	6a 08                	push   $0x8
80104bde:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104be1:	50                   	push   %eax
80104be2:	6a 00                	push   $0x0
80104be4:	e8 e3 f3 ff ff       	call   80103fcc <argptr>
80104be9:	83 c4 10             	add    $0x10,%esp
80104bec:	85 c0                	test   %eax,%eax
80104bee:	78 77                	js     80104c67 <sys_pipe+0x92>
80104bf0:	83 ec 08             	sub    $0x8,%esp
80104bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104bf6:	50                   	push   %eax
80104bf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bfa:	50                   	push   %eax
80104bfb:	e8 3c e2 ff ff       	call   80102e3c <pipealloc>
80104c00:	83 c4 10             	add    $0x10,%esp
80104c03:	85 c0                	test   %eax,%eax
80104c05:	78 67                	js     80104c6e <sys_pipe+0x99>
80104c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c0a:	e8 14 f5 ff ff       	call   80104123 <fdalloc>
80104c0f:	89 c3                	mov    %eax,%ebx
80104c11:	85 c0                	test   %eax,%eax
80104c13:	78 21                	js     80104c36 <sys_pipe+0x61>
80104c15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c18:	e8 06 f5 ff ff       	call   80104123 <fdalloc>
80104c1d:	85 c0                	test   %eax,%eax
80104c1f:	78 15                	js     80104c36 <sys_pipe+0x61>
80104c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c24:	89 1a                	mov    %ebx,(%edx)
80104c26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c29:	89 42 04             	mov    %eax,0x4(%edx)
80104c2c:	b8 00 00 00 00       	mov    $0x0,%eax
80104c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c34:	c9                   	leave  
80104c35:	c3                   	ret    
80104c36:	85 db                	test   %ebx,%ebx
80104c38:	78 0d                	js     80104c47 <sys_pipe+0x72>
80104c3a:	e8 cc e6 ff ff       	call   8010330b <myproc>
80104c3f:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104c46:	00 
80104c47:	83 ec 0c             	sub    $0xc,%esp
80104c4a:	ff 75 f0             	pushl  -0x10(%ebp)
80104c4d:	e8 8d c0 ff ff       	call   80100cdf <fileclose>
80104c52:	83 c4 04             	add    $0x4,%esp
80104c55:	ff 75 ec             	pushl  -0x14(%ebp)
80104c58:	e8 82 c0 ff ff       	call   80100cdf <fileclose>
80104c5d:	83 c4 10             	add    $0x10,%esp
80104c60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c65:	eb ca                	jmp    80104c31 <sys_pipe+0x5c>
80104c67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6c:	eb c3                	jmp    80104c31 <sys_pipe+0x5c>
80104c6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c73:	eb bc                	jmp    80104c31 <sys_pipe+0x5c>

80104c75 <sys_fork>:
80104c75:	55                   	push   %ebp
80104c76:	89 e5                	mov    %esp,%ebp
80104c78:	83 ec 08             	sub    $0x8,%esp
80104c7b:	e8 03 e8 ff ff       	call   80103483 <fork>
80104c80:	c9                   	leave  
80104c81:	c3                   	ret    

80104c82 <sys_exit>:
80104c82:	55                   	push   %ebp
80104c83:	89 e5                	mov    %esp,%ebp
80104c85:	83 ec 08             	sub    $0x8,%esp
80104c88:	e8 2d ea ff ff       	call   801036ba <exit>
80104c8d:	b8 00 00 00 00       	mov    $0x0,%eax
80104c92:	c9                   	leave  
80104c93:	c3                   	ret    

80104c94 <sys_wait>:
80104c94:	55                   	push   %ebp
80104c95:	89 e5                	mov    %esp,%ebp
80104c97:	83 ec 08             	sub    $0x8,%esp
80104c9a:	e8 a4 eb ff ff       	call   80103843 <wait>
80104c9f:	c9                   	leave  
80104ca0:	c3                   	ret    

80104ca1 <sys_kill>:
80104ca1:	55                   	push   %ebp
80104ca2:	89 e5                	mov    %esp,%ebp
80104ca4:	83 ec 20             	sub    $0x20,%esp
80104ca7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104caa:	50                   	push   %eax
80104cab:	6a 00                	push   $0x0
80104cad:	e8 f2 f2 ff ff       	call   80103fa4 <argint>
80104cb2:	83 c4 10             	add    $0x10,%esp
80104cb5:	85 c0                	test   %eax,%eax
80104cb7:	78 10                	js     80104cc9 <sys_kill+0x28>
80104cb9:	83 ec 0c             	sub    $0xc,%esp
80104cbc:	ff 75 f4             	pushl  -0xc(%ebp)
80104cbf:	e8 7c ec ff ff       	call   80103940 <kill>
80104cc4:	83 c4 10             	add    $0x10,%esp
80104cc7:	c9                   	leave  
80104cc8:	c3                   	ret    
80104cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cce:	eb f7                	jmp    80104cc7 <sys_kill+0x26>

80104cd0 <sys_getpid>:
80104cd0:	55                   	push   %ebp
80104cd1:	89 e5                	mov    %esp,%ebp
80104cd3:	83 ec 08             	sub    $0x8,%esp
80104cd6:	e8 30 e6 ff ff       	call   8010330b <myproc>
80104cdb:	8b 40 10             	mov    0x10(%eax),%eax
80104cde:	c9                   	leave  
80104cdf:	c3                   	ret    

80104ce0 <sys_sbrk>:
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
80104ce3:	53                   	push   %ebx
80104ce4:	83 ec 1c             	sub    $0x1c,%esp
80104ce7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cea:	50                   	push   %eax
80104ceb:	6a 00                	push   $0x0
80104ced:	e8 b2 f2 ff ff       	call   80103fa4 <argint>
80104cf2:	83 c4 10             	add    $0x10,%esp
80104cf5:	85 c0                	test   %eax,%eax
80104cf7:	78 27                	js     80104d20 <sys_sbrk+0x40>
80104cf9:	e8 0d e6 ff ff       	call   8010330b <myproc>
80104cfe:	8b 18                	mov    (%eax),%ebx
80104d00:	83 ec 0c             	sub    $0xc,%esp
80104d03:	ff 75 f4             	pushl  -0xc(%ebp)
80104d06:	e8 0b e7 ff ff       	call   80103416 <growproc>
80104d0b:	83 c4 10             	add    $0x10,%esp
80104d0e:	85 c0                	test   %eax,%eax
80104d10:	78 07                	js     80104d19 <sys_sbrk+0x39>
80104d12:	89 d8                	mov    %ebx,%eax
80104d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d17:	c9                   	leave  
80104d18:	c3                   	ret    
80104d19:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104d1e:	eb f2                	jmp    80104d12 <sys_sbrk+0x32>
80104d20:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104d25:	eb eb                	jmp    80104d12 <sys_sbrk+0x32>

80104d27 <sys_sleep>:
80104d27:	55                   	push   %ebp
80104d28:	89 e5                	mov    %esp,%ebp
80104d2a:	53                   	push   %ebx
80104d2b:	83 ec 1c             	sub    $0x1c,%esp
80104d2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d31:	50                   	push   %eax
80104d32:	6a 00                	push   $0x0
80104d34:	e8 6b f2 ff ff       	call   80103fa4 <argint>
80104d39:	83 c4 10             	add    $0x10,%esp
80104d3c:	85 c0                	test   %eax,%eax
80104d3e:	78 75                	js     80104db5 <sys_sleep+0x8e>
80104d40:	83 ec 0c             	sub    $0xc,%esp
80104d43:	68 80 3c 12 80       	push   $0x80123c80
80104d48:	e8 60 ef ff ff       	call   80103cad <acquire>
80104d4d:	8b 1d c0 44 12 80    	mov    0x801244c0,%ebx
80104d53:	83 c4 10             	add    $0x10,%esp
80104d56:	a1 c0 44 12 80       	mov    0x801244c0,%eax
80104d5b:	29 d8                	sub    %ebx,%eax
80104d5d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d60:	73 39                	jae    80104d9b <sys_sleep+0x74>
80104d62:	e8 a4 e5 ff ff       	call   8010330b <myproc>
80104d67:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104d6b:	75 17                	jne    80104d84 <sys_sleep+0x5d>
80104d6d:	83 ec 08             	sub    $0x8,%esp
80104d70:	68 80 3c 12 80       	push   $0x80123c80
80104d75:	68 c0 44 12 80       	push   $0x801244c0
80104d7a:	e8 33 ea ff ff       	call   801037b2 <sleep>
80104d7f:	83 c4 10             	add    $0x10,%esp
80104d82:	eb d2                	jmp    80104d56 <sys_sleep+0x2f>
80104d84:	83 ec 0c             	sub    $0xc,%esp
80104d87:	68 80 3c 12 80       	push   $0x80123c80
80104d8c:	e8 81 ef ff ff       	call   80103d12 <release>
80104d91:	83 c4 10             	add    $0x10,%esp
80104d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d99:	eb 15                	jmp    80104db0 <sys_sleep+0x89>
80104d9b:	83 ec 0c             	sub    $0xc,%esp
80104d9e:	68 80 3c 12 80       	push   $0x80123c80
80104da3:	e8 6a ef ff ff       	call   80103d12 <release>
80104da8:	83 c4 10             	add    $0x10,%esp
80104dab:	b8 00 00 00 00       	mov    $0x0,%eax
80104db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104db3:	c9                   	leave  
80104db4:	c3                   	ret    
80104db5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dba:	eb f4                	jmp    80104db0 <sys_sleep+0x89>

80104dbc <sys_uptime>:
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	53                   	push   %ebx
80104dc0:	83 ec 10             	sub    $0x10,%esp
80104dc3:	68 80 3c 12 80       	push   $0x80123c80
80104dc8:	e8 e0 ee ff ff       	call   80103cad <acquire>
80104dcd:	8b 1d c0 44 12 80    	mov    0x801244c0,%ebx
80104dd3:	c7 04 24 80 3c 12 80 	movl   $0x80123c80,(%esp)
80104dda:	e8 33 ef ff ff       	call   80103d12 <release>
80104ddf:	89 d8                	mov    %ebx,%eax
80104de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104de4:	c9                   	leave  
80104de5:	c3                   	ret    

80104de6 <sys_dump_physmem>:
80104de6:	55                   	push   %ebp
80104de7:	89 e5                	mov    %esp,%ebp
80104de9:	83 ec 1c             	sub    $0x1c,%esp
80104dec:	6a 04                	push   $0x4
80104dee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104df1:	50                   	push   %eax
80104df2:	6a 00                	push   $0x0
80104df4:	e8 d3 f1 ff ff       	call   80103fcc <argptr>
80104df9:	83 c4 10             	add    $0x10,%esp
80104dfc:	85 c0                	test   %eax,%eax
80104dfe:	78 42                	js     80104e42 <sys_dump_physmem+0x5c>
80104e00:	83 ec 04             	sub    $0x4,%esp
80104e03:	6a 04                	push   $0x4
80104e05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e08:	50                   	push   %eax
80104e09:	6a 01                	push   $0x1
80104e0b:	e8 bc f1 ff ff       	call   80103fcc <argptr>
80104e10:	83 c4 10             	add    $0x10,%esp
80104e13:	85 c0                	test   %eax,%eax
80104e15:	78 32                	js     80104e49 <sys_dump_physmem+0x63>
80104e17:	83 ec 08             	sub    $0x8,%esp
80104e1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104e1d:	50                   	push   %eax
80104e1e:	6a 02                	push   $0x2
80104e20:	e8 7f f1 ff ff       	call   80103fa4 <argint>
80104e25:	83 c4 10             	add    $0x10,%esp
80104e28:	85 c0                	test   %eax,%eax
80104e2a:	78 24                	js     80104e50 <sys_dump_physmem+0x6a>
80104e2c:	83 ec 04             	sub    $0x4,%esp
80104e2f:	ff 75 ec             	pushl  -0x14(%ebp)
80104e32:	ff 75 f0             	pushl  -0x10(%ebp)
80104e35:	ff 75 f4             	pushl  -0xc(%ebp)
80104e38:	e8 52 d3 ff ff       	call   8010218f <dump_physmem>
80104e3d:	83 c4 10             	add    $0x10,%esp
80104e40:	c9                   	leave  
80104e41:	c3                   	ret    
80104e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e47:	eb f7                	jmp    80104e40 <sys_dump_physmem+0x5a>
80104e49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4e:	eb f0                	jmp    80104e40 <sys_dump_physmem+0x5a>
80104e50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e55:	eb e9                	jmp    80104e40 <sys_dump_physmem+0x5a>

80104e57 <alltraps>:
80104e57:	1e                   	push   %ds
80104e58:	06                   	push   %es
80104e59:	0f a0                	push   %fs
80104e5b:	0f a8                	push   %gs
80104e5d:	60                   	pusha  
80104e5e:	66 b8 10 00          	mov    $0x10,%ax
80104e62:	8e d8                	mov    %eax,%ds
80104e64:	8e c0                	mov    %eax,%es
80104e66:	54                   	push   %esp
80104e67:	e8 e3 00 00 00       	call   80104f4f <trap>
80104e6c:	83 c4 04             	add    $0x4,%esp

80104e6f <trapret>:
80104e6f:	61                   	popa   
80104e70:	0f a9                	pop    %gs
80104e72:	0f a1                	pop    %fs
80104e74:	07                   	pop    %es
80104e75:	1f                   	pop    %ds
80104e76:	83 c4 08             	add    $0x8,%esp
80104e79:	cf                   	iret   

80104e7a <tvinit>:
80104e7a:	55                   	push   %ebp
80104e7b:	89 e5                	mov    %esp,%ebp
80104e7d:	83 ec 08             	sub    $0x8,%esp
80104e80:	b8 00 00 00 00       	mov    $0x0,%eax
80104e85:	eb 4a                	jmp    80104ed1 <tvinit+0x57>
80104e87:	8b 0c 85 08 90 10 80 	mov    -0x7fef6ff8(,%eax,4),%ecx
80104e8e:	66 89 0c c5 c0 3c 12 	mov    %cx,-0x7fedc340(,%eax,8)
80104e95:	80 
80104e96:	66 c7 04 c5 c2 3c 12 	movw   $0x8,-0x7fedc33e(,%eax,8)
80104e9d:	80 08 00 
80104ea0:	c6 04 c5 c4 3c 12 80 	movb   $0x0,-0x7fedc33c(,%eax,8)
80104ea7:	00 
80104ea8:	0f b6 14 c5 c5 3c 12 	movzbl -0x7fedc33b(,%eax,8),%edx
80104eaf:	80 
80104eb0:	83 e2 f0             	and    $0xfffffff0,%edx
80104eb3:	83 ca 0e             	or     $0xe,%edx
80104eb6:	83 e2 8f             	and    $0xffffff8f,%edx
80104eb9:	83 ca 80             	or     $0xffffff80,%edx
80104ebc:	88 14 c5 c5 3c 12 80 	mov    %dl,-0x7fedc33b(,%eax,8)
80104ec3:	c1 e9 10             	shr    $0x10,%ecx
80104ec6:	66 89 0c c5 c6 3c 12 	mov    %cx,-0x7fedc33a(,%eax,8)
80104ecd:	80 
80104ece:	83 c0 01             	add    $0x1,%eax
80104ed1:	3d ff 00 00 00       	cmp    $0xff,%eax
80104ed6:	7e af                	jle    80104e87 <tvinit+0xd>
80104ed8:	8b 15 08 91 10 80    	mov    0x80109108,%edx
80104ede:	66 89 15 c0 3e 12 80 	mov    %dx,0x80123ec0
80104ee5:	66 c7 05 c2 3e 12 80 	movw   $0x8,0x80123ec2
80104eec:	08 00 
80104eee:	c6 05 c4 3e 12 80 00 	movb   $0x0,0x80123ec4
80104ef5:	0f b6 05 c5 3e 12 80 	movzbl 0x80123ec5,%eax
80104efc:	83 c8 0f             	or     $0xf,%eax
80104eff:	83 e0 ef             	and    $0xffffffef,%eax
80104f02:	83 c8 e0             	or     $0xffffffe0,%eax
80104f05:	a2 c5 3e 12 80       	mov    %al,0x80123ec5
80104f0a:	c1 ea 10             	shr    $0x10,%edx
80104f0d:	66 89 15 c6 3e 12 80 	mov    %dx,0x80123ec6
80104f14:	83 ec 08             	sub    $0x8,%esp
80104f17:	68 7d 6d 10 80       	push   $0x80106d7d
80104f1c:	68 80 3c 12 80       	push   $0x80123c80
80104f21:	e8 4b ec ff ff       	call   80103b71 <initlock>
80104f26:	83 c4 10             	add    $0x10,%esp
80104f29:	c9                   	leave  
80104f2a:	c3                   	ret    

80104f2b <idtinit>:
80104f2b:	55                   	push   %ebp
80104f2c:	89 e5                	mov    %esp,%ebp
80104f2e:	83 ec 10             	sub    $0x10,%esp
80104f31:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
80104f37:	b8 c0 3c 12 80       	mov    $0x80123cc0,%eax
80104f3c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80104f40:	c1 e8 10             	shr    $0x10,%eax
80104f43:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
80104f47:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104f4a:	0f 01 18             	lidtl  (%eax)
80104f4d:	c9                   	leave  
80104f4e:	c3                   	ret    

80104f4f <trap>:
80104f4f:	55                   	push   %ebp
80104f50:	89 e5                	mov    %esp,%ebp
80104f52:	57                   	push   %edi
80104f53:	56                   	push   %esi
80104f54:	53                   	push   %ebx
80104f55:	83 ec 1c             	sub    $0x1c,%esp
80104f58:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104f5b:	8b 43 30             	mov    0x30(%ebx),%eax
80104f5e:	83 f8 40             	cmp    $0x40,%eax
80104f61:	74 13                	je     80104f76 <trap+0x27>
80104f63:	83 e8 20             	sub    $0x20,%eax
80104f66:	83 f8 1f             	cmp    $0x1f,%eax
80104f69:	0f 87 3a 01 00 00    	ja     801050a9 <trap+0x15a>
80104f6f:	ff 24 85 24 6e 10 80 	jmp    *-0x7fef91dc(,%eax,4)
80104f76:	e8 90 e3 ff ff       	call   8010330b <myproc>
80104f7b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f7f:	75 1f                	jne    80104fa0 <trap+0x51>
80104f81:	e8 85 e3 ff ff       	call   8010330b <myproc>
80104f86:	89 58 18             	mov    %ebx,0x18(%eax)
80104f89:	e8 d9 f0 ff ff       	call   80104067 <syscall>
80104f8e:	e8 78 e3 ff ff       	call   8010330b <myproc>
80104f93:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f97:	74 7e                	je     80105017 <trap+0xc8>
80104f99:	e8 1c e7 ff ff       	call   801036ba <exit>
80104f9e:	eb 77                	jmp    80105017 <trap+0xc8>
80104fa0:	e8 15 e7 ff ff       	call   801036ba <exit>
80104fa5:	eb da                	jmp    80104f81 <trap+0x32>
80104fa7:	e8 44 e3 ff ff       	call   801032f0 <cpuid>
80104fac:	85 c0                	test   %eax,%eax
80104fae:	74 6f                	je     8010501f <trap+0xd0>
80104fb0:	e8 e6 d4 ff ff       	call   8010249b <lapiceoi>
80104fb5:	e8 51 e3 ff ff       	call   8010330b <myproc>
80104fba:	85 c0                	test   %eax,%eax
80104fbc:	74 1c                	je     80104fda <trap+0x8b>
80104fbe:	e8 48 e3 ff ff       	call   8010330b <myproc>
80104fc3:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fc7:	74 11                	je     80104fda <trap+0x8b>
80104fc9:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104fcd:	83 e0 03             	and    $0x3,%eax
80104fd0:	66 83 f8 03          	cmp    $0x3,%ax
80104fd4:	0f 84 62 01 00 00    	je     8010513c <trap+0x1ed>
80104fda:	e8 2c e3 ff ff       	call   8010330b <myproc>
80104fdf:	85 c0                	test   %eax,%eax
80104fe1:	74 0f                	je     80104ff2 <trap+0xa3>
80104fe3:	e8 23 e3 ff ff       	call   8010330b <myproc>
80104fe8:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104fec:	0f 84 54 01 00 00    	je     80105146 <trap+0x1f7>
80104ff2:	e8 14 e3 ff ff       	call   8010330b <myproc>
80104ff7:	85 c0                	test   %eax,%eax
80104ff9:	74 1c                	je     80105017 <trap+0xc8>
80104ffb:	e8 0b e3 ff ff       	call   8010330b <myproc>
80105000:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105004:	74 11                	je     80105017 <trap+0xc8>
80105006:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010500a:	83 e0 03             	and    $0x3,%eax
8010500d:	66 83 f8 03          	cmp    $0x3,%ax
80105011:	0f 84 43 01 00 00    	je     8010515a <trap+0x20b>
80105017:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010501a:	5b                   	pop    %ebx
8010501b:	5e                   	pop    %esi
8010501c:	5f                   	pop    %edi
8010501d:	5d                   	pop    %ebp
8010501e:	c3                   	ret    
8010501f:	83 ec 0c             	sub    $0xc,%esp
80105022:	68 80 3c 12 80       	push   $0x80123c80
80105027:	e8 81 ec ff ff       	call   80103cad <acquire>
8010502c:	83 05 c0 44 12 80 01 	addl   $0x1,0x801244c0
80105033:	c7 04 24 c0 44 12 80 	movl   $0x801244c0,(%esp)
8010503a:	e8 d8 e8 ff ff       	call   80103917 <wakeup>
8010503f:	c7 04 24 80 3c 12 80 	movl   $0x80123c80,(%esp)
80105046:	e8 c7 ec ff ff       	call   80103d12 <release>
8010504b:	83 c4 10             	add    $0x10,%esp
8010504e:	e9 5d ff ff ff       	jmp    80104fb0 <trap+0x61>
80105053:	e8 27 cd ff ff       	call   80101d7f <ideintr>
80105058:	e8 3e d4 ff ff       	call   8010249b <lapiceoi>
8010505d:	e9 53 ff ff ff       	jmp    80104fb5 <trap+0x66>
80105062:	e8 78 d2 ff ff       	call   801022df <kbdintr>
80105067:	e8 2f d4 ff ff       	call   8010249b <lapiceoi>
8010506c:	e9 44 ff ff ff       	jmp    80104fb5 <trap+0x66>
80105071:	e8 05 02 00 00       	call   8010527b <uartintr>
80105076:	e8 20 d4 ff ff       	call   8010249b <lapiceoi>
8010507b:	e9 35 ff ff ff       	jmp    80104fb5 <trap+0x66>
80105080:	8b 7b 38             	mov    0x38(%ebx),%edi
80105083:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105087:	e8 64 e2 ff ff       	call   801032f0 <cpuid>
8010508c:	57                   	push   %edi
8010508d:	0f b7 f6             	movzwl %si,%esi
80105090:	56                   	push   %esi
80105091:	50                   	push   %eax
80105092:	68 88 6d 10 80       	push   $0x80106d88
80105097:	e8 6f b5 ff ff       	call   8010060b <cprintf>
8010509c:	e8 fa d3 ff ff       	call   8010249b <lapiceoi>
801050a1:	83 c4 10             	add    $0x10,%esp
801050a4:	e9 0c ff ff ff       	jmp    80104fb5 <trap+0x66>
801050a9:	e8 5d e2 ff ff       	call   8010330b <myproc>
801050ae:	85 c0                	test   %eax,%eax
801050b0:	74 5f                	je     80105111 <trap+0x1c2>
801050b2:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801050b6:	74 59                	je     80105111 <trap+0x1c2>
801050b8:	0f 20 d7             	mov    %cr2,%edi
801050bb:	8b 43 38             	mov    0x38(%ebx),%eax
801050be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801050c1:	e8 2a e2 ff ff       	call   801032f0 <cpuid>
801050c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801050c9:	8b 53 34             	mov    0x34(%ebx),%edx
801050cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
801050cf:	8b 73 30             	mov    0x30(%ebx),%esi
801050d2:	e8 34 e2 ff ff       	call   8010330b <myproc>
801050d7:	8d 48 6c             	lea    0x6c(%eax),%ecx
801050da:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801050dd:	e8 29 e2 ff ff       	call   8010330b <myproc>
801050e2:	57                   	push   %edi
801050e3:	ff 75 e4             	pushl  -0x1c(%ebp)
801050e6:	ff 75 e0             	pushl  -0x20(%ebp)
801050e9:	ff 75 dc             	pushl  -0x24(%ebp)
801050ec:	56                   	push   %esi
801050ed:	ff 75 d8             	pushl  -0x28(%ebp)
801050f0:	ff 70 10             	pushl  0x10(%eax)
801050f3:	68 e0 6d 10 80       	push   $0x80106de0
801050f8:	e8 0e b5 ff ff       	call   8010060b <cprintf>
801050fd:	83 c4 20             	add    $0x20,%esp
80105100:	e8 06 e2 ff ff       	call   8010330b <myproc>
80105105:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010510c:	e9 a4 fe ff ff       	jmp    80104fb5 <trap+0x66>
80105111:	0f 20 d7             	mov    %cr2,%edi
80105114:	8b 73 38             	mov    0x38(%ebx),%esi
80105117:	e8 d4 e1 ff ff       	call   801032f0 <cpuid>
8010511c:	83 ec 0c             	sub    $0xc,%esp
8010511f:	57                   	push   %edi
80105120:	56                   	push   %esi
80105121:	50                   	push   %eax
80105122:	ff 73 30             	pushl  0x30(%ebx)
80105125:	68 ac 6d 10 80       	push   $0x80106dac
8010512a:	e8 dc b4 ff ff       	call   8010060b <cprintf>
8010512f:	83 c4 14             	add    $0x14,%esp
80105132:	68 82 6d 10 80       	push   $0x80106d82
80105137:	e8 0c b2 ff ff       	call   80100348 <panic>
8010513c:	e8 79 e5 ff ff       	call   801036ba <exit>
80105141:	e9 94 fe ff ff       	jmp    80104fda <trap+0x8b>
80105146:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010514a:	0f 85 a2 fe ff ff    	jne    80104ff2 <trap+0xa3>
80105150:	e8 2b e6 ff ff       	call   80103780 <yield>
80105155:	e9 98 fe ff ff       	jmp    80104ff2 <trap+0xa3>
8010515a:	e8 5b e5 ff ff       	call   801036ba <exit>
8010515f:	e9 b3 fe ff ff       	jmp    80105017 <trap+0xc8>

80105164 <uartgetc>:
80105164:	55                   	push   %ebp
80105165:	89 e5                	mov    %esp,%ebp
80105167:	83 3d c8 95 11 80 00 	cmpl   $0x0,0x801195c8
8010516e:	74 15                	je     80105185 <uartgetc+0x21>
80105170:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105175:	ec                   	in     (%dx),%al
80105176:	a8 01                	test   $0x1,%al
80105178:	74 12                	je     8010518c <uartgetc+0x28>
8010517a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010517f:	ec                   	in     (%dx),%al
80105180:	0f b6 c0             	movzbl %al,%eax
80105183:	5d                   	pop    %ebp
80105184:	c3                   	ret    
80105185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010518a:	eb f7                	jmp    80105183 <uartgetc+0x1f>
8010518c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105191:	eb f0                	jmp    80105183 <uartgetc+0x1f>

80105193 <uartputc>:
80105193:	83 3d c8 95 11 80 00 	cmpl   $0x0,0x801195c8
8010519a:	74 3b                	je     801051d7 <uartputc+0x44>
8010519c:	55                   	push   %ebp
8010519d:	89 e5                	mov    %esp,%ebp
8010519f:	53                   	push   %ebx
801051a0:	83 ec 04             	sub    $0x4,%esp
801051a3:	bb 00 00 00 00       	mov    $0x0,%ebx
801051a8:	eb 10                	jmp    801051ba <uartputc+0x27>
801051aa:	83 ec 0c             	sub    $0xc,%esp
801051ad:	6a 0a                	push   $0xa
801051af:	e8 06 d3 ff ff       	call   801024ba <microdelay>
801051b4:	83 c3 01             	add    $0x1,%ebx
801051b7:	83 c4 10             	add    $0x10,%esp
801051ba:	83 fb 7f             	cmp    $0x7f,%ebx
801051bd:	7f 0a                	jg     801051c9 <uartputc+0x36>
801051bf:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051c4:	ec                   	in     (%dx),%al
801051c5:	a8 20                	test   $0x20,%al
801051c7:	74 e1                	je     801051aa <uartputc+0x17>
801051c9:	8b 45 08             	mov    0x8(%ebp),%eax
801051cc:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051d1:	ee                   	out    %al,(%dx)
801051d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051d5:	c9                   	leave  
801051d6:	c3                   	ret    
801051d7:	f3 c3                	repz ret 

801051d9 <uartinit>:
801051d9:	55                   	push   %ebp
801051da:	89 e5                	mov    %esp,%ebp
801051dc:	56                   	push   %esi
801051dd:	53                   	push   %ebx
801051de:	b9 00 00 00 00       	mov    $0x0,%ecx
801051e3:	ba fa 03 00 00       	mov    $0x3fa,%edx
801051e8:	89 c8                	mov    %ecx,%eax
801051ea:	ee                   	out    %al,(%dx)
801051eb:	be fb 03 00 00       	mov    $0x3fb,%esi
801051f0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801051f5:	89 f2                	mov    %esi,%edx
801051f7:	ee                   	out    %al,(%dx)
801051f8:	b8 0c 00 00 00       	mov    $0xc,%eax
801051fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105202:	ee                   	out    %al,(%dx)
80105203:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105208:	89 c8                	mov    %ecx,%eax
8010520a:	89 da                	mov    %ebx,%edx
8010520c:	ee                   	out    %al,(%dx)
8010520d:	b8 03 00 00 00       	mov    $0x3,%eax
80105212:	89 f2                	mov    %esi,%edx
80105214:	ee                   	out    %al,(%dx)
80105215:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010521a:	89 c8                	mov    %ecx,%eax
8010521c:	ee                   	out    %al,(%dx)
8010521d:	b8 01 00 00 00       	mov    $0x1,%eax
80105222:	89 da                	mov    %ebx,%edx
80105224:	ee                   	out    %al,(%dx)
80105225:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010522a:	ec                   	in     (%dx),%al
8010522b:	3c ff                	cmp    $0xff,%al
8010522d:	74 45                	je     80105274 <uartinit+0x9b>
8010522f:	c7 05 c8 95 11 80 01 	movl   $0x1,0x801195c8
80105236:	00 00 00 
80105239:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010523e:	ec                   	in     (%dx),%al
8010523f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105244:	ec                   	in     (%dx),%al
80105245:	83 ec 08             	sub    $0x8,%esp
80105248:	6a 00                	push   $0x0
8010524a:	6a 04                	push   $0x4
8010524c:	e8 39 cd ff ff       	call   80101f8a <ioapicenable>
80105251:	83 c4 10             	add    $0x10,%esp
80105254:	bb a4 6e 10 80       	mov    $0x80106ea4,%ebx
80105259:	eb 12                	jmp    8010526d <uartinit+0x94>
8010525b:	83 ec 0c             	sub    $0xc,%esp
8010525e:	0f be c0             	movsbl %al,%eax
80105261:	50                   	push   %eax
80105262:	e8 2c ff ff ff       	call   80105193 <uartputc>
80105267:	83 c3 01             	add    $0x1,%ebx
8010526a:	83 c4 10             	add    $0x10,%esp
8010526d:	0f b6 03             	movzbl (%ebx),%eax
80105270:	84 c0                	test   %al,%al
80105272:	75 e7                	jne    8010525b <uartinit+0x82>
80105274:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105277:	5b                   	pop    %ebx
80105278:	5e                   	pop    %esi
80105279:	5d                   	pop    %ebp
8010527a:	c3                   	ret    

8010527b <uartintr>:
8010527b:	55                   	push   %ebp
8010527c:	89 e5                	mov    %esp,%ebp
8010527e:	83 ec 14             	sub    $0x14,%esp
80105281:	68 64 51 10 80       	push   $0x80105164
80105286:	e8 b3 b4 ff ff       	call   8010073e <consoleintr>
8010528b:	83 c4 10             	add    $0x10,%esp
8010528e:	c9                   	leave  
8010528f:	c3                   	ret    

80105290 <vector0>:
80105290:	6a 00                	push   $0x0
80105292:	6a 00                	push   $0x0
80105294:	e9 be fb ff ff       	jmp    80104e57 <alltraps>

80105299 <vector1>:
80105299:	6a 00                	push   $0x0
8010529b:	6a 01                	push   $0x1
8010529d:	e9 b5 fb ff ff       	jmp    80104e57 <alltraps>

801052a2 <vector2>:
801052a2:	6a 00                	push   $0x0
801052a4:	6a 02                	push   $0x2
801052a6:	e9 ac fb ff ff       	jmp    80104e57 <alltraps>

801052ab <vector3>:
801052ab:	6a 00                	push   $0x0
801052ad:	6a 03                	push   $0x3
801052af:	e9 a3 fb ff ff       	jmp    80104e57 <alltraps>

801052b4 <vector4>:
801052b4:	6a 00                	push   $0x0
801052b6:	6a 04                	push   $0x4
801052b8:	e9 9a fb ff ff       	jmp    80104e57 <alltraps>

801052bd <vector5>:
801052bd:	6a 00                	push   $0x0
801052bf:	6a 05                	push   $0x5
801052c1:	e9 91 fb ff ff       	jmp    80104e57 <alltraps>

801052c6 <vector6>:
801052c6:	6a 00                	push   $0x0
801052c8:	6a 06                	push   $0x6
801052ca:	e9 88 fb ff ff       	jmp    80104e57 <alltraps>

801052cf <vector7>:
801052cf:	6a 00                	push   $0x0
801052d1:	6a 07                	push   $0x7
801052d3:	e9 7f fb ff ff       	jmp    80104e57 <alltraps>

801052d8 <vector8>:
801052d8:	6a 08                	push   $0x8
801052da:	e9 78 fb ff ff       	jmp    80104e57 <alltraps>

801052df <vector9>:
801052df:	6a 00                	push   $0x0
801052e1:	6a 09                	push   $0x9
801052e3:	e9 6f fb ff ff       	jmp    80104e57 <alltraps>

801052e8 <vector10>:
801052e8:	6a 0a                	push   $0xa
801052ea:	e9 68 fb ff ff       	jmp    80104e57 <alltraps>

801052ef <vector11>:
801052ef:	6a 0b                	push   $0xb
801052f1:	e9 61 fb ff ff       	jmp    80104e57 <alltraps>

801052f6 <vector12>:
801052f6:	6a 0c                	push   $0xc
801052f8:	e9 5a fb ff ff       	jmp    80104e57 <alltraps>

801052fd <vector13>:
801052fd:	6a 0d                	push   $0xd
801052ff:	e9 53 fb ff ff       	jmp    80104e57 <alltraps>

80105304 <vector14>:
80105304:	6a 0e                	push   $0xe
80105306:	e9 4c fb ff ff       	jmp    80104e57 <alltraps>

8010530b <vector15>:
8010530b:	6a 00                	push   $0x0
8010530d:	6a 0f                	push   $0xf
8010530f:	e9 43 fb ff ff       	jmp    80104e57 <alltraps>

80105314 <vector16>:
80105314:	6a 00                	push   $0x0
80105316:	6a 10                	push   $0x10
80105318:	e9 3a fb ff ff       	jmp    80104e57 <alltraps>

8010531d <vector17>:
8010531d:	6a 11                	push   $0x11
8010531f:	e9 33 fb ff ff       	jmp    80104e57 <alltraps>

80105324 <vector18>:
80105324:	6a 00                	push   $0x0
80105326:	6a 12                	push   $0x12
80105328:	e9 2a fb ff ff       	jmp    80104e57 <alltraps>

8010532d <vector19>:
8010532d:	6a 00                	push   $0x0
8010532f:	6a 13                	push   $0x13
80105331:	e9 21 fb ff ff       	jmp    80104e57 <alltraps>

80105336 <vector20>:
80105336:	6a 00                	push   $0x0
80105338:	6a 14                	push   $0x14
8010533a:	e9 18 fb ff ff       	jmp    80104e57 <alltraps>

8010533f <vector21>:
8010533f:	6a 00                	push   $0x0
80105341:	6a 15                	push   $0x15
80105343:	e9 0f fb ff ff       	jmp    80104e57 <alltraps>

80105348 <vector22>:
80105348:	6a 00                	push   $0x0
8010534a:	6a 16                	push   $0x16
8010534c:	e9 06 fb ff ff       	jmp    80104e57 <alltraps>

80105351 <vector23>:
80105351:	6a 00                	push   $0x0
80105353:	6a 17                	push   $0x17
80105355:	e9 fd fa ff ff       	jmp    80104e57 <alltraps>

8010535a <vector24>:
8010535a:	6a 00                	push   $0x0
8010535c:	6a 18                	push   $0x18
8010535e:	e9 f4 fa ff ff       	jmp    80104e57 <alltraps>

80105363 <vector25>:
80105363:	6a 00                	push   $0x0
80105365:	6a 19                	push   $0x19
80105367:	e9 eb fa ff ff       	jmp    80104e57 <alltraps>

8010536c <vector26>:
8010536c:	6a 00                	push   $0x0
8010536e:	6a 1a                	push   $0x1a
80105370:	e9 e2 fa ff ff       	jmp    80104e57 <alltraps>

80105375 <vector27>:
80105375:	6a 00                	push   $0x0
80105377:	6a 1b                	push   $0x1b
80105379:	e9 d9 fa ff ff       	jmp    80104e57 <alltraps>

8010537e <vector28>:
8010537e:	6a 00                	push   $0x0
80105380:	6a 1c                	push   $0x1c
80105382:	e9 d0 fa ff ff       	jmp    80104e57 <alltraps>

80105387 <vector29>:
80105387:	6a 00                	push   $0x0
80105389:	6a 1d                	push   $0x1d
8010538b:	e9 c7 fa ff ff       	jmp    80104e57 <alltraps>

80105390 <vector30>:
80105390:	6a 00                	push   $0x0
80105392:	6a 1e                	push   $0x1e
80105394:	e9 be fa ff ff       	jmp    80104e57 <alltraps>

80105399 <vector31>:
80105399:	6a 00                	push   $0x0
8010539b:	6a 1f                	push   $0x1f
8010539d:	e9 b5 fa ff ff       	jmp    80104e57 <alltraps>

801053a2 <vector32>:
801053a2:	6a 00                	push   $0x0
801053a4:	6a 20                	push   $0x20
801053a6:	e9 ac fa ff ff       	jmp    80104e57 <alltraps>

801053ab <vector33>:
801053ab:	6a 00                	push   $0x0
801053ad:	6a 21                	push   $0x21
801053af:	e9 a3 fa ff ff       	jmp    80104e57 <alltraps>

801053b4 <vector34>:
801053b4:	6a 00                	push   $0x0
801053b6:	6a 22                	push   $0x22
801053b8:	e9 9a fa ff ff       	jmp    80104e57 <alltraps>

801053bd <vector35>:
801053bd:	6a 00                	push   $0x0
801053bf:	6a 23                	push   $0x23
801053c1:	e9 91 fa ff ff       	jmp    80104e57 <alltraps>

801053c6 <vector36>:
801053c6:	6a 00                	push   $0x0
801053c8:	6a 24                	push   $0x24
801053ca:	e9 88 fa ff ff       	jmp    80104e57 <alltraps>

801053cf <vector37>:
801053cf:	6a 00                	push   $0x0
801053d1:	6a 25                	push   $0x25
801053d3:	e9 7f fa ff ff       	jmp    80104e57 <alltraps>

801053d8 <vector38>:
801053d8:	6a 00                	push   $0x0
801053da:	6a 26                	push   $0x26
801053dc:	e9 76 fa ff ff       	jmp    80104e57 <alltraps>

801053e1 <vector39>:
801053e1:	6a 00                	push   $0x0
801053e3:	6a 27                	push   $0x27
801053e5:	e9 6d fa ff ff       	jmp    80104e57 <alltraps>

801053ea <vector40>:
801053ea:	6a 00                	push   $0x0
801053ec:	6a 28                	push   $0x28
801053ee:	e9 64 fa ff ff       	jmp    80104e57 <alltraps>

801053f3 <vector41>:
801053f3:	6a 00                	push   $0x0
801053f5:	6a 29                	push   $0x29
801053f7:	e9 5b fa ff ff       	jmp    80104e57 <alltraps>

801053fc <vector42>:
801053fc:	6a 00                	push   $0x0
801053fe:	6a 2a                	push   $0x2a
80105400:	e9 52 fa ff ff       	jmp    80104e57 <alltraps>

80105405 <vector43>:
80105405:	6a 00                	push   $0x0
80105407:	6a 2b                	push   $0x2b
80105409:	e9 49 fa ff ff       	jmp    80104e57 <alltraps>

8010540e <vector44>:
8010540e:	6a 00                	push   $0x0
80105410:	6a 2c                	push   $0x2c
80105412:	e9 40 fa ff ff       	jmp    80104e57 <alltraps>

80105417 <vector45>:
80105417:	6a 00                	push   $0x0
80105419:	6a 2d                	push   $0x2d
8010541b:	e9 37 fa ff ff       	jmp    80104e57 <alltraps>

80105420 <vector46>:
80105420:	6a 00                	push   $0x0
80105422:	6a 2e                	push   $0x2e
80105424:	e9 2e fa ff ff       	jmp    80104e57 <alltraps>

80105429 <vector47>:
80105429:	6a 00                	push   $0x0
8010542b:	6a 2f                	push   $0x2f
8010542d:	e9 25 fa ff ff       	jmp    80104e57 <alltraps>

80105432 <vector48>:
80105432:	6a 00                	push   $0x0
80105434:	6a 30                	push   $0x30
80105436:	e9 1c fa ff ff       	jmp    80104e57 <alltraps>

8010543b <vector49>:
8010543b:	6a 00                	push   $0x0
8010543d:	6a 31                	push   $0x31
8010543f:	e9 13 fa ff ff       	jmp    80104e57 <alltraps>

80105444 <vector50>:
80105444:	6a 00                	push   $0x0
80105446:	6a 32                	push   $0x32
80105448:	e9 0a fa ff ff       	jmp    80104e57 <alltraps>

8010544d <vector51>:
8010544d:	6a 00                	push   $0x0
8010544f:	6a 33                	push   $0x33
80105451:	e9 01 fa ff ff       	jmp    80104e57 <alltraps>

80105456 <vector52>:
80105456:	6a 00                	push   $0x0
80105458:	6a 34                	push   $0x34
8010545a:	e9 f8 f9 ff ff       	jmp    80104e57 <alltraps>

8010545f <vector53>:
8010545f:	6a 00                	push   $0x0
80105461:	6a 35                	push   $0x35
80105463:	e9 ef f9 ff ff       	jmp    80104e57 <alltraps>

80105468 <vector54>:
80105468:	6a 00                	push   $0x0
8010546a:	6a 36                	push   $0x36
8010546c:	e9 e6 f9 ff ff       	jmp    80104e57 <alltraps>

80105471 <vector55>:
80105471:	6a 00                	push   $0x0
80105473:	6a 37                	push   $0x37
80105475:	e9 dd f9 ff ff       	jmp    80104e57 <alltraps>

8010547a <vector56>:
8010547a:	6a 00                	push   $0x0
8010547c:	6a 38                	push   $0x38
8010547e:	e9 d4 f9 ff ff       	jmp    80104e57 <alltraps>

80105483 <vector57>:
80105483:	6a 00                	push   $0x0
80105485:	6a 39                	push   $0x39
80105487:	e9 cb f9 ff ff       	jmp    80104e57 <alltraps>

8010548c <vector58>:
8010548c:	6a 00                	push   $0x0
8010548e:	6a 3a                	push   $0x3a
80105490:	e9 c2 f9 ff ff       	jmp    80104e57 <alltraps>

80105495 <vector59>:
80105495:	6a 00                	push   $0x0
80105497:	6a 3b                	push   $0x3b
80105499:	e9 b9 f9 ff ff       	jmp    80104e57 <alltraps>

8010549e <vector60>:
8010549e:	6a 00                	push   $0x0
801054a0:	6a 3c                	push   $0x3c
801054a2:	e9 b0 f9 ff ff       	jmp    80104e57 <alltraps>

801054a7 <vector61>:
801054a7:	6a 00                	push   $0x0
801054a9:	6a 3d                	push   $0x3d
801054ab:	e9 a7 f9 ff ff       	jmp    80104e57 <alltraps>

801054b0 <vector62>:
801054b0:	6a 00                	push   $0x0
801054b2:	6a 3e                	push   $0x3e
801054b4:	e9 9e f9 ff ff       	jmp    80104e57 <alltraps>

801054b9 <vector63>:
801054b9:	6a 00                	push   $0x0
801054bb:	6a 3f                	push   $0x3f
801054bd:	e9 95 f9 ff ff       	jmp    80104e57 <alltraps>

801054c2 <vector64>:
801054c2:	6a 00                	push   $0x0
801054c4:	6a 40                	push   $0x40
801054c6:	e9 8c f9 ff ff       	jmp    80104e57 <alltraps>

801054cb <vector65>:
801054cb:	6a 00                	push   $0x0
801054cd:	6a 41                	push   $0x41
801054cf:	e9 83 f9 ff ff       	jmp    80104e57 <alltraps>

801054d4 <vector66>:
801054d4:	6a 00                	push   $0x0
801054d6:	6a 42                	push   $0x42
801054d8:	e9 7a f9 ff ff       	jmp    80104e57 <alltraps>

801054dd <vector67>:
801054dd:	6a 00                	push   $0x0
801054df:	6a 43                	push   $0x43
801054e1:	e9 71 f9 ff ff       	jmp    80104e57 <alltraps>

801054e6 <vector68>:
801054e6:	6a 00                	push   $0x0
801054e8:	6a 44                	push   $0x44
801054ea:	e9 68 f9 ff ff       	jmp    80104e57 <alltraps>

801054ef <vector69>:
801054ef:	6a 00                	push   $0x0
801054f1:	6a 45                	push   $0x45
801054f3:	e9 5f f9 ff ff       	jmp    80104e57 <alltraps>

801054f8 <vector70>:
801054f8:	6a 00                	push   $0x0
801054fa:	6a 46                	push   $0x46
801054fc:	e9 56 f9 ff ff       	jmp    80104e57 <alltraps>

80105501 <vector71>:
80105501:	6a 00                	push   $0x0
80105503:	6a 47                	push   $0x47
80105505:	e9 4d f9 ff ff       	jmp    80104e57 <alltraps>

8010550a <vector72>:
8010550a:	6a 00                	push   $0x0
8010550c:	6a 48                	push   $0x48
8010550e:	e9 44 f9 ff ff       	jmp    80104e57 <alltraps>

80105513 <vector73>:
80105513:	6a 00                	push   $0x0
80105515:	6a 49                	push   $0x49
80105517:	e9 3b f9 ff ff       	jmp    80104e57 <alltraps>

8010551c <vector74>:
8010551c:	6a 00                	push   $0x0
8010551e:	6a 4a                	push   $0x4a
80105520:	e9 32 f9 ff ff       	jmp    80104e57 <alltraps>

80105525 <vector75>:
80105525:	6a 00                	push   $0x0
80105527:	6a 4b                	push   $0x4b
80105529:	e9 29 f9 ff ff       	jmp    80104e57 <alltraps>

8010552e <vector76>:
8010552e:	6a 00                	push   $0x0
80105530:	6a 4c                	push   $0x4c
80105532:	e9 20 f9 ff ff       	jmp    80104e57 <alltraps>

80105537 <vector77>:
80105537:	6a 00                	push   $0x0
80105539:	6a 4d                	push   $0x4d
8010553b:	e9 17 f9 ff ff       	jmp    80104e57 <alltraps>

80105540 <vector78>:
80105540:	6a 00                	push   $0x0
80105542:	6a 4e                	push   $0x4e
80105544:	e9 0e f9 ff ff       	jmp    80104e57 <alltraps>

80105549 <vector79>:
80105549:	6a 00                	push   $0x0
8010554b:	6a 4f                	push   $0x4f
8010554d:	e9 05 f9 ff ff       	jmp    80104e57 <alltraps>

80105552 <vector80>:
80105552:	6a 00                	push   $0x0
80105554:	6a 50                	push   $0x50
80105556:	e9 fc f8 ff ff       	jmp    80104e57 <alltraps>

8010555b <vector81>:
8010555b:	6a 00                	push   $0x0
8010555d:	6a 51                	push   $0x51
8010555f:	e9 f3 f8 ff ff       	jmp    80104e57 <alltraps>

80105564 <vector82>:
80105564:	6a 00                	push   $0x0
80105566:	6a 52                	push   $0x52
80105568:	e9 ea f8 ff ff       	jmp    80104e57 <alltraps>

8010556d <vector83>:
8010556d:	6a 00                	push   $0x0
8010556f:	6a 53                	push   $0x53
80105571:	e9 e1 f8 ff ff       	jmp    80104e57 <alltraps>

80105576 <vector84>:
80105576:	6a 00                	push   $0x0
80105578:	6a 54                	push   $0x54
8010557a:	e9 d8 f8 ff ff       	jmp    80104e57 <alltraps>

8010557f <vector85>:
8010557f:	6a 00                	push   $0x0
80105581:	6a 55                	push   $0x55
80105583:	e9 cf f8 ff ff       	jmp    80104e57 <alltraps>

80105588 <vector86>:
80105588:	6a 00                	push   $0x0
8010558a:	6a 56                	push   $0x56
8010558c:	e9 c6 f8 ff ff       	jmp    80104e57 <alltraps>

80105591 <vector87>:
80105591:	6a 00                	push   $0x0
80105593:	6a 57                	push   $0x57
80105595:	e9 bd f8 ff ff       	jmp    80104e57 <alltraps>

8010559a <vector88>:
8010559a:	6a 00                	push   $0x0
8010559c:	6a 58                	push   $0x58
8010559e:	e9 b4 f8 ff ff       	jmp    80104e57 <alltraps>

801055a3 <vector89>:
801055a3:	6a 00                	push   $0x0
801055a5:	6a 59                	push   $0x59
801055a7:	e9 ab f8 ff ff       	jmp    80104e57 <alltraps>

801055ac <vector90>:
801055ac:	6a 00                	push   $0x0
801055ae:	6a 5a                	push   $0x5a
801055b0:	e9 a2 f8 ff ff       	jmp    80104e57 <alltraps>

801055b5 <vector91>:
801055b5:	6a 00                	push   $0x0
801055b7:	6a 5b                	push   $0x5b
801055b9:	e9 99 f8 ff ff       	jmp    80104e57 <alltraps>

801055be <vector92>:
801055be:	6a 00                	push   $0x0
801055c0:	6a 5c                	push   $0x5c
801055c2:	e9 90 f8 ff ff       	jmp    80104e57 <alltraps>

801055c7 <vector93>:
801055c7:	6a 00                	push   $0x0
801055c9:	6a 5d                	push   $0x5d
801055cb:	e9 87 f8 ff ff       	jmp    80104e57 <alltraps>

801055d0 <vector94>:
801055d0:	6a 00                	push   $0x0
801055d2:	6a 5e                	push   $0x5e
801055d4:	e9 7e f8 ff ff       	jmp    80104e57 <alltraps>

801055d9 <vector95>:
801055d9:	6a 00                	push   $0x0
801055db:	6a 5f                	push   $0x5f
801055dd:	e9 75 f8 ff ff       	jmp    80104e57 <alltraps>

801055e2 <vector96>:
801055e2:	6a 00                	push   $0x0
801055e4:	6a 60                	push   $0x60
801055e6:	e9 6c f8 ff ff       	jmp    80104e57 <alltraps>

801055eb <vector97>:
801055eb:	6a 00                	push   $0x0
801055ed:	6a 61                	push   $0x61
801055ef:	e9 63 f8 ff ff       	jmp    80104e57 <alltraps>

801055f4 <vector98>:
801055f4:	6a 00                	push   $0x0
801055f6:	6a 62                	push   $0x62
801055f8:	e9 5a f8 ff ff       	jmp    80104e57 <alltraps>

801055fd <vector99>:
801055fd:	6a 00                	push   $0x0
801055ff:	6a 63                	push   $0x63
80105601:	e9 51 f8 ff ff       	jmp    80104e57 <alltraps>

80105606 <vector100>:
80105606:	6a 00                	push   $0x0
80105608:	6a 64                	push   $0x64
8010560a:	e9 48 f8 ff ff       	jmp    80104e57 <alltraps>

8010560f <vector101>:
8010560f:	6a 00                	push   $0x0
80105611:	6a 65                	push   $0x65
80105613:	e9 3f f8 ff ff       	jmp    80104e57 <alltraps>

80105618 <vector102>:
80105618:	6a 00                	push   $0x0
8010561a:	6a 66                	push   $0x66
8010561c:	e9 36 f8 ff ff       	jmp    80104e57 <alltraps>

80105621 <vector103>:
80105621:	6a 00                	push   $0x0
80105623:	6a 67                	push   $0x67
80105625:	e9 2d f8 ff ff       	jmp    80104e57 <alltraps>

8010562a <vector104>:
8010562a:	6a 00                	push   $0x0
8010562c:	6a 68                	push   $0x68
8010562e:	e9 24 f8 ff ff       	jmp    80104e57 <alltraps>

80105633 <vector105>:
80105633:	6a 00                	push   $0x0
80105635:	6a 69                	push   $0x69
80105637:	e9 1b f8 ff ff       	jmp    80104e57 <alltraps>

8010563c <vector106>:
8010563c:	6a 00                	push   $0x0
8010563e:	6a 6a                	push   $0x6a
80105640:	e9 12 f8 ff ff       	jmp    80104e57 <alltraps>

80105645 <vector107>:
80105645:	6a 00                	push   $0x0
80105647:	6a 6b                	push   $0x6b
80105649:	e9 09 f8 ff ff       	jmp    80104e57 <alltraps>

8010564e <vector108>:
8010564e:	6a 00                	push   $0x0
80105650:	6a 6c                	push   $0x6c
80105652:	e9 00 f8 ff ff       	jmp    80104e57 <alltraps>

80105657 <vector109>:
80105657:	6a 00                	push   $0x0
80105659:	6a 6d                	push   $0x6d
8010565b:	e9 f7 f7 ff ff       	jmp    80104e57 <alltraps>

80105660 <vector110>:
80105660:	6a 00                	push   $0x0
80105662:	6a 6e                	push   $0x6e
80105664:	e9 ee f7 ff ff       	jmp    80104e57 <alltraps>

80105669 <vector111>:
80105669:	6a 00                	push   $0x0
8010566b:	6a 6f                	push   $0x6f
8010566d:	e9 e5 f7 ff ff       	jmp    80104e57 <alltraps>

80105672 <vector112>:
80105672:	6a 00                	push   $0x0
80105674:	6a 70                	push   $0x70
80105676:	e9 dc f7 ff ff       	jmp    80104e57 <alltraps>

8010567b <vector113>:
8010567b:	6a 00                	push   $0x0
8010567d:	6a 71                	push   $0x71
8010567f:	e9 d3 f7 ff ff       	jmp    80104e57 <alltraps>

80105684 <vector114>:
80105684:	6a 00                	push   $0x0
80105686:	6a 72                	push   $0x72
80105688:	e9 ca f7 ff ff       	jmp    80104e57 <alltraps>

8010568d <vector115>:
8010568d:	6a 00                	push   $0x0
8010568f:	6a 73                	push   $0x73
80105691:	e9 c1 f7 ff ff       	jmp    80104e57 <alltraps>

80105696 <vector116>:
80105696:	6a 00                	push   $0x0
80105698:	6a 74                	push   $0x74
8010569a:	e9 b8 f7 ff ff       	jmp    80104e57 <alltraps>

8010569f <vector117>:
8010569f:	6a 00                	push   $0x0
801056a1:	6a 75                	push   $0x75
801056a3:	e9 af f7 ff ff       	jmp    80104e57 <alltraps>

801056a8 <vector118>:
801056a8:	6a 00                	push   $0x0
801056aa:	6a 76                	push   $0x76
801056ac:	e9 a6 f7 ff ff       	jmp    80104e57 <alltraps>

801056b1 <vector119>:
801056b1:	6a 00                	push   $0x0
801056b3:	6a 77                	push   $0x77
801056b5:	e9 9d f7 ff ff       	jmp    80104e57 <alltraps>

801056ba <vector120>:
801056ba:	6a 00                	push   $0x0
801056bc:	6a 78                	push   $0x78
801056be:	e9 94 f7 ff ff       	jmp    80104e57 <alltraps>

801056c3 <vector121>:
801056c3:	6a 00                	push   $0x0
801056c5:	6a 79                	push   $0x79
801056c7:	e9 8b f7 ff ff       	jmp    80104e57 <alltraps>

801056cc <vector122>:
801056cc:	6a 00                	push   $0x0
801056ce:	6a 7a                	push   $0x7a
801056d0:	e9 82 f7 ff ff       	jmp    80104e57 <alltraps>

801056d5 <vector123>:
801056d5:	6a 00                	push   $0x0
801056d7:	6a 7b                	push   $0x7b
801056d9:	e9 79 f7 ff ff       	jmp    80104e57 <alltraps>

801056de <vector124>:
801056de:	6a 00                	push   $0x0
801056e0:	6a 7c                	push   $0x7c
801056e2:	e9 70 f7 ff ff       	jmp    80104e57 <alltraps>

801056e7 <vector125>:
801056e7:	6a 00                	push   $0x0
801056e9:	6a 7d                	push   $0x7d
801056eb:	e9 67 f7 ff ff       	jmp    80104e57 <alltraps>

801056f0 <vector126>:
801056f0:	6a 00                	push   $0x0
801056f2:	6a 7e                	push   $0x7e
801056f4:	e9 5e f7 ff ff       	jmp    80104e57 <alltraps>

801056f9 <vector127>:
801056f9:	6a 00                	push   $0x0
801056fb:	6a 7f                	push   $0x7f
801056fd:	e9 55 f7 ff ff       	jmp    80104e57 <alltraps>

80105702 <vector128>:
80105702:	6a 00                	push   $0x0
80105704:	68 80 00 00 00       	push   $0x80
80105709:	e9 49 f7 ff ff       	jmp    80104e57 <alltraps>

8010570e <vector129>:
8010570e:	6a 00                	push   $0x0
80105710:	68 81 00 00 00       	push   $0x81
80105715:	e9 3d f7 ff ff       	jmp    80104e57 <alltraps>

8010571a <vector130>:
8010571a:	6a 00                	push   $0x0
8010571c:	68 82 00 00 00       	push   $0x82
80105721:	e9 31 f7 ff ff       	jmp    80104e57 <alltraps>

80105726 <vector131>:
80105726:	6a 00                	push   $0x0
80105728:	68 83 00 00 00       	push   $0x83
8010572d:	e9 25 f7 ff ff       	jmp    80104e57 <alltraps>

80105732 <vector132>:
80105732:	6a 00                	push   $0x0
80105734:	68 84 00 00 00       	push   $0x84
80105739:	e9 19 f7 ff ff       	jmp    80104e57 <alltraps>

8010573e <vector133>:
8010573e:	6a 00                	push   $0x0
80105740:	68 85 00 00 00       	push   $0x85
80105745:	e9 0d f7 ff ff       	jmp    80104e57 <alltraps>

8010574a <vector134>:
8010574a:	6a 00                	push   $0x0
8010574c:	68 86 00 00 00       	push   $0x86
80105751:	e9 01 f7 ff ff       	jmp    80104e57 <alltraps>

80105756 <vector135>:
80105756:	6a 00                	push   $0x0
80105758:	68 87 00 00 00       	push   $0x87
8010575d:	e9 f5 f6 ff ff       	jmp    80104e57 <alltraps>

80105762 <vector136>:
80105762:	6a 00                	push   $0x0
80105764:	68 88 00 00 00       	push   $0x88
80105769:	e9 e9 f6 ff ff       	jmp    80104e57 <alltraps>

8010576e <vector137>:
8010576e:	6a 00                	push   $0x0
80105770:	68 89 00 00 00       	push   $0x89
80105775:	e9 dd f6 ff ff       	jmp    80104e57 <alltraps>

8010577a <vector138>:
8010577a:	6a 00                	push   $0x0
8010577c:	68 8a 00 00 00       	push   $0x8a
80105781:	e9 d1 f6 ff ff       	jmp    80104e57 <alltraps>

80105786 <vector139>:
80105786:	6a 00                	push   $0x0
80105788:	68 8b 00 00 00       	push   $0x8b
8010578d:	e9 c5 f6 ff ff       	jmp    80104e57 <alltraps>

80105792 <vector140>:
80105792:	6a 00                	push   $0x0
80105794:	68 8c 00 00 00       	push   $0x8c
80105799:	e9 b9 f6 ff ff       	jmp    80104e57 <alltraps>

8010579e <vector141>:
8010579e:	6a 00                	push   $0x0
801057a0:	68 8d 00 00 00       	push   $0x8d
801057a5:	e9 ad f6 ff ff       	jmp    80104e57 <alltraps>

801057aa <vector142>:
801057aa:	6a 00                	push   $0x0
801057ac:	68 8e 00 00 00       	push   $0x8e
801057b1:	e9 a1 f6 ff ff       	jmp    80104e57 <alltraps>

801057b6 <vector143>:
801057b6:	6a 00                	push   $0x0
801057b8:	68 8f 00 00 00       	push   $0x8f
801057bd:	e9 95 f6 ff ff       	jmp    80104e57 <alltraps>

801057c2 <vector144>:
801057c2:	6a 00                	push   $0x0
801057c4:	68 90 00 00 00       	push   $0x90
801057c9:	e9 89 f6 ff ff       	jmp    80104e57 <alltraps>

801057ce <vector145>:
801057ce:	6a 00                	push   $0x0
801057d0:	68 91 00 00 00       	push   $0x91
801057d5:	e9 7d f6 ff ff       	jmp    80104e57 <alltraps>

801057da <vector146>:
801057da:	6a 00                	push   $0x0
801057dc:	68 92 00 00 00       	push   $0x92
801057e1:	e9 71 f6 ff ff       	jmp    80104e57 <alltraps>

801057e6 <vector147>:
801057e6:	6a 00                	push   $0x0
801057e8:	68 93 00 00 00       	push   $0x93
801057ed:	e9 65 f6 ff ff       	jmp    80104e57 <alltraps>

801057f2 <vector148>:
801057f2:	6a 00                	push   $0x0
801057f4:	68 94 00 00 00       	push   $0x94
801057f9:	e9 59 f6 ff ff       	jmp    80104e57 <alltraps>

801057fe <vector149>:
801057fe:	6a 00                	push   $0x0
80105800:	68 95 00 00 00       	push   $0x95
80105805:	e9 4d f6 ff ff       	jmp    80104e57 <alltraps>

8010580a <vector150>:
8010580a:	6a 00                	push   $0x0
8010580c:	68 96 00 00 00       	push   $0x96
80105811:	e9 41 f6 ff ff       	jmp    80104e57 <alltraps>

80105816 <vector151>:
80105816:	6a 00                	push   $0x0
80105818:	68 97 00 00 00       	push   $0x97
8010581d:	e9 35 f6 ff ff       	jmp    80104e57 <alltraps>

80105822 <vector152>:
80105822:	6a 00                	push   $0x0
80105824:	68 98 00 00 00       	push   $0x98
80105829:	e9 29 f6 ff ff       	jmp    80104e57 <alltraps>

8010582e <vector153>:
8010582e:	6a 00                	push   $0x0
80105830:	68 99 00 00 00       	push   $0x99
80105835:	e9 1d f6 ff ff       	jmp    80104e57 <alltraps>

8010583a <vector154>:
8010583a:	6a 00                	push   $0x0
8010583c:	68 9a 00 00 00       	push   $0x9a
80105841:	e9 11 f6 ff ff       	jmp    80104e57 <alltraps>

80105846 <vector155>:
80105846:	6a 00                	push   $0x0
80105848:	68 9b 00 00 00       	push   $0x9b
8010584d:	e9 05 f6 ff ff       	jmp    80104e57 <alltraps>

80105852 <vector156>:
80105852:	6a 00                	push   $0x0
80105854:	68 9c 00 00 00       	push   $0x9c
80105859:	e9 f9 f5 ff ff       	jmp    80104e57 <alltraps>

8010585e <vector157>:
8010585e:	6a 00                	push   $0x0
80105860:	68 9d 00 00 00       	push   $0x9d
80105865:	e9 ed f5 ff ff       	jmp    80104e57 <alltraps>

8010586a <vector158>:
8010586a:	6a 00                	push   $0x0
8010586c:	68 9e 00 00 00       	push   $0x9e
80105871:	e9 e1 f5 ff ff       	jmp    80104e57 <alltraps>

80105876 <vector159>:
80105876:	6a 00                	push   $0x0
80105878:	68 9f 00 00 00       	push   $0x9f
8010587d:	e9 d5 f5 ff ff       	jmp    80104e57 <alltraps>

80105882 <vector160>:
80105882:	6a 00                	push   $0x0
80105884:	68 a0 00 00 00       	push   $0xa0
80105889:	e9 c9 f5 ff ff       	jmp    80104e57 <alltraps>

8010588e <vector161>:
8010588e:	6a 00                	push   $0x0
80105890:	68 a1 00 00 00       	push   $0xa1
80105895:	e9 bd f5 ff ff       	jmp    80104e57 <alltraps>

8010589a <vector162>:
8010589a:	6a 00                	push   $0x0
8010589c:	68 a2 00 00 00       	push   $0xa2
801058a1:	e9 b1 f5 ff ff       	jmp    80104e57 <alltraps>

801058a6 <vector163>:
801058a6:	6a 00                	push   $0x0
801058a8:	68 a3 00 00 00       	push   $0xa3
801058ad:	e9 a5 f5 ff ff       	jmp    80104e57 <alltraps>

801058b2 <vector164>:
801058b2:	6a 00                	push   $0x0
801058b4:	68 a4 00 00 00       	push   $0xa4
801058b9:	e9 99 f5 ff ff       	jmp    80104e57 <alltraps>

801058be <vector165>:
801058be:	6a 00                	push   $0x0
801058c0:	68 a5 00 00 00       	push   $0xa5
801058c5:	e9 8d f5 ff ff       	jmp    80104e57 <alltraps>

801058ca <vector166>:
801058ca:	6a 00                	push   $0x0
801058cc:	68 a6 00 00 00       	push   $0xa6
801058d1:	e9 81 f5 ff ff       	jmp    80104e57 <alltraps>

801058d6 <vector167>:
801058d6:	6a 00                	push   $0x0
801058d8:	68 a7 00 00 00       	push   $0xa7
801058dd:	e9 75 f5 ff ff       	jmp    80104e57 <alltraps>

801058e2 <vector168>:
801058e2:	6a 00                	push   $0x0
801058e4:	68 a8 00 00 00       	push   $0xa8
801058e9:	e9 69 f5 ff ff       	jmp    80104e57 <alltraps>

801058ee <vector169>:
801058ee:	6a 00                	push   $0x0
801058f0:	68 a9 00 00 00       	push   $0xa9
801058f5:	e9 5d f5 ff ff       	jmp    80104e57 <alltraps>

801058fa <vector170>:
801058fa:	6a 00                	push   $0x0
801058fc:	68 aa 00 00 00       	push   $0xaa
80105901:	e9 51 f5 ff ff       	jmp    80104e57 <alltraps>

80105906 <vector171>:
80105906:	6a 00                	push   $0x0
80105908:	68 ab 00 00 00       	push   $0xab
8010590d:	e9 45 f5 ff ff       	jmp    80104e57 <alltraps>

80105912 <vector172>:
80105912:	6a 00                	push   $0x0
80105914:	68 ac 00 00 00       	push   $0xac
80105919:	e9 39 f5 ff ff       	jmp    80104e57 <alltraps>

8010591e <vector173>:
8010591e:	6a 00                	push   $0x0
80105920:	68 ad 00 00 00       	push   $0xad
80105925:	e9 2d f5 ff ff       	jmp    80104e57 <alltraps>

8010592a <vector174>:
8010592a:	6a 00                	push   $0x0
8010592c:	68 ae 00 00 00       	push   $0xae
80105931:	e9 21 f5 ff ff       	jmp    80104e57 <alltraps>

80105936 <vector175>:
80105936:	6a 00                	push   $0x0
80105938:	68 af 00 00 00       	push   $0xaf
8010593d:	e9 15 f5 ff ff       	jmp    80104e57 <alltraps>

80105942 <vector176>:
80105942:	6a 00                	push   $0x0
80105944:	68 b0 00 00 00       	push   $0xb0
80105949:	e9 09 f5 ff ff       	jmp    80104e57 <alltraps>

8010594e <vector177>:
8010594e:	6a 00                	push   $0x0
80105950:	68 b1 00 00 00       	push   $0xb1
80105955:	e9 fd f4 ff ff       	jmp    80104e57 <alltraps>

8010595a <vector178>:
8010595a:	6a 00                	push   $0x0
8010595c:	68 b2 00 00 00       	push   $0xb2
80105961:	e9 f1 f4 ff ff       	jmp    80104e57 <alltraps>

80105966 <vector179>:
80105966:	6a 00                	push   $0x0
80105968:	68 b3 00 00 00       	push   $0xb3
8010596d:	e9 e5 f4 ff ff       	jmp    80104e57 <alltraps>

80105972 <vector180>:
80105972:	6a 00                	push   $0x0
80105974:	68 b4 00 00 00       	push   $0xb4
80105979:	e9 d9 f4 ff ff       	jmp    80104e57 <alltraps>

8010597e <vector181>:
8010597e:	6a 00                	push   $0x0
80105980:	68 b5 00 00 00       	push   $0xb5
80105985:	e9 cd f4 ff ff       	jmp    80104e57 <alltraps>

8010598a <vector182>:
8010598a:	6a 00                	push   $0x0
8010598c:	68 b6 00 00 00       	push   $0xb6
80105991:	e9 c1 f4 ff ff       	jmp    80104e57 <alltraps>

80105996 <vector183>:
80105996:	6a 00                	push   $0x0
80105998:	68 b7 00 00 00       	push   $0xb7
8010599d:	e9 b5 f4 ff ff       	jmp    80104e57 <alltraps>

801059a2 <vector184>:
801059a2:	6a 00                	push   $0x0
801059a4:	68 b8 00 00 00       	push   $0xb8
801059a9:	e9 a9 f4 ff ff       	jmp    80104e57 <alltraps>

801059ae <vector185>:
801059ae:	6a 00                	push   $0x0
801059b0:	68 b9 00 00 00       	push   $0xb9
801059b5:	e9 9d f4 ff ff       	jmp    80104e57 <alltraps>

801059ba <vector186>:
801059ba:	6a 00                	push   $0x0
801059bc:	68 ba 00 00 00       	push   $0xba
801059c1:	e9 91 f4 ff ff       	jmp    80104e57 <alltraps>

801059c6 <vector187>:
801059c6:	6a 00                	push   $0x0
801059c8:	68 bb 00 00 00       	push   $0xbb
801059cd:	e9 85 f4 ff ff       	jmp    80104e57 <alltraps>

801059d2 <vector188>:
801059d2:	6a 00                	push   $0x0
801059d4:	68 bc 00 00 00       	push   $0xbc
801059d9:	e9 79 f4 ff ff       	jmp    80104e57 <alltraps>

801059de <vector189>:
801059de:	6a 00                	push   $0x0
801059e0:	68 bd 00 00 00       	push   $0xbd
801059e5:	e9 6d f4 ff ff       	jmp    80104e57 <alltraps>

801059ea <vector190>:
801059ea:	6a 00                	push   $0x0
801059ec:	68 be 00 00 00       	push   $0xbe
801059f1:	e9 61 f4 ff ff       	jmp    80104e57 <alltraps>

801059f6 <vector191>:
801059f6:	6a 00                	push   $0x0
801059f8:	68 bf 00 00 00       	push   $0xbf
801059fd:	e9 55 f4 ff ff       	jmp    80104e57 <alltraps>

80105a02 <vector192>:
80105a02:	6a 00                	push   $0x0
80105a04:	68 c0 00 00 00       	push   $0xc0
80105a09:	e9 49 f4 ff ff       	jmp    80104e57 <alltraps>

80105a0e <vector193>:
80105a0e:	6a 00                	push   $0x0
80105a10:	68 c1 00 00 00       	push   $0xc1
80105a15:	e9 3d f4 ff ff       	jmp    80104e57 <alltraps>

80105a1a <vector194>:
80105a1a:	6a 00                	push   $0x0
80105a1c:	68 c2 00 00 00       	push   $0xc2
80105a21:	e9 31 f4 ff ff       	jmp    80104e57 <alltraps>

80105a26 <vector195>:
80105a26:	6a 00                	push   $0x0
80105a28:	68 c3 00 00 00       	push   $0xc3
80105a2d:	e9 25 f4 ff ff       	jmp    80104e57 <alltraps>

80105a32 <vector196>:
80105a32:	6a 00                	push   $0x0
80105a34:	68 c4 00 00 00       	push   $0xc4
80105a39:	e9 19 f4 ff ff       	jmp    80104e57 <alltraps>

80105a3e <vector197>:
80105a3e:	6a 00                	push   $0x0
80105a40:	68 c5 00 00 00       	push   $0xc5
80105a45:	e9 0d f4 ff ff       	jmp    80104e57 <alltraps>

80105a4a <vector198>:
80105a4a:	6a 00                	push   $0x0
80105a4c:	68 c6 00 00 00       	push   $0xc6
80105a51:	e9 01 f4 ff ff       	jmp    80104e57 <alltraps>

80105a56 <vector199>:
80105a56:	6a 00                	push   $0x0
80105a58:	68 c7 00 00 00       	push   $0xc7
80105a5d:	e9 f5 f3 ff ff       	jmp    80104e57 <alltraps>

80105a62 <vector200>:
80105a62:	6a 00                	push   $0x0
80105a64:	68 c8 00 00 00       	push   $0xc8
80105a69:	e9 e9 f3 ff ff       	jmp    80104e57 <alltraps>

80105a6e <vector201>:
80105a6e:	6a 00                	push   $0x0
80105a70:	68 c9 00 00 00       	push   $0xc9
80105a75:	e9 dd f3 ff ff       	jmp    80104e57 <alltraps>

80105a7a <vector202>:
80105a7a:	6a 00                	push   $0x0
80105a7c:	68 ca 00 00 00       	push   $0xca
80105a81:	e9 d1 f3 ff ff       	jmp    80104e57 <alltraps>

80105a86 <vector203>:
80105a86:	6a 00                	push   $0x0
80105a88:	68 cb 00 00 00       	push   $0xcb
80105a8d:	e9 c5 f3 ff ff       	jmp    80104e57 <alltraps>

80105a92 <vector204>:
80105a92:	6a 00                	push   $0x0
80105a94:	68 cc 00 00 00       	push   $0xcc
80105a99:	e9 b9 f3 ff ff       	jmp    80104e57 <alltraps>

80105a9e <vector205>:
80105a9e:	6a 00                	push   $0x0
80105aa0:	68 cd 00 00 00       	push   $0xcd
80105aa5:	e9 ad f3 ff ff       	jmp    80104e57 <alltraps>

80105aaa <vector206>:
80105aaa:	6a 00                	push   $0x0
80105aac:	68 ce 00 00 00       	push   $0xce
80105ab1:	e9 a1 f3 ff ff       	jmp    80104e57 <alltraps>

80105ab6 <vector207>:
80105ab6:	6a 00                	push   $0x0
80105ab8:	68 cf 00 00 00       	push   $0xcf
80105abd:	e9 95 f3 ff ff       	jmp    80104e57 <alltraps>

80105ac2 <vector208>:
80105ac2:	6a 00                	push   $0x0
80105ac4:	68 d0 00 00 00       	push   $0xd0
80105ac9:	e9 89 f3 ff ff       	jmp    80104e57 <alltraps>

80105ace <vector209>:
80105ace:	6a 00                	push   $0x0
80105ad0:	68 d1 00 00 00       	push   $0xd1
80105ad5:	e9 7d f3 ff ff       	jmp    80104e57 <alltraps>

80105ada <vector210>:
80105ada:	6a 00                	push   $0x0
80105adc:	68 d2 00 00 00       	push   $0xd2
80105ae1:	e9 71 f3 ff ff       	jmp    80104e57 <alltraps>

80105ae6 <vector211>:
80105ae6:	6a 00                	push   $0x0
80105ae8:	68 d3 00 00 00       	push   $0xd3
80105aed:	e9 65 f3 ff ff       	jmp    80104e57 <alltraps>

80105af2 <vector212>:
80105af2:	6a 00                	push   $0x0
80105af4:	68 d4 00 00 00       	push   $0xd4
80105af9:	e9 59 f3 ff ff       	jmp    80104e57 <alltraps>

80105afe <vector213>:
80105afe:	6a 00                	push   $0x0
80105b00:	68 d5 00 00 00       	push   $0xd5
80105b05:	e9 4d f3 ff ff       	jmp    80104e57 <alltraps>

80105b0a <vector214>:
80105b0a:	6a 00                	push   $0x0
80105b0c:	68 d6 00 00 00       	push   $0xd6
80105b11:	e9 41 f3 ff ff       	jmp    80104e57 <alltraps>

80105b16 <vector215>:
80105b16:	6a 00                	push   $0x0
80105b18:	68 d7 00 00 00       	push   $0xd7
80105b1d:	e9 35 f3 ff ff       	jmp    80104e57 <alltraps>

80105b22 <vector216>:
80105b22:	6a 00                	push   $0x0
80105b24:	68 d8 00 00 00       	push   $0xd8
80105b29:	e9 29 f3 ff ff       	jmp    80104e57 <alltraps>

80105b2e <vector217>:
80105b2e:	6a 00                	push   $0x0
80105b30:	68 d9 00 00 00       	push   $0xd9
80105b35:	e9 1d f3 ff ff       	jmp    80104e57 <alltraps>

80105b3a <vector218>:
80105b3a:	6a 00                	push   $0x0
80105b3c:	68 da 00 00 00       	push   $0xda
80105b41:	e9 11 f3 ff ff       	jmp    80104e57 <alltraps>

80105b46 <vector219>:
80105b46:	6a 00                	push   $0x0
80105b48:	68 db 00 00 00       	push   $0xdb
80105b4d:	e9 05 f3 ff ff       	jmp    80104e57 <alltraps>

80105b52 <vector220>:
80105b52:	6a 00                	push   $0x0
80105b54:	68 dc 00 00 00       	push   $0xdc
80105b59:	e9 f9 f2 ff ff       	jmp    80104e57 <alltraps>

80105b5e <vector221>:
80105b5e:	6a 00                	push   $0x0
80105b60:	68 dd 00 00 00       	push   $0xdd
80105b65:	e9 ed f2 ff ff       	jmp    80104e57 <alltraps>

80105b6a <vector222>:
80105b6a:	6a 00                	push   $0x0
80105b6c:	68 de 00 00 00       	push   $0xde
80105b71:	e9 e1 f2 ff ff       	jmp    80104e57 <alltraps>

80105b76 <vector223>:
80105b76:	6a 00                	push   $0x0
80105b78:	68 df 00 00 00       	push   $0xdf
80105b7d:	e9 d5 f2 ff ff       	jmp    80104e57 <alltraps>

80105b82 <vector224>:
80105b82:	6a 00                	push   $0x0
80105b84:	68 e0 00 00 00       	push   $0xe0
80105b89:	e9 c9 f2 ff ff       	jmp    80104e57 <alltraps>

80105b8e <vector225>:
80105b8e:	6a 00                	push   $0x0
80105b90:	68 e1 00 00 00       	push   $0xe1
80105b95:	e9 bd f2 ff ff       	jmp    80104e57 <alltraps>

80105b9a <vector226>:
80105b9a:	6a 00                	push   $0x0
80105b9c:	68 e2 00 00 00       	push   $0xe2
80105ba1:	e9 b1 f2 ff ff       	jmp    80104e57 <alltraps>

80105ba6 <vector227>:
80105ba6:	6a 00                	push   $0x0
80105ba8:	68 e3 00 00 00       	push   $0xe3
80105bad:	e9 a5 f2 ff ff       	jmp    80104e57 <alltraps>

80105bb2 <vector228>:
80105bb2:	6a 00                	push   $0x0
80105bb4:	68 e4 00 00 00       	push   $0xe4
80105bb9:	e9 99 f2 ff ff       	jmp    80104e57 <alltraps>

80105bbe <vector229>:
80105bbe:	6a 00                	push   $0x0
80105bc0:	68 e5 00 00 00       	push   $0xe5
80105bc5:	e9 8d f2 ff ff       	jmp    80104e57 <alltraps>

80105bca <vector230>:
80105bca:	6a 00                	push   $0x0
80105bcc:	68 e6 00 00 00       	push   $0xe6
80105bd1:	e9 81 f2 ff ff       	jmp    80104e57 <alltraps>

80105bd6 <vector231>:
80105bd6:	6a 00                	push   $0x0
80105bd8:	68 e7 00 00 00       	push   $0xe7
80105bdd:	e9 75 f2 ff ff       	jmp    80104e57 <alltraps>

80105be2 <vector232>:
80105be2:	6a 00                	push   $0x0
80105be4:	68 e8 00 00 00       	push   $0xe8
80105be9:	e9 69 f2 ff ff       	jmp    80104e57 <alltraps>

80105bee <vector233>:
80105bee:	6a 00                	push   $0x0
80105bf0:	68 e9 00 00 00       	push   $0xe9
80105bf5:	e9 5d f2 ff ff       	jmp    80104e57 <alltraps>

80105bfa <vector234>:
80105bfa:	6a 00                	push   $0x0
80105bfc:	68 ea 00 00 00       	push   $0xea
80105c01:	e9 51 f2 ff ff       	jmp    80104e57 <alltraps>

80105c06 <vector235>:
80105c06:	6a 00                	push   $0x0
80105c08:	68 eb 00 00 00       	push   $0xeb
80105c0d:	e9 45 f2 ff ff       	jmp    80104e57 <alltraps>

80105c12 <vector236>:
80105c12:	6a 00                	push   $0x0
80105c14:	68 ec 00 00 00       	push   $0xec
80105c19:	e9 39 f2 ff ff       	jmp    80104e57 <alltraps>

80105c1e <vector237>:
80105c1e:	6a 00                	push   $0x0
80105c20:	68 ed 00 00 00       	push   $0xed
80105c25:	e9 2d f2 ff ff       	jmp    80104e57 <alltraps>

80105c2a <vector238>:
80105c2a:	6a 00                	push   $0x0
80105c2c:	68 ee 00 00 00       	push   $0xee
80105c31:	e9 21 f2 ff ff       	jmp    80104e57 <alltraps>

80105c36 <vector239>:
80105c36:	6a 00                	push   $0x0
80105c38:	68 ef 00 00 00       	push   $0xef
80105c3d:	e9 15 f2 ff ff       	jmp    80104e57 <alltraps>

80105c42 <vector240>:
80105c42:	6a 00                	push   $0x0
80105c44:	68 f0 00 00 00       	push   $0xf0
80105c49:	e9 09 f2 ff ff       	jmp    80104e57 <alltraps>

80105c4e <vector241>:
80105c4e:	6a 00                	push   $0x0
80105c50:	68 f1 00 00 00       	push   $0xf1
80105c55:	e9 fd f1 ff ff       	jmp    80104e57 <alltraps>

80105c5a <vector242>:
80105c5a:	6a 00                	push   $0x0
80105c5c:	68 f2 00 00 00       	push   $0xf2
80105c61:	e9 f1 f1 ff ff       	jmp    80104e57 <alltraps>

80105c66 <vector243>:
80105c66:	6a 00                	push   $0x0
80105c68:	68 f3 00 00 00       	push   $0xf3
80105c6d:	e9 e5 f1 ff ff       	jmp    80104e57 <alltraps>

80105c72 <vector244>:
80105c72:	6a 00                	push   $0x0
80105c74:	68 f4 00 00 00       	push   $0xf4
80105c79:	e9 d9 f1 ff ff       	jmp    80104e57 <alltraps>

80105c7e <vector245>:
80105c7e:	6a 00                	push   $0x0
80105c80:	68 f5 00 00 00       	push   $0xf5
80105c85:	e9 cd f1 ff ff       	jmp    80104e57 <alltraps>

80105c8a <vector246>:
80105c8a:	6a 00                	push   $0x0
80105c8c:	68 f6 00 00 00       	push   $0xf6
80105c91:	e9 c1 f1 ff ff       	jmp    80104e57 <alltraps>

80105c96 <vector247>:
80105c96:	6a 00                	push   $0x0
80105c98:	68 f7 00 00 00       	push   $0xf7
80105c9d:	e9 b5 f1 ff ff       	jmp    80104e57 <alltraps>

80105ca2 <vector248>:
80105ca2:	6a 00                	push   $0x0
80105ca4:	68 f8 00 00 00       	push   $0xf8
80105ca9:	e9 a9 f1 ff ff       	jmp    80104e57 <alltraps>

80105cae <vector249>:
80105cae:	6a 00                	push   $0x0
80105cb0:	68 f9 00 00 00       	push   $0xf9
80105cb5:	e9 9d f1 ff ff       	jmp    80104e57 <alltraps>

80105cba <vector250>:
80105cba:	6a 00                	push   $0x0
80105cbc:	68 fa 00 00 00       	push   $0xfa
80105cc1:	e9 91 f1 ff ff       	jmp    80104e57 <alltraps>

80105cc6 <vector251>:
80105cc6:	6a 00                	push   $0x0
80105cc8:	68 fb 00 00 00       	push   $0xfb
80105ccd:	e9 85 f1 ff ff       	jmp    80104e57 <alltraps>

80105cd2 <vector252>:
80105cd2:	6a 00                	push   $0x0
80105cd4:	68 fc 00 00 00       	push   $0xfc
80105cd9:	e9 79 f1 ff ff       	jmp    80104e57 <alltraps>

80105cde <vector253>:
80105cde:	6a 00                	push   $0x0
80105ce0:	68 fd 00 00 00       	push   $0xfd
80105ce5:	e9 6d f1 ff ff       	jmp    80104e57 <alltraps>

80105cea <vector254>:
80105cea:	6a 00                	push   $0x0
80105cec:	68 fe 00 00 00       	push   $0xfe
80105cf1:	e9 61 f1 ff ff       	jmp    80104e57 <alltraps>

80105cf6 <vector255>:
80105cf6:	6a 00                	push   $0x0
80105cf8:	68 ff 00 00 00       	push   $0xff
80105cfd:	e9 55 f1 ff ff       	jmp    80104e57 <alltraps>

80105d02 <walkpgdir>:
80105d02:	55                   	push   %ebp
80105d03:	89 e5                	mov    %esp,%ebp
80105d05:	57                   	push   %edi
80105d06:	56                   	push   %esi
80105d07:	53                   	push   %ebx
80105d08:	83 ec 0c             	sub    $0xc,%esp
80105d0b:	89 d6                	mov    %edx,%esi
80105d0d:	c1 ea 16             	shr    $0x16,%edx
80105d10:	8d 3c 90             	lea    (%eax,%edx,4),%edi
80105d13:	8b 1f                	mov    (%edi),%ebx
80105d15:	f6 c3 01             	test   $0x1,%bl
80105d18:	74 22                	je     80105d3c <walkpgdir+0x3a>
80105d1a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105d20:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
80105d26:	c1 ee 0c             	shr    $0xc,%esi
80105d29:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105d2f:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
80105d32:	89 d8                	mov    %ebx,%eax
80105d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d37:	5b                   	pop    %ebx
80105d38:	5e                   	pop    %esi
80105d39:	5f                   	pop    %edi
80105d3a:	5d                   	pop    %ebp
80105d3b:	c3                   	ret    
80105d3c:	85 c9                	test   %ecx,%ecx
80105d3e:	74 33                	je     80105d73 <walkpgdir+0x71>
80105d40:	83 ec 0c             	sub    $0xc,%esp
80105d43:	6a fe                	push   $0xfffffffe
80105d45:	e8 7d c3 ff ff       	call   801020c7 <kalloc>
80105d4a:	89 c3                	mov    %eax,%ebx
80105d4c:	83 c4 10             	add    $0x10,%esp
80105d4f:	85 c0                	test   %eax,%eax
80105d51:	74 df                	je     80105d32 <walkpgdir+0x30>
80105d53:	83 ec 04             	sub    $0x4,%esp
80105d56:	68 00 10 00 00       	push   $0x1000
80105d5b:	6a 00                	push   $0x0
80105d5d:	50                   	push   %eax
80105d5e:	e8 f6 df ff ff       	call   80103d59 <memset>
80105d63:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105d69:	83 c8 07             	or     $0x7,%eax
80105d6c:	89 07                	mov    %eax,(%edi)
80105d6e:	83 c4 10             	add    $0x10,%esp
80105d71:	eb b3                	jmp    80105d26 <walkpgdir+0x24>
80105d73:	bb 00 00 00 00       	mov    $0x0,%ebx
80105d78:	eb b8                	jmp    80105d32 <walkpgdir+0x30>

80105d7a <mappages>:
80105d7a:	55                   	push   %ebp
80105d7b:	89 e5                	mov    %esp,%ebp
80105d7d:	57                   	push   %edi
80105d7e:	56                   	push   %esi
80105d7f:	53                   	push   %ebx
80105d80:	83 ec 1c             	sub    $0x1c,%esp
80105d83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105d86:	8b 75 08             	mov    0x8(%ebp),%esi
80105d89:	89 d3                	mov    %edx,%ebx
80105d8b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105d91:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105d95:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80105d9b:	b9 01 00 00 00       	mov    $0x1,%ecx
80105da0:	89 da                	mov    %ebx,%edx
80105da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105da5:	e8 58 ff ff ff       	call   80105d02 <walkpgdir>
80105daa:	85 c0                	test   %eax,%eax
80105dac:	74 2e                	je     80105ddc <mappages+0x62>
80105dae:	f6 00 01             	testb  $0x1,(%eax)
80105db1:	75 1c                	jne    80105dcf <mappages+0x55>
80105db3:	89 f2                	mov    %esi,%edx
80105db5:	0b 55 0c             	or     0xc(%ebp),%edx
80105db8:	83 ca 01             	or     $0x1,%edx
80105dbb:	89 10                	mov    %edx,(%eax)
80105dbd:	39 fb                	cmp    %edi,%ebx
80105dbf:	74 28                	je     80105de9 <mappages+0x6f>
80105dc1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105dc7:	81 c6 00 10 00 00    	add    $0x1000,%esi
80105dcd:	eb cc                	jmp    80105d9b <mappages+0x21>
80105dcf:	83 ec 0c             	sub    $0xc,%esp
80105dd2:	68 ac 6e 10 80       	push   $0x80106eac
80105dd7:	e8 6c a5 ff ff       	call   80100348 <panic>
80105ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105de4:	5b                   	pop    %ebx
80105de5:	5e                   	pop    %esi
80105de6:	5f                   	pop    %edi
80105de7:	5d                   	pop    %ebp
80105de8:	c3                   	ret    
80105de9:	b8 00 00 00 00       	mov    $0x0,%eax
80105dee:	eb f1                	jmp    80105de1 <mappages+0x67>

80105df0 <seginit>:
80105df0:	55                   	push   %ebp
80105df1:	89 e5                	mov    %esp,%ebp
80105df3:	53                   	push   %ebx
80105df4:	83 ec 14             	sub    $0x14,%esp
80105df7:	e8 f4 d4 ff ff       	call   801032f0 <cpuid>
80105dfc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e02:	66 c7 80 18 18 12 80 	movw   $0xffff,-0x7fede7e8(%eax)
80105e09:	ff ff 
80105e0b:	66 c7 80 1a 18 12 80 	movw   $0x0,-0x7fede7e6(%eax)
80105e12:	00 00 
80105e14:	c6 80 1c 18 12 80 00 	movb   $0x0,-0x7fede7e4(%eax)
80105e1b:	0f b6 88 1d 18 12 80 	movzbl -0x7fede7e3(%eax),%ecx
80105e22:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e25:	83 c9 1a             	or     $0x1a,%ecx
80105e28:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e2b:	83 c9 80             	or     $0xffffff80,%ecx
80105e2e:	88 88 1d 18 12 80    	mov    %cl,-0x7fede7e3(%eax)
80105e34:	0f b6 88 1e 18 12 80 	movzbl -0x7fede7e2(%eax),%ecx
80105e3b:	83 c9 0f             	or     $0xf,%ecx
80105e3e:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e41:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e44:	88 88 1e 18 12 80    	mov    %cl,-0x7fede7e2(%eax)
80105e4a:	c6 80 1f 18 12 80 00 	movb   $0x0,-0x7fede7e1(%eax)
80105e51:	66 c7 80 20 18 12 80 	movw   $0xffff,-0x7fede7e0(%eax)
80105e58:	ff ff 
80105e5a:	66 c7 80 22 18 12 80 	movw   $0x0,-0x7fede7de(%eax)
80105e61:	00 00 
80105e63:	c6 80 24 18 12 80 00 	movb   $0x0,-0x7fede7dc(%eax)
80105e6a:	0f b6 88 25 18 12 80 	movzbl -0x7fede7db(%eax),%ecx
80105e71:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e74:	83 c9 12             	or     $0x12,%ecx
80105e77:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e7a:	83 c9 80             	or     $0xffffff80,%ecx
80105e7d:	88 88 25 18 12 80    	mov    %cl,-0x7fede7db(%eax)
80105e83:	0f b6 88 26 18 12 80 	movzbl -0x7fede7da(%eax),%ecx
80105e8a:	83 c9 0f             	or     $0xf,%ecx
80105e8d:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e90:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e93:	88 88 26 18 12 80    	mov    %cl,-0x7fede7da(%eax)
80105e99:	c6 80 27 18 12 80 00 	movb   $0x0,-0x7fede7d9(%eax)
80105ea0:	66 c7 80 28 18 12 80 	movw   $0xffff,-0x7fede7d8(%eax)
80105ea7:	ff ff 
80105ea9:	66 c7 80 2a 18 12 80 	movw   $0x0,-0x7fede7d6(%eax)
80105eb0:	00 00 
80105eb2:	c6 80 2c 18 12 80 00 	movb   $0x0,-0x7fede7d4(%eax)
80105eb9:	c6 80 2d 18 12 80 fa 	movb   $0xfa,-0x7fede7d3(%eax)
80105ec0:	0f b6 88 2e 18 12 80 	movzbl -0x7fede7d2(%eax),%ecx
80105ec7:	83 c9 0f             	or     $0xf,%ecx
80105eca:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ecd:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ed0:	88 88 2e 18 12 80    	mov    %cl,-0x7fede7d2(%eax)
80105ed6:	c6 80 2f 18 12 80 00 	movb   $0x0,-0x7fede7d1(%eax)
80105edd:	66 c7 80 30 18 12 80 	movw   $0xffff,-0x7fede7d0(%eax)
80105ee4:	ff ff 
80105ee6:	66 c7 80 32 18 12 80 	movw   $0x0,-0x7fede7ce(%eax)
80105eed:	00 00 
80105eef:	c6 80 34 18 12 80 00 	movb   $0x0,-0x7fede7cc(%eax)
80105ef6:	c6 80 35 18 12 80 f2 	movb   $0xf2,-0x7fede7cb(%eax)
80105efd:	0f b6 88 36 18 12 80 	movzbl -0x7fede7ca(%eax),%ecx
80105f04:	83 c9 0f             	or     $0xf,%ecx
80105f07:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f0a:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f0d:	88 88 36 18 12 80    	mov    %cl,-0x7fede7ca(%eax)
80105f13:	c6 80 37 18 12 80 00 	movb   $0x0,-0x7fede7c9(%eax)
80105f1a:	05 10 18 12 80       	add    $0x80121810,%eax
80105f1f:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
80105f25:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
80105f29:	c1 e8 10             	shr    $0x10,%eax
80105f2c:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
80105f30:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105f33:	0f 01 10             	lgdtl  (%eax)
80105f36:	83 c4 14             	add    $0x14,%esp
80105f39:	5b                   	pop    %ebx
80105f3a:	5d                   	pop    %ebp
80105f3b:	c3                   	ret    

80105f3c <switchkvm>:
80105f3c:	55                   	push   %ebp
80105f3d:	89 e5                	mov    %esp,%ebp
80105f3f:	a1 c4 44 12 80       	mov    0x801244c4,%eax
80105f44:	05 00 00 00 80       	add    $0x80000000,%eax
80105f49:	0f 22 d8             	mov    %eax,%cr3
80105f4c:	5d                   	pop    %ebp
80105f4d:	c3                   	ret    

80105f4e <switchuvm>:
80105f4e:	55                   	push   %ebp
80105f4f:	89 e5                	mov    %esp,%ebp
80105f51:	57                   	push   %edi
80105f52:	56                   	push   %esi
80105f53:	53                   	push   %ebx
80105f54:	83 ec 1c             	sub    $0x1c,%esp
80105f57:	8b 75 08             	mov    0x8(%ebp),%esi
80105f5a:	85 f6                	test   %esi,%esi
80105f5c:	0f 84 dd 00 00 00    	je     8010603f <switchuvm+0xf1>
80105f62:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105f66:	0f 84 e0 00 00 00    	je     8010604c <switchuvm+0xfe>
80105f6c:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105f70:	0f 84 e3 00 00 00    	je     80106059 <switchuvm+0x10b>
80105f76:	e8 55 dc ff ff       	call   80103bd0 <pushcli>
80105f7b:	e8 14 d3 ff ff       	call   80103294 <mycpu>
80105f80:	89 c3                	mov    %eax,%ebx
80105f82:	e8 0d d3 ff ff       	call   80103294 <mycpu>
80105f87:	8d 78 08             	lea    0x8(%eax),%edi
80105f8a:	e8 05 d3 ff ff       	call   80103294 <mycpu>
80105f8f:	83 c0 08             	add    $0x8,%eax
80105f92:	c1 e8 10             	shr    $0x10,%eax
80105f95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f98:	e8 f7 d2 ff ff       	call   80103294 <mycpu>
80105f9d:	83 c0 08             	add    $0x8,%eax
80105fa0:	c1 e8 18             	shr    $0x18,%eax
80105fa3:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105faa:	67 00 
80105fac:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105fb3:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105fb7:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105fbd:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105fc4:	83 e2 f0             	and    $0xfffffff0,%edx
80105fc7:	83 ca 19             	or     $0x19,%edx
80105fca:	83 e2 9f             	and    $0xffffff9f,%edx
80105fcd:	83 ca 80             	or     $0xffffff80,%edx
80105fd0:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105fd6:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105fdd:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80105fe3:	e8 ac d2 ff ff       	call   80103294 <mycpu>
80105fe8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105fef:	83 e2 ef             	and    $0xffffffef,%edx
80105ff2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80105ff8:	e8 97 d2 ff ff       	call   80103294 <mycpu>
80105ffd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
80106003:	8b 5e 08             	mov    0x8(%esi),%ebx
80106006:	e8 89 d2 ff ff       	call   80103294 <mycpu>
8010600b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106011:	89 58 0c             	mov    %ebx,0xc(%eax)
80106014:	e8 7b d2 ff ff       	call   80103294 <mycpu>
80106019:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
8010601f:	b8 28 00 00 00       	mov    $0x28,%eax
80106024:	0f 00 d8             	ltr    %ax
80106027:	8b 46 04             	mov    0x4(%esi),%eax
8010602a:	05 00 00 00 80       	add    $0x80000000,%eax
8010602f:	0f 22 d8             	mov    %eax,%cr3
80106032:	e8 d6 db ff ff       	call   80103c0d <popcli>
80106037:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010603a:	5b                   	pop    %ebx
8010603b:	5e                   	pop    %esi
8010603c:	5f                   	pop    %edi
8010603d:	5d                   	pop    %ebp
8010603e:	c3                   	ret    
8010603f:	83 ec 0c             	sub    $0xc,%esp
80106042:	68 b2 6e 10 80       	push   $0x80106eb2
80106047:	e8 fc a2 ff ff       	call   80100348 <panic>
8010604c:	83 ec 0c             	sub    $0xc,%esp
8010604f:	68 c8 6e 10 80       	push   $0x80106ec8
80106054:	e8 ef a2 ff ff       	call   80100348 <panic>
80106059:	83 ec 0c             	sub    $0xc,%esp
8010605c:	68 dd 6e 10 80       	push   $0x80106edd
80106061:	e8 e2 a2 ff ff       	call   80100348 <panic>

80106066 <inituvm>:
80106066:	55                   	push   %ebp
80106067:	89 e5                	mov    %esp,%ebp
80106069:	56                   	push   %esi
8010606a:	53                   	push   %ebx
8010606b:	8b 75 10             	mov    0x10(%ebp),%esi
8010606e:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106074:	77 51                	ja     801060c7 <inituvm+0x61>
80106076:	83 ec 0c             	sub    $0xc,%esp
80106079:	6a fe                	push   $0xfffffffe
8010607b:	e8 47 c0 ff ff       	call   801020c7 <kalloc>
80106080:	89 c3                	mov    %eax,%ebx
80106082:	83 c4 0c             	add    $0xc,%esp
80106085:	68 00 10 00 00       	push   $0x1000
8010608a:	6a 00                	push   $0x0
8010608c:	50                   	push   %eax
8010608d:	e8 c7 dc ff ff       	call   80103d59 <memset>
80106092:	83 c4 08             	add    $0x8,%esp
80106095:	6a 06                	push   $0x6
80106097:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010609d:	50                   	push   %eax
8010609e:	b9 00 10 00 00       	mov    $0x1000,%ecx
801060a3:	ba 00 00 00 00       	mov    $0x0,%edx
801060a8:	8b 45 08             	mov    0x8(%ebp),%eax
801060ab:	e8 ca fc ff ff       	call   80105d7a <mappages>
801060b0:	83 c4 0c             	add    $0xc,%esp
801060b3:	56                   	push   %esi
801060b4:	ff 75 0c             	pushl  0xc(%ebp)
801060b7:	53                   	push   %ebx
801060b8:	e8 17 dd ff ff       	call   80103dd4 <memmove>
801060bd:	83 c4 10             	add    $0x10,%esp
801060c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801060c3:	5b                   	pop    %ebx
801060c4:	5e                   	pop    %esi
801060c5:	5d                   	pop    %ebp
801060c6:	c3                   	ret    
801060c7:	83 ec 0c             	sub    $0xc,%esp
801060ca:	68 f1 6e 10 80       	push   $0x80106ef1
801060cf:	e8 74 a2 ff ff       	call   80100348 <panic>

801060d4 <loaduvm>:
801060d4:	55                   	push   %ebp
801060d5:	89 e5                	mov    %esp,%ebp
801060d7:	57                   	push   %edi
801060d8:	56                   	push   %esi
801060d9:	53                   	push   %ebx
801060da:	83 ec 0c             	sub    $0xc,%esp
801060dd:	8b 7d 18             	mov    0x18(%ebp),%edi
801060e0:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801060e7:	75 07                	jne    801060f0 <loaduvm+0x1c>
801060e9:	bb 00 00 00 00       	mov    $0x0,%ebx
801060ee:	eb 3c                	jmp    8010612c <loaduvm+0x58>
801060f0:	83 ec 0c             	sub    $0xc,%esp
801060f3:	68 ac 6f 10 80       	push   $0x80106fac
801060f8:	e8 4b a2 ff ff       	call   80100348 <panic>
801060fd:	83 ec 0c             	sub    $0xc,%esp
80106100:	68 0b 6f 10 80       	push   $0x80106f0b
80106105:	e8 3e a2 ff ff       	call   80100348 <panic>
8010610a:	05 00 00 00 80       	add    $0x80000000,%eax
8010610f:	56                   	push   %esi
80106110:	89 da                	mov    %ebx,%edx
80106112:	03 55 14             	add    0x14(%ebp),%edx
80106115:	52                   	push   %edx
80106116:	50                   	push   %eax
80106117:	ff 75 10             	pushl  0x10(%ebp)
8010611a:	e8 60 b6 ff ff       	call   8010177f <readi>
8010611f:	83 c4 10             	add    $0x10,%esp
80106122:	39 f0                	cmp    %esi,%eax
80106124:	75 47                	jne    8010616d <loaduvm+0x99>
80106126:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010612c:	39 fb                	cmp    %edi,%ebx
8010612e:	73 30                	jae    80106160 <loaduvm+0x8c>
80106130:	89 da                	mov    %ebx,%edx
80106132:	03 55 0c             	add    0xc(%ebp),%edx
80106135:	b9 00 00 00 00       	mov    $0x0,%ecx
8010613a:	8b 45 08             	mov    0x8(%ebp),%eax
8010613d:	e8 c0 fb ff ff       	call   80105d02 <walkpgdir>
80106142:	85 c0                	test   %eax,%eax
80106144:	74 b7                	je     801060fd <loaduvm+0x29>
80106146:	8b 00                	mov    (%eax),%eax
80106148:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010614d:	89 fe                	mov    %edi,%esi
8010614f:	29 de                	sub    %ebx,%esi
80106151:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106157:	76 b1                	jbe    8010610a <loaduvm+0x36>
80106159:	be 00 10 00 00       	mov    $0x1000,%esi
8010615e:	eb aa                	jmp    8010610a <loaduvm+0x36>
80106160:	b8 00 00 00 00       	mov    $0x0,%eax
80106165:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106168:	5b                   	pop    %ebx
80106169:	5e                   	pop    %esi
8010616a:	5f                   	pop    %edi
8010616b:	5d                   	pop    %ebp
8010616c:	c3                   	ret    
8010616d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106172:	eb f1                	jmp    80106165 <loaduvm+0x91>

80106174 <deallocuvm>:
80106174:	55                   	push   %ebp
80106175:	89 e5                	mov    %esp,%ebp
80106177:	57                   	push   %edi
80106178:	56                   	push   %esi
80106179:	53                   	push   %ebx
8010617a:	83 ec 0c             	sub    $0xc,%esp
8010617d:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106180:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106183:	73 11                	jae    80106196 <deallocuvm+0x22>
80106185:	8b 45 10             	mov    0x10(%ebp),%eax
80106188:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010618e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106194:	eb 19                	jmp    801061af <deallocuvm+0x3b>
80106196:	89 f8                	mov    %edi,%eax
80106198:	eb 64                	jmp    801061fe <deallocuvm+0x8a>
8010619a:	c1 eb 16             	shr    $0x16,%ebx
8010619d:	83 c3 01             	add    $0x1,%ebx
801061a0:	c1 e3 16             	shl    $0x16,%ebx
801061a3:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
801061a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061af:	39 fb                	cmp    %edi,%ebx
801061b1:	73 48                	jae    801061fb <deallocuvm+0x87>
801061b3:	b9 00 00 00 00       	mov    $0x0,%ecx
801061b8:	89 da                	mov    %ebx,%edx
801061ba:	8b 45 08             	mov    0x8(%ebp),%eax
801061bd:	e8 40 fb ff ff       	call   80105d02 <walkpgdir>
801061c2:	89 c6                	mov    %eax,%esi
801061c4:	85 c0                	test   %eax,%eax
801061c6:	74 d2                	je     8010619a <deallocuvm+0x26>
801061c8:	8b 00                	mov    (%eax),%eax
801061ca:	a8 01                	test   $0x1,%al
801061cc:	74 db                	je     801061a9 <deallocuvm+0x35>
801061ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801061d3:	74 19                	je     801061ee <deallocuvm+0x7a>
801061d5:	05 00 00 00 80       	add    $0x80000000,%eax
801061da:	83 ec 0c             	sub    $0xc,%esp
801061dd:	50                   	push   %eax
801061de:	e8 cd bd ff ff       	call   80101fb0 <kfree>
801061e3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801061e9:	83 c4 10             	add    $0x10,%esp
801061ec:	eb bb                	jmp    801061a9 <deallocuvm+0x35>
801061ee:	83 ec 0c             	sub    $0xc,%esp
801061f1:	68 46 68 10 80       	push   $0x80106846
801061f6:	e8 4d a1 ff ff       	call   80100348 <panic>
801061fb:	8b 45 10             	mov    0x10(%ebp),%eax
801061fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106201:	5b                   	pop    %ebx
80106202:	5e                   	pop    %esi
80106203:	5f                   	pop    %edi
80106204:	5d                   	pop    %ebp
80106205:	c3                   	ret    

80106206 <allocuvm>:
80106206:	55                   	push   %ebp
80106207:	89 e5                	mov    %esp,%ebp
80106209:	57                   	push   %edi
8010620a:	56                   	push   %esi
8010620b:	53                   	push   %ebx
8010620c:	83 ec 1c             	sub    $0x1c,%esp
8010620f:	8b 7d 10             	mov    0x10(%ebp),%edi
80106212:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106215:	85 ff                	test   %edi,%edi
80106217:	0f 88 ca 00 00 00    	js     801062e7 <allocuvm+0xe1>
8010621d:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106220:	72 65                	jb     80106287 <allocuvm+0x81>
80106222:	8b 45 0c             	mov    0xc(%ebp),%eax
80106225:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010622b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106231:	39 fb                	cmp    %edi,%ebx
80106233:	0f 83 b5 00 00 00    	jae    801062ee <allocuvm+0xe8>
80106239:	83 ec 0c             	sub    $0xc,%esp
8010623c:	ff 75 14             	pushl  0x14(%ebp)
8010623f:	e8 83 be ff ff       	call   801020c7 <kalloc>
80106244:	89 c6                	mov    %eax,%esi
80106246:	83 c4 10             	add    $0x10,%esp
80106249:	85 c0                	test   %eax,%eax
8010624b:	74 42                	je     8010628f <allocuvm+0x89>
8010624d:	83 ec 04             	sub    $0x4,%esp
80106250:	68 00 10 00 00       	push   $0x1000
80106255:	6a 00                	push   $0x0
80106257:	50                   	push   %eax
80106258:	e8 fc da ff ff       	call   80103d59 <memset>
8010625d:	83 c4 08             	add    $0x8,%esp
80106260:	6a 06                	push   $0x6
80106262:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106268:	50                   	push   %eax
80106269:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010626e:	89 da                	mov    %ebx,%edx
80106270:	8b 45 08             	mov    0x8(%ebp),%eax
80106273:	e8 02 fb ff ff       	call   80105d7a <mappages>
80106278:	83 c4 10             	add    $0x10,%esp
8010627b:	85 c0                	test   %eax,%eax
8010627d:	78 38                	js     801062b7 <allocuvm+0xb1>
8010627f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106285:	eb aa                	jmp    80106231 <allocuvm+0x2b>
80106287:	8b 45 0c             	mov    0xc(%ebp),%eax
8010628a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010628d:	eb 5f                	jmp    801062ee <allocuvm+0xe8>
8010628f:	83 ec 0c             	sub    $0xc,%esp
80106292:	68 29 6f 10 80       	push   $0x80106f29
80106297:	e8 6f a3 ff ff       	call   8010060b <cprintf>
8010629c:	83 c4 0c             	add    $0xc,%esp
8010629f:	ff 75 0c             	pushl  0xc(%ebp)
801062a2:	57                   	push   %edi
801062a3:	ff 75 08             	pushl  0x8(%ebp)
801062a6:	e8 c9 fe ff ff       	call   80106174 <deallocuvm>
801062ab:	83 c4 10             	add    $0x10,%esp
801062ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801062b5:	eb 37                	jmp    801062ee <allocuvm+0xe8>
801062b7:	83 ec 0c             	sub    $0xc,%esp
801062ba:	68 41 6f 10 80       	push   $0x80106f41
801062bf:	e8 47 a3 ff ff       	call   8010060b <cprintf>
801062c4:	83 c4 0c             	add    $0xc,%esp
801062c7:	ff 75 0c             	pushl  0xc(%ebp)
801062ca:	57                   	push   %edi
801062cb:	ff 75 08             	pushl  0x8(%ebp)
801062ce:	e8 a1 fe ff ff       	call   80106174 <deallocuvm>
801062d3:	89 34 24             	mov    %esi,(%esp)
801062d6:	e8 d5 bc ff ff       	call   80101fb0 <kfree>
801062db:	83 c4 10             	add    $0x10,%esp
801062de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801062e5:	eb 07                	jmp    801062ee <allocuvm+0xe8>
801062e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801062ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062f4:	5b                   	pop    %ebx
801062f5:	5e                   	pop    %esi
801062f6:	5f                   	pop    %edi
801062f7:	5d                   	pop    %ebp
801062f8:	c3                   	ret    

801062f9 <freevm>:
801062f9:	55                   	push   %ebp
801062fa:	89 e5                	mov    %esp,%ebp
801062fc:	56                   	push   %esi
801062fd:	53                   	push   %ebx
801062fe:	8b 75 08             	mov    0x8(%ebp),%esi
80106301:	85 f6                	test   %esi,%esi
80106303:	74 1a                	je     8010631f <freevm+0x26>
80106305:	83 ec 04             	sub    $0x4,%esp
80106308:	6a 00                	push   $0x0
8010630a:	68 00 00 00 80       	push   $0x80000000
8010630f:	56                   	push   %esi
80106310:	e8 5f fe ff ff       	call   80106174 <deallocuvm>
80106315:	83 c4 10             	add    $0x10,%esp
80106318:	bb 00 00 00 00       	mov    $0x0,%ebx
8010631d:	eb 10                	jmp    8010632f <freevm+0x36>
8010631f:	83 ec 0c             	sub    $0xc,%esp
80106322:	68 5d 6f 10 80       	push   $0x80106f5d
80106327:	e8 1c a0 ff ff       	call   80100348 <panic>
8010632c:	83 c3 01             	add    $0x1,%ebx
8010632f:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106335:	77 1f                	ja     80106356 <freevm+0x5d>
80106337:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
8010633a:	a8 01                	test   $0x1,%al
8010633c:	74 ee                	je     8010632c <freevm+0x33>
8010633e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106343:	05 00 00 00 80       	add    $0x80000000,%eax
80106348:	83 ec 0c             	sub    $0xc,%esp
8010634b:	50                   	push   %eax
8010634c:	e8 5f bc ff ff       	call   80101fb0 <kfree>
80106351:	83 c4 10             	add    $0x10,%esp
80106354:	eb d6                	jmp    8010632c <freevm+0x33>
80106356:	83 ec 0c             	sub    $0xc,%esp
80106359:	56                   	push   %esi
8010635a:	e8 51 bc ff ff       	call   80101fb0 <kfree>
8010635f:	83 c4 10             	add    $0x10,%esp
80106362:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106365:	5b                   	pop    %ebx
80106366:	5e                   	pop    %esi
80106367:	5d                   	pop    %ebp
80106368:	c3                   	ret    

80106369 <setupkvm>:
80106369:	55                   	push   %ebp
8010636a:	89 e5                	mov    %esp,%ebp
8010636c:	56                   	push   %esi
8010636d:	53                   	push   %ebx
8010636e:	83 ec 0c             	sub    $0xc,%esp
80106371:	6a fe                	push   $0xfffffffe
80106373:	e8 4f bd ff ff       	call   801020c7 <kalloc>
80106378:	89 c6                	mov    %eax,%esi
8010637a:	83 c4 10             	add    $0x10,%esp
8010637d:	85 c0                	test   %eax,%eax
8010637f:	74 55                	je     801063d6 <setupkvm+0x6d>
80106381:	83 ec 04             	sub    $0x4,%esp
80106384:	68 00 10 00 00       	push   $0x1000
80106389:	6a 00                	push   $0x0
8010638b:	50                   	push   %eax
8010638c:	e8 c8 d9 ff ff       	call   80103d59 <memset>
80106391:	83 c4 10             	add    $0x10,%esp
80106394:	bb 20 94 10 80       	mov    $0x80109420,%ebx
80106399:	81 fb 60 94 10 80    	cmp    $0x80109460,%ebx
8010639f:	73 35                	jae    801063d6 <setupkvm+0x6d>
801063a1:	8b 43 04             	mov    0x4(%ebx),%eax
801063a4:	8b 4b 08             	mov    0x8(%ebx),%ecx
801063a7:	29 c1                	sub    %eax,%ecx
801063a9:	83 ec 08             	sub    $0x8,%esp
801063ac:	ff 73 0c             	pushl  0xc(%ebx)
801063af:	50                   	push   %eax
801063b0:	8b 13                	mov    (%ebx),%edx
801063b2:	89 f0                	mov    %esi,%eax
801063b4:	e8 c1 f9 ff ff       	call   80105d7a <mappages>
801063b9:	83 c4 10             	add    $0x10,%esp
801063bc:	85 c0                	test   %eax,%eax
801063be:	78 05                	js     801063c5 <setupkvm+0x5c>
801063c0:	83 c3 10             	add    $0x10,%ebx
801063c3:	eb d4                	jmp    80106399 <setupkvm+0x30>
801063c5:	83 ec 0c             	sub    $0xc,%esp
801063c8:	56                   	push   %esi
801063c9:	e8 2b ff ff ff       	call   801062f9 <freevm>
801063ce:	83 c4 10             	add    $0x10,%esp
801063d1:	be 00 00 00 00       	mov    $0x0,%esi
801063d6:	89 f0                	mov    %esi,%eax
801063d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063db:	5b                   	pop    %ebx
801063dc:	5e                   	pop    %esi
801063dd:	5d                   	pop    %ebp
801063de:	c3                   	ret    

801063df <kvmalloc>:
801063df:	55                   	push   %ebp
801063e0:	89 e5                	mov    %esp,%ebp
801063e2:	83 ec 08             	sub    $0x8,%esp
801063e5:	e8 7f ff ff ff       	call   80106369 <setupkvm>
801063ea:	a3 c4 44 12 80       	mov    %eax,0x801244c4
801063ef:	e8 48 fb ff ff       	call   80105f3c <switchkvm>
801063f4:	c9                   	leave  
801063f5:	c3                   	ret    

801063f6 <clearpteu>:
801063f6:	55                   	push   %ebp
801063f7:	89 e5                	mov    %esp,%ebp
801063f9:	83 ec 08             	sub    $0x8,%esp
801063fc:	b9 00 00 00 00       	mov    $0x0,%ecx
80106401:	8b 55 0c             	mov    0xc(%ebp),%edx
80106404:	8b 45 08             	mov    0x8(%ebp),%eax
80106407:	e8 f6 f8 ff ff       	call   80105d02 <walkpgdir>
8010640c:	85 c0                	test   %eax,%eax
8010640e:	74 05                	je     80106415 <clearpteu+0x1f>
80106410:	83 20 fb             	andl   $0xfffffffb,(%eax)
80106413:	c9                   	leave  
80106414:	c3                   	ret    
80106415:	83 ec 0c             	sub    $0xc,%esp
80106418:	68 6e 6f 10 80       	push   $0x80106f6e
8010641d:	e8 26 9f ff ff       	call   80100348 <panic>

80106422 <copyuvm>:
80106422:	55                   	push   %ebp
80106423:	89 e5                	mov    %esp,%ebp
80106425:	57                   	push   %edi
80106426:	56                   	push   %esi
80106427:	53                   	push   %ebx
80106428:	83 ec 1c             	sub    $0x1c,%esp
8010642b:	e8 39 ff ff ff       	call   80106369 <setupkvm>
80106430:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106433:	85 c0                	test   %eax,%eax
80106435:	0f 84 d1 00 00 00    	je     8010650c <copyuvm+0xea>
8010643b:	bf 00 00 00 00       	mov    $0x0,%edi
80106440:	89 fe                	mov    %edi,%esi
80106442:	3b 75 0c             	cmp    0xc(%ebp),%esi
80106445:	0f 83 c1 00 00 00    	jae    8010650c <copyuvm+0xea>
8010644b:	89 75 e4             	mov    %esi,-0x1c(%ebp)
8010644e:	b9 00 00 00 00       	mov    $0x0,%ecx
80106453:	89 f2                	mov    %esi,%edx
80106455:	8b 45 08             	mov    0x8(%ebp),%eax
80106458:	e8 a5 f8 ff ff       	call   80105d02 <walkpgdir>
8010645d:	85 c0                	test   %eax,%eax
8010645f:	74 70                	je     801064d1 <copyuvm+0xaf>
80106461:	8b 18                	mov    (%eax),%ebx
80106463:	f6 c3 01             	test   $0x1,%bl
80106466:	74 76                	je     801064de <copyuvm+0xbc>
80106468:	89 df                	mov    %ebx,%edi
8010646a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80106470:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106476:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80106479:	83 ec 0c             	sub    $0xc,%esp
8010647c:	ff 75 10             	pushl  0x10(%ebp)
8010647f:	e8 43 bc ff ff       	call   801020c7 <kalloc>
80106484:	89 c3                	mov    %eax,%ebx
80106486:	83 c4 10             	add    $0x10,%esp
80106489:	85 c0                	test   %eax,%eax
8010648b:	74 6a                	je     801064f7 <copyuvm+0xd5>
8010648d:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80106493:	83 ec 04             	sub    $0x4,%esp
80106496:	68 00 10 00 00       	push   $0x1000
8010649b:	57                   	push   %edi
8010649c:	50                   	push   %eax
8010649d:	e8 32 d9 ff ff       	call   80103dd4 <memmove>
801064a2:	83 c4 08             	add    $0x8,%esp
801064a5:	ff 75 e0             	pushl  -0x20(%ebp)
801064a8:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801064ae:	50                   	push   %eax
801064af:	b9 00 10 00 00       	mov    $0x1000,%ecx
801064b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064ba:	e8 bb f8 ff ff       	call   80105d7a <mappages>
801064bf:	83 c4 10             	add    $0x10,%esp
801064c2:	85 c0                	test   %eax,%eax
801064c4:	78 25                	js     801064eb <copyuvm+0xc9>
801064c6:	81 c6 00 10 00 00    	add    $0x1000,%esi
801064cc:	e9 71 ff ff ff       	jmp    80106442 <copyuvm+0x20>
801064d1:	83 ec 0c             	sub    $0xc,%esp
801064d4:	68 78 6f 10 80       	push   $0x80106f78
801064d9:	e8 6a 9e ff ff       	call   80100348 <panic>
801064de:	83 ec 0c             	sub    $0xc,%esp
801064e1:	68 92 6f 10 80       	push   $0x80106f92
801064e6:	e8 5d 9e ff ff       	call   80100348 <panic>
801064eb:	83 ec 0c             	sub    $0xc,%esp
801064ee:	53                   	push   %ebx
801064ef:	e8 bc ba ff ff       	call   80101fb0 <kfree>
801064f4:	83 c4 10             	add    $0x10,%esp
801064f7:	83 ec 0c             	sub    $0xc,%esp
801064fa:	ff 75 dc             	pushl  -0x24(%ebp)
801064fd:	e8 f7 fd ff ff       	call   801062f9 <freevm>
80106502:	83 c4 10             	add    $0x10,%esp
80106505:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010650c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010650f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106512:	5b                   	pop    %ebx
80106513:	5e                   	pop    %esi
80106514:	5f                   	pop    %edi
80106515:	5d                   	pop    %ebp
80106516:	c3                   	ret    

80106517 <uva2ka>:
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106522:	8b 55 0c             	mov    0xc(%ebp),%edx
80106525:	8b 45 08             	mov    0x8(%ebp),%eax
80106528:	e8 d5 f7 ff ff       	call   80105d02 <walkpgdir>
8010652d:	8b 00                	mov    (%eax),%eax
8010652f:	a8 01                	test   $0x1,%al
80106531:	74 10                	je     80106543 <uva2ka+0x2c>
80106533:	a8 04                	test   $0x4,%al
80106535:	74 13                	je     8010654a <uva2ka+0x33>
80106537:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010653c:	05 00 00 00 80       	add    $0x80000000,%eax
80106541:	c9                   	leave  
80106542:	c3                   	ret    
80106543:	b8 00 00 00 00       	mov    $0x0,%eax
80106548:	eb f7                	jmp    80106541 <uva2ka+0x2a>
8010654a:	b8 00 00 00 00       	mov    $0x0,%eax
8010654f:	eb f0                	jmp    80106541 <uva2ka+0x2a>

80106551 <copyout>:
80106551:	55                   	push   %ebp
80106552:	89 e5                	mov    %esp,%ebp
80106554:	57                   	push   %edi
80106555:	56                   	push   %esi
80106556:	53                   	push   %ebx
80106557:	83 ec 0c             	sub    $0xc,%esp
8010655a:	8b 7d 14             	mov    0x14(%ebp),%edi
8010655d:	eb 25                	jmp    80106584 <copyout+0x33>
8010655f:	8b 55 0c             	mov    0xc(%ebp),%edx
80106562:	29 f2                	sub    %esi,%edx
80106564:	01 d0                	add    %edx,%eax
80106566:	83 ec 04             	sub    $0x4,%esp
80106569:	53                   	push   %ebx
8010656a:	ff 75 10             	pushl  0x10(%ebp)
8010656d:	50                   	push   %eax
8010656e:	e8 61 d8 ff ff       	call   80103dd4 <memmove>
80106573:	29 df                	sub    %ebx,%edi
80106575:	01 5d 10             	add    %ebx,0x10(%ebp)
80106578:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
8010657e:	89 45 0c             	mov    %eax,0xc(%ebp)
80106581:	83 c4 10             	add    $0x10,%esp
80106584:	85 ff                	test   %edi,%edi
80106586:	74 2f                	je     801065b7 <copyout+0x66>
80106588:	8b 75 0c             	mov    0xc(%ebp),%esi
8010658b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80106591:	83 ec 08             	sub    $0x8,%esp
80106594:	56                   	push   %esi
80106595:	ff 75 08             	pushl  0x8(%ebp)
80106598:	e8 7a ff ff ff       	call   80106517 <uva2ka>
8010659d:	83 c4 10             	add    $0x10,%esp
801065a0:	85 c0                	test   %eax,%eax
801065a2:	74 20                	je     801065c4 <copyout+0x73>
801065a4:	89 f3                	mov    %esi,%ebx
801065a6:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801065a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801065af:	39 df                	cmp    %ebx,%edi
801065b1:	73 ac                	jae    8010655f <copyout+0xe>
801065b3:	89 fb                	mov    %edi,%ebx
801065b5:	eb a8                	jmp    8010655f <copyout+0xe>
801065b7:	b8 00 00 00 00       	mov    $0x0,%eax
801065bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065bf:	5b                   	pop    %ebx
801065c0:	5e                   	pop    %esi
801065c1:	5f                   	pop    %edi
801065c2:	5d                   	pop    %ebp
801065c3:	c3                   	ret    
801065c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c9:	eb f1                	jmp    801065bc <copyout+0x6b>

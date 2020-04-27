// Physical memory allocator, intended to allocate
// memory for user processes, kernel stacks, page table pages,
// and pipe buffers. Allocates 4096-byte pages.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"

#define NULL ((void *)0)

int frame[16384] = {0};
int size = 0;
int flag = 0;

int r_frame[16384];
int r_pid[16384];


void freerange(void *vstart, void *vend);
extern char end[]; // first address after kernel loaded from ELF file
                   // defined by the kernel linker script in kernel.ld

struct run {
  struct run *next;  // int addr = (V2P((char*)r) >> 12);
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

void 
update() {
  for (int i = 0; i < 16384; i++) {
    if (i <= 10000) {
      if (frame[i] != 0){ 
        r_frame[i] = 0xDFFF - i;
        r_pid[i] = frame[i];       
      }
    } else {
      r_frame[i] = -1;
      r_pid[i] = -1;
    }
  }
}

// Initialization happens in two phases.
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
  freerange(vstart, vend);
  kmem.use_lock = 1;
  flag = 1;
}

void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
    kfree(p);
}
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = (struct run*)v;
  int addr = (V2P((char*)r) >> 12);
  // if (addr <= 1200) {
  r->next = kmem.freelist;
  kmem.freelist = r;
  // } else {
    if (flag) {
      int index = 0XDFFF - addr;
      frame[index] = 0;
      update();
    }

  // }
  if(kmem.use_lock)
    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(int pid)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if (flag) {
    for (int i = 0; i < 16384; i++) {
      if (frame[i] == 0) {
        if ((i == 0 || frame[i-1] == 0 || frame[i - 1] == pid) && (i == 16383 || frame[i + 1] == 0 || frame[i + 1] == pid)) {
          r = P2V((0XDFFF - i) << 12);
          frame[i] = pid;
          size = i > size? i : size;
          break;
        }
      }
    }
    update();
  } else {
    kmem.freelist = r->next;
  }
  // int addr = (V2P((char*)r) >> 12);
  // if (addr <= 1024) {
  //   if(r) {
  //     kmem.freelist = r->next;
  //   }
  // } else {
  // }
  //
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}



int
dump_physmem(int *frames, int *pids, int numframes)
{
  if (frames == NULL || pids == NULL || numframes < 0) {
      return -1;
  }
  for (int i = 0; i < numframes; i++) {
    // if (i <= size){
    //   if(kmem.use_lock)
    //       acquire(&kmem.lock);
    //   if (frame[i] != 0){ 
    //     frames[i] = 0xDFFF - i;
    //     pids[i] = frame[i];       
    //   }
    //   if(kmem.use_lock)
    //       release(&kmem.lock);
    // } else {
    //   frames[i] = -1;
    //   pids[i] = -1;
    // }
    frames[i] = r_frame[i];
    pids[i] = r_pid[i];
  }
  
  return 0;
}

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

int frame[16384] = {-1};
int mem_pid[16384] = {-1};
int size = 0;
int flag = 0;

void freerange(void *vstart, void *vend);
extern char end[]; // first address after kernel loaded from ELF file
                   // defined by the kernel linker script in kernel.ld

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

int 
isValid(struct run *r, int pid) {
  if (pid == -2) {
    return 1;
  }
  int addr = (V2P((char*)r) >> 12);
  for (int i = 0; i < size; i++) {
    if (frame[i] == addr - 1 && mem_pid[i] != -2 && mem_pid[i] != pid) {
      return 0;
    } else if (frame[i] == addr + 1 && mem_pid[i] != -2 && mem_pid[i] != pid) {
      return 0;
    } 
    // else if (frame[i] < addr + 1) {
    //   return 1;
    // }
  }
  return 1;
}

void
add2frame(struct run *r, int pid) {
  int addr = (V2P((char*)r) >> 12);
  int added = 0;
  // cprintf("add2frame : addr -> %d\n", addr);
  for (int i = 0; i < size; i++) {
    if (frame[i] < addr) {
      for (int j = size; j >= i + 1; j--) {
        frame[j] = frame[j - 1];
        mem_pid[j] = mem_pid[j - 1];
      }
      frame[i] = addr;
      mem_pid[i] = pid;
      added = 1;
      break;
    }
  }
  if (added == 0) {
    frame[size] = addr;
    mem_pid[size] = pid;
  }
}


struct run*
insert(int pid) 
{
  struct run *r = kmem.freelist;
  struct run *prev = NULL;
  while (r) {
    if (isValid(r, pid)) {
      // cprintf("%s", "insert Success\n");
      if (prev == NULL) {
        kmem.freelist = kmem.freelist->next;
      } else {
        prev -> next = r -> next;
      }
      add2frame(r, pid);
      size++;
      break;
    }
    prev = r;
    r = r->next;
  }
  return r;
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
  r->next = kmem.freelist;
  kmem.freelist = r;
  // update frame
  int found = 0;
  if (flag == 1) {
    int addr = (V2P((char*)r) >> 12);
    // cprintf("kfree : addr -> %d\n", addr);

    // for (int i = 0; i < size; i++) {
    //   cprintf("frame[%d] : %d\n", i, frame[i]);
    // }
    // cprintf("size: %d\n", size);


    for (int i = 0; i < size; i++) {
      if (frame[i] == addr) {
        for (int j = i; j < size - 1; j++) {
          frame[j] = frame[j + 1];
          mem_pid[j] = mem_pid[j + 1];
        }
        found = 1;
        break;
      }
    }
    if (found == 0) {
      // cprintf("Warning: Problem in kfree! : addr -> %d\n", addr);
    } else {
      size--;
    }
  }

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

  if (flag == 0) {
    if (r) {
      kmem.freelist = r->next;
    }
  } else {
    // cprintf("%s", "kalloc\n");
    // cprintf("size = %d\n", size);
    // insert the first valid free frame to frame[]
    r = insert(pid);
    // cprintf("kalloc : addr -> %d\n", (V2P((char*)r) >> 12));
  }
  
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
  for (int i = 0; i < numframes; i++) { // size?
    if (frame[i] != 0){
      frames[i] = frame[i];
      pids[i] = mem_pid[i];
    } else {
      frames[i] = -1;
      pids[i] = -1;
    }
  }
  return 0;
}
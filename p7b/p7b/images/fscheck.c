#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include "fs.h"

void print_error(char* msg) {
    fprintf(stderr, "%s\n", msg);
    exit(1);
}

void inodeCheck(struct superblock *sb, void* fs_ptr, int* bbmap) {
    for (int i = 0; i < sb->ninodes; i++) {
        struct dinode* cur_inode = (struct dinode*)
                (fs_ptr + BSIZE * sb->inodestart + i * sizeof(struct dinode));
        if (cur_inode->type == 0)
            continue;
        if (cur_inode->type != 1 &&
            cur_inode->type != 2 &&
            cur_inode->type != 3)
            print_error("ERROR: bad inode.");
        int count_dir = 0;
        for (int j = 0; j < NDIRECT; j++) {
            if (cur_inode->addrs[j] != 0) {
                bbmap[cur_inode->addrs[j]] = 1;
                count_dir++;
            }
        }
        int count_indir = 0;
        if (cur_inode->addrs[NDIRECT] != 0) {
            bbmap[cur_inode->addrs[NDIRECT]] = 1;
            unsigned int* cur = (unsigned int*)
                    (fs_ptr + BSIZE * cur_inode->addrs[NDIRECT]);
            for (int j = 0; j < NINDIRECT; j++) {
                if (*cur != 0) {
                    count_indir++;
                    bbmap[*cur] = 1;
                }
                cur++;
            }
        }
        if ((cur_inode->size + BSIZE - 1) / BSIZE != count_dir + count_indir)
            print_error("ERROR: bad size in inode.");
    }
}

void dirCheck(struct superblock *sb, void* fs_ptr) {
    struct dinode* root_dir = (struct dinode*)
            (fs_ptr + BSIZE * sb->inodestart + 1 * sizeof(struct dinode));
    if (root_dir -> type != 1) {
        print_error("ERROR: root directory does not exist.");
    }

    for (int i = 0; i < sb->ninodes; i++) {
        struct dinode *cur_inode = (struct dinode *)
                (fs_ptr + BSIZE * sb->inodestart + i * sizeof(struct dinode));
        if (cur_inode->type != 1)  continue;
        for (int j = 0; j < 2; j++) {
            struct dirent* cur_dir = (struct dirent*)(fs_ptr +
                    BSIZE * cur_inode->addrs[0]+ j * sizeof(struct dirent));
            if (i == 1 && cur_dir->inum != 1)
                print_error("ERROR: root directory does not exist.");
            if (j == 0 && cur_dir->inum != i)
                print_error("ERROR: current directory mismatch.");
        }
    }
}

void bitmapCheck(struct superblock *sb, void* fs_ptr, int* bbmap) {
    int* bitmap_cur = (int*)(fs_ptr + BSIZE * sb->bmapstart);
    int flag1 = 0, flag2 = 0, bbmap_cur = 0;
    int remainder = sb->size % 32;
    for (int i = 0; i < sb->size/32 + 1 ; i++) {
        int mask = 0x1;
        int bit_num = 32;
        if (i == sb->size/32) bit_num = remainder;
        for (int j = 0; j < bit_num; j++) {
            int bmap_num = (*bitmap_cur >> j) & mask;
            if (bbmap[bbmap_cur++] != bmap_num) {
                flag1 = (bmap_num == 0) ? 1 : flag1;
                flag2 = (bmap_num == 1) ? 1 : flag2;
            }
        }
        bitmap_cur++;
    }
    if (flag1 == 1)
        print_error
        ("ERROR: bitmap marks data free but data block used by inode.");
    if (flag2 == 1)
        print_error("ERROR: bitmap marks data block in use but not used.");
}

void multistructCheck(struct superblock *sb, void* fs_ptr) {
    int flag1 = 0, flag2 = 0;
    const int numOfInodes = sb->ninodes;
    int *inode = malloc(sizeof(int) * numOfInodes);
    int *dir_inum = malloc(sizeof(int) * numOfInodes);
    for (int i = 0; i < numOfInodes; i++) {
        inode[i] = 0;
        dir_inum[i] = 0;
    }
    for (int m = 0; m < numOfInodes; m++) {
        struct dinode *cur_inode = (struct dinode *)
                (fs_ptr + BSIZE * sb->inodestart + m * sizeof(struct dinode));
        if (cur_inode->type != 0) inode[m] = 1;
        if (cur_inode->type != 1) continue;
        for (int i = 0; i < NDIRECT; i++) {
            for (int j = 0; j < BSIZE / sizeof(struct dirent); j++) {
                struct dirent *cur_dir = (struct dirent *)(fs_ptr +
                        BSIZE * cur_inode->addrs[i] +
                        j * sizeof(struct dirent));
                if (cur_dir->inum != 0) {
                    dir_inum[cur_dir->inum] = 1;
                }
            }
        }
        for (int i = 0; i < BSIZE / 4; i++) {
            unsigned int *cur = (unsigned int *)
                    (fs_ptr + BSIZE * cur_inode->addrs[NDIRECT]);
            for (int j = 0; j < NINDIRECT; j++) {
                for (int k = 0; k < BSIZE / sizeof(struct dirent); k++) {
                    struct dirent *cur_dir = (struct dirent *)
                            (fs_ptr + BSIZE *
                            (*cur) + k * sizeof(struct dirent));
                    if (cur_dir->inum != 0) {
                        dir_inum[cur_dir->inum] = 1;
                    }
                }
                cur++;
            }
        }
    }
    for (int i = 0; i < sb->ninodes; i++) {
        if (inode[i] != dir_inum[i]) {
            flag1 = (inode[i] == 0) ? 1 : flag1;
            flag2 = (inode[i] == 1) ? 1 : flag2;
        }
    }
    free(inode);
    free(dir_inum);
    if (flag1 == 1)
        print_error("ERROR: inode marked free but referred to in directory.");
    if (flag2 == 1)
        print_error("ERROR: inode marked in use but not found in a directory.");
}

int main(int argc, char* argv[]) {
    if (argc != 2)
        print_error("Error: Usage: fscheck <file_system_image>");

    int fsfd;
    fsfd = open(argv[1], O_RDONLY);
    if (fsfd < 0)
        print_error("ERROR: image not found.");

    struct stat fs_stat;
    fstat(fsfd, &fs_stat);
    void* fs_ptr = mmap(NULL, fs_stat.st_size, PROT_READ, MAP_PRIVATE, fsfd, 0);

    struct superblock *sb = (struct superblock*)(fs_ptr+BSIZE);

    int *bbmap = malloc(sizeof(int) * sb->size);
    int d_block_start = sb->bmapstart + 1;

    // initialize bbmap
    for (int i = 0; i < sb->size; i++) {
       bbmap[i] = (i < d_block_start) ? 1 : 0;
    }

    // inode check
    inodeCheck(sb, fs_ptr, bbmap);

    // dir check
    dirCheck(sb, fs_ptr);

    // bitmap Check
    bitmapCheck(sb, fs_ptr, bbmap);

    // multistruct Check
    multistructCheck(sb, fs_ptr);

    exit(0);
}

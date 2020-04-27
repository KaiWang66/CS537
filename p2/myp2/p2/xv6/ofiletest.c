//
// Created by wangk on 2019/9/21.
//

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"


void reverse(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

static void
itoa(int x, char buf[])
{
    static char digits[] = "0123456789";
    int i;

    i = 0;
    do{
        buf[i++] = digits[x % 10];
    }while((x /= 10) != 0);
    buf[i] = '\0';
    reverse(buf);
}

int
main(int argc, char *argv[])
{

    if(argc < 2){
        printf(2, "ofiletest N <list of file nums to close and delete>\n");
        exit();
    }

    char buf[2];
    int n = atoi(argv[1]);
    char fn[7] = "ofile";
    for (int i = 0; i < n; i++) {
        itoa(i, buf);
        fn[5] = buf[0];
        fn[6] = buf[1];
        fn[7] = '\0';
        if (i >= 13) {
            printf(1, "can not open ofile%d\n", i);
            continue;
        }
        open(fn, O_CREATE);
    }

    int numOfFileClose = argc - 2;
    for (int i = 0; i < numOfFileClose; i++) {
        int c = atoi(argv[2 + i]);
//        printf(1, "arg[%d] is %d\n", 2 + i, c);
        itoa(c, buf);
        fn[5] = buf[0];
        fn[6] = buf[1];
        fn[7] = '\0';
        if (c >= n) {
            printf(1, "%s is invalid\n", fn);
        }
        close(3 + c);
        if(unlink(fn) < 0){
            printf(2, "%s failed to delete\n", fn);
            break;
        }
    }

    int num = getofilecnt(getpid());
    printf(1, "%d ", num);
    num = getofilenext(getpid());
    printf(1, "%d\n", num);
    exit();
}



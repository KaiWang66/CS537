#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

#define NULL ( (void *) 0)

int main(int argc, char *argv[])
{
     setpri(getpid(), 0);
     getpri(getpid());
     fork2(0);
     getpinfo(NULL);
    return 0;
}

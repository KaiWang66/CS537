#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
// #include "pstat.h"

#define NULL ( (void *) 0)

int main(int argc, char *argv[])
{
    struct pstat* p = NULL;
    setpri(getpid(), 0);
    getpri(getpid());
    fork2(0);
    getpinfo(p);
    exit();
}

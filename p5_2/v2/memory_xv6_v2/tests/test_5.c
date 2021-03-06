#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    int numframes = -1;
    int* frames = 0;
    int* pids = malloc(numframes * sizeof(int));
    
    int flag = dump_physmem(frames, pids, numframes);
    
    if(flag == 0)
    {
        for (int i = 0; i < numframes; i++)
          if(*(pids+i) ==-2)
            printf(0,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
    }
    else// if(flag == -1)
    {
        printf(0,"error\n");
    }
    wait();
    exit();
}

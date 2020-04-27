#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[]) {
    int a = 1;
    int b = 1;
    int c = 1;
    dump_physmem(&a, &b, c);
    exit();
}
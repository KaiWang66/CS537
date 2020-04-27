// Copyright 2019 Kai Wang
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc == 1 || argc >= 4) {
        printf("my-look: invalid number of arguments\n");
        exit(1);
    }
    char *str = argv[1];
    char *path = "/usr/share/dict/words";
    if (argc == 3) {
        path = argv[2];
    }
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        printf("my-look: cannot open file\n");
        exit(1);
    }

    char buffer[200];
    while (fgets(buffer, 200, fp) != NULL) {
        int diff = strncasecmp(buffer, str, strlen(str));
        if (diff == 0) {
            printf("%s", buffer);
        }
    }
    if (fclose(fp) != 0) {
        printf("my-look: cannot close file\n");
        exit(1);
    }
    return 0;
}

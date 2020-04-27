// Copyright 2019 Kai Wang
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 4 && argc != 5) {
        printf("across: invalid number of arguments\n");
        exit(1);
    }
    char *path = "/usr/share/dict/words";
    if (argc == 5) {
        path = argv[4];
    }
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        printf("across: cannot open file\n");
        exit(1);
    }
    char *str = argv[1];
    int startingIndex = atoi(argv[2]);
    int length = atoi(argv[3]);
    if (startingIndex + strlen(str) > length) {
        printf("across: invalid position\n");
        exit(1);
    }

    char buffer[200];
    while (fgets(buffer, 200, fp) != NULL) {
        int flag = 1;
        int buflen = strlen(buffer) - 1;
        if (buflen == length) {
            for (int i = 0; i < buflen && flag != 0; i++) {
                if (buffer[i] > 'z' || buffer[i] < 'a') {
                    flag = 0;
                }
                if (i >= startingIndex && i < startingIndex + strlen(str)
                && buffer[i] != str[i - startingIndex]) {
                    flag = 0;
                }
            }
            if (flag == 1) {
                printf("%s", buffer);
            }
        }
    }
    if (fclose(fp) != 0) {
        printf("my-look: cannot close file\n");
        exit(1);
    }
    return 0;
}

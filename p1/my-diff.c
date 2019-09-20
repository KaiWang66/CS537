// Copyright 2019 Kai Wang
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int print1(char* buffer) {
    printf("< ");
    printf("%s", buffer);
    return 0;
}

int print2(char* buffer) {
    printf("> ");
    printf("%s", buffer);
    return 0;
}

int check(int prev, int index) {
    if (prev != index - 1) {
        printf("%d\n", index);
    }
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("my-diff: invalid number of arguments\n");
        exit(1);
    }
    FILE *fp1 = fopen(argv[1], "r");
    FILE *fp2 = fopen(argv[2], "r");
    if (fp1 == NULL || fp2 == NULL) {
        printf("my-diff: cannot open file\n");
        exit(1);
    }
    char *buffer1;
    char *buffer2;
    size_t bufsize = 32;
    size_t len1 = 0;
    size_t len2 = 0;
    size_t nread1;
    size_t nread2;
    buffer1 = (char*)malloc(bufsize * sizeof(char));
    buffer2 = (char*)malloc(bufsize * sizeof(char));
    nread1 = getline(&buffer1, &len1, fp1);
    nread2 = getline(&buffer2, &len2, fp2);
    int index = 1;
    int prev = -10;
    while (nread1 != -1 || nread2 != -1) {
        if (nread1 == -1 || nread2 == -1) {
            check(prev, index);
            prev = index;
            if (nread2 == -1) {
                print1(buffer1);
            } else {
                print2(buffer2);
            }
        } else if (strcmp(buffer1, buffer2) != 0) {
            check(prev, index);
            prev = index;
            print1(buffer1);
            print2(buffer2);
        }
        index++;
        nread1 = getline(&buffer1, &len1, fp1);
        nread2 = getline(&buffer2, &len2, fp2);
    }
    free(buffer1);
    free(buffer2);
    buffer1 = NULL;
    buffer2 = NULL;
    if (fclose(fp1) != 0 || fclose(fp2) != 0) {
        printf("my-diff: cannot close file\n");
        exit(1);
    }
    return 0;
}



#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

#define BUFFERSIZE 512

void reverse(char s[]) {
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

static void itoa(int x, char buf[]) {
    static char digits[] = "0123456789";
    int i;

    i = 0;
    do{
        buf[i++] = digits[x % 10];
    }while((x /= 10) != 0);
    buf[i] = '\0';
    reverse(buf);
}

struct Node {
    int jid;
    pid_t pid;
    char *job;
    int valid;
};

struct Node jobs[32]; 

int main(int argc, char *argv[]) {
    // initialize jobs
    for (int i = 0; i < 32; i++) {
        jobs[i].valid = 0;
    }

    int jid = 0;
    // batch mode
    // echo each line you read from the batch file back to the user (stdout) before executing it
    if (argc == 2) {
        FILE *fp = fopen(argv[1], "r");
        // cannot open file
        if (fp == NULL) {
            char *buffer = "Error: Cannot open file ";
            write(STDERR_FILENO, buffer, strlen(buffer));
            write(STDERR_FILENO, argv[1], strlen(argv[1]));
            return 1;
        }

        // batch
        char *line = NULL;
        size_t len = 0;
        ssize_t read;
        // int jid = 0;
        while ((read = getline(&line, &len, fp)) != -1) {
            // echo each command
            write(STDOUT_FILENO, line, read);
            
            // very long command line, continue
            if (read >= 512 || read == 0) {
                continue;
            }

            // parse and ...
            
        }
        //free line
        free(line);
        //close the fp
        fclose(fp);
        return 0;
    } else if (argc > 2) { 
        // invalid number of args
        write(STDERR_FILENO, "Usage: mysh [batchFile]", 23);
        return 1;
    }

    // interactive mode 
    while (1) {
        write(STDOUT_FILENO, "mysh> ", 6);
        char *exec_argv_buff[BUFFERSIZE];
        char buffer[BUFFERSIZE];
        if (fgets(buffer, BUFFERSIZE, stdin) != NULL) {
            int num = 0;
            char *token = strtok(buffer, " \r\n\t");
            if (token == NULL) {
                continue;
            }
            while (token != NULL) {
                exec_argv_buff[num] = token;
                num++;
                token = strtok(NULL, " \r\n\t");
            }

            // exit
            if (num <= 2 && strcmp(exec_argv_buff[0], "exit") == 0) {
                if (num == 1 || strcmp(exec_argv_buff[1], "&") == 0) {
                    return 0;
                }
            }

            // jobs
            if (num <= 2 && strcmp(exec_argv_buff[0], "jobs") == 0) {
                write(STDOUT_FILENO, "print jobs", strlen("print jobs"));
                write(STDOUT_FILENO, "\n", 1);
                for (int i = 0; i < 32; i++) {
                    char valid_buff[BUFFERSIZE];
                    itoa(jobs[i].valid, valid_buff);
                    write(STDOUT_FILENO, valid_buff, strlen(valid_buff));
                    // if (jobs[i].valid == 1) {
                    //     write(STDOUT_FILENO, jobs[i].job, strlen(jobs[i].job));
                    // }
                }
                continue;
            }

            // wait


            // set background
            int background = 0;
            int exec_argc = num + 1;
            if (strcmp(exec_argv_buff[num - 1], "&") == 0) {
                if (num == 1) {
                    continue;
                }
                exec_argc = num;
                background = 1;
            }
            char *exec_argv[exec_argc];
            for (int i = 0; i < exec_argc - 1; i++) {
                exec_argv[i] = exec_argv_buff[i];
            }
            exec_argv[exec_argc - 1] = NULL;
            if (background == 0) {
                int length = strlen(exec_argv[exec_argc - 2]);
                if (exec_argv[exec_argc - 2][length - 1] == '&') {
                    background = 1;
                    exec_argv[exec_argc - 2][length - 1] = 0;
                }
            }

            if (background == 1) {
                write(STDOUT_FILENO, "this is background\n", strlen("this is background\n"));
                char jid_buff[BUFFERSIZE];
                itoa(jid, jid_buff);
                char *job = jid_buff;
                // write(STDOUT_FILENO, job, strlen(job));
                // write(STDOUT_FILENO, "\n", 1);
                for (int i = 0; i < 32; i++) {
                    write(STDOUT_FILENO, job, strlen(job));
                    write(STDOUT_FILENO, "\n", 1);
                    if (jobs[i].valid == 0) {
                        jobs[i].jid = jid;
                        jobs[i].pid = getpid();
                        jobs[i].valid = 1;
                        break;
                    }
                }
            }


            int retval = fork();
            if (retval == 0) {
                if (execvp(exec_argv[0], exec_argv) < 0) {
                    write(STDOUT_FILENO, exec_argv[0], strlen(exec_argv[0]));
                    write(STDOUT_FILENO, ":", 1);
                    write(STDOUT_FILENO, " Command not found", strlen(" Command not found"));
                    write(STDOUT_FILENO, "\n", 1);
                }
                return 0;
            } else {
                //parent
                int stat;
                int pid = retval;
                if (background == 0) {
                    waitpid(pid, &stat, 0);
                } 
            }
            jid++;
        } else {
            return 0;
        }
    }
    return 0;
}

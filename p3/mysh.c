#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

#define BUFFERSIZE 512

typedef struct Node {
    int jid;
    pid_t pid;
    char *job;
    int valid;
}j;

int main(int argc, char *argv[]) {
    j *jobs[32];
    // initialize jobs
    for (int i = 0; i < 32; i++) {
        jobs[i] = malloc(sizeof(j));
        jobs[i]->valid = 0;
        jobs[i]->jid = -1;
    }

    int jid = -1;
    // batch mode
    if (argc == 2) {
        FILE *fp = fopen(argv[1], "r");
        // cannot open file
        if (fp == NULL) {
            char *buffer = "Error: Cannot open file ";
            write(STDERR_FILENO, buffer, strlen(buffer));
            write(STDERR_FILENO, argv[1], strlen(argv[1]));
            write(STDERR_FILENO, "\n", 1);
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

            char *exec_argv_buff[BUFFERSIZE];
            // char buffer[BUFFERSIZE];

            int num = 0;
            char *token = strtok(line, " \r\n\t");
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
                if (num == 1 || (num == 1 && strcmp(exec_argv_buff[0],
                "exit&") == 0) || strcmp(exec_argv_buff[1], "&") == 0) {
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i]->jid != -1) {
                            free(jobs[i]->job);
                        }
                        // jobs[i] -> job = NULL;
                        free(jobs[i]);
                        jobs[i] = NULL;
                    }
                    free(line);
                    fclose(fp);
                    return 0;
                }
            }

            // jobs
            if (num <= 2 && strcmp(exec_argv_buff[0], "jobs") == 0) {
                if (num == 1 || (num == 1 && strcmp(exec_argv_buff[0],
                "jobs&") == 0) || strcmp(exec_argv_buff[1], "&") == 0) {
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i]->valid == 1) {
                            if (waitpid(jobs[i] -> pid, NULL, 1) != 0) {
                                if (jobs[i]->jid != -1) {
                                    free(jobs[i]->job);
                                }
                                // jobs[i] -> job = NULL;
                                jobs[i] -> valid = 0;
                            } else {
                                write(STDOUT_FILENO,
                                jobs[i]->job, strlen(jobs[i]->job));
                                write(STDOUT_FILENO, "\n", 1);
                            }
                        }
                    }
                    continue;
                }
            }

            // wait
            if (num <= 3 && strcmp(exec_argv_buff[0], "wait") == 0) {
                int length = strlen(exec_argv_buff[1]);
                if (num == 2 || (num == 2 &&
                exec_argv_buff[1][length - 1] == '&')
                ||strcmp(exec_argv_buff[2], "&") == 0) {
                    char bufferp[BUFFERSIZE];
                    int jid_wait = atoi(exec_argv_buff[1]);
                    int flag = 0;
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i]->jid == jid_wait) {
                            if (waitpid(jobs[i] -> pid, NULL, 1) == 0) {
                                int stat;
                                waitpid(jobs[i] -> pid, &stat, 0);
                            }
                            sprintf(bufferp, "JID %d terminated", jid_wait);
                            write(STDOUT_FILENO, bufferp, strlen(bufferp));
                            write(STDOUT_FILENO, "\n", 1);
                            flag = 1;
                            break;
                        }
                    }
                    if (flag == 1) {
                        continue;
                    }
                    if (jid_wait <= jid && jid_wait >= 0) {
                        sprintf(bufferp, "JID %d terminated", jid_wait);
                        write(STDOUT_FILENO, bufferp, strlen(bufferp));
                        write(STDOUT_FILENO, "\n", 1);
                        continue;
                    }
                    sprintf(bufferp, "Invalid JID %d", jid_wait);
                    write(STDERR_FILENO, bufferp, strlen(bufferp));
                    write(STDERR_FILENO, "\n", 1);
                    continue;
                }
            }
            jid++;
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
            int retval = fork();
            if (retval == 0) {
                for (int i = 0; i < exec_argc; i++) {
                    if (exec_argv[i] != NULL &&
                    strcmp(exec_argv[i], ">") == 0) {
                        if (exec_argv[i + 1] != NULL &&
                        exec_argv[i + 2] == NULL) {
                            freopen(exec_argv[i + 1], "w", stdout);
                            dup2(1, 2);
                            exec_argv[i + 1] = NULL;
                            exec_argv[i] = NULL;
                        } else {
                            write(STDERR_FILENO, exec_argv[0],
                            strlen(exec_argv[0]));
                            write(STDERR_FILENO, ": ", 2);
                            write(STDERR_FILENO, "Command not found",
                            strlen("Command not found"));
                            write(STDERR_FILENO, "\n", 1);
                            return 1;
                        }
                    }
                }
                if (execvp(exec_argv[0], exec_argv) < 0) {
                    write(STDERR_FILENO, exec_argv[0], strlen(exec_argv[0]));
                    write(STDERR_FILENO, ": ", 2);
                    write(STDERR_FILENO, "Command not found",
                    strlen("Command not found"));
                    write(STDERR_FILENO, "\n", 1);
                }
                return 0;
            } else {
                // parent
                int stat;
                int pid = retval;
                if (background == 0) {
                    waitpid(pid, &stat, 0);
                } else {
                    // update
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i] -> valid == 1) {
                            if (waitpid(jobs[i] -> pid, NULL, 1) != 0) {
                                if (jobs[i]->jid != -1) {
                                    free(jobs[i]->job);
                                }
                                // jobs[i] -> job = NULL;
                                jobs[i] -> valid = 0;
                            }
                        }
                        if (jobs[i] -> valid == 0) {
                            char *job;
                            job = malloc(BUFFERSIZE * sizeof(char));
                            sprintf(job, "%d :", jid);
                            for (int j = 0; j < exec_argc - 1; j++) {
                                strcat(job, " ");
                                strcat(job, exec_argv[j]);
                            }
                            jobs[i] -> jid = jid;
                            jobs[i] -> pid = pid;
                            jobs[i] -> valid = 1;
                            jobs[i] -> job = job;
                            break;
                        }
                    }
                }
            }
        }
        // free line
        free(line);
        for (int i = 0; i < 32; i++) {
            if (jobs[i]->jid != -1) {
                free(jobs[i]->job);
            }
            // jobs[i]->job = NULL;
            free(jobs[i]);
            jobs[i] = NULL;
        }
        // close the fp
        fclose(fp);
        return 0;
    } else if (argc > 2) {
        // invalid number of args
        write(STDERR_FILENO, "Usage: mysh [batchFile]\n", 24);
        for (int i = 0; i < 32; i++) {
            if (jobs[i]->jid != -1) {
                free(jobs[i]->job);
            }
            // jobs[i]->job = NULL;
            free(jobs[i]);
            jobs[i] = NULL;
        }
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
                if (num == 1 || (num == 1 && strcmp(exec_argv_buff[0],
                "exit&") == 0) || strcmp(exec_argv_buff[1], "&") == 0) {
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i]->jid != -1) {
                            free(jobs[i]->job);
                        }
                        // jobs[i]->job = NULL;
                        free(jobs[i]);
                        jobs[i] = NULL;
                    }
                    return 0;
                }
            }

            // jobs
            if (num <= 2 && strcmp(exec_argv_buff[0], "jobs") == 0) {
                if (num == 1 || (num == 1 && strcmp(exec_argv_buff[0],
                "jobs&") == 0) || strcmp(exec_argv_buff[1], "&") == 0) {
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i]->valid == 1) {
                            if (waitpid(jobs[i] -> pid, NULL, 1) != 0) {
                                if (jobs[i]->jid != -1) {
                                free(jobs[i]->job);
                                }
                                // jobs[i] -> job = NULL;
                                jobs[i] -> valid = 0;
                            } else {
                                write(STDOUT_FILENO, jobs[i]->job,
                                strlen(jobs[i]->job));
                                write(STDOUT_FILENO, "\n", 1);
                            }
                        }
                    }
                    continue;
                }
            }

            // wait
            if (num <= 3 && strcmp(exec_argv_buff[0], "wait") == 0) {
                int length = strlen(exec_argv_buff[1]);
                if (num == 2 || (num == 2
                && exec_argv_buff[1][length - 1] == '&')
                ||strcmp(exec_argv_buff[2], "&") == 0) {
                    char bufferp[BUFFERSIZE];
                    int jid_wait = atoi(exec_argv_buff[1]);
                    int flag = 0;
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i]->jid == jid_wait) {
                            if (waitpid(jobs[i] -> pid, NULL, 1) == 0) {
                                int stat;
                                waitpid(jobs[i] -> pid, &stat, 0);
                            }
                            sprintf(bufferp, "JID %d terminated", jid_wait);
                            write(STDOUT_FILENO, bufferp, strlen(bufferp));
                            write(STDOUT_FILENO, "\n", 1);
                            flag = 1;
                            break;
                        }
                    }
                    if (flag == 1) {
                        continue;
                    }
                    if (jid_wait <= jid && jid_wait >= 0) {
                        sprintf(bufferp, "JID %d terminated", jid_wait);
                        write(STDOUT_FILENO, bufferp, strlen(bufferp));
                        write(STDOUT_FILENO, "\n", 1);
                        continue;
                    }
                    sprintf(bufferp, "Invalid JID %d", jid_wait);
                    write(STDERR_FILENO, bufferp, strlen(bufferp));
                    write(STDERR_FILENO, "\n", 1);
                    continue;
                }
            }
            jid++;
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


            int retval = fork();
            if (retval == 0) {
                for (int i = 0; i < exec_argc; i++) {
                    if (exec_argv[i] != NULL &&
                    strcmp(exec_argv[i], ">") == 0) {
                        if (exec_argv[i + 1] != NULL &&
                        exec_argv[i + 2] == NULL) {
                            freopen(exec_argv[i + 1], "w+", stdout);
                            dup2(1, 2);
                            exec_argv[i + 1] = NULL;
                            exec_argv[i] = NULL;
                            break;
                        } else {
                            write(STDERR_FILENO, exec_argv[0],
                            strlen(exec_argv[0]));
                            write(STDERR_FILENO, ": ", 2);
                            write(STDERR_FILENO, "Command not found",
                            strlen("Command not found"));
                            write(STDERR_FILENO, "\n", 1);
                            return 1;
                        }
                    }
                }

                if (execvp(exec_argv[0], exec_argv) < 0) {
                    write(STDERR_FILENO, exec_argv[0],
                    strlen(exec_argv[0]));
                    write(STDERR_FILENO, ": ", 2);
                    write(STDERR_FILENO, "Command not found",
                    strlen("Command not found"));
                    write(STDERR_FILENO, "\n", 1);
                }
                return 0;
            } else {
                // parent
                int stat;
                int pid = retval;
                if (background == 0) {
                    waitpid(pid, &stat, 0);
                } else {
                    // update
                    for (int i = 0; i < 32; i++) {
                        if (jobs[i] -> valid == 1) {
                            if (waitpid(jobs[i] -> pid, NULL, 1) != 0) {
                                if (jobs[i]->jid != -1) {
                                    free(jobs[i]->job);
                                }
                                // jobs[i] -> job = NULL;
                                jobs[i] -> valid = 0;
                            }
                        }
                        if (jobs[i] -> valid == 0) {
                            char *job;
                            job = malloc(BUFFERSIZE * sizeof(char));
                            sprintf(job, "%d :", jid);
                            for (int j = 0; j < exec_argc - 1; j++) {
                                strcat(job, " ");
                                strcat(job, exec_argv[j]);
                            }
                            jobs[i] -> jid = jid;
                            jobs[i] -> pid = pid;
                            jobs[i] -> valid = 1;
                            jobs[i] -> job = job;
                            break;
                        }
                    }
                }
            }
        } else {
            for (int i = 0; i < 32; i++) {
                if (jobs[i]->jid != -1) {
                    free(jobs[i]->job);
                }
                // jobs[i]->job = NULL;
                free(jobs[i]);
                jobs[i] = NULL;
            }
            return 0;
        }
    }
    return 0;
}

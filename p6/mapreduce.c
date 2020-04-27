#include "mapreduce.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>

int DEFAULT_CAPACITY = 10;
float GROWTH_FACTOR = 2;

// global value of Partitioner and numOfPartitioner
Partitioner g_partitioner;
int numOfPartitioner;
int power;

// create_struct: void* args passed into lib_creat
typedef struct {
    Mapper map;
    char** file_names;
    int numOfFiles;
} creat_struct;

// reduce_struct: void* args passed into lib_reduce
typedef struct {
    Reducer reduce;
    int start_partition_number;
    int size;
} reduce_struct;

// Node : <K,V> pair
typedef struct {
    char* key;
    char* value;
} Node;

typedef struct {
    Node* array;
    int size;
    int capacity;
    // mutex : locks for array[i]
    sem_t* mutex;
    // index that get_next will use
    int get_next_index;
} Bucket;

// table : array of resizable array with its size
Bucket* table;

// table is an array of bucket
// each bucket contains an array of node<K, V>

void initialize_bucket(int index) {
    table[index].array = malloc(sizeof(Node) * DEFAULT_CAPACITY);
    if (table[index].array == NULL) {
        printf("Warning: cannot allocate memory!\n");
    }
    table[index].size = 0;
    table[index].capacity = DEFAULT_CAPACITY;
    table[index].get_next_index = 0;
    table[index].mutex = malloc(sizeof(sem_t));
    if (table[index].mutex == NULL) {
        printf("Warning: cannot allocate memory!\n");
    }
    sem_init(table[index].mutex, 0, 1);
}

void resize(Bucket* bucket) {
    int newCapacity = (int)(bucket->size * GROWTH_FACTOR);
    bucket->array = realloc(bucket->array, newCapacity * sizeof(Node));
    bucket->capacity = newCapacity;
}

void insert(char* key, char* value, unsigned long index) {
    // sem
    sem_wait(table[index].mutex);
    if (table[index].size == table[index].capacity) resize(&table[index]);
    table[index].array[table[index].size].key =
    malloc(strlen(key) * sizeof(char*));
    table[index].array[table[index].size].value =
    malloc(strlen(value) * sizeof(char*));
    strncpy(table[index].array[table[index].size].key, key, strlen(key));
    strncpy(table[index].array[table[index].size].value, value, strlen(value));
    table[index].size++;
    sem_post(table[index].mutex);
    //
}

void MR_Emit(char *key, char *value) {
    unsigned long index = g_partitioner(key, numOfPartitioner);
    insert(key, value, index);
}

char* get_next(char *key, int partition_number) {
    if (table[partition_number].size <= table[partition_number]
    .get_next_index) {
        return NULL;
    }
    if (table[partition_number].array == NULL) {
        return NULL;
    }
    if (table[partition_number].array[table[partition_number].get_next_index]
    .key == NULL) {
        return NULL;
    }

    char *cmp_key = table[partition_number].array[table[partition_number]
    .get_next_index].key;
    if (strlen(cmp_key) != strlen(key)) {
        return NULL;
    }
    if ((strncmp(cmp_key, key, strlen(cmp_key))) != 0) {
        return NULL;
    } else {
        return table[partition_number]
        .array[table[partition_number]
        .get_next_index++].value;
    }
}

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) {
    unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;
}

unsigned long MR_SortedPartition(char *key, int num_partitions) {
    if (power == 0) {
        return 0;
    }
    unsigned int uint_key = (unsigned int)(atoi(key));
    int index = (uint_key >> (32 - power));
    return index;
}

void* library_create(void* args) {
    creat_struct *actual_arg = args;
    Mapper map = actual_arg -> map;
    int numOfFiles = actual_arg -> numOfFiles;
    char **file_names = actual_arg -> file_names;
    for (int i = 0; i < numOfFiles; i++) {
        map(file_names[i]);
    }
    free(actual_arg);
}

void* library_reduce(void* args) {
    reduce_struct *actual_arg = args;
    Reducer reduce = actual_arg->reduce;
    int start = actual_arg->start_partition_number;
    for (int i = 0; i < actual_arg->size; i++) {
        while (table[i + start].size > table[i + start].get_next_index) {
            reduce(table[i + start]
            .array[table[i + start]
            .get_next_index].key, get_next, start + i);
        }
    }
    free(actual_arg);
}

void* library_free(void* args) {
    int index = *((int*)args);
    int size = table[index].size;
    for (int i = 0; i < size; i++) {
        free(table[index].array[i].key);
        free(table[index].array[i].value);
    }
    free(table[index].mutex);
    free(table[index].array);
    free(args);
}

int comparator(const void *p, const void *q) {
    return strcmp((((Node *)p)->key), (((Node *)q)->key));
}

void* sort(void* args) {
    int i = *((int*)args);
    qsort(table[i].array, table[i].size, sizeof(Node), comparator);
    free(args);
}

void MR_Run(int argc, char *argv[],
Mapper map, int num_mappers, Reducer reduce, int num_reducers,
Partitioner partition, int num_partitions) {
    // store partition as global g_partition
    g_partitioner = partition;
    // store num_partitions as numOfPartitioner
    numOfPartitioner = num_partitions;

    power = 0;
    int num = 1;
    while (num < num_partitions) {
        power++;
        num *= 2;
    }

    // malloc table
    table = malloc(sizeof(Bucket) * num_partitions);
    if (table == NULL) {
        printf("Warning: malloc fails!\n");
    }

    for (int i = 0; i < num_partitions; i++) {
        initialize_bucket(i);
    }

    // new mappers thread
    pthread_t *p = malloc(num_mappers * sizeof(*p));
    int numOfFiles = argc - 1;
    int filesPerMapper = numOfFiles / num_mappers;
    int remainder = numOfFiles % num_mappers;
    for (int i = 0; i < num_mappers; i++) {
        creat_struct *args = malloc(sizeof (*args));
        if (args == NULL) {
            printf("Warning: cannot allocate memory!\n");
        }
        args -> map = map;
        args -> numOfFiles = filesPerMapper + ((i < remainder) ? 1 : 0);
        args -> file_names = argv + 1 +
        (i * filesPerMapper + ((i < remainder) ? i : remainder));
        if (pthread_create(&p[i], NULL, library_create, args)) {
            free(args);
            printf("Warning : pthread_creat fails!\n");
        }
    }
    // join mapper threads
    for (int i = 0; i < num_mappers; i++) {
        pthread_join(p[i], NULL);
    }
    free(p);

    // sort
    pthread_t *s = malloc(num_partitions * sizeof(*s));
    for (int i = 0; i < num_partitions; i++) {
        int *args = malloc(sizeof(*args));
        if (args == NULL) {
            printf("Warning: cannot allocate memory!\n");
        }
        *args = i;
        if (pthread_create(&s[i], NULL, sort, args)) {
            free(args);
            printf("Warning: pthread_creat fails!\n");
        }
    }
    // join
    for (int i = 0; i < num_partitions; i++) {
        pthread_join(s[i], NULL);
    }
    free(s);

    // create reducer thread
    pthread_t *r = malloc(num_reducers * sizeof(*r));
    remainder = num_partitions % num_reducers;
    int PartitionPerReducer = num_partitions / num_reducers;
    for (int i = 0; i < num_reducers; i++) {
        reduce_struct *args = malloc(sizeof (*args));
        if (args == NULL) {
            printf("Warning: cannot allocate memory!\n");
        }
        args->reduce = reduce;
        args->start_partition_number = i * PartitionPerReducer +
        ((i < remainder) ? i : remainder);
        args->size = PartitionPerReducer + ((i < remainder) ? 1 : 0);
        if (pthread_create(&r[i], NULL, library_reduce, args)) {
            free(args);
            printf("Warning : pthread_reduce fails!\n");
        }
    }
    for (int i = 0; i < num_reducers; i++) {
        pthread_join(r[i], NULL);
    }
    free(r);

    // free

    for (int i = 0; i < num_partitions; i++) {
        for (int j = 0; j < table[i].size; j++) {
            free(table[i].array[j].key);
            table[i].array[j].key = NULL;
            free(table[i].array[j].value);
            table[i].array[j].value = NULL;
        }
        free(table[i].mutex);
        table[i].mutex = NULL;
        free(table[i].array);
        table[i].array = NULL;
    }
    free(table);
    table = NULL;
}

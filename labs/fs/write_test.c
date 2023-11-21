// /buildroot/output/host/usr/bin/aarch64-linux-gcc -Wall -Wextra -o write_test write_test.c

#define _GNU_SOURCE
#include <sched.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define SIZE 1024 // 1024 bytes = 1KB
#define BIGSIZE 1024*1024 // 1MB

static double diff           (struct timespec start, struct timespec end);
static int    writeSmallFiles(int n);
static int    writeBigFile   (int n);

int main (int argc, char *argv[])
{
int      ret;
int      cpu;
cpu_set_t set;
struct sched_param sp = {.sched_priority = 50, };
struct timespec    tStart, tEnd;

    // cpu and task priority
    if (argc == 2)
    {
        cpu    = atoi(argv[1]);
    }
    else
    {
        cpu = 0;
    }

    
    CPU_ZERO (&set);
    CPU_SET (cpu, &set);
    ret=sched_setaffinity (0, sizeof(set), &set);
    printf ("setaffinity=%d\n", ret);

    ret=sched_setscheduler (0, SCHED_FIFO, &sp);
    printf ("setscheduler=%d\n", ret);
    
    clock_gettime(CLOCK_REALTIME, &tStart);	
    writeSmallFiles(1000);
    clock_gettime(CLOCK_REALTIME, &tEnd);
    printf ("Write small files, time[s]: %f\n", diff(tStart, tEnd));

    clock_gettime(CLOCK_REALTIME, &tStart);	
    writeBigFile(1);
    clock_gettime(CLOCK_REALTIME, &tEnd);
    printf ("Write big files, time[s]: %f\n", diff(tStart, tEnd));

    return (0);
}

static int writeSmallFiles(int n)
{
    // write n files of SIZE bytes
    for(int i = 0; i < n; i++) {
        char buffer[SIZE];
        memset(buffer, 'a', SIZE); // fill buffer with 'a'

        char filename[20];
        sprintf(filename, "file%d.txt", i); // create filename file0.txt, file1.txt, ...

        FILE *fp = fopen(filename, "w");
        if(fp == NULL) {
            printf("Failed to open file %s\n", filename);
            return -1;
        }

        fwrite(buffer, sizeof(char), SIZE, fp); // write buffer to file
        fclose(fp);
    }
    return 0;
}

static int writeBigFile(int n)
{
    for(int i = 0; i < n; i++) {
        char buffer[BIGSIZE];
        memset(buffer, 'a', BIGSIZE); // fill buffer with 'a'

        char filename[20];
        sprintf(filename, "big_file%d.txt", i); // create filename file0.txt, file1.txt, ...

        FILE *fp = fopen(filename, "w");
        if(fp == NULL) {
            printf("Failed to open file %s\n", filename);
            return -1;
        }

        fwrite(buffer, sizeof(char), BIGSIZE, fp); // write buffer to file
        fclose(fp);
    }
    return 0;
}

static double diff(struct timespec start, struct timespec end)
{
double t1, t2;

    t1 = (double)start.tv_sec;
    t1 = t1 + ((double)start.tv_nsec)/1000000000.0;
    t2 = (double)end.tv_sec;
    t2 = t2 + ((double)end.tv_nsec)/1000000000.0;

    return (t2-t1);
}
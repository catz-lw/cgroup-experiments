#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

#define SIZE_KB (1024)
#define SIZE_MB (SIZE_KB * SIZE_KB)
#define PAGE_SIZE (SIZE_KB * 4)

int main(int argc,  const char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "error: %s: missing argument for memory size\n", argv[0]);
        return 1;
    }

     // Convert the command line argument to a size_t
    size_t num_megabytes = strtoull(argv[1], NULL, 10);

    // Set up the signal set to wait for SIGUSR1
    sigset_t sigset;
    sigemptyset(&sigset);
    sigaddset(&sigset, SIGUSR1);
    // Block SIGUSR1 so that it can be waited for using sigwait
    if (sigprocmask(SIG_BLOCK, &sigset, NULL) == -1) {
        fprintf(stderr, "error: sigprocmask failed: %m\n");
        return 1;
    }

    printf("Waiting for SIGUSR1 to allocate memory...\n");

    // Wait for SIGUSR1
    int sig;
    if (sigwait(&sigset, &sig) != 0) {
        fprintf(stderr, "error: sigwait failed: %m\n");
        return 1;
    }

    const size_t total_size = num_megabytes * SIZE_MB;
    char *memory = (char *)malloc(total_size);

    if (memory == NULL) {
        fprintf(stderr, "error: memory allocation failed\n");
        return 1;
    }

    // Touch each page of the memory to ensure it's committed
    for (size_t i = 0; i < total_size; i += PAGE_SIZE) { 
        memory[i] = 1;
    }

    printf("touched memory\n");

    // Use the memory
    // memset(memory, 1, total_size);

    // sleep forever
    sleep(-1);

    // Free the memory
    free(memory);

    return 0;
}
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/wait.h>
#include <unistd.h>

// The Result struct contains the result of the sum operation and a counter for the number of fork operations.
typedef struct Result {
	int sum;
	int num;
} Result;

// Declare functions to make them usable before the implementation.
Result forkbench(int start, int end);
int parseInt(char *str, char *errMsg);

// spawnChild forks a subprocess to compute the sum with the given range of numbers. For computing the sum, the subprocess calls forkbench().
// Before spawning the child process, spawnChild creates a bidirectional pipe. One side of the pipe is returned to the caller,
// the other side is used by the child process to output results.
int spawnChild(int start, int end) {
	
	// TODO Implement me

	int fd[2];
	
    if (pipe(fd)==-1) 
    { 
        fprintf(stderr, "Pipe Failed" ); 
        return 1;
    } 
	pid_t p = fork();
	// if it's child process
    if (p == 0){
		Result r = forkbench(start,end);
		write(fd[1], &r.sum, sizeof(int));
		write(fd[1], &r.num, sizeof(int));
		// printf("spawnChild: wrote sum %d and num %d\n",r.sum,r.num);
		close(fd[1]);
	}
	// if it's a parent process
	else if(p > 0){
		wait(0);
		exit(0);
	}
	return fd[0];
}

// readChild reads data from the given file descriptor and parses it to a Result struct.
// This reads the result data written by a child process in spawnChild().
Result readChild(int fd) {
		
	// TODO Implement me
	int sum = 0;
	int num = 0;
	read(fd, &sum, sizeof(int));
	read(fd, &num, sizeof(int));  
	// printf("readChild: read sum %d num %d\n",sum,num);
	close(fd);
	
	return (Result) {sum, num};
}

// forkbench computes the sum of all numbers in the given range (inclusive) by spawning 2 child processes.
// One child computes the sum of the lower range, the other of the upper range.
// The two results are summed and returned.
// If the start and end parameters are equal, the result is returned directly. This is the break condition for the recursion.
Result forkbench(int start, int end) {
	if (start >= end) {
		if (start > end)
			fprintf(stderr, "Start bigger than end: %d - %d\n", start, end);

		// The recursive fork arrived at a leaf process. Return our input and 1 to count this leaf process.
		return (Result) {start, 1};
	}
	
	// First, spawn child processes for the two sub-ranges. The result is a file descriptor for a buffer where the child will write its results.
	int mid = start + (end - start) / 2;
	int child1 = spawnChild(start, mid);
	int child2 = spawnChild(mid + 1, end);
	
	// Read the results from the two file descriptors.
	Result res1 = readChild(child1);
	Result res2 = readChild(child2);

	// Wait for the 2 child processes to exit and return the summed result.
	// Add 1 to the number of processes to count the current process.
	wait(0);
	wait(0);
	return (Result) {res1.sum + res2.sum, res1.num + res2.num + 1};
}

// parseInt is a helper function to parse an integer and exit with an error message, if parsing fails.
int parseInt(char *str, char *errMsg) {
	char *endptr = NULL;
	errno = 0;
	int result = strtol(str, &endptr, 10);
	if (errno != 0) {
		perror(errMsg);
		exit(1);
	}
	if (*endptr) {
		fprintf(stderr, "%s: %s\n", errMsg, str);
		exit(1);
	}
	return result;
}

// The main function parses the two command line arguments: The start and end of the number range to sum up.
// Afterwards, it calls forkbench() with the two given parameters.
// After forkbench() completes, the expected result of the sum is computed for validation, using the Gauß sum formula.
// The time for the forkbench() function is measured and the number of forks per second is printed to the standard output.
void main(int argc, char **args) {
	// Parse parameters
	if (argc != 3) {
		fprintf(stderr, "Need 2 parameters: start and end\n");
		exit(1);
	}
	int start = parseInt(args[1], "Failed to parse start argument");
	int end = parseInt(args[2], "Failed to parse end argument");

	// Compute the result using forkbench() and measure the time.
	struct timespec startTime={0,0}, endTime={0,0};
    clock_gettime(CLOCK_MONOTONIC, &startTime);
	Result result = forkbench(start, end);
	clock_gettime(CLOCK_MONOTONIC, &endTime);
	double seconds = ((double) endTime.tv_sec + 1.0e-9*endTime.tv_nsec) - ((double) startTime.tv_sec + 1.0e-9*startTime.tv_nsec);

	// Output the number of forks per second. This is the only output on the stdout.
	printf("%.2f\n", (double) result.num / seconds);

	// Compare the result to the expectation and print the result.
	int test = (end*(end+1)/2) - (start*(start+1)/2) + start;
	if (test == result.sum) {
		fprintf(stderr, "Correct result: %d\n", result.sum);
		exit(0);
	} else {
		fprintf(stderr, "Wrong result: %d (should be: %d)\n", result.sum, test);
		exit(1);
	}
}

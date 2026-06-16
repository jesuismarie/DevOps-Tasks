#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

int	main(void)
{
	pid_t	pid;

	pid = fork();
	if (pid == 0)
	{
		printf("Child PID: %d — exiting now\n", getpid());
		exit(0);
	}
	printf("Parent PID: %d — not calling wait()\n", getpid());
	while (1)
		sleep(1);
	return (0);
}
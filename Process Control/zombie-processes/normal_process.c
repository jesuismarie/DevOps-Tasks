#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int	main(void)
{
	pid_t	pid;
	int		status;

	pid = fork();
	if (pid == 0)
	{
		printf("Child PID: %d — exiting now\n", getpid());
		exit(0);
	}
	printf("Parent PID: %d — waiting for child\n", getpid());
	wait(&status);
	printf("Parent: child exited with status %d — cleaned up\n", WEXITSTATUS(status));
	while (1)
		sleep(1);
	return (0);
}
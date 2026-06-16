# Zombie Processes ☠️

## Overview

When a child process exits, the kernel doesn't remove it from the process table immediately.
It keeps a minimal entry (PID, exit status) until the parent collects it via `wait()`.
A zombie is a child that has exited but whose parent never called `wait()`.

## Zombie Process (Bad)

The parent forks a child, the child exits immediately, but the parent never calls `wait()`.
The child stays in `Z` (zombie) state indefinitely.

```c
pid = fork();
if (pid == 0)
{
	printf("Child PID: %d — exiting now\n", getpid());
	exit(0);
}
// Parent never calls wait()
while (1)
	sleep(1);
```

Compile and run:
```bash
cc -o zombie zombie_process.c
./zombie
```

Verify:

```bash
ps aux | grep <PID>
```

Output:

```bash
<USER>    <PID>  0.0  0.0      0     0 pts/0    Z+   10:32   0:00 [zombie] <defunct>
```

You will see the child listed as `Z` with `<defunct>` next to its name.

## Normal Process (Good)

The parent forks a child, the child exits, and the parent calls `wait()` to collect
the exit status and clean up the process table entry.

```c
pid = fork();
if (pid == 0)
{
	printf("Child PID: %d — exiting now\n", getpid());
	exit(0);
}
wait(&status);
printf("Parent: child exited with status %d — cleaned up\n", WEXITSTATUS(status));
```

Compile and run:
```bash
cc -o normal normal_process.c
./normal
```

No zombie is created — the child is fully removed from the process table.

## Why Zombies Happen

| Step                        | What happens                                 |
|-----------------------------|----------------------------------------------|
| Child calls `exit()`        | Process stops executing, kernel marks it `Z` |
| Kernel keeps entry          | Stores PID + exit status, waiting for parent |
| Parent calls `wait()`       | Entry removed, PID freed                     |
| Parent never calls `wait()` | Entry stays forever → zombie                 |

## Why Zombies Are Dangerous in Large Numbers

Each zombie still holds a slot in the kernel process table.
Linux has a hard limit on how many processes can exist simultaneously:

```bash
cat /proc/sys/kernel/pid_max
```

If a buggy parent keeps spawning children without calling `wait()`, zombies accumulate
and eventually exhaust the PID limit. At that point the system cannot create any new
processes — which is effectively a denial of service.

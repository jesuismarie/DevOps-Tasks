# Process Monitoring with `htop` 🧠

## Description

### PID

Process ID  a unique number the kernel assigns to each running process. It's used to interact with that process (kill, taskset, renice, etc.).

### USER

The user account that owns/runs the process. Helps spot whether something is running as a normal user, a service account, or unexpectedly as root.

### PRI

`PRI` is the scheduling priority assigned by the Linux scheduler, which determines how much CPU time a process receives. Lower numbers mean higher priority. The kernel uses a range from 0 to 139:

- 0 to 99: reserved for real-time processes.
- 100 to 139: used for normal (non-real-time) processes.

### NI

The "nice" value is a user-space setting that lets users influence a process's priority. It directly affects the priority. A lower nice value means higher priority (more CPU time). The range is -20 to 19:

- -20: highest priority (least "nice" to other processes)
- 0: default priority
- 19: lowest priority (most "nice" to other processes)

The kernel combines the nice value with other factors to calculate the actual `PRI`. Roughly calculated as:

```
PRI = 20 + NI
```

### VIRT

Virtual memory size — the total virtual memory mapped by the process, including shared libraries, memory-mapped files, and allocated-but-unused space. It can be much larger than actual RAM usage, so it's not a reliable indicator on its own.

### RES

Resident memory - the amount of physical RAM the process is currently using. This is usually the number that matters when checking memory usage.

### SHR

Shared memory — the portion of RES shared with other processes, such as common libraries (e.g. `libc`). Explains why RES can look high even for small processes.

### S

Current process state:

| State | Meaning |
| ----- | ------- |
| R | Running (executing on CPU) |
| S | Sleeping (waiting for an event — user input, disk activity, etc.) |
| D | Uninterruptible sleep (waiting on kernel-level I/O, e.g. disk) |
| T | Stopped (remains in memory but isn't executing) |
| Z | Zombie (finished but not yet cleaned up by its parent) |

### CPU%

Percentage of CPU time the process is currently using (per core — can exceed 100% for multithreaded processes on multi-core systems).

### MEM%

Percentage of total system RAM used by the process's RES.

### TIME+

Total accumulated CPU time the process has used since it started — actual CPU-seconds consumed.

### COMMAND

The command/binary that launched the process, including its arguments.

## Troubleshooting

1. **CPU%** – Spot immediate high CPU usage (look for processes consistently above 50–80%).
2. **MEM% / RES** – Find memory hogs. High RES combined with high MEM% can point to a memory leak or a process that needs more RAM.
3. **COMMAND** – Identifies what's actually using resources (e.g. `chrome`, `java`, `postgres`, `nginx`).
4. **PID** – Once you've found the culprit, you need its PID to act on it (kill, renice, debug, etc.).
5. **TIME+** – Useful for spotting long-running processes slowly accumulating CPU time, like cron jobs, daemons, or background workers.
6. **S (State)** – Watch for many processes stuck in `D` (disk I/O bottleneck) or `Z` (zombies — usually harmless, but can indicate a parent process issue).
7. **USER** – Helps determine whether a process is a normal user app, a system service, or potentially suspicious (e.g. an unexpected root process).

# System Hang (Danger Zone) ⚠️

## Fork Bomb

**Script:**

```bash
fork_bomb(){ fork_bomb | fork_bomb & }; fork_bomb
```

### Description:

Defines a function that recursively calls itself twice in the background on each execution.
This causes exponential process creation until the system runs out of PIDs.

### Observed behavior:

* System becomes unresponsive within seconds
* No new processes can be created
* SSH sessions drop
* Input devices (mouse/keyboard) stop responding

### Recovery:

* Hard reboot required
* No recovery possible once PID table is exhausted

## CPU Stress Test

**Script:**

```bash
#!/bin/bash

echo "Starting CPU stress test..."

CORES=$(nproc)

for i in $(seq 1 $CORES); do
	yes > /dev/null &
done

echo "CPU load started on $CORES cores."

wait
```

### Description:

Creates one infinite CPU loop per available core using `yes > /dev/null`.

### Observed behavior:

* CPU usage reaches ~100% per core
* System remains responsive but heavily slowed
* Fans increase speed due to load
* Other processes experience latency

### Recovery:

```bash
pkill yes
# or
killall yes
```
## Memory Exhaustion

**Script:**

```bash
#!/bin/bash

memory=()

while true; do
	memory+=( "$(dd if=/dev/urandom bs=1M count=1 2>/dev/null | base64)" )
done
```

### Description:

* Continuously allocates 1MB chunks of random data
* Stores data in a bash array
* Memory usage grows indefinitely

### Observed behavior:

* RAM usage increases rapidly
* Swap memory becomes fully utilized
* System performance degrades significantly
* Linux OOM (Out-Of-Memory) killer may activate

### Recovery:

```bash
dmesg | grep -i "oom\|killed process"
kill -9 <PID>
```

* Identify killed or hanging process via logs
* Terminate process manually if system is still responsive
* Reboot if system is fully frozen

## ⚠️ Safety Note

* These tests must be run **only inside a VM**
* Never run on production or host systems
* Always ensure recovery method is known before execution

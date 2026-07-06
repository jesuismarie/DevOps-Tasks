# Signal Handling (SIGTERM) 🛑

This script demonstrates how to trap the **SIGTERM** signal in Bash so the process cannot be easily terminated with the standard `kill` command.

## Script

```bash
#!/bin/bash

trap "echo \"You can't terminate me\"" SIGTERM

echo "Process started with PID: $$"

while true; do
	sleep 1
done
```

## How to Use

1. Save the script as `sigterm_handler.sh`
2. Make it executable:
   ```bash
   chmod +x sigterm_handler.sh
   ```
3. Run the script:
   ```bash
   ./sigterm_handler.sh
   ```

## Send SIGTERM

SIGTERM is the default signal sent by the `kill` command.

```bash
kill <PID>
# or
kill -15 <PID>
# or
kill -TERM <PID>
```

## Why the Process Survives

The trap command registers a custom handler for the SIGTERM signal. When SIGTERM is received, Bash executes the command inside the trap (echo "You can’t terminate me"). Because the trap handler does not contain exit or any termination command, the script continues normal execution.

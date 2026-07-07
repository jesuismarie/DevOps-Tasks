# Process Control

This task focuses on **Linux process management, signals, permissions, and system behavior under load**.

The goal is to understand **how processes work, how they are controlled, and how misuse can impact system stability**.

⚠️ Some tasks are **intentionally dangerous** (system hang).

They **must be executed only in a test VM**.

---

## Task Overview

You will work with:

- Linux processes and signals
- Process states and monitoring
- Shell scripting
- System stability and failure scenarios

Emphasis is on **understanding**, not harming production systems.

---

## Tools / Commands 🔧

- `htop`
- `ps`, `top`
- Bash scripting
- Linux signals (`SIGTERM`, `SIGKILL`, etc.)
- `/proc` filesystem

---

## Tasks 📝

### Process Monitoring with `htop` 🧠

Explain the following **htop columns** in your own words:

- PID
- USER
- PRI / NI
- VIRT
- RES
- SHR
- S (Process State)
- CPU%
- MEM%
- TIME+
- COMMAND

📄 Document:

- What each column means
- Which ones are most important for troubleshooting

---

### Root Permission Check Script 🔒

Write a **very simple shell script** that:

1. Checks if the script is **not executed as root**
2. If not root, prints:

	```
	Please execute this script with sudo
	```

3. Exits with a non-zero exit code

🧪 Test the script both:

- With `sudo`
- Without `sudo`

---

### Signal Handling (SIGTERM) 🛑

Create a script that:

1. Runs in an infinite loop (e.g., `sleep`)
2. Traps `SIGTERM`
3. When `SIGTERM` is received, prints:

	```
	You can’t terminate me
	```

4. Continues running after the signal

📄 Document:

- How you sent the signal
- Why the process survived

---

### Zombie Processes ☠️

Demonstrate **how zombie processes are created**:

1. Create a parent process
2. Fork a child process
3. Let the child exit
4. Prevent the parent from calling `wait()`

🧪 Verify:

- Zombie state using `ps` or `htop`
- Explain why zombies happen
- Explain why they are dangerous in large numbers

---

### System Hang (Danger Zone) ⚠️

Create **one** of the following (script or one-liner):

- A fork bomb
- A process that consumes 100% CPU
- A process that exhausts memory

🔥 Requirements:

- Run **only in a VM**
- Document how the system behaves
- Document how to recover (reboot, kill, rescue mode)

---

## Safety Rules 🚨

- ❌ DO NOT run these tasks on your laptop or production systems
- ✅ Use a disposable VM
- ✅ Snapshot before testing dangerous commands

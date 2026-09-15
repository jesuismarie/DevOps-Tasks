# Containerization Task

## Overview 🖥️

The goal of this task is to create and manage Linux containers **without using Docker or other containerization daemons**. You will work with native Linux tools to isolate processes, filesystem, and resources. This exercise helps understand how containers work at a low level.

Focus on **practical implementation, clean commands, and documentation**.

---

## Functional Requirements 🔧

### 1. Namespace Isolation

- Use the `unshare` command to create a new namespace.
- Demonstrate:
	- PID namespace (process isolation)
	- Mount namespace (separate filesystem view)
	- Network namespace (optional, isolated network)
	- UTS namespace (hostname isolation)
- Provide examples of running processes in this namespace.

---

### 2. Filesystem Isolation

- Use `chroot` to create an isolated filesystem environment.
- Prepare a minimal Linux filesystem for the container.
- Demonstrate running commands inside this chrooted environment.

---

### 3. Resource Limits with cgroups ⏱️

- Use **cgroups** (via `libcgroup` or `systemd`) to restrict resources for the container:
	- CPU usage
	- Memory usage
	- Number of processes (pids)
- Demonstrate applying limits to the containerized processes.

---

### 4. Combined Container Example 🐢

- Combine **unshare**, **chroot**, and **cgroups** to create a simple fully isolated container.
- Demonstrate:
	- Running a process inside the container
	- Resource limits are applied
	- Containerized process cannot affect host filesystem outside chroot
- Include commands/scripts to automate container creation (optional).

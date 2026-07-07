# Aceess Control

This task focuses on **Linux access control, user management, sudo configuration, namespaces, and CPU resource allocation**.

The goal is to gain hands-on experience with **user permissions, ACLs, PAM, sudoers, namespaces, and cgroups**.

---

## Task Overview

You will perform tasks related to:

- File permissions and ACLs
- User account management
- Sudoers configuration
- PAM configuration
- Namespaces and isolated environments
- CPU resource allocation

Focus on **practical implementation, correctness, and documentation**.

---

## Technology / Tools 🔧

- Linux (any modern distribution)
- Bash / Shell scripting
- Systemd
- Linux namespaces
- Control Groups (cgroups)
- PAM configuration
- `/etc/sudoers` and `visudo`
- ACL (`setfacl`, `getfacl`)

---

## Tasks 📝

### File Access Control (ACLs) 🖥️

1. Show examples of file ACLs:
	- How to set ACLs for a user or group
	- How to view ACLs
2. Create a directory and assign specific read/write/execute permissions to multiple users
3. Test access as different users

---

### User Account Management 🔒

1. Manipulate user accounts:
	- Disable a user account
	- Disable a password for a user
	- Create a user without a default shell
2. Set password requirements for an account:
	- Minimum length
	- Complexity rules
	- Force users to comply
3. Document all changes and commands used

---

### Sudo / Privilege Management 🔧

1. Explore `/etc/sudoers` and `visudo`:
	- Allow sudoers to run sudo commands **without a password**
2. Configure user `myapp` and service `myapp.service`:
	- `myapp` can restart/start the service **without password**
	- Cannot run other sudo commands
3. Use PAM to allow sudoers to run `su` and `su -` without root password
4. Document configuration, commands, and tests

---

### Linux Namespaces & Capabilities 🖥️

1. Create a new Linux namespace:
	- Run `bash` inside it
	- Ensure it **cannot see processes in the main namespace**
2. Add capability to create a virtual network device inside the namespace
3. Document all steps

---

### CPU Resource Management ⏱️

1. Configure Linux to **not use one CPU core by default**
2. Schedule certain tasks to run **on that CPU core**:
	- Use Linux **control groups (cgroups)**
	- Adjust **GRUB kernel arguments** if needed
3. Document how to test CPU allocation and confirm behavior

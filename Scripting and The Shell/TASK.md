# Scripting and The Shell

## Overview

This task focuses on **shell initialization, scripting, and command-line automation** in Linux. You will explore the initialization files, understand shell behavior, and create a password generator script with configurable options.

The goal is to **learn shell scripting, argument parsing, and Linux core commands**.

---

## Task Requirements

### Shell Initialization Files 🖥️🔧

Explain the purpose of the following files:

- Login and non-login shell
- `/etc/profile`
- `/etc/bash.bashrc`
- `/etc/profile.d/`
- `~/.profile`
- `~/.bash_profile`
- `~/.bashrc`
- `~/.bash_login`
- `~/.bash_logout`

Provide **examples** of how and when each file is executed and how they affect the shell environment.

---

### Understand the Fork Bomb ⚠️

Explain what the following code does:

```bash
:() { :|: & };:
```

- Describe its behavior
- Explain why it is dangerous
- Discuss how to protect against it

---

### Password Generator Script ⚙️🔒

Write a **Bash script** that generates random passwords with the following features:

- Users can pass options for:
	- **Length** of the password
	- **Character types**:
		- Alphabetic
		- Numeric
		- Special characters
- Use `getopt` to allow **short and long options**
- Output the generated password to standard output

**Example usage:**

```bash
./password_generator.sh --length 16 --alpha --numeric --special
./password_generator.sh -l 12 -a -n
```

**Requirements:**

- Script must validate input options
- Script must provide help output (`h` / `-help`)
- Use Linux core commands only (no external dependencies)

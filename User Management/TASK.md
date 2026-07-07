# User Management

## Overview

The goal of this task is to **create and manage a Linux user without using standard user creation commands** (`useradd`, `adduser`). The user should have controlled system limits, assigned group membership, and an initial setup in their home directory.

Focus on **practical user management, resource control, and scripting skills**.

---

## Task Requirements

### User Creation

- Create a user named `test` **without using `useradd` or `adduser`**
- User must have a **login shell**
- User must have a **password set and expired**, so they are forced to create a new one at first login
- `/home/test` directory must exist and include basic files and directories, such as:
	- `.bashrc`
	- `.profile`
	- `Documents/`
	- `Downloads/`

---

### Group Management

- Create a group named `test`
- Add the `test` user to the `test` group

---

### Resource Limits

Configure system restrictions for the `test` user:

| Resource | Limit |
| --- | --- |
| Disk usage | Maximum **10 GB** |
| Processes | Maximum **100 processes** |
| Open files | Maximum **104800 files at once** |
| RAM usage | Maximum **20% of total RAM** |

**Hint:** You may use:

- `/etc/security/limits.conf`
- `ulimit`
- Cgroups

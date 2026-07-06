# Linux File Permissions Quiz 📄

## 1. File Ownership

Every file and directory in Linux has:

* **Owner (User)** → user who owns the file
* **Group** → group associated with the file
* **Others** → all remaining users

View ownership:

```bash
ls -l file.txt
```

Example output:

```text
-rw-r--r-- 1 alice developers 120 Jun 17 10:00 file.txt
```

* `alice` → owner
* `developers` → group

Change ownership:

```bash
sudo chown alice file.txt
sudo chown alice:developers file.txt
```

Change group:

```bash
sudo chgrp developers file.txt
```

## 2. Permission Bits (rwx)

Linux permissions are represented by:

| Permission | Symbol | Value |
| ---------- | ------ | ----- |
| Read       | `r`    | 4     |
| Write      | `w`    | 2     |
| Execute    | `x`    | 1     |

Example:

```text
-rwxr-xr--
```

Breakdown:

| Entity | Permissions |
| ------ | ----------- |
| Owner  | `rwx` (7)   |
| Group  | `r-x` (5)   |
| Others | `r--` (4)   |

Equivalent numeric mode:

```bash
chmod 754 file.txt
```

Common examples:

```bash
chmod 644 file.txt
chmod 755 script.sh
chmod 600 secret.txt
```

## 3. Special Permissions

### setuid

Allows a program to run with the permissions of its owner.

```bash
chmod u+s file
```

Example:

```bash
ls -l /usr/bin/passwd
```

Output:

```text
-rwsr-xr-x
```

* `s` in owner's execute position indicates `setuid`

### setgid

For executables:

* Process runs with the file's group permissions

For directories:

* New files inherit the directory's group

```bash
chmod g+s directory
```

Example:

```text
drwxrwsr-x
```

### Sticky Bit

Used mainly on shared directories.

```bash
chmod +t directory
```

Example:

```bash
ls -ld /tmp
```

Output:

```text
drwxrwxrwt
```

* Only file owner (or root) can delete files

## 4. Access Control Lists (ACLs)

ACLs provide more granular permissions than traditional owner/group/other permissions.

### View ACLs

```bash
getfacl file.txt
```

Example:

```text
user::rw-
user:alice:r--
group::r--
mask::r--
other::---
```

### Set ACLs

Grant read permission to a user:

```bash
setfacl -m u:alice:r file.txt
```

Grant read and write permission:

```bash
setfacl -m u:bob:rw file.txt
```

Grant permissions to a group:

```bash
setfacl -m g:developers:rwx project/
```

### Remove ACLs

Remove ACL for a user:

```bash
setfacl -x u:alice file.txt
```

Remove all extended ACL entries:

```bash
setfacl -b file.txt
```

## ACL Demonstration

Create a test file:

```bash
echo "Hello ACL" > testfile
chmod 600 testfile
```

Grant permissions:

```bash
setfacl -m u:alice:r testfile
setfacl -m u:bob:rw testfile
```

View ACL configuration:

```bash
getfacl testfile
```

Expected result:

* `alice` → read access
* `bob` → read and write access
* Other users → no access

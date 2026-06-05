# File Access Control (ACLs) 🖥️

## Write a script [acl_management.sh](./acl_management.sh)

### 1. System protection setting (temporary)

At the beginning of the script, a kernel parameter is modified:

```bash
sudo sysctl -w fs.protected_regular=0
```

* Temporarily disables certain file protection mechanisms (lab/testing only)
* Used to simplify controlled permission experiments

At the end of the script, it is restored:

```bash
sudo sysctl -w fs.protected_regular=2
```

### 2. Test file creation

A test file is created in `/tmp`:

```bash
echo "Hello from user debian" > /tmp/testfile
```

### 3. Base permissions setup

Standard UNIX permissions are applied:

```bash
chmod 600 /tmp/testfile
```

* Only the owner can read and write
* All other users are denied access by default

### 4. ACL configuration

Fine-grained permissions are defined using ACLs:

```bash
setfacl -m u:alice:r /tmp/testfile
setfacl -m u:bob:rw /tmp/testfile
```

Resulting access rules:

* `alice` → read only (`r`)
* `bob` → read and write (`rw`)
* `charle` → no ACL entry → no access

### 5. Permission inspection

The script verifies permissions using:

```bash
ls -l /tmp/testfile
getfacl /tmp/testfile
```

This shows:

* Traditional UNIX permissions (`chmod`)
* Extended ACL rules

### 6. Access testing logic

Each user is tested via:

```bash
sudo su - <user> -c "<command>"
```

Two checks are performed:

* `test_read()` → verifies read access
* `test_write()` → verifies write (append) access

Output format:

```
USERNAME   READ/WRITE   [PASS/FAIL]
```

### 7. Users tested

* `alice`
* `bob`
* `charle` (no ACL entry → expected to fail both tests)

### 8. Final verification

The final file content is displayed:

```bash
cat /tmp/testfile
```

This confirms:

* Which users successfully wrote to the file
* Final state of the shared resource

## Expected Results

| User   | Read | Write | Explanation          |
| ------ | ---- | ----- | -------------------- |
| alice  | ✔    | ✘     | ACL allows read only |
| bob    | ✔    | ✔     | Full ACL access      |
| charle | ✘    | ✘     | No ACL permissions   |

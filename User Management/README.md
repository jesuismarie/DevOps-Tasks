# User Management 👤

## User Creation

### Create custom skeleton directory

```bash
sudo mkdir -p /etc/custom_skel
```

Create required user directory structure:

```bash
sudo mkdir -p /etc/custom_skel/Documents
sudo mkdir -p /etc/custom_skel/Downloads
```

Copy default shell configuration files:

```bash
sudo cp /etc/skel/.bashrc /etc/custom_skel/.bashrc
sudo cp /etc/skel/.profile /etc/custom_skel/.profile
```

### Create user

```bash
sudo useradd -m -s /bin/bash -k /etc/custom_skel test
```

* `-m` → creates home directory
* `-s /bin/bash` → assigns login shell
* `-k /etc/custom_skel` → uses skeleton directory for initial files

### Set password

```bash
sudo passwd test
```

### Force password change on first login

```bash
sudo passwd -e test
```

* Expires password immediately
* Forces user to set a new password at next login

## Group Management

By default, `useradd` creates a primary group with the same name as the user.

If manual creation is needed:

```bash
sudo groupadd test
sudo usermod -aG test test
```

* `groupadd` → creates group `test`
* `usermod -aG` → adds user to supplementary group

## Resource Limits

### Disk usage (Quota)

Install quota tools:

```bash
sudo apt install quota -y
```

Check disk usage:

```bash
df -h /home
```

### Enable quota in filesystem

Edit `/etc/fstab`:

```bash
/dev/sda1  /home  ext4  defaults,usrquota  0  2
```

Apply changes:

```bash
sudo mount -o remount /home
sudo quotacheck -cum /home
sudo quotaon /home
```

### Set disk limit (10 GB)

```bash
sudo setquota -u test 10485760 10485760 0 0 /home
```

* Soft limit: 10 GB
* Hard limit: 10 GB

Verify:

```bash
sudo quota -u test
```

## Processes limit

Edit limits configuration:

```bash
sudo vim /etc/security/limits.conf
```

Add:

```ini
test    soft    nproc       100
test    hard    nproc       100
```

* `soft` → warning/usable limit
* `hard` → maximum enforced limit
* `nproc` → max number of processes

## Open files limit

Edit:

```bash
sudo vim /etc/security/limits.conf
```

Add:

```ini
test    soft    nofile      104800
test    hard    nofile      104800
```

* `nofile` → maximum open file descriptors per user

## RAM usage limit

Check system memory:

```bash
free -m
```

Create systemd slice:

```bash
sudo vim /etc/systemd/system/user-test.slice
```

Add:

```ini
[Unit]
Description=Resource limits for test user

[Slice]
MemoryMax=20%
```

Apply changes:

```bash
sudo systemctl daemon-reload
sudo systemctl start user-test.slice
```

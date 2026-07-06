# Volume Management & Partitioning 🔧

## Attach A Volume

Go to VM settings.
Navigate to **Storage**.
In **Controller SATA**, click **Add Hard Disk**.
Create a new virtual disk.

Start the machine and verify that the system detects the new disk:

```bash
lsblk
```

You should see something like:

```bash
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   30G  0 disk 
sdb      8:16   0    5G  0 disk 
```

## Create partitions

### `fdisk`

```bash
sudo fdisk /dev/sdb
```

Inside `fdisk`, do the following:

* `g` → create GPT partition table (recommended)
* `n` → new partition

  * Partition size: `+2G`
* `n` → second partition (optional depending on task)
* `w` → write changes

### `cfdisk`

```bash
sudo cfdisk /dev/sdb
```

Inside `cfdisk`, do the following:

* Select **Free space**
* `New` → create partition

  * Size: `+1G`
* `Write` → confirm changes
* `Quit` → exit menu

### `gdisk`

```bash
sudo gdisk /dev/sdb
```

Inside `gdisk`, do the following:

* `n` → new partition

  * Size: `+3G`
* `w` → write changes

### Confirm partitions

```bash
lsblk
```

You should see partitions like:

```bash
sdb1
sdb2
sdb3
```

## Configure Swap Space 🔒

### Create swap area

```bash
sudo mkswap /dev/sdb2
```

Example output:

```bash
Setting up swapspace version 1, size = 1024 MiB (1073737728 bytes)
no label, UUID=<UUID>
```

### Activate swap temporarily

```bash
sudo swapon /dev/sdb2
```

### Verify swap

```bash
swapon --show
free -h
```

## Persistent swap configuration

### Get UUID

```bash
sudo blkid
```

Example output:

```bash
/dev/sdb2: UUID="xxxx-xxxx" TYPE="swap"
```

### Edit fstab

```bash
sudo vim /etc/fstab
```

Add the following line:

```bash
UUID=<UUID> none swap sw 0 0
```

## Final verification

After reboot or reload:

```bash
swapon --show
lsblk
```

# LVM Configuration 🖥️

## Attach Volumes

Go to VM settings.
Navigate to **Storage**.
In **Controller SATA**, click **Add Hard Disk**.
Create two new virtual disks.

Start the machine and verify that the system detects the new disks:

```bash
lsblk
```

You should see something like:

```bash
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   30G  0 disk 
sdb      8:16   0    5G  0 disk 
sdc      8:32   0    5G  0 disk 
sdd      8:48   0    5G  0 disk 
```

## Configure LVM

### Physical Volumes (PVs)

Create physical volumes:

```bash
sudo pvcreate /dev/sdc /dev/sdd
```

Verify:

```bash
sudo pvdisplay
# or
sudo pvs
```

### Volume Group (VG)

Create volume group:

```bash
sudo vgcreate vg_data /dev/sdc /dev/sdd
```

Verify:

```bash
sudo vgdisplay
# or
sudo vgs
```

### Logical Volumes (LVs)

Create logical volumes:

```bash
sudo lvcreate -L 2G -n lv_app vg_data
sudo lvcreate -L 2G -n lv_logs vg_data
```

Verify:

```bash
sudo lvdisplay
# or
sudo lvs
```

### Format Logical Volumes

```bash
sudo mkfs.ext4 /dev/vg_data/lv_app
sudo mkfs.ext4 /dev/vg_data/lv_logs
```

### Create mount points

```bash
sudo mkdir -p /mnt/app
sudo mkdir -p /mnt/logs
```

### Mount logical volumes

```bash
sudo mount /dev/vg_data/lv_app /mnt/app
sudo mount /dev/vg_data/lv_logs /mnt/logs
```

### Make configuration persistent

Get UUIDs:

```bash
sudo blkid
```

Edit fstab:

```bash
sudo nano /etc/fstab
```

Add:

```text
UUID=bc3dc679-f405-4e47-a6f4-94a83f6c5cea  /mnt/app   ext4  defaults  0  2
UUID=fd771699-1599-4e4d-a71f-fc70db54577c  /mnt/logs  ext4  defaults  0  2
```

### Apply changes

Reload systemd configuration:

```bash
sudo systemctl daemon-reload
```

Apply mounts:

```bash
sudo mount -a
```

### Verify setup

```bash
df -h
```

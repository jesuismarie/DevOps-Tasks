# Filesystem Management

## Overview

This task focuses on managing storage in Linux, including attaching volumes, partitioning, configuring swap, using LVM, and understanding file permissions. You will learn how to safely manipulate disks, manage swap, and organize storage for virtual machines.

---

## Tasks 📝

### Volume Management & Partitioning 🔧

1. **Attach a volume to a virtual machine**
	- Use your preferred virtualization platform (e.g., VMware, VirtualBox, AWS EC2, Hetzner VM).
	- Ensure the OS recognizes the new volume.
2. **Create partitions using different tools**
	- `fdisk`
	- `gdisk`
	- `cfdisk`
	- Create at least **two partitions per disk**.
	- Document the differences and commands for each tool.
3. **Configure Swap Space 🔒**
	- Create a swap **partition** on one of the disks and enable it.
	- Create a swap **file** on another disk and enable it.
	- Ensure persistence across reboots by editing `/etc/fstab`.
	- Verify with `swapon --show` and `free -h`.

---

### LVM Configuration 🖥️

1. **Attach two additional volumes** to your VM.
2. **Configure LVM**:
	- Create **physical volumes** (PVs) for each disk.
	- Create a **volume group** (VG) containing the PVs.
	- Create **logical volumes** (LVs) from the VG.
	- Format the LVs with a filesystem (e.g., ext4) and mount them.
3. Verify using:
	- `pvdisplay`
	- `vgdisplay`
	- `lvdisplay`
	- Mounted volumes with `df -h`

---

### Linux File Permissions Quiz 📄

1. Fill out the quiz covering:
	- File ownership
	- Permission bits (rwx)
	- Special permissions (`setuid`, `setgid`, sticky bit)
	- ACLs (Access Control Lists)
2. Demonstrate:
	- Setting and viewing ACLs using `setfacl` and `getfacl`.

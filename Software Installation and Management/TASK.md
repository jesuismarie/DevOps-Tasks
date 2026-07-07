# Software Installation and Management

## Overview

This task covers **software installation, package management, and repository creation** on both RPM and DEB-based Linux distributions. You will simulate a client-server setup, mirror package repositories, and create/install signed packages.

The focus is on **Linux package management, networking, and GPG signing**.

---

## Technology Stack

- Ubuntu (DEB) and Fedora (RPM)
- Bash / Shell scripting
- GPG for signing packages
- Virtual Machines (VMs)
- AI assistant (for ping-pong game code generation)

---

## Task Requirements

### 1️⃣ Virtual Machines Setup 🖥️🌐

- Create two VMs in the same network:
	- **Server VM (S)**
	- **Client VM (C)**
- Both should have network connectivity between each other

---

### 2️⃣ Repository Mirroring and Configuration 🔧🌐

- On **Server VM (S)**:
	- Mirror the `kubectl` repository locally
- On **Client VM (C)**:
	- Configure to download `kubectl` packages from **Server VM (S)** instead of the internet
- Ensure that package updates are available to the client through the server mirror

---

### 3️⃣ Software Packaging 🔧🖥️

- Create a **simple ping-pong game** using an AI assistant
- Package the game as:
	- `.deb` for DEB-based systems
	- `.rpm` for RPM-based systems
- Host both packages in a package repository accessible via the network

---

### 4️⃣ GPG Signing 🔒

- Sign all packages (`.deb` and `.rpm`) with **GPG**
- Ensure the client can verify the packages and install them securely from the repository

---

### 5️⃣ Client Installation 🌐🔧

- Test installing both `.deb` and `.rpm` packages from the repositories on the client VM
- Verify that packages are correctly signed and functional

# High Availability Implementation Task (Percona + HAProxy + KeepaliveD) 🔗💽⚡

## Task Overview

You need to **implement a High Availability setup** for a VM-based database infrastructure.

The environment consists of:

- **3 VM nodes running Percona Database**
- **HAProxy** for database traffic routing
- An additional HA component that provides a **floating / virtual IP address**

The floating IP must automatically move between nodes to ensure **no single point of failure**.

---

## Goal 🎯

Deliver a **fully working High Availability setup** where:

- Database access uses a **single virtual IP**
- If a node fails, the IP automatically moves to a healthy node
- HAProxy continues serving traffic without manual intervention

---

## Architecture Requirements 🧱

- Virtual Machines (not Kubernetes)
- 3-node Percona DB cluster
- HAProxy in front of the database
- One **floating / virtual IP**
- Automatic failover between nodes

---

## Tasks to Implement 🛠

### 1️⃣ HA Component Setup (Floating IP)

- Install and configure an HA solution that supports **floating IP failover** (e.g. VRRP-based)
- Ensure the virtual IP can:
	- Attach to one active node
	- Move automatically on node failure
- Configure health checks for failover logic

---

### 2️⃣ HAProxy Integration

- Bind HAProxy to the **floating IP**
- Ensure HAProxy:
	- Routes traffic correctly to Percona nodes
	- Continues working after failover
- Validate no manual changes are needed during node loss

---

### 3️⃣ Percona Cluster Validation

- Ensure all 3 Percona nodes:
	- Are healthy and synchronized
	- Can handle failover scenarios
- Validate database connectivity through the virtual IP

---

### 4️⃣ Failover Testing 🚨

Perform and document the following tests:

- Stop HA component on the active node
- Shutdown one VM
- Restart HAProxy
- Simulate network loss

Expected result:

- Floating IP moves to another node automatically
- Database remains reachable
- No client-side configuration change needed

---

### 5️⃣ Security & Stability

- Run HA component with minimal required permissions
- Ensure no open or unused ports
- Validate startup on VM reboot
- Confirm HA survives node restarts

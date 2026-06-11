# Linux Namespaces & Capabilities 🖥️

## 1. Linux Namespace Creation

Create a new isolated Linux namespace:

```bash
sudo unshare --fork --pid --mount-proc --net bash
```

* `--fork` → creates a new process for the namespace
* `--pid` → isolates process IDs (PID namespace)
* `--mount-proc` → mounts a fresh `/proc` filesystem
* `--net` → creates a separate network namespace
* `bash` → starts a shell inside the namespace

### Verification

Inside the namespace:

```bash
ps aux
```

* Only processes inside the namespace are visible
* Main system processes are hidden

Check network isolation:

```bash
ip addr
```

* Shows only namespace-local network interfaces

## 2. Virtual Network Device Creation & Capabilities

To create virtual network devices inside the namespace, the process must have **network administration capabilities**.

### Check available capabilities:

```bash
capsh --print
```

Look for:

* `CAP_NET_ADMIN` → required for managing network interfaces

### Create virtual network interfaces (veth pair)

Inside the namespace, create a virtual Ethernet pair:

```bash
ip link add veth0 type veth peer name veth1
ip link set veth0 up
ip link set veth1 up
```

* `veth0` and `veth1` → virtual Ethernet pair (connected endpoints)
* `ip link add` → creates the virtual network device
* `type veth` → specifies virtual Ethernet type
* `peer name` → creates the connected interface
* `ip link set up` → activates the interfaces

### Verification

Check network interfaces:

```bash
ip addr
```

* Confirms creation of virtual network devices
* Interfaces exist only within the namespace

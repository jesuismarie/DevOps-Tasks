# CPU Resource Management ⏱️

## 1. Adjust GRUB Kernel Parameters (Boot-Time CPU Isolation)

First, check how many CPU cores are available:

```bash
nproc
```

Edit GRUB configuration:

```bash
sudo vim /etc/default/grub
```

Find the line:

```ini
GRUB_CMDLINE_LINUX_DEFAULT
```

Add CPU isolation parameters:

```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet isolcpus=domain,2 nohz_full=2 rcu_nocbs=2"
```

* `isolcpus=domain,2` → removes CPU 2 from the normal scheduler
* `nohz_full=2` → disables periodic timer ticks on CPU 2 (reduces kernel noise)
* `rcu_nocbs=2` → moves RCU callbacks away from CPU 2

Apply changes and reboot:

```bash
sudo update-grub
sudo reboot
```

Verify isolation after reboot:

```bash
cat /sys/devices/system/cpu/isolated
```

* Should show CPU `2` (or your configured core)

## 2. Schedule tasks to a specific CPU core using cgroups

Check cgroup controller availability:

```bash
cat /sys/fs/cgroup/cgroup.controllers
```

If `cpuset` is not enabled:

```bash
echo "+cpuset" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
```

Create a dedicated cgroup:

```bash
sudo mkdir -p /sys/fs/cgroup/isolated_tasks
```

Assign CPU and memory affinity:

```bash
echo "2" | sudo tee /sys/fs/cgroup/isolated_tasks/cpuset.cpus
echo "0" | sudo tee /sys/fs/cgroup/isolated_tasks/cpuset.mems
```

* `cpuset.cpus = 2` → restricts tasks to CPU core 2
* `cpuset.mems = 0` → binds memory to NUMA node 0 (required for cpuset to work)

Verify configuration:

```bash
cat /sys/fs/cgroup/isolated_tasks/cpuset.cpus
```

Expected output:

```
2
```

Run a test process:

```bash
yes > /dev/null &
echo $!
```

Get the PID, then assign it to the cgroup:

```bash
echo <PID> | sudo tee /sys/fs/cgroup/isolated_tasks/cgroup.procs
```

Verify CPU affinity:

```bash
taskset -cp <PID>
```

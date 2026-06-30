# High Availability Implementation Task (Percona + HAProxy + Keepalived) 🔗💽⚡

## VM Installation

Create 3 virtual machines and install **Debian 13** on each.

Assign roles:

* db-node-1
* db-node-2
* db-node-3

## Set up Percona XtraDB Cluster

### Configure static IP (IMPORTANT FIXED VERSION)

> *⚠️ Do this on each VM*

1. Edit network config:

```bash
sudo nano /etc/network/interfaces
```

2. Set correct configuration

```ini
auto enp0s3

iface enp0s3 inet static
    address 192.168.86.101
    netmask 255.255.255.0
    gateway 192.168.86.1
    dns-nameservers 8.8.8.8 1.1.1.1
```

3. Change per VM:

| VM        | IP             |
| --------- | -------------- |
| db-node-1 | 192.168.86.101 |
| db-node-2 | 192.168.86.102 |
| db-node-3 | 192.168.86.103 |

4. Apply network changes

```bash
sudo systemctl restart networking
```

or if it fails:

```bash
sudo reboot
```

### Install Percona on each VM

```bash
sudo apt update
sudo apt install -y wget gnupg2 lsb-release curl

wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo dpkg -i percona-release_latest.generic_all.deb

sudo apt update
sudo percona-release setup pxc-84-lts

sudo apt install -y percona-xtradb-cluster
```

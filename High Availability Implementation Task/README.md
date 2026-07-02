# High Availability Implementation Task (Percona + HAProxy + Keepalived) 🔗💽⚡

## VM Installation

Create **3 virtual machines** and install **Debian 13** on each.

Assign the following roles:

- db-node-1
- db-node-2
- db-node-3

## Set Up Percona XtraDB Cluster

### Network Configuration

> ⚠️ Do this on **each VM**.

1. Edit the network configuration

```bash
sudo vim /etc/network/interfaces
```

2. Configure a static IP

```ini
auto enp0s3

iface enp0s3 inet static
    address 192.168.86.X
    netmask 255.255.255.0
    gateway 192.168.86.1
    dns-nameservers 8.8.8.8 1.1.1.1
```

3. Assign IP addresses

| VM        | IP             |
| --------- | -------------- |
| db-node-1 | 192.168.86.101 |
| db-node-2 | 192.168.86.102 |
| db-node-3 | 192.168.86.103 |

4. Apply the configuration

```bash
sudo systemctl restart networking
```

If the changes are not applied correctly:

```bash
sudo reboot
```

### Hostname Configuration

> ⚠️ Each node must have a unique hostname.

Set hostname:

```bash
sudo hostnamectl set-hostname db-node-1
```

Use the following values:

| VM | Hostname |
|----|----------|
| db-node-1 | db-node-1 |
| db-node-2 | db-node-2 |
| db-node-3 | db-node-3 |

### `/etc/hosts` Configuration

> ⚠️ Required for cluster communication.

```text
192.168.86.101 db-node-1
192.168.86.102 db-node-2
192.168.86.103 db-node-3
```

### Install Percona XtraDB Cluster

> ⚠️ Run on **all nodes**.

```bash
sudo apt update
sudo apt install -y wget gnupg2 lsb-release curl

wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo dpkg -i percona-release_latest.generic_all.deb

sudo apt update
sudo percona-release setup pxc-84-lts

sudo apt install -y percona-xtradb-cluster
```

During installation, you will be prompted to set the MySQL root password.

> ⚠️ Use the **same strong password on all three nodes**.

## Configure Percona XtraDB Cluster (Without SSL Encryption)

1. Configure each node

Edit:

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

Add or replace the following configuration:

```ini
[mysqld]

server-id=<node-num>

wsrep_provider=/usr/lib/galera4/libgalera_smm.so

wsrep_cluster_address=gcomm://192.168.86.101,192.168.86.102,192.168.86.103
wsrep_cluster_name=pxc-cluster

wsrep_node_name=pxc-node-<node-num>
wsrep_node_address=192.168.86.10X
pxc_strict_mode=ENFORCING

wsrep_sst_method=xtrabackup-v2

pxc-encrypt-cluster-traffic=OFF
```

> Replace `<node-num>` with `1`, `2`, or `3`, and replace `X` in the IP address with the corresponding node number.

2. Start the cluster

#### Bootstrap Node 1

```bash
sudo systemctl restart mysql@bootstrap
```

#### Start Nodes 2 and 3

```bash
sudo systemctl restart mysql
```

3. Verify the cluster

Check cluster size:

```bash
mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
```

Check node state:

```bash
mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_local_state_comment';"
```

Expected output:

```text
wsrep_cluster_size = 3
wsrep_local_state_comment = Synced
```

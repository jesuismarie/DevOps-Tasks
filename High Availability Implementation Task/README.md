# High Availability Implementation Task (Percona + HAProxy + Keepalived) 🔗💽⚡

## VM Installation

Create **3 virtual machines** and install **Debian 13** on each.

Assign roles:

* db-node-1
* db-node-2
* db-node-3

## Set Up Percona XtraDB Cluster

### Network Configuration

> ⚠️ Do this on **EACH VM**

1. Edit network config

```bash
sudo vim /etc/network/interfaces
```

2. Set static configuration

```ini
auto enp0s3

iface enp0s3 inet static
    address 192.168.86.X
    netmask 255.255.255.0
    gateway 192.168.86.1
    dns-nameservers 8.8.8.8 1.1.1.1
```

3. IP assignment

| VM        | IP             |
| --------- | -------------- |
| db-node-1 | 192.168.86.101 |
| db-node-2 | 192.168.86.102 |
| db-node-3 | 192.168.86.103 |

4. Apply changes

```bash
sudo systemctl restart networking
```

If it does not apply correctly:

```bash
sudo reboot
```

### Hostname Configuration

> ⚠️ Must be unique per node

```bash
sudo hostnamectl set-hostname db-node-1
```

| VM        | Hostname  |
| --------- | --------- |
| db-node-1 | db-node-1 |
| db-node-2 | db-node-2 |
| db-node-3 | db-node-3 |

### /etc/hosts Configuration

> ⚠️ Required for cluster communication

```text
192.168.86.101 db-node-1
192.168.86.102 db-node-2
192.168.86.103 db-node-3
```

### Install Percona XtraDB Cluster

> ⚠️ Run on **all nodes**

```bash
sudo apt update
sudo apt install -y wget gnupg2 lsb-release curl

wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo dpkg -i percona-release_latest.generic_all.deb

sudo apt update
sudo percona-release setup pxc-84-lts

sudo apt install -y percona-xtradb-cluster
```

During installation, you will be prompted for a MySQL root password.
> ⚠️ Use the **same strong password on all 3 nodes**.

### SSL Certificates

1. Generate CA (node-1 only)

```bash
mkdir ~/ssl-certs && cd ~/ssl-certs

openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 3650 \
  -key ca-key.pem -out ca.pem \
  -subj "/CN=PXC-Cluster-CA"
```

2. Generate node & client certificates

```bash
# Node certificate (db-node-1 example)
openssl req -newkey rsa:2048 -nodes \
  -keyout db-node-1-key.pem \
  -out db-node-1-req.pem \
  -subj "/CN=db-node-1"

openssl x509 -req -days 3650 -set_serial 01 \
  -in db-node-1-req.pem \
  -out db-node-1-cert.pem \
  -CA ca.pem -CAkey ca-key.pem

# Client certificate
openssl req -newkey rsa:2048 -nodes \
  -keyout client-key.pem \
  -out client-req.pem \
  -subj "/CN=PXC-Client"

openssl x509 -req -days 3650 -set_serial 01 \
  -in client-req.pem \
  -out client-cert.pem \
  -CA ca.pem -CAkey ca-key.pem
```

3. Move certificates

```bash
sudo mkdir -p /etc/mysql/certs

sudo cp ca.pem \
         db-node-1-cert.pem db-node-1-key.pem \
         client-cert.pem client-key.pem \
         /etc/mysql/certs/

sudo chown -R mysql:mysql /etc/mysql/certs

sudo chmod 600 /etc/mysql/certs/*-key.pem
sudo chmod 644 /etc/mysql/certs/*-cert.pem /etc/mysql/certs/ca.pem
```

4. Verify

```bash
ls -la /etc/mysql/certs/
```

Expected files:

* ca.pem
* client-cert.pem
* client-key.pem
* db-node-1-cert.pem
* db-node-1-key.pem

### PXC Configuration

#### Node 1 (BOOTSTRAP)

```ini
[mysqld]

server-id=1

wsrep_provider=/usr/lib/galera4/libgalera_smm.so

wsrep_provider_options="socket.ssl_key=/etc/mysql/certs/db-node-1-key.pem;socket.ssl_cert=/etc/mysql/certs/db-node-1-cert.pem;socket.ssl_ca=/etc/mysql/certs/ca.pem"

wsrep_cluster_name=pxc-cluster

wsrep_cluster_address=gcomm://192.168.86.101,192.168.86.102,192.168.86.103

wsrep_node_name=pxc-node-1
wsrep_node_address=192.168.86.101

binlog_format=ROW
innodb_autoinc_lock_mode=2

pxc_strict_mode=ENFORCING

wsrep_sst_method=xtrabackup-v2
wsrep_sst_auth=sstuser:<you-strong-password>
```

Bootstrap Node 1

```bash
sudo systemctl start mysql@bootstrap.service
sudo systemctl status mysql@bootstrap.service
```

Verify Cluster

```bash
mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
```

Expected output:

```
wsrep_cluster_size = 1
```

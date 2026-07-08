# High Availability Implementation Task (Percona + HAProxy + Keepalived) 🔗💽⚡

## Architecture

The client connects to a single **floating (virtual) IP address** — never to any node's real IP directly.

That VIP is bound, at any given moment, to whichever node is currently active. Keepalived owns that binding: it uses VRRP to assign the VIP to one node's network interface, and moves it to another node automatically if the active node fails its health check.

![PXC-HA-Architecture](pxc_ha_architecture.svg)

On the node holding the VIP, HAProxy is what's actually listening on that IP (port 3306). The real connection path is:

`Client → Floating IP → HAProxy (on whichever node currently holds the VIP) → one of the 3 Percona nodes (chosen by HAProxy's backend health check)`

HAProxy's backend check verifies each Percona node is actually synced with the cluster (`wsrep_local_state_comment = Synced`), not just reachable — so traffic never lands on a node that's up but out of sync.

The client only ever targets the VIP; Keepalived and HAProxy handle routing to a healthy node underneath.

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

3. Assign IP addresses — replace `X` with the value below on each node

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

| VM        | Hostname  |
|-----------|-----------|
| db-node-1 | db-node-1 |
| db-node-2 | db-node-2 |
| db-node-3 | db-node-3 |

### `/etc/hosts` Configuration

> ⚠️ Required for cluster communication. This file is **identical on all 3 nodes**.

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

### Configure Percona XtraDB Cluster (Without SSL Encryption)

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

> ⚠️ Bootstrap is **only** used to create a brand-new cluster from nothing. Only ever run it on **one** node.

**db-node-1 — bootstrap**

```bash
sudo systemctl start mysql@bootstrap
```

**db-node-2 and db-node-3 — normal start (join via SST)**

```bash
sudo systemctl start mysql
```

3. Verify the Cluster

Run on any node:

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

### Enable SSL Encryption (Optional)

**db-node-1**

1. Generate the CA key and certificate

```bash
mkdir ~/ssl-certs && cd ~/ssl-certs

openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 3650 \
  -key ca-key.pem -out ca.pem \
  -subj "/CN=PXC-Cluster-CA"
```

2. Generate the server private key and CSR:

```bash
openssl req -newkey rsa:2048 -nodes -days 3650 \
  -keyout server-key.pem \
  -out server-req.pem \
  -subj "/CN=pxc-server"
```

> ⚠️ Do NOT use the same Common Name you used for your CA certificate.

3. Generate the server certificate:

```bash
openssl x509 -req -in server-req.pem \
  -CA ca.pem -CAkey ca-key.pem \
  -set_serial 01 -days 3650 \
  -out server-cert.pem
```

4. Send the key and certificate files to the other two nodes:

```bash
scp ca.pem server-cert.pem server-key.pem <user>@192.168.86.102:/tmp/
scp ca.pem server-cert.pem server-key.pem <user>@192.168.86.103:/tmp/
```

5. Move certificates into place on db-node-1:

```bash
mkdir -p /etc/mysql/certs
mv ~/ssl-certs/ca.pem ~/ssl-certs/server-key.pem ~/ssl-certs/server-cert.pem /etc/mysql/certs/
chown -R mysql:mysql /etc/mysql/certs
```

**db-node-2 and db-node-3**

1. Install the certs sent from db-node-1

```bash
mkdir -p /etc/mysql/certs
mv /tmp/ca.pem /tmp/server-key.pem /tmp/server-cert.pem /etc/mysql/certs/
chown -R mysql:mysql /etc/mysql/certs
```

**All 3 Nodes**

1. Update the MySQL config

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

> Same substitution rules as the non-SSL config above — keep `server-id`, `wsrep_node_name`, and `wsrep_node_address` unique per node:

```ini
[mysqld]

server-id=<node-num>

wsrep_provider=/usr/lib/galera4/libgalera_smm.so

wsrep_provider_options="socket.ssl=yes;socket.ssl_key=/etc/mysql/certs/server-key.pem;socket.ssl_cert=/etc/mysql/certs/server-cert.pem;socket.ssl_ca=/etc/mysql/certs/ca.pem;"

wsrep_cluster_address=gcomm://192.168.86.101,192.168.86.102,192.168.86.103
wsrep_cluster_name=pxc-cluster

wsrep_node_name=pxc-node-<node-num>
wsrep_node_address=192.168.86.10X
pxc_strict_mode=ENFORCING

wsrep_sst_method=xtrabackup-v2

ssl-key=/etc/mysql/certs/server-key.pem
ssl-ca=/etc/mysql/certs/ca.pem
ssl-cert=/etc/mysql/certs/server-cert.pem

[sst]
encrypt=4
ssl-key=/etc/mysql/certs/server-key.pem
ssl-ca=/etc/mysql/certs/ca.pem
ssl-cert=/etc/mysql/certs/server-cert.pem
```

2. Start the Cluster with SSL

**db-node-1 — bootstrap**

```bash
sudo systemctl start mysql@bootstrap
```

**db-node-2 and db-node-3 — normal start**

```bash
sudo systemctl start mysql
```

### Important Notes About Cluster State

All nodes in the same **Galera / Percona XtraDB Cluster** share the same **cluster UUID (state UUID)**. This UUID is generated automatically during the first bootstrap and then shared across all nodes.

Only one node can be used to bootstrap the cluster.

Before starting a node, check:

```bash
cat /var/lib/mysql/grastate.dat
```

| Node                           | Expected `safe_to_bootstrap` |
|--------------------------------|------------------------------|
| The bootstrap node (db-node-1) | `1`                          |
| All other nodes                | `0`                          |

> ⚠️ Do NOT manually change this value during normal operations. It is only touched during cluster recovery after an unclean shutdown.

#### Restarting the Cluster Safely

Once the cluster is up and synced, restarting nodes is **not** the same as the first-time bootstrap. Do it in this order so you never lose quorum or corrupt state.

1. **db-node-3** — stop it first (not the reference node)

```bash
sudo systemctl stop mysql
```

2. **db-node-2** — stop it next

```bash
sudo systemctl stop mysql
```

At this point db-node-1 is the only node left running. It's still serving traffic alone (`wsrep_cluster_size = 1`), and its clean shutdown state marks it as the safe reference node.

3. **db-node-1** — confirm it's the safe node, then restart it as a fresh bootstrap (as the last man standing, a plain `restart mysql` will hang trying to reach peers that aren't there anymore)

```bash
cat /var/lib/mysql/grastate.dat   # confirm safe_to_bootstrap: 1
sudo systemctl restart mysql@bootstrap
```

4. **db-node-2** — start normally, it will IST/SST-sync from db-node-1

```bash
sudo systemctl start mysql
```

5. **db-node-3** — start normally, same as above

```bash
sudo systemctl start mysql
```

6. Verify again with the `wsrep_cluster_size` / `wsrep_local_state_comment` checks above — expect `3` and `Synced`.

> ⚠️ Never run `mysql@bootstrap` on more than one node at the same time — that creates two separate clusters (split brain) instead of one.
> ⚠️ Never bootstrap a node whose `grastate.dat` shows `safe_to_bootstrap: 0` unless you're doing a documented crash-recovery procedure (`mysqld --wsrep-recover`).

## Set Up HAProxy

### Install HAProxy

> Use the HAProxy version provided by your supported operating system repositories.

```bash
sudo apt update
sudo apt install haproxy
```

### Cluster Healthcheck

1. Login to MySQL

```bash
mysql -u root -p
```

2. Create a user for the cluster healthcheck

```mysql
CREATE USER '<clustercheck-user>'@'localhost' IDENTIFIED BY '<clustercheck-password>';

GRANT PROCESS ON *.* TO '<clustercheck-user>'@'localhost';

FLUSH PRIVILEGES;
```

> You can use the default user and password (user: `clustercheckuser`, password: `clustercheckpassword!`)

3. Verify the user was created

```mysql
SELECT user, host FROM mysql.user WHERE user = "clustercheckuser";
```

4. Verify the script itself works

> On PXC 8.4, `clustercheck` is provided by the `percona-xtradb-cluster-client` package (or a separate `percona-clustercheck` package depending on version).

Run on the bootstrap node:

```bash
clustercheck
```

If you set a different user and password:

```bash
clustercheck <clustercheck-user> <clustercheck-password>
```

`clustercheck` also accepts these optional parameters, in order:

- `user` / `password` (default `clustercheckuser` / `clustercheckpassword!`): credentials for the check. Pass `""` for either to use an empty value.
- `available_when_donor` (default 0): by default, a node acting as SST donor is reported unavailable. Set to 1 to allow queries on a donor node — requires a non-blocking SST method like xtrabackup.
- `log_file` (default `/dev/null`): where check logs/errors go.
- `available_when_readonly` (default 1): whether a node in `read_only` mode is still reported available.
- `defaults_extra_file` (default `/etc/my.cnf`): passed to the underlying `mysql` command via `--defaults-extra-file`. **Use this to store the check credentials instead of passing them as plain arguments** — otherwise the password ends up readable in the systemd unit file below.

5. Expose the check over HTTP with systemd

Create the socket unit:

```bash
sudo vim /etc/systemd/system/mysqlchk.socket
```

```ini
[Unit]
Description=Percona XtraDB Cluster Node Healthcheck Socket

[Socket]
ListenStream=9200
Accept=yes

[Install]
WantedBy=sockets.target
```

Create the matching service template:

```bash
sudo vim /etc/systemd/system/mysqlchk@.service
```

```ini
[Unit]
Description=Percona XtraDB Cluster Node Healthcheck Service

[Service]
ExecStart=-/usr/bin/clustercheck
StandardInput=socket
StandardOutput=socket
```

> Credentials aren't passed on the command line here — instead, put them in a `defaults_extra_file` (e.g. `/etc/my.cnf.local`, root-readable only) so they never appear in the unit file or in `ps` output.

6. Reload systemd so it picks up the new units

```bash
sudo systemctl daemon-reload
```

7. Enable and start the socket

```bash
sudo systemctl enable --now mysqlchk.socket
```

8. Verify it's listening and responding

```bash
sudo ss -ltnp | grep 9200
curl localhost:9200
```

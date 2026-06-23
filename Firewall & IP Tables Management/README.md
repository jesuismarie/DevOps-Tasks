# Firewall & IP Tables Management 🛡️🔥

## Launch Instances

- AMI: Ubuntu 24.04 LTS SSD Volume Type
- Instance type: `t3.micro`
- Key pair: RSA, `.pem` format
- Number of instances: 2 (launch one at a time, name them `iptables-A` and `iptables-B`)

Connect to each instance:

```bash
ssh -i <key-path>.pem ubuntu@<public-ip>
```

## Verify Clean State

Before configuring anything, check that iptables has no rules:

```bash
sudo iptables -L -n -v
```

Expected output — all chains empty, all policies ACCEPT:

```
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
```

## Create Custom Chains

Custom chains are empty containers — they do nothing until rules are added and they are attached to INPUT/OUTPUT.

```bash
sudo iptables -N MY_FIREWALL_IN
sudo iptables -N MY_FIREWALL_OUT
```

Verify — both chains exist with 0 references:

```
Chain MY_FIREWALL_IN (0 references)
 pkts bytes target     prot opt in     out     source               destination

Chain MY_FIREWALL_OUT (0 references)
 pkts bytes target     prot opt in     out     source               destination
```

## INPUT Rules (`MY_FIREWALL_IN`)

Rules are processed top-to-bottom. Order matters.

**Allow loopback** — the machine talking to itself (127.0.0.1). Required for internal services:

```bash
sudo iptables -A MY_FIREWALL_IN -i lo -j ACCEPT
```

**Allow ESTABLISHED and RELATED** — stateful matching. Allows replies to connections this machine initiated:

```bash
sudo iptables -A MY_FIREWALL_IN -m state --state ESTABLISHED,RELATED -j ACCEPT
```

**Drop INVALID packets** — malformed, spoofed, or packets that don't belong to any known connection:

```bash
sudo iptables -A MY_FIREWALL_IN -m state --state INVALID -j DROP
```

**Allow SSH, HTTP, HTTPS** — NEW allows the initial connection, ESTABLISHED allows the ongoing session:

```bash
sudo iptables -A MY_FIREWALL_IN -p tcp -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT
sudo iptables -A MY_FIREWALL_IN -p tcp -m state --state NEW,ESTABLISHED --dport 80 -j ACCEPT
sudo iptables -A MY_FIREWALL_IN -p tcp -m state --state NEW,ESTABLISHED --dport 443 -j ACCEPT
```

**Drop everything else** — catch-all at the end:

```bash
sudo iptables -A MY_FIREWALL_IN -j DROP
```

**Attach to INPUT** — without this, the chain is never used:

```bash
sudo iptables -A INPUT -j MY_FIREWALL_IN
```

Verify — chain now has 1 reference:

```
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
  668 56892 MY_FIREWALL_IN  0    --  *      *       0.0.0.0/0            0.0.0.0/0

Chain MY_FIREWALL_IN (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     0    --  lo     *       0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     0    --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    0     0 DROP       0    --  *      *       0.0.0.0/0            0.0.0.0/0            state INVALID
    0     0 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW,ESTABLISHED tcp dpt:22
    0     0 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW,ESTABLISHED tcp dpt:80
    0     0 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW,ESTABLISHED tcp dpt:443
    0     0 DROP       0    --  *      *       0.0.0.0/0            0.0.0.0/0
```

## OUTPUT Rules (`MY_FIREWALL_OUT`)

**Allow loopback out** — `-o` flag for outgoing interface:

```bash
sudo iptables -A MY_FIREWALL_OUT -o lo -j ACCEPT
```

**Allow ESTABLISHED and RELATED out** — replies to incoming connections:

```bash
sudo iptables -A MY_FIREWALL_OUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

**Allow new outbound TCP connections** — browsing, apt, etc.:

```bash
sudo iptables -A MY_FIREWALL_OUT -p tcp -m state --state NEW -j ACCEPT
```

**Allow DNS** — UDP port 53, required for hostname resolution:

```bash
sudo iptables -A MY_FIREWALL_OUT -p udp --dport 53 -j ACCEPT
```

**Allow NTP** — UDP port 123, required for clock sync:

```bash
sudo iptables -A MY_FIREWALL_OUT -p udp --dport 123 -j ACCEPT
```

**Allow DHCP** — UDP port 67, required for IP lease renewal:

```bash
sudo iptables -A MY_FIREWALL_OUT -p udp --dport 67 -j ACCEPT
```

**Allow ICMP out** — so this machine can ping others:

```bash
sudo iptables -A MY_FIREWALL_OUT -p icmp -j ACCEPT
```

**Drop everything else** — catch-all:

```bash
sudo iptables -A MY_FIREWALL_OUT -j DROP
```

**Attach to OUTPUT**:

```bash
sudo iptables -A OUTPUT -j MY_FIREWALL_OUT
```

Verify:

```
Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 1160  105K MY_FIREWALL_OUT  0    --  *      *       0.0.0.0/0            0.0.0.0/0

Chain MY_FIREWALL_OUT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    8   842 ACCEPT     0    --  *      lo      0.0.0.0/0            0.0.0.0/0
  886 78848 ACCEPT     0    --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    0     0 ACCEPT     6    --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW
    3   258 ACCEPT     17   --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:53
    0     0 ACCEPT     17   --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:123
    0     0 ACCEPT     17   --  *      *       0.0.0.0/0            0.0.0.0/0            udp dpt:67
    0     0 ACCEPT     1    --  *      *       0.0.0.0/0            0.0.0.0/0
   15  1140 DROP       0    --  *      *       0.0.0.0/0            0.0.0.0/0
```

## Default Policies

Set INPUT and FORWARD to DROP — deny by default. Any packet that somehow bypasses the custom chains is dropped:

```bash
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
```

OUTPUT stays ACCEPT (controlled by MY_FIREWALL_OUT).

## Logging Dropped Packets

The `LOG` target writes packet info to syslog but does **not** stop processing — it must always be followed by a DROP rule. We insert the LOG rule just before each catch-all DROP.

Check line numbers first:

```bash
sudo iptables -L MY_FIREWALL_IN -n -v --line-numbers
sudo iptables -L MY_FIREWALL_OUT -n -v --line-numbers
```

Insert LOG rule before the catch-all DROP (line 7 in IN, line 6 in OUT — pushing DROP down by one):

```bash
sudo iptables -I MY_FIREWALL_IN 7  -j LOG --log-prefix "IPTABLES-IN-DROP: "  --log-level 4
sudo iptables -I MY_FIREWALL_OUT 8 -j LOG --log-prefix "IPTABLES-OUT-DROP: " --log-level 4
```

Create the log file:

```bash
sudo touch /var/log/iptables.log
sudo chmod 640 /var/log/iptables.log
```

Configure rsyslog to redirect iptables messages to the dedicated log file:

```bash
sudo vim /etc/rsyslog.d/10-iptables.conf
```

Add:

```
:msg, contains, "IPTABLES" /var/log/iptables.log
& stop
```

The first line matches any syslog message containing "IPTABLES" and writes it to the file. `& stop` prevents it from also appearing in `/var/log/syslog`.

Restart rsyslog:

```bash
sudo systemctl restart rsyslog
```

## Testing

Install nginx on `iptables-A` to serve HTTP:

```bash
sudo apt update && sudo apt install -y nginx
```

Open ports in AWS Security Group inbound rules (to allow packets to reach the OS):

- TCP 22, 80, 443 — should be accessible
- TCP 8080 — should be blocked by iptables

From `iptables-B`, test connectivity to `iptables-A`:

```bash
# Should succeed
nc -zv <iptables-A-private-ip> 22
nc -zv <iptables-A-private-ip> 80

# Should be blocked
nc -zv <iptables-A-private-ip> 8080
```

Expected results:

```
Connection to <ip> 22 port [tcp/ssh] succeeded!    ✅
Connection to <ip> 80 port [tcp/http] succeeded!   ✅
nc: connect to <ip> port 8080 (tcp) failed: Connection timed out  ✅ blocked
```

Monitor logs on `iptables-A` while testing:

```bash
sudo tail -f /var/log/iptables.log
```

Example dropped packet log entry:

```
2026-06-22T11:28:52 kernel: IPTABLES-IN-DROP: IN=ens5 SRC=172.31.27.126 DST=172.31.28.149 PROTO=TCP SPT=56834 DPT=8080 SYN
```

- `SRC` — source IP (iptables-B)
- `DST` — destination IP (iptables-A)
- `DPT=8080` — blocked port
- `SYN` — new connection attempt

## Persist Rules After Reboot

Install `iptables-persistent` — saves rules to `/etc/iptables/rules.v4` and restores them at boot automatically:

```bash
sudo apt install -y iptables-persistent
```

Answer **Yes** when asked to save current IPv4 and IPv6 rules.

Verify saved rules:

```bash
cat /etc/iptables/rules.v4
```

Expected output:

```
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:MY_FIREWALL_IN - [0:0]
:MY_FIREWALL_OUT - [0:0]
-A INPUT -j MY_FIREWALL_IN
-A OUTPUT -j MY_FIREWALL_OUT
-A MY_FIREWALL_IN -i lo -j ACCEPT
-A MY_FIREWALL_IN -m state --state RELATED,ESTABLISHED -j ACCEPT
-A MY_FIREWALL_IN -m state --state INVALID -j DROP
-A MY_FIREWALL_IN -p tcp -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT
-A MY_FIREWALL_IN -p tcp -m state --state NEW,ESTABLISHED --dport 80 -j ACCEPT
-A MY_FIREWALL_IN -p tcp -m state --state NEW,ESTABLISHED --dport 443 -j ACCEPT
-A MY_FIREWALL_IN -j LOG --log-prefix "IPTABLES-IN-DROP: "
-A MY_FIREWALL_IN -j DROP
-A MY_FIREWALL_OUT -o lo -j ACCEPT
-A MY_FIREWALL_OUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A MY_FIREWALL_OUT -p tcp -m state --state NEW -j ACCEPT
-A MY_FIREWALL_OUT -p udp --dport 53 -j ACCEPT
-A MY_FIREWALL_OUT -p udp --dport 123 -j ACCEPT
-A MY_FIREWALL_OUT -p udp --dport 67 -j ACCEPT
-A MY_FIREWALL_OUT -p icmp -j ACCEPT
-A MY_FIREWALL_OUT -j LOG --log-prefix "IPTABLES-OUT-DROP: "
-A MY_FIREWALL_OUT -j DROP
COMMIT
```

To manually save rules at any time:

```bash
sudo netfilter-persistent save
```

To manually restore:

```bash
sudo netfilter-persistent reload
```

## SSH Brute Force Rate Limiting (Optional)

The `recent` module tracks IPs and their connection attempts over time.
If one IP makes more than 3 new SSH connections in 60 seconds it gets blocked.

Two rules work together — the block check must come **before** the accept rule,
otherwise the packet gets accepted before the rate limit is ever evaluated.

**Rule A — block if IP hit 4+ times in 60 seconds:**

```bash
sudo iptables -I MY_FIREWALL_IN 4 -p tcp --dport 22 -m state --state NEW -m recent --name sshbf --update --seconds 60 --hitcount 4 -j DROP
```

- `--name sshbf` — name of the tracking list
- `--update` — check if IP is in the list and update its timestamp
- `--seconds 60` — time window
- `--hitcount 4` — trigger after 4 attempts

**Rule B — record IP and accept:**

```bash
sudo iptables -I MY_FIREWALL_IN 5 -p tcp --dport 22 -m state --state NEW -m recent --name sshbf --set -j ACCEPT
```

- `--set` — add the IP to the tracking list

Verify:

```bash
sudo iptables -L MY_FIREWALL_IN -n -v --line-numbers
```

```
4    0    0 DROP   6  --  *  *  0.0.0.0/0  0.0.0.0/0  state NEW recent: UPDATE seconds: 60 hit_count: 4 name: sshbf tcp dpt:22
5    0    0 ACCEPT 6  --  *  *  0.0.0.0/0  0.0.0.0/0  state NEW recent: SET name: sshbf tcp dpt:22
6    8  764 ACCEPT 6  --  *  *  0.0.0.0/0  0.0.0.0/0  state NEW,ESTABLISHED tcp dpt:22
```

**Test from Instance-2:**

```bash
for i in {1..6}; do ssh -o ConnectTimeout=3 -o BatchMode=yes ubuntu@172.31.28.149 exit; done
```

Expected result — first 4 attempts reach SSH, attempts 5-6 time out:

```
Host key verification failed.
Host key verification failed.
Host key verification failed.
Host key verification failed.
ssh: connect to host 172.31.28.149 port 22: Connection timed out
ssh: connect to host 172.31.28.149 port 22: Connection timed out
```

**Check tracked IPs:**

```bash
cat /proc/net/xt_recent/sshbf
```

**Reset the tracking list:**

```bash
sudo bash -c "echo / > /proc/net/xt_recent/sshbf"
```

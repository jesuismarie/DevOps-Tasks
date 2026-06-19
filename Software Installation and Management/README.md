# Software Installation and Management 🔧

A walkthrough for setting up a local package mirror (kubectl), packaging a custom application (ping-pong), signing it with GPG, and distributing it through a private APT repository to a client VM.

## Virtual Machines Setup 🖥️🌐

Set up two VMs (**Server** and **Client**) on the same network.

1. In VirtualBox: **File → Tools → Network**
2. Navigate to **NAT Network**
3. Create a new NAT Network
4. Set both the Server and Client VM network adapters to use this NAT Network

### Verify connectivity

Check the IP address on each VM:

```bash
ip addr
```

Ping the other VM:

```bash
ping <vm-ip>
```

### Install base packages (Server)

```bash
sudo apt update
sudo apt install apt-mirror curl gnupg
```

## Repository Mirroring and Configuration 🔧🌐

### Add the Kubernetes (kubectl) repository — Server

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes.gpg
```

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
```

```bash
sudo apt update
```

### Mirror the repository locally

```bash
sudo vim /etc/apt/mirror.list
```

Replace the file contents with:

```ini
set base_path    /var/spool/apt-mirror
set nthreads     20
set _tilde 0

deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /

clean https://pkgs.k8s.io/core:/stable:/v1.36/deb/
```

Run the mirror:

```bash
sudo apt-mirror
```

Verify:

```bash
ls -la /var/spool/apt-mirror/mirror/pkgs.k8s.io/
du -sh /var/spool/apt-mirror/mirror/
```

### Serve the mirror via nginx — Server

```bash
sudo apt update
sudo apt install -y nginx
```

Create the site config:

```bash
sudo nano /etc/nginx/sites-available/kubectl-mirror
```

```nginx
server {
    listen 80;
    server_name _;

    root /var/spool/apt-mirror/mirror;
    autoindex on;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Enable and restart:

```bash
sudo ln -s /etc/nginx/sites-available/kubectl-mirror /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

Verify locally:

```bash
curl http://localhost/pkgs.k8s.io
```

### Configure the Client to use the Server mirror

Copy the GPG key from Server to Client:

```bash
scp <server>@<server-ip>:/etc/apt/keyrings/kubernetes.gpg /etc/apt/keyrings/
sudo chmod 644 /etc/apt/keyrings/kubernetes.gpg
```

Add the source pointing at the Server's mirror:

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] http://10.0.2.15/pkgs.k8s.io/core:/stable:/v1.36/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
```

Confirm packages are pulled from the Server:

```bash
sudo apt update
```

## Software Packaging 🔧🖥️

Package the ping-pong game (Python + Tkinter) as a `.deb`.

### Build the package directory structure

```
ping-pong-1.0/
├── DEBIAN/
│   └── control
└── usr/
    ├── bin/
    │   └── ping-pong          (launcher script)
    └── share/
        └── ping-pong/
            └── ping-pong.py    (actual game code)
```

```bash
mkdir -p ~/ping-pong-1.0/DEBIAN
mkdir -p ~/ping-pong-1.0/usr/share/ping-pong
mkdir -p ~/ping-pong-1.0/usr/bin
cp /home/server/ping-pong.py ~/ping-pong-1.0/usr/share/ping-pong/
```

### Create the launcher script

```bash
cat << 'EOF' | sudo tee ~/ping-pong-1.0/usr/bin/ping-pong
#!/bin/bash
python3 /usr/share/ping-pong/ping-pong.py
EOF
chmod +x ~/ping-pong-1.0/usr/bin/ping-pong
```

### Create the control file

```bash
cat << 'EOF' | tee ~/ping-pong-1.0/DEBIAN/control
Package: ping-pong
Version: 1.0
Section: games
Priority: optional
Architecture: all
Depends: python3, python3-tk
Maintainer: M <m@example.com>
Description: Simple ping-pong game
 A simple terminal/GUI ping-pong game built with Python and Tkinter.
EOF
```

### Build and verify the package

```bash
dpkg-deb --build --root-owner-group ~/ping-pong-1.0
```

```bash
dpkg-deb -I ~/ping-pong-1.0.deb
dpkg-deb -c ~/ping-pong-1.0.deb
```

### Test install on the Server

```bash
sudo apt install ./ping-pong-1.0.deb
ping-pong
```

### Test on the Client VM

*(installed later, after the signed repo is set up — see [Section 5](#5-client-installation-))*

## GPG Signing 🔒

### Create a signing key — Server

```bash
sudo apt install -y gnupg reprepro
```

```bash
gpg --full-generate-key
```

When prompted:

| Prompt | Value |
|---|---|
| Key type | `RSA and RSA` (default) |
| Key size | `4096` |
| Expiry | `0` (no expiry), or e.g. `1y` |
| Name | `M Packaging Key` |
| Email | `m@example.com` |
| Passphrase | your choice |

List the key:

```bash
gpg --list-secret-keys m@example.com
```

### Set up a signed repo with `reprepro`

```bash
mkdir -p ~/repo/conf
```

```bash
cat << 'EOF' | tee ~/repo/conf/distributions
Origin: PingPongRepo
Label: PingPongRepo
Codename: stable
Architectures: amd64
Components: main
Description: Custom ping-pong package repo
SignWith: <key-ID>
EOF
```

### Add the `.deb` to the repo

```bash
cd ~/repo
reprepro includedeb stable ~/ping-pong-1.0.deb
```

### Serve the repo via nginx

```bash
sudo cp -r ~/repo /var/www/ping-pong-repo
sudo chown -R www-data:www-data /var/www/ping-pong-repo
```

```bash
sudo vim /etc/nginx/sites-available/ping-pong-repo
```

```nginx
server {
    listen 8080;
    server_name _;

    root /var/www/ping-pong-repo;
    autoindex on;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/ping-pong-repo /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Verify the signed metadata is served:

```bash
curl http://localhost:8080/dists/stable/InRelease
```

You should see a PGP-signed metadata block.

### Export the public key for clients

```bash
gpg --armor --export <key_ID> | sudo tee /var/www/ping-pong-repo/ping-pong-repo.gpg.key
```

```bash
curl http://localhost:8080/ping-pong-repo.gpg.key
```

## Client Installation 🌐🔧

### Trust the signing key — Client

```bash
curl http://10.0.2.15:8080/ping-pong-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/ping-pong-repo.gpg
sudo chmod 644 /etc/apt/keyrings/ping-pong-repo.gpg
```

### Add the repo source

```bash
echo "deb [signed-by=/etc/apt/keyrings/ping-pong-repo.gpg] http://10.0.2.15:8080 stable main" | sudo tee /etc/apt/sources.list.d/ping-pong-repo.list
```

### Update and install

```bash
sudo apt update
sudo apt install ping-pong
```

### Verify

```bash
ping-pong
```

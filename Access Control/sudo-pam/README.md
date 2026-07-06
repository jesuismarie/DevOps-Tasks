# Sudo / Privilege Management 🔧

## 1. Passwordless Sudo for the `sudo` Group

### Edit sudoers configuration

The `/etc/sudoers` file was modified using `visudo`:

```bash
sudo visudo
```

Add or modify the following rule:

```sudo
%sudo ALL=(ALL:ALL) NOPASSWD: ALL
```

* `%sudo` → applies the rule to all members of the `sudo` group
* `ALL=(ALL:ALL)` → allows commands to be executed as any user and group
* `NOPASSWD:` → disables password prompts for sudo commands
* `ALL` → permits execution of all commands

### Effect

* Users in the `sudo` group can run administrative commands without entering a password
* Sudo logging and auditing remain enabled
* Simplifies privilege escalation for trusted administrators

## 2. `myapp` User and Service Configuration

### 1. Create a Service Account

```bash
sudo useradd -r -M -s /usr/sbin/nologin myapp
sudo passwd -d myapp
```

* `-r` → creates a system account
* `-M` → does not create a home directory
* `-s /usr/sbin/nologin` → prevents interactive login
* `passwd -d` → removes the account password

This creates a dedicated service account that cannot be used for normal user sessions.

### 2. Create a Systemd Service

Create the service file:

`/etc/systemd/system/myapp.service`

```ini
[Unit]
Description=MyApp Service
After=network.target

[Service]
Type=simple
User=myapp
ExecStart=/usr/bin/sleep infinity
Restart=always

[Install]
WantedBy=multi-user.target
```

* `User=myapp` → runs the service with the privileges of the `myapp` account
* `ExecStart=/usr/bin/sleep infinity` → example long-running process
* `Restart=always` → automatically restarts the service if it exits

Reload systemd configuration:

```bash
sudo systemctl daemon-reload
```

### 3. Configure Restricted Sudo Permissions

Create a dedicated sudoers file:

`/etc/sudoers.d/myapp`

```sudo
myapp ALL=(root) NOPASSWD: /usr/bin/systemctl start myapp.service, \
                         /usr/bin/systemctl restart myapp.service, \
                         /usr/bin/systemctl stop myapp.service, \
                         /usr/bin/systemctl status myapp.service
```

* `myapp` → user receiving permissions
* `ALL` → valid from any host
* `(root)` → commands execute as root
* `NOPASSWD:` → no password required
* Limits the user to specific `systemctl` operations for `myapp.service`

Validate the configuration:

```bash
chmod 440 /etc/sudoers.d/myapp
sudo visudo -c
```

* `chmod 440` → applies correct sudoers file permissions
* `visudo -c` → checks sudo configuration syntax

### Effect

* `myapp` cannot obtain full root access
* `myapp` can only manage its own service
* Follows the principle of least privilege

## 3. Allow Sudo Users to Run `su` and `su -` Without the Root Password

Edit the PAM configuration for `su`:

```bash
sudo vim /etc/pam.d/su
```

Add the following rule:

```pam
auth sufficient pam_succeed_if.so use_uid user ingroup sudo
```

* `auth` → authentication rule
* `sufficient` → if the check succeeds, authentication is immediately accepted
* `pam_succeed_if.so` → conditional PAM module
* `use_uid` → checks the calling user's UID
* `user ingroup sudo` → matches users belonging to the `sudo` group

### Effect

* Members of the `sudo` group can run `su` and `su -`
* Root's password is not required
* Non-sudo users must still authenticate normally
* Access remains controlled through group membership and PAM policies

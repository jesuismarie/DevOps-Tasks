# User Account Management 🔒

## 1. User Account Manipulation

### 1. Lock a user account

The user `charle` can be locked using either method:

```bash
sudo usermod -L charle
# or
sudo passwd -l charle
```

* Prevents login using password authentication
* Account remains present in the system but becomes inactive

### 2. Check account status

```bash
sudo passwd -S charle
```

* Shows current password status:

  * Locked / unlocked state
  * Password aging information

### 3. Unlock user account

```bash
sudo usermod -U charle
# or
sudo passwd -u charle
```

* Restores login capability for the user

### 4. Disable password for a user

```bash
sudo passwd -d charle
```

* Removes the password entirely
* User cannot authenticate via password login

### 5. Create user without login shell

```bash
sudo useradd -M -s /usr/sbin/nologin martin
# or
sudo useradd -M -s /bin/false martin
```

* `-M` → do not create home directory
* `-s nologin/false` → disables interactive shell access
* Typically used for service/system accounts

## 2. Password Policy Configuration

### 1. Password aging rules

Configured in `/etc/login.defs`:

```bash
PASS_MAX_DAYS   90    # Maximum number of days a password is valid before it must be changed
PASS_MIN_DAYS   0     # Minimum number of days allowed between password changes
PASS_WARN_AGE   7     # Number of days before expiry when user starts receiving warnings
PASS_MIN_LEN    12    # Minimum required password length
```

* Defines global password expiration and warning policies

Alternative per-user configuration:

```bash
sudo chage -M 90 -m 0 -W 7 alice
sudo chage -M 90 -m 0 -W 7 bob
sudo chage -M 90 -m 0 -W 7 charlie
```

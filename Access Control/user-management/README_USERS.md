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
* `PASS_MIN_LEN` is deprecated / not enforced by most modern systems
* Password length is now enforced by **PAM** `(pam_pwquality)`, not `/etc/login.def`s

Alternative per-user configuration:

```bash
sudo chage -M 90 -m 0 -W 7 alice
sudo chage -M 90 -m 0 -W 7 bob
sudo chage -M 90 -m 0 -W 7 charlie
```

## 3. Password Complexity Rules (PAM)

### 1. Install required module

```bash
sudo apt install libpam-pwquality -y
```

### 2. Configure complexity rules

Edit configuration file:

```bash
sudo vim /etc/security/pwquality.conf
```

Rules applied:

```bash
minlen = 12     # minimum length
dcredit = -1    # at least 1 digit
ucredit = -1    # at least 1 uppercase letter
lcredit = -1    # at least 1 lowercase letter
ocredit = -1    # at least 1 special character
difok = 5       # at least 5 characters must differ from old password
```

### 3. PAM configuration

Edit PAM password policy:

```bash
sudo vim /etc/pam.d/common-password
```

Add or ensure the following rule:

```bash
password requisite pam_pwquality.so retry=3 minlen=12 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 difok=5
```

* `password` → applies rule to password changes
* `requisite` → fails immediately if check fails
* `pam_pwquality.so` → module for password complexity validation
* `retry=3` → allows 3 attempts to set a valid password
* `minlen=12` → requires minimum 12 characters
* `dcredit=-1` → requires at least 1 digit
* `ucredit=-1` → requires at least 1 uppercase letter
* `lcredit=-1` → requires at least 1 lowercase letter
* `ocredit=-1` → requires at least 1 special character
* `difok=5` → at least 5 characters must differ from previous password

```bash
password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass sha512
```

* `password` → applies rule to password changes
* `[success=1 default=ignore]` → control behavior of module execution

  * `success=1` → skip next rule if successful
  * `default=ignore` → ignore failure unless required by stack
* `pam_unix.so` → standard Linux authentication/password module
* `obscure` → blocks weak or easily guessable passwords
* `use_authtok` → uses already validated password from previous module
* `try_first_pass` → tries existing password before prompting again
* `sha512` → uses SHA-512 hashing algorithm for secure password storage

To force users to comply with these rules, we can force them to change their password immediately:

```bash
sudo chage -d 0 <username>
```

* `chage` → command used to manage password expiration
* `-d 0` → sets last password change date to “epoch” (forces expiry)
* `<username>` → target user account

Effect:

* Forces user to change password at next login
* New password must follow PAM rules (`pam_pwquality`)
* Ensures minimum length and complexity requirements are enforced immediately
* Prevents continued use of old password

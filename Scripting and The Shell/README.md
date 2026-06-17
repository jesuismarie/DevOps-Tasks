# Scripting and The Shell

## Shell Initialization Files 🖥️🔧

### Login vs Non-Login Shell

#### Login Shell

A login shell is started when a user logs into the system.

Examples:

```bash
ssh user@server
# or
su - user
# or
bash --login
```

### Non-Login Shell

A non-login shell is started inside an existing session (e.g., opening a new terminal tab/window).

Example:

```bash
bash
```

#### Test Shell Type

```bash
echo $0
```

* `-bash` → login shell
* `bash` → non-login shell

### System-Wide Files

#### `/etc/profile`

System-wide configuration executed for all users during login shell startup.

* Sets global environment variables
* Sources scripts from `/etc/profile.d/`

Example:

```bash
export EDITOR=vim
```

#### `/etc/bash.bashrc`

System-wide configuration for **interactive non-login shells**.

* Defines aliases
* Sets shell options
* Configures prompt behavior

Example:

```bash
alias ll='ls -alF'
```

#### `/etc/profile.d/`

Directory containing modular shell scripts sourced by `/etc/profile`.

* Used for application-specific environment setup
* Avoids modifying `/etc/profile` directly

Example:

```bash
export JAVA_HOME=/usr/lib/jvm/java-21
```

### User-Specific Files

#### `~/.profile`

User-specific login shell configuration.

* Used if `.bash_profile` and `.bash_login` do not exist

Example:

```bash
export PATH="$HOME/bin:$PATH"
```

#### `~/.bash_profile`

Bash-specific login shell configuration.

* Used instead of `~/.profile` if it exists
* Commonly used to load `.bashrc`

Example:

```bash
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
```

#### `~/.bashrc`

Configuration for **interactive non-login shells**.

* Aliases
* Functions
* Prompt (PS1)
* History settings

Examples:

```bash
alias gs='git status'
export HISTSIZE=5000
PS1='\u@\h:\w\$ '
```

#### `~/.bash_login`

Alternative login file.

* Used only if `.bash_profile` does not exist
* Rarely used in modern systems

### `~/.bash_logout`

Executed when a login shell exits.

Common uses:

```bash
clear
history -c
```

### Load Order

#### Login Shell

```text
/etc/profile
 └── /etc/profile.d/*.sh
      └── ~/.bash_profile
           └── ~/.bashrc
```

If `~/.bash_profile` does not exist:

```text
/etc/profile
 └── ~/.bash_login
```

If neither exists:

```text
/etc/profile
 └── ~/.profile
```

#### Non-login Interactive Shell

```text
/etc/bash.bashrc
 └── ~/.bashrc
```

#### Logout

```text
~/.bash_logout
```

## Understand the Fork Bomb ⚠️

A fork bomb is a **self-replicating process that rapidly exhausts system resources**, causing a denial of service (DoS).

```bash
:() { :|: & };:
```

### Breakdown

* `:()` → defines a function named `:`
* `{ :|: & }` → function body:

  * `:` calls itself twice (`:|:`)
  * `|` pipes output between recursive calls
  * `&` runs processes in the background
* `;:` → immediately executes the function once

### Effect

* Exponential process creation
* Rapid exhaustion of system PIDs
* System becomes unresponsive

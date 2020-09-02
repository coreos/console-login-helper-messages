# Manual - console-login-helper-messages

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Architecture overview - issuegen/motgen](#architecture-overview---issuegenmotgen)
- [Installation](#installation)
  - [Packaging](#packaging)
  - [Integrating into a distribution](#integrating-into-a-distribution)
- [Common operations](#common-operations)
  - [Enabling messages](#enabling-messages)
  - [Appending messages](#appending-messages)
  - [Disabling messages](#disabling-messages)
    - [Silencing a generated message without disabling](#silencing-a-generated-message-without-disabling)
    - [Finer-grained disabling](#finer-grained-disabling)
- [Troubleshooting](#troubleshooting)
  - [Recreating the symlinks](#recreating-the-symlinks)
  - [Regenerating the messages](#regenerating-the-messages)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Architecture overview

By default, `console-login-helper-messages` provides several units and scripts
for displaying helpful messages before or at login. Currently, the following 
messages are displayed:
  - SSH keys (before login)
  - Network interface information (before login)
  - OS release information (after login)
  - Failed systemd units (after login)

Depending on the state of the system that `console-login-helper-messages` is 
installed on and user configuration, some of the above messages _may_ be displayed
with the help of `issuegen` and `motdgen`.

The `issuegen` and `motdgen`-related units are:
  - `console-login-helper-messages-issuegen.path`
  - `console-login-helper-messages-motdgen.path`
  - `console-login-helper-messages-issuegen.service`
  - `console-login-helper-messages-motdgen.service`

The following default units and scripts are in charge of generating the information
that needs to be displayed in a MOTD or issue, and placing the sourced information to
the correct location, depending on whether the upstream tools mentioned
[here](#integrating-into-a-distribution) support reading from public runtime
directories `/run/{issue,motd}.d`:
  - `console-login-helper-messages-gensnippet-ssh-keys.service` (SSH keys)
  - `etc/NetworkManager/dispatcher.d/90-console-login-helper-messages-gensnippet-if` (Network interface info)
  - `console-login-helper-messages-gensnippet-os-release.service` (OS release info)

### Reading from public runtime directories supported:
On systems where reading from public runtime directories (specifically 
`/run/{issue,motd}.d`) is natively supported by `agetty`, `login`, and 
`pam_motd`, and the user has configured these tools to do so (instructions in 
[Integrating into a distribution](#integrating-into-a-distribution)), the 
aforementioned units and scripts write their files directly into the _public_ 
runtime directories `/run/{issue,motd}.d`, and the upstream tools handle the 
rest. 
`issuegen` and `motdgen` units and scripts only exist to concatenate the 
snippets in the non-runtime directories 
(`/{etc,usr/lib}/console-login-helper-messages/{issue,motd}.d`) at start up, and
write the compiled ("generated") output to a location where the serial console 
`agetty` (for issue) or the SSH/terminal login message (for motd) will read. 

### Reading from public runtime directories NOT supported:
On systems where reading from public runtime directories 
(i.e. `/run/{issue,motd}.d`) is NOT supported, the aforementioned units and 
scripts write their files into the _private_ runtime directories 
`/run/console-login-helper-messages/{issue,motd}.d`; `-issuegen.path` or 
`-motdgen.path` detects this and activates their respective `.service` units, 
triggering `issuegen` or `motdgen` to run. 
`issuegen` or `motdgen` concatenates all the snippets in the non-runtime AND 
runtime directories 
(`/{etc,run,usr/lib}/console-login-helper-messages/{issue,motd}.d`), and writes 
the compiled output to a file where the serial console `agetty` (for issue) or 
the SSH/terminal login message (for motd) will read.

Currently, whether or not to use public runtime directories are set by the 
variable `USE_PUBLIC_RUN_DIR` in 
`/usr/lib/console-login-helper-messages/libutil.sh`, depending on the system's 
`util-linux` version. Public runtime directories are used if `util-linux` 
version is at least 2.36. In the future, this should be configurable through a 
configuration file. 

Files may also be dropped into the runtime directories above through
other means, such as udev rules; it need not be a systemd service
doing this.

In all cases, the purpose of the issuegen/motdgen units themselves is only to, 
when necessary, (re)generate a final compiled issue/MOTD in response to files 
being dropped into their source directories.

## Installation

To test out the latest RPMs in Fedora, run:

```
dnf install \
  console-login-helper-messages-issuegen \
  console-login-helper-messages-motdgen \
  console-login-helper-messages-profile
```

### Packaging

In Fedora, the console-login-helper-messages package is grouped via
subpackages in the following way:

| package                                | function |
| -------------------------------------- | -------- |
| console-login-helper-messages          | base directory layout for this packge (required by all subpackages) |
| console-login-helper-messages-issuegen | messages shown on serial console using issue (SSH keys, IP address for SSH) |
| console-login-helper-messages-motdgen  | messages shown using the motd paths after SSH in (OS release information) |
| console-login-helper-messages-profile  | messages shown using /etc/profile.d script, shown on login to bash terminal (failed systemd units) |

The `install` target of the [Makefile](../Makefile) is the source of truth
on where files should be placed, and which symlinks should be created.

### Integrating into a distribution

The following must be met to ship `console-login-helper-messages` by
default as part of a distribution. These instructions apply to Fedora
only as packages are only available in Fedora, currently.

First, list the names of the subpackages to include in the manifest
of base packages for the distribution (this may vary depending on the
build system). **Each individual subpackage being included must be
requested**, e.g. to install all of `issuegen`, `motdgen`, and
`profile`, list the following:

```
- console-login-helper-messages-issuegen
- console-login-helper-messages-motdgen
- console-login-helper-messages-profile
```

Second, add a systemd preset to enable units for specific pieces of information
(see [all available units](/usr/lib/systemd/system)). 
The issuegen/motdgen-related units are optional on systems where reading from
public runtime directories supported and the user has set the necessary
configurations for these tools.
E.g.:

```
# /usr/lib/systemd/system-preset/40-console-login-helper-messages.preset

enable console-login-helper-messages-issuegen.service
enable console-login-helper-messages-motdgen.service
enable console-login-helper-messages-issuegen.path
enable console-login-helper-messages-motdgen.path
enable console-login-helper-messages-gensnippet-os-release.service
enable console-login-helper-messages-gensnippet-ssh-keys.service
```

#### For "newer" distributions
To take advantage of upstream tools' native features 
(i.e. use public runtime directories whenever possible), ensure that the 
following conditions are met:
  - `util-linux` version >= 2.36 (`agetty` and `login`)
  - `pam` version >= 1.3.1-15 (`pam_motd`)
  - `selinux-policy` >= 3.14.3-23 (allow `/run/motd.d` location to be usable)

To enable displaying issue snippets _before_ login (via the _serial console_),
let `/run/issue.d` be one of the directories that 
[`agetty`](https://github.com/karelzak/util-linux/blob/master/term-utils/agetty.8)
reads from.

Example:
```
agetty --issue-file=/run/issue.d
```

To enable displaying MOTD snippets _after_ login via the _serial console_, in
`/etc/login.defs`, make sure that `/run/motd.d` is one of the directories that 
[`login`](https://github.com/karelzak/util-linux/blob/master/login-utils/login.1)
reads from. The default value is 
`"/usr/share/misc/motd:/run/motd:/run/motd.d:/etc/motd:/etc/motd.d"`.

Example:
```
MOTD_FILE=/run/motd.d
```

To enable displaying MOTD snippets _after_ login via _ssh_, in `/etc/pam.d/login`,
make sure that `/run/motd.d` is one of the directories that
[pam_motd](https://github.com/linux-pam/linux-pam/blob/master/modules/pam_motd/pam_motd.8.xml)
reads from. The default is `/etc/motd.d:/run/motd.d:/usr/lib/motd.d`, so no further
configuration is necessary if defaults have not been changed.

Example:
```
session  optional  pam_motd.so motd_dir=/run/motd.d
```

## Common operations

### Enabling messages

The following enables the `motd` and `issue` messages to regenerate at
boot, and throughout the system runtime:

```
systemctl enable \
  console-login-helper-messages-issuegen.path \
  console-login-helper-messages-motdgen.path
```

One or the other may also be enabled at a time.

Generation of individual information snippets, such as OS release
information and SSH keys, can be individually as follows (provided
`issuegen` and `motdgen` are enabled as needed):

```
# read by motdgen
systemctl enable console-login-helper-messages-gensnippet-os-release.service

# read by issuegen
systemctl enable console-login-helper-messages-gensnippet-ssh-keys.service
```

Network interface information is shown via a 
[NetworkManager Dispatcher script](/etc/NetworkManager/dispatcher.d/90-console-login-helper-messages-gensnippet_if),
and will display in `issue` by default. If using private runtime directories, 
the `-issuegen` subpackage must also be installed and `-issuegen.path` shown 
above must be enabled.

On systems where NetworkManager is unavailable, udev rules could be used to 
detect new interfaces being added/removed. Udev rules are disabled by default and
do not support complex networking devices or network interfaces with custom names.

The `profile` messages are enabled by default by a symlink from
`/etc/profile.d` at install.

### Appending messages

- To have a message appended to the same `motd` file generated by 
  `console-login-helper-messages-motdgen`, the files to append can be dropped in 
  `/etc/console-login-helper-messages/motd.d/`.
- Similarly, `issue` messages to append to the same `issue` file generated by 
  `console-login-helper-messages-issuegen` can be dropped in 
  `/etc/console-login-helper-messages/issue.d/`.

Files dropped under the `/etc` location above are expected to be
unchanged during system runtime and are read only during boot.

### Disabling messages

The following disables the `motd` and `issue`  messages from regenerating from
the `.issue`/`.motd` snippets in `console-login-helper-messages`' private
directories (`/{etc,run,usr/lib}/console-login-helper-messages/{issue,motd}.d`):

```
systemctl disable \
  console-login-helper-messages-issuegen.path \
  console-login-helper-messages-motdgen.path
```

The `profile` messages can be disabled only by uninstalling
`console-login-helper-messages-profile`.

#### Silencing a generated message without disabling

If using `openssh` with `pam_motd` (default on Fedora) MOTD messages can
be silenced without completely disabling.

- Silence the `motd` generated by `console-login-helper-messages-motdgen.service`
  using a null symlink as follows:

    ```
    ln -s /dev/null /etc/motd.d/40_console-login-helper-messages.motd
    ```
- Currently, the `issue` generated by `console-login-helper-messages-issuegen.service` 
  can be silenced only by uninstalling `console-login-helper-messages-issuegen`.

#### Finer-grained disabling

The default OS release information and SSH keys may be individually
disabled from showing in the motd/issue individually:

```
# disable from motd
systemctl disable console-login-helper-messages-gensnippet-os-release.service

# disable from issue
systemctl disable console-login-helper-messages-gensnippet-ssh-keys.service
```

## Troubleshooting

### Recreating the symlinks

If a message is not showing, it could be because a symlink required to
show the message was deleted. To recreate the symlinks, the following
command can be used:

```
systemd-tmpfiles --create
```

### Regenerating the messages

To manually regenerate the `motd` or `issue` in private directories 
(`/{etc,run,usr/lib}/console-login-helper-messages/{issue,motd}.d`), the 
following commands can be used, respectively:

```
systemctl start console-login-helper-messages-motdgen.service
systemctl start console-login-helper-messages-issuegen.service
```

Otherwise, please [open an issue](https://github.com/coreos/console-login-helper-messages/issues/new)
describing the problem.

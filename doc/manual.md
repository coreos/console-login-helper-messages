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

## Architecture overview - issuegen/motgen

Two units, `console-login-helper-messages-issuegen.path` and
`console-login-helper-messages-motdgen.path`, when enabled, start on
boot and monitor the directories
`/run/console-login-helper-messages/issue.d` and
`/run/console-login-helper-messages/motd.d` for changes. If a file
(snippet) with extension `.issue`/`.motd` is written in the respective
directory, `-issuegen.path` or `-motdgen.path` triggers and runs
`-issuegen.service` or `-motdgen.service`, which concatenates all
snippets in the directories
`/{etc,run,usr/lib}/console-login-helper-messages/issue.d` or
`/{etc,run,usr/lib}/console-login-helper-messages/motd.d`, and writes
the compiled ("generated") output to a file that either the serial
console `agetty` (for issue) or the SSH login message (motd) will read.

On systems where generated runtime information snippets are not natively
supported in `agetty` or `sshd` (due to having lower versions of these
programs available), external services may instead write the information
to display to one of the
`/run/console-login-helper-messages/{issue,motd}.d`, depending on if the
information should be displayed before login (issue) or at login (motd).

Some default units and rules that make use of `-motdgen.service` and
`-issuegen.service` are included in `console-login-helper-messages`.
These include the OS release information and SSH keys snippet
generation services:

- console-login-helper-messages-gensnippet-os-release.service (motdgen)
- console-login-helper-messages-gensnippet-ssh-keys.service (issuegen)

The "gensnippet" units do nothing more than source the information that
needs to be displayed in a motd or issue, and write a file in one of the
`/run/console-login-helper-messages/{issue,motd}.d` directories. Once
a new file is written, console-login-helper-messages dynamically
updates the generated motd or issue message shown at SSH login / on
the serial console.

Files may also be dropped into the runtime directories above through
other means, such as udev rules; it need not be a systemd service
doing this. The purpose of the issuegen/motdgen units themselves is only
to regenerate a final compiled issue/MOTD in response to files being
dropped into their source runtime directories
`/run/console-login-helper-messages/{issue,motd}.d`.

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

Second, add a systemd preset to enable the issue/motd path units, as
well as units for specific pieces of information (see
[all available units](/usr/lib/systemd/system)). E.g.:

```
# /usr/lib/systemd/system-preset/40-console-login-helper-messages.preset

enable console-login-helper-messages-issuegen.path
enable console-login-helper-messages-motdgen.path
enable console-login-helper-messages-gensnippet-os-release.service
enable console-login-helper-messages-gensnippet-ssh-keys.service
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
and will display in `issue` by default as long as the `-issuegen`
subpackage is installed and `-issuegen.path` shown above is enabled.

On systems where NetworkManager is unavailable, udev rules could be used to 
detect new interfaces being added/removed. Udev rules are disabled by default and
do not support complex networking devices or network interfaces with custom names.

The `profile` messages are enabled by default by a symlink from
`/etc/profile.d` at install.

### Appending messages

- To have a message appended to the same `motd` file generated by 
  `console-login-helper-messages-motdgen`, the files to append can be dropped in 
  `/etc/console-login-helper-messages/motd.d/` or `/run/console-login-helper-messages/motd.d/`
- Similarly, `issue` messages to append to the same `issue` file generated by 
  `console-login-helper-messages-issuegen` can be dropped in 
  `/etc/console-login-helper-messages/issue.d/` or `/run/console-login-helper-messages/issue.d/`

Files dropped under the `/etc` location above are expected to be
unchanged during system runtime and are read only during boot. Files
dropped under the `/run` location above will trigger the
issuegen/motdgen `.path` unit, and the issue/motd message will be
updated.

### Disabling messages

The following disables the `motd` and `issue`  messages from regenerating:

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

To manually regenerate the `motd` or `issue`, the following commands
can be used respectively:

```
systemctl start console-login-helper-messages-motdgen.service
systemctl start console-login-helper-messages-issuegen.service
```

Otherwise, please [open an issue](https://github.com/coreos/console-login-helper-messages/issues/new)
describing the problem.

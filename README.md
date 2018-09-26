# fedora-coreos-login-messages

Runtime scripts, systemd unit files, tmpfiles, and installer scripts to provide an `issue/motd` mechanism for RHCOS/FCOS. To be distributed as an RPM, with some additional manual configuration required to work with software like PAM, agetty, ...

## Operation

Let `x` denote `{motd,issue}`.

- Symlinks from `/etc/x` to `/run/x` (see below) are set by `systemd-tmpfiles`.
- `issuegen` and `motdgen` generate `/run/x`, from files in `/etc/coreos/x.d`, `/run/coreos/x.d`, `/lib/usr/coreos/x.d`.
- Users may append to `issue` or `motd` by placing a file in `/etc/coreos/x.d/`.
- PAM and agetty must be configured to search `/etc/motd.d` and `/etc/issue.d` respectively, for the messages in those directories to be shown at login. This is default for agetty, and default for PAM as long as the `pam_motd.so` module is specified in the necessary `/etc/pam.d` configuration files.

## Directory tree (unpacking the rpm)

```
[root@a5cba1b23420 view-rpm-tree-output]# ../view-rpm-tree.sh

...

[root@a5cba1b23420 view-rpm-tree-output]# tree
.
|-- etc
|   `-- coreos
|       |-- issue.d
|       `-- motd.d
|-- run
|   `-- coreos
|       |-- issue.d
|       `-- motd.d
|-- usr
|   |-- lib
|   |   |-- coreos
|   |   |   |-- issue.d
|   |   |   |   `-- base.issue
|   |   |   |-- issuegen
|   |   |   |-- motd.d
|   |   |   `-- motdgen
|   |   |-- systemd
|   |   |   `-- system
|   |   |       |-- issuegen.path
|   |   |       |-- issuegen.service
|   |   |       |-- motdgen.path
|   |   |       `-- motdgen.service
|   |   |-- tmpfiles.d
|   |   |   |-- coreos-profile.conf
|   |   |   |-- issuegen.conf
|   |   |   `-- motdgen.conf
|   |   `-- udev
|   |       `-- rules.d
|   |           `-- 91-issuegen.rules
|   `-- share
|       |-- coreos
|       |   `-- coreos-profile.sh
|       |-- doc
|       |   `-- coreos-ux
|       |       `-- README.md
|       `-- licenses
|           `-- coreos-ux
|               `-- LICENSE
`-- view-rpm-tree-output

25 directories, 14 files
```

## Next steps
- [x] account for issue in install.sh (for testing)
- [x] script to enable the systemd units and reboot (for testing)
- [x] script to configure PAM (for testing)
    - no script; make it a responsibility of the user, not of the package installer. therefore PAM doesn't need to be a dependency
- [x] make systemd-tmpfiles config to create symlinks
    - rpm installation can also set up symlinks, but it should be a responsibility of systemd to keep the symlinks maintained (user can easily override by placing config in /etc/\*.conf acting on top of /usr/lib/\*.conf)
- [x] wrap everything up with rpm spec file (includes gen scripts, tmpfiles config, systemd units)
- [x] show systemd failed units, or find out where this is currently being done https://github.com/coreos/init/commit/5e82c6bf46d746545281a219ce82af57e950f026#diff-892b6c24ac66bd41b13adeaeb077da83
- [ ] testing that the info we need shows in RHCOS
  - [ ] a "you should not be sshing into this OS" message in motd
  - [ ] a "dev info" message (motd and issue)
  - [ ] ssh keys in issue and motd
  - [ ] added users in issue and motd
  - [x] ip address in issue
  - [ ] some info  on updates (booting, pending, etc) from rpm-ostree status --json? in motd
  - [x] failed units on login
- [ ] check installation against RHCOS and FCOS

## Issues to figure out right now

- How to manage files existing at /etc/motd and /etc/issue before installing? If they exist, this causes problems when installing if they are included under `%files` as part of the coreos-ux package. The symlinks `/etc/motd -> /etc/run` and `/etc/issue -> /run/issue` do not get created if they exist.
- After a system update, how do motd/issue source the updated info? Possibly add a PathChanged to the appropriate system/\*.path unit file, so that motd and issue can update.
- How to make sure issuegen.* and motdgen.* are enabled (i.e. run every boot, and whenever something is dropped into a motd.d/issue.d) after installing? Done in `%post`? `WantedBy` a `.target` required? Or is this done by preset config?

## Enhancements for future
- have upstream PAM include the "trying" functionality, use this config rather than symlinks
- have upstream PAM search issue.d with pam_issue.so (rather than agetty, go through one interface - PAM)

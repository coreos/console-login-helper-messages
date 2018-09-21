# fedora-coreos-login-messages

Runtime scripts, systemd unit files, tmpfiles, and installer scripts to provide an `issue/motd` mechanism for RHCOS/FCOS. To be distributed as an RPM, with some additional manual configuration required to work with software like PAM, agetty, ...

## Operation

Let `x` denote `{motd,issue}`.

- Symlinks from `/etc/x` to `/run/x` (see below) are set by `systemd-tmpfiles`.
- `issuegen` and `motdgen` generate `/run/x`, from files in `/etc/coreos/x.d`, `/run/coreos/x.d`, `/lib/usr/coreos/x.d`.
- Users may append to `issue` or `motd` by placing a file in `/etc/coreos/x.d/`.
- PAM and agetty must be configured to search `/etc/motd.d` and `/etc/issue.d` respectively, for the messages in those directories to be shown at login. This is default for agetty, and default for PAM as long as the `pam_motd.so` module is specified in the necessary `/etc/pam.d` configuration files.

## Directory tree (after install and runtime initialization)

```
/
├── etc
│   ├── coreos
│   │   ├── issue.d
│   │   └── motd.d
│   ├── issue -> ../run/issue
│   └── motd -> ../run/motd
├── run
│   ├── coreos
│   │   ├── issue.d
│   │   └── motd.d
│   ├── issue
│   └── motd
└── usr
    └── lib
        ├── coreos
        │   ├── issue.d
        │   ├── issuegen
        │   ├── motd.d
        │   └── motdgen
        ├── systemd
        │   └── system
        │       ├── issuegen.service
        │       └── motdgen.service
        ├── tmpfiles.d
        │   ├── issuegen.conf
        │   └── motdgen.conf
        └── udev
            └── 91-issuegen.rules  
```

## Steps to test motd in RHCOS

1. After cloning this repository, download the latest RHCOS Vagrant box
2. `vagrant box add --name rhcos /path/to/box.box` (any name other than `rhcos` works here, just be sure to update the Vagrantfile)
3. In this repository, `vagrant up && vagrant ssh`
4. Run the following commands once ssh has completed

        $ sudo su
        # ostree admin unlock
        # cd /srv/fedora-coreos-login-messages
        # ./install.sh
        # ./setup-run.sh
        # ./start.sh

5. Now edit the sshd PAM configuration of RHCOS in `vi /etc/pam.d/sshd`:

Add the following line just before `session include password-auth`:

        session optional pam_motd.so

6. `# exit`, then `$ exit` to exit SSH.

7. `vagrant ssh`, now new `motd`s should appear!

## Steps to test issue in RHCOS

1. Follow steps 1-4 in "Steps to test motd..." above

2. **WIP**: need to reboot or `udevadm control --reload-rules` here, running into issues with those. doing this on `fedora/28-cloud-base` works

3. `vagrant ssh`, and check the contents of `/run/coreos/issue.d`. If there are device files in there, then the udev rule successfully transferred the information to issue.

## Next steps
- [x] account for issue in install.sh (for testing)
- [x] script to enable the systemd units and reboot (for testing)
- [x] script to configure PAM (for testing)
    - no script; make it a responsibility of the user, not of the package installer. therefore PAM doesn't need to be a dependency
- [x] make systemd-tmpfiles config to create symlinks
    - rpm installation can also set up symlinks, but it should be a responsibility of systemd to keep the symlinks maintained (user can easily override by placing config in /etc/\*.conf acting on top of /usr/lib/\*.conf)
- [ ] wrap everything up with rpm spec file (includes gen scripts, tmpfiles config, systemd units)
- [x] show systemd failed units, or find out where this is currently being done https://github.com/coreos/init/commit/5e82c6bf46d746545281a219ce82af57e950f026#diff-892b6c24ac66bd41b13adeaeb077da83
- [ ] testing that the info we need shows in RHCOS
  - [ ] a "you should not be sshing into this OS" message in motd
  - [ ] a "dev info" message (motd and issue)
  - [ ] ssh keys in issue and motd
  - [ ] added users in issue and motd
  - [ ] ip address in issue
  - [ ] some info  on updates (booting, pending, etc) from rpm-ostree status --json? in motd

## Issues to figure out right now

- delete symlinks/files existing in /etc/ before install?
- rpm packaging and making sure the services are run by init script (which has system_u SELinux user)
- how do `motd` and `issue` get updated at runtime (e.g. if a systemd unit fails, new device appears, updates finished installing, user drops something in /etc/... etc)?
  - should add a PathChanged to the appropriate system/\*.path unit file
- integrating the issuegen and motdgen systemd units into current init system

## Enhancements for future
- have upstream PAM include the "trying" functionality, use this config rather than symlinks
- have upstream PAM search issue.d with pam_issue.so (rather than agetty, go through one interface - PAM)

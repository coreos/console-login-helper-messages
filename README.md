# fedora-coreos-login-messages

Runtime scripts, systemd unit files, tmpfiles, and installer scripts to provide an `issue/motd` mechanism for RHCOS/FCOS. To be distributed as an RPM, with some additional manual configuration required to work with software like PAM, agetty, udev, ...

## Operation

- Symlinks from `/etc/` to `/run/` (see below) are set by `systemd-tmpfiles`.
- `issuegen` and `motdgen` generate `issue`/`motd` files in `/run/`, `/run/motd.d/`, and `/run/issue.d`, based on updated system data.
- New system data may be "fed" at runtime to `issuegen`/`motdgen` by placing a file in the corresponding private folder in `/run/coreos/issue.d` or `/run/coreos/motd.d`. This is currently how `isssuegen` works in CL to get an IP address.
- Users may customize `issue` or `motd` by breaking the necessary symlinks and placing a file in `/etc/`. This overshadows the generated ones in `/run/`
- If users would like to keep the original generated `issue`/`motd` and append their own `issue`/`motd`, they may break the symlinks `/etc/motd.d` or `/etc/issue.d`, create directories in their place, and place files in those directories (`/etc/motd.d/`/`/etc/issue.d/`).
- PAM and agetty must be configured to search `/etc/motd.d` and `/etc/issue.d` respectively, for the messages in those directories to be shown at login. This is default for agetty, and default for PAM as long as the `pam_motd.so` module is specified in the necessary `/etc/pam.d` configuration files.

## Directory tree (after install and systemd-tmpfiles)

```
/
├── etc
│   ├── issue -> ../run/issue
│   ├── issue.d -> ../run/issue.d
│   ├── motd -> ../run/motd
│   └── motd.d -> ../run/motd.d
├── run
│   ├── coreos
│   │   └── issue.d
│   ├── issue
│   ├── issue.d
│   ├── motd
│   └── motd.d
└── usr
    └── lib
        ├── coreos
        │   ├── issuegen
        │   └── motdgen
        ├── issue
        ├── issue.d
        │   └── test.issue
        ├── motd
        ├── motd.d
        │   └── test.motd
        ├── systemd
        │   └── system
        │       ├── issuegen.service
        │       ├── motdgen.path
        │       └── motdgen.service
        └── tmpfiles.d
            ├── issuegen.conf
            └── motdgen.conf
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

2. Create a new file `# vi /usr/lib/udev/rules.d/90-issuegen.rules` with contents of the following (same rule as CL):

        ACTION=="add", SUBSYSTEM=="net", ENV{INTERFACE}=="e*", RUN+="/usr/lib/coreos/issuegen add $env{INTERFACE}"
        ACTION=="remove", SUBSYSTEM=="net", ENV{INTERFACE}=="e*", RUN+="/usr/lib/coreos/issuegen remove $env{INTERFACE}"

3. `# chcon -u system_u /usr/lib/udev/rules.d/90-issuegen.rules`

4. **WIP**: need to reboot or `udevadm control --reload-rules` here, running into issues with those. doing this on `fedora/28-cloud-base` works

5. `vagrant ssh`, and check the contents of `/run/coreos/issue.d`. If there are device files in there, then the udev rule successfully transferred the information to issue.

## Next steps
- [x] account for issue in install.sh (for testing)
- [x] script to enable the systemd units and reboot (for testing)
- [x] script to configure PAM (for testing)
    - no script; make it a responsibility of the user, not of the package installer. therefore PAM doesn't need to be a dependency
- [x] make systemd-tmpfiles config to create symlinks
    - rpm installation can also set up symlinks, but it should be a responsibility of systemd to keep the symlinks maintained (user can easily override by placing config in /etc/\*.conf acting on top of /usr/lib/\*.conf)
- [ ] wrap everything up with rpm spec file (includes gen scripts, tmpfiles config, systemd units)
- [ ] show systemd failed units, or find out where this is currently being done https://github.com/coreos/init/commit/5e82c6bf46d746545281a219ce82af57e950f026#diff-892b6c24ac66bd41b13adeaeb077da83
- [ ] testing that the info we need shows in RHCOS

## Issues to figure out right now

- delete symlinks/files existing in /etc/ before install?
- create backup symlink from /run/{motd,issue} to /usr/lib/{motd,issue}?
- rpm packaging and making sure the services are run by init script (which has system_u SELinux user)
- path for update configuration changes in motdgen.path unit file
- how do `motd` and `issue` get updated at runtime (e.g. if a systemd unit fails, new device appears, etc)?
- integrating the issuegen and motdgen systemd units into current init system

## Enhancements for future
- have upstream PAM include the "trying" functionality, use this config rather than symlinks
- have upstream PAM search issue.d with pam_issue.so (rather than agetty, go through one interface - PAM)

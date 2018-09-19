# fedora-coreos-login-messages
Repo to contain development files for fedora-coreos login messages

## Operation
- use symlinks (see tree output below, issue will have similar idea) created by systemd-tmpfiles
- within motdgen and issuegen scripts, generate a single motd/issue file (don't append anything in `/etc/motd.d`)
    - PAM and agetty search /etc/motd.d and /etc/issue.d, so users can drop messages in here (after removing the symlink) - no need to append in issuegen or motdgen
    - issuegen only appends things in `/run/coreos/issue.d`, not `/run/issue.d`; the former is in our control and latter is for users
    - the init process (or any process with systemd_u in SELinux security context) must install the motd scripts, otherwise `systemctl start motdgen.service` runs into permission errors
- if users wish to override things, they may place a new file in tmpfiles.d to change/delete the symlinks, drop their own files into issue/motd/issue.d/motd.d, create their own systemd units
- to integrate with PAM, agetty, etc, this is up to the user to configure those - this RPM will only install the systemd units, scripts, and tmpfiles config

## How the directory looks after ./install.sh

```
[root@localhost fedora-coreos-login-messages]# ./install.sh install
Installing to install/
[root@localhost fedora-coreos-login-messages]# tree install
install
├── etc
│   ├── issue -> install/run/issue
│   ├── issue.d -> install/run/issue.d
│   ├── motd -> install/run/motd
│   └── motd.d -> install/run/motd.d
├── run
│   ├── coreos
│   │   └── issue.d
│   │       └── test-info.issue
│   ├── issue -> install/usr/lib/issue
│   ├── issue.d -> install/usr/lib/issue.d
│   ├── motd -> install/usr/lib/motd
│   └── motd.d -> install/usr/lib/motd.d
└── usr
    └── lib
        ├── coreos
        │   ├── issuegen
        │   └── motdgen
        ├── issue
        ├── issue.d
        │   └── test.motd
        ├── motd
        ├── motd.d
        │   └── test.motd
        └── systemd
            └── system
                ├── issuegen.service
                ├── motdgen.path
                └── motdgen.service
```

## Next steps
- [x] account for issue in install.sh (for testing)
- [x] script to enable the systemd units and reboot (for testing)
- [x] script to configure PAM (for testing)
    - no script; make it a responsibility of the user, not of the package installer. therefore PAM doesn't need to be a dependency
- [ ] make systemd-tmpfiles config to create symlinks
    - rpm installation can also set up symlinks, but it should be a responsibility of systemd to keep the symlinks maintained (user can easily override by placing config in /etc/\*.conf acting on top of /usr/lib/\*.conf)
- [ ] wrap everything up with rpm spec file (includes gen scripts, tmpfiles config, systemd units)
- [ ] show systemd failed units, or find out where this is currently being done https://github.com/coreos/init/commit/5e82c6bf46d746545281a219ce82af57e950f026#diff-892b6c24ac66bd41b13adeaeb077da83

## Issues to figure out right now
 - have symlinks be treated like files - if a file is written where the symlink is, the symlink gets deleted and file goes in its place
    - users can use cp --remove-destination my-motd /etc/motd to delete the symlink first, then put a file in to replace it. other option is rm /etc/motd and
    - another option is delete the tmpfile creating the symlinks
- appropriate selinux perms for systemd units (the units, scripts, symlinks need to have context with user system_u)

## Enhancements for future
- have upstream PAM include the "trying" functionality, use this config rather than symlinks
- have upstream PAM search issue.d with pam_issue.so (rather than agetty, go through one interface - PAM)

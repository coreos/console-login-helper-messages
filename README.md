# fedora-coreos-login-messages
Repo to contain development files for fedora-coreos login messages

## Operation
- use symlinks (see tree output below, issue will have similar idea)
- within motdgen and issuegen scripts, generate a single motd/issue file (don't append anything in `/etc/motd.d`)
    - PAM and agetty search /etc/motd.d and /etc/issue.d, so users can drop messages in here (after removing the symblink) - no need to append in issuegen or motdgen
    - issuegen only appends things in `/run/coreos/issue.d`, not `/run/issue.d`; the former is in our control and latter is for users
- if users wish to override things, they may delete the symlinks at etc, drop their own files there, create their own systemd units writing to etc

## How the directory looks after ./install.sh

```
[rob@localhost fedora-coreos-login-messages]$ ./install.sh 
Installing to /home/rob/vagrants/fedora-coreos-login-messages/install
[rob@localhost fedora-coreos-login-messages]$ tree install
install
├── etc
│   ├── motd -> ../run/motd
│   └── motd.d -> ../run/motd.d
├── run
│   ├── motd -> ../usr/lib/motd
│   └── motd.d -> ../usr/lib/motd.d
└── usr
    └── lib
        ├── coreos
        │   └── motdgen
        ├── motd
        ├── motd.d
        │   └── test.motd
        └── systemd
            └── system
                ├── motdgen.path
                └── motdgen.service
```

## Next steps
- script to enable the systemd units and reboot (for testing)
- script to configure PAM (for testing)
- make systemd-tmpfiles config to create symlinks
- wrap everything up with rpm spec file (includes gen scripts, tmpfiles config, systemd units)
- show systemd failed units, or find out where this is currently being done https://github.com/coreos/init/commit/5e82c6bf46d746545281a219ce82af57e950f026#diff-892b6c24ac66bd41b13adeaeb077da83

## Issues to figure out right now
 - have symlinks be treated like files - if a file is written where the symlink is, the symlink gets deleted and file goes in its place

## Enhancements for future
- have upstream PAM include the "trying" functionality, use this config rather than symlinks
- have upstream PAM search issue.d with pam_issue.so (rather than agetty, go through one interface - PAM)

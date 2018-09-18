# fedora-coreos-login-messages
Repo to contain development files for fedora-coreos login messages

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

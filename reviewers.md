# Reviewers

Please see the following steps as ways to verify the `console-login-helper-messages` functionality
is working.

## Testing

After installing the `console-login-helper-messages-*` rpms, the items on the following
checklist should work.

Alternatively to manually installing, the Vagrantfile (see section below)
may be used to automatically enable the COPR repo and install the packages.

- [x] The MOTD was generated

        $ cat /run/motd.d/console-login-helper-messages.motd
        Fedora (29 (Cloud Edition))

- [x] The issue symlink was created and issue generated

        $ ls -l /etc/issue.d/console-login-helper-messages.issue
        lrwxrwxrwx. 1 root root 48 Dec 10 20:12 /etc/issue.d/console-login-helper-messages.issue -> /run/issue.d/console-login-helper-messages.issue
        $ cat /run/issue.d/console-login-helper-messages.issue
        This is \n (\s \m \r) \t
        SSH host key: SHA256:0n7Zlbmhnjr7P+pNA2hYM0MPmdmPBNnGQ+I90Q1Dwgk (ECDSA)
        SSH host key: SHA256:FUpLCL6eYYCT5s2izSxGvwaE6lEqjp3GO34UEa7G/UQ (ED25519)
        SSH host key: SHA256:nApsM6b6l2peh/+X5iYInMFcAeEm4T6irRp/VTeSvDM (RSA)

- [x] The profile script reports a failed unit

        $ sudo su
        # cat > /usr/lib/systemd/system/console-login-helper-messages-fail-unit-test.service <<EOF
        [Unit]
        Description=Failing unit
        Before=systemd-user-sessions.service

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/lib/console-login-helper-messages/nonexistent

        [Install]
        WantedBy=multi-user.target
        EOF

        # systemctl start console-login-helper-messages-fail-unit-test.service
        Job for console-login-helper-messages-fail-unit-test.service failed because...

        # exit # Exit out and back in to get the profile script to run
        $ sudo su
        [systemd]
        Failed Units: 1
          console-login-helper-messages-fail-unit-test.service

- [x] A motd message can be appended and displayed

        # echo "hello" > /run/console-login-helper-messages/motd.d/00_hello
        # systemctl restart console-login-helper-messages-motdgen.service
        # cat /run/motd.d/console-login-helper-messages.motd 
        Fedora (29 (Cloud Edition))
        hello


### Testing - Vagrantfile

The [Vagrantfile](Vagrantfile) can also be used to install the packages and
verify the package functionality on Fedora 29 Cloud Base as follows:

```
# dnf install vagrant-libvirt # The Vagrantfile specifically uses libvirt, but others like VirtualBox would work
$ cd console-login-helper-messages # Be in the top level of this repo
$ vagrant up
$ vagrant ssh
# Check the items in the checklist in the Testing section above.
```

## Build locally

To build the srpm locally, use the command

```
make -f .copr/Makefile srpm outdir="$PWD" spec="./console-login-helper-messages.spec"
```

from the top level directory of this repository.

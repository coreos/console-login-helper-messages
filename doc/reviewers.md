# Reviewing and verifying package functionality

Use the following steps to verify the `console-login-helper-messages` package
works.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Manual tests](#manual-tests)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Install RPMs to test in a machine following [manual](manual.md#installation),
**or** install from source following [development instructions](development.md).

To see the full instructions available to the user, please see the [manual](manual.md).

## Manual tests

- [x] The MOTD was generated

        $ cat /run/motd.d/40_console-login-helper-messages.motd
        Fedora 29 (Cloud Edition)

        `ssh localhost` from within the machine should display this
        information.

- [x] The issue symlink was created and issue generated

        $ ls -l /etc/issue.d/40_console-login-helper-messages.issue
        lrwxrwxrwx. 1 root root 48 Dec 10 20:12 /etc/issue.d/40_console-login-helper-messages.issue -> /run/console-login-helper-messages/40_console-login-helper-messages.issue
        $ cat /run/console-login-helper-messages/40_console-login-helper-messages.issue
        SSH host key: SHA256:0n7Zlbmhnjr7P+pNA2hYM0MPmdmPBNnGQ+I90Q1Dwgk (ECDSA)
        SSH host key: SHA256:FUpLCL6eYYCT5s2izSxGvwaE6lEqjp3GO34UEa7G/UQ (ED25519)
        SSH host key: SHA256:nApsM6b6l2peh/+X5iYInMFcAeEm4T6irRp/VTeSvDM (RSA)
        eth0: 10.0.2.15 fec0::5054:ff:fe12:3456

        Running `agetty --show-issue` should display this information.

- [x] The profile script reports a failed unit

        $ sudo su
        # cat > /usr/lib/systemd/system/console-login-helper-messages-fail-unit-test.service <<EOF
        [Unit]
        Description=Failing unit
        Before=systemd-user-sessions.service

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/libexec/console-login-helper-messages/nonexistent

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

        # echo "hello" > /run/console-login-helper-messages/motd.d/00_hello.motd
        # cat /run/motd.d/40_console-login-helper-messages.motd 
        hello
        Fedora 29 (Cloud Edition)

- [x] An issue message can be appended and displayed

        # echo "hello" > /run/console-login-helper-messages/issue.d/00_hello.issue
        # cat /run/console-login-helper-messages/40_console-login-helper-messages.issue
        hello
        Fedora 29 (Cloud Edition)

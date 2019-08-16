# Reviewers

Please see the following steps as ways to verify the `console-login-helper-messages` functionality
is working.

To see the full instructions available to the user, please see the [manual](manual.md).

## Testing

After installing the `console-login-helper-messages-*` rpms, the items on the following
checklist should work.

Alternatively to manually installing, the Vagrantfile (see section below)
may be used to automatically enable the COPR repo and install the packages.

- [x] The MOTD was generated

        $ cat /run/motd.d/40_console-login-helper-messages.motd
        Fedora 29 (Cloud Edition)

- [x] The issue symlink was created and issue generated

        $ ls -l /etc/issue.d/40_console-login-helper-messages.issue
        lrwxrwxrwx. 1 root root 48 Dec 10 20:12 /etc/issue.d/40_console-login-helper-messages.issue -> /run/console-login-helper-messages/40_console-login-helper-messages.issue
        $ cat /run/console-login-helper-messages/40_console-login-helper-messages.issue
        SSH host key: SHA256:0n7Zlbmhnjr7P+pNA2hYM0MPmdmPBNnGQ+I90Q1Dwgk (ECDSA)
        SSH host key: SHA256:FUpLCL6eYYCT5s2izSxGvwaE6lEqjp3GO34UEa7G/UQ (ED25519)
        SSH host key: SHA256:nApsM6b6l2peh/+X5iYInMFcAeEm4T6irRp/VTeSvDM (RSA)
        eth0: 10.0.2.15 fec0::5054:ff:fe12:3456

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

        # echo "hello" > /run/console-login-helper-messages/motd.d/00_hello
        # systemctl restart console-login-helper-messages-motdgen.service
        # cat /run/motd.d/40_console-login-helper-messages.motd 
        hello
        Fedora 29 (Cloud Edition)

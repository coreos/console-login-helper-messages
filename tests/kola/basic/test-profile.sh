#!/bin/bash

# Test for profile.sh

set -xeuo pipefail

. ${KOLA_EXT_DATA}/test-util.sh

# Add a systemd unit that will fail
cat > /etc/systemd/system/${PKG_NAME}-fail-unit-test.service <<EOF
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

systemctl start ${PKG_NAME}-fail-unit-test.service || :

cd $(mktemp -d)

bash -i <<< "echo Displaying failed units" > console-output.txt
assert_file_has_content console-output.txt \
    '[systemd]' \
    'Failed Units: ' \
    'console-login-helper-messages-fail-unit-test.service'
ok "displaying failed units"

tap_finish

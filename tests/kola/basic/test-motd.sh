#!/bin/bash

# Test for motdgen's basic functionality

set -xeuo pipefail

. ${KOLA_EXT_DATA}/test-util.sh

unit="${PKG_NAME}-gensnippet-os-release.service"
if ! systemctl is-enabled "${unit}"; then
  fatal "unit ${unit} not enabled"
fi

# Check that the OS Release snippet was created.
assert_has_file "${MOTD_RUN_SNIPPETS_PATH}/21_os_release.motd"
ok "gensnippet_os_release"

cd "$(mktemp -d)"

# Generate SSH keys and add public key to authorized keys
ssh-keygen -t rsa -N "" -f my.key
mkdir -p ~/.ssh/
cat my.key.pub >> ~/.ssh/authorized_keys
# Check that a new motd snippet will be displayed at login from SSH when a .motd
# file is dropped into the MOTD run directory.
echo 'foo' > "${MOTD_RUN_SNIPPETS_PATH}/10_foo.motd"
( timeout 5 script -c "ssh -tt -o StrictHostKeyChecking=no -i my.key root@localhost" ssh_login_output.txt ) || :
assert_file_has_content ssh_login_output.txt 'foo'
ok "display new MOTD"

tap_finish

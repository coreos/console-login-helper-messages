#!/usr/bin/bash

set -xeuo pipefail

top_src_dir=$(git rev-parse --show-toplevel)
pkg=console-login-helper-messages
vmdir=$top_src_dir/vm
sshkey_path="${vmdir}/id_rsa"
ssh_port=2226

rpms_paths="$(ls "$top_src_dir/build/${pkg}/rpms/noarch/${pkg}-"*.noarch.rpm | tr "\n" " ")"
ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Remove old RPMs in VM image.
ssh ${ssh_opts} -i "${sshkey_path}" -p "${ssh_port}" root@localhost <<EOF
set -xeuo pipefail

pkgs=\$(rpm -qa | grep ${pkg})
if [ -n "\${pkgs}" ]; then
    echo "\${pkgs}" | xargs rpm -e
fi
rm -f "/root/${pkg}-"*.noarch.rpm
EOF

# Copy new RPMs to VM image.
scp ${ssh_opts} -i ${sshkey_path} -P ${ssh_port} ${rpms_paths} root@localhost:/root

ssh ${ssh_opts} -i "${sshkey_path}" -p "${ssh_port}" root@localhost <<EOF
set -xeuo pipefail

# Install new RPMs in VM.
rpm -i "/root/${pkg}-"*.noarch.rpm

# Enable applicable units, and reboot the VM so the services start as
# if installed already.
systemctl enable console-login-helper-messages-issuegen.path
systemctl enable console-login-helper-messages-motdgen.path
systemctl enable console-login-helper-messages-gensnippet-ssh-keys.service
systemctl enable console-login-helper-messages-gensnippet-os-release.service
systemctl reboot
EOF

echo "SSH into the VM with: ssh -i ${sshkey_path} -p ${ssh_port} root@localhost"

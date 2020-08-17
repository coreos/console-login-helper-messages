#!/usr/bin/bash

set -xeuo pipefail

pkg=console-login-helper-messages
top_src_dir=$(git rev-parse --show-toplevel)
vmdir=$top_src_dir/vm
sshkey_path="$vmdir/id_rsa"
ssh_port="2226"
ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# rootfs to install to, mounted in the container
mkdir -p "./build/rootfs"

podman run --rm --name $pkg -v $top_src_dir:/$pkg $pkg make install DESTDIR=/$pkg/build/rootfs

# Note: don't use the -a (archive) option for rsync - don't preserve
# file owner (-o) and groups (-g) (these should all be root), otherwise
# systemd-tmpfiles appears to run into problems creating the runtime
# directories. https://github.com/systemd/systemd/issues/11282
rsync -rlpdv -e "ssh $ssh_opts -i $sshkey_path -p $ssh_port" ./build/rootfs/ root@localhost:/

# Enable applicable units, and reboot the VM so the services start as
# if installed already.
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost <<EOF
set -xeuo pipefail
systemctl enable console-login-helper-messages-issuegen.path
systemctl enable console-login-helper-messages-motdgen.path
systemctl enable console-login-helper-messages-gensnippet-os-release.service
systemctl enable console-login-helper-messages-gensnippet-ssh-keys.service
systemctl reboot
EOF

echo SSH into the VM with: ssh -i $sshkey_path -p $ssh_port root@localhost

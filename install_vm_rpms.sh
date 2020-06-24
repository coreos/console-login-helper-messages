#!/usr/bin/bash

set -xeuo pipefail

pkg=console-login-helper-messages
vmdir=./vm
sshkey_path="$vmdir/id_rsa"
ssh_port=2226

rpms_paths=$(ls ./build/$pkg/rpms/noarch/${pkg}-*.noarch.rpm | tr '\n' ' ')
ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Remove old RPMs in VM image.
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost "pkgs=\$(rpm -qa | grep ${pkg}) ; if [ -n \"\$pkgs\" ]; then echo \"\$pkgs\" | xargs rpm -e; fi"
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost "rm -f /root/${pkg}-*.noarch.rpm"

# Copy new RPMs to VM image.
scp $ssh_opts -i $sshkey_path -P $ssh_port $rpms_paths root@localhost:/root

# Install new RPMs in VM.
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost "rpm -i /root/${pkg}-*.noarch.rpm"

# Enable applicable units, and reboot the VM so the services start as
# if installed already.
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost "systemctl enable console-login-helper-messages-issuegen.path"
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost "systemctl enable console-login-helper-messages-motdgen.path"
ssh $ssh_opts -i $sshkey_path -p $ssh_port root@localhost "systemctl reboot"

echo SSH into the VM with: ssh -i $sshkey_path -p $ssh_port root@localhost

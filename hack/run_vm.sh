#!/usr/bin/bash

set -xeuo pipefail

top_src_dir=$(git rev-parse --show-toplevel)
vmdir=$top_src_dir/vm
ssh_port=2226
mkdir -p $vmdir

image_path="$1"

rm -f $vmdir/*
sshkey_path="$vmdir/id_rsa"
ssh-keygen -t rsa -f "$sshkey_path" -q -N ""
ssh_pubkey=$(cat "${sshkey_path}.pub")

guestfish --rw -i -a "$image_path" <<EOF
mkdir-p /root/.ssh/
chmod 0700 /root/.ssh/
copy-in "$sshkey_path" "${sshkey_path}.pub" /root/.ssh/
write /root/.ssh/authorized_keys "${ssh_pubkey}"
chmod 0600 /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/id_rsa
chmod 0644 /root/.ssh/id_rsa.pub
write /etc/ssh/sshd_config.d/99-enable-root-login "PermitRootLogin without-password\n"
write /etc/ssh/sshd_config.d/99-enable-pubkey "PubkeyAuthentication yes\n"
selinux-relabel /etc/selinux/targeted/contexts/files/file_contexts /root/.ssh
EOF

qemu-kvm -m 2048 -cpu host -nographic -snapshot \
	-drive if=virtio,file="${image_path}" \
	-nic user,model=virtio,hostfwd=tcp::${ssh_port}-:22

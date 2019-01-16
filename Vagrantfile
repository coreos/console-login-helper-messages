# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install dependencies, install, and run console-login-helper-messages on Fedora.
Vagrant.configure("2") do |config|
  config.vm.box = "fedora/29-cloud-base"
  config.vm.provision "shell", inline: <<-SHELL
    sudo su
    dnf copr enable -y rfairley/console-login-helper-messages 
    dnf install -y console-login-helper-messages \
        console-login-helper-messages-motdgen \
        console-login-helper-messages-issuegen \
        console-login-helper-messages-profile \
        selinux-policy \
        pam --enablerepo=updates-testing
    echo "placeholder" > /run/motd
    mkdir -p /run/motd.d
    systemctl enable motdgen.service motdgen.path issuegen.service issuegen.path
    systemctl start motdgen.service issuegen.service
    SHELL
end

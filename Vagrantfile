# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install dependencies, install, and run console-login-helper-messages on Fedora.
Vagrant.configure("2") do |config|
  config.vm.box = "fedora/29-cloud-base"
  config.vm.provider "libvirt" do |v|
     v.memory = 2048
  end
  config.vm.provision "shell", inline: <<-SHELL
    sudo su
    dnf update -y
    dnf install -y console-login-helper-messages \
        console-login-helper-messages-motdgen \
        console-login-helper-messages-issuegen \
        console-login-helper-messages-profile
    systemctl enable \
        console-login-helper-messages-motdgen.service \
        console-login-helper-messages-issuegen.service
    systemctl start \
        console-login-helper-messages-motdgen.service \
        console-login-helper-messages-issuegen.service
    SHELL
end

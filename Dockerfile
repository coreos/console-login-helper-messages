FROM registry.fedoraproject.org/fedora:32

RUN dnf -y install make git rpm-build 'dnf-command(builddep)'
RUN dnf -y builddep console-login-helper-messages-issuegen console-login-helper-messages-motdgen console-login-helper-messages-profile

WORKDIR /console-login-helper-messages

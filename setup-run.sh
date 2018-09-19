#!/bin/bash

# None of this logic will be included in the installer
# this is just to workaround to get system_u added so
# systemctl can be used to start the services when testing.

set -eo pipefail

# Leave as empty to install to root (/)
INSTALL_PATH="$1"

source ./envvars

echo "Setting up run for $INSTALL_PATH/"

# ---- deal with SELinux for everything created ----

chcon -u system_u $SCRIPT_DEST
chcon -u system_u $SYSTEMD_UNIT_DEST
chcon -u system_u $SYSTEMD_TMPFILES_DEST
chcon -u system_u $ETC_DEST
chcon -u system_u $RUN_DEST
chcon -u system_u $USRLIB_DEST
chcon -u system_u $USRLIB_DEST/motd.d
chcon -u system_u $USRLIB_DEST/issue.d
chcon -u system_u $RUN_DEST/coreos/issue.d

chcon -u system_u $SYSTEMD_UNIT_DEST/issuegen.service
chcon -u system_u $SYSTEMD_UNIT_DEST/motdgen.service
chcon -u system_u $SYSTEMD_UNIT_DEST/motdgen.path
chcon -u system_u $SCRIPT_DEST/issuegen
chcon -u system_u $SCRIPT_DEST/motdgen
chcon -u system_u $SYSTEMD_TMPFILES_DEST/motdgen.conf
chcon -u system_u $SYSTEMD_TMPFILES_DEST/issuegen.conf

chcon -u system_u $USRLIB_DEST/motd
chcon -u system_u $USRLIB_DEST/motd.d/test.motd

# ---- get things ready for motdgen/issuegen ----

touch $RUN_DEST/motd
chcon -u system_u $RUN_DEST/motd

mkdir -p $RUN_DEST/motd.d
chcon -u system_u $RUN_DEST/motd.d
touch $RUN_DEST/motd.d/test-info.motd
chcon -u system_u $RUN_DEST/motd.d/test-info.motd

touch $RUN_DEST/issue
chcon -u system_u $RUN_DEST/issue

mkdir -p $RUN_DEST/issue.d
chcon -u system_u $RUN_DEST/issue.d
touch $RUN_DEST/issue.d/test-info.issue
chcon -u system_u $RUN_DEST/issue.d/test-info.issue

chcon -u system_u $RUN_DEST/coreos/issue.d/test-info-priv.issue

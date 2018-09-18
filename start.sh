#!/bin/bash

set -eo pipefail

# Leave as empty to install to root (/)
INSTALL_PATH="$1"

echo "Starting, from install path $INSTALL_PATH/"

SCRIPT_DEST=$INSTALL_PATH/usr/lib/coreos
SYSTEMD_UNIT_DEST=$INSTALL_PATH/usr/lib/systemd/system
ETC_DEST=$INSTALL_PATH/etc
RUN_DEST=$INSTALL_PATH/run
USRLIB_DEST=$INSTALL_PATH/usr/lib

# ---- deal with SELinux for everything created ----

chcon -u system_u $SCRIPT_DEST
chcon -u system_u $SYSTEMD_UNIT_DEST
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

chcon -u system_u $USRLIB_DEST/motd
chcon -u system_u $USRLIB_DEST/motd.d/test.motd

chcon -h -u system_u $ETC_DEST/motd
chcon -h -u system_u $ETC_DEST/motd.d
chcon -h -u system_u $ETC_DEST/issue
chcon -h -u system_u $ETC_DEST/issue.d

chcon -h -u system_u $RUN_DEST/motd
chcon -h -u system_u $RUN_DEST/motd.d
chcon -h -u system_u $RUN_DEST/issue
chcon -h -u system_u $RUN_DEST/issue.d

# ---- get things ready for motdgen/issuegen ----

if [ -h "$RUN_DEST/motd" ]
then
  echo "Removing run/motd symlink"
  rm $RUN_DEST/motd
fi
if [ -h "$RUN_DEST/motd.d" ]
then
  echo "Removing run/motd.d symlink"
  rm $RUN_DEST/motd.d
fi
if [ -h "$RUN_DEST/issue" ]
then
  echo "Removing run/issue symlink"
  rm $RUN_DEST/issue
fi
if [ -h "$RUN_DEST/issue.d" ]
then
  echo "Removing run/issue.d symlink"
  rm $RUN_DEST/issue.d
fi

touch /run/motd
chcon -u system_u $RUN_DEST/motd

mkdir -p $RUN_DEST/motd.d
chcon -u system_u $RUN_DEST/motd.d
touch $RUN_DEST/motd.d/test-info.motd
chcon -u system_u $RUN_DEST/motd.d/test-info.motd

touch /run/issue
chcon -u system_u $RUN_DEST/issue

mkdir -p $RUN_DEST/issue.d
chcon -u system_u $RUN_DEST/issue.d
touch $RUN_DEST/issue.d/test-info.issue
chcon -u system_u $RUN_DEST/issue.d/test-info.issue

# --- start services ----

systemctl daemon-reload
systemctl start motdgen.service
systemctl start issuegen.service

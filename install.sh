#!/bin/bash

set -eo pipefail

# Leave as empty to install to root (/)
INSTALL_PATH="$1"

echo "Installing to $INSTALL_PATH/"

SCRIPT_DEST=$INSTALL_PATH/usr/lib/coreos
SYSTEMD_UNIT_DEST=$INSTALL_PATH/usr/lib/systemd/system
ETC_DEST=$INSTALL_PATH/etc
RUN_DEST=$INSTALL_PATH/run
USRLIB_DEST=$INSTALL_PATH/usr/lib

# ---- create files and directories ----

mkdir -p $SCRIPT_DEST
mkdir -p $SYSTEMD_UNIT_DEST
mkdir -p $ETC_DEST
mkdir -p $RUN_DEST
mkdir -p $USRLIB_DEST
mkdir -p $USRLIB_DEST/motd.d
# mkdir -p $USRLIB_DEST/issue.d

# cp ./issuegen.service $SYSTEMD_UNIT_DEST/
cp ./motdgen.service $SYSTEMD_UNIT_DEST/
cp ./motdgen.path $SYSTEMD_UNIT_DEST/
# cp ./issuegen $SCRIPT_DEST/
# chmod +x $SCRIPT_DEST/issuegen
cp ./motdgen $SCRIPT_DEST/
chmod +x $SCRIPT_DEST/motdgen

echo "Fallback /usr/lib/motd" > $USRLIB_DEST/motd
echo "Test file in /usr/lib/motd.d" > $USRLIB_DEST/motd.d/test.motd
# echo "Fallback /usr/lib/issue" > $USRLIB_DEST/issue
# echo "Test file in /usr/lib/issue.d" > $USRLIB_DEST/issue.d/test.motd

# ---- make symlinks ----

ln -sfT $RUN_DEST/motd $ETC_DEST/motd
ln -sfT $RUN_DEST/motd.d $ETC_DEST/motd.d
# ln -sfT $INSTALL_PATH/run/issue $INSTALL_PATH/etc/issue
# ln -sfT $INSTALL_PATH/run/issue.d $INSTALL_PATH/etc/issue.d

ln -sfT $USRLIB_DEST/motd $RUN_DEST/motd
ln -sfT $USRLIB_DEST/motd.d $RUN_DEST/motd.d
# ln -sfT $USRLIB_DEST/issue $RUN_DEST/issue
# ln -sfT $USRLIB_DEST/issue.d $RUN_DEST/issue.d

# ---- deal with SELinux for everything created ----

chcon -u system_u $SCRIPT_DEST
chcon -u system_u $SYSTEMD_UNIT_DEST
chcon -u system_u $ETC_DEST
chcon -u system_u $RUN_DEST
chcon -u system_u $USRLIB_DEST
chcon -u system_u $USRLIB_DEST/motd.d
# chcon -u system_u $USRLIB_DEST/issue.d

# chcon -u system_u $SYSTEMD_UNIT_DEST/issuegen.service
chcon -u system_u $SYSTEMD_UNIT_DEST/motdgen.service
chcon -u system_u $SYSTEMD_UNIT_DEST/motdgen.path
# chcon -u system_u $SCRIPT_DEST/issuegen
chcon -u system_u $SCRIPT_DEST/motdgen

chcon -u system_u $USRLIB_DEST/motd
chcon -u system_u $USRLIB_DEST/motd.d/test.motd

chcon -h -u system_u $ETC_DEST/motd
chcon -h -u system_u $ETC_DEST/motd.d
# chcon -h -u system_u $ETC_DEST/issue
# chcon -h -u system_u $ETC_DEST/issue.d

chcon -h -u system_u $RUN_DEST/motd
chcon -h -u system_u $RUN_DEST/motd.d
# chcon -h -u system_u $RUN_DEST/issue
# chcon -h -u system_u $RUN_DEST/issue.d

# ---- get things ready for motdgen/issuegen ----

if [ -h "$RUN_DEST/motd" ]
then
  echo "Removing run/motd symlink"
  rm $RUN_DEST/motd
  touch /run/motd
  chcon -u system_u $RUN_DEST/motd
fi
if [ -h "$RUN_DEST/motd.d" ]
then
  echo "Removing run/motd.d symlink"
  rm $RUN_DEST/motd.d
  mkdir -p $RUN_DEST/motd.d
  chcon -u system_u $RUN_DEST/motd.d
  touch $RUN_DEST/motd.d/test-info.motd
  chcon -u system_u $RUN_DEST/motd.d/test-info.motd
fi
# same for issue here

# --- start services ----

systemctl daemon-reload
systemctl start motdgen.service
# systemctl start issuegen.service

#!/bin/bash

set -eo pipefail

# Leave as empty to install to root (/)
INSTALL_PATH=$PWD/install
# INSTALL_PATH=""

echo "Installing to $INSTALL_PATH/"

SCRIPT_DEST=$INSTALL_PATH/usr/lib/coreos
SYSTEMD_UNIT_DEST=$INSTALL_PATH/usr/lib/systemd/system
ETC_DEST=$INSTALL_PATH/etc
RUN_DEST=$INSTALL_PATH/run
USRLIB_DEST=$INSTALL_PATH/usr/lib

mkdir -p $SCRIPT_DEST
mkdir -p $SYSTEMD_UNIT_DEST
mkdir -p $ETC_DEST
mkdir -p $RUN_DEST
mkdir -p $USRLIB_DEST

# cp ./issuegen $SCRIPT_DEST
cp ./motdgen $SCRIPT_DEST/
# chmod +x \
# $SCRIPT_DEST/issuegen \
# $SCRIPT_DEST/motdgen
chmod +x \
$SCRIPT_DEST/motdgen

# cp ./issuegen.service $SYSTEMD_UNIT_DEST
cp ./motdgen.service $SYSTEMD_UNIT_DEST/
cp ./motdgen.path $SYSTEMD_UNIT_DEST/

echo "Fallback /usr/lib/motd" > $USRLIB_DEST/motd
mkdir -p $USRLIB_DEST/motd.d
echo "Test file in /usr/lib/motd.d" > $USRLIB_DEST/motd.d/test.motd
# echo "Fallback /usr/lib/issue" > $USRLIB_DEST/issue
# mkdir -p $USRLIB_DEST/issue.d
# echo "Test file in /usr/lib/issue.d" > $USRLIB_DEST/issue.d/test.motd

ln -sf $RUN_DEST/motd $ETC_DEST/motd
ln -sf $RUN_DEST/motd.d $ETC_DEST/motd.d
# ln -sf $INSTALL_PATH/run/issue $INSTALL_PATH/etc/issue
# ln -sf $INSTALL_PATH/run/issue.d $INSTALL_PATH/etc/issue.d

ln -sf $USRLIB_DEST/motd $RUN_DEST/motd
ln -sf $USRLIB_DEST/motd.d $RUN_DEST/motd.d
# ln -sf $USRLIB_DEST/issue $RUN_DEST/issue
# ln -sf $USRLIB_DEST/issue.d $RUN_DEST/issue.d

chcon -u system_u /usr/lib/coreos/motdgen

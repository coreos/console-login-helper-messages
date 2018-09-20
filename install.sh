#!/bin/bash

set -eo pipefail

# This logic will be included in the installer

# Leave as empty to install to root (/)
INSTALL_PATH="$1"

echo "Installing to $INSTALL_PATH/"

source ./envvars

rm -f /etc/motd
rm -f /etc/issue

# ---- create files and directories ----

mkdir -p $SCRIPT_DEST
mkdir -p $SYSTEMD_UNIT_DEST
mkdir -p $SYSTEMD_TMPFILES_DEST
mkdir -p $UDEV_RULES_DEST
mkdir -p $ETC_DEST
mkdir -p $ETC_DEST/coreos/motd.d
mkdir -p $ETC_DEST/coreos/issue.d
mkdir -p $ETC_DEST/profile.d
mkdir -p $RUN_DEST
mkdir -p $RUN_DEST/coreos/motd.d
mkdir -p $RUN_DEST/coreos/issue.d
mkdir -p $USRLIB_DEST
mkdir -p $USRLIB_DEST/coreos/motd.d
mkdir -p $USRLIB_DEST/coreos/issue.d
mkdir -p $USRSHARE_DEST/coreos

cp ./issuegen.service $SYSTEMD_UNIT_DEST/
cp ./issuegen.path $SYSTEMD_UNIT_DEST/
cp ./motdgen.service $SYSTEMD_UNIT_DEST/
cp ./motdgen.path $SYSTEMD_UNIT_DEST/
cp ./91-issuegen.rules $UDEV_RULES_DEST/
cp ./issuegen $SCRIPT_DEST/
chmod +x $SCRIPT_DEST/issuegen
cp ./motdgen $SCRIPT_DEST/
chmod +x $SCRIPT_DEST/motdgen
cp ./issuegen.conf $SYSTEMD_TMPFILES_DEST/
cp ./motdgen.conf $SYSTEMD_TMPFILES_DEST/
cp ./coreos-profile.conf $SYSTEMD_TMPFILES_DEST/
cp ./base.issue $USRLIB_DEST/coreos/issue.d/
cp ./coreos-profile.sh $USRSHARE_DEST/coreos/
chmod +x $USRSHARE_DEST/coreos/coreos-profile.sh

echo "Test motd in /usr/lib/coreos/motd.d" > $USRLIB_DEST/coreos/motd.d/test.motd
echo "Test issue in /usr/lib/coreos/issue.d" > $USRLIB_DEST/coreos/issue.d/test.issue

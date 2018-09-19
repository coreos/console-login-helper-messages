#!/bin/bash

set -eo pipefail

# Leave as empty to install to root (/)
INSTALL_PATH="$1"

echo "Installing to $INSTALL_PATH/"

source ./envvars

# ---- create files and directories ----

mkdir -p $SCRIPT_DEST
mkdir -p $SYSTEMD_UNIT_DEST
mkdir -p $SYSTEMD_TMPFILES_DEST
mkdir -p $ETC_DEST
mkdir -p $RUN_DEST
mkdir -p $USRLIB_DEST
mkdir -p $USRLIB_DEST/motd.d
mkdir -p $USRLIB_DEST/issue.d
mkdir -p $RUN_DEST/coreos/issue.d

cp ./issuegen.service $SYSTEMD_UNIT_DEST/
cp ./motdgen.service $SYSTEMD_UNIT_DEST/
cp ./motdgen.path $SYSTEMD_UNIT_DEST/
cp ./issuegen $SCRIPT_DEST/
chmod +x $SCRIPT_DEST/issuegen
cp ./motdgen $SCRIPT_DEST/
chmod +x $SCRIPT_DEST/motdgen
cp ./issuegen.conf $SYSTEMD_TMPFILES_DEST/
cp ./motdgen.conf $SYSTEMD_TMPFILES_DEST/

echo "Fallback /usr/lib/motd" > $USRLIB_DEST/motd
echo "Test file in /usr/lib/motd.d" > $USRLIB_DEST/motd.d/test.motd
echo "Fallback /usr/lib/issue" > $USRLIB_DEST/issue
echo "Test file in /usr/lib/issue.d" > $USRLIB_DEST/issue.d/test.motd
echo "\"Private\" issue file in /run/coreos/issue.d" > $RUN_DEST/coreos/issue.d/test-info.issue

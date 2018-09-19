#!/bin/bash

set -eo pipefail

# Leave as empty to install to root (/)
INSTALL_PATH="$1"

echo "Installing to $INSTALL_PATH/"

SCRIPT_DEST=$INSTALL_PATH/usr/lib/coreos
SYSTEMD_UNIT_DEST=$INSTALL_PATH/usr/lib/systemd/system
SYSTEMD_TMPFILES_DEST=$INSTALL_PATH/usr/lib/tmpfiles.d
ETC_DEST=$INSTALL_PATH/etc
RUN_DEST=$INSTALL_PATH/run
USRLIB_DEST=$INSTALL_PATH/usr/lib

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

# ---- make symlinks ----

# improved error checking would be to assert that a symlink exists in the "else"
# conditions of all of these
if [ -f "$RUN_DEST/motd" ]
then
  if [ -h "$RUN_DEST/motd" ]
  then
    echo "Symlink already exists run/motd"
  else
    echo "Removing run/motd file"
    rm $RUN_DEST/motd
  fi
fi
if [ -d "$RUN_DEST/motd.d" ]
then
  if [ -h "$RUN_DEST/motd.d" ]
  then
    echo "Symlink already exists run/motd.d"
  else
    echo "Removing run/motd.d dir"
    rm -r $RUN_DEST/motd.d
  fi
fi
if [ -f "$RUN_DEST/issue" ]
then
  if [ -h "$RUN_DEST/issue" ]
  then
    echo "Symlink already exists run/issue"
  else
    echo "Removing run/issue file"
    rm $RUN_DEST/issue
  fi
fi
if [ -d "$RUN_DEST/issue.d" ]
then
  if [ -h "$RUN_DEST/issue.d" ]
  then
    echo "Symlink already exists run/issue.d"
  else
    echo "Removing run/issue.d dir"
    rm -r $RUN_DEST/issue.d
  fi
fi

ln -sfT $RUN_DEST/motd $ETC_DEST/motd
ln -sfT $RUN_DEST/motd.d $ETC_DEST/motd.d
ln -sfT $INSTALL_PATH/run/issue $INSTALL_PATH/etc/issue
ln -sfT $INSTALL_PATH/run/issue.d $INSTALL_PATH/etc/issue.d

ln -sfT $USRLIB_DEST/motd $RUN_DEST/motd
ln -sfT $USRLIB_DEST/motd.d $RUN_DEST/motd.d
ln -sfT $USRLIB_DEST/issue $RUN_DEST/issue
ln -sfT $USRLIB_DEST/issue.d $RUN_DEST/issue.d

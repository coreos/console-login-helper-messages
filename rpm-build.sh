#!/bin/bash

set -euo pipefail

PKG_NAME="fedora-user-messages"
PKG_VER="0.1"

mkdir -p $PKG_NAME-$PKG_VER
cp -r LICENSE README.md usr --target-directory $PKG_NAME-$PKG_VER/
tar -cvzf $PKG_NAME-$PKG_VER.tar.gz $PKG_NAME-$PKG_VER
./rpmlocalbuild $PKG_NAME.spec

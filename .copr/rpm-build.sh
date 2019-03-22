#!/bin/bash

set -euo pipefail

PKG_NAME="console-login-helper-messages"
# Change this to match the version in the specfile
# (the need to do this will be eliminated once
# Automake is added, https://github.com/rfairley/console-login-helper-messages/issues/2).
PKG_VER="0.16"

out_dir="${1}"
top_dir="$(dirname ${2})"

mkdir -p "$top_dir/.copr/$PKG_NAME-$PKG_VER"
cp -r "$top_dir"/LICENSE "$top_dir"/README.md "$top_dir"/usr --target-directory "$top_dir/.copr/$PKG_NAME-$PKG_VER/"
cd $top_dir/.copr/
tar -cvzf "$top_dir/.copr/v$PKG_VER.tar.gz" "$PKG_NAME-$PKG_VER"
cd -

# Adapted from https://github.com/jlebon/files/blob/master/bin/rpmlocalbuild

spec=$PKG_NAME.spec

rpmbuild -ba \
    --define "_sourcedir $top_dir/.copr" \
    --define "_specdir $top_dir" \
    --define "_builddir $top_dir/.copr/.build" \
    --define "_srcrpmdir $out_dir" \
    --define "_rpmdir $top_dir/.copr/rpms" \
    --define "_buildrootdir $top_dir/.copr/.buildroot" "$top_dir/$spec"
rm -rf "$top_dir/.copr/.build"

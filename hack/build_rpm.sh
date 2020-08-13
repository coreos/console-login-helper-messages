#!/usr/bin/bash

set -euo pipefail

top_src_dir=$(git rev-parse --show-toplevel)
pkg=console-login-helper-messages

# builds destination directory mounted into the container
mkdir -p $top_src_dir/build

podman run --rm --name $pkg -v $top_src_dir:/$pkg $pkg make rpm TOPSRCDIR=/$pkg/build

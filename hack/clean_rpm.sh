#!/usr/bin/bash

set -euo pipefail

top_src_dir=$(git rev-parse --show-toplevel)
pkg=console-login-helper-messages

podman run --rm --name $pkg -v $top_src_dir:/$pkg $pkg make clean_rpm TOPSRCDIR=/$pkg/build

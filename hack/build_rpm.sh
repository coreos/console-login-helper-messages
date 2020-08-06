#!/usr/bin/bash

set -euo pipefail

pkg=console-login-helper-messages

# builds destination directory mounted into the container
mkdir -p ./build

podman run --rm --name $pkg -v ./:/$pkg $pkg make rpm TOPSRCDIR=/$pkg/build

#!/usr/bin/bash

set -euo pipefail

pkg=console-login-helper-messages

podman run --rm --name $pkg -v ./:/$pkg $pkg make clean_rpm TOPSRCDIR=/$pkg/build

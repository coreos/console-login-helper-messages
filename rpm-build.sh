#!/bin/bash

set -euo pipefail

mkdir -p coreos-base-0.1
cp -r LICENSE README.md usr --target-directory coreos-base-0.1/
tar -cvzf coreos-base-0.1.tar.gz coreos-base-0.1
../rpmlocalbuild coreos-base.spec

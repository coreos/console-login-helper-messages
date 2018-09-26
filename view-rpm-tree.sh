#!/bin/bash

set -euo pipefail

mkdir -p view-rpm-tree-output
while read f; do rpm2cpio ../rpms/noarch/$f | cpio -idmv; done < <(ls ../rpms/noarch/)

#!/bin/bash

set -euo pipefail

rm -rf view-rpm-tree-output
mkdir -p view-rpm-tree-output
cd view-rpm-tree-output
while read f; do rpm2cpio ../rpms/noarch/$f | cpio -idmv; done < <(ls ../rpms/noarch/)
tree .

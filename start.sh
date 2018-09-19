#!/bin/bash

set -eo pipefail

systemctl daemon-reload

# --- make sure symlinks are created from tmpfiles ---

systemd-tmpfiles --create

# --- start services ----

systemctl start motdgen.service
systemctl start issuegen.service

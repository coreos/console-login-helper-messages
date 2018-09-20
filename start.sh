#!/bin/bash

set -eo pipefail

systemctl daemon-reload

# --- make sure symlinks are created from tmpfiles ---

systemd-tmpfiles --create

# --- start services ----

systemctl enable motdgen.path
systemctl enable motdgen.service
systemctl start motdgen.path
systemctl start motdgen.service

systemctl enable issuegen.path
systemctl enable issuegen.service
systemctl start issuegen.path
systemctl start issuegen.service

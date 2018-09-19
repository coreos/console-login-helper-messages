#!/bin/bash

set -eo pipefail

# --- start services ----

systemctl daemon-reload
systemctl start motdgen.service
systemctl start issuegen.service

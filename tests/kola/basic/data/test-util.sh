#!/bin/bash

# Collection of util functions and common definitions for kola tests.

PKG_NAME="console-login-helper-messages"

.  ${KOLA_EXT_DATA}/libtest.sh

ISSUE_RUN_SNIPPETS_PATH="/run/issue.d"
MOTD_RUN_SNIPPETS_PATH="/run/motd.d"

# this rpm is required for the fake TTY.
install_dependencies () {
  rpm-ostree install util-linux-script -y --apply-live
}

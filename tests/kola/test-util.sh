#!/bin/bash

# Collection of util functions and common definitions for kola tests.

PKG_NAME="console-login-helper-messages"

.  ${KOLA_EXT_DATA}/libtest.sh
# Source common definitions for console-login-helper-messages scripts.
. /usr/lib/${PKG_NAME}/libutil.sh

# ISSUE_RUN_SNIPPETS, MOTD_RUN_SNIPPETS may be different, depending on how
# console-login-helper-messages is configured. By default, if `util-linux`
# version is at least 2.36, `USE_PUBLIC_RUN_DIR` is set to "true".
if [ ${USE_PUBLIC_RUN_DIR} == "true" ]; then
    # Use public runtime directories
    ISSUE_RUN_SNIPPETS_PATH="/run/issue.d"
    MOTD_RUN_SNIPPETS_PATH="/run/motd.d"
else
    # Use private runtime directories
    ISSUE_RUN_SNIPPETS_PATH="/run/${PKG_NAME}/issue.d"
    MOTD_RUN_SNIPPETS_PATH="/run/${PKG_NAME}/motd.d"
fi

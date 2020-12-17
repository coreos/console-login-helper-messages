#!/bin/bash

# Collection of util functions and common definitions for kola tests.

PKG_NAME="console-login-helper-messages"

.  ${KOLA_EXT_DATA}/libtest.sh

# ISSUE_RUN_SNIPPETS, MOTD_RUN_SNIPPETS may be different, depending on the
# version of console-login-helper-messages. 
# Source `libutil.sh` to determine whether the version of 
# console-login-helper-messages that we are testing is using public or
# private directories for dropping issue/motd files.
. /usr/lib/${PKG_NAME}/libutil.sh
if [ ${USE_PUBLIC_RUN_DIR} == "true" ]; then
    # Use public runtime directories
    ISSUE_RUN_SNIPPETS_PATH="/etc/issue.d"
    MOTD_RUN_SNIPPETS_PATH="/run/motd.d"
else
    # Use private runtime directories
    ISSUE_RUN_SNIPPETS_PATH="/run/${PKG_NAME}/issue.d"
    MOTD_RUN_SNIPPETS_PATH="/run/${PKG_NAME}/motd.d"
fi

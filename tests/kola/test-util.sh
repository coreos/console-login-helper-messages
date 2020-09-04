#!/bin/bash

# Collection of util functions and common definitions for kola tests

. ${KOLA_EXT_DATA}/libtest.sh

PKG_NAME="console-login-helper-messages"
# ISSUE_RUN_SNIPPETS, MOTD_RUN_SNIPPETS may be changed in the future once 
# util-linux 2.36 is available and we can drop issue snippets directly into 
# /run/issue.d. 
ISSUE_RUN_SNIPPETS_PATH="/run/${PKG_NAME}/issue.d"
MOTD_RUN_SNIPPETS_PATH="/run/${PKG_NAME}/motd.d"

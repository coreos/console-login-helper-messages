#!/bin/bash

# Collection of util functions and common definitions for kola tests.

PKG_NAME="console-login-helper-messages"

.  ${KOLA_EXT_DATA}/libtest.sh

ISSUE_RUN_SNIPPETS_PATH="/etc/issue.d"
MOTD_RUN_SNIPPETS_PATH="/run/motd.d"

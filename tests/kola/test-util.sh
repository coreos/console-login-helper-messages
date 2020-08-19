#!/bin/bash

# Collection of util functions and common definitions for kola tests

. ${KOLA_EXT_DATA}/libtest-core.sh

PKG_NAME="console-login-helper-messages"

ok() {
    echo "ok" "$@"
}

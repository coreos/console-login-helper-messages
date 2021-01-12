#!/usr/bin/bash
#
# Collection of util functions and common definitions for
# console-login-helper-messages scripts.

PKG_NAME="console-login-helper-messages"

# On distributions where Network Manager is not used, udev rules could be used
# to detect new interfaces being added/removed.
# Udev rules are disabled by default and do not support complex networking 
# devices or network interfaces with custom names.
USE_UDEV_FOR_NETWORK_SNIPPETS=false

# On distributions that have util-linux >= 2.36, public runtime directories
# (e.g. `/run/motd.d`) can be used. Use this hardcoded variable so we can
# keep the test files the same across the two branches of c-l-h-m. 
USE_PUBLIC_RUN_DIR=true

tempfile_template="${PKG_NAME}.XXXXXXXXXX.tmp"
# Use same filesystem, under /run, as where snippets are generated, so
# that rename operations through `mv` are atomic.
tempfile_dir="/run/${PKG_NAME}"
# Default SELinux context at destination is applied, e.g. for sshd which
# requires that written files in `/run/motd.d` maintain the type
# `pam_var_run_t`.
mv_Z="mv -Z"

# Write stdin to a tempfile, and rename the tempfile to the path given
# as an argument. When called from multiple processes on the same
# generated file path, this avoids interleaving writes to the generated
# file by using `mv` to overwrite the file.
write_via_tempfile() {
    local generated_file="$1"
    local staged_file="$(mktemp --tmpdir="${tempfile_dir}" "${tempfile_template}")"
    cat > "${staged_file}"
    chmod a+r "${staged_file}"
    ${mv_Z} "${staged_file}" "${generated_file}"
}

# Write concatenation of all files with a given suffix from a list of
# source directories to a target file. The target file is the first
# argument; suffix the second; and source directories the remaining,
# searched in the given order in the list. Atomicity of the write to 
# the target file is given by appending file contents to a tempfile
# before moving to the target file.
cat_via_tempfile() {
    local generated_file="$1"
    local filter_suffix="$2"
    shift 2
    local source_dirs="$@"
    local staged_file="$(mktemp --tmpdir="${tempfile_dir}" "${tempfile_template}")"
    for source_dir in ${source_dirs[@]}; do
        # Ignore stderr, and let the command succeed if no files are
        # found in the source directory.
        cat "${source_dir}"/*"$filter_suffix" 2>/dev/null >> "${staged_file}" || :
    done
    ${mv_Z} "${staged_file}" "${generated_file}"
}

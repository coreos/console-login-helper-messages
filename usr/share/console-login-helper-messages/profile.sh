# Print count of failed systemd units for interactive shells
# Originally from https://github.com/coreos/baselayout/blob/master/baselayout/coreos-profile.sh

# Only print for interactive shells.
if [[ $- == *i* ]]; then
    # If not using systemd, return.
    if ! grep -q 'systemd' /proc/1/stat; then
        return 0
    fi

    FAILED=$(systemctl list-units --state=failed --no-legend --plain)

    if [[ ! -z "${FAILED}" ]]; then
        COUNT=$(wc -l <<<"${FAILED}")
        # output to stderr since it belongs better there but also in case
        # something automated brokenly starts an interactive ssh session to
        # capture output...
        echo "[systemd]" 1>&2
        echo -e "Failed Units: \033[31m${COUNT}\033[39m" 1>&2
        awk '{ print "  " $1 }' <<<"${FAILED}" 1>&2
    fi
fi

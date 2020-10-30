# /usr/share/console-login-helper-messages/profile.sh

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
        echo "[systemd]"
        echo -e "Failed Units: \033[31m${COUNT}\033[39m"
        awk '{ print "  " $1 }' <<<"${FAILED}"
    fi
fi

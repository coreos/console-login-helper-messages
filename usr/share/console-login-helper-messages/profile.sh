# /usr/share/console-login-helper-messages/console-login-helper-messages-profile.sh

# Only print for interactive shells.
if [[ $- == *i* ]]; then
	FAILED=$(systemctl list-units --state=failed --no-legend)

	if [[ ! -z "${FAILED}" ]]; then
		COUNT=$(wc -l <<<"${FAILED}")
		echo "[systemd]"
		echo -e "Failed Units: \033[31m${COUNT}\033[39m"
		awk '{ print "  " $1 }' <<<"${FAILED}"
	fi
fi

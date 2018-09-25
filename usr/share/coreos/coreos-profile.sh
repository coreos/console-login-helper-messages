# /usr/share/coreos/coreos-profile.sh

# Only print for interactive shells.
if [[ $- == *i* ]]; then

  echo "test: Failed systemd units will show here, if there are any."
  FAILED=$(systemctl list-units --state=failed --no-legend)
  if [[ ! -z "${FAILED}" ]]; then
  	COUNT=$(wc -l <<<"${FAILED}")
  	echo -e "Failed Units: \033[31m${COUNT}\033[39m"
  	awk '{ print "  " $1 }' <<<"${FAILED}"
  fi
fi

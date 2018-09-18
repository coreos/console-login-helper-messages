# ---- deal with SELinux for everything created ----

chcon -u system_u $SCRIPT_DEST
chcon -u system_u $SYSTEMD_UNIT_DEST
chcon -u system_u $ETC_DEST
chcon -u system_u $RUN_DEST
chcon -u system_u $USRLIB_DEST
chcon -u system_u $USRLIB_DEST/motd.d
# chcon -u system_u $USRLIB_DEST/issue.d

# chcon -u system_u $SYSTEMD_UNIT_DEST/issuegen.service
chcon -u system_u $SYSTEMD_UNIT_DEST/motdgen.service
chcon -u system_u $SYSTEMD_UNIT_DEST/motdgen.path
# chcon -u system_u $SCRIPT_DEST/issuegen
chcon -u system_u $SCRIPT_DEST/motdgen

chcon -u system_u $USRLIB_DEST/motd
chcon -u system_u $USRLIB_DEST/motd.d/test.motd

chcon -h -u system_u $ETC_DEST/motd
chcon -h -u system_u $ETC_DEST/motd.d
# chcon -h -u system_u $ETC_DEST/issue
# chcon -h -u system_u $ETC_DEST/issue.d

chcon -h -u system_u $RUN_DEST/motd
chcon -h -u system_u $RUN_DEST/motd.d
# chcon -h -u system_u $RUN_DEST/issue
# chcon -h -u system_u $RUN_DEST/issue.d

# ---- get things ready for motdgen/issuegen ----

if [ -h "$RUN_DEST/motd" ]
then
  echo "Removing run/motd symlink"
  rm $RUN_DEST/motd
  touch /run/motd
  chcon -u system_u $RUN_DEST/motd
fi
if [ -h "$RUN_DEST/motd.d" ]
then
  echo "Removing run/motd.d symlink"
  rm $RUN_DEST/motd.d
  mkdir -p $RUN_DEST/motd.d
  chcon -u system_u $RUN_DEST/motd.d
  touch $RUN_DEST/motd.d/test-info.motd
  chcon -u system_u $RUN_DEST/motd.d/test-info.motd
fi
# same for issue here

# --- start services ----

systemctl daemon-reload
systemctl start motdgen.service
# systemctl start issuegen.service

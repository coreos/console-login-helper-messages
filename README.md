# fedora-user-messages

`issue/motd` mechanism for Fedora-based distributions and possibly others

## Installation

1. Load up a VM with RHCOS, FCOS, fedora/28-atomic-host, fedora/28-cloud-base...
2. SSH in and log in as root, `sudo su`
3. Do the following (using rpm-ostree or dnf depending on your system):

```
# curl --remote-name-all https://kojipkgs.fedoraproject.org//work/tasks/3368/30013368/fedora-user-messages-0.1-1.fc28.noarch.rpm https://kojipkgs.fedoraproject.org//work/tasks/3368/30013368/fedora-user-messages-issuegen-0.1-1.fc28.noarch.rpm https://kojipkgs.fedoraproject.org//work/tasks/3368/30013368/fedora-user-messages-motdgen-0.1-1.fc28.noarch.rpm https://kojipkgs.fedoraproject.org//work/tasks/3368/30013368/fedora-user-messages-profile-0.1-1.fc28.noarch.rpm
# rpm-ostree install fedora-user-messages-*
# systemctl reboot
```

4. SSH back in

5. Configure PAM (version >= 1.3.1) to look in `/etc/motd.d`:

    Edit `/etc/pam.d/sshd` to have line `session    optional     pam_motd.so` (if it does not already have it). It should look like the following:

    `/etc/pam.d/sshd`
    
        #%PAM-1.0
        auth       substack     password-auth
        auth       include      postlogin
        account    required     pam_sepermit.so
        account    required     pam_nologin.so
        account    include      password-auth
        password   include      password-auth
        # pam_selinux.so close should be the first session rule
        session    required     pam_selinux.so close
        session    required     pam_loginuid.so
        # pam_selinux.so open should only be followed by sessions to be executed in the user context
        session    required     pam_selinux.so open env_params
        session    required     pam_namespace.so
        session    optional     pam_keyinit.so force revoke
        session    optional     pam_motd.so
        session    include      password-auth
        session    include      postlogin

6. Enable the units and restart.

```
# systemctl enable motdgen.service motdgen.path issuegen.service issuegen.path
# systemctl reboot
```

7. The updated issue should show in serial console.

**problem with motd**: appears the symlink created in `/etc/motd.d` is not being followed by PAM on startup. Need to check if cockpit did anything to make it work on their end.

## Operation

Let `x` denote `{motd,issue}`.

- Symlinks from `/etc/x.d/fedora-user-messages.x` to `/run/fedora-user-messages.x` are set by `systemd-tmpfiles`.
- `issuegen` and `motdgen` generate `/run/fedora-user-messages.x`, from files in `/run/fedora-user-messages/x.d`, `/lib/usr/coreos/x.d`.
- Users may add their own `issue`s or `motd`s by placing files in `/etc/x.d/`, which is a feature already provided by Fedora 29.
- Users may also drop files into `/etc/fedora-user-messages/x.d` to have the issuegen/motdgen services append their files to the generated `x`.

## Next steps
- [x] account for issue in install.sh (for testing)
- [x] script to enable the systemd units and reboot (for testing)
- [x] script to configure PAM (for testing)
    - no script; make it a responsibility of the user, not of the package installer. therefore PAM doesn't need to be a dependency
- [x] make systemd-tmpfiles config to create symlinks
    - rpm installation can also set up symlinks, but it should be a responsibility of systemd to keep the symlinks maintained (user can easily override by placing config in /etc/\*.conf acting on top of /usr/lib/\*.conf)
- [x] wrap everything up with rpm spec file (includes gen scripts, tmpfiles config, systemd units)
- [x] show systemd failed units, or find out where this is currently being done https://github.com/coreos/init/commit/5e82c6bf46d746545281a219ce82af57e950f026#diff-892b6c24ac66bd41b13adeaeb077da83
- [x] still allow dropping files into `/etc/fedora-user-messages/x.d/`
- [ ] testing that the info we need shows in RHCOS
  - [ ] a "you should not be sshing into this OS" message in motd **[coreos specific]**
  - [ ] a "dev info" message (motd and issue) **[coreos specific]**
  - [x] ssh keys in issue and motd (NOTE: ssh-keygen functionality will not be handled here)
  - [x] added users in issue and motd
  - [x] ip address in issue
  - [x] some info  on updates (booting, pending, etc) from rpm-ostree status --json? in motd (db, upgrade, status, version) (see https://github.com/rtnpro/motdgen/blob/master/motdgen-cache-updateinfo)
  - [x] failed units on login
- [ ] check installation against RHCOS and FCOS
- [ ] ensure licensing is correct
- [ ] %check
- [ ] tidy up code, comments
- [ ] user manual (brief)

## Issues to figure out

- [x] How to manage files existing at /etc/motd and /etc/issue before installing? If they exist, this causes problems when installing if they are included under `%files` as part of the coreos-ux package. The symlinks `/etc/motd -> /etc/run` and `/etc/issue -> /run/issue` do not get created if they exist.
    - Do not change `/etc/x` symlinks - have a symlink to the generated file in `/etc/x.d/fedora-user-messages.x`. Cockpit currently places `cockpit.issue` in `/etc/issue.d/` (see "Files" in https://rpmfind.net/linux/RPM/fedora/devel/rawhide/x86_64/c/cockpit-ws-178-1.fc30.x86_64.html) This is because `/etc/x` is owned by fedora-release, and we should not change this.
- [x] After a system update, how do motd/issue source the updated info? Possibly add a PathChanged to the appropriate system/\*.path unit file, so that motd and issue can update. Also call rpm-ostree/dnf whenever issuegen/motdgen is run.
- [x] How to make sure issuegen.* and motdgen.* are enabled (i.e. run every boot, and whenever something is dropped into a motd.d/issue.d) after installing? Done in `%post`? `WantedBy` a `.target` required? Or is this done by preset config? Done by WantedBy user.target (the default target for Fedora).
- [ ] After installing the rpms generated by `rpm-build.sh` more tmpfiles named `pkg-fedora-user-messages-*.conf` are
created, which include lines to create directories in run; `/run/fedora-user-messages`, `/run/fedora-user-messages/issue.d`, `/run/fedora-user-messages/motd.d`. This clutters up tmpfiles.d (given that this package contains 3 tmpfiles already). May want to consider another something like CL's [baselayout](https://github.com/coreos/baselayout/blob/master/tmpfiles.d/baselayout.conf) rather than have several tmpfiles.
- [x] support `dnf` and `rpm-ostree` when getting data about updates
- [ ] systemd tmpfiles @macros@

## Enhancements for future
- have upstream PAM include the "trying" functionality, use this config rather than symlinks
- have upstream PAM search issue.d with pam_issue.so (rather than agetty, go through one interface - PAM)

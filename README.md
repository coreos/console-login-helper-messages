# console-login-helper-messages

Uses `motd`, `issue`, and `profile` to show helper messages before/at login.

## User manual

The following messages are shown:

- [x] available ssh keys from `/etc/ssh` matching the regex `ssh_host_*_key`, _before_ login as an **issue**
- [x] ip addresses of network interfaces such as `eth0`, _before_ login as an **issue**
- [x] available system updates from rpm-ostree or dnf, _at_ login as a **motd**
- [x] failed systemd units, _at_ login as a bash **profile** script

How to use:

Let `x` denote `{motd,issue}`.

- `x`gen scripts source files from `/etc/console-login-helper-messages/x.d`, `/run/console-login-helper-messages/x.d`, and `/usr/lib/console-login-helper-messages/x.d`, and generate a file at `/run/x.d/40_console-login-helper-messages.x`
- A symlink `/etc/issue.d/console-login-helper-messages.issue -> /run/issue.d/console-login-helper-messages.issue` is created as agetty will only look for files in `/etc/issue.d` as of today, so a symlink to the generated one is required
- Users may continue to add their own `x`s by placing files in `/etc/x.d/`
- Users may also drop files into `/etc/console-login-helper-messages/x.d/` to have the `x`gen services append their files to the generated `x`. This is to preserve Container Linux functionality where appending messages to the overall generated message was available, not just placing a file into a public directory then searched by programs like PAM/sshd and agetty.

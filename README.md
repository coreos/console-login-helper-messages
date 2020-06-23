# console-login-helper-messages

Shows helper messages at or before login using `motd`, `issue`, and `profile`.

Useful in situations where a desktop environment is not available and information is communicated through the terminal.

## Messages shown

The following messages will show before or upon login after installing `console-login-helper-messages` and enabling the needed units (see [manual](manual.md)).

- issuegen:
    - [x] available ssh keys from `/etc/ssh`
    - [x] ip addresses of network interfaces to SSH into
- motdgen:
    - [x] system information from `/etc/os-release`
- profile:
    - [x] failed systemd units

### Example

Before login (serial console):

```
SSH host key: SHA256:yP+/44/bfuj6UKHdUwAVURsO3y6haKLKfSFNcnmn7bY (ECDSA)
SSH host key: SHA256:gGDZ/JQzwL76UpT29dyZ/M6Zua7QvGyegP8aTLc/D+Y (DSA)
SSH host key: SHA256:nQEysCYP3hZgkus2+e28KQGrs0pRI2NOgJGQ6L8PnyU (RSA)
SSH host key: SHA256:A3c6toZ3/eTMKNDmyyG9CYUSWsdSunmTeOC68iuDfAg (ED25519)
eth0: 192.168.122.36 fe80::5054:ff:fe85:43a6
```

At login:

```
Fedora (29 (Cloud Edition))
[systemd]
Failed Units: 1
    var-srv.mount
```

## Customizing

The motd/issue messages are defaults and can be disabled following the [manual](manual.md#Disabling-messages).

Messages can be appended to the motd or issue, by placing
files in the directories sourced by motdgen/issuegen to generate
the message (see [manual](manual.md#Appending-messages)).

## Building

The included `build_rpm.sh` script will archive the current checked out
commit in the upstream repo, clone the downstream Fedora SCM repo,
and build the RPM with the archived source, within a container.
Built RPM artifacts can be found in `./build/console-login-helper-messages/rpms`.
The built RPMs can then be installed into an RPM-based distribution,
to test, e.g. Fedora Cloud.

Note if the `make` command gives `Permission denied`, it may be
due to SELinux. TO fix this, the type `container_file_t` should be
given on this repository if using the build workflow below, which
can be done with `chcon -R -t container_file_t ./`.

```
# First build the container image used to build console-login-helper-messages
podman build . -t console-login-helper-messages

./build_rpm.sh
```

To remove the previous RPMs and build a fresh set, do:

```
./clean_rpm.sh && ./build_rpm.sh
```

### Building (without container)

To build without using a container, execute:

```
make rpm
```

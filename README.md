[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub Release](https://img.shields.io/github/release/coreos/console-login-helper-messages/all.svg)](https://github.com/coreos/console-login-helper-messages/releases/) 

# console-login-helper-messages

Shows helper messages at or before login using `motd`, `issue`, and `profile`.

Useful in situations where a desktop environment is not available and information is communicated through the terminal.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Messages shown](#messages-shown)
  - [Example](#example)
- [Installation](#installation)
- [Customizing](#customizing)
- [Development](#development)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Messages shown

The following messages will show before or upon login after installing `console-login-helper-messages` and enabling the needed units (see [manual](doc/manual.md)).

- issuegen:
  - SSH keys (before login)
  - Network interface information (before login)
- motdgen:
  - OS release information (at login)
- profile:
  - Failed systemd units (at login)

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

## Installation

See the [manual](doc/manual.md#Installation).

To verify working package functionality manually (for now), see the
[reviewers](doc/reviewers.md) doc.

## Customizing

The motd/issue messages are defaults and can be disabled following the [manual](doc/manual.md#Disabling-messages).
## Development

For information on contributing and testing changes in a virtual
machine, see the [development README](doc/development.md).

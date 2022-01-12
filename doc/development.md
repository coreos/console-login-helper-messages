# console-login-helper-messages - development

The below sections include information on editing the
console-login-helper-messages source files and testing changes.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Building a development container](#building-a-development-container)
- [Installing executables and systemd units](#installing-executables-and-systemd-units)
- [Testing changes in a virtual machine](#testing-changes-in-a-virtual-machine)
- [Building RPMs from Fedora SCM](#building-rpms-from-fedora-scm)
  - [Building RPMs (without container)](#building-rpms-without-container)
- [Testing RPM builds in a VM](#testing-rpm-builds-in-a-vm)
- [Kola tests](#kola-tests)
  - [Building a FCOS image with the new changes using CoreOS Assembler `build-fast`](#building-a-fcos-image-with-the-new-changes-using-coreos-assembler-build-fast)
  - [Building a FCOS image with the new changes using CoreOS Assembler overrides](#building-a-fcos-image-with-the-new-changes-using-coreos-assembler-overrides)
  - [Running the tests](#running-the-tests)
  - [Adding Kola tests](#adding-kola-tests)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

To get started, the suggested workflow is first to [build the development container](#building-a-development-container)
and then to iterate following [Testing changes in a virtual machine](#testing-changes-in-a-virtual-machine).
Running the VM with the provided scripts requires `libguestfs-tools-c`
and `qemu-kvm` installed.

## Building a development container

Before running scripts in the sections below, run the following command
to build the development container, which includes necessary
dependencies such as `make`.

```
podman build . -t console-login-helper-messages
```

## Installing executables and systemd units

To install `console-login-helper-messages` and associated systemd units,
run `make install DESTDIR=<write destination directory here>`. This can
also be done in a container, see [sync_to_vm.sh](../hack/sync_to_vm.sh).

## Testing changes in a virtual machine

First, start a VM with (after downloading a `.qcow2`, `.img`, or `.raw`
image suitable for testing):

```
./hack/run_vm.sh path/to/image.qcow2
```

Note if the `make` command gives `Permission denied`, it may be
due to SELinux. TO fix this, the type `container_file_t` should be
given on this repository if using the build workflow below, which
can be done with `chcon -R -t container_file_t ./`.

A suggested image for iteration is the [Fedora Cloud Base](https://alt.fedoraproject.org/cloud/)
image.

Next, in another terminal window, run the following to sync current
local source files to the VM. You can then SSH with the command
outputted by the script. To iterate with new changes, the script can be
run repeatedly.

```
./hack/sync_to_vm.sh
```

## Building RPMs from Fedora SCM

**Note**: the recommended development flow for faster iteration is using
`make install` described in the sections above. The specfile in Fedora
SCM may also be out of date, e.g. if the main branch of the upstream
repository added files that haven't been declared in the specfile.

The included `build_rpm.sh` script will archive the current checked out
commit in the upstream repo, clone the downstream Fedora SCM repo,
and build the RPM with the archived source, within a container.
Built RPM artifacts can be found in `./build/console-login-helper-messages/rpms`.
The built RPMs can then be installed into an RPM-based distribution,
to test, e.g. Fedora Cloud.


```
./hack/build_rpm.sh
```

To remove the previous RPMs and build a fresh set, do:

```
cd hack/
./clean_rpm.sh && ./build_rpm.sh
```

### Building RPMs (without container)

To build the RPM without using a container, execute:

```
make rpm
```

## Testing RPM builds in a VM

`./run_vm.sh` will provision a VM image (`.qcow2` or `.raw`) passed as
the first argument, and start up a VM which you can SSH into. After
running `./run_vm.sh`, run `./install_vm_rpms.sh` to install the last
built RPMs from `./build_rpm.sh` in the VM. You can then SSH into the
machine using the details that `./install_vm_rpms.sh` outputs to the
terminal.

```
cd hack/
./clean_rpm.sh && ./build_rpm.sh
./run_vm.sh path/to/image.qcow2
./install_vm_rpms.sh
```

To iterate while the VM is running, after committing changes locally:

```
cd hack/
./clean_rpm.sh && ./build_rpm.sh && ./install_vm_rpms.sh
```

## Kola tests

#### Building a FCOS image with the new changes using CoreOS Assembler `build-fast`
Please refer to the CoreOS Assembler's
[Kola external tests README](https://github.com/coreos/coreos-assembler/blob/main/mantle/kola/README-kola-ext.md#fast-build-and-iteration-on-your-projects-tests)
for instructions on fast-building a qemu image for testing.

#### Building a FCOS image with the new changes using CoreOS Assembler overrides

Please refer to the CoreOS Assembler
[README](https://github.com/coreos/coreos-assembler/blob/main/README.md#getting-started---prerequisites)
and [README-devel](https://github.com/coreos/coreos-assembler/blob/main/README-devel.md#using-overrides)
for the most up-to-date instructions on how to build a FCOS image and use
overrides, respectively.

We can set `DESTDIR=` in `make install` to be the `overrides/rootfs` directory
in a FCOS configuration repository to build a FCOS image that contains the new
changes to console-login-helper-messages.

#### Enabling new systemd units (if necessary)

Make sure that all of console-login-helper-messages' systemd units are enabled.

For example, if the new changes involve adding a new systemd unit
`console-login-helper-messages-new-unit.service`, then add the line
```
enable console-login-helper-messages-new-unit.service
```
in the FCOS configuration repository's systemd system-preset files, specifically
https://github.com/coreos/fedora-coreos-config/blob/testing-devel/overlay.d/05core/usr/lib/systemd/system-preset/40-coreos.preset.

#### Running the tests

It is possible to run external Kola tests by specifying the path to the tests'
location and which tests to run, using `kola run`'s `-E` option.

Example (run all tests):
```
cosa kola run -p qemu --qemu-image path/to/qcow2 -E /path/to/console-login-helper-messages/ 'ext.console-login-helper-messages.*'
```

Example (run only the basic tests):
```
cosa kola run -p qemu --qemu-image path/to/qcow2 -E /path/to/console-login-helper-messages/ 'ext.console-login-helper-messages.basic.*'
```

More detailed and up-to-date information can be found in the
Kola external tests' [README](https://github.com/coreos/coreos-assembler/blob/master/mantle/kola/README-kola-ext.md).

#### Adding Kola tests
Please refer to the CoreOS Assembler's
[Kola external tests README](https://github.com/coreos/coreos-assembler/blob/master/mantle/kola/README-kola-ext.md#quick-start)
for instructions on adding additional tests.

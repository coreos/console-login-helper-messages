# console-login-helper-messages - development

The below sections include information on editing the
console-login-helper-messages source files and testing changes. To get
started, the suggested workflow is first to
[build the development container](README.md#building-a-development-container)
and then to iterate following [Testing changes in a virtual machine](README.md#testing-changes-in-a-virtual-machine).

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
also be done in a container, see [sync_to_vm.sh](sync_to_vm.sh).

## Testing changes in a virtual machine

First, start a VM with (after downloading a `.qcow2`, `.img`, or `.raw`
image suitable for testing):

```
./run_vm.sh path/to/image.qcow2
```

A suggested image for iteration is the [Fedora Cloud Base](https://alt.fedoraproject.org/cloud/)
image.

Next, in another terminal window, run the following to sync current
local source files to the VM. You can then SSH with the command
outputted by the script. To iterate with new changes, the script can be
run repeatedly.

```
./sync_to_vm.sh
```

## Building RPMs from Fedora SCM

**Note**: the recommended development flow for faster iteration is using
`make install` described in the sections above. The specfile in Fedora
SCM may also be out of date, e.g. if the master branch of the upstream
repository added files that haven't been declared in the specfile.

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
./build_rpm.sh
```

To remove the previous RPMs and build a fresh set, do:

```
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
./clean_rpm.sh && ./build_rpm.sh
./run_vm.sh path/to/image.qcow2
./install_vm_rpms.sh
```

To iterate while the VM is running, after committing changes locally:

```
./clean_rpm.sh && ./build_rpm.sh && ./install_vm_rpms.sh
```

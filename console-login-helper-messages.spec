%global github_owner    rfairley
%global github_project  console-login-helper-messages

Name:           console-login-helper-messages
Version:        0.16
Release:        1%{?dist}
Summary:        Combines motd, issue, profile features to show system information to the user before/on login
License:        BSD
URL:            https://github.com/%{github_owner}/%{github_project}
Source0:        https://github.com/%{github_owner}/%{github_project}/archive/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  systemd
%{?systemd_requires}
Requires:       bash systemd

%description
%{summary}.

%package motdgen
Summary:        Message of the day generator script showing system information
Requires:       console-login-helper-messages
# sshd reads /run/motd.d, where the generated MOTD message is written.
Recommends:     openssh
# bash: bash scripts are included in this package
# systemd: systemd service and path units, and querying for failed units
# (the above applies to the issuegen and profile subpackages too)
Requires:       bash systemd
# setup: filesystem paths need setting up
#   * https://pagure.io/setup/pull-request/14
#   * https://pagure.io/setup/pull-request/15
# Make exception for fc29 - soft requires as we will create /run/motd.d
# ourselves using tmpfiles if it doesn't already exist.
%if 0%{?fc29}
Requires:       setup
%else
Requires:       setup >= 2.12.7-1
%endif
# pam: Needed to display issues symlinked from /etc/motd.d.
#   * https://github.com/linux-pam/linux-pam/issues/47
Requires:       ((pam >= 1.3.1-15) if openssh)
# selinux-policy: to apply pam_var_run_t contexts:
#   * https://github.com/fedora-selinux/selinux-policy/pull/244
# Make exception for fc29, as PAM will create the tmpfiles. (In Fedora 30 and
# above, setup is responsible for this).
%if 0%{?fc29}
Requires:       ((selinux-policy >= 3.14.2-50) if openssh)
%else
Requires:       ((selinux-policy >= 3.14.3-23) if openssh)
%endif

%description motdgen
%{summary}.

%package issuegen
Summary:        Issue generator script showing SSH keys and IP address
Requires:       console-login-helper-messages
Requires:       bash systemd setup
# systemd-udev: for udev rules
Requires:       systemd-udev
# fedora-release: for /etc/issue.d path
#   * https://src.fedoraproject.org/rpms/fedora-release/pull-request/64#
Requires:       fedora-release
# TODO: add a requires for redhat-release-coreos once merged
#   * https://github.com/openshift/redhat-release-coreos/pull/18
# Requires:       redhat-release-coreos
# agetty is included in util-linux, which searches /etc/issue.d.
# Needed to display issues symlinked from /etc/issue.d.
#   * https://github.com/karelzak/util-linux/commit/37ae6191f7c5686f1f9a2c3984e2cd9a62764029#diff-15eca7082c3cb16e5ac467f4acceb9d0R54
#   * https://github.com/karelzak/util-linux/commit/1fc82a1360305f696dc1be6105c9c56a9ea03f52#diff-d7efd2b3dbb10e54185f001dc21d43db
Requires:       util-linux >= 2.32-1

%description issuegen
%{summary}.

%package profile
Summary:        Profile script showing systemd failed units
Requires:       console-login-helper-messages
Requires:       bash systemd setup

%description profile
%{summary}.

%prep
%setup -q

%build

%install

# Vendor-scoped directories
mkdir -p %{buildroot}%{_prefix}/lib/%{name}/issue.d
mkdir -p %{buildroot}%{_prefix}/lib/%{name}/motd.d
mkdir -p %{buildroot}/run/%{name}/issue.d
mkdir -p %{buildroot}/run/%{name}/motd.d
mkdir -p %{buildroot}%{_prefix}/share/%{name}
mkdir -p %{buildroot}%{_sysconfdir}/%{name}/issue.d
mkdir -p %{buildroot}%{_sysconfdir}/%{name}/motd.d

# External directories
mkdir -p %{buildroot}%{_sysconfdir}/issue.d
mkdir -p %{buildroot}%{_sysconfdir}/motd.d
mkdir -p %{buildroot}%{_sysconfdir}/profile.d
mkdir -p %{buildroot}%{_unitdir}
mkdir -p %{buildroot}%{_tmpfilesdir}
mkdir -p %{buildroot}%{_prefix}/lib/udev/rules.d

# issuegen files
install -DpZm 0644 usr/lib/systemd/system/%{name}-issuegen.path %{buildroot}%{_unitdir}/%{name}-issuegen.path
install -DpZm 0644 usr/lib/systemd/system/%{name}-issuegen.service %{buildroot}%{_unitdir}/%{name}-issuegen.service
install -DpZm 0644 usr/lib/tmpfiles.d/%{name}-issuegen-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/%{name}-issuegen.conf
install -DpZm 0644 usr/lib/udev/rules.d/90-%{name}-issuegen.rules %{buildroot}%{_prefix}/lib/udev/rules.d/90-%{name}-issuegen.rules
install -DpZm 0755 usr/lib/%{name}/issuegen %{buildroot}%{_libexecdir}/%{name}/issuegen

# motdgen files
install -DpZm 0644 usr/lib/systemd/system/%{name}-motdgen.path %{buildroot}%{_unitdir}/%{name}-motdgen.path
install -DpZm 0644 usr/lib/systemd/system/%{name}-motdgen.service %{buildroot}%{_unitdir}/%{name}-motdgen.service
install -DpZm 0644 usr/lib/tmpfiles.d/%{name}-motdgen-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/%{name}-motdgen.conf
install -DpZm 0755 usr/lib/%{name}/motdgen %{buildroot}%{_libexecdir}/%{name}/motdgen

# profile files
install -DpZm 0644 usr/lib/tmpfiles.d/%{name}-profile-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/%{name}-profile.conf
install -DpZm 0755 usr/share/%{name}/profile.sh %{buildroot}%{_prefix}/share/%{name}/profile.sh

# symlinks
ln -snf /run/%{name}/%{name}.issue %{buildroot}%{_sysconfdir}/issue.d/%{name}.issue
ln -snf %{_prefix}/share/%{name}/profile.sh %{buildroot}%{_sysconfdir}/profile.d/%{name}-profile.sh
ln -snf /run/%{name}/%{name}.motd %{buildroot}%{_sysconfdir}/motd.d/%{name}.motd

%pre
# TODO: use tmpfiles_create_package macro for tmpfiles

%post
%systemd_post %{name}-issuegen.path
%systemd_post %{name}-issuegen.service
%systemd_post %{name}-motdgen.path
%systemd_post %{name}-motdgen.service

%preun
%systemd_preun %{name}-issuegen.path
%systemd_preun %{name}-issuegen.service
%systemd_preun %{name}-motdgen.path
%systemd_preun %{name}-motdgen.service

%postun
%systemd_postun_with_restart %{name}-issuegen.path
%systemd_postun_with_restart %{name}-issuegen.service
%systemd_postun_with_restart %{name}-motdgen.path
%systemd_postun_with_restart %{name}-motdgen.service

# TODO: %check

%files
%doc README.md
%license LICENSE
%dir %{_libexecdir}/%{name}
%dir %{_prefix}/lib/%{name}
%dir /run/%{name}
%dir %{_prefix}/share/%{name}
%dir %{_sysconfdir}/%{name}

%files issuegen
%{_unitdir}/%{name}-issuegen.path
%{_unitdir}/%{name}-issuegen.service
%{_tmpfilesdir}/%{name}-issuegen.conf
%{_prefix}/lib/udev/rules.d/90-%{name}-issuegen.rules
%{_libexecdir}/%{name}/issuegen
%dir %{_prefix}/lib/%{name}/issue.d
%dir /run/%{name}/issue.d
%{_sysconfdir}/issue.d/%{name}.issue
%dir %{_sysconfdir}/%{name}/issue.d

%files motdgen
%{_unitdir}/%{name}-motdgen.path
%{_unitdir}/%{name}-motdgen.service
%{_tmpfilesdir}/%{name}-motdgen.conf
%{_libexecdir}/%{name}/motdgen
%dir %{_prefix}/lib/%{name}/motd.d
%dir /run/%{name}/motd.d
%{_sysconfdir}/motd.d/%{name}.motd
%dir %{_sysconfdir}/%{name}/motd.d

%files profile
%{_prefix}/share/%{name}/profile.sh
%{_tmpfilesdir}/%{name}-profile.conf
%{_sysconfdir}/profile.d/%{name}-profile.sh

%changelog
* Thu Mar 21 2019 Robert Fairley <rfairley@redhat.com> - 0.16-1
- relax setup dependency for f29
- upstream source improvements
- house executable scripts in /usr/libexec
- go back to using symlink for motdgen
- change Source0 to use GitHub-generated archive link

* Fri Mar 15 2019 Robert Fairley <rfairley@redhat.com> - 0.15-1
- make motdgen generate motd in /run with no symlink

* Fri Mar 15 2019 Robert Fairley <rfairley@redhat.com> - 0.14-1
- issuegen.service: rely on sshd-keygen.target
- issuegen: don't show kernel version

* Thu Jan 24 2019 Robert Fairley <rfairley@redhat.com> - 0.13-4
- update reviewers.md and manual.md with correct paths

* Wed Jan 23 2019 Robert Fairley <rfairley@redhat.com> - 0.13-3
- change generated issue to be scoped in private directory

* Wed Jan 23 2019 Robert Fairley <rfairley@redhat.com> - 0.13-2
- change generated motd to be scoped in private directory

* Wed Jan 23 2019 Robert Fairley <rfairley@redhat.com> - 0.13-1
- add a symlink for motdgen (quick solution until upstream pam_motd.so changes propagate)

* Fri Jan 18 2019 Robert Fairley <rfairley@redhat.com> - 0.12-2
- fix Requires for selinux-policy, add missing Requires for systemd-udev and fedora-release

* Wed Jan 16 2019 Robert Fairley <rfairley@redhat.com> - 0.12-1
- fix specfile Source0 to correct github URL

* Wed Jan 16 2019 Robert Fairley <rfairley@redhat.com> - 0.11-1
- add reviewers.md, specfile fixes

* Wed Jan 16 2019 Robert Fairley <rfairley@redhat.com> - 0.1-12
- add move README.md sections out into a manual, update specfile

* Wed Jan 09 2019 Robert Fairley <rfairley@redhat.com> - 0.1-11
- specfile cleanup, go through git commit history to write changelog

* Wed Jan 09 2019 Robert Fairley <rfairley@redhat.com> - 0.1-10
- Add license, tidyups

* Mon Dec 10 2018 Robert Fairley <rfairley@redhat.com> - 0.1-9
- Add tmpfiles_create_package usage to reproduce coredump

* Mon Dec 10 2018 Robert Fairley <rfairley@redhat.com> - 0.1-8
- Remove tmpfiles_create_package usage

* Mon Dec 10 2018 Robert Fairley <rfairley@redhat.com> - 0.1-7
- Fix usage of tmpfiles_create_package macro in specfile

* Fri Dec 07 2018 Robert Fairley <rfairley@redhat.com> - 0.1-6
- Fix tmpfile symlink paths

* Fri Dec 07 2018 Robert Fairley <rfairley@redhat.com> - 0.1-5
- Add [systemd] label to failed units message in profile script

* Tue Dec 04 2018 Robert Fairley <rfairley@redhat.com> - 0.1-4
- Minor formatting edits to generated issue and motd

* Tue Dec 04 2018 Robert Fairley <rfairley@redhat.com> - 0.1-3
- Remove printing package manager info (rpm-ostree, dnf)

* Tue Dec 04 2018 Robert Fairley <rfairley@redhat.com> - 0.1-2
- Add CI with copr
- Drop requirement on specifc SELinux version
- Various tidyups including filenames

* Tue Sep 25 2018 Robert Fairley <rfairley@redhat.com> - 0.1-1
- Initial Package

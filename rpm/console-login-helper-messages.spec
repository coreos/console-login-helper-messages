%global github_owner    coreos
%global github_project  console-login-helper-messages

Name:           console-login-helper-messages
Version:        0.22.0
Release:        1%{?dist}
Summary:        Combines motd, issue, profile features to show system information to the user before/on login
License:        BSD-3-Clause
URL:            https://github.com/%{github_owner}/%{github_project}
Source0:        https://github.com/%{github_owner}/%{github_project}/archive/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  systemd make
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
# systemd: systemd service units, and querying for failed units
# (the above applies to the issuegen and profile subpackages too)
Requires:       bash systemd
# setup: filesystem paths need setting up.
#   * https://pagure.io/setup/pull-request/14
#   * https://pagure.io/setup/pull-request/15
#   * https://pagure.io/setup/pull-request/16
Requires:       setup >= 2.12.7-1
# pam: to display motds in /run/motd.d.
#   * https://github.com/linux-pam/linux-pam/issues/47
#   * https://github.com/linux-pam/linux-pam/pull/69
#   * https://github.com/linux-pam/linux-pam/pull/76
Requires:       ((pam >= 1.3.1-15) if openssh)
# selinux-policy: to apply pam_var_run_t contexts:
#   * https://github.com/fedora-selinux/selinux-policy/pull/244
Requires:       ((selinux-policy >= 3.14.2-50) if openssh)
# Needed to display MOTDs in `/run/motd.d` before upon login through 
# the serial console.
Requires:       util-linux >= 2.36-1

%description motdgen
%{summary}.

%package issuegen
Summary:        Issue generator scripts showing SSH keys and IP address
Requires:       console-login-helper-messages
Requires:       bash systemd setup
# NetworkManager: for displaying IP info using NetworkManager dispatcher script
Requires:       (NetworkManager)
Requires:       /etc/issue.d
# Needed to display issues in /etc/issue.d before login through the serial console.
Requires:       util-linux >= 2.36-1

%description issuegen
%{summary}.

%package profile
Summary:        Profile script showing systemd failed units
Requires:       console-login-helper-messages
Requires:       bash systemd setup

%description profile
%{summary}.

%prep
%autosetup -p1

%build

%install
make install DESTDIR=%{buildroot}
# /run/motd.d is now provided by the setup package on Fedora
rm %{buildroot}/%{_tmpfilesdir}/%{name}-motdgen.conf

%post issuegen
%systemd_post %{name}-gensnippet-ssh-keys.service

%preun issuegen
%systemd_preun %{name}-gensnippet-ssh-keys.service

%postun issuegen
%systemd_postun_with_restart %{name}-gensnippet-ssh-keys.service

%post motdgen
%systemd_post %{name}-gensnippet-os-release.service

%preun motdgen
%systemd_preun %{name}-gensnippet-os-release.service

%postun motdgen
%systemd_postun_with_restart %{name}-gensnippet-os-release.service

# TODO: %%check

%files
%doc README.md
%doc doc/manual.md
%license LICENSE
%dir %{_libexecdir}/%{name}
%dir %{_prefix}/lib/%{name}
%dir %{_prefix}/share/%{name}
%{_prefix}/lib/%{name}/libutil.sh
%{_tmpfilesdir}/%{name}.conf

%files issuegen
%{_unitdir}/%{name}-gensnippet-ssh-keys.service
%{_sysconfdir}/NetworkManager/dispatcher.d/90-%{name}-gensnippet_if
%{_prefix}/lib/%{name}/issue.defs
%{_libexecdir}/%{name}/gensnippet_ssh_keys
%{_libexecdir}/%{name}/gensnippet_if
%{_libexecdir}/%{name}/gensnippet_if_udev

%files motdgen
%{_unitdir}/%{name}-gensnippet-os-release.service
%{_prefix}/lib/%{name}/motd.defs
%{_libexecdir}/%{name}/gensnippet_os_release

%files profile
%{_prefix}/share/%{name}/profile.sh
%{_tmpfilesdir}/%{name}-profile.conf
%ghost %{_sysconfdir}/profile.d/%{name}-profile.sh

%changelog
%autochangelog

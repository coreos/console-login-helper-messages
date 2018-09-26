%global github_owner    rfairley
%global github_project  fedora-coreos-login-messages

# TODO: discuss whether {name} should be used to create directories, and if that name should be "coreos".
#       then this package would become the "base" package, and include any unit files, scripts, configs
#       not necessarily related to ux. For now, "coreos" is used in the install paths below and is
#       independent of the package {name}.
Name:           coreos-ux
Version:        0.1
Release:        1%{?dist}
Summary:        Fedora CoreOS user-experience-related modules (motd, issue, profile)
# TODO: check license
# TODO: finalize URLs below
License:        ASL 2.0
URL:            https://github.com/%{github_owner}/%{github_project}
Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  systemd
%{?systemd_requires}
Requires:       bash
Requires:       systemd

%description
%{summary}.

%package motdgen
Summary:        Message of the day generator for Fedora CoreOS
Requires:       coreos-ux
Requires:       bash
Requires:       systemd
# Note: pam 1.3.1 not needed since not using motd.d feature of pam_motd
Requires:       pam

%description motdgen
%{summary}.

%package issuegen
Summary:        Issue generator for Fedora CoreOS
Requires:       coreos-ux
Requires:       bash
Requires:       systemd
Requires:       util-linux

%description issuegen
%{summary}.

%package profile
Summary:        Profile script for Fedora CoreOS
Requires:       coreos-ux
Requires:       bash
Requires:       systemd

%description profile
%{summary}.

%prep
%setup -q

%build

%install

# Vendor-scoped directories
mkdir -p %{buildroot}%{_prefix}/lib/coreos/issue.d
mkdir -p %{buildroot}%{_prefix}/lib/coreos/motd.d
mkdir -p %{buildroot}/run/coreos/issue.d
mkdir -p %{buildroot}/run/coreos/motd.d
mkdir -p %{buildroot}%{_sysconfdir}/coreos/issue.d
mkdir -p %{buildroot}%{_sysconfdir}/coreos/motd.d
mkdir -p %{buildroot}%{_prefix}/share/coreos

# External directories
mkdir -p %{buildroot}%{_unitdir}
mkdir -p %{buildroot}%{_tmpfilesdir}
mkdir -p %{buildroot}%{_prefix}/lib/udev/rules.d

install -DpZm 0644 usr/lib/systemd/system/issuegen.path %{buildroot}%{_unitdir}/issuegen.path
install -DpZm 0644 usr/lib/systemd/system/issuegen.service %{buildroot}%{_unitdir}/issuegen.service
install -DpZm 0644 usr/lib/tmpfiles.d/issuegen-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/issuegen.conf
install -DpZm 0644 usr/lib/systemd/system/motdgen.path %{buildroot}%{_unitdir}/motdgen.path
install -DpZm 0644 usr/lib/systemd/system/motdgen.service %{buildroot}%{_unitdir}/motdgen.service
install -DpZm 0644 usr/lib/tmpfiles.d/motdgen-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/motdgen.conf
install -DpZm 0644 usr/lib/udev/rules.d/91-issuegen.rules %{buildroot}%{_prefix}/lib/udev/rules.d/91-issuegen.rules

install -DpZm 0755 usr/lib/coreos/issuegen %{buildroot}%{_prefix}/lib/coreos/issuegen
install -DpZm 0644 usr/lib/coreos/issue.d/* %{buildroot}%{_prefix}/lib/coreos/issue.d
install -DpZm 0755 usr/lib/coreos/motdgen %{buildroot}%{_prefix}/lib/coreos/motdgen
install -DpZm 0755 usr/share/coreos/coreos-profile.sh %{buildroot}%{_prefix}/share/coreos/coreos-profile.sh
# TODO: below symlink not working with percent{buildroot} prepended to LINK_NAME
ln -snf %{_prefix}/share/coreos/coreos-profile.sh %{_sysconfdir}/profile.d/coreos-profile.sh

# TODO: handle pkg-* being created more nicely
%pre
%tmpfiles_create_package issuegen issuegen-tmpfiles.conf
%tmpfiles_create_package motdgen motdgen-tmpfiles.conf

# TODO: check presets will enable the services in RHCOS
# TODO: can %pre, %post, etc. be specified as e.g. %pre issuegen?
%post
%systemd_post issuegen.path
%systemd_post issuegen.service
%systemd_post motdgen.path
%systemd_post motdgen.service

%preun
%systemd_preun issuegen.path
%systemd_preun issuegen.service
%systemd_preun motdgen.path
%systemd_preun motdgen.service

%postun
%systemd_postun_with_restart issuegen.path
%systemd_postun_with_restart issuegen.service
%systemd_postun_with_restart motdgen.path
%systemd_postun_with_restart motdgen.service

# TODO: %check

%files
%doc README.md
%license LICENSE
%dir %{_prefix}/lib/coreos
%dir /run/coreos
%dir %{_sysconfdir}/coreos
%dir %{_prefix}/share/coreos

%files issuegen
%{_unitdir}/issuegen.path
%{_unitdir}/issuegen.service
%{_tmpfilesdir}/issuegen.conf
%{_prefix}/lib/udev/rules.d/91-issuegen.rules
%{_prefix}/lib/coreos/issuegen
%dir %{_prefix}/lib/coreos/issue.d
%{_prefix}/lib/coreos/issue.d/base.issue
%dir /run/coreos/issue.d
%dir %{_sysconfdir}/coreos/issue.d

%files motdgen
%{_unitdir}/motdgen.path
%{_unitdir}/motdgen.service
%{_tmpfilesdir}/motdgen.conf
%{_prefix}/lib/coreos/motdgen
%dir %{_prefix}/lib/coreos/motd.d
%dir /run/coreos/motd.d
%dir %{_sysconfdir}/coreos/motd.d

%files profile
%{_prefix}/share/coreos/coreos-profile.sh

%changelog
* Tue Sep 25 2018 Robert Fairley <rfairley@redhat.com> - 0.1-1
- Initial Package

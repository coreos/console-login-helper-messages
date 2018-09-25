Name:           coreos-base
Version:        0.1
Release:        1%{?dist}
Summary:        Base scripts, systemd units, rules for Fedora CoreOS

# TODO: decide on Name: and package scope
# TODO: %check

# TODO: check license
License:        ASL 2.0
URL:            https://example.com/%{name}
Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  systemd
%{?systemd_requires}
Requires:       bash
Requires:       systemd

%description
%{summary}.

%package motdgen
Summary:        Message of the day generator files for Fedora CoreOS
Requires:       coreos-base
Requires:       bash
Requires:       systemd
Requires:       pam
# Requires:       pam >= 1.3.1 TODO need this in RHCOS

%description motdgen
%{summary}.

%package issuegen
Summary:        Issue generator files for Fedora CoreOS
Requires:       coreos-base
Requires:       bash
Requires:       systemd
Requires:       util-linux

%description issuegen
%{summary}.

%package profile
Summary:        Profile script for Fedora CoreOS
Requires:       bash
Requires:       systemd

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
mkdir -p %{buildroot}%{_sysconfdir}/%{name}/issue.d
mkdir -p %{buildroot}%{_sysconfdir}/%{name}/motd.d
mkdir -p %{buildroot}%{_prefix}/share/%{name}

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
install -DpZm 0644 usr/lib/tmpfiles.d/coreos-profile-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/coreos-profile.conf

install -DpZm 0755 usr/lib/coreos/issuegen %{buildroot}%{_prefix}/lib/%{name}/issuegen
install -DpZm 0755 usr/lib/coreos/motdgen %{buildroot}%{_prefix}/lib/%{name}/motdgen
install -DpZm 0755 usr/share/coreos/coreos-profile.sh %{buildroot}%{_prefix}/share/%{name}/coreos-profile.sh
install -DpZm 0644 usr/lib/issue.d/* %{buildroot}%{_prefix}/lib/%{name}/issue.d

# TODO: handle pkg-* being created more nicely
# TODO: fix problem with symlink path in tmpfile not necessarily matching %{name}
%pre
%tmpfiles_create_package issuegen issuegen-tmpfiles.conf
%tmpfiles_create_package motdgen motdgen-tmpfiles.conf
%tmpfiles_create_package coreos-profile coreos-profile-tmpfiles.conf

# TODO: check presets will enable the services in RHCOS
# TODO: can %pre, %post, etc. be specified as e.g. %pre issuegen
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

%files
%doc README.md
%license LICENSE
%dir %{_prefix}/lib/%{name}
%dir /run/%{name}
%dir %{_sysconfdir}/%{name}
%dir %{_prefix}/share/%{name}

%files issuegen
%{_unitdir}/issuegen.path
%{_unitdir}/issuegen.service
%{_tmpfilesdir}/issuegen.conf
%{_prefix}/lib/udev/rules.d/91-issuegen.rules
%{_prefix}/lib/%{name}/issuegen
%dir %{_prefix}/lib/%{name}/issue.d
%{_prefix}/lib/%{name}/issue.d/base.issue
%dir /run/%{name}/issue.d
%dir %{_sysconfdir}/%{name}/issue.d

%files motdgen
%{_unitdir}/motdgen.path
%{_unitdir}/motdgen.service
%{_tmpfilesdir}/motdgen.conf
%{_prefix}/lib/%{name}/motdgen
%dir %{_prefix}/lib/%{name}/motd.d
%dir /run/%{name}/motd.d
%dir %{_sysconfdir}/%{name}/motd.d

%files profile
%{_tmpfilesdir}/coreos-profile.conf
%{_prefix}/share/%{name}/coreos-profile.sh

%changelog
* Tue Sep 25 2018 Robert Fairley <rfairley@redhat.com> - 0.1
- Initial Package

%global github_owner    rfairley
%global github_project  console-login-helper-messages

Name:           console-login-helper-messages
Version:        0.1
Release:        1%{?dist}
Summary:        Combines Fedora motd, issue, profile features to show system information to the user
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
Summary:        Message of the day generator
Requires:       console-login-helper-messages
Requires:       bash
Requires:       systemd
# Needed for showing multiple motds.
Requires:       pam >= 1.3.1
Requires:       jq

%description motdgen
%{summary}.

%package issuegen
Summary:        Issue generator
Requires:       console-login-helper-messages
Requires:       bash
Requires:       systemd
# agetty is included in util-linux, which searches /etc/issue.d.
# Needed for the generated issue symlink to display.
Requires:       util-linux

%description issuegen
%{summary}.

%package profile
Summary:        Profile script
Requires:       console-login-helper-messages
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

install -DpZm 0644 usr/lib/systemd/system/issuegen.path %{buildroot}%{_unitdir}/issuegen.path
install -DpZm 0644 usr/lib/systemd/system/issuegen.service %{buildroot}%{_unitdir}/issuegen.service
install -DpZm 0644 usr/lib/tmpfiles.d/issuegen-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/issuegen.conf
install -DpZm 0644 usr/lib/systemd/system/motdgen.path %{buildroot}%{_unitdir}/motdgen.path
install -DpZm 0644 usr/lib/systemd/system/motdgen.service %{buildroot}%{_unitdir}/motdgen.service
install -DpZm 0644 usr/lib/tmpfiles.d/%{name}-profile-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/%{name}-profile.conf
install -DpZm 0644 usr/lib/udev/rules.d/91-issuegen.rules %{buildroot}%{_prefix}/lib/udev/rules.d/91-issuegen.rules

install -DpZm 0755 usr/lib/%{name}/issuegen %{buildroot}%{_prefix}/lib/%{name}/issuegen
install -DpZm 0644 usr/lib/%{name}/issue.d/* %{buildroot}%{_prefix}/lib/%{name}/issue.d
install -DpZm 0755 usr/lib/%{name}/motdgen %{buildroot}%{_prefix}/lib/%{name}/motdgen
install -DpZm 0644 usr/lib/%{name}/motd.d/* %{buildroot}%{_prefix}/lib/%{name}/motd.d
install -DpZm 0755 usr/share/%{name}/%{name}-profile.sh %{buildroot}%{_prefix}/share/%{name}/%{name}-profile.sh

ln -snf /run/issue.d/%{name}.issue %{buildroot}%{_sysconfdir}/issue.d/%{name}.issue
ln -snf %{_prefix}/share/%{name}/%{name}-profile.sh %{buildroot}%{_sysconfdir}/profile.d/%{name}-profile.sh

%pre
%tmpfiles_create_package issuegen issuegen-tmpfiles.conf
%tmpfiles_create_package %{name}-profile %{name}-profile-tmpfiles.conf

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
%dir %{_prefix}/lib/%{name}
%dir /run/%{name}
%dir %{_prefix}/share/%{name}
%dir %{_sysconfdir}/%{name}

%files issuegen
%{_unitdir}/issuegen.path
%{_unitdir}/issuegen.service
%{_tmpfilesdir}/issuegen.conf
%{_prefix}/lib/udev/rules.d/91-issuegen.rules
%{_prefix}/lib/%{name}/issuegen
%dir %{_prefix}/lib/%{name}/issue.d
%{_prefix}/lib/%{name}/issue.d/base.issue
%dir /run/%{name}/issue.d
%{_sysconfdir}/issue.d/%{name}.issue
%dir %{_sysconfdir}/%{name}/issue.d

%files motdgen
%{_unitdir}/motdgen.path
%{_unitdir}/motdgen.service
%{_prefix}/lib/%{name}/motdgen
%dir %{_prefix}/lib/%{name}/motd.d
%{_prefix}/lib/%{name}/motd.d/base.motd
%dir /run/%{name}/motd.d
%dir %{_sysconfdir}/%{name}/motd.d

%files profile
%{_prefix}/share/%{name}/%{name}-profile.sh
%{_tmpfilesdir}/%{name}-profile.conf
%{_sysconfdir}/profile.d/%{name}-profile.sh

%changelog
* Tue Sep 25 2018 Robert Fairley <rfairley@redhat.com> - 0.1-1
- Initial Package

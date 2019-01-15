%global github_owner    rfairley
%global github_project  console-login-helper-messages

Name:           console-login-helper-messages
Version:        0.1
Release:        11%{?dist}
Summary:        Combines motd, issue, profile features to show system information to the user before/on login
# TODO: finalize URLs below
License:        BSD
URL:            https://github.com/%{github_owner}/%{github_project}
Source0:        https://github.com/%{github_owner}/%{github_project}/archive/%{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  systemd
%{?systemd_requires}
Requires:       bash systemd

%description
%{summary}.

%package motdgen
Summary:        Message of the day generator
Requires:       console-login-helper-messages
Requires:       bash systemd
# Needed to display motds under /run and /usr/lib
Recommends:     pam >= 1.3.1-12 if sshd

%description motdgen
%{summary}.

%package issuegen
Summary:        Issue generator
Requires:       console-login-helper-messages
Requires:       bash systemd
# agetty is included in util-linux, which searches /etc/issue.d.
# Needed to display issues symlinked from /etc/issue.d.
Requires:       util-linux

%description issuegen
%{summary}.

%package profile
Summary:        Profile script
Requires:       console-login-helper-messages
Requires:       bash systemd

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

install -DpZm 0644 usr/lib/systemd/system/%{name}-issuegen.path %{buildroot}%{_unitdir}/%{name}-issuegen.path
install -DpZm 0644 usr/lib/systemd/system/%{name}-issuegen.service %{buildroot}%{_unitdir}/%{name}-issuegen.service
install -DpZm 0644 usr/lib/tmpfiles.d/%{name}-issuegen-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/%{name}-issuegen.conf
install -DpZm 0644 usr/lib/systemd/system/%{name}-motdgen.path %{buildroot}%{_unitdir}/%{name}-motdgen.path
install -DpZm 0644 usr/lib/systemd/system/%{name}-motdgen.service %{buildroot}%{_unitdir}/%{name}-motdgen.service
install -DpZm 0644 usr/lib/tmpfiles.d/%{name}-profile-tmpfiles.conf %{buildroot}%{_tmpfilesdir}/%{name}-profile.conf
install -DpZm 0644 usr/lib/udev/rules.d/90-%{name}-issuegen.rules %{buildroot}%{_prefix}/lib/udev/rules.d/90-%{name}-issuegen.rules

install -DpZm 0755 usr/lib/%{name}/issuegen %{buildroot}%{_prefix}/lib/%{name}/issuegen
install -DpZm 0755 usr/lib/%{name}/motdgen %{buildroot}%{_prefix}/lib/%{name}/motdgen
install -DpZm 0755 usr/share/%{name}/profile.sh %{buildroot}%{_prefix}/share/%{name}/profile.sh

ln -snf /run/issue.d/%{name}.issue %{buildroot}%{_sysconfdir}/issue.d/%{name}.issue
ln -snf %{_prefix}/share/%{name}/profile.sh %{buildroot}%{_sysconfdir}/profile.d/%{name}-profile.sh

%pre
# TODO: use %tmpfiles_create_package for issuegen and profile tmpfiles

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
%dir %{_prefix}/lib/%{name}
%dir /run/%{name}
%dir %{_prefix}/share/%{name}
%dir %{_sysconfdir}/%{name}

%files issuegen
%{_unitdir}/%{name}-issuegen.path
%{_unitdir}/%{name}-issuegen.service
%{_tmpfilesdir}/%{name}-issuegen.conf
%{_prefix}/lib/udev/rules.d/90-%{name}-issuegen.rules
%{_prefix}/lib/%{name}/issuegen
%dir %{_prefix}/lib/%{name}/issue.d
%dir /run/%{name}/issue.d
%{_sysconfdir}/issue.d/%{name}.issue
%dir %{_sysconfdir}/%{name}/issue.d

%files motdgen
%{_unitdir}/%{name}-motdgen.path
%{_unitdir}/%{name}-motdgen.service
%{_prefix}/lib/%{name}/motdgen
%dir %{_prefix}/lib/%{name}/motd.d
%dir /run/%{name}/motd.d
%dir %{_sysconfdir}/%{name}/motd.d

%files profile
%{_prefix}/share/%{name}/profile.sh
%{_tmpfilesdir}/%{name}-profile.conf
%{_sysconfdir}/profile.d/%{name}-profile.sh

%changelog
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

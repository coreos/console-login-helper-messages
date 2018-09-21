Name:           coreos-base
Version:        0.1
Release:        1%{?dist}
Summary:        Base files for Fedora Coreos.

License:
URL:            https://example.com/%{name}
Source0:        https://example.com/%{name}/release/%{name}-%{version}.tar.gz

BuildRequires:
Requires:       bash,systemd

%description

Long description goes here.

%prep
%setup -q

%build

%install

# Vendor-scoped directories
mkdir -p %{buildroot}%{_prefix}/lib/%{name}/issue.d
mkdir -p %{buildroot}%{_prefix}/lib/%{name}/motd.d
mkdir -p %{buildroot}%{_sysconfdir}/%{name}/issue.d
mkdir -p %{buildroot}%{_sysconfdir}/%{name}/motd.d
mkdir -p %{buildroot}%{_prefix}/share/%{name}

# External directories
mkdir -p %{buildroot}%{_unitdir}
mkdir -p %{buildroot}%{_tmpfilesdir}
mkdir -p %{buildroot}%{_prefix}/lib/udev/rules.d

# TODO: move files in current repo to better organized dirs
# TODO: once moved to new dirs, use * for things like base.issue
install -DpZm 0644 issuegen.path %{buildroot}%{_unitdir}/issuegen.path
install -DpZm 0644 issuegen.service %{buildroot}%{_unitdir}/issuegen.service
install -DpZm 0644 issuegen.conf %{buildroot}%{_tmpfilesdir}/issuegen.conf
install -DpZm 0644 motdgen.path %{buildroot}%{_unitdir}/motdgen.path
install -DpZm 0644 motdgen.service %{buildroot}%{_unitdir}/motdgen.service
install -DpZm 0644 motdgen.conf %{buildroot}%{_tmpfilesdir}/motdgen.conf
install -DpZm 0644 91-issuegen.rules %{buildroot}%{_prefix}/lib/udev/rules.d/91-issuegen.rules
install -DpZm 0644 coreos-profile.conf %{buildroot}%{_tmpfilesdir}/coreos-profile.conf

install -DpZm 0755 issuegen %{buildroot}%{_prefix}/lib/%{name}/issuegen
install -DpZm 0755 motdgen %{buildroot}%{_prefix}/lib/%{name}/motdgen
install -DpZm 0755 coreos-profile.sh %{buildroot}%{_prefix}/share/%{name}/coreos-profile.sh
install -DpZm 0644 base.issue %{buildroot}%{_prefix}/lib/%{name}/issue.d/base.issue

%files
%doc README.md
%license LICENSE
%dir %{_prefix}/lib/%{name}


%changelog
*
-

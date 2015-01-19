Name:           cloudrouter-release
Version:        1
Release:        1
Summary:        Extra packages for the CloudRouter Software-Defined Interconnect (SDI) platform

Group:          System Environment/Base
License:        AGPLv3

URL:            https://cloudrouter.org/
Source0:        https://cloudrouter.org/repo/RPM-GPG-KEY-CLOUDROUTER
Source1:        cloudrouter.repo
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       java-1.8.0-openjdk-devel >= 1.8.0
%description
This packages the CloudRouter repository GPG key as well as configuration for yum.

%prep
%setup -q  -c -T
install -pm 644 %{SOURCE0} .

%build


%install
rm -rf $RPM_BUILD_ROOT

#GPG Key
install -Dpm 644 %{SOURCE0} \
    $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-CLOUDROUTER

# yum
install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE1} \
    $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d

%clean
rm -rf $RPM_BUILD_ROOT

%post
sed -i 's/Fedora/CloudRouter 1.0 Beta based on Fedora/' /etc/issue

%postun
sed -i 's/CloudRouter 1.0 Beta based on Fedora/Fedora/' /etc/issue

%files
%defattr(-,root,root,-)
%config(noreplace) /etc/yum.repos.d/*
/etc/pki/rpm-gpg/*

%changelog
* Sat Jan 17 2015 David Jorm - 1-1
- Added openjdk-devel dependency, update issue file
* Fri Jan 16 2015 David Jorm - 1-0
- Initial package

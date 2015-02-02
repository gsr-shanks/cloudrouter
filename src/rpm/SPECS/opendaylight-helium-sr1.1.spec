Summary: OpenDaylight Controller
Name: opendaylight
Version: helium
Release: 2
Source0: https://cloudrouter.org/repo/beta/src/opendaylight-helium.zip
 
License: EPL-1.0
Group: Applications/System
 
ExclusiveArch: x86_64
BuildRoot: %{_tmppath}/%{name}-buildroot
Requires: java-1.7.0-openjdk-devel >= 1.7.0

# disable debug packages and the stripping of the binaries
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}
 
%description
OpenDaylight is an open platform for network programmability to enable SDN and create a solid foundation for NFV for networks at any size and scale.
 
%prep
%setup -q
 
%build
 
%install
rm -fr $RPM_BUILD_ROOT
mkdir -m 0755 -p $RPM_BUILD_ROOT/opt/%{name}/%{name}-%{version}
cp -R * $RPM_BUILD_ROOT/opt/%{name}/%{name}-%{version}
 
%clean
rm -rf $RPM_BUILD_ROOT
 
%post
echo " "
echo "OpenDaylight Helium successfully installed"
 
%files
%defattr(-,root,root)
/opt/%{name}/*
 
%changelog
* Sun Feb 01 2015 David Jorm - helium-2
- Upgraded to helium SR2
* Tue Jan 20 2015 David Jorm - helium-1
- Added openjdk-devel dependency
* Fri Jan 16 2015 David Jorm - helium-0
- Initial creation

#!/bin/sh
mkdir -p ~/rpmbuild
cp SPECS/* ~/rpmbuild/SPECS/
cp SOURCES/* ~/rpmbuild/SOURCES/
curl -o ~/rpmbuild/SOURCES/RPM-GPG-KEY-CLOUDROUTER https://cloudrouter.org/repo/RPM-GPG-KEY-CLOUDROUTER
rpmbuild -ba --clean ~/rpmbuild/SPECS/cloudrouter-1.0.spec
curl -o ~/rpmbuild/SOURCES/opendaylight-helium.zip https://cloudrouter.org/repo/beta/src/opendaylight-helium.zip
rpmbuild -ba --clean ~/rpmbuild/SPECS/opendaylight-helium.spec
rm -rf ~/rpmbuild/BUILD/distribution-karaf-0.2.1-Helium-SR1/

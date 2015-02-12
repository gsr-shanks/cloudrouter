#!/bin/sh

# Get the Fedora 20 cloud image (if it doesn't already exist on disk)

if [ ! -f Fedora-x86_64-20-20131211.1-sda.raw ]; then
	wget http://dl.fedoraproject.org/pub/fedora/linux/releases/20/Images/x86_64/Fedora-x86_64-20-20131211.1-sda.raw.xz
	unxz Fedora-x86_64-20-20131211.1-sda.raw.xz
fi

# Put a working copy in /tmp

if [ -f /tmp/cloudrouter-build.raw ]; then
	rm -f /tmp/cloudrouter-build.raw
fi
cp Fedora-x86_64-20-20131211.1-sda.raw /tmp/cloudrouter-build-tmp.raw
chmod 777 /tmp/cloudrouter-build-tmp.raw

# Resize the image (+1 GB)

truncate -r /tmp/cloudrouter-build-tmp.raw /tmp/cloudrouter-build.raw
truncate -s +1G /tmp/cloudrouter-build.raw
virt-resize --expand /dev/sda1 /tmp/cloudrouter-build-tmp.raw /tmp/cloudrouter-build.raw
rm -f /tmp/cloudrouter-build-tmp.raw 

# Use virt-edit to add the no_timer_check kernel parameter. This is necessary for the image to load under pure QEMU (no KVM).

virt-edit -a /tmp/cloudrouter-build.raw --format=raw /boot/extlinux/extlinux.conf -e 's/console=tty1/no_timer_check console=tty1/'

# Create a cloud-init ISO image setting the fedora user's password to "build"

genisoimage -output cloud-init/init.iso -volid cidata -joliet -rock cloud-init/user-data cloud-init/meta-data
if [ -f /tmp/init.iso ]; then
	rm -f /tmp/init.iso
fi
cp cloud-init/init.iso /tmp/init.iso
chmod 777 /tmp/init.iso

# Spin up the VM and wait 5 minutes for it to boot

virsh create CloudRouter-build.xml
sleep 300

# Get the VM's IP

IP_ADDR=$(arp -e | grep "`virsh dumpxml cloudrouter-build | grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"`" | cut -d ' ' -f1)
echo $IP_ADDR

# Clear old ssh known hosts

rm -f ~/.ssh/known_hosts

# SSH to the VM using the "build" password and install repos/packages. As a last step, clear the cloud-init config in /var/lib/cloud/instances

sshpass -p 'build' ssh -o StrictHostKeyChecking=no fedora@$IP_ADDR -t 'cd /tmp ; sudo yum install -y wget ; wget https://cloudrouter.org/repo/beta/x86_64/cloudrouter-release-1-1.noarch.rpm ; ls -la cloudrouter-release-1-1.noarch.rpm ; sudo yum localinstall -y cloudrouter-release-1-1.noarch.rpm ; sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CLOUDROUTER ; sudo yum -y remove docker ; sudo yum install -y opendaylight bird quagga dpdk docker-io firewalld bind dnsmasq ipsec-tools xl2tpd; sudo yum update -y ; rpm -qa | sort > /tmp/manifest.txt ; sudo rm -rf /var/lib/cloud/instances'

# Grab the manifest file, then remove it from the VM

sshpass -p 'build' scp fedora@$IP_ADDR:/tmp/manifest.txt /tmp/manifest.txt
sshpass -p 'build' ssh -o StrictHostKeyChecking=no fedora@$IP_ADDR -t 'rm -f /tmp/manifest ; yum clean all'

# Shutdown VM and cleanup

virsh destroy cloudrouter-build
rm -f cloud-init/init.iso

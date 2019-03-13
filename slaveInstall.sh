#!/bin/bash
echo " .----------------.  .----------------.  .----------------."
echo "| .--------------. || .--------------. || .--------------. |"
echo "| |  _________   | || |     ______   | || | ____    ____ | |"
echo "| | |_   ___  |  | || |   .' ___  |  | || ||_   \  /   _|| |"
echo "| |   | |_  \_|  | || |  / .'   \_|  | || |  |   \/   |  | |"
echo "| |   |  _|  _   | || |  | |         | || |  | |\  /| |  | |"
echo "| |  _| |___/ |  | || |  \  .___.'\  | || | _| |_\/_| |_ | |"
echo "| | |_________|  | || |    ._____.'  | || ||_____||_____|| |"
echo "| |              | || |              | || |              | |"
echo "| '--------------' || '--------------' || '--------------' |"
echo " '----------------'  '----------------'  '----------------'"

echo "-------> Installer v0.01            "
echo "----> Installing ECM v0.01 slave   "
echo "-> You have 10 seconds to cancel.   "
echo " "

if [ ! -e "/etc/centos-release" ]; then
echo "Warning: Only servers running CentOS 6.x are supported."
exit 1
fi

sleep 10
mkdir /etc/ecm
touch /etc/ecm/seedit2.conf
chmod 777 /etc/ecm/seedit2.conf
wget "https://raw.githubusercontent.com/madeinearnest/container-manager/master/ecm-iptables-script" -O /etc/ecm/ecm-iptables-init-script
wget "https://raw.githubusercontent.com/madeinearnest/container-manager/master/init-wildcard-ssl" -O /etc/ecm/init-wildcard-ssl
chmod +x /etc/ecm/init-wildcard-ssl
echo "-> Installing packages"
yum update
yum install -y git expr bc &> /dev/null
echo "-> Downloading ECM files..."
cd /tmp && git clone https://github.com/madeinearnest/container-manager
mv /tmp/container-manager /tmp/slave
chmod 700 /tmp/slave/*
mv /tmp/slave/* /sbin
echo "-> Installing OpenVZ kernel"
wget -P /etc/yum.repos.d/ https://download.openvz.org/openvz.repo
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ
yum install vzkernel -y
echo "-> Installing OpenVZ tools"
yum install vzctl vzquota ploop -y
echo "-> Installation complete. Please wait while final configuration changes are made."
newPassword=$(openssl rand -base64 32)
useradd remote
mkdir -p /srv/consoleusers/
mkdir -p /srv/containers
groupadd consoleusers
echo '%consoleusers ALL=NOPASSWD:/sbin/vzenter' >> /etc/sudoers
sed -i 's/VE_LAYOUT=ploop/VE_LAYOUT=simfs/g' /etc/vz/vz.conf
chmod 755 /sbin/vzenter
mkdir /data/seedboxes
mkdir /data/seedboxes/private
mkdir /data/seedboxes/root
echo "->Configuring iptables"
echo 'options nf_conntrack ip_conntrack_disable_ve0=0' > /etc/modprobe.d/openvz.conf
echo '' >> /etc/sysctl.conf
echo '' >> /etc/sysctl.conf
echo '#ECM' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.forwarding=1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.forwarding=1' >> /etc/sysctl.conf
/sbin/iptables-restore < /etc/ecm/ecm-iptables-init-script
echo "-> Setup NGINX"
yum -y install epel-release
yum -y install nginx
echo "-> Install Lets Encrypt"
yum -y install epel-release mod_ssl
rpm -ivh https://rhel6.iuscommunity.org/ius-release.rpm
yum --enablerepo=ius install git python27 python27-devel python27-pip python27- setuptools python27-virtualenv -y
cd /etc/ecm
git clone https://github.com/letsencrypt/letsencrypt
/etc/init.d/nginx start
echo "-> Configuring IP Block"
yum -y install ipset
ipset create publictrackers hash:net
iptables -I FORWARD -m set --match-set publictrackers dst -j DROP
echo -e "$newPassword\n$newPassword" | passwd remote
echo 'Downloading container template'
wget https://earnest.ams3.digitaloceanspaces.com/seed/templates/ubuntu-16.04-x86_64-swizzin.tar.gz -O /var/lib/vz/template/cache/ubuntu-16.04-x86_64-swizzin.tar.gz
sed -i "s#/vz/private#/data/seedboxes/private#g" /etc/vz/vz.conf
sed -i "s#/vz/root#/data/seedboxes/root#g" /etc/vz/vz.conf
echo 'remote ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
echo "-> Slave node configured. Here are the slave details:"
echo "-> Access key: $newPassword"
echo "-> Note: A reboot is required. Failiure to do so will prevent the proper installation of the OpenVZ kernel."
echo "-> After reboot, please execute the following command"
echo "iptables -t nat -A POSTROUTING -o `/sbin/ip addr | awk '/state UP/ {print $2}' | sed s/://g` -j MASQUERADE"

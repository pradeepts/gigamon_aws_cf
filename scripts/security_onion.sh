#!/bin/bash
username=$1
password=$2
sudo ip link add vxlan0 type vxlan id 0 group 239.1.1.1 dev eth0 port 4789 4789
sudo ip link set vxlan0 up
echo "debconf debconf/frontend select noninteractive" | sudo debconf-set-selections
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:securityonion/stable
sudo apt-get update
sudo apt-get -y install securityonion-all syslog-ng-core
sudo sed -i 's/eth1/vxlan0/g' /usr/share/securityonion/sosetup.conf
sudo sed -i 's/onionuser/$username/g' /usr/share/securityonion/sosetup.conf
sudo sed -i 's/asdfasdf/$password/g' /usr/share/securityonion/sosetup.conf
sudo sosetup -f /usr/share/securityonion/sosetup.conf  -y
sudo ufw disable
sudo apt install securityonion-elastic  -y
sudo so-elastic-common
sudo so-replay
sudo so-elastic-download
sudo sh /opt/elsa/contrib/securityonion/contrib/securityonion-elsa-cron.sh
sudo sh /opt/elsa/contrib/securityonion/contrib/securityonion-elsa-cron.sh
sudo so-elastic-configure
sudo so-migrate-elsa-data-to-elastic -y
sudo so-elastic-final-text

# sudo apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 make libmagic-dev
# sudo apt-get -y install build-essential bison flex linux-headers-$(uname -r)
# sleep 3
sudo ip link del vxlan0

sudo chmod 777 /etc/apt/sources.list
sudo echo -e "\ndeb http://mirrors.kernel.org/ubuntu xenial main" >> /etc/apt/sources.list
sudo apt-get update
sudo apt-get install iproute2 -y

sudo ip link add vxlan0 type vxlan id 0 group 239.1.1.1 dev eth0 dstport 4789
sudo ip link set vxlan0 up
sudo service nsm restart
sudo ufw disable



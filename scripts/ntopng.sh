#!/bin/bash
vpc_cidr=$1
sudo wget http://apt-stable.ntop.org/16.04/all/apt-ntop-stable.deb
sudo dpkg -i apt-ntop-stable.deb
sudo apt-get clean all
sudo apt-get update
sudo apt-get install ntopng -y
sudo chmod 777 /etc/ntopng/ntopng.conf
sudo sed -i -e "s/run/tmp/g" /etc/ntopng/ntopng.conf
sudo echo "-e=" >> /etc/ntopng/ntopng.conf
sudo echo "-i=2" >> /etc/ntopng/ntopng.conf
sudo echo "-w=3000" >> /etc/ntopng/ntopng.conf
sudo echo "-m=$vpc_cidr" >> /etc/ntopng/ntopng.conf
sudo echo "-n=1" >> /etc/ntopng/ntopng.conf
sudo echo "-S=" >> /etc/ntopng/ntopng.conf
sudo echo "-d=/var/tmp/ntopng" >> /etc/ntopng/ntopng.conf
sudo echo "-q=" >> /etc/ntopng/ntopng.conf
sudo echo "-W=0" >> /etc/ntopng/ntopng.conf
sudo echo "-g=-1" >> /etc/ntopng/ntopng.conf
sudo touch /etc/ntopng/ntopng.start
sudo echo "--local-networks "$vpc_cidr"" >> /etc/ntopng/ntopng.start
sudo echo "--interface 1" >> /etc/ntopng/ntopng.start
sudo systemctl restart redis-server.service 
sudo service ntopng restart
sudo ip link add vxlan0 type vxlan id 0 group 239.1.1.1 dev eth0 dstport 4789
sudo ip link set vxlan0 up
sudo service ntopng restart
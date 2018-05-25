#!/bin/bash
pwd=$1
pstatus=`ps -eaf | grep apt.systemd.daily | wc -l`
while [ $pstatus -gt 1 ]; do sleep 180; pstatus=`ps -eaf | grep apt.systemd.daily | wc -l`; done
# Installation of xrdp to enable RDP and xfce4 for creation desktop environment on Ubuntu instance
sudo apt-get update
sudo apt-get install -y xrdp xfce4
sudo  service xrdp restart
#Adding Wireshark package to apt-get repository
sudo add-apt-repository ppa:wireshark-dev/stable -y
sudo apt-get update
# Installation of Wireshark package
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark-gtk
sudo chmod 4711 /usr/bin/dumpcap
# Upgrading the kernel version
sudo chmod 777 /etc/apt/sources.list
sudo echo -e "\ndeb http://mirrors.kernel.org/ubuntu xenial main" >> /etc/apt/sources.list
sudo apt-get update
sudo apt-get install iproute2 -y
# Creating Vxlan tunnel to receive traffic from gigamonVUE
sudo ip link add vxlan0 type vxlan id 0 group 239.1.1.1 dev eth0 dstport 4789
sudo ip link set vxlan0 up
sudo ufw disable
# changing the password of Ubuntu user
sudo echo -e "$pwd\n$pwd" | sudo passwd ubuntu
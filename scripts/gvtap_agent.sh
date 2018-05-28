#!/bin/bash
sudo apt-get update
sudo apt-get install apache2 unzip -y
sudo chmod 777 /etc/network/interfaces.d/50-cloud-init.cfg
sudo echo -e "\nauto eth1 \niface eth1 inet dhcp" >> /etc/network/interfaces.d/50-cloud-init.cfg
sudo wget https://s3.amazonaws.com/gigamonartifacts/wireshark_splunk/scripts/gvtap-agent_1.4-1_amd64.deb
sudo dpkg -i gvtap-agent_1.4-1_amd64.deb
sudo echo -e "eth0    mirror-src-ingress mirror-src-egress\neth1    mirror-dst" >> /etc/gvtap-agent/gvtap-agent.conf
sudo service gvtap-agent restart
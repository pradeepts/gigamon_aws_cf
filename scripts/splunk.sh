#!/bin/bash
wget https://s3.amazonaws.com/gigamonartifacts/wireshark_splunk/scripts/splunk-stream_711.tgz
tar -xvzf splunk-stream_711.tgz
sudo cp -r ./splunk_app_stream/ /opt/splunk/etc/apps/
wget https://s3.amazonaws.com/gigamonartifacts/wireshark_splunk/scripts/gigamon-ipfix-metadata-application-for-splunk_110.tgz
tar -xvzf gigamon-ipfix-metadata-application-for-splunk_110.tgz
sudo cp -r ./GigamonIPFIXForSplunk/ /opt/splunk/etc/apps/
cd /opt/splunk/bin/
sudo ./splunk restart
sudo -i
cd /opt/splunk/etc/apps/Splunk_TA_stream/
./set_permissions.sh
echo -e "[streamfwd]\nnetflowReceiver.0.ip = 0.0.0.0\nnetflowReceiver.0.port = 2055\nnetflowReceiver.0.protocol = udp\nnetflowReceiver.0.decoder = netflow" >> /opt/splunk/etc/apps/Splunk_TA_stream/local/streamfwd.conf
curl -k -X "POST" https://localhost:8089/servicesNS/admin/splunk_httpinput/data/inputs/http/http/enable
/opt/splunk/bin/splunk restart
#Applying free license
sudo chmod 777 /opt/splunk/etc/system/local/server.conf
sudo echo -e "\n[license]\nactive_group = Free" >> /opt/splunk/etc/system/local/server.conf
cd /opt/splunk/bin/
#Restarting the Splunk service
sudo ./splunk restart
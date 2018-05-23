#!/bin/bash
agent1_ip=$1
wget https://s3.amazonaws.com/gigamonartifacts/scripts/traffic_generator.sh
chmod +x ./traffic_generator.sh
sudo sed -i 's/$1/'$agent1_ip'/g' ./traffic_generator.sh
sudo cp ./traffic_generator.sh /tmp/
SELECTED_EDITOR=/bin/nano
sudo service cron reload
crontab -l | { cat; echo "*/5 * * * * /tmp/traffic_generator.sh"; } | crontab -
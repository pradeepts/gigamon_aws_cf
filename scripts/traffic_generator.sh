#!/bin/bash
agent1_ip=$1
ping $agent1_ip &
while : true
do
curl $agent1_ip
sleep 5
done &
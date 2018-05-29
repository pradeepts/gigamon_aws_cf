#!/bin/bash
instance_id=$1
vpc_id=$2
key_pair=$3
mgmt_subnet_id=$4
mirror_subnet_id=$5
securitygroup_Id=$6
region=$7
availability_zone=$8
ntopng_ip=$9
gigamon_fm_ip=${10}
#Gigamon Apis
sleep 100
conn_data="{\"id\": \"\", \"alias\": \"aws\",\"authType\": \"ec2InstanceRole\",\"regionName\": \"$region\",\"vpcId\": \"$vpc_id\",  \"availabilityZone\": \"$availability_zone\"}"
echo $conn_data
curl  --insecure  -X POST https://$gigamon_fm_ip/api/v1.3/vfm/aws/connections  -u admin:$instance_id -d "$conn_data" --header "Content-Type:application/json"
sleep 20
d=`curl -s  --insecure   -u admin:$instance_id https://$gigamon_fm_ip/api/v1.3/vfm/aws/connections | grep  "id"  | cut -d ":" -f2 | tr -d "\"," | tr -d  " "`
data="{ \"id\": \"\", \"connId\": \"${d}\", \"connAlias\": \"aws\", \"fabricNodeConfigs\": [{\"imageId\": \"ami-89681df1\", \"imageName\": \"gigamon-gvtap-cntlr-1.4-1-456b49b8-d4f9-40e7-8bdb-049fa0f39ef8-ami-2e00a053.4\", \"instanceType\": \"t2.medium\", \"numOfInstancesToLaunch\": 1 }],\"ebsVolumeType\": \"gp2\", \"sshKeyPairName\": \"$key_pair\", \"mgmtSubnetSpec\": { \"subnetId\": \"$mgmt_subnet_id\", \"subnetName\": \"gigamon-mgmtsubnet\", \"securityGroups\": [{ \"securityGroupId\": \"$securitygroup_Id\", \"securityGroupName\": \"gigamon-sg\" } ] }, \"usePublicIps\": false,\"mtu\": 8951}"
echo "$data"
echo -e "\n\n\n\n"
curl  --insecure -X POST https://$gigamon_fm_ip/api/v1.3/vfm/aws/fabricDeployment/gvTapControllers/configs  -u admin:$instance_id -d "$data" --header "Content-Type:application/json"
data1="{ \"id\": \"\", \"connId\": \"$d\", \"connAlias\": \"aws\",\"imageId\": \"ami-936e1beb\", \"imageName\": \"gigamon-gigavue-vseries-cntlr-1.4-1-be2b37d9-7e97-426e-9aac-84480f0f15b1-ami-4f3e9e32.4\", \"instanceType\": \"t2.medium\", \"ebsVolumeType\": \"gp2\", \"sshKeyPairName\": \"$key_pair\", \"mgmtSubnetSpec\": { \"subnetId\": \"$mgmt_subnet_id\", \"subnetName\": \"gigamon-mgmtsubnet\", \"securityGroups\": [{ \"securityGroupId\": \"$securitygroup_Id\", \"securityGroupName\": \"gigamon-sg\" } ] }, \"usePublicIps\": false,\"numOfInstancesToLaunch\": 1}"
sleep 20
curl  --insecure -X POST https://$gigamon_fm_ip/api/v1.3/vfm/aws/fabricDeployment/vseriesControllers/configs  -u admin:$instance_id -d "$data1"  --header "Content-Type:application/json"
data2="{\"id\": \"\", \"connAlias\": \"aws\",\"connId\": \"${d}\",\"imageId\": \"ami-556e1b2d\",\"imageName\": \"gigamon-gigavue-vseries-node-1.4-1-3663e3ea-7a87-4f9d-91e5-ae66da6e8f29-ami-1f3f9f62.4\",  \"sshKeyPairName\": \"$key_pair\", \"mgmtSubnetSpec\": { \"subnetId\": \"$mgmt_subnet_id\",  \"subnetName\": \"gigamon-mgmtsubnet\",\"securityGroups\": [  {  \"securityGroupId\": \"$securitygroup_Id\", \"securityGroupName\": \"gigamon-sg\" } ] },\"minInstancesToLaunch\": 1, \"maxInstancesToLaunch\": 1, \"mtu\": 9001, \"ebsVolumeType\": \"gp2\",\"dataSubnetsSpec\": [{\"subnetId\": \"$mirror_subnet_id\",\"subnetName\": \"gigamon-mirrorsubnet\", \"securityGroups\": [{ \"securityGroupId\": \"$securitygroup_Id\", \"securityGroupName\": \"gigamon-sg\"}]},{\"subnetId\": \"$mgmt_subnet_id\",\"subnetName\": \"gigamon-mgmtsubnet\", \"securityGroups\": [{\"securityGroupId\": \"$securitygroup_Id\",\"securityGroupName\": \"gigamon-sg\" }]}],\"instanceType\": \"c4.large\"}"
sleep 140
curl  --insecure -X POST https://$gigamon_fm_ip/api/v1.3/vfm/aws/fabricDeployment/vseriesNodes/configs  -u admin:$instance_id -d "$data2"  --header "Content-Type:application/json"
sleep 20
tunnel1="{\"type\": \"vxlan\",\"vxlanConfig\": {\"id\": \"1\", \"alias\": \"ntopng\",\"dstAddress\": \"$ntopng_ip\",\"dstPort\": \"4789\",\"trafficDirection\": \"out\",\"nodeIfaceSubnetCIDR\": \"\" }}"
curl --insecure -X POST https://$gigamon_fm_ip/api/v1.3/vfm/tunnelSpecs -u admin:$instance_id -d "$tunnel1" --header "Content-Type:application/json"
sleep 5
monitoring_session="{ \"alias\": \"Session1\",\"id\": \"1\",\"connId\": \"${d}\", \"connAlias\": \"aws\", \"deployed\": true }"
curl  --insecure  -X POST https://$gigamon_fm_ip/api/v1.3/vfm/monitoringSessions -u admin:$instance_id -d "$monitoring_session" --header "Content-Type:application/json"
curl --insecure -X POST https://$gigamon_fm_ip//api/v1.3/vfm/maps -u admin:$instance_id -d '{ "id": "1", "alias": "passall", "rules":[ {"actionSet": 0,"comment": "", "filters": [], "priority": 0 }] }' --header "Content-Type:application/json"
curl --insecure -X POST https://$gigamon_fm_ip//api/v1.3/vfm/maps -u admin:$instance_id -d '{ "id": "2", "alias": "http","rules": [{"actionSet": 0, "filters": [{ "type": "etherType", "value": "0x0800"},{"type": "ipProto","value": 6 },{ "type": "portDst", "valueMax": 80, "value": 80 }],"priority": 0}] }]}' --header "Content-Type:application/json"
curl --insecure -X POST https://$gigamon_fm_ip//api/v1.3/vfm/maps -u admin:$instance_id -d '{ "id": "3", "alias": "icmp","rules": [{"actionSet": 0, "filters": [{ "type": "etherType", "value": "0x0800"},{"type": "ipProto","value": 1 }],"priority": 0}] }]}' --header "Content-Type:application/json"

#!/bin/bash
#ASSIGNMENT 1 : Setting up VPC & NAT in GCP
#creating a vpc network with automatic subnets

gcloud compute networks create cdm-network-vpc-auto --subnet-mode auto

#creating a firewall rule to allow ssh from only Quantiphi's IP

gcloud compute firewall-rules create cdm-qip-ssh \
--network cdm-network-vpc-auto \
--source-ranges 59.152.0.0/24 \
--allow tcp:22 \
--description="This rule allows any instance created in the vpc to be only accessible via Quantiphi's IP"

#creating a new vpc network with custom subnets in the reqions us-east1 and us-central1

gcloud compute networks create cdm-network-vpc-custom \
--subnet-mode custom

#adding subnets to the custom vpc made

gcloud compute networks subnets create cdm-subnet-useast1 \
--network cdm-network-vpc-custom \
--region us-east1 \
--range 10.142.0.0/20

gcloud compute networks subnets create cdm-subnet-uscentral1 \
--network cdm-network-vpc-custom \
--region us-central1 \
--range 10.128.0.0/20

#adding firewall rules for ssh and internal communications on all protocols and ports

gcloud compute firewall-rules create cdm-allow-ssh \
--allow tcp:22 \
--network cdm-network-vpc-custom

gcloud compute firewall-rules create cdm-allow-internal \
--allow tcp:1-65535,udp:1-65535,icmp \
--source-ranges 10.142.0.0/20 \
--network cdm-network-vpc-custom

#creating a nat gateway via a VM instance with a startup_script containing the configuration for ip tabels

gcloud compute instances create cdm-nat-gateway --network cdm-network-vpc-custom \
--subnet cdm-subnet-useast1 \
--can-ip-forward \
--zone us-east1-b \
--image-family debian-8 \
--image-project debian-cloud \
--tags nat \
--metadata startup-script='#! /bin/bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#below commands make above settings to be persist across future reboots
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo apt-get install iptables-persistent'

#creating a no-ip instance which will be connected to the internet via the nat gateway 

gcloud compute instances create cdm-noip-instance --network cdm-network-vpc-custom \
--subnet cdm-subnet-useast1 \
--no-address \
--zone us-east1-b \
--image-family debian-8 \
--image-project debian-cloud \
--tags no-ip

#creating a route table to connect no ip instance to its destination internet via the next hop nat gateway

gcloud compute routes create cdm-no-ip-internet-route \
--network cdm-network-vpc-custom \
--destination-range 0.0.0.0/0 \
--next-hop-instance cdm-nat-gateway \
--next-hop-instance-zone us-east1-b \
--tags no-ip --priority 800

echo "The result will be shown on the link : "
echo "The process has been executed. Terminating script......."

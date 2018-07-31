#!/bin/bash
#ASSIGNMENT 2: Setting up Instance group, LB & Bucket in GCP

#Creating an instance template for instance group creation

gcloud beta compute instance-templates create cdm-instance-template \
--machine-type=n1-standard-1 \
--network=projects/pe-training/global/networks/default \
--network-tier=PREMIUM \
--metadata=startup-script=\#\!\ /bin/bash$'\n'apt-get\ update\ -y$'\n'apt-get\ install\ apache2\ -y$'\n'cd\ /var/www/html/$'\n'echo\ \"\<html\>\<title\>HTTP\ APPLICATION\ PART1\</title\>\<body\>\<h1\>This\ is\ for\ request\ \(\ \)\</h1\>\</body\>\</html\>\"\ \>\ index.html \
--maintenance-policy=MIGRATE \
--service-account=912623308461-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-tags --image=debian-9-stretch-v20180716 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=cdm-instance-template \
--project=pe-training

#making a http health check

gcloud compute --project "pe-training" http-health-checks create "cdm-health-check" \
--port "80" \
--request-path "/" \
--check-interval "15" \
--timeout "15" \
--unhealthy-threshold "10" \
--healthy-threshold "2" 


#creating an instance group from the instance template we created

gcloud beta compute instance-groups managed create "cdm-instance-grp" \
--base-instance-name "cdm-instance-grp" \
--template "chaitanya-instance-template" \
--size "1" \
--zones "us-east1-b,us-east1-c,us-east1-d" \
--project "pe-training" \
--http-health-check "cdm-health-check" \

#enabling autoscaling in our instance group create above

gcloud compute instance-groups managed set-autoscaling "cdm-instance-grp" \
--project "pe-training" \
--region "us-east1" \
--cool-down-period "60" \
--max-num-replicas "10" \
--min-num-replicas "2" \
--target-cpu-utilization "0.6"

#Now we can start configuring the load balancer for our newly created instance group
#Creating the backend service required for our load balancer

gcloud compute backend-services create cdm-backend-service \
--protocol HTTP \
--http-health-checks "cdm-health-check"

#Attaching the newly created backend service to the instance group we had created

gcloud compute backend-services add-backend cdm-backend-service \
--balancing-mode RATE \
--max-rate-per-instance 1 \
--capacity-scaler 1 \
--instance-group "cdm-instance-grp" \
--global

#Creating a URL Map

gcloud compute url-maps create cdm-web-map \
--default-service "cdm-backend-service"

#creating target proxies to configure proxy to hide our load balancer's IP

gcloud compute target-http-proxies create cdm-http-proxy \
--url-map cdm-web-map

#now we need to attach an external IP to our load balancer by forwarding the proxy to point to load balancer IP

gcloud compute forwarding-rules create cdm-http-cr-rule \
--address cdm-static-ip \
--ports 80 \
--target-http-proxy cdm-http-proxy \
--global

#!/bin/bash
#ASSIGNMENT 4: Create a GKE (Google Kubernetes Engine) cluster with an appropriate name, labels and other configuration.

#We need to create a multi zone GKE cluster using gcloud

gcloud container clusters create cdm-cluster \
--zone us-central1-a \
--node-locations us-central1-a,us-central1-b,us-central1-c \
--enable-autoscaling --max-nodes 3 --min-nodes 1 \
--labels="name"="chaitanya","project"="pe-training" \
--num-nodes 1

#After creating your cluster, you need to get authentication credentials to interact with the cluster.

gcloud container clusters get-credentials cdm-cluster

#Need to deploy hello-app in your cluster

kubectl run cdm-hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080 --replicas 3

#Exposing the Deployment to the internet so that users can access it on a custom port say 4000

kubectl expose deployment cdm-hello-server --type LoadBalancer \
--port 3000 --target-port 8080

#storing the value of output response in string to get external IP
output=$(kubectl get service cdm-hello-server)
ip=( $output )
echo ${ip[9]}

echo "Following is the response of load balancer when you hit its ext IP. NOTE THE CHANGE IN POD NAME!"
curl ${ip[9]}:3000




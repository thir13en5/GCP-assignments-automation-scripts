#!/bin/bash
#ASSIGNMENT 3 : Cloud Pub/Sub & Cloud Functions assignment

echo "Creating Pub/Sub Topic .............."
#creating a pub/sub topic
gcloud pubsub topics create cdm-topic

#Now we will create subscriptions for our topic created above
#Creating a default pull subscription which will trigger the default pull cloud function
gcloud pubsub subscriptions create cdm-subscription --topic cdm-topic

#before we update our newly created subscription to be triggered by a push cloud fucntion we need to create a cloud fucntion
#Since we have our python cloud function ready in GIT repository we will clone it to local machine
echo "************CLONING FROM GIT REPOSITORY*************"
git clone https://github.com/thir13en5/GCP-PubSub-and-Cloud-Fucntion-Assessment.git

#Change to the directory that contains the Cloud Functions sample code
cd ~/GCP-PubSub-and-Cloud-Fucntion-Assessment/

#now we need to deploy the cloud function
echo "**************DEPLOYING CLOUD FUNCTION***************"
gcloud beta functions deploy hello_pubsub --runtime python37 --trigger-topic "cdm-topic" --timeout 540s

#Now we need to publish message to our pub/sub topic which will trigger our cloud function
#storing the value of text file in our message variable
message=$(<pubsubmessage.txt)

gcloud pubsub topics publish cdm-topic --message $message








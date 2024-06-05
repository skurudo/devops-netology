#!/bin/bash

yc iam access-key create --service-account-name sa-storage-admin > ~/key.txt

export YC_TOKEN=`yc config list | grep token | awk '{print $2}'`
export YC_CLOUD_ID=`yc config list | grep cloud-id | awk '{print $2}'`
export YC_FOLDER_ID=`yc config list | grep folder-id | awk '{print $2}'`
export YC_ZONE=`yc config list | grep zone | awk '{print $2}'`
export YC_KEY_ID=`cat ~/key.txt | grep key_id | awk '{print $2}'`
export YC_KEY_SECRET=`cat ~/key.txt | grep secret | awk '{print $2}'`

echo YC_TOKEN=$YC_TOKEN
echo YC_CLOUD_ID=$YC_CLOUD_ID
echo YC_FOLDER_ID=$YC_FOLDER_ID
echo YC_ZONE=$YC_ZONE
echo YC_KEY_ID=$YC_KEY_ID
echo YC_KEY_SECRET=$YC_KEY_SECRET

sleep 2

mv s3-backet.tf_ s3-backet.tf

terraform init -upgrade -reconfigure -backend-config="access_key=$YC_KEY_ID" -backend-config="secret_key=$YC_KEY_SECRET"

terraform apply -auto-approve

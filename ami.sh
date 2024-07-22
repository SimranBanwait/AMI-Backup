#!/bin/bash

#Usage : Create a servers.txt file and enter their name one by one in the file.
#server1
#server2
#server2

REGION="us-east-1"

# Read the list of server names from servers.txt
while IFS= read -r server; do
    echo " "
    echo "AMI backup has started for server: $server in region: $REGION"
    
    # Get the instance ID of the server
    instance_id=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=$server" --query "Reservations[*].Instances[*].InstanceId" --output text)
    
    if [ -z "$instance_id" ]; then
        echo "Instance ID for server $server not found in region $REGION."
        continue
    fi
    
    # Create an AMI from the instance
    ami_id=$(aws ec2 create-image --region "$REGION" --instance-id "$instance_id" --name "$server-backup-$(date +%Y-%m-%d)" --query "ImageId" --no-reboot --output text)
    
    if [ -z "$ami_id" ]; then
        echo "Failed to create AMI for server $server in region $REGION."
    else
        echo " "
    fi
done < servers.txt

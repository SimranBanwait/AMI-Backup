#!/bin/bash

REGION="us-east-1"

# Server name definitions
declare -A SERVER_GROUPS
SERVER_GROUPS[dev]="dev-insight-1 dev-insight-2 cron-dev-ofsight-3"
SERVER_GROUPS[stg]="stg-ofs-insight cronab-stg"
SERVER_GROUPS[qa]="Post-Fixer-2"
SERVER_GROUPS[beta]="Win-machine"

# Function to perform AMI backup for a given server
perform_backup() {
    local server="$1"
    echo " "
    echo "AMI backup has started for server: $server in region: $REGION"
    
    # Get the instance ID of the server
    instance_id=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:Name,Values=$server" --query "Reservations[*].Instances[*].InstanceId" --output text)
    
    if [ -z "$instance_id" ]; then
        echo "Instance ID for server $server not found in region $REGION."
        return
    fi
    
    # Create an AMI from the instance
    ami_id=$(aws ec2 create-image --region "$REGION" --instance-id "$instance_id" --name "$server-backup-$(date +%Y-%m-%d)" --query "ImageId" --no-reboot --output text)
    
    if [ -z "$ami_id" ]; then
        echo "Failed to create AMI for server $server in region $REGION."
    else
        echo "AMI created successfully for $server: $ami_id"
    fi
}

# Check for flags
if [ "$1" == "-dev" ]; then
    environment="dev"
elif [ "$1" == "-stg" ]; then
    environment="stg"
elif [ "$1" == "-qa" ]; then
    environment="qa"
elif [ "$1" == "-beta" ]; then
    environment="beta"
else
    echo "Please use either -dev, -stg, -qa, or -beta flag to specify the environment."
    exit 1
fi

# Get the servers for the specified environment
IFS=' ' read -ra servers <<< "${SERVER_GROUPS[$environment]}"

# Check if the environment exists
if [ ${#servers[@]} -eq 0 ]; then
    echo "No servers defined for the $environment environment."
    exit 1
fi

# Perform backup for each server in the selected environment
for server in "${servers[@]}"; do
    perform_backup "$server"
done
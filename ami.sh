$REGION = "us-east-1"

# Server name definitions
$SERVER_GROUPS = @{
    dev  = @("dev-insight-1", "dev-insight-2", "cron-dev-ofsight-3")
    stg  = @("stg-ofs-insight", "cronab-stg")
    qa   = @("Post-Fixer-2")
    beta = @("Win-machine")
}

# Function to perform AMI backup for a given server
function Perform-Backup {
    param (
        [string]$server
    )
    
    Write-Output ""
    Write-Output "AMI backup has started for server: ${server} in region: ${REGION}"
    
    # Get the instance ID of the server
    $instance_id = aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$server" --query "Reservations[*].Instances[*].InstanceId" --output text
    
    if ([string]::IsNullOrEmpty($instance_id)) {
        Write-Output "Instance ID for server ${server} not found in region ${REGION}."
        return
    }
    
    # Create an AMI from the instance
    $ami_id = aws ec2 create-image --region $REGION --instance-id $instance_id --name "${server}-backup-$(Get-Date -Format 'yyyy-MM-dd')" --query "ImageId" --no-reboot --output text
    
    if ([string]::IsNullOrEmpty($ami_id)) {
        Write-Output "Failed to create AMI for server ${server} in region ${REGION}."
    } else {
        Write-Output "AMI created successfully for ${server}: ${ami_id}"
    }
}

# Check for flags
$environment = $null
switch ($args[0]) {
    "-dev"  { $environment = "dev" }
    "-stg"  { $environment = "stg" }
    "-qa"   { $environment = "qa" }
    "-beta" { $environment = "beta" }
    default {
        Write-Output "Please use either -dev, -stg, -qa, or -beta flag to specify the environment."
        exit 1
    }
}

# Get the servers for the specified environment
$servers = $SERVER_GROUPS[$environment]

# Check if the environment exists
if ($servers.Count -eq 0) {
    Write-Output "No servers defined for the ${environment} environment."
    exit 1
}

# Perform backup for each server in the selected environment
foreach ($server in $servers) {
    Perform-Backup -server $server
}
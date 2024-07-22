# Create a servers.txt file, add the name of severs as below
# server1
# server2
# server3

$servers = Get-Content -Path "servers.txt"

foreach ($server in $servers) {
    # Describe the instance to get the instance ID
    $instance = aws ec2 describe-instances --filters "Name=tag:Name,Values=$server" --query "Reservations[*].Instances[*].InstanceId" --output text

    if ($instance) {
        # Create an AMI backup
        $ami_id = aws ec2 create-image --instance-id $instance --name "$server-backup-$(Get-Date -Format 'yyyy-MM-dd-HH-mm')" --no-reboot --output text

        if ($ami_id) {
            Write-Output "AMI backup fo server: $server started successfully with AMI ID: $ami_id"
        } else {
            Write-Output "Failed to create AMI backup for $server"
        }
    } else {
        Write-Output "Instance for server $server not found"
    }
}

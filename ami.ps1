# Define AWS region
$region = "us-east-1"

# Read server names from servers.txt
$serverNames = Get-Content -Path "servers.txt"

foreach ($serverName in $serverNames) {
    # Get the instance ID for the server name
    $instance = Get-EC2Instance -Region $region | Where-Object { $_.Tags.Key -eq "Name" -and $_.Tags.Value -eq $serverName -and $_.State.Name -eq "running" }

    if ($instance) {
        # Create AMI backup
        $ami = New-EC2Image -InstanceId $instance.InstanceId -Name "Backup-$($instance.InstanceId)-$(Get-Date -Format 'yyyyMMddHHmmss')" -NoReboot

        # Output the AMI ID
        Write-Output "Created AMI: $($ami.ImageId) for Instance: $($instance.InstanceId)"
    } else {
        Write-Output "No running instance found for server: $serverName"
    }
}


# Post Fixer 2
# Windows-Machine2
# Post Fixer 1

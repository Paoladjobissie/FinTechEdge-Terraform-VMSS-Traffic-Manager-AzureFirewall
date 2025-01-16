# East
# Connect to Azure (ensure the runbook has appropriate permissions)
Connect-AzAccount -Identity

# Parameters
$subscriptionId = "Your Azure Subscription"
$resourceGroupName = "east-us-rg"
$vmName = "east-vm"

# Set the context to the correct subscription
Set-AzContext -SubscriptionId $subscriptionId

# Get VM status
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Status

# Check if the VM is running
if ($vm.Statuses[1].Code -eq "PowerState/running") {
    Write-Output "VM $vmName is running."
} else {
    Write-Output "VM $vmName is not running. Current status: $($vm.Statuses[1].DisplayStatus)"
}

# Optional: Check additional metrics (e.g., CPU, Memory, Disk)
# Add specific metric queries or integrations here if needed

# Example: Send output to a Log Analytics workspace
# Set this up if using Log Analytics for monitoring
Send-AzOperationalInsightsData -WorkspaceId "a2fe3408-518f-4e3f-bdf5-3a0bcb982f0d" -Data @{"VMStatus"=$vm.Statuses[1].DisplayStatus}

Write-Output "Health check completed for VM $vmName."


# WEST
# Connect to Azure (ensure the runbook has appropriate permissions)
Connect-AzAccount -Identity

# Parameters
$subscriptionId = "Your Azure Subscription"
$resourceGroupName = "west-us-rg"
$vmName = "west-vm"

# Set the context to the correct subscription
Set-AzContext -SubscriptionId $subscriptionId

# Get VM status
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Status

# Check if the VM is running
if ($vm.Statuses[1].Code -eq "PowerState/running") {
    Write-Output "VM $vmName is running."
} else {
    Write-Output "VM $vmName is not running. Current status: $($vm.Statuses[1].DisplayStatus)"
}

# Optional: Check additional metrics (e.g., CPU, Memory, Disk)
# Add specific metric queries or integrations here if needed

# Example: Send output to a Log Analytics workspace
# Set this up if using Log Analytics for monitoring
Send-AzOperationalInsightsData -WorkspaceId "a2fe3408-518f-4e3f-bdf5-3a0bcb982f0d" -Data @{"VMStatus"=$vm.Statuses[1].DisplayStatus}

Write-Output "Health check completed for VM $vmName."

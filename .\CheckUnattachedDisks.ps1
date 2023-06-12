<#
.SYNOPSIS
This script scans for unattached Managed Disks in Azure subscriptions. 

.DESCRIPTION
Creeping consumption costs can be associated with disks not being removed once the VM has been deleted. 
This script will scan all Azure subscriptions under the connected account, and list out all the unattached Managed Disks. 
It will also mark the disk names that contain "ASRReplica".

.AUTHOR
Ryan Mangan
Website: ryanmangansitblog.com
Date: 2023

.EXAMPLE
.\CheckUnattachedDisks.ps1

#>

# Import the Azure module
Import-Module Az

# Connect to your Azure account
Connect-AzAccount

# Get all the subscriptions
$subscriptions = Get-AzSubscription

# Emoji warning symbol
$emojiWarning = [char]::ConvertFromUtf32(0x26A0)

# Emoji info symbol
$emojiInfo = [char]::ConvertFromUtf32(0x2139)

# Loop through each subscription
foreach($subscription in $subscriptions) {
    # Select the subscription to work on
    Select-AzSubscription -SubscriptionId $subscription.Id

    # Get all the disks in the selected subscription
    $disks = Get-AzDisk

    # Loop through each disk
    foreach($disk in $disks) {
        # Check if the disk is unattached
        if($disk.ManagedBy -eq $null) {
            # Check if the disk name contains "ASRReplica"
            if($disk.Name -like '*ASRReplica*') {
                # Output the disk name with emoji info
                Write-Output "$emojiInfo INFO: Unattached Disk (ASRReplica): $($disk.Name)"
            }
            else {
                # Output the disk name with emoji warning
                Write-Output "$emojiWarning WARNING: Unattached Disk: $($disk.Name)"
            }
        }
    }
}

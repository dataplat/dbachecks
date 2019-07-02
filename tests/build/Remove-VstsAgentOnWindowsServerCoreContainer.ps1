########################################################################################################################
# Script Disclaimer
########################################################################################################################
# This script is not supported under any Microsoft standard support program or service.
# This script is provided AS IS without warranty of any kind.
# Microsoft disclaims all implied warranties including, without limitation, any implied warranties of
# merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
# performance of this script and documentation remains with you. In no event shall Microsoft, its authors,
# or anyone else involved in the creation, production, or delivery of this script be liable for any damages
# whatsoever (including, without limitation, damages for loss of business profits, business interruption,
# loss of business information, or other pecuniary loss) arising out of the use of or inability to use
# this script or documentation, even if Microsoft has been advised of the possibility of such damages.

<#
.SYNOPSIS
    This script removes the selected Azure Container Instance(s).
.DESCRIPTION
    This script removes the selected Azure Container Instance(s). It leaves the Resource Group (and other resources
     within it) intact. This script is designed and tested to be run from Azure Cloud Shell.
.PARAMETER SubscriptionName
    Name of the Subscription.
.PARAMETER ResourceGroupName
    Name of the Resource Group.
.PARAMETER ContainerName
    Name of the ACI container(s).
.PARAMETER PatToken
    PAT token required to log in to Azure DevOps to delete the Agent's registration from the pool.
.PARAMETER AzureDevOpsAccountName
    Name of the Azure DevOps account that the Agent is registered to.
.PARAMETER AgentPoolName
    Name of the Agent Pool that holds the Agent to delete.
.EXAMPLE
    .\Remove-VstsAgentOnWindowsServerCoreContainer.ps1 -SubscriptionName "<subscription name>" -ResourceGroupName "<resource group name>" -ContainerName "<container 1 name>", "<container 2 name>" -PatToken "<pat token to log in>" -AzureDevOpsAccountName "<ADOS account name>" -AgentPoolName "<name of the Agent Pool>"
    This removes the 2 requested containers and their registrations from Azure DevOps. It leaves the Resource Group (and other resources within) intact.
.INPUTS
    <none>
.OUTPUTS
    <none>
.NOTES
    Version:        1.1
    Author:         Mate Barabas
    Creation Date:  2018-08-29
    Change log:
    - v1.1 (2019-04-06): the script now removes the Agent's registration from the Agent pool
#>

param(

    [Parameter(Mandatory = $true)][string]$SubscriptionName,
    [Parameter(Mandatory = $true)][string]$ResourceGroupName,
    [Parameter(Mandatory = $true)][array]$ContainerName,
    [Parameter(Mandatory = $true)][string]$PatToken, #Personal access token
    [Parameter(Mandatory = $true)][string]$AzureDevOpsAccountName, #Azure DevOps account name
    [Parameter(Mandatory = $true)][string]$AgentPoolName #Azure DevOps Agent pool name

)


#region Functions

function Set-AzureContext
{

    param (

        [Parameter(Mandatory = $false)][string]$SubscriptionName

    )


    # Select the desired Subscription based on the Subscription name provided
    if ($SubscriptionName)
    {
        $Subscription = (Get-AzureRmSubscription | Where-Object { $_.Name -eq $SubscriptionName })
            
        if (-not $Subscription)
        {
            Write-Error "There's no Subscription available with the provided name."
            return
        }
        else
        {
            $SubscriptionId = $Subscription.Id
            Select-AzureRmSubscription -SubscriptionId $SubscriptionId | Out-Null
            Write-Output "The following subscription was selected: ""$SubscriptionName"""
        }
    }
    # If no Subscription name was provided select the active Subscription based on the existing context
    else
    {
        $SubscriptionName = (Get-AzureRmContext).Subscription.Name
        $Subscription = (Get-AzureRmSubscription | Where-Object { $_.Name -eq $SubscriptionName })
        Write-Output "The following subscription was selected: ""$SubscriptionName"""
    }

    if ($Subscription.Count -gt 1)
    {
        Write-Error "You have more then 1 Subscription with the same name. Exiting..."
        return
    }
}

function Remove-Container
{

    param (

        [Parameter(Mandatory = $true)][array]$ContainerName

    )

    foreach ($Name in $ContainerName)
    {
        $Container = Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
        if (-not $Container)
        {
            Write-Warning "No ACI container exists with the provided name ($Name)."
        }
        else 
        {
            Write-Warning "Removing selected ACI container ($Name)..."    
            Remove-AzureRmContainerGroup -ResourceGroupName $ResourceGroupName -Name $Name -Confirm:$false

            # Check success
            $Container = Get-AzureRmContainerGroup -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
            if ($null -eq $Container)
            {
                Write-Output "ACI container ""$Name"" successfully deleted."
                if (-not ($PatToken -and $AgentPoolName -and $AzureDevOpsAccountName))
                {
                    Write-Warning "One or more containers have been deleted. Don't forget to clean your Agent pool in Azure DevOps (remove any agents that were created in a previous iteration and are now offline)!"
                }
            }
        }
    }

}

function Remove-AzureDevOpsAgentFromPool
{
    Param(
        [string]$PatToken, #Personal access token
        [string]$AzureDevOpsAccountName, #Azure DevOps account name
        [string]$AgentPoolName, #Azure DevOps Agent pool name
        [array]$ContainerName  #Azure DevOps Agent pool name
    )
        
    $base64AuthInfo = [System.Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PatToken)"))
    $Header = @{Authorization = ("Basic $base64AuthInfo") }

    # Get Agent Pool
    Write-Output "Getting Agent Pool ($AgentPoolName)..."
    $uri = "https://dev.azure.com/$AzureDevOpsAccountName/_apis/distributedtask/pools"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header
    $AgentPool = $result.value | Where-Object { $_.Name -eq "$AgentPoolName" }
    $AgentPoolId = $AgentPool.id

    if (-not $AgentPoolId)
    {
        Write-Error "The Agent Pool ($AgentPoolName) doesn't exist!"
    }
    else
    {
        # Get Agents
        Write-Output "Getting Agents from Pool..."
        $uri = "https://dev.azure.com/$AzureDevOpsAccountName/_apis/distributedtask/pools/$AgentPoolId/agents?includeCapabilities=false&includeAssignedRequest=true"
        $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header
        $Agents = $result.value

        if (-not $Agents)
        {
            Write-Output "There are no Agents in this Agent Pool"
        }
        else
        {
            Write-Output "The following agents were found:"
            foreach ($Agent in $Agents)
            {
                $AgentName = $Agent.name
                $AgentStatus = $Agent.status
                Write-Output "$AgentName ($AgentStatus)"
            }

            # Delete Agent(s) from Pool
            foreach ($Name in $ContainerName)
            {
                Write-Output "Attempting to remove any Agent(s) that belonged to this ACI container: $Name..."
                foreach ($Agent in $Agents)
                {
                    $AgentName = $Agent.name

                    if ($AgentName -match "^$Name-")
                    {
                        # Delete Agent
                        $AgentIds = $Agent.id
                        foreach ($AgentId in $AgentIds)
                        {
                            Write-Output "Deleting Agent ($AgentName) - (Agent ID: $AgentId)..."
                            $uri = "https://dev.azure.com/$AzureDevOpsAccountName/_apis/distributedtask/pools/$AgentPoolId/agents/$($AgentId)?api-version=5.0"
                            $result = Invoke-RestMethod -Uri $uri -Method DELETE -ContentType "application/json" -Headers $Header

                            # Check success
                            Write-Output "Checking if the Agent ($AgentName) - (Agent ID: $AgentId) is still there..."
                            $uri = "https://dev.azure.com/$AzureDevOpsAccountName/_apis/distributedtask/pools/$AgentPoolId/agents?includeCapabilities=false&includeAssignedRequest=true"
                            $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header
                            $AgentStillThere = $result.value.id -contains $AgentId
                            if ($AgentStillThere)
                            {
                                Write-Warning "Agent ($AgentName) could not be deleted. Don't forget to clean your Agent pool in Azure Devops (remove any agents that were created in a previous iteration and are now offline)!"
                            }
                            else
                            {
                                Write-Output "Agent ($AgentName) successfully deleted."    
                            }
                        }
                    }
                }
            }
        }
    }
}

#endregion


#region Main

# Login to Azure and select Subscription
Set-AzureContext -SubscriptionName $SubscriptionName

# Delete selected containers
Remove-Container -ContainerName $ContainerName

# Delete Agent registration from Azure DevOps Agent pool
Remove-AzureDevOpsAgentFromPool -PatToken $PatToken -AzureDevOpsAccountName $AzureDevOpsAccountName -AgentPoolName $AgentPoolName -ContainerName $ContainerName

#endregion
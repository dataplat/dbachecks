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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUsernameAndPasswordParams", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidTrailingWhiteSpace", "")]
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
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqnC17MmjLJIModmCDDzDSlmd
# OEGgggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTRWXL978E8G0Ad7rqqqhCDE2a2
# WDANBgkqhkiG9w0BAQEFAASCAQAJLXwSjpFXNvsRTGaJCps/BdPTa4vslCLFIiqk
# Hnk9YAdT4avJIEWFJeYPtNG9YYMueEQ778aigPyvFDwdIormXm5ECfm3Ijfo2Pn2
# RXd8zBwb/bNnAYsnmBLw1J9nCz0umVVqv2gGGDZWykclyZXFd4C+qZihRoRS6bUi
# rDUDkSN61nPtcv3naa2a99NV8qcZeXEvXhivDxz7gqGSTqWCEDzt868q4dAN81gi
# sWbrsiUCrNL313euZRW5zH6DICgmXLacqKam1gvIdWqLpYVX/OSfZh1DIR7UG/xm
# CFMzSSJ0SeOYYEGQd6vzv9qz2woDmsQcsbnHqZjimWzEIeJa
# SIG # End signature block

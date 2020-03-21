$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# Get all the info in the function
function Get-ClusterObject {
    [CmdletBinding()]
    param (
        [string]$ClusterVM
    )

    [pscustomobject]$return = @{}
    # Don't think you can use the cluster name here it won't run remotely
    try {
        $ErrorActionPreference = 'Stop'
        $return.Cluster = (Get-Cluster -Name $clustervm)
        $return.Nodes = (Get-ClusterNode -Cluster $clustervm)
        $return.Resources = (Get-ClusterResource -Cluster $clustervm)
        $return.Network = (Get-ClusterNetwork -Cluster $clustervm)
        $return.Groups = (Get-ClusterGroup -Cluster $clustervm)
        $return.AGs = $return.Resources.Where{ $psitem.ResourceType -eq 'SQL Server Availability Group' }
    }
    catch {
        $return.Cluster = 'FailedToConnect'
        $return.Nodes = 'FailedToConnect'
        $return.Resources = 'FailedToConnect'
        $return.Network = 'FailedToConnect'
        $return.Groups = 'FailedToConnect'
        $return.AGs = 'FailedToConnect'
    }
    $return.AvailabilityGroups = @{}
    #Add all the AGs
    foreach ($Ag in $return.AGs) {
        try {
            $return.AvailabilityGroups[$AG.Name] = Get-DbaAvailabilityGroup -SqlInstance $Ag.OwnerNode.Name -AvailabilityGroup $AG.Name
        }
        catch {
            $return = $null
        }
    }
    Return $return
}

# Import module or bomb out

# needs the failover cluster module
if (-not (Get-Module FailoverClusters)) {
    try {
        if($IsCoreCLR){
            Stop-PSFFunction -Message "FailoverClusters module cannot be loaded in PowerShell Core unfortunately" -ErrorRecord $psitem
        return
        }else{
            Import-Module FailoverClusters -ErrorAction Stop
        }
    }
    catch {
        Stop-PSFFunction -Message "FailoverClusters module could not load - Please install the Failover Cluster module using Windows Features " -ErrorRecord $psitem
        return
    }
}

# Grab some values
$clusters = Get-DbcConfigValue app.cluster
$skiplistener = Get-DbcConfigValue skip.hadr.listener.pingcheck
$domainname = Get-DbcConfigValue domain.name
$tcpport = Get-DbcConfigValue policy.hadr.tcpport

#Check for Cluster config value
if ($clusters.Count -eq 0) {
    Write-Warning "No Clusters to look at. Please use Set-DbcConfig -Name app.cluster to add clusters for checking"
    break
}

foreach ($clustervm in $clusters) {
    try{
    # pick the name here for the output - we cant use it as we are accessing remotely
    $clustername = (Get-Cluster -Name $clustervm -ErrorAction Stop).Name
    }
    catch{
        # so that we dont get the error and Get-ClusterObject fills it as FailedtoConnect
        $clustername = $clustervm
    }

    Describe "Cluster $clustername Health using Node $clustervm" -Tags ClusterHealth, $filename {
        $return = @(Get-ClusterObject -Clustervm $clustervm)

        Context "Cluster nodes for $clustername" {
            @($return.Nodes).ForEach{
                It "Node $($psitem.Name) should be up" {
                    $psitem.State | Should -Be 'Up' -Because 'Every node in the cluster should be available'
                }
            }
        }
        Context "Cluster resources for $clustername" {
            # Get the resources that are no IP Addresses with an owner of Availability Group
            $return.Resources.Where{ ( $_.ResourceType -in ($_.ResourceType -ne 'IP Address') ) -and ($_.OwnerGroup -in $Return.Ags) }.ForEach{
                It "Resource $($psitem.Name) should be online" {
                    $psitem.State | Should -Be 'Online' -Because 'All of the cluster resources should be online'
                }
            }
            # Get the resources where IP Address is owned by AG and group by AG
            @($return.Resources.Where{$_.ResourceType -eq 'IP Address' -and $_.OwnerGroup -in $return.AGs} | Group-Object -Property OwnerGroup).ForEach{
                It "One of the IP Addresses for Availability Group $($Psitem.Name) Should be online" {
                    $psitem.Group.Where{$_.State -eq 'Online'}.Count | Should -Be 1 -Because "There should be one IP Address online for Availability Group $($PSItem.Name)"
                }
            }
        }
        Context "Cluster networks for $clustername" {
            @($return.Network).ForEach{
                It "$($psitem.Name) should be up" {
                    $psitem.State | Should -Be 'Up' -Because 'All of the CLuster Networks should be up'
                }
            }
        }

        Context "HADR status for $clustername" {
            @($return.Nodes).ForEach{
                It "HADR should be enabled on the node $($psitem.Name)" {
                    try {
                        $HADREnabled = (Get-DbaAgHadr -SqlInstance $psitem.Name -WarningAction SilentlyContinue).IsHadrEnabled
                    }
                    catch {
                        $HADREnabled = $false
                    }
                    $HADREnabled | Should -BeTrue -Because 'All of the nodes should have HADR enabled'
                }
            }
        }
        $Ags = $return.AGs.Name
        foreach ($Name in $Ags) {
            $Ag = @($return.AvailabilityGroups[$Name])

            Context "Cluster Connectivity for Availability Group $($AG.Name) on $clustername" {
                @($AG.AvailabilityGroupListeners).ForEach{
                    try{
                        $results = Test-DbaConnection -sqlinstance $_.Name
                    }
                    Catch{
                        $results = [PSCustomObject]@{
                            IsPingable = $false
                            ConnectSuccess  = $false
                            DomainName  = $false
                            TCPPort  = $false
                        }
                    }

                    It "Listener $($results.SqlInstance) should be pingable" -skip:$skiplistener {
                        $results.IsPingable | Should -BeTrue -Because 'The listeners should be pingable'
                    }
                    It "Listener $($results.SqlInstance) should be able to connect with SQL" {
                        $results.ConnectSuccess | Should -BeTrue -Because 'The listener should process SQL commands successfully'
                    }
                    It "Listener $($results.SqlInstance) domain name should be $domainname" {
                        $results.DomainName | Should -Be $domainname -Because "$domainname is what we expect the domain name to be"
                    }
                    It "Listener $($results.SqlInstance) TCP port should be in $tcpport" {
                        $results.TCPPort | Should -BeIn $tcpport -Because "We expect the TCP Port to be in $tcpport"
                    }
                }

                @($AG.AvailabilityReplicas).ForEach{
                    $results = Test-DbaConnection -sqlinstance $PsItem.Name
                    It "Replica $($results.SqlInstance) should be Pingable" {
                        $results.IsPingable | Should -BeTrue -Because 'Each replica should be pingable'
                    }
                    It "Replica $($results.SqlInstance) should be able to connect with SQL" {
                        $results.ConnectSuccess | Should -BeTrue -Because 'Each replica should be able to process SQL commands'
                    }
                    It "Replica $($results.SqlInstance) domain name should be $domainname" {
                        $results.DomainName | Should -Be $domainname -Because "$domainname is what we expect the domain name to be"
                    }
                    It "Replica $($results.SqlInstance) TCP port should be in $tcpport" {
                        $results.TCPPort | Should -BeIn $tcpport -Because "We expect the TCP Port to be in $tcpport"
                    }
                }
            }

            Context "Availability group status for $($AG.Name) on $clustername" {
                @($AG.AvailabilityReplicas).ForEach{
                    It "$($psitem.Name) replica should not be in unknown availability mode" {
                        $psitem.AvailabilityMode | Should -Not -Be 'Unknown' -Because 'The replica should not be in unknown state'
                    }
                }
                @($AG.AvailabilityReplicas).Where{ $psitem.AvailabilityMode -eq 'SynchronousCommit' }.ForEach{
                    It "$($psitem.Name) replica should be synchronised" {
                        $psitem.RollupSynchronizationState | Should -Be 'Synchronized' -Because 'The synchronous replica should be synchronised'
                    }
                }
                $AG.AvailabilityReplicas.Where{ $psitem.AvailabilityMode -eq 'ASynchronousCommit' }.ForEach{
                    It "$($psitem.Name) replica should be synchronising" {
                        $psitem.RollupSynchronizationState | Should -Be 'Synchronizing' -Because 'The asynchronous replica should be synchronizing '
                    }
                }
                @($AG.AvailabilityReplicas).Where.ForEach{
                    It "$($psitem.Name) replica should be connected" {
                        $psitem.ConnectionState | Should -Be 'Connected' -Because 'The replica should be connected'
                    }
                }
            }

            Context "Database availability group status for $($AG.Name) on $clustername" {
                @($ag.AvailabilityReplicas.Where{$_.AvailabilityMode -eq 'SynchronousCommit' }).ForEach{
                    @(Get-DbaAgDatabase -SqlInstance $psitem.Name -AvailabilityGroup $Ag.Name).ForEach{
                        It "Database $($psitem.DatabaseName) should be synchronised on the replica $($psitem.Replica)" {
                            $psitem.SynchronizationState | Should -Be 'Synchronized'  -Because 'The database on the synchronous replica should be synchronised'
                        }
                        It "Database $($psitem.DatabaseName) should be failover ready on the replica $($psitem.Replica)" {
                            $psitem.IsFailoverReady | Should -BeTrue -Because 'The database on the synchronous replica should be ready to failover'
                        }
                        It "Database $($psitem.DatabaseName) should be joined on the  replica $($psitem.Replica)" {
                            $psitem.IsJoined | Should -BeTrue -Because 'The database on the synchronous replica should be joined to the availability group'
                        }
                        It "Database $($psitem.DatabaseName) should not be suspended on the replica $($psitem.Replica)" {
                            $psitem.IsSuspended | Should -Be  $False -Because 'The database on the synchronous replica should not be suspended'
                        }
                    }
                }
                @($ag.AvailabilityReplicas.Where{$_.AvailabilityMode -eq 'AsynchronousCommit' }).ForEach{
                    @(Get-DbaAgDatabase -SqlInstance $PSItem.Name -AvailabilityGroup $Ag.Name).ForEach{
                        It "Database $($psitem.DatabaseName) should be synchronising on the secondary as it is Async" {
                            $psitem.SynchronizationState | Should -Be 'Synchronizing' -Because 'The database on the asynchronous secondary replica should be synchronising'
                        }
                        It "Database $($psitem.DatabaseName) should not be failover ready on the secondary replica $($psitem.Replica)" {
                            $psitem.IsFailoverReady | Should -BeFalse -Because 'The database on the asynchronous secondary replica should be ready to failover'
                        }
                        It "Database $($psitem.DatabaseName) should be joined on the secondary replica $($psitem.Replica)" {
                            $psitem.IsJoined | Should -BeTrue -Because 'The database on the asynchronous secondary replica should be joined to the availability group'
                        }
                        It "Database $($psitem.DatabaseName) should not be suspended on the secondary replica $($psitem.Replica)" {
                            $psitem.IsSuspended | Should -Be  $False -Because 'The database on the asynchronous secondary replica should not be suspended'
                        }
                    }
                }
            }
        }
        @($return.Nodes).ForEach{
            Context "Always On extended event status for replica $($psitem.Name) on $clustername" {
                try {
                    $Xevents = Get-DbaXEsession -SqlInstance $psitem.Name -WarningAction SilentlyContinue
                }
                catch {
                    $Xevents = 'FailedToConnect'
                }
                It "Replica $($psitem.Name) should have an extended event session called AlwaysOn_health" {
                    $Xevents.Name  | Should -Contain 'AlwaysOn_health' -Because 'The extended events session should exist'
                }
                It "Replica $($psitem.Name) Always On Health extended event session should be running" {
                    $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.Status | Should -Be 'Running' -Because 'The extended event session will enable you to troubleshoot errors'
                }
                It "Replica $($psitem.Name) Always On Health extended event session should be set to auto start" {
                    $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.AutoStart | Should -BeTrue  -Because 'The extended event session will enable you to troubleshoot errors'
                }
            }
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZghzF/X40NGvrsVYaBqx25oF
# 9qWgggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRVvHGgkzX4zIaUF9r37drpMuAD
# uDANBgkqhkiG9w0BAQEFAASCAQBNpwJmApoJh/5EYTSvzk/cxtNseg1iIj5Q3Xug
# g3akpOOdxDTOzV22azFSDn7/ojmaTXUTH41eXENltXSpyLb8W+I+QuF4JqJuo+9g
# yWV9eUkd7bSoVweg3UDB50eu/kBTOWrIqj3Znf5SMQHUt2h5dXCk9SY5WcIjrTLQ
# y0tOkAlYZ9xYFjI6SKayNM7zSQKVWh5xoymsGeSc9dZqfFy1mjralkrSX+/1Dfxz
# jbgVLP2jkEDPoLbhalJOrBuG7Bn3MxEfsGBJBEcZdC6xUmIQy8gzG2aAyLHkR+0G
# Mp0ASdr16LW2rvHHqcsIqJPf7QlgDXXqZ/Ee7X7NMtm+wl/E
# SIG # End signature block

$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# Get all the info in the function
function Get-ClusterObject {
    [CmdletBinding()]
    param (
        [string]$ClusterVM
    )

    [PsCustomObject]$return = @{ }
    # Don't think you can use the cluster name here it won't run remotely
    try {
        $ErrorActionPreference = 'Stop'
        $return.Cluster = (Get-Cluster -Name $ClusterVM)
        $return.Nodes = (Get-ClusterNode -Cluster $ClusterVM)
        $return.Resources = (Get-ClusterResource -Cluster $ClusterVM)
        $return.Network = (Get-ClusterNetwork -Cluster $ClusterVM)
        $return.Groups = (Get-ClusterGroup -Cluster $ClusterVM)
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
    $return.AvailabilityGroups = @{ }
    #Add all the AGs
    foreach ($AGResource in $return.AGs) {
        try {
            # Because several replicas can be on the same cluster node,
            # cluster node can appear several times, then we want to
            # avoid duplicate detection of replicas
            If ($PreviousClusterNode -ne $AGResource.OwnerNode.Name) {
                $PreviousClusterNode = $AGResource.OwnerNode.Name
                # We get cluster node owner first ...
                # We need then for each owner to find out the corresponding replicas => SQL Instance Name + Port
                $Replicas = Find-DbaInstance -ComputerName $AGResource.OwnerNode.Name
            }

            # Finally for each replica detected (SQL Server + Port)
            # We try to find the corresponding AG(s) info
            foreach ($replica in $Replicas){
                $AGs = Get-DbaAvailabilityGroup -SqlInstance "$($replica.ComputerName),$($replica.Port)"

                foreach ($AG in $AGs){
                    If ($AG.AvailabilityGroup -eq $AGResource.Name) {
                        $return.AvailabilityGroups[$AGResource.Name] = $AG
                    }
                }
            }
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
        if ($IsCoreCLR) {
            Stop-PSFFunction -Message "FailoverClusters module cannot be loaded in PowerShell Core unfortunately" -ErrorRecord $psitem
            return
        }
        else {
            Import-Module FailoverClusters -ErrorAction Stop
        }
    }
    catch {
        Stop-PSFFunction -Message "FailoverClusters module could not load - Please install the Failover Cluster module using Windows Features " -ErrorRecord $psitem
        return
    }
}
else {
    if ($IsCoreCLR) {
        Stop-PSFFunction -Message "FailoverClusters module cannot be loaded in PowerShell Core unfortunately" -ErrorRecord $psitem
        return
    }
}

# Grab some values
$clusters = Get-DbcConfigValue app.cluster
$skipClusterNetInterface = Get-DbcConfigValue skip.cluster.netclusterinterface
$skipAgListenerPing = Get-DbcConfigValue skip.hadr.listener.pingcheck
$skipAgListenerTcpPort = Get-DbcConfigValue skip.hadr.listener.tcpport
$skipReplicaTcpPort = Get-DbcConfigValue skip.hadr.replica.tcpport
$domainName = Get-DbcConfigValue domain.name
$agTcpPort = Get-DbcConfigValue policy.hadr.agtcpport
$sqlTcpPort = Get-DbcConfigValue policy.hadr.tcpport

# hadr endpoint config parameters
$hadrEndPointName = Get-DbcConfigValue policy.hadr.endpointname
$hadrEndPointPort = Get-DbcConfigValue policy.hadr.endpointport
$hadrSessionTimeout = Get-DbcConfigValue policy.hadr.sessiontimeout

# cluster config parameters
$clustAgResFailureConditionLevel = Get-DbcConfigValue policy.hadr.failureconditionlevel
$clustAgResHealthCheckTimeout = Get-DbcConfigValue policy.hadr.healthchecktimeout
$clustAgResLeaseTimeout = Get-DbcConfigValue policy.hadr.leasetimeout
$clustPrivateNetworkProtocolsIPV4 = Get-DbcConfigValue policy.cluster.NetworkProtocolsIPV4
$clustAgReshostRecordTTL = Get-DbcConfigValue policy.cluster.hostrecordttl
$clustAgResRegisterAllProvidersIP = Get-DbcConfigValue policy.cluster.registerallprovidersIP

#Check for Cluster config value
if ($clusters.Count -eq 0) {
    Write-Warning "No Clusters to look at. Please use Set-DbcConfig -Name app.cluster to add clusters for checking"
    break
}


foreach ($clustervm in $clusters) {
    try {
        # pick the name here for the output - we cant use it as we are accessing remotely
        $clustername = (Get-Cluster -Name $clustervm -ErrorAction Stop).Name
    }
    catch {
        # so that we don't get the error and Get-ClusterObject fills it as FailedtoConnect
        $clustername = $clustervm
    }

    Describe "Cluster $clustername Health using Node $clustervm" -Tags ClusterHealth, $filename {
        $return = @(Get-ClusterObject -ClusterVM $clustervm)

        Context "Cluster nodes for $clustername" {
            @($return.Nodes).ForEach{
                It "This node should be available - Node $($psitem.Name)" {
                    $psitem.State | Should -Be 'Up' -Because 'Every node in the cluster should be available'
                }
            }
        }
        Context "Cluster resources for $clustername" {
            # Get the resources that are no IP Addresses with an owner of Availability Group
            $return.Resources.Where{ ( $_.ResourceType -in ($_.ResourceType -ne 'IP Address') ) -and ($_.OwnerGroup -in $Return.Ags) }.ForEach{
                It "This resource should be online - Resource $($psitem.Name)" {
                    $psitem.State | Should -Be 'Online' -Because 'All of the cluster resources should be online'
                }
            }
            # Get the resources where IP Address is owned by AG and group by AG
            @($return.Resources.Where{ $_.ResourceType -eq 'IP Address' -and $_.OwnerGroup -in $return.AGs } | Group-Object -Property OwnerGroup).ForEach{
                It "One of the IP Addresses should be online for AvailabilityGroup $($Psitem.Name)" {
                    $psitem.Group.Where{ $_.State -eq 'Online' }.Count | Should -Be 1 -Because "There should be one IP Address online for Availability Group $($PSItem.Name)"
                }
            }

            $return.Resources.Where{ $_.ResourceType -eq 'Network Name' -and $_.OwnerGroup -in $return.AGs }.ForEach{
                It "HostRecordTTL should be $clustAgReshostRecordTTL for Resource $($PSItem.Name)"  {
                    $hostRecordTTL = ($PSItem | Get-ClusterParameter | Where-Object { $_.Name -eq 'HostRecordTTL' }).Value
                    $hostRecordTTL | Should -be $clustAgReshostRecordTTL -Because "$clustAgReshostRecordTTL is what we expect to be for hostRecordTTL"
                }
                It "RegisterAllProvidersIP should be $clustAgResRegisterAllProvidersIP for Resource $($PSItem.Name)" {
                    $RegisterAllProvidersIP = ($PSItem | Get-ClusterParameter | Where-Object { $_.Name -eq 'RegisterAllProvidersIP' }).Value
                    $RegisterAllProvidersIP | Should -be $clustAgResRegisterAllProvidersIP -Because "$clustAgResRegisterAllProvidersIP is what we expect to be for RegisterAllProvidersIP"
                }
                It "StatusNetBIOS should be $clustAgResStatusNetBIOS for Resource $($PSItem.Name)" {
                    $StatusNetBIOS = ($PSItem | Get-ClusterParameter | Where-Object { $_.Name -eq 'StatusNetBIOS' }).Value
                    $StatusNetBIOS | Should -be 0 -Because "NetBIOS State should be healthy"
                }
                It "StatusDNS should be $clustAgStatusDNS for Resource $($PSItem.Name)" {
                    $StatusDNS = ($PSItem | Get-ClusterParameter | Where-Object { $_.Name -eq 'StatusDNS' }).Value
                    $StatusDNS | Should -be 0 -Because "DNS State should be healthy"
                }
                It "StatusKerberos should be $clustAgStatusKerberos for Resource $($PSItem.Name)" {
                    $StatusKerberos = ($PSItem | Get-ClusterParameter | Where-Object { $_.Name -eq 'StatusKerberos' }).Value
                    $StatusKerberos | Should -be 0 -Because "Kerberos State should be healthy"
                }
            }
        }
        Context "Cluster network for $clustername" {
            It "At least 2 dedicated networks for the cluster should exist for cluster $clustername" -Skip:$skipClusterNetInterface {
                $return.Network.count | Should -BeGreaterOrEqual 2 -Because "To prevent heartbeat traffic to be overwhelmed by the public workload"
            }
            It "One Cluster Network interface should be dedicated for cluster traffic for cluster $clustername" -Skip:$skipClusterNetInterface {
                $return.network.Role | Should -Contain 'Cluster' -Because "Heartbeat traffic is sensitive to network latency and network interface should be dedicated for this specific usage"
            }
            It "One Cluster Network interface should be dedicated for public traffic for cluster $clustername" {
                $return.network.Role | Should -Contain 'ClusterAndClient' -Because "Public network is mandatory to handle public workload"
            }

            $ClusterNetwork = $return.Network | Where-Object { $_.Role -eq 'Cluster' }
            Foreach ($node in $return.Nodes){

                $ReplicaNetInterfaces = Get-DbaWsfcNetworkInterface -ComputerName $clustervm | `
                                        Where-Object { $_.Network -eq $ClusterNetwork.Name -And $_.Node -eq $node.Name}

                Foreach ($rni in $ReplicaNetInterfaces | Where-Object { $_.IPv4Addresses -ne $null }){
                    $netinterface = ($rni.Name.Split('-')[1]).Trim()
                    $netbindings = Get-NetAdapter -Name $netinterface -CimSession $node.Name | `
                                    Get-NetAdapterBinding | `
                                    Where-Object { $_.Enabled -eq $true }
                    It "Only required network protocols should be configured for IPV4 cluster interface on node $($node.Name)" -Skip:$skipClusterNetInterface {
                        $netbindings.Count | Should -Be $clustPrivateNetworkProtocolsIPV4.Count -Because "Heartbeat traffic is sensitive to network latency and network protocols should be configured optimally"
                    }
                    $IpConfig = Get-NetIPConfiguration -CimSession $node.Name -InterfaceAlias $netinterface
                    It "No default gateway should be configured for cluster network interface - Node $($node.Name)" -Skip:$skipClusterNetInterface {
                        $IpConfig.IPv4DefaultGateway | Should -BeNullOrEmpty -Because "Heartbeat traffic should not be routable"
                    }
                    $IpDNS = Get-DnsClientServerAddress -CimSession $node.Name -InterfaceAlias $netinterface
                    It "No DNS entries should be configured for cluster network interface - Node $($node.Name)" -Skip:$skipClusterNetInterface {
                        $IpDNS.ServerAddresses.Count | Should -Be 0 -Because "Heartbeat traffic doesn't use DNS resolution"
                    }
                    $DNSRegistration = Get-NetAdapter `
                                        -Name $netinterface `
                                        -CimSession $node.Name | Get-DNSClient
                    It "DNS Registration should be disabled for cluster network interface - Node $($node.Name)" -Skip:$skipClusterNetInterface {
                        $DNSRegistration.RegisterThisConnectionsAddress | Should -Be $false -Because "Heartbeat traffic doesn't use DNS resolution"
                    }
                    $AdapterNetBios = Get-CimInstance `
                                        -ClassName 'Win32_NetworkAdapterConfiguration' `
                                        -CimSession $node.Name `
                                        -Filter "InterfaceIndex = $((Get-NetAdapter -CimSession $node.Name -Name $netinterface).ifIndex)"

                    It "NetBios Over TCP/IP should be disabled for cluster network interface - Node $($node.Name)" -Skip:$skipClusterNetInterface {
                        $AdapterNetBios.TcpipNetbiosOptions | Should -Be 2 -Because "Heartbeat traffic doesn't use NetBios resolution"
                    }
                }
            }

            @($return.Network).ForEach{
                It "The Network should be up - Network $($psitem.Name)" {
                    $psitem.State | Should -Be 'Up' -Because 'All of the Cluster Networks should be up'
                }
            }
        }

        $AGResources = $return.Resources | Where-Object { $_.ResourceType -eq 'SQL Server Availability Group'}

        Context "Cluster Availability Group Resources for $clustername" {
            ForEach($AGRes in $AGResources){
                It "Failure Condition Level should be $clustAgResFailureConditionLevel for AG Resource $($AGRes.Name)" {
                    $AGResourceResult = $AGRes | Get-ClusterParameter | Where-Object { $_.Name -eq 'FailureConditionLevel' }
                    $AGResourceResult.Value | Should -Be $clustAgResFailureConditionLevel -Because "$clustAgResFailureConditionLevel is what we expect to be for Flexible automatic failover policy"
                }
                It "HealthCheck Timeout should be $clustAgResHealthCheckTimeout for AG Resource $($AGRes.Name)" {
                    $AGResourceResult = $AGRes | Get-ClusterParameter | Where-Object { $_.Name -eq 'HealthCheckTimeout' }
                    $AGResourceResult.Value | Should -Be $clustAgResHealthCheckTimeout -Because "$clustAgResHealthCheckTimeout is what we expect to be for health check timeout"
                }
                It "Lease Timeout should be $clustAgResLeaseTimeout for AG Resource $($AGRes.Name)" {
                    $AGResourceResult = $AGRes | Get-ClusterParameter | Where-Object { $_.Name -eq 'LeaseTimeout' }
                    $AGResourceResult.Value | Should -Be $clustAgResLeaseTimeout -Because "$clustAgResLeaseTimeout is what we expect to be for lease timeout"
                }
            }
        }

        $AGs = $return.AGs.Name
        foreach ($AGName in $AGs) {
            $AG = @($return.AvailabilityGroups[$AGName])

            Context "HADR status for $($AG.SqlInstance) on $clustername" {
                It "HADR should be enabled on the replica $($AG.SqlInstance)" {
                    try {
                        $HADREnabled = (Get-DbaAgHadr -SqlInstance $AG.SqlInstance -WarningAction SilentlyContinue).IsHadrEnabled
                    }
                    catch {
                        $HADREnabled = $false
                    }
                    $HADREnabled | Should -BeTrue -Because 'All of the nodes should have HADR enabled'
                }
            }

            Context "Cluster Connectivity for Availability Group $($AG.Name) on $clustername" {
                @($AG.AvailabilityGroupListeners).ForEach{
                    try {
                        $results = Test-DbaConnection -SqlInstance $_.Name
                    }
                    Catch {
                        $results = [PSCustomObject]@{
                            IsPingable     = $false
                            ConnectSuccess = $false
                            DomainName     = $false
                            TCPPort        = $false
                        }
                    }

                    It "Listener should be pingable for $($results.SqlInstance)" -skip:$skipaglistenerping {
                        $results.IsPingable | Should -BeTrue -Because 'The listeners should be pingable'
                    }
                    It "Listener should be connectable on $($results.SqlInstance)" {
                        $results.ConnectSuccess | Should -BeTrue -Because 'The listener should process SQL commands successfully'
                    }

                    It "Listener domain name should be $domainname on $($results.SqlInstance)" {
                        $results.DomainName | Should -Be $domainname -Because "$domainname is what we expect the domain name to be"
                    }
                }

                @($AG.AvailabilityReplicas).ForEach{
                    $results = Test-DbaConnection -SqlInstance $PsItem.Name
                    It "Replica should be Pingable for $($results.SqlInstance)" {
                        $results.IsPingable | Should -BeTrue -Because 'Each replica should be pingable'
                    }
                    It "Should be able to connect with SQL on Replica $($results.SqlInstance)" {
                        $results.ConnectSuccess | Should -BeTrue -Because 'Each replica should be able to process SQL commands'
                    }

                    It "Replica domain name should be $domainname on Replica $($results.SqlInstance)" {
                        $results.DomainName | Should -Be $domainname -Because "$domainname is what we expect the domain name to be"
                    }

                    # Consolidated environments with multi-instances / AG replicas
                    # In this case we cannot configure the same tcpport than those used for AG listeners
                    # TCP port conflict
                    # Adding exclusion for these scenarios

                    It "HADR TCP port should be in $tcpport for replica $($results.SqlInstance)" -Skip:$skipReplicaTcpPort {
                        $results.TCPPort | Should -BeIn $sqlTcpPort -Because "We expect the TCP Port to be in $sqlTcpPort"
                    }

                    $resultshadrendpoint = Get-DbaEndpoint -SqlInstance $results.SqlInstance -Endpoint $hadrEndPointName
                    It "HADR endpoint name should be $hadrEndPointName for replica $($results.SqlInstance)" {
                        $resultshadrendpoint.Name | Should -BeIn $hadrEndPointName -Because "$hadrEndPointName is what we expect the compliant name to be"
                    }
                    It "HADR TCP endpoint state should be Started for replica $($results.SqlInstance)" {
                        $resultshadrendpoint.EndpointState | Should -BeIn "Started" -Because "We expect the HADR Endpoint to get ready for log block replication"
                    }

                    It "Session timeout should be $hadrSessionTimeout for replica $($results.SqlInstance)" {
                        $replica = Get-DbaAgReplica -SqlInstance $PsItem.Name
                        $replica.SessionTimeout | Should -BeIn $hadrSessionTimeout -Because "$hadrSessionTimeout is what we expect the session time value to be"
                    }
                }
            }

            Context "Availability group status for $($AG.Name) on $clustername" {
                @($AG.AvailabilityReplicas).ForEach{
                    It "The replica should not be in unknown availability mode for $($psitem.Name)" {
                        $psitem.AvailabilityMode | Should -Not -Be 'Unknown' -Because 'The replica should not be in unknown state'
                    }
                }
                @($AG.AvailabilityReplicas).Where{ $psitem.AvailabilityMode -eq 'SynchronousCommit' }.ForEach{
                    It "The replica should be synchronised $($psitem.Name)" {
                        $psitem.RollupSynchronizationState | Should -Be 'Synchronized' -Because 'The synchronous replica should be synchronised'
                    }
                }
                $AG.AvailabilityReplicas.Where{ $psitem.AvailabilityMode -eq 'ASynchronousCommit' }.ForEach{
                    It "The replica should be synchronising $($psitem.Name)" {
                        $psitem.RollupSynchronizationState | Should -Be 'Synchronizing' -Because 'The asynchronous replica should be synchronizing '
                    }
                }
                @($AG.AvailabilityReplicas).Where.ForEach{
                    It "The replica should be connected $($psitem.Name)" {
                        $psitem.ConnectionState | Should -Be 'Connected' -Because 'The replica should be connected'
                    }
                }
            }

            Context "Database availability group status for $($AG.Name) on $clustername" {
                @($ag.AvailabilityReplicas.Where{ $_.AvailabilityMode -eq 'SynchronousCommit' }).ForEach{
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
                @($ag.AvailabilityReplicas.Where{ $_.AvailabilityMode -eq 'AsynchronousCommit' }).ForEach{
                    @(Get-DbaAgDatabase -SqlInstance $PSItem.Name -AvailabilityGroup $Ag.Name).ForEach{
                        It "Database $($psitem.DatabaseName) should be synchronising as it is Async on the secondary replica $($psitem.Replica)" {
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

            Context "Always On extended event status for replica $($AG.SqlInstance) on $clustername" {
                try {
                    $Xevents = Get-DbaXEsession -SqlInstance $AG.SqlInstance -WarningAction SilentlyContinue
                }
                catch {
                    $Xevents = 'FailedToConnect'
                }
                It "There should be an extended event session called AlwaysOn_health on Replica $($psitem.Name)" {
                    $Xevents.Name  | Should -Contain 'AlwaysOn_health' -Because 'The extended events session should exist'
                }
                It "The Always On Health extended event session should be running on Replica $($psitem.Name)" {
                    $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.Status | Should -Be 'Running' -Because 'The extended event session will enable you to troubleshoot errors'
                }
                It "The Always On Health extended event session should be set to auto start on Replica $($psitem.Name)" {
                    $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.AutoStart | Should -BeTrue  -Because 'The extended event session will enable you to troubleshoot errors'
                }
            }
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUW+i9VUpgxvFu0m8CjHR4wio2
# QYygggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT+I7ZxtqIhmUvNKQFmlW8I9W3y
# 5jANBgkqhkiG9w0BAQEFAASCAQBUHmUJqOrFJlthbAiIzL4D6LwH908qv77k84WN
# J1/usSBHy1tAUX5jtMo/EJLLoXEzlL7NjhgA6zkcWX0KlSw6QoZ4qG7r61t9nm7E
# RaR+kOjIYLFQB0ljSYr08YLiagcOj1NaXkiU6ohKHymcLVKjRwsY6Gwym4M9MmIS
# 5Eo7pSBB1junSlXY8FuGw1F0kmZEh9vTkUOeVerFrKdY7gvZP1RiEapB6fINnPk0
# Tc8/0m+DhnjCqROPLmh3pDBZ7md+4x7fFTyU0zb7rRT8NQkgPhoUPag8wBQhba2A
# vTp085O7s6kU2mq1nr1St9Od1kd2mFoLBI5Tx5VL7lL9YmrS
# SIG # End signature block

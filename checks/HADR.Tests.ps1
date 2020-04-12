$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

# Get all the info in the function
function Get-ClusterObject {
    [CmdletBinding()]
    param (
        [string]$ClusterVM
    )

    [pscustomobject]$return = @{ }
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
$skipaglistenerping = Get-DbcConfigValue skip.hadr.listener.pingcheck
# $skipaglistenertcpport = Get-DbcConfigValue skip.hadr.listener.tcpport # to stop the pester failing
$skipreplicatcpport = Get-DbcConfigValue skip.hadr.replica.tcpport
$domainname = Get-DbcConfigValue domain.name
# $agtcpport = Get-DbcConfigValue policy.hadr.agtcpport # to stop the pester failing
$sqltcpport = Get-DbcConfigValue policy.hadr.tcpport

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
        # so that we dont get the error and Get-ClusterObject fills it as FailedtoConnect
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
        }
        Context "Cluster networks for $clustername" {
            @($return.Network).ForEach{
                It "The Network should be up - Network $($psitem.Name)" {
                    $psitem.State | Should -Be 'Up' -Because 'All of the CLuster Networks should be up'
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
                        $results = Test-DbaConnection -sqlinstance $_.Name
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
                    $results = Test-DbaConnection -sqlinstance $PsItem.Name
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
                    It "TCP port should be in $tcpport on Replica $($results.SqlInstance)" -Skip:$skipreplicatcpport {
                        $results.TCPPort | Should -BeIn $sqltcpport -Because "We expect the TCP Port to be in $sqltcpport"
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
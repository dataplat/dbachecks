$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

function Get-ClusterObject {
    [CmdletBinding()]
    param (
        [string]$Cluster
    )
    
    if (-not (Get-Module FailoverClusters)) {
        try {
            Import-Module FailoverClusters -ErrorAction Stop
        }
        catch {
            Stop-PSFFunction -Message "FailoverClusters module could not load" -ErrorRecord $psitem
            return
        }
    }
    [pscustomobject]$return = @{ }
    $return.Cluster = (Get-Cluster -Name $cluster)
    $return.Nodes = (Get-ClusterNode -Cluster $cluster)
    $return.Resources = (Get-ClusterResource -Cluster $cluster)
    $return.Network = (Get-ClusterNetwork -Cluster $cluster)
    $return.Groups = (Get-ClusterGroup -Cluster $cluster)

    $return.AGs = $return.Resources.Where{ $psitem.ResourceType -eq 'SQL Server Availability Group' }
    $Ags = $return.AGs.Name
    $return.AvailabilityGroups = @{}
    foreach ($Ag in $ags ) {
        
        $return.AvailabilityGroups[$AG] = Get-DbaAvailabilityGroup -SqlInstance $AG -AvailabilityGroup $ag
    }

    Return $return
}


    $clusters = Get-DbcConfigValue app.clusters
    $skiplistener = Get-DbcConfigValue skip.hadr.listener.pingcheck
    if ($clusters.Count -eq 0) {
        Write-Warning "No Clusters to look at. Please use Set-DbcConfig -Name app.clusters to add clusters for checking"
        break
    }
    $domainname = Get-DbcConfigValue domain.name
    $tcpport = Get-DbcConfigValue policy.hadr.tcpport

    foreach ($cluster in $clusters) {
        Describe "Cluster $cluster Health" -Tags ClusterHealth, $filename {
        $return = Get-ClusterObject -Cluster $cluster
    
        Context "Cluster Nodes for $cluster" {
            $return.Nodes.ForEach{
                It "Node $($psitem.Name) Should Be Up" {
                    $psitem.State | Should -Be 'Up' -Because 'Every node in the cluster should be available'
                }
            }
        }
        Context "Cluster Resources for $cluster" {
            $return.Resources.foreach{
                It "Resource $($psitem.Name) Should Be Online" {
                    $psitem.State | Should -Be 'Online' -Because 'All of the cluster resources should be online'
                }
            }
        }
        Context "Cluster Networks for $cluster" {
            $return.Network.ForEach{
                It "$($psitem.Name) Should Be Up" {
                    $psitem.State | Should -Be 'Up' -Because 'All of the CLuster Networks should be up'
                }
            }
        }
        
        Context "HADR Status for $cluster" {
            $return.Nodes.ForEach{
                It "HADR Should Be Enabled on the Server $($psitem.Name)" {
                    (Get-DbaAgHadr -SqlInstance $psitem.Name).IsHadrEnabled | Should -BeTrue -Because 'All of the SQL Services should have HADR enabled'
                }
            }
        }
        $Ags = $return.AGs.Name
        foreach($Name in $Ags) {
            $Ag = $return.AvailabilityGroups[$Name]
            
            Context "Cluster Connectivity for Availability Group $($AG.Name) on $cluster" {
                $AG.AvailabilityGroupListeners.ForEach{
                    $results = Test-DbaConnection -sqlinstance $_.Name
                    It "Listener $($results.SqlInstance) Should Be Pingable" -skip:$skiplistener {
                        $results.IsPingable | Should -BeTrue -Because 'The listeners should be pingable'
                    }
                    It "Listener $($results.SqlInstance) Should Be Connectable" {
                        $results.ConnectSuccess | Should -BeTrue -Because 'The listener should process SQL commands successfully'
                    }
                    It "Listener $($results.SqlInstance) Domain Name Should Be $domainname" {
                        $results.DomainName | Should -Be $domainname -Because 'This is what we expect the domain name to be'
                    }
                    It "Listener $($results.SqlInstance) TCP Port Should Be $tcpport" {
                        $results.TCPPort | Should -Be $tcpport -Because 'This is what we said the TCP Port should be'
                    }
                }

                $AG.AvailabilityReplicas.ForEach{
                    $results = Test-DbaConnection -sqlinstance $PsItem.Name
                    It "Replica $($results.SqlInstance) Should Be Pingable" {
                        $results.IsPingable | Should -BeTrue -Because 'Each replica should be pingable'
                    }
                    It "Replica $($results.SqlInstance) Should Be Connectable" {
                        $results.ConnectSuccess | Should -BeTrue -Because 'Each replica should be able to process SQL commands'
                    }
                    It "Replica $($results.SqlInstance) Domain Name Should Be $domainname" {
                        $results.DomainName | Should -Be $domainname -Because 'This is what we expect the domain name to be'
                    }
                    It "Replica $($results.SqlInstance) TCP Port Should Be $tcpport" {
                        $results.TCPPort | Should -Be $tcpport -Because 'This is what we expect the TCP Port to be'
                    }
                }
            }

            Context "Availability Group Status for Availability Group $($AG.Name) on $cluster" {
                $AG.AvailabilityReplicas.ForEach{
                    It "$($psitem.Name) Replica should not be in Unknown Availability Mode" {
                        $psitem.AvailabilityMode | Should -Not -Be 'Unknown' -Because 'The replica should not be in unknown state'
                    }
                }
                $AG.AvailabilityReplicas.Where{ $psitem.AvailabilityMode -eq 'SynchronousCommit' }.ForEach{
                    It "$($psitem.Name) Replica Should Be synchronised" {
                        $psitem.RollupSynchronizationState | Should -Be 'Synchronized' -Because 'The synchronous replica should not synchronised'
                    }
                }
                $AG.AvailabilityReplicas.Where{ $psitem.AvailabilityMode -eq 'ASynchronousCommit' }.ForEach{
                    It "$($psitem.Name) Replica Should Be synchronising" {
                        $psitem.RollupSynchronizationState | Should -Be 'Synchronizing' -Because 'The asynchronous replica should be synchronizing '
                    }
                }
                $AG.AvailabilityReplicas.Where.ForEach{
                    It"$($psitem.Name) Replica Should Be Connected" {
                        $psitem.ConnectionState | Should -Be 'Connected' -Because 'The replica should be connected'
                    }
                }
            
            }
        
            Context "Database AG Status for Availability Group $($AG.Name) on $cluster" {
                $Primary = $ag.AvailabilityReplicas.Where{$_.Role -eq 'Primary'}.Name
                (Get-DbaAgDatabase -SqlInstance $Primary -AvailabilityGroup $Ag.Name).ForEach{
                    It "Database $($psitem.DatabaseName) Should Be Synchronised on the Primary Replica $($psitem.Replica)" {
                        $psitem.SynchronizationState | Should -Be 'Synchronized' -Because 'The database on the primary replica should be synchronised'
                    }
                    It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Primary Replica $($psitem.Replica)" {
                        $psitem.IsFailoverReady | Should -BeTrue  -Because 'The database on the primary replica should be ready to failover'
                    }
                    It "Database $($psitem.DatabaseName) Should Be Joined on the Primary Replica $($psitem.Replica)" {
                        $psitem.IsJoined | Should -BeTrue  -Because 'The database on the primary replica should be joined to the availablity group'
                    }
                    It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Primary Replica $($psitem.Replica)" {
                        $psitem.IsSuspended | Should -Be  $False  -Because 'The database on the primary replica should not be suspended'
                    }
                }
                $SecSync = $ag.AvailabilityReplicas.Where{$_.Role -eq 'Secondary' -and $_.AvailabilityMode -eq 'SynchronousCommit' }.name
                (Get-DbaAgDatabase -SqlInstance $SecSync -AvailabilityGroup $Ag.Name).ForEach{
                    It "Database $($psitem.DatabaseName) Should Be Synchronised on the Secondary Replica $($psitem.Replica)" {
                        $psitem.SynchronizationState | Should -Be 'Synchronized'  -Because 'The database on the synchronous secondary replica should be synchronised'
                    }
                    It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Secondary Replica $($psitem.Replica)" {
                        $psitem.IsFailoverReady | Should -BeTrue -Because 'The database on the synchronous secondary replica should be ready to failover'
                    }
                    It "Database $($psitem.DatabaseName) Should Be Joined on the Secondary Replica $($psitem.Replica)" {
                        $psitem.IsJoined | Should -BeTrue -Because 'The database on the synchronous secondary replica should be joined to the Availability Group'
                    }
                    It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Secondary Replica $($psitem.Replica)" {
                        $psitem.IsSuspended | Should -Be  $False -Because 'The database on the synchronous secondary replica should not be suspended'
                    }
                }
                $SecASync = $ag.AvailabilityReplicas.Where{$_.Role -eq 'Secondary' -and $_.AvailabilityMode -eq 'AsynchronousCommit' }.name
                if($SecASync){
                (Get-DbaAgDatabase -SqlInstance $SecASync -AvailabilityGroup $Ag.Name).ForEach{
                    It "Database $($psitem.DatabaseName) Should Be Synchronising on the Secondary as it is Async" {
                        $psitem.SynchronizationState | Should -Be 'Synchronizing' -Because 'The database on the asynchronous secondary replica should be synchronising'
                    }
                    It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Secondary Replica $($psitem.Replica)" {
                        $psitem.IsFailoverReady | Should -BeTrue -Because 'The database on the asynchronous secondary replica should be ready to failover'
                    }
                    It "Database $($psitem.DatabaseName) Should Be Joined on the Secondary Replica $($psitem.Replica)" {
                        $psitem.IsJoined | Should -BeTrue -Because 'The database on the asynchronous secondary replica should be joined to the availaility group'
                    }
                    It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Secondary Replica $($psitem.Replica)" {
                        $psitem.IsSuspended | Should -Be  $False -Because 'The database on the asynchronous secondary replica should not be suspended'
                    }
                }
            }
            }
            Context "Extended Event Status for $cluster" {
                $AG.AvailabilityReplicas.ForEach{
                    $Xevents = Get-DbaXESession -SqlInstance $psitem.Name
                    It "Replica $($psitem.Replica) should have an Extended Event Session called AlwaysOn_health" {
                        $Xevents.Name  | Should -Contain 'AlwaysOn_health' -Because 'The Extended Events session should exist'
                    }
                    It "Replica $($psitem.Replica) Always On Health XEvent Should Be Running" {
                        $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.Status | Should -Be 'Running' -Because 'The extended event session will enable you to troubleshoot errors'
                    }
                    It "Replica $($psitem.Replica) Always On Health XEvent Auto Start Should Be True" {
                        $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.AutoStart | Should -BeTrue  -Because 'The extended event session will enable you to troubleshoot errors'
                    }
                }
            }
        }
    }
}
       
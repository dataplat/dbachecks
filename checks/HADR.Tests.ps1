$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Cluster Health" -Tags ClusterHealth, $filename {
    $domainname = Get-DbcConfigValue domain.name
    $tcpport = Get-DbcConfigValue policy.hadr.tcpport
    
    foreach ($cluster in (Get-ComputerName)) {
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
            $listeners = $return.AGStatus.AvailabilityGroupListeners.Name
            $return.SqlTestListeners = $listeners.ForEach{ Test-DbaConnection -SqlInstance $psitem }
            $return.SqlTestReplicas = $return.AGReplica.ForEach{ Test-DbaConnection -SqlInstance $psitem.Name }
            $return.Groups = (Get-ClusterGroup -Cluster $cluster)
            $listeneripaddress = (Get-ClusterResource -Cluster $cluster -InputObject (Get-ClusterResource -Cluster $cluster | Where-Object { $psitem.ResourceType -like "SQL Server Availability Group" }).OwnerGroup)
            $return.AGOwner = $return.Resources.Where{ $psitem.ResourceType -eq 'SQL Server Availability Group' }.OwnerNode
            $return.AGStatus = (Get-DbaAvailabilityGroup -SqlInstance $return.AGOwner.Name)
            $listeners = $return.AGStatus.AvailabilityGroupListeners.Name
            $return.AGReplica = (Get-DbaAgReplica -SqlInstance $return.AGStatus.PrimaryReplica)
            $return.AGDatabasesPrim = (Get-DbaAgDatabase -SqlInstance $return.AGStatus.PrimaryReplica)
            $synchronoussecondaries = $return.AGReplica.Where{ $psitem.Role -eq 'Secondary' -and $psitem.AvailabilityMode -eq 'SynchronousCommit' }.Name
            $return.AGDatabasesSecSync = $synchronoussecondaries.ForEach{ Get-DbaAgDatabase -SqlInstance $psitem }
            $asyncsecondaries = $return.AGReplica.Where{ $psitem.Role -eq 'Secondary' -and $psitem.AvailabilityMode -eq 'AsynchronousCommit' }.Name
            $return.AGDatabasesSecASync = $asyncsecondaries.ForEach{ Get-DbaAgDatabase -SqlInstance $psitem }
            $return.SqlTestListeners = $listeners.ForEach{ Test-DbaConnection -SqlInstance $psitem }
            $return.SqlTestReplicas = $return.AGReplica.ForEach{ Test-DbaConnection -SqlInstance $psitem.Name }
        }
    }
    
    $return = Get-ClusterObject -Cluster $cluster
    
    Describe "Cluster Server Health" -Tags ClusterServerHealth, $filename {
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
    }
    
    Describe "Cluster Network Health" -Tags ClusterNetworkHealth, $filename {
        Context "Cluster Connectivity for $cluster" {
            $return.SqlTestListeners.ForEach{
                It "Listener $($psitem.SqlInstance) Should Be Pingable" {
                    $psitem.IsPingable | Should -BeTrue -Because 'The listeners should be pingable'
                }
                It "Listener $($psitem.SqlInstance) Should Be Connectable" {
                    $psitem.ConnectSuccess | Should -BeTrue -Because 'The listener should process SQL commands successfully'
                }
                It "Listener $($psitem.SqlInstance) Domain Name Should Be $domainname" {
                    $psitem.DomainName | Should -Be $domainname -Because 'This is what we expect the domain name to be'
                }
                It "Listener $($psitem.SqlInstance) TCP Port Should Be $tcpport" {
                    $psitem.TCPPort | Should -Be $tcpport -Because 'This is what we said the TCP Port should be'
                }
            }
            $return.SqlTestReplicas.ForEach{
                It "Replica $($psitem.SqlInstance) Should Be Pingable" {
                    $psitem.IsPingable | Should -BeTrue -Because 'Each replica should be pingable'
                }
                It "Replica $($psitem.SqlInstance) Should Be Connectable" {
                    $psitem.ConnectSuccess | Should -BeTrue -Because 'Each replica should be able to process SQL commands'
                }
                It "Replica $($psitem.SqlInstance) Domain Name Should Be $domainname" {
                    $psitem.DomainName | Should -Be $domainname -Because 'This is what we expect the domain name to be'
                }
                It "Replica $($psitem.SqlInstance) TCP Port Should Be $tcpport" {
                    $psitem.TCPPort | Should -Be $tcpport -Because 'This is what we expect the TCP Port to be'
                }
            }
        }
    }
    
    Describe "Availability Group Health" -Tags AvailabilityGroupHealth, AvailabilityGroup, $filename {
        Context "Availability Group Status for $cluster" {
            $return.AGReplica.Where.ForEach{
                It "$($psitem.Replica) Replica should not be in Unknown Availability Mode" {
                    $psitem.AvailabilityMode | Should Not Be 'Unknown' -Because 'The replica should not be in unknown state - You should investigate'
                }
            }
            $return.AGReplica.Where{ $psitem.AvailabilityMode -eq 'SynchronousCommit' }.ForEach{
                It "$($psitem.Replica) Replica Should Be synchronised" {
                    $psitem.RollupSynchronizationState | Should -Be 'Synchronized' -Because 'The synchronous replica should not synchronised - You should investigate'
                }
            }
            $return.AGReplica.Where{ $psitem.AvailabilityMode -eq 'ASynchronousCommit' }.ForEach{
                It "$($psitem.Replica) Replica Should Be synchronising" {
                    $psitem.RollupSynchronizationState | Should -Be 'Synchronizing' -Because 'The asynchronous replica should synchronizing - You should investigate'
                }
            }
            $return.AGReplica.Where.ForEach{
                It"$($psitem.Replica) Replica Should Be Connected" {
                    $psitem.ConnectionState | Should -Be 'Connected' -Because 'The replica should be connected - You should investigate'
                }
            }
            
        }
        Context "Database AG Status for $cluster" {
            $return.AGDatabasesPrim.ForEach{
                It "Database $($psitem.DatabaseName) Should Be Synchronised on the Primary Replica $($psitem.Replica)" {
                    $psitem.SynchronizationState | Should -Be 'Synchronized' -Because 'The database on the primary replica should be synchronised - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Primary Replica $($psitem.Replica)" {
                    $psitem.IsFailoverReady | Should -BeTrue  -Because 'The database on the primary replica should be ready to failover - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Be Joined on the Primary Replica $($psitem.Replica)" {
                    $psitem.IsJoined | Should -BeTrue  -Because 'The database on the primary replica should be joined to the availablity group - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Primary Replica $($psitem.Replica)" {
                    $psitem.IsSuspended | Should -Be  $False  -Because 'The database on the primary replica should not be suspended - You should investigate'
                }
            }
            $return.AGDatabasesSecSync.ForEach{
                It "Database $($psitem.DatabaseName) Should Be Synchronised on the Secondary Replica $($psitem.Replica)" {
                    $psitem.SynchronizationState | Should -Be 'Synchronized'  -Because 'The database on the synchronous secondary replica should be synchronised - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Secondary Replica $($psitem.Replica)" {
                    $psitem.IsFailoverReady | Should -BeTrue -Because 'The database on the synchronous secondary replica should be ready to failover - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Be Joined on the Secondary Replica $($psitem.Replica)" {
                    $psitem.IsJoined | Should -BeTrue -Because 'The database on the synchronous secondary replica should be joined to the Availability Group - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Secondary Replica $($psitem.Replica)" {
                    $psitem.IsSuspended | Should -Be  $False -Because 'The database on the synchronous secondary replica should not be suspended - You should investigate'
                }
            }
            $return.AGDatabasesSecASync.ForEach{
                It "Database $($psitem.DatabaseName) Should Be Synchronising on the Secondary as it is Async" {
                    $psitem.SynchronizationState | Should -Be 'Synchronizing' -Because 'The database on the asynchronous secondary replica should be synchronising - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Secondary Replica $($psitem.Replica)" {
                    $psitem.IsFailoverReady | Should -BeTrue -Because 'The database on the asynchronous secondary replica should be ready to failover - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Be Joined on the Secondary Replica $($psitem.Replica)" {
                    $psitem.IsJoined | Should -BeTrue -Because 'The database on the asynchronous secondary replica should be joined to the availaility group - You should investigate'
                }
                It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Secondary Replica $($psitem.Replica)" {
                    $psitem.IsSuspended | Should -Be  $False -Because 'The database on the asynchronous secondary replica should not be suspended - You should investigate'
                }
            }
        }
        Context "Extended Event Status for $cluster" {
            $return.AGReplica.ForEach{
                $Xevents = Get-DbaXESession -SqlInstance $psitem
                It "Replica $($psitem) should have an Extended Event Session called AlwaysOn_health" {
                    $Xevents.Name  | Should -Contain 'AlwaysOn_health' -Because 'The Extended Events session should exist'
                }
                It "Replica $($psitem) Always On Health XEvent Should Be Running" {
                    $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.Status | Should -Be 'Running' -Because 'The extended event session will enable you to troubleshoot errors'
                }
                It "Replica $($psitem) Always On Health XEvent Auto Start Should Be True" {
                    $Xevents.Where{ $_.Name -eq 'AlwaysOn_health' }.AutoStart | Should -BeTrue  -Because 'The extended event session will enable you to troubleshoot errors'
                }
            }
        }
    }
}
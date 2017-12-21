if (-not (Get-DbcConfigValue HADRcheck)) {
    Import-Module FailoverClusters

    $ClusterNames = Get-DbcConfigValue policy.HADRClusterName
    $DomainName = Get-DbcConfigValue policy.HADRFQDN
    $TCPPort = Get-DbcConfigValue policy.HADRTCPPort

    foreach ($ClusterName in $ClusterNames) {
        [pscustomobject]$Return = @{}
        $Return.Cluster = (Get-Cluster -Name $ClusterName)
        $Return.Nodes = (Get-ClusterNode -Cluster $ClusterName)
        $return.Resources = (Get-ClusterResource -Cluster $ClusterName)
        $Return.Network = (Get-ClusterNetwork -Cluster $ClusterName)
        $Return.Groups = (Get-ClusterGroup -Cluster $ClusterName)
        $Return.AGOwner = $Return.Resources.Where{$_.ResourceType -eq 'SQL Server Availability Group'}.OwnerNode 
        $Return.AGStatus = (Get-DbaAvailabilityGroup -SqlInstance $Return.AGOwner.Name )
        $ListenerIPAddress = (Get-ClusterResource -Cluster $ClusterName -inputobject (get-clusterresource -cluster $ClusterName | where-object {$_.ResourceType -like "SQL Server Availability Group"}).OwnerGroup)
        $Listeners = $Return.AGStatus.AvailabilityGroupListeners.Name
        $Return.AGReplica = (Get-DbaAgReplica -SqlInstance $Return.AGStatus.PrimaryReplica)
        $Return.AGDatabasesPrim = (Get-DbaAgDatabase -SqlInstance $Return.AGStatus.PrimaryReplica)
        $SynchronousSecondaries = $Return.AGReplica.Where{$_.Role -eq 'Secondary' -and $_.AvailabilityMode -eq 'SynchronousCommit'}.Name
        $Return.AGDatabasesSecSync = $SynchronousSecondaries.ForEach{Get-DbaAgDatabase -SqlInstance $_}
        $ASynchronousSecondaries = $Return.AGReplica.Where{$_.Role -eq 'Secondary' -and $_.AvailabilityMode -eq 'AsynchronousCommit'}.Name
        $Return.AGDatabasesSecASync = $ASynchronousSecondaries.ForEach{Get-DbaAgDatabase -SqlInstance $_}
        $Return.SQLTestListeners = $Listeners.ForEach{Test-DbaConnection -SqlInstance $_}
        $Return.SQLTestReplicas = $Return.AGReplica.ForEach{Test-DbaConnection -SqlInstance $_.Name}

        Describe "Testing $ClusterName Cluster" {
            Context "Cluster Nodes" {
                $Return.Nodes.ForEach{
                    It "Node $($_.Name) should be Up" {
                        $_.State | Should Be 'Up'
                    }
                }
            }
            Context "Cluster Resources" {
                $return.Resources.foreach{
                    It "Resource $($_.Name) Should Be Online" {
                        $_.State | Should Be 'Online'
                    }          
                }
            }
            Context "Cluster Networks" {
                $Return.Network.ForEach{
                    It "$($_.Name) Shold Be Up" {
                        $_.State | Should Be 'Up'
                    }
                }
            }
        }

        Describe "SQL" {
            Context "SQL Status" {
                $Return.SQLTestListeners.ForEach{
                    It "Listener $($_.SQLInstance) Should be Pingable" {
                        $_.IsPingable | Should Be $True
                    }
                    It "Listener $($_.SQLInstance) Should be Connectable" {
                        $_.ConnectSuccess | Should Be $true
                    }
                    It "Listener $($_.SQLInstance) Domain Name Should Be $DomainName" {
                        $_.DomainName | Should Be $DomainName
                    }
                    It "Listener $($_.SQLInstance) TCP Port Should Be $TCPPort" {
                        $_.TCPPort | Should Be $TCPPort
                    }
                }
                $Return.SQLTestReplicas.ForEach{
                    It "Replica $($_.SQLInstance) Should be Pingable" {
                        $_.IsPingable | Should Be $True
                    }
                    It "Replica $($_.SQLInstance) Should be Connectable" {
                        $_.ConnectSuccess | Should Be $true
                    }
                    It "Replica $($_.SQLInstance) Domain Name Should Be $DomainName" {
                        $_.DomainName | Should Be $DomainName
                    }
                    It "Replica $($_.SQLInstance) TCP Port Should Be $TCPPort" {
                        $_.TCPPort | Should Be $TCPPort
                    }
                }
            }
            Context "HADR Status for Server" {
                $return.Nodes.ForEach{
                    It "HADR Should Be Enabled on the Server $($_.Name)" {
                        (Get-DbaAgHadr -SqlInstance $_.Name).IsHadrEnabled | Should Be $true
                    }
                } 
            }
            Context "Availability Group Status" {
                $Return.AGReplica.Where.ForEach{
                    It "$($_.Replica) Replica should not be in Unknown Availability Mode" {
                        $_.AvailabilityMode | Should Not Be 'Unknown'
                    }
                }
                $Return.AGReplica.Where{$_.AvailabilityMode -eq 'SynchronousCommit'}.ForEach{
                    It "$($_.Replica) Replica should be synchronised" {
                        $_.RollupSynchronizationState | Should Be 'Synchronized'
                    }
                }
                $Return.AGReplica.Where{$_.AvailabilityMode -eq 'ASynchronousCommit'}.ForEach{
                    It "$($_.Replica) Replica should be synchronising" {
                        $_.RollupSynchronizationState | Should Be 'Synchronizing'
                    }
                }
                $Return.AGReplica.Where.ForEach{
                    It"$($_.Replica) Replica should be Connected" {
                        $_.ConnectionState | Should Be 'Connected'
                    }
                }

            }

            Context "Datbase AG Status" {
                $Return.AGDatabasesPrim.ForEach{
                    It "Database $($_.DatabaseName) Should Be Synchronised on the Primary Replica $($_.Replica)" {
                        $_.SynchronizationState | Should Be 'Synchronized'
                    }
                    It "Database $($_.DatabaseName) Should Be Failover Ready on the Primary Replica $($_.Replica)" {
                        $_.IsFailoverReady   | Should Be $True
                    }
                    It "Database $($_.DatabaseName) Should Be Joined on the Primary Replica $($_.Replica)" {
                        $_.IsJoined   | Should Be $True
                    }
                    It "Database $($_.DatabaseName) Should Not Be Suspended on the Primary Replica $($_.Replica)" {
                        $_.IsSuspended  | Should Be  $False
                    }
                }
                $Return.AGDatabasesSecSync.ForEach{
                    It "Database $($_.DatabaseName) Should Be Synchronised on the Secondary Replica $($_.Replica)" {
                        $_.SynchronizationState | Should Be 'Synchronized'
                    }
                    It "Database $($_.DatabaseName) Should Be Failover Ready on the Secondary Replica $($_.Replica)" {
                        $_.IsFailoverReady   | Should Be $True
                    }
                    It "Database $($_.DatabaseName) Should Be Joined on the Secondary Replica $($_.Replica)" {
                        $_.IsJoined   | Should Be $True
                    }
                    It "Database $($_.DatabaseName) Should Not Be Suspended on the Secondary Replica $($_.Replica)" {
                        $_.IsSuspended  | Should Be  $False
                    }
                }
                $Return.AGDatabasesSecASync.ForEach{
                    It "Database $($_.DatabaseName) Should Be Synchronising on the Secondary as it is Async" {
                        $_.SynchronizationState | Should Be 'Synchronizing'
                    }
                    It "Database $($_.DatabaseName) Should Be Failover Ready on the Secondary Replica $($_.Replica)" {
                        $_.IsFailoverReady   | Should Be $True
                    }
                    It "Database $($_.DatabaseName) Should Be Joined on the Secondary Replica $($_.Replica)" {
                        $_.IsJoined   | Should Be $True
                    }
                    It "Database $($_.DatabaseName) Should Not Be Suspended on the Secondary Replica $($_.Replica)" {
                        $_.IsSuspended  | Should Be  $False
                    }
                }
            }
        }

        <#
Write-Output "UseFul Info - You Can run

`$Return.Cluster
`$Return.Resources | Select *| OGV 
`$Return.Network | Select * | OGV
`$Return.Nodes | Select * | OGV
`$Return.Groups | Select * | OGV
`$Return.AGStatus | OGV
`$Return.AGReplica |ogv
`$Return.AGDatabasesPrim | ogv
`$Return.AGDatabasesSecSync | ogv
`$Return.AGDatabasesSecASync | ogv
"
#>
    }
}
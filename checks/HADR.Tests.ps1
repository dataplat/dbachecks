$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Cluster Server Health" -Tags ClusterServerHealth, $filename {
	
try {
	Import-Module FailoverClusters -ErrorAction Stop
}
catch {
	Stop-PSFFunction -Message "FailoverClusters module could not load" -ErrorRecord $psitem
	return
}

$domainname = Get-DbcConfigValue domain.name
$tcpport = Get-DbcConfigValue policy.hadrtcpport

foreach ($cluster in (Get-ComputerName)) {
	[pscustomobject]$return = @{ }
	$return.Cluster = (Get-Cluster -Name $cluster)
	$return.Nodes = (Get-ClusterNode -Cluster $cluster)
	$return.Resources = (Get-ClusterResource -Cluster $cluster)
	$return.Network = (Get-ClusterNetwork -Cluster $cluster)
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
	
		Context "Cluster Nodes" {
			$return.Nodes.ForEach{
				It "Node $($psitem.Name) should be Up" {
					$psitem.State | Should Be 'Up'
				}
			}
		}
		Context "Cluster Resources" {
			$return.Resources.foreach{
				It "Resource $($psitem.Name) Should Be Online" {
					$psitem.State | Should Be 'Online'
				}
			}
		}
		Context "Cluster Networks" {
			$return.Network.ForEach{
				It "$($psitem.Name) Shold Be Up" {
					$psitem.State | Should Be 'Up'
				}
			}
		}
	}
	
	Describe "Cluster Network Health" -Tags ClusterNetworkHealth, AvailabilityGroup, $filename {
		Context "Cluster Connectivity" {
			$return.SqlTestListeners.ForEach{
				It "Listener $($psitem.SqlInstance) Should be Pingable" {
					$psitem.IsPingable | Should Be $true
				}
				It "Listener $($psitem.SqlInstance) Should be Connectable" {
					$psitem.ConnectSuccess | Should Be $true
				}
				It "Listener $($psitem.SqlInstance) Domain Name Should Be $domainname" {
					$psitem.DomainName | Should Be $domainname
				}
				It "Listener $($psitem.SqlInstance) TCP Port Should Be $tcpport" {
					$psitem.TCPPort | Should Be $tcpport
				}
			}
			$return.SqlTestReplicas.ForEach{
				It "Replica $($psitem.SqlInstance) Should be Pingable" {
					$psitem.IsPingable | Should Be $true
				}
				It "Replica $($psitem.SqlInstance) Should be Connectable" {
					$psitem.ConnectSuccess | Should Be $true
				}
				It "Replica $($psitem.SqlInstance) Domain Name Should Be $domainname" {
					$psitem.DomainName | Should Be $domainname
				}
				It "Replica $($psitem.SqlInstance) TCP Port Should Be $tcpport" {
					$psitem.TCPPort | Should Be $tcpport
				}
			}
		}
		Context "HADR Status for Server" {
			$return.Nodes.ForEach{
				It "HADR Should Be Enabled on the Server $($psitem.Name)" {
					(Get-DbaAgHadr -SqlInstance $psitem.Name).IsHadrEnabled | Should Be $true
				}
			}
		}
		Context "Availability Group Status" {
			$return.AGReplica.Where.ForEach{
				It "$($psitem.Replica) Replica should not be in Unknown Availability Mode" {
					$psitem.AvailabilityMode | Should Not Be 'Unknown'
				}
			}
			$return.AGReplica.Where{ $psitem.AvailabilityMode -eq 'SynchronousCommit' }.ForEach{
				It "$($psitem.Replica) Replica should be synchronised" {
					$psitem.RollupSynchronizationState | Should Be 'Synchronized'
				}
			}
			$return.AGReplica.Where{ $psitem.AvailabilityMode -eq 'ASynchronousCommit' }.ForEach{
				It "$($psitem.Replica) Replica should be synchronising" {
					$psitem.RollupSynchronizationState | Should Be 'Synchronizing'
				}
			}
			$return.AGReplica.Where.ForEach{
				It"$($psitem.Replica) Replica should be Connected" {
					$psitem.ConnectionState | Should Be 'Connected'
				}
			}
			
		}
		Context "Database AG Status" {
			$return.AGDatabasesPrim.ForEach{
				It "Database $($psitem.DatabaseName) Should Be Synchronised on the Primary Replica $($psitem.Replica)" {
					$psitem.SynchronizationState | Should Be 'Synchronized'
				}
				It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Primary Replica $($psitem.Replica)" {
					$psitem.IsFailoverReady | Should Be $true
				}
				It "Database $($psitem.DatabaseName) Should Be Joined on the Primary Replica $($psitem.Replica)" {
					$psitem.IsJoined | Should Be $true
				}
				It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Primary Replica $($psitem.Replica)" {
					$psitem.IsSuspended | Should Be  $False
				}
			}
			$return.AGDatabasesSecSync.ForEach{
				It "Database $($psitem.DatabaseName) Should Be Synchronised on the Secondary Replica $($psitem.Replica)" {
					$psitem.SynchronizationState | Should Be 'Synchronized'
				}
				It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Secondary Replica $($psitem.Replica)" {
					$psitem.IsFailoverReady | Should Be $true
				}
				It "Database $($psitem.DatabaseName) Should Be Joined on the Secondary Replica $($psitem.Replica)" {
					$psitem.IsJoined | Should Be $true
				}
				It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Secondary Replica $($psitem.Replica)" {
					$psitem.IsSuspended | Should Be  $False
				}
			}
			$return.AGDatabasesSecASync.ForEach{
				It "Database $($psitem.DatabaseName) Should Be Synchronising on the Secondary as it is Async" {
					$psitem.SynchronizationState | Should Be 'Synchronizing'
				}
				It "Database $($psitem.DatabaseName) Should Be Failover Ready on the Secondary Replica $($psitem.Replica)" {
					$psitem.IsFailoverReady | Should Be $true
				}
				It "Database $($psitem.DatabaseName) Should Be Joined on the Secondary Replica $($psitem.Replica)" {
					$psitem.IsJoined | Should Be $true
				}
				It "Database $($psitem.DatabaseName) Should Not Be Suspended on the Secondary Replica $($psitem.Replica)" {
					$psitem.IsSuspended | Should Be  $False
				}
			}
		}
		Context "Extended Event Status" {
			$return.AGReplica.ForEach{
				$Xevents = Get-DbaXESession -SqlInstance $psitem
				It "Replica $($psitem) should have an Extended Event Session called AlwaysOn_health" {
					$Xevents.Name -contains 'AlwaysOn_health' | Should Be True
				}
				It "Replica $($psitem) Always On Health XEvent should be Running" {
					$Xevents.Where{$_.Name -eq 'AlwaysOn_health'}.Status | Should be 'Running'
				}
				It "Replica $($psitem) Always On Health XEvent Auto Start Should Be True" {
					$Xevents.Where{$_.Name -eq 'AlwaysOn_health'}.AutoStart | Should be $true
				}
			}
		}
	}
}
$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

if (-not (Get-DbcConfigValue skip.hadrcheck)) {
	Import-Module FailoverClusters -ErrorAction SilentlyContinue
	
	$clusternames = Get-DbcConfigValue policy.hadrclustername
	$domainname = Get-DbcConfigValue policy.hadrfqdn
	$tcpport = Get-DbcConfigValue policy.hadrtcpport
	if ($null -ne (Get-Module FailoverClusters)) {
		foreach ($ClusterName in $clusternames) {
			[pscustomobject]$return = @{ }
			$return.Cluster = (Get-Cluster -Name $ClusterName)
			$return.Nodes = (Get-ClusterNode -Cluster $ClusterName)
			$return.Resources = (Get-ClusterResource -Cluster $ClusterName)
			$return.Network = (Get-ClusterNetwork -Cluster $ClusterName)
			$return.Groups = (Get-ClusterGroup -Cluster $ClusterName)
			$listeneripaddress = (Get-ClusterResource -Cluster $ClusterName -inputobject (Get-ClusterResource -cluster $ClusterName | where-object { $_.ResourceType -like "SQL Server Availability Group" }).OwnerGroup)
			$return.AGOwner = $return.Resources.Where{ $_.ResourceType -eq 'SQL Server Availability Group' }.OwnerNode
			$return.AGStatus = (Get-DbaAvailabilityGroup -SqlInstance $return.AGOwner.Name)
			$listeners = $return.AGStatus.AvailabilityGroupListeners.Name
			$return.AGReplica = (Get-DbaAgReplica -SqlInstance $return.AGStatus.PrimaryReplica)
			$return.AGDatabasesPrim = (Get-DbaAgDatabase -SqlInstance $return.AGStatus.PrimaryReplica)
			$SynchronousSecondaries = $return.AGReplica.Where{ $_.Role -eq 'Secondary' -and $_.AvailabilityMode -eq 'SynchronousCommit' }.Name
			$return.AGDatabasesSecSync = $SynchronousSecondaries.ForEach{ Get-DbaAgDatabase -SqlInstance $_ }
			$asyncsecondaries = $return.AGReplica.Where{ $_.Role -eq 'Secondary' -and $_.AvailabilityMode -eq 'AsynchronousCommit' }.Name
			$return.AGDatabasesSecASync = $asyncsecondaries.ForEach{ Get-DbaAgDatabase -SqlInstance $_ }
			$return.SQLTestListeners = $listeners.ForEach{ Test-DbaConnection -SqlInstance $_ }
			$return.SQLTestReplicas = $return.AGReplica.ForEach{ Test-DbaConnection -SqlInstance $_.Name }
			
			Describe "Testing $ClusterName Cluster" -Tags Cluster, $filename {
				Context "Cluster Nodes" {
					$return.Nodes.ForEach{
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
					$return.Network.ForEach{
						It "$($_.Name) Shold Be Up" {
							$_.State | Should Be 'Up'
						}
					}
				}
			}
			
			Describe "SQL" -Tags AG, $filename {
				Context "SQL Status" {
					$return.SQLTestListeners.ForEach{
						It "Listener $($_.SQLInstance) Should be Pingable" {
							$_.IsPingable | Should Be $True
						}
						It "Listener $($_.SQLInstance) Should be Connectable" {
							$_.ConnectSuccess | Should Be $true
						}
						It "Listener $($_.SQLInstance) Domain Name Should Be $domainname" {
							$_.DomainName | Should Be $domainname
						}
						It "Listener $($_.SQLInstance) TCP Port Should Be $tcpport" {
							$_.TCPPort | Should Be $tcpport
						}
					}
					$return.SQLTestReplicas.ForEach{
						It "Replica $($_.SQLInstance) Should be Pingable" {
							$_.IsPingable | Should Be $True
						}
						It "Replica $($_.SQLInstance) Should be Connectable" {
							$_.ConnectSuccess | Should Be $true
						}
						It "Replica $($_.SQLInstance) Domain Name Should Be $domainname" {
							$_.DomainName | Should Be $domainname
						}
						It "Replica $($_.SQLInstance) TCP Port Should Be $tcpport" {
							$_.TCPPort | Should Be $tcpport
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
					$return.AGReplica.Where.ForEach{
						It "$($_.Replica) Replica should not be in Unknown Availability Mode" {
							$_.AvailabilityMode | Should Not Be 'Unknown'
						}
					}
					$return.AGReplica.Where{ $_.AvailabilityMode -eq 'SynchronousCommit' }.ForEach{
						It "$($_.Replica) Replica should be synchronised" {
							$_.RollupSynchronizationState | Should Be 'Synchronized'
						}
					}
					$return.AGReplica.Where{ $_.AvailabilityMode -eq 'ASynchronousCommit' }.ForEach{
						It "$($_.Replica) Replica should be synchronising" {
							$_.RollupSynchronizationState | Should Be 'Synchronizing'
						}
					}
					$return.AGReplica.Where.ForEach{
						It"$($_.Replica) Replica should be Connected" {
							$_.ConnectionState | Should Be 'Connected'
						}
					}
					
				}
				Context "Datbase AG Status" {
					$return.AGDatabasesPrim.ForEach{
						It "Database $($_.DatabaseName) Should Be Synchronised on the Primary Replica $($_.Replica)" {
							$_.SynchronizationState | Should Be 'Synchronized'
						}
						It "Database $($_.DatabaseName) Should Be Failover Ready on the Primary Replica $($_.Replica)" {
							$_.IsFailoverReady | Should Be $True
						}
						It "Database $($_.DatabaseName) Should Be Joined on the Primary Replica $($_.Replica)" {
							$_.IsJoined | Should Be $True
						}
						It "Database $($_.DatabaseName) Should Not Be Suspended on the Primary Replica $($_.Replica)" {
							$_.IsSuspended | Should Be  $False
						}
					}
					$return.AGDatabasesSecSync.ForEach{
						It "Database $($_.DatabaseName) Should Be Synchronised on the Secondary Replica $($_.Replica)" {
							$_.SynchronizationState | Should Be 'Synchronized'
						}
						It "Database $($_.DatabaseName) Should Be Failover Ready on the Secondary Replica $($_.Replica)" {
							$_.IsFailoverReady | Should Be $True
						}
						It "Database $($_.DatabaseName) Should Be Joined on the Secondary Replica $($_.Replica)" {
							$_.IsJoined | Should Be $True
						}
						It "Database $($_.DatabaseName) Should Not Be Suspended on the Secondary Replica $($_.Replica)" {
							$_.IsSuspended | Should Be  $False
						}
					}
					$return.AGDatabasesSecASync.ForEach{
						It "Database $($_.DatabaseName) Should Be Synchronising on the Secondary as it is Async" {
							$_.SynchronizationState | Should Be 'Synchronizing'
						}
						It "Database $($_.DatabaseName) Should Be Failover Ready on the Secondary Replica $($_.Replica)" {
							$_.IsFailoverReady | Should Be $True
						}
						It "Database $($_.DatabaseName) Should Be Joined on the Secondary Replica $($_.Replica)" {
							$_.IsJoined | Should Be $True
						}
						It "Database $($_.DatabaseName) Should Not Be Suspended on the Secondary Replica $($_.Replica)" {
							$_.IsSuspended | Should Be  $False
						}
					}
				}
			}
		}
	}
}
<#
Write-Output "UseFul Info - You Can run

`$return.Cluster
`$return.Resources | Select *| OGV 
`$return.Network | Select * | OGV
`$return.Nodes | Select * | OGV
`$return.Groups | Select * | OGV
`$return.AGStatus | OGV
`$return.AGReplica |ogv
`$return.AGDatabasesPrim | ogv
`$return.AGDatabasesSecSync | ogv
`$return.AGDatabasesSecASync | ogv
"
#>

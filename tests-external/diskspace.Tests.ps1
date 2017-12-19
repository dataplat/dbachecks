$free = Get-DbcConfigValue policy.diskspacepercentfree
Describe 'Testing Disk Space' -Tags Storage, DISA {
	(Get-DbcConfigValue Setup.ComputerName).ForEach{
		Context "Testing disk space for $psitem" {
			$results = Get-DbaDiskSpace -ComputerName $psitem
			foreach ($result in $results) {
				It "$($result.Name) should be at least $free percent free" {
					$result.PercentFree -ge $free | Should be $true
				}
			}
		}
	}
}
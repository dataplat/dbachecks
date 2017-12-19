$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$free = Get-DbcConfigValue policy.diskspacepercentfree
Describe 'Testing Disk Space' -Tags Storage, DISA, $filename {
	(Get-ComputerName).ForEach{
		$results = Get-DbaDiskSpace -ComputerName $psitem
		foreach ($result in $results) {
			It "$($result.Name) on $psitem should be at least $free percent free" {
				$result.PercentFree -ge $free | Should be $true
			}
		}
	}
}
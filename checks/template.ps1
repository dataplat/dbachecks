$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$max = Get-DbcConfigValue policy.diskspacepercentfree
Describe 'Testing Disk Space' -Tags Storage, DISA, $filename {
	(Get-ComputerName).ForEach{
		$results = Get-DbaDiskSpace -ComputerName $psitem
		foreach ($result in $results) {
			It "$($result.Name) on $psitem should be at least $max percent free" {
				$result.PercentFree -ge $max | Should be $true
			}
		}
	}
}
Describe "Disk Space Usage" -Tag Storage, DISA, $filename {
	$max = Get-DbcConfigValue policy.diskspacepercentfree
	(Get-ComputerName).ForEach{
		$results = Get-DbaDiskSpace -ComputerName $psitem
		foreach ($result in $results) {
			It "$($result.Name) on $psitem should be at least $max percent free" {
				$result.PercentFree -ge $max | Should be $true
			}
		}
	}
}
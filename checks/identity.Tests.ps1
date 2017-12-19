$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$maxpercentage = Get-DbcConfigValue policy.identityusagepercent

Describe 'Testing Column Identity Usage' -Tags Database, $filename {
	(Get-SqlInstance).ForEach{
		$results = Test-DbaIdentityUsage -SqlInstance $psitem
		foreach ($result in $results) {
			if ($result.Database -ne 'tempdb') {
				$columnfqdn = "$($result.Database).$($result.Schema)).$($result.Table)).$($result.Column))"
				It "usage for $columnfqdn on $psitem should be less than $maxpercentage percent" {
					$result.PercentUsed -lt $maxpercentage | Should be $true
				}
			}
		}
	}
}
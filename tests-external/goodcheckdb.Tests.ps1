$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$maxdays = Get-DbcConfigValue policy.integritycheckmaxdays

Describe 'Testing Database Collation' -Tags Database, Corruption, Integrity, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing last good DBCC CHECKDB for $psitem" {
			$results = Get-DbaLastGoodCheckDb -SqlInstance $psitem
			foreach ($result in $results) {
				if ($result.Database -ne 'tempdb') {
					It "last good integrity check for $($result.Database) on $psitem should be less than $maxdays" {
						$result.LastGoodCheckDb -ge (Get-Date).AddDays(- ($maxdays)) | Should be $true
					}
				}
			}
		}
	}
}
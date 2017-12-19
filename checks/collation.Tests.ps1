$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing Database Collation' -Tags Database, Collation, $filename {
	(Get-SqlInstance).ForEach{
		$results = Test-DbaDatabaseCollation -SqlInstance $psitem
		foreach ($result in $results) {
			It "database collation ($($result.DatabaseCollation)) on $psitem should match server collation ($($result.ServerCollation)) for $($result.Database) on $psitem" {
				$result.ServerCollation -eq $result.DatabaseCollation | Should be $true
			}
		}
	}
}
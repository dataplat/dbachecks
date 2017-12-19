$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing Database Collation' -Tags Database, Collation, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing recovery models for $psitem" {
			$results = Test-DbaDatabaseCollation -SqlInstance $psitem
			foreach ($result in $results) {
				It "collations should match for $($result.Database) on $psitem" {
					$result.ServerCollation -eq $result.DatabaseCollation | Should be $true
				}
			}
		}
	}
}
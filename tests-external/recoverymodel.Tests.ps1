Describe 'Testing FullRecovery Model' -Tags Backup, Database, DISA {
	(Get-DbcConfigValue Setup.SqlInstance).ForEach{
		Context "Testing recovery models for $psitem" {
			$results = Get-DbaDbRecoveryModel -SqlInstance $psitem
			foreach ($result in $results) {
				It "$result should be set to the Full recovery model" {
					$result.RecoveryModel -eq 'Full' | Should be $true
				}
			}
		}
	}
}
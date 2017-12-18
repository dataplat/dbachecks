Describe 'Testing FullRecovery Model' -Tags Backup, Database, DISA {
	(Get-DbcConfigValue  SqlInstance).ForEach{
		Context "Testing recovery models for $psitem" {
			$results = Get-DbaDbRecoveryModel -SqlInstance $psitem
			foreach ($result in $results) {
				It "$result should be in Full Recovery" {
					$result.RecoveryModel -eq 'Full' | Should be $true
				}
			}
		}
	}
}
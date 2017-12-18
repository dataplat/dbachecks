(Get-DbcConfigValue  SqlInstance).ForEach{
	Context "Testing recovery model on $psitem" {
		$results = Get-DbaDbRecoveryModel -SqlInstance $psitem -SqlCredential (Get-DbcConfigValue SqlCredential)
		foreach ($result in $results) {
			$result.RecoveryModel -eq 'Full' | Should Be $true
		}
	}
}
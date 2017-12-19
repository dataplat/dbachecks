$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$recoverymodel =
Describe 'Testing Full Recovery Model' -Tags Backup, Database, DISA, RecoveryModel, $filename {
	(Get-SqlInstance).ForEach{
		$results = Get-DbaDbRecoveryModel -SqlInstance $psitem
		foreach ($result in $results) {
			if ($result.Name -ne 'tempdb') {
				It "$result on $psitem should be set to the Full recovery model" {
					$result.RecoveryModel -eq (Get-DbcConfigValue policy.recoverymodel) | Should be $true
				}
			}
		}
	}
}
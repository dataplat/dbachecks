$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$maxfull = Get-DbcConfigValue policy.backupfullmaxdays
$maxdiff = Get-DbcConfigValue policy.backupdiffmaxhours
$maxlog  = Get-DbcConfigValue policy.backuplogmaxminutes
$diffskip = Get-DbcConfigValue skip.backupdiffcheck

Describe 'Testing Last Backup Times' -Tags Backup, Database, DISA, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing backups on $psitem" {
			$results = Get-DbaDatabase -SqlInstance $psitem
			foreach ($result in $results) {
				if ($result.RecoveryModel -ne 'Simple') {
					It "full backups for $result should be less than $maxfull days" {
						$result.LastFullBackup -ge (Get-Date).AddDays(-($maxfull)) | Should be $true
					}
				}
				
					It -Skip:$diffskip "diff backups for $result should be less than $maxdiff hours" {
						$result.LastDiffBackup -ge (Get-Date).AddHours(-($maxdiff)) | Should be $true
					}
				
				
				It "log backups for $result should be less than $maxlog minutes" {
					$result.LastLogBackup -ge (Get-Date).AddMinutes(-($maxlog)) | Should be $true
				}
			}
		}
	}
}
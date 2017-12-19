$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$destserver = Get-DbcConfigValue setup.backuptestserver
$destdata = Get-DbcConfigValue setup.backupdatadir
$destlog = Get-DbcConfigValue setup.backuplogdir

if (Get-DbcConfigValue skip.backuptesting) {
	Describe 'Testing backups' -Tags Backup, Database, $filename {
		(Get-SqlInstance).ForEach{
			foreach ($result in (Test-DbaLastBackup -SqlInstance $psitem -Destination $destserver -LogDirectory $destlog -DataDirectory $destdata )) {
				if ($result.DBCCResult -notmatch 'skipped for restored master') {
					It "DBCC for $($result.Database) on $psitem should be success" {
						$result.DBCCResult | Should Be 'Success'
					}
					It "restore for $($result.Database) on $psitem should be success" {
						$result.RestoreResult | Should Be 'Success'
					}
					
				}
			}
		}
	}
}
$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Database Collation" -Tags DatabaseCollation, $filename {
	(Get-SqlInstance).ForEach{
		$results = Test-DbaDatabaseCollation -SqlInstance $psitem
		foreach ($result in $results) {
			It "database collation ($($result.DatabaseCollation)) on $psitem should match server collation ($($result.ServerCollation)) for $($result.Database) on $psitem" {
				$result.ServerCollation -eq $result.DatabaseCollation | Should be $true
			}
		}
	}
}

Describe 'Testing Suspect Page' -Tags SuspectPage, $filename {
	(Get-SqlInstance).ForEach{
		$results = Get-DbaSuspectPage -SqlInstance $psitem
		foreach ($result in $results) {
			It "Suspect Page has been found on $psitem on database $result.DatabaseName" {
				$result.ErrorCount -eq 0 | Should be $true
			}
		}
	}
}
Describe "Last Backup Restore & Integrity Checks" -Tags Backup, TestLastBackup, $filename {
	if (-not (Get-DbcConfigValue skip.backuptesting)) {
		$destserver = Get-DbcConfigValue setup.backuptestserver
		$destdata = Get-DbcConfigValue setup.backupdatadir
		$destlog = Get-DbcConfigValue setup.backuplogdir
		(Get-SqlInstance).ForEach{
			foreach ($result in (Test-DbaLastBackup -SqlInstance $psitem -Destination $destserver -LogDirectory $destlog -DataDirectory $destdata)) {
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

Describe "Database Owners" -Tags DatabaseOwner, $filename {
	$targetowner = Get-DbcConfigValue policy.dbownershould
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem for Database Owners" {
			$results = Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner
			$results.ForEach{
				It "$($psitem.Database) Owner should be $targetowner" {
					$psitem.CurrentOwner | Should Be $psitem.TargetOwner
				}
			}
		}
	}
}

Describe "Not Database Owners" -Tags NotDatabaseOwner, $filename {
	$targetowner = Get-DbcConfigValue policy.dbownershouldnot
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem for Database Owners" {
			$results = Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner
			$results.ForEach{
				It "$($psitem.Database) Owner should Not be $targetowner" {
					$psitem.CurrentOwner | Should Not Be $psitem.TargetOwner
				}
			}
		}
	}
}

Describe "Last Good DBCC CHECKDB" -Tags LastGoodCheckDb, $filename {
	$maxdays = Get-DbcConfigValue policy.integritycheckmaxdays
	$datapurity = Get-DbcConfigValue skip.datapuritycheck
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem " {
			$results = Get-DbaLastGoodCheckDb -SqlInstance $psitem
			foreach ($result in $results) {
				if ($result.Database -ne 'tempdb') {
					It "last good integrity check for $($result.Database) on $psitem should be less than $maxdays" {
						$result.LastGoodCheckDb | Should BeGreaterThan (Get-Date).AddDays(- ($maxdays))
					}
					
					It -Skip:$datapurity "last good integrity check for $($result.Database) on $psitem has Data Purity Enabled" {
						$result.DataPurityEnabled | Should Be $true
					}
				}
			}
		}
	}
}

Describe "Column Identity Usage" -Tags IdentityUsage, $filename {
	$maxpercentage = Get-DbcConfigValue policy.identityusagepercent
	(Get-SqlInstance).ForEach{
		$results = Test-DbaIdentityUsage -SqlInstance $psitem
		foreach ($result in $results) {
			if ($result.Database -ne 'tempdb') {
				$columnfqdn = "$($result.Database).$($result.Schema).$($result.Table).$($result.Column)"
				It "usage for $columnfqdn on $psitem should be less than $maxpercentage percent" {
					$result.PercentUsed -lt $maxpercentage | Should be $true
				}
			}
		}
	}
}


Describe "Recovery Model" -Tags DISA, RecoveryModel, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem" {
			$results = Get-DbaDbRecoveryModel -SqlInstance $psitem
			foreach ($result in $results) {
				if ($result.Name -ne 'tempdb') {
					It "$($result.Name) on $psitem should be set to the proper recovery model" {
						$result.RecoveryModel | Should be (Get-DbcConfigValue policy.recoverymodel)
					}
				}
			}
		}
	}
}

Describe "Last Backup Times" -Tags Backup, DISA, LastBackup, $filename {
	(Get-SqlInstance).ForEach{
		$maxfull = Get-DbcConfigValue policy.backupfullmaxdays
		$maxdiff = Get-DbcConfigValue policy.backupdiffmaxhours
		$maxlog = Get-DbcConfigValue policy.backuplogmaxminutes
		$diffskip = Get-DbcConfigValue skip.backupdiffcheck
		
		Context "Testing backups on $psitem" {
			$results = Get-DbaDatabase -SqlInstance $psitem
			foreach ($result in $results) {
				
				It "full backups for $result should be less than $maxfull days" {
					$result.LastFullBackup -ge (Get-Date).AddDays(- ($maxfull)) | Should be $true
				}
				
				It -Skip:$diffskip "diff backups for $result should be less than $maxdiff hours" {
					$result.LastDiffBackup -ge (Get-Date).AddHours(- ($maxdiff)) | Should be $true
				}
				
				if ($result.RecoveryModel -ne 'Simple') {
					It "log backups for $result should be less than $maxlog minutes" {
						$result.LastLogBackup -ge (Get-Date).AddMinutes(- ($maxlog)) | Should be $true
					}
				}
			}
		}
	}
}

Describe "Duplicate Index" -Tags DuplicateIndex, $filename {
	(Get-SqlInstance).ForEach{
		$servername = $psitem
		Context "Testing $servername for duplicate indexes" {
			(Get-DbaDatabase -SqlInstance $servername).ForEach{
				It "$psitem should not have duplicate indexes" {
					Find-SqlDuplicateIndex -SqlInstance $servername -Database $psitem.Name | Should Be $null
				}
			}
		}
	}
}

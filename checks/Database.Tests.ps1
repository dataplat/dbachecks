$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Database Collation" -Tags DatabaseCollation, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing database collation on $psitem" {
			(Test-DbaDatabaseCollation -SqlInstance $psitem).ForEach{
				It "database collation ($($psitem.DatabaseCollation)) should match server collation ($($psitem.ServerCollation)) for $($psitem.Database) on $instance" {
					$psitem.ServerCollation -eq $psitem.DatabaseCollation | Should be $true
				}
			}
		}
	}
}

Describe 'Suspect Page' -Tags SuspectPage, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing suspect pages on $psitem" {
			(Get-DbaSuspectPage -SqlInstance $psitem).ForEach{
				It "Suspect Page has been found on database $psitem.DatabaseName" {
					$psitem.ErrorCount -eq 0 | Should be $true
				}
			}
		}
	}
}

Describe "Last Backup Restore & Integrity Checks" -Tags TestLastBackup, Backup, $filename {
	if (-not (Get-DbcConfigValue skip.backuptesting)) {
		$destserver = Get-DbcConfigValue setup.backuptestserver
		$destdata = Get-DbcConfigValue setup.backupdatadir
		$destlog = Get-DbcConfigValue setup.backuplogdir
		(Get-SqlInstance).ForEach{
			Context "Testing Backup Restore & Integrity Checks on $psitem" {
				(Test-DbaLastBackup -SqlInstance $psitem -Destination $destserver -LogDirectory $destlog -DataDirectory $destdata).ForEach{
					if ($psitem.DBCCResult -notmatch 'skipped for restored master') {
						It "DBCC for $($psitem.Database) should be success" {
							$psitem.DBCCResult | Should Be 'Success'
						}
						It "restore for $($psitem.Database) should be success" {
							$psitem.RestoreResult | Should Be 'Success'
						}
					}
				}
			}
		}
	}
}

Describe "Database Owners" -Tags DatabaseOwner, $filename {
	$targetowner = Get-DbcConfigValue policy.dbownershould
	(Get-SqlInstance).ForEach{
		Context "Testing Database Owners on $psitem" {
			(Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner).ForEach{
				It "$($psitem.Database) owner should be $targetowner" {
					$psitem.CurrentOwner | Should Be $psitem.TargetOwner
				}
			}
		}
	}
}

Describe "Not Database Owners" -Tags NotDatabaseOwner, $filename {
	$targetowner = Get-DbcConfigValue policy.dbownershouldnot
	(Get-SqlInstance).ForEach{
		Context "Testing Database Owners on $psitem" {
			(Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner).ForEach{
				It "$($psitem.Database) owner should Not be $targetowner" {
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
		Context "Testing Last Good DBCC CHECKDB on $psitem" {
			(Get-DbaLastGoodCheckDb -SqlInstance $psitem).ForEach{
				if ($psitem.Database -ne 'tempdb') {
					It "last good integrity check for $($psitem.Database) should be less than $maxdays" {
						$psitem.LastGoodCheckDb | Should BeGreaterThan (Get-Date).AddDays(- ($maxdays))
					}
					
					It -Skip:$datapurity "last good integrity check for $($psitem.Database) has Data Purity Enabled" {
						$psitem.DataPurityEnabled | Should Be $true
					}
				}
			}
		}
	}
}

Describe "Column Identity Usage" -Tags IdentityUsage, $filename {
	$maxpercentage = Get-DbcConfigValue policy.identityusagepercent
	(Get-SqlInstance).ForEach{
		Context "Testing Column Identity Usage on $psitem" {
			(Test-DbaIdentityUsage -SqlInstance $psitem).ForEach{
				if ($psitem.Database -ne 'tempdb') {
					$columnfqdn = "$($psitem.Database).$($psitem.Schema).$($psitem.Table).$($psitem.Column)"
					It "usage for $columnfqdn should be less than $maxpercentage percent" {
						$psitem.PercentUsed -lt $maxpercentage | Should be $true
					}
				}
			}
		}
	}
}

Describe "Recovery Model" -Tags DISA, RecoveryModel, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing Recovery Model on $psitem" {
			(Get-DbaDbRecoveryModel -SqlInstance $psitem -ExcludeDatabase tempdb).ForEach{
				It "$($psitem.Name) should be set to the proper recovery model" {
					$psitem.RecoveryModel | Should be (Get-DbcConfigValue policy.recoverymodel)
				}
			}
		}
	}
}

Describe "Last Backup Times" -Tags LastBackup, Backup, DISA, $filename {
	(Get-SqlInstance).ForEach{
		$maxfull = Get-DbcConfigValue policy.backupfullmaxdays
		$maxdiff = Get-DbcConfigValue policy.backupdiffmaxhours
		$maxlog = Get-DbcConfigValue policy.backuplogmaxminutes
		$diffskip = Get-DbcConfigValue skip.backupdiffcheck
		
		Context "Testing last backups on $psitem" {
			(Get-DbaDatabase -SqlInstance $psitem).ForEach{
				It "full backups should be less than $maxfull days" {
					$psitem.LastFullBackup -ge (Get-Date).AddDays(-($maxfull)) | Should be $true
				}
				
				It -Skip:$diffskip "diff backups should be less than $maxdiff hours" {
					$psitem.LastDiffBackup -ge (Get-Date).AddHours(-($maxdiff)) | Should be $true
				}
				
				if ($psitem.RecoveryModel -ne 'Simple') {
					It "log backups should be less than $maxlog minutes" {
						$psitem.LastLogBackup -ge (Get-Date).AddMinutes(-($maxlog)) | Should be $true
					}
				}
			}
		}
	}
}

Describe "Duplicate Index" -Tags DuplicateIndex, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing duplicate indexes on $psitem" {
			(Get-DbaDatabase -SqlInstance $psitem).ForEach{
				It "$psitem should not have duplicate indexes" {
					Find-SqlDuplicateIndex -SqlInstance $psitem.Parent -Database $psitem.Name | Should Be $null
				}
			}
		}
	}
}
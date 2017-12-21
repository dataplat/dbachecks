$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe 'Testing Database Collation' -Tags Collation, $filename {
	(Get-SqlInstance).ForEach{
		$results = Test-DbaDatabaseCollation -SqlInstance $psitem
		foreach ($result in $results) {
			It "database collation ($($result.DatabaseCollation)) on $psitem should match server collation ($($result.ServerCollation)) for $($result.Database) on $psitem" {
				$result.ServerCollation -eq $result.DatabaseCollation | Should be $true
			}
		}
	}
}

Describe 'Testing backups' -Tags Backup, BackupTest, $filename {
	if (-not (Get-DbcConfigValue skip.backuptesting)) {
		$destserver = Get-DbcConfigValue setup.backuptestserver
		$destdata = Get-DbcConfigValue setup.backupdatadir
		$destlog = Get-DbcConfigValue setup.backuplogdir
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

Describe 'Testing Database Owners' -Tags DatabaseOwner, $filename {
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

Describe 'Testing Database Owners' -Tags NotDatabaseOwner, $filename {
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

Describe 'Testing last good DBCC CHECKDB' -Tags Corruption, Integrity, DBCC, $filename {
	$maxdays = Get-DbcConfigValue policy.integritycheckmaxdays
	$datapurity = Get-DbcConfigValue skip.datapuritycheck
    (Get-SqlInstance).ForEach{
        Context "Testing $psitem " {
            $results = Get-DbaLastGoodCheckDb -SqlInstance $psitem
            foreach ($result in $results) {
                if ($result.Database -ne 'tempdb') {
                    It "last good integrity check for $($result.Database) on $psitem should be less than $maxdays" {
                        $result.LastGoodCheckDb | Should BeGreaterThan (Get-Date).AddDays( - ($maxdays))
                    }
				
                    It -Skip:$datapurity "last good integrity check for $($result.Database) on $psitem has Data Purity Enabled" {
                        $result.DataPurityEnabled | Should Be $true
                    }
                }
            }
        }
    }
}

Describe 'Testing Column Identity Usage' -Tags Identity, $filename {
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


Describe 'Testing Full Recovery Model' -Tags Database, DISA, RecoveryModel, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing $psitem" {
			$results = Get-DbaDbRecoveryModel -SqlInstance $psitem
			foreach ($result in $results) {
				if ($result.Name -ne 'tempdb') {
					It "$($result.Name) on $psitem should be set to the Full recovery model" {
						$result.RecoveryModel | Should be (Get-DbcConfigValue policy.recoverymodel)
					}
				}
			}
		}
	}
}


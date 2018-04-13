$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot/../internal/functions/Get-DatabaseInfo.ps1"

Describe "Last Backup Restore Test" -Tags TestLastBackup, $filename {
    if (-not (Get-DbcConfigValue skip.backup.testing)) {
        $destserver = Get-DbcConfigValue policy.backup.testserver
        $destdata = Get-DbcConfigValue policy.backup.datadir
        $destlog = Get-DbcConfigValue policy.backup.logdir
        @(Get-Instance).ForEach{
            Context "Testing Backup Restore & Integrity Checks on $psitem" {
            @(Test-DbaLastBackup -SqlInstance $psitem -Database ((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).Name -VerifyOnly).ForEach{
                    
                    if ($psitem.DBCCResult -notmatch "skipped for restored master") {
                        It "DBCC for $($psitem.Database) on $($psitem.SourceServer) Should Be success" {
                            $psitem.DBCCResult | Should -Be "Success" -Because "You need to run DBCC CHECKDB to ensure your database is consistent"
                        }
                        It "restore for $($psitem.Database) on $($psitem.SourceServer) Should Be success" {
                            $psitem.RestoreResult | Should -Be "Success" -Because "The backup file has not successfully restored - you have no backup"
                        }
                    }
                }
            }
        }
    }
}

Describe "Last Backup VerifyOnly" -Tags TestLastBackupVerifyOnly, $filename {
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        Context "VerifyOnly tests of last backups on $psitem" {
            @(Test-DbaLastBackup -SqlInstance $psitem -Database ((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).Name -VerifyOnly).ForEach{
                It "restore for $($psitem.Database) on $($psitem.SourceServer) Should be success" {
                    $psitem.RestoreResult | Should -Be "Success" -Because "The restore file has not successfully restored - you have no backup"
                }
                It "file exists for last backup of $($psitem.Database) on $($psitem.SourceServer)" {
                    $psitem.FileExists | Should -BeTrue -Because "Without a backup file you have no backup"
                }
            }
        }
    }
}

Describe "Last Full Backup Times" -Tags LastFullBackup, LastBackup, Backup, DISA, $filename {
    $maxfull = Get-DbcConfigValue policy.backup.fullmaxdays
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        Context "Testing last full backups on $psitem" {
            @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ ($psitem.Name -ne 'tempdb') -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                $offline = ($psitem.Status -match "Offline")
                It -Skip:$offline "$($psitem.Name) full backups on $($psitem.Parent.Name) Should Be less than $maxfull days" {
                    $psitem.LastBackupDate | Should -BeGreaterThan (Get-Date).AddDays( - ($maxfull)) -Because "Taking regular backups is extraordinarily important"
                }
            }
        }
    }
}

Describe "Last Diff Backup Times" -Tags LastDiffBackup, LastBackup, Backup, DISA, $filename {
    if (-not (Get-DbcConfigValue skip.diffbackuptest)) {
        $maxdiff = Get-DbcConfigValue policy.backup.diffmaxhours
        $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
        @(Get-Instance).ForEach{
            Context "Testing last diff backups on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                    $offline = ($psitem.Status -match "Offline")
                    It -Skip:$offline "$($psitem.Name) diff backups on $($psitem.Parent.Name) Should Be less than $maxdiff hours" {
                        $psitem.LastDifferentialBackupDate | Should -BeGreaterThan (Get-Date).AddHours( - ($maxdiff)) -Because 'Taking regular backups is extraordinarily important'
                    }
                }
            }
        }
    }
}

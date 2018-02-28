$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Database Collation" -Tags DatabaseCollation, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database collation on $psitem" {
            @(Test-DbaDatabaseCollation -SqlInstance $psitem -ExcludeDatabase ReportingServer,ReportingServerTempDB ).ForEach{
                It "database collation ($($psitem.DatabaseCollation)) should match server collation ($($psitem.ServerCollation)) for $($psitem.Database) on $($psitem.SqlInstance)" {
                    $psitem.ServerCollation | Should -Be $psitem.DatabaseCollation -Because 'You will get collation conflict errors in tempdb'
                }
            }
        }
    }
}

Describe "Suspect Page" -Tags SuspectPage, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing suspect pages on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                $results = Get-DbaSuspectPage -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$psitem should return 0 suspect pages on $($psitem.SqlInstance)" {
                    @($results).Count | Should -Be 0 -Because 'You dont want suspect pages'
                }
            }
        }
    }
}

Describe "Last Backup Restore Test" -Tags TestLastBackup, Backup, $filename {
    if (-not (Get-DbcConfigValue skip.backup.testing)) {
        $destserver = Get-DbcConfigValue policy.backup.testserver 
        $destdata = Get-DbcConfigValue policy.backup.datadir
        $destlog = Get-DbcConfigValue policy.backup.logdir
        (Get-SqlInstance).ForEach{
            Context "Testing Backup Restore & Integrity Checks on $psitem" {
                @(Test-DbaLastBackup -SqlInstance $psitem -Destination $destserver -LogDirectory $destlog -DataDirectory $destdata).ForEach{
                    if ($psitem.DBCCResult -notmatch 'skipped for restored master') {
                        It "DBCC for $($psitem.Database) on $($psitem.SourceServer) Should Be success" {
                            $psitem.DBCCResult | Should -Be 'Success' -Because 'You need to run DBCC CHECKDB to ensure your database is consistent'
                        }
                        It "restore for $($psitem.Database) on $($psitem.SourceServer) Should Be success" {
                            $psitem.RestoreResult | Should -Be 'Success' -Because 'The backup file has not successfully restored - you have no backup'
                        }
                    }
                }
            }
        }
    }
}

Describe "Last Backup VerifyOnly" -Tags TestLastBackupVerifyOnly, Backup, $filename {
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod 
    (Get-SqlInstance).ForEach{
        Context "VerifyOnly tests of last backups on $psitem" {
            @(Test-DbaLastBackup -SqlInstance $psitem -Database (Get-DbaDatabase -SqlInstance $psitem | Where-Object {$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod)}).name -VerifyOnly).ForEach{
                It "restore for $($psitem.Database) on $($psitem.SourceServer) Should Be success" {
                    $psitem.RestoreResult | Should -Be 'Success' -Because 'The restore file has not successfully restored - you have no backup'
                }
                It "file exists for last backup of $($psitem.Database) on $($psitem.SourceServer)" {
                    $psitem.FileExists | Should -BeTrue -Because 'Without a backup file you have no backup'
                }
            }
        }
    }
}

Describe "Valid Database Owner" -Tags ValidDatabaseOwner, $filename {
    $targetowner = Get-DbcConfigValue policy.validdbowner.name
    $exclude = Get-DbcConfigValue policy.validdbowner.excludedb 
    (Get-SqlInstance).ForEach{
        Context "Testing Database Owners on $psitem" {
            @(Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner -ExcludeDatabase $exclude -EnableException:$false).ForEach{
                It "$($psitem.Database) owner Should Be $targetowner on $($psitem.Server)" {
                    $psitem.CurrentOwner | Should -Be $psitem.TargetOwner -Because "The account that is the database owner is not what was expected"
                }
            }
        }
    }
}

Describe "Invalid Database Owner" -Tags InvalidDatabaseOwner, $filename {
    $targetowner = Get-DbcConfigValue policy.invaliddbowner.name
    $exclude = Get-DbcConfigValue policy.invaliddbowner.excludedb 
    (Get-SqlInstance).ForEach{
        Context "Testing Database Owners on $psitem" {
            @(Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner -ExcludeDatabase $exclude -EnableException:$false).ForEach{
                It "$($psitem.Database) owner should Not be $targetowner on $($psitem.Server)" {
                    $psitem.CurrentOwner | Should -Not -Be $psitem.TargetOwner -Because 'The database owner was one specified as incorrect'
                }
            }
        }
    }
}

Describe "Last Good DBCC CHECKDB" -Tags LastGoodCheckDb, $filename {
    $maxdays = Get-DbcConfigValue policy.dbcc.maxdays
    $datapurity = Get-DbcConfigValue skip.dbcc.datapuritycheck
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod    
    (Get-SqlInstance).ForEach{
        Context "Testing Last Good DBCC CHECKDB on $psitem" {
            @(Get-DbaLastGoodCheckDb -SqlInstance $psitem -Database (Get-DbaDatabase -SqlInstance $psitem | Where-Object {$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod)}).name).ForEach{
                if ($psitem.Database -ne 'tempdb') {
                    It "last good integrity check for $($psitem.Database) on $($psitem.SqlInstance) Should Be less than $maxdays" {
                        $psitem.LastGoodCheckDb | Should -BeGreaterThan (Get-Date).AddDays( - ($maxdays)) -Because 'You should have run a DBCC CheckDB inside that time'
                    }

                    It -Skip:$datapurity "last good integrity check for $($psitem.Database) on $($psitem.SqlInstance) has Data Purity Enabled" {
                        $psitem.DataPurityEnabled | Should -BeTrue -Because 'the DATA_PURITY option causes the CHECKDB command to look for column values that are invalid or out of range.'
                    }
                }
            }
        }
    }
}

Describe "Column Identity Usage" -Tags IdentityUsage, $filename {
    $maxpercentage = Get-DbcConfigValue policy.identity.usagepercent
    (Get-SqlInstance).ForEach{
        Context "Testing Column Identity Usage on $psitem" {
            @(Test-DbaIdentityUsage -SqlInstance $psitem).ForEach{
                if ($psitem.Database -ne 'tempdb') {
                    $columnfqdn = "$($psitem.Database).$($psitem.Schema).$($psitem.Table).$($psitem.Column)"
                    It "usage for $columnfqdn on $($psitem.SqlInstance) Should Be less than $maxpercentage percent" {
                        $psitem.PercentUsed -lt $maxpercentage | Should -BeTrue -Because 'You do not want your Identity columns to hit the max value and stop inserts'
                    }
                }
            }
        }
    }
}

Describe "Recovery Model" -Tags RecoveryModel, DISA, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Recovery Model on $psitem" {
            $exclude = Get-DbcConfigValue policy.recoverymodel.excludedb
            @(Get-DbaDbRecoveryModel -SqlInstance $psitem -ExcludeDatabase $exclude).ForEach{
                It "$($psitem.Name) Should -Be set to $((Get-DbcConfigValue policy.recoverymodel.type)) on $($psitem.SqlInstance)" {
                    $psitem.RecoveryModel | Should -Be (Get-DbcConfigValue policy.recoverymodel.type) -Because 'You expect this recovery model'
                }
            }
        }
    }
}

Describe "Duplicate Index" -Tags DuplicateIndex, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing duplicate indexes on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                $results = Find-DbaDuplicateIndex -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$psitem on $($psitem.Parent) should return 0 duplicate indexes" {
                    @($results).Count | Should -Be 0 -Because 'Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory'
                }
            }
        }
    }
}

Describe "Unused Index" -Tags UnusedIndex, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Unused indexes on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                try {
                    $results = Find-DbaUnusedIndex -SqlInstance $psitem.Parent -Database $psitem.Name -EnableException
                    It "$psitem on $($psitem.Parent) should return 0 Unused indexes" {
                        @($results).Count | Should -Be 0 -Because 'You should have indexes that are used'
                    }
                }
                catch {
                    It -Skip "$psitem on $($psitem.Parent) should return 0 Unused indexes" {
                        @($results).Count | Should -Be 0 -Because 'You should have indexes that are used'
                    }
                }
            }
        }
    }
}

Describe "Disabled Index" -Tags DisabledIndex, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Disabled indexes on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                $results = Find-DbaDisabledIndex -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$psitem on $($psitem.Parent) should return 0 Disabled indexes" {
                    @($results).Count | Should -Be 0 -Because 'Disabled indexes are wasting disk space'
                }
            }
        }
    }
}

Describe "Database Growth Event" -Tags DatabaseGrowthEvent, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database growth event on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                $results = Find-DbaDbGrowthEvent -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$psitem should return 0 database growth events on $($psitem.SqlInstance)" {
                    @($results).Count | Should -Be 0 -Because 'You want to control how your database files are grown'
                }
            }
        }
    }
}

Describe "Page Verify" -Tags PageVerify, $filename {
    $pageverify = Get-DbcConfigValue policy.pageverify
    (Get-SqlInstance).ForEach{
        Context "Testing page verify on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                It "$psitem on $($psitem.SqlInstance) should have page verify set to $pageverify" {
                    $psitem.PageVerify | Should -Be $pageverify -Because 'Page verify helps SQL Server to detect corruption'
                }
            }
        }
    }
}

Describe "Auto Close" -Tags AutoClose, $filename {
    $autoclose = Get-DbcConfigValue policy.database.autoclose
    (Get-SqlInstance).ForEach{
        Context "Testing Auto Close on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                It "$psitem on $($psitem.SqlInstance) should have Auto Close set to $autoclose" {
                    $psitem.AutoClose | Should -Be $autoclose -Because 'Because!'
                }
            }
        }
    }
}

Describe "Auto Shrink" -Tags AutoShrink, $filename {
    $autoshrink = Get-DbcConfigValue policy.database.autoshrink
    (Get-SqlInstance).ForEach{
        Context "Testing Auto Shrink on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                It "$psitem on $($psitem.SqlInstance) should have Auto Shrink set to $autoshrink" {
                    $psitem.AutoShrink | Should -Be $autoshrink -Because 'Shrinking databases causes fragmentation and performance issues'
                }
            }
        }
    }
}

Describe "Last Full Backup Times" -Tags LastFullBackup, LastBackup, Backup, DISA, $filename {
    $maxfull = Get-DbcConfigValue policy.backup.fullmaxdays
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    (Get-SqlInstance).ForEach{
        Context "Testing last full backups on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem -ExcludeDatabase tempdb | Where-Object {$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod)}).ForEach{
                $offline = ($psitem.Status -match "Offline")
                It -Skip:$offline "$($psitem.Name) full backups on $($psitem.SqlInstance) Should Be less than $maxfull days" {
                    $psitem.LastFullBackup | Should -BeGreaterThan (Get-Date).AddDays( - ($maxfull)) -Because 'Taking regular backups is extraordinarily important'
                }
            }
        }
    }
}

Describe "Last Diff Backup Times" -Tags LastDiffBackup, LastBackup, Backup, DISA, $filename {
    $maxdiff = Get-DbcConfigValue policy.backup.diffmaxhours
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    (Get-SqlInstance).ForEach{
        Context "Testing last diff backups on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem | Where-Object { (-not $psitem.IsSystemObject) -and $_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) }).ForEach{
                $offline = ($psitem.Status -match "Offline")
                It -Skip:$offline "$($psitem.Name) diff backups on $($psitem.SqlInstance) Should Be less than $maxdiff hours" {
                    $psitem.LastDiffBackup | Should -BeGreaterThan (Get-Date).AddHours(- ($maxdiff)) -Because 'Taking regular backups is extraordinarily important'
                }
            }
        }
    }
}

Describe "Last Log Backup Times" -Tags LastLogBackup, LastBackup, Backup, DISA, $filename {
    $maxlog = Get-DbcConfigValue policy.backup.logmaxminutes
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    (Get-SqlInstance).ForEach{
        Context "Testing last log backups on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem | Where-Object { -not $psitem.IsSystemObject -and $_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) }).ForEach{
                if ($psitem.RecoveryModel -ne 'Simple') {
                    $offline = ($psitem.Status -match "Offline")
                    It -Skip:$offline "$($psitem.Name) log backups on $($psitem.SqlInstance) Should Be less than $maxlog minutes" {
                        $psitem.LastLogBackup | Should -BeGreaterThan (Get-Date).AddMinutes(- ($maxlog) + 1) -Because 'Taking regular backups is extraordinarily important'
                    }
                }

            }
        }
    }
}

Describe "Virtual Log Files" -Tags VirtualLogFile, $filename {
    $vlfmax = Get-DbcConfigValue policy.database.maxvlf
    (Get-SqlInstance).ForEach{
        Context "Testing Database VLFs on $psitem" {
            @(Test-DbaVirtualLogFile -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) VLF count on $($psitem.SqlInstance) Should Be less than $vlfmax" {
                    $psitem.Total | Should -BeLessThan $vlfmax -Because 'Too many VLFs can impact performance and slow down backup/restore'
                }
            }
        }
    }
}

Describe "Log File Count Checks" -Tags LogfileCount, $filename {
    $LogFileCountTest = Get-DbcConfigValue skip.database.logfilecounttest
    $LogFileCount = Get-DbcConfigValue policy.database.logfilecount
    If (-not $LogFileCountTest) {
        (Get-SqlInstance).ForEach{
            Context "Testing Log File count and size for $psitem" {
                (Get-DbaDatabase -SqlInstance $psitem | Select-Object SqlInstance, Name).ForEach{
                    $Files = Get-DbaDatabaseFile -SqlInstance $psitem.SqlInstance -Database $psitem.Name
                    $LogFiles = $Files | Where-Object {$_.TypeDescription -eq 'LOG'}
                    It "$($psitem.Name) on $($psitem.SqlInstance) Should have less than $LogFileCount Log files" {
                        $LogFiles.Count | Should -BeLessThan $LogFileCount -Because 'You want the correct number of log files'
                    }
                }
            }
        }
    }
}

Describe "Log File Size Checks" -Tags LogfileSize, $filename {
    $LogFileSizePercentage = Get-DbcConfigValue policy.database.logfilesizepercentage
    $LogFileSizeComparison = Get-DbcConfigValue policy.database.logfilesizecomparison
    (Get-SqlInstance).ForEach{
        Context "Testing Log File count and size for $psitem" {
            (Get-DbaDatabase -SqlInstance $psitem | Select-Object SqlInstance, Name).ForEach{
                $Files = Get-DbaDatabaseFile -SqlInstance $psitem.SqlInstance -Database $psitem.Name
                $LogFiles = $Files | Where-Object {$_.TypeDescription -eq 'LOG'}
                $Splat = @{$LogFileSizeComparison = $true;
                    property                      = 'size'
                }
                $LogFileSize = ($LogFiles | Measure-Object -Property Size -Maximum).Maximum
                $DataFileSize = ($Files | Where-Object {$_.TypeDescription -eq 'ROWS'} | Measure-Object @Splat).$LogFileSizeComparison
                It "$($psitem.Name) on $($psitem.SqlInstance) Should have no log files larger than $LogFileSizePercentage% of the $LogFileSizeComparison of DataFiles" {
                    $LogFileSize | Should -BeLessThan ($DataFileSize * $LogFileSizePercentage) -Because 'If your log file is this large you are not maintaining it well enough'
                }
            }
        }
    }
}

Describe "Correctly sized Filegroup members" -Tags FileGroupBalanced, $filename {
    $Tolerance = Get-DbcConfigValue policy.database.filebalancetolerance

    (Get-SqlInstance).ForEach{
        Context "Testing for balanced FileGroups on $psitem" {
            (Get-DbaDatabase -SqlInstance $psitem | Select-Object SqlInstance, Name).ForEach{
                $Files = Get-DbaDatabaseFile -SqlInstance $psitem.SqlInstance -Database $psitem.Name
                $FileGroups = $Files | Where-Object {$_.TypeDescription -eq 'ROWS'} | Group-Object -Property FileGroupName
                $FileGroups.ForEach{
                    $Unbalanced = 0
                    $Average = ($psitem.Group.Size | Measure-Object -Average).Average

                    $Unbalanced = $psitem | Where-Object {$psitem.group.Size -lt ((1 - ($Tolerance / 100)) * $Average) -or $psitem.group.Size -gt ((1 + ($Tolerance / 100)) * $Average)}
                    It "$($psitem.Name) of $($psitem.Group[0].Database) on $($psitem.Group[0].SqlInstance)  Should have FileGroup members with sizes within 5% of the average" {
                        $Unbalanced.count | Should -Be 0 -Because 'If your file groups are not balanced SQL Server wont be optimal'
                    }
                }
            }
        }
    }
}

Describe "Auto Create Statistics" -Tags AutoCreateStatistics, $filename {
    $autocreatestatistics = Get-DbcConfigValue policy.database.autocreatestatistics
    (Get-SqlInstance).ForEach{
        Context "Testing Auto Create Statistics on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                It "$psitem on $($psitem.SqlInstance) should have Auto Create Statistics set to $autocreatestatistics" {
                    $psitem.AutoCreateStatisticsEnabled | Should -Be $autocreatestatistics -Because 'This is value expeceted for autocreate statistics'
                }
            }
        }
    }
}

Describe "Auto Update Statistics" -Tags AutoUpdateStatistics, $filename {
    $autoupdatestatistics = Get-DbcConfigValue policy.database.autoupdatestatistics
    (Get-SqlInstance).ForEach{
        Context "Testing Auto Update Statistics on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                It "$psitem on $($psitem.SqlInstance) should have Auto Update Statistics set to $autoupdatestatistics" {
                    $psitem.AutoUpdateStatisticsEnabled | Should -Be $autoupdatestatistics  -Because 'This is value expeceted for autoupdate statistics'
                }
            }
        }
    }
}

Describe "Auto Update Statistics Asynchronously" -Tags AutoUpdateStatisticsAsynchronously, $filename {
    $autoupdatestatisticsasynchronously = Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously
    (Get-SqlInstance).ForEach{
        Context "Testing Auto Update Statistics Asynchronously on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem).ForEach{
                It "$psitem on $($psitem.SqlInstance) should have Auto Update Statistics Asynchronously set to $autoupdatestatisticsasynchronously" {
                    $psitem.AutoUpdateStatisticsAsync | Should -Be $autoupdatestatisticsasynchronously  -Because 'This is value expeceted for autoupdate statistics asynchronously'
                }
            }
        }
    }
}

Describe "Datafile Auto Growth Configuration" -Tags DatafileAutoGrowthType, $filename {
    $datafilegrowthtype = Get-DbcConfigValue policy.database.filegrowthtype 
    $datafilegrowthvalue = Get-DbcConfigValue policy.database.filegrowthvalue 
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    (Get-SqlInstance).ForEach{
        Context "Testing datafile growth type on $psitem" {
            (Get-DbaDatabaseFile -SqlInstance $psitem -ExcludeDatabase $exclude ).ForEach{
                if (-Not (($psitem.Growth -eq 0) -and (Get-DbcConfigValue skip.database.filegrowthdisabled))) {
                    It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have GrowthType set to $datafilegrowthtype on $($psitem.SqlInstance)" {
                        $psitem.GrowthType | Should -Be $datafilegrowthtype -Because 'We expect a certain file growth type'
                    }
                    if ($datafilegrowthtype -eq "kb") {
                        It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have Growth set equal or higher than $datafilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth * 8 | Should -BeGreaterOrEqual $datafilegrowthvalue  -because 'We expect a certain file growth value'
                        }
                    }
                    else {
                        It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have Growth set equal or higher than $datafilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth | Should -BeGreaterOrEqual $datafilegrowthvalue  -because 'We expect a certain fFile growth value'
                        }
                    }
                }
            }
        }
    }
}

Describe "Trustworthy Option" -Tags Trustworthy, DISA, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database trustworthy option on $psitem" {
            @(Get-DbaDatabase -SqlInstance $psitem -ExcludeDatabase msdb).ForEach{
                It "Trustworthy is set to false on $($psitem.Name)" {
                    $psitem.Trustworthy | Should -BeFalse -Because 'Trustworthy has security implications and may expose your SQL Server to additional risk'
                }
            }
        }
    }
}

Describe "Database Orphaned User" -Tags OrphanedUser, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database orphaned user event on $psitem" {
            $results = Get-DbaOrphanUser -SqlInstance $psitem
            It "$psitem should return 0 orphaned users" {
                @($results).Count | Should -Be 0 -Because 'We dont want orphaned users'
            }
        }
    }
}

Describe "PseudoSimple Recovery Model" -Tags PseudoSimple, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database is not in PseudoSimple recovery model on $psitem" {
            @(Get-DbaDatabase -SqlInstance $PSItem -ExcludeDatabase tempdb).ForEach{
                It "$($psitem.Name) has PseudoSimple recovery model equal false on $($psitem.Parent)" {
                    (Test-DbaFullRecoveryModel -SqlInstance $psitem.Parent -Database $psitem.Name).ActualRecoveryModel -eq 'pseudo-SIMPLE' | Should -BeFalse -Because 'PseudoSimple means that a FULL backup has not been taken and the database is still effectively in SIMPLE mode'
                }
            }
        }
    }
}

Describe "Compatibility Level" -Tags CompatibilityLevel, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing database compatibility level matches server compatibility level on $psitem" {
            @(Test-DbaDatabaseCompatibility -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) has a database compatibility level equal to the level of $($psitem.SqlInstance)" {
                   $psItem.DatabaseCompatibility | Should -Be $psItem.ServerLevel -Because 'it means you are on the appropirate compatibility level for your SQL Server version to use all available features'
                }
            }
        }
    }
}
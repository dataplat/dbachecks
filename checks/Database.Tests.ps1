<# It is important to test our test. It really is. 
 # (http://jakubjares.com/2017/12/07/testing-your-environment-tests/)
 #
 #   To be able to do it with Pester one has to keep the test definition and the assertion 
 # in separate files. Writing a new test, or modifying an existing one typically involves 
 # modifications to the three related files:
 #
 # /confirms/Database.<CheckName>.ps1                     - where the confirms and config functions are defined
 # /checks/Database.Tests.ps1 (this file)                 - where the confirms are used to check stuff
 # /tests/confirms/Database.<CheckName>.Tests.ps1         - where the confirms are unit tested
 #>

$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot/../internal/functions/Get-DatabaseInfo.ps1"

# dot source the assertion files
@(Get-ChildItem "$PSScriptRoot/../confirms/$filename.*.ps1").ForEach{ . $psItem.FullName }

Describe "Auto Close" -Tags AutoClose, FastDatabase, $filename {
    $settings = Get-ConfigForAutoCloseCheck
    @(Get-Instance).ForEach{
        Context "Testing Auto Close on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) should have Auto Close set to $($settings.AutoClose)" {
                    $psitem | Confirm-AutoClose -With $settings -Because "Because!"
                }
            }
        }
    }
}

Describe "Auto Create Statistics" -Tags AutoCreateStatistics, FastDatabase, $filename {
    $settings = Get-ConfigForAutoCreateStatisticsCheck
    @(Get-Instance).ForEach{
        Context "Testing Auto Create Statistics on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) on $($psitem.SqlInstance) should have Auto Create Statistics set to $($settings.AutoCreateStatistics)" {
                    $psitem | Confirm-AutoCreateStatistics -With $settings -Because "This is value expeceted for autocreate statistics"
                }
            }
        }
    }
}

Describe "Auto Shrink" -Tags AutoShrink, $filename {
    $settings = Get-ConfigForAutoShrinkCheck
    @(Get-Instance).ForEach{
        Context "Testing Auto Shrink on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) on $($psitem.SqlInstance) should have Auto Shrink set to $($settings.AutoShrink)" {
                    $psitem | Confirm-AutoShrink -With $settings -Because "Shrinking databases causes fragmentation and performance issues"
                }
            }
        }
    }
}

Describe "Auto Update Statistics" -Tags AutoUpdateStatistics, FastDatabase, $filename {
    $settings = Get-ConfigForAutoUpdateStatisticsCheck
    @(Get-Instance).ForEach{
        Context "Testing Auto Update Statistics on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) on $($psitem.SqlInstance) should have Auto Update Statistics set to $($settings.AutoUpdateStatistics)" {
                    $psitem | Confirm-AutoUpdateStatistics -With $settings -Because "This is value expeceted for autoupdate statistics"
                }
            }
        }
    }
}

Describe "Auto Update Statistics Asynchronously" -Tags AutoUpdateStatisticsAsynchronously, FastDatabase, $filename {
    $settings = Get-ConfigForAutoUpdateStatisticsAsynchronouslyCheck
    @(Get-Instance).ForEach{
        Context "Testing Auto Update Statistics Asynchronously on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) on $($psitem.SqlInstance) should have Auto Update Statistics Asynchronously set to $($settings.AutoUpdateStatisticsAsynchronously)" {
                    $psitem | Confirm-AutoUpdateStatisticsAsynchronously -With $settings -Because "This is value expeceted for autoupdate statistics asynchronously"
                }
            }
        }
    }
}

Describe "Compatibility Level" -Tags CompatibilityLevel, FastDatabase, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database compatibility level matches server compatibility level on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) has a database compatibility level equal to the level of $($psitem.SqlInstance)" {
                    Confirm-CompatibilityLevel -Because "it means you are on the appropriate compatibility level for your SQL Server version to use all available features"
                }
            }
        }
    }
}

Describe "Database Collation" -Tags DatabaseCollation, FastDatabase, $filename {
    $settings = Get-ConfigForDatabaseCollactionCheck
    @(Get-Instance).ForEach{
        Context "Testing database collations on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "Collation of [$($psitem.Database)] should be as expected" {
                    $psitem | Confirm-DatabaseCollation -With $settings -Because 'you will get collation conflict errors in tempdb' 
                }
            }
        }
    }
}

Describe "Database Owner is not invalid" -Tags InvalidDatabaseOwner, FastDatabase, $filename {
    $settings = Get-ConfigForDatabaseOwnerIsNotInvalidCheck
    @(Get-Instance).ForEach{
        Context "Testing Database Owners on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "Database $($psitem.Database) - owner $($psitem.Owner) should Not be in this list ($( [String]::Join(", ", $settings.InvalidOwner))) on $($psitem.SqlInstance)" {
                    $psitem | Confirm-DatabaseOwnerIsNotInvalid -With $settings -Because "The database owner was one specified as incorrect"
                }
            }
        }
    }
}

Describe "Page Verify" -Tags PageVerify, FastDatabase, $filename {
    $settings = Get-ConfigForPageVerifyCheck 
    @(Get-Instance).ForEach{
        Context "Testing page verify on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) should have page verify set to $($settings.PageVerify)" {
                    $psitem | Confirm-PageVerify -With $settings -Because "Page verify helps SQL Server to detect corruption"
                }
            }
        }
    }
}

Describe "PseudoSimple Recovery Model" -Tags PseudoSimple, FastDatabase, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database is not in PseudoSimple recovery model on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$($psitem.Database) has PseudoSimple recovery model equal false on $($psitem.SqlInstance)" {
                    $psitem | Confirm-PseudoSimpleRecovery -Because "PseudoSimple means that a FULL backup has not been taken and the database is still effectively in SIMPLE mode"
                }
            }
        }
    }
}

Describe "Recovery Model" -Tags RecoveryModel, DISA, FastDatabase, $filename {
    $settings = Get-ConfigForRecoveryModelCheck
    @(Get-Instance).ForEach{
        Context "Testing Recovery Model on $psitem" {
            (Get-DatabaseInfo -SqlInstance $psitem -ExcludeDatabase $exclude).ForEach{
                It "$($psitem.Database) should be set to $($settings.RecoveryModel) on $($psitem.SqlInstance)" {
                    $psitem | Confirm-RecoveryModel -With $settings -Because "You expect this recovery model"
                }
            }
        }
    }
}

Describe "Suspect Page" -Tags SuspectPage, FastDatabase, $filename {
    @(Get-Instance).ForEach{
        Context "Testing suspect pages on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "$psitem should return 0 suspect pages on $($psitem.SqlInstance)" {
                    $psitem | Confirm-SuspectPageCount -Because 'You do not want any suspect pages'
                }
            }
        }
    }
}

Describe "Trustworthy Option" -Tags Trustworthy, DISA, FastDatabase, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database trustworthy option on $psitem" {
            @((Get-DatabaseInfo -SqlInstance $psitem).Where{$psitem.Database -ne 'msdb'}).ForEach{
                It "Trustworthy is set to false on $($psitem.Name)" {
                    $psitem | Confirm-Trustworthy -Because "Trustworthy has security implications and may expose your SQL Server to additional risk"
                }
            }
        }
    }
}

Describe "Database Owner is valid" -Tags ValidDatabaseOwner, FastDatabase, $filename {
    $settings = Get-ConfigForDatabaseOwnerIsValidCheck
    (Get-Instance).ForEach{
        Context "Testing Database Owners on $psitem" {
            @(Get-DatabaseInfo -SqlInstance $psitem).ForEach{
                It "Database $($psitem.Database) - owner $($psitem.Owner) should be in ($([String]::Join(",", $settings.ExpectedOwner))) on $($psitem.SqlInstance)" {
                    $psitem | Confirm-DatabaseOwnerIsValid -With $settings -Because "The database owner was one specified as incorrect"
                }
            }
        }
    }
}

# Still to be reviewed

Describe "Last Good DBCC CHECKDB" -Tags LastGoodCheckDb, $filename {
    $maxdays = Get-DbcConfigValue policy.dbcc.maxdays
    $datapurity = Get-DbcConfigValue skip.dbcc.datapuritycheck
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        Context "Testing Last Good DBCC CHECKDB on $psitem" {
            @(Get-DbaLastGoodCheckDb -SqlInstance $psitem -Database ((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($_.IsAccessible -eq $true) -and ($ExcludedDatabases -notcontains $_.Name)}).Name ).ForEach{
                if ($psitem.Database -ne "tempdb") {
                    It "last good integrity check for $($psitem.Database) on $($psitem.SqlInstance) Should Be less than $maxdays days old" {
                        $psitem.LastGoodCheckDb | Should -BeGreaterThan (Get-Date).AddDays( - ($maxdays)) -Because "You should have run a DBCC CheckDB inside that time"
                    }

                    It -Skip:$datapurity "last good integrity check for $($psitem.Database) on $($psitem.SqlInstance) has Data Purity Enabled" {
                        $psitem.DataPurityEnabled | Should -BeTrue -Because "the DATA_PURITY option causes the CHECKDB command to look for column values that are invalid or out of range."
                    }
                }
            }
        }
    }
}

Describe "Column Identity Usage" -Tags IdentityUsage, $filename {
    $maxpercentage = Get-DbcConfigValue policy.identity.usagepercent
    @(Get-Instance).ForEach{
        Context "Testing Column Identity Usage on $psitem" {
            @(Test-DbaIdentityUsage -SqlInstance $psitem).ForEach{
                if ($psitem.Database -ne "tempdb") {
                    $columnfqdn = "$($psitem.Database).$($psitem.Schema).$($psitem.Table).$($psitem.Column)"
                    It "usage for $columnfqdn on $($psitem.SqlInstance) Should Be less than $maxpercentage percent" {
                        $psitem.PercentUsed -lt $maxpercentage | Should -BeTrue -Because "You do not want your Identity columns to hit the max value and stop inserts"
                    }
                }
            }
        }
    }
}

Describe "Duplicate Index" -Tags DuplicateIndex, $filename {
    @(Get-Instance).ForEach{
        Context "Testing duplicate indexes on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                $results = Find-DbaDuplicateIndex -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$($psitem.Name) on $($psitem.Parent.Name) should return 0 duplicate indexes" {
                    @($results).Count | Should -Be 0 -Because "Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory"
                }
            }
        }
    }
}

Describe "Unused Index" -Tags UnusedIndex, $filename {
    @(Get-Instance).ForEach{
        Context "Testing Unused indexes on $psitem" {
            try {
                @($results = Find-DbaUnusedIndex -SqlInstance $psitem -EnableException).ForEach{
                    It "$psitem on $($psitem.SQLInstance) should return 0 Unused indexes" {
                        @($results).Count | Should -Be 0 -Because "You should have indexes that are used"
                    }
                }
            }
            catch {
                It -Skip "$psitem on $($psitem.SQLInstance) should return 0 Unused indexes" {
                    @($results).Count | Should -Be 0 -Because "You should have indexes that are used"
                }
            }
        }
    }
}

Describe "Disabled Index" -Tags DisabledIndex, $filename {
    @(Get-Instance).ForEach{
        Context "Testing Disabled indexes on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name -and ($_.IsAccessible -eq $true)}.ForEach{
                $results = Find-DbaDisabledIndex -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$($psitem.Name) on $($psitem.Parent.Name) should return 0 Disabled indexes" {
                    @($results).Count | Should -Be 0 -Because "Disabled indexes are wasting disk space"
                }
            }
        }
    }
}

Describe "Database Growth Event" -Tags DatabaseGrowthEvent, $filename {
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    @(Get-Instance).ForEach{
        Context "Testing database growth event on $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$PSItem.Name -notin $exclude -and ($ExcludedDatabases -notcontains $PsItem.Name)}.ForEach{
                $results = Find-DbaDbGrowthEvent -SqlInstance $psitem.Parent -Database $psitem.Name
                It "$($psitem.Name) should return 0 database growth events on $($psitem.Parent.Name)" {
                    @($results).Count | Should -Be 0 -Because "You want to control how your database files are grown"
                }
            }
        }
    }
}

Describe "Last Log Backup Times" -Tags LastLogBackup, LastBackup, Backup, DISA, $filename {
    $maxlog = Get-DbcConfigValue policy.backup.logmaxminutes
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        Context "Testing last log backups on $psitem" {
            @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                if ($psitem.RecoveryModel -ne "Simple") {
                    $offline = ($psitem.Status -match "Offline")
                    It -Skip:$offline "$($psitem.Name) log backups on $($psitem.Parent.Name) Should Be less than $maxlog minutes" {
                        $psitem.LastLogBackupDate | Should -BeGreaterThan (Get-Date).AddMinutes( - ($maxlog) + 1) -Because "Taking regular backups is extraordinarily important"
                    }
                }

            }
        }
    }
}

Describe "Virtual Log Files" -Tags VirtualLogFile, $filename {
    $vlfmax = Get-DbcConfigValue policy.database.maxvlf
    @(Get-Instance).ForEach{
        Context "Testing Database VLFs on $psitem" {
            @(Test-DbaDbVirtualLogFile -SqlInstance $_ -ExcludeDatabase $ExcludedDatabases).ForEach{
                It "$($psitem.Database) VLF count on $($psitem.SqlInstance) Should Be less than $vlfmax" {
                    $psitem.Total | Should -BeLessThan $vlfmax -Because "Too many VLFs can impact performance and slow down backup/restore"
                }
            }
        }
    }
}

Describe "Log File Count Checks" -Tags LogfileCount, $filename {
    $LogFileCountTest = Get-DbcConfigValue skip.database.logfilecounttest
    $LogFileCount = Get-DbcConfigValue policy.database.logfilecount
    If (-not $LogFileCountTest) {
        @(Get-Instance).ForEach{
            Context "Testing Log File count and size for $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $_.Name}).ForEach{
                    $Files = Get-DbaDatabaseFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
                    $LogFiles = $Files | Where-Object {$_.TypeDescription -eq "LOG"}
                    It "$($psitem.Name) on $($psitem.Parent.Name) Should have less than $LogFileCount Log files" {
                        $LogFiles.Count | Should -BeLessThan $LogFileCount -Because "You want the correct number of log files"
                    }
                }
            }
        }
    }
}

Describe "Log File Size Checks" -Tags LogfileSize, $filename {
    $LogFileSizePercentage = Get-DbcConfigValue policy.database.logfilesizepercentage
    $LogFileSizeComparison = Get-DbcConfigValue policy.database.logfilesizecomparison
    @(Get-Instance).ForEach{
        Context "Testing Log File count and size for $psitem" {
            @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                $Files = Get-DbaDatabaseFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
                $LogFiles = $Files | Where-Object {$_.TypeDescription -eq "LOG"}
                $Splat = @{$LogFileSizeComparison = $true;
                    property                      = "size"
                }
                $LogFileSize = ($LogFiles | Measure-Object -Property Size -Maximum).Maximum
                $DataFileSize = ($Files | Where-Object {$_.TypeDescription -eq "ROWS"} | Measure-Object @Splat).$LogFileSizeComparison
                It "$($psitem.Name) on $($psitem.Parent.Name) Should have no log files larger than $LogFileSizePercentage% of the $LogFileSizeComparison of DataFiles" {
                    $LogFileSize | Should -BeLessThan ($DataFileSize * $LogFileSizePercentage) -Because "If your log file is this large you are not maintaining it well enough"
                }
            }
        }
    }
}

Describe "Future File Growth" -Tags FutureFileGrowth, $filename {
    $threshold = Get-DbcConfigValue policy.database.filegrowthfreespacethreshold
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    @(Get-Instance).ForEach{
        Context "Testing for files likely to grow soon on $psitem" {
            @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.Name -notin $exclude -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                $Files = Get-DbaDatabaseFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
                $Files | Add-Member ScriptProperty -Name PercentFree -Value {100 - [Math]::Round(([int64]$PSItem.UsedSpace.Byte / [int64]$PSItem.Size.Byte) * 100, 3)}
                $Files | ForEach-Object {
                    if (-Not (($PSItem.Growth -eq 0) -and (Get-DbcConfigValue skip.database.filegrowthdisabled))) {
                        It "$($PSItem.Database) file $($PSItem.LogicalName) on $($PSItem.SqlInstance) has free space under threshold" {
                            $PSItem.PercentFree | Should -BeGreaterOrEqual $threshold -Because "free space within the file should be lower than threshold of $threshold %"
                        }
                    }
                }
            }
        }
    }
}

Describe "Correctly sized Filegroup members" -Tags FileGroupBalanced, $filename {
    $Tolerance = Get-DbcConfigValue policy.database.filebalancetolerance
    @(Get-Instance).ForEach{
        Context "Testing for balanced FileGroups on $psitem" {
            @((Connect-DbaInstance -SqlInstance $_).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}).ForEach{
                $Files = Get-DbaDatabaseFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
                $FileGroups = $Files | Where-Object {$_.TypeDescription -eq "ROWS"} | Group-Object -Property FileGroupName
                @($FileGroups).ForEach{
                    $Unbalanced = 0
                    $Average = ($psitem.Group.Size | Measure-Object -Average).Average

                    $Unbalanced = $psitem | Where-Object {$psitem.group.Size -lt ((1 - ($Tolerance / 100)) * $Average) -or $psitem.group.Size -gt ((1 + ($Tolerance / 100)) * $Average)}
                    It "$($psitem.Name) of $($psitem.Group[0].Database) on $($psitem.Group[0].SqlInstance)  Should have FileGroup members with sizes within 5% of the average" {
                        $Unbalanced.count | Should -Be 0 -Because "If your file groups are not balanced SQL Server wont be optimal"
                    }
                }
            }
        }
    }
}

Describe "Certificate Expiration" -Tags CertificateExpiration, $filename {
    $CertificateWarning = Get-DbcConfigValue policy.certificateexpiration.warningwindow
    $exclude = Get-DbcConfigValue policy.certificateexpiration.excludedb
    @(Get-Instance).ForEach{
        Context "Checking that encryption certificates have not expired on $psitem" {
            @(Get-DbaDatabaseEncryption -SqlInstance $psitem -IncludeSystemDBs | Where-Object {$_.Encryption -eq "Certificate" -and !($exclude.contains($_.Database))}).ForEach{
                It "$($psitem.Name) in $($psitem.Database) has not expired" {
                    $psitem.ExpirationDate  | Should -BeGreaterThan (Get-Date) -Because "this certificate should not be expired"
                }
                It "$($psitem.Name) in $($psitem.Database) does not expire for more than $CertificateWarning months" {
                    $psitem.ExpirationDate  | Should -BeGreaterThan (Get-Date).AddMonths($CertificateWarning) -Because "expires inside the warning window of $CertificateWarning"
                }
            }
        }
    }
}

Describe "Datafile Auto Growth Configuration" -Tags DatafileAutoGrowthType, $filename {
    $datafilegrowthtype = Get-DbcConfigValue policy.database.filegrowthtype
    $datafilegrowthvalue = Get-DbcConfigValue policy.database.filegrowthvalue
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    $exclude += $ExcludedDatabases 
    @(Get-Instance).ForEach{
        Context "Testing datafile growth type on $psitem" {
            @(Get-DbaDatabaseFile -SqlInstance $psitem -ExcludeDatabase $exclude ).ForEach{
                if (-Not (($psitem.Growth -eq 0) -and (Get-DbcConfigValue skip.database.filegrowthdisabled))) {
                    It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have GrowthType set to $datafilegrowthtype on $($psitem.SqlInstance)" {
                        $psitem.GrowthType | Should -Be $datafilegrowthtype -Because "We expect a certain file growth type"
                    }
                    if ($datafilegrowthtype -eq "kb") {
                        It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have Growth set equal or higher than $datafilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth * 8 | Should -BeGreaterOrEqual $datafilegrowthvalue  -because "We expect a certain file growth value"
                        }
                    }
                    else {
                        It "$($psitem.LogicalName) on filegroup $($psitem.FileGroupName) should have Growth set equal or higher than $datafilegrowthvalue on $($psitem.SqlInstance)" {
                            $psitem.Growth | Should -BeGreaterOrEqual $datafilegrowthvalue  -because "We expect a certain fFile growth value"
                        }
                    }
                }
            }
        }
    }
}

Describe "Database Orphaned User" -Tags OrphanedUser, $filename {
    @(Get-Instance).ForEach{
        Context "Testing database orphaned user event on $psitem" {
            $results = Get-DbaOrphanUser -SqlInstance $psitem
            It "$psitem should return 0 orphaned users" {
                @($results).Count | Should -Be 0 -Because "We dont want orphaned users"
            }
        }
    }
}

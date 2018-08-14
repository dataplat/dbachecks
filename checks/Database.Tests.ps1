$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Database.Assertions.ps1 

$ExcludedDatabases = Get-DbcConfigValue command.invokedbccheck.excludedatabases
$ExcludedDatabases += $ExcludeDatabase
$NotContactable = Get-PSFConfig -Module dbachecks -Name global.notcontactable 

@(Get-Instance).ForEach{
    if ($NotContactable -notcontains $psitem) {
        $Instance = $psitem
        try {  
            $connectioncheck = Connect-DbaInstance  -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
        }
        catch {
            $NotContactable += $Instance
        }
        if ($null -eq $connectioncheck.version) {
            $NotContactable += $Instance
        }
        else {

        }
    }
}

Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable 
Describe "Database Collation" -Tags DatabaseCollation, $filename {
    $Wrongcollation = Get-DbcConfigValue policy.database.wrongcollation
    $exclude = "ReportingServer", "ReportingServerTempDB"
    $exclude += $Wrongcollation
    $exclude += $ExcludedDatabases
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing database collation on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database collation on $psitem" {
                @(Test-DbaDatabaseCollation -SqlInstance $psitem -ExcludeDatabase $exclude ).ForEach{
                    It "database collation ($($psitem.DatabaseCollation)) should match server collation ($($psitem.ServerCollation)) for $($psitem.Database) on $($psitem.SqlInstance)" {
                        $psitem.ServerCollation | Should -Be $psitem.DatabaseCollation -Because "You will get collation conflict errors in tempdb"
                    }
                }
                if ($Wrongcollation) {
                    @(Test-DbaDatabaseCollation -SqlInstance $psitem -Database $Wrongcollation ).ForEach{
                        It "database collation ($($psitem.DatabaseCollation)) should not match server collation ($($psitem.ServerCollation)) for $($psitem.Database) on $($psitem.SqlInstance)" {
                            $psitem.ServerCollation | Should -Not -Be $psitem.DatabaseCollation -Because "You have defined the database to have another collation then the server. You will get collation conflict errors in tempdb"
                        }
                    }
                }
            }
        }
    }
}

Describe "Suspect Page" -Tags SuspectPage, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing suspect pages on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing suspect pages on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    $results = Get-DbaSuspectPage -SqlInstance $psitem.Parent -Database $psitem.Name
                    It "$($psitem.Name) should return 0 suspect pages on $($psitem.Parent.Name)" {
                        @($results).Count | Should -Be 0 -Because "You do not want suspect pages"
                    }
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
        @(Get-Instance).ForEach{
            if ($NotContactable -contains $psitem) {
                Context "Testing Backup Restore & Integrity Checks on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                if (-not $destserver) {
                    $destserver = $psitem
                }
                Context "Testing Backup Restore & Integrity Checks on $psitem" {
                    $srv = Connect-DbaInstance -SqlInstance $psitem
                    $dbs = ($srv.Databases.Where{$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).Name
                    if (-not ($destdata)) {$destdata -eq $srv.DefaultFile}
                    if (-not ($destlog)) {$destlog -eq $srv.DefaultLog}
                    @(Test-DbaLastBackup -SqlInstance $psitem -Database $dbs -Destination $destserver -DataDirectory $destdata -LogDirectory $destlog -VerifyOnly).ForEach{                    if ($psitem.DBCCResult -notmatch "skipped for restored master") {
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
}

Describe "Last Backup VerifyOnly" -Tags TestLastBackupVerifyOnly, Backup, $filename {
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "VerifyOnly tests of last backups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "VerifyOnly tests of last backups on $psitem" {
                @(Test-DbaLastBackup -SqlInstance $psitem -Database ((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).Name -VerifyOnly).ForEach{
                    It "restore for $($psitem.Database) on $($psitem.SourceServer) Should be success" {
                        $psitem.RestoreResult | Should -Be "Success" -Because "The restore file has not successfully verified - you have no backup"
                    }
                    It "file exists for last backup of $($psitem.Database) on $($psitem.SourceServer)" {
                        $psitem.FileExists | Should -BeTrue -Because "Without a backup file you have no backup"
                    }
                }
            }
        }
    }
}

Describe "Valid Database Owner" -Tags ValidDatabaseOwner, $filename {
    [string[]]$targetowner = Get-DbcConfigValue policy.validdbowner.name
    [string[]]$exclude = Get-DbcConfigValue policy.validdbowner.excludedb
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Database Owners on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Database Owners on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{if($database){$_.Name -in $database}else{$_.Name -notin $exclude -and ($ExcludedDatabases -notcontains $_.Name)}}).ForEach{
                    It "Database $($psitem.Name) - owner $($psitem.Owner) should be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.Parent.Name)" {
                        $psitem.Owner | Should -BeIn $TargetOwner -Because "The account that is the database owner is not what was expected"
                    }
                }
            }
        }
    }
}

Describe "Invalid Database Owner" -Tags InvalidDatabaseOwner, $filename {
    [string[]]$targetowner = Get-DbcConfigValue policy.invaliddbowner.name
    [string[]]$exclude = Get-DbcConfigValue policy.invaliddbowner.excludedb
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Database Owners on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Database Owners on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.Name -notin $exclude -and ($ExcludedDatabases -notcontains $_.Name)}).ForEach{
                    It "Database $($psitem.Name) - owner $($psitem.Owner) should Not be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.Parent.Name)" {
                        $psitem.Owner | Should -Not -BeIn $TargetOwner -Because "The database owner was one specified as incorrect"
                    }
                }
            }
        }
    }
}

Describe "Last Good DBCC CHECKDB" -Tags LastGoodCheckDb, $filename {
    $maxdays = Get-DbcConfigValue policy.dbcc.maxdays
    $datapurity = Get-DbcConfigValue skip.dbcc.datapuritycheck
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Last Good DBCC CHECKDB on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
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
}

Describe "Column Identity Usage" -Tags IdentityUsage, $filename {
    $maxpercentage = Get-DbcConfigValue policy.identity.usagepercent
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Column Identity Usage on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Column Identity Usage on $psitem" {
                $exclude = $ExcludedDatabases
                $exclude += (Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.IsAccessible -eq $false}.Name
                @(Test-DbaIdentityUsage -SqlInstance $psitem -ExcludeDatabase $exclude).ForEach{
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
}

Describe "Recovery Model" -Tags RecoveryModel, DISA, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Recovery Model on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            $recoverymodel = Get-DbcConfigValue policy.recoverymodel.type
            Context "Testing Recovery Model on $psitem" {
                $exclude = Get-DbcConfigValue policy.recoverymodel.excludedb
                $exclude += $ExcludedDatabases 
                @(Get-DbaDbRecoveryModel -SqlInstance $psitem -ExcludeDatabase $exclude).ForEach{
                    It "$($psitem.Name) should be set to $recoverymodel on $($psitem.SqlInstance)" {
                        $psitem.RecoveryModel | Should -Be $recoverymodel -Because "You expect this recovery model"
                    }
                }
            }
        }
    }
}

Describe "Duplicate Index" -Tags DuplicateIndex, $filename {
    $Excludeddbs = $ExcludedDatabases + 'msdb'
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing duplicate indexes on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing duplicate indexes on $psitem" {
                $instance = $Psitem
                @(Get-Database -Instance $instance -Requiredinfo Name -Exclusions NotAccessible -ExcludedDbs $Excludeddbs).ForEach{
                    It "$($psitem) on $Instance should return 0 duplicate indexes" {
                        Assert-DatabaseDuplicateIndex -Instance $instance -Database $psItem
                    }
                }
            }
        }
    }
}

Describe "Unused Index" -Tags UnusedIndex, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Unused indexes on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Unused indexes on $psitem" {
                try {
                    @($results = Find-DbaUnusedIndex -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases -EnableException).ForEach{
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
}

Describe "Disabled Index" -Tags DisabledIndex, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Disabled indexes on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
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
}

Describe "Database Growth Event" -Tags DatabaseGrowthEvent, $filename {
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing database growth event on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
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
}

Describe "Page Verify" -Tags PageVerify, $filename {
    $pageverify = Get-DbcConfigValue policy.pageverify
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing page verify on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing page verify on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have page verify set to $pageverify" {
                        $psitem.PageVerify | Should -Be $pageverify -Because "Page verify helps SQL Server to detect corruption"
                    }
                }
            }
        }
    }
}

Describe "Auto Close" -Tags AutoClose, $filename {
    $autoclose = Get-DbcConfigValue policy.database.autoclose
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Close on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Close on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Close set to $autoclose" {
                        $psitem.AutoClose | Should -Be $autoclose -Because "Because!"
                    }
                }
            }
        }
    }
}

Describe "Auto Shrink" -Tags AutoShrink, $filename {
    $autoshrink = Get-DbcConfigValue policy.database.autoshrink
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Shrink on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Shrink on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Shrink set to $autoshrink" {
                        $psitem.AutoShrink | Should -Be $autoshrink -Because "Shrinking databases causes fragmentation and performance issues"
                    }
                }
            }
        }
    }
}

Describe "Last Full Backup Times" -Tags LastFullBackup, LastBackup, Backup, DISA, $filename {
    $maxfull = Get-DbcConfigValue policy.backup.fullmaxdays
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    $skipreadonly = Get-DbcConfigValue skip.backup.readonly
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing last full backups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing last full backups on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ ($psitem.Name -ne 'tempdb') -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                    $skip = ($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)
                    It -Skip:$skip "$($psitem.Name) full backups on $($psitem.Parent.Name) Should Be less than $maxfull days" {
                        $psitem.LastBackupDate | Should -BeGreaterThan (Get-Date).AddDays( - ($maxfull)) -Because "Taking regular backups is extraordinarily important"
                    }
                }
            }
        }
    }
}

Describe "Last Diff Backup Times" -Tags LastDiffBackup, LastBackup, Backup, DISA, $filename {
    if (-not (Get-DbcConfigValue skip.diffbackuptest)) {
        $maxdiff = Get-DbcConfigValue policy.backup.diffmaxhours
        $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
        $skipreadonly = Get-DbcConfigValue skip.backup.readonly
        @(Get-Instance).ForEach{
            if ($NotContactable -contains $psitem) {
                Context "Testing last diff backups on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Testing last diff backups on $psitem" {
                    @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                        $skip = ($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)
                        It -Skip:$skip "$($psitem.Name) diff backups on $($psitem.Parent.Name) Should Be less than $maxdiff hours" {
                            $psitem.LastDifferentialBackupDate | Should -BeGreaterThan (Get-Date).AddHours( - ($maxdiff)) -Because 'Taking regular backups is extraordinarily important'
                        }
                    }
                }
            }
        }
    }
}

Describe "Last Log Backup Times" -Tags LastLogBackup, LastBackup, Backup, DISA, $filename {
    $maxlog = Get-DbcConfigValue policy.backup.logmaxminutes
    $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
    $skipreadonly = Get-DbcConfigValue skip.backup.readonly
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing last log backups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing last log backups on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate -lt (Get-Date).AddHours( - $graceperiod) -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                    if ($psitem.RecoveryModel -ne "Simple") {
                        $skip = ($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)
                        It -Skip:$skip  "$($psitem.Name) log backups on $($psitem.Parent.Name) Should Be less than $maxlog minutes" {
                            $psitem.LastLogBackupDate | Should -BeGreaterThan (Get-Date).AddMinutes( - ($maxlog) + 1) -Because "Taking regular backups is extraordinarily important"
                        }
                    }
                }
            }
        }
    }
}

Describe "Virtual Log Files" -Tags VirtualLogFile, $filename {
    $vlfmax = Get-DbcConfigValue policy.database.maxvlf
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Database VLFs on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Database VLFs on $psitem" {
                @(Test-DbaDbVirtualLogFile -SqlInstance $_ -ExcludeDatabase $ExcludedDatabases).ForEach{
                    It "$($psitem.Database) VLF count on $($psitem.SqlInstance) Should Be less than $vlfmax" {
                        $psitem.Total | Should -BeLessThan $vlfmax -Because "Too many VLFs can impact performance and slow down backup/restore"
                    }
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
            if ($NotContactable -contains $psitem) {
                Context "Testing Log File count for $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Testing Log File count for $psitem" {
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
}

Describe "Log File Size Checks" -Tags LogfileSize, $filename {
    $LogFileSizePercentage = Get-DbcConfigValue policy.database.logfilesizepercentage
    $LogFileSizeComparison = Get-DbcConfigValue policy.database.logfilesizecomparison
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Log File size for $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Log File size for $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name -and ($Psitem.IsAccessible -eq $true)}.ForEach{
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
}

Describe "Future File Growth" -Tags FutureFileGrowth, $filename {
    $threshold = Get-DbcConfigValue policy.database.filegrowthfreespacethreshold
    $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing for files likely to grow soon on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
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
}


Describe "Correctly sized Filegroup members" -Tags FileGroupBalanced, $filename {
    $Tolerance = Get-DbcConfigValue policy.database.filebalancetolerance
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing for balanced FileGroups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing for balanced FileGroups on $psitem" {
                @((Connect-DbaInstance -SqlInstance $_).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}).ForEach{
                    $Files = Get-DbaDatabaseFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
                    $FileGroups = $Files | Where-Object {$_.TypeDescription -eq "ROWS"} | Group-Object -Property FileGroupName
                    @($FileGroups).ForEach{
                        $Unbalanced = 0
                        $Average = ($psitem.Group.Size | Measure-Object -Average).Average
                        ## files where average size is less than 95% of the average or more than 105% of the average filegroup size (using default 5% config value)
                        $Unbalanced = $psitem | Where-Object {$psitem.group.Size -lt ((1 - ($Tolerance / 100)) * $Average) -or $psitem.group.Size -gt ((1 + ($Tolerance / 100)) * $Average)}
                        It "$($psitem.Name) of $($psitem.Group[0].Database) on $($psitem.Group[0].SqlInstance) Should have FileGroup members with sizes within $tolerance % of the average" {
                            $Unbalanced.count | Should -Be 0 -Because "If your file groups are not balanced the files with the most free space will become allocation hotspots"
                        }
                    }
                }
            }
        }
    }
}

Describe "Certificate Expiration" -Tags CertificateExpiration, $filename {
    $CertificateWarning = Get-DbcConfigValue policy.certificateexpiration.warningwindow
    $exclude = Get-DbcConfigValue policy.certificateexpiration.excludedb
    $exclude += $ExcludedDatabases
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Checking that encryption certificates have not expired on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
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
}

Describe "Auto Create Statistics" -Tags AutoCreateStatistics, $filename {
    $autocreatestatistics = Get-DbcConfigValue policy.database.autocreatestatistics
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Create Statistics on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Create Statistics on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Create Statistics set to $autocreatestatistics" {
                        $psitem.AutoCreateStatisticsEnabled | Should -Be $autocreatestatistics -Because "This is value expeceted for autocreate statistics"
                    }
                }
            }
        }
    }
}

Describe "Auto Update Statistics" -Tags AutoUpdateStatistics, $filename {
    $autoupdatestatistics = Get-DbcConfigValue policy.database.autoupdatestatistics
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Update Statistics on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Update Statistics on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Update Statistics set to $autoupdatestatistics" {
                        $psitem.AutoUpdateStatisticsEnabled | Should -Be $autoupdatestatistics  -Because "This is value expeceted for autoupdate statistics"
                    }
                }
            }
        }
    }
}

Describe "Auto Update Statistics Asynchronously" -Tags AutoUpdateStatisticsAsynchronously, $filename {
    $autoupdatestatisticsasynchronously = Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Update Statistics Asynchronously on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Update Statistics Asynchronously on $psitem" {
                @(Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$ExcludedDatabases -notcontains $PsItem.Name}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Update Statistics Asynchronously set to $autoupdatestatisticsasynchronously" {
                        $psitem.AutoUpdateStatisticsAsync | Should -Be $autoupdatestatisticsasynchronously  -Because "This is value expeceted for autoupdate statistics asynchronously"
                    }
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
        if ($NotContactable -contains $psitem) {
            Context "Testing datafile growth type on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
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
}

Describe "Trustworthy Option" -Tags Trustworthy, DISA, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing database trustworthy option on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database trustworthy option on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.Name -ne 'msdb' -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                    It "Trustworthy is set to false on $($psitem.Name)" {
                        $psitem.Trustworthy | Should -BeFalse -Because "Trustworthy has security implications and may expose your SQL Server to additional risk"
                    }
                }
            }
        }
    }
}

Describe "Database Orphaned User" -Tags OrphanedUser, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing database orphaned user event on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database orphaned user event on $psitem" {
                $results = Get-DbaOrphanUser -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases
                It "$psitem should return 0 orphaned users" {
                    @($results).Count | Should -Be 0 -Because "We dont want orphaned users"
                }
            }
        }
    }
}

Describe "PseudoSimple Recovery Model" -Tags PseudoSimple, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing database is not in PseudoSimple recovery model on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database is not in PseudoSimple recovery model on $psitem" {
                @((Connect-DbaInstance -SqlInstance $psitem).Databases.Where{$_.Name -ne 'tempdb' -and $_.Name -ne 'model' -and ($ExcludedDatabases -notcontains $PsItem.Name)}).ForEach{
                    if (-not($psitem.RecoveryModel -eq "Simple")) {
                        It "$($psitem.Name) has PseudoSimple recovery model equal false on $($psitem.Parent.Name)" { (Test-DbaRecoveryModel -SqlInstance $psitem.Parent -Database $psitem.Name).ActualRecoveryModel -eq "SIMPLE" | Should -BeFalse -Because "PseudoSimple means that a FULL backup has not been taken and the database is still effectively in SIMPLE mode" } 
                    }
                }
            }
        }
    }
}

Describe "Compatibility Level" -Tags CompatibilityLevel, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing database compatibility level matches server compatibility level on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database compatibility level matches server compatibility level on $psitem" {
                @(Test-DbaDatabaseCompatibility -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases).ForEach{
                    It "$($psitem.Database) has a database compatibility level equal to the level of $($psitem.SqlInstance)" {
                        $psItem.DatabaseCompatibility | Should -Be $psItem.ServerLevel -Because "it means you are on the appropriate compatibility level for your SQL Server version to use all available features"
                    }
                }
            }
        }
    }
}

Describe "Foreign keys and check constraints not trusted" -Tags FKCKTrusted, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Foreign Keys and Check Constraints are not trusted $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Foreign Keys and Check Constraints are not trusted $psitem" {
                @(Get-DbaDbForeignKey -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases).Where{$_.NotForReplication -eq $false}.ForEach{
                    It "$($psitem.Name) foreign key on table $($psitem.Parent) within database $($psitem.Database) should be trusted." {
                        $psitem.IsChecked | Should -Be $true -Because "This can have a huge performance impact on queries. SQL Server won’t use untrusted constraints to build better execution plans. It will also avoid data violation"
                    }
                }

                @(Get-DbaDbCheckConstraint -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases).Where{$_.NotForReplication -eq $false -and $_.IsEnabled -eq $true}.ForEach{
                    It "$($psitem.Name) check constraint on table $($psitem.Parent) within database $($psitem.Database) should be trusted." {
                        $psitem.IsChecked | Should -Be $true -Because "This can have a huge performance impact on queries. SQL Server won’t use untrusted constraints to build better execution plans. It will also avoid data violation"
                    }
                }
            }
        }
    }
}

Describe "Database MaxDop" -Tags MaxDopDatabase, MaxDop, $filename {
    $MaxDopValue = Get-DbcConfigValue policy.database.maxdop
    $Excluded = Get-DbcConfigValue policy.database.maxdopexcludedb
    $excluded += $ExcludedDatabases
    if ($Excluded) {Write-Warning "Excluded $Excluded from testing"}
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Database MaxDop setting is correct on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Database MaxDop setting is correct on $psitem" {
                @(Test-DbaMaxDop -SqlInstance $psitem).Where{$_.Database -ne 'N/A' -and $_.Database -notin $Excluded}.ForEach{
                    It "Database $($psitem.Database) should have the correct MaxDop setting" {
                        Assert-DatabaseMaxDop -MaxDop $PsItem -MaxDopValue $MaxDopValue
                    }
                }
            }
        }
    }
}

Describe "Database Status" -Tags DatabaseStatus, $filename {
    $Excludedbs = Get-DbcConfigValue command.invokedbccheck.excludedatabases
    $ExcludeReadOnly = Get-DbcConfigValue policy.database.status.excludereadonly
    $ExcludeOffline = Get-DbcConfigValue policy.database.status.excludeoffline
    $ExcludeRestoring = Get-DbcConfigValue policy.database.status.excluderestoring
    $Excludedbs += $ExcludedDatabases

    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Database status is correct on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Database status is correct on $psitem" {
                It "All Databases should have the expected status" {
                    Assert-DatabaseStatus -Instance $psitem -Excludedbs $Excludedbs -ExcludeReadOnly $ExcludeReadOnly -ExcludeOffline $ExcludeOffline -ExcludeRestoring $ExcludeRestoring
                }
            }
        }
    }
}

Describe "Database Exists" -Tags DatabaseExists, $filename {
    $Excludedbs = $ExcludedDatabases
    $expected = Get-DbcConfigValue database.exists
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Database exists on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false  |  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            $instance = $psitem
            Context "Database exists on $psitem" {
                $expected.Where{$psitem -notin $Excludedbs}.ForEach{
                    It "Database $psitem should exist" {
                        Assert-DatabaseExists -Instance $instance -Expecteddb $psitem 
                    }
                }
            }
        }
    }
}
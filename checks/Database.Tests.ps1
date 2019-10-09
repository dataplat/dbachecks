$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Database.Assertions.ps1 


[array]$ExcludedDatabases = Get-DbcConfigValue command.invokedbccheck.excludedatabases
$ExcludedDatabases += $ExcludeDatabase
[string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value

@(Get-Instance).ForEach{
    if ($NotContactable -notcontains $psitem) {
        $Instance = $psitem
        try {  
            $InstanceSMO = $connectioncheck = Connect-DbaInstance  -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
        }
        catch {
            $NotContactable += $Instance
        }
        if ($NotContactable -notcontains $psitem) {
            if ($null -eq $InstanceSMO.version) {
                $NotContactable += $Instance
            }
            else {
                $Version = $InstanceSMO.VersionMajor 
            }
        }
    }

    Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable 

    Describe "Database Collation" -Tags DatabaseCollation, High, $filename {
        $Wrongcollation = Get-DbcConfigValue policy.database.wrongcollation
        $exclude = "ReportingServer", "ReportingServerTempDB"
        $exclude += $Wrongcollation
        $exclude += $ExcludedDatabases
  
        if ($NotContactable -contains $psitem) {
            Context "Testing database collation on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database collation on $psitem" {
                @(Test-DbaDbCollation -SqlInstance $psitem -Database $Database -ExcludeDatabase $exclude).ForEach{
                    It "database collation ($($psitem.DatabaseCollation)) should match server collation ($($psitem.ServerCollation)) for $($psitem.Database) on $($psitem.SqlInstance)" {
                        $psitem.ServerCollation | Should -Be $psitem.DatabaseCollation -Because "You will get collation conflict errors in tempdb"
                    }
                }
                if ($Wrongcollation) {
                    @(Test-DbaDbCollation -SqlInstance $psitem -Database $Wrongcollation ).ForEach{
                        It "database collation ($($psitem.DatabaseCollation)) should not match server collation ($($psitem.ServerCollation)) for $($psitem.Database) on $($psitem.SqlInstance)" {
                            $psitem.ServerCollation | Should -Not -Be $psitem.DatabaseCollation -Because "You have defined the database to have another collation then the server. You will get collation conflict errors in tempdb"
                        }
                    }
                }
            }
        }
    }

    Describe "Suspect Page" -Tags SuspectPage, High, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing suspect pages on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing suspect pages on $psitem" {
                $InstanceSMO.Databases.Where{if ($Database) {$_.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name}}.ForEach{
                    $results = Get-DbaSuspectPage -SqlInstance $psitem.Parent -Database $psitem.Name
                    It "$($psitem.Name) should return 0 suspect pages on $($psitem.Parent.Name)" {
                        @($results).Count | Should -Be 0 -Because "You do not want suspect pages"
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
            if ($NotContactable -contains $psitem) {
                Context "Testing Backup Restore & Integrity Checks on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                if (-not $destserver) {
                    $destserver = $psitem
                }
                Context "Testing Backup Restore & Integrity Checks on $psitem" {
                    $srv = Connect-DbaInstance -SqlInstance $psitem
                    $dbs = ($srv.Databases.Where{$_.CreateDate.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddHours( - $graceperiod) -and $(if ($Database) {$_.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}).Name
                    if (-not ($destdata)) {$destdata -eq $srv.DefaultFile}
                    if (-not ($destlog)) {$destlog -eq $srv.DefaultLog}
                    @(Test-DbaLastBackup -SqlInstance $psitem -Database $dbs -Destination $destserver -DataDirectory $destdata -LogDirectory $destlog -VerifyOnly).ForEach{                    if ($psitem.DBCCResult -notmatch "skipped for restored master") {
                            It "DBCC for $($psitem.Database) on $($psitem.SourceServer) should be success" {
                                $psitem.DBCCResult | Should -Be "Success" -Because "You need to run DBCC CHECKDB to ensure your database is consistent"
                            }
                            It "restore for $($psitem.Database) on $($psitem.SourceServer) should be success" {
                                $psitem.RestoreResult | Should -Be "Success" -Because "The backup file has not successfully restored - you have no backup"
                            }
                        }
                    }
                }
            }
        }
    }

    Describe "Last Backup VerifyOnly" -Tags TestLastBackupVerifyOnly, Backup, $filename {
        $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
        if ($NotContactable -contains $psitem) {
            Context "VerifyOnly tests of last backups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "VerifyOnly tests of last backups on $psitem" {
                @(Test-DbaLastBackup -SqlInstance $psitem -Database ($InstanceSMO.Databases.Where{$_.CreateDate.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddHours( - $graceperiod) -and $(if ($Database) {$_.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}).Name -VerifyOnly).ForEach{
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
        
    Describe "Valid Database Owner" -Tags ValidDatabaseOwner, Medium, $filename {
        [string[]]$targetowner = Get-DbcConfigValue policy.validdbowner.name
        [string[]]$exclude = Get-DbcConfigValue policy.validdbowner.excludedb
        $exclude += $ExcludedDatabases 
        if ($NotContactable -contains $psitem) {
            Context "Testing Database Owners on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Database Owners on $psitem" {
                @($InstanceSMO.Databases.Where{if ($database) {$_.Name -in $database}else {$_.Name -notin $exclude}}).ForEach{
                    It "Database $($psitem.Name) - owner $($psitem.Owner) should be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.Parent.Name)" {
                        $psitem.Owner | Should -BeIn $TargetOwner -Because "The account that is the database owner is not what was expected"
                    }
                }
            }
        }
    }

    Describe "Invalid Database Owner" -Tags InvalidDatabaseOwner, Medium, $filename {
        [string[]]$targetowner = Get-DbcConfigValue policy.invaliddbowner.name
        [string[]]$exclude = Get-DbcConfigValue policy.invaliddbowner.excludedb
        $exclude += $ExcludedDatabases 
        if ($NotContactable -contains $psitem) {
            Context "Testing Database Owners on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Database Owners on $psitem" { 
                @($InstanceSMO.Databases.Where{if ($database) {$_.Name -in $database}else {$_.Name -notin $exclude}}).ForEach{
                    It "Database $($psitem.Name) - owner $($psitem.Owner) should Not be in this list ( $( [String]::Join(", ", $targetowner) ) ) on $($psitem.Parent.Name)" {
                        $psitem.Owner | Should -Not -BeIn $TargetOwner -Because "The database owner was one specified as incorrect"
                    }
                }
            }
        }
    }

    Describe "Last Good DBCC CHECKDB" -Tags LastGoodCheckDb, Varied, $filename {
        $maxdays = Get-DbcConfigValue policy.dbcc.maxdays
        $datapurity = Get-DbcConfigValue skip.dbcc.datapuritycheck
        $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
        if ($NotContactable -contains $psitem) {
            Context "Testing Last Good DBCC CHECKDB on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Last Good DBCC CHECKDB on $psitem" {
                @(Get-DbaLastGoodCheckDb -SqlInstance $psitem -Database ($InstanceSMO.Databases.Where{$_.CreateDate.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddHours( - $graceperiod) -and ($_.IsAccessible -eq $true) -and $(if ($database) {$psitem.name -in $Database}else {$ExcludedDatabases -notcontains $_.Name})}).Name ).ForEach{
                    if ($psitem.Database -ne "tempdb") {
                        It "last good integrity check for $($psitem.Database) on $($psitem.SqlInstance) should be less than $maxdays days old" {
                            if ($psitem.LastGoodCheckDb) {
                                $psitem.LastGoodCheckDb | Should -BeGreaterThan (Get-Date).ToUniversalTime().AddDays( - ($maxdays)) -Because "You should have run a DBCC CheckDB inside that time"
                            }
                            else{
                                $psitem.LastGoodCheckDb | Should -BeGreaterThan (Get-Date).ToUniversalTime().AddDays( - ($maxdays)) -Because "You should have run a DBCC CheckDB inside that time"
                            }
                        }
                        It -Skip:$datapurity "last good integrity check for $($psitem.Database) on $($psitem.SqlInstance) has Data Purity Enabled" {
                            $psitem.DataPurityEnabled | Should -BeTrue -Because "the DATA_PURITY option causes the CHECKDB command to look for column values that are invalid or out of range."
                        }
                    }
                }
            }
        }
    }

    Describe "Column Identity Usage" -Tags IdentityUsage, Medium, $filename {
        $maxpercentage = Get-DbcConfigValue policy.identity.usagepercent
        if ($NotContactable -contains $psitem) {
            Context "Testing Column Identity Usage on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Column Identity Usage on $psitem" {
                if ($version -lt 10) {
                    It "Databases on $Instance should return 0 duplicate indexes" -Skip {
                        Assert-DatabaseDuplicateIndex -Instance $instance -Database $psitem
                    }
                }
                else {
                    $exclude = $ExcludedDatabases
                    $exclude += $InstanceSMO.Databases.Where{$_.IsAccessible -eq $false}.Name
                    @(Test-DbaIdentityUsage -SqlInstance $psitem -Database $Database -ExcludeDatabase $exclude).ForEach{
                        if ($psitem.Database -ne "tempdb") {
                            $columnfqdn = "$($psitem.Database).$($psitem.Schema).$($psitem.Table).$($psitem.Column)"
                            It "usage for $columnfqdn on $($psitem.SqlInstance) should be less than $maxpercentage percent" {
                                $psitem.PercentUsed -lt $maxpercentage | Should -BeTrue -Because "You do not want your Identity columns to hit the max value and stop inserts"
                            }
                        }
                    }
                }
            }
        }
    }

    Describe "Recovery Model" -Tags RecoveryModel, DISA, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Recovery Model on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            $recoverymodel = Get-DbcConfigValue policy.recoverymodel.type
            Context "Testing Recovery Model on $psitem" {
                $exclude = Get-DbcConfigValue policy.recoverymodel.excludedb
                $exclude += $ExcludedDatabases 
                @(Get-DbaDbRecoveryModel -SqlInstance $psitem -Database $Database -ExcludeDatabase $exclude).ForEach{
                    It "$($psitem.Name) should be set to $recoverymodel on $($psitem.SqlInstance)" {
                        $psitem.RecoveryModel | Should -Be $recoverymodel -Because "You expect this recovery model"
                    }
                }
            }
        }
    }

    Describe "Duplicate Index" -Tags DuplicateIndex, $filename {
        $Excludeddbs = $ExcludedDatabases + 'msdb'
        if ($NotContactable -contains $psitem) {
            Context "Testing duplicate indexes on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing duplicate indexes on $psitem" {
                if ($version -lt 10) {
                    It "Databases on $Instance should return 0 duplicate indexes" -Skip {
                        Assert-DatabaseDuplicateIndex -Instance $instance -Database $psitem
                    }
                }
                else {
                    $instance = $Psitem
                    @(Get-Database -Instance $instance -Requiredinfo Name -Exclusions NotAccessible -Database $Database -ExcludedDbs $Excludeddbs).ForEach{
                        It "$psitem on $Instance should return 0 duplicate indexes" {
                            Assert-DatabaseDuplicateIndex -Instance $instance -Database $psitem
                        }
                    }
                }
            }
        }
    }

    Describe "Unused Index" -Tags UnusedIndex, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Unused indexes on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Unused indexes on $psitem" {
                try {
                    @($results = Find-DbaDbUnusedIndex -SqlInstance $psitem -Database $Database -ExcludeDatabase $ExcludedDatabases -EnableException).ForEach{
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

    Describe "Disabled Index" -Tags DisabledIndex, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Disabled indexes on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Disabled indexes on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name}) -and ($_.IsAccessible -eq $true)}.ForEach{
                    $results = Find-DbaDbDisabledIndex -SqlInstance $psitem.Parent -Database $psitem.Name
                    It "$($psitem.Name) on $($psitem.Parent.Name) should return 0 Disabled indexes" {
                        @($results).Count | Should -Be 0 -Because "Disabled indexes are wasting disk space"
                    }
                }
            }
        }
    }

    Describe "Database Growth Event" -Tags DatabaseGrowthEvent, Low, $filename {
        $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
        if ($NotContactable -contains $psitem) {
            Context "Testing database growth event on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database growth event on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$PSItem.Name -notin $exclude -and ($ExcludedDatabases -notcontains $PsItem.Name)})}.ForEach{
                    $results = Find-DbaDbGrowthEvent -SqlInstance $psitem.Parent -Database $psitem.Name
                    It "$($psitem.Name) should return 0 database growth events on $($psitem.Parent.Name)" {
                        @($results).Count | Should -Be 0 -Because "You want to control how your database files are grown"
                    }
                }
            }
        }
    }

    Describe "Page Verify" -Tags PageVerify, Medium, $filename {
        $pageverify = Get-DbcConfigValue policy.pageverify
        if ($NotContactable -contains $psitem) {
            Context "Testing page verify on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing page verify on $psitem" {
                switch ($version) {
                    8 {                         
                        It "Page verify is not available on SQL 2000" {
                            $true | Should -BeTrue
                        } 
                    }
                    9 {
                        $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                            if ($Psitem.Name -ne 'tempdb') {
                                It "$($psitem.Name) on $($psitem.Parent.Name) should have page verify set to $pageverify" {
                                    $psitem.PageVerify | Should -Be $pageverify -Because "Page verify helps SQL Server to detect corruption"
                                }
                            }
                            else {
                                It "Page verify is not available on tempdb on SQL 2005" {
                                    $true | Should -BeTrue
                                } 
                            }
                        }
                    }
                    Default {
                        $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                            It "$($psitem.Name) on $($psitem.Parent.Name) should have page verify set to $pageverify" {
                                $psitem.PageVerify | Should -Be $pageverify -Because "Page verify helps SQL Server to detect corruption"
                            }
                        }
                    }
                }
            }
        }
    }

    Describe "Auto Close" -Tags AutoClose, High, $filename {
        $autoclose = Get-DbcConfigValue policy.database.autoclose
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Close on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Close on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Close set to $autoclose" {
                        $psitem.AutoClose | Should -Be $autoclose -Because "Because!"
                    }
                }
            }
        }
    }

    Describe "Auto Shrink" -Tags AutoShrink, High, $filename {
        $autoshrink = Get-DbcConfigValue policy.database.autoshrink
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Shrink on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Shrink on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Shrink set to $autoshrink" {
                        $psitem.AutoShrink | Should -Be $autoshrink -Because "Shrinking databases causes fragmentation and performance issues"
                    }
                }
            }
        }
    }

    Describe "Last Full Backup Times" -Tags LastFullBackup, LastBackup, Backup, DISA, Varied, $filename {
        $maxfull = Get-DbcConfigValue policy.backup.fullmaxdays
        $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
        $skipreadonly = Get-DbcConfigValue skip.backup.readonly
        if ($NotContactable -contains $psitem) {
            Context "Testing last full backups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing last full backups on $psitem" {
                $InstanceSMO.Databases.Where{ ($psitem.Name -ne 'tempdb') -and $Psitem.CreateDate.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddHours( - $graceperiod) -and $(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                    $skip = ($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)
                    It -Skip:$skip "$($psitem.Name) full backups on $($psitem.Parent.Name) should be less than $maxfull days" {
                        $psitem.LastBackupDate.ToUniversalTime() | Should -BeGreaterThan (Get-Date).ToUniversalTime().AddDays( - ($maxfull)) -Because "Taking regular backups is extraordinarily important"
                    }
                }
            }
        }
    }

    Describe "Last Diff Backup Times" -Tags LastDiffBackup, LastBackup, Backup, DISA, Varied, $filename {
        if (-not (Get-DbcConfigValue skip.diffbackuptest)) {
            $maxdiff = Get-DbcConfigValue policy.backup.diffmaxhours
            $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
            $skipreadonly = Get-DbcConfigValue skip.backup.readonly
            if ($NotContactable -contains $psitem) {
                Context "Testing last diff backups on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Testing last diff backups on $psitem" {
                    @($InstanceSMO.Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddHours( - $graceperiod) -and $(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}).ForEach{
                        $skip = ($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)
                        It -Skip:$skip "$($psitem.Name) diff backups on $($psitem.Parent.Name) should be less than $maxdiff hours" {
                            $psitem.LastDifferentialBackupDate.ToUniversalTime() | Should -BeGreaterThan (Get-Date).ToUniversalTime().AddHours( - ($maxdiff)) -Because 'Taking regular backups is extraordinarily important'
                        }
                    }
                }
            }
        }
    }

    Describe "Last Log Backup Times" -Tags LastLogBackup, LastBackup, Backup, DISA, Varied, $filename {
        $maxlog = Get-DbcConfigValue policy.backup.logmaxminutes
        $graceperiod = Get-DbcConfigValue policy.backup.newdbgraceperiod
        $skipreadonly = Get-DbcConfigValue skip.backup.readonly
        if ($NotContactable -contains $psitem) {
            Context "Testing last log backups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing last log backups on $psitem" {
                @($InstanceSMO.Databases.Where{ (-not $psitem.IsSystemObject) -and $Psitem.CreateDate.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddHours( - $graceperiod) -and $(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}).ForEach{
                    if ($psitem.RecoveryModel -ne "Simple") {
                        $skip = ($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)
                        It -Skip:$skip  "$($psitem.Name) log backups on $($psitem.Parent.Name) should be less than $maxlog minutes" {
                            $psitem.LastLogBackupDate.ToUniversalTime() | Should -BeGreaterThan (Get-Date).ToUniversalTime().AddMinutes( - ($maxlog) + 1) -Because "Taking regular backups is extraordinarily important"
                        }
                    }
                }
            }
        }
    }

    Describe "Virtual Log Files" -Tags VirtualLogFile, Medium, $filename {
        $vlfmax = Get-DbcConfigValue policy.database.maxvlf
        if ($NotContactable -contains $psitem) {
            Context "Testing Database VLFs on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Database VLFs on $psitem" {
                @(Measure-DbaDbVirtualLogFile -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases -Database $Database).ForEach{
                    It "$($psitem.Database) VLF count on $($psitem.SqlInstance) should be less than $vlfmax" {
                        $psitem.Total | Should -BeLessThan $vlfmax -Because "Too many VLFs can impact performance and slow down backup/restore"
                    }
                }
            }
        }
    }

    Describe "Log File Count Checks" -Tags LogfileCount, Medium, $filename {
        $LogFileCountTest = Get-DbcConfigValue skip.database.logfilecounttest
        $LogFileCount = Get-DbcConfigValue policy.database.logfilecount
        If (-not $LogFileCountTest) {   
            if ($NotContactable -contains $psitem) {
                Context "Testing Log File count for $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Testing Log File count for $psitem" {
                    @($InstanceSMO.Databases.Where{if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name -and ($Psitem.IsAccessible -eq $true)}}).ForEach{
                        $Files = Get-DbaDbFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
                        $LogFiles = $Files | Where-Object {$_.TypeDescription -eq "LOG"}
                        It "$($psitem.Name) on $($psitem.Parent.Name) Should have $LogFileCount or less Log files" {
                            $LogFiles.Count | Should -BeLessOrEqual $LogFileCount -Because "You want the correct number of log files"
                        }
                    }
                }
            }
        }
    }

    Describe "Log File Size Checks" -Tags LogfileSize, Medium, $filename {
        $LogFileSizePercentage = Get-DbcConfigValue policy.database.logfilesizepercentage
        $LogFileSizeComparison = Get-DbcConfigValue policy.database.logfilesizecomparison
        if ($NotContactable -contains $psitem) {
            Context "Testing Log File size for $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Log File size for $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name}) -and ($Psitem.IsAccessible -eq $true)}.ForEach{
                    $Files = Get-DbaDbFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
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

    Describe "Future File Growth" -Tags FutureFileGrowth, Low, $filename {
        $threshold = Get-DbcConfigValue policy.database.filegrowthfreespacethreshold
        [string[]]$exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
        $exclude += $ExcludedDatabases 
        if ($NotContactable -contains $psitem) {
            Context "Testing for files likely to grow soon on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing for files likely to grow soon on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$PsItem.Name -notin $exclude})}.ForEach{
                    $Files = Get-DbaDbFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
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

    Describe "Correctly sized Filegroup members" -Tags FileGroupBalanced, Medium, $filename {
        $Tolerance = Get-DbcConfigValue policy.database.filebalancetolerance
        if ($NotContactable -contains $psitem) {
            Context "Testing for balanced FileGroups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing for balanced FileGroups on $psitem" {
                @(Connect-DbaInstance -SqlInstance $_).Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name -and ($Psitem.IsAccessible -eq $true)})}.ForEach{
                    $Files = Get-DbaDbFile -SqlInstance $psitem.Parent.Name -Database $psitem.Name
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

    Describe "Certificate Expiration" -Tags CertificateExpiration, High, $filename {
        $CertificateWarning = Get-DbcConfigValue policy.certificateexpiration.warningwindow
        [string[]]$exclude = Get-DbcConfigValue policy.certificateexpiration.excludedb
        $exclude += $ExcludedDatabases 
        if ($NotContactable -contains $psitem) {
            Context "Checking that encryption certificates have not expired on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that encryption certificates have not expired on $psitem" {
                @(Get-DbaDbEncryption -SqlInstance $psitem -IncludeSystemDBs -Database $Database | Where-Object {$_.Encryption -eq "Certificate" -and ($_.Database -notin $exclude)}).ForEach{
                    It "$($psitem.Name) in $($psitem.Database) has not expired on $($psitem.SqlInstance)" {
                        $psitem.ExpirationDate.ToUniversalTime()  | Should -BeGreaterThan (Get-Date).ToUniversalTime() -Because "this certificate should not be expired"
                    }
                    It "$($psitem.Name) in $($psitem.Database) does not expire for more than $CertificateWarning months on $($psitem.SqlInstance)" {
                        $psitem.ExpirationDate.ToUniversalTime()  | Should -BeGreaterThan (Get-Date).ToUniversalTime().AddMonths($CertificateWarning) -Because "expires inside the warning window of $CertificateWarning"
                    }
                }
            }
        }
    }

    Describe "Auto Create Statistics" -Tags AutoCreateStatistics, Low, $filename {
        $autocreatestatistics = Get-DbcConfigValue policy.database.autocreatestatistics
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Create Statistics on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Create Statistics on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Create Statistics set to $autocreatestatistics" {
                        $psitem.AutoCreateStatisticsEnabled | Should -Be $autocreatestatistics -Because "This value is expected for autocreate statistics"
                    }
                }
            }
        }
    }

    Describe "Auto Update Statistics" -Tags AutoUpdateStatistics, Low, $filename {
        $autoupdatestatistics = Get-DbcConfigValue policy.database.autoupdatestatistics
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Update Statistics on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Update Statistics on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Update Statistics set to $autoupdatestatistics" {
                        $psitem.AutoUpdateStatisticsEnabled | Should -Be $autoupdatestatistics  -Because "This value is expected for autoupdate statistics"
                    }
                }
            }
        }
    }

    Describe "Auto Update Statistics Asynchronously" -Tags AutoUpdateStatisticsAsynchronously, Low, $filename {
        $autoupdatestatisticsasynchronously = Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously
        if ($NotContactable -contains $psitem) {
            Context "Testing Auto Update Statistics Asynchronously on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Auto Update Statistics Asynchronously on $psitem" {
                $InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}.ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Auto Update Statistics Asynchronously set to $autoupdatestatisticsasynchronously" {
                        $psitem.AutoUpdateStatisticsAsync | Should -Be $autoupdatestatisticsasynchronously  -Because "This value is expected for autoupdate statistics asynchronously"
                    }
                }
            }
        }
    }

    Describe "Datafile Auto Growth Configuration" -Tags DatafileAutoGrowthType, Low, $filename {
        $datafilegrowthtype = Get-DbcConfigValue policy.database.filegrowthtype
        $datafilegrowthvalue = Get-DbcConfigValue policy.database.filegrowthvalue
        $exclude = Get-DbcConfigValue policy.database.filegrowthexcludedb
        $exclude += $ExcludedDatabases 
        if ($NotContactable -contains $psitem) {
            Context "Testing datafile growth type on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing datafile growth type on $psitem" {
                @(Get-DbaDbFile -SqlInstance $psitem -Database $Database -ExcludeDatabase $exclude ).ForEach{
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

    Describe "Trustworthy Option" -Tags Trustworthy, DISA, Varied, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing database trustworthy option on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database trustworthy option on $psitem" {
                @($InstanceSMO.Databases.Where{$psitem.Name -ne 'msdb' -and ($(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name}))}).ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should have Trustworthy set to false" {
                        $psitem.Trustworthy | Should -BeFalse -Because "Trustworthy has security implications and may expose your SQL Server to additional risk"
                    }
                }
            }
        }
    }

    Describe "Database Orphaned User" -Tags OrphanedUser, CIS, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing database orphaned user event on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database orphaned user event on $psitem" {
                $instance = $psitem
                @($InstanceSMO.Databases.Where{($(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name}))}).ForEach{
                    It "$($psitem.Name) on $($psitem.Parent.Name) should return 0 orphaned users" {
                        @(Get-DbaDbOrphanUser -SqlInstance $instance -ExcludeDatabase $ExcludedDatabases -Database $psitem.Name).Count | Should -Be 0 -Because "We dont want orphaned users"
                    }
                }
            }
        }
    }

    Describe "PseudoSimple Recovery Model" -Tags PseudoSimple, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing database is not in PseudoSimple recovery model on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database is not in PseudoSimple recovery model on $psitem" {
                @($InstanceSMO.Databases.Where{$psitem.Name -ne 'tempdb' -and $psitem.Name -ne 'model' -and $psitem.Status -ne 'Offline' -and ($(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name}))}).ForEach{
                    if (-not($psitem.RecoveryModel -eq "Simple")) {
                        It "$($psitem.Name) has PseudoSimple recovery model equal false on $($psitem.Parent.Name)" { (Test-DbaDbRecoveryModel -SqlInstance $psitem.Parent -Database $psitem.Name).ActualRecoveryModel -eq "SIMPLE" | Should -BeFalse -Because "PseudoSimple means that a FULL backup has not been taken and the database is still effectively in SIMPLE mode" } 
                    }
                }
            }
        }
    }

    Describe "Compatibility Level" -Tags CompatibilityLevel, High, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing database compatibility level matches server compatibility level on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing database compatibility level matches server compatibility level on $psitem" {
                @(Test-DbaDbCompatibility -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases -Database $Database).ForEach{
                    It "$($psitem.Database) has a database compatibility level equal to the level of $($psitem.SqlInstance)" {
                        $psItem.DatabaseCompatibility | Should -Be $psItem.ServerLevel -Because "it means you are on the appropriate compatibility level for your SQL Server version to use all available features"
                    }
                }
            }
        }
    }

    Describe "Foreign keys and check constraints not trusted" -Tags FKCKTrusted, Low, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Foreign Keys and Check Constraints are not trusted $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Foreign Keys and Check Constraints are not trusted $psitem" {
                @(Get-DbaDbForeignKey -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases -Database $Database).Where{$_.NotForReplication -eq $false}.ForEach{
                    It "$($psitem.Name) foreign key on table $($psitem.Parent) within database $($psitem.Database) should be trusted on $($psitem.SqlInstance)." {
                        $psitem.IsChecked | Should -Be $true -Because "This can have a huge performance impact on queries. SQL Server won't use untrusted constraints to build better execution plans. It will also avoid data violation"
                    }
                }

                @(Get-DbaDbCheckConstraint -SqlInstance $psitem -ExcludeDatabase $ExcludedDatabases -Database $Database).Where{$_.NotForReplication -eq $false -and $_.IsEnabled -eq $true}.ForEach{
                    It "$($psitem.Name) check constraint on table $($psitem.Parent) within database $($psitem.Database) should be trusted on $($psitem.SqlInstance)." {
                        $psitem.IsChecked | Should -Be $true -Because "This can have a huge performance impact on queries. SQL Server won't use untrusted constraints to build better execution plans. It will also avoid data violation"
                    }
                }
            }
        }
    }

    Describe "Database MaxDop" -Tags MaxDopDatabase, MaxDop, Low, $filename {
        $MaxDopValue = Get-DbcConfigValue policy.database.maxdop
        [string[]]$exclude = Get-DbcConfigValue policy.database.maxdopexcludedb
        $exclude += $ExcludedDatabases 
        if ($exclude) {Write-Warning "Excluded $exclude from testing"}
        if ($NotContactable -contains $psitem) {
            Context "Database MaxDop setting is correct on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Database MaxDop setting is correct on $psitem" {
                @(Test-DbaMaxDop -SqlInstance $psitem).Where{$_.Database -ne 'N/A' -and $(if ($database) {$PsItem.Database -in $Database} else {$_.Database -notin $exclude})}.ForEach{
                    It "Database $($psitem.Database) should have the correct MaxDop setting on $($psitem.SqlInstance)" {
                        Assert-DatabaseMaxDop -MaxDop $PsItem -MaxDopValue $MaxDopValue
                    }
                }
            }
        }
    }

    Describe "Database Status" -Tags DatabaseStatus, High, $filename {
        $ExcludeReadOnly = Get-DbcConfigValue policy.database.status.excludereadonly
        $ExcludeOffline = Get-DbcConfigValue policy.database.status.excludeoffline
        $ExcludeRestoring = Get-DbcConfigValue policy.database.status.excluderestoring
  
        if ($NotContactable -contains $psitem) {
            Context "Database status is correct on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Database status is correct on $psitem" {
                $instance = $psitem
                @($InstanceSMO.Databases.Where{$(if ($Database) {$PsItem.Name -in $Database}else {$ExcludedDatabases -notcontains $PsItem.Name})}).Foreach{
                    It "Database $($psitem.Name) on $instance has the expected status" {
                        Assert-DatabaseStatus -Instance $instance -Database $($psitem.Name) -ExcludeReadOnly $ExcludeReadOnly -ExcludeOffline $ExcludeOffline -ExcludeRestoring $ExcludeRestoring
                    }
                }
            }
        }
    }

    Describe "Database Exists" -Tags DatabaseExists, $filename {
        $Excludedbs = $ExcludedDatabases
        $expected = Get-DbcConfigValue database.exists
        if ($Database) {$expected += $Database}
        $expected = $expected.where{$psitem -notin $ExcludeDatabase}
        if ($NotContactable -contains $psitem) {
            Context "Database exists on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true  |  Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            $instance = $psitem
            Context "Database exists on $psitem" {
                $expected.ForEach{
                    It "Database $psitem should exist on $($psitem.Parent.Name)" {
                        Assert-DatabaseExists -Instance $instance -Expecteddb $psitem
                    }
                }
            }
        }
    }
}
Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable




# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYL41IQtYnBAL7QMDnUlg0UAW
# 3aygggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSUPoy0dA4hnawLjAcMS4/2Sh/4
# oDANBgkqhkiG9w0BAQEFAASCAQCA6gxCfTdPJ25u1bu5XPerpd97EBVkeQA4nChs
# D6iGorbN0FotZQGXCgsVVQCEef91mcyy4n3ML5yuB4BOkG9G58UneUpQHngeNieJ
# yXp/ggMOOj0jg0kq2u2qCIch3n2j8/DJxM3jLO51NmbjUWeI6P1AKmn0v25wzLd3
# 7JIEtu53sAMRrPzhzhPXO2vhnpBWQe19cHA6gc+CUwC7+WYYO6mhdxr1DLtVAhj+
# mi5tePIlS3h37YsXfIAcBcloqG7wWnB6Om2lt/QomorzXCJvYEoLeUcEuyWdVSgg
# aO/j4MvNTi1WRDPFqfal6z6IXnehNFuRX1wZgbPBVd83dvTk
# SIG # End signature block

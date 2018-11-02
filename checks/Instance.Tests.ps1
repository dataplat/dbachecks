$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Instance.assertions.ps1

[string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value

@(Get-Instance).ForEach{
    if ($NotContactable -notcontains $psitem) {
        $Instance = $psitem
        try {
            $connectioncheck = Connect-DbaInstance	-SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
        }
        catch {
            $NotContactable += $Instance
        }
        if ($NotContactable -notcontains $psitem) {
            if ($null -eq $connectioncheck.version) {
                $NotContactable += $Instance
            }
            else {

            }
        }
    }

    Describe "Instance Connection" -Tags InstanceConnection, Connectivity, $filename {
        $skipremote = Get-DbcConfigValue skip.connection.remoting
        $skipping = Get-DbcConfigValue skip.connection.ping
        $authscheme = Get-DbcConfigValue policy.connection.authscheme
        if ($NotContactable -contains $psitem) {
            Context "Testing Instance Connection on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Instance Connection on $psitem" {
                $connection = Test-DbaConnection -SqlInstance $psitem
                It "connects successfully to $psitem" {
                    $connection.connectsuccess | Should -BeTrue
                }
                It "auth scheme Should Be $authscheme on $psitem" {
                    $connection.AuthScheme | Should -Be $authscheme
                }
                It -Skip:$skipping "$psitem is pingable" {
                    $connection.IsPingable | Should -BeTrue
                }
                It -Skip:$skipremote "$psitem Is PSRemoteable" {
                    $Connection.PSRemotingAccessible | Should -BeTrue
                }
            }
        }
    }
    
    Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing database collation on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            $IsClustered = $Psitem.$IsClustered
            Context "Testing SQL Engine Service on $psitem" {
                @(Get-DbaService -ComputerName $psitem -Type Engine -ErrorAction SilentlyContinue).ForEach{
                    It "SQL Engine service account should Be running on $($psitem.InstanceName)" {
                        $psitem.State | Should -Be "Running" -Because 'If the service is not running, the SQL Server will not be accessible'
                    }
                    if ($IsClustered) {
                        It "SQL Engine service account should have a start mode of Manual on FailOver Clustered Instance $($psitem.InstanceName)" {
                            $psitem.StartMode | Should -Be "Manual" -Because 'Clustered Instances required that the SQL engine service is set to manual'
                        }
                    }
                    else {
                        It "SQL Engine service account should have a start mode of Automatic on standalone instance $($psitem.InstanceName)" {
                            $psitem.StartMode | Should -Be "Automatic" -Because 'If the server restarts, the SQL Server will not be accessible'
                        }
                    }
                }
            }
        }
    }

    Describe "TempDB Configuration" -Tags TempDbConfiguration, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing TempDB Configuration on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing TempDB Configuration on $psitem" {
                $TempDBTest = Test-DbaTempdbConfig -SqlServer $psitem
                It "should have TF1118 enabled on $($TempDBTest[0].SqlInstance)" -Skip:(Get-DbcConfigValue skip.TempDb1118) {
                    $TempDBTest[0].CurrentSetting | Should -Be $TempDBTest[0].Recommended -Because 'TF 1118 should be enabled'
                }
                It "should have $($TempDBTest[1].Recommended) TempDB Files on $($TempDBTest[1].SqlInstance)" -Skip:(Get-DbcConfigValue skip.tempdbfileCount) {
                    $TempDBTest[1].CurrentSetting | Should -Be $TempDBTest[1].Recommended -Because 'This is the recommended number of tempdb files for your server'
                }
                It "should not have TempDB Files autogrowth set to percent on $($TempDBTest[2].SqlInstance)" -Skip:(Get-DbcConfigValue skip.TempDbFileGrowthPercent) {
                    $TempDBTest[2].CurrentSetting | Should -Be $TempDBTest[2].Recommended -Because 'Auto growth type should not be percent'
                }
                It "should not have TempDB Files on the C Drive on $($TempDBTest[3].SqlInstance)" -Skip:(Get-DbcConfigValue skip.TempDbFilesonC) {
                    $TempDBTest[3].CurrentSetting | Should -Be $TempDBTest[3].Recommended -Because 'You do not want the tempdb files on the same drive as the operating system'
                }
                It "should not have TempDB Files with MaxSize Set on $($TempDBTest[4].SqlInstance)" -Skip:(Get-DbcConfigValue skip.TempDbFileSizeMax) {
                    $TempDBTest[4].CurrentSetting | Should -Be $TempDBTest[4].Recommended -Because 'Tempdb files should be able to grow'
                }
                It "The data files should all be the same size on $($TempDBTest[0].SqlInstance)" {
                    Assert-TempDBSize -Instance $Psitem
                }
            }
        }
    }

    Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Ad Hoc Workload Optimization on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Ad Hoc Workload Optimization on $psitem" {
                It "$psitem Should be Optimize for Ad Hoc workloads" -Skip:((Get-Version -SQLInstance $psitem) -lt 10) {
                    @(Test-DbaOptimizeForAdHoc -SqlInstance $psitem).ForEach{
                        $psitem.CurrentOptimizeAdHoc | Should -Be $psitem.RecommendedOptimizeAdHoc -Because "optimize for ad hoc workloads is a recommended setting"
                    }
                }
            }
        }
    }

    Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Backup Path Access on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Backup Path Access on $psitem" {
                $backuppath = Get-DbcConfigValue policy.storage.backuppath
                if (-not $backuppath) {
                    $backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
                }
                It "can access backup path ($backuppath) on $psitem" {
                    Test-DbaPath -SqlInstance $psitem -Path $backuppath | Should -BeTrue -Because 'The SQL Service account needs to have access to the backup path to backup your databases'
                }
            }
        }
    }

    Describe "Dedicated Administrator Connection" -Tags DAC, $filename {
        $dac = Get-DbcConfigValue policy.dacallowed
        if ($NotContactable -contains $psitem) {
            Context "Testing Dedicated Administrator Connection on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Dedicated Administrator Connection on $psitem" {
                It "DAC is set to $dac on $psitem" {
                    (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should -Be $dac -Because 'This is the setting that you have chosen for DAC connections'
                }
            }
        }
    }

    Describe "Network Latency" -Tags NetworkLatency, Connectivity, $filename {
        $max = Get-DbcConfigValue policy.network.latencymaxms
        if ($NotContactable -contains $psitem) {
            Context "Testing Network Latency on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Network Latency on $psitem" {
                @(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
                    It "network latency Should Be less than $max ms on $($psitem.SqlInstance)" {
                        $psitem.Average.TotalMilliseconds | Should -BeLessThan $max -Because 'You do not want to be waiting on the network'
                    }
                }
            }
        }
    }

    Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Linked Servers on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Linked Servers on $psitem" {
                @(Test-DbaLinkedServerConnection -SqlInstance $psitem).ForEach{
                    It "Linked Server $($psitem.LinkedServerName) on on $($psitem.SqlInstance) has connectivity" {
                        $psitem.Connectivity | Should -BeTrue -Because 'You need to be able to connect to your linked servers'
                    }
                }
            }
        }
    }

    Describe "Max Memory" -Tags MaxMemory, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Max Memory on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Max Memory on $psitem" {
                It "Max Memory setting Should Be correct on $psitem" {
                    @(Test-DbaMaxMemory -SqlInstance $psitem).ForEach{
                        $psitem.SqlMaxMB | Should -BeLessThan ($psitem.RecommendedMB + 379) -Because 'You do not want to exhaust server memory'
                    }
                }
            }
        }
    }

    Describe "Orphaned Files" -Tags OrphanedFile, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking for orphaned database files on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking for orphaned database files on $psitem" {
                It "$psitem doesn't have orphan files" {
                    (Find-DbaOrphanedFile -SqlInstance $psitem).Count | Should -Be 0 -Because 'You dont want any orphaned files - Use Find-DbaOrphanedFile to locate them'
                }
            }
        }
    }

    Describe "SQL and Windows names match" -Tags ServerNameMatch, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing instance name matches Windows name for $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing instance name matches Windows name for $psitem" {
                It "$psitem doesn't require rename" {
                    (Test-DbaServerName -SqlInstance $psitem).RenameRequired | Should -BeFalse -Because 'SQL and Windows should agree on the server name'
                }
            }
        }
    }

    Describe "SQL Memory Dumps" -Tags MemoryDump, $filename {
        $maxdumps = Get-DbcConfigValue	policy.dump.maxcount
        if ($NotContactable -contains $psitem) {
            Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
                $count = (Get-DbaDump -SqlInstance $psitem).Count
                It "dump count of $count is less than or equal to the $maxdumps dumps on $psitem" {
                    $Count | Should -BeLessOrEqual $maxdumps -Because 'Memory dumps often suggest issues with the SQL Server instance'
                }
            }
        }
    }

    Describe "Supported Build" -Tags SupportedBuild, DISA, $filename {
        $BuildWarning = Get-DbcConfigValue policy.build.warningwindow
        $BuildBehind = Get-DbcConfigValue policy.build.behind
        $Date = Get-Date 


        if ($NotContactable -contains $psitem) {
            Context "Checking that build is still supportedby Microsoft for $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that build is still supportedby Microsoft for $psitem" {
                if ($BuildBehind) {
                    It "$psitem is not behind the latest build by more than $BuildBehind" {
                        Assert-InstanceSupportedBuild -Instance $psitem -BuildBehind $BuildBehind -Date $Date
                    }
                }
                It "$Instance's build is supported by Microsoft" {
                    Assert-InstanceSupportedBuild -Instance $psitem -Date $Date
                }
                It "$Instance's build is supported by Microsoft within the warning window of $BuildWarning months" {
                    Assert-InstanceSupportedBuild -Instance $psitem -BuildWarning $BuildWarning -Date $Date
                }


            }
        }
    }

    Describe "SA Login Renamed" -Tags SaRenamed, DISA, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking that sa login has been renamed on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that sa login has been renamed on $psitem" {
                $results = Get-DbaErrorLogin -SqlInstance $psitem -Login sa
                It "sa login does not exist on $psitem" {
                    $results | Should -Be $null -Because 'Renaming the sa account is a requirement'
                }
            }
        }
    }

    Describe "Default Backup Compression" -Tags DefaultBackupCompression, $filename {
        $defaultbackupcompression = Get-DbcConfigValue policy.backup.defaultbackupcompression
        if ($NotContactable -contains $psitem) {
            Context "Testing Default Backup Compression on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Default Backup Compression on $psitem" {
                It "Default Backup Compression is set to $defaultbackupcompression on $psitem" -Skip:((Get-Version -SQLInstance $psitem) -lt 10) {
                    Assert-BackupCompression -Instance $psitem -defaultbackupcompression $defaultbackupcompression
                }
            }
        }
    }

    Describe "XE Sessions That Should Be Stopped" -Tags XESessionStopped, ExtendedEvent, $filename {
        $xesession = Get-DbcConfigValue policy.xevent.requiredstoppedsession
        # no point running if we dont have something to check
        if ($xesession) {
            if ($NotContactable -contains $psitem) {
                Context "Checking sessions on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Checking sessions on $psitem" {
                    $runningsessions = (Get-DbaXESession -SqlInstance $psitem).Where{$_.Status -eq 'Running'}.Name
                    @($xesession).ForEach{
                        It "Session $psitem should not be running on $Instance" {
                            $psitem | Should -Not -BeIn $runningsessions -Because "$psitem session should be stopped"
                        }
                    }
                }
            }
        }
        else {
            Write-Warning "You need to use Set-DbcConfig -Name policy.xevent.requiredstoppedsession -Value to add some Extended Events session names to run this check"
        }
    }

    Describe "XE Sessions That Should Be Running" -Tags XESessionRunning, ExtendedEvent, $filename {
        $xesession = Get-DbcConfigValue policy.xevent.requiredrunningsession
        # no point running if we dont have something to check
        if ($xesession) {
            if ($NotContactable -contains $psitem) {
                Context "Checking running sessions on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Checking running sessions on $psitem" {
                    $runningsessions = (Get-DbaXESession -SqlInstance $psitem).Where{$_.Status -eq 'Running'}.Name
                    @($xesession).ForEach{
                        It "session $psitem Should Be running on $Instance" {
                            $psitem | Should -BeIn $runningsessions -Because "$psitem session should be running"
                        }
                    }
                }
            }
        }
        else {
            Write-Warning "You need to use Set-DbcConfig -Name policy.xevent.requiredrunningsession -Value to add some Extended Events session names to run this check"
        }
    }

    Describe "XE Sessions That Are Allowed to Be Running" -Tags XESessionRunningAllowed, ExtendedEvent, $filename {
        $xesession = Get-DbcConfigValue policy.xevent.validrunningsession
        # no point running if we dont have something to check
        if ($xesession) {
            if ($NotContactable -contains $psitem) {
                Context "Checking sessions on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Checking sessions on $psitem" {
                    @(Get-DbaXESession -SqlInstance $psitem).Where{$_.Status -eq 'Running'}.ForEach{
                        It "Session $($Psitem.Name) is allowed to be running on $Instance" {
                            $psitem.name | Should -BeIn $xesession -Because "Only these sessions are allowed to be running"
                        }
                    }
                }
            }
        }
        else {
            Write-Warning "You need to use Set-DbcConfig -Name policy.xevent.validrunningsession -Value to add some Extended Events session names to run this check"
        }
    }
    Describe "OLE Automation" -Tags OLEAutomation, security, $filename {
        $OLEAutomation = Get-DbcConfigValue policy.oleautomation
        if ($NotContactable -contains $psitem) {
            Context "Testing OLE Automation on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing OLE Automation on $psitem" {
                It "OLE Automation is set to $OLEAutomation on $psitem" {
                    (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'OleAutomationProceduresEnabled').ConfiguredValue -eq 1 | Should -Be $OLEAutomation -Because 'OLE Automation can introduce additional security risks'
                }
            }
        }
    }

    Describe "sp_whoisactive is Installed" -Tags WhoIsActiveInstalled, $filename {
        $db = Get-DbcConfigValue policy.whoisactive.database
        if ($NotContactable -contains $psitem) {
            Context "Testing WhoIsActive exists on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing WhoIsActive exists on $psitem" {
                It "WhoIsActive should exists on $db on $psitem" {
                    (Get-DbaModule -SqlInstance $psitem -Database $db -Type StoredProcedure | Where-Object name -eq "sp_WhoIsActive") | Should -Not -Be $Null -Because 'The sp_WhoIsActive stored procedure should be installed'
                }
            }
        }
    }

    Describe "Model Database Growth" -Tags ModelDbGrowth, $filename {
        $modeldbgrowthtest = Get-DbcConfigValue skip.instance.modeldbgrowth
        if (-not $modeldbgrowthtest) {
            if ($NotContactable -contains $psitem) {
                Context "Testing model database growth setting is not default on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Testing model database growth setting is not default on $psitem" {
                    @(Get-DbaDbFile -SqlInstance $psitem -Database Model).ForEach{
                        It "Model database growth settings should not be percent for file $($psitem.LogicalName) on $($psitem.SqlInstance)" {
                            $psitem.GrowthType | Should -Not -Be 'Percent' -Because 'New databases use the model database as a template and percent growth can cause performance problems'
                        }
                        It "Model database growth settings should not be 1Mb for file $($psitem.LogicalName) on $($psitem.SqlInstance)" {
                            $psitem.Growth | Should -Not -Be 1024 -Because 'New databases use the model database as a template and growing for each Mb will have a performance impact'
                        }
                    }
                }
            }
        }
    }

    Describe "Ad Users and Groups " -Tags ADUser, Domain, $filename {
        $userexclude = Get-DbcConfigValue policy.adloginuser.excludecheck
        $groupexclude = Get-DbcConfigValue policy.adlogingroup.excludecheck

        if ($NotContactable -contains $psitem) {
            Context "Testing active Directory users on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
            Context "Testing active Directory groups on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing active Directory users on $psitem" {
                @(Test-DbaWindowsLogin -SqlInstance $psitem -FilterBy LoginsOnly -ExcludeLogin $userexclude).ForEach{
                    It "Active Directory user $($psitem.login) was found in $Instance on $($psitem.domain)" {
                        $psitem.found | Should -Be $true -Because "$($psitem.login) should be in Active Directory"
                    }
                    if ($psitem.found -eq $true) {
                        It "Active Directory user $($psitem.login) should not have an expired password in $Instance on $($psitem.domain)" {
                            $psitem.PasswordExpired | Should -Be $false -Because "$($psitem.login) password should not be expired"
                        }
                        It "Active Directory user $($psitem.login) should not be locked out in $Instance on $($psitem.domain)" {
                            $psitem.lockedout | Should -Be $false -Because "$($psitem.login) should not be locked out"
                        }
                        It "Active Directory user $($psitem.login) should be enabled in $Instance on $($psitem.domain)" {
                            $psitem.Enabled | Should -Be $true -Because "$($psitem.login) should be enabled"
                        }
                        It "Active Directory user $($psitem.login) should not be disabled in $Instance on $($psitem.Server)" {
                            $psitem.DisabledInSQLServer | Should -Be $false -Because "$($psitem.login) should be active on the SQL server"
                        }
                    }

                }
            }

            Context "Testing active Directory groups on $psitem" {
                @(Test-DbaWindowsLogin -SqlInstance $psitem -FilterBy GroupsOnly -ExcludeLogin $groupexclude).ForEach{
                    It "Active Directory group $($psitem.login) was found in $Instance on $($psitem.domain)" {
                        $psitem.found | Should -Be $true -Because "$($psitem.login) should be in Active Directory"
                    }
                    if ($psitem.found -eq $true) {
                        It "Active Directory group $($psitem.login) should not be disabled in $Instance on $($psitem.Server)" {
                            $psitem.DisabledInSQLServer | Should -Be $false -Because "$($psitem.login) should be active on the SQL server"
                        }
                    }

                }
            }
        }
    }

    Describe "Error Log Entries" -Tags ErrorLog, $filename {
        $logWindow = Get-DbcConfigValue policy.errorlog.warningwindow
        if ($NotContactable -contains $psitem) {
            Context "Checking error log on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking error log on $psitem" {
                It "Error log should be free of error severities 17-24 on $psitem" {
                    Get-DbaErrorLog -SqlInstance $psitem -After (Get-Date).AddDays( - $logWindow) -Text "Severity: 1[7-9]" | Should -BeNullOrEmpty -Because "these severities indicate serious problems"
                    Get-DbaErrorLog -SqlInstance $psitem -After (Get-Date).AddDays( - $logWindow) -Text "Severity: 2[0-4]" | Should -BeNullOrEmpty -Because "these severities indicate serious problems"
                }
            }
        }
    }

    Describe "Instance MaxDop" -Tags MaxDopInstance, MaxDop, $filename {
        $UseRecommended = Get-DbcConfigValue policy.instancemaxdop.userecommended
        $MaxDop = Get-DbcConfigValue policy.instancemaxdop.maxdop
        $ExcludeInstance = Get-DbcConfigValue policy.instancemaxdop.excludeinstance

        if ($NotContactable -contains $psitem) {
            Context "Testing Instance MaxDop Value on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            if ($psitem -in $ExcludeInstance) {$Skip = $true}else {$skip = $false}
            Context "Testing Instance MaxDop Value on $psitem" {
                It "Instance Level MaxDop setting should be correct on $psitem" -Skip:$Skip {
                    Assert-InstanceMaxDop -Instance $psitem -UseRecommended:$UseRecommended -MaxDopValue $MaxDop
                }
            }
        }
    }

    Describe "Two Digit Year Cutoff" -Tags TwoDigitYearCutoff, $filename {
        $twodigityearcutoff = Get-DbcConfigValue policy.twodigityearcutoff
        if ($NotContactable -contains $psitem) {
            Context "Testing Two Digit Year Cutoff on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Two Digit Year Cutoff on $psitem" {
                It "Two Digit Year Cutoff is set to $twodigityearcutoff on $psitem" {
                    Assert-TwoDigitYearCutoff -Instance $psitem -TwoDigitYearCutoff $twodigityearcutoff
                }
            }
        }
    }

    Describe "Trace Flags Expected" -Tags TraceFlagsExpected, TraceFlag, $filename {
        $ExpectedTraceFlags = Get-DbcConfigValue policy.traceflags.expected
        if ($NotContactable -contains $psitem) {
            Context "Testing Expected Trace Flags on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Expected Trace Flags on $psitem" {
                It "Expected Trace Flags $ExpectedTraceFlags exist on $psitem" {
                    Assert-TraceFlag -SQLInstance $psitem -ExpectedTraceFlag $ExpectedTraceFlags
                }
            }
        }
    }
    Describe "Trace Flags Not Expected" -Tags TraceFlagsNotExpected, TraceFlag, $filename {
        $NotExpectedTraceFlags = Get-DbcConfigValue policy.traceflags.notexpected
        if ($NotContactable -contains $psitem) {
            Context "Testing Not Expected Trace Flags on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Not Expected Trace Flags on $psitem" {
                It "Expected Trace Flags $NotExpectedTraceFlags to not exist on $psitem" {
                    Assert-NotTraceFlag -SQLInstance $psitem -NotExpectedTraceFlag $NotExpectedTraceFlags
                }
            }
        }
    }

    Describe "CLR Enabled" -Tags CLREnabled, security, $filename {
        $CLREnabled = Get-DbcConfigValue policy.security.clrenabled
        if ($NotContactable -contains $psitem) {
            Context "Testing CLR Enabled on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing CLR Enabled on $psitem" {
                It "CLR Enabled is set to $CLREnabled on $psitem" {
                    Assert-CLREnabled -SQLInstance $psitem -CLREnabled $CLREnabled 
                }
            }
        }
    }

    Describe "Cross Database Ownership Chaining" -Tags CrossDBOwnershipChaining, security, $filename {
        $CrossDBOwnershipChaining = Get-DbcConfigValue policy.security.crossdbownershipchaining
        if ($NotContactable -contains $psitem) {
            Context "Testing Cross Database Ownership Chaining on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Cross Database Ownership Chaining on $psitem" {
                It "Cross Database Ownership Chaining is set to $CrossDBOwnershipChaining on $psitem" {
                    Assert-CrossDBOwnershipChaining -SQLInstance $Psitem -CrossDBOwnershipChaining $CrossDBOwnershipChaining 
                }
            }
        }
    }
    Describe "Ad Hoc Distributed Queries" -Tags AdHocDistributedQueriesEnabled, security, $filename {
        $AdHocDistributedQueriesEnabled = Get-DbcConfigValue policy.security.AdHocDistributedQueriesEnabled
        if ($NotContactable -contains $psitem) {
            Context "Testing Ad Hoc Distributed Queries on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Ad Hoc Distributed Queries on $psitem" {
                It "Ad Hoc Distributed Queries is set to $AdHocDistributedQueriesEnabled on $psitem" {
                    Assert-AdHocDistributedQueriesEnabled -SQLInstance $Psitem -AdHocDistributedQueriesEnabled $AdHocDistributedQueriesEnabled 
                }
            }
        }
    }
    Describe "XP CmdShell" -Tags XpCmdShellDisabled, security, $filename {
        $XpCmdShellDisabled = Get-DbcConfigValue policy.security.XpCmdShellDisabled
        if ($NotContactable -contains $psitem) {
            Context "Testing XP CmdShell on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing XP CmdShell on $psitem" {
                It "XPCmdShell is set to $XpCmdShellDisabled on $psitem" {
                    Assert-XpCmdShellDisabled -SQLInstance $Psitem -XpCmdShellDisabled $XpCmdShellDisabled 
                }
            }
        }
    }

}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename {
    @(Get-ComputerName).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing SQL Browser Service on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing SQL Browser Service on $psitem" {
                $Services = Get-DbaService -ComputerName $psitem
                if ($Services.Where{$_.ServiceType -eq 'Engine'}.Count -eq 1) {
                    It "SQL browser service on $psitem Should Be Stopped as only one instance is installed" {
                        $Services.Where{$_.ServiceType -eq 'Browser'}.State | Should -Be "Stopped" -Because 'Unless there are multple instances you dont need the browser service'
                    }
                }
                else {
                    It "SQL browser service on $psitem Should Be Running as multiple instances are installed" {
                        $Services.Where{$_.ServiceType -eq 'Browser'}.State| Should -Be "Running" -Because 'You need the browser service with multiple instances' }
                }
                if ($Services.Where{$_.ServiceType -eq 'Engine'}.Count -eq 1) {
                    It "SQL browser service startmode Should Be Disabled on $psitem as only one instance is installed" {
                        $Services.Where{$_.ServiceType -eq 'Browser'}.StartMode | Should -Be "Disabled" -Because 'Unless there are multple instances you dont need the browser service' }
                }
                else {
                    It "SQL browser service startmode Should Be Automatic on $psitem as multiple instances are installed" {
                        $Services.Where{$_.ServiceType -eq 'Browser'}.StartMode | Should -Be "Automatic"
                    }
                }
            }
        }
    }
}


Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable






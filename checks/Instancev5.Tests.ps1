$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Instance.Assertions.ps1

# Check out the comments at the top of Instance.Assertions for guidance on adding checks

# Gather the instances we know are not contactable
[string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value

# Get all the tags in use in this run
$Tags = Get-CheckInformation -Check $Check -Group Instance -AllChecks $AllChecks -ExcludeCheck $ChecksToExclude

@(Get-Instance).ForEach{
    # Try to make a connection to the instance and add to NotContactable if required
    if ($NotContactable -notcontains $psitem) {
        $Instance = $psitem
        try {
            $InstanceSMO = Connect-DbaInstance -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
        }
        catch {
            $NotContactable += $Instance
            $There = $false
        }
        if ($NotContactable -notcontains $psitem) {
            if ($null -eq $InstanceSMO.version) {
                $NotContactable += $Instance
                $There = $false
            }
            else {
                $There = $True
            }
        }
    }
    else {
        $There = $false
    }
    # Get the relevant information for the checks in one go to save repeated trips to the instance and set values for Not Contactable tests if required
    $AllInstanceInfo = Get-AllInstanceInfo -Instance $InstanceSMO -Tags $Tags -There $There
    Describe "Instance Connection" -Tags InstanceConnection, Connectivity, High, $filename {
        $skipremote = Get-DbcConfigValue skip.connection.remoting
        $skipping = Get-DbcConfigValue skip.connection.ping
        $skipauth = Get-DbcConfigValue skip.connection.auth
        $authscheme = Get-DbcConfigValue policy.connection.authscheme
        if ($NotContactable -contains $psitem) {
            Context "Testing Instance Connection on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Instance Connection on $psitem" {
                It "connects successfully to $psitem" {
                    #Because Test-DbaInstance only shows connectsuccess false if the Connect-SQlInstance throws an error and we use Connect-DbaInstance
                    $true | Should -BeTrue
                }
                #local is always NTLM except when its a container ;-)
                if ($InstanceSMO.NetBiosName -eq $ENV:COMPUTERNAME -and ($instance -notlike '*,*')) {
                    It -Skip:$skipauth "auth scheme should be NTLM on the local machine on $psitem" {
                        (Test-DbaConnectionAuthScheme -SqlInstance $Instance).authscheme | Should -Be NTLM
                    }
                }
                else {
                    It -Skip:$skipauth "auth scheme should be $authscheme on $psitem" {
                        (Test-DbaConnectionAuthScheme -SqlInstance $Instance).authscheme | Should -Be $authscheme
                    }
                }
                It -Skip:$skipping "We should be able to ping host $psitem" {
                    $ping = New-Object System.Net.NetworkInformation.Ping
                    $timeout = 1000 #milliseconds
                    $reply = $ping.Send($InstanceSMO.ComputerName, $timeout)
                    $pingable = $reply.Status -eq 'Success'
                    $pingable | Should -BeTrue

                }
                It -Skip:$skipremote "We should be able to remote onto $psitem" {
                    #simple remoting check
                    try {
                        $null = Invoke-Command -ComputerName $InstanceSMO.ComputerName -ScriptBlock { Get-ChildItem } -ErrorAction Stop
                        $remoting = $true
                    }
                    catch {
                        $remoting = $false
                    }
                    $remoting | Should -BeTrue
                }
            }
        }
    }

    Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, High, $filename {
        $starttype = Get-DbcConfigValue policy.instance.sqlenginestart
        $state = Get-DbcConfigValue policy.instance.sqlenginestate
        if ($NotContactable -contains $psitem) {
            Context "Testing SQL Engine Service on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            $IsClustered = $InstanceSMO.IsClustered
            Context "Testing SQL Engine Service on $psitem" {
                if ( -not $IsLInux) {
                    @(Get-DbaService -ComputerName $psitem -Type Engine -ErrorAction SilentlyContinue).ForEach{
                        It "SQL Engine service account should be $state on $($psitem.InstanceName)" {
                            Assert-EngineState -AllInstanceInfo $AllInstanceInfo -state $state
                        }
                        if ($IsClustered) {
                            It "SQL Engine service account should have a start mode of Manual on FailOver Clustered Instance $($psitem.InstanceName)" {
                                Assert-EngineStartTypeCluster -AllInstanceInfo $AllInstanceInfo
                            }
                        }
                        else {
                            It "SQL Engine service account should have a start mode of $starttype on standalone instance $($psitem.InstanceName)" {
                                Assert-EngineStartType -AllInstanceInfo $AllInstanceInfo -StartType $starttype
                            }
                        }
                    }
                }
                else {
                    It "Running on Linux so can't check Services on $Psitem" -skip {
                    }
                }
            }
        }
    }

    Describe "TempDB Configuration" -Tags TempDbConfiguration, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing TempDB Configuration on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing TempDB Configuration on $psitem" {
                $TempDBTest = Test-DbaTempdbConfig -SqlInstance $psitem
                It "should have TF1118 enabled on $($TempDBTest[0].SqlInstance)" -Skip:((Get-DbcConfigValue skip.TempDb1118) -or ($InstanceSMO.VersionMajor -gt 12)) {
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

    Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Ad Hoc Workload Optimization on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Ad Hoc Workload Optimization on $psitem" {
                It "Should have Optimize for Ad Hoc workloads set correctly on $psitem" -Skip:((Get-Version -SQLInstance $psitem) -lt 10) {
                    @(Test-DbaOptimizeForAdHoc -SqlInstance $psitem).ForEach{
                        $psitem.CurrentOptimizeAdHoc | Should -Be $psitem.RecommendedOptimizeAdHoc -Because "optimize for ad hoc workloads is a recommended setting"
                    }
                }
            }
        }
    }

    Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Backup Path Access on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "Default File Path" -Tags DefaultFilePath, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Default File Path on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Default Data File Path on $psitem" {
                It "Default Data File Path on $psitem" {
                    $diskFile = Get-DbaInstanceProperty -SqlInstance $psitem | Where-Object Name -eq DefaultFile
                    $diskFile.Value.substring(0, 1) | Should -Not -Be "C" -Because 'Default Data file path should not be your C:\ drive'
                }
            }
            Context "Testing Default Log File Path on $psitem" {
                It "Default Log File Path on $psitem" {
                    $diskLog = Get-DbaInstanceProperty -SqlInstance $psitem | Where-Object Name -eq DefaultLog
                    $diskLog.Value.substring(0, 1) | Should -Not -Be "C" -Because 'Default Log file path should not be your C:\ drive'
                }
            }
        }
    }

    Describe "Dedicated Administrator Connection" -Tags DAC, CIS, Low, $filename {
        $dac = Get-DbcConfigValue policy.dacallowed
        if ($NotContactable -contains $psitem) {
            Context "Testing Dedicated Administrator Connection on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "Network Latency" -Tags NetworkLatency, Connectivity, Medium, $filename {
        $max = Get-DbcConfigValue policy.network.latencymaxms
        if ($NotContactable -contains $psitem) {
            Context "Testing Network Latency on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Network Latency on $psitem" {
                @(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
                    It "network latency should be less than $max ms on $($psitem.SqlInstance)" {
                        $psitem.Average.TotalMilliseconds | Should -BeLessThan $max -Because 'You do not want to be waiting on the network'
                    }
                }
            }
        }
    }

    Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Linked Servers on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Linked Servers on $psitem" {
                @(Test-DbaLinkedServerConnection -SqlInstance $psitem).ForEach{
                    It "Linked Server $($psitem.LinkedServerName) has connectivity on $($psitem.SqlInstance)" {
                        $psitem.Connectivity | Should -BeTrue -Because 'You need to be able to connect to your linked servers'
                    }
                }
            }
        }
    }

    Describe "Max Memory" -Tags MaxMemory, High, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Max Memory on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Max Memory on $psitem" {
                if (-not $IsLInux) {
                    It "Max Memory setting should be correct on $psitem" {
                        @(Test-DbaMaxMemory -SqlInstance $psitem).ForEach{
                            $psitem.MaxValue  | Should -BeLessThan ($psitem.RecommendedValue + 379) -Because 'You do not want to exhaust server memory'
                        }
                    }
                }
                else {
                    It "Max Memory setting should be correct (running on Linux so only checking Max Memory is less than Total Memory) on $psitem" {
                        # simply check that the max memory is less than total memory
                        $MemoryValues = Get-DbaMaxMemory -SqlInstance $psitem
                        $MemoryValues.Total | Should -BeGreaterThan $MemoryValues.MaxValue -Because 'You do not want to exhaust server memory'
                    }
                }
            }
        }
    }


    Describe "Orphaned Files" -Tags OrphanedFile, Low, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking for orphaned database files on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking for orphaned database files on $psitem" {
                It "There should be zero orphaned database files on $psitem" {
                    @(Find-DbaOrphanedFile -SqlInstance $psitem).Count | Should -Be 0 -Because 'You dont want any orphaned files - Use Find-DbaOrphanedFile to locate them'
                }
            }
        }
    }

    Describe "SQL and Windows names match" -Tags ServerNameMatch, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing instance name matches Windows name for $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing instance name matches Windows name for $psitem" {
                if ($InstanceSMO.NetBiosName -eq $ENV:COMPUTERNAME -and ($instance -like '*,*')) {
                    It "We wont check this as it appears to be a local container - for $psitem" -Skip {
                    }
                }
                else {
                    It "Testing rename required for $psitem" {
                        (Test-DbaInstanceName -SqlInstance $psitem).RenameRequired | Should -BeFalse -Because 'SQL and Windows should agree on the server name'
                    }
                }
            }
        }
    }

    Describe "SQL Memory Dumps" -Tags MemoryDump, Medium, $filename {
        $maxdumps = Get-DbcConfigValue	policy.dump.maxcount
        if ($NotContactable -contains $psitem) {
            Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
                It "dump count of $count is less than or equal to the $maxdumps dumps on $psitem" -Skip:($InstanceSMO.Version.Major -lt 11 -and (-not ($InstanceSMO.Version.Major -eq 10 -and $InstanceSMO.Version.Minor -eq 50)) ) {
                    Assert-MaxDump -AllInstanceInfo $AllInstanceInfo -maxdumps $maxdumps
                }
            }
        }
    }

    Describe "Supported Build" -Tags SupportedBuild, DISA, High, $filename {
        $BuildWarning = Get-DbcConfigValue policy.build.warningwindow
        $BuildBehind = Get-DbcConfigValue policy.build.behind
        $Date = Get-Date
        if ($NotContactable -contains $psitem) {
            Context "Checking that build is still supported by Microsoft for $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that build is still supported by Microsoft for $psitem" {
                if ($BuildBehind) {
                    It "The build is not behind the latest build by more than $BuildBehind for $psitem" {
                        Assert-InstanceSupportedBuild -Instance $InstanceSMO -BuildBehind $BuildBehind -Date $Date
                    }
                }
                It "The build is supported by Microsoft for $psitem" {
                    Assert-InstanceSupportedBuild -Instance $InstanceSMO -Date $Date
                }
                It "The build is supported by Microsoft within the warning window of $BuildWarning months for $psitem" {
                    Assert-InstanceSupportedBuild -Instance $InstanceSMO -BuildWarning $BuildWarning -Date $Date
                }
            }
        }
    }


    Describe "SA Login Renamed" -Tags SaRenamed, DISA, CIS, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking that sa login has been renamed on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that sa login has been renamed on $psitem" {
                $results = Get-DbaLogin -SqlInstance $psitem -Login sa
                It "sa login has been renamed on $psitem" {
                    $results | Should -Be $null -Because 'Renaming the sa account is a requirement'
                }
            }
        }
    }

    Describe "SA Login Disabled" -Tags SaDisabled, DISA, CIS, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking that sa login has been disabled on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that sa login has been disabled on $psitem" {
                $skip = Get-DbcConfigValue skip.security.sadisabled
                It "sa login is disabled on $psitem" -Skip:$Skip {
                    Assert-SaDisabled -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Login SA cannot exist" -Tags SaExist, CIS, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking that a login named sa does not exist on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that a login named sa does not exist on $psitem" {
                $skip = Get-DbcConfigValue skip.security.saexist
                It "sa login does not exist on $psitem" -Skip:$Skip {
                    Assert-SaExist -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "Default Backup Compression" -Tags DefaultBackupCompression, Low, $filename {
        $defaultbackupcompression = Get-DbcConfigValue policy.backup.defaultbackupcompression
        if ($NotContactable -contains $psitem) {
            Context "Testing Default Backup Compression on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "XE Sessions That should be Stopped" -Tags XESessionStopped, ExtendedEvent, Medium, $filename {
        $xesession = Get-DbcConfigValue policy.xevent.requiredstoppedsession
        if ((Get-Version -SQLInstance $psitem) -gt 10) {
            # no point running if we dont have something to check
            if ($xesession) {
                if ($NotContactable -contains $psitem) {
                    Context "Checking sessions on $psitem" {
                        It "Can't Connect to $Psitem" {
                            $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                        }
                    }
                }
                else {
                    Context "Checking sessions on $psitem" {
                        $runningsessions = (Get-DbaXESession -SqlInstance $psitem).Where{ $_.Status -eq 'Running' }.Name
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
        else {
            Context "Checking sessions on $psitem" {
                It "Version does not support XE sessions on $Instance" -skip {
                    1 | Should -Be 3
                }
            }
        }
    }

    Describe "XE Sessions That should be Running" -Tags XESessionRunning, ExtendedEvent, Medium, $filename {
        $xesession = Get-DbcConfigValue policy.xevent.requiredrunningsession
        if ((Get-Version -SQLInstance $psitem) -gt 10) {
            # no point running if we dont have something to check
            if ($xesession) {
                if ($NotContactable -contains $psitem) {
                    Context "Checking running sessions on $psitem" {
                        It "Can't Connect to $Psitem" {
                            $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                        }
                    }
                }
                else {
                    Context "Checking running sessions on $psitem" {
                        $runningsessions = (Get-DbaXESession -SqlInstance $psitem).Where{ $_.Status -eq 'Running' }.Name
                        @($xesession).ForEach{
                            It "session $psitem should be running on $Instance" {
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
        else {
            Context "Checking running sessions on $psitem" {
                It "Version does not support XE sessions on $Instance" -skip {
                    1 | Should -Be 3
                }
            }
        }
    }

    Describe "XE Sessions That Are Allowed to Be Running" -Tags XESessionRunningAllowed, ExtendedEvent, Medium, $filename {
        $xesession = Get-DbcConfigValue policy.xevent.validrunningsession
        if ((Get-Version -SQLInstance $psitem) -gt 10) {
        # no point running if we dont have something to check
        if ($xesession) {
            if ($NotContactable -contains $psitem) {
                Context "Checking running sessions allowed on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Checking running sessions allowed on $psitem" {
                    @(Get-DbaXESession -SqlInstance $psitem).Where{ $_.Status -eq 'Running' }.ForEach{
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
        else {
            Context "Checking running sessions allowed on $psitem" {
                It "Version does not support XE sessions on $Instance" -skip {
                    1 | Should -Be 3
                }
            }
        }
    }
    Describe "OLE Automation" -Tags OLEAutomation, security, CIS, Medium, $filename {
        $OLEAutomation = Get-DbcConfigValue policy.oleautomation
        if ($NotContactable -contains $psitem) {
            Context "Testing OLE Automation on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "sp_whoisactive is Installed" -Tags WhoIsActiveInstalled, Low, $filename {
        $db = Get-DbcConfigValue policy.whoisactive.database
        if ($NotContactable -contains $psitem) {
            Context "Testing WhoIsActive exists on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "Model Database Growth" -Tags ModelDbGrowth, Low, $filename {
        $modeldbgrowthtest = Get-DbcConfigValue skip.instance.modeldbgrowth
        if (-not $modeldbgrowthtest) {
            if ($NotContactable -contains $psitem) {
                Context "Testing model database growth setting is not default on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "Ad Users and Groups " -Tags ADUser, Domain, High, $filename {
        if (-not $IsLinux) {
            $userexclude = Get-DbcConfigValue policy.adloginuser.excludecheck
            $groupexclude = Get-DbcConfigValue policy.adlogingroup.excludecheck

            if ($NotContactable -contains $psitem) {
                Context "Testing Active Directory users on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                    }
                }
                Context "Testing Active Directory groups on $psitem" {
                    It "Can't Connect to $Psitem" {
                        $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                    }
                }
            }
            else {
                Context "Testing Active Directory users on $psitem" {
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

                Context "Testing Active Directory groups on $psitem" {
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
        else {
            Context "Testing Active Directory users on $psitem" {
                It "Running on Linux so can't check AD on $Psitem" -skip {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
            Context "Testing Active Directory groups on $psitem" {
                It "Running on Linux so can't check AD on $Psitem" -skip {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
    }

    Describe "Error Log Entries" -Tags ErrorLog, Medium, $filename {
        $logwindow = Get-DbcConfigValue policy.errorlog.warningwindow
        if ($NotContactable -contains $psitem) {
            Context "Checking error log on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking error log on $psitem" {
                It "Error log should be free of error severities 17-24 within the window of $logwindow days on $psitem" {
                    Assert-ErrorLogEntry -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Error Log Count" -Tags ErrorLogCount, CIS, Low, $filename {
        $errorLogCount = Get-DbcConfigValue policy.errorlog.logcount
        if ($NotContactable -contains $psitem) {
            Context "Checking error log count on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking error log count on $psitem" {
                It "Error log count should be greater or equal to $errorLogCount on $psitem" {
                    Assert-ErrorLogCount -SqlInstance $psitem -errorLogCount $errorLogCount
                }
            }
        }
    }

    Describe "Instance MaxDop" -Tags MaxDopInstance, MaxDop, Medium, $filename {
        $UseRecommended = Get-DbcConfigValue policy.instancemaxdop.userecommended
        $MaxDop = Get-DbcConfigValue policy.instancemaxdop.maxdop
        $ExcludeInstance = Get-DbcConfigValue policy.instancemaxdop.excludeinstance
        if ($NotContactable -contains $psitem) {
            Context "Testing Instance MaxDop Value on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            if ($psitem -in $ExcludeInstance) { $Skip = $true }else { $skip = $false }
            Context "Testing Instance MaxDop Value on $psitem" {
                It "Instance Level MaxDop setting should be correct on $psitem" -Skip:$Skip {
                    Assert-InstanceMaxDop -Instance $psitem -UseRecommended:$UseRecommended -MaxDopValue $MaxDop
                }
            }
        }
    }

    Describe "Two Digit Year Cutoff" -Tags TwoDigitYearCutoff, Low, $filename {
        $twodigityearcutoff = Get-DbcConfigValue policy.twodigityearcutoff
        if ($NotContactable -contains $psitem) {
            Context "Testing Two Digit Year Cutoff on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "Trace Flags Expected" -Tags TraceFlagsExpected, TraceFlag, High, $filename {
        $ExpectedTraceFlags = Get-DbcConfigValue policy.traceflags.expected
        if ($NotContactable -contains $psitem) {
            Context "Testing Expected Trace Flags on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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
    Describe "Trace Flags Not Expected" -Tags TraceFlagsNotExpected, TraceFlag, Medium, $filename {
        $NotExpectedTraceFlags = Get-DbcConfigValue policy.traceflags.notexpected
        $ExpectedTraceFlags = Get-DbcConfigValue policy.traceflags.expected
        if ($NotContactable -contains $psitem) {
            Context "Testing Not Expected Trace Flags on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Not Expected Trace Flags on $psitem" {
                It "Expected Trace Flags $NotExpectedTraceFlags to not exist on $psitem" {
                    Assert-NotTraceFlag -SQLInstance $psitem -NotExpectedTraceFlag $NotExpectedTraceFlags -ExpectedTraceFlag $ExpectedTraceFlags
                }
            }
        }
    }

    Describe "CLR Enabled" -Tags CLREnabled, security, CIS, High, $filename {
        $CLREnabled = Get-DbcConfigValue policy.security.clrenabled
        if ($NotContactable -contains $psitem) {
            Context "Testing CLR Enabled on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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
    Describe "Cross Database Ownership Chaining" -Tags CrossDBOwnershipChaining, security, CIS, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Testing Cross Database Ownership Chaining on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Cross Database Ownership Chaining on $psitem" {
                It "Cross Database Ownership Chaining should be disabled on $psitem" {
                    Assert-CrossDBOwnershipChaining -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "Ad Hoc Distributed Queries" -Tags AdHocDistributedQueriesEnabled, security, CIS, Medium, $filename {
        $AdHocDistributedQueriesEnabled = Get-DbcConfigValue policy.security.AdHocDistributedQueriesEnabled
        if ($NotContactable -contains $psitem) {
            Context "Testing Ad Hoc Distributed Queries on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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
    Describe "XP CmdShell" -Tags XpCmdShellDisabled, security, CIS, Medium, $filename {
        $XpCmdShellDisabled = Get-DbcConfigValue policy.security.XpCmdShellDisabled
        if ($NotContactable -contains $psitem) {
            Context "Testing XP CmdShell on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
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

    Describe "Scan For Startup Procedures" -Tags ScanForStartupProceduresDisabled, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.instance.scanforstartupproceduresdisabled
        $ScanForStartupProcsDisabled = Get-DbcConfigValue policy.security.scanforstartupproceduresdisabled
        if ($NotContactable -contains $psitem) {
            Context "Testing Scan For Startup Procedures on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Scan For Startup Procedures on $psitem" {
                It "Scan For Startup Procedures is set to $ScanForStartupProcsDisabled on $psitem" -Skip:$skip {
                    Assert-ScanForStartupProcedures -AllInstanceInfo $AllInstanceInfo -ScanForStartupProcsDisabled $ScanForStartupProcsDisabled
                }
            }
        }
    }
    Describe "Default Trace" -Tags DefaultTrace, CIS, Low, $filename {
        $skip = Get-DbcConfigValue skip.instance.defaulttrace
        if ($NotContactable -contains $psitem) {
            Context "Checking Default Trace on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking Default Trace on $psitem" {
                It "The Default Trace should be enabled on $psitem"  -Skip:$skip {
                    Assert-DefaultTrace -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "OLE Automation Procedures Disabled" -Tags OLEAutomationProceduresDisabled, CIS, Low, $filename {
        $skip = Get-DbcConfigValue skip.instance.oleautomationproceduresdisabled
        if ($NotContactable -contains $psitem) {
            Context "Checking OLE Automation Procedures on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking OLE Automation Procedures on $psitem" {
                It "The OLE Automation Procedures should be disabled on $psitem"  -Skip:$skip {
                    Assert-OLEAutomationProcedures -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "Remote Access Disabled" -Tags RemoteAccessDisabled, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.instance.remoteaccessdisabled
        if ($NotContactable -contains $psitem) {
            Context "Testing Remote Access on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Remote Access on $psitem" {
                It "The Remote Access should be disabled on $psitem" -Skip:$skip {
                    Assert-RemoteAccess -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Latest Build" -Tags LatestBuild, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.instance.latestbuild
        if ($NotContactable -contains $psitem) {
            Context "Testing Latest Build on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Latest Build on $psitem" {
                It "The Latest Build of SQL should be installed on $psitem" -Skip:$skip {
                    Assert-LatestBuild -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Login BUILTIN Administrators cannot exist" -Tags BuiltInAdmin, CIS, Medium, $filename {
        if ($NotContactable -contains $psitem) {
            Context "Checking that a login named BUILTIN\Administrators does not exist on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that a login named BUILTIN\Administrators does not exist on $psitem" {
                $skip = Get-DbcConfigValue skip.security.builtinadmin
                It "BUILTIN\Administrators login does not exist on $psitem" -Skip:$skip {
                    Assert-BuiltInAdmin -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "Local Windows Groups Not Have SQL Logins" -Tags LocalWindowsGroup, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.localwindowsgroup
        if ($NotContactable -contains $psitem) {
            Context "Checking that local Windows groups do not have SQL Logins on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking that local Windows groups do not have SQL Logins on $psitem" {
                It "Local Windows groups should not SQL Logins on $psitem" -Skip:$skip {
                    Assert-LocalWindowsGroup -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Failed Login Auditing" -Tags LoginAuditFailed, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.loginauditlevelfailed
        if ($NotContactable -contains $psitem) {
            Context "Testing if failed login auditing is in place on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if failed login auditing is in place on $psitem" {
                It "The failed login auditing should be set on $psitem" -Skip:$skip {
                    Assert-LoginAuditFailed -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Successful Login Auditing" -Tags LoginAuditSuccessful, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.loginauditlevelsuccessful
        if ($NotContactable -contains $psitem) {
            Context "Testing if successful and failed login auditing is in place on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if successful and failed login auditing is in place on $psitem" {
                It "The successful and failed auditing should be set on $psitem" -Skip:$skip {
                    Assert-LoginAuditSuccessful -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "SqlAgentProxiesNoPublicRole" -Tags SqlAgentProxiesNoPublicRole, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.sqlagentproxiesnopublicrole
        if ($NotContactable -contains $psitem) {
            Context "Testing to see if the public role has access to the SQL Agent proxies on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing to see if the public role has access to the SQL Agent proxies on $psitem" {
                It "The public role should not have access to the SQL Agent Proxies on $psitem" -Skip:$skip {
                    Assert-SqlAgentProxiesNoPublicRole -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Hide Instance" -Tags HideInstance, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.hideinstance
        if ($NotContactable -contains $psitem) {
            Context "Checking the Hide an Instance of SQL Server Database Engine property on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Checking the Hide an Instance of SQL Server Database Engine property on $psitem" {
                It "The Hide an Instance of SQL Server Database Engine property on SQL Server instance $psitem" -Skip:$skip {
                    Assert-HideInstance -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "SQL Engine Service Admin" -Tags EngineServiceAdmin, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.EngineServiceAdmin
        if ($NotContactable -contains $psitem) {
            Context "Testing whether SQL Engine account is a local administrator on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            if ($IsCoreCLR) {
                $Skip = $true
            }
            Context "Testing whether SQL Engine account is a local administrator on $psitem" {
                It "The SQL Engine service account should not be a local administrator on $psitem" -Skip:$skip {
                    Assert-EngineServiceAdmin -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "SQL Agent Service Admin" -Tags AgentServiceAdmin, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.AgentServiceAdmin
        if ($NotContactable -contains $psitem) {
            Context "Testing whether SQL Agent account is a local administrator on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            if ($IsCoreCLR) {
                $Skip = $true
            }
            Context "Testing whether SQL Agent account is a local administrator on $psitem" {
                It "The SQL Agent service account should not be a local administrator on $psitem" -Skip:$skip {
                    Assert-AgentServiceAdmin -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "SQL Full Text Service Admin" -Tags FullTextServiceAdmin, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.FullTextServiceAdmin
        if ($NotContactable -contains $psitem) {
            Context "Testing whether SQL Full Text account is a local administrator on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false | Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            if ($IsCoreCLR) {
                $Skip = $true
            }
            Context "Testing whether SQL Full Text account is a local administrator on  $psitem" {
                It "The SQL Full Text service account should not be a local administrator on $psitem" -Skip:$skip {
                    Assert-FullTextServiceAdmin -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
    Describe "Login Check Policy" -Tags LoginCheckPolicy, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.LoginCheckPolicy
        if ($NotContactable -contains $psitem) {
            Context "Testing if the CHECK_POLICY is enabled on all logins on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if the CHECK_POLICY is enabled on all logins on $psitem" {
                It "All logins should have the CHECK_POLICY option set to ON on $psitem" -Skip:$skip {
                    Assert-LoginCheckPolicy -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Login Password Expiration" -Tags LoginPasswordExpiration, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.LoginPasswordExpiration
        if ($NotContactable -contains $psitem) {
            Context "Testing if the login password expiration is enabled for sql logins in the sysadmin role $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if the login password expiration is enabled for sql logins in the sysadmin role on $psitem" {
                It "All sql logins should have the password expiration option set to ON in the sysadmin role on $psitem" -Skip:$skip {
                    Assert-LoginPasswordExpiration -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Login Must Change" -Tags LoginMustChange, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.LoginMustChange
        if ($NotContactable -contains $psitem) {
            Context "Testing if the new SQL logins that have not logged have to change their password when they log in on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if the new SQL logins that have not logged have to change their password when they log in on $psitem" {
                It "All new sql logins should have the have to change their password when they log in for the first time on $psitem"  -Skip:$skip {
                    Assert-LoginMustChange -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Suspect Page Limit Nearing" -Tags SuspectPageLimit, Medium, $filename {
        $skip = Get-DbcConfigValue skip.instance.suspectpagelimit
        $thresholdPercent = Get-DbcConfigValue policy.suspectpages.threshold
        if ($NotContactable -contains $psitem) {
            Context "Testing if the suspect_pages table is nearing the limit of 1000 rows on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if the suspect_pages table is nearing the limit of 1000 rows on $psitem" {
                It "The suspect_pages table in msdb shouldn't be nearing the limit of 1000 rows on $psitem" -Skip:$skip {
                    (((Get-DbaSuspectPage -SqlInstance $psitem | Measure-Object).Count)/1000)*100 | Should -BeLessThan $thresholdPercent
                }
            }
        }
    }

    Describe "SQL Mail XPs Disabled" -Tags SQLMailXPsDisabled, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.SQLMailXPsDisabled
        if ($NotContactable -contains $psitem) {
            Context "Testing SQL Mail XPs on $psitem" {
                It "Can't Connect to $Psitem" -Skip:($skip -or $InstanceSMO.VersionMajor -gt 10){
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing SQL Mail XPs on $psitem" {
                It "The SQL Mail XPs should be disabled on $psitem" -Skip:($skip -or $InstanceSMO.VersionMajor -gt 10){
                    Assert-SQLMailXPs -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }

    Describe "Public Role Permissions" -Tags PublicPermission, Security, CIS, Medium, $filename {
        $skip = Get-DbcConfigValue skip.security.PublicPermission
        if ($NotContactable -contains $psitem) {
            Context "Testing if the public role permissions don't have permissions on $psitem" {
                It "Can't Connect to $Psitem" -Skip:$skip {
                    $false	| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing if the public role permissions don't have permissions  on $psitem" {
                It "All permissions should be set to CIS standards on the public role on $psitem"  -Skip:$skip {
                    Assert-PublicPermission -AllInstanceInfo $AllInstanceInfo
                }
            }
        }
    }
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, CIS, High, $filename {
    @(Get-ComputerName).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing SQL Browser Service on $psitem" {
                It "Can't Connect to $Psitem" {
                    $true | Should -BeFalse -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            # cant check agent on container - hmm does this actually work with instance need to check
            if (-not $IsLinux -and ($InstanceSMO.HostPlatform -ne 'Linux')) {
                Context "Testing SQL Browser Service on $psitem" {
                    if (-not $IsLinux) {
                        $Services = Get-DbaService -ComputerName $psitem
                        if ($Services.Where{ $_.ServiceType -eq 'Engine' }.Count -eq 1) {
                            It "SQL Browser service should be Stopped as only one instance is installed on $psitem" {
                                $Services.Where{ $_.ServiceType -eq 'Browser' }.State | Should -Be "Stopped" -Because 'Unless there are multiple instances you dont need the browser service'
                            }
                        }
                        else {
                            It "SQL Browser service should be Running as multiple instances are installed on $psitem" {
                                $Services.Where{ $_.ServiceType -eq 'Browser' }.State | Should -Be "Running" -Because 'You need the browser service with multiple instances' }
                        }
                        if ($Services.Where{ $_.ServiceType -eq 'Engine' }.Count -eq 1) {
                            It "SQL Browser service startmode should be Disabled as only one instance is installed on $psitem" {
                                $Services.Where{ $_.ServiceType -eq 'Browser' }.StartMode | Should -Be "Disabled" -Because 'Unless there are multiple instances you dont need the browser service' }
                        }
                        else {
                            It "SQL Browser service startmode should be Automatic as multiple instances are installed on $psitem" {
                                $Services.Where{ $_.ServiceType -eq 'Browser' }.StartMode | Should -Be "Automatic"
                            }
                        }
                    }
                    else {
                        It "Running on Linux so can't check Services on $Psitem" -skip {
                        }
                    }
                }
            }
            else {
                Context "Testing SQL Browser Service on $psitem" {
                    It "Running on Linux or connecting to container so can't check Services on $Psitem" -skip {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUW4dbcY1WxYJ8l/oAYpwlqWaL
# aV+gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQWsI/NEEkwLkqtHxRQfgYdjkSp
# BTANBgkqhkiG9w0BAQEFAASCAQCAwuSHT8zQvUzd0+krCKk8F7Cr3g2FAbQvyyNV
# VVstquqAh3cPQAt2Lk90/jNnklPLKWqTr7FTOkLdwkMs6NSvwRoJu6XBNL/ginmp
# R8GpzyFEp4p1Pot+dZSds/d+wx3G9C9+V8Nchj0oeQSMPjbalUTPNPfx1o7cpHEH
# k8JY8K7rnCSSnCnkeZPP5KmXSrN9nSL9yX8EbQfmHSX8p/mNvPhkdWoxiTeAeEp0
# Rh6z/OF4acRn3MxwpT+8WHvAT+X9Cen5Ec5o/BCdsx6E817E8g30x4RpO6I1jVWL
# tYmk20LK2bUx5An2PGWmbutWs9KOn4OiM7TG0YG6WRL0i4Ot
# SIG # End signature block

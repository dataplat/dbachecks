$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
    @(Get-Instance).ForEach{
        Context "Testing SQL Engine Service on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Engine).ForEach{
                It "SQL Engine service account Should Be running on $($psitem.InstanceName)" {
                    $psitem.State | Should -Be "Running" -Because 'If the service is not running, the SQL Server will not be accessible'
                }
                It "SQL Engine service account should have a start mode of Automatic on $($psitem.InstanceName)" {
                    $psitem.StartMode | Should -Be "Automatic" -Because 'If the server restarts, the SQL Server will not be accessibl'
                }
            }
        }
    }
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename { 
    @(Get-ComputerName).ForEach{ 
        Context "Testing SQL Browser Service on $psitem" { 
            $Services = Get-DbaSqlService -ComputerName $psitem 
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
Describe "TempDB Configuration" -Tags TempDbConfiguration, $filename {
    @(Get-Instance).ForEach{
        Context "Testing TempDB Configuration on $psitem" {
            $TempDBTest = Test-DbaTempDbConfiguration -SqlServer $psitem
            It "should have TF1118 enabled on $($TempDBTest[0].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDb1118) {
                $TempDBTest[0].CurrentSetting | Should -Be $TempDBTest[0].Recommended -Because 'TF 1118 should be enabled'
            }
            It "should have $($TempDBTest[1].Recommended) TempDB Files on $($TempDBTest[1].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.tempdbfileCount) {
                $TempDBTest[1].CurrentSetting | Should -Be $TempDBTest[1].Recommended -Because 'This is the recommended number of tempdb files for your server'
            }
            It "should not have TempDB Files autogrowth set to percent on $($TempDBTest[2].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $TempDBTest[2].CurrentSetting | Should -Be $TempDBTest[2].Recommended -Because 'Auto growth type should not be percent'
            }
            It "should not have TempDB Files on the C Drive on $($TempDBTest[3].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $TempDBTest[3].CurrentSetting | Should -Be $TempDBTest[3].Recommended -Because 'You dot want the tempdb files on the same drive as the operating system'
            }
            It "should not have TempDB Files with MaxSize Set on $($TempDBTest[4].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileSizeMax) {
                $TempDBTest[4].CurrentSetting | Should -Be $TempDBTest[4].Recommended -Because 'Tempdb files should be able to grow'
            }
        }
    }
}

Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
    @(Get-Instance).ForEach{
        Context "Testing Ad Hoc Workload Optimization on $psitem" {
            It "$psitem Should Be Optimised for Ad Hoc workloads" {
                @(Test-DbaOptimizeForAdHoc -SqlInstance $psitem).ForEach{
                    $psitem.CurrentOptimizeAdHoc | Should -Be $psitem.RecommendedOptimizeAdHoc
                }
            }
        }
    }
}

Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
    @(Get-Instance).ForEach{
        Context "Testing Backup Path Access on $psitem" {
            if (-not (Get-DbcConfigValue policy.storage.backuppath)) {
                $backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
            }
            else {
                $backuppath = Get-DbcConfigValue policy.storage.backuppath
            }

            It "can access backup path ($backuppath) on $psitem" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $backuppath | Should -BeTrue -Because 'The SQL Service account needs to have access to the backup path to backup your databases'
            }
        }
    }
}

Describe "Dedicated Administrator Connection" -Tags DAC, $filename {
    $dac = Get-DbcConfigValue policy.dacallowed
    @(Get-Instance).ForEach{
        Context "Testing Dedicated Administrator Connection on $psitem" {
            It "DAC is set to $dac on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should -Be $dac -Because 'This is the setting that you have chosen for DAC connections'
            }
        }
    }
}

Describe "Network Latency" -Tags NetworkLatency, Connectivity, $filename {
    $max = Get-DbcConfigValue policy.network.latencymaxms
    @(Get-Instance).ForEach{
        Context "Testing Network Latency on $psitem" {
            @(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
                It "network latency Should Be less than $max ms on $($psitem.SqlInstance)" {
                    $psitem.Average.TotalMilliseconds | Should -BeLessThan $max -Because 'You dont want to be waiting on the network'
                }
            }
        }
    }
}

Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, $filename {
    @(Get-Instance).ForEach{
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
    @(Get-Instance).ForEach{
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
    @(Get-Instance).ForEach{
        Context "Checking for orphaned database files on $psitem" {
            It "$psitem doesn't have orphan files" {
                (Find-DbaOrphanedFile -SqlInstance $psitem).Count | Should -Be 0 -Because 'You dont want any orphaned files - Use Find-DbaOrphanedFiles to locate them'
            }
        }
    }
}

Describe "SQL + Windows names match" -Tags ServerNameMatch, $filename {
    @(Get-Instance).ForEach{
        Context "Testing instance name matches Windows name for $psitem" {
            It "$psitem doesn't require rename" {
                (Test-DbaServerName -SqlInstance $psitem).RenameRequired | Should -BeFalse -Because 'SQL and Windows should agree on the server name'
            }
        }
    }
}

Describe "SQL Memory Dumps" -Tags MemoryDump, $filename {
    $maxdumps = Get-DbcConfigValue -Name policy.dump.maxcount
    @(Get-Instance).ForEach{
        Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
            $count = (Get-DbaDump -SqlInstance $psitem).Count
            It "dump count of $count is less than or equal to the $maxdumps dumps on $psitem" {
                $Count | Should -BeLessOrEqual $maxdumps -Because 'Memory dumps often suggest issues with the SQL Server instance'
            }
        }
    }
}

Describe "Supported Build" -Tags SupportedBuild, DISA, $filename {
    $BuildWarning = Get-DbcConfigValue -Name  policy.build.warningwindow
    @(Get-Instance).ForEach{
        Context "Checking that build is still supportedby Microsoft for $psitem" {
            $results = Get-DbaSqlBuildReference -SqlInstance $psitem
            It "$($results.Build) on $psitem is still supported" {
                $results.SupportedUntil  | Should -BeGreaterThan (Get-Date) -Because 'This build is now unsupported by Microsoft'
            }
            It "$($results.Build) on $psitem is supported for more than $BuildWarning Months" {
                $results.SupportedUntil  | Should -BeGreaterThan (Get-Date).AddMonths($BuildWarning) -Because 'This build will soon be unsupported by Microsoft'
            }
        }
    }
}

Describe "SA Login Renamed" -Tags SaRenamed, DISA, $filename {
    @(Get-Instance).ForEach{
        Context "Checking that sa login has been renamed on $psitem" {
            $results = Get-DbaLogin -SqlInstance $psitem -Login sa
            It "sa login does not exist on $psitem" {
                $results | Should -Be $null -Because 'Renaming the sa account is a requirement'
            }
        }
    }
}

Describe "Default Backup Compression" -Tags DefaultBackupCompression, $filename {
    $defaultbackupcompression = Get-DbcConfigValue policy.backup.defaultbackupcompression
    @(Get-Instance).ForEach{
        Context "Testing Default Backup Compression on $psitem" {
            It "Default Backup Compression is set to $defaultbackupcompression on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should -Be $defaultbackupcompression -Because 'The default backup compression should be set correctly'
            }
        }
    }
}

Describe "XE Sessions That Should Be Stopped" -Tags XESessionStopped, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue policy.xevent.requiredstoppedsession
    # no point running if we dont have something to check
    if ($xesession) {
        @(Get-Instance).ForEach{
            Context "Checking sessions on $psitem" {
                $runningsessions = (Get-DbaXESession -SqlInstance $psitem).Where{$_.Status -eq 'Running'}.Name
                $xesession.ForEach{
                    It "Session $psitem should not be running" {
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
        @(Get-Instance).ForEach{
            Context "Checking running sessions on $psitem" {
                $runningsessions = (Get-DbaXESession -SqlInstance $psitem).Where{$_.Status -eq 'Running'}.Name
                $xesession.ForEach{
                    It "session $psitem Should Be running" {
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
        @(Get-Instance).ForEach{
            Context "Checking sessions on $psitem" {
                @(Get-DbaXESession -SqlInstance $psitem).Where{$_.Status -eq 'Running'}.ForEach{
                    It "Session $($Psitem.Name) is allowed to be running" {
                        $psitem.name | Should -BeIn $xesession -Because "Only these sessions are  allowed to be running"
                    }
                }
            }
        }
    }
    else {
        Write-Warning "You need to use Set-DbcConfig -Name policy.xevent.validrunningsession -Value to add some Extended Events session names to run this check"
    }
}
Describe "OLE Automation" -Tags OLEAutomation, $filename {
    $OLEAutomation = Get-DbcConfigValue policy.oleautomation
    @(Get-Instance).ForEach{
        Context "Testing OLE Automation on $psitem" {
            It "OLE Automation is set to $OLEAutomation on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'OleAutomationProceduresEnabled').ConfiguredValue -eq 1 | Should -Be $OLEAutomation -Because 'OLE Automation can introduce additional security risks'
            }
        }
    }
}

Describe "sp_whoisactive is Installed" -Tags WhoIsActiveInstalled, $filename {
    $db = Get-DbcConfigValue policy.whoisactive.database
    @(Get-Instance).ForEach{
        Context "Testing WhoIsActive exists on $psitem" {
            It "WhoIsActive should exists on $db on $psitem" {
                (Get-DbaSqlModule -SqlInstance $psitem -Database $db -Type StoredProcedure | Where-Object name -eq "sp_WhoIsActive") | Should -Not -Be $Null -Because 'The sp_WhoIsActive stored procedure should be installed'
            }
        }
    }
}

Describe "Model Database Growth" -Tags ModelDbGrowth, $filename {
    $modeldbgrowthtest = Get-DbcConfigValue skip.instance.modeldbgrowth
    if (-not $modeldbgrowthtest) {
        @(Get-Instance).ForEach{
            Context "Testing model database growth setting is not default on $psitem" {
                @(Get-DbaDatabaseFile -SqlInstance $psitem -Database Model).ForEach{
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
    @(Get-Instance).ForEach{
        Context "Testing active Directory users on $psitem" {
            @(Test-DbaValidLogin -SqlInstance $psitem -FilterBy LoginsOnly -ExcludeLogin $userexclude).ForEach{
                It "Active Directory user $($psitem.login) was found in $($psitem.domain)" {
                    $psitem.found | Should -Be $true -Because "$($psitem.login) should be in Active Directory"
                }
                if ($psitem.found -eq $true) {
                    It "Active Directory user $($psitem.login) should not have expired password in $($psitem.domain)" {
                        $psitem.PasswordExpired | Should -Be $false -Because "$($psitem.login) password should not be expired"
                    }                
                    It "Active Directory user $($psitem.login) should not be lockedout in $($psitem.domain)" {
                        $psitem.lockedout | Should -Be $false -Because "$($psitem.login) should mot be locked out"
                    }
                    It "Active Directory user $($psitem.login) should be enabled on $($psitem.domin)" {
                        $psitem.Enabled | Should -Be $true -Because "$($psitem.login) should be enabled"
                    }
                    It "Active Directory user $($psitem.login) should not be disabled in SQL Server on $($psitem.Server)" {
                        $psitem.DisabledInSQLServer | Should -Be $false -Because "$($psitem.login) should be active on the SQL server"
                    }
                }

            }            
        }

        Context "Testing active Directory groups on $psitem" {
            @(Test-DbaValidLogin -SqlInstance $psitem -FilterBy GroupsOnly -ExcludeLogin $groupexclude).ForEach{
                It "Active Directory group $($psitem.login) was found in $($psitem.domain)" {
                    $psitem.found | Should -Be $true -Because "$($psitem.login) should be in Active Directory"
                }
                if ($psitem.found -eq $true) {
                    It "Active Directory group $($psitem.login) should not be disabled in SQL Server on $($psitem.Server)" {
                        $psitem.DisabledInSQLServer | Should -Be $false -Because "$($psitem.login) should be active on the SQL server"
                    }
                }

            }            
        }
    }
}
Describe "Error Log Entries" -Tags ErrorLog, $filename {
    $logWindow = Get-DbcConfigValue policy.errorlog.warningwindow
    @(Get-Instance).ForEach{
        Context "Checking error log on $psitem" {
            It "Error log should be free of error severities 17-24 on $psitem" {
                (Get-DbaSqlLog -SqlInstance $psitem -After (Get-Date).AddDays( - $logWindow)).Text | Should -Not -Match "Severity: 1[7-9]" -Because "these severities indicate serious problems"
                (Get-DbaSqlLog -SqlInstance $psitem -After (Get-Date).AddDays( - $logWindow)).Text | Should -Not -Match "Severity: 2[0-4]" -Because "these severities indicate serious problems"
            }
        }
    }
}

$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing SQL Engine Service on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Engine).ForEach{
                It "SQL Engine service account Should Be running on $($psitem.InstanceName)" {
                    $psitem.State | Should -Be "Running" -Because 'If the service is not running you wont have any SQL!'
                }
                It "SQL Engine service account should have a start mode of Automatic on $($psitem.InstanceName)" {
                    $psitem.StartMode | Should -Be "Automatic" -Because 'If the server restarts you wont have any SQL'
                }
            }
        }
    }
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename {
    (Get-ComputerName).ForEach{
        Context "Testing SQL Browser Service on $psitem" {
            It "SQL browser service on $psitem Should Be Stopped unless multiple instances are installed" {
                if ((Get-DbaSqlService -ComputerName $psitem -Type Engine).Count -eq 1) {
                    (Get-DbaSqlService -ComputerName $psitem -Type Browser).State | Should -Be "Stopped" -Because 'Unless there are multple instances you dont need the browser service'
                }
                else {
                    (Get-DbaSqlService -ComputerName $psitem -Type Browser).State| Should -Be "Running" -Because 'You need the browser service with multiple instances'
                }
            }
            It "SQL browser service startmode Should Be Disabled on $psitem unless multiple instances are installed" {
                if ((Get-DbaSqlService -ComputerName $psitem -Type Engine).Count -eq 1) {
                    (Get-DbaSqlService -ComputerName $psitem -Type Browser).State | Should -Be "Disabled" -Because 'Unless there are multple instances you dont need the browser service'
                }
                else {
                    (Get-DbaSqlService -ComputerName $psitem -Type Browser).StartMode| Should -Be "Automatic"
                }
            }
        }
    }
}

Describe "TempDB Configuration" -Tags TempDbConfiguration, $filename {
    (Get-SqlInstance).ForEach{
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
            It "should not have TempDB Files with MaxSize Set on $($TempDBTest[4].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
                $TempDBTest[4].CurrentSetting | Should -Be $TempDBTest[4].Recommended -Because 'Tempdb files should be able to grow'
            }
        }
    }
}

Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
    (Get-SqlInstance).ForEach{
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
    (Get-SqlInstance).ForEach{
        Context "Testing Backup Path Access on $psitem" {
            if (-not (Get-DbcConfigValue policy.storage.backuppath)) {
                $backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
            }
            else {
                $backuppath = Get-DbcConfigValue policy.storage.backuppath
            }

            It "can access backup path ($backuppath) on $psitem" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $backuppath | Should -BeTrue -Because 'SQL Service Account needs to have access to the backup path to backup your databases'
            }
        }
    }
}

Describe "Dedicated Administrator Connection" -Tags DAC, $filename {
    $dac = Get-DbcConfigValue policy.dacallowed
    (Get-SqlInstance).ForEach{
        Context "Testing Dedicated Administrator Connection on $psitem" {
            It "DAC is set to $dac on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should -Be $dac -Because 'This is the setting that you have chosen for DAC connections'
            }
        }
    }
}

Describe "Network Latency" -Tags NetworkLatency, Connectivity, $filename {
    $max = Get-DbcConfigValue policy.network.latencymaxms
    (Get-SqlInstance).ForEach{
        Context "Testing Network Latency on $psitem" {
            @(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
                It "network latency Should Be less than $max ms on $($psitem.InstanceName)" {
                    $psitem.Average.TotalMilliseconds | Should -BeLessThan $max -Because 'You dont want to be waiting on the network'
                }
            }
        }
    }
}

Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, $filename {
    (Get-SqlInstance).ForEach{
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
    (Get-SqlInstance).ForEach{
        Context "Testing Max Memory on $psitem" {
            It "Max Memory setting Should Be correct on $psitem" {
                @(Test-DbaMaxMemory -SqlInstance $psitem).ForEach{
                    $psitem.SqlMaxMB | Should -BeLessThan ($psitem.RecommendedMB + 379) -Because 'You dont want SQL taking all of the RAMs'
                }
            }
        }
    }
}

Describe "Orphaned Files" -Tags OrphanedFile, $filename {
    (Get-SqlInstance).ForEach{
        Context "Checking for orphaned database files on $psitem" {
            It "$psitem doesn't have orphan files" {
                (Find-DbaOrphanedFile -SqlInstance $psitem).Count | Should -Be 0 -Because 'You dont want any orphaned files - Use Find-DbaOrphanedFiles to locate them'
            }
        }
    }
}

Describe "SQL + Windows names match" -Tags ServerNameMatch, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing instance name matches Windows name for $psitem" {
            It "$psitem doesn't require rename" {
                (Test-DbaServerName -SqlInstance $psitem).RenameRequired | Should -BeFalse -Because 'SQL and Windows should agree on the server name'
            }
        }
    }
}

Describe "SQL Memory Dumps" -Tags MemoryDump, $filename {
    $maxdumps = Get-DbcConfigValue -Name policy.dump.maxcount
    (Get-SqlInstance).ForEach{
        Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
            $count = (Get-DbaDump -SqlInstance $psitem).Count
            It "dump count of $count is less than or equal to the $maxdumps dumps on $psitem" {
                $Count | Should -BeLessOrEqual $maxdumps -Because 'The number of SQL Memory dumps should be less than this'
            }
        }
    }
}

Describe "Supported Build" -Tags SupportedBuild, DISA, $filename {
    $BuildWarning = Get-DbcConfigValue -Name  policy.build.warningwindow
    (Get-SqlInstance).ForEach{
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
    (Get-SqlInstance).ForEach{
        Context "Checking that sa login has been renamed on $psitem" {
            $results = Get-DbaLogin -SqlInstance $psitem -Login sa
            It "sa login does not exist on $psitem" {
                $results | Should -Be $null -Because 'Renaming the sa account is a requirement'
            }
        }
    }
}

Describe "Default Backup Compression" -Tags DefaultBackupCompression, $filename {
    $defaultbackupcompreesion = Get-DbcConfigValue policy.backup.defaultbackupcompreesion
    (Get-SqlInstance).ForEach{
        Context "Testing Default Backup Compression on $psitem" {
            It "Default Backup Compression is set to $defaultbackupcompreesion on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should -Be $defaultbackupcompreesion -Because 'The default backup compression should be set correctly'
            }
        }
    }
}

Describe "Stopped XE Sessions" -Tags XESessionStopped, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue policy.xevent.requiredstoppedsession
    (Get-SqlInstance).ForEach{
        Context "Checking sessions on $psitem" {
            @(Get-DbaXESession -SqlInstance $psitem).ForEach{
                if ($psitem.Name -in $xesession) {
                    It "session $($psitem.Name) should not be running on $($psitem.InstanceName)" {
                        $psitem.Status | Should -Be "Stopped" -Because 'This session should be stopped'
                    }
                }
            }
        }
    }
}

Describe "Running XE Sessions" -Tags XESessionRunning, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue policy.xevent.requiredrunningsession
    (Get-SqlInstance).ForEach{
        Context "Checking running sessions on $psitem" {
            @(Get-DbaXESession -SqlInstance $psitem).ForEach{
                if ($psitem.Name -in $xesession) {
                    It "session $($psitem.Name) Should Be running on $($psitem.InstanceName)" {
                        $psitem.Status | Should -Be "Running" -Because 'This session should be running'
                    }
                }
            }
        }
    }
}

Describe "XE Sessions Running Allowed" -Tags XESessionRunningAllowed, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue policy.xevent.validrunningsession
    (Get-SqlInstance).ForEach{
        Context "Checking sessions on $psitem" {
            @(Get-DbaXESession -SqlInstance $psitem).ForEach{
                if ($psitem.Name -notin $xesession) {
                    It "session $($psitem.Name) should not be running on $($psitem.InstanceName)" {
                        $psitem.Status | Should -Be "Stopped" -Because 'These sessions should not be running'
                    }
                }
            }
        }
    }
}

Describe "OLE Automation" -Tags OLEAutomation, $filename {
    $OLEAutomation = Get-DbcConfigValue policy.oleautomation
    (Get-SqlInstance).ForEach{
        Context "Testing OLE Automation on $psitem" {
            It "OLE Automation is set to $OLEAutomation on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'OleAutomationProceduresEnabled').ConfiguredValue -eq 1 | Should -Be $OLEAutomation -Because 'This is the required setting'
            }
        }
    }
}

Describe "sp_whoisactive is Installed" -Tags WhoIsActiveInstalled, $filename {
    $db = Get-DbcConfigValue policy.whoisactive.database
    (Get-SqlInstance).ForEach{
        Context "Testing WhoIsActive exists on $psitem" {
            It "WhoIsActive should exists on $db on $psitem" {
                (Get-DbaSqlModule -SqlInstance $psitem -Database $db -Type StoredProcedure | Where-Object name -eq "sp_WhoIsActive") | Should -Not -Be $Null -Because 'The sp_WhoIsActive stored procedure should be installed'
            }
        }
    }
}

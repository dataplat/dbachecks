$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing SQL Engine Service on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem -Type Engine).ForEach{
                It "SQL agent service account should be running on $($psitem.InstanceName)" {
                    $psitem.State | Should be "Running"
                }
                It "SQL agent service account should have a start mode of Automatic on $($psitem.InstanceName)" {
                    $psitem.StartMode | Should be "Automatic"
                }
            }
        }
    }
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename {
    (Get-ComputerName).ForEach{
        Context "Testing SQL Browser Service on $psitem" {
            @(Get-DbaSqlService -ComputerName $psitem).ForEach{
                It "SQL browser service on $($psitem.InstanceName) should be Stopped unless multiple instances are installed" {
                    if (($psitem.ServiceType -eq "Engine").count -eq 1) {
                        $psitem.State | Should be "Stopped"
                    }
                    else {
                        $psitem.State | Should be "Running"
                    }
                }
                It "SQL browser service startmode should be Disabled on $($psitem.InstanceName) unless multiple instances are installed" {
                    if (($psitem.ServiceType -eq "Engine").count -eq 1) {
                        $psitem.StartMode | Should be "Disabled"
                    }
                    else {
                        $psitem.StartMode | Should be "Automatic"
                    }
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
                $TempDBTest[0].CurrentSetting | Should Be $TempDBTest[0].Recommended
            }
            It "should have $($TempDBTest[1].Recommended) TempDB Files on $($TempDBTest[1].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.tempdbfileCount) {
                $TempDBTest[1].CurrentSetting | Should Be $TempDBTest[1].Recommended
            }
            It "should not have TempDB Files autogrowth set to percent on $($TempDBTest[2].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $TempDBTest[2].CurrentSetting | Should Be $TempDBTest[2].Recommended
            }
            It "should not have TempDB Files on the C Drive on $($TempDBTest[3].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $TempDBTest[3].CurrentSetting | Should Be $TempDBTest[3].Recommended
            }
            It "should not have TempDB Files with MaxSize Set on $($TempDBTest[4].SqlInstance)" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
                $TempDBTest[4].CurrentSetting | Should Be $TempDBTest[4].Recommended
            }
        }
    }
}

Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Ad Hoc Workload Optimization on $psitem" {
            It "$psitem Should be Optimised for Ad Hoc workloads" {
                @(Test-DbaOptimizeForAdHoc -SqlInstance $psitem).ForEach{
                    $psitem.CurrentOptimizeAdHoc | Should be $psitem.RecommendedOptimizeAdHoc
                }
            }
        }
    }
}

Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Backup Path Access on $psitem" {
            if (-not (Get-DbcConfigValue policy.backuppath)) {
                $backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
            }
            else {
                $backuppath = Get-DbcConfigValue policy.backuppath
            }

            It "can access backup path ($backuppath) on $psitem" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $backuppath | Should be $true
            }
        }
    }
}

Describe "Dedicated Administrator Connection" -Tags DAC, $filename {
    $dac = Get-DbcConfigValue policy.dacallowed
    (Get-SqlInstance).ForEach{
        Context "Testing Dedicated Administrator Connection on $psitem" {
            It "DAC is set to $dac on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should Be $dac
            }
        }
    }
}

Describe "Network Latency" -Tags NetworkLatency, Connectivity, $filename {
    $max = Get-DbcConfigValue policy.networklatencymsmax
    (Get-SqlInstance).ForEach{
        Context "Testing Network Latency on $psitem" {
            @(Test-DbaNetworkLatency -SqlInstance $psitem).ForEach{
                It "network latency should be less than $max ms on $($psitem.InstanceName)" {
                    $psitem.Average.TotalMilliseconds | Should BeLessThan $max
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
                    $psitem.Connectivity | Should be $true
                }
            }
        }
    }
}

Describe "Max Memory" -Tags MaxMemory, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Max Memory on $psitem" {
            It "Max Memory setting should be correct on $psitem" {
                @(Test-DbaMaxMemory -SqlInstance $psitem).ForEach{
                    $psitem.SqlMaxMB | Should BeLessThan ($psitem.RecommendedMB + 379)
                }
            }
        }
    }
}

Describe "Orphaned Files" -Tags OrphanedFile, $filename {
    (Get-SqlInstance).ForEach{
        Context "Checking for orphaned database files on $psitem" {
            It "$psitem doesn't have orphan files" {
                (Find-DbaOrphanedFile -SqlInstance $psitem).Count | Should Be 0
            }
        }
    }
}

Describe "SQL + Windows names match" -Tags ServerNameMatch, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing instance name matches Windows name for $psitem" {
            It "$psitem doesn't require rename" {
                (Test-DbaServerName -SqlInstance $psitem).RenameRequired | Should Be $false
            }
        }
    }
}

Describe "SQL Memory Dumps" -Tags MemoryDump, $filename {
    $maxdumps = Get-DbcConfigValue -Name policy.maxdumpcount
    (Get-SqlInstance).ForEach{
        Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
            $count = (Get-DbaDump -SqlInstance $psitem).Count
            It "dump count of $count does not exceed $maxdumps on $psitem" {
                $count -le $maxdumps | Should Be $true
            }
        }
    }
}

Describe "Supported Build" -Tags SupportedBuild, DISA, $filename {
    (Get-SqlInstance).ForEach{
        Context "Checking that build is still supportedby Microsoft for $psitem" {
            $results = Get-DbaSqlBuildReference -SqlInstance $psitem
            It "$($results.Build) on $psitem is still suported" {
                $results.SupportedUntil -ge (Get-Date) | Should Be $true
            }
        }
    }
}

Describe "SA Login Renamed" -Tags SaRenamed, DISA, $filename {
    (Get-SqlInstance).ForEach{
        Context "Checking that sa login has been renamed on $psitem" {
            $results = Get-DbaLogin -SqlInstance $psitem -Login sa
            It "returns no results on $psitem" {
                $results -eq $null | Should Be $true
            }
        }
    }
}

Describe "Default Backup Compression" -Tags DefaultBackupCompression, $filename {
    $defaultbackupcompreesion = Get-DbcConfigValue policy.defaultbackupcompreesion
    (Get-SqlInstance).ForEach{
        Context "Testing Default Backup Compression on $psitem" {
            It "Default Backup Compression is set to $defaultbackupcompreesion on $psitem" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should Be $defaultbackupcompreesion
            }
        }
    }
}

Describe "Stopped XE Sessions" -Tags XESessionStopped, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue xevent.requiredstoppedsession
    (Get-SqlInstance).ForEach{
        Context "Checking sessions on $psitem" {
            @(Get-DbaXESession -SqlInstance $psitem).ForEach{
                if ($psitem.Name -in $xesession) {
                    It "session $($psitem.Name) should not be running on $($psitem.InstanceName)" {
                        $psitem.Status | Should Be "Stopped"
                    }
                }
            }
        }
    }
}

Describe "Running XE Sessions" -Tags XESessionRunning, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue xevent.requiredrunningsession
    (Get-SqlInstance).ForEach{
        Context "Checking running sessions on $psitem" {
            @(Get-DbaXESession -SqlInstance $psitem).ForEach{
                if ($psitem.Name -in $xesession) {
                    It "session $($psitem.Name) should be running on $($psitem.InstanceName)" {
                        $psitem.Status | Should Be "Running"
                    }
                }
            }
        }
    }
}

Describe "XE Sessions Running Allowed" -Tags XESessionRunningAllowed, ExtendedEvent, $filename {
    $xesession = Get-DbcConfigValue xevent.validrunningsession
    (Get-SqlInstance).ForEach{
        Context "Checking sessions on $psitem" {
            @(Get-DbaXESession -SqlInstance $psitem).ForEach{
                if ($psitem.Name -notin $xesession) {
                    It "session $($psitem.Name) should not be running on $($psitem.InstanceName)" {
                        $psitem.Status | Should Be "Stopped"
                    }
                }
            }
        }
    }
}

Describe "Trace 3226" -Tags TraceFlag3226, TraceFlags, $filename {
	$trace3226 = Get-DbcConfigValue policy.Trace3226
	(Get-SqlInstance).ForEach{
		Context "Testing Trace flag 3226 on $psitem"{
            It "Trace flag 3226 is set at the instance level $trace3226 on $psitem" {
                $results = Get-DbaTraceFlag $psitem | Where-Object {$_.TraceFlag -eq "3226"} | Measure-Object
                $results.count -gt 0 | Should be $trace3226
            }
		}
	}
}

Describe "Trace 2371" -Tags TraceFlag2371, TraceFlags, $filename {
	$trace2371 = Get-DbcConfigValue policy.Trace2371
	(Get-SqlInstance).ForEach{
		Context "Testing Trace flag 2371 on $psitem"{
            It "Trace flag 2371 is set at the instance level $trace2371 on $psitem" {
			    $results = Get-DbaTraceFlag $psitem | Where-Object {$_.TraceFlag -eq "2371"} | Measure-Object
                $results.count -gt 0 -or (Connect-DbaInstance $psitem).VersionMajor -ge 13 | Should be $trace2371                
            }
		}
	}
}
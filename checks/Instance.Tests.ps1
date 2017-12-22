$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "SQL Engine Service" -Tags SqlEngineServiceAccount, ServiceAccount, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing SQL Engine Service on $psitem" {
            $results = Get-DbaSqlService -ComputerName $psitem -Type Engine
            It "SQL agent service account should be running on $psitem" {
                $results.State | Should be "Running"
            }
            It "SQL agent service account should have a start mode of Automatic on $psitem" {
                $results.StartMode | Should be "Automatic"
            }
        }
    }
}

Describe "SQL Browser Service" -Tags SqlBrowserServiceAccount, ServiceAccount, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing SQL Browser Service on $psitem" {
            $results = Get-DbaSqlService -ComputerName $psitem
            It "SQL browser service should be Stopped on $psitem unless multiple instances are installed" {
                if (($r.ServiceType -eq "Engine").count -eq 1) {
                    $results.State | Should be "Stopped"
                }
                else {
                    $results.State | Should be "Running"
                }
            }
            It "SQL browser service startmode should be Disabled on $psitem unless multiple instances are installed" {
                if (($r.ServiceType -eq "Engine").count -eq 1) {
                    $results.StartMode | Should be "Disabled"
                }
                else {
                    $results.StartMode | Should be "Automatic"
                }
            }
        }
    }
}

Describe "TempDB Configuration" -Tags TempDbConfiguration, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing TempDB Configuration on $psitem" {
            $tempdbtests = Test-DBATempDbConfiguration -SqlServer $psitem
            It "$psitem should have TF118 enabled" -Skip:$($Config.TempDb.Skip118) {
                $tempdbtests[0].CurrentSetting | Should Be $tempdbtests[0].Recommended
            }
            It "$psitem should have $($tempdbtests[1].Recommended) TempDB Files" -Skip:(Get-DbcConfigValue -Name skip.TempDb118) {
                $tempdbtests[1].CurrentSetting | Should Be $tempdbtests[1].Recommended
            }
            It "$psitem should not have TempDB Files autogrowth set to percent" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $tempdbtests[2].CurrentSetting | Should Be $tempdbtests[2].Recommended
            }
            It "$psitem should not have TempDB Files on the C Drive" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $tempdbtests[3].CurrentSetting | Should Be $tempdbtests[3].Recommended
            }
            It "$psitem should not have TempDB Files with MaxSize Set" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
                $tempdbtests[4].CurrentSetting | Should Be $tempdbtests[4].Recommended
            }
        }
    }
}

Describe "Ad Hoc Workload Optimization" -Tags AdHocWorkload, $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing Ad Hoc Workload Optimization on $psitem" {
            It "Should be Optimised for Ad Hoc workloads" {
                $Results = Test-DbaOptimizeForAdHoc -SqlInstance $psitem
                $Results.CurrentOptimizeAdHoc | Should be $Results.RecommendedOptimizeAdHoc
            }
        }
    }
}

Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing Backup Path Access on $psitem" {
            if (-not (Get-DbcConfigValue setup.backuppath)) {
                $backuppath = (Get-DbaDefaultPath -SqlInstance $psitem).Backup
            }
            else {
                $backuppath = Get-DbcConfigValue setup.backuppath
            }

            It "$psitem access to the backup path ($backuppath)" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $backuppath | Should be $true
            }

        }
    }

    Describe "Dedicated Administrator Connection" -Tags DAC, $filename {
        $dac = Get-DbcConfigValue policy.dacallowed
            (Get-SqlInstance).ForEach{
				Context "Testing Dedicated Administrator Connection on $psitem" {
                    It "$psitem Should have DAC enabled $dac" {
                        (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1 | Should Be $dac
                    }
                }
            }
        }
    }

    Describe "Network Latency" -Tags NetworkLatency, Connectivity, $filename {
        $max = Get-DbcConfigValue policy.networklatencymsmax
        (Get-SqlInstance).ForEach{
            Context "Testing Network Latency on $psitem" {
                $results = Test-DbaNetworkLatency -SqlInstance $psitem
                It "network latency for $psitem should be less than $max ms" {
                    $results.Average.TotalMilliseconds | Should BeLessThan $max
                }
            }
        }
    }

    Describe "Linked Servers" -Tags LinkedServerConnection, Connectivity, $filename {
        (Get-SqlInstance).ForEach{
            Context "Testing Linked Servers on $psitem" {
                $Results = Test-DbaLinkedServerConnection -SqlInstance $psitem
                $Results.ForEach{
                    It "Linked Server $($psitem.LinkedServerName) Should Be Connectable" {
                        $psitem.Connectivity | Should be $True
                    }
                }
            }
        }
    }

    Describe "Max Memory" -Tags MaxMemory, $filename {
        (Get-SqlInstance).ForEach{
            Context "Testing Max Memory on $PSItem" {
                It "Max Memory setting should be correct" {
                    $Results = Test-DbaMaxMemory -SqlInstance $PSItem
                    $Results.SqlMaxMB | Should BeLessThan ($Results.RecommendedMB + 379)
                }
            }
        }
    }
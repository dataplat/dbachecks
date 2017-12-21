$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing TempDB Configuration' -Tag TempDB, Instance , $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
            $TempDbTests = Test-DBATempDbConfiguration -SqlServer $psitem
            It "$psitem should have TF118 enabled" -Skip:$($Config.TempDb.Skip118) {
                $TempDbTests[0].CurrentSetting | Should Be $TempDbTests[0].Recommended
            }
            It "$psitem should have $($TempDbTests[1].Recommended) TempDB Files" -Skip:(Get-DbcConfigValue -Name skip.TempDb118) {
                $TempDbTests[1].CurrentSetting | Should Be $TempDbTests[1].Recommended
            }
            It "$psitem should not have TempDB Files autogrowth set to percent" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $TempDbTests[2].CurrentSetting | Should Be $TempDbTests[2].Recommended
            }
            It "$psitem should not have TempDB Files on the C Drive" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $TempDbTests[3].CurrentSetting | Should Be $TempDbTests[3].Recommended
            }
            It "$psitem should not have TempDB Files with MaxSize Set" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
                $TempDbTests[4].CurrentSetting | Should Be $TempDbTests[4].Recommended
            }
        }
    }
}

Describe 'Testing Optimise for AdHoc Workloads setting' -Tag AdHoc, Instance , $filename{

    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
            It "Should be Optimised for AdHocworkloads" {
                $Results = Test-DbaOptimizeForAdHoc -SqlInstance $psitem
                $Results.CurrentOptimizeAdHoc | Should be $Results.RecommendedOptimizeAdHoc
            }
        }
    }
}

Describe 'Testing access to backup path' -Tags Storage, DISA, $filename {
	(Get-SqlInstance).ForEach{
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

Describe 'Testing DAC' -Tags DAC, $filename {
    $dac = Get-DbcConfigValue policy.dacallowed
    (Get-SqlInstance).ForEach{
        Context "Testing $psitem" {
			It "$psitem Should have DAC enabled $dac" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1  | Should Be $dac
            }
        }
    }
}

$max = Get-DbcConfigValue policy.networklatencymsmax
Describe 'Testing network latency' -Tags Network, $filename {
	(Get-SqlInstance).ForEach{
		$results = Test-DbaNetworkLatency -SqlInstance $psitem
		It "network latency for $psitem should be less than $max ms" {
			$results.Average.TotalMilliseconds | Should BeLessThan $max
		}
	}
}

Describe 'Testing Linked Servers' -Tag LinkedServer, Instance, $filename {
	(Get-SqlInstance).ForEach{
        Context "Testing $psitem" {
            $Results = Test-DbaLinkedServerConnection -SqlInstance $psitem
            $Results.ForEach{
                It "Linked Server $($psitem.LinkedServerName) Should Be Connectable" {
                    $psitem.Connectivity | Should be $True
                }
            }
        }
    }
}
Describe 'Testing Max Memory' -Tag Memory, Instance, $filename {
	(Get-SqlInstance).ForEach{
        Context "Testing $PSItem" {
            It "Max Memory setting should be correct" {
                $Results = Test-DbaMaxMemory -SqlInstance $PSItem
                $Results.SqlMaxMB | Should BeLessThan ($Results.RecommendedMB + 379)
            }
        }
    }
}

Describe 'Testing Full Recovery Model' -Tags Database, DISA, RecoveryModel, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing $psitem" {
            $results = Get-DbaDbRecoveryModel -SqlInstance $psitem
            foreach ($result in $results) {
                if ($result.Name -ne 'tempdb') {
                    It "$($result.Name) on $psitem should be set to the Full recovery model" {
                        $result.RecoveryModel | Should be (Get-DbcConfigValue policy.recoverymodel)
                    }
                }
            }
        }
    }
}

$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Server.Assertions.ps1

$Tags = Get-CheckInformation -Check $Check -Group Server -AllChecks $AllChecks -ExcludeCheck $ChecksToExclude

@(Get-ComputerName).ForEach{
    $AllServerInfo = Get-AllServerInfo -ComputerName $Psitem -Tags $Tags
    Describe "Server Power Plan Configuration" -Tags PowerPlan, $filename {
        Context "Testing Server Power Plan Configuration on $psitem" {
            It "PowerPlan is High Performance on $psitem" {
                Assert-PowerPlan -AllServerInfo $AllServerInfo
            }       
        }
    }
    Describe "SPNs" -Tags SPN, $filename {
        Context "Testing SPNs on $psitem" {
            $computer = $psitem
            @(Test-DbaSpn -ComputerName $psitem).ForEach{
                It "$computer should have SPN for $($psitem.RequiredSPN) for $($psitem.InstanceServiceAccount)" {
                    $psitem.Error | Should -Be 'None'
                }
            }
        }
    }

    Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, $filename {
        $free = Get-DbcConfigValue policy.diskspace.percentfree
        Context "Testing Disk Space on $psitem" {
            @(Get-DbaDiskSpace -ComputerName $psitem).ForEach{
                It "$($psitem.Name) with $($psitem.PercentFree)% free should be at least $free% free on $($psitem.ComputerName)" {
                    $psitem.PercentFree  | Should -BeGreaterThan $free
                }
            }
        }
    }

    Describe "Ping Computer" -Tags PingComputer, $filename {
        $pingmsmax = Get-DbcConfigValue policy.connection.pingmaxms
        $pingcount = Get-DbcConfigValue policy.connection.pingcount
        $skipping = Get-DbcConfigValue skip.connection.ping
        Context "Testing Ping to $psitem" {
            $results = Test-Connection -Count $pingcount -ComputerName $psitem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ResponseTime
            $avgResponseTime = (($results | Measure-Object -Average).Average) / $pingcount
            It -skip:$skipping "Should have pinged $pingcount times for $psitem" {
                Assert-Ping -AllServerInfo $AllServerInfo -Type Ping
            }
            It -skip:$skipping "Average response time (ms) should Be less than $pingmsmax (ms) for $psitem" {
                $avgResponseTime | Should -BeLessThan $pingmsmax
            }
        }
    }

    Describe "CPUPrioritisation" -Tags CPUPrioritisation, $filename {
        $exclude = Get-DbcConfigValue policy.server.cpuprioritisation
        Context "Testing CPU Prioritisation on $psitem" {
            It "Should have the registry key set correctly for background CPU Prioritisation" -Skip:$exclude {
                Assert-CPUPrioritisation -ComputerName $psitem
            }
        }
    }

    Describe "Disk Allocation Unit" -Tags DiskAllocationUnit, $filename {
        Context "Testing disk allocation unit on $psitem" {
            It "Should be set to 64kb " -Skip:$exclude {
                Assert-DiskAllocationUnit -ComputerName $psitem
            }
        }
    }
}

Describe "Instance Connection" -Tags InstanceConnection, Connectivity, $filename {
    $skipremote = Get-DbcConfigValue skip.connection.remoting
    $skipping = Get-DbcConfigValue skip.connection.ping
    $authscheme = Get-DbcConfigValue policy.connection.authscheme
    @(Get-Instance).ForEach{
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
            It -Skip:$skipremote "$psitem Is PSRemotebale" {
                $Connection.PSRemotingAccessible | Should -BeTrue
            }
        }
    }
}
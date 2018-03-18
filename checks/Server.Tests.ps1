$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Server Power Plan Configuration" -Tags PowerPlan, $filename {
    @(Get-ComputerName).ForEach{
        Context "Testing Server Power Plan Configuration on $psitem" {
            It "PowerPlan is High Performance on $psitem" {
                (Test-DbaPowerPlan -ComputerName $psitem).IsBestPractice | Should -BeTrue
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

Describe "SPNs" -Tags SPN, $filename {
    @(Get-ComputerName).ForEach{
        Context "Testing SPNs on $psitem" {
            $computer = $psitem
            @(Test-DbaSpn -ComputerName $psitem).ForEach{
                It "$computer should have SPN for $($psitem.RequiredSPN) for $($psitem.InstanceServiceAccount)" {
                    $psitem.Error | Should -Be 'None'
                }
            }
        }
    }
}

Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, $filename {
    $free = Get-DbcConfigValue policy.diskspace.percentfree
    @(Get-ComputerName).ForEach{
        Context "Testing Disk Space on $psitem" {
            @(Get-DbaDiskSpace -ComputerName $psitem).ForEach{
                It "$($psitem.Name) with $($psitem.PercentFree)% free should be at least $free% free on $($psitem.ComputerName)" {
                    $psitem.PercentFree  | Should -BeGreaterThan $free
                }
            }
        }
    }
}

Describe "Ping Computer" -Tags PingComputer, $filename {
    $pingmsmax = Get-DbcConfigValue policy.connection.pingmaxms 
    $pingcount = Get-DbcConfigValue policy.connection.pingcount 
    $skipping = Get-DbcConfigValue skip.connection.ping
    @(Get-ComputerName).ForEach{
        Context "Testing Ping to  $psitem" {
            $results = Test-Connection -Count $pingcount -ComputerName $psitem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ResponseTime
            $avgResponseTime = (($results | Measure-Object -Average).Average) / $pingcount
            It -skip:$skipping "Should have pinged $pingcount times for $psitem" {
                $results.Count  | Should -Be $pingcount
            }
            It -skip:$skipping "Average response time (ms) should Be less than $pingmsmax (ms) for $psitem" {
                $avgResponseTime | Should -BeLessThan $pingmsmax 
            }
        }
    }
}
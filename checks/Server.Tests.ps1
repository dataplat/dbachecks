$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Server.Assertions.ps1

# getting the tags that we are using for this file
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
            $computername = $psitem
            @($AllServerInfo.SPNs).ForEach{
                It "$computername should have a SPN $($psitem.RequiredSPN) for $($psitem.InstanceServiceAccount)" {
                    Assert-SPN -SPN $psitem
                }
            }
        }
    }

    Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, $filename {
        $free = Get-DbcConfigValue policy.diskspace.percentfree
        Context "Testing Disk Space on $psitem" {
            @($AllServerInfo.DiskSpace).ForEach{
                It "$($psitem.Name) with $($psitem.PercentFree)% free should be at least $free% free on $($psitem.ComputerName)" {
                    Assert-DiskSpace -Disk $psitem 
                }
            }
        }
    }

    Describe "Ping Computer" -Tags PingComputer, $filename {
        $pingmsmax = Get-DbcConfigValue policy.connection.pingmaxms
        $pingcount = Get-DbcConfigValue policy.connection.pingcount
        $skipping = Get-DbcConfigValue skip.connection.ping
        Context "Testing Ping to $psitem" {
            It -skip:$skipping "Should have pinged $pingcount times for $psitem" {
                Assert-Ping -AllServerInfo $AllServerInfo -Type Ping
            }
            It -skip:$skipping "Average response time (ms) should Be less than $pingmsmax (ms) for $psitem" {
                Assert-Ping -AllServerInfo $AllServerInfo -Type Average
            }
        }
    }

    Describe "CPUPrioritisation" -Tags CPUPrioritisation, $filename {
        $exclude = Get-DbcConfigValue policy.server.cpuprioritisation
        Context "Testing CPU Prioritisation on $psitem" {
            It "Should have the registry key set correctly for background CPU Prioritisation on $psitem" -Skip:$exclude {
                Assert-CPUPrioritisation -ComputerName $psitem
            }
        }
    }

    Describe "Disk Allocation Unit" -Tags DiskAllocationUnit, $filename {
        Context "Testing disk allocation unit on $psitem" {
            $computerName = $psitem
            @($AllServerInfo.DiskAllocation).Where{$psitem.IsSqlDisk -eq $true}.ForEach{
                It "$($Psitem.Name) Should be set to 64kb on $computerName" -Skip:$exclude {
                    Assert-DiskAllocationUnit -DiskAllocationObject $Psitem
                }
            }
        }
    }

    Describe "Local Security Policy Privileges" -Tags LocalSecurityPolicy, $filename {

        $ifi = Get-DbcConfigValue policy.security.ifi
        $lpim = Get-DbcConfigValue policy.security.lpim
        Context "Testing Local Security Policy to $psitem" {
            $lspcomp = $psitem
            @($AllServerInfo.LocalSecurityPolicy).ForEach{
                It "For SQL Service account $($psitem.SQLServiceAccount) IFI Enabled Should be $ifi on $lspcomp" {
                    Assert-Privilege -LocalSecurityPolicy $psitem -Type IFI -IFI $ifi
                }
                It "For SQL Service account $($psitem.SQLServiceAccount) LPIM Enabled Should be $lpim on $lspcomp" {
                    Assert-Privilege -LocalSecurityPolicy $psitem -Type LPIM -LPIM $lpim
                }
            }
        }
    }
}
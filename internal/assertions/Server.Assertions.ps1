<#
This file is used to hold the Assertions for the Server.Tests

It starts with the Get-AllServerInfo which uses all of the unique
 tags that have been passed and gathers the required information
 which can then be used for the assertions.

 The long term aim is to make Get-AllServerInfo as performant as 
 possible
#>
function Get-AllServerInfo {
    # Using the unique tags gather the information required
    # 2018/09/06 - Added PowerPlan Tag - RMS
    Param($ComputerName, $Tags)
    switch ($tags) {
        {$tags -contains 'PowerPlan'} { 
            try {
                $PowerPlan = (Test-DbaPowerPlan -ComputerName $ComputerName -EnableException -WarningVariable PowerWarning -WarningAction SilentlyContinue).IsBestPractice
            }
            catch {
                if ($PowerWarning[1].ToString().Contains('Couldn''t resolve hostname')) {
                    $PowerPlan = 'Could not connect'
                }else{
                    $PowerPlan = 'An Error occured'
                }
            }
        }
        Default {}
    }
     [PSCustomObject]@{
        PowerPlan = $PowerPlan
    }
}

function Assert-CPUPrioritisation {
    Param(
        [string]$ComputerName
    )
    function Get-RemoteRegistryValue {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
        $RegSubKey = $Reg.OpenSubKey("System\CurrentControlSet\Control\PriorityControl")
        $RegSubKey.GetValue('Win32PrioritySeparation')
    }

    Get-RemoteRegistryValue | Should -BeExactly 24 -Because "a server should prioritise CPU to it's Services, not to the user experience when someone logs on"
}

function Assert-DiskAllocationUnit {
    param(
        [string]$ComputerName
    )
    (Test-DbaDiskAllocation -ComputerName $ComputerName).ForEach{
        $PSItem.isbestpractice | Should -BeTrue -Because "SQL Server performance will be better when accessing data from a disk that is formatted with 64Kb block allocation unit"
    }
}

function Assert-PowerPlan {
    Param($AllServerInfo)
            $AllServerInfo.PowerPlan | Should -Be 'True' -Because "You want your SQL Server to not be throttled by the Power Plan settings - See https://support.microsoft.com/en-us/help/2207548/slow-performance-on-windows-server-when-using-the-balanced-power-plan"   
}

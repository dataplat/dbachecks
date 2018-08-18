function Get-AllServerInfo {
    Param($ComputerName, $Tags)
     [PSCustomObject]@{
        PowerPlan = Test-DbaPowerPlan -ComputerName $psitem -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
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
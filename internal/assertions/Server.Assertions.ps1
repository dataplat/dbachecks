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
    # 2018/09/04 - Added PowerPlan Tag - RMS
    # 2018/09/06 - Added more Tags - RMS
    Param($ComputerName, $Tags)
    $There = $true
    switch ($tags) {
        {$tags -contains 'PingComputer'} { 
            if ($There) {
                try {
                    $pingcount = Get-DbcConfigValue policy.connection.pingcount
                    $PingComputer = Test-Connection -Count $pingcount -ComputerName $ComputerName -ErrorAction Stop
                }
                catch {
                    $There = $false
                    $PingComputer = [PSCustomObject] @{
                        Count        = -1
                        ResponseTime = 50000000
                    } 
                }
            }
            else {
                $PingComputer = [PSCustomObject] @{
                    Count        = -1
                    ResponseTime = 50000000
                } 
            }
        }
        {$tags -contains 'DiskAllocationUnit'} { 
            if ($There) {
                try {
                    $DiskAllocation = Test-DbaDiskAllocation -ComputerName $ComputerName -EnableException -WarningAction SilentlyContinue -WarningVariable DiskAllocationWarning
                }
                catch {
                    $There = $false
                    $DiskAllocation = [PSCustomObject]@{
                        Name           = '? '
                        isbestpractice = $false
                        IsSqlDisk      = $true
                    } 
                }
            }
            else {
                $DiskAllocation = [PSCustomObject]@{
                    Name           = '? '
                    isbestpractice = $false
                    IsSqlDisk      = $true
                } 
            }
        }
        {$tags -contains 'PowerPlan'} { 
            if ($There) {
                try {
                    $PowerPlan = (Test-DbaPowerPlan -ComputerName $ComputerName -EnableException -WarningVariable PowerWarning -WarningAction SilentlyContinue).IsBestPractice
                }
                catch {
                    $There = $false
                    if ($PowerWarning) {
                        if ($PowerWarning[1].ToString().Contains('Couldn''t resolve hostname')) {
                            $PowerPlan = 'Could not connect'
                        }
                    }
                    else {
                        $PowerPlan = 'An Error occurred'
                    }
                }
            }
            else {
                $PowerPlan = 'An Error occurred'
            }
        }
        {$Tags -contains 'SPN'} {
            if ($There) {
                try {
                    $SPNs = Test-DbaSpn -ComputerName $ComputerName -EnableException -WarningVariable SPNWarning -WarningAction SilentlyContinue
                    if ($SPNWarning) {
                        if ($SPNWarning[1].ToString().Contains('Cannot resolve IP address')) {
                            $There = $false
                            $SPNs = [PSCustomObject]@{
                                RequiredSPN            = 'Dont know the SPN'
                                InstanceServiceAccount = 'Dont know the Account'
                                Error                  = 'Could not connect'
                            }
                        }
                        else {
                            $SPNs = [PSCustomObject]@{
                                RequiredSPN            = 'Dont know the SPN'
                                InstanceServiceAccount = 'Dont know the Account'
                                Error                  = 'An Error occurred'
                            }
                        }
                    }
                }
                catch {
                    $SPNs = [PSCustomObject]@{
                        RequiredSPN            = 'Dont know the SPN'
                        InstanceServiceAccount = 'Dont know the Account'
                        Error                  = 'An Error occurred'
                    }
                }
            }
            else {
                $SPNs = [PSCustomObject]@{
                    RequiredSPN            = 'Dont know the SPN'
                    InstanceServiceAccount = 'Dont know the Account'
                    Error                  = 'An Error occurred'
                }
            }
        }
        {$tags -contains 'DiskCapacity'} { 
            if ($There) {
                try {
                    $DiskSpace = Get-DbaDiskSpace -ComputerName $ComputerName -EnableException -WarningVariable DiskSpaceWarning -WarningAction SilentlyContinue
                }
                catch {
                    if ($DiskSpaceWarning) {
                        $There = $false
                        if ($DiskSpaceWarning[1].ToString().Contains('Couldn''t resolve hostname')) {
                            $DiskSpace = [PSCustomObject]@{
                                Name         = 'Do not know the Name'
                                PercentFree  = -1
                                ComputerName = 'Cannot resolve ' + $ComputerName
                            } 
                        }
                    }
                    else {
                        $DiskSpace = [PSCustomObject]@{
                            Name         = 'Do not know the Name'
                            PercentFree  = -1
                            ComputerName = 'An Error occurred ' + $ComputerName
                        } 
                    }
                }
            }
            else {
                $DiskSpace = [PSCustomObject]@{
                    Name         = 'Do not know the Name'
                    PercentFree  = -1
                    ComputerName = 'An Error occurred ' + $ComputerName
                } 
            }
        }
        Default {}
    }
    [PSCustomObject]@{
        PowerPlan      = $PowerPlan
        SPNs           = $SPNs
        DiskSpace      = $DiskSpace
        PingComputer   = $PingComputer
        DiskAllocation = $DiskAllocation 
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
    Param($DiskAllocationObject)
    $DiskAllocationObject.isbestpractice | Should -BeTrue -Because "SQL Server performance will be better when accessing data from a disk that is formatted with 64Kb block allocation unit"
}

function Assert-PowerPlan {
    Param($AllServerInfo)
    $AllServerInfo.PowerPlan | Should -Be 'True' -Because "You want your SQL Server to not be throttled by the Power Plan settings - See https://support.microsoft.com/en-us/help/2207548/slow-performance-on-windows-server-when-using-the-balanced-power-plan"   
}

function Assert-SPN {
    Param($SPN)
    $SPN.Error | Should -Be 'None' -Because "We expect to have a SPN $($SPN.RequiredSPN) for $($SPN.InstanceServiceAccount)"
}

function Assert-DiskSpace {
    Param($Disk)
    $free = Get-DbcConfigValue policy.diskspace.percentfree
    $Disk.PercentFree  | Should -BeGreaterThan $free -Because "You Do not want to run out of space on your disks"
}

function Assert-Ping {
    Param(
        $AllServerInfo,
        $Type
    )
    $pingcount = Get-DbcConfigValue policy.connection.pingcount
    $pingmsmax = Get-DbcConfigValue policy.connection.pingmaxms
    switch ($type) {
        Ping { 
            $AllServerInfo.PingComputer.Count | Should -Be $pingcount -Because "We expect the server to respond to ping"
        }
        Average {
            ($AllServerInfo.PingComputer | Measure-Object -Property ResponseTime -Average).Average / $pingcount | Should -BeLessThan $pingmsmax -Because "We expect the server to respond within $pingmsmax"
        }
        Default {}
    }
}
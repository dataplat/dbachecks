<#
This file is used to hold the Assertions for the Server.Tests

Follow the guidance in Instance.Assertions to add new checks

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
        'PingComputer' {
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
        'DiskAllocationUnit' {
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
        'PowerPlan' {
            if ($There) {
                try {
                    $PowerPlan = (Test-DbaPowerPlan -ComputerName $ComputerName -EnableException -WarningVariable PowerWarning -WarningAction SilentlyContinue).IsBestPractice
                }
                catch {
                    $PowerPlan = $false
                }
            }
            else {
                $PowerPlan = $false
            }
        }
        'SPN' {
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
        'DiskCapacity' {
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
        'NonStandardPort' {
            if ($There) {
                try {
                    $count = (Find-DbaInstance -ComputerName $ComputerName -TCPPort 1433).Count
                    $StandardPortCount = [pscustomobject] @{
                        Count = $count
                    }
                }
                catch {
                    $There = $false
                    $StandardPortCount = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $StandardPortCount = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }
        'ServerProtocol' {
            if ($There) {
                try {
                    $count = (Get-DbaInstanceProtocol -ComputerName $ComputerName | Where-Object {$_.DisplayName -ne "TCP/IP" -and $_.IsEnabled -eq $true}).Count
                    $ServerProtocol = [pscustomobject] @{
                        Count = $count
                    }
                }
                catch {
                    $There = $false
                    $ServerProtocol = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $ServerProtocol = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }
        Default {}
    }
    [PSCustomObject]@{
        PowerPlan         = $PowerPlan
        SPNs              = $SPNs
        DiskSpace         = $DiskSpace
        PingComputer      = $PingComputer
        DiskAllocation    = $DiskAllocation
        StandardPortCount = $StandardPortCount
        ServerProtocol = $ServerProtocol
    }
}

function Assert-CPUPrioritisation {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'ComputerName')]
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
            ($AllServerInfo.PingComputer).Count | Should -Be $pingcount -Because "We expect the server to respond to ping"
        }
        Average {
            if ($IsCoreCLR) {
                ($AllServerInfo.PingComputer | Measure-Object -Property Latency -Average).Average / $pingcount | Should -BeLessThan $pingmsmax -Because "We expect the server to respond within $pingmsmax"
            }
            else {
                ($AllServerInfo.PingComputer | Measure-Object -Property ResponseTime -Average).Average / $pingcount | Should -BeLessThan $pingmsmax -Because "We expect the server to respond within $pingmsmax"
            }
        }
        Default {}
    }
}

function Assert-NonStandardPort {
    Param($AllServerInfo)
    $AllServerInfo.StandardPortCount.count | Should -Be 0 -Because "SQL Server should be configured to not use the standard port of 1433"
}

function Assert-ServerProtocol {
    Param($AllServerInfo)
    $AllServerInfo.ServerProtocol.Count | Should -Be 0 -Because "SQL Server should be configured to use only the TCP/IP protocol"
}

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkbWiF6k6prHEAiMVnoEKu09n
# bPygggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT4os0MlMhlV4UraAiFxccwRITI
# uTANBgkqhkiG9w0BAQEFAASCAQCKNm/SlwW5wDhBqZCVycDNtcEt3+/CdqsxM9AE
# SVOHD31uUTQB/pgUyu0TE2VFlLYKCCbwxy/Rz4jLbbz3z+Dd/dm9wNvYnJc7rEs3
# pj6VOVwCG+hwtneIjEJFF9DmoWgNczpuuDriHo6KsLZYX33t0PRpDpUsKq7WTXS9
# YAm7zTvSPJnZhgBbDAC8QrGfngE+iaJu+OwquKikbgH5DsvBgGSkOsgaPztAtqjR
# SEDeN3OGT5BsJKAh8qw8nezZXvYjd0ffsNEMNro/hN8SbTlR1kMm9NaUKyrTS48A
# wpRxkz3cFtkEH5ql8BZTH3Nj4GsDrK40mCE2+1TKcboajhKM
# SIG # End signature block

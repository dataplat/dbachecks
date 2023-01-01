$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot/../internal/assertions/Server.Assertions.ps1

# follow the guidance in Instance.Assertions to add new checks

$Tags = Get-CheckInformation -Check $Check -Group Server -AllChecks $AllChecks -ExcludeCheck $ChecksToExclude
if($IsLinux){
Write-PSFMessage "We cannot run any of the Server tests from linux at the moment" -Level Warning
Return
}
@(Get-ComputerName).ForEach{
    $AllServerInfo = Get-AllServerInfo -ComputerName $Psitem -Tags $Tags
    Describe "Server Power Plan Configuration" -Tags PowerPlan, Medium, $filename {
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
                It "There should be an SPN $($psitem.RequiredSPN) for $($psitem.InstanceServiceAccount) on $computername" {
                    Assert-SPN -SPN $psitem
                }
            }
        }
    }

    Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, Varied, $filename {
        $free = Get-DbcConfigValue policy.diskspace.percentfree
        Context "Testing Disk Space on $psitem" {
            @($AllServerInfo.DiskSpace).ForEach{
                It "$($psitem.Name) with $($psitem.PercentFree)% free should be at least $free% free on $($psitem.ComputerName)" {
                    Assert-DiskSpace -Disk $psitem
                }
            }
        }
    }

    Describe "Ping Computer" -Tags PingComputer, Varied, $filename {
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

    Describe "CPUPrioritisation" -Tags CPUPrioritisation, Medium, $filename {
        $exclude = Get-DbcConfigValue policy.server.cpuprioritisation
        Context "Testing CPU Prioritisation on $psitem" {
            It "Should have the registry key set correctly for background CPU Prioritisation on $psitem" -Skip:$exclude {
                Assert-CPUPrioritisation -ComputerName $psitem
            }
        }
    }

    Describe "Disk Allocation Unit" -Tags DiskAllocationUnit, Medium, $filename {
        if($IsCoreCLR){
            Context "Testing disk allocation unit on $psitem" {
                It "Can't run this check on Core on $psitem" -Skip {
                    $true | Should -BeTrue
                }
            }
        }
        else {
            Context "Testing disk allocation unit on $psitem" {
                $computerName = $psitem
                $excludedisks = Get-DbcConfigValue policy.server.excludeDiskAllocationUnit
                @($AllServerInfo.DiskAllocation).Where{$psitem.IsSqlDisk -eq $true}.ForEach{
                    if($Psitem.Name -in $excludedisks){
                        $exclude = $true
                    }
                    else {
                        $exclude = $false
                    }
                    It "$($Psitem.Name) Should be set to 64kb on $computerName" -Skip:$exclude {
                        Assert-DiskAllocationUnit -DiskAllocationObject $Psitem
                    }
                }
            }
        }
    }

    Describe "Non Standard Port" -Tags NonStandardPort, Medium, CIS, $filename {
        $skip = Get-DbcConfigValue skip.security.nonstandardport
        Context "Checking SQL Server ports on $psitem" {
            It  "No SQL Server Instances should be configured with port 1433 on $psitem" -skip:$skip {
                Assert-NonStandardPort -AllServerInfo $AllServerInfo
            }
        }
    }

    Describe "Server Protocols" -Tags ServerProtocol, Medium, CIS, $filename {
        $skip = Get-DbcConfigValue skip.security.serverprotocol
        Context "Checking SQL Server protocols on $psitem" {
            It  "All SQL Server Instances should be configured to run only TCP/IP protocol on $psitem" -skip:$skip {
                Assert-ServerProtocol -AllServerInfo $AllServerInfo
            }
        }
    }

}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4VzG8Um6bNQuBBJDVJTixLoH
# c6GgggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQLrVHq2xWVeT/Yis0CW7DFOnrz
# 3TANBgkqhkiG9w0BAQEFAASCAQBa4ar9/SNGWCbUjfixhB09tP8BgiYT+cVmfouo
# VqnGmvLgY4FyzP9fDdu8lAFqGDXWEvX1WLHQ8Er0YQwAnqLzAkZ574G/JLkm3AYe
# Kzmz45DiYWkXDwAUIc9blMY1f3y99sRYbY2ZCAyDnIdzb5hS2iL0jwLO/tI/3exn
# sDGLRhdApejAphzoLOLiG4lgCLXQgXcebiQ9riqgpna/i4YhR5eeNhHirWRkY0WJ
# baiw/YXViFXMC7YpNQrZsPntebw929RtRmwkCGmdwggDgSsBUDYUHuZbrpn5Vs4r
# ifMN8tXG6d2PoD2g0ApF4YHEZGS/nGGolgBzEE/GkPW4z+RQ
# SIG # End signature block

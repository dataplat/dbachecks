Remove-Module dbachecks -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"

. "$PSScriptRoot/../../internal/functions/Get-CheckFile.ps1"

Describe "Testing Get-CheckFile function" {
    Mock Get-ChildItem {
        return @(
            @{ Name = "One.Tests.ps1"; FullName = "C:\Checks\One.Tests.ps1" },
            @{ Name = "Two.Tests.ps1"; FullName = "C:\Checks\Two.Tests.ps1" },
            @{ Name = "Three.Tests.ps1"; FullName = "C:\Checks\Three.Tests.ps1" }
        )
    } -ParameterFilter { $Path }

    Mock Get-Content {
        return "
# some comments to start with

Describe `"First fake check`" -Tags FirstCheck {
    Context `"Some context`" {
    }
}

Describe `"Second fake check`" -Tags SecondCheck, `$filename {
    Context `"Some context`" {
    }
}

Describe `"Third fake check`" -Tags ThirdCheck, `$filename {
    Context `"Some context`" {
    }
}
        ".Split([Environment]::NewLine)
    } -ParameterFilter { $Path -eq "C:\Checks\One.Tests.ps1" }

    Mock Get-Content {
        return "
`$filename = `$MyInvocation.MyCommand.Name.Replace(`".Tests.ps1`", `"`")

Describe `"Fourth fake check`" -Tags FourthCheck, CommonTag, `$filename {
    Context `"Some context`" {
    }
}

Describe `"Fifth fake check`" -Tags FifthCheck,CommonTag,`$filename {
    Context `"Some context`" {
    }
}

# some comments at the end of a file, perhaps a function definition
function Get-MeSomeStuff {
    param([string]`$whatToGet)
    process { }
}
        ".Split([Environment]::NewLine)
    } -ParameterFilter { $Path -eq "C:\Checks\Two.Tests.ps1" }

    Mock Get-Content {
        return "
Describe `"Sixth fake check`" -Tags `"SixthCheck`" {
    Context `"Some context`" {
    }
}
        ".Split([Environment]::NewLine)
    } -ParameterFilter { $Path -eq "C:\Checks\Three.Tests.ps1" }

    Context "Testing with files matching by name" {
        $cases = @(
            @{ CheckValue = "One"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "Two"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "Three"; MatchingFile = "C:\Checks\Three.Tests.ps1" }
        )

        It "<MatchingFile> is found when Check is <CheckValue>" -TestCases $cases {
            param([String]$CheckValue, [String]$MatchingFile)
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check $CheckValue)
            $result.Count | Should -Be 1 -Because "we expect exactly one file"
            $result[0] | Should -Be $MatchingFile -Because "we expect specific file"
        }

        It "When two files match, both should be returned" {
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check One,three)
            $result.Count | Should -Be 2 -Because "we expect exactly two files, one and three"
        }
    }

    Context "Testing with files matching by tag" {
        $cases = @(
            @{ CheckValue = "FirstCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "SecondCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "ThirdCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "FourthCheck"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "FifthCheck"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "SixthCheck"; MatchingFile = "C:\Checks\Three.Tests.ps1" }
        )

        It "<MatchingFile> is found when Check is <CheckValue>" -TestCases $cases {
            param([String]$CheckValue, [String]$MatchingFile)
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check $CheckValue)
            $result.Count | Should -Be 1 -Because "we expect exactly one file"
        }

        It "When two files match, both should be returned" {
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check SecondCheck,SixthCheck)
            $result.Count | Should -Be 2 -Because "we expect exactly two files, one and three"
        }
    }

    Context "Testing to make sure duplicates are not returned" {
        $cases = @(
            @{ CheckValue = "One,FirstCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "One,FirstCheck,SecondCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "Two,FourthCheck,InvalidCheck"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "Three,Three,Three"; MatchingFile = "C:\Checks\Three.Tests.ps1" }
        )

        It "<MatchingFile> is found when Check is <CheckValue>" -TestCases $cases {
            param([String]$CheckValue, [String]$MatchingFile)
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check $CheckValue.Split(","))
            $result.Count | Should -Be 1 -Because "we expect exactly one file"
        }
    }
    # test for duplicates


    Context "Testing things that don't match" {
        It "If there is no match, no file should be returned" {
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check "NotMatchingAnything")
            $result.Count | Should -Be 0 -Because "we don't expect any matches to NotMatchingAnything"
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEvVWSy+gQvt0tsmQfwVbN135
# wU+gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRTTyU4WE6SB0PPxqULWt3QOzSe
# vDANBgkqhkiG9w0BAQEFAASCAQAcVYWr9PB+SwhN9enLdr2/knqP/NvEi7cId6bK
# luTaPcx+JeM0Hwjk15Ct4ilpoVq321ITl9CmCZLGc6c+OC0F6PrAiWsf40LQX3h2
# ytNN0oHDZTlw2EwO83zXwnFVPR1QjyyD+S7A6sN+Vx0ft5oRFF8pZPdK1STZB/h3
# 80TDP5y2MyeAV9DXfu5NXCtElYiRxwWXzHwQU9CNn2MBEyIVWXo9D7/dxt+AxJ6Z
# e+ClrTCh8vwEvSgrpJ5Oa3bH0oVFg6u03oavCe/iWMm/oMHuzjLjdTvDE/PpM2Wh
# FkZhF5aifj++Ptxpv0I4HifhX5RMlUT/mX5qLpJeplVY9Yes
# SIG # End signature block

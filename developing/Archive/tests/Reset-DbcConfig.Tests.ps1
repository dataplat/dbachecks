[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Justification='because rightnow I cant be bothered to look at it')]
Param()
$testSettingsDefinition = '
# config needed for testing
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
'

Invoke-Expression $testSettingsDefinition

Describe "Testing Reset-DbcConfig" {
    InModuleScope -Module dbachecks {
        Mock Invoke-ConfigurationScript {
            Invoke-Expression '

            # config needed for testing
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            '
        }

        It "Resetting specific setting works" {
            Set-DbcConfig -Name testing.samplesettingforunittest.a -Value "newvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.a) | Should -Be "newvalue"
            Reset-DbcConfig -Name testing.samplesettingforunittest.a
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.a) | Should -Be "DefaultValueA"
        }

        It "Resetting specific setting doesn't change anything else" {
            Set-DbcConfig -Name testing.samplesettingforunittest.a -Value "newvalue"
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig -Name testing.samplesettingforunittest.a
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.a) | Should -Be "DefaultValueA"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
        }

        It "Resetting with wildcard resets all matching settings" {
            Set-DbcConfig -Name testing.samplesettingforunittest.group.a -Value "newvalue1"
            Set-DbcConfig -Name testing.samplesettingforunittest.group.b -Value "newvalue2"
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "newvalue1"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "newvalue2"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig -Name "testing.samplesettingforunittest.group.*"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "DefaultValueA"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "DefaultValueB"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
        }

        It "Resetting with wildcard resets only matching settings" {
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig -Name testing.samplesettingforunittest.group.*
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
        }

        Mock Get-DbcConfig {
            param([string]$Name = "*")
            process {
                $results = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values |
                    Where-Object { ($_.Name.startswith("testing.samplesettingforunittest.")) -and ($_.Name -like $Name) -and ($_.Module -like "dbachecks") } |
                    Sort-Object Module, Name
                return $results | Select-Object Name, Value, Description
            }
        }

        It "Resetting all resets really all" {
            Set-DbcConfig -Name testing.samplesettingforunittest.group.a -Value "newvalue1"
            Set-DbcConfig -Name testing.samplesettingforunittest.group.b -Value "newvalue2"
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "newvalue1"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "newvalue2"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "DefaultValueA"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "DefaultValueB"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "DefaultValueB"
        }
    }
}

# cleanup, we don't want those test configuration options left in the system
# the cleanup from within AfterAll did not work, so it is here
Reset-DbcConfig -Name testing.samplesettingforunittest.a
Reset-DbcConfig -Name testing.samplesettingforunittest.b
Reset-DbcConfig -Name testing.samplesettingforunittest.group.a
Reset-DbcConfig -Name testing.samplesettingforunittest.group.b

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3hbO6CI8W/M1qcw++tNBCLs0
# vnOgggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSXgbRjet+5yJGfXYhbhMNZOBK2
# jzANBgkqhkiG9w0BAQEFAASCAQAzbYMqyxH8pyY80OhG5yhxH1F0G1YABQR+agNM
# ZDlwgakLEornYun9zdbxFOI4e3S3PiK3upnN8Cf0tDOCETqgS6Dmkj6SFPfXoGn+
# 2mWGtQjZjpD3mrO6s2YgvWozshBP1o5tJEL0S/JrEeXIqfo8aM9TEjIC8lcLMzSl
# XYbBsja49DYbVMqEXDoWoGqF/mErfnSoA6aNJiY8Zw2quN+occ0RpSycTG3iOeLd
# t/bdzOSB5qfAGuY/eSJ9ir6ApAAsXyOsjTqJihU9zpcVYzdRmi8ps4OPbFT0xEwD
# uhdTxdncViT4yprsk1mKg8ESh5q3p2gEsRayDWOu9ybkrTtJ
# SIG # End signature block

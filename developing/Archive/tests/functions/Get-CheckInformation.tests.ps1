$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path
Remove-Module dbachecks -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"
. $ModuleBase\..\..\internal\functions\Get-CheckInformation.ps1
Describe "Testing Get-CheckInformation" -Tag Get-CheckInformation, Unittest {
    Context "Input" {
        It "Should have a Group Parameter"{
        (Get-Command Get-CheckInformation).Parameters['group'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
        It "Should have a Check Parameter"{
        (Get-Command Get-CheckInformation).Parameters['Check'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
        It "Should have a AllChecks Parameter"{
        (Get-Command Get-CheckInformation).Parameters['AllChecks'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
        It "Should have a ExcludeCheck Parameter"{
        (Get-Command Get-CheckInformation).Parameters['ExcludeCheck'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
    }
    Context "Output" {
        $results = (Get-Content $ModuleBase\get-check.json) -join "`n"| ConvertFrom-Json
        Mock Get-DbcCheck {$results.Where{$_.Group -eq $Group}} -ParameterFilter {$Group -and $Group -in ('Server','Database')}
        It "Should Return All of the checks for a group when the Check equals the group and nothing excluded" {
            Get-CheckInformation -Group Server -Check Server | Should -Be 'PowerPlan', 'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group and not the groupname if nothing is exclueded'
        }
        It "Should Return All of the checks for a group When AllChecks is specified and nothing excluded" {
            Get-CheckInformation -Group Server -AllChecks $true | Should -Be 'PowerPlan', 'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When AllChecks is specified  it should return all of the tags for that group and not the groupname if nothing is excluded'
        }
        It "Should Return one check for a group when one unique tag is specified and nothing excluded" {
            Get-CheckInformation -Group Server -Check SPN | Should -Be  'SPN' -Because 'When a Check is specified it should return just that check'
        }
        It "Should Return two checks for a group when two unique tags are specified and nothing excluded" {
            Get-CheckInformation -Group Server -Check SPN,InstanceConnection | Should -Be  'SPN', 'InstanceConnection' -Because 'When a Check is specified it should return just that check'
        }
        It "Should return a the unique tags for the none-unique tag if a none-unique tag is specified and nothing is excluded"{
            Get-CheckInformation -Group Database -Check LastBackup | Should -Be 'TestLastBackup', 'TestLastBackupVerifyOnly', 'LastFullBackup', 'LastDiffBackup', 'LastLogBackup' -Because 'When a none-unique tag is specified it should return all of the unique tags'
        }
        It "Should return the unique tags for the none-unique tags if two none-unique tags are specified and nothing is excluded"{
            Get-CheckInformation -Group Database -Check LastBackup, MaxDop  | Should -Be 'TestLastBackup', 'TestLastBackupVerifyOnly', 'LastFullBackup', 'LastDiffBackup', 'LastLogBackup', 'MaxDopDatabase', 'MaxDopInstance' -Because 'When a none-unique tag is specified it should return all of the unique tags'
        }
        It "Should Return All of the checks for a group except the excluded ones when the Check equals the group and one check is excluded" {
            Get-CheckInformation -Group Server -Check Server -ExcludeCheck PowerPlan | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded one and not the groupname'
        }
        It "Should Return All of the checks for a group except the excluded ones when the Check equals the group and two checks are excluded" {
            Get-CheckInformation -Group Server -Check Server -ExcludeCheck PowerPlan, CPUPrioritisation | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded ones and not the groupname'
        }
        It "Should Return All of the checks for a group except the excluded ones when AllChecks is specified and one check is excluded" {
            Get-CheckInformation -Group Server -AllChecks $true -ExcludeCheck PowerPlan | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded one and not the groupname'
        }
        It "Should Return All of the checks for a group except the excluded ones when AllChecks is specified and two checks are excluded" {
            Get-CheckInformation -Group Server --AllChecks $true -ExcludeCheck PowerPlan, CPUPrioritisation | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded ones and not the groupname'
        }
        It "Mocks Get-DbcCheck"{
            $assertMockParams = @{
                'CommandName' = 'Get-DbcCheck'
                'Times'       = 10
                'Exactly'     = $true
                }
                Assert-MockCalled @assertMockParams
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/QO1w1t2IvaGC48k1oxNvLTw
# ihugggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT/f5aMZz9Q/1Idd5KPTcOMvSRj
# vzANBgkqhkiG9w0BAQEFAASCAQBig6LSjIhmtoxk9Aaz3f5L7LibHHQf5Nht8xZ1
# ear+piGGYvKCA9oYQ9JgMlKaljsIBDyzLHp+61I3dDx+id/a52tOz382xZY011wv
# mzx5S+fgkUCwQFdF4V93C1T8o+GH6IABFUl97gDyZDiBM+YS6xwr6mQvkAkM6bUh
# 5I4+34W3+PwKZE+BSXV9vwaSlTpM7J5WQ48pkuhx5Y9G9QqKwhTnABj8lyvewjlt
# G6EUcZhgLJVOkFpEJdUz6pcgkYwx/9m7j1uG5MDMOdRS0Nhw8EXoVvZZdvyN9Tdf
# M2y2sO4xvt8ScdWvV0kzZ2PhEUhK793AgcTJWOrRVDc5HNJM
# SIG # End signature block

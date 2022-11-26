# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking Agent.Tests.ps1 checks" -Tag UnitTest, AgentAssertions {
    Context "Checking Database Mail XPs" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance {}
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig = 1; expected = $false; actual = $true}, @{spconfig = 0; expected = $true; actual = $false}
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
            {Assert-DatabaseMailEnabled -SQLInstance 'Dummy' -DatabaseMailEnabled $expected} | Should -Throw -ExpectedMessage "Expected `$$expected, because The Database Mail XPs setting should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig = 0; expected = $false}, @{spconfig = 1; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
            Assert-DatabaseMailEnabled -SQLInstance 'Dummy' -DatabaseMailEnabled $expected
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaSpConfigure'
                'Times'       = 4
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Checking Job History" {
        # if configured value for MaximumHistoryRows is -1 and test value -1 it will pass
        It "Passes Check Correctly with Maximum History Rows disabled (-1)" {
            # Mock to pass
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = -1;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            Assert-JobHistoryRowsDisabled -AgentServer $AgentServer -minimumJobHistoryRows -1
        }
        # if configured value for MaximumHistoryRows is -1 and test value -1 it will pass
        It "Fails Check Correctly with Maximum History Rows disabled (-1) but configured value is 1000" {
            # Mock to fail
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 1000;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            { Assert-JobHistoryRowsDisabled -AgentServer $AgentServer -minimumJobHistoryRows -1 } | Should -Throw -ExpectedMessage "Expected '-1', because Maximum job history configuration should be disabled, but got 1000."
        }
        # if configured value for MaximumHistoryRows is 10000 and test value 10000 it will pass
        It "Passes Check Correctly with Maximum History Rows being 10000" {
            # Mock to pass
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 10000;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            Assert-JobHistoryRows -AgentServer $AgentServer -minimumJobHistoryRows 10000
        }
        # if configured value for MaximumHistoryRows is -1 and test value -1 it will pass
        It "Fails Check Correctly with Maximum History Rows being less than 10000" {
            # Mock to fail
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 1000;
                    MaximumJobHistoryRows = 0;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            { Assert-JobHistoryRows -AgentServer $AgentServer -minimumJobHistoryRows 10000 } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than or equal to 10000, because We expect the maximum job history row configuration to be greater than the configured setting 10000, but got 1000."
        }
        # if configured value is 100 and test value 100 it will pass
        It "Passes Check Correctly with Maximum History Rows per job being 100" {
            # Mock to pass
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 1000;
                    MaximumJobHistoryRows = 100;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            Assert-JobHistoryRowsPerJob -AgentServer $AgentServer -minimumJobHistoryRowsPerJob 100
        }
        # if configured value is -1 and test value -1 it will pass
        It "Fails Check Correctly with Maximum History Rows per job being less than 100" {
            # Mock to fail
            Mock Get-DbaAgentServer {
                [PSCustomObject]@{
                    MaximumHistoryRows = 100;
                    MaximumJobHistoryRows = 50;
                }
            }
            $AgentServer = Get-DbaAgentServer -SqlInstance "Dummy" -EnableException:$false
            { Assert-JobHistoryRowsPerJob -AgentServer $AgentServer -minimumJobHistoryRowsPerJob 100 } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than or equal to 100, because We expect the maximum job history row configuration per agent job to be greater than the configured setting 100, but got 50."
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaAgentServer'
                'Times'       = 6
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Checking running jobs"{
        It "Should pass when the running job duration is less than the average job duration" {
            # Mock to pass
            $runningjob = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                StartDate      = '30/07/2019 12:17:25'
                RunningSeconds = 24
                Diff           = -14
            }
            $runningjobpercentage = 50
            Assert-LongRunningJobs -runningjob $runningjob -runningjobpercentage $runningjobpercentage
        }

        It "Should pass when the running job duration is the same as the average job duration" {
            # Mock to pass
            $runningjob = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                StartDate      = '30/07/2019 12:17:25'
                RunningSeconds = 38
                Diff           = 0
            }
            $runningjobpercentage = 50
            Assert-LongRunningJobs -runningjob $runningjob -runningjobpercentage $runningjobpercentage
        }

        It "Should pass when the running job duration is more than the average job duration but the percentage difference is less than the specified" {
            # Mock to pass
            $runningjob = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                StartDate      = '30/07/2019 12:17:25'
                RunningSeconds = 50
                Diff           = 12
            }
            $runningjobpercentage = 50
            Assert-LongRunningJobs -runningjob $runningjob -runningjobpercentage $runningjobpercentage
        }

        It "Should fail when the running job duration is more than the average job duration and the percentage difference is more than the specified" {
            # Mock to fail
            $runningjob = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                StartDate      = '30/07/2019 12:17:25'
                RunningSeconds = 78
                Diff           = 40
            }
            $runningjobpercentage = 50
            {Assert-LongRunningJobs -runningjob $runningjob -runningjobpercentage $runningjobpercentage} | Should -Throw -ExpectedMessage "Expected the actual value to be less than 50, because The current running job Waiting for 5 seconds has been running for 40 seconds longer than the average run time. This is more than the 50 % specified as the maximum, but got 105"
        }
    }
    Context "Checking last run time"{
        It "Should pass when the last job run duration is less than the average job duration" {
            # Mock to pass
            $lastagentjobrun  = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                Duration       = 25
                Diff           = -13
            }
            $runningjobpercentage = 50
            Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
        }

        It "Should pass when the last job run duration is the same as the average job duration" {
            # Mock to pass
            $lastagentjobrun  = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                Duration       = 38
                Diff           = 0
            }
            $runningjobpercentage = 50
            Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
        }

        It "Should pass when the last job run duration is more than the average job duration but the percentage difference is less than the specified" {
            # Mock to pass
            $lastagentjobrun  = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                Duration       = 48
                Diff           = 10
            }
            $runningjobpercentage = 50
            Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage
        }

        It "Should fail when the last job run duration is more than the average job duration and the percentage difference is more than the specified" {
            # Mock to fail
            $lastagentjobrun  = @{
                JobName        = 'Waiting for 5 seconds'
                AvgSec         = 38
                Duration       = 68
                Diff           = 30
            }
            $runningjobpercentage = 50
            {Assert-LastJobRun -lastagentjobrun $lastagentjobrun -runningjobpercentage $runningjobpercentage} | Should -Throw -ExpectedMessage "Expected the actual value to be less than 50, because The last run of job Waiting for 5 seconds was 68 seconds. This is more than the 50 % specified as the maximum variance, but got 79"
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmTZjTQTwNKqPz7pIbT43TLIZ
# 0v6gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRSvI7x6L3/fpX5iK+Xgh4DyYnE
# mjANBgkqhkiG9w0BAQEFAASCAQBaNJ/Z2YcItSXpTK4hl1OChr4Ww93vSVksSuRE
# KMxy6CvCqVcl/JRsIzeUAI77ENcACimQ10ZU+MCoekM96etiLQgrh/d2DKK37REk
# EVISOtdWAbMnaR0LJklQxBDekSIwW325gL14Y3+UmaZeaT53hrX1xR28YtCRKoUm
# Z3ERnfgS3FveVS8XPkKNA1YbkZzkmk4RhISinT4urcE7f/mxxDnvwiHra9N0+YSz
# fKIpJHvLyyqvyatEuR94raYmXeZPZjX2SCCTOfz5VJAGhqzkhHnLbQVZLzpcEExq
# qtzPMo00dgZOFmeObTxJytfN5EMaBr4XBr4ojbq5ID1FFcgy
# SIG # End signature block

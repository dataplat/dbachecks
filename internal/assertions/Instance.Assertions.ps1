<#
This file is used to hold the Assertions for the Instance.Tests

It starts with the Get-AllInstanceInfo which uses all of the unique
 tags that have been passed and gathers the required information
 which can then be used for the assertions.

 The long term aim is to make Get-AllInstanceInfo as performant as 
 possible and to cover all of the tests
#>

function Get-AllInstanceInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags, $There)
    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {
        {$tags -contains 'ErrorLog'} { 
            if ($There) {
                try {
                    $logWindow = Get-DbcConfigValue -Name policy.errorlog.warningwindow
                    # so that it can be mocked
                    function Get-ErrorLogEntry {
                        # get the number of the first error log that was created after the logwindow config
                        $OldestErrorLogNumber = ($InstanceSMO.EnumErrorLogs() | Where-Object {$psitem.CreateDate -gt (Get-Date).AddDays( - $LogWindow)} |Sort-Object ArchiveNo -Descending | Select-Object -First 1).ArchiveNo + 1
                    
                        # Get the Error Log entries for each one
                        (0..$OldestErrorLogNumber).ForEach{
                            $InstanceSMO.ReadErrorLog($psitem).Where{$_.Text -match "Severity: 1[7-9]|Severity: 2[0-4]"}
                        }
                    }
                    $ErrorLog = @(Get-ErrorLogEntry).ForEach{
                        [PSCustomObject]@{
                        LogDate       = $psitem.LogDate
                        ProcessInfo   = $Psitem.ProcessInfo
                        Text          = $Psitem.Text
                        }
                    }
                }
                catch {
                    $There = $false        
                    $ErrorLog = [PSCustomObject]@{
                        LogDate       = 'Do not know the Date'
                        ProcessInfo   = 'Do not know the Process'
                        Text          = 'Do not know the Test'
                        $InstanceName = 'An Error occurred ' + $Instance
                    } 
                }
            }
            else {
                $There = $false
                $ErrorLog = [PSCustomObject]@{
                    LogDate       = 'Do not know the Date'
                    ProcessInfo   = 'Do not know the Process'
                    Text          = 'Do not know the Test'
                    $InstanceName = 'An Error occurred ' + $Instance
                } 
            }
        }
        Default {}
    }
    [PSCustomObject]@{
        ErrorLog = $ErrorLog 
    }
}

function Assert-InstanceMaxDop {
    Param(
        [string]$Instance,
        [switch]$UseRecommended,
        [int]$MaxDopValue
    )
    $MaxDop = @(Test-DbaMaxDop -SqlInstance $Instance)[0]
    if ($UseRecommended) {
        #if UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the the RecommendedMaxDop property
        $MaxDop.CurrentInstanceMaxDop | Should -Be $MaxDop.RecommendedMaxDop -Because "We expect the MaxDop Setting to be the recommended value $($MaxDop.RecommendedMaxDop)"
    }
    else {
        #if not UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
        $MaxDop.CurrentInstanceMaxDop | Should -Be $MaxDopValue -Because "We expect the MaxDop Setting to be $MaxDopValue"
    }
}

function Assert-BackupCompression {
    Param($Instance, $defaultbackupcompression)
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should -Be $defaultbackupcompression -Because 'The default backup compression should be set correctly'
}

function Assert-TempDBSize {
    Param($Instance)

    @((Get-DbaDbFile -SqlInstance $Instance -Database tempdb).Where{$_.Type -eq 0}.Size.Megabyte |Select-Object -Unique).Count | Should -Be 1 -Because "We want all the tempdb data files to be the same size - See https://blogs.sentryone.com/aaronbertrand/sql-server-2016-tempdb-fixes/ and https://www.brentozar.com/blitz/tempdb-data-files/ for more information"
}

function Assert-InstanceSupportedBuild {
    Param(
        [string]$Instance,
        [int]$BuildWarning,
        [string]$BuildBehind,
        [DateTime]$Date
    )
    #If $BuildBehind check against SP/CU parameter to determine validity of the build
    if ($BuildBehind) {
        $results = Test-DbaBuild -SqlInstance $Instance -MaxBehind $BuildBehind
        $Compliant = $results.Compliant
        $Build = $results.build
        $Compliant | Should -Be $true -Because "this build $Build should not be behind the required build"
        #If no $BuildBehind only check against support dates
    }
    else {
        $Results = Test-DbaBuild -SqlInstance $Instance -Latest
        [DateTime]$SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $Build = $results.build
        #If $BuildWarning, check for support date within the warning window
        if ($BuildWarning) {
            [DateTime]$expected = Get-Date ($Date).AddMonths($BuildWarning) -Format O
            $SupportedUntil | Should -BeGreaterThan $expected -Because "this build $Build will be unsupported by Microsoft on $(Get-Date $SupportedUntil -Format O) which is less than $BuildWarning months away"
        }
        #If neither, check for Microsoft support date
        else {
            $SupportedUntil | Should -BeGreaterThan $Date -Because "this build $Build is now unsupported by Microsoft"
        }
    }
}

function Assert-TwoDigitYearCutoff {
    Param(
        [string]$Instance,
        [int]$TwoDigitYearCutoff
    )
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'TwoDigitYearCutoff').ConfiguredValue | Should -Be $TwoDigitYearCutoff -Because 'This is the value that you have chosen for Two Digit Year Cutoff configuration'
}

function Assert-TraceFlag {
    Param(
        [string]$SQLInstance,
        [int[]]$ExpectedTraceFlag
    )
    if ($null -eq $ExpectedTraceFlag) {
        $a = (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag
        (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $SQLInstance"
    }
    else {
        @($ExpectedTraceFlag).ForEach{
            (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -Contain $PSItem -Because "We expect that Trace Flag $PsItem will be set on $SQLInstance"
        }
    }
}
function Assert-NotTraceFlag {
    Param(
        [string]$SQLInstance,
        [int[]]$NotExpectedTraceFlag
    )

    if ($null -eq $NotExpectedTraceFlag) {
        (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $SQLInstance"
    }
    else {
        @($NotExpectedTraceFlag).ForEach{
            (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag  | Should -Not -Contain $PSItem -Because "We expect that Trace Flag $PsItem will not be set on $SQLInstance"
        }
    }
}

function Assert-CLREnabled {
    param (
        $SQLInstance,
        $CLREnabled
    )

    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name IsSqlClrEnabled).ConfiguredValue -eq 1 | Should -Be $CLREnabled -Because 'The CLR Enabled should be set correctly'
}
function Assert-CrossDBOwnershipChaining {
    param (
        $SQLInstance,
        $CrossDBOwnershipChaining
    )
    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name CrossDBOwnershipChaining).ConfiguredValue -eq 1 | Should -Be $CrossDBOwnershipChaining -Because 'The Cross Database Ownership Chaining setting should be set correctly'
}
function Assert-AdHocDistributedQueriesEnabled {
    param (
        $SQLInstance,
        $AdHocDistributedQueriesEnabled
    )
    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name AdHocDistributedQueriesEnabled).ConfiguredValue -eq 1 | Should -Be $AdHocDistributedQueriesEnabled -Because 'The AdHoc Distributed Queries Enabled setting should be set correctly'
}
function Assert-XpCmdShellDisabled {
    param (
        $SQLInstance,
        $XpCmdShellDisabled
    )
    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name XPCmdShellEnabled).ConfiguredValue -eq 0 | Should -Be $XpCmdShellDisabled -Because 'The XP CmdShell setting should be set correctly'
}

function Assert-ErrorLogCount {
    param (
        $SQLInstance,
        $errorLogCount
    )
    (Get-DbaErrorLogConfig -SqlInstance $SQLInstance).LogCount | Should -BeGreaterOrEqual $errorLogCount -Because "We expect to have at least $errorLogCount number of error log files"
}

function Assert-ErrorLogEntry {
    Param($AllInstanceInfo)
    $AllInstanceInfo.ErrorLog | Should -BeNullOrEmpty -Because "these severities indicate serious problems"
}


# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUncCtYi0k2a2nT5KzPa5J1DXf
# eyagggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQj7PN2tTpWBwr8+8QWASk0wtYp
# WjANBgkqhkiG9w0BAQEFAASCAQBfsbQiu0GEMgNlw6NUt9PHAvTjmnflhcm0DbMN
# QCMMs0aklDPOFaPD1Q7nEh0L8MWyldqA+sBMKJVfgpwOctPXfn5w9dOAzqQcYA9e
# 4Ub8g6T+vWsTqtBb3ojpeRUarAo+HiMJbInlUay22PP4HnWsqLjsSjVhpZqCzDhh
# /r8zA/xis4o5ZmwmsK5xaAqT3MkriYylf2Glhl13FBo9R1U9xxk+DWwa7XiDuwoT
# RveVeSjNrXJRkOsMrs/vjFumfCp1YbesJojDbOITjPo8IGGgLqsbyxpF7KHAik1s
# 8XWIc/re4Er01v8u5U4rxwI4oD9NKTWLk8/pkfGc9fnWYArO
# SIG # End signature block

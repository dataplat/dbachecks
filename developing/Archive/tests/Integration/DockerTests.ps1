[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Because they are used just parsed')]
Param()
<#
    # Need to create a credential to be saved using user sa and password Password0! by running
    Get-Credential | Export-Clixml -Path $CredentialPath
#>
$CredentailPath = 'C:\MSSQL\BACKUP\KEEP\sacred.xml'
$dbacheckslocalpath = 'GIT:\dbachecks\'

#region setup
Write-PSFMessage "Removing Modules" -Level Significant
Remove-Module dbatools, dbachecks, PSFramework -ErrorAction SilentlyContinue
Write-PSFMessage "Importing from source control" -Level Significant
Import-Module $dbacheckslocalpath\dbachecks.psd1
Write-PSFMessage "Resetting dbachecks config"  -Level Significant
$null = Reset-DbcConfig

$PSDefaultParameterValues += @{ 'Write-PSFMessage:Level' = 'Output'} # setting for messages to screen
Set-Location $dbacheckslocalpath\tests\Integration

Write-PSFMessage "resetting docker-compose to save Rob from troubleshooting for hours because the containers already existed"
docker-compose down
Write-PSFMessage "Starting containers"
try {
    $ErrorActionPreference = 'Stop'
    docker-compose up -d
    $ErrorActionPreference = 'Continue'
}
catch {
    $ErrorActionPreference = 'Continue'
    Return
}

$containers = 'localhost,15589', 'localhost,15588', 'localhost,15587', 'localhost,15586'
$cred = Import-Clixml $CredentailPath

Write-PSFMessage "Setting default configs"
$null = Set-DbcConfig -Name app.sqlinstance $containers
$null = Set-DbcConfig -Name policy.connection.authscheme -Value SQL
$null = Set-DbcConfig -Name policy.network.latencymaxms -Value 150 # because the containers run a bit slow!
$null = Set-DbcConfig -Name skip.connection.auth -Value $true

## Ensure that SQLAgent is started - SQL2014 agent wont start in container
Write-PSFMessage "Starting SQL Agent on all containers except SQL2014"
docker exec -ti integration_sql2012_1 powershell start-service SQLSERVERAGENT
docker exec -ti integration_sql2016_1 powershell start-service SQLSERVERAGENT
docker exec -ti integration_sql2017_1 powershell start-service SQLSERVERAGENT

#endregion

#region Pester Functions
function Invoke-DefaultCheck {
    It "All Checks should pass with default for $Check" {
        $Tests = get-variable "$($Check)default"  -ValueOnly
        $Tests.FailedCount | Should -Be 0 -Because "We expect all of the checks to run and pass with default setting (Yes we may set some values before but you get my drift)"
    }
}
function Invoke-ConfigCheck {
    It "All Checks should fail when config changed for $Check" {
        $Tests = get-variable "$($Check)configchanged"  -ValueOnly
        $Tests.PassedCount | Should -Be 0 -Because "We expect all of the checks to run and fail when we have changed the config values"
    }
}
function Invoke-ValueCheck {
    It "All Checks should pass when setting changed for $Check" {
        $Tests = get-variable "$($Check)valuechanged"  -ValueOnly
        $Tests.FailedCount | Should -Be 0 -Because "We expect all of the checks to run and pass when we have changed the settings to match the config values"
    }
}
#endregion

# make sure the containers are up and running
Write-PSFMessage "Default connectivity check"
$ConnectivityTests = Invoke-DbcCheck -SqlCredential $cred -Check Connectivity -Show None -PassThru

#region error Log Count - PR 583
# default test
Write-PSFMessage "Checking ErrorLogCount default"
$errorlogscountdefault = Invoke-DbcCheck -SqlCredential $cred -Check ErrorLogCount -Show None  -PassThru
# set a value and then it will fail
Write-PSFMessage "Checking ErrorLogCount config changed"
$null = Set-DbcConfig -Name policy.errorlog.logcount -Value 10
$errorlogscountconfigchanged = Invoke-DbcCheck -SqlCredential $cred -Check ErrorLogCount -Show None  -PassThru

# set the value and then it will pass
Write-PSFMessage "Checking ErrorLogCount value changed"
$null = Set-DbaErrorLogConfig -SqlInstance $containers -SqlCredential $cred -LogCount 10
$errorlogscountvaluechanged = Invoke-DbcCheck -SqlCredential $cred -Check ErrorLogCount -Show None  -PassThru
#endregion

#region Job History Count PR 582

# run the checks against these instances (SQL2014 agent wont start :-( ))
Write-PSFMessage "Checking JobHistory default"
$null = Set-DbcConfig -Name app.sqlinstance $containers.Where{$_ -ne 'localhost,15588'}
# by default all tests should pass on default instance settings
$jobhistorydefault = Invoke-DbcCheck -SqlCredential $cred -Check JobHistory -Show None  -PassThru

#Change the configuration to test that the checks fail
Write-PSFMessage "Checking JobHistory config changed"
$null = Set-DbcConfig -Name agent.history.maximumjobhistoryrows -value 1000
$null = Set-DbcConfig -Name agent.history.maximumhistoryrows -value 10000
$jobhistoryconfigchanged = Invoke-DbcCheck -SqlCredential $cred -Check JobHistory -Show None  -PassThru
Write-PSFMessage "Checking JobHistory value changed"
$setDbaAgentServerSplat = @{
    MaximumJobHistoryRows = 1000
    MaximumHistoryRows    = 10000
    SqlInstance           = $containers.Where{$_ -ne 'localhost,15588'}
    SqlCredential         = $cred
}
$null = Set-DbaAgentServer @setDbaAgentServerSplat
$jobhistoryvaluechanged = Invoke-DbcCheck -SqlCredential $cred -Check JobHistory -Show None  -PassThru

#endregion

#region BackupPathAccess

# run the checks against these instances
Write-PSFMessage "Checking BackupPathAccess default"
$null = Set-DbcConfig -Name app.sqlinstance $containers
# by default all tests should pass on default instance settings
$BackupPathAccessdefault = Invoke-DbcCheck -SqlCredential $cred -Check BackupPathAccess -Show None  -PassThru

#Change the configuration to test that the checks fail
Write-PSFMessage "Checking BackupPathAccess config changed"
$null = Set-DbcConfig -Name policy.storage.backuppath -value 'C:\Windows\temp\a' ## Setting to an invalid unaccessible folder
$BackupPathAccessconfigchanged = Invoke-DbcCheck -SqlCredential $cred -Check BackupPathAccess -Show None  -PassThru
Write-PSFMessage "Checking BackupPathAccess value changed"

foreach ($container in $containers) {
    $Instance = Connect-DbaInstance -SqlInstance $container -SqlCredential $cred
    $Instance.BackupDirectory = 'C:\Windows\temp\'
    $Instance.Alter()
}

$null = Set-DbcConfig -Name policy.storage.backuppath -value 'C:\Windows\temp\'

$BackupPathAccessvaluechanged = Invoke-DbcCheck -SqlCredential $cred -Check BackupPathAccess -Show None  -PassThru


#endregion

#region DAC

# run the checks against these instances
Write-PSFMessage "Checking DAC default"
$null = Set-DbcConfig -Name app.sqlinstance $containers
foreach($container in $containers){
    $null = Set-DbaSpConfigure -SqlInstance $container -SqlCredential $cred -Name RemoteDACConnectionsEnabled -Value 1 ## because it is set to false by default but dbachecks uses true as default
    }
# by default all tests should pass on default instance settings
$DACdefault = Invoke-DbcCheck -SqlCredential $cred -Check DAC -Show None  -PassThru

#Change the configuration to test that the checks fail
Write-PSFMessage "Checking DAC config changed"
$null = Set-DbcConfig -Name policy.dacallowed -value $false
$DACconfigchanged = Invoke-DbcCheck -SqlCredential $cred -Check DAC -Show None  -PassThru
Write-PSFMessage "Checking DAC value changed"

foreach($container in $containers){
    $null = Set-DbaSpConfigure -SqlInstance $container -SqlCredential $cred -Name RemoteDACConnectionsEnabled -Value 0
    }

$DACvaluechanged = Invoke-DbcCheck -SqlCredential $cred -Check DAC -Show None  -PassThru


#endregion

Write-PSFMessage "Running Pester Tests ........."
Describe "Testing the checks are running as expected" -Tag Integration {
    Context "Connectivity Checks" {
        It "All Tests should pass" {
            $ConnectivityTests.FailedCount | Should -Be 0 -Because "We expect all of the checks to run and pass with default settings"
        }
    }

    $TestingTheChecks = @('errorlogscount', 'jobhistory', 'BackupPathAccess', 'DAC')
    Foreach ($Check in $TestingTheChecks) {
        Context "$Check Checks" {
            Invoke-DefaultCheck
            Invoke-ConfigCheck
            INvoke-ValueCheck
        }
    }
}

Write-PSFMessage "Finished running Pester Tests"
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoCglQhb3cpQGiNZYDTV1Zn/l
# ovSgggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTKEaVMVkW7Jpz69FG46ZV+gDZt
# PzANBgkqhkiG9w0BAQEFAASCAQAzXtLiTNHXRqbcTmsc3msXu0zewS4iyx5HYrN8
# /RAVu8JCx5SgRScDYgTQt35k4VpmDMF2fPXnPnpGjmg+VmghYKNFVXE+h+l+3Ale
# bKQb7pnLVkPqjtU2JMdSvJd1rKHePV7PBNIHTtsyM19c4tVH3CGupUzGrRWL09CZ
# K2K8FmSU9cPypWrNcuzHA4fAqxuBRecps48NIdEWtjKxFmwXUo6pPOTpwRSL3hxU
# 0eDp8woA0JrH0ao4JcJ2/epKewiOb9XQKV0GdhAIJUczK7jA9lA5U083INMIf4jc
# jx2+VHF4IAtbrA+q78L9MEjfLHqmdHMS9jTdvGbFyFH/plce
# SIG # End signature block

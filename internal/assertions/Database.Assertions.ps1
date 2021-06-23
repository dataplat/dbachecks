function Get-Database {
    Param(
        [string]$Instance,
        [string[]]$ExcludedDbs,
        [string[]]$Database,
        [ValidateSet('Name')]
        [string]$Requiredinfo,
        [ValidateSet('NotAccessible')]
        [string]$Exclusions
    )

    switch ($Exclusions) {
        NotAccessible { $dbs = (Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$(if($database){$PsItem.Name -in $Database}else{$ExcludedDbs -notcontains $PsItem.Name}) -and $psitem.IsAccessible -eq $true} }
        Default {
            $dbs = (Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$(if($database){$PsItem.Name -in $Database}else{$ExcludedDbs -notcontains $PsItem.Name})}
        }
    }
    switch ($Requiredinfo) {
        Name { $dbs.Name}
        Default {}
    }
}
function Assert-DatabaseMaxDop {
    Param(
        [pscustomobject]$MaxDop,
        [int]$MaxDopValue
    )
    $MaxDop.DatabaseMaxDop | Should -Be $MaxDopValue -Because "We expect the Database MaxDop Value to be the specified value $MaxDopValue"
}

function Assert-DatabaseStatus {
    Param(
        [string]$instance,
        [string[]]$Database,
        [string[]]$Excludedbs,
        [string[]]$ExcludeReadOnly,
        [string[]]$ExcludeOffline,
        [string[]]$ExcludeRestoring
    )
    if($Database){
        $results = @((Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$psitem.Name -in $Database -and $psitem.Name -notin $Excludedbs} | Select-Object Name, Status, Readonly, IsDatabaseSnapshot)
    }
    else{
    $results = @((Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$psitem.Name -notin $Excludedbs} | Select-Object Name, Status, Readonly, IsDatabaseSnapshot)
    }
    $results.Where{$_.Name -notin $ExcludeReadOnly -and $_.IsDatabaseSnapshot -eq $false}.Readonly | Should -Not -Contain True -Because "We expect that there will be no Read-Only databases except for those specified"
    $results.Where{$_.Name -notin $ExcludeOffline}.Status | Should -Not -Match 'Offline' -Because "We expect that there will be no offline databases except for those specified"
    $results.Where{$_.Name -notin $ExcludeRestoring}.Status | Should -Not -Match 'Restoring' -Because "We expect that there will be no databases in a restoring state except for those specified"
    $results.Where{$_.Name -notin $ExcludeOffline}.Status | Should -Not -Match 'AutoClosed' -Because "We expect that there will be no databases that have been auto closed"
    $results.Status | Should -Not -Match 'Recover' -Because "We expect that there will be no databases going through the recovery process or in a recovery pending state"
    $results.Status | Should -Not -Match 'Emergency' -Because "We expect that there will be no databases in EmergencyMode"
    $results.Status | Should -Not -Match 'Standby' -Because "We expect that there will be no databases in Standby"
    $results.Status | Should -Not -Match 'Suspect' -Because "We expect that there will be no databases in a Suspect state"
}

function Assert-DatabaseDuplicateIndex {
    Param(
        [string]$instance,
        [string]$Database
    )
    @(Find-DbaDbDuplicateIndex -SqlInstance $Instance -Database $Database).Count | Should -Be 0 -Because "Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory - Use Find-DbaDbDuplicateIndex to find them"
}

function Assert-DatabaseExists {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param (
        [string]$Instance,
        [string]$ExpectedDB
    )
    $Actual = Get-Database -Instance $instance -Requiredinfo Name
    $Actual | Should -Contain $expecteddb -Because "We expect $expecteddb to be on $Instance"
}

function Assert-GuestUserConnect {
    Param (
        [string]$Instance,
        [string]$Database
    )
    $guestperms = Get-DbaUserPermission -SqlInstance $Instance -Database $Database | Where-Object {$_.Grantee -eq "guest" -and $_.Permission -eq "CONNECT"}
    $guestperms.Count | Should -Be 0 -Because "We expect the guest user in $Database on $Instance to not have CONNECT permissions"
}

function Assert-CLRAssembliesSafe {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbAssembly -SqlInstance $Instance -Database $Database | Where-Object {$_.IsSystemObject -eq $false -and $_.SecurityLevel -ne "Safe" -and $_.Database -ne "SSISDB" -and $_.Name -ne "ISSERVER"}).Count | Should -Be 0 -Because "We expect CLR Assemblies to operate in the SAFE permission set"
}

function Assert-AsymmetricKeySize {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbEncryption -SqlInstance $Instance -Database $Database | Where-Object {$_.Encryption -eq "Asymmetric Key" -and $_.KeyLength -LT 2048}).Count | Should -Be 0 -Because "Asymmetric keys should have a key length greater than or equal to 2048"
}

function Assert-SymmetricKeyEncryptionLevel {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbEncryption -SqlInstance $Instance -Database $Database | Where-Object {$_.Encryption -eq "Symmetric Key" -and $_.EncryptionAlgrothim -notin "AES_128","AES_192","AES_256"}).Count  | Should -Be 0 -Because "Symmetric keys should have an encryption algrothim of at least AES_128"
}

function Assert-QueryStoreEnabled {
    Param (
        [string]$Instance,
        [string]$Database
    )
    (Get-DbaDbQueryStoreOption -SqlInstance $Instance -Database $Database).ActualState  | Should -Not -BeIn 'OFF', 'ERROR' -Because "We expect the Query Store to be enabled in $Database on $Instance"
}
function Assert-QueryStoreDisabled {
    Param (
        [string]$Instance,
        [string]$Database
    )
    (Get-DbaDbQueryStoreOption -SqlInstance $Instance -Database $Database).ActualState | Should -Be 'OFF' -Because "We expect the Query Store to be disabled in $Database on $Instance"
}
function Assert-ContainedDBSQLAuth {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbUser -SQLInstance $Instance -Database $Database | Where-Object {$_.LoginType -eq "SqlLogin" -and $_.HasDbAccess -eq $true}).Count | Should -Be 0 -Because "We expect there to be no sql authenticated users in contained database $Database on $Instance"
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWV5eEvZUineXnauPcBDvBW6K
# wHygggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQw7LZnAhvpN+sY8bINEHrOjzii
# mjANBgkqhkiG9w0BAQEFAASCAQBtnx2QeSl3A26bXXoAwf1wkKsetkHTJzjC642v
# cbrVffim+MKWNRICLZx0KLyWe5bEdOadY1GgFEaYRPeaVCFMJopNL4uJfnJ1GoBw
# zZrDQaSf5hUlrQvETMtoCnX8+65eJQECAkV87LsJckC5P8F2P+iC1uDbeKGVFw3C
# ncii3LHqlzx0KuRk+Y6wYcIAjAACr2/tyXxdl1rCBG3xg8XJRssQ1NfVs6W50sBz
# Ql42LSzBWaaCjcyGC8optFyIQd+5vJ2KiL8MuAjuOZvd5TvzY0MXOaLohlnz5qEP
# V/1CKLtRyNRyQvxgrIQlGNe5Ei//V/v44mzD8in3dsL2cGZS
# SIG # End signature block

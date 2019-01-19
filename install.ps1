<#
Push in path to install
Work out where we're being called from (should be withing dbchecks folder)

if path!= where we are then we need to pull and move latest dbchecks install to there,

pull from github

Then work through other requirements
if psd1 modules != modules in here, throw as someones' not updated.

For each module grab latest
Unzip to path
If path in $P

#>

[CmdletBinding()]
param (
    [string]$Path,
    [switch]$Beta
)

function Write-LocalMessage {
    [CmdletBinding()]
    Param (
        [string]$Message
    )
    
    if (Test-Path function:Write-Message) { Write-Message -Level Output -Message $Message }
    else { Write-Host $Message }
}
#    @{ ModuleName = 'dbachecks'; URL='https://github.com/potatoqualitee/dbachecks/archive/master.zip'},
#Sort ourselves out first:
$modules = @(
    
    @{ ModuleName = 'Pester'; ModuleVersion = '4.1.1'; URL = 'https://github.com/pester/Pester/archive/master.zip' },
    @{ ModuleName = 'dbatools'; ModuleVersion = '0.9.139'; URL = 'https://dbatools.io/zip' },
    @{ ModuleName = 'PSFramework'; ModuleVersion = '0.9.5.10'; URL = 'https://github.com/PowershellFrameworkCollective/psframework/archive/master.zip' }
)
$RequiredModules = (Import-PowerShellDataFile -path .\dbachecks.psd1).RequiredModules


ForEach ($Module in $RequiredModules) {
    if ($Module.ModuleName -notin $Modules.ModuleName) {
        Write-LocalMessage -Message "We do not have the download information for $($Module.ModuleName), please raise an issue"
    }
}

ForEach ($Module in $Modules) {
    try {
        Update-Module $Module.ModuleName -Erroraction Stop
        Write-LocalMessage -Message "Updated $($Module.ModuleName) using the PowerShell Gallery"
        return
    }
    catch {
        Write-LocalMessage -Message "$($Module.ModuleName) was not installed by the PowerShell Gallery, continuing with web install."
    }
    
    $dbatools_copydllmode = $true
    $Impmodule = Import-Module -Name $Module.ModuleName -ErrorAction SilentlyContinue
    $localpath = $Impmodule.ModuleBase
    
    $temp = ([System.IO.Path]::GetTempPath()).TrimEnd("\")
    $zipfile = "$temp\$($Module.ModuleName).zip"
    Write-LocalMessage -Message "Downloading archive from github"
    try {
        (New-Object System.Net.WebClient).DownloadFile($Module.url, $zipfile)
    }
    catch {
        #try with default proxy and usersettings
        Write-LocalMessage -Message "Probably using a proxy for internet access, trying default proxy settings"
        $wc = (New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        $wc.DownloadFile($Module.url, $zipfile)
    }
    
    
    # Unblock if there's a block
    Unblock-File $zipfile -ErrorAction SilentlyContinue
    
    Write-LocalMessage -Message "Unzipping"
    
    # Keep it backwards compatible
    Remove-Item -ErrorAction SilentlyContinue "$temp\$($Module.ModuleName)-old" -Recurse -Force
    $null = New-Item "$temp\$($Module.ModuleName)-old" -ItemType Directory
    $shell = New-Object -ComObject Shell.Application
    $zipPackage = $shell.NameSpace($zipfile)
    $destinationFolder = $shell.NameSpace($temp)
    $destinationFolder.CopyHere($zipPackage.Items())
    
    
    $PSD = Get-ChildItem  "$temp\$($Module.ModuleName)-master\" -file -Filter "$($Module.ModuleName).psd1" -Recurse
    $ModuleDetails = Import-PowerShellDataFile -Path $PSD.fullname
    $ModuleVersion = $Moduledetails.ModuleVersion
    
    if ($null -eq $localpath) {
        $localpath = "$HOME\Documents\WindowsPowerShell\Modules\$($Module.ModuleName)\$ModuleVersion"
    }
    else {
        Write-LocalMessage -Message "Updating current install of $($Module.ModuleName)"
    }
    
    try {
        if (-not $path) {
            if ($PSCommandPath.Length -gt 0) {
                $path = Split-Path $PSCommandPath
                if ($path -match "github") {
                    Write-LocalMessage -Message "Looks like this installer is run from your GitHub Repo, defaulting to psmodulepath"
                    $path = $localpath
                }
            }
            else {
                $path = $localpath
            }
        }
    }
    catch {
        $path = $localpath
    }
    
    if (-not $path -or (Test-Path -Path "$path\.git")) {
        $path = $localpath
    }
    
    Write-LocalMessage -Message "Installing module $($Module.ModuleName) to $path"
    
    if (!(Test-Path -Path $path)) {
        try {
            Write-LocalMessage -Message "Creating directory: $path"
            New-Item -Path $path -ItemType Directory | Out-Null
        }
        catch {
            throw "Can't create $Path. You may need to Run as Administrator: $_"
        }
    }
    
    Write-LocalMessage -Message "Applying Update"
    Write-LocalMessage -Message "1) Backing up previous installation"
    Copy-Item -Path "$Path\*" -Destination "$temp\$($Module.ModuleName)-old" -ErrorAction Stop
    try {
        Write-LocalMessage -Message "2) Cleaning up installation directory"
        Remove-Item "$Path\*" -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-LocalMessage -Message @"
        Failed to clean up installation directory, rolling back update.
        This usually has one of two causes:
        - Insufficient privileges (need to run as admin)
        - A file is locked - generally a dll file from having the module imported in some process.

        Exception:
        $_
"@
        Copy-Item -Path "$temp\$($Module.ModuleName)-old\*" -Destination $path -ErrorAction Ignore -Recurse
        Remove-Item "$temp\$($Module.ModuleName)-old" -Recurse -Force
        return
    }
    Write-LocalMessage -Message "3) Setting up current version"
    Move-Item -Path "$temp\\$($Module.ModuleName)-master\*" -Destination $path -ErrorAction SilentlyContinue -Force
    Remove-Item -Path "$temp\\$($Module.ModuleName)-master" -Recurse -Force
    #Remove-Item "destinationFolder" -Recurse -Force
    Remove-Item -Path $zipfile -Recurse -Force
    Remove-Item "$temp\$($Module.ModuleName)-old" -Recurse -Force
    #Remove-Item -Path $zipfile -Recurse -Force
    
    Write-LocalMessage -Message "Module $($Module.ModuleName) now installed"
    if (Get-Module $Module.ModuleName) {
        Write-LocalMessage -Message @"

    Please restart PowerShell before working with $($Module.ModuleName).
"@
    }
    else {
        Write-LocalMessage -Message "Debug - Path = $path"
        $ImportPsd = Get-ChildItem  $path -file -Filter "$($Module.ModuleName).psd1" -Recurse
        
        Import-Module $ImportPSd -Force
        Write-LocalMessage @"

    $($Module.ModuleName) v $((Get-Module $Module.ModuleName).Version)
    # Commands available: $((Get-Command -Module $Module.ModuleName -CommandType Function | Measure-Object).Count)

"@
    }
    Remove-Variable path
    
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUP6OsfsC6ij4qb1kO2Q2+gZ2S
# Nw2gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRj2RkVH+jXSeVMgHn7WE4C7Ce/
# ljANBgkqhkiG9w0BAQEFAASCAQAA/93HkXYtbSpIPZDJ+Tw7qGrKBbkp1PUSl20O
# OJIG1kcfV0zuWehbkw8mSrmroq82M8ah91zix4L9xQNVsrcu3K/6+s1r2+Eg5As7
# CBYOW45jVySNsVGjp6/3y/Tar0oc2xYocQkJgbMETRCYiE4T/BcuW19OZwc+TA0O
# Xe2OaluSBkjw5DeLN8SJfLQpdAvDIhBJXT8Zv7Xkytm4WTuk/fklMO2vKVaxjlm9
# ZlXVUiNnHJwCDc6yupsxFkyb/yT3SvBMNHX2CxhmaClsLi6YLFoa99sfa+gOZluV
# KkUQx3VFnuIRbuKylfobmIIV4mcRsvKn5jMk+XOPH/BM57kj
# SIG # End signature block

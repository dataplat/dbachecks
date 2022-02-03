<#
.SYNOPSIS
Converts Pester results and exports file in required format for launching the
Power BI command. **You will need refresh* the Power BI dashboard every time to
see the new results.

.DESCRIPTION
Converts Pester results and exports file in required format for launching the
Power BI command. **You will need refresh* the Power BI dashboard every time to
see the new results.

Basically, it does this:
$InputObject.TestResult | Select-Object -First 20 | ConvertTo-Json -Depth 3 | Out-File "$env:windir\temp\dbachecks.json"

.PARAMETER InputObject
Required. Resultset from Invoke-DbcCheck. If InputObject is not provided, it will be generated using a very generic resultset:

.PARAMETER Path
The directory to store your JSON files. "C:\windows\temp\dbachecks\*.json" by default

.PARAMETER FileName
if you want to give the file a specific name

.PARAMETER Environment
A Name to give your suite of tests IE Prod - This will also alter the name of the file

.PARAMETER Force
Delete all json files in the data source folder.

.PARAMETER Append
Appends results to existing file. Use this if you have custom check repos

.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.EXAMPLE
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource

Runs the DatabaseStatus checks against $Instance then saves to json to $env:windir\temp\dbachecks\dbachecks_1_DatabaseStatus.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp

Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\dbachecks_1_DatabaseStatus.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -FileName BeardyTests

Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\BeardyTests.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -FileName BeardyTests.json

Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\BeardyTests.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -Environment Prod_DBChecks

Runs the DatabaseStatus checks against $Instance then saves to json to  C:\Temp\dbachecks_1_Prod_DBChecks_DatabaseStatus.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Environment Prod_DBChecks

Runs the DatabaseStatus checks against $Instance then saves to json to  C:\Windows\temp\dbachecks\dbachecks_1_Prod_DBChecks_DatabaseStatus.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Path \\nas\projects\dbachecks.json
Start-DbcPowerBi -Path \\nas\projects\dbachecks.json

Runs tests, saves to json to \\nas\projects\dbachecks.json
Opens the PowerBi using that file
then you'll have to change your data source in Power BI because by default it
points to C:\Windows\Temp (limitation of Power BI)

.EXAMPLE

Set-DbcConfig -Name app.checkrepos -Value \\SharedPath\CustomPesterChecks
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus, CustomCheckTag -PassThru | Update-DbcPowerBiDataSource -Path \\SharedPath\CheckResults -Name CustomCheckResults -Append

Because we are using a custom check repository you MUSTR use the Append parameter for Update-DbcPowerBiDataSource
otherwise the json file will be overwritten

Sets the custom check repository to \\SharedPath\CustomPesterChecks
Runs the DatabaseStatus checks and custom checks with the CustomCheckTag against $Instance then saves all the results
to json to \\SharedPath\CheckResults.json -Name CustomCheckResults


.EXAMPLE
Invoke-DbcCheck -SqlInstance sql2017 -Check SuspectPage -Show None -PassThru | Update-DbcPowerBiDataSource -Environment Test -Whatif

What if: Performing the operation "Removing .json files named *Default*" on target "C:\Windows\temp\dbachecks".
What if: Performing the operation "Passing results" on target "C:\Windows\temp\dbachecks\dbachecks_1_Test__SuspectPage.json".

Will not actually create or update the data sources but will output what happens with the command and what the file name will be
called.

.LINK
https://dbachecks.readthedocs.io/en/latest/functions/Update-DbcPowerBiDataSource/

#>
function Update-DbcPowerBiDataSource {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [pscustomobject]$InputObject,
        [string]$Path = "$env:windir\temp\dbachecks",
        [string]$FileName,
        [string]$Environment = "Default",
        [switch]$Force,
        [switch]$EnableException,
        [switch]$Append
    )
    begin {
        Write-PSFMessage "Starting begin block" -Level Debug
        if ($IsLinux -and $Path -eq '\temp\dbachecks') {
            Write-PSFMessage "Setting path on Linux" -Level Verbose
            $Path = Get-DbcConfigValue -Name app.localapp
            Write-PSFMessage "Setting path on Linux to $Path" -Level Verbose
        }
        if ($Force) {
            if ($PSCmdlet.ShouldProcess($Path, 'Removing all .json files')) {
                try {
                    $null = Remove-Item "$Path\*.json" -ErrorAction Stop
                    Write-PSFMessage "Removed all files from $Path" -Level Verbose
                }
                catch {
                    Stop-PSFFunction -Message "FAILED - Removing all files from $Path" -ErrorRecord $_
                    return
                }
            }
        }
    }
    process {
        ++$i
        try {
            if (-not (Test-Path -Path $Path)) {
                if ($PSCmdlet.ShouldProcess($Path, 'Creating new directory')) {
                    $null = New-Item -ItemType Directory -Path $Path -ErrorAction Stop
                    Write-PSFMessage "Created New Directory $Path" -Level Verbose
                }
            }
        }
        catch {
            Stop-PSFFunction -Message "Failed - Creating New Directory $Path" -ErrorRecord $_
            return
        }
        $basename = "dbachecks_$i"
        if ($Environment) {
            $basename = "dbachecks_$i" + "_$Environment`_"
        }
        if ($FileName) {
            $basename = $FileName
        }
        else {
            if ($InputObject.TagFilter) {
                $tagnames = $InputObject.TagFilter[0..3] -join "_"
                $basename = "$basename`_" + $tagnames + ".json"
            }
        }

        if ($basename.EndsWith('.json')) {}
        else {
            $basename = $basename + ".json"
        }

        Write-PSFMessage "Set basename to $basename" -Level Verbose
        $FilePath = "$Path\$basename"
        Write-PSFMessage "Set filepath to $FilePath" -Level Verbose

        if ($InputObject.TotalCount -gt 0) {
            try {
                if ($PSCmdlet.ShouldProcess($FilePath, 'Passing results')) {
                    if ($Append) {
                        $InputObject.TestResult | ConvertTo-Json -Depth 5 | Out-File -FilePath $FilePath -Append
                        Write-PSFMessage -Level Output -Message "Appended results to $FilePath"
                    }
                    else {
                        $InputObject.TestResult | ConvertTo-Json -Depth 5 | Out-File -FilePath $FilePath
                        Write-PSFMessage -Level Output -Message "Wrote results to $FilePath"
                    }
                }
            }
            catch {
                Stop-PSFFunction -Message "Failed Passing Results to $FilePath" -ErrorRecord $_
                return
            }
        }
    }
    end {
        if ($InputObject.TotalCount -isnot [int]) {
            Stop-PSFFunction -Message "Invalid TestResult. Did you forget to use -Passthru with Invoke-DbcCheck?"
            return
        }
    }
}

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGad1N8rU46XXXiQXKctuXhy8
# qU+gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS4q3UVKZeERragHnuZtyhulEMh
# bzANBgkqhkiG9w0BAQEFAASCAQAIpU2w6E5wragmblIeHZRlZJ6NqOV9e0EgZdHF
# hoKR+j4CBEZ2Jo0MF66siC0iQdR6amo0TNYsxo6L80ygxIrj7P6KoT3sOdzcJ0/3
# BpoyUbC8rFhA9SVxtbe3CFCj4nSBsboeLLym+plBpHYaeLKnN5E+vpuXIfkh63We
# 3ovKaMAADLihQb5SU0gBndsg0xzfcinv+YtMVCmEK8TRAT5bw+tjLOgBDUFVeyz1
# x9w4cyvk6mhqW4PZDT42B2/79RPCMWifysVJ2t7sdLIkBByuQVhTFjJTQKwS6m3Y
# OFwAm2rDk9l/2PuM406qXN0duVr4udpy3RMs+hXrWNa2477m
# SIG # End signature block

<#
.SYNOPSIS
Writes the result of Invoke-DbcCheck to a file (after converting with Convert-DbcResult)

.DESCRIPTION
When a check has been run with Invoke-DbcCheck (and -PassThru) and then converted with
Convert-DbcResult This command will write the results to a CSV, JSON or XML file

.PARAMETER InputObject
The datatable created by Convert-DbcResult

.PARAMETER FilePath
The directory for the file

.PARAMETER FileName
The name of the file

.PARAMETER FileType
The type of file -CSV,JSON,XML

.PARAMETER Append
Add to an existing file or not

.PARAMETER Force
Overwrite Existing file

.EXAMPLE
$Date = Get-Date -Format "yyyy-MM-dd"
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close_$Date -FileType xml

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to xml and saves in C:\temp\dbachecks\Auto-close_DATE.xml

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.xml -FileType xml

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to xml and saves in C:\temp\dbachecks\Auto-close.xml

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.csv -FileType csv

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to csv and saves in C:\temp\dbachecks\Auto-close.csv

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json -Append

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json appending the results to the existing file

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json -Force

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json overwriting the existing file

.NOTES
Initial - RMS 28/12/2019
#>
function Set-DbcFile {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "Default")]
    [OutputType([string])]
    Param(
        # The pester results object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Force')]
        $InputObject,
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        # The Directory for the file
        [string]$FilePath,
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        # The name for the file
        [string]$FileName,
        # the type of file
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        [ValidateSet('Csv', 'Json', 'Xml')]
        [string]$FileType,
        # Appending
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [switch]$Append,
        # Overwrite file
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        [switch]$Force
    )

    Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
    if(-not $InputObject){
        Write-PSFMessage "Uh-Oh - I'm really sorry - We don't have a Test Results Object" -Level Significant
        Write-PSFMessage "Did You forget the -PassThru parameter on Invoke-DbcCheck?" -Level Warning
        Return ''
    }
    Write-PSFMessage "Testing we can access $FilePath" -Level Verbose
    If (Test-Path -Path $FilePath) {

    }
    else {
        Write-PSFMessage "Uh-Oh - We cant access $FilePath - Please check that $Env:USERNAME has access" -Level Significant
        Return ''
    }
    $File = "$FilePath\$FileName"
    Write-PSFMessage "Testing if $file exists" -Level Verbose
    if (Test-Path -Path $file) {
        if (!$Force -and !$Append) {
            Write-PSFMessage "Uh-Oh - File $File exists - use the Force parameter to overwrite (even if your name is not Luke!)" -Level Significant
            Return ''
        }
        else {
            if (-not $Append) {
                Write-PSFMessage "File $File exists and will be overwritten " -Level Verbose
            }
        }
        if ($Append) {
            if ($FileType -eq 'XML') {
                Write-PSFMessage "I'm not coding appending to XML - Sorry - The Beard loves you but not that much" -Level Significant
                Return ''
            }
            else {
                Write-PSFMessage "File $File exists and will be appended to " -Level Verbose
            }
        }
    }

    function Add-Extension {
        Param ($FileType)
                if(-not ($FileName.ToLower().EndsWith(".$FileType"))){
                    Write-PSFMessage "No Extension supplied so I will add .$FileType to $Filename" -Level Verbose
                    $FileName = $FileName + '.' + $FileType
                }
                $File = "$FilePath\$FileName"
                $File
            }

    try {
        switch ($FileType) {
            'CSV' {
                $file = Add-Extension -FileType csv
                if ($PSCmdlet.ShouldProcess("$File" , "Adding results to CSV")) {
                    $InputObject  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | Export-Csv -Path $File -NoTypeInformation -Append:$Append
                }
            }
            'Json' {
                $file = Add-Extension -FileType json
                if ($PSCmdlet.ShouldProcess("$File" , "Adding results to Json file")) {
                    $Date = @{Name = 'Date'; Expression = {($_.Date).Tostring('MM/dd/yy HH:mm:ss')}}
                    $InputObject  | Select-Object $Date, Label,Describe,Context,Name,Database,ComputerName,Instance,Result,FailureMessage | ConvertTo-Json | Out-File -FilePath $File -Append:$Append
                }
            }
            'Xml' {
                $file = Add-Extension -FileType xml
                if ($PSCmdlet.ShouldProcess("$File" , "Adding results to XML file ")) {
                    $InputObject  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | Export-CliXml -Path $File -Force:$force
                }
            }
        }
        Write-PSFMessage "Exported results to $file" -Level Output
    }
    catch {
        Write-PSFMessage "Uh-Oh - We failed to create the file $file :-("
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUx0zz6Opkgx1KL+StqytBCrq5
# dligggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRT+0vM2eNscCs7R1X6mnoonUzs
# oDANBgkqhkiG9w0BAQEFAASCAQBON/45klZQGxL9/H9nr+X9Vo0ETLQitGU1aj+W
# zO6f8l9KfBm5O4wgbkvtRkSjs+prqVB3BYjD0ejlEK3/ewD+cR7UZLJs6TqralA7
# DJPqsBk9Ssspkv8mgJqdG0r6sUxlhsVp7+UKXhc/ANhdV6Skb1MHxHht7kp6lIB7
# ZpEWC7jJ44Zj0/2sJd2KgbyoADaw3R2IxByORc3AN3z4qDanRpLtHFPuGGpQeB8X
# R0sOcXUc0076gSlW6LUMN1mtcb69PaYVos2OfQhmqSM/p/QbHV4XiX8pzQAZoYi9
# nvilZTqD8lIeCshOCmiCZT9g9vtbI6KVNOO2U1I0aK6XAZg9
# SIG # End signature block

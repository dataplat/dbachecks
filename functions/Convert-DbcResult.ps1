<#
.SYNOPSIS
Takes the results of Invoke-DbcCheck, parses it and converts it to a datatable object

.DESCRIPTION
You need to run Invoke-DbcCheck with the PassThru parameter and this command will take the
results and parse them creating a datatable object with column headings
Date Label Describe Context Name Database ComputerName Instance Result FailureMessage
so that it can be written to a database with Write-DbcTable (or Write-DbaDataTable) or to
a file with Set-DbcFile

.PARAMETER TestResults
The output of Invoke-DbcCheck (WITH -PassThru)

.PARAMETER Label
An optional label to add to the set of results to identify them - Think Morning-Checks or New-instance

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Write-DbcTable -SqlInstance sql2017n5 -Database tempdb -Table newdbachecks

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and writes it to a table newdbachecks in tempdb on SQL2017N5 (NB Don't use tempdb!!)

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json

.NOTES
Initial - RMS 28/12/2019
#>
function Convert-DbcResult {
    [OutputType([System.Data.DataTable])]
    Param(
        # The pester results object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$TestResults,
        [Parameter(Mandatory = $false)]
        # the label for the Tests
        [string]$Label
    )
    Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
    if (-not $TestResults) {
        Write-PSFMessage "Uh-Oh - I'm really sorry - We don't have a Test Results Object" -Level Significant
        Write-PSFMessage "Did You forget the -PassThru parameter on Invoke-DbcCheck?" -Level Warning
        Return ''
    }
    # Create DataTable Object
    $table = New-Object system.Data.DataTable Results

    # Create Columns
    $col1 = New-Object system.Data.DataColumn Date, ([datetime])
    $col2 = New-Object system.Data.DataColumn Label, ([string])
    $col3 = New-Object system.Data.DataColumn Describe, ([string])
    $col4 = New-Object system.Data.DataColumn Context, ([string])
    $col5 = New-Object system.Data.DataColumn Name, ([string])
    $col6 = New-Object system.Data.DataColumn Database, ([string])
    $col7 = New-Object system.Data.DataColumn ComputerName, ([string])
    $col8 = New-Object system.Data.DataColumn Instance, ([string])
    $col9 = New-Object system.Data.DataColumn Result, ([string])
    $col10 = New-Object system.Data.DataColumn FailureMessage, ([string])

    #Add the Columns to the table
    $table.columns.add($col1)
    $table.columns.add($col2)
    $table.columns.add($col3)
    $table.columns.add($col4)
    $table.columns.add($col5)
    $table.columns.add($col6)
    $table.columns.add($col7)
    $table.columns.add($col8)
    $table.columns.add($col9)
    $table.columns.add($col10)

    Write-PSFMessage "Processing the test results" -Level Verbose
    $TestResults.TestResult.ForEach{
        $ContextSplit = ($PSitem.Context -split ' ')
        $ComputerName = ($ContextSplit[-1] -split '\\')[0]
        $NameSplit = ($PSitem.Name -split ' ')
        if ($PSitem.Name -match '^Database\s(.*?)\s') {
            $Database = $Matches[1]
        }
        else {
            $Database = $null
        }
        $Date = Get-Date # -Format "yyyy-MM-dd"
        if ($Label) {

        }
        else {
            $Label = 'NoLabel'
        }
        # Create a new Row
        $row = $table.NewRow()
        # Add values to new row
        $Row.Date = $Date
        $Row.Label = $Label
        $Row.Describe = $PSitem.Describe
        $Row.Context = $ContextSplit[0..($ContextSplit.Count - 3)] -join ' '
        $Row.Name = $NameSplit[0..($NameSplit.Count - 3)] -join ' '
        $Row.Database = $Database
        $Row.ComputerName = $ComputerName
        $Row.Instance = $ContextSplit[-1]
        $Row.Result = $PSitem.Result
        $Row.FailureMessage = $PSitem.FailureMessage
        #Add new row to table
        $table.Rows.Add($row)

    }
    Write-Output -NoEnumerate -InputObject $table
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULNEwdidNTqJidfqD4tS2HVEK
# XA+gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRXleGNBmuhuSAUlgRq/E9OGEaU
# OjANBgkqhkiG9w0BAQEFAASCAQAyAOCBYlU8Z9pZ9BZmBco0i/Xgy6f4wSGMwZek
# wAF7pMaGbxq0MZgYpjvmY3OEZPgzf7EOkUjJxPgzJRVqJ/4wwFnEi07Xc3Yqzi7O
# DXL14WOVsOh1ks9c8kJGXc8ltU5uqjDMrkm0oT8V4dcpVh2YyTWuPOGSbgC33of3
# HKdHJ1LsGWsYvDQBC9wZJUfXjZirCvR3tKrrRs6BRVKDcSWLWiZuzvcaX8maTn89
# wUrwnu6rCuRHH+LnuVLMFlKhguzFuykC5prSY749wqS651ZB08gflU5lKe4ucLed
# CswbM4m0KME19w3z0ynpwLpASlquCWxY5wvvJZXtHbBEyQM9
# SIG # End signature block

function Send-DbcMailMessage {
    <#
    .SYNOPSIS
    Converts Pester results and emails results

    .DESCRIPTION
    Converts Pester results and emails results

    Wraps the Send-MailMessage cmdlet which sends an e-mail message from within Windows PowerShell.

    .PARAMETER InputObject
    Required. Resultset from Invoke-DbcCheck.

    .PARAMETER To
    Specifies the addresses to which the mail is sent. Enter names (optional) and the e-mail address, such as "Name
    <someone@example.com>". This parameter is required.
        
    .PARAMETER Subject
    Specifies the subject of the e-mail message. Default is "dbachecks results"

    .PARAMETER SmtpServer
    Specifies the name of the SMTP server that sends the e-mail message.

    The default value is the value of the $PSEmailServer preference variable. If the preference variable is not set and this parameter is omitted, the command fails.

    .PARAMETER From
    Specifies the address from which the mail is sent. Enter a name (optional) and e-mail address, such as "Name
    <someone@example.com>". This parameter is required.

    .PARAMETER Cc
    Specifies the e-mail addresses to which a carbon copy (CC) of the e-mail message is sent. Enter names (optional) and the e-mail address, such as "Name <someone@example.com>".

    .PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default is the current user.

    Type a user name, such as "User01" or "Domain01\User01". Or, enter a PSCredential object, such as one from the
    Get-Credential cmdlet.

    .PARAMETER Port
    Specifies an alternate port on the SMTP server. The default value is 25, which is the default SMTP port. This
    parameter is available in Windows PowerShell 3.0 and newer releases.

    .PARAMETER Priority
    Specifies the priority of the e-mail message. The valid values for this are Normal, High, and Low. Normal is the default.

    .PARAMETER DeliveryNotificationOption
    Specifies the delivery notification options for the e-mail message. You can specify multiple values. "None" is the default value.  The alias for this parameter is "dno".

    The delivery notifications are sent in an e-mail message to the address specified in the value of the To parameter.

    Valid values are:

    .PARAMETER - None: No notification.

    .PARAMETER - OnSuccess: Notify if the delivery is successful.

    .PARAMETER - OnFailure: Notify if the delivery is unsuccessful.

    .PARAMETER - Delay: Notify if the delivery is delayed.

    .PARAMETER - Never: Never notify.

    .PARAMETER Bcc
    Specifies the e-mail addresses that receive a copy of the mail but are not listed as recipients of the message.
    Enter names (optional) and the e-mail address, such as "Name <someone@example.com>".

    .PARAMETER Attachments
    Specifies the path and file names of files to be attached to the e-mail message. You can use this parameter or pipe the paths and file names to Send-MailMessage.

    .PARAMETER Body
    Specifies the body (content) of the e-mail message. Automatically provided by this command.

    .PARAMETER BodyAsHtml
    Indicates that the value of the Body parameter contains HTML. Automatically provided by this command.

    .PARAMETER Encoding
    Specifies the encoding used for the body and subject. Valid values are ASCII, UTF8, UTF7, UTF32, Unicode,
    BigEndianUnicode, Default, and OEM. ASCII is the default.

    .PARAMETER UseSsl
    Uses the Secure Sockets Layer (SSL) protocol to establish a connection to the remote computer to send mail. By
    default, SSL is not used.

    .PARAMETER ExcludeHtmlAttachment
    By default, the HTML will be attached. Use ExcludeHtmlAttachment to send without the HTML.

    .PARAMETER ExcludeXmlAttachment
    By default, the raw XML will be attached. Use ExcludeXmlAttachment to send without the raw xml.

    .PARAMETER ExcludeCsvAttachment
    By default, a CSV will be attached. Use ExcludeCsvAttachment to send without the CSV data.

    .PARAMETER MaxNotifyInterval
    Max notify interval in minutes, based on Checks collection.
    
    .PARAMETER EnableException
    By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
    This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
    Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
        
    .EXAMPLE
    Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -OutputFormat NUnitXml -PassThru | 
    Send-DbcMailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SmtpServer smtp.ad.local
        
    Runs two tests against sql2017 and sends a mail message

#>
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [pscustomobject]$InputObject,
        [string[]]$To,
        [string]$From,
        [string]$Subject,
        [string]$Body,
        [string]$SmtpServer,
        [int]$Port,
        [string]$Priority,
        [string[]]$Attachments,
        [string[]]$Bcc,
        [string[]]$Cc,
        [switch]$BodyAsHtml,
        [PSCredential]$Credential,
        [string]$DeliveryNotificationOption,
        [string]$Encoding,
        [switch]$UseSsl,
        [switch]$ExcludeXmlAttachment,
        [switch]$ExcludeCsvAttachment,
        [switch]$ExcludeHtmlAttachment,
        [int]$MaxNotifyInterval,
        [string]$EnableException
    )
    begin {
        if ($MaxNotifyInterval) {
            # Gotta save the values somewhere - put it in wintemp
            $xmlfile = "$script:maildirectory\notify\max.xml"
            
            # Create initial data if it doesn't exist
            if (-not (Test-Path -Path "$script:maildirectory\notify")) {
                $null = New-Item -ItemType Directory -Path "$script:maildirectory\notify" -ErrorAction Stop
            }
            if (-not (Test-Path -Path $xmlfile)) {
                Export-Clixml -Path $xmlfile -InputObject $null
            }
        }
    }
    end {
        if ($InputObject.FailedCount -lt (Get-DbcConfig mail.failurethreshhold).value){
            Stop-PSFFunction -Message "Failure count of $($InputObject.FailedCount) is below configured threshold of $((Get-DbcConfig mail.failurethreshhold).value), not sending email" -Continue
        }

        if ($MaxNotifyInterval) {
            # get old values
            $notify = Import-Clixml -Path $xmlfile
            
            # Create distinct ID
            $tags = $InputObject.TagFilter -join ', '
            
            # See if it exists already in the file
            $match = $notify | Where-Object TagFilter -eq $tags
            
            # Check to see if it's time to send mail again
            if ($match) {
                if ($match.NotifyTime.AddMinutes($MaxNotifyInterval) -gt (Get-Date)) {
                    Stop-PSFFunction -Message "Mail for $tags won't be sent again until $($match.NotifyTime.AddMinutes($MaxNotifyInterval))" -Continue
                }
            }
            
            # Reset values (there's probably a better way to do this)
            $notify = $notify | Where-Object TagFilter -ne $tags
            $notify += [pscustomobject]@{
                TagFilter  = $tags
                NotifyTime = (Get-Date)
            }
            
            # Reexport values for next time
            $null = $notify | Export-Clixml -Path $xmlfile
        }
        
        if (Test-PSFParameterBinding -ParameterName Subject -Not) {
            $PSBoundParameters['Subject'] = (Get-DbcConfig -Name mail.Subject).value
        }
        if (Test-PSFParameterBinding -ParameterName To -Not) {
            $PSBoundParameters['To'] = (Get-DbcConfig -Name mail.To).value          
        }

        if ($null -eq $PSBoundParameters['To']) {
            Stop-PSFFunction -Message "No recipient email address specified, exiting" -Continue
        }
        if (Test-PSFParameterBinding -ParameterName smtpserver -Not) {
            $PSBoundParameters['smtpserver'] = (Get-DbcConfig -Name mail.smtpserver).value
        }
        if (Test-PSFParameterBinding -ParameterName from -Not) {
            $PSBoundParameters['from'] = (Get-DbcConfig -Name mail.from).value
        }
        if ($null -eq $PSBoundParameters['from']) {
            Stop-PSFFunction -Message "No sender email address specified, exiting" -Continue
        }
        
        $outputpath = "$script:maildirectory\index.html"
        $reportunit = "$script:ModuleRoot\bin\ReportUnit.exe"
        
        if (-not (Test-Path -Path $script:maildirectory)) {
            try {
                $null = New-Item -ItemType Directory -Path $script:maildirectory
            }
            catch {
                Stop-PSFFunction -Message "Failure" -ErrorRecord $_
                return
            }
        }
        
        if (-not ($xmlfiles = Get-ChildItem -Path "$script:maildirectory\*.xml")) {
            Stop-PSFFunction -Message "Oops, $("$script:maildirectory\*.xml") does not exist"
            return
        }
        
        foreach ($file in $xmlfiles) {
            $xml = [xml](Get-Content $file.FullName)
            $total = $xml.'test-results'.Total
            if ($total -eq 0) {
                $file | Remove-Item -ErrorAction SilentlyContinue
                Write-PSFMessage -Level Verbose -Message "Removed $file because it contained 0 total test results"
            }
            else {
                # I give up trynna parse this to CSV
                $csv = "$script:maildirectory\$($file.basename).csv"
                $results = $xml.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'
                $results | Export-Csv -Path $csv
                if (-not $ExcludeXmlAttachment) {
                    $Attachments += $csv
                }
                if (-not $ExcludeCsvAttachment) {
                    $Attachments += $csv
                }
            }
        }
        
        if (Get-ChildItem -Path "$script:maildirectory\*.xml") {
            try {
                # Output report
                & $reportunit $script:maildirectory
				
                if (-not $ExcludeHtmlAttachment) {
                    $htmlfiles = Get-ChildItem -Path "$script:maildirectory\*.html"
				    foreach ($file in $htmlfiles) {
					    $Attachments += $file
				    }
                }
                
                # Get HTML variable
                $htmlbody = Get-Content -Path $outputpath -ErrorAction SilentlyContinue | Out-String
                
                # Modify the params as required
                $null = $PSBoundParameters.Remove("InputObject")
                $null = $PSBoundParameters.Remove("ExcludeAttachment")
                $null = $PSBoundParameters.Remove("EnableException")
                $null = $PSBoundParameters.Remove('MaxNotifyInterval')
                $PSBoundParameters['Body'] = $htmlbody
                $PSBoundParameters['BodyAsHtml'] = $true
                if ($Attachments) {
                    $PSBoundParameters['Attachments'] = $Attachments
                }
                try {
                    Send-MailMessage -ErrorAction Stop @PSBoundParameters
                }
                catch {
                    Stop-PSFFunction -Message "Failure" -ErrorRecord $_
                    return
                }
            }
            catch {
                Stop-PSFFunction -Message "Failure" -ErrorRecord $_
                return
            }
            
            Get-ChildItem -Path "$script:maildirectory\*.*" | Remove-Item -ErrorAction SilentlyContinue
        }
        if (-not $InputObject) {
            Stop-PSFFunction -Message "InputObject is null. Did you forget to specify -Passthru for your previous command?"
            return
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUm5jHEmcKBBbPztnnl4OBvzn0
# hUCgggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS+PkdfKh7tEea4kNYv+mPH++HR
# wjANBgkqhkiG9w0BAQEFAASCAQCEZaTpJOPsb3t7e2BBhvufSITAp9gzp95V3M20
# 3RqEYM4lqWFIgN71gil7wnHRvaT21o+Gs2jruQihp9GH0sbTFYWhcA40Ztsx2t1Q
# 01CEi6m+NCqsXsL+la4JG0Vgp6ihdQelcxthjKpJk/LBLL2YFASapNYX5gFUjgyk
# QvcAuLDdXwiQuv9nfVJDdm9fFeSLgi03wXqN4JWSccmfhl6oeoz/dSVufeP1tPWE
# ce9Zfkaj/0lft7q5A6lf1cG89cTgJRT3DHQPD5g0BuoW1FjV7U0TK5MUFLZXOuzI
# SZrbwvL8YCPh9UrIz76ETnjkTZbwx6bkAsPWdKryQbRE0MHR
# SIG # End signature block

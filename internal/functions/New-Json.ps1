
function New-Json {
    [CmdletBinding(SupportsShouldProcess)]
    Param()
    # Parse repo for tags and descriptions then write json
    $script:localapp = Get-DbcConfigValue -Name app.localapp
    $repos = Get-CheckRepo
    $collection = $groups = $repofiles = @()
    foreach ($repo in $repos) {
        $repofiles += (Get-ChildItem "$repo\*.Tests.ps1")
    }

    $tokens = $null
    $errors = $null
    foreach ($file in $repofiles) {
        $Check = $null
        $filename = $file.Name.Replace(".Tests.ps1", "")

      #  Write-Verbose "Processing $FileName"
      #  Write-Verbose "Getting Content of File"
        $Check = Get-Content $file -Raw

        # because custom checks if they are not coded correctly will break this json creation
        # and they wont get added nicely so that they can be targetted with tags (checks)
        # this part will check all of the files and ensure that they have the filename variabel at the top and that
        # each describe is using Tags not Tag and the last tag is the $filename

        if ($Filename -notin ('Agent','Database','Domain','HADR','Instance','LogShipping','MaintenanceSolution','Server')) {

            #all checks files MUST have this at the top
            if ($Check -notmatch '\$filename = \$MyInvocation\.MyCommand\.Name\.Replace\("\.Tests\.ps1", ""\)') {
                Write-Verbose "$Filename does not have the correct value at the top so we will add it"
                $filecontent = @"
    `$filename = `$MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

"@
                $filecontent = $filecontent + $Check
                if ($PSCmdlet.ShouldProcess("$($File.Name)" , "Adding the filename variable to the file")) {
                    $Check = $null
                    Set-Content -Path $file -Value $filecontent
                    Write-Verbose "Getting Content of File again"
                    $Check = Get-Content $file -Raw
                }

            }

            ## Parse the file with AST
            $CheckFileAST = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors)

            #Check that the tags are set correctly otherwise the json doesnt get properly created
            $Statements = $CheckFileAST.EndBlock.statements.Extent
            ## Ignore the filename line
            @($Statements.Where{$PSItem.StartLineNumber -ne 1}).ForEach{
              #  Write-Verbose "Checking the Describe Tag $($PSItem.Text.SubString(0,50) )"
                if ($PSItem.Text -notmatch 'Describe ".*" -Tags .*,.*\$filename \{') {
                    $RogueDescribe = $PSItem.Text.SubString(0, $PSitem.Text.IndexOf('{'))
                    Write-Warning "The Describe Tag $RogueDescribe in $($File.Name) is not set up correctly - we will try to fix it for you"
                    $replace = $RogueDescribe + ', $Filename '
                    $Check = $Check -replace $RogueDescribe , $replace
                    $Check = $Check -replace '-Tag ', '-Tags '
                    if ($PSCmdlet.ShouldProcess("$($File.Name)" , "Fixing the tags on the files")) {
                        Set-Content $file -Value $Check
                        $Check = $null
                    }
                  #  Write-Verbose "Getting Content of File again"
                    $Check = Get-Content $file -Raw

                }
            }
        }

        ## Parse the file with AST
        $CheckFileAST = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors)

        ## New code uses a Computer Name loop to speed up execution so need to find that as well
        $ComputerNameForEach = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $ast.expression.Subexpression.Extent.Text -eq 'Get-ComputerName'
            }, $true).Extent

        ## New code uses a Computer Name loop to speed up execution so need to find that as well
        $InstanceNameForEach = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $ast.expression.Subexpression.Extent.Text -eq 'Get-Instance'
            }, $true).Extent


        ## Old code we can use the describes
        $Describes = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast.CommandElements -and
                $ast.CommandElements[0].Value -eq 'Describe'
            }, $true)

        @($describes).ForEach{
            $groups += $filename
            $Describe = $_.CommandElements.Where{$PSItem.StaticType.name -eq 'string'}[1]
            $title = $Describe.Value
            $Tags = $PSItem.CommandElements.Where{$PSItem.StaticType.name -eq 'Object[]' -and $null -eq $psitem.Value}.Extent.Text.ToString().Replace(', $filename', '')
            # CHoose the type
            if ($Describe.Parent -match "Get-Instance") {
                $type = "Sqlinstance"
            }
            elseif ($Describe.Parent -match "Get-ComputerName" -or $Describe.Parent -match "AllServerInfo") {
                $type = "ComputerName"
            }
            elseif ($Describe.Parent -match "Get-ClusterObject") {
                $Type = "ClusterNode"
            }
            else {
                #Choose the type from the new way from inside the foreach
                if ($ComputerNameForEach -match $title) {
                    $type = "ComputerName"
                }
                elseif ($InstanceNameForEach -match $title) {
                    $type = "Sqlinstance"
                }
                else {
                    $type = $null
                }
            }

            if ($filename -eq 'HADR') {
                ## HADR configs are outside of describe
                $configs = [regex]::matches($check, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
            }
            else {
                $configs = [regex]::matches($describe.Parent.Extent.Text, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
            }
            $Config = ''
            foreach ($c in $Configs) {$config += "$c "} # DON't DELETE THE SPACE in "$c "
            if ($filename -eq 'MaintenanceSolution') {
                # The Maintenance Solution needs a bit of faffing as the configs for the jobnames are used to create the titles
                switch ($tags -match $PSItem) {
                    {$Tags.Contains('SystemFull')} {
                        $config = 'ola.JobName.SystemFull ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.systemfull)
                    }
                    {$Tags.Contains('UserFull')} {
                        $config = 'ola.JobName.UserFull ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userfull)
                    }
                    {$Tags.Contains('UserDiff')} {
                        $config = 'ola.JobName.UserDiff ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userdiff)
                    }
                    {$Tags.Contains('UserLog')} {
                        $config = 'ola.JobName.UserLog ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userlog)
                    }
                    {$Tags.Contains('CommandLog')} {
                        $config = 'ola.JobName.CommandLogCleanup ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.commandlogcleanup)
                    }
                    {$Tags.Contains('SystemIntegrityCheck')} {
                        $config = 'ola.JobName.SystemIntegrity ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.systemintegrity)
                    }
                    {$Tags.Contains('UserIntegrityCheck')} {
                        $config = 'ola.JobName.UserIntegrity ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userintegrity)
                    }
                    {$Tags.Contains('UserIndexOptimize')} {
                        $config = 'ola.JobName.UserIndex ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userindex)
                    }
                    {$Tags.Contains('OutputFileCleanup')} {
                        $config = 'ola.JobName.OutputFileCleanup ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.outputfilecleanup)
                    }
                    {$Tags.Contains('DeleteBackupHistory')} {
                        $config = 'ola.JobName.DeleteBackupHistory ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.deletebackuphistory)
                    }
                    {$Tags.Contains('PurgeJobHistory')} {
                        $config = 'ola.JobName.PurgeBackupHistory ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.purgebackuphistory)
                    }
                    Default {}
                }
            }
            # add the config for the type
            switch ($type) {
                SqlInstance {$config = 'app.sqlinstance ' + $config}
                ComputerName {$config = 'app.computername ' + $config}
                ClusterNode {$config = 'app.sqlinstance ' + $config}
                Default {}
            }
            if (-not $config) {$config = "None"}
            $collection += [pscustomobject]@{
                Group       = $filename
                Type        = $type
                UniqueTag   = $null
                AllTags     = "$tags, $filename"
                Config      = $config
                Description = $null
                Describe    = $title
            }
        }
    }
    $singletags = (($collection.AllTags -split ",").Trim() | Group-Object | Where-Object { $_.Count -eq 1 -and $_.Name -notin $groups })
    $Descriptions = Get-Content $script:ModuleRoot\internal\configurations\DbcCheckDescriptions.json -Raw| ConvertFrom-Json
    foreach ($check in $collection) {
        $unique = $singletags | Where-Object { $_.Name -in ($check.AllTags -split ",").Trim() }
        $check.UniqueTag = $unique.Name
        $Check.Description = $Descriptions.Where{$_.UniqueTag -eq $Check.UniqueTag}.Description
    }
    try {
        if ($PSCmdlet.ShouldProcess("$script:localapp\checks.json" , "Convert Json and write to file")) {
            ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"
        }
    }
    catch {
        Write-PSFMessage "Failed to create the json, something weird might happen now with tags and things" -Level Significant
    }

}

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0fsGvoQJI0G5lwItZwPc8ygM
# nrygggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSFlHCk9kkbEHMP6SbUWCpFhRbv
# szANBgkqhkiG9w0BAQEFAASCAQAiP1lNcNdaKY065b33HryiBTn57LaR6OTKewO9
# 3JXKRI/FfKC/5a+4RlOKRZ4oSSto0fqbWejnbD+9y3+pGmVcf7BEDJRcIuD6N9b4
# xsvyavfUoX/w5QXnmlaeLB+WukDYv1Obk0eN0oWxAFhIv900kWIKje9j2GvouJwu
# cFetZq1yVb8qcO5O3XoIfhrkQ7aoITtAyaO4MId9OXhM/d5zq1L9IX55tTKH4y6a
# OOCWV3FU7pZh1zPQHz/PO3bOEnG91RXHCGtwstbCe1mwyY1Qg9ogvyXmnNQOU/eZ
# nkOaE9W4Lw0824NXGGigInpdcCaEqXKuzWCrHXKW54pd+orW
# SIG # End signature block

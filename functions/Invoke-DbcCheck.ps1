<#
.SYNOPSIS
Invoke-DbcCheck is a SQL-centric Invoke-Pester wrapper

.DESCRIPTION
The Invoke-DbcCheck function runs Pester tests, including *.Tests.ps1 files and Pester tests in PowerShell scripts.

Extended description about Pester: Get-Help -Name Invoke-Pester

.PARAMETER Check
Runs only tests in Describe blocks with the specified Tag parameter values. Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

When you specify multiple Tag values, Invoke-DbcCheck runs tests that have any of the listed tags (it ORs the tags). However, when you specify TestName and Tag values, Invoke-DbcCheck runs only describe blocks that have one of the specified TestName values and one of the specified Tag values.

If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

.PARAMETER ExcludeCheck
Omits tests in Describe blocks with the specified Tag parameter values. Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

When you specify multiple ExcludeTag values, Invoke-DbcCheck omits tests that have any of the listed tags (it ORs the tags). However, when you specify TestName and ExcludeTag values, Invoke-DbcCheck omits only describe blocks that have one of the specified TestName values and one of the specified Tag values.

If you use both Tag and ExcludeTag, ExcludeTag takes precedence

.PARAMETER SqlInstance
A list of SQL Servers to run the tests against. If this is not provided, it will be gathered from:
Get-DbatoolsConfig -Name app.sqlinstance

.PARAMETER ComputerName
A list of computers to run the tests against. If this is not provided, it will be gathered from:
Get-DbatoolsConfig -Name app.computername

.PARAMETER SqlCredential
Alternate SQL Server-based credential.

.PARAMETER Credential
Alternate Windows credential.

.PARAMETER Database
A list of databases to include if your check is database centric.

.PARAMETER ExcludeDatabase
A list of databases to exclude if your check is database centric.

.PARAMETER PassThru
Returns a custom object (PSCustomObject) that contains the test results.

By default, Invoke-DbcCheck writes to the host program, not to the output stream (stdout).
If you try to save the result in a variable, the variable is empty unless you
use the PassThru parameter.

To suppress the host output, use the Quiet parameter.

.PARAMETER ConfigFile
The path to the exported dbachecks config file.

.PARAMETER OutputFormat
The format of output. Currently, only NUnitXML is supported.

.PARAMETER Strict
Makes Pending and Skipped tests to Failed tests. Useful for continuous integration where you need to make sure all tests passed.

.PARAMETER AllChecks
In the unlikely event that you'd like to run all checks, specify -AllChecks. These checks still confirm to the skip settings in Get-DbcConfig.

.PARAMETER Quiet
The parameter Quiet is deprecated since Pester v. 4.0 and will be deleted in the next major version of Pester. Please use the parameter Show with value 'None' instead.

.PARAMETER Show
Customizes the output Pester writes to the screen.

Available options are
None
Default
Passed
Failed
Pending
Skipped
Inconclusive
Describe
Context
Summary
Header
All
Fails

The options can be combined to define presets.

Common use cases are:

None - to write no output to the screen.
All - to write all available information (this is default option).
Fails - to write everything except Passed (but including Describes etc.).

A common setting is also Failed, Summary, to write only failed tests and test summary.

This parameter does not affect the PassThru custom object or the XML output that is written when you use the Output parameters.

.PARAMETER Value
A value.. it's hard to explain

.PARAMETER Script
Get-Help -Name Invoke-Pester -Parameter Script

.PARAMETER TestName
Get-Help -Name Invoke-Pester -Parameter TestName

.PARAMETER EnableExit
Get-Help -Name Invoke-Pester -Parameter EnableExit

.PARAMETER OutputFile
Get-Help -Name Invoke-Pester -Parameter OutputFile

.PARAMETER CodeCoverage
Get-Help -Name Invoke-Pester -Parameter CodeCoverage

.PARAMETER PesterOption
Get-Help -Name Invoke-Pester -Parameter PesterOption

.PARAMETER CodeCoverageOutputFile
Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFile

.PARAMETER CodeCoverageOutputFileFormat
Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFileFormat

.LINK
https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/

.EXAMPLE
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016

Runs all of the checks tagged Backup against the sql2016 instance

.EXAMPLE
Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster -SqlCredential (Get-Credential sqladmin)

Runs the Recovery model check against the SQL instances sql2017, sqlcluster
using the sqladmin SQL login with the password provided interactively

.EXAMPLE
Invoke-DbcCheck -Check Database -ExcludeCheck AutoShrink -ConfigFile \\share\repo\prod.json

Runs all of the checks tagged Database except for the AutoShrink check against
the SQL Instances set in the config under app.sqlinstance

Imports configuration file, \\share\repo\prod.json, prior to executing checks.

.EXAMPLE
# Set the servers you'll be working with
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008

# Look at the current configs
Get-DbcConfig

# Invoke a few tests
Invoke-DbcCheck -Tags SuspectPage, LastBackup

Runs the Suspect Pages and Last Backup checks against the SQL Instances sql2016,
sql2017, sql2008, sql2008\express after setting them in the configuration

.EXAMPLE
Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource

Start-DbcPowerBi

Runs the Suspect Page and Last Backup checks against the SQL Instances set in
the config under app.sqlinstance only showing the summary of the results of the
checks. It then updates the source json for the XML which is stored at
C:\Windows\temp\dbachecks\ and then opens the PowerBi report in PowerBi Desktop

.EXAMPLE
Get-Help -Name Invoke-Pester -Examples

Want to get super deep? You can look at Invoke-Pester's example's and run them against Invoke-DbcCheck since it's a wrapper.

https://github.com/pester/Pester/wiki/Invoke-Pester

Describe
about_Pester
#>

function Invoke-DbcCheck {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification='Because scoping is hard')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Because its set to the global var')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Alias('Path', 'relative_path')]
        [object[]]$Script,
        [Alias("Name")]
        [string[]]$TestName,
        [switch]$EnableExit,
        [Parameter(Position = 0)]
        [Alias("Tags", "Tag", "Checks")]
        [string[]]$Check,
        [AllowEmptyCollection()]
        [Alias("ExcludeTags", "ExcludeTag", "ExcludeChecks")]
        [string[]]$ExcludeCheck = (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludecheck' -Fallback @()),
        [switch]$PassThru,
        [DbaInstance[]]$SqlInstance,
        [DbaInstance[]]$ComputerName,
        [PSCredential]$SqlCredential,
        [PSCredential]$Credential,
        [object[]]$Database,
        [object[]]$ExcludeDatabase = (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludedatabase' -Fallback @()),
        [string[]]$Value,
        [string]$ConfigFile,
        [object[]]$CodeCoverage = @(),
        [string]$CodeCoverageOutputFile,
        [ValidateSet('JaCoCo')]
        [string]$CodeCoverageOutputFileFormat = "JaCoCo",
        [switch]$Strict,
        [Parameter(Mandatory = $true, ParameterSetName = 'NewOutputSet')]
        [string]$OutputFile,
        [ValidateSet('NUnitXml')]
        [string]$OutputFormat,
        [switch]$AllChecks,
        [switch]$Quiet,
        [object]$PesterOption,
        [string]$Show = 'All'
    )

    dynamicparam {
        $config = Get-PSFConfig -Module dbachecks

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        foreach ($setting in $config) {
            $name = $setting.Name
            $name = "Config" + (($name.Split(".") | ForEach-Object { $_.SubString(0, 1).ToUpper() + $_.SubString(1) }) -join '')
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.ParameterSetName = '__AllParameterSets'
            $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)

            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($name, [object], $AttribColl)

            $RuntimeParamDic.Add($name, $RuntimeParam)
        }
        return $RuntimeParamDic
    }

    begin {
        if (Test-PSFParameterBinding -ParameterName ConfigFile) {
            if (-not (Test-Path -Path $ConfigFile)) {
                Stop-PSFFunction -Message "$ConfigFile does not exist"
                return
            }
            $null = Import-DbcConfig -Path $ConfigFile -WarningAction SilentlyContinue -Temporary
        }

        $config = Get-PSFConfig -Module dbachecks
        foreach ($key in $PSBoundParameters.Keys | Where-Object { $_ -like "Config*" }) {
            if ($item = $config | Where-Object { "Config$($_.Name.Replace('.', ''))" -eq $key }) {
                Set-PSFConfig -Module dbachecks -Name $item.Name -Value $PSBoundParameters.$key
            }
        }

        if ($SqlCredential) {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*:SqlCredential')
                $newvalue = $PSDefaultParameterValues += @{ '*:SqlCredential' = $SqlCredential }
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
            }
            else {
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $SqlCredential }
            }
        }
        else {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*:SqlCredential')
            }
        }

        if ($Credential) {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*Dba*:Credential')
                $newvalue = $PSDefaultParameterValues += @{ '*Dba*:Credential' = $Credential }
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
            }
            else {
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*Dba*:Credential' = $Credential }
            }
        }
        else {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*Dba*:Credential')
            }
        }
    }

    process {
        if (Test-PSFFunctionInterrupt) { return }

        #get the output config for dbatools and store it to set it back at the end
        $dbatoolsoutputconfig = Get-DbatoolsConfigValue -FullName message.consoleoutput.disable
        if (!$dbatoolsoutputconfig) {
            Set-DbatoolsConfig -FullName message.consoleoutput.disable -Value $true
        }


        if (-not $Script -and -not $TestName -and -not $Check -and -not $ExcludeCheck -and -not $AllChecks) {
            Stop-PSFFunction -Message "Please specify Check, ExcludeCheck, Script, TestName or AllChecks"
            return
        }

        if (-not $SqlInstance.InputObject -and -not $ComputerName.InputObject -and -not (Get-PSFConfigValue -FullName dbachecks.app.sqlinstance) -and -not (Get-PSFConfigValue -FullName dbachecks.app.computername) -and -not (Get-PSFConfigValue -FullName dbachecks.app.cluster)) {
            Stop-PSFFunction -Message "No servers set to run against. Use Get/Set-DbcConfig to setup your servers or Get-Help Invoke-DbcCheck for additional options."
            return
        }

        $customparam = 'SqlInstance', 'ComputerName', 'SqlCredential', 'Credential', 'Database', 'ExcludeDatabase', 'Value'

        foreach ($param in $customparam) {
            if (Test-PSFParameterBinding -ParameterName $param) {
                $value = Get-Variable -Name $param
                if ($value.InputObject) {
                    Set-Variable -Scope 0 -Name $param -Value $value.InputObject -ErrorAction SilentlyContinue
                    $PSDefaultParameterValues.Add( { "*-Dba*:$param", $value.InputObject })
                }
            }
            else {
                $PSDefaultParameterValues.Remove( { "*-Dba*:$param" })
            }
            $null = $PSBoundParameters.Remove($param)
        }


        # Lil bit of cleanup here, for a switcharoo
        $null = $PSBoundParameters.Remove('AllChecks')
        $null = $PSBoundParameters.Remove('Check')
        $null = $PSBoundParameters.Remove('ExcludeCheck')
        $null = $PSBoundParameters.Remove('ConfigFile')
        $null = $PSBoundParameters.Add('Tag', $Check)
        $null = $PSBoundParameters.Add('ExcludeTag', $ExcludeCheck)

        $globalexcludedchecks = Get-PSFConfigValue -FullName dbachecks.command.invokedbccheck.excludecheck
        $global:ChecksToExclude = $ExcludeCheck + $globalexcludedchecks
        [string[]]$Script:ExcludedDatabases = Get-PSFConfigValue -FullName dbachecks.command.invokedbccheck.excludedatabases
        $Script:ExcludedDatabases += $ExcludeDatabase


        foreach ($singlecheck in $check) {
            if ($singlecheck -in $globalexcludedchecks) {
                Write-PSFMessage -Level Warning -Message "$singlecheck is excluded in command.invokedbccheck.excludecheck and will be skipped "
            }
        }

        if ($AllChecks -and $globalexcludedchecks) {
            Write-PSFMessage -Level Warning -Message "$globalexcludedchecks will be skipped"
        }

        if ($ExcludedDatabases) {
            Write-PSFMessage -Level Warning -Message "$ExcludedDatabases databases will be skipped for all checks"
        }

        # Then we'll need a generic param passer that doesn't require global params
        # cuz global params are hard

        $finishedAllTheChecks = $false
        try {
            $repos = Get-CheckRepo
            foreach ($repo in $repos) {
                if ((Test-Path $repo -ErrorAction SilentlyContinue)) {
                    if ($OutputFormat -eq "NUnitXml" -and -not $OutputFile) {
                        $number = $repos.IndexOf($repo)
                        $timestamp = Get-Date -format "yyyyMMddHHmmss"
                        $PSBoundParameters['OutputFile'] = "$script:maildirectory\report-$number-$pid-$timestamp.xml"
                    }

                    if ($Check.Count -gt 0) {
                        # specific checks were listed. find the necessary script files.
                        $PSBoundParameters['Script'] = (Get-CheckFile -Repo $repo -Check $check)
                    }

                    Push-Location -Path $repo
                    ## remove any previous entries ready for this run
                    Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value @()
                    Invoke-Pester @PSBoundParameters
                    Pop-Location
                }
            }
            $finishedAllTheChecks = $true
        }
        catch {
            Stop-PSFFunction -Message "There was a problem executing Invoke-Pester" -ErrorRecord $psitem
        }
        finally {
            # reset the config to original value
            Set-DbatoolsConfig -FullName message.consoleoutput.disable -Value $dbatoolsoutputconfig

            if (!($finishedAllTheChecks)) {
                Write-PSFMessage -Level Warning -Message "Execution was cancelled!"
                Pop-Location
            }
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbjAY6hEQPnXqnkJD67xORkU6
# Oz6gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRERRxXc70li4eB3EwYuK4smcCI
# GTANBgkqhkiG9w0BAQEFAASCAQAvDO+mmO/g9iyv+ADpwMfIwX7c3kFjv6KqdH8f
# waXf9cesRsFHbG0HN9kDss2QThaS5Zth5jCBJDhUem4CTiPNyoCaTA8gHAjB9f81
# U6SJZR2h25INctVJW9mqrhzQu4hXqXTMGC4N9nM+MPbE3V0L2sPgBkh+3kHoOgML
# 0/G27HS8hvYdkrsEa80WGzDivF+YNIcJ7MV5KDpllv37wa2hHDq3qy+Yz8WoUGQr
# BF3HB8sgjcDuX1gbRLta4CCuz+0z1lXfUAUrktNRk4W3ghxRn1aW/RmudRKnuzV5
# PUD8vvXCGgjhERofziwYsEWkTagp/7bRYQ0Orl5h0GBHI1QU
# SIG # End signature block

[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification='Because scoping is hard')]
Param()
<#
    .NOTES
        ===========================================================================
        Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.119
        Created on:   	4/12/2016 1:11 PM
        Created by:   	June Blender
        Organization: 	SAPIEN Technologies, Inc
        Filename:		*.Help.Tests.ps1
        ===========================================================================
    .DESCRIPTION
    To test help for the commands in a module, place this file in the module folder.
    To test any module from any path, use https://github.com/juneb/PesterTDD/Module.Help.Tests.ps1
#>
if ($SkipHelpTest) { return }
. "$PSScriptRoot\InModule.Help.Exceptions.ps1"

$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path

# This should stop people making breaking changes to the tests without first altering the test
Remove-Module dbachecks -Force -ErrorAction SilentlyContinue
Import-Module $ModuleBase\..\dbachecks.psd1

$includedNames = (Get-ChildItem "$PSScriptRoot\..\functions" | Where-Object Name -like "*.ps1" ).BaseName
$commands = Get-Command -Module (Get-Module dbachecks) -CommandType Cmdlet, Function | Where-Object Name -in $includedNames

## When testing help, remember that help is cached at the beginning of each session.
## To test, restart session.


foreach ($command in $commands) {
    $commandName = $command.Name

    # Skip all functions that are on the exclusions list
    if ($global:FunctionHelpTestExceptions -contains $commandName) { continue }

    # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
    $Help = Get-Help $commandName -ErrorAction SilentlyContinue
    $testhelperrors = 0
    $testhelpall = 0
    Describe "Test help for $commandName" -Tag Help{

        $testhelpall += 1
        if ($Help.Synopsis -like '*`[`<CommonParameters`>`]*') {
            # If help is not found, synopsis in auto-generated help is the syntax diagram
            It "should not be auto-generated" {
                $Help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
            }
            $testhelperrors += 1
        }

        $testhelpall += 1
        if ([String]::IsNullOrEmpty($Help.Description.Text)) {
            # Should -Be a description for every function
            It "gets description for $commandName" {
                $Help.Description | Should Not BeNullOrEmpty
            }
            $testhelperrors += 1
        }

        $testhelpall += 1
        if ([String]::IsNullOrEmpty(($Help.Examples.Example | Select-Object -First 1).Code)) {
            # Should -Be at least one example
            It "gets example code from $commandName" {
                ($Help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
            }
            $testhelperrors += 1
        }

        $testhelpall += 1
        if ([String]::IsNullOrEmpty(($Help.Examples.Example.Remarks | Select-Object -First 1).Text)) {
            # Should -Be at least one example description
            It "gets example help from $commandName" {
                ($Help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
            }
            $testhelperrors += 1
        }

        if ($testhelperrors -eq 0) {
            It "Ran silently $testhelpall tests" {
                $testhelperrors | Should -Be 0
            }
        }

        $testparamsall = 0
        $testparamserrors = 0
        Context "Test parameter help for $commandName" {

            $Common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'Confirm', 'WhatIf'

            $parameters = $command.ParameterSets.Parameters | Where-Object {$psitem.IsDynamic -eq $false} | Sort-Object -Property Name -Unique | Where-Object Name -notin $common
            $parameterNames = $parameters.Name
            $HelpParameterNames = ($Help.Parameters.Parameter | Sort-Object -Unique | Where-Object Name -notin $common).Name
            foreach ($parameter in $parameters) {
                $parameterName = $parameter.Name
                $parameterHelp = $Help.parameters.parameter | Where-Object Name -EQ $parameterName

                $testparamsall += 1
                if ([String]::IsNullOrEmpty($parameterHelp.Description.Text)) {
                    # Should -Be a description for every parameter
                    It "gets help for parameter: $parameterName : in $commandName" {
                        $parameterHelp.Description.Text | Should Not BeNullOrEmpty
                    }
                    $testparamserrors += 1
                }

                $testparamsall += 1
                $codeMandatory = $parameter.IsMandatory.toString()
                if ($parameterHelp.Required -ne $codeMandatory) {
                    # Required value in Help should match IsMandatory property of parameter
                    It "help for $parameterName parameter in $commandName has correct Mandatory value" {
                        $parameterHelp.Required | Should -Be $codeMandatory
                    }
                    $testparamserrors += 1
                }

                if ($HelpTestSkipParameterType[$commandName] -contains $parameterName) { continue }

                $codeType = $parameter.ParameterType.Name

                $testparamsall += 1
                if ($parameter.ParameterType.IsEnum) {
                    # Enumerations often have issues with the typename not being reliably available
                    $names = $parameter.ParameterType::GetNames($parameter.ParameterType)
                    if ($parameterHelp.parameterValueGroup.parameterValue -ne $names) {
                        # Parameter type in Help should match code
                        It "help for $commandName has correct parameter type for $parameterName" {
                            $parameterHelp.parameterValueGroup.parameterValue | Should -Be $names
                        }
                        $testparamserrors += 1
                    }
                }
                elseif ($parameter.ParameterType.FullName -in $HelpTestEnumeratedArrays) {
                    # Enumerations often have issues with the typename not being reliably available
                    $names = [Enum]::GetNames($parameter.ParameterType.DeclaredMembers[0].ReturnType)
                    if ($parameterHelp.parameterValueGroup.parameterValue -ne $names) {
                        # Parameter type in Help should match code
                        It "help for $commandName has correct parameter type for $parameterName" {
                            $parameterHelp.parameterValueGroup.parameterValue | Should -Be $names
                        }
                        $testparamserrors += 1
                    }
                }
                else {
                    # To avoid calling Trim method on a null object.
                    $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                    if ($helpType -ne $codeType ) {
                        # Parameter type in Help should match code
                        It "help for $commandName has correct parameter type for $parameterName" {
                            $helpType | Should -Be $codeType
                        }
                        $testparamserrors += 1
                    }
                }
            }
            foreach ($helpParm in $HelpParameterNames) {
                $testparamsall += 1
                if ($helpParm -notin $parameterNames) {
                    # Shouldn't find extra parameters in help.
                    It "finds help parameter in code: $helpParm" {
                        $helpParm -in $parameterNames | Should -BeTrue
                    }
                    $testparamserrors += 1
                }
            }
            if ($testparamserrors -eq 0) {
                It "Ran silently $testparamsall tests" {
                    $testparamserrors | Should -Be 0
                }
            }
        }
    }
}

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOQn6XAVOZu8FeBq7y4vF/V80
# Ql+gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSpQbpEdfnW1M5JjD64yU8Znowk
# wDANBgkqhkiG9w0BAQEFAASCAQAoX/M2RgLM/kBzs2Xur4w685CT6/OQDx62w/zb
# 3xAswvDioABnxZmhjIbszBFRjn7rTxtoPa67GlPl2BI4OD+LZNv8aTVkep+PxrZW
# ZzJ4XcYQHgdIlT3AGmLVYQseeLNbJBaeWNNuxTFkRhvk6lGHT30K/jMBjYr776LX
# 2qJxNeGLQP/JZxjLWRTalPZxxanrG+hsnM3n+soVhLnLZndIJ6CP+JLzDti9U4+z
# j5XoyG1wIIEL1gbqAplNc6g/2xbqburtmZVhkG/4mczp7FWyhIWnSaNG/aX8Z+1G
# O8Q4dkiV7eMLQgeMopXUJWxVNBv/dVVL31QaQu76S77SI4jX
# SIG # End signature block

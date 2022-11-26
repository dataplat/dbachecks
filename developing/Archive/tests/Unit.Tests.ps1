$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path
# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Tests') {
    $ModuleBase = Split-Path $ModuleBase -Parent
}

# This should stop people making breaking changes to the tests without first altering the test
Remove-Module dbachecks -Force -ErrorAction SilentlyContinue
Import-Module $ModuleBase\dbachecks.psd1

$tokens = $null
$errors = $null
Describe "Checking that each dbachecks Pester test is correctly formatted for Power Bi and Coded correctly" -Tags UnitTest {
    $Checks = (Get-ChildItem $ModuleBase\checks) #.Where{$PSItem.Name -eq 'Agent.Tests.ps1'}
    $Checks.ForEach{
        $CheckName = $psitem.Name
        $Check = Get-Content $PSItem.FullName -Raw
        Context "$($PSItem.Name) - Checking Describes titles and tags" {
            $UniqueTags = (Get-DbcCheck).UniqueTag
            ## This gets all of the code with a describe
            $Describes = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
            FindAll([Func[Management.Automation.Language.Ast, bool]] {
                    param ($ast)
                    $ast.CommandElements -and
                    $ast.CommandElements[0].Value -eq 'describe'
                }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                $tagIdx = $CE.IndexOf(($CE | Where-Object ParameterName -eq 'Tags')) + 1
                $tags = if ($tagIdx -and $tagIdx -lt $CE.Count) {
                    $CE[$tagIdx].Extent
                }
                New-Object PSCustomObject -Property @{
                    Name = $secondString
                    Tags = $tags
                }
            }
            @($describes).ForEach{
                $title = $PSItem.Name.ToString().Trim('"').Trim('''')
                It "The Describe Title - $title - Should Use a double quote after the Describe" {
                    $PSItem.Name.ToString().Startswith('"') | Should -BeTrue -Because 'You need to alter the title of the Describe - We need use double quotes for titles'
                    $PSItem.Name.ToString().Endswith('"') | Should -BeTrue -Because 'You need to alter the title of the Describe - We need use double quotes for titles'
                }
                It "The Describe Title - $title - should use a plural for tags" {
                    $PSItem.Tags | Should -Not -BeNullOrEmpty -Because 'You need to alter the tags parameter of the Describe - We use the plural of Tags'
                }
                # a simple test for no esses apart from statistics and Access!!
                if ($null -ne $PSItem.Tags) {
                    $PSItem.Tags.Text.Split(',').Trim().Where{ ($PSItem -ne '$filename') -and ($PSItem -notlike '*statistics*') -and ($PSItem -notlike '*BackupPathAccess*') -and ($PSItem -notlike '*OlaJobs*') -and ($PSItem -notlike '*status*') -and ($PSItem -notlike '*exists') -and ($PSItem -notlike '*Ops') }.ForEach{
                        It "The Describe Title - $title - Tags parameter $PSItem should be Singular" {
                            $PSItem.ToString().Endswith('s') | Should -BeFalse -Because 'You need to alter the tags for this Describe OR alter this test if the tag makes sense - Our coding standards say tags should be singular'
                        }
                    }
                    It "The Describe Title - $title - The first Tag $($PSItem.Tags.Text.Split(',')[0]) should be in the unique Tags returned from Get-DbcCheck" {
                        $UniqueTags | Should -Contain $PSItem.Tags.Text.Split(',')[0].ToString() -Because 'We need a unique tag for each test - Format should be -Tags space UniqueTag comma - Also if you are running this on a machine where dbachecks has already been imported previously try running reset-dbcconfig, which will create a new checks.json for Get-DbcCheck'
                    }
                }
                else {
                    It "The Describe Title - $title - You haven't used the Tags Parameter so we can't check the tags" {
                        $false | Should -BeTrue -Because 'You need to alter the Describe - We use the Tags parameter'
                    }
                }
            }
        }
        Context "$($PSItem.Name) - Checking Contexts" {
            ## Find the Contexts
            $Contexts = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
            FindAll([Func[Management.Automation.Language.Ast, bool]] {
                    param ($ast)
                    $ast.CommandElements -and
                    $ast.CommandElements[0].Value -eq 'Context'
                }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                New-Object PSCustomObject -Property @{
                    Name = $secondString
                }
            }

            @($Contexts).ForEach{
                $title = $PSItem.Name.ToString().Trim('"').Trim('''')
                It "The Context Title - $Title - Should end with `$PSItem (or `$clustername) So that the PowerBi will work correctly" {
                    $PSItem.Name.ToString().Endswith('psitem"') -or $PSItem.Name.ToString().Endswith('clustername"')  -or $PSItem.Name.ToString().Endswith('SqlInstance"')  | Should -BeTrue -Because 'You need to alter the title of the Context - This helps the PowerBi to parse the data'
                }
            }
        }
        Context "$($PSItem.Name) - Checking the Its" {
            $CheckName = $psitem.Name
            ## Find the Its
            $Its = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
            FindAll([Func[Management.Automation.Language.Ast, bool]] {
                    param ($ast)
                    $ast.CommandElements -and
                    $ast.CommandElements[0].Value -eq 'It'
                }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                New-Object PSCustomObject -Property @{
                    Name = $secondString
                }
            }


            @($Its).ForEach{
                $title = $PSItem.Name.ToString().Trim('"').Trim('''')
                It "The It Title - $Title - Should end with the right ending so that the PowerBi will work correctly" {
                    $Lower = $PSItem.Name.ToString().ToLower()
                    $Lower.Endswith('psitem"') -or $Lower.Endswith('clustername"') -or $Lower.EndsWith('server)"') -or $Lower.EndsWith('name)"') -or $Lower.EndsWith('name"') -or $Lower.EndsWith('instance"') -or $Lower.EndsWith('instance)"') -or $Lower.EndsWith('domain)"') -or $Lower.EndsWith('domain"') -or $Lower.EndsWith('replica)"') | Should -BeTrue -Because 'You need to alter the title of the It, it should end with the instance name or computername - This helps the PowerBi to parse the data'
                }
                if ($CheckName -eq 'Database.Tests.ps1') {
                    It "The It Title - $Title - Should begin with - Database" {
                        $PSItem.Name.ToString().StartsWith('"Database') -or $PSItem.Name.ToString().StartsWith('"Can') | Should -BeTrue -Because 'You need to alter the It Title to start with Database (or Can t Connect) - For the database checks we can parse them and make magic'
                    }
                }
            }
        }
        Context "$($PSItem.Name) - Checking Code" {
            $CheckName = $psitem.Name
            ## This just grabs all the code
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($Check, [ref]$null, [ref]$null)
            $Statements = $AST.EndBlock.statements.Extent
            ## Ignore the filename line
            @($Statements.Where{ $PSItem.StartLineNumber -ne 1 }).ForEach{
                # make sure we only regex if the title contains a describe
                if ($PSItem.Text -match 'Describe') {
                    $title = [regex]::matches($PSItem.text, "Describe(.*)-Tag").groups[1].value.Replace('"', '').Replace('''', '').trim()
                    if ($title -ne 'Cluster $clustername Health using Node $clustervm') {
                        It "Describe - $title - Should Use Get-Instance or Get-ComputerName" {
                            ($PSItem.text -Match 'Get-Instance') -or ($PSItem.text -match 'Get-ComputerName') | Should -BeTrue -Because 'These are the commands to use to get Instances or Computers'
                        }
                    }
                    if ($title -ne 'Cluster $clustername Health using Node $clustervm') {
                        It "Describe - $title Should use the ForEach Method" {
                            ($PSItem.text -match 'Get-Instance\).ForEach{' ) -or ($Psitem.text -match 'Get-ComputerName\).ForEach{' ) | Should -BeTrue # use the \ to escape the ) -Because 'We use the ForEach method in our coding standards'
                        }
                    }
                    It "Describe - $title Should not use `$_" {
                        ($PSItem.text -match '$_' ) | Should -BeFalse -Because '¬$psitem is the correct one to use'
                    }
                    if ($CheckName -ne 'Agent.Tests.ps1') {
                        It "Describe - $title Should Contain a Context Block" {
                            $PSItem.text -match 'Context' | Should -BeTrue -Because 'This helps the Power BI'
                        }
                    }
                    else {
                        $Contexts = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
                        FindAll([Func[Management.Automation.Language.Ast, bool]] {
                                param ($ast)
                                $ast.CommandElements -and
                                $ast.CommandElements[0].Value -eq 'Context'
                            }, $true) |
                        ForEach-Object {
                            $CE = $PSItem.CommandElements
                            $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                            New-Object PSCustomObject -Property @{
                                Name = $secondString
                            }
                        }
                        It "$CheckName should have the right number of Context blocks as the AST doesnt parse how I like and I cant be bothered to fix it right now"{
                            $Contexts.Count | Should -Be 27 -Because "There should be 27 context blocks in the Agent checks file"
                        }
                    }
                }
            }
        }
    }
    (Get-DbcCheck).ForEach{
        It "Should have one Unique Tag for each check" {
            $psitem.UniqueTag.Count | Should -Be 1 -Because "You need to check that the tags for this check -  We want to only have one Unique Tag per test and we got $($psitem.UniqueTag) instead"
        }
    }
}

Describe "Checking that there is a description for each check" -Tags UnitTest {
    (Get-DbcCheck).ForEach{
        It "$($psitem.UniqueTag) Should have a description in the DbcCheckDescriptions.json" {
            $psitem.description | Should -Not -BeNullOrEmpty -Because "We need a description in the .\internal\configurations\DbcCheckDescriptions.json for $($psitem.uniquetag) so that Get-DbcCheck shows it"
        }
    }
}

Describe "Each Config referenced in a check should exist" -Tags UnitTest {
    $dbcConfig = (Get-DbcConfig).Name
    ((Get-DbcCheck).Config.Split(' ') | Sort-Object -Unique).Where{ $Psitem -ne '' }.ForEach{
        It "Config Value $psitem Should exist in Get-DbcConfig" {
            $Psitem | Should -BeIn $dbcConfig -Because "You need to look at the configurations as there appears to not be a unique tag"
        }
    }
}

Describe "Database Tests Exclusions" {
    $DbChecks = (Get-ChildItem $ModuleBase\checks).Where{ $PSItem.Name -eq 'Database.Tests.ps1' }
    $Check = Get-Content $DbChecks.FullName -Raw

    $Describes = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
    FindAll([Func[Management.Automation.Language.Ast, bool]] {
            param ($ast)
            $ast.CommandElements -and
            $ast.CommandElements[0].Value -eq 'describe'
        }, $true) |
    ForEach-Object {
        $CE = $PSItem.CommandElements
        $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
        [PSCustomObject] @{
            Name   = $secondString.Value
            Extent = $secondString.Parent.Extent.Text
        }
    }

    $Describes.ForEach{
        It "$($Psitem.Name) should reference the global exclude configuration" {
            $psitem.Extent -like "*`$ExcludedDatabases*" | Should -BeTrue -Because "We need to exclude the databases specified in the config command.invokedbccheck.excludedatabases"
        }
    }
}

# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnG8fYYQ+n/6teg5vWZsCC5Ga
# 1y6gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRJ2yB4Tm6Zaxb+gZab7tFGYsxW
# 9TANBgkqhkiG9w0BAQEFAASCAQCCIcStyAb/yxOlY9t7GWaqEVgSZydVqjfbx/9O
# m0TxalifwzRAVoMFufzivmRJdC4eCEHwa52JRQuFil0Ucmu0H/ITZk44NkhNjZk3
# FmV0EHKtkhhuMyEObzeVqzz4htjDobLbjfsu/IvP7NEAznq5MrDRgfFz/L4Ndyyt
# wD53mmsQtGoX9OWgL14gKxQZhxbzNJV72f9VFfBWcZ5Zcxh4foerG2jikAtyeH93
# vfeEiPewVvTtR9NzKQmRz9nqKtRTUaZCPHeYIoGX0Sq2HdCfY6fRNt/cSOhrOr1N
# JdrpoTCNdFA6oeEN7GMQ056XIjQCcYwaFWExQrqridnObxYu
# SIG # End signature block

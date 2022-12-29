
# This should stop people making breaking changes to the tests without first altering the test

BeforeDiscovery {
    Remove-Module dbachecks
    Import-Module dbachecks
    $ModuleBase = (Get-Module dbachecks).ModuleBase

    $v4Groups = (Get-ChildItem $ModuleBase\checks).Where{ $PSItem.Name -notlike '*v5*' }
    $UniqueTags = (Get-DbcCheck).UniqueTag
    $v4Describes = foreach ($Group in $v4Groups) {
        $tokens = $null
        $errors = $null
        $GroupName = $Group.Name
        $GroupContent = Get-Content $Group.FullName -Raw

        [Management.Automation.Language.Parser]::ParseInput($GroupContent, [ref]$tokens, [ref]$errors).
        FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast.CommandElements -and
                $ast.CommandElements[0].Value -eq 'describe'
            }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                $tagIdx = $CE.IndexOf(($CE | Where-Object ParameterName -EQ 'Tags')) + 1
                $tags = if ($tagIdx -and $tagIdx -lt $CE.Count) {
                    $CE[$tagIdx].Extent
                }
                New-Object PSCustomObject -Property @{
                    CheckTitle = $secondString
                    CheckTags  = $tags
                }
            }
    }
}

Describe 'Checking that each v4 dbachecks Pester test is correctly formatted for Power Bi and Coded correctly' -Tags UnitTest -ForEach $v4Describes {
    BeforeDiscovery {
        $CheckTitle = $PsItem.CheckTitle.Value
    }
    Context "Validating the  - $CheckTitle  - Check's Describes titles and tags" {
        It "The Describe Title - $CheckTitle - Should Use a double quote after the Describe" {
            $PSItem.CheckTitle.StringConstantType | Should -Be 'DoubleQuoted' -Because 'You need to alter the title of the Describe - We need use double quotes for titles'
        }
    }
}
<#
Describe 'Checking that each dbachecks Pester test is correctly formatted for Power Bi and Coded correctly' -Tags UnitTest {
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
                    $tagIdx = $CE.IndexOf(($CE | Where-Object ParameterName -EQ 'Tags')) + 1
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
                } else {
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
                    $PSItem.Name.ToString().Endswith('psitem"') -or $PSItem.Name.ToString().Endswith('clustername"') -or $PSItem.Name.ToString().Endswith('SqlInstance"') | Should -BeTrue -Because 'You need to alter the title of the Context - This helps the PowerBi to parse the data'
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
                    $title = [regex]::matches($PSItem.text, 'Describe(.*)-Tag').groups[1].value.Replace('"', '').Replace('''', '').trim()
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
                    } else {
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
                        It "$CheckName should have the right number of Context blocks as the AST doesnt parse how I like and I cant be bothered to fix it right now" {
                            $Contexts.Count | Should -Be 27 -Because 'There should be 27 context blocks in the Agent checks file'
                        }
                    }
                }
            }
        }
    }
    (Get-DbcCheck).ForEach{
        It 'Should have one Unique Tag for each check' {
            $psitem.UniqueTag.Count | Should -Be 1 -Because "You need to check that the tags for this check -  We want to only have one Unique Tag per test and we got $($psitem.UniqueTag) instead"
        }
    }
}

Describe 'Checking that there is a description for each check' -Tags UnitTest {
    (Get-DbcCheck).ForEach{
        It "$($psitem.UniqueTag) Should have a description in the DbcCheckDescriptions.json" {
            $psitem.description | Should -Not -BeNullOrEmpty -Because "We need a description in the .\internal\configurations\DbcCheckDescriptions.json for $($psitem.uniquetag) so that Get-DbcCheck shows it"
        }
    }
}

Describe 'Each Config referenced in a check should exist' -Tags UnitTest {
    $dbcConfig = (Get-DbcConfig).Name
    ((Get-DbcCheck).Config.Split(' ') | Sort-Object -Unique).Where{ $Psitem -ne '' }.ForEach{
        It "Config Value $psitem Should exist in Get-DbcConfig" {
            $Psitem | Should -BeIn $dbcConfig -Because 'You need to look at the configurations as there appears to not be a unique tag'
        }
    }
}

Describe 'Database Tests Exclusions' {
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
            $psitem.Extent -like "*`$ExcludedDatabases*" | Should -BeTrue -Because 'We need to exclude the databases specified in the config command.invokedbccheck.excludedatabases'
        }
    }
}

$Describes.ForEach{
    It "$($Psitem.Name) should reference the global exclude configuration" {
        $psitem.Extent -like "*`$ExcludedDatabases*" | Should -BeTrue -Because 'We need to exclude the databases specified in the config command.invokedbccheck.excludedatabases'
    }
}


#>


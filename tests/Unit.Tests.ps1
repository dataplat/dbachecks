
# This should stop people making breaking changes to the tests without first altering the test

BeforeDiscovery {
    Remove-Module dbachecks -Force -ErrorAction SilentlyContinue
    Import-Module dbachecks
    $ModuleBase = (Get-Module dbachecks).ModuleBase

    $v4Groups = (Get-ChildItem $ModuleBase\checks).Where{ $PSItem.Name -notlike '*v5*' }
}

Describe "Group <_.Name.Replace('.Tests.ps1','')> that each v4 dbachecks Pester test is correctly formatted for Power Bi and Coded correctly" -Tags UnitTest -ForEach $v4Groups {
    BeforeDiscovery {
        $tokens = $null
        $errors = $null
        $GroupName = $Psitem.Name -replace '.Tests.ps1', ''
        $GroupContent = Get-Content $Psitem.FullName -Raw

        $v4Describes = [Management.Automation.Language.Parser]::ParseInput($GroupContent, [ref]$tokens, [ref]$errors).
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
                    GroupName  = $GroupName
                    CheckTitle = $secondString
                    CheckTags  = $tags
                    Extent     = $secondString.Parent.Extent.Text
                }
            }
        ## Find the Contexts
        
        $tokens = $null
        $errors = $null
        $v4Contexts = [Management.Automation.Language.Parser]::ParseInput($GroupContent, [ref]$tokens, [ref]$errors).
        FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast.CommandElements -and
                $ast.CommandElements[0].Value -eq 'Context'
            }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                New-Object PSCustomObject -Property @{
                    GroupName = $GroupName
                    Name      = $secondString
                }
            }
        ## Find the Its
        $tokens = $null
        $errors = $null
        $v4Its = [Management.Automation.Language.Parser]::ParseInput($GroupContent, [ref]$tokens, [ref]$errors).
        FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast.CommandElements -and
                $ast.CommandElements[0].Value -eq 'It'
            }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                New-Object PSCustomObject -Property @{
                    GroupName = $GroupName
                    Name      = $secondString
                }
            }

        ## This just grabs all the code
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($GroupContent, [ref]$null, [ref]$null)
        $v4Code = New-Object PSCustomObject -Property @{
            GroupName = $GroupName
            Statement = $AST.EndBlock.statements.Extent.Where{ $PSItem.StartLineNumber -ne 1 }.Where{ $PSItem.Text -match 'Describe' }  ## Ignore the filename line and only if the title contains a describe
        }
            
    }
    BeforeAll {
        $UniqueTags = (Get-DbcCheck).UniqueTag
    }
    Context "Validating the group $GroupName - Check's Describes titles and tags" -ForEach $v4Describes {
        BeforeDiscovery {
            $CheckTitle = $PsItem.CheckTitle.Value
            $CheckTagsList = $PSItem.CheckTags.Text.Split(',').Trim().Where{ ($PSItem -ne '$filename') -and ($PSItem -notlike '*statistics*') -and ($PSItem -notlike '*BackupPathAccess*') -and ($PSItem -notlike '*OlaJobs*') -and ($PSItem -notlike '*status*') -and ($PSItem -notlike '*exists') -and ($PSItem -notlike '*Ops') 
            }
        }
        It "The Describe Title - <_.CheckTitle.Value> - Should Use a double quote after the Describe" {
            $PSItem.CheckTitle.StringConstantType | Should -Be 'DoubleQuoted' -Because 'You need to alter the title of the Describe - We need use double quotes for titles'
        }
        It "The Describe Title - <_.CheckTitle.Value> - should use a plural for tags" {
            $PSItem.CheckTags | Should -Not -BeNullOrEmpty -Because 'You need to alter the tags parameter of the Describe - We use the plural of Tags'
        }

        It "The Describe Title - $CheckTitle - Tags parameter <_> should be Singular" -ForEach $CheckTagsList {
            $PSItem.ToString().Endswith('s') | Should -BeFalse -Because 'You need to alter the tags for this Describe OR alter this test if the tag makes sense - Our coding standards say tags should be singular'
        }
        It "The Describe Title - $CheckTitle - The first Tag <_> should be in the unique Tags returned from Get-DbcCheck" -ForEach $CheckTagsList[0].Where{ $PsItem -notin ('Low', 'High', 'Storage', 'DISA') } {
            $UniqueTags | Should -Contain $Psitem -Because 'We need a unique tag for each test - Format should be -Tags space UniqueTag comma - Also if you are running this on a machine where dbachecks has already been imported previously try running reset-dbcconfig, which will create a new checks.json for Get-DbcCheck'
        }
        It "The Describe Title - <_.CheckTitle.Value> - should reference the global exclude configuration" -ForEach $Psitem.Where{ $Psitem.GroupName -eq 'Database' } {
            $psitem.Extent -like "*`$ExcludedDatabases*" | Should -BeTrue -Because 'We need to exclude the databases specified in the config command.invokedbccheck.excludedatabases'
        }
    }
    Context "Validating the group $GroupName - Checking Contexts" {
        It "The Context Title - <_.Name> - Should end with `$PSItem (or `$clustername) So that the PowerBi will work correctly" -ForEach $v4Contexts {
            $PSItem.Name.ToString().Endswith('psitem"') -or $PSItem.Name.ToString().Endswith('clustername"') -or $PSItem.Name.ToString().Endswith('SqlInstance"') | Should -BeTrue -Because 'You need to alter the title of the Context - This helps the PowerBi to parse the data'
        }
    }
    Context "Validating the group $GroupName - Checking Its" {
        It "The It - <_.Name> - Should end with the right ending so that the PowerBi will work correctly" -ForEach $v4its {
            $Lower = $PSItem.Name.ToString().ToLower()
            $Lower.Endswith('psitem"') -or $Lower.Endswith('clustername"') -or $Lower.EndsWith('server)"') -or $Lower.EndsWith('name)"') -or $Lower.EndsWith('name"') -or $Lower.EndsWith('instance"') -or $Lower.EndsWith('instance)"') -or $Lower.EndsWith('domain)"') -or $Lower.EndsWith('domain"') -or $Lower.EndsWith('replica)"') | Should -BeTrue -Because 'You need to alter the title of the It, it should end with the instance name or computername - This helps the PowerBi to parse the data'
        }
        It "The Database It - <_.Name> - Should begin with - Database" -ForEach $v4its.Where{ $Psitem.GroupName -eq 'Database' } {
            $PSItem.Name.ToString().StartsWith('"Database') -or $PSItem.Name.ToString().StartsWith('"Can') | Should -BeTrue -Because 'You need to alter the It Title to start with Database (or Can t Connect) - For the database checks we can parse them and make magic'
        }
    }

    Context "Validating the group $GroupName - Checking Code Quality" -ForEach $v4Code {

        It "Should Use Get-Instance or Get-ComputerName" -ForEach $psitem.Statement {
        ($PSItem.text -Match 'Get-Instance') -or ($PSItem.text -match 'Get-ComputerName') -or ($PSItem.text -match 'clustervm' ) | Should -BeTrue -Because 'These are the commands to use to get Instances or Computers or clusters'
        }

        It "Should use the ForEach Method" -ForEach $psitem.Where{ $PsItem.GroupName -notlike '*HADR*' }.Statement {
        ($PSItem.text -match 'Get-Instance\).ForEach{' ) -or ($Psitem.text -match 'Get-ComputerName\).ForEach{' ) | Should -BeTrue # use the \ to escape the ) -Because 'We use the ForEach method in our coding standards'
        }
        It "Should not use `$_" -ForEach $psitem.Statement {
        ($PSItem.text -match '$_' ) | Should -BeFalse -Because '¬$psitem is the correct one to use'
        }
        It "Should Contain a Context Block" -ForEach ($psitem.Where{ $PsItem.GroupName -ne 'Agent' }.Statement) {
            $PSItem.text -match 'Context' | Should -BeTrue -Because 'This helps the Power BI'
        }
        It "Agent Should Contain a Context Block" -ForEach ($psitem.Where{ $PsItem.GroupName -eq 'Agent' }.Statement) {
            $PSItem.text -match 'Context' | Should -BeTrue -Because 'This helps the Power BI'
        }

    }
}
Describe 'Each Config referenced in a check should exist' -Tags UnitTest {
    BeforeDiscovery {
        $dbcCheck = Get-DbcCheck

    }
    BeforeAll {
        $dbcConfig = Get-DbcConfig
    }

    It "Config Value <_> Should exist in Get-DbcConfig" -ForEach ($dbcCheck.Config.Split(' ') | Sort-Object -Unique).Where{ $Psitem -ne '' } {
        $Psitem | Should -BeIn $dbcConfig.Name -Because 'You need to look at the configurations as there appears to not be a unique tag'
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


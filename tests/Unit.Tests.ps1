$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path
# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Tests') {
    $ModuleBase = Split-Path $ModuleBase -Parent
}
$tokens = $null
$errors = $null
Describe "Checking that each dbachecks Pester test is correctly formatted for Power Bi and Coded correctly" -Tags UnitTest {
    $Checks = (Get-ChildItem $ModuleBase\checks) #.Where{$PSItem.Name -ne 'MaintenanceSolution.Tests.ps1'}
    $Checks.ForEach{
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
                It "$title Should Use a double quote after the Describe" {
                    $PSItem.Name.ToString().Startswith('"')  | Should -BeTrue -Because 'We need use double quotes for titles'
                    $PSItem.Name.ToString().Endswith('"')  | Should -BeTrue -Because 'We need use double quotes for titles'
                }
                It "$title should use a plural for tags" {
                    $PSItem.Tags | Should -Not -BeNullOrEmpty -Because 'We use the plural of Tags'
                }
                # a simple test for no esses apart from statistics and Access!!
                if ($null -ne $PSItem.Tags) {
                    $PSItem.Tags.Text.Split(',').Trim().Where{($PSItem -ne '$filename') -and ($PSItem -notlike '*statistics*') -and ($PSItem -notlike '*BackupPathAccess*') -and ($PSItem -notlike '*OlaJobs*') -and ($PSItem -notlike '*status*') }.ForEach{
                        It "$PSItem Should Be Singular" {
                            $PSItem.ToString().Endswith('s') | Should -BeFalse -Because 'Our coding standards say tags should be singular'
                        }
                    }
                    It "The first Tag $($PSItem.Tags.Text.Split(',')[0]) Should Be in the unique Tags returned from Get-DbcCheck" {
                        $UniqueTags | Should -Contain $PSItem.Tags.Text.Split(',')[0].ToString() -Because 'We need a unique tag for each test - Format should be -Tags space UniqueTag comma'
                    }
                }
                else {
                    It "You haven't used the Tags Parameter so we can't check the tags" {
                        $false | Should -BeTrue -Because 'We use teh Tags parameter'
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
                It "$Title Should end with `$PSItem (or `$clustername) So that the PowerBi will work correctly" {
                    $PSItem.Name.ToString().Endswith('psitem"') -or $PSItem.Name.ToString().Endswith('clustername"') | Should -BeTrue -Because 'This helps the PowerBi to parse the data'
                }
            }
        }
        Context "$($PSItem.Name) - Checking Code" {
            ## This just grabs all the code
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($Check, [ref]$null, [ref]$null)
            $Statements = $AST.EndBlock.statements.Extent
            ## Ignore the filename line
            @($Statements.Where{$PSItem.StartLineNumber -ne 1}).ForEach{
                # make sure we only regex if the title contains a describe
                if ($PSItem.Text -match 'Describe') {
                    $title = [regex]::matches($PSItem.text, "Describe(.*)-Tag").groups[1].value.Replace('"', '').Replace('''', '').trim()
                    if ($title -ne 'Cluster $clustername Health using Node $clustervm') {
                        It "$title Should Use Get-Instance or Get-ComputerName" {
                            ($PSItem.text -Match 'Get-Instance') -or ($PSItem.text -match 'Get-ComputerName') | Should -BeTrue -Because 'These are the commands to use to get Instances or Computers'
                        }
                    }
                    if ($title -ne 'Cluster $clustername Health using Node $clustervm') {
                        It "$title Should use the ForEach Method" {
                            ($PSItem.text -match 'Get-Instance\).ForEach{' ) -or ($Psitem.text -match 'Get-ComputerName\).ForEach{' ) | Should -BeTrue # use the \ to escape the ) -Because 'We use the ForEach method in our coding standards'
                        }
                    }
                    It "$title Should not use `$_" {
                        ($PSItem.text -match '$_' )| Should -BeFalse -Because '¬$psitem is the correct one to use'
                    }
                    It "$title Should Contain a Context Block" {
                        $PSItem.text -match 'Context' | Should -BeTrue -Because 'This helps the Power BI'
                    }
                }
            }
        }
    }
    (Get-DbcCheck).ForEach{
        It "Should have one Unique Tag for each check"{
            $psitem.UniqueTag.Count | Should -Be 1 -Because "We want to only have one Unique Tag per test and we got $($psitem.UniqueTag) instead"
        }
    }
}

Describe "Checking that there is a description for each check" -Tags UnitTest {
    (Get-DbcCheck).ForEach{
        It "$($psitem.UniqueTag) Should have a description in the DbcCheckDescriptions.json"{
            $psitem.description | Should -Not -BeNullOrEmpty -Because "We need a description in the .\internal\configurations\DbcCheckDescriptions.json for $($psitem.uniquetag) so that Get-DbcCheck shows it"
        }
    }
}

# This should stop people making breaking changes to the tests without first altering the test
Remove-Module dbachecks -Force -ErrorAction SilentlyContinue
Import-Module $ModuleBase\dbachecks.psd1 

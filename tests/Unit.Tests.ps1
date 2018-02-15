$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path
# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Tests') {
    $ModuleBase = Split-Path $ModuleBase -Parent
}
$tokens = $null
$errors = $null
Describe "Checking that each dbachecks Pester test is correctly formatted for Power Bi and Coded correctly" {
    $Checks = (Get-ChildItem $ModuleBase\checks).Where{$_.Name -ne 'HADR.Tests.ps1'}
    $Checks.Foreach{
        $Check = Get-Content $Psitem.FullName -Raw
        Context "$($_.Name) - Checking Describes titles and tags" {
            $UniqueTags = (Get-DbcCheck).UniqueTag
            ## This gets all of the code with a describe
            $Describes = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
            FindAll([Func[Management.Automation.Language.Ast, bool]] {
                    param ($ast)
                    $ast.CommandElements -and
                    $ast.CommandElements[0].Value -eq 'describe'
                }, $true) |
                ForEach {
                $CE = $_.CommandElements
                $secondString = ($CE | Where { $_.StaticType.name -eq 'string' })[1]
                $tagIdx = $CE.IndexOf(($CE | Where ParameterName -eq 'Tags')) + 1
                $tags = if ($tagIdx -and $tagIdx -lt $CE.Count) {
                    $CE[$tagIdx].Extent
                }
                New-Object PSCustomObject -Property @{
                    Name = $secondString
                    Tags = $tags
                }
            }
            @($describes).Foreach{
                $title = $PSItem.Name.ToString().Trim('"').Trim('''')
                It "$title Should Use a double quote after the Describe" {
                    $PSItem.Name.ToString().Startswith('"')  | Should -Be $true
                    $PSItem.Name.ToString().Endswith('"')  | Should -Be $true
                }
                It "$title should use a plural for tags" {
                    $PsItem.Tags | Should Not BeNullOrEmpty
                }
                # a simple test for no esses apart from statistics and Access!!
                if ($null -ne $PSItem.Tags) {
                    $PSItem.Tags.Text.Split(',').Trim().Where{($_ -ne '$filename') -and ($_ -notlike '*statistics*') -and ($_ -notlike '*BackupPathAccess*') }.ForEach{
                        It "$PsItem Should -Be Singular" {
                            $_.ToString().Endswith('s') | Should -Be $False
                        }
                    }
                    It "The first Tag Should -Be in the unique Tags returned from Get-DbcCheck" {
                        $UniqueTags -contains $PSItem.Tags.Text.Split(',')[0].ToString() | Should -Be $true
                    }
                }
                else {
                    It "You haven't used the Tags Parameter so we can't check the tags" {
                        $false | Should -Be $true
                    }
                }  
            }
        }
        Context "$($_.Name) - Checking Contexts" {
            ## Find the Contexts
            $Contexts = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
            FindAll([Func[Management.Automation.Language.Ast, bool]] {
                    param ($ast)
                    $ast.CommandElements -and
                    $ast.CommandElements[0].Value -eq 'Context'
                }, $true) |
                ForEach {
                $CE = $_.CommandElements
                $secondString = ($CE | Where { $_.StaticType.name -eq 'string' })[1]
                New-Object PSCustomObject -Property @{
                    Name = $secondString
                }
            }

            @($Contexts).ForEach{
                $title = $PSItem.Name.ToString().Trim('"').Trim('''')
                It "$Title Should end with `$psitem So that the PowerBi will work correctly" {
                    $PSItem.Name.ToString().Endswith('psitem"') | Should -Be $true
                }
            }
        }
        Context "$($_.Name) - Checking Code" {
            ## This just grabs all the code
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($Check, [ref]$null, [ref]$null)
            $Statements = $AST.EndBlock.statements.Extent
            ## Ignore the filename line
            @($Statements.Where{$_.StartLineNumber -ne 1}).ForEach{
                $title = [regex]::matches($PSItem.text, "Describe(.*)-Tag").groups[1].value.Replace('"', '').Replace('''', '').trim()
                It "$title Should Use Get-SqlInstance or Get-ComputerName" {
                    ($PSItem.text -Match 'Get-SqlInstance') -or ($psitem.text -match 'Get-ComputerName') | Should -Be $true
                }
                It "$title Should use the ForEach Method" {
                    ($Psitem.text -match 'Get-SqlInstance\).ForEach{' ) -or ($Psitem.text -match 'Get-ComputerName\).ForEach{' )| Should -Be $true # use the \ to escape the )
                }
                It "$title Should not use `$_" {
                    ($Psitem.text -match '$_' )| Should -Be $false
                }
                It "$title Should Contain a Context Block" {
                    $Psitem.text -match 'Context' | Should -Be $True
                }
            }
        }
    }
}

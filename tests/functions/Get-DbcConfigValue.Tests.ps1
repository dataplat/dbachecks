[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Because they are used just doesnt see them')]
Param()

$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\..\constants.ps1"

Describe "$commandname Unit Tests" -Tags UnitTest {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            $results = Get-DbcConfigValue -Name policy.database.autoclose
        }
        It "returns a single bool" {
            $results -eq $true -or $results -eq $false | Should -BeTrue
        }
    }
}
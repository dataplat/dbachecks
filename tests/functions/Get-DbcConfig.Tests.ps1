[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Because they are used just doesnt see them')]
Param()
$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

. "$PSScriptRoot\..\constants.ps1"

Describe "$commandname Unit Tests" -Tags UnitTest {
    Context "Command executes properly and returns proper info" {
        BeforeAll {
            $results = Get-DbcConfig
            $specific = Get-DbcConfig -Name policy.database.autoclose
        }

        It "returns a number of configs" {
            ($results).Count -gt 10 | Should -BeTrue
        }

        It "returns a single bool" {
            $specific.Value -eq $true -or $specific.Value -eq $false | Should -BeTrue
        }
    }
}
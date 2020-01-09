$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. "$PSScriptRoot\..\constants.ps1"

Describe "$commandname Unit Tests" -Tags UnitTest {
    Context "Command executes properly and returns proper info" {
        $results = Get-DbcTagCollection
        $count = ($results).Count

        It "returns a number of tags" {
            $count -gt 10 | Should -BeTrue
        }

        It "returns a unique number of tags" {
            ($results | Sort-Object | Select-Object -Unique).Count | Should -Be $count
        }
    }
}
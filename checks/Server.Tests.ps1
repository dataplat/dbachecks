$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing Server PowerPlan Configuration' -Tag PowerPlan, Server, $filename {
    (Get-ComputerName).ForEach{
        Context "Testing $_" {
            It "Server PowerPlan should be High Performance" {
                (Test-DbaPowerPlan -ComputerName $_).IsBestPractice | Should be $true
            }
        }
    }
}
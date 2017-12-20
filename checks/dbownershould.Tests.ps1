$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$skip = Get-DbcConfigValue skip.dbownershould
$targetowner = Get-DbcConfigValue policy.dbownershould
Describe 'Testing Database Owners' -Tags Database, Owner, $filename {
    $PSDefaultParameterValues = @{ 'It:Skip' = $skip}
    (Get-SqlInstance).ForEach{
        Context "Testing $_ for Database Owners" {
            $Results = Test-DbaDatabaseOwner -SqlInstance $_ -TargetLogin $targetowner
            $Results.ForEach{
                It "$($_.Database) Owner should be $targetowner" {
                    $_.CurrentOwner | Should Be $_.TargetOwner
                }
            }
        }
    }
}
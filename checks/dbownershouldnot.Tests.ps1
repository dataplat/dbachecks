$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$skip = Get-DbcConfigValue skip.dbownershouldnot
$targetowner = Get-DbcConfigValue policy.dbownershouldnot
Describe 'Testing Database Owners' -Tags Database, Owner, $filename {
    $PSDefaultParameterValues = @{ 'It:Skip' = $skip}
    (Get-SqlInstance).ForEach{
        Context "Testing $_ for Database Owners" {
            $Results = Test-DbaDatabaseOwner -SqlInstance $_ -TargetLogin $targetowner
            $Results.ForEach{
                It "$($_.Database) Owner should Not be $targetowner" {
                    $_.CurrentOwner | Should Not Be $_.TargetOwner
                }
            }
        }
    }
}
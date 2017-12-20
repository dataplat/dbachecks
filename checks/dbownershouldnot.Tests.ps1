$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$targetowner = Get-DbcConfigValue policy.dbownershouldnot
Describe 'Testing Database Owners' -Tags Database, Owner, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing $psitem for Database Owners" {
            $results = Test-DbaDatabaseOwner -SqlInstance $psitem -TargetLogin $targetowner
            $results.ForEach{
                It "$($psitem.Database) Owner should Not be $targetowner" {
                    $psitem.CurrentOwner | Should Not Be $psitem.TargetOwner
                }
            }
        }
    }
}
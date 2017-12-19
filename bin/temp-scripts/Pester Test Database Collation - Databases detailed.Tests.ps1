# Requires -Version 4
# Requires module dbatools
Describe "Testing Database Collation" -Tag Detailed,Database,Collation{
             if($($Config.CollationDatabaseDetailed.Skip))
        {
            continue
        }
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.CollationDatabaseDetailed.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.CollationDatabaseDetailed.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers = $SQLServers.Where{$_ -like "*$($Config.CollationDatabaseDetailed.NameSearch)*"}
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
foreach($Server in $SQLServers)
{
$CollationTests = Test-DbaDatabaseCollation -SqlServer $Server -Detailed
foreach($CollationTest in $CollationTests)
{
It "$($Collationtest.Server) database $($CollationTest.Database) should have the correct collation of $($CollationTest.ServerCollation)" {
$CollationTest.DatabaseCollation | Should Be $CollationTest.ServerCollation
}
}
}
}
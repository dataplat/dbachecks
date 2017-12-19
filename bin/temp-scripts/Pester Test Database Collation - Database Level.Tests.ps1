# Requires -Version 4
# Requires module dbatools
Describe "Testing Database Collation" -Tag Database,Collation{
             if($($Config.CollationDatabase.Skip))
        {
            continue
        }
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.CollationDatabase.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.CollationDatabase.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers = $SQLServers.Where{$_ -like "*$($Config.CollationDatabase.NameSearch)*"}
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
   foreach($Server in $SQLServers)
    {
        $CollationTests = Test-DbaDatabaseCollation -SqlServer $Server
        foreach($CollationTest in $CollationTests)
        {
            It "$($Collationtest.Server) database $($CollationTest.Database) should have the correct collation" {
            $CollationTest.IsEqual | Should Be $true
            }
        }
    }
}
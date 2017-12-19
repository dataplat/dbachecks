# Requires -Version 4
# Requires module dbatools
Describe "Testing Database Collation" -Tag Server,Collation{
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.CollationServer.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.CollationServer.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
$testCases= @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> databases have the right collation" -TestCases $testCases -Skip:$($Config.CollationServer.Skip){
        Param($Name)
        $Collation = Test-DbaDatabaseCollation -SqlServer $Name
        $Collation.IsEqual -contains $false | Should Be $false
    }

}
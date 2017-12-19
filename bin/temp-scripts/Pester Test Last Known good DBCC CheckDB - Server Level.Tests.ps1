# Requires -Version 4
# Requires module dbatools
Describe "Testing Last Known Good DBCC" -Tag Server,DBCC {
         if($($Config.DBCCServer.Skip))
        {
            continue
        }
 ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.DBCCServer.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.DBCCServer.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers.Where{$_ -like "*$($Config.DBCCServer.NameSearch)*"}
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
 $testCases= @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> databases have all had a successful CheckDB within the last 7 days" -TestCases $testCases {
        Param($Name)
        $DBCC = Get-DbaLastGoodCheckDb -SqlServer $Name  -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        $DBCC.Status -contains 'New database, not checked yet'| Should Be $false
        $DBCC.Status -contains 'CheckDb should be performed'| Should Be $false
    }
}
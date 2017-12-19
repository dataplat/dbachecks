# Requires -Version 4
# Requires module dbatools
Describe "Testing Last Known Good DBCC" -Tag Database, DBCC{
                if($($Config.DBCCDatabase.Skip))
        {
            continue
        }
 ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.DBCCDatabase.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.DBCCDatabase.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers = $SQLServers.Where{$_ -like "*$($Config.DBCCDatabase.NameSearch)*"}
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
   foreach($Server in $SQLServers)
    {
        $DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        foreach($DBCCTest in $DBCCTests)
        {
            It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a successful CheckDB"{
            $DBCCTest.Status | Should Be 'Ok'
            }
            It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a CheckDB run in the last $($Config.DBCCDatabase.Daysold) days" {
            $DBCCTest.DaysSinceLastGoodCheckdb | Should BeLessThan $($Config.DBCCDatabase.Daysold) 
            $DBCCTest.DaysSinceLastGoodCheckdb | Should Not BeNullOrEmpty
            }   
            It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) has Data Purity Enabled" {
            $DBCCTest.DataPurityEnabled| Should Be $true
            }    
        }
    }
}
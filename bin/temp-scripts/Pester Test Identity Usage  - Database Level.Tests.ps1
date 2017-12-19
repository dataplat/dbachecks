# Requires -Version 4
# Requires module dbatools
Describe "Testing how full the Identity columns are" -Tag Database,Identity{
       if($Config.IdentityDatabase.Skip)
{continue}
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.IdentityColumn.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.IdentityColumn.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
    foreach($SQLServer in $SQLServers)
    {
        Context "Testing $SQLServer" {
            $dbs = (Connect-DbaSqlServer -SqlServer $SQLServer).Databases.Name
            foreach($db in $dbs)
            {
                It "$db on $SQLServer identity columns are less than $($Config.IdentityDatabase.Percent) % full"{
                    (Test-DbaIdentityUsage -SqlInstance $SQLServer -Databases $db -Threshold $($Config.IdentityDatabase.Percent) -WarningAction SilentlyContinue).PercentUsed | Should Be
                }
            }
        }
    }
}
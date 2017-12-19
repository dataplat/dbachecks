# Requires -Version 4
# Requires module dbatools
Describe "$SQLServer - Testing how full the Identity columns are" -Tag Column, Detailed, Identity{
    if($Config.IdentityColumn.Skip)
{continue}
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.IdentityColumn.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.IdentityColumn.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
foreach($SQLServer in $SQLServers)
{
            $dbs = (Connect-DbaSqlServer -SqlServer $SQLServer).Databases.Name
            foreach($db in $dbs)
            {
                Context "Testing $db" {
                $Tests = Test-DbaIdentityUsage -SqlInstance $SQLServer -Databases $db -WarningAction SilentlyContinue
                foreach($test in $tests)
                {
                    It "$($test.Column) identity column in $($Test.Table) is less than $($Config.IdentityColumn.Percent) % full" {
                        $Test.PercentUsed | Should BeLessThan $($Config.IdentityColumn.Percent)
                    }
                }
            }
        }
    }
}
# Requires -Version 4
# Requires module dbatools
Describe "Testing Network Latency" -Tag Server,Network {
         if($($Config.Network.Skip))
        {
            continue
        }
 ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.Network.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.Network.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers = $SQLServers.Where{$_ -like "*$($Config.Network.NameSearch)*"}
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
foreach($Server in  $SQLServers)
{
    Context "Testing $Server Spns"{
        $Latency = Test-DBANetworkLatency -SqlServer $Server
            It "$Server Total Latency should be less than $($Config.Network.Latency)" {
                $Latency.AvgMs | Should BeLessThan $($Config.Network.Latency)
        }
    }
}
}
# Requires -Version 4
# Requires module dbatools
Describe "Testing SPNs" -Tag Server,SPN {
         if($($Config.SPN.Skip))
        {
            continue
        }
 ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.SPN.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.SPN.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
foreach($Server in  $SQLServers)
{
    Context "Testing $Server Spns"{
        $SPNs = Test-DbaSpn -ComputerName $Server -Domain $($Config.SPN.DomainName)
        foreach($SPN in $SPNs)
        {
            It "$Server should have SPN for $($SPN.RequiredSPN) for $($SPN.InstanceServiceAccount)" {
                $SPN.Error | Should Be 'None'
            }
        }
    }
}
}
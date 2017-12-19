# Requires -Version 4
# Requires module dbatools
Describe "Testing TempDb" -Tag Server,TempDb {
         if($($Config.TempDb.Skip))
        {
            continue
        }
 ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.TempDb.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.TempDb.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
foreach($Server in  $SQLServers)
{
    Context "Testing $Server TempDb"{
        $TempDbTests = Test-DBATempDbConfiguration -SqlServer $Server 

            It "$Server should have TF118 enabled" -Skip:$($Config.TempDb.Skip118){
                $TempDbTests[0].CurrentSetting | Should Be $TempDbTests[0].Recommended
            }
            It "$Server should have $($TempDbTests[1].Recommended) TempDB Files" -Skip:$($Config.TempDb.SkipNumberofFiles){
                $TempDbTests[1].CurrentSetting | Should Be $TempDbTests[1].Recommended
            }
            It "$Server should not have TempDB Files autogrowth set to percent" -Skip:$($Config.TempDb.SkipFileGrowthPercent){
                $TempDbTests[2].CurrentSetting | Should Be $TempDbTests[2].Recommended
            }      
            It "$Server should not have TempDB Files on the C Drive" -Skip:$($Config.TempDb.SkipFilesonC){
                $TempDbTests[3].CurrentSetting | Should Be $TempDbTests[3].Recommended
            }   
            It "$Server should not have TempDB Files with MaxSize Set" -Skip:$($Config.TempDb.SkipFileMaxSize){
                $TempDbTests[4].CurrentSetting | Should Be $TempDbTests[4].Recommended
            }                                   
    }
}
}
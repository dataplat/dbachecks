# Requires -Version 4
# Requires module dbatools
Describe 'Testing Access to Backup Share' -Tag Server, Backup {
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# # $SQLServers = (Get-VM -ComputerName $Config.BackupShare.HyperV| Where-Object {$_.Name -like "*$($Config.BackupShare.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers = $SQLServers.Where{$_ -like "*$($Config.BackupShare.NameSearch)*"} 
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
## create the test cases array
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share $($Config.BackupShare.BackupShare)" -TestCases $testCases -Skip:$($Config.BackupShare.Skip){
        Param($Name)
        Test-DBASqlPath -SqlServer $Name -Path $($Config.BackupShare.BackupShare) | Should Be $True
    }
}

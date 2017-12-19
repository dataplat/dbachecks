# Requires -Version 4
# Requires module dbatools

Describe "Last Backup Test results" -Tag Database, Backup {
            if($($Config.LastBackup.Skip))
        {
            continue
        }

## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
# $SQLServers = (Get-VM -ComputerName $Config.LastBackup.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.LastBackup.NameSearch)*" -and $_.State -eq 'Running'}).Name
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$SQLServers = $SQLServers.Where{$_ -like "*$($Config.LastBackup.NameSearch)*"} 
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
 $Results = $SQLservers.ForEach{Test-DbaLastBackup -SqlServer $_ -Destination $Config.LastBackup.TestServer -WarningAction SilentlyContinue}

    foreach($result in $results)
    {
       $skipexists = $false
       $skipdbcc = $false
       $SkipRestore = $false
        if($result.FileExists -ne $true -and $result.FileExists -ne $false)
        {
            $skipexists = $true
        }
        if($result.DBCCResult -like '*DBCC CHECKTABLE skipped for restored master*' -or $result.DBCCResult -eq 'Skipped')
        {
            $skipDBCC = $true
        }
        if($Result.RestoreResult -eq 'Restore not located on shared location')
        {
            $SkipRestore =$true
        }
        It "$($Result.Database) on $($Result.SourceServer) File Should Exist" -Skip:$skipExists  {
            $Result.FileExists| Should Be 'True'
        }
        It "$($Result.Database) on $($Result.SourceServer) Restore should be Success" -skip:$SkipRestore{
            $Result.RestoreResult| Should Be 'Success'
        }
        It "$($Result.Database) on $($Result.SourceServer) DBCC should be Success" -Skip:$SkipDBCC{
            $Result.DBCCResult| Should Be 'Success'
        }
        It "$($Result.Database) on $($Result.SourceServer) Backup Should be less than $($Config.LastBackup.DaysOld) days old" {
            $Result.BackupDate| Should BeGreaterThan (Get-Date).AddDays(-$($Config.LastBackup.DaysOld) )
        }
        
    }
}

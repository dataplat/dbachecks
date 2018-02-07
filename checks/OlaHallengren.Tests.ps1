$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Ola maintenance solution installed" -Tags OlaInstalled, $filename{
    $OlaSPs = @('CommandExecute', 'DatabaseBackup', 'DatabaseIntegrityCheck', 'IndexOptimize')
    $oladb = Get-DbcConfigValue policy.ola.database
    (Get-SqlInstance).ForEach{        
        $db = Get-DbaDatabase -SqlInstance $PSItem -Database $oladb
        Context "Checking the CommandLog table"{            
            It "The CommandLog table exists in $oladb on $PSItem" {
                @($db.tables | Where-Object name -eq "CommandLog").Count | Should Be 1
            }
        }
        Context "Checking the Ola Stored Procedures" {
            It "The stored procedures exists in $oladb on $PSItem" {
                ($db.StoredProcedures | Where-Object {$PSItem.schema -eq 'dbo' -and $PSItem.name -in $OlaSPs} | Measure-Object).Count | should be $OlaSPs.Count
            }
        }
    }
}

Class OlaJob
{
    [ValidateNotNullOrEmpty()][String]$JobName
    [ValidateNotNullOrEmpty()][string]$prefix
    [Bool]
}

$jobnames = @()
$jobnames += [OlaJob]@{JobName='DatabaseBackup - SYSTEM_DATABASES - FULL'; prefix='SystemFull'}
$jobnames += [OlaJob]@{JobName='DatabaseBackup - USER_DATABASES - FULL'; prefix='UserFull'}
$jobnames += [OlaJob]@{JobName='DatabaseBackup - USER_DATABASES - DIFF'; prefix='UserDiff'}
$jobnames += [OlaJob]@{JobName='DatabaseBackup - USER_DATABASES - LOG'; prefix='UserLog'}

$jobnames | ForEach-Object {    
    $tagname = "Ola$($JobPrefix)"
    $JobName = $PSItem.Jobname
    $JobPrefix = $psitem.prefix
    $Enabled = Get-DbcConfigValue "policy.ola.$($JobPrefix)enabled"
    $Scheduled = Get-DbcConfigValue "policy.ola.$($JobPrefix)scheduled"
    $Retention = Get-DbcConfigValue "policy.ola.$($JobPrefix)retention"
    
    Describe "Ola - $Jobname" -tags $tagname, OlaJobs, $filename {
        (Get-SqlInstance).ForEach{
            $job = Get-DbaAgentJob -SqlInstance $PSItem -Job $JobName
            Context  "Is job enabled on $PSItem" {
                It "$JobName should be enabled - $Enabled " {
                    $job.IsEnabled | Should Be $Enabled
                }
            }
            Context "Is job scheduled on $PSItem" {
                It "$JobName should be scheduled - $Scheduled " {
                    $job.HasSchedule | should be $Scheduled
                }
                It "$($JobName) schedules should be enabled - $Scheduled" {
                    $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object ).Count -gt 0
                    $results | Should BeGreaterThan 0 
                }
            }             
            Context "Checking the backup retention on $psitem" {
                $results = (($job.JobSteps | Where-Object {$_.SubSystem -eq "CmdExec"}).Command.Split("@") | Where-Object {$_ -match "CleanupTime"}).split("=")[1].split(",").split(" ")[1]
                It "Is the backup retention set to at least $Retention hours" {
                    $results | Should BeGreaterThan ($Retention -1 )
                }
            }
        }
    }
}
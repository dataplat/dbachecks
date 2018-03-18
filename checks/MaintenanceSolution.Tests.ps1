$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Ola maintenance solution installed" -Tags OlaInstalled, $filename{
    $OlaSPs = @('CommandExecute', 'DatabaseBackup', 'DatabaseIntegrityCheck', 'IndexOptimize')
    $oladb = Get-DbcConfigValue policy.ola.database
    @(Get-Instance).ForEach{
        $db = Get-DbaDatabase -SqlInstance $PSItem -Database $oladb
        Context "Checking the CommandLog table on $psitem"{
            It "The CommandLog table exists in $oladb on $PSItem" {
                @($db.tables | Where-Object name -eq "CommandLog").Count | Should -Be 1 -Because 'The command log table is required'
            }
        }
        Context "Checking the Ola Stored Procedures on $psitem" {
            It "The stored procedures exists in $oladb on $PSItem" {
                ($db.StoredProcedures | Where-Object { $PSItem.schema -eq 'dbo' -and $PSItem.name -in $OlaSPs } | Measure-Object).Count | Should -Be $OlaSPs.Count -Because 'The stored procedures are required for Olas jobs to run'
            }
        }
    }
}

$jobnames = @()
$jobnames += [pscustomobject]@{ JobName = 'DatabaseBackup - SYSTEM_DATABASES - FULL'; prefix = 'SystemFull' }
$jobnames += [pscustomobject]@{ JobName = 'DatabaseBackup - USER_DATABASES - FULL'; prefix = 'UserFull' }
$jobnames += [pscustomobject]@{ JobName = 'DatabaseBackup - USER_DATABASES - DIFF'; prefix = 'UserDiff' }
$jobnames += [pscustomobject]@{ JobName = 'DatabaseBackup - USER_DATABASES - LOG'; prefix = 'UserLog' }
$jobnames += [pscustomobject]@{ JobName = 'CommandLog Cleanup'; prefix = 'CommandLog' }
$jobnames += [pscustomobject]@{ JobName = 'DatabaseIntegrityCheck - SYSTEM_DATABASES'; prefix = 'SystemIntegrityCheck' }
$jobnames += [pscustomobject]@{ JobName = 'DatabaseIntegrityCheck - USER_DATABASES'; prefix = 'UserIntegrityCheck' }
$jobnames += [pscustomobject]@{ JobName = 'IndexOptimize - USER_DATABASES'; prefix = 'UserIndexOptimize' }
$jobnames += [pscustomobject]@{ JobName = 'Output File Cleanup'; prefix = 'OutputFileCleanup' }
$jobnames += [pscustomobject]@{ JobName = 'sp_delete_backuphistory'; prefix = 'DeleteBackupHistory' }
$jobnames += [pscustomobject]@{ JobName = 'sp_purge_jobhistory'; prefix = 'PurgeJobHistory' }

$jobnames | ForEach-Object {
    $JobPrefix = $psitem.prefix
    $tagname = "Ola$($JobPrefix)"
    $JobName = $PSItem.Jobname
    $Enabled = Get-DbcConfigValue "policy.ola.$($JobPrefix)enabled"
    $Scheduled = Get-DbcConfigValue "policy.ola.$($JobPrefix)scheduled"
    $Retention = Get-DbcConfigValue "policy.ola.$($JobPrefix)retention"
    
    #Write-PSFMessage -Level Host -Message "$jobname / $JobPrefix / $tagname"
    
    Describe "Ola - $Jobname" -Tags $tagname, OlaJobs, $filename {
        @(Get-Instance).ForEach{
            $job = Get-DbaAgentJob -SqlInstance $PSItem -Job $JobName
            Context  "Is job enabled on $PSItem" {
                It "$JobName Should Be enabled - $Enabled " {
                    $job.IsEnabled | Should -Be $Enabled -Because 'If the job is not enabled it will not run'
                }
            }
            Context "Is job scheduled on $PSItem" {
                It "$JobName Should Be scheduled - $Scheduled " {
                    $job.HasSchedule | Should -Be $Scheduled -Because 'If the job is not scheduled it will not run'
                }
                It "$($JobName) schedules Should Be enabled - $Scheduled" {
                    $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                    $results | Should -BeGreaterThan 0 -Because 'If the schedule is not enabled the jobs will not run'
                }
            }
            
            if ($Retention) {
                Context "Checking the backup retention on $psitem" {
                    $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" }
                    if ($jobsteps) {
                        $results = $jobsteps.Command.Split("@") | Where-Object { $_ -match "CleanupTime" }
                    }
                    else {
                        $results = $null    
                    }
                    
                    It "Is the backup retention set to at least $Retention hours" {
                        if ($results) {
                            $hours = $results.split("=")[1].split(",").split(" ")[1]
                        }
                        $hours | Should -BeGreaterOrEqual $Retention -Because 'The backup retention needs to be correct'
                    }
                }
            }
        }
    }
}

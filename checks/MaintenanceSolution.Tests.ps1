$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Ola maintenance solution installed" -Tags OlaInstalled, $filename {
    $OlaSPs = @('CommandExecute', 'DatabaseBackup', 'DatabaseIntegrityCheck', 'IndexOptimize')
    $oladb = Get-DbcConfigValue policy.ola.database
    @(Get-Instance).ForEach{
        $db = Get-DbaDatabase -SqlInstance $psitem -Database $oladb
        Context "Checking the CommandLog table on $psitem" {
            It "The CommandLog table exists in $oladb on $psitem" {
                @($db.tables | Where-Object name -eq "CommandLog").Count | Should -Be 1 -Because 'The command log table is required'
            }
        }
        Context "Checking the Ola Stored Procedures on $psitem" {
            It "The stored procedures exists in $oladb on $psitem" {
                ($db.StoredProcedures | Where-Object { $psitem.schema -eq 'dbo' -and $psitem.name -in $OlaSPs } | Measure-Object).Count | Should -Be $OlaSPs.Count -Because 'The stored procedures are required for Olas jobs to run'
            }
        }
    }
}

$SysFullJobName = Get-DbcConfigValue ola.JobName.SystemFull
$UserFullJobName = Get-DbcConfigValue ola.JobName.UserFull
$UserDiffJobName = Get-DbcConfigValue ola.JobName.UserDiff
$UserLogJobName = Get-DbcConfigValue ola.JobName.UserLog
$CommandLogJobName = Get-DbcConfigValue ola.JobName.CommandLogCleanup 
$SysIntegrityJobName = Get-DbcConfigValue ola.JobName.SystemIntegrity
$UserIntegrityJobName = Get-DbcConfigValue ola.JobName.UserIntegrity 
$UserIndexJobName = Get-DbcConfigValue ola.JobName.UserIndex 
$OutputFileJobName = Get-DbcConfigValue ola.JobName.OutputFileCleanup
$DeleteBackupJobName = Get-DbcConfigValue ola.JobName.DeleteBackupHistory
$PurgeBackupJobName = Get-DbcConfigValue ola.JobName.PurgeBackupHistory


Describe "Ola - $SysFullJobName" -Tags SystemFull, OlaJobs, $filename {
    $Enabled = Get-DbcConfigValue policy.ola.SystemFullenabled
    $Scheduled = Get-DbcConfigValue policy.ola.SystemFullscheduled
    $Retention = Get-DbcConfigValue policy.ola.SystemFullretention

    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $SysFullJobName
        Context  "Is job enabled on $psitem" {
            It "$SysFullJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $SysFullJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$SysFullJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $SysFullJobName job is not scheduled it will not run"
            }
            It "$SysFullJobName schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $SysFullJobName jobs will not run"
            }
        }
        
        if ($Retention) {
            Context "Checking the backup retention on $psitem" {
                $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
                if ($jobsteps) {
                    $results = $jobsteps.Command.Split("@") | Where-Object { $_ -match "CleanupTime" }
                }
                else {
                    $results = $null    
                }
                
                It "Is the backup retention set to at least $Retention hours" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1]
                    }
                    $hours | Should -BeGreaterOrEqual $Retention -Because "The backup retention for $SysFullJobName needs to be correct"
                }
            }
        }
    }
}

Describe "Ola - $UserFullJobName" -Tags UserFull, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $UserFullJobName

        $Enabled = Get-DbcConfigValue policy.ola.UserFullenabled
        $Scheduled = Get-DbcConfigValue policy.ola.UserFullscheduled
        $Retention = Get-DbcConfigValue policy.ola.UserFullretention

        Context  "Is job enabled on $psitem" {
            It "$UserFullJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserFullJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserFullJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserFullJobName job is not scheduled it will not run"
            }
            It "$($UserFullJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $UserFullJobName job will not run"
            }
        }
        
        if ($Retention) {
            Context "Checking the backup retention on $psitem" {
                $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
                if ($jobsteps) {
                    $results = $jobsteps.Command.Split("@") | Where-Object { $_ -match "CleanupTime" }
                }
                else {
                    $results = $null    
                }
                
                It "Is the backup retention set to at least $Retention hours" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1]
                    }
                    $hours | Should -BeGreaterOrEqual $Retention -Because "The backup retention for $UserFullJobName needs to be correct"
                }
            }
        }
    }
}

Describe "Ola - $UserDiffJobName" -Tags UserDiff, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $UserDiffJobName

        $Enabled = Get-DbcConfigValue policy.ola.UserDiffenabled
        $Scheduled = Get-DbcConfigValue policy.ola.UserDiffscheduled
        $Retention = Get-DbcConfigValue policy.ola.UserDiffretention

        Context  "Is job enabled on $psitem" {
            It "$UserDiffJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserDiffJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserDiffJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserDiffJobName job is not scheduled it will not run"
            }
            It "$($UserDiffJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $UserDiffJobName job will not run"
            }
        }
        
        if ($Retention) {
            Context "Checking the backup retention on $psitem" {
                $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
                if ($jobsteps) {
                    $results = $jobsteps.Command.Split("@") | Where-Object { $_ -match "CleanupTime" }
                }
                else {
                    $results = $null    
                }
                
                It "Is the backup retention set to at least $Retention hours" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1]
                    }
                    $hours | Should -BeGreaterOrEqual $Retention -Because "The backup retention for $UserDiffJobName needs to be correct"
                }
            }
        }
    }
}

Describe "Ola - $UserLogJobName" -Tags UserLog, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $UserLogJobName

        $Enabled = Get-DbcConfigValue policy.ola.UserLogenabled
        $Scheduled = Get-DbcConfigValue policy.ola.UserLogscheduled
        $Retention = Get-DbcConfigValue policy.ola.UserLogretention

        Context  "Is job enabled on $psitem" {
            It "$UserLogJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserLogJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserLogJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserLogJobName job is not scheduled it will not run"
            }
            It "$($UserLogJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $UserLogJobName job will not run"
            }
        }
        
        if ($Retention) {
            Context "Checking the backup retention on $psitem" {
                $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
                if ($jobsteps) {
                    $results = $jobsteps.Command.Split("@") | Where-Object { $_ -match "CleanupTime" }
                }
                else {
                    $results = $null    
                }
                
                It "Is the backup retention set to at least $Retention hours" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1]
                    }
                    $hours | Should -BeGreaterOrEqual $Retention -Because "The backup retention for $UserLogJobName needs to be correct"
                }
            }
        }
    }
}

Describe "Ola - $CommandLogJobName" -Tags CommandLog, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $CommandLogJobName

        $Enabled = Get-DbcConfigValue policy.ola.CommandLogenabled
        $Scheduled = Get-DbcConfigValue policy.ola.CommandLogscheduled
        $CleanUp = Get-DbcConfigValue policy.ola.CommandLogCleanUp 

        Context  "Is job enabled on $psitem" {
            It "$CommandLogJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $CommandLogJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$CommandLogJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $CommandLogJobName job is not scheduled it will not run"
            }
            It "$($CommandLogJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $CommandLogJobName job will not run"
            }
        }
        
        Context "Checking the Command Log Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "dd,-(\d\d)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days" {
                $days | Should -BeGreaterOrEqual $CleanUp -Because "The Clean up time for $CommandLogJobName needs to be correct"
            }
        }  
    }
}

Describe "Ola - $SysIntegrityJobName" -Tags SystemIntegrityCheck, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $SysIntegrityJobName

        $Enabled = Get-DbcConfigValue policy.ola.SystemIntegrityCheckenabled
        $Scheduled = Get-DbcConfigValue policy.ola.SystemIntegrityCheckscheduled

        Context  "Is job enabled on $psitem" {
            It "$SysIntegrityJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $SysIntegrityJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$SysIntegrityJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $SysIntegrityJobName job is not scheduled it will not run"
            }
            It "$($SysIntegrityJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $SysIntegrityJobName job will not run"
            }
        }
    }
}

Describe "Ola - $UserIntegrityJobName" -Tags UserIntegrityCheck, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $UserIntegrityJobName

        $Enabled = Get-DbcConfigValue policy.ola.UserIntegrityCheckenabled
        $Scheduled = Get-DbcConfigValue policy.ola.UserIntegrityCheckscheduled

        Context  "Is job enabled on $psitem" {
            It "$UserIntegrityJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserIntegrityJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserIntegrityJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserIntegrityJobName job is not scheduled it will not run"
            }
            It "$($UserIntegrityJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $UserIntegrityJobName job will not run"
            }
        }
    }
}

Describe "Ola - $UserIndexJobName" -Tags UserIndexOptimize, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $UserIndexJobName

        $Enabled = Get-DbcConfigValue policy.ola.UserIndexOptimizeenabled
        $Scheduled = Get-DbcConfigValue policy.ola.UserIndexOptimizescheduled

        Context  "Is job enabled on $psitem" {
            It "$UserIndexJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserIndexJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserIndexJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserIndexJobName job is not scheduled it will not run"
            }
            It "$($UserIndexJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $UserIndexJobName job will not run"
            }
        }
    }
}

Describe "Ola - $OutputFileJobName" -Tags OutputFileCleanup, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $OutputFileJobName

        $Enabled = Get-DbcConfigValue policy.ola.OutputFileCleanupenabled
        $Scheduled = Get-DbcConfigValue policy.ola.OutputFileCleanupscheduled
        $CleanUp = Get-DbcConfigValue policy.ola.OutputFileCleanUp 

        Context  "Is job enabled on $psitem" {
            It "$OutputFileJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $OutputFileJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$OutputFileJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $OutputFileJobName job is not scheduled it will not run"
            }
            It "$($OutputFileJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $OutputFileJobName job will not run"
            }
        }

        Context "Checking the Command Log Clenup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "\/d\s-(\d\d)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days" {
                $days | Should -BeGreaterOrEqual $CleanUp -Because "The Clean up time for $OutputFileJobName needs to be correct"
            }
        }  
    }
}

Describe "Ola - $DeleteBackupJobName" -Tags DeleteBackupHistory, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $DeleteBackupJobName

        $Enabled = Get-DbcConfigValue policy.ola.DeleteBackupHistoryenabled
        $Scheduled = Get-DbcConfigValue policy.ola.DeleteBackupHistoryscheduled
        $CleanUp = Get-DbcConfigValue policy.ola.DeleteBackupHistoryCleanUp 

        Context  "Is job enabled on $psitem" {
            It "$DeleteBackupJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $DeleteBackupJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$DeleteBackupJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $DeleteBackupJobName job is not scheduled it will not run"
            }
            It "$($DeleteBackupJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $DeleteBackupJobName job will not run"
            }
        }

        Context "Checking the Delete Backup History Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "dd,-(\d\d)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days" {
                $days | Should -BeGreaterOrEqual $CleanUp -Because "The Clean up time for $DeleteBackupJobName needs to be correct"
            }
        }  
    }
}

Describe "Ola - $PurgeBackupJobName" -Tags PurgeJobHistory, OlaJobs, $filename {
    @(Get-Instance).ForEach{
        $job = Get-DbaAgentJob -SqlInstance $psitem -Job $PurgeBackupJobName

        $Enabled = Get-DbcConfigValue policy.ola.PurgeJobHistoryenabled
        $Scheduled = Get-DbcConfigValue policy.ola.PurgeJobHistoryscheduled
        $CleanUp = Get-DbcConfigValue policy.ola.PurgeJobHistoryCleanUp 

        Context  "Is job enabled on $psitem" {
            It "$PurgeBackupJobName Should Be enabled - $Enabled " {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $PurgeBackupJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$PurgeBackupJobName Should Be scheduled - $Scheduled " {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $PurgeBackupJobName job is not scheduled it will not run"
            }
            It "$($PurgeBackupJobName) schedules Should Be enabled - $Scheduled" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $PurgeBackupJobName job will not run"
            }
        }

        Context "Checking the Purge Backup History Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "dd,-(\d\d)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days" {
                $days | Should -BeGreaterOrEqual $CleanUp -Because "The Clean up time for $PurgeBackupJobName needs to be correct"
            }
        }  
    }
}



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
            It "$SysFullJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $SysFullJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$SysFullJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $SysFullJobName job is not scheduled it will not run"
            }
            It "$SysFullJobName schedules should be enabled - $Scheduled on $psitem" {
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

                It "Is the backup retention set to at least $Retention hours on $psitem" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1].replace('NULL','')
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
            It "$UserFullJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserFullJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserFullJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserFullJobName job is not scheduled it will not run"
            }
            It "$($UserFullJobName) schedules should be enabled - $Scheduled on $psitem" {
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

                It "Is the backup retention set to at least $Retention hours on $psitem" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1].replace('NULL','')
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
            It "$UserDiffJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserDiffJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserDiffJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserDiffJobName job is not scheduled it will not run"
            }
            It "$($UserDiffJobName) schedules should be enabled - $Scheduled on $psitem" {
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

                It "Is the backup retention set to at least $Retention hours on $psitem" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1].replace('NULL','')
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
            It "$UserLogJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserLogJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserLogJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserLogJobName job is not scheduled it will not run"
            }
            It "$($UserLogJobName) schedules should be enabled - $Scheduled on $psitem" {
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

                It "Is the backup retention set to at least $Retention hours on $psitem" {
                    if ($results) {
                        [int]$hours = $results.split("=")[1].split(",").split(" ")[1].replace('NULL','')
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
            It "$CommandLogJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $CommandLogJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$CommandLogJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $CommandLogJobName job is not scheduled it will not run"
            }
            It "$($CommandLogJobName) schedules should be enabled - $Scheduled on $psitem" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $CommandLogJobName job will not run"
            }
        }

        Context "Checking the Command Log Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "dd,-(\d*)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days on $psitem" {
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
            It "$SysIntegrityJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $SysIntegrityJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$SysIntegrityJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $SysIntegrityJobName job is not scheduled it will not run"
            }
            It "$($SysIntegrityJobName) schedules should be enabled - $Scheduled on $psitem" {
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
            It "$UserIntegrityJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserIntegrityJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserIntegrityJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserIntegrityJobName job is not scheduled it will not run"
            }
            It "$($UserIntegrityJobName) schedules should be enabled - $Scheduled on $psitem" {
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
            It "$UserIndexJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $UserIndexJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$UserIndexJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $UserIndexJobName job is not scheduled it will not run"
            }
            It "$($UserIndexJobName) schedules should be enabled - $Scheduled on $psitem" {
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
            It "$OutputFileJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $OutputFileJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$OutputFileJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $OutputFileJobName job is not scheduled it will not run"
            }
            It "$($OutputFileJobName) schedules should be enabled - $Scheduled on $psitem" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $OutputFileJobName job will not run"
            }
        }

        Context "Checking the Output File Job Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $jobsteps.Command -match "\/d\s-(\d\d)"
            If($Matches.Count -gt 0){
                $days = $Matches[1]
            }
            else{
                $days = 0
            }

            It "Is the Clean up time set to at least $CleanUp Days on $psitem" {
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
            It "$DeleteBackupJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $DeleteBackupJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$DeleteBackupJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $DeleteBackupJobName job is not scheduled it will not run"
            }
            It "$($DeleteBackupJobName) schedules should be enabled - $Scheduled on $psitem" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $DeleteBackupJobName job will not run"
            }
        }

        Context "Checking the Delete Backup History Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "dd,-(\d*)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days on $psitem" {
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
            It "$PurgeBackupJobName should be enabled - $Enabled on $psitem" {
                $job.IsEnabled | Should -Be $Enabled -Because "If the $PurgeBackupJobName job is not enabled it will not run"
            }
        }
        Context "Is job scheduled on $psitem" {
            It "$PurgeBackupJobName should be scheduled - $Scheduled on $psitem" {
                $job.HasSchedule | Should -Be $Scheduled -Because "If the $PurgeBackupJobName job is not scheduled it will not run"
            }
            It "$($PurgeBackupJobName) schedules should be enabled - $Scheduled on $psitem" {
                $results = ($job.JobSchedules | Where-Object IsEnabled | Measure-Object).Count -gt 0
                $results | Should -BeGreaterThan 0 -Because "If the schedule is not enabled the $PurgeBackupJobName job will not run"
            }
        }

        Context "Checking the Purge Backup History Cleanup Time on $psitem" {
            $jobsteps = $job.JobSteps | Where-Object { $_.SubSystem -eq "CmdExec" -or $_.SubSystem -eq "TransactSql" }
            $days = [regex]::matches($jobsteps.Command, "dd,-(\d*)").groups[1].value

            It "Is the Clean up time set to at least $CleanUp Days on $psitem" {
                $days | Should -BeGreaterOrEqual $CleanUp -Because "The Clean up time for $PurgeBackupJobName needs to be correct"
            }
        }
    }
}



# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUS1JQPHv5yCEsWxq/oekgpzof
# efigggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQrwbrUliQ9N0KAabkjhkVyFJXK
# gDANBgkqhkiG9w0BAQEFAASCAQAV13wSIR24gk+gKS/qcNNSK+ugz0pzotNya4sj
# KFZ6T6AzliNxFJD7EVIBNtsjlMNBWVDIrALhZxOR6VGPxlvFhCXJTY2kuE4zfBTW
# epbVpbBK8d2Z8NqhSM5Cnh8pwgABYygRIVYGby06XIXDf36Jd0wTk74uOqajOA/S
# 5XkwxNaeoeV58gEHOquTOpXWsf1JFZBnKI8pn4imT1i/meGdvo5wnaI+uIY8N2m6
# ZgDjrO0SN5cIMQE8jIaih/LjqplJkL/YB3h9dxLuDm37rSeSv/UX5ltM1cXmxIXk
# mqUCh2+zTsZ8gOk5bkbuihdKpERqfF/5E8ZMw5mFMynDO+Yz
# SIG # End signature block

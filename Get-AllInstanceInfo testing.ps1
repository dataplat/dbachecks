# Get-AllInstanceInfo testing 

# so the initial load doesnt skew the figures
ipmo dbatools
ipmo ./dbachecks.psd1
function prompt { Write-Host "pwsh >" -NoNewline; ' ' }
cls
# load the original function
. .\originalGet-AllInstanceInfo.ps1
. .\internal\functions\NewGet-AllInstanceInfo.ps1

$Checks = 'TwoDigitYearCutoff','MaxDopInstance','ErrorLogCount','ModelDbGrowth','DefaultBackupCompression','SaExist','SaDisabled','SaRenamed','DefaultFilePath','AdHocDistributedQueriesEnabled','AdHocWorkload',  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
$Checks = 'TwoDigitYearCutoff'

Compare-GetAllInstanceInfoPerf -Checks $Checks

function Compare-GetAllInstanceInfoPerf {
    Param($Checks)
    $originalCode = {
        $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
        
        $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
        $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred
    
        foreach ($smo in $smos) {
            Get-AllInstanceInfo -Instance $smo -Tags $Checks -There $true
        }
    }
    $NewCode = {
        $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
        
        $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
        $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred
    
        foreach ($smo in $smos) {
            NewGet-AllInstanceInfo -Instance $smo -Tags  $SPConfigureChecks -There $true
        }
    }
    $originalCodetrace = Trace-Script -ScriptBlock $originalCode
    $NewCodetrace = Trace-Script -ScriptBlock $NewCode

    $originalCodeMessage = "With original Code it takes {0} MilliSeconds" -f $originalCodetrace.StopwatchDuration.TotalMilliseconds
    $NewCodeMessage = "With New Code it takes {0} MilliSeconds" -f $NewCodetrace.StopwatchDuration.TotalMilliseconds
    $savingMessage = "
Running with 

{3} 

Checks against 3 SQL Containers

With original Code it takes {1} Seconds
With New Code it takes {4} Seconds

New Code for these {5} checks 
is saving {0} seconds
from a run of {1} seconds
New Code runs in {2} % of the time
" -f ('{0:N2}' -f ($originalCodetrace.StopwatchDuration.TotalSeconds - $NewCodetrace.StopwatchDuration.TotalSeconds)),('{0:N2}' -f $originalCodetrace.StopwatchDuration.TotalSeconds),('{0:N2}' -f (($NewCodetrace.StopwatchDuration.TotalSeconds/$originalCodetrace.StopwatchDuration.TotalSeconds) * 100)),($Checks -split ',' -join ',') ,('{0:N2}' -f $NewCodetrace.StopwatchDuration.TotalSeconds), $Checks.Count
cls
Write-PSFMessage -Message $originalCodeMessage -Level Significant
Write-PSFMessage -Message $NewCodeMessage -Level Significant
Write-PSFMessage -Message $savingMessage -Level Output

}

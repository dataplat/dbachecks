# Get-AllInstanceInfo testing 

# so the initial load doesnt skew the figures
ipmo dbatools
function prompt { Write-Host "pwsh >" -NoNewline; ' '}

# load the original function
. .\originalGet-AllInstanceInfo.ps1
. .\NewGet-AllInstance.ps1

# Lets check just the spconfigure ones :D
$originalCode = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred

    foreach($smo in $smos){
    Get-AllInstanceInfo -Instance $smo -Tags 'DefaultTrace','OleAutomationProceduresDisabled','CrossDBOwnershipChaining','ScanForStartupProceduresDisabled','RemoteAccessDisabled','SQLMailXPsDisabled' -There $true
    }
}

# Lets check just the spconfigure ones :D
$NewCode = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred

    foreach($smo in $smos){
    NewGet-AllInstanceInfo -Instance $smo -Tags 'DefaultTrace','OleAutomationProceduresDisabled','CrossDBOwnershipChaining','ScanForStartupProceduresDisabled','RemoteAccessDisabled','SQLMailXPsDisabled' -There $true
    }
}

$originalCodetrace = Trace-Script -ScriptBlock $originalCode
$NewCodetrace = Trace-Script -ScriptBlock $NewCode

$originalCodeMessage = "With original Code it takes {0} MilliSeconds" -f $originalCodetrace.StopwatchDuration.TotalMilliseconds
$NewCodeMessage = "With New Code it takes {0} MilliSeconds" -f $NewCodetrace.StopwatchDuration.TotalMilliseconds

Write-PSFMessage -Message $originalCodeMessage -Level Significant
Write-PSFMessage -Message $NewCodeMessage -Level Significant
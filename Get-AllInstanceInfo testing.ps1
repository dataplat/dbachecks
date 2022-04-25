# Get-AllInstanceInfo testing 

# so the initial load doesnt skew the figures
ipmo dbatools
ipmo ./dbachecks.psd1
function prompt { Write-Host "pwsh >" -NoNewline; ' ' }
cls
# load the original function
. .\originalGet-AllInstanceInfo.ps1
. .\internal\functions\NewGet-AllInstanceInfo.ps1

$SPConfigureChecks =  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'

# Lets check just the spconfigure ones :D
$originalCode = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $smos = Connect-DbaInstance -SqlInstance $Sqlinstances -SqlCredential $cred

    foreach ($smo in $smos) {
        Get-AllInstanceInfo -Instance $smo -Tags $SPConfigureChecks -There $true
    }
}

# Lets check just the spconfigure ones :D
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
cls
Write-PSFMessage -Message $originalCodeMessage -Level Significant
Write-PSFMessage -Message $NewCodeMessage -Level Significant

# Check it works
function prompt { Write-Host "pwsh >" -NoNewline; ' ' }
cls
ipmo ./dbachecks.psd1

$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'

Invoke-DbcCheck -SqlInstance $Sqlinstances -Check DefaultTrace -SqlCredential $cred -legacy $false
Invoke-DbcCheck -SqlInstance $Sqlinstances -Check DefaultTrace -SqlCredential $cred -legacy $true

$SPConfigureChecks =  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $SPConfigureChecks -SqlCredential $cred -legacy $true
Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $SPConfigureChecks -SqlCredential $cred -legacy $false


# Lets check just the spconfigure ones :D
$originalCode = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    
    Invoke-DbcCheck -SqlInstance $Sqlinstances -Check 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation' -SqlCredential $cred -legacy $true -Show None
}

# Lets check just the spconfigure ones :D
$NewCode = {
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'

    Invoke-DbcCheck -SqlInstance $Sqlinstances -Check 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation' -SqlCredential $cred -legacy $false  -Show None
}

$originalCodetrace = Trace-Script -ScriptBlock $originalCode
$NewCodetrace = Trace-Script -ScriptBlock $NewCode

$originalCodeMessage = "With original Code it takes {0} MilliSeconds" -f $originalCodetrace.StopwatchDuration.TotalMilliseconds
$NewCodeMessage = "With New Code it takes {0} MilliSeconds" -f $NewCodetrace.StopwatchDuration.TotalMilliseconds
cls
Write-PSFMessage -Message $originalCodeMessage -Level Significant
Write-PSFMessage -Message $NewCodeMessage -Level Significant
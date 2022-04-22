## # ipmo Pester -Req 4.10.1
## ipmo ./dbachecks.psd1 # -Verbose
## # Get-MOdule Pester
## $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
## $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
## 
## 
## $Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'
## 
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred  -Verbose
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseCollation -SqlCredential $cred  
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseStatus -SqlCredential $cred  
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AdHocDistributedQueriesEnabled -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentAlert -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentServiceAccount -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check Backup -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check CIS -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ExtendedEvent -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check VirtualLogFile -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check TempDbConfiguration -SqlCredential $cred
## Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check InstanceConnection -SqlCredential $cred
## 
## ###############################endregion

ipmo ./dbachecks.psd1 # -Verbose
# Get-MOdule Pester
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password


$Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'

$PSDefaultParameterValues = @{
    "Invoke-DbcCheck:legacy" = $false
}

Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred -Show Detailed
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred -Show Diagnostic
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred -Show Minimal
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseCollation -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseStatus -SqlCredential $cred  -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AdHocDistributedQueriesEnabled -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentAlert -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentServiceAccount -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check Backup -SqlCredential $cred -Debug -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check CIS -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ExtendedEvent -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check VirtualLogFile -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check TempDbConfiguration -SqlCredential $cred -Show All
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check InstanceConnection -SqlCredential $cred -Show All 






























































































$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password


$Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'

$sql1 = Connect-DbaInstance -SqlInstance $Sqlinstances[0] -SqlCredential $cred
$sql2 = Connect-DbaInstance -SqlInstance $Sqlinstances[1] -SqlCredential $cred
$sql3 = Connect-DbaInstance -SqlInstance $Sqlinstances[2] -SqlCredential $cred


Get-DbcConfig -Name agent.validjobowner.name 
Set-DbcConfig -Name agent.validjobowner.name -Value 'NotRob','NotGrilliam','ProperJobOwnerAccount','OldNamingConventionJobAccount'
Invoke-DbcCheck -SqlInstance $sql1 -Check ValidJobOwner -SqlCredential $cred

New-DbaLogin $sql1,$sql2,$sql3 -Login Monica 
New-DbaLogin $sql1,$sql2,$sql3 -Login 'ProperJobOwnerAccount'
Set-DbaAgentJobOwner -SqlInstance $sql1,$sql2,$sql3 -Job 'IndexOptimize - USER_DATABASES' -Login Monica
Set-DbaAgentJobOwner -SqlInstance $sql1,$sql2,$sql3  -Login 'NotGrilliam'

# Dirks Bye, I am leaving script
Set-DbaAgentJobOwner -SqlInstance $sql1 -Login 'ProperJobOwnerAccount'
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred

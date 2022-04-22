## To Test pull the dbatools docker repo and cd to the samples/stackoverflow Directory

## I changed the ports because I have some of them already running SQL

##     line 17   - "7401:1433"
##     line 34   - "7402:1433"
##     line 52   - "7403:1433"

#then docker compose up -d

# cd to the root of dbachecks and checkout the pesterv5 branch


<#
What Is here
So I have removed the check for Pester v5 from the psm1 load

and created 2 internal functions Invoke-DbcCheckv4 and Invoke-DbcCheckv5

and added a legacy param to Invoke-DbcCheck
by default it passes everything on to Invoke-DbcCheckv4 which is still the same as the original Invoke-DbcCheck so it shouldnt break anything

So If you can test original work with Pester v4 that would be great.

#>

 ipmo ./dbachecks.psd1 # -Verbose

 # We run Pester V4 here because the -legacy parameter of Invoke-DbcCheck is set to true by default
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password


$Sqlinstances = 'localhost,7401','localhost,7402','localhost,7403'

Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ValidJobOwner -SqlCredential $cred  -Verbose
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseCollation -SqlCredential $cred  
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check DatabaseStatus -SqlCredential $cred  
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AdHocDistributedQueriesEnabled -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentAlert -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check AgentServiceAccount -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check Backup -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check CIS -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check ExtendedEvent -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check VirtualLogFile -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check TempDbConfiguration -SqlCredential $cred
Invoke-DbcCheck -SqlInstance $Sqlinstances[0] -Check InstanceConnection -SqlCredential $cred

###############################

 # We run Pester V5 here because the -legacy parameter of Invoke-DbcCheck is set to false as a default param

 # You dont have to reimport 
ipmo ./dbachecks.psd1 # -Verbose

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

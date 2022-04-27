## To Test performance - I pull the dbatools docker repo and cd to the samples/stackoverflow Directory

## I changed the ports because I have some of them already running SQL

##     line 17   - "7401:1433"
##     line 34   - "7402:1433"
##     line 52   - "7403:1433"

#then docker compose up -d

# cd to the root of dbachecks and checkout the pesterv5 branch

ipmo ./dbachecks.psd1

# 

$Checks = 'ModelDbGrowth','DefaultBackupCompression','SaExist','SaDisabled','SaRenamed','DefaultFilePath','AdHocDistributedQueriesEnabled','AdHocWorkload',  'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
$Checks = 'ErrorLogCount'
Compare-v4andv5Results -Checks $Checks

<#
When there are default skips (some of the CIS checks) we need to set the configs and check

Set-DbcConfig skip.security.sadisabled -Value $false
Set-DbcConfig skip.security.sadisabled -Value $true
Get-DbcConfigValue skip.security.sadisabled

Set-DbcConfig skip.security.saexist -Value $false
Set-DbcConfig skip.security.saexist -Value $true
Get-DbcConfigValue skip.security.saexist
#>

# Load the function below and then you can keep running the checks defined above in v4 and v5 and compare the performance
# You can keep updating the .Tests.ps1 files and rerunning the function without needing to re-import hte module

# You can keep updating the .Tests.ps1 files and rerunning  without needing to re-import hte module

# If you change any of the functions you WILL need to re-import or better still use a new session

# If you get odd results - or you dont get any checks run

# run the import module and the Invoke Dbc Check with Verbose and that might show you New-Json messing 
# with your files or that you are looking in PSModulePath instead of Git Repo path (run Reset-dbcConfig to fix that)


function Compare-v4andv5Results {
    param($Checks)
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
    $Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'

    # Run v4 checks
    $v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -Show None -PassThru
    # Run v5 checks 
    $v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show None -PassThru

    If (Compare-Object $v5code.Configuration.Filter.Tag.Value $v4code.TagFilter) {
        $Message = "
Uh-Oh - The Tag filters between v4 and v5 are not the same somehow.
For v4 We returned 
{0} 
and
For v5 we returned 
{1} 
    " -f ($v4code.TagFilter | Out-String), ($v5code.Configuration.Filter.Tag.Value | Out-String)
        Write-PSFMessage -Message $Message -Level Warning
    }
    else {
        $message = "
    The Tags are the same"
        Write-PSFMessage -Message $Message -Level Output
    }

    If (($v5code.TotalCount - $v5code.NotRunCount) -ne $v4code.TotalCount) {
        $Message = "
Uh-Oh - The total tests run between v4 and v5 are not the same somehow.
For v4 We ran 
{0} tests
and
For v5 we ran 
{1} tests
The MOST COMMON REASON IS you have used Tags instead of Tag in your Describe block
    " -f $v4code.TotalCount, ($v5code.TotalCount - $v5code.NotRunCount)
        Write-PSFMessage -Message $Message -Level Warning
    }
    else {
        $message = "
    The Total Tests Run are the same {0} {1} " -f $v4code.TotalCount, ($v5code.TotalCount - $v5code.NotRunCount)
        Write-PSFMessage -Message $Message -Level Output
    }

    If ($v5code.PassedCount -ne $v4code.PassedCount) {
        $Message = "
Uh-Oh - The total tests Passed between v4 and v5 are not the same somehow.
For v4 We ran 
{0} tests
and
For v5 we ran 
{1} tests
    " -f $v4code.PassedCount, $v5code.PassedCount
        Write-PSFMessage -Message $Message -Level Warning
    }
    else {
        $message = "
    The Total Tests Passed are the same {0} {1} " -f $v4code.PassedCount, $v5code.PassedCount
        Write-PSFMessage -Message $Message -Level Output
    }
 

    If ($v5code.FailedCount -ne $v4code.FailedCount) {
        $Message = "
Uh-Oh - The total tests Failed between v4 and v5 are not the same somehow.
For v4 We ran 
{0} tests
and
For v5 we ran 
{1} tests
    " -f $v4code.FailedCount, $v5code.FailedCount
        Write-PSFMessage -Message $Message -Level Warning
    }
    else {
        $message = "
    The Total Tests Failed are the same {0} {1} " -f $v4code.FailedCount, $v5code.FailedCount
        Write-PSFMessage -Message $Message -Level Output
    }

    If ($v5code.SkippedCount -ne $v4code.SkippedCount) {
        $Message = "
Uh-Oh - The total tests Skipped between v4 and v5 are not the same somehow.
For v4 We ran 
{0} tests
and
For v5 we ran 
{1} tests
    " -f $v4code.SkippedCount, $v5code.SkippedCount
        Write-PSFMessage -Message $Message -Level Warning
    }
    else {
        $message = "
    The Total Tests Skipped are the same {0} {1} "-f $v4code.SkippedCount, $v5code.SkippedCount
        Write-PSFMessage -Message $Message -Level Output
    }
 
}

<#e
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false
Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true 

$smo = $Instance = Connect-DbaInstance -Sqlinstance $SqlInstances[0] -SqlCredential $cred
#>
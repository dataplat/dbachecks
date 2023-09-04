# Oslo Demo

./build.ps1 -tasks build

#region setup
$containers = $SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'

$PSDefaultParameterValues = @{
    "*:SQlInstance"   = $SQLInstances
    "*:SqlCredential" = $cred
}
#endregion

#region What do we have?

Get-DbaDatabase | Select-Object Sqlinstance, Name, Status

Get-DbaAgentJob | Select-Object Sqlinstance, Name, Enabled
#end region

Get-DbaLastBackup | Select-Object Sqlinstance, Database, LastFullBackup | Format-Table

# lets run a couple of tests

# this one shows that the old existing code will work
# the legacy switch is set to true by default

Invoke-DbcCheck -Check InstanceConnection, DatabaseStatus -Show $show

# So lets show the shiny new faster code - legacy switch set to false

Invoke-DbcCheck -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false


# The Authentication check failed but we  would like to pass  - lets  set config
Set-DbcConfig -Name policy.connection.authscheme -Value SQL

# run again

Invoke-DbcCheck -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false

# Hmmm, we know that we will never be able to remote onto these containers so let talk about skipping. No Claudio not that sort of skipping!!
Set-DbcConfig -Name skip.connection.remoting -Value $true

# run again

Invoke-DbcCheck -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false

# So much quicker !!! OK for one check it will be slower. For two it will probably be about the same but for 3 or more it will be quicker. Much quicket. Exrapolate that to 100 checks and a 1000 instances you can see the difference.

# This is how we know - We perf test our PowerShell code
# This will take about 80-100 seconds to run so run first then talk!

$Checks = 'ErrorLogCount', 'XpCmdShellDisabled', 'WhoIsActiveInstalled', 'CLREnabled', 'TwoDigitYearCutoff', 'MaxDopInstance', 'ErrorLogCount', 'ModelDbGrowth', 'DefaultBackupCompression', 'SaExist', 'SaDisabled', 'SaRenamed', 'DefaultFilePath', 'AdHocDistributedQueriesEnabled', 'AdHocWorkload', 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation', 'ServerNameMatch', 'OrphanedFile', 'MaxMemory', 'PublicPermission'

Invoke-PerfAndValidateCheck -Checks $Checks

# I want to use the results in a different way

# ok lets run the checks and save the out put to a variable so that we can show you what happens. Notice we need the -PassThru switch

$CheckResults = Invoke-DbcCheck -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false -PassThru

# this is our base results object
$CheckResults

# lets convert it to something useful

$SomethingUseful = $CheckResults | Convert-DbcResult

$SomethingUseful
$SomethingUseful | Format-Table
#TODO: fix this Checking Instance Connection on on dbachecks3

$SomethingUseful | Select-Object -First 1

# Label huh - what is that?
# label these results so that they can be filtered later

$Coffee = $CheckResults | Convert-DbcResult -Label 'CoffeeFilter'

$Coffee | Select-Object -First 1

# Now we can set those to a file if we want

$CheckResults | Convert-DbcResult -Label 'CoffeeFilter' | Set-DbcFile -FileType Json -FilePath . -FileName oslo -Verbose
$CheckResults | Convert-DbcResult -Label 'Whiskey' | Set-DbcFile -FileType Json -FilePath . -FileName oslo -Append

code ./oslo.json

# or put them into a database table

$CheckResults | Convert-DbcResult -Label 'claudiodidthis' | Write-DbcTable -SqlInstance dbachecks1 -SqlCredential $cred -Database tempdb

Invoke-DbaQuery -SqlInstance dbachecks1 -SqlCredential $cred -Database tempdb -Query 'SELECT COUNT(*) FROM CheckResults'

# AUDIENCE AND OTHER PRESENTERS - WE NEED REMINDERS HERE !!!
# YOU CANT DO THIS FROM HERE - Open Windows terminal on the host and run

Start-DbcPowerBi -FromDatabase

# AUDIENCE AND OTHER PRESENTERS - WE NEED REMINDERS HERE !!!
# then use localhost,7401 tempdb and u:sqladmin p:dbatools.IO

# question turn off a container and talk about the fails?


## made some funky results for the Power Bi

$CheckResults = Invoke-DbcCheck -Check Instance, Database -Show $show -legacy $false -PassThru

$CheckResults | Convert-DbcResult -Label 'DatabaseInstance' | Write-DbcTable -SqlInstance dbachecks1 -SqlCredential $cred -Database tempdb -Verbose

$CheckResults = Invoke-DbcCheck -Check compatibilitylevel -Show $show -legacy $false -PassThru
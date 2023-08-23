# Oslo Demo

./build.ps1 -tasks build

#region setup
$containers = $SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$show = 'All'
#endregion

#region What do we have?

Get-DbaDatabase -SqlInstance $Sqlinstances -SqlCredential $cred -ExcludeSystem | Select-Object Sqlinstance, DatabaseName, Status

Get-DbaAgentJob -SqlInstance $Sqlinstances -SqlCredential $cred | Select-Object Sqlinstance, Name, Enabled
#end region

Get-DbaLastBackup -SqlInstance $Sqlinstances -SqlCredential $cred | Select-Object Sqlinstance, Database, LastFullBackup | Format-Table

# lets run a couple of tests

# this one shows that the old existing code will work
# the legacy switch is set to true by default

Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -Show $show

# So lets show the shiny new faster code - legacy switch set to false

Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false


# The Authentication check failed but we  would like to pass  - lets  set config
Set-DbcConfig -Name policy.connection.authscheme -Value SQL

# run again

Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false

# Hmmm, we know that we will never be able to remote onto these containers so let talk about skipping. No Claudio not that sort of skipping!!
Set-DbcConfig -Name skip.connection.remoting -Value $true

# run again

Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false

# So much quicker !!! OK for one check it will be slower. For two it will probably be about the same but for 3 or more it will be quicker. Much quicket. Exrapolate that to 100 checks and a 1000 instances you can see the difference.

# This is how we know - We perf test our PowerShell code
# This will take about 80-100 seconds to run so run first then talk!

$Checks = 'ErrorLogCount', 'XpCmdShellDisabled', 'WhoIsActiveInstalled', 'CLREnabled', 'TwoDigitYearCutoff', 'MaxDopInstance', 'ErrorLogCount', 'ModelDbGrowth', 'DefaultBackupCompression', 'SaExist', 'SaDisabled', 'SaRenamed', 'DefaultFilePath', 'AdHocDistributedQueriesEnabled', 'AdHocWorkload', 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation', 'ServerNameMatch', 'OrphanedFile', 'MaxMemory', 'PublicPermission'

Invoke-PerfAndValidateCheck -Checks $Checks

# I want to use the results in a different way

# ok lets run the checks and save the out put to a variable so that we can show you what happens. Notice we need the -PassThru switch

$CheckResults = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check InstanceConnection, DatabaseStatus -Show $show -legacy $false -PassThru

# this is our base results object
$CheckResults

# lets convert it to something useful

$SomethingUseful = $CheckResults | Convert-DbcResult

$SomethingUseful
$SomethingUseful | Format-Table

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

$CheckResults | Convert-DbcResult -Label 'CoffeeFilter' | Write-DbcTable -SqlInstance dbachecks1 -SqlCredential $cred -Database tempdb -Verbose

Invoke-DbaQuery -SqlInstance dbachecks1 -SqlCredential $cred -Database tempdb -Query 'SELECT * FROM CheckResults'

# YOU CANT DO THIS FROM HERE - Open Windows terminal on the host and run

Start-DbcPowerBi -FromDatabase

# then use localhost,7401 tempdb and u:sqladmin p:dbatools.IO

# question turn off a container adn talk about hte fails?


## made some funky results for the Power Bi

$CheckResults = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check Instance, Database -Show $show -legacy $false -PassThru

$CheckResults | Convert-DbcResult -Label 'DatabaseInstance' | Write-DbcTable -SqlInstance dbachecks1 -SqlCredential $cred -Database tempdb -Verbose

$CheckResults = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check compatibilitylevel -Show $show -legacy $false -PassThru
<#
This file is used to hold the Assertions for the Instance.Tests

When adding new checks or improving existing ones -

    - Ensure your branch is up to date with the development branch
    - In the Instance.Assertions.ps1 - Add a New code block in the switch using the unique tag name

                'MemoryDump' {  # This is the unique tag
                if ($There) {  ## we need $There to save trying to gather information from later checks for an instance that is not contactable
                    ## Then a try catch to gather the required information for the assertion and set a variable to a custom object
                    try {
                        $MaxDump = [pscustomobject] @{
                            # Warning Action removes dbatools output for version too low from test results
                            # Skip on the it will show in the results
                            Count = (Get-DbaDump -SqlInstance $psitem -WarningAction SilentlyContinue).Count
                        }
                    }
                    # In the catch set There to false and create an object with the same name but an obvious error entry
                    catch {
                        $There = $false
                        $MaxDump = [pscustomobject] @{
                            Count = 'We Could not Connect to $Instance'
                        }
                    }
                }
                # the else matches the catch block
                else {
                    $There = $false
                    $MaxDump = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }

    - Create an Assertion for the Check

    Name must start Assert
    function Assert-MaxDump {
        Pass in params for configs
    Param($AllInstanceInfo,$maxdumps)
    Ensure Because has good information
    $AllInstanceInfo.MaxDump.Count | Should -BeLessThan $maxdumps -Because "We expected less than $maxdumps dumps but found $($AllInstanceInfo.MaxDump.Count). Memory dumps often suggest issues with the SQL Server instance"
}

    - In The Instance.Tests.ps1 file create the check

        # Must be in its own describe block, must use an s on Tags, first tag must be unique, last tag must be $filename
        Describe "SQL Memory Dumps" -Tags MemoryDump, Medium, $filename {
        # Gather any config items here so that the code to match config to check works
        $maxdumps = Get-DbcConfigValue	policy.dump.maxcount
        # We check if the instance is contactable at the top of the file, use this block with the context title the same as the proper test below
        if ($NotContactable -contains $psitem) {
            Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
                It "Can't Connect to $Psitem" {
                    $false	|  Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            # The title must end $psitem
            Context "Checking that dumps on $psitem do not exceed $maxdumps for $psitem" {
                # The check itself - a skip can be added from a config value if required -Skip:$Skip or per version
                It "dump count of $count is less than or equal to the $maxdumps dumps on $psitem" -Skip:($InstanceSMO.Version.Major -lt 10 ) {
                    # Call the assertion with any parameters here
                    Assert-MaxDump -AllInstanceInfo $AllInstanceInfo -maxdumps $maxdumps
                }
            }
        }
    }

    - In the tests\checks\InstanceChecks.Tests.ps1 file add tests for the assertions by mocking passing and failing tests following the code in the file
    - In a NEW session - checkout your branch of dbachecks
        cd to the root of the repo
        import the module with
            ipmo .\dbachecks.psd1
        Run the Pester tests

        Invoke-Pester .\tests\ -ExcludeTag Integration -Show Fails

It starts with the Get-AllInstanceInfo which uses all of the unique
 tags that have been passed and gathers the required information
 which can then be used for the assertions.

 The long term aim is to make Get-AllInstanceInfo as performant as
 possible and to cover all of the tests
#>

function Get-AllInstanceInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags, $There)
    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {
        'ErrorLog' {
            if ($There) {
                try {
                    $logWindow = Get-DbcConfigValue -Name policy.errorlog.warningwindow
                    # so that it can be mocked
                    function Get-ErrorLogEntry {
                        # get the number of the first error log that was created after the log window config
                        $OldestErrorLogNumber = ($InstanceSMO.EnumErrorLogs() | Where-Object { $psitem.CreateDate -gt (Get-Date).AddDays( - $LogWindow) } | Sort-Object ArchiveNo -Descending | Select-Object -First 1).ArchiveNo + 1
                        # Get the Error Log entries for each one
                        (0..$OldestErrorLogNumber).ForEach{
                            $InstanceSMO.ReadErrorLog($psitem).Where{ $_.Text -match "Severity: 1[7-9]|Severity: 2[0-4]" }
                        }
                    }
                    # It is not enough to check the CreateDate on the log, you must check the LogDate on every error record as well.
                    $ErrorLog = @(Get-ErrorLogEntry).ForEach{
                        [PSCustomObject]@{
                            LogDate     = $psitem.LogDate
                            ProcessInfo = $Psitem.ProcessInfo
                            Text        = $Psitem.Text
                        } | Where-Object { $psitem.LogDate -gt (Get-Date).AddDays( - $LogWindow) }
                    }
                }
                catch {
                    $There = $false
                    $ErrorLog = [PSCustomObject]@{
                        LogDate      = 'Do not know the Date'
                        ProcessInfo  = 'Do not know the Process'
                        Text         = 'Do not know the Test'
                        InstanceName = 'An Error occurred ' + $Instance
                    }
                }
            }
            else {
                $There = $false
                $ErrorLog = [PSCustomObject]@{
                    LogDate      = 'Do not know the Date'
                    ProcessInfo  = 'Do not know the Process'
                    Text         = 'Do not know the Test'
                    InstanceName = 'An Error occurred ' + $Instance
                }
            }
        }
        'DefaultTrace' {
            if ($There) {
                try {
                    $SpConfig = Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'DefaultTraceEnabled'
                    $DefaultTrace = [pscustomobject] @{
                        ConfiguredValue = $SpConfig.ConfiguredValue
                    }
                }
                catch {
                    $There = $false
                    $DefaultTrace = [pscustomobject] @{
                        ConfiguredValue = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $DefaultTrace = [pscustomobject] @{
                    ConfiguredValue = 'We Could not Connect to $Instance'
                }
            }
        }

        'OleAutomationProceduresDisabled' {
            if ($There) {
                try {
                    $SpConfig = Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'OleAutomationProceduresEnabled'
                    $OleAutomationProceduresDisabled = [pscustomobject] @{
                        ConfiguredValue = $SpConfig.ConfiguredValue
                    }
                }
                catch {
                    $There = $false
                    $OleAutomationProceduresDisabled = [pscustomobject] @{
                        ConfiguredValue = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $OleAutomationProceduresDisabled = [pscustomobject] @{
                    ConfiguredValue = 'We Could not Connect to $Instance'
                }
            }
        }

        'CrossDBOwnershipChaining' {
            if ($There) {
                try {
                    $SpConfig = Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'CrossDBOwnershipChaining'
                    $CrossDBOwnershipChaining = [pscustomobject] @{
                        ConfiguredValue = $SpConfig.ConfiguredValue
                    }
                }
                catch {
                    $There = $false
                    $CrossDBOwnershipChaining = [pscustomobject] @{
                        ConfiguredValue = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $CrossDBOwnershipChaining = [pscustomobject] @{
                    ConfiguredValue = 'We Could not Connect to $Instance'
                }
            }
        }

        'ScanForStartupProceduresDisabled' {
            if ($There) {
                try {
                    $SpConfig = Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'ScanForStartupProcedures'

                    $query = "
                        SELECT name
                        FROM sys.procedures
                        WHERE OBJECTPROPERTY(OBJECT_ID, 'ExecIsStartup') = 1
                            AND name <> 'sp_MSrepl_startup'"
                    $results = Invoke-DbaQuery -SqlInstance $Instance -Query $query

                    if ($null -eq $results)  {
                        $Value = 0
                    } else {
                        $Value = $SpConfig.ConfiguredValue
                    }

                    $ScanForStartupProceduresDisabled = [pscustomobject] @{
                        ConfiguredValue = $Value
                    }
                }
                catch {
                    $There = $false
                    $ScanForStartupProceduresDisabled = [pscustomobject] @{
                        ConfiguredValue = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $ScanForStartupProceduresDisabled = [pscustomobject] @{
                    ConfiguredValue = 'We Could not Connect to $Instance'
                }
            }
        }
        'MemoryDump' {
            if ($There) {
                try {
                    $daystocheck = Get-DbcConfigValue policy.instance.memorydumpsdaystocheck
                    if ($null -eq $daystocheck) {
                        $datetocheckfrom = '0001-01-01'
                    }
                    else {
                        $datetocheckfrom = (Get-Date).ToUniversalTime().AddDays( - $daystocheck )
                    }
                    $MaxDump = [pscustomobject] @{
                        # Warning Action removes dbatools output for version too low from test results
                        # Skip on the it will show in the results
                        Count = (@(Get-DbaDump -SqlInstance $Instance -WarningAction SilentlyContinue).Where{ $_.CreationTime -gt $datetocheckfrom}).Count
                    }
                }
                catch {
                    $There = $false
                    $MaxDump = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $MaxDump = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }

        'RemoteAccessDisabled' {
            if ($There) {
                try {
                    $SpConfig = Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'RemoteAccess'
                    $RemoteAccessDisabled = [pscustomobject] @{
                        ConfiguredValue = $SpConfig.ConfiguredValue
                    }
                }
                catch {
                    $There = $false
                    $RemoteAccessDisabled = [pscustomobject] @{
                        ConfiguredValue = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $RemoteAccessDisabled = [pscustomobject] @{
                    ConfiguredValue = 'We Could not Connect to $Instance'
                }
            }
        }

        'LatestBuild' {
            if ($There) {
                try {
                    $results = Test-DbaBuild -SqlInstance $Instance -Latest
                    $LatestBuild = [pscustomobject] @{
                        Compliant = $results.Compliant
                    }
                }
                catch {
                    $There = $false
                    $LatestBuild = [pscustomobject] @{
                        Compliant = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LatestBuild = [pscustomobject] @{
                    Compliant = 'We Could not Connect to $Instance'
                }
            }
        }
        'SaDisabled' {
            if ($There) {
                try {
                    #This needs to be done in query just in case the account had already been renamed
                    $login = Get-DbaLogin -SqlInstance $Instance | Where-Object Id -eq 1
                    $SaDisabled = [pscustomobject] @{
                        Disabled = $login.IsDisabled
                    }
                }
                catch {
                    $There = $false
                    $SaDisabled = [pscustomobject] @{
                        Disabled = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $SaDisabled = [pscustomobject] @{
                    Disabled = 'We Could not Connect to $Instance'
                }
            }
        }
        'SaExist' {
            if ($There) {
                try {
                    $SaExist = [pscustomobject] @{
                        Exist = @(Get-DbaLogin -SqlInstance $Instance -Login sa).Count
                    }
                }
                catch {
                    $There = $false
                    $SaExist = [pscustomobject] @{
                        Exist = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $SaExist = [pscustomobject] @{
                    Exist = 'We Could not Connect to $Instance'
                }
            }
        }
        'SqlEngineServiceAccount' {
            if ($There) {
                try {
                    $ComputerName , $InstanceName = $Instance.Name.Split('\')
                    if ($null -eq $InstanceName) {
                        $InstanceName = 'MSSQLSERVER'
                    }
                    $SqlEngineService = Get-DbaService -ComputerName $ComputerName -InstanceName $instanceName -Type Engine -ErrorAction SilentlyContinue
                    $EngineService = [pscustomobject] @{
                        State     = $SqlEngineService.State
                        StartType = $SqlEngineService.StartMode
                    }
                }
                catch {
                    $There = $false
                    $EngineService = [pscustomobject] @{
                        State     = 'We Could not Connect to $Instance $ComputerName , $InstanceName from catch'
                        StartType = 'We Could not Connect to $Instance $ComputerName , $InstanceName from catch'
                    }
                }
            }
            else {
                $There = $false
                $EngineService = [pscustomobject] @{
                    State     = 'We Could not Connect to $Instance'
                    StartType = 'We Could not Connect to $Instance'
                }
            }
        }
        'PublicRolePermission' {
            if ($There) {
                try {
                    #This needs to be done in query just in case the account had already been renamed
                    $query = "
                        SELECT Count(*) AS [RowCount]
                        FROM master.sys.server_permissions
                        WHERE (grantee_principal_id = SUSER_SID(N'public') and state_desc LIKE 'GRANT%')
                            AND NOT (state_desc = 'GRANT' and [permission_name] = 'VIEW ANY DATABASE' and class_desc = 'SERVER')
                            AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 2)
                            AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 3)
                            AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 4)
                            AND NOT (state_desc = 'GRANT' and [permission_name] = 'CONNECT' and class_desc = 'ENDPOINT' and major_id = 5);
                        "
                    $results = Invoke-DbaQuery -SqlInstance $Instance -Query $query

                    $PublicRolePermission = [pscustomobject] @{
                        Count = $results.RowCount
                    }
                }
                catch {
                    $There = $false
                    $PublicRolePermission = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $PublicRolePermission = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }
        'BuiltInAdmin' {
            if ($There) {
                try {
                    $BuiltInAdmin = [pscustomobject] @{
                        Exist = @(Get-DbaLogin -SqlInstance $Instance -Login "BUILTIN\Administrators").Count
                    }
                }
                catch {
                    $There = $false
                    $BuiltInAdmin = [pscustomobject] @{
                        Exist = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $BuiltInAdmin = [pscustomobject] @{
                    Exist = 'We Could not Connect to $Instance'
                }
            }
        }
        'LocalWindowsGroup' {
            if ($There) {
                try {
                    $ComputerName, $InstanceName = $Instance.Name.Split('\')
                    if ($null -eq $InstanceName){
                        $InstanceName = 'MSSQLSERVER'
                    }
                    $logins = Get-DbaLogin -SqlInstance $Instance | Where-Object {$_.LoginType -eq 'WindowsGroup' -and $_.Name.Split('\') -eq $ComputerName}
                    if ($null -ne $logins) {
                        $LocalWindowsGroup = [pscustomobject] @{
                            Exist = $true
                        }
                    }
                    else {
                        $LocalWindowsGroup = [pscustomobject] @{
                            Exist = $false
                        }
                    }
                }
                catch {
                    $There = $false
                    $LocalWindowsGroup = [pscustomobject] @{
                        Exist = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LocalWindowsGroup = [pscustomobject] @{
                    Exist = 'We Could not Connect to $Instance'
                }
            }
        }
        'LoginAuditFailed' {
            if ($There) {
                try {
                    $results = Get-DbaInstanceProperty -SQLInstance $instance -InstanceProperty AuditLevel
                    $LoginAuditFailed = [pscustomobject] @{
                        AuditLevel = $results.Value
                    }
                }
                catch {
                    $There = $false
                    $LoginAuditFailed = [pscustomobject] @{
                        AuditLevel = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LoginAuditFailed = [pscustomobject] @{
                    AuditLevel = 'We Could not Connect to $Instance'
                }
            }
        }

        'LoginAuditSuccessful' {
            if ($There) {
                try {
                    $results = Get-DbaInstanceProperty -SQLInstance $instance -InstanceProperty AuditLevel
                    $LoginAuditSuccessful = [pscustomobject] @{
                        AuditLevel = $results.Value
                    }
                }
                catch {
                    $There = $false
                    $LoginAuditSuccessful = [pscustomobject] @{
                        AuditLevel = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LoginAuditSuccessful = [pscustomobject] @{
                    AuditLevel = 'We Could not Connect to $Instance'
                }
            }
        }

        'SqlAgentProxiesNoPublicRole' {
            if ($There) {
                try {
                    $SqlAgentProxiesWithPublicRole = @()

                    Get-DbaAgentProxy -SqlInstance $Instance | ForEach-Object {
                        if ($psitem.EnumMsdbRoles().Name -contains 'public') {
                            $SqlAgentProxyWithPublicRole = [pscustomobject] @{
                                Name               = $psitem.Name
                                CredentialName     = $psitem.CredentialName
                                CredentialIdentity = $psitem.CredentialIdentity
                            }
                            $SqlAgentProxiesWithPublicRole += $SqlAgentProxyWithPublicRole
                        }
                    }
                }
                catch {
                    $There = $false
                    $SqlAgentProxiesWithPublicRole = [pscustomobject] @{
                        Name               = 'We Could not Connect to $Instance'
                        CredentialName     = $null
                        CredentialIdentity = $null
                    }
                }
            }
            else {
                $There = $false
                $SqlAgentProxiesWithPublicRole = [pscustomobject] @{
                    Name               = 'We Could not Connect to $Instance'
                    CredentialName     = $null
                    CredentialIdentity = $null
                }
            }
        }
        'HideInstance' {
            if ($There) {
                try {
                    $results = Get-DbaHideInstance -SqlInstance $Instance

                    $HideInstance = [pscustomobject] @{
                        HideInstance = $results.HideInstance
                    }
                }
                catch {
                    $There = $false
                    $HideInstance = [pscustomobject] @{
                        HideInstance = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $HideInstance = [pscustomobject] @{
                    HideInstance = 'We Could not Connect to $Instance'
                }
            }
        }

        'EngineServiceAdmin' {
            if ($There) {
                if ($IsLinux) {
                    $EngineServiceAdmin = [pscustomobject] @{
                        Exist = 'We Cant Check running on Linux'
                    }
                }
                else {
                    try {
                        $ComputerName , $InstanceName = $Instance.Name.Split('\')
                        if ($null -eq $InstanceName) {
                            $InstanceName = 'MSSQLSERVER'
                        }
                        $SqlEngineService = Get-DbaService -ComputerName $ComputerName -InstanceName $instanceName -Type Engine -ErrorAction SilentlyContinue
                        $LocalAdmins = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-LocalGroupMember -Group "Administrators" } -ErrorAction SilentlyContinue

                        $EngineServiceAdmin = [pscustomobject] @{
                            Exist = $localAdmins.Name.Contains($SqlEngineService.StartName)
                        }
                    }
                    catch [System.Exception] {
                        if ($_.Exception.Message -like '*No services found in relevant namespaces*') {
                            $EngineServiceAdmin = [pscustomobject] @{
                                Exist = $false
                            }
                        }
                        else {
                            $EngineServiceAdmin = [pscustomobject] @{
                                Exist = 'Some sort of failure'
                            }
                        }
                    }
                    catch {
                        $There = $false
                        $EngineServiceAdmin = [pscustomobject] @{
                            Exist = 'We Could not Connect to $Instance $ComputerName , $InstanceName from catch'
                        }
                    }
                }
            }
            else {
                $There = $false
                $EngineServiceAdmin = [pscustomobject] @{
                    Exist = 'We Could not Connect to $Instance'
                }
            }
        }

        'AgentServiceAdmin' {
            if ($There) {
                if ($IsLinux) {
                    $AgentServiceAdmin = [pscustomobject] @{
                        Exist = 'We Cant Check running on Linux'
                    }
                }
                else {
                    try {
                        $ComputerName , $InstanceName = $Instance.Name.Split('\')
                        if ($null -eq $InstanceName) {
                            $InstanceName = 'MSSQLSERVER'
                        }
                        $SqlAgentService = Get-DbaService -ComputerName $ComputerName -InstanceName $instanceName -Type Agent -ErrorAction SilentlyContinue
                        $LocalAdmins = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-LocalGroupMember -Group "Administrators" } -ErrorAction SilentlyContinue

                        $AgentServiceAdmin = [pscustomobject] @{
                            Exist = $localAdmins.Name.Contains($SqlAgentService.StartName)
                        }
                    }
                    catch [System.Exception] {
                        if ($_.Exception.Message -like '*No services found in relevant namespaces*') {
                            $AgentServiceAdmin = [pscustomobject] @{
                                Exist = $false
                            }
                        }
                        else {
                            $AgentServiceAdmin = [pscustomobject] @{
                                Exist = 'Some sort of failure'
                            }
                        }
                    }
                    catch {
                        $There = $false
                        $AgentServiceAdmin = [pscustomobject] @{
                            Exist = 'We Could not Connect to $Instance $ComputerName , $InstanceName from catch'
                        }
                    }
                }
            }
            else {
                $There = $false
                $AgentServiceAdmin = [pscustomobject] @{
                    Exist = 'We Could not Connect to $Instance'
                }
            }
        }

        'FullTextServiceAdmin' {
            if ($There) {
                if ($IsLinux) {
                    $FullTextServiceAdmin = [pscustomobject] @{
                        Exist = 'We Cant Check running on Linux'
                    }
                }
                else {
                    try {
                        $ComputerName , $InstanceName = $Instance.Name.Split('\')
                        if ($null -eq $InstanceName) {
                            $InstanceName = 'MSSQLSERVER'
                        }
                        $SqlFullTextService = Get-DbaService -ComputerName $ComputerName -InstanceName $instanceName -Type FullText -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -WarningVariable WarVar
                        $LocalAdmins = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-LocalGroupMember -Group "Administrators" } -ErrorAction SilentlyContinue
                        $FullTextServiceAdmin = [pscustomobject] @{
                            Exist = $localAdmins.Name.Contains($SqlFullTextService.StartName)
                        }
                    }
                    catch [System.Exception] {
                        if ($_.Exception.Message -like '*No services found in relevant namespaces*') {
                            $FullTextServiceAdmin = [pscustomobject] @{
                                Exist = $false
                            }
                        }
                        else {
                            $FullTextServiceAdmin = [pscustomobject] @{
                                Exist = 'Some sort of failure'
                            }
                        }
                    }
                    catch {
                        $There = $false
                        $FullTextServiceAdmin = [pscustomobject] @{
                            Exist = "We Could not Connect to $Instance $ComputerName , $InstanceName from catch"
                        }
                    }
                }

            }
            else {
                $There = $false
                $FullTextServiceAdmin = [pscustomobject] @{
                    Exist = 'We Could not Connect to $Instance'
                }
            }
        }

        'LoginCheckPolicy' {
            if ($There) {
                try {
                    $LoginCheckPolicy = [pscustomobject] @{
                        Count = @(Get-DbaLogin -SQLInstance $instance -Type SQL | Where-Object { $_.PasswordPolicyEnforced -eq $false -and $_.IsDisabled -eq $false}).Count
                    }
                }
                catch {
                    $There = $false
                    $LoginCheckPolicy = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LoginCheckPolicy = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }

        'LoginPasswordExpiration' {
            if ($There) {
                try {
                    $role = Get-DbaServerRole -SQLInstance $instance -ServerRole "sysadmin"

                    $LoginPasswordExpiration = [pscustomobject] @{
                        Count = @(Get-DbaLogin -SQLInstance $instance -Login @($role.Login) -Type SQL | Where-Object { $_.PasswordExpirationEnabled -eq $false -and $_.IsDisabled -eq $false}).Count
                    }
                }
                catch {
                    $There = $false
                    $LoginPasswordExpiration = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LoginPasswordExpiration = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }
        'LoginMustChange' {
            if ($There) {
                try {
                    $role = Get-DbaServerRole -SQLInstance $instance -ServerRole "sysadmin"

                    $LoginMustChange = [pscustomobject] @{
                        Count = @(Get-DbaLogin -SQLInstance $instance -Login @($role.Login) -Type SQL | Where-Object { $_.IsMustChange -eq $false -and $_.IsDisabled -eq $false -and $null -eq $_LastLogin }).Count
                    }
                }
                catch {
                    $There = $false
                    $LoginMustChange = [pscustomobject] @{
                        Count = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $LoginMustChange = [pscustomobject] @{
                    Count = 'We Could not Connect to $Instance'
                }
            }
        }

        'SQLMailXPsDisabled' {
            if ($There) {
                try {
                    $SpConfig = Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'SqlMailXPsEnabled'
                    $SQLMailXPsDisabled = [pscustomobject] @{
                        ConfiguredValue = $SpConfig.ConfiguredValue
                    }
                }
                catch {
                    $There = $false
                    $SQLMailXPsDisabled = [pscustomobject] @{
                        ConfiguredValue = 'We Could not Connect to $Instance'
                    }
                }
            }
            else {
                $There = $false
                $SQLMailXPsDisabled = [pscustomobject] @{
                    ConfiguredValue = 'We Could not Connect to $Instance'
                }
            }
        }

        Default { }
    }
    [PSCustomObject]@{
        ErrorLog                         = $ErrorLog
        DefaultTrace                     = $DefaultTrace
        MaxDump                          = $MaxDump
        CrossDBOwnershipChaining         = $CrossDBOwnershipChaining
        ScanForStartupProceduresDisabled = $ScanForStartupProceduresDisabled
        RemoteAccess                     = $RemoteAccessDisabled
        OleAutomationProceduresDisabled  = $OleAutomationProceduresDisabled
        LatestBuild                      = $LatestBuild
        SaExist                          = $SaExist
        SaDisabled                       = $SaDisabled
        EngineService                    = $EngineService
        SqlAgentProxiesWithPublicRole    = $SqlAgentProxiesWithPublicRole
        HideInstance                     = $HideInstance
        LoginAuditFailed                 = $LoginAuditFailed
        LoginAuditSuccessful             = $LoginAuditSuccessful
        EngineServiceAdmin               = $EngineServiceAdmin
        AgentServiceAdmin                = $AgentServiceAdmin
        FullTextServiceAdmin             = $FullTextServiceAdmin
        LocalWindowsGroup                = $LocalWindowsGroup
        BuiltInAdmin                     = $BuiltInAdmin
        PublicRolePermission             = $PublicRolePermission
        LoginCheckPolicy                 = $LoginCheckPolicy
        LoginPasswordExpiration          = $LoginPasswordExpiration
        LoginMustChange                  = $LoginMustChange
        SQLMailXPsDisabled = $SQLMailXPsDisabled
    }
}

function Assert-DefaultTrace {
    Param($AllInstanceInfo)
    $AllInstanceInfo.DefaultTrace.ConfiguredValue | Should -Be 1 -Because "We expected the Default Trace to be enabled"
}
function Assert-EngineState {
    Param($AllInstanceInfo, $state)
    $AllInstanceInfo.EngineService.State | Should -Be $state -Because "The SQL Service was expected to be $state"
}
function Assert-EngineStartType {
    Param($AllInstanceInfo, $starttype)
    $AllInstanceInfo.EngineService.StartType | Should -Be $starttype -Because "The SQL Service Start Type was expected to be $starttype"
}
function Assert-EngineStartTypeCluster {
    Param($AllInstanceInfo)
    $AllInstanceInfo.EngineService.StartType | Should -Be "Manual" -Because 'Clustered Instances required that the SQL engine service is set to manual'
}

function Assert-OleAutomationProcedures {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param($AllInstanceInfo)
    $AllInstanceInfo.OleAutomationProceduresDisabled.ConfiguredValue | Should -Be 0 -Because "We expect the OLE Automation Procedures to be disabled"
}
function Assert-ScanForStartupProcedures {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    param ($AllInstanceInfo, $ScanForStartupProcsDisabled)
    ($AllInstanceInfo.ScanForStartupProceduresDisabled.ConfiguredValue -eq 0)  | Should -Be $ScanForStartupProcsDisabled -Because "We expected the scan for startup procedures to be configured correctly"
}
function Assert-MaxDump {
    Param($AllInstanceInfo, $maxdumps)
    $AllInstanceInfo.MaxDump.Count | Should -BeLessThan $maxdumps -Because "We expected less than $maxdumps dumps but found $($AllInstanceInfo.MaxDump.Count). Memory dumps often suggest issues with the SQL Server instance"
}

function Assert-RemoteAccess {
    param ($AllInstanceInfo)
    $AllInstanceInfo.RemoteAccess.ConfiguredValue | Should -Be 0 -Because "We expected Remote Access to be disabled"
}

function Assert-InstanceMaxDop {
    Param(
        [string]$Instance,
        [switch]$UseRecommended,
        [int]$MaxDopValue
    )
    $MaxDop = @(Test-DbaMaxDop -SqlInstance $Instance)[0]
    if ($UseRecommended) {
        #if UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the the RecommendedMaxDop property
        $MaxDop.CurrentInstanceMaxDop | Should -Be $MaxDop.RecommendedMaxDop -Because "We expect the MaxDop Setting to be the recommended value $($MaxDop.RecommendedMaxDop)"
    }
    else {
        #if not UseRecommended - check that the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
        $MaxDop.CurrentInstanceMaxDop | Should -Be $MaxDopValue -Because "We expect the MaxDop Setting to be $MaxDopValue"
    }
}

function Assert-BackupCompression {
    Param($Instance, $defaultbackupcompression)
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'DefaultBackupCompression').ConfiguredValue -eq 1 | Should -Be $defaultbackupcompression -Because 'The default backup compression should be set correctly'
}

function Assert-TempDBSize {
    Param($Instance)

    @((Get-DbaDbFile -SqlInstance $Instance -Database tempdb).Where{ $_.Type -eq 0 }.Size.Megabyte | Select-Object -Unique).Count | Should -Be 1 -Because "We want all the tempdb data files to be the same size - See https://blogs.sentryone.com/aaronbertrand/sql-server-2016-tempdb-fixes/ and https://www.brentozar.com/blitz/tempdb-data-files/ for more information"
}

function Assert-InstanceSupportedBuild {
    Param(
        [string]$Instance,
        [int]$BuildWarning,
        [string]$BuildBehind,
        [DateTime]$Date
    )
    #If $BuildBehind check against SP/CU parameter to determine validity of the build
    if ($BuildBehind) {
        $results = Test-DbaBuild -SqlInstance $Instance -SqlCredential $sqlcredential -MaxBehind $BuildBehind
        $Compliant = $results.Compliant
        $Build = $results.build
        $Compliant | Should -Be $true -Because "this build $Build should not be behind the required build"
        #If no $BuildBehind only check against support dates
    }
    else {
        $Results = Test-DbaBuild -SqlInstance $Instance -SqlCredential $sqlcredential -Latest
        [DateTime]$SupportedUntil = Get-Date $results.SupportedUntil -Format O
        $Build = $results.build
        #If $BuildWarning, check for support date within the warning window
        if ($BuildWarning) {
            [DateTime]$expected = Get-Date ($Date).AddMonths($BuildWarning) -Format O
            $SupportedUntil | Should -BeGreaterThan $expected -Because "this build $Build will be unsupported by Microsoft on $(Get-Date $SupportedUntil -Format O) which is less than $BuildWarning months away"
        }
        #If neither, check for Microsoft support date
        else {
            $SupportedUntil | Should -BeGreaterThan $Date -Because "this build $Build is now unsupported by Microsoft"
        }
    }
}

function Assert-TwoDigitYearCutoff {
    Param(
        [string]$Instance,
        [int]$TwoDigitYearCutoff
    )
    (Get-DbaSpConfigure -SqlInstance $Instance -ConfigName 'TwoDigitYearCutoff').ConfiguredValue | Should -Be $TwoDigitYearCutoff -Because 'This is the value that you have chosen for Two Digit Year Cutoff configuration'
}

function Assert-TraceFlag {
    Param(
        [string]$SQLInstance,
        [int[]]$ExpectedTraceFlag
    )
    if ($null -eq $ExpectedTraceFlag) {
        (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $SQLInstance"
    }
    else {
        @($ExpectedTraceFlag).ForEach{
            (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag | Should -Contain $PSItem -Because "We expect that Trace Flag $PsItem will be set on $SQLInstance"
        }
    }
}
function Assert-NotTraceFlag {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'ExpectedTraceFlag')]
    Param(
        [string]$SQLInstance,
        [int[]]$NotExpectedTraceFlag,
        [int[]]$ExpectedTraceFlag
    )

    if ($null -eq $NotExpectedTraceFlag) {
        (@(Get-DbaTraceFlag -SqlInstance $SQLInstance).Where{ $_.TraceFlag -notin $ExpectedTraceFlag} | Select-Object).TraceFlag | Should -BeNullOrEmpty -Because "We expect that there will be no Trace Flags set on $SQLInstance"
    }
    else {
        @($NotExpectedTraceFlag).ForEach{
            (Get-DbaTraceFlag -SqlInstance $SQLInstance).TraceFlag | Should -Not -Contain $PSItem -Because "We expect that Trace Flag $PsItem will not be set on $SQLInstance"
        }
    }
}

function Assert-CLREnabled {
    param (
        $SQLInstance,
        $CLREnabled
    )

    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name IsSqlClrEnabled).ConfiguredValue -eq 1 | Should -Be $CLREnabled -Because 'The CLR Enabled should be set correctly'
}

function Assert-CrossDBOwnershipChaining {
    Param($AllInstanceInfo)
    $AllInstanceInfo.CrossDBOwnershipChaining.ConfiguredValue | Should -Be 0 -Because "We expected the Cross DB Ownership Chaining to be disabled"
}

function Assert-AdHocDistributedQueriesEnabled {
    param (
        $SQLInstance,
        $AdHocDistributedQueriesEnabled
    )
    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name AdHocDistributedQueriesEnabled).ConfiguredValue -eq 1 | Should -Be $AdHocDistributedQueriesEnabled -Because 'The AdHoc Distributed Queries Enabled setting should be set correctly'
}
function Assert-XpCmdShellDisabled {
    param (
        $SQLInstance,
        $XpCmdShellDisabled
    )
    (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name XPCmdShellEnabled).ConfiguredValue -eq 0 | Should -Be $XpCmdShellDisabled -Because 'The XP CmdShell setting should be set correctly'
}
function Assert-ErrorLogCount {
    param (
        $SQLInstance,
        $errorLogCount
    )
    (Get-DbaErrorLogConfig -SqlInstance $SQLInstance).LogCount | Should -BeGreaterOrEqual $errorLogCount -Because "We expect to have at least $errorLogCount number of error log files"
}

function Assert-ErrorLogEntry {
    Param($AllInstanceInfo)
    $AllInstanceInfo.ErrorLog | Should -BeNullOrEmpty -Because "these severities indicate serious problems"
}

function Assert-LatestBuild {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LatestBuild.Compliant | Should -Be $true -Because "We expected the SQL Server to be on the newest SQL Server Packs/CUs"
}

function Assert-SaDisabled {
    Param($AllInstanceInfo)
    $AllInstanceInfo.SaDisabled.Disabled | Should -Be $true -Because "We expected the original sa login to be disabled"
}

function Assert-SaExist {
    Param($AllInstanceInfo)
    $AllInstanceInfo.SaExist.Exist | Should -Be 0 -Because "We expected no login to exist with the name sa"
}

function Assert-SqlAgentProxiesNoPublicRole {
    Param($AllInstanceInfo)
    $AllInstanceInfo.SqlAgentProxiesWithPublicRole | Should -BeNull -Because "We expected the public role to not have access to any SQL Agent proxies"
}
function Assert-HideInstance {
    Param($AllInstanceInfo)
    $AllInstanceInfo.HideInstance.HideInstance | Should -Be $true -Because "We expected the hide instance property to be set to $true"
}

function Assert-LocalWindowsGroup {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LocalWindowsGroup.Exist | Should -Be $false -Because "We expected to have no local Windows groups as SQL logins"
}
function Assert-PublicRolePermission {
    Param($AllInstanceInfo)
    $AllInstanceInfo.PublicRolePermission.Count | Should -Be 0 -Because "We expected the public server role to have been granted no permissions"
}
function Assert-BuiltInAdmin {
    Param($AllInstanceInfo)
    $AllInstanceInfo.BuiltInAdmin.Exist | Should -Be 0 -Because "We expected no login to exist with the name BUILTIN\Administrators"
}

function Assert-LoginAuditSuccessful {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LoginAuditSuccessful.AuditLevel | Should -Be "All" -Because "We expected the audit level to be set to capture all logins (successful and failed)"
}

function Assert-LoginAuditFailed {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LoginAuditFailed.AuditLevel | Should -BeIn  @("Failure", "All") -Because "We expected the audit level to be set to capture failed logins"
}


function Assert-AgentServiceAdmin {
    Param($AllInstanceInfo)
    $AllInstanceInfo.AgentServiceAdmin.Exist | Should -Be $false -Because "We expected the service account for the SQL Agent to not be a local administrator"
}

function Assert-EngineServiceAdmin {
    Param($AllInstanceInfo)
    $AllInstanceInfo.EngineServiceAdmin.Exist | Should -Be $false -Because "We expected the service account for the SQL Engine to not be a local administrator"
}

function Assert-FullTextServiceAdmin {
    Param($AllInstanceInfo)
    $AllInstanceInfo.FullTextServiceAdmin.Exist | Should -Be $false -Because "We expected the service account for the SQL Full Text to not be a local administrator"
}
function Assert-LoginCheckPolicy {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LoginCheckPolicy.Count | Should -Be 0 -Because "We expected the CHECK_POLICY for the all logins to be enabled"
}

function Assert-LoginPasswordExpiration {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LoginPasswordExpiration.Count | Should -Be 0 -Because "We expected the password expiration policy to set on all sql logins in the sysadmin role"
}

function Assert-LoginMustChange {
    Param($AllInstanceInfo)
    $AllInstanceInfo.LoginMustChange.Count | Should -Be 0 -Because "We expected the all the new sql logins to have change the password on first login"
}

function Assert-SQLMailXPsDisabled {
    param ($AllInstanceInfo)
    $AllInstanceInfo.SQLMailXPsDisabled.ConfiguredValue | Should -Be 0 -Because "We expected Sql Mail XPs to be disabled"
}

function Assert-PublicPermission {
    Param($AllInstanceInfo)
    $AllInstanceInfo.PublicPermission.Count | Should -Be 0 -Because "We expected the public role to have no permissions for CIS compliance."
}


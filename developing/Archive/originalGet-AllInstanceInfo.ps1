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
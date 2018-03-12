function Get-Database {
    <#
        .SYNOPSIS
            Gets SQL Database information for each database that is present on the target instance(s) of SQL Server.

        .DESCRIPTION
            The Get-DbaDatabase command gets SQL database information for each database that is present on the target instance(s) of
            SQL Server. If the name of the database is provided, the command will return only the specific database information.

         .PARAMETER SqlInstance
            The SQL Server instance to connect to.

        .PARAMETER SqlCredential
            Allows you to login to servers using SQL Logins instead of Windows Authentication (AKA Integrated or Trusted). To use:

            $scred = Get-Credential, then pass $scred object to the -SqlCredential parameter.

            Windows Authentication will be used if SqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials.

            To connect as a different Windows user, run PowerShell as that user.

        .PARAMETER Database
            Specifies one or more database(s) to process. If unspecified, all databases will be processed.

        .PARAMETER ExcludeDatabase
            Specifies one or more database(s) to exclude from processing.

        .PARAMETER ExcludeAllUserDb
            If this switch is enabled, only databases which are not User databases will be processed.

            This parameter cannot be used with -ExcludeAllSystemDb.

        .PARAMETER ExcludeAllSystemDb
            If this switch is enabled, only databases which are not System databases will be processed.

            This parameter cannot be used with -ExcludeAllUserDb.

        .PARAMETER Status
            Specifies one or more database statuses to filter on. Only databases in the status(es) listed will be returned. Valid options for this parameter are 'Emergency', 'Normal', 'Offline', 'Recovering', 'Restoring', 'Standby', and 'Suspect'.

        .PARAMETER Access
            Filters databases returned by their access type. Valid options for this parameter are 'ReadOnly' and 'ReadWrite'. If omitted, no filtering is performed.

        .PARAMETER Owner
            Specifies one or more database owners. Only databases owned by the listed owner(s) will be returned.

        .PARAMETER Encrypted
            If this switch is enabled, only databases which have Transparent Data Encryption (TDE) enabled will be returned.

        .PARAMETER RecoveryModel
            Filters databases returned by their recovery model. Valid options for this parameter are 'Full', 'Simple', and 'BulkLogged'.

        .PARAMETER NoFullBackup
            If this switch is enabled, only databases without a full backup recorded by SQL Server will be returned. This will also indicate which of these databases only have CopyOnly full backups.

        .PARAMETER NoFullBackupSince
            Only databases which haven't had a full backup since the specified DateTime will be returned.

        .PARAMETER NoLogBackup
            If this switch is enabled, only databases without a log backup recorded by SQL Server will be returned. This will also indicate which of these databases only have CopyOnly log backups.

        .PARAMETER NoLogBackupSince
            Only databases which haven't had a log backup since the specified DateTime will be returned.

        .PARAMETER IncludeLastUsed
            If this switch is enabled, the last used read & write times for each database will be returned. This data is retrieved from sys.dm_db_index_usage_stats which is reset when SQL Server is restarted.

        .PARAMETER OnlyAccessible
           If this switch is enabled, only accessible databases are returned (huge speedup in SMO enumeration)

        .PARAMETER WhatIf
            If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

        .PARAMETER Confirm
            If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .NOTES
            Tags: Database
            Author: Garry Bargsley (@gbargsley | http://blog.garrybargsley.com)
            Author: Klaas Vandenberghe ( @PowerDbaKlaas )
            Author: Simone Bizzotto ( @niphlod )

            Website: https://dbatools.io
            Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
            License: MIT https://opensource.org/licenses/MIT

        .LINK
            https://dbatools.io/Get-DbaDatabase

        .EXAMPLE
            Get-DbaDatabase -SqlInstance localhost

            Returns all databases on the local default SQL Server instance.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance localhost -ExcludeAllUserDb

            Returns only the system databases on the local default SQL Server instance.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance localhost -ExcludeAllSystemDb

            Returns only the user databases on the local default SQL Server instance.

        .EXAMPLE
            'localhost','sql2016' | Get-DbaDatabase

            Returns databases on multiple instances piped into the function.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL1\SQLExpress -RecoveryModel full,Simple

            Returns only the user databases in Full or Simple recovery model from SQL Server instance SQL1\SQLExpress.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL1\SQLExpress -Status Normal

            Returns only the user databases with status 'normal' from SQL Server instance SQL1\SQLExpress.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL1\SQLExpress -IncludeLastUsed

            Returns the databases from SQL Server instance SQL1\SQLExpress and includes the last used information
            from the sys.dm_db_index_usage_stats DMV.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL1\SQLExpress,SQL2 -ExcludeDatabase model,master

            Returns all databases except master and model from SQL Server instances SQL1\SQLExpress and SQL2.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL1\SQLExpress,SQL2 -Encrypted

            Returns only databases using TDE from SQL Server instances SQL1\SQLExpress and SQL2.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL1\SQLExpress,SQL2 -Access ReadOnly

            Returns only read only databases from SQL Server instances SQL1\SQLExpress and SQL2.

        .EXAMPLE
            Get-DbaDatabase -SqlInstance SQL2,SQL3 -Database OneDB,OtherDB

            Returns databases 'OneDb' and 'OtherDB' from SQL Server instances SQL2 and SQL3 if databases by those names exist on those instances.
    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param (
        [parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $True)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [Alias("Databases")]
        [object[]]$Database,
        [object[]]$ExcludeDatabase,
        [Alias("SystemDbOnly", "NoUserDb")]
        [switch]$ExcludeAllUserDb,
        [Alias("UserDbOnly", "NoSystemDb")]
        [switch]$ExcludeAllSystemDb,
        [string[]]$Owner,
        [switch]$Encrypted,
        [ValidateSet('EmergencyMode', 'Normal', 'Offline', 'Recovering', 'Restoring', 'Standby', 'Suspect')]
        [string[]]$Status = @('EmergencyMode', 'Normal', 'Offline', 'Recovering', 'Restoring', 'Standby', 'Suspect'),
        [ValidateSet('ReadOnly', 'ReadWrite')]
        [string]$Access,
        [ValidateSet('Full', 'Simple', 'BulkLogged')]
        [string[]]$RecoveryModel = @('Full', 'Simple', 'BulkLogged'),
        [switch]$NoFullBackup,
        [datetime]$NoFullBackupSince,
        [switch]$NoLogBackup,
        [datetime]$NoLogBackupSince,
        [switch][Alias('Silent')]
        $EnableException,
        [switch]$IncludeLastUsed,
        [switch]$OnlyAccessible
    )
    process {        
        foreach ($instance in $SqlInstance) {
            try {
                Write-PSFMessage -Level Verbose -Message "Connecting to $instance."
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $sqlcredential
            }
            catch {
                Stop-PSFFunction -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }
            
            try {
                $dbs = $server.Databases
                if ($database) {
                    $dbs | Where-Object Name -in $database
                }
                elseif ($excludeDatabase) {
                    $dbs | Where-Object Name -notin $excludeDatabase
                }
                else {
                    $dbs
                }
            }
            catch {
                Stop-PSFFunction -ErrorRecord $_ -Target $instance -Message "Failure. Collection may have been modified. If so, please use parens (Get-DbaDatabase ....) | when working with commands that modify the collection such as Remove-DbaDatabase." -Continue
            }
        }
    }
}
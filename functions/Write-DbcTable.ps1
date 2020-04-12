<#
.SYNOPSIS
Writes the result of Invoke-DbcCheck (with -PassThru) after Convert-DbcResult to a database table

.DESCRIPTION
After running Invoke-DbcCheck (With PassThru) and converting it to a datatable with Convert-DbcResult, this command
will write the results to a database table and will also write the current Checks to another table called dbachecksChecks

.PARAMETER SqlInstance
The Instance for the results

.PARAMETER SqlCredential
The SQL Credential for the instance if required

.PARAMETER Database
The database to write the results

.PARAMETER InputObject
The datatable from Convert-DbcResult

.PARAMETER Table
The name of the table for the results - will be created if it doesnt exist

.PARAMETER Schema
the schema for the table - defaults to dbo

.PARAMETER Truncate
Will truncate the existing table (if results go to a staging table for example)


.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Write-DbcTable -SqlInstance sql2017n5 -Database tempdb -Table newdbachecks

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and writes it to a table newdbachecks in tempdb on SQL2017N5 (NB Don't use tempdb!!)

.NOTES
Initial - RMS 28/12/2019
#>
function Write-DbcTable {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [string]$SqlInstance,
        [ValidateNotNull()]
        [PSCredential]$SqlCredential,
        [object]$Database,
        [Parameter(Mandatory, ValueFromPipeline)]
        # The pester results object
        [ValidateNotNull()]
        [object]$InputObject,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Table,
        [ValidateNotNullOrEmpty()]
        [string]$Schema = 'dbo',
        [switch]$Truncate

    )
    Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
    if(-not $InputObject){
        Write-PSFMessage "Uh-Oh - I'm really sorry - We don't have a Test Results Object" -Level Significant
        Write-PSFMessage "Did You forget the -PassThru parameter on Invoke-DbcCheck?" -Level Warning
        Return ''
    }

    $SqlInstanceSmo = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential

    if ($PSCmdlet.ShouldProcess("$schema.$database" , "On $SqlInstance - Add or update the Configs tables in ")) {
       Get-DbcCheck | Write-DbaDataTable -SqlInstance $SqlInstanceSmo -Database $Database -Table dbachecksChecks -Schema $Schema -AutoCreateTable -Truncate
    }
    if ($PSCmdlet.ShouldProcess("$Schema.$database" , "On $SqlInstance - Add dbachecks results to $Table in")) {
       $InputObject | Write-DbaDataTable -SqlInstance $SqlInstanceSmo  -Database $Database -Table $Table -Schema $Schema -AutoCreateTable -Truncate:$Truncate
    }
}
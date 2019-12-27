function Write-DbcTable{
    [CmdletBinding(SupportsShouldProcess)]
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
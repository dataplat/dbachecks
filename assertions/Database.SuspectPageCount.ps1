. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Assert-SuspectPageCount {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [string]$Because
    )
    process {
        $TestObject.SuspectPages | Should -Be 0 -Because $Because
    }
}

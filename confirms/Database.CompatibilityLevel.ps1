. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Confirm-CompatibilityLevel {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [string]$Because
    )
    process {
        $TestObject.CompatibilityLevel | Should -Be $TestObject.InstanceCompatibilityLevel -Because $Because
    }
}

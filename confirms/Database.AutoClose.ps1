. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForAutoCloseCheck {
    return @{
        AutoClose = (Get-DbcConfigValue policy.database.autoclose | Convert-ConfigValueToBoolean)
    }
} 

function Confirm-AutoClose {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.AutoClose | Should -Be $config.AutoClose -Because $Because
    }
}

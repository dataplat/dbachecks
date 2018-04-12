. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForAutoShrinkCheck {
    return @{
        AutoShrink = (Get-DbcConfigValue policy.database.autoshrink | Convert-ConfigValueToBoolean)
    }
} 

function Confirm-AutoShrink {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.AutoShrink | Should -Be $config.AutoShrink -Because $Because
    }
}

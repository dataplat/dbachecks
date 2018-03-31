. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForAutoShrinkCheck {
    return @{
        AutoShrink = (Get-DbcConfigValue policy.database.autoshrink | Convert-ConfigValueToBoolean)
    }
} 

function Assert-AutoShrink {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        $TestObject.AutoShrink | Should -Be $TestSettings.AutoShrink -Because $Because
    }
}

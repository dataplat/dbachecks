. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForAutoCloseCheck {
    return @{
        AutoClose = (Get-DbcConfigValue policy.database.autoclose | Convert-ConfigValueToBoolean)
    }
} 

function Assert-AutoClose {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        $TestObject.AutoClose | Should -Be $TestSettings.AutoClose -Because $Because
    }
}

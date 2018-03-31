. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForAutoCreateStatisticsCheck {
    return @{
        AutoCreateStatistics = (Get-DbcConfigValue policy.database.autocreatestatistics | Convert-ConfigValueToBoolean)
    }
} 

function Assert-AutoCreateStatistics {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        $TestObject.AutoCreateStatistics | Should -Be $TestSettings.AutoCreateStatistics -Because $Because
    }
}

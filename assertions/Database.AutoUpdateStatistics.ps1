. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForAutoUpdateStatisticsCheck {
    return @{
        AutoUpdateStatistics = (Get-DbcConfigValue policy.database.autoupdatestatistics | Convert-ConfigValueToBoolean)
    }
} 

function Assert-AutoUpdateStatistics {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        $TestObject.AutoUpdateStatistics | Should -Be $TestSettings.AutoUpdateStatistics -Because $Because
    }
}

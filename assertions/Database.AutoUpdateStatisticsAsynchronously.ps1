. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForAutoUpdateStatisticsAsynchronouslyCheck {
    return @{
        AutoUpdateStatisticsAsynchronously = (Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously | Convert-ConfigValueToBoolean)
    }
} 

function Assert-AutoUpdateStatisticsAsynchronously {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        $TestObject.AutoUpdateStatisticsAsynchronously | Should -Be $TestSettings.AutoUpdateStatisticsAsynchronously -Because $Because
    }
}

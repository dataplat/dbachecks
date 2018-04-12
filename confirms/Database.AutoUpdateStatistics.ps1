. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForAutoUpdateStatisticsCheck {
    return @{
        AutoUpdateStatistics = (Get-DbcConfigValue policy.database.autoupdatestatistics | Convert-ConfigValueToBoolean)
    }
} 

function Confirm-AutoUpdateStatistics {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.AutoUpdateStatistics | Should -Be $config.AutoUpdateStatistics -Because $Because
    }
}

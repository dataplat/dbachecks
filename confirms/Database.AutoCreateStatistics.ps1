. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForAutoCreateStatisticsCheck {
    return @{
        AutoCreateStatistics = (Get-DbcConfigValue policy.database.autocreatestatistics | Convert-ConfigValueToBoolean)
    }
} 

function Confirm-AutoCreateStatistics {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.AutoCreateStatistics | Should -Be $config.AutoCreateStatistics -Because $Because
    }
}

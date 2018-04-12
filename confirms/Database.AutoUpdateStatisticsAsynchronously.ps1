. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForAutoUpdateStatisticsAsynchronouslyCheck {
    return @{
        AutoUpdateStatisticsAsynchronously = (Get-DbcConfigValue policy.database.autoupdatestatisticsasynchronously | Convert-ConfigValueToBoolean)
    }
} 

function Confirm-AutoUpdateStatisticsAsynchronously {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.AutoUpdateStatisticsAsynchronously | Should -Be $config.AutoUpdateStatisticsAsynchronously -Because $Because
    }
}

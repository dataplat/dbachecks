function Get-SettingsForRecoveryModelCheck {
    $RecoveryModelValidValues = @("FULL", "SIMPLE")
    $RecoveryModel = Get-DbcConfigValue policy.recoverymodel.type
    if (!($RecoveryModel -in $RecoveryModelValidValues)) {
        throw "The policy.recoverymodel.type is set to $RecoveryModel. Valid values are ($($RecoveryModelValidValues.Join(", ")))"
    }
    return @{
        RecoveryModel = (Get-DbcConfigValue policy.recoverymodel.type)
        ExcludedDatabase = Get-DbcConfigValue policy.recoverymodel.excludedb
    }
}

function Assert-RecoveryModel {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $TestSettings.ExcludedDatabase)) {
            $TestObject.RecoveryModel | Should -Be $TestSettings.RecoveryModel -Because $Because
        }
    }
}

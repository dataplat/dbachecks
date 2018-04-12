function Get-ConfigForRecoveryModelCheck {
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

function Confirm-RecoveryModel {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $config.ExcludedDatabase)) {
            $TestObject.RecoveryModel | Should -Be $config.RecoveryModel -Because $Because
        }
    }
}

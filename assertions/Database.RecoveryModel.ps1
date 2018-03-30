. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Assert-RecoveryModel {
    param (
        [object]$TestObject,
        [string]$ExpectedRecoveryModel,
        [string]$Because
    )
    $TestObject.RecoveryModel | Should -Be $ExpectedRecoveryModel -Because $Because
}

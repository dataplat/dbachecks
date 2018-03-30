. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForDatabaseOwnerIsValidCheck {
    return @{
        ExpectedOwner = @(Get-DbcConfigValue policy.validdbowner.name)
        ExcludedDatabase = @(Get-DbcConfigValue policy.validdbowner.excludedb)
    }
}

function Assert-DatabaseOwnerIsValid {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $TestSettings.ExcludedDatabase)) {
            $TestObject.Owner | Should -BeIn $TestSettings.ExpectedOwner -Because $Because
        }
    }
}

function Get-SettingsForDatabaseOwnerIsNotInvalidCheck {
    return @{
        InvalidOwner = @(Get-DbcConfigValue policy.invaliddbowner.name)
        ExcludedDatabase = @(Get-DbcConfigValue policy.invaliddbowner.excludedb)
    }
}

function Assert-DatabaseOwnerIsNotInvalid {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $TestSettings.ExcludedDatabase)) {
            $TestObject.Owner | Should -Not -BeIn $TestSettings.InvalidOwner -Because $Because
        }
    }
}

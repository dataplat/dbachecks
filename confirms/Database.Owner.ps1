. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForDatabaseOwnerIsValidCheck {
    return @{
        ExpectedOwner = @(Get-DbcConfigValue policy.validdbowner.name)
        ExcludedDatabase = @(Get-DbcConfigValue policy.validdbowner.excludedb)
    }
}

function Confirm-DatabaseOwnerIsValid {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $config.ExcludedDatabase)) {
            $TestObject.Owner | Should -BeIn $config.ExpectedOwner -Because $Because
        }
    }
}

function Get-ConfigForDatabaseOwnerIsNotInvalidCheck {
    return @{
        InvalidOwner = @(Get-DbcConfigValue policy.invaliddbowner.name)
        ExcludedDatabase = @(Get-DbcConfigValue policy.invaliddbowner.excludedb)
    }
}

function Confirm-DatabaseOwnerIsNotInvalid {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        if (!($TestObject.Database -in $config.ExcludedDatabase)) {
            $TestObject.Owner | Should -Not -BeIn $config.InvalidOwner -Because $Because
        }
    }
}

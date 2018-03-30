. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForPageVerifyCheck {
    $pageverifyValidValues = @("NONE", "TORN_PAGE_DETECTION", "CHECKSUM")
    $pageverify = Get-DbcConfigValue policy.pageverify
    if (!($pageverify -in $pageverifyValidValues)) {
        throw "The policy.pageverify is set to $pageverify. Valid values are ($($pageverifyValidValues.Join(", ")))"
    }
    return @{
        PageVerify = (Get-DbcConfigValue policy.pageverify)
    }
}

function Assert-PageVerify {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        $TestObject.PageVerify | Should -Be $TestSettings.PageVerify -Because $Because
    }
}

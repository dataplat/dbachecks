. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-ConfigForPageVerifyCheck {
    $pageverifyValidValues = @("NONE", "TORN_PAGE_DETECTION", "CHECKSUM")
    $pageverify = Get-DbcConfigValue policy.pageverify
    if (!($pageverify -in $pageverifyValidValues)) {
        throw "The policy.pageverify is set to $pageverify. Valid values are ($($pageverifyValidValues.Join(", ")))"
    }
    return @{
        PageVerify = (Get-DbcConfigValue policy.pageverify)
    }
}

function Confirm-PageVerify {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject, 
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.PageVerify | Should -Be $config.PageVerify -Because $Because
    }
}

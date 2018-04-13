function Confirm-Trustworthy {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [string]$Because
    )
    process {
        $TestObject.Trustworthy | Should -BeFalse -Because $Because
    }
}

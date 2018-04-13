function Confirm-PseudoSimpleRecovery {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [string]$Because
    )
    process {
        if (!($TestObject.RecoveryModel -eq "SIMPLE")) {
            $TestObject.DataFilesWithoutBackup | Should -Be 0 -Because $Because
        } 
    }
}

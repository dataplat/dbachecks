. "$PSScriptRoot/../../confirms/Database.PseudoSimpleRecovery.ps1"

Describe "Testing Pseudo Simple Recovery Confirms" -Tags PseudoSimpleRecovery {
    It "The test should pass when database is in simple recovery model" {
        @{
            RecoveryModel = "SIMPLE"
            DataFilesWithoutBackup = 3
        } |
        Confirm-PseudoSimpleRecovery
    }

    It "The test should pass when database is in full recovery model and full backup exists" {
        @{
            RecoveryModel = "FULL"
            DataFilesWithoutBackup = 0
        } |
        Confirm-PseudoSimpleRecovery
    }
    
    It "The test should fail when recovery model is not simple and there is no full backup" {
        {
            @{
                RecoveryModel = "FULL"
                DataFilesWithoutBackup = 2
            } | 
            Confirm-SuspectPageCount 
        } | Should -Throw
    }
}

. "$PSScriptRoot/../../confirms/Database.SuspectPageCount.ps1"

Describe "Testing Suspect Page Count Confirms" -Tags SuspectPage {
    Context "Validate the suspect pages check" {
        It "The test should pass when there are no suspect pages" {
            @{
                SuspectPages = 0
            } |
            Confirm-SuspectPageCount  
        }
        
        It "The test should fail when there is even one suspect page" {
            {
                @{
                    SuspectPages = 1
                } | 
                Confirm-SuspectPageCount 
            } | Should -Throw
        }

        It "The test should fail when there are many suspect pages" {
            {
                @{
                    SuspectPages = 10
                } | 
                Confirm-SuspectPageCount 
            } | Should -Throw
        }
    }
}

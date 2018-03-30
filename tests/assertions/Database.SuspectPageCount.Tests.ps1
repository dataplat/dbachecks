. "$PSScriptRoot/../../assertions/Database.SuspectPageCount.ps1"

Describe "Testing Suspect Page Count Assertions" -Tags SuspectPage {
    Context "Validate the suspect pages check" {
        It "The test should pass when there are no suspect pages" {
            @{
                SuspectPages = 0
            } |
            Assert-SuspectPageCount  
        }
        
        It "The test should fail when there is even one suspect page" {
            {
                @{
                    SuspectPages = 1
                } | 
                Assert-SuspectPageCount 
            } | Should -Throw
        }

        It "The test should fail when there are many suspect pages" {
            {
                @{
                    SuspectPages = 10
                } | 
                Assert-SuspectPageCount 
            } | Should -Throw
        }
    }
}

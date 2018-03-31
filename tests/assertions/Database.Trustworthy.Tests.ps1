. "$PSScriptRoot/../../assertions/Database.Trustworthy.ps1"
Describe "Testing Trustworthy Assertion" -Tags Trustworthy {
    It "The test should pass when Trustworthy is set to false" {
        @{ Trustworthy = $false } |
        Assert-Trustworthy
    }

    It "The test should fail when Trustworthy is set to true" {
        { 
            @{ Trustworthy = $true } |
            Assert-Trustworthy
        } | Should -Throw
    }
}
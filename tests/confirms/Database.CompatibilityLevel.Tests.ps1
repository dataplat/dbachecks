. "$PSScriptRoot/../../confirms/Database.CompatibilityLevel.ps1"

Describe "Testing Compatibility Level Assertion" -Tags CompatibilityLevel {
    Context "Validate compatibility level checks" {
        It "The test should pass when the compatibility level match" {
            @{
                CompatibilityLevel = "100"
                InstanceCompatibilityLevel = "100"
            } |
            Confirm-CompatibilityLevel
        }

        It "The test should fail when the current recovery model is not what is expected" {
            {
                @{
                    CompatibilityLevel = "100"
                    InstanceCompatibilityLevel = "110"
                } |
                Confirm-CompatibilityLevel
            } | Should -Throw 
        }
    }
}

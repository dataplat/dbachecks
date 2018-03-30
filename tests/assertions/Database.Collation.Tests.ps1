. "$PSScriptRoot/../../assertions/Database.Collation.ps1"

Describe "Testing Collaction Assertion" -Tags DatabaseCollation {
    Context "Validate the database collation check" {
        Mock Get-DbcConfigValue { return "mySpecialDbWithUniqueCollation" } -ParameterFilter { $Name -like "policy.database.wrongcollation" }
        
        $testSettings = Get-SettingsForDatabaseCollactionCheck

        It "The test should pass when the database is not on the exclusion list and the collations match" {
            @{
                Database = "db1"
                ServerCollation = "collation1"
                DatabaseCollation = "collation1"
            } |
            Assert-DatabaseCollation -With $testSettings
        }

        It "The test should pass when the database is on the exclusion list and the collations do not match" {
            @{
                Database = "mySpecialDbWithUniqueCollation"
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            } |
            Assert-DatabaseCollation -With $testSettings
        }

        It "The test should pass when the database is ReportingServer and the collations do not match" {
            @{
                Database = "mySpecialDbWithUniqueCollation"
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            } |
            Assert-DatabaseCollation -With $testSettings
        }

        It "The test should fail when the database is not on the exclusion list and the collations do not match" {
            {
                @{
                    Database = "db1"
                    ServerCollation = "collation1"
                    DatabaseCollation = "collation2"
                } |
                Assert-DatabaseCollation -With $testSettings
            } | Should -Throw
        }

        It "The test should pass when excluded datbase collation does not matche the instance collation" {
            @{
                Database = "mySpecialDbWithUniqueCollation"
                ServerCollation = "collation1"
                DatabaseCollation = "collation2"
            } |
            Assert-DatabaseCollation -With $testSettings
        }
    }
}

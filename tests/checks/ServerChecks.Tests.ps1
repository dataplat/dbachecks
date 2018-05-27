# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking ServerChecks.Tests" {
    Context "Testing Assert-CPUPrioritisation" {
        #Mock for passing
        function Get-RemoteRegistryValue {}
        Mock Get-RemoteRegistryValue {
            24
        }
        It "Should Pass When value set correctly" {
            Assert-CPUPrioritisation
        }
        #Mock for failing
        function Get-RemoteRegistryValue {}
        Mock Get-RemoteRegistryValue {
            2
        }
        It "Should fail When value set incorrectly" {
            {Assert-CPUPrioritisation} | Should -Throw -ExpectedMessage "Expected exactly 24, because a server should prioritise CPU to it's Services, not to the user experience when someone logs on, but got 2."
        }
    }
    Context "Testing Assert-DiskAllocationUnit" {
        Mock Test-DbaDiskAllocation {# passing test
            @(
                [PSCustomObject]@{
                    Server         = "SQL0"
                    Name           = "C:\"
                    Label          = ""
                    BlockSize      = "4096"
                    IsSqlDisk      = $true
                    IsBestPractice = $true
                },
                [PSCustomObject]@{
                    Server         = "SQL0"
                    Name           = "D:\"
                    Label          = ""
                    BlockSize      = "4096"
                    IsSqlDisk      = $true
                    IsBestPractice = $true
                },
                [PSCustomObject]@{
                    Server         = "SQL0"
                    Name           = "E:\"
                    Label          = ""
                    BlockSize      = "4096"
                    IsSqlDisk      = $true
                    IsBestPractice = $true
                }
            )
        }
        it "Should pass when all SQLDisks are formatted with the 65536b (64kb) block allocation unit size" {
            Assert-DiskAllocationUnit
        }
        Mock Test-DbaDiskAllocation { # failing test
            @(
                [PSCustomObject]@{
                    Server         = "SQL0"
                    Name           = "C:\"
                    Label          = ""
                    BlockSize      = "65536"
                    IsSqlDisk      = $true
                    IsBestPractice = $false
                },
                [PSCustomObject]@{
                    Server         = "SQL0"
                    Name           = "D:\"
                    Label          = ""
                    BlockSize      = "65536"
                    IsSqlDisk      = $true
                    IsBestPractice = $true
                },
                [PSCustomObject]@{
                    Server         = "SQL0"
                    Name           = "E:\"
                    Label          = ""
                    BlockSize      = "65536"
                    IsSqlDisk      = $true
                    IsBestPractice = $false
                }
            )
        }
        it "should fail when any SQLDisks is formatted with a block allocation unit size that isnt 65536b (64KB)" {
            {Assert-DiskAllocationUnit} | should -Throw -ExpectedMessage "Expected `$true, because SQL Server performance will be better when accessing data from a disk that is formatted with 64Kb block allocation unit, but got `$false."
        }
    }
}
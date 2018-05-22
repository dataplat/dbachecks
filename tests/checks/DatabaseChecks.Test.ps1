# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking Instance.Tests.ps1 checks" -Tag UnitTest {
    Context "Testing Database Max Dop" {
        ## Mock for Passing
        Mock Test-DbaMaxDop {
            @{Database = 'N/A'; DatabaseMaxDop = 'N/A'},
            @{Database = 'Dummy1'; DatabaseMaxDop = '1'}
        }
        @(Test-DbaMaxDop -SqlInstance Dummy).Where{$_.Database -ne 'N/A'}.ForEach{
            It "Passes the test successfully" {
                Assert-DatabaseMaxDop -MaxDop $PsItem -MaxDopValue 1
            }
        }
        ## Mock for Failing
        Mock Test-DbaMaxDop {
            @{Database = 'N/A'; DatabaseMaxDop = 'N/A'},
            @{Database = 'Dummy1'; DatabaseMaxDop = '5'}
        }
        @(Test-DbaMaxDop -SqlInstance Dummy).Where{$_.Database -ne 'N/A'}.ForEach{
            It "Fails the test successfully" {
                {Assert-DatabaseMaxDop -MaxDop $PsItem -MaxDopValue 4} | Should -Throw -ExpectedMessage "Expected 4, because We expect the Database MaxDop Value 5 to be the specified value 4, but got '5'."
            }
        }
    }
}

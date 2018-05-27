# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking ServerChecks.Tests" {
    Context "Testing Assert-CPUPrioritisation" {
        #Mock for passing
        function Get-RemoteRegistryValue{}
        Mock Get-RemoteRegistryValue {
            24
        }
        It "Should Pass When value set correctly" {
            Assert-CPUPrioritisation
        }
        #Mock for failing
        function Get-RemoteRegistryValue{}
        Mock Get-RemoteRegistryValue {
            2
        }
        It "Should fail When value set incorrectly" {
            {Assert-CPUPrioritisation} | Should -Throw -ExpectedMessage "Expected exactly 24, because a server should prioritise CPU to it's Services, not to the user experience when someone logs on, but got 2."
        }
    }
}
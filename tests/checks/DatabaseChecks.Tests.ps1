# load all of the assertion functions
. /../internal/assertions/Database.Assertions.ps1 

Describe "Checking Database.Assertions.ps1 assertions" -Tag UnitTest, Assertions {
    Context "Testing Assert-DatabaseMaxDop " {
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

        It "Calls the Mocks successfully" {
            $assertMockParams = @{
            'CommandName' = 'Test-DbaMaxDop'
            'Times'       = 2
            'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Testing Assert-DatabaseStatus " {
        #mock for passing
        Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Pass when all databases are ok" {
            Assert-DatabaseStatus Dummy
        }
        # Mock for readonly failing
        Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $True;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is readonly" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected 'True' to not be found in collection @(`$false, `$true), because We expect that there will be no Read-Only databases except for those specified, but it was found."
        }
        It "It Should Not Fail for a database that is readonly when it is excluded" {
            Assert-DatabaseStatus -Instance Dummy -ExcludeReadOnly 'Dummy2' 
        }
        # Mock for offline failing
        Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Offline, AutoClosed';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is offline" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Offline' to not match 'Offline, AutoClosed', because We expect that there will be no offline databases except for those specified, but it did match."
        }
        It "It Should Not Fail for a database that is offline when it is excluded" {
            Assert-DatabaseStatus Dummy -ExcludeOffline 'Dummy1'
       }
          # Mock for restoring failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Restoring';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is restoring" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Restoring' to not match 'Restoring', because We expect that there will be no databases in a restoring state except for those specified, but it did match."
        }
        It "It Should Not Fail for a database that is restoring when it is excluded" {
            Assert-DatabaseStatus Dummy -ExcludeRestoring 'Dummy1'
       }
          # Mock for recovery failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Recovering';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Recovering" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Recover' to not match 'Recovering', because We expect that there will be no databases going through the recovery process or in a recovery pending state, but it did match."
        }
          # Mock for recovery pending failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'RecoveryPending';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Recovery pending" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Recover' to not match 'RecoveryPending', because We expect that there will be no databases going through the recovery process or in a recovery pending state, but it did match."
        }
          # Mock for autoclosed failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'AutoClosed';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is AutoClosed" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'AutoClosed' to not match 'AutoClosed', because We expect that there will be no databases that have been auto closed, but it did match."
        }
        
          # Mock for EmergencyMode failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'EmergencyMode';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is EmergencyMode" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Emergency' to not match 'EmergencyMode', because We expect that there will be no databases in EmergencyMode, but it did match."
        }
        
          # Mock for Suspect failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Suspect';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Suspect" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Suspect' to not match 'Suspect', because We expect that there will be no databases in a Suspect state, but it did match."
        }
        
          # Mock for Standby failing
          Mock Connect-DbaInstance {
            @{
                Databases = @(
                    @{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Standby';
                    },
                    @{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Standby" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Standby' to not match 'Standby', because We expect that there will be no databases in Standby, but it did match."
        }
    
       It "Should Not Fail for databases that are excluded" {
        Assert-DatabaseStatus Dummy -Excludedbs 'Dummy1'
       }
    }

}

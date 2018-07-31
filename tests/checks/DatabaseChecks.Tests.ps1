# load all of the assertion functions
. /../internal/assertions/Database.Assertions.ps1 

Describe "Checking Database.Assertions.ps1 assertions" -Tag UnitTest, Assertions {
    Context "Testing Get-Database" {
        It "Should have a Instance parameter" {
            (Get-Command Get-Database).Parameters['Instance'] | Should -Not -BeNullOrEmpty -Because "We Need to pass the instance in"
        }
        It "Should have a ExcludedDbs parameter" {
            (Get-Command Get-Database).Parameters['ExcludedDbs'] | Should -Not -BeNullOrEmpty -Because "We need to pass in the Excluded Databases - Don't forget that the ExcludedDatabases parameter is set by default so dont use that"
        }
        It "Should have a Requiredinfo parameter" {
            (Get-Command Get-Database).Parameters['Requiredinfo'] | Should -Not -BeNullOrEmpty -Because "We want to be able to choose the infomration we return"
        }
        It "Should have a Exclusions parameter" {
            (Get-Command Get-Database).Parameters['Exclusions'] | Should -Not -BeNullOrEmpty -Because "We need to be able to excluded databases for various reasons like readonly etc"
        }
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name         = 'Dummy1';
                        ReadOnly     = $False;
                        Status       = 'Normal';
                        IsAccessible = $True;
                    },
                    [PSCustomObject]@{
                        Name         = 'Dummy2';
                        ReadOnly     = $False;
                        Status       = 'Normal';
                        IsAccessible = $false;
                    }
                );
            }
        }
        It "Should return the Database Names with the Requiredinfo switch parameter value Name" {
            Get-Database -Instance Dummy -Requiredinfo Name | Should -Be 'Dummy1', 'Dummy2'
        }
        It "Should Exclude Databases that are specified for the Name  Required Info" {
            Get-Database -Instance Dummy -Requiredinfo Name -ExcludedDbs Dummy1 | Should -Be 'Dummy2'
        }
        It "Should Exclude none accessible databases if the NotAccessible value for Exclusions parameter is used"{
            Get-Database -Instance Dummy -Requiredinfo Name -Exclusions NotAccessible | Should -Be 'Dummy1'

        }
        It "Should call the Mocks" {
            $assertMockParams = @{
                'CommandName' = 'Connect-DbaInstance'
                'Times'       = 3
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Offline, AutoClosed';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Restoring';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Recovering';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'RecoveryPending';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'AutoClosed';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'EmergencyMode';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Suspect';
                    },
                    [PSCustomObject]@{
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
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Standby';
                    },
                    [PSCustomObject]@{
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
        It "Should call the Mocks successfully" {
            $assertMockParams = @{
                'CommandName' = 'Connect-DbaInstance'
                'Times'       = 14
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Testing Assert-DatabaseDuplicateIndex" {
        #Mock for passing
        Mock Find-DbaDuplicateIndex {}
        It "Should pass when there are no Duplicate Indexes" {
            Assert-DatabaseDuplicateIndex -Instance Dummy -Database Dummy1
        }
        # Mock for failing for 1 index
        Mock Find-DbaDuplicateIndex {
            [PSCustomObject]@{
                DatabaseName           = "msdb"
                TableName              = "dbo.log_shipping_primary_databases"
                IndexName              = "UQ__log_ship__2A5EF6DCB9BFAE2F"
                KeyColumns             = "primary_database ASC"
                IncludedColumns        = ""
                IndexType              = "NONCLUSTERED"
                IndexSizeMB            = "0.000000"
                CompressionDescription = "NONE"
                RowCount               = "0"
                IsDisabled             = "False"
                IsFiltered             = "False"
            }
        }
        It "Should fail for one duplicate index" {
            {Assert-DatabaseDuplicateIndex -Instance Dummy -Database Dummy1 } | Should -Throw -ExpectedMessage 'Expected 0, because Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory, but got 1.'
        }
        #Mock for failing for 2 indexes
        Mock Find-DbaDuplicateIndex {
            @([PSCustomObject]@{
                    DatabaseName           = "msdb"
                    TableName              = "dbo.log_shipping_primary_databases"
                    IndexName              = "UQ__log_ship__2A5EF6DCB9BFAE2F"
                    KeyColumns             = "primary_database ASC"
                    IncludedColumns        = ""
                    IndexType              = "NONCLUSTERED"
                    IndexSizeMB            = "0.000000"
                    CompressionDescription = "NONE"
                    RowCount               = "0"
                    IsDisabled             = "False"
                    IsFiltered             = "False"
                },
                [PSCustomObject]@{
                    DatabaseName           = "msdb"
                    TableName              = "dbo.log_shipping_primary_databases"
                    IndexName              = "UQ__log_ship__2A5EF6DCB9BFAE2F"
                    KeyColumns             = "primary_database ASC"
                    IncludedColumns        = ""
                    IndexType              = "NONCLUSTERED"
                    IndexSizeMB            = "0.000000"
                    CompressionDescription = "NONE"
                    RowCount               = "0"
                    IsDisabled             = "False"
                    IsFiltered             = "False"
                }
            )
        }

        It "Should fail for more than one duplicate index"{
            {Assert-DatabaseDuplicateIndex -Instance Dummy -Database Dummy1 } | Should -Throw -ExpectedMessage 'Expected 0, because Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory, but got 2.'
        }
    }
    Context "Testing Assert-DatabaseExists" {
        It "Should have a Instance parameter" {
            (Get-Command Assert-DatabaseExists).Parameters['Instance'] | Should -Not -BeNullOrEmpty -Because "We Need to pass the instance in"
        }
        It "Should have a ExpectedDB parameter" {
            (Get-Command Assert-DatabaseExists).Parameters['ExpectedDB'] | Should -Not -BeNullOrEmpty -Because "We Need to pass the Expected DB in"
        }

        # Mock for Passing
        Mock Get-Database {
            @(
                [PSCustomObject]@{
                    Name = 'Expected1'
                },
                [PSCustomObject]@{
                    Name = 'Expected2'
                },
                [PSCustomObject]@{
                    Name = 'Expected3'
                },
                [PSCustomObject]@{
                    Name = 'Expected4'
                }
            )
        }
        @('Expected1', 'Expected2', 'Expected3', 'Expected4').ForEach{
            It "Should Pass when the database exists" {
                Assert-DatabaseExists -Instance Instance -ExpectedDb $psitem
            }
        }

        It "Should Fail when the database doesnot exist" {
            {Assert-DatabaseExists -Instance Instance -ExpectedDb NotThere} | Should -Throw -ExpectedMessage "We expect NotThere to be on Instance"
        }
    }
}

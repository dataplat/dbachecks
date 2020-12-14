# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{ . $Psitem.FullName }

Describe "Checking Instance.Tests.ps1 checks" -Tag UnitTest {
    Context "Checking Backup Compression" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance { @{Version = @{Major = 14 } } }
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig = 1; expected = $false; actual = $true }, @{spconfig = 0; expected = $true; actual = $false }
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            { Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected } | Should -Throw -ExpectedMessage "Expected `$$expected, because The default backup compression should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig = 0; expected = $false }, @{spconfig = 1; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaSpConfigure'
                'Times'       = 4
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        <#
				It "Should not run for SQL 2005 and below"{
					# Mock Get-Version
					function Get-Version {}
					Mock Get-Version {9}
				# Mock the version check for not running the tests
				Mock Get-DbaSpConfigure {@{"ConfiguredValue" = 1}}
				$Pester = Invoke-DbcCheck -SQLInstance Dummy -Check DefaultBackupCompression -PassThru -Show None
			   # $Pester.TotalCount | Should -Be 1
			   # $Pester.SkippedCount | Should -Be 1
				$assertMockParams = @{
					'CommandName' = 'Get-Version'
					'Times'		  = 1
					'Exactly'	  = $true
					}
					Assert-MockCalled @assertMockParams
			}
		#>

    }
    Context "Checking Instance MaxDop" {
        # if Userecommended it should pass if CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the RecommendedMaxDop property
        It "Passes Check Correctly with the use recommended parameter set to true" {
            # Mock to pass
            Mock Test-DbaMaxDop { @{"CurrentInstanceMaxDop" = 0; "RecommendedMaxDop" = 0 } }
            Assert-InstanceMaxDop  -Instance 'Dummy' -UseRecommended
        }
        # if Userecommended it should fail if CurrentInstanceMaxDop property returned from Test-DbaMaxDop does not match the RecommendedMaxDop property
        It "Fails Check Correctly with the use recommended parameter set to true" {
            # Mock to fail
            Mock Test-DbaMaxDop { @{"CurrentInstanceMaxDop" = 0; "RecommendedMaxDop" = 5 } }
            { Assert-InstanceMaxDop -Instance 'Dummy' -UseRecommended } | Should -Throw -ExpectedMessage "Expected 5, because We expect the MaxDop Setting to be the recommended value 5"
        }
        $TestCases = @{"MaxDopValue" = 5 }
        # if not UseRecommended - it should pass if the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
        It "Passes Check Correctly with a specified value <MaxDopValue>" -TestCases $TestCases {
            Param($MaxDopValue)
            # Mock to pass
            Mock Test-DbaMaxDop { @{"CurrentInstanceMaxDop" = 5; "RecommendedMaxDop" = $MaxDopValue } }
            Assert-InstanceMaxDop -Instance 'Dummy' -MaxDopValue $MaxDopValue
        }
        $TestCases = @{"MaxDopValue" = 5 }, @{"MaxDopValue" = 0 }
        # if not UseRecommended - it should fail if the CurrentInstanceMaxDop property returned from Test-DbaMaxDop does not match the MaxDopValue parameter
        It "Fails Check Correctly with with a specified value <MaxDopValue>" -TestCases $TestCases {
            Param($MaxDopValue)
            # Mock to fail
            Mock Test-DbaMaxDop { @{"CurrentInstanceMaxDop" = 4; "RecommendedMaxDop" = 73 } }
            { Assert-InstanceMaxDop -Instance 'Dummy' -MaxDopValue $MaxDopValue } | Should -Throw -ExpectedMessage "Expected $MaxDopValue, because We expect the MaxDop Setting to be $MaxDopValue"
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Test-DbaMaxDop'
                'Times'       = 5
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Checking tempdb size" {
        Mock Get-DbaDbFile { @(
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 8
                    }
                },
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 8
                    }
                },
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 8
                    }
                },
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 8
                    }
                }
            ) }

        It "Should pass the test when all tempdb files are the same size" {
            Assert-TempDBSize -Instance Dummy
        }

        Mock Get-DbaDbFile { @(
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 8
                    }
                },
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 6
                    }
                },
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 8
                    }
                },
                [PSCustomObject]@{
                    Type = 0
                    Size = [PSCustomObject]@{
                        Megabyte = 7
                    }
                }
            ) }

        It "Should fail when all of the tempdb files are not the same size" {
            { Assert-TempDBSize -Instance Dummy } | Should -Throw -ExpectedMessage "We want all the tempdb data files to be the same size - See https://blogs.sentryone.com/aaronbertrand/sql-server-2016-tempdb-fixes/ and https://www.brentozar.com/blitz/tempdb-data-files/ for more information"
        }
    }
    Context "Checking Supported Build" {
        [DateTime]$Date = Get-Date -Format O

        $TestCases = @{"Date" = $Date; "BuildBehind" = "1SP"; },
        @{"Date" = $Date; "BuildBehind" = "1CU"; }
        #if BuildBehind it should pass if build is >= SP/CU specified & Support Dates are valid
        It "Passed check correctly when the current build is not behind the BuildBehind value of <BuildBehind>" -TestCases $TestCases {
            Param($BuildBehind, $Date)
            #Mock to pass
            Mock Test-DbaBuild { @{"SPLevel" = "{SP4, LATEST}"; "CULevel" = "CU4"; "Compliant" = $true; "SupportedUntil" = $Date.AddMonths(1) } }
            Assert-InstanceSupportedBuild -Instance 'Dummy' -BuildBehind $BuildBehind -Date $Date
        }
        $TestCases = @{"Date" = $Date; "BuildBehind" = "1SP"; "BuildWarning" = 6; "expected" = $true; "actual" = $false },
        @{"Date" = $Date; "BuildBehind" = "1CU"; "BuildWarning" = 6; "expected" = $true; "actual" = $false }
        #if BuildBehind it should fail if build is <= SP/CU specified & Support dates are valid
        It "Failed check correctly when the current build is behind the BuildBehind value of <BuildBehind>" -TestCases $TestCases {
            Param($BuildBehind, $Date, $expected, $actual)
            #Mock to fail
            Mock Test-DbaBuild { @{"SPLevel" = "{SP2}"; "CULevel" = "CU2"; "SPTarget" = "SP4"; "CUTarget" = "CU4"; "Compliant" = $false; "SupportedUntil" = $Date.AddMonths(1); "Build" = 42 } }
            { Assert-InstanceSupportedBuild -Instance 'Dummy' -BuildBehind $BuildBehind -Date $Date } | Should -Throw -ExpectedMessage "Expected `$$expected, because this build 42 should not be behind the required build, but got `$$actual"
        }
        $TestCases = @{"Date" = $Date }
        #if neither BuildBehind nor BuildWarning it should pass if support dates are valid
        It "Passed check correctly with a SupportedUntil date > today" -TestCases $TestCases {
            Param($Date)
            #Mock to pass
            Mock Test-DbaBuild { @{"SupportedUntil" = $Date.AddMonths(1) } }
            Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date
        }
        $TestCases = @{"Date" = $Date }
        #if neither BuildBehind nor BuildWarning it should fail if support date is out of the support window
        It "Failed check correctly with a SupportedUntil date < today" -TestCases $TestCases {
            Param($Date)
            #Mock to fail
            Mock Test-DbaBuild { @{"SupportedUntil" = $Date.AddMonths(-1); "Build" = 42 } }
            $SupportedUntil = Get-Date $Date.AddMonths(-1) -Format O
            $Date = Get-Date $Date -Format O
            { Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than $Date, because this build 42 is now unsupported by Microsoft, but got $SupportedUntil"
        }
        $TestCases = @{"Date" = $Date; "BuildWarning" = 6 }
        #if BuildWarning it should fail if support date is in the warning window
        It "Passed check correctly with the BuildWarning window > today" -TestCases $TestCases {
            Param($Date, $BuildWarning)
            #Mock to pass
            Mock Test-DbaBuild { @{"SupportedUntil" = $Date.AddMonths(9); "Build" = 42 } }
            { Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date -BuildWarning $BuildWarning }
        }
        $TestCases = @{"Date" = $Date; "BuildWarning" = 6 }
        #if BuildWarning it should fail if support date is in the warning window
        It "Failed check correctly with the BuildWarning window < today" -TestCases $TestCases {
            Param($Date, $BuildWarning)
            #Mock to fail
            Mock Test-DbaBuild { @{"SupportedUntil" = $Date.AddMonths(3); "Build" = 42 } }
            $SupportedUntil = Get-Date $Date.AddMonths(3) -Format O
            $expected = Get-Date $Date.AddMonths($BuildWarning) -Format O
            { Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date -BuildWarning $BuildWarning } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than $expected, because this build 42 will be unsupported by Microsoft on $SupportedUntil which is less than $BuildWarning months away, but got $SupportedUntil"
        }

    }
    Context "Checking Trace Flags" {
        ## Mock for one trace flag
        Mock Get-DbaTraceFlag {

            [PSObject]@{
                'ComputerName' = 'ComputerName'
                'Global'       = 1
                'InstanceName' = 'MSSQLSERVER'
                'Session'      = 0
                'SqlInstance'  = 'SQLInstance'
                'Status'       = 1
                'TraceFlag'    = 118
            }
        }
        It "Should pass correctly when the trace flag exists and it is the only one" {
            Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 118
        }
        It "Should fail correctly when the trace flag does not exist but there is a different trace flag" {
            { Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 117 } | Should -Throw -ExpectedMessage  "Expected 117 to be found in collection 118, because We expect that Trace Flag 117 will be set on Dummy, but it was not found."
        }
        It "Should fail correctly when the trace flag does not exist and there is no trace flag" {
            Mock Get-DbaTraceFlag {

                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                }
            }
            { Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 117 } | Should -Throw -ExpectedMessage  "Expected 117 to be found in collection 118, because We expect that Trace Flag 117 will be set on Dummy, but it was not found."
        }
        It "Should Pass Correctly for more than one trace flag when they all exist" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 3604
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 3605
                }
            }
            Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 118, 117, 3604, 3605
        }
        It "Should Pass Correctly for more than one trace flag when they exist but there are extra trace flags" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 3604
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 3605
                }
            }
            Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 118, 117, 3604
        }
        It "Should Fail Correctly when checking more than one trace flag when 1 is missing" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 3604
                }
            }
            { Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 118, 117, 3604, 3605 } | Should -Throw -ExpectedMessage "Expected 3605 to be found in collection @(117, 118, 3604), because We expect that Trace Flag 3605 will be set on Dummy, but it was not found."
        }
        It "Should Fail Correctly when checking more than one trace flag when 2 are missing" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                }
            }
            { Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag 118, 117, 3604, 3605 } | Should -Throw -ExpectedMessage "Expected 3604 to be found in collection @(117, 118), because We expect that Trace Flag 3604 will be set on Dummy, but it was not found"
        }
        It "Should pass correctly when no trace flag exists and none expected" {
            Mock Get-DbaTraceFlag {
            }
            Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag $null
        }
        It "Should fail correctly when a trace flag exists and none expected" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                }
            }
            { Assert-TraceFlag -SQLInstance Dummy -ExpectedTraceFlag $null } | Should -Throw -ExpectedMessage "Expected `$null or empty, because We expect that there will be no Trace Flags set on Dummy, but got 117"
        }
    }
    Context "Checking Trace Flags Not Expected" {
        ## Mock for one trace flag
        Mock Get-DbaTraceFlag {
            [PSObject]@{
                'ComputerName' = 'ComputerName'
                'Global'       = 1
                'InstanceName' = 'MSSQLSERVER'
                'Session'      = 0
                'SqlInstance'  = 'SQLInstance'
                'Status'       = 1
                'TraceFlag'    = 118
            }
        }
        It "Should pass correctly when the trace flag exists and it is not the one expected to be running" {
            Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag 117
        }
        It "Should pass correctly when no trace flag is running" {
            Mock Get-DbaTraceFlag { }
            Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag 117
        }
        It "Should fail correctly when the trace flag is running and is the only one" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                }
            }
            { Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag 118 } | Should -Throw -ExpectedMessage "Expected 118 to not be found in collection 118, because We expect that Trace Flag 118 will not be set on Dummy, but it was found."
        }
        It "Should fail correctly for one trace flag when the trace flag is running but there is another one running as well" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                }
            }
            { Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag 117 } | Should -Throw -ExpectedMessage  "Expected 117 to not be found in collection @(117, 118), because We expect that Trace Flag 117 will not be set on Dummy, but it was found."
        }
        It "Should Pass Correctly for more than one trace flag when no trace flag is set" {
            Mock Get-DbaTraceFlag { }
            Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag 118, 117, 3604, 3605
        }
        It "Should Pass Correctly for more than one trace flag when a different one is running" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                }
            }
            Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag  3604, 3605
        }
        It "Should Fail Correctly for more than one trace flag when one is running" {
            Mock Get-DbaTraceFlag {
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 117
                },
                [PSObject]@{
                    'ComputerName' = 'ComputerName'
                    'Global'       = 1
                    'InstanceName' = 'MSSQLSERVER'
                    'Session'      = 0
                    'SqlInstance'  = 'SQLInstance'
                    'Status'       = 1
                    'TraceFlag'    = 118
                }
            }
            { Assert-NotTraceFlag -SQLInstance Dummy -NotExpectedTraceFlag  117, 3604, 3605 } | Should -Throw -ExpectedMessage  "Expected 117 to not be found in collection @(117, 118), because We expect that Trace Flag 117 will not be set on Dummy, but it was found."
        }
    }
    Context "Checking CLR Enabled" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance { }
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig = 1; expected = $false; actual = $true }, @{spconfig = 0; expected = $true; actual = $false }
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            { Assert-CLREnabled -SQLInstance 'Dummy' -CLREnabled $expected } | Should -Throw -ExpectedMessage "Expected `$$expected, because The CLR Enabled should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig = 0; expected = $false }, @{spconfig = 1; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            Assert-CLREnabled -SQLInstance 'Dummy' -CLREnabled $expected
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaSpConfigure'
                'Times'       = 4
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Checking AdHoc Distributed Queries Enabled" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance { }
        # Define test cases for the results to fail test and fill expected message
        # So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
        $TestCases = @{spconfig = 1; expected = $false; actual = $true }, @{spconfig = 0; expected = $true; actual = $false }
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            { Assert-AdHocDistributedQueriesEnabled -SQLInstance 'Dummy' -AdHocDistributedQueriesEnabled $expected } | Should -Throw -ExpectedMessage "Expected `$$expected, because The AdHoc Distributed Queries Enabled setting should be set correctly, but got `$$actual"
        }
        $TestCases = @{spconfig = 0; expected = $false }, @{spconfig = 1; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            Assert-AdHocDistributedQueriesEnabled -SQLInstance 'Dummy' -AdHocDistributedQueriesEnabled $expected
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaSpConfigure'
                'Times'       = 4
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Checking XPCmdShell is disabled" {
        # Mock the version check for running tests
        Mock Connect-DbaInstance { }
        # Define test cases for the results to fail test and fill expected message
        # This one is different from the others as we are checking for disabled !!
        # So the results of SPConfigure is 1, we expect $true but the result is false and the results of SPConfigure is 0, we expect $false but the result is true
        $TestCases = @{spconfig = 1; expected = $true; actual = $false }, @{spconfig = 0; expected = $false; actual = $true }
        It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $actual, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            { Assert-XpCmdShellDisabled -SQLInstance 'Dummy' -XpCmdShellDisabled $expected } | Should -Throw -ExpectedMessage "Expected `$$expected, because The XP CmdShell setting should be set correctly, but got `$$actual"
        }
        # again this one is different from the others as we are checking for disabled
        $TestCases = @{spconfig = 1; expected = $false }, @{spconfig = 0; expected = $true; }
        It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
            Param($spconfig, $expected)
            Mock Get-DbaSpConfigure { @{"ConfiguredValue" = $spconfig } }
            Assert-XpCmdShellDisabled -SQLInstance 'Dummy' -XpCmdShellDisabled $expected
        }
        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaSpConfigure'
                'Times'       = 4
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Checking ErrorLog Count" {
        # if configured value is 30 and test value 30 it will pass
        It "Passes Check Correctly with the number of error log files set to 30" {
            # Mock to pass
            Mock Get-DbaErrorLogConfig { @{"LogCount" = 30 } }
            Assert-ErrorLogCount -SQLInstance 'Dummy' -errorLogCount 30
        }

        # if configured value is less than the current value it fails
        It "Fails Check Correctly with the number of error log files being 10 instead of 30 or higher" {
            # Mock to fail
            Mock Get-DbaErrorLogConfig { @{"LogCount" = 10 } }
            { Assert-ErrorLogCount -SQLInstance 'Dummy' -errorLogCount 30 } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than or equal to 30, because We expect to have at least 30 number of error log files, but got 10."
        }

        # if configured value is higher than the current value it fails
        It "Passes Check Correctly with the number of error log files being 40 and test of 30 or higher" {
            # Mock to Pass
            Mock Get-DbaErrorLogConfig { @{"LogCount" = 40 } }
            Assert-ErrorLogCount -SQLInstance 'Dummy' -errorLogCount 30
        }

        # Validate we have called the mock the correct number of times
        It "Should call the mocks" {
            $assertMockParams = @{
                'CommandName' = 'Get-DbaErrorLogConfig'
                'Times'       = 3
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
}

InModuleScope dbachecks {
    (Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{ . $Psitem.FullName }
    Describe "Testing AllInstanceInfo and Relevant Assertions" -Tag AllInstanceInfo {
        function Get-ErrorLogEntry { }
        Mock Get-DbcConfigValue { } -ParameterFilter { $Name -and $Name -eq 'policy.errorlog.warningwindow' }
        Context "Checking Get-AllInstanceInfo" {
            Mock Get-ErrorLogEntry { }

            It "Should return the correct results for ErrorLog Entries when there are no severities" {
                (Get-AllInstanceInfo -Instance Dummy -Tags ErrorLog -There $true).ErrorLog | Should -BeNullOrEmpty -Because "We need no entries when we have no sev 17 to 24 errors"
            }

            It "Should return the correct results for ErrorLog Entries when there are severities" {
                Mock Get-ErrorLogEntry { [PSCustomObject]@{
                        LogDate     = '2019-02-14 23:00'
                        ProcessInfo = 'spid55'
                        Text        = 'Error: 50000, Severity: 18, State: 1.'
                    }
                }
                (Get-AllInstanceInfo -Instance Dummy -Tags ErrorLog -There $true).ErrorLog | Should -BeOfType PSCustomObject -Because "We need entries when we have sev 17 to 24 errors"
            }

            It "Should return the correct results for Default Trace when it is enabled" {
                Mock Get-DbaSpConfigure { @{
                        'ConfiguredValue' = 1
                    } }
                (Get-AllInstanceInfo -Instance Dummy -Tags DefaultTrace -There $true).DefaultTrace.ConfiguredValue | Should -Be 1 -Because "We need to return one when we have default trace enabled"
            }

            It "Should return the correct results for Default Trace when it is disabled" {
                Mock Get-DbaSpConfigure { [pscustomobject]@{
                        ConfiguredValue = 0
                    } }

                (Get-AllInstanceInfo -Instance Dummy -Tags DefaultTrace -There $true).DefaultTrace.ConfiguredValue | Should -Be 0 -Because "We need to return zero when default trace is not enabled"
            }
        }
        Context "Checking ErrorLog Entries" {

            It "Should pass the test successfully when there are no Severity Errors" {
                # Mock for success
                Mock Get-AllInstanceInfo { }
                Assert-ErrorLogEntry -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when there are Severity Errors" {
                # MOck for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        ErrorLog = [PSCustomObject]@{
                            LogDate     = '2019-02-14 23:00'
                            ProcessInfo = 'spid55'
                            Text        = 'Error: 50000, Severity: 18, State: 1.'
                        }
                    } }
                { Assert-ErrorLogEntry -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected `$null or empty, because these severities indicate serious problems, but got @(@{LogDate=2019-02-14 23:00; ProcessInfo=spid55; Text=Error: 50000, Severity: 18, State: 1.})."
            }
        }
        Context "Checking Cross DB Ownership Chaining" {
            It "Should pass the test successfully when cross db ownership chaining is disabled" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        CrossDBOwnershipChaining = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    } }

                Assert-CrossDBOwnershipChaining -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when cross db ownership chaining is enabled" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        CrossDBOwnershipChaining = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    } }

                { Assert-CrossDBOwnershipChaining -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected 0, because We expected the Cross DB Ownership Chaining to be disabled, but got 1."
            }
        }

        Context "Checking Default Trace Entries" {

            It "Should pass the test successfully when default trace is enabled" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        DefaultTrace = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    } }
                Assert-DefaultTrace -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when when default trace is disabled" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        DefaultTrace = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    }
                }
                { Assert-DefaultTrace -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected 1, because We expected the Default Trace to be enabled, but got 0."
            }
        }
        Context "Checking OLE Automation Procedures Entries" {

            It "Should pass the test successfully when OLE Automation Procedures is disabled" {
                # Mock for success
                # This should pass when the configured value for OleAutomationProcedures enabled is 0 (ie disabled)
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        OleAutomationProceduresDisabled = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    }
                }
                Assert-OLEAutomationProcedures -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when when OLE Automation Procedures is enabled" {
                # Mock for failing test
                # This should pass when the configured value for OleAutomationProcedures enabled is 1 (ie enabled)
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        OleAutomationProceduresDisabled = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    }
                }
                { Assert-OLEAutomationProcedures -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected 0, because we expect the OLE Automation Procedures to be disabled, but got 1."
            }
        }
        Context "Checking Remote Access Entries" {

            It "Should pass the test successfully when remote access is disabled" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        RemoteAccess = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    }
                }
                Assert-RemoteAccess -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when remote access is enabled" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        RemoteAccess = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    }
                }

                { Assert-RemoteAccess -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected 0, because we expected Remote Access to be disabled, but got 1."
            }
        }
        Context "Checking Scan For Startup Procedures Entries" {

            It "Should pass the test successfully when scan for startup procedures is disabled and config is true" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        ScanForStartupProceduresDisabled = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    }
                }
                Assert-ScanForStartupProcedures -AllInstanceInfo (Get-AllInstanceInfo) -ScanForStartupProcsDisabled $true
            }

            It "Should fail the test successfully when scan for startup procedures is disabled and config is false" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        ScanForStartupProceduresDisabled = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    } }
                { Assert-ScanForStartupProcedures -AllInstanceInfo (Get-AllInstanceInfo) -ScanForStartupProcsDisabled $false } | Should -Throw -ExpectedMessage "Expected `$false, because We expected the scan for startup procedures to be configured correctly, but got `$true."
            }

            It "Should pass the test successfully when scan for startup procedures is enabled and config is false" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        ScanForStartupProceduresDisabled = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    }
                }
                Assert-ScanForStartupProcedures -AllInstanceInfo (Get-AllInstanceInfo) -ScanForStartupProcsDisabled $false
            }

            It "Should fail the test successfully when scan for startup procedures is enabled and config is true" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        ScanForStartupProceduresDisabled = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    } }
                { Assert-ScanForStartupProcedures -AllInstanceInfo (Get-AllInstanceInfo) -ScanForStartupProcsDisabled $true } | Should -Throw -ExpectedMessage "Expected `$true, because We expected the scan for startup procedures to be configured correctly, but got `$false."
            }
        }
        Context "Checking Cross DB Ownership Chaining" {
            It "Should pass the test successfully when cross db ownership chaining is disabled" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        CrossDBOwnershipChaining = [PSCustomObject]@{
                            ConfiguredValue = 0
                        }
                    } }
                Assert-CrossDBOwnershipChaining -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when cross db ownership chaining is enabled" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        CrossDBOwnershipChaining = [PSCustomObject]@{
                            ConfiguredValue = 1
                        }
                    } }
                { Assert-CrossDBOwnershipChaining -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected 0, because we expected the cross db ownership chaining to be disabled, but got 1."
            }
        }
        Context "Checking Max Dump Entries" {

            It "Should pass the test successfully when the number of dumps is less than config" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        MaxDump = [PSCustomObject]@{
                            Count = 0
                        }
                    }
                }
                $maxdumps = 1
                Assert-MaxDump  -AllInstanceInfo (Get-AllInstanceInfo)  -maxdumps $maxdumps
            }

            It "Should fail the test successfully when the number of dumps is more than config" {
                # Mock for failing test
                Mock Get-AllInstanceInfo {
                    [PSCustomObject]@{
                        MaxDump = [PSCustomObject]@{
                            Count = 7
                        }
                    }
                }
                $maxdumps = 4
                { Assert-MaxDump  -AllInstanceInfo (Get-AllInstanceInfo) -maxdumps $maxdumps } | Should -Throw -ExpectedMessage "Expected the actual value to be less than 4, because We expected less than 4 dumps but found 7. Memory dumps often suggest issues with the SQL Server instance, but got 7"
            }
        }
        Context "Checking Latest Build of SQL Server" {

            It "Should pass the test successfully when scan for latest build of SQL passes" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        LatestBuild = [PSCustomObject]@{
                            Compliant = $true
                        }
                    }
                }
                Assert-LatestBuild -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when scan for latest build of SQL fails" {
                # Mock for failing test
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        LatestBuild = [PSCustomObject]@{
                            Compliant = $false
                        }
                    } }
                { Assert-LatestBuild -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected `$true, because We expected the SQL Server to be on the newest SQL Server Packs/CUs, but got `$false."
            }
        }
        Context "Checking SQL Engine" {

            It "Should pass the test successfully when the sql engine is running and the config is set to running" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Running'
                            StartType = 'Automatic'
                        }
                    }
                }
                Assert-EngineState  -AllInstanceInfo (Get-AllInstanceInfo) -state 'Running'
            }

            It "Should fail the test successfully successfully when the sql engine is stopped and the config is set to running" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Automatic'
                        }
                    }
                }
                { Assert-EngineState  -AllInstanceInfo (Get-AllInstanceInfo) -state 'Running' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service was expected to be Running, but they were different."
            }
            It "Should pass the test successfully when the sql engine is stopped and the config is set to stopped" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Running'
                            StartType = 'Automatic'
                        }
                    }
                }
                Assert-EngineState  -AllInstanceInfo (Get-AllInstanceInfo) -state 'Running'
            }

            It "Should fail the test successfully successfully when the sql engine is running and the config is set to stopped" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Automatic'
                        }
                    }
                }
                { Assert-EngineState  -AllInstanceInfo (Get-AllInstanceInfo) -state 'Running' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service was expected to be Running, but they were different."
            }

            It "Should pass the test successfully when the sql engine is set to Automatic and the config is set to Automatic and it is not a cluster" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Running'
                            StartType = 'Automatic'
                        }
                    }
                }
                Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Automatic'
            }

            It "Should fail the test successfully when the sql engine is set to Manual and the config is set to Automatic and it is not a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Manual'
                        }
                    }
                }
                { Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Automatic' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service Start Type was expected to be Automatic, but they were different."
            }
            It "Should fail the test successfully when the sql engine is set to Disabled and the config is set to Automatic and it is not a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Disabled'
                        }
                    }
                }
                { Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Automatic' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service Start Type was expected to be Automatic, but they were different."
            }
            It "Should pass the test successfully when the sql engine is set to Manual and the config is set to Manual and it is not a cluster" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Running'
                            StartType = 'Manual'
                        }
                    }
                }
                Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Manual'
            }

            It "Should fail the test successfully when the sql engine is set to Automatic and the config is set to Manual and it is not a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Automatic'
                        }
                    }
                }
                { Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Manual' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service Start Type was expected to be Manual, but they were different."
            }
            It "Should fail the test successfully when the sql engine is set to Disabled and the config is set to Manual and it is not a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Disabled'
                        }
                    }
                }
                { Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Manual' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service Start Type was expected to be Manual, but they were different."
            }
            It "Should pass the test successfully when the sql engine is set to Disabled and the config is set to Disabled and it is not a cluster" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Running'
                            StartType = 'Disabled'
                        }
                    }
                }
                Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Disabled'
            }
            It "Should fail the test successfully when the sql engine is set to Manual and the config is set to Disabled and it is not a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Manual'
                        }
                    }
                }
                { Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Disabled' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service Start Type was expected to be Disabled, but they were different."
            }
            It "Should fail the test successfully when the sql engine is set to Automatic and the config is set to Disabled and it is not a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Automatic'
                        }
                    }
                }
                { Assert-EngineStartType  -AllInstanceInfo (Get-AllInstanceInfo) -StartType 'Disabled' } | Should -Throw -ExpectedMessage "Expected strings to be the same, because The SQL Service Start Type was expected to be Disabled, but they were different."
            }
            It "Should pass the test successfully when the sql engine is set to Manual and it is a cluster" {
                # Mock for success
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Running'
                            StartType = 'Manual'
                        }
                    }
                }
                Assert-EngineStartTypeCluster  -AllInstanceInfo (Get-AllInstanceInfo)
            }
            It "Should fail the test successfully when the sql engine is set to Automatic and it is a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Automatic'
                        }
                    }
                }
                { Assert-EngineStartTypeCluster  -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected strings to be the same, because Clustered Instances required that the SQL engine service is set to manual, but they were different."
            }
            It "Should fail the test successfully when the sql engine is set to Disabled and it is a cluster" {
                # Mock for failure
                Mock Get-AllInstanceInfo { [PSCustomObject]@{
                        EngineService = [pscustomobject] @{
                            State     = 'Stopped'
                            StartType = 'Disabled'
                        }
                    }
                }
                { Assert-EngineStartTypeCluster  -AllInstanceInfo (Get-AllInstanceInfo) } | Should -Throw -ExpectedMessage "Expected strings to be the same, because Clustered Instances required that the SQL engine service is set to manual, but they were different."
            }
        }
        Context "Checking sa login disabled" {

            It "Should pass the test successfully when the original sa account is disabled" {
                # Mock for success
                Mock Get-AllInstanceInfo {[PSCustomObject]@{
                    SaDisabled = [PSCustomObject]@{
                        Disabled = $true
                    }
                }
            }
                Assert-SaDisabled -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when the original sa account is enabled" {
                # Mock for failing test
                Mock Get-AllInstanceInfo {[PSCustomObject]@{
                    SaDisabled = [PSCustomObject]@{
                        Disabled = $false
                        }
                    }}
                {Assert-SaDisabled -AllInstanceInfo (Get-AllInstanceInfo)} | Should -Throw -ExpectedMessage "Expected `$true, because We expected the original sa login to be disabled, but got `$false."
            }
        }
        Context "Checking no sa login exist" {

            It "Should pass the test successfully when no sa login exist" {
                # Mock for success
                Mock Get-AllInstanceInfo {[PSCustomObject]@{
                    SaExist = [PSCustomObject]@{
                        Exist = 0
                    }
                }
            }
                Assert-SaExist -AllInstanceInfo (Get-AllInstanceInfo)
            }

            It "Should fail the test successfully when a sa login doesn't exist" {
                # Mock for failing test
                Mock Get-AllInstanceInfo {[PSCustomObject]@{
                    SaExist = [PSCustomObject]@{
                        Exist = 1
                        }
                    }}
                {Assert-SaExist -AllInstanceInfo (Get-AllInstanceInfo)} | Should -Throw -ExpectedMessage "Expected 0, because We expected no login to exist with the name sa, but got 1."
            }
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3zT39A2lyXiuj8g4j77KCVG1
# vq2gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSGUXCG13OfAv5/0pfenyNd4nxE
# HzANBgkqhkiG9w0BAQEFAASCAQA3Oz2mbycV6Q4ns38NGrSqedo4pV0TmWpQ7oxr
# IpZQisFu095UwNQQ+dmWlwjT411VBlvw0ud0Njt+EFGt458CvvVU9T6nqkkmK2OG
# JLkJOkzwDLrFG7H92LdJRq8LtREnBBz488xz/Tpb4HJs/Drgwi0muC99mug9Cv9C
# ffTv69G9bf7C9yDuGHfftArerPIg+c3OVLOLuEYPgGQb84yb7k5UmtSQmRwI+puw
# H88Byh7MRR5sTHhwSMlla0ESvTSnks/XJwWYXw/IyqyCyD9PwPJejccwiI+pC1Os
# TKVpI+AhTilaojWO0qr5jYawjd1JndKREFl5MtrsIdUX5PVM
# SIG # End signature block

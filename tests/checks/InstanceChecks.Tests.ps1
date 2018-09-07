# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking Instance.Tests.ps1 checks" -Tag UnitTest {
	Context "Checking Backup Compression" {
		# Mock the version check for running tests
		Mock Connect-DbaInstance {@{Version = @{Major = 14}}}
		# Define test cases for the results to fail test and fill expected message
		# So the results of SPConfigure is 1, we expect $false but the result is true and the results of SPConfigure is 0, we expect $true but the result is false
		$TestCases = @{spconfig = 1; expected = $false; actual = $true}, @{spconfig = 0; expected = $true; actual = $false}
		It "Fails Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
			Param($spconfig, $actual, $expected)
			Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
			{Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected} | Should -Throw -ExpectedMessage "Expected `$$expected, because The default backup compression should be set correctly, but got `$$actual"
		}
		$TestCases = @{spconfig = 0; expected = $false}, @{spconfig = 1; expected = $true; }
		It "Passes Check Correctly for Config <spconfig> and expected value <expected>" -TestCases $TestCases {
			Param($spconfig, $expected)
			Mock Get-DbaSpConfigure {@{"ConfiguredValue" = $spconfig}}
			Assert-BackupCompression -Instance 'Dummy' -defaultbackupcompression $expected
		}
		# Validate we have called the mock the correct number of times
		It "Should call the mocks" {
			$assertMockParams = @{
				'CommandName' = 'Get-DbaSpConfigure'
				'Times'		  = 4
				'Exactly'	  = $true
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
			Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 0; "RecommendedMaxDop" = 0}}
			Assert-InstanceMaxDop  -Instance 'Dummy' -UseRecommended
		}
		# if Userecommended it should fail if CurrentInstanceMaxDop property returned from Test-DbaMaxDop does not match the RecommendedMaxDop property
		It "Fails Check Correctly with the use recommended parameter set to true" {
			# Mock to fail
			Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 0; "RecommendedMaxDop" = 5}}
			{Assert-InstanceMaxDop -Instance 'Dummy' -UseRecommended} | Should -Throw -ExpectedMessage "Expected 5, because We expect the MaxDop Setting 0 to be the recommended value 5"
		}
		$TestCases = @{"MaxDopValue" = 5}
		# if not UseRecommended - it should pass if the CurrentInstanceMaxDop property returned from Test-DbaMaxDop matches the MaxDopValue parameter
		It "Passes Check Correctly with a specified value <MaxDopValue>" -TestCases $TestCases {
			Param($MaxDopValue)
			# Mock to pass
			Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 5; "RecommendedMaxDop" = $MaxDopValue}}
			Assert-InstanceMaxDop -Instance 'Dummy' -MaxDopValue $MaxDopValue
		}
		$TestCases = @{"MaxDopValue" = 5}, @{"MaxDopValue" = 0}
		# if not UseRecommended - it should fail if the CurrentInstanceMaxDop property returned from Test-DbaMaxDop does not match the MaxDopValue parameter
		It "Fails Check Correctly with with a specified value <MaxDopValue>" -TestCases $TestCases {
			Param($MaxDopValue)
			# Mock to fail
			Mock Test-DbaMaxDop {@{"CurrentInstanceMaxDop" = 4; "RecommendedMaxDop" = 73}}
			{Assert-InstanceMaxDop -Instance 'Dummy' -MaxDopValue $MaxDopValue} | Should -Throw -ExpectedMessage "Expected $MaxDopValue, because We expect the MaxDop Setting 4 to be $MaxDopValue"
		}
		# Validate we have called the mock the correct number of times
		It "Should call the mocks" {
			$assertMockParams = @{
				'CommandName' = 'Test-DbaMaxDop'
				'Times'		  = 5
				'Exactly'	  = $true
			}
			Assert-MockCalled @assertMockParams
		}
	}
	Context "Checking tempdb size" {
		Mock Get-DbaDbFile {@(
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
		)}

		It "Should pass the test when all tempdb files are the same size" {
			Assert-TempDBSize -Instance Dummy
		}

		Mock Get-DbaDbFile {@(
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
		)}

		It "Should fail when all of the tempdb files are not the same size" {
			{Assert-TempDBSize -Instance Dummy} | Should -Throw -ExpectedMessage "We want all the tempdb data files to be the same size - See https://blogs.sentryone.com/aaronbertrand/sql-server-2016-tempdb-fixes/ and https://www.brentozar.com/blitz/tempdb-data-files/ for more information"
		}
	}
	Context "Checking Supported Build" {
		[DateTime]$Date = Get-Date -Format O

		$TestCases = 	@{"Date" = $Date; "BuildBehind" = "1SP";}, 
					 	@{"Date" = $Date; "BuildBehind" = "1CU";}
		#if BuildBehind it should pass if build is >= SP/CU specified & Support Dates are valid
		It "Passed check correctly when the current build is not behind the BuildBehind value of <BuildBehind>" -TestCases $TestCases {
			Param($BuildBehind, $Date)
			#Mock to pass
			Mock Test-DbaBuild {@{"SPLevel" = "{SP4, LATEST}"; "CULevel" = "CU4"; "Compliant" = $true; "SupportedUntil" = $Date.AddMonths(1)}}
			Assert-InstanceSupportedBuild -Instance 'Dummy' -BuildBehind $BuildBehind -Date $Date
		}
		$TestCases = 	@{"Date" = $Date; "BuildBehind" = "1SP"; "BuildWarning" = 6; "expected" = $true; "actual" = $false},
					 	@{"Date" = $Date; "BuildBehind" = "1CU"; "BuildWarning" = 6; "expected" = $true; "actual" = $false}
		#if BuildBehind it should fail if build is <= SP/CU specified & Support dates are valid
		It "Failed check correctly when the current build is behind the BuildBehind value of <BuildBehind>" -TestCases $TestCases {
			Param($BuildBehind, $Date, $expected, $actual)
			#Mock to fail
			Mock Test-DbaSqlBuild {@{"SPLevel" = "{SP2}"; "CULevel" = "CU2"; "SPTarget" = "SP4"; "CUTarget" = "CU4"; "Compliant" = $false; "SupportedUntil" = $Date.AddMonths(1); "Build" = 42}}
			{ Assert-InstanceSupportedBuild -Instance 'Dummy' -BuildBehind $BuildBehind -Date $Date} | Should -Throw -ExpectedMessage "Expected `$$expected, because this build 42 should not be behind the required build, but got `$$actual"
		}
		$TestCases = @{"Date" = $Date}
		#if neither BuildBehind nor BuildWarning it should pass if support dates are valid
		It "Passed check correctly with a SupportedUntil date > today" -TestCases $TestCases {
			Param($Date)
			#Mock to pass
			Mock Test-DbaSqlBuild {@{"SupportedUntil" = $Date.AddMonths(1)}}
			Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date
		}
		$TestCases = @{"Date" = $Date}
		#if neither BuildBehind nor BuildWarning it should fail if support date is out of the support window
		It "Failed check correctly with a SupportedUntil date < today" -TestCases $TestCases {
			Param($Date)
			#Mock to fail
			Mock Test-DbaBuild {@{"SupportedUntil" = $Date.AddMonths(-1); "Build" = 42}}
			$SupportedUntil = Get-Date $Date.AddMonths(-1) -Format O
			$Date = Get-Date $Date -Format O
			{ Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than $Date, because this build 42 is now unsupported by Microsoft, but got $SupportedUntil"
		}
		$TestCases = @{"Date" = $Date; "BuildWarning" = 6}
		#if BuildWarning it should fail if support date is in the warning window
		It "Passed check correctly with the BuildWarning window > today" -TestCases $TestCases {
			Param($Date, $BuildWarning)
			#Mock to pass
			Mock Test-DbaSqlBuild {@{"SupportedUntil" = $Date.AddMonths(9); "Build" = 42}}
			{ Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date -BuildWarning $BuildWarning }
		}
		$TestCases = @{"Date" = $Date; "BuildWarning" = 6}
		#if BuildWarning it should fail if support date is in the warning window
		It "Failed check correctly with the BuildWarning window < today" -TestCases $TestCases {
			Param($Date, $BuildWarning)
			#Mock to fail
			Mock Test-DbaBuild {@{"SupportedUntil" = $Date.AddMonths(3); "Build" = 42}}
			$SupportedUntil = Get-Date $Date.AddMonths(3) -Format O
			$expected = Get-Date $Date.AddMonths($BuildWarning) -Format O
			{ Assert-InstanceSupportedBuild -Instance 'Dummy' -Date $Date -BuildWarning $BuildWarning } | Should -Throw -ExpectedMessage "Expected the actual value to be greater than $expected, because this build 42 will be unsupported by Microsoft on $SupportedUntil which is less than $BuildWarning months away, but got $SupportedUntil"
		}

	}
}



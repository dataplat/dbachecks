function Invoke-DbcCheck {
	<#
		.SYNOPSIS
			Invoke-DbcCheck is a SQL-centric Invoke-Pester wrapper

		.DESCRIPTION
			The Invoke-DbcCheck function runs Pester tests, including *.Tests.ps1 files and Pester tests in PowerShell scripts.

			Extended description about Pester: Get-Help -Name Invoke-Pester
	
		.PARAMETER Check
		Runs only tests in Describe blocks with the specified Tag parameter values. Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

		When you specify multiple Tag values, Invoke-DbcCheck runs tests that have any of the listed tags (it ORs the tags). However, when you specify TestName and Tag values, Invoke-DbcCheck runs only describe blocks that have one of the specified TestName values and one of the specified Tag values.

		If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

		.PARAMETER ExcludeCheck
			Omits tests in Describe blocks with the specified Tag parameter values. Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

			When you specify multiple ExcludeTag values, Invoke-DbcCheck omits tests that have any of the listed tags (it ORs the tags). However, when you specify TestName and ExcludeTag values, Invoke-DbcCheck omits only describe blocks that have one of the specified TestName values and one of the specified Tag values.

			If you use both Tag and ExcludeTag, ExcludeTag takes precedence

		.PARAMETER SqlInstance
			A list of SQL Servers to run the tests against. If this is not provided, it will be gathered from:
				Get-DbaConfig -Name app.sqlinstance
	
		.PARAMETER ComputerName
			A list of computers to run the tests against. If this is not provided, it will be gathered from:
				Get-DbaConfig -Name app.computername
	
		.PARAMETER SqlCredential
			Alternate SQL Server-based credential.
	
		.PARAMETER Credential
			Alternate Windows credential.
	
		.PARAMETER Database
			A list of databases to include if your check is database centric.

		.PARAMETER ExcludeDatabase
			A list of databases to exclude if your check is database centric.
	
		.PARAMETER PassThru
			Returns a custom object (PSCustomObject) that contains the test results.

			By default, Invoke-DbcCheck writes to the host program, not to the output stream (stdout).
			If you try to save the result in a variable, the variable is empty unless you
			use the PassThru parameter.

			To suppress the host output, use the Quiet parameter.
	
		.PARAMETER OutputFormat
		The format of output. Two formats of output are supported: NUnitXML and LegacyNUnitXML.

			.PARAMETER Strict
			Makes Pending and Skipped tests to Failed tests. Useful for continuous integration where you need to make sure all tests passed.

		.PARAMETER AllChecks
			In the unlikely event that you'd like to run all checks, specify -AllChecks. These checks still confirm to the skip settings in Get-DbcConfig.
	
		.PARAMETER Quiet
			The parameter Quiet is deprecated since Pester v. 4.0 and will be deleted in the next major version of Pester. Please use the parameter Show with value 'None' instead.

		.PARAMETER Show
			Customizes the output Pester writes to the screen. 
			
			Available options are 
				None
				Default
				Passed
				Failed
				Pending
				Skipped
				Inconclusive
				Describe
				Context
				Summary
				Header
				All
				Fails

			The options can be combined to define presets.

			Common use cases are:

			None - to write no output to the screen.
			All - to write all available information (this is default option).
			Fails - to write everything except Passed (but including Describes etc.).

			A common setting is also Failed, Summary, to write only failed tests and test summary.

			This parameter does not affect the PassThru custom object or the XML output that is written when you use the Output parameters.
	
		.PARAMETER Value
			A value.. it's hard to explain
	
		.PARAMETER Script
			Get-Help -Name Invoke-Pester -Parameter Script

		.PARAMETER TestName
			Get-Help -Name Invoke-Pester -Parameter TestName
	
		.PARAMETER EnableExit
			Get-Help -Name Invoke-Pester -Parameter EnableExit

		.PARAMETER OutputFile
			Get-Help -Name Invoke-Pester -Parameter OutputFile
	
		.PARAMETER CodeCoverage
			Get-Help -Name Invoke-Pester -Parameter CodeCoverage

		.PARAMETER CodeCoverageOutputFile
			Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFile

		.PARAMETER CodeCoverageOutputFileFormat
			Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFileFormat


		.PARAMETER PesterOption
			Get-Help -Name Invoke-Pester -Parameter PesterOption

		.LINK
			https://github.com/pester/Pester/wiki/Invoke-Pester

			Describe
			about_Pester
			New-PesterOption

		.EXAMPLE
			Invoke-DbcCheck

			This command runs all *.Tests.ps1 files in the current directory and its subdirectories.

		.EXAMPLE
			Invoke-DbcCheck -Script .\Util*

			This commands runs all *.Tests.ps1 files in subdirectories with names that begin
			with 'Util' and their subdirectories.

		.EXAMPLE
			Invoke-DbcCheck -Script D:\MyModule, @{ Path = '.\Tests\Utility\ModuleUnit.Tests.ps1'; Parameters = @{ Name = 'User01' }; Arguments = srvNano16  }

			This command runs all *.Tests.ps1 files in D:\MyModule and its subdirectories.
			It also runs the tests in the ModuleUnit.Tests.ps1 file using the following
			parameters: .\Tests\Utility\ModuleUnit.Tests.ps1 srvNano16 -Name User01

		.EXAMPLE
			Invoke-DbcCheck -TestName "Add Numbers"

			This command runs only the tests in the Describe block named "Add Numbers".

		.EXAMPLE
			$results = Invoke-DbcCheck -Script D:\MyModule -PassThru -Show None
			$failed = $results.TestResult | where Result -eq 'Failed'

			$failed.Name
			cannot find help for parameter: Force : in Compress-Archive
			help for Force parameter in Compress-Archive has wrong Mandatory value
			help for Compress-Archive has wrong parameter type for Force
			help for Update parameter in Compress-Archive has wrong Mandatory value
			help for DestinationPath parameter in Expand-Archive has wrong Mandatory value

			$failed[0]
			Describe               : Test help for Compress-Archive in Microsoft.PowerShell.Archive (1.0.0.0)
			Context                : Test parameter help for Compress-Archive
			Name                   : cannot find help for parameter: Force : in Compress-Archive
			Result                 : Failed
			Passed                 : False
			Time                   : 00:00:00.0193083
			FailureMessage         : Expected: value to not be empty
			StackTrace             : at line: 279 in C:\GitHub\PesterTdd\Module.Help.Tests.ps1
									 279:                     $parameterHelp.Description.Text | Should Not BeNullOrEmpty
			ErrorRecord            : Expected: value to not be empty
			ParameterizedSuiteName :
			Parameters             : {}

			This examples uses the PassThru parameter to return a custom object with the
			Pester test results. By default, Invoke-DbcCheck writes to the host program, but not
			to the output stream. It also uses the Quiet parameter to suppress the host output.

			The first command runs Invoke-DbcCheck with the PassThru and Quiet parameters and
			saves the PassThru output in the $results variable.

			The second command gets only failing results and saves them in the $failed variable.

			The third command gets the names of the failing results. The result name is the
			name of the It block that contains the test.

			The fourth command uses an array index to get the first failing result. The
			property values describe the test, the expected result, the actual result, and
			useful values, including a stack trace.


		.EXAMPLE
			Invoke-DbcCheck -Script C:\Tests -Check UnitTest, Newest -ExcludeCheck Bug

			This command runs *.Tests.ps1 files in C:\Tests and its subdirectories. In those
			files, it runs only tests that have UnitTest or Newest tags, unless the test
			also has a Bug tag.
	#>
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param (
		[Alias('Path', 'relative_path')]
		[object[]]$Script,
		[Alias("Name")]
		[string[]]$TestName,
		[switch]$EnableExit,
		[Parameter(Position=0)]
		[Alias("Tags", "Tag", "Checks")]
		[string[]]$Check,
		[Alias("ExcludeTags", "ExcludeTag", "ExcludeChecks")]
		[string[]]$ExcludeCheck,
		[switch]$PassThru,
		[DbaInstance[]]$SqlInstance,
		[DbaInstance[]]$ComputerName,
		[PSCredential]$SqlCredential,
		[PSCredential]$Credential,
		[object[]]$Database,
		[object[]]$ExcludeDatabase,
		[string[]]$Value,
		[object[]]$CodeCoverage = @(),
		[string]$CodeCoverageOutputFile,
		[ValidateSet('JaCoCo')]
		[string]$CodeCoverageOutputFileFormat = "JaCoCo",
		[switch]$Strict,
		[Parameter(Mandatory = $true, ParameterSetName = 'NewOutputSet')]
		[string]$OutputFile,
		[ValidateSet('NUnitXml')]
		[string]$OutputFormat = 'NUnitXml',
		[switch]$AllChecks,
		[switch]$Quiet,
		[object]$PesterOption,
		[Pester.OutputTypes]$Show = 'All'
	)
	
	process {
		
		if (-not $Script -and -not $TestName -and -not $Check -and -not $ExcludeCheck -and -not $AllChecks) {
			Stop-PSFFunction -Message "Please specify Check, ExcludeCheck, Script, TestName or AllChecks"
			return
		}
		
		if (-not $SqlInstance.InputObject -and -not $ComputerName.InputObject -and -not (Get-PSFConfigValue -FullName dbachecks.app.sqlinstance) -and -not (Get-PSFConfigValue -FullName dbachecks.app.computername)) {
			Stop-PSFFunction -Message "No servers set to run against. Use Get/Set-DbcConfig to setup your servers or Get-Help Invoke-DbcCheck for additional options."
			return
		}
		
		$customparam = 'SqlInstance', 'ComputerName', 'SqlCredential', 'Credential', 'Database', 'ExcludeDatabase', 'Value'
		
		foreach ($param in $customparam) {
			if (Test-PSFParameterBinding -ParameterName $param) {
				$value = Get-Variable -Name $param
				if ($value.InputObject) {
					Set-Variable -Scope 0 -Name $param -Value $value.InputObject -ErrorAction SilentlyContinue
					$PSDefaultParameterValues.Add({ "*-Dba*:$param", $value.InputObject })
				}
			}
			else {
				$PSDefaultParameterValues.Remove({ "*-Dba*:$param" })
			}
			$null = $PSBoundParameters.Remove($param)
		}
		
		# Lil bit of cleanup here, for a switcharoo
		$null = $PSBoundParameters.Remove('AllChecks')
		$null = $PSBoundParameters.Remove('Check')
		$null = $PSBoundParameters.Remove('ExcludeCheck')
		$null = $PSBoundParameters.Add('Tag', $Check)
		$null = $PSBoundParameters.Add('ExcludeTag', $ExcludeCheck)
		
		
		# Then we'll need a generic param passer that doesnt require global params 
		# cuz global params are hard
		
		$repos = Get-CheckRepo
		foreach ($repo in $repos) {
			if ((Test-Path $repo -ErrorAction SilentlyContinue)) {
				if ($OutputFormat -eq "NUnitXml" -and -not $OutputFile) {
					$number = $repos.IndexOf($repo)
					$PSBoundParameters['OutputFile'] = "$script:maildirectory\report$number.xml"
				}
				Push-Location -Path $repo
				Invoke-Pester @PSBoundParameters
				Pop-Location
			}
		}
	}
}

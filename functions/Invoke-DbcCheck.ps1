function Invoke-DbcCheck {
	<#
		.SYNOPSIS
			Invoke-DbcCheck is a SQL-centric Invoke-Pester wrapper

		.DESCRIPTION
			The Invoke-DbcCheck function runs Pester tests, including *.Tests.ps1 files and Pester tests in PowerShell scripts.

			Extended description about Pester:
	
			You can run scripts that include Pester tests just as you would any other Windows PowerShell script, including typing the full path at the command line and running in a script editing program. Typically, you use Invoke-DbcCheck to run all Pester tests in a directory, or to use its many helpful parameters, including parameters that generate custom objects or XML files.

			By default, Invoke-DbcCheck runs all *.Tests.ps1 files in the checks directory and all subdirectories recursively. You can use its parameters to select tests by file name, test name, or tag.

			To run Pester tests in scripts that take parameter values, use the Script parameter with a hash table value.

			Also, by default, Pester tests write the results to the console host, much like Write-Host does, a few items to consider/remember:
			
			- Use the Quiet parameter to suppress the host messages.
			- Use the PassThru parameter to generate a custom object (PSCustomObject) that contains the test results. 
			- Use the OutputXml and OutputFormat parameters to write the test results to an XML file.
			- Use the EnableExit parameter to return an exit code that contains the number of failed tests.
			- Use the Strict parameter to fail all pending and skipped tests. This feature is ideal for build systems and other processes that require success on every test.

			To help with test design, Invoke-DbcCheck includes a CodeCoverage parameter that lists commands, functions, and lines of code that did not run during test execution and returns the code that ran as a percentage of all tested code.

			Invoke-Pester, and the Pester module that exports it, are products of an open-source project hosted on GitHub. To view, comment, or contribute to the repository, see https://github.com/Pester.

		.PARAMETER Script
			Specifies the test files that Pester runs. You can also use the Script parameter to pass parameter names and values to a script that contains Pester tests. The value of the Script parameter can be a string, a hash table, or a collection of hash tables and strings. Wildcard characters are supported.

			The Script parameter is optional. If you omit it, Invoke-DbcCheck runs all *.Tests.ps1 files in the local directory and its subdirectories recursively.

			To run tests in other files, such as .ps1 files, enter the path and file name of the file. (The file name is required. Name patterns that end in "*.ps1" run only *.Tests.ps1 files.)

			To run a Pester test with parameter names and/or values, use a hash table as the value of the script parameter. The keys in the hash table are:

			-- Path [string] (required): Specifies a test to run. The value is a path\file name or name pattern. Wildcards are permitted. All hash tables in a Script parameter value must have a Path key.

			-- Parameters [hashtable]: Runs the script with the specified parameters. The value is a nested hash table with parameter name and value pairs, such as @{UserName = 'User01'; Id = '28'}.

			-- Arguments [array]: An array or comma-separated list of parameter values without names, such as 'User01', 28. Use this key to pass values to positional parameters.

		.PARAMETER TestName
			Runs only tests in Describe blocks that have the specified name or name pattern. Wildcard characters are supported.

			If you specify multiple TestName values, Invoke-DbcCheck runs tests that have any of the values in the Describe name (it ORs the TestName values).

		.PARAMETER EnableExit
			Will cause Invoke-DbcCheck to exit with a exit code equal to the number of failed tests once all tests have been run. Use this to "fail" a build when any tests fail.

		.PARAMETER OutputFile
			The path where Invoke-DbcCheck will save formatted test results log file.

			The path must include the location and name of the folder and file name with the xml extension.

			If this path is not provided, no log will be generated.

		.PARAMETER OutputFormat
			The format of output. Two formats of output are supported: NUnitXML and LegacyNUnitXML.

		.PARAMETER Tag
			Runs only tests in Describe blocks with the specified Tag parameter values. Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

			When you specify multiple Tag values, Invoke-DbcCheck runs tests that have any of the listed tags (it ORs the tags). However, when you specify TestName and Tag values, Invoke-DbcCheck runs only describe blocks that have one of the specified TestName values and one of the specified Tag values.

			If you use both Tag and ExcludeTag, ExcludeTag takes precedence.

		.PARAMETER ExcludeTag
			Omits tests in Describe blocks with the specified Tag parameter values. Wildcard characters and Tag values that include spaces or whitespace characters are not supported.

			When you specify multiple ExcludeTag values, Invoke-DbcCheck omits tests that have any of the listed tags (it ORs the tags). However, when you specify TestName and ExcludeTag values, Invoke-DbcCheck omits only describe blocks that have one of the specified TestName values and one of the specified Tag values.

			If you use both Tag and ExcludeTag, ExcludeTag takes precedence

		.PARAMETER PassThru
			Returns a custom object (PSCustomObject) that contains the test results.

			By default, Invoke-DbcCheck writes to the host program, not to the output stream (stdout).
			If you try to save the result in a variable, the variable is empty unless you
			use the PassThru parameter.

			To suppress the host output, use the Quiet parameter.

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
	
		.PARAMETER Value
			A value.. it's hard to explain
	
		.PARAMETER CodeCoverage
			Adds a code coverage report to the Pester tests. Takes strings or hash table values.

			A code coverage report lists the lines of code that did and did not run during a Pester test. This report does not tell whether code was tested; only whether the code ran during the test.

			By default, the code coverage report is written to the host program (like Write-Host). When you use the PassThru parameter, the custom object that Invoke-DbcCheck returns has an additional CodeCoverage property that contains a custom object with detailed results of the code coverage test, including lines hit, lines missed, and helpful statistics.

			However, NUnitXML and LegacyNUnitXML output (OutputXML, OutputFormat) do not include any code coverage information, because it's not supported by the schema.

			Enter the path to the files of code under test (not the test file). Wildcard characters are supported. If you omit the path, the default is local directory, not the directory specified by the Script parameter.

			To run a code coverage test only on selected functions or lines in a script, enter a hash table value with the following keys:

			-- Path (P)(mandatory) <string>. Enter one path to the files. Wildcard characters are supported, but only one string is permitted.

			One of the following: Function or StartLine/EndLine

			-- Function (F) <string>: Enter the function name. Wildcard characters are supported, but only one string is permitted.

			-or-

			-- StartLine (S): Performs code coverage analysis beginning with the specified line. Default is line 1.
			-- EndLine (E): Performs code coverage analysis ending with the specified line. Default is the last line of the script.

		.PARAMETER CodeCoverageOutputFile
			The path where Invoke-DbcCheck will save formatted code coverage results file.

			The path must include the location and name of the folder and file name with a required extension (usually the xml).

			If this path is not provided, no file will be generated.

		.PARAMETER CodeCoverageOutputFileFormat
			The name of a code coverage report file format.

			Default value is: JaCoCo.

			Currently supported formats are:
			- JaCoCo - this XML file format is compatible with the VSTS/TFS

		.PARAMETER Strict
			Makes Pending and Skipped tests to Failed tests. Useful for continuous integration where you need to make sure all tests passed.

		.PARAMETER Quiet
			The parameter Quiet is deprecated since Pester v. 4.0 and will be deleted in the next major version of Pester. Please use the parameter Show with value 'None' instead.

			The parameter Quiet suppresses the output that Pester writes to the host program, including the result summary and CodeCoverage output.

			This parameter does not affect the PassThru custom object or the XML output that is written when you use the Output parameters.

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

		.PARAMETER PesterOption
			Sets advanced options for the test execution. Enter a PesterOption object, such as one that you create by using the New-PesterOption cmdlet, or a hash table in which the keys are option names and the values are option values.

			For more information on the options available, see the help for New-PesterOption.

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
			Invoke-DbcCheck -EnableExit -OutputFile ".\artifacts\TestResults.xml" -OutputFormat NUnitXml

			This command runs all tests in the current directory and its subdirectories. It
			writes the results to the TestResults.xml file using the NUnitXml schema. The
			test returns an exit code equal to the number of test failures.

		 .EXAMPLE
			Invoke-DbcCheck -CodeCoverage 'ScriptUnderTest.ps1'

			Runs all *.Tests.ps1 scripts in the current directory, and generates a coverage
			report for all commands in the "ScriptUnderTest.ps1" file.

		.EXAMPLE
			Invoke-DbcCheck -CodeCoverage @{ Path = 'ScriptUnderTest.ps1'; Function = 'FunctionUnderTest' }

			Runs all *.Tests.ps1 scripts in the current directory, and generates a coverage
			report for all commands in the "FunctionUnderTest" function in the "ScriptUnderTest.ps1" file.

		 .EXAMPLE
			Invoke-DbcCheck -CodeCoverage 'ScriptUnderTest.ps1' -CodeCoverageOutputFile '.\artifacts\TestOutput.xml'

			Runs all *.Tests.ps1 scripts in the current directory, and generates a coverage
			report for all commands in the "ScriptUnderTest.ps1" file, and writes the coverage report to TestOutput.xml
			file using the JaCoCo XML Report DTD.

		.EXAMPLE
			Invoke-DbcCheck -CodeCoverage @{ Path = 'ScriptUnderTest.ps1'; StartLine = 10; EndLine = 20 }

			Runs all *.Tests.ps1 scripts in the current directory, and generates a coverage
			report for all commands on lines 10 through 20 in the "ScriptUnderTest.ps1" file.

		.EXAMPLE
			Invoke-DbcCheck -Script C:\Tests -Tag UnitTest, Newest -ExcludeTag Bug

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
		[Alias("Tags", "Check")]
		[string[]]$Tag,
		[string[]]$ExcludeTag,
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
		[String]$CodeCoverageOutputFileFormat = "JaCoCo",
		[Switch]$Strict,
		[Parameter(Mandatory = $true, ParameterSetName = 'NewOutputSet')]
		[string]$OutputFile,
		[ValidateSet('NUnitXml')]
		[string]$OutputFormat = 'NUnitXml',
		[Switch]$Quiet,
		[object]$PesterOption,
		[Pester.OutputTypes]$Show = 'All'
	)
	
	process {
		
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

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
            The format of output. Currently, only NUnitXML is supported. 

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
    
        .PARAMETER PesterOption
            Get-Help -Name Invoke-Pester -Parameter PesterOption

        .PARAMETER CodeCoverageOutputFile
            Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFile

        .PARAMETER CodeCoverageOutputFileFormat
            Get-Help -Name Invoke-Pester -Parameter CodeCoverageOutputFileFormat

        .LINK
            https://github.com/pester/Pester/wiki/Invoke-Pester

            Describe
            about_Pester

        .EXAMPLE
            # Set the servers you'll be working with
            Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
            Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008

            # Look at the current configs
            Get-DbcConfig

            # Invoke a few tests
            Invoke-DbcCheck -Tags SuspectPage, LastBackup
    
            Does this and that
    
        .EXAMPLE
            Invoke-DbcCheck -Tag Backup -SqlInstance sql2016
            Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster -SqlCredential (Get-Credential sqladmin)
    
            Does this

        .EXAMPLE
            Invoke-DbcCheck -Check Database -ExcludeCheck AutoShrink
            Does that

        .EXAMPLE
            # Run checks and export its JSON
            Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource

            # Launch Power BI then hit refresh
            Start-DbcPowerBi
    
            Does that

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -OutputFormat NUnitXml -PassThru |
            Send-DbcMailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SmtpServer smtp.ad.local

        .EXAMPLE
            Get-Help -Name Invoke-Pester -Examples

            Want to get super deep? You can look at Invoke-Pester's example's and run them against Invoke-DbcCheck since it's a wrapper.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Alias('Path', 'relative_path')]
        [object[]]$Script,
        [Alias("Name")]
        [string[]]$TestName,
        [switch]$EnableExit,
        [Parameter(Position = 0)]
        [Alias("Tags", "Tag", "Checks")]
        [string[]]$Check,
        [AllowEmptyCollection()]
        [Alias("ExcludeTags", "ExcludeTag", "ExcludeChecks")]
        [string[]]$ExcludeCheck = (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludecheck' -Fallback @()),
        [switch]$PassThru,
        [DbaInstance[]]$SqlInstance,
        [DbaInstance[]]$ComputerName,
        [PSCredential]$SqlCredential,
        [PSCredential]$Credential,
        [object[]]$Database,
        [object[]]$ExcludeDatabase = (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludedatabase' -Fallback @()),
        [string[]]$Value,
        [object[]]$CodeCoverage = @(),
        [string]$CodeCoverageOutputFile,
        [ValidateSet('JaCoCo')]
        [string]$CodeCoverageOutputFileFormat = "JaCoCo",
        [switch]$Strict,
        [Parameter(Mandatory = $true, ParameterSetName = 'NewOutputSet')]
        [string]$OutputFile,
        [ValidateSet('NUnitXml')]
        [string]$OutputFormat,
        [switch]$AllChecks,
        [switch]$Quiet,
        [object]$PesterOption,
        [Pester.OutputTypes]$Show = 'All'
    )
    
    dynamicparam {
        $config = Get-PSFConfig -Module dbachecks
        
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        foreach ($setting in $config) {
            $name = $setting.Name
            $name = "Config" + (($name.Split(".") | ForEach-Object { $_.SubString(0, 1).ToUpper() + $_.SubString(1) }) -join '')
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.ParameterSetName = '__AllParameterSets'
            $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)
            
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($name, [object], $AttribColl)
            
            $RuntimeParamDic.Add($name, $RuntimeParam)
        }
        return $RuntimeParamDic
    }
    
    begin {
        $config = Get-PSFConfig -Module dbachecks
        
        foreach ($key in $PSBoundParameters.Keys | Where-Object { $_ -like "Config*" }) {
            if ($item = $config | Where-Object { "Config$($_.Name.Replace('.', ''))" -eq $key }) {
                Set-PSFConfig -Module dbachecks -Name $item.Name -Value $PSBoundParameters.$key
            }
        }
        
        if ($SqlCredential) {
            if ($PSDefaultParameterValues) {
                $newvalue = $PSDefaultParameterValues += @{ '*:SqlCredential' = $SqlCredential }
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
            }
            else {
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $SqlCredential }
            }
        }
        else {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*:SqlCredential')
            }
        }
        
        if ($Credential) {
            if ($PSDefaultParameterValues) {
                $newvalue = $PSDefaultParameterValues += @{ '*Dba*:Credential' = $Credential }
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
            }
            else {
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*Dba*:Credential' = $Credential }
            }
        }
        else {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*Dba*:Credential')
            }
        }
    }
    
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
                    $PSDefaultParameterValues.Add( { "*-Dba*:$param", $value.InputObject })
                }
            }
            else {
                $PSDefaultParameterValues.Remove( { "*-Dba*:$param" })
            }
            $null = $PSBoundParameters.Remove($param)
        }

        
        # Lil bit of cleanup here, for a switcharoo
        $null = $PSBoundParameters.Remove('AllChecks')
        $null = $PSBoundParameters.Remove('Check')
        $null = $PSBoundParameters.Remove('ExcludeCheck')
        $null = $PSBoundParameters.Add('Tag', $Check)
        $null = $PSBoundParameters.Add('ExcludeTag', $ExcludeCheck)

        
        $globalexcludedchecks = Get-PSFConfigValue -FullName dbachecks.command.invokedbccheck.excludecheck
        [string[]]$Script:ExcludedDatabases = Get-PSFConfigValue -FullName dbachecks.command.invokedbccheck.excludedatabases
        $Script:ExcludedDatabases += $ExcludeDatabase

        
        foreach ($singlecheck in $check) {
            if ($singlecheck -in $globalexcludedchecks) {
                Write-PSFMessage -Level Warning -Message "$singlecheck is excluded in command.invokedbccheck.excludecheck and will be skipped "
            }
        }
        
        if ($AllChecks -and $globalexcludedchecks) {
            Write-PSFMessage -Level Warning -Message "$globalexcludedchecks will be skipped"
        }

        if ($ExcludedDatabases) {
            Write-PSFMessage -Level Warning -Message "$ExcludedDatabases databases will be skipped for all checks"
        }
        
        # Then we'll need a generic param passer that doesnt require global params 
        # cuz global params are hard

        $finishedAllTheChecks = $false
        try {
            $repos = Get-CheckRepo
            foreach ($repo in $repos) {
                if ((Test-Path $repo -ErrorAction SilentlyContinue)) {
                    if ($OutputFormat -eq "NUnitXml" -and -not $OutputFile) {
                        $number = $repos.IndexOf($repo)
                        $timestamp = Get-Date -format "yyyyMMddHHmmss"
                        $PSBoundParameters['OutputFile'] = "$script:maildirectory\report-$number-$pid-$timestamp.xml"
                    }

                    if ($Check.Count -gt 0) {
                        # specific checks were listed. find the necessary script files. 
                        $PSBoundParameters['Script'] = (Get-CheckFile -Repo $repo -Check $check)
                    }

                    Push-Location -Path $repo
                    Invoke-Pester @PSBoundParameters
                }
            }
            $finishedAllTheChecks = $true
        }
        catch {
            Stop-PSFFunction -Message "There was a problem with execution of checks repos!" -ErrorRecord $psitem
        }
        finally {
            if (!($finishedAllTheChecks)) {
                Write-PSFMessage -Level Warning -Message "Execution was cancelled!"
            }
            Pop-Location
        }
    }
}

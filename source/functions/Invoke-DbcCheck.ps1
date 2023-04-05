
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
Get-DbatoolsConfig -Name app.sqlinstance

.PARAMETER ComputerName
A list of computers to run the tests against. If this is not provided, it will be gathered from:
Get-DbatoolsConfig -Name app.computername

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

.PARAMETER ConfigFile
The path to the exported dbachecks config file.

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
https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/

.EXAMPLE
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016

Runs all of the checks tagged Backup against the sql2016 instance

.EXAMPLE
Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster -SqlCredential (Get-Credential sqladmin)

Runs the Recovery model check against the SQL instances sql2017, sqlcluster
using the sqladmin SQL login with the password provided interactively

.EXAMPLE
Invoke-DbcCheck -Check Database -ExcludeCheck AutoShrink -ConfigFile \\share\repo\prod.json

Runs all of the checks tagged Database except for the AutoShrink check against
the SQL Instances set in the config under app.sqlinstance

Imports configuration file, \\share\repo\prod.json, prior to executing checks.

.EXAMPLE
# Set the servers you'll be working with
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008

# Look at the current configs
Get-DbcConfig

# Invoke a few tests
Invoke-DbcCheck -Tags SuspectPage, LastBackup

Runs the Suspect Pages and Last Backup checks against the SQL Instances sql2016,
sql2017, sql2008, sql2008\express after setting them in the configuration

.EXAMPLE
Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource

Start-DbcPowerBi

Runs the Suspect Page and Last Backup checks against the SQL Instances set in
the config under app.sqlinstance only showing the summary of the results of the
checks. It then updates the source json for the XML which is stored at
C:\Windows\temp\dbachecks\ and then opens the PowerBi report in PowerBi Desktop

.EXAMPLE
Get-Help -Name Invoke-Pester -Examples

Want to get super deep? You can look at Invoke-Pester's example's and run them against Invoke-DbcCheck since it's a wrapper.

https://github.com/pester/Pester/wiki/Invoke-Pester

Describe
about_Pester
#>
#TODO the help is probably not correct
function Invoke-DbcCheck {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Because scoping is hard')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Because its set to the global var')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Alias('Path', 'relative_path')]
        [object[]]$Script,
        [Alias('Name')]
        [string[]]$TestName,
        [switch]$EnableExit,
        [Parameter(Position = 0)]
        [Alias('Tags', 'Tag', 'Checks')]
        [string[]]$Check,
        [AllowEmptyCollection()]
        [Alias('ExcludeTags', 'ExcludeTag', 'ExcludeChecks')]
        [string[]]$ExcludeCheck = (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludecheck' -Fallback @()),
        [switch]$PassThru,
        [DbaInstance[]]$SqlInstance,
        [DbaInstance[]]$ComputerName,
        [PSCredential]$SqlCredential,
        [PSCredential]$Credential,
        [object[]]$Database,
        [object[]]$ExcludeDatabase = (Get-PSFConfigValue -FullName 'dbachecks.command.invokedbccheck.excludedatabase' -Fallback @()),
        [string[]]$Value,
        [string]$ConfigFile,
        [object[]]$CodeCoverage = @(),
        [string]$CodeCoverageOutputFile,
        [ValidateSet('JaCoCo')]
        [string]$CodeCoverageOutputFileFormat = 'JaCoCo',
        [switch]$Strict,
        [Parameter(Mandatory = $true, ParameterSetName = 'NewOutputSet')]
        [string]$OutputFile,
        [ValidateSet('NUnitXml')]
        [string]$OutputFormat,
        [switch]$AllChecks,
        [switch]$Quiet,
        [ValidateSet('None', 'Minimal', 'Detailed', 'Default', 'Passed', 'Failed', 'Pending', 'Skipped', 'Inconclusive', 'Describe', 'Context', 'Summary', 'Header', 'Fails', 'All', 'Diagnostic')] #None, Default,Passed, Failed, Pending, Skipped, Inconclusive, Describe, Context, Summary, Header, All, Fails.
        [string]$Show = 'All',
        [bool]$legacy = $true
    )

    dynamicparam {
        $config = Get-PSFConfig -Module dbachecks

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        foreach ($setting in $config) {
            $name = $setting.Name
            $name = 'Config' + (($name.Split('.') | ForEach-Object { $_.SubString(0, 1).ToUpper() + $_.SubString(1) }) -join '')
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.ParameterSetName = '__AllParameterSets'
            $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)

            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($name, [object], $AttribColl)

            $RuntimeParamDic.Add($name, $RuntimeParam)
        }
        return $RuntimeParamDic
    }

    begin {
        if (Test-PSFParameterBinding -ParameterName ConfigFile) {
            if (-not (Test-Path -Path $ConfigFile)) {
                Stop-PSFFunction -Message "$ConfigFile does not exist"
                return
            }
            $null = Import-DbcConfig -Path $ConfigFile -WarningAction SilentlyContinue -Temporary
        }

        $config = Get-PSFConfig -Module dbachecks
        foreach ($key in $PSBoundParameters.Keys | Where-Object { $_ -like 'Config*' }) {
            if ($item = $config | Where-Object { "Config$($_.Name.Replace('.', ''))" -eq $key }) {
                Set-PSFConfig -Module dbachecks -Name $item.Name -Value $PSBoundParameters.$key
            }
        }

        if ($SqlCredential) {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*:SqlCredential')
                $newvalue = $PSDefaultParameterValues += @{ '*:SqlCredential' = $SqlCredential }
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
            } else {
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $SqlCredential }
            }
        } else {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*:SqlCredential')
            }
        }

        if ($Credential) {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*Dba*:Credential')
                $newvalue = $PSDefaultParameterValues += @{ '*Dba*:Credential' = $Credential }
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
            } else {
                Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*Dba*:Credential' = $Credential }
            }
        } else {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*Dba*:Credential')
            }
        }
    }
    process {
        if ($legacy) {
            try {
                if (Get-Module Pester | Where-Object { $_.Version -gt '5.0.0' }) {
                    Remove-Module Pester -ErrorAction SilentlyContinue
                    Write-PSFMessage 'Running in legacy mode, we need to import Version 4' -Level Verbose
                    Import-Module Pester -RequiredVersion 4.10.1 -Global
                }
            } catch {
                Write-PSFMessage -Message 'Something Went wrong' -Level Warning -ErrorRecord $_
                Return
            }
            $null = $PSBoundParameters.Remove('legacy')
            Invoke-DbcCheckv4 @PSBoundParameters
        } else {
            try {
                if (Get-Module Pester | Where-Object { $_.Version -lt '5.0.0' }) {
                    Remove-Module Pester -ErrorAction SilentlyContinue
                    Write-PSFMessage 'Running in fancy new mode, we need to import Version 5' -Level Verbose
                    Import-Module Pester -MinimumVersion 5.0.0 -Global
                } else {
                    Write-PSFMessage 'Running in fancy new mode but not imported' -Level Verbose
                }

                # We should be able to move the creation of the container and the configuration to here
                switch ($Show) {
                    'None' {
                        $NewShow = 'None'
                    }
                    'Default' {
                        $NewShow = 'Detailed'
                    }
                    'Passed' {
                        $NewShow = 'Normal'
                    }
                    'Failed' {
                        $NewShow = 'Normal'
                    }
                    'Pending' {
                        $NewShow = 'Normal'
                    }
                    'Skipped' {
                        $NewShow = 'Normal'
                    }
                    'Inconclusive' {
                        $NewShow = 'Normal'
                    }
                    'Describe' {
                        $NewShow = 'Normal'
                    }
                    'Context' {
                        $NewShow = 'Normal'
                    }
                    'Summary' {
                        $NewShow = 'Normal'
                    }
                    'Header' {
                        $NewShow = 'Normal'
                    }
                    'Fails' {
                        $NewShow = 'Normal'
                    }
                    'All' {
                        $NewShow = 'Detailed'
                    }
                    'Diagnostic' {
                        $NewShow = 'Diagnostic'
                    }
                    'Minimal' {
                        $NewShow = 'Minimal'
                    }
                    Default {
                        $NewShow = 'Detailed'
                    }
                }
                # cast from empty hashtable to get default
                $configuration = New-PesterConfiguration
                $configuration.Output.Verbosity = $NewShow
                $configuration.Filter.Tag = $check
                $configuration.Filter.ExcludeTag = $ExcludeCheck
                if ($PassThru) {
                    $configuration.Run.PassThru = $true
                }
            } catch {
                Write-PSFMessage -Message 'Something Went wrong' -Level Warning -ErrorRecord $_
                Return
            }
            $null = $PSBoundParameters.Remove('legacy')
            $null = $PSBoundParameters.Remove('Show')
            $null = $PSBoundParameters.Remove('PassThru')
            Write-PSFMessage -Message ($PSBoundParameters | Out-String) -Level Significant
            Invoke-DbcCheckv5 @PSBoundParameters -configuration $configuration
        }
    }
    end {

    }


}
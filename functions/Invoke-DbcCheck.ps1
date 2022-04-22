function Invoke-DbcCheck {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Because scoping is hard')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Because its set to the global var')]
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
        [string]$ConfigFile,
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
        [ValidateSet('None', 'Minimal','Detailed','Default', 'Passed', 'Failed', 'Pending', 'Skipped', 'Inconclusive', 'Describe', 'Context', 'Summary', 'Header', 'Fails', 'All', 'Diagnostic')] #None, Default,Passed, Failed, Pending, Skipped, Inconclusive, Describe, Context, Summary, Header, All, Fails.
        [string]$Show = 'All',
        [bool]$legacy = $true
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
        if (Test-PSFParameterBinding -ParameterName ConfigFile) {
            if (-not (Test-Path -Path $ConfigFile)) {
                Stop-PSFFunction -Message "$ConfigFile does not exist"
                return
            }
            $null = Import-DbcConfig -Path $ConfigFile -WarningAction SilentlyContinue -Temporary
        }

        $config = Get-PSFConfig -Module dbachecks
        foreach ($key in $PSBoundParameters.Keys | Where-Object { $_ -like "Config*" }) {
            if ($item = $config | Where-Object { "Config$($_.Name.Replace('.', ''))" -eq $key }) {
                Set-PSFConfig -Module dbachecks -Name $item.Name -Value $PSBoundParameters.$key
            }
        }

        if ($SqlCredential) {
            if ($PSDefaultParameterValues) {
                $PSDefaultParameterValues.Remove('*:SqlCredential')
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
                $PSDefaultParameterValues.Remove('*Dba*:Credential')
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
        if ($legacy) {
            try {
                Remove-Module Pester -ErrorAction SilentlyContinue
                Write-PsfMessage "Running in legacy mode, we need to import Version 4" -Level Verbose
                Import-Module Pester -RequiredVersion 4.10.1 -Global
            }
            catch {
                Write-PsfMessage -Message "Something Went wrong" -Level Warning -ErrorRecord $_ 
                Return
            }
            $null = $PSBoundParameters.Remove('legacy')
            Invoke-DbcCheckv4 @PSBoundParameters
        }
        else {
            try {
                Remove-Module Pester -ErrorAction SilentlyContinue
                Write-PsfMessage "Running in fancy new mode, we need to import Version 5" -Level Verbose
                Import-Module Pester -MinimumVersion 5.0.0 -Global

                # We should be able to move the creation of the container and the configuration to here
                switch ($Show) {
                    'None' {
                        $NewShow  = 'None'
                    }
                    'Default' {
                        $NewShow  = 'Detailed'
                    }
                    'Passed' {
                        $NewShow  = 'Normal'
                    }
                    'Failed' {
                        $NewShow  = 'Normal'
                    }
                    'Pending' {
                        $NewShow  = 'Normal'
                    }
                    'Skipped' {
                        $NewShow  = 'Normal'
                    }
                    'Inconclusive' {
                        $NewShow  = 'Normal'
                    }
                    'Describe' {
                        $NewShow  = 'Normal'
                    }
                    'Context' {
                        $NewShow  = 'Normal'
                    }
                    'Summary' {
                        $NewShow  = 'Normal'
                    }
                    'Header' {
                        $NewShow  = 'Normal'
                    }
                    'Fails' {
                        $NewShow  = 'Normal'
                    }
                    'All' {
                        $NewShow  = 'Detailed'
                    }
                    'Diagnostic' {
                        $NewShow  = 'Diagnostic'
                    }
                    'Minimal' {
                        $NewShow  = 'Minimal'
                    }
                    Default {
                        $NewShow  = 'Detailed'
                    }
                }
                # cast from empty hashtable to get default
                $configuration = New-PesterConfiguration
                $configuration.Output.Verbosity = $NewShow
                $configuration.Filter.Tag = $check
                $configuration.Filter.ExcludeTag = $ExcludeCheck
            }
            catch {
                Write-PsfMessage -Message "Something Went wrong" -Level Warning -ErrorRecord $_ 
                Return
            }
            $null = $PSBoundParameters.Remove('legacy')
            $null = $PSBoundParameters.Remove('Show')
            Write-PSFMessage -Message ($PSBoundParameters | Out-String) -Level Significant
            Invoke-DbcCheckv5 @PSBoundParameters -configuration $configuration
        }
    }
    end {

    }


}
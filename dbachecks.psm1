$script:ModuleRoot = $PSScriptRoot
$script:localapp = "$env:localappdata\dbachecks"

function Import-ModuleFile
{
	[CmdletBinding()]
	Param (
		[string]
		$Path
	)
	
	if ($doDotSource) { . $Path }
	else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

# Detect whether at some level dotsourcing was enforced
$script:doDotSource = $false
if ($dbachecks_dotsourcemodule) { $script:doDotSource = $true }
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsPowerShell\dbachecks\System" -Name "DoDotSource" -ErrorAction Ignore).DoDotSource) { $script:doDotSource = $true }
if ((Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\WindowsPowerShell\dbachecks\System" -Name "DoDotSource" -ErrorAction Ignore).DoDotSource) { $script:doDotSource = $true }

# Execute Preimport actions
. Import-ModuleFile -Path "$ModuleRoot\internal\scripts\preimport.ps1"

# Import all internal functions
foreach ($function in (Get-ChildItem "$ModuleRoot\internal\functions\*.ps1"))
{
	. Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\functions\*.ps1"))
{
	. Import-ModuleFile -Path $function.FullName
}

# Execute Postimport actions
. Import-ModuleFile -Path "$ModuleRoot\internal\scripts\postimport.ps1"

# Importing PSDefaultParameterValues
$PSDefaultParameterValues = (Get-Variable -Scope Global -Name PSDefaultParameterValues).Value
Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $PSDefaultParameterValues

# Set default param values if it exists
if ($streetcred = (Get-DbcConfigValue -Name Setup.SqlCredential)) {
	if ($PSDefaultParameterValues) {
		Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $PSDefaultParameterValues += @{ '*:SqlCredential' = $streetcred }
	}
	else
	{
		Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $streetcred }
	}
}
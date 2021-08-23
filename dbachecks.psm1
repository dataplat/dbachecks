$script:ModuleRoot = $PSScriptRoot
$VerbosePreference = "SilentlyContinue"

## Rotten way to fix Pester v5 issues


if ((Get-Module Pester).Version.Major -eq 5) {
    Write-PSFMessage -Message "You have Pester version 5 in this session which is not compatible - Let me try to remove it" -Level Verbose

    try {
        Remove-Module Pester -Force
        $CompatibleInstalledPester = Get-Module Pester -ListAvailable | Where-Object { $Psitem.Version.Major -le 4 } | Sort-Object Version -Descending | Select-Object -First 1
        Write-PSFMessage -Message "Removed Version 5 trying to import version $($CompatibleInstalledPester.Version.ToString())"
        Import-Module $CompatibleInstalledPester.Path -Scope Global
    }
    catch {
        Write-PSFMessage -Level Significant -Message "Failed to remove Pester version 5 or import suitable version - Do you have Version 4* installed ?"
        Break
    }
}
else {
    try {
        $CompatibleInstalledPester = Get-Module Pester -ListAvailable | Where-Object { $Psitem.Version.Major -le 4 } | Sort-Object Version -Descending | Select-Object -First 1
        Write-PSFMessage -Message "Trying to import version $($CompatibleInstalledPester.Version.ToString())"
        Import-Module $CompatibleInstalledPester.Path -Scope Global
    }
    catch {
        Write-PSFMessage -Level Significant -Message "Failed to import suitable version - Do you have Version 4* installed ?"
        Break
    }
}


function Import-ModuleFile {
    [CmdletBinding()]
    Param (
        [string]
        $Path
    )

    if ($doDotSource) { . $Path }
    else {
        try {
            $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null)
        }
        catch {
            Write-Warning "Failed to import $Path"
        }
    }
}

# Detect whether at some level dotsourcing was enforced
$script:doDotSource = $false
if ($dbachecks_dotsourcemodule) { $script:doDotSource = $true }
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsPowerShell\dbachecks\System" -Name "DoDotSource" -ErrorAction Ignore).DoDotSource) { $script:doDotSource = $true }
if ((Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\WindowsPowerShell\dbachecks\System" -Name "DoDotSource" -ErrorAction Ignore).DoDotSource) { $script:doDotSource = $true }

# Execute Preimport actions
if($IsLinux){
    Write-Verbose "Loading preimport in linux"
    . Import-ModuleFile -Path "$ModuleRoot/internal/scripts/preimport.ps1"
}else{
    . Import-ModuleFile -Path "$ModuleRoot\internal\scripts\preimport.ps1"
}


# Import all internal functions
foreach ($function in (Get-ChildItem "$ModuleRoot\internal\functions\*.ps1")) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\functions\*.ps1")) {
    . Import-ModuleFile -Path $function.FullName
}

# Execute Postimport actions
if($IsLinux){
    Write-Verbose "Loading postimport in linux"
    . Import-ModuleFile -Path "$ModuleRoot/internal/scripts/postimport.ps1"
}else{
    . Import-ModuleFile -Path "$ModuleRoot\internal\scripts\postimport.ps1"
}

if (-not (Test-Path Alias:Update-Dbachecks)) { Set-Alias -Scope Global -Name 'Update-Dbachecks' -Value 'Update-DbcRequiredModules' }
$VerbosePreference = "SilentlyContinue"

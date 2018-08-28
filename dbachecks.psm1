$script:ModuleRoot = $PSScriptRoot

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
. Import-ModuleFile -Path "$ModuleRoot\internal\scripts\preimport.ps1"

# Import all internal functions
foreach ($function in (Get-ChildItem "$ModuleRoot\internal\functions\*.ps1")) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\functions\*.ps1")) {
    . Import-ModuleFile -Path $function.FullName
}

# Execute Postimport actions
. Import-ModuleFile -Path "$ModuleRoot\internal\scripts\postimport.ps1"

if (-not (Test-Path Alias:Update-Dbachecks)) { Set-Alias -Scope Global -Name 'Update-Dbachecks' -Value 'Update-DbcRequiredModules' }


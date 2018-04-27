# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
    . Import-ModuleFile -Path $file.FullName
}

# load app stuff and create files if needed
$script:localapp = Get-DbcConfigValue -Name app.localapp
$script:maildirectory = Get-DbcConfigValue -Name app.maildirectory

if (-not (Test-Path -Path $script:localapp)) {
    New-Item -ItemType Directory -Path $script:localapp
}

if (-not (Test-Path -Path $script:maildirectory)) {
    New-Item -ItemType Directory -Path $script:maildirectory
}

# Parse repo for tags and descriptions then write json
New-Json

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.ps1")) {
    . Import-ModuleFile -Path $file.FullName
}

# Importing PSDefaultParameterValues
$PSDefaultParameterValues = $global:PSDefaultParameterValues

# Set default param values if it exists
if ($credential = (Get-DbcConfigValue -Name app.sqlcredential)) {
    if ($PSDefaultParameterValues) {
        $newvalue = $PSDefaultParameterValues += @{ '*:SqlCredential' = $credential }
        Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
    }
    else {
        Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $credential }
    }
}

# EnableException so that failed commands cause failures
$PSDefaultParameterValues += @{ '*-Dba*:EnableException' = $true }

# Fred magic
# Set-PSFTaskEngineCache -Module dbachecks -Name module-imported -Value $true
Install-Module PlatyPs -Scope CurrentUser -Force
Import-Module PlatyPs 

# Get the Module versions
Install-Module Configuration -RequiredVersion 1.3.0 -Scope CurrentUser -Force
$Modules = Get-ManifestValue -Path .\dbachecks.psd1 -PropertyName RequiredModules

$PesterVersion = $Modules.Where{$_.Get_Item('ModuleName') -eq 'Pester'}[0].Get_Item('ModuleVersion')
$PSFrameworkVersion = $Modules.Where{$_.Get_Item('ModuleName') -eq 'PSFramework'}[0].Get_Item('ModuleVersion')
$dbatoolsVersion = $Modules.Where{$_.Get_Item('ModuleName') -eq 'dbatools'}[0].Get_Item('ModuleVersion')

# Install Pester
try {
    Write-Output "Installing Pester"
    Install-Module Pester  -RequiredVersion $PesterVersion  -Scope CurrentUser -Force -SkipPublisherCheck
    Write-Output "Installed Pester"

}
catch {
    Write-Error "Failed to Install Pester $($_)"
}

# Install Latest version of pester as well 
try {
    Write-Output "Installing Latest Pester"
    Install-Module Pester  -Scope CurrentUser -Force -SkipPublisherCheck
    Write-Output "Installed Latest Pester"

}
catch {
    Write-Error "Failed to Install Pester $($_)"
}
# Install dbatools
try {
    Write-Output "Installing PSFramework"
    Install-Module PSFramework  -RequiredVersion $PsFrameworkVersion  -Scope CurrentUser -Force 
    Write-Output "Installed PSFramework"

}
catch {
    Write-Error "Failed to Install PSFramework $($_)"
}
# Install dbachecks
try {
    Write-Output "Installing dbatools"
    Install-Module dbatools  -RequiredVersion $dbatoolsVersion  -Scope CurrentUser -Force 
    Write-Output "Installed dbatools"

}
catch {
    Write-Error "Failed to Install dbatools $($_)"
}

# Add current folder to PSModulePath
try {
    Write-Output "Adding local folder to PSModulePath"
    $ENV:PSModulePath = $ENV:PSModulePath + ";$pwd"
    Write-Output "Added local folder to PSModulePath"    
    $ENV:PSModulePath.Split(';')
}
catch {
    Write-Error "Failed to add $pwd to PSModulePAth - $_"
}
try {
    Write-Output "Installing dbachecks"
    Import-Module .\dbachecks.psd1
    Write-Output "Installed dbachecks"

}
catch {
    Write-Error "Failed to Install dbachecks $($_)"
}

$ProjectRoot = Get-Location
$ModuleName = 'dbachecks'
$BuildDate = Get-Date -uFormat '%Y-%m-%d'
$ReleaseNotes = ".\RELEASE.md"
$ChangeLog = "$ProjectRoot\docs\ChangeLog.md"


#Build YAMLText starting with the header
$YMLtext = (Get-Content "$ProjectRoot\header-mkdocs.yml") -join "`n"
$YMLtext = "$YMLtext`n"

$parameters = @{
    Path = $ReleaseNotes
    ErrorAction = 'SilentlyContinue'
}
$ReleaseText = (Get-Content @parameters) -join "`n"
if ($ReleaseText) {
    $ReleaseText | Set-Content "$ProjectRoot\docs\RELEASE.md"
    $YMLText = "$YMLtext  - Release Notes: RELEASE.md`n"
}
if ((Test-Path -Path $ChangeLog)) {
    $YMLText = "$YMLtext  - Change Log: ChangeLog.md`n"
}
$YMLText = "$YMLtext  - Functions:`n"

$Params = @{
    Module       = 'dbachecks'
    Force        = $true
    OutputFolder = "$ProjectRoot\docs\functions"
    NoMetadata   = $true
}
New-MarkdownHelp @Params | foreach-object {
    $Function = $_.Name -replace '\.md', ''
    $Part = "    - {0}: functions/{1}" -f $Function, $_.Name
    $YMLText = "{0}{1}`n" -f $YMLText, $Part
    $Part
}
$YMLtext | Set-Content -Path "$ProjectRoot\mkdocs.yml"
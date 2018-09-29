Install-Module PlatyPs -Scope CurrentUser -Force
Import-Module PlatyPs 
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
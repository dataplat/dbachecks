<#
Push in path to install
Work out where we're being called from (should be withing dbchecks folder)

if path!= where we are then we need to pull and move latest dbchecks install to there,

pull from github

Then work through other requirements
if psd1 modules != modules in here, throw as someones' not updated.

For each module grab latest
Unzip to path
If path in $P

#>

[CmdletBinding()]
param (
    [string]$Path,
    [switch]$Beta
)

function Write-LocalMessage {
    [CmdletBinding()]
    Param (
        [string]$Message
    )
    
    if (Test-Path function:Write-Message) { Write-Message -Level Output -Message $Message }
    else { Write-Host $Message }
}
#    @{ ModuleName = 'dbachecks'; URL='https://github.com/potatoqualitee/dbachecks/archive/master.zip'},
#Sort ourselves out first:
$modules = @(
    
    @{ ModuleName = 'Pester'; ModuleVersion = '4.1.1'; URL = 'https://github.com/pester/Pester/archive/master.zip' },
    @{ ModuleName = 'dbatools'; ModuleVersion = '0.9.139'; URL = 'https://dbatools.io/zip' },
    @{ ModuleName = 'PSFramework'; ModuleVersion = '0.9.5.10'; URL = 'https://github.com/PowershellFrameworkCollective/psframework/archive/master.zip' }
)
$RequiredModules = (Import-PowerShellDataFile -path .\dbachecks.psd1).RequiredModules


ForEach ($Module in $RequiredModules) {
    if ($Module.ModuleName -notin $Modules.ModuleName) {
        Write-LocalMessage -Message "We do not have the download information for $($Module.ModuleName), please raise an issue"
    }
}

ForEach ($Module in $Modules) {
    try {
        Update-Module $Module.ModuleName -Erroraction Stop
        Write-LocalMessage -Message "Updated $($Module.ModuleName) using the PowerShell Gallery"
        return
    }
    catch {
        Write-LocalMessage -Message "$($Module.ModuleName) was not installed by the PowerShell Gallery, continuing with web install."
    }
    
    $dbatools_copydllmode = $true
    $Impmodule = Import-Module -Name $Module.ModuleName -ErrorAction SilentlyContinue
    $localpath = $Impmodule.ModuleBase
    
    $temp = ([System.IO.Path]::GetTempPath()).TrimEnd("\")
    $zipfile = "$temp\$($Module.ModuleName).zip"
    Write-LocalMessage -Message "Downloading archive from github"
    try {
        (New-Object System.Net.WebClient).DownloadFile($Module.url, $zipfile)
    }
    catch {
        #try with default proxy and usersettings
        Write-LocalMessage -Message "Probably using a proxy for internet access, trying default proxy settings"
        $wc = (New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        $wc.DownloadFile($Module.url, $zipfile)
    }
    
    
    # Unblock if there's a block
    Unblock-File $zipfile -ErrorAction SilentlyContinue
    
    Write-LocalMessage -Message "Unzipping"
    
    # Keep it backwards compatible
    Remove-Item -ErrorAction SilentlyContinue "$temp\$($Module.ModuleName)-old" -Recurse -Force
    $null = New-Item "$temp\$($Module.ModuleName)-old" -ItemType Directory
    $shell = New-Object -ComObject Shell.Application
    $zipPackage = $shell.NameSpace($zipfile)
    $destinationFolder = $shell.NameSpace($temp)
    $destinationFolder.CopyHere($zipPackage.Items())
    
    
    $PSD = Get-ChildItem  "$temp\$($Module.ModuleName)-master\" -file -Filter "$($Module.ModuleName).psd1" -Recurse
    $ModuleDetails = Import-PowerShellDataFile -Path $PSD.fullname
    $ModuleVersion = $Moduledetails.ModuleVersion
    
    if ($null -eq $localpath) {
        $localpath = "$HOME\Documents\WindowsPowerShell\Modules\$($Module.ModuleName)\$ModuleVersion"
    }
    else {
        Write-LocalMessage -Message "Updating current install of $($Module.ModuleName)"
    }
    
    try {
        if (-not $path) {
            if ($PSCommandPath.Length -gt 0) {
                $path = Split-Path $PSCommandPath
                if ($path -match "github") {
                    Write-LocalMessage -Message "Looks like this installer is run from your GitHub Repo, defaulting to psmodulepath"
                    $path = $localpath
                }
            }
            else {
                $path = $localpath
            }
        }
    }
    catch {
        $path = $localpath
    }
    
    if (-not $path -or (Test-Path -Path "$path\.git")) {
        $path = $localpath
    }
    
    Write-LocalMessage -Message "Installing module $($Module.ModuleName) to $path"
    
    if (!(Test-Path -Path $path)) {
        try {
            Write-LocalMessage -Message "Creating directory: $path"
            New-Item -Path $path -ItemType Directory | Out-Null
        }
        catch {
            throw "Can't create $Path. You may need to Run as Administrator: $_"
        }
    }
    
    Write-LocalMessage -Message "Applying Update"
    Write-LocalMessage -Message "1) Backing up previous installation"
    Copy-Item -Path "$Path\*" -Destination "$temp\$($Module.ModuleName)-old" -ErrorAction Stop
    try {
        Write-LocalMessage -Message "2) Cleaning up installation directory"
        Remove-Item "$Path\*" -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-LocalMessage -Message @"
        Failed to clean up installation directory, rolling back update.
        This usually has one of two causes:
        - Insufficient privileges (need to run as admin)
        - A file is locked - generally a dll file from having the module imported in some process.

        Exception:
        $_
"@
        Copy-Item -Path "$temp\$($Module.ModuleName)-old\*" -Destination $path -ErrorAction Ignore -Recurse
        Remove-Item "$temp\$($Module.ModuleName)-old" -Recurse -Force
        return
    }
    Write-LocalMessage -Message "3) Setting up current version"
    Move-Item -Path "$temp\\$($Module.ModuleName)-master\*" -Destination $path -ErrorAction SilentlyContinue -Force
    Remove-Item -Path "$temp\\$($Module.ModuleName)-master" -Recurse -Force
    #Remove-Item "destinationFolder" -Recurse -Force
    Remove-Item -Path $zipfile -Recurse -Force
    Remove-Item "$temp\$($Module.ModuleName)-old" -Recurse -Force
    #Remove-Item -Path $zipfile -Recurse -Force
    
    Write-LocalMessage -Message "Module $($Module.ModuleName) now installed"
    if (Get-Module $Module.ModuleName) {
        Write-LocalMessage -Message @"

    Please restart PowerShell before working with $($Module.ModuleName).
"@
    }
    else {
        Write-LocalMessage -Message "Debug - Path = $path"
        $ImportPsd = Get-ChildItem  $path -file -Filter "$($Module.ModuleName).psd1" -Recurse
        
        Import-Module $ImportPSd -Force
        Write-LocalMessage @"

    $($Module.ModuleName) v $((Get-Module $Module.ModuleName).Version)
    # Commands available: $((Get-Command -Module $Module.ModuleName -CommandType Function | Measure-Object).Count)

"@
    }
    Remove-Variable path
    
}
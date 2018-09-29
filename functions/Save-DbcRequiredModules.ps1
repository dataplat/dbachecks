function Save-DbcRequiredModules {
    <#
        .SYNOPSIS
            Saves all required modules, including dbachecks, dbatools, Pester and PSFramework to a directory. Ideal for offline installs.
        
        .DESCRIPTION
            Saves all required modules, including dbachecks, dbatools, Pester and PSFramework to a directory. Ideal for offline installs.
    
        .PARAMETER Path
            The directory where the modules will be saved. Directory will be created if it does not exist.
    
        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
            
        .EXAMPLE
            Save-DbcRequiredModules -Path C:\temp\downlaods
        
            Saves all required modules and dbachecks to C:\temp\downloads
    #>
    
    [CmdletBinding()]
    param (
        [Parameter (Mandatory)]
        [string]$Path,
        [switch]$EnableException
    )
    
    if (-not (Test-Path $Path)) {
        try {
            $null = New-Item -ItemType Directory -Path $Path
        }
        catch {
            Stop-PSFFunction -Message "Failure" -ErrorRecord $_
        }
    }
    
    Write-PSFMessage -Level Output -Message "Note: PowerShell Gallery will say 'Installing dependent package' but it's really just saving them."
    Save-Module -Name dbachecks -Path $path -ErrorAction Stop
}
function Import-DbcConfig {
    <#
        .SYNOPSIS
            Imports the Config from a JSON file
        
        .DESCRIPTION
            Imports the Config from a JSON file
    
        .PARAMETER Path
            The path to import from, by default is "$script:localapp\config.json"
    
        .PARAMETER Temporary
            The settings are not persisted outside the current session.
            By default, settings will be remembered across all powershell sessions.
    
        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .PARAMETER Force
            Don't prompt for the SQL Authentication. This should be used in automated solutions where you set the app.sqlcredential 
            configuration setting in a different way. This WILL NOT set the SQL Auth configuration you will have to do it in a different way
            
        .EXAMPLE
            Import-DbcConfig
        
            Imports config from "$script:localapp\config.json"

        .EXAMPLE
            Import-DbcConfig -Path \\nas\projects\config.json
        
            Imports config from \\nas\projects\config.json
    #>
    [CmdletBinding()]
    param (
        [string]$Path = "$script:localapp\config.json",
        [switch]$Temporary,
        [switch]$Force,
        [switch]$EnableException
    )

    process {
        if (-not (Test-Path -Path $Path)) {
            Stop-PSFFunction -Message "$Path does not exist. Run Export-DbcConfig to create."
            return
        }
        
        try {
            $results = Get-Content -Path $Path | ConvertFrom-Json
        }
        catch {
            Stop-PSFFunction -Message "Failure" -Exception $_
            return
        }


        foreach ($result in $results) {
            if(($result.name -eq 'app.sqlcredential') -and ($null -ne $result.value) -and (-not $force))
            {
                Write-Warning "You need to re-enter the credential"
                Set-DbcConfig -Name app.sqlcredential -Value (Get-Credential -Message "You need to reenter the credential for app.sqlcredential") -Temporary:$Temporary
            }
            else{
                Set-DbcConfig -Name $result.Name -Value $result.Value -Temporary:$Temporary
            }
        }
    }
}
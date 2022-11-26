<#
.SYNOPSIS
    Exports dbachecks configs to a json file to make it easier to modify or be used for specific configurations.

.DESCRIPTION
    Exports dbachecks configs to a json file to make it easier to modify or be used for specific configurations.

.PARAMETER Path
    The path to export to, by default is "$script:localapp\config.json"

.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.PARAMETER Force
Overwrite Existing file

.EXAMPLE
    Export-DbcConfig

    Exports config to "$script:localapp\config.json"
.EXAMPLE
    Export-DbcConfig -Path \\nfs\projects\config.json

    Exports config to \\nfs\projects\config.json

.EXAMPLE
    $config = Export-DbcConfig | Invoke-Item

    Exports config to "$script:localapp\config.json" as and opens it in a default application.

.LINK
https://dbachecks.readthedocs.io/en/latest/functions/Export-DbcConfig/
#>
function Export-DbcConfig {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [string]$Path = "$script:localapp\config.json",
        [switch]$Force
    )

    Write-PSFMessage "Testing if $Path exists" -Level Verbose
    if (Test-Path -Path $file) {
        if (-not $Force) {
            Write-PSFMessage "Uh-Oh - File $Path exists - use the Force parameter to overwrite (even if your name is not Luke!)" -Level Significant
            Return ''
        }
        else {
            Write-PSFMessage "File $Path exists and will be overwritten " -Level Verbose
        }
    }
    try {
        Get-DbcConfig | Select-Object * | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Force -ErrorAction Stop
        # support for Invoke-Item
        Get-Item -Path $Path
        Write-PSFMessage -Message "Wrote file to $Path" -Level Verbose
    }
    catch {
        Stop-PSFFunction -Message $_ -Target $Path
    }
}

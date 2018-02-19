function Clear-DbcPowerBiDataSource {
    <#
        .SYNOPSIS
            Clears the data source directory created by Update-DbcPowerBiDataSource

        .DESCRIPTION
            Clears the data source directory created by Update-DbcPowerBiDataSource ("C:\windows\temp\dbachecks\*.json" by default). This command makes it easier to clean up data used by PowerBI via Start-DbcPowerBi.

        .PARAMETER Path
            The directory to your JSON files, which will be removed. "C:\windows\temp\dbachecks\*.json" by default

        .PARAMETER Environment
            Removes the JSON files for a specific environement
    
        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .EXAMPLE
            Clear-DbcPowerBiDataSource

            Removes "$env:windir\temp\dbachecks\*.json"

        .EXAMPLE
            Clear-DbcPowerBiDataSource -Environment Production

            Removes "$env:windir\temp\dbachecks\*Production*.json"
    #>
    [CmdletBinding()]
    param (
        [string]$Path = "$env:windir\temp\dbachecks",
        [string]$Enviornment,
        [switch]$EnableException
    )
    $null = Remove-Item "$Path\*$Enviornment*.json" -ErrorAction SilentlyContinue
}
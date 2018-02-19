function Get-DbcTagCollection {
    <#
        .SYNOPSIS
            Retrieves a list of all available tags. Simplistic, similar to Get-Verb.
    
        .DESCRIPTION
            Retrieves a list of all available tags. Simplistic, similar to Get-Verb.
            
        .PARAMETER Name
            Default: "*"
            
            The name of the tag to retrieve.
            May be any string, supports wildcards.

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
    
        .EXAMPLE
            Get-DbcTag
            
            Retrieves all of the available tags for -Tag and -ExcludeTag

        .EXAMPLE
            Get-DbcTag backups
            
            Retrieves all of the available tags for -Tag and -ExcludeTag that are -like backups
    #>
    [CmdletBinding()]
    param (
        [string]$Name = "*",
        [switch]$EnableException
    )
    
    process {
        $alltags = (Get-Content "$script:localapp\checks.json" | Out-String | ConvertFrom-Json) | Select-Object -ExpandProperty AllTags
        ($alltags -split ",").Trim() | Where-Object { $_ -like $name } | Sort-Object | Select-Object -Unique
    }
}

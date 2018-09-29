function Get-DbcConfig {
    <#
        .SYNOPSIS
            Retrieves configuration elements by name.
        
        .DESCRIPTION
            Retrieves configuration elements by name.
            
            Can be used to search the existing configuration list.
    
        .PARAMETER Name
            Default: "*"
            
            The name of the configuration element(s) to retrieve.
            May be any string, supports wildcards.
        
        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
            
        .EXAMPLE
            Get-DbcConfig Lists.SqlServers
            
            Retrieves the configuration element for the key "Lists.SqlServers"
    #>
    [CmdletBinding()]
    param (
        [string]$Name = "*",
        [switch]$EnableException
    )
    
    begin {
        $Module = "dbachecks"
    }
    process {
        $Name = $Name.ToLower()
        $results = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values | Where-Object { ($_.Name -like $Name) -and ($_.Module -like $Module) -and ((-not $_.Hidden) -or ($Force)) } | Sort-Object Module, Name
        $results | Select-Object Name, Value, Description
    }
}

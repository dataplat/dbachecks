function Get-DbcConfigValue {
    <#
        .SYNOPSIS
            Retrieves raw configuration values by name.
        
        .DESCRIPTION
            Retrieves raw configuration values by name.
            
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
            Get-DbcConfigValue app.sqlinstance
            
            Retrieves the raw value for the key "app.sqlinstance"
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
        Get-DbcConfig -Name $name | Select-Object -ExpandProperty Value
    }
}

function Convert-ConfigValueToBoolean {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string[]]$Value
    )
    process {
        @($Value).ForEach{
            switch -regex ($psitem.Trim()) {
                "^(true|yes|on|enable|enabled|1)$" { return $true }
                "^(false|no|off|disable|disabled|0)$" { return $false }
                default { throw "Value $psitem cannot be converted to boolean" }
            }
        }
    }
}
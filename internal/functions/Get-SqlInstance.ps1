function Get-Instance {
    if ($null -ne $sqlinstance) {
        return [array]$sqlinstance
    }
    
    $instances = Get-DbcConfigValue app.sqlinstance
    if ($instances.Length -eq 0) {
        Write-PSFMessage -Level Warning -Message "You must specify -SqlInstance or use Set-DbcConfig app.sqlinstance to setup a list of servers"
        return
    }
    else {
        [array]$instances
    }
}
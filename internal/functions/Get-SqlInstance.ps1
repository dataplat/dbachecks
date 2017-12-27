function Get-SqlInstance {
	if ($null -ne $sqlinstance) {
		return $sqlinstance
	}
	else {
		$instances = Get-DbcConfigValue app.sqlinstance
		if ($instances.Count -eq 0) {
			Write-PSFMessage -Level Warning -Message "You must specify -SqlInstance or use Set-DbcConfig app.sqlinstance to setup a list of servers"
		}
		else {
			$instances
		}
	}
}
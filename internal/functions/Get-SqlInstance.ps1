function Get-SqlInstance {
	if ($null -ne $sqlinstance) {
		return $sqlinstance
	}
	else {
		return (Get-DbcConfigValue Setup.SqlInstance)
	}
}
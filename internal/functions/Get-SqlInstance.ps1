function Get-SqlInstance {
	if ($sqlinstance) {
		return $sqlinstance
	}
	else {
		return (Get-DbcConfigValue Setup.SqlInstance)
	}
}
function Get-ComputerName {
	if ($null -ne $computername) {
		return $computername
	}
	else {
		return (Get-DbcConfigValue Setup.ComputerName)
	}
}
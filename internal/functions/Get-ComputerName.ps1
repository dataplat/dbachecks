function Get-ComputerName {
	if ($computername) {
		return $computername
	}
	else {
		return (Get-DbcConfigValue Setup.ComputerName)
	}
}
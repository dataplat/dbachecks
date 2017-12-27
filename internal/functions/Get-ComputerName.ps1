function Get-ComputerName {
	if ($null -ne $computername) {
		return $computername
	}
	else {
		$computers = Get-DbcConfigValue app.computername
		if ($computers.Count -eq 0) {
			Write-PSFMessage -Level Warning -Message "You must specify -ComputerName or use Set-DbcConfig app.computername to setup a list of servers"
		}
		else {
			$computers
		}
	}
}
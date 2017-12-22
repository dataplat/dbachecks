$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Active Directory Domain Name" -Tags DomainName, $filename {
	$domain = Get-DbcConfig -Name domain.name
	(Get-ComputerName).ForEach{
		It 'Should be on the Domain $domain' {
			(Get-DbaCmObject -Class Win32_ComputerSystem -ComputerName $psitem -Credential $credential).Domain | Should be $domain
		}
	}
}

# Skipping this for now until we get AdsiPS command equiv
Describe "Active Directory OU" -Tags OrganizationalUnit, $filename {
	$dc = Get-DbcConfig -Name domain.domaincontroller
	(Get-ComputerName).ForEach{
		if (-not $value) {
			# Can be passed by Invoke-DbcCheck -Value
			$value = Get-DbcConfig -Name domain.organizationalunit
		}
		It -Skip '$psitem should be in the right OU ($value)' {
			(Get-ADComputer $psitem -Properties CanonicalName -Server $dc).CanonicalName | Should be $value
		}
	}
}
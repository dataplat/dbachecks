$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "Active Directory Domain Name Check" -Tags ProperDomain, $filename {
	$domain = Get-DbcConfig -Name domain.name
	(Get-ComputerName).ForEach{
		It 'Should be on the Domain $domain' {
			(Get-DbaCmObject -Class Win32_ComputerSystem -ComputerName $psitem -Credential $credential).Domain | Should be $domain
		}
	}
}

# Skipping this for now until we get AdsiPS command equiv
Describe "Active Directory" -Tags OrganizationalUnit, $filename {
	$dc = Get-DbcConfig -Name domain.domaincontroller
	(Get-ComputerName).ForEach{
		It -Skip 'Server should be in the right OU' {
			if (-not $value) {
				$value = Get-DbcConfig -Name domain.organizationalunit
			}
			(Get-ADComputer $psitem -Properties CanonicalName -Server $dc).CanonicalName | Should be $value
		}
	}
}
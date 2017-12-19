$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing SPNs' -Tags SPN, $filename {
	(Get-ComputerName).ForEach{
		$results = Test-DbaSpn -ComputerName $psitem
		foreach ($result in $results) {
			It "$psitem should have SPN for $($result.RequiredSPN) for $($result.InstanceServiceAccount)" {
				$result.Error | Should Be 'None'
			}
		}
	}
}
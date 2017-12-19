$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$max = Get-DbcConfigValue policy.networklatencymsmax
Describe 'Testing network latency' -Tags Network, $filename {
	(Get-ComputerName).ForEach{
		$results = Get-DbaDiskSpace -ComputerName $psitem
		It "network latency for $psitem should be less than $max ms" {
			$results.Average -lt $max | Should be $true
		}
	}
}
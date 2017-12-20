$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$max = Get-DbcConfigValue policy.networklatencymsmax
Describe 'Testing network latency' -Tags Network, $filename {
	(Get-SqlInstance).ForEach{
		$results = Test-DbaNetworkLatency -sqlInstance $psitem
		It "network latency for $psitem should be less than $max ms" {
			$results.Average.TotalMilliseconds -lt $max | Should be $true
		}
	}
}
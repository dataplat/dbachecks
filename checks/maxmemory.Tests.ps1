$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing MaxMemory' -Tags Memory, $filename {
	(Get-SqlInstance).ForEach{
        $results = Get-DbaMaxMemory -SqlInstance $psitem
		foreach ($result in $results) {
			It "$psitem instance MaxMemory value $($result.SqlMaxMb) should be less than host total memory $($result.TotalMB)" {
				$result.SqlMaxMb | Should BeLessThan $result.TotalMB
			}
		}
	}
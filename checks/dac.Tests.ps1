$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$dac = Get-DbcConfigValue -Name policy.dacallowed
Describe 'Testing DAC' -Tags DAC, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing $psitem" {
			It "$psitem Should have DAC enabled $dac" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1  | Should Be $dac
            }
        }
    }
}
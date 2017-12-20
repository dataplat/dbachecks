$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$DAC = Get-DbcConfigValue -Name policy.DACAllowed
Describe 'Testing DAC' -Tags DAC, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing $_" {
            It "$psitem Should have DAC enabled $DAC" {
                (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue -eq 1  | Should Be $DAC
            }
        }
    }
}
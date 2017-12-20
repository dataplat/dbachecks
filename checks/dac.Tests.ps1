$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing DAC' -Tags DAC, $filename {
    (Get-SqlInstance).ForEach{
        It "$psitem Should have DAC enabled" {
            (Get-DbaSpConfigure -SqlInstance $psitem -ConfigName 'RemoteDACConnectionsEnabled').ConfiguredValue | Should Be 1
        }
    }
}
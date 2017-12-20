$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe "Testing Instance Connectionn" -Tag Instance, Connection {
    (Get-ComputerName).ForEach{
        Context "$_ Connection Tests" {
            BeforeAll {
                $Connection = Test-DbaConnection -SqlInstance $_ 
            }
            It "$_ Connects successfully" {
                $Connection.connectsuccess | Should BE $true
            }
            It "$_ AUth Scheme should be NTLM" {
                $connection.AuthScheme | Should Be "NTLM"
            }
            It "$_ Is pingable" {
                $Connection.IsPingable | Should be $True
            }
            It "$_ Is PSRemotebale" {
                $Connection.PSRemotingAccessible | Should Be $True
            }
        }
    }

}
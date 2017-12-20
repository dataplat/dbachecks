$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$skipremote = Get-DbcConfigValue skip.remotingcheck
$authscheme = Get-DbcConfigValue policy.authscheme

Describe "Testing Instance Connectionn" -Tag Instance, Connection {
    (Get-ComputerName).ForEach{
        Context "$psitem Connection Tests" {
            BeforeAll {
                $Connection = Test-DbaConnection -SqlInstance $psitem 
            }
            It "$psitem Connects successfully" {
                $Connection.connectsuccess | Should BE $true
            }
            It "$psitem Auth Scheme should be $authscheme" {
                $connection.AuthScheme | Should Be $authscheme
            }
            It "$psitem Is pingable" {
                $Connection.IsPingable | Should be $true
            }
            It -Skip:$skipremote "$psitem Is PSRemotebale" {
                $Connection.PSRemotingAccessible | Should Be $True
            }
        }
    }
}
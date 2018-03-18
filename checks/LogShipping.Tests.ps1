$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe "Log Shipping Status Primary" -Tags LogShippingPrimary, $filename {
    @(Get-Instance).ForEach{
        Context "Testing the primary databases on $psitem" {
            @(Test-DbaLogShippingStatus -SqlInstance $psitem -Primary).ForEach{
                It "Status Should Be OK for $($psitem.Database) on $($psitem.SqlInstance)" {
                    $psitem.Status | Should -Be "All OK" -Because 'The Log shipping should be ok'
                }
            }
        }
    }
}
Describe "Log Shipping Status Secondary" -Tags LogShippingSecondary, $filename {
    @(Get-Instance).ForEach{
        Context "Testing the secondary databases on $psitem" {
            @(Test-DbaLogShippingStatus -SqlInstance $psitem -Secondary).ForEach{
                It "Status Should Be OK for $($psitem.Database) on $($psitem.SqlInstance)" {
                    $psitem.Status | Should -Be "All OK"  -Because 'The Log shipping should be ok'
                }
            }
        }
    }
}

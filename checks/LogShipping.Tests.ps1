$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe "Log Shipping Status Primary" -Tags LogShippingPrimary, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing the primary databases on $psitem" {
			@(Test-DbaLogShippingStatus -SqlInstance $psitem -Primary).ForEach{
				It "Status should be OK for $($psitem.Database) on $($psitem.SqlInstance)" {
					$psitem.Status | Should Be "All OK"
				}
			}
		}
	}
}
Describe "Log Shipping Status Secondary" -Tags LogShippingSecondary, $filename {
	(Get-SqlInstance).ForEach{
		Context "Testing the secondary databases on $psitem" {
			@(Test-DbaLogShippingStatus -SqlInstance $psitem -Secondary).ForEach{
				It "Status should be OK for $($psitem.Database) on $($psitem.SqlInstance)" {
					$psitem.Status | Should Be "All OK"
				}
			}
		}
	}
}

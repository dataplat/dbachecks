$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")


Describe "Log Shipping State" -Tags Logshipping, $filename {
	(Get-SqlInstance).ForEach{

		Context "Testing the primary databases on $psitem" {
			@(Test-DbaLogShippingStatus -SqlInstance $psitem -Primary).ForEach{
				It "Status should be OK for $($psitem.Database) on $($psitem.SqlInstance)" {
					#$timeDifference = (Get-Date) - $psitem.TimeSinceLastBackup
					#$timeDifference.Minutes | Should BeLessThan $psitem.BackupThresshold
					$psitem.Status | Should Be "All OK"
				}
			}
		}

		Context "Testing the secondary databases on $psitem" {
			@(Test-DbaLogShippingStatus -SqlInstance $psitem -Secondary).ForEach{
				It "Status should be OK for $($psitem.Database) on $($psitem.SqlInstance)" {
					$psitem.Status | Should Be "All OK"
				}
				<# It "Time since last restore should be less than ($($psitem.RestoreThresshold))" {
					$timeDifference = (Get-Date) - $psitem.TimeSinceLastRestore
					$timeDifference.Minutes | Should BeLessThan $psitem.RestoreThresshold
				}

				It "Restore latency should be less than ($($psitem.RestoreThresshold))" {
					$psitem.LastRestoredLatency | Should BeLessThan $psitem.RestoreThresshold
				} #>
			}
		}

	} # end for each instance

} # end describe


$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "sp_whoisactive is Installed" -Tags WhoIsActiveInstalled, $filename {
	$db = Get-DbcConfigValue whoisactive.database
	(Get-SqlInstance).ForEach{
		Context "Testing WhoIsActive exists on $psitem" {
			It "WhoIsActive should exists on $db on $psitem" {
				(Get-DbaSqlModule -SqlInstance $psitem -Database $db -Type StoredProcedure | Where-Object name -eq "sp_WhoIsActive") | Should Not Be $Null
			}
		}
	}
}
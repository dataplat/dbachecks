$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
$maxdays = Get-DbcConfigValue policy.integritycheckmaxdays
$datapurity = Get-DbcConfigValue skip.datapuritycheck

Describe 'Testing last good DBCC CHECKDB' -Tags Database, Corruption, Integrity, DBCC, $filename {
    (Get-SqlInstance).ForEach{
        Context "Testing $_ " {
            $results = Get-DbaLastGoodCheckDb -SqlInstance $psitem
            foreach ($result in $results) {
                if ($result.Database -ne 'tempdb') {
                    It "last good integrity check for $($result.Database) on $psitem should be less than $maxdays" {
                        $result.LastGoodCheckDb | Should BeGreaterThan (Get-Date).AddDays( - ($maxdays))
                    }
				
                    It -Skip:$datapurity "last good integrity check for $($result.Database) on $psitem has Data Purity Enabled" {
                        $result.DataPurityEnabled | Should Be $true
                    }
                }
            }
        }
    }
}
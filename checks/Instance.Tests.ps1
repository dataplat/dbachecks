$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing TempDB Configuration' -Tag TempDB, Instance , $filename {
    (Get-SQLInstance).ForEach{
        Context "Testing $psitem" {
            $TempDbTests = Test-DBATempDbConfiguration -SqlServer $psitem
            It "$psitem should have TF118 enabled" -Skip:$($Config.TempDb.Skip118) {
                $TempDbTests[0].CurrentSetting | Should Be $TempDbTests[0].Recommended
            }
            It "$psitem should have $($TempDbTests[1].Recommended) TempDB Files" -Skip:(Get-DbcConfigValue -Name skip.TempDb118) {
                $TempDbTests[1].CurrentSetting | Should Be $TempDbTests[1].Recommended
            }
            It "$psitem should not have TempDB Files autogrowth set to percent" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileGrowthPercent) {
                $TempDbTests[2].CurrentSetting | Should Be $TempDbTests[2].Recommended
            }      
            It "$psitem should not have TempDB Files on the C Drive" -Skip:(Get-DbcConfigValue -Name skip.TempDbFilesonC) {
                $TempDbTests[3].CurrentSetting | Should Be $TempDbTests[3].Recommended
            }   
            It "$psitem should not have TempDB Files with MaxSize Set" -Skip:(Get-DbcConfigValue -Name skip.TempDbFileMaxSize) {
                $TempDbTests[4].CurrentSetting | Should Be $TempDbTests[4].Recommended
            }      
        }
    }
}
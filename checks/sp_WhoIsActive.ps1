$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

if (-not (Get-DbcConfigValue skip.sp_WhoIsActive)) {
    Describe "sp_WhoIsActive" -Tags sp_WhoIsActive, ServiceAccount, $filename {
        $spwhoisactivedatabase = Get-DbcConfigValue sp_WhoIsActive.database
        (Get-SqlInstance).ForEach{
            Context "Testing sp_WhoIsActive exists on $psitem" {
                It "sp_WhoIsActive should exists on $spwhoisactivedatabase" {
                    @(Get-DbaSqlModule -SqlInstance $psitem -Database $spwhoisactivedatabase -Type StoredProcedure | Where-Object name -eq "sp_WhoIsActive").Count -eq 1 | Should be $true
                }
            }
        }
    }
}
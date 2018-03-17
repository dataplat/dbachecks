$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. "$PSScriptRoot/../internal/functions/Get-FrkVersion.ps1"


Describe "First responder self checks" -Tags CheckFirstResponderKit, $filename {
    $frkdb = Get-DbcConfigValue policy.frk.database 
    @(Get-SqlInstance).ForEach{
        Context "Check if Frist Responder Kit is installed and up to date on $psitem" {
            It "Is first responder kit installed in [$frkdb]" {
                (Get-FrkVersion -SqlInstance $psitem).Count | Should -BeGreaterThan 0
            }
        }
    }
}

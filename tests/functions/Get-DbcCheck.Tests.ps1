$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Remove-Module dbachecks -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\..\constants.ps1"

Describe "$commandname Integration Tests" -Tags IntegrationTests, Integration {
    Context "Command executes properly and returns proper info" {
        (Get-DbcCheck).ForEach{
            It "$($psitem.Description) returns a unique tag" {
                $psitem.UniqueTag | Should Not Be $null
            }
            It "$($psitem.Description) should have a group" {
                $psitem.Group | Should Not Be $null
            }
        }
    }
}
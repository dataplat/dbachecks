<#

This function is intended for use in integration testing.
It ensures the test database exists and the test instnace.

#>
function Set-DatabaseForIntegrationTesting {
    param (
        [DbaInstanceParameter]$SqlInstance,
        [string]$DatabaseName
    )
    process {
        $db = Get-DbaDatabase -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Database $DatabaseName
        if ($db -eq $null) {
            $server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $sqlcredential
            $server.Query("create database $DatabaseName")
        }
    }
}

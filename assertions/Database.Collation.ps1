. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1 

function Get-SettingsForDatabaseCollactionCheck {
    $Wrongcollation = Get-DbcConfigValue policy.database.wrongcollation
    return @{
        WrongCollation = $Wrongcollation
        ExcludedDatabase = @("ReportingServer", "ReportingServerTempDB")+@($Wrongcollation)
    }
}

function Assert-DatabaseCollation {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$TestSettings,
        [string]$Because
    )
    process {
        if ($TestObject.Database -in $TestSettings.ExcludedDatabase) {
            # if it is one of the excluded databases than we expect the database collation not to match the server one
            $TestObject.DatabaseCollation | Should -Not -Be $TestObject.InstanceCollation -Because $Because 
        } else { 
            # otherwise it should match
            $TestObject.DatabaseCollation | Should -Be $TestObject.InstanceCollation -Because $Because 
        }
    }
}

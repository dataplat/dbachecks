BeforeDiscovery {
    . $PSScriptRoot/../internal/assertions/Database.Assertions.ps1
    [array]$ExcludedDatabases = Get-DbcConfigValue command.invokedbccheck.excludedatabases
    $ExcludedDatabases += $ExcludeDatabase
    [string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value

    $InstancesToTest = @(Get-Instance).ForEach{
        # just add it to the Not Contactable list
        if ($NotContactable -notcontains $psitem) {
            $Instance = $psitem
            try {
                $InstanceSMO = Connect-DbaInstance  -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
            } catch {
                $NotContactable += $Instance
            }
            if ($NotContactable -notcontains $psitem) {
                if ($null -eq $InstanceSMO.version) {
                    $NotContactable += $Instance
                } else {
                    $InstanceSMO
                }
            }
        }
    }
    Write-PSFMessage -Message "Instances = $InstancesToTest" -Level Significant
    Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable
}
Describe "Database Collation" -Tag DatabaseCollation, High, Database -ForEach $InstancesToTest {
    BeforeAll {
        $Wrongcollation = Get-DbcConfigValue policy.database.wrongcollation
        $exclude = "ReportingServer", "ReportingServerTempDB"
        $exclude += $Wrongcollation
        $exclude += $ExcludedDatabases

    }

    Context "Testing database collation on <_.Name>"  {
        @(Test-DbaDbCollation -SqlInstance $psitem -Database $Database -ExcludeDatabase $exclude).ForEach{
            It "Database $($psitem.Database) collation ($($psitem.DatabaseCollation)) should match server collation ($($psitem.ServerCollation)) on $($psitem.SqlInstance)" {
                $psitem.ServerCollation | Should -Be $psitem.DatabaseCollation -Because "You will get collation conflict errors in tempdb"
            }
        }
        if ($Wrongcollation) {
            @(Test-DbaDbCollation -SqlInstance $psitem -Database $Wrongcollation ).ForEach{
                It "Database $($psitem.Database) collation ($($psitem.DatabaseCollation)) should not match server collation ($($psitem.ServerCollation)) on $($psitem.SqlInstance)" {
                    $psitem.ServerCollation | Should -Not -Be $psitem.DatabaseCollation -Because "You have defined the database to have another collation then the server. You will get collation conflict errors in tempdb"
                }
            }
        }
    }
}

Describe "Suspect Page" -Tags SuspectPage, High , Database -ForEach $InstancesToTest {
    Context "Testing suspect pages on <_.Name>" {
        It "Database <_.Parent.Name> should return 0 suspect pages on <_.Name>" -Foreach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database }else { $ExcludedDatabases -notcontains $PsItem.Name } } {
            $results = Get-DbaSuspectPage -SqlInstance $psitem.Parent -Database $psitem.Name
            @($results).Count | Should -Be 0 -Because "You do not want suspect pages - $results"
        }
    }
}

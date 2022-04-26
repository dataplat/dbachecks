# So the v5 files need to be handled differently.
# Ww will start with a BeforeDiscovery which for the Database Checks will need to gather the Instances up front
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

# Each Test will have a -ForEach for the Instances and the InstancesToTest object will have a 
# lot of information gathered up front to reduce trips and connections to the database
Describe "Database Collation" -Tag DatabaseCollation, High, Database -ForEach $InstancesToTest {
    BeforeAll {
        $Wrongcollation = Get-DbcConfigValue policy.database.wrongcollation
        $exclude = "ReportingServer", "ReportingServerTempDB"
        $exclude += $Wrongcollation
        $exclude += $ExcludedDatabases

    }

    Context "Testing database collation on <_.Name>" {
        It "Database <_.Database> collation <_.DatabaseCollation> should match server collation <_.ServerCollation> on <_.SqlInstance>" -ForEach @(Test-DbaDbCollation -SqlInstance $psitem -Database $Database -ExcludeDatabase $exclude) {
            $psitem.ServerCollation | Should -Be $psitem.DatabaseCollation -Because "You will get collation conflict errors in tempdb"
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
        It "Database <_.Name> should return 0 suspect pages on <_.Parent.Name>" -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database }else { $ExcludedDatabases -notcontains $PsItem.Name } } {
            $results = Get-DbaSuspectPage -SqlInstance $psitem.Parent -Database $psitem.Name
            @($results).Count | Should -Be 0 -Because "You do not want suspect pages - $results"
        }
    }
}

Describe "Valid Database Owner" -Tags ValidDatabaseOwner, Medium, Database -ForEach $InstancesToTest {
    BeforeAll {
        [string[]]$targetowner = Get-DbcConfigValue policy.validdbowner.name
        $ExcludedDatabases += Get-DbcConfigValue policy.validdbowner.excludedb
    }
    Context "Testing Database Owners on <_.Name>" {
        #TODO fix the it text - needs commas --> should be in this list ( sqladmin sa ) )
        #It "Database <_.Name> - owner should be in this list ( $( [String]::Join(", ", $targetowner) ) ) on  <_.Parent.Name>" -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database }else { $ExcludedDatabases -notcontains $PsItem.Name } } {
        It "Database <_.Name> - owner '<_.Owner>' should be in this list ( <targetowner> ) ) on  <_.Parent.Name>" -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database }else { $ExcludedDatabases -notcontains $PsItem.Name } } {
            [string[]]$targetowner = Get-DbcConfigValue policy.validdbowner.name
            $psitem.Owner | Should -BeIn $targetowner -Because "The account that is the database owner is not what was expected"
        }
    }
}

# how to we get config data to use in its? like $TargetOwner



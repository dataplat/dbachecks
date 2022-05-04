# So the v5 files need to be handled differently.
# Ww will start with a BeforeDiscovery , $Filename which for the Database Checks will need to gather the Instances up front
BeforeDiscovery {
    <#
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
    #>

        # Gather the instances we know are not contactable
        [string[]]$NotContactable = (Get-PSFConfig -Module dbachecks -Name global.notcontactable).Value
        # Get all the tags in use in this run
        $Tags = Get-CheckInformation -Check $Check -Group Database -AllChecks $AllChecks -ExcludeCheck $ChecksToExclude


        $InstancesToTest = @(Get-Instance).ForEach{
            # just add it to the Not Contactable list
            if ($NotContactable -notcontains $psitem) {
                $Instance = $psitem
                try {
                    $InstanceSMO = Connect-DbaInstance  -SqlInstance $Instance -ErrorAction SilentlyContinue -ErrorVariable errorvar
                }
                catch {
                    $NotContactable += $Instance
                }
                if ($NotContactable -notcontains $psitem) {
                    if ($null -eq $InstanceSMO.version) {
                        $NotContactable += $Instance
                    }
                    else {
                        # Get the relevant information for the checks in one go to save repeated trips to the instance and set values for Not Contactable tests if required
                        Get-AllDatabaseInfo -Instance $InstanceSMO -Tags $Tags
                    }
                }
            }
        }
        Write-PSFMessage -Message "Instances = $($InstancesToTest.Name)" -Level Significant
        Set-PSFConfig -Module dbachecks -Name global.notcontactable -Value $NotContactable
}

# Each Test will have a -ForEach for the Instances and the InstancesToTest object will have a 
# lot of information gathered up front to reduce trips and connections to the database
<#


Describe "Suspect Page" -Tags SuspectPage, High , Database -ForEach $InstancesToTest {
    Context "Testing suspect pages on <_.Name>" {
        It "Database <_.Name> should return 0 suspect pages on <_.Parent.Name>" -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database }else { $ExcludedDatabases -notcontains $PsItem.Name } } {

            $results = Get-DbaSuspectPage -SqlInstance $psitem.Parent -Database $psitem.Name
            @($results).Count | Should -Be 0 -Because "You do not want suspect pages - $results"
        }
    }
}

#>

Describe "Database Collation" -Tag DatabaseCollation, High, Database -ForEach $InstancesToTest {
        # TODO: just add reporting servers into config? rather than here?
        #$exclude = "ReportingServer", "ReportingServerTempDB"

    Context "Testing database collation on <_.Name>" {
        $skip = Get-DbcConfigValue skip.database.databasecollation
        It "Database <_.Name> collation <_.Collation> should match server collation <_.ServerCollation> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.wrongcollation -notcontains $PsItem.Name } } {
            $psitem.ServerCollation | Should -Be $psitem.Collation -Because "You will get collation conflict errors in tempdb"
        }

        # wrong collation set
        It "Database <_.Name> collation <_.Collation> should not match server collation <_.ServerCollation> on <_.SqlInstance>" -ForEach $psitem.Databases.Where{ $_.Name -in $psitem.ConfigValues.wrongcollation } {
            $psitem.ServerCollation | Should -Not -Be $psitem.Collation -Because "You have defined the database to have another collation then the server. You will get collation conflict errors in tempdb"
        }

    }
}


Describe "Valid Database Owner" -Tag ValidDatabaseOwner, Medium, Database -ForEach $InstancesToTest {
    $skip = Get-DbcConfigValue skip.database.validdatabaseowner
    Context "Testing Database Owners on <_.Name>" {
        #TODO fix the it text - needs commas --> should be in this list ( sqladmin sa ) )
            It "Database <_.Name> - owner '<_.Owner>' should be in this list ( <_.ConfigValues.validdbownername> ) ) on  <_.Parent.Name>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database }else { $psitem.ConfigValues.validdbownerexclude -notcontains $PsItem.Name } } {
            $psitem.Owner | Should -BeIn $psitem.ConfigValues.validdbownername -Because "The account that is the database owner is not what was expected"
        }
    }
}


#and can evey check have a skip policy.GROUP.UNIQUETAG - if it doesnt have one already and that will live on the line below the describe




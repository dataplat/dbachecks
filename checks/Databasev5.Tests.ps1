# So the v5 files need to be handled differently.
# Ww will start with a BeforeDiscovery , $Filename which for the Database Checks will need to gather the Instances up front
BeforeDiscovery {

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

- copy in test
- add skip  after describe
    $skip = Get-DbcConfigValue skip.database.databasecollation
    add to IT -Skip:$skip
#>



Describe "Suspect Page" -Tag SuspectPage, High , Database -ForEach $InstancesToTest {
    $skip = Get-DbcConfigValue skip.database.suspectpage
    Context "Testing suspect pages on <_.Name>" {
        It "Database <_.Name> should return 0 suspect pages on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.suspectpageexclude -notcontains $PsItem.Name } } {
            $psitem.SuspectPage | Should -Be 0 -Because "You do not want any suspect pages"
        }
    }
}

Describe "Database Collation" -Tag DatabaseCollation, High, Database -ForEach $InstancesToTest {
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
            It "Database <_.Name> - owner '<_.Owner>' should be in this list ( <_.ConfigValues.validdbownername> ) ) on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.validdbownerexclude -notcontains $PsItem.Name } } {
            $psitem.Owner | Should -BeIn $psitem.ConfigValues.validdbownername -Because "The account that is the database owner is not what was expected"
        }
    }
}


Describe "Invalid Database Owner" -Tag InvalidDatabaseOwner, Medium, Database -ForEach $InstancesToTest {
    $skip = Get-DbcConfigValue skip.database.invaliddatabaseowner
    Context "Testing Database Owners on <_.Name>" {

        It "Database <_.Name> - owner '<_.Owner>' should not be in this list ( <_.ConfigValues.invaliddbownername> ) ) on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.invaliddbownerexclude -notcontains $PsItem.Name } } {
            $psitem.Owner | Should -Not -BeIn $psitem.ConfigValues.invaliddbownername -Because "The database owner was one specified as incorrect"
        }
    }
}

Describe "AsymmetricKeySize" -Tag AsymmetricKeySize, CIS, Database -ForEach $InstancesToTest {
    $skip = Get-DbcConfigValue skip.security.asymmetrickeysize
    Context "Testing Asymmetric Key Size is 2048 or higher on <_.Name>" {
        It "Database <_.Name> asymmetric key size should be at least 2048 on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.asymmetrickeysizeexclude -notcontains $PsItem.Name } } {
            $psitem.AsymmetricKeySize | Should -Be 0 -Because "Asymmetric keys should have a key length greater than or equal to 2048"
            #$psitem.AsymmetricKeySize | Should -BeGreaterOrEqual 2048 -Because "Asymmetric keys should have a key length greater than or equal to 2048"
        }
    }
}



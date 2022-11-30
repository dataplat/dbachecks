    $filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
# So the v5 files need to be handled differently.
# We will start with a BeforeDiscovery which for the Database Checks will need to gather the Instances up front
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

        # Get-DbcConfig is expensive so we call it once
        $__dbcconfig = Get-DbcConfig
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
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.suspectpage' }).Value
    Context "Testing suspect pages on <_.Name>" {
        It "Database <_.Name> should return 0 suspect pages on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.suspectpageexclude -notcontains $PsItem.Name } } {
            $psitem.SuspectPage | Should -Be 0 -Because "You do not want any suspect pages"
        }
    }
}

Describe "Database Collation" -Tag DatabaseCollation, High, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.databasecollation' }).Value
    Context "Testing database collation on <_.Name>" {
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
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.validdatabaseowner' }).Value

    Context "Testing Database Owners on <_.Name>" {
        #TODO fix the it text - needs commas --> should be in this list ( sqladmin sa ) )
            It "Database <_.Name> - owner '<_.Owner>' should be in this list ( <_.ConfigValues.validdbownername> ) ) on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.validdbownerexclude -notcontains $PsItem.Name } } {
            $psitem.Owner | Should -BeIn $psitem.ConfigValues.validdbownername -Because "The account that is the database owner is not what was expected"
        }
    }
}


Describe "Invalid Database Owner" -Tag InvalidDatabaseOwner, Medium, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.invaliddatabaseowner' }).Value
    Context "Testing Database Owners on <_.Name>" {

        It "Database <_.Name> - owner '<_.Owner>' should not be in this list ( <_.ConfigValues.invaliddbownername> ) ) on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.invaliddbownerexclude -notcontains $PsItem.Name } } {
            $psitem.Owner | Should -Not -BeIn $psitem.ConfigValues.invaliddbownername -Because "The database owner was one specified as incorrect"
        }
    }
}

Describe "AsymmetricKeySize" -Tag AsymmetricKeySize, CIS, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.security.asymmetrickeysize' }).Value
    Context "Testing Asymmetric Key Size is 2048 or higher on <_.Name>" {
        It "Database <_.Name> asymmetric key size should be at least 2048 on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.asymmetrickeysizeexclude -notcontains $PsItem.Name } } {
            $psitem.AsymmetricKeySize | Should -Be 0 -Because "Asymmetric keys should have a key length greater than or equal to 2048"
            #$psitem.AsymmetricKeySize | Should -BeGreaterOrEqual 2048 -Because "Asymmetric keys should have a key length greater than or equal to 2048"
        }
    }
}

Describe "Auto Close" -Tag AutoClose, High, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.autoclose' }).Value
    Context "Testing Auto Close on <_.Name>" {
        It "Database <_.Name> should have Auto Close set to <_.ConfigValues.autoclose> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.autocloseexclude -notcontains $PsItem.Name } } {
            $psitem.AutoClose | Should -Be $psitem.ConfigValues.autoclose -Because "Because!"
        }
    }
}

Describe "Auto Shrink" -Tag AutoShrink, High, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.autoshrink' }).Value
    Context "Testing Auto Shrink on <_.Name>" {
        It "Database <_.Name> should have Auto Shrink set to <_.ConfigValues.autoshrink> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.autoshrinkexclude -notcontains $PsItem.Name } } {
            $psitem.AutoShrink | Should -Be $psitem.ConfigValues.autoshrink -Because "Shrinking databases causes fragmentation and performance issues"
        }
    }
}

Describe "Virtual Log Files" -Tag VirtualLogFile, Medium, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.vlf' }).Value
    Context "Testing Database VLFs on <_.Name>" {
        It "Database <_.Name> VLF count should be less than <_.ConfigValues.maxvlf> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.vlfexclude -notcontains $PsItem.Name } } {
            $psitem.VLF | Should -BeLessThan $psitem.ConfigValues.maxvlf -Because "Too many VLFs can impact performance and slow down backup/restore"
        }
    }
}

Describe "Log File Count Checks" -Tag LogfileCount, Medium, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.logfilecounttest' }).Value
    Context "Testing Log File count for <_.Name>" {
        It "Database <_.Name> should have <_.ConfigValues.logfilecount> or less log files on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.logfilecountexclude -notcontains $PsItem.Name } } {
            $psitem.LogFileCount | Should -BeLessOrEqual $psitem.ConfigValues.logfilecount -Because "You want the correct number of log files"
        }
    }
}

Describe "Auto Create Statistics" -Tag AutoCreateStatistics, Low, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.autocreatestatistics' }).Value
    Context "Testing Auto Create Statistics for <_.Name>" {
        It "Database <_.Name> should have Auto Create Statistics set to <_.ConfigValues.autocreatestats> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.autocreatestatsexclude -notcontains $PsItem.Name } } {
            $psitem.AutoCreateStatistics | Should -Be $psitem.ConfigValues.autocreatestats -Because "This value is expected for autocreate statistics"
        }
    }
}

Describe "Auto Update Statistics" -Tag AutoUpdateStatistics, Low, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.autoupdatestatistics' }).Value
    Context "Testing Auto Update Statistics on <_.Name>" {
        It "Database <_.Name> should have Auto Update Statistics set to <_.ConfigValues.autoupdatestats> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.autoupdatestatsexclude -notcontains $PsItem.Name } } {
            $psitem.AutoUpdateStatistics | Should -Be $psitem.ConfigValues.autoupdatestats  -Because "This value is expected for autoupdate statistics"
        }
    }
}

Describe "Auto Update Statistics Asynchronously" -Tag AutoUpdateStatisticsAsynchronously, Low, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.autoupdatestatisticsasynchronously' }).Value
    Context "Testing Auto Update Statistics Asynchronously on <_.Name>" {
        It "Database <_.Name> should have Auto Update Statistics Asynchronously set to <_.ConfigValues.autoupdatestatsasync> on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.autoupdatestatsasyncexclude -notcontains $PsItem.Name } } {
            $psitem.AutoUpdateStatisticsAsync | Should -Be $psitem.ConfigValues.autoupdatestatsasync  -Because "This value is expected for autoupdate statistics asynchronously"
        }
    }
}

Describe "Trustworthy Option" -Tag Trustworthy, DISA, Varied, CIS, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.trustworthy' }).Value
    Context "Testing database trustworthy option on <_.Name>" {
        It "Database <_.Name> should have Trustworthy set to false on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.trustworthyexclude -notcontains $PsItem.Name } } {
            $psitem.Trustworthy | Should -BeFalse -Because "Trustworthy has security implications and may expose your SQL Server to additional risk"
        }
    }
}

Describe "Database Status" -Tag DatabaseStatus, High, Database -ForEach $InstancesToTest {
    $skip = ($__dbcconfig | Where-Object {$_.Name -eq 'skip.database.status' }).Value
    Context "Database status is correct on <_.Name>" {
        It "Database <_.Name> has the expected status on <_.SqlInstance>" -Skip:$skip -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.statusexclude -notcontains $PsItem.Name } } {
            $psitem.Where{$_.Name -notin $psitem.ConfigValues.excludereadonly -and $psitem.IsDatabaseSnapshot -eq $false}.Readonly | Should -Not -Contain True -Because "We expect that there will be no Read-Only databases except for those specified"
            $psitem.Where{$_.Name -notin $psitem.ConfigValues.excludeoffline}.Status | Should -Not -Match 'Offline' -Because "We expect that there will be no offline databases except for those specified"
            $psitem.Where{$_.Name -notin $psitem.ConfigValues.excluderestoring}.Status | Should -Not -Match 'Restoring' -Because "We expect that there will be no databases in a restoring state except for those specified"
            $psitem.Where{$_.Name -notin $psitem.ConfigValues.excludeoffline}.Status | Should -Not -Match 'AutoClosed' -Because "We expect that there will be no databases that have been auto closed"
            $psitem.Status | Should -Not -Match 'Recover' -Because "We expect that there will be no databases going through the recovery process or in a recovery pending state"
            $psitem.Status | Should -Not -Match 'Emergency' -Because "We expect that there will be no databases in EmergencyMode"
            $psitem.Status | Should -Not -Match 'Standby' -Because "We expect that there will be no databases in Standby"
            $psitem.Status | Should -Not -Match 'Suspect' -Because "We expect that there will be no databases in a Suspect state"
        }
    }
}

Describe "Compatibality Level" -Tag CompatibilityLevel, High, Database -ForEach $InstancesToTest {
    $Skip = ($__dbcconfig | Where-Object Name -eq 'skip.database.compatabilitylevel').Value 
    Context "Compatibility level matches server compatability level" {
        It "Database <_.Name> has the expected compatibility level on <_.SqlInstance>" -ForEach $psitem.Databases.Where{ if ($Database) { $_.Name -in $Database } else { $psitem.ConfigValues.statusexclude -notcontains $psitem.Name } } { 
            $DBCompat = $psitem.CompatibilityLevel
            $SrvCompat = $psitem.ServerLevel
            $DBCompat | Should -Be $SrvCompat -Because "it means you are on the appropriate compatibility level for your SQL Server version to use all available features."
        }
    }
}

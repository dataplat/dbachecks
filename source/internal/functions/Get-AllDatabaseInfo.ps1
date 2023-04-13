function Get-AllDatabaseInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags)

    #clear out the default initialised fields
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Information], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $false)
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $false)

    # set the default init fields for all the tags

    # Server Initial fields
    $ServerInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server])
    $ServerInitFields.Add("VersionMajor") | Out-Null # so we can check versions
    $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $ServerInitFields)

    # Database Initial Fields
    $DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database])

    # Stored Procedure Initial Fields
    $StoredProcedureInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure])

    # Information Initial Fields

    # Settings Initial Fields
    $SettingsInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings])

    # Login Initial Fields
    $LoginInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login])

    # Log File Initial Fields
    $LogFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile])

    # Data File Initial Fields
    $DataFileInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile])

    # Configuration cannot have default init fields :-)
    $configurations = $false

    # Set up blank ConfigValues object for any config we need to use in the checks
    $ConfigValues = [PSCustomObject]@{}

    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {

        'AsymmetricKeySize' {
            $asymmetrickey = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'asymmetrickeysizeexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.asymmetrickeysize.excludedb').Value
        }

        'AutoClose' {
            $autoclose = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoclose' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.autoclose').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autocloseexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.autoclose.excludedb').Value
        }

        'AutoShrink' {
            $autoshrink = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoshrink' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.autoshrink').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoshrinkexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.autoshrinke.excludedb').Value
        }

        'ValidDatabaseOwner' {
            $owner = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validdbownername' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.validdbowner.name').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validdbownerexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.validdbowner.excludedb').Value
        }

        'InvalidDatabaseOwner' {
            $owner = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'invaliddbownername' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.invaliddbowner.name').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'invaliddbownerexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.invaliddbowner.excludedb').Value
        }

        'DatabaseCollation' {
            $collation = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'wrongcollation' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.wrongcollation').Value
        }

        'SuspectPage' {
            $suspectPage = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'suspectpageexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.suspectpage.excludedb').Value
        }
        'VirtualLogFile' {
            $vlf = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'maxvlf' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.maxvlf').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'vlfexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.vlf.excludedb').Value
        }
        'LogFileCount' {
            $logfilecount = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'logfilecount' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.logfilecount').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'logfilecountexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.logfilecount.excludedb').Value
        }
        'AutoCreateStatistics' {
            $autocreatestats = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autocreatestats' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.autocreatestatistics').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autocreatestatsexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.autocreatestats.excludedb').Value
        }
        'AutoUpdateStatistics' {
            $autoupdatestats = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestats' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.autoupdatestatistics').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestatsexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.autoupdatestats.excludedb').Value
        }
        'AutoUpdateStatisticsAsynchronously' {
            $autoupdatestatsasync = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestatsasync' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.autoupdatestatisticsasynchronously').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'autoupdatestatsasyncexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.autoupdatestatisticsasynchronously.excludedb').Value
        }
        'Trustworthy' {
            $trustworthy = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'trustworthyexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.trustworthyexcludedb').Value
        }
        'DatabaseStatus' {
            $status = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'excludereadonly' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.status.excludereadonly').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'excludeoffline' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.status.excludeoffline').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'excluderestoring' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.status.excluderestoring').Value
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'statusexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'policy.database.statusexcludedb').Value
        }
        'QueryStoreEnabled' {
            $qs = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'qsenabledexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'database.querystoreenabled.excludedb').Value
        }
        'QueryStoreDisabled' {
            $qs = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'qsdisabledexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'database.querystoredisabled.excludedb').Value
        }
        'CompatibilityLevel' {
            $compatibilityLevel = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'compatexclude' -Value ($__dbcconfig | Where-Object Name -EQ 'database.compatibilitylevel.excludedb').Value
        }
        Default { }
    }

    #build the object
    $testInstanceObject = [PSCustomObject]@{
        ComputerName = $Instance.ComputerName
        InstanceName = $Instance.DbaInstanceName
        Name         = $Instance.Name
        ConfigValues = $ConfigValues # can we move this out to here?
        Databases    = $Instance.Databases.Foreach{
            [PSCustomObject]@{
                Name                      = $psitem.Name
                SqlInstance               = $Instance.Name
                Owner                     = @(if ($owner) { $psitem.owner })
                ServerCollation           = @(if ($collation) { $Instance.collation })
                Collation                 = @(if ($collation) { $psitem.collation })
                SuspectPage               = @(if ($suspectPage) { (Get-DbaSuspectPage -SqlInstance $Instance -Database $psitem.Name | Measure-Object).Count })
                ConfigValues              = $ConfigValues # can we move this out?
                AsymmetricKeySize         = @(if ($asymmetrickey) { ($psitem.AsymmetricKeys | Where-Object { $_.KeyLength -lt 2048 } | Measure-Object).Count })
                #AsymmetricKeySize          = if ($asymmetrickey) { $psitem.AsymmetricKeys.KeyLength }  # doing this I got $null if there wasn't a key so counting ones that are too short
                AutoClose                 = @(if ($autoclose) { $psitem.AutoClose })
                AutoCreateStatistics      = @(if ($autocreatestats) { $psitem.AutoCreateStatisticsEnabled })
                AutoUpdateStatistics      = @(if ($autoupdatestats) { $psitem.AutoUpdateStatisticsEnabled })
                AutoUpdateStatisticsAsync = @(if ($autoupdatestatsasync) { $psitem.AutoUpdateStatisticsAsync })
                AutoShrink                = @(if ($autoshrink) { $psitem.AutoShrink })
                VLF                       = @(if ($vlf) { ($psitem.Query("DBCC LOGINFO") | Measure-Object).Count })
                LogFileCount              = @(if ($logfilecount) { ($psitem.LogFiles | Measure-Object).Count })
                Trustworthy               = @(if ($trustworthy) { $psitem.Trustworthy })
                Status                    = @(if ($status) { $psitem.Status })
                IsDatabaseSnapshot        = @(if ($status) { $psitem.IsDatabaseSnapshot }) # needed for status test
                Readonly                  = @(if ($status) { $psitem.Readonly }) # needed for status test
                QueryStore                = @(if ($qs) { $psitem.QueryStoreOptions.ActualState })
                CompatibilityLevel        = @(if ($compatibilitylevel) { $psitem.CompatibilityLevel })
                ServerLevel               = @(if ($compatibilitylevel) { [Enum]::GetNames('Microsoft.SqlServer.Management.Smo.CompatibilityLevel').Where{ $psitem -match $Instance.VersionMajor } })
            }
        }
    }
    return $testInstanceObject
}

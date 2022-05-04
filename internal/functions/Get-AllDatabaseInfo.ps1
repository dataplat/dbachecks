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

        'ValidDatabaseOwner' {
            $owner = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validdbownername' -Value (Get-DbcConfigValue policy.validdbowner.name)
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'validdbownerexclude' -Value (Get-DbcConfigValue policy.validdbowner.excludedb)
        }

        'DatabaseCollation' {
            $collation = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'wrongcollation' -Value (Get-DbcConfigValue policy.database.wrongcollation)
        }

        'SuspectPage' {
            $suspectPage = $true
            $ConfigValues | Add-Member -MemberType NoteProperty -Name 'suspectpageexclude' -Value (Get-DbcConfigValue policy.suspectpage.excludedb)
        }

        Default { }
    }

    #build the object
    $testInstanceObject = [PSCustomObject]@{
        ComputerName     = $Instance.ComputerName
        InstanceName     = $Instance.DbaInstanceName
        Name             = $Instance.Name
        ConfigValues    = $ConfigValues # can we move this out?
        Databases        = $Instance.Databases.Foreach{
            [PSCustomObject]@{
                Name            = $psitem.Name
                SqlInstance     = $Instance.Name
                Owner           = if ($owner) { $psitem.owner }
                ServerCollation = if ($collation) { $Instance.collation }
                Collation       = if ($collation) { $psitem.collation }
                SuspectPage     = if ($suspectPage) { (Get-DbaSuspectPage -SqlInstance $Instance -Database $psitem.Name | Measure-Object).Count }
                ConfigValues    = $ConfigValues # can we move this out?
            }
        }
    }
    return $testInstanceObject
}


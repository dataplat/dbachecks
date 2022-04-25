function NewGet-AllInstanceInfo {
    # Using the unique tags gather the information required
    Param($Instance, $Tags)
    
    #clear out the default initialised fields
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
    $smo.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
    
    # COnfiguration cannot have default init fields :-)
    $configurations = $false

    # Using there so that if the instance is not contactable, no point carrying on with gathering more information
    switch ($tags) {

        'DefaultTrace' {
            $configurations = $true
        }
        'OleAutomationProceduresDisabled' {
            $configurations = $true
        }
        'CrossDBOwnershipChaining' {
            $configurations = $true
        }
        'ScanForStartupProceduresDisabled' {
            $configurations = $true
        }
        'RemoteAccessDisabled' {
            $configurations = $true
        }
        'SQLMailXPsDisabled' {
            $configurations = $true
        }

        Default { }
    }

    # set the default init fields for all the tags
    
    #build the object

    $testInstanceObject = [PSCustomObject]@{
        ComputerName  = $smo.ComputerName
        InstanceName  = $smo.DbaInstanceName
        Configuration = if ($configurations) { $Smo.Configuration }else { $null }
    }
    return $testInstanceObject
}
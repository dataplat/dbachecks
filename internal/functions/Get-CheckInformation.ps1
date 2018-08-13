# Returns all of the tags that have been specified in the checks file for this run of the Invoke-DbcCheck
function Get-CheckInformation {
    Param($Group, $Check, $AllChecks ,$ExcludeCheck)
    ## need to reset the variable here
    $script:localapp = Get-DbcConfigValue -Name app.localapp
    $GroupChecksConfig = (Get-DbcCheck).Where{$_.Group -eq $Group}
    # Nothing if we exclude the group
    if ($ExcludeCheck -contains $Group) {Return}
    # Create an array of tags for the group except the Group Name
    $GroupChecks = @()
    @($GroupChecksConfig.AllTags).foreach{
        @($psitem.Split(',')).ForEach{
            $checkitem = $_.Trim()
            if ($checkitem -eq $Group) {}
            elseif ($ExcludeCheck -match $Checkitem) {}
            else {
                $GroupChecks += $checkitem
            }
        }
    }
    $CheckInfo = @()
    if(($Check -eq $Group) -or ($Check -contains $Group) -or ($AllChecks)){
        $CheckInfo = $GroupChecks
    }
    else{
        @($Check).ForEach{
            if($GroupChecks -contains $psitem){
                $CheckInfo += $psitem
            }
        }
    }
    Return $CheckInfo 
}

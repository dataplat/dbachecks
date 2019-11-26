# Returns all of the tags that have been specified in the checks file for this run of the Invoke-DbcCheck
function Get-CheckInformation {
    Param($Group, $Check, $AllChecks ,$ExcludeCheck)
    ## need to reset the variable here
    $script:localapp = Get-DbcConfigValue -Name app.localapp
    $GroupChecksConfig = (Get-DbcCheck).Where{$_.Group -eq $Group}
    # Nothing if we exclude the group
    if ($ExcludeCheck -contains $Group) {Return}
    # Create an array of tags for the group except the Group Name
    #It's a bit clubnky but it works
    # This will create a list of all the tags for the group that has been specified ( so the instance checks or the database checks for example)
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
    # Now we have a list of tags if we have a group. We need to have a list of tags for all the possible checks passed in

    #BUT

    # If we have called Invoke-DbcCheck without using the Check parameter (IE using the config) we have nothing in Check

    # So Lets fix that!

    if($null -eq $Check){
        $Check = $GroupChecks
    }

    ## OK - Now we can return all of the tags for all fo the checks whether they are specified individually, by group, in the Check parameter or not specified and included by the config as either a group or an individual tag (Which is what I want!)
    
    $CheckInfo = @()
    if(($Check -eq $Group) -or ($Check -contains $Group) -or ($AllChecks)){
        $CheckInfo = $GroupChecks
    }
    else{
        @($Check).ForEach{
            if($GroupChecks -contains $psitem){
    ## BUT - This falls flat when you use a tag for a number of Checks that is not a group (like CIS) in that case all you get in $CheckInfo is CIS and not the relevant unique tags
                (Get-DbcCheck $psitem).ForEach{
                    $CheckInfo += $psitem.UniqueTag
                } 
            }
        }
    }
    Return $CheckInfo 
}

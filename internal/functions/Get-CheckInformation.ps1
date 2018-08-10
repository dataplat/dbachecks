function Get-CheckInformation {
    Param($Group)
    $script:localapp = Get-DbcConfigValue -Name app.localapp
    $GroupChecksConfig = (Get-DbcCheck).Where{$_.Group -eq $Group}
    if ($ExcludeCheck -contains $Group) {Return}
        $GroupChecks = @()
        @($GroupChecksConfig.AllTags).foreach{
            @($psitem.Split(',')).ForEach{
                $checkarray = $_.Trim()
                if ($checkarray -eq $Group) {}
                elseif ($ExcludeCheck -match $Checkarray) {}
                else {
                    $GroupChecks += $checkarray
                }
            }
        }
}

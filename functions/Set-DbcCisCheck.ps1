<#
.SYNOPSIS
Resets values to defaults then sets values for CIS test.

.DESCRIPTION
Resets to default values then sets all CIS checks to defaults values that were different than normals values.  Then sets CIS 
test that are set to skip by default to run.

.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.EXAMPLE
Set-DbcCisConfig

.LINK

#>

function Set-DbcCisConfig {
    [CmdletBinding(SupportsShouldProcess)]
    Param ()
    #Reset all configs to defaults
    Reset-DbcConfig

    #set CIS configs that differ from the defaults
    if ($PSCmdlet.ShouldProcess("$name" , "Setting the value to $NewValue on ")) {
        # Two CIS tests that have different values from the default test originally written
        Set-PSFConfig -Module dbachecks -Name policy.security.databasemailenabled -Value $false
        Set-PSFConfig -Module dbachecks -Name policy.security.clrenabled -Value $false

        # CIS Test set to skip by default
        Set-PSFConfig -Module dbachecks -Name skip.security.sadisabled -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.saexist -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.containedbautoclose -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.sqlagentproxiesnopublicrole -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.symmetrickeyencryptionlevel -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.asymmetrickeysize -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.hideinstance -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.clrassembliessafe -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.engineserviceadmin -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.agentserviceadmin -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.fulltextserviceadmin -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.loginauditlevelfailed -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.loginauditlevelsuccessful -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.localwindowsgroup -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.publicrolepermission -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.builtinadmin -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.guestuserconnect -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.ContainedDBSQLAuth -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.LoginCheckPolicy -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.LoginPasswordExpiration -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.LoginMustChange -Value $false
        Set-PSFConfig -Module dbachecks -Name skip.security.nonstandardport -Value $false
    }
}
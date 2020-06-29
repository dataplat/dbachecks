<#
.SYNOPSIS
Sets values for CIS tests.

.DESCRIPTION
Sets CIS checks to defaults values that were different than normals values.  Then sets CIS
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
    [CmdletBinding(DefaultParameterSetName = "FullName", SupportsShouldProcess)]
    Param ()

    #set CIS to what they need to be
    if ($PSCmdlet.ShouldProcess("$name" , "Setting the value to $NewValue on ")) {
        Set-DbcConfig -Name skip.security.nonstandardport -Value $false
        Set-DbcConfig -Name policy.dacallowed -Value $false
        Set-DbcConfig -Name policy.errorlog.logcount -Value 12
        Set-DbcConfig -Name policy.security.oleautomationproceduresdisabled -Value $false
        Set-DbcConfig -Name policy.oleautomation -Value 0
        Set-DbcConfig -Name policy.security.adhocdistributedqueriesenabled -Value $false
        Set-DbcConfig -Name policy.security.clrenabled -Value $false
        Set-DbcConfig -Name policy.security.databasemailenabled -Value $false
        Set-DbcConfig -Name policy.security.xpcmdshelldisabled -Value $false
        Set-DbcConfig -Name skip.instance.defaulttrace -Value $false
        Set-DbcConfig -Name policy.security.latestbuild -Value $true
        Set-DbcConfig -Name skip.instance.oleautomationproceduresdisabled -Value $false
        Set-DbcConfig -Name policy.security.remoteaccessdisabled -Value $false
        Set-DbcConfig -Name policy.security.scanforstartupproceduresdisabled -Value $false
        Set-DbcConfig -Name skip.security.agentserviceadmin -Value $false
        Set-DbcConfig -Name skip.security.asymmetrickeysize -Value $false
        Set-DbcConfig -Name skip.security.builtinadmin -Value $false
        Set-DbcConfig -Name skip.security.clrassembliessafe -Value $false
        Set-DbcConfig -Name policy.security.containedbautoclose -Value $false
        Set-DbcConfig -Name skip.security.containedbautoclose -Value $false
        Set-DbcConfig -Name policy.security.databasemailenabled -Value $false
        Set-DbcConfig -Name policy.security.clrenabled -Value $false
        Set-DbcConfig -Name policy.security.crossdbownershipchaining -Value $false
        Set-DbcConfig -Name policy.security.databasemailenabled -Value $false
        Set-DbcConfig -Name policy.security.adhocdistributedqueriesenabled -Value $false
        Set-DbcConfig -Name policy.security.xpcmdshelldisabled -Value $false
        Set-DbcConfig -Name skip.security.ContainedDBSQLAuth -Value $false
        Set-DbcConfig -Name skip.security.engineserviceadmin -Value $false
        Set-DbcConfig -Name skip.security.fulltextserviceadmin -Value $false
        Set-DbcConfig -Name skip.security.guestuserconnect -Value $false
        Set-DbcConfig -Name skip.security.hideinstance -Value $false
        Set-DbcConfig -Name skip.security.localwindowsgroup -Value $false
        Set-DbcConfig -Name skip.security.loginauditlevelfailed -Value $false
        Set-DbcConfig -Name skip.security.loginauditlevelsuccessful -Value $false
        Set-DbcConfig -Name skip.security.LoginCheckPolicy -Value $false
        Set-DbcConfig -Name skip.security.LoginPasswordExpiration -Value $false
        Set-DbcConfig -Name skip.security.LoginMustChange -Value $false
        Set-DbcConfig -Name skip.security.sadisabled -Value $false
        Set-DbcConfig -Name skip.security.saexist -Value $false
        Set-DbcConfig -Name skip.security.sqlagentproxiesnopublicrole -Value $false
        Set-DbcConfig -Name skip.security.symmetrickeyencryptionlevel -Value $false
        Set-DbcConfig -Name skip.security.publicrolepermission -Value $false
    }
}

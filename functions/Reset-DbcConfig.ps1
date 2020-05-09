. $script:ModuleRoot/internal/functions/Invoke-ConfigurationScript.ps1
<#
.SYNOPSIS
Resets configuration entries to their default values.

.DESCRIPTION
This function unregisters configuration values and then registers them back with the default values and type.

This can be used to get the dbachecks back to default state of configuration, or to resolve problems with a specific setting.

.PARAMETER Name
Name of the configuration key.

.EXAMPLE
Reset-DbcConfig

Resets all the configuration values for dbachecks.

.EXAMPLE
Reset-DbcConfig -Name policy.recoverymodel.type

Resets the policy.recoverymodel.type to the default value and type.

.LINK
https://dbachecks.readthedocs.io/en/latest/functions/Reset-DbcConfig/

#>
function Reset-DbcConfig {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(DefaultParameterSetName = "FullName")]
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$Name
    )
    process {
        if (!$Name) {
            # no name provided, get all known dbachecks settings
            $resolvedName = (Get-DbcConfig).Name
        }
        elseif ($Name -match '\*') {
            # wildcard is used, get only the matching settings
            $resolvedName = (Get-DbcConfig).Name | Where-Object { $psitem -like $Name }
        }
        else {
            $resolvedName = $Name
        }

        @($resolvedName).ForEach{
            $localName = $psitem.ToLower()
            if (-not (Get-DbcConfig -Name $localName)) {
                Stop-PSFFunction -FunctionName Reset-DbcConfig -Message "Setting named $localName does not exist. Use Get-DbcCheck to get the list of supported settings."
            }
            else {
                Write-PSFMessage -FunctionName Reset-DbcConfig -Message "resetting $localName"
                Unregister-PSFConfig -Module dbachecks -Name $localName
                [PSFramework.Configuration.ConfigurationHost]::Configurations.Remove("dbachecks.$localName") | Out-Null
            }
        }

        # set up everything that is now missing back to the default values
        Invoke-ConfigurationScript

        # display the new values
        @($resolvedName).ForEach{
            Get-DbcConfig -Name $psitem
        }
    }
}

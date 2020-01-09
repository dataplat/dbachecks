<#
.SYNOPSIS
Sets configuration values for specific checks.

.DESCRIPTION
Changes configuration values which enable each check to have specific thresholds

.PARAMETER Name
Name of the configuration entry.

.PARAMETER Value
The value to assign.

.PARAMETER Handler
A scriptblock that is executed when a value is being set.

Is only executed if the validation was successful (assuming there was a validation, of course)

.PARAMETER Append
Adds the value to the existing configuration instead of overwriting it

.PARAMETER Temporary
The setting is not persisted outside the current session.
By default, settings will be remembered across all powershell sessions.

.PARAMETER EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

.EXAMPLE
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sqlcluster

Sets the SQL Instances which will be checked by default using Invoke-DbcCheck
to sql2016, sql2017, sqlcluster

.EXAMPLE
Set-DbcConfig -Name policy.validdbowner.name -Value 'TheBeard\sqldbowner'

Sets the value of the configuration for the expected database owners to
TheBeard\sqldbowner

.EXAMPLE
Set-DbcConfig -Name policy.database.status.excludereadonly -Value 'TheBeard'

Sets the value of the configuration for databases that are expected to be readonly
to TheBeard

.EXAMPLE
Set-DbcConfig -Name agent.validjobowner.name -Value 'TheBeard\SQLJobOwner' -Append

Adds 'TheBeard\SQLJobOwner' to the value of the configuration for accounts that
are expected to be owners of SQL Agent Jobs

.LINK
https://dbachecks.readthedocs.io/en/latest/functions/Set-DbcConfig/

#>
function Set-DbcConfig {
    [CmdletBinding(DefaultParameterSetName = "FullName", SupportsShouldProcess)]
    param (
        [string]$Name,
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        $Value,
        [System.Management.Automation.ScriptBlock]$Handler,
        [switch]$Append,
        [switch]$Temporary,
        [switch]$EnableException
    )

    process {
        if (-not (Get-DbcConfig -Name $Name)) {
            Stop-PSFFunction -Message "Setting named $Name does not exist. If you'd like us to support an additional setting, please file a GitHub issue."
            return
        }

        if ($Append) {
            $NewValue = (Get-DbcConfigValue -Name $Name)

            # this is important to fix issue 535
            # Need to process arrays correctly
            if ($NewValue -is [System.Array]) {
                if ($value -is [System.Array]) {
                    $Value.ForEach{
                        $NewValue += $psitem
                    }
                }
                else {
                    $NewValue += $Value
                }
            }
            else {
                $NewValue = $NewValue, $Value
            }
        }
        else {
            $NewValue = $Value
        }

        $Name = $Name.ToLower()
        if ($PSCmdlet.ShouldProcess("$name" , "Setting the value to $NewValue on ")) {
            Set-PSFConfig -Module dbachecks -Name $name -Value $NewValue
        }
        try {
            if (-not $Temporary) {
                if ($PSCmdlet.ShouldProcess("$name" , "Registering PSFConfig ")) {
                    Register-PSFConfig -FullName dbachecks.$name -EnableException -WarningAction SilentlyContinue
                }
            }
        }
        catch {
            if ($PSCmdlet.ShouldProcess("$Value" , "Setting PSFConfig $name ")) {
                Set-PSFConfig -Module dbachecks -Name $name -Value ($Value -join ", ")
            }
            if (-not $Temporary) {
                if ($PSCmdlet.ShouldProcess("$name" , "Registering PSFConfig ")) {
                    Register-PSFConfig -FullName dbachecks.$name
                }
            }
        }

        # Still unsure if I'll persist it here - wondering if this impacts global or keeps local
        if ($name -eq 'app.sqlcredential') {
            if ($PSCmdlet.ShouldProcess("Variable" , "Setting PSDefaultParameterValues ")) {
                Set-Variable -Scope 1 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $value }
            }
        }
        Get-DbcConfig -Name $name
    }
}
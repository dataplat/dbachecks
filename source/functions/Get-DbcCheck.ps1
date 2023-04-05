<#
    .SYNOPSIS
        Lists all checks, tags and unique identifiers

    .DESCRIPTION
        Lists all checks, tags and unique identifiers

    .PARAMETER Tag
        The tag to return information about

    .PARAMETER Pattern
        May be any string, supports wildcards.

    .PARAMETER Group
        To be able to filter by group

    .EXAMPLE
        Get-DbcCheck

        Retrieves all of the available checks

    .EXAMPLE
        Get-DbcCheck backups

        Retrieves all of the available tags that match backups

    .LINK
    https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcCheck/
#>
function Get-DbcCheck {
    [CmdletBinding()]
    param (
        [string]$Tag,
        [string]$Pattern,
        [string]$Group
    )

    process {
        $script:localapp = Get-DbcConfigValue -Name app.localapp
        # so that it works cross platform
        $checksfile = Join-Path -Path $script:localapp -ChildPath 'checks.json'
        if ($Pattern) {
            if ($Pattern -notmatch '\*') {
                $output = @([System.IO.File]::ReadAllText("$script:localapp/checks.json" ) | ConvertFrom-Json).ForEach{
                    $psitem | Where-Object {
                        $_.Group, $_.Description , $_.UniqueTag , $_.AllTags, $_.Type -match $Pattern
                    }
                }
            } else {
                $output = @([System.IO.File]::ReadAllText("$script:localapp/checks.json" ) | ConvertFrom-Json).ForEach{
                    $psitem | Where-Object {
                        $_.Group, $_.Description , $_.UniqueTag , $_.AllTags, $_.Type -like $Pattern
                    }
                }
            }
        } else {
            $output = [System.IO.File]::ReadAllText("$script:localapp/checks.json" ) | ConvertFrom-Json
        }
        if ($Group) {
            $output = @($output).ForEach{
                $psitem | Where-Object {
                    $_.Group -eq $Group
                }
            }
        }
        if ($Tag) {
            $output = @($output).ForEach{
                $psitem | Where-Object {
                    $_.AllTags -match $Tag
                }
            }
        }
        @($output).ForEach{
            Select-DefaultView -InputObject $psitem -TypeName Check -Property 'Group', 'Type', 'UniqueTag', 'AllTags', 'Config', 'Description'
        }
    }
}
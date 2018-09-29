<#
.SYNOPSIS
Returns the release notes for the module - organised by date

.DESCRIPTION
Grabs the release notes for the dbachecks module and returns either the latest or all of them

.PARAMETER Latest
A Switch to return the latest release notes only

.EXAMPLE
Get-DbcReleaseNote

Returns the release notes for the dbachecks module

.EXAMPLE
Get-DbcReleaseNote -Latest

Returns just the latest release notes for the dbachecks module

.NOTES
30/05/2012 - RMS
#>
function Get-DbcReleaseNote {
    Param (
        [switch]$Latest
    )
 
    $releasenotes = Get-Content $ModuleRoot\RELEASE.md -Raw
 
    if($Latest){
        ($releasenotes -Split "##Latest")[0]
    }
    else{
        $releasenotes
    }
 }
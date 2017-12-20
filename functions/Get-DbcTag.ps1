function Get-DbcTag {
	<#
		.SYNOPSIS
			Retrieves a list of all available tags. Simplisitic, similar to Get-Verb.
	
		.DESCRIPTION
			
		.PARAMETER Name
			Default: "*"
			The name of the tag to retrieve.
			May be any string, supports wildcards.

		.EXAMPLE
			PS C:\> Get-DbcTag
			
			Retrieves all of the available tags for -Tag and -ExcludeTag

		.EXAMPLE
			PS C:\> Get-DbcTag backups
			
			Retrieves all of the available tags for -Tag and -ExcludeTag that are -like backups
    #>
	[CmdletBinding()]
	param (
		[string]$Name = "*"
	)
	
	process {
		(Get-PSFConfigValue -FullName dbachecks.autocomplete.pestertags).ToLower() | Where-Object { $_ -like $name } | Sort-Object | Select-Object -Unique
	}
}

# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}

# Parse repo for tags and descriptions then write json
$repo = Get-DbcConfigValue -Name app.checkrepos
$collection = @()
$strings = Get-Content "$repo\*.Tests.ps1" | Where-Object { $_ -match "-Tag" }
foreach ($string in $strings) {
	$describe = Select-String -InputObject $string -Pattern 'Describe\ \"[\s]*(.+)[\s]*\"\ \-Tag' | ForEach-Object { $_.matches.Groups[1].Value }
	$tags = Select-String -InputObject $string -Pattern '-Tag[\s]*(.+)[\s]*\, \$filename' | ForEach-Object { $_.matches.Groups[1].Value }
	$collection += [pscustomobject]@{
		Name		   = $describe
		UniqueTag	   = $null
		AllTags	       = $tags
	}
}

$singletags = ($collection.AllTags -split ",").Trim() | Group-Object | Where-Object Count -eq 1
foreach ($check in $collection) {
	$unique = $singletags | Where-Object { $_.Name -in ($check.AllTags -split ",").Trim() }
	$check.UniqueTag = $unique.Name
}
ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}
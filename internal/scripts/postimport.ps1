# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}

# This is an abomination, but works
$repo = Get-DbcConfigValue -Name app.checkrepos
$collection = @()
$strings = Get-Content "$repo\*.Tests.ps1" | Where-Object { $_ -match "-Tag" }
foreach ($string in $strings) {
	$describe = Select-String -InputObject $string -Pattern 'Describe\ \"[\s]*(.+)[\s]*\"\ \-Tag' | ForEach-Object { $_.matches.Groups[1].Value }
	$tags = Select-String -InputObject $string -Pattern '-Tag[\s]*(.+)[\s]*\, \$filename' | ForEach-Object { $_.matches.Groups[1].Value }
	$collection += [pscustomobject]@{
		Name   = $describe
		Tags   = $tags
	}
}

ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}
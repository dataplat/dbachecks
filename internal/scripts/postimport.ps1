# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}

# This is an abomination, but works
$repo = Get-DbcConfigValue -Name app.checkrepo
$alltags = (Get-ChildItem -Path "$repo\*Tests.ps1").Name.Replace(".Tests.ps1", "")
$content = Get-Content "$repo\*Tests.ps1" | Where-Object { $_ -match "-Tag" }
$parsedtags = Get-Content "$repo\*.Tests.ps1" | Where-Object { $_ -match "-Tag" } | Select-String -Pattern '-Tag[\s]*(.+)[\s]*\$filename' | ForEach-Object { $_.matches.Groups[1].Value }
$alltags += $parsedtags.Split(",").Trim() | Where-Object { $_.length -gt 2 } | Select-Object -Unique
Set-PSFConfig -Module dbachecks -Name app.pestertags -Value $alltags

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}
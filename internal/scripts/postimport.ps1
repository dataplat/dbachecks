# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
	. Import-ModuleFile -Path $file.FullName
}

# Parse repo for tags and descriptions then write json
$repos = Get-CheckRepo
$collection = $repofiles = @()
foreach ($repo in $repos) {
	$repofiles += Get-ChildItem "$repo\*.Tests.ps1"
}

foreach ($file in $repofiles) {
	$filename = $file.Name.Replace(".Tests.ps1", "")
	$strings = Get-Content $file | Where-Object { $_ -match "-Tags" }
	foreach ($string in $strings) {
		$describe = Select-String -InputObject $string -Pattern 'Describe\ \"[\s]*(.+)[\s]*\"\ \-Tags' | ForEach-Object { $_.matches.Groups[1].Value }
		$tags = Select-String -InputObject $string -Pattern '-Tags[\s]*(.+)[\s]*\, \$filename' | ForEach-Object { $_.matches.Groups[1].Value }
		$collection += [pscustomobject]@{
			Group			    = $filename
			Description		    = $describe
			UniqueTag		    = $null
			AllTags			    = "$tags, $filename"
		}
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
# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1")) {
    . Import-ModuleFile -Path $file.FullName
}

# load app stuff and create files if needed
$script:localapp = Get-DbcConfigValue -Name app.localapp
$script:maildirectory = Get-DbcConfigValue -Name app.maildirectory

if (-not (Test-Path -Path $script:localapp)) {
    New-Item -ItemType Directory -Path $script:localapp
}

if (-not (Test-Path -Path $script:maildirectory)) {
    New-Item -ItemType Directory -Path $script:maildirectory
}

# Parse repo for tags and descriptions then write json
$repos = Get-CheckRepo
$collection = $groups = $repofiles = @()
foreach ($repo in $repos) {
	$repofiles += Get-ChildItem "$repo\*.Tests.ps1"
}

foreach ($file in $repofiles) {
	$gets = Select-String -InputObject $file -Pattern 'Get-SqlInstance|Get-ComputerName'
	$filename = $file.Name.Replace(".Tests.ps1", "")
	$groups += $filename
	$strings = Get-Content $file | Where-Object { $_ -match "-Tags" }
	foreach ($string in $strings) {
		$rawtype = $gets | Where-Object { $_.LineNumber -gt $string.ReadCount } | Sort-Object LineNumber | Select-Object -First 1
		
		if ($rawtype -match "Get-SqlInstance") {
			$type = "Sqlinstance"
		}
		if ($rawtype -match "Get-ComputerName") {
			$type = "ComputerName"
		}
		if ($null -eq $rawtype) {
			$type = $null
		}
		
		$describe = Select-String -InputObject $string -Pattern 'Describe\ \"[\s]*(.+)[\s]*\"\ \-Tags' | ForEach-Object { $_.matches.Groups[1].Value }
		$tags = Select-String -InputObject $string -Pattern '-Tags[\s]*(.+)[\s]*\, \$filename' | ForEach-Object { $_.matches.Groups[1].Value }
		if ($filename -eq "HADR" -and $type -eq $null) { $type = "ComputerName" }
		$collection += [pscustomobject]@{
			Group			   = $filename
			Type			   = $type
			Description	       = $describe
			UniqueTag		   = $null
			AllTags		       = "$tags, $filename"
		}
	}
}

$singletags = ($collection.AllTags -split ",").Trim() | Group-Object | Where-Object { $_.Count -eq 1 -and $_.Name -notin $groups }
foreach ($check in $collection) {
	$unique = $singletags | Where-Object { $_.Name -in ($check.AllTags -split ",").Trim() }
	$check.UniqueTag = $unique.Name
}
ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.ps1")) {
    . Import-ModuleFile -Path $file.FullName
}

# Importing PSDefaultParameterValues
$PSDefaultParameterValues = $global:PSDefaultParameterValues

# Set default param values if it exists
if ($credential = (Get-DbcConfigValue -Name app.sqlcredential)) {
    if ($PSDefaultParameterValues) {
        $newvalue = $PSDefaultParameterValues += @{ '*:SqlCredential' = $credential }
        Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value $newvalue
    }
    else {
        Set-Variable -Scope 0 -Name PSDefaultParameterValues -Value @{ '*:SqlCredential' = $credential }
    }
}

# EnableException so that failed commands cause failures
$PSDefaultParameterValues += @{ '*-Dba*:EnableException' = $true }

# Fred magic
# Set-PSFTaskEngineCache -Module dbachecks -Name module-imported -Value $true
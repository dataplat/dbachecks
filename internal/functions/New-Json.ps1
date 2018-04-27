
function New-Json {
    # Parse repo for tags and descriptions then write json
    $repos = Get-CheckRepo
    $collection = $groups = $repofiles = @()
    foreach ($repo in $repos) {
        $repofiles += (Get-ChildItem "$repo\*.Tests.ps1" | Where-Object { $_.Name -ne 'MaintenanceSolution.Tests.ps1' })
    }
    
    $tokens = $null
    $errors = $null
    foreach ($file in $repofiles) {
        $filename = $file.Name.Replace(".Tests.ps1", "")
        $Check = Get-Content $file -Raw
        $Describes = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors).
                FindAll([Func[Management.Automation.Language.Ast, bool]] {
                        param ($ast)
                        $ast.CommandElements -and
                        $ast.CommandElements[0].Value -eq 'describe'
                    }, $true)
    
    @($describes).ForEach{
        $groups += $filename
        $Describe = $_.CommandElements.Where{$PSItem.StaticType.name -eq 'string'}[1]
        $title = $Describe.Value
        $Tags = $PSItem.CommandElements.Where{$PSItem.StaticType.name -eq 'Object[]' -and $psitem.Value -eq $null}.Extent.Text.ToString().Replace(', $filename','')
     if ($Describe.Parent -match "Get-Instance") {
        $type = "Sqlinstance"
    }
    elseif ($Describe.Parent -match "Get-ComputerName") {
        $type = "ComputerName"
    }
    else  {
        $type = $null
    }
    $configs = [regex]::matches($describe.Parent.Extent.Text, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
    $Config = ''
    $configs.foreach{$config += "$_ "}
        $collection += [pscustomobject]@{
            Group         = $filename
            Type          = $type
            Description   = $title
            UniqueTag     = $null
            AllTags       = "$tags, $filename"
            Config        = $config
        }
    }
    }
    $singletags = (($collection.AllTags -split ",").Trim() | Group-Object | Where-Object { $_.Count -eq 1 -and $_.Name -notin $groups })
    foreach ($check in $collection) {
        $unique = $singletags | Where-Object { $_.Name -in ($check.AllTags -split ",").Trim() }
        $check.UniqueTag = $unique.Name
    }

    
$olanames = @()
$olanames += [pscustomobject]@{ Description = 'Ola System Full Backup'; prefix = 'OlaSystemFull' }
$olanames += [pscustomobject]@{ Description = 'Ola System Full Backup'; prefix = 'OlaUserFull' }
$olanames += [pscustomobject]@{ Description = 'Ola User Diff Backup'; prefix = 'OlaUserDiff' }
$olanames += [pscustomobject]@{ Description = 'Ola User Log Backup'; prefix = 'OlaUserLog' }
$olanames += [pscustomobject]@{ Description = 'Ola CommandLog Cleanup'; prefix = 'OlaCommandLog' }
$olanames += [pscustomobject]@{ Description = 'Ola System Integrity Check'; prefix = 'OlaSystemIntegrityCheck' }
$olanames += [pscustomobject]@{ Description = 'Ola User Integrity Check'; prefix = 'OlaUserIntegrityCheck' }
$olanames += [pscustomobject]@{ Description = 'Ola User Index Optimize'; prefix = 'OlaUserIndexOptimize' }
$olanames += [pscustomobject]@{ Description = 'Ola Output File Cleanup'; prefix = 'OlaOutputFileCleanup' }
$olanames += [pscustomobject]@{ Description = 'Ola Delete Backup History'; prefix = 'OlaDeleteBackupHistory' }
$olanames += [pscustomobject]@{ Description = 'Ola Purge Job History'; prefix = 'OlaPurgeJobHistory' }

foreach ($olaname in $olanames) {
    $collection += [pscustomobject]@{
        Group          = 'MaintenanceSolution'
        Type           = 'Sqlinstance'
        Description    = $olaname.Description
        UniqueTag      = $olaname.Prefix
        AllTags        = "$($olaname.Prefix), MaintenanceSolution"
    }
}

    ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"
    }
    
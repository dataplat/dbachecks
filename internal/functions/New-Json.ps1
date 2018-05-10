
function New-Json {
    # Parse repo for tags and descriptions then write json
    $repos = Get-CheckRepo
    $collection = $groups = $repofiles = @()
    foreach ($repo in $repos) {
        $repofiles += (Get-ChildItem "$repo\*.Tests.ps1")
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
    if(-not $config){$config = "None"}
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
    ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"
    }
    
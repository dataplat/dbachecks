
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
        ## Parse the file with AST and get each describe block
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
            $Tags = $PSItem.CommandElements.Where{$PSItem.StaticType.name -eq 'Object[]' -and $psitem.Value -eq $null}.Extent.Text.ToString().Replace(', $filename', '')
            # CHoose the type            
            if ($Describe.Parent -match "Get-Instance") {
                $type = "Sqlinstance"
            }
            elseif ($Describe.Parent -match "Get-ComputerName") {
                $type = "ComputerName"
            }
            elseif ($Describe.Parent -match "Get-ClusterObject") {
                $Type = "ClusteNode"
            }
            else {
                $type = $null
            }
            if ($filename -eq 'HADR') {
                ## HADR configs are outside of describe
                $configs = [regex]::matches($check, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
            }
            else {
                $configs = [regex]::matches($describe.Parent.Extent.Text, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
            }
            $Config = ''
            $configs.foreach{$config += "$_ "}
            if ($filename -eq 'MaintenanceSolution') {
                # The Maintenance Solution needs a bit of faffing as the configs for the jobnames are used to create the titles
                switch ($tags -match $PSItem) {
                    {$Tags.Contains('SystemFull')} {$config = 'ola.JobName.SystemFull ' + $config}                
                    {$Tags.Contains('UserFull')} {$config = 'ola.JobName.UserFull ' + $config}                
                    {$Tags.Contains('UserDiff')} {$config = 'ola.JobName.UserDiff ' + $config}                
                    {$Tags.Contains('UserLog')} {$config = 'ola.JobName.UserLog ' + $config}                
                    {$Tags.Contains('CommandLog')} {$config = 'ola.JobName.CommandLogCleanup ' + $config}                
                    {$Tags.Contains('SystemIntegrityCheck')} {$config = 'ola.JobName.SystemIntegrity ' + $config}                
                    {$Tags.Contains('UserIntegrityCheck')} {$config = 'ola.JobName.UserIntegrity ' + $config}                
                    {$Tags.Contains('UserIndexOptimize')} {$config = 'ola.JobName.UserIndex ' + $config}                
                    {$Tags.Contains('OutputFileCleanup')} {$config = 'ola.JobName.OutputFileCleanup ' + $config}                
                    {$Tags.Contains('DeleteBackupHistory')} {$config = 'ola.JobName.DeleteBackupHistory ' + $config}                
                    {$Tags.Contains('PurgeJobHistory')} {$config = 'ola.JobName.PurgeBackupHistory ' + $config}                
                    Default {}
                }
            }
            # add the config for the type
            switch ($type) {
                SqlInstance {$config = 'app.sqlinstance' + $config}
                ComputerName {$config = 'app.computername' + $config}
                ClusterNode {$config = 'app.sqlinstance' + $config}
                Default {}
            }
            if (-not $config) {$config = "None"}
            $collection += [pscustomobject]@{
                Group       = $filename
                Type        = $type
                Description = $title
                UniqueTag   = $null
                AllTags     = "$tags, $filename"
                Config      = $config
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
    
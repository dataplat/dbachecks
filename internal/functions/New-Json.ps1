
function New-Json {
    # Parse repo for tags and descriptions then write json
    $script:localapp = Get-DbcConfigValue -Name app.localapp
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
        ## Parse the file with AST 
        $CheckFileAST = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors)

        ## New code uses a Computer Name loop to speed up execution so need to find that as well
        $ComputerNameForEach = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast) 
                $ast -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $ast.expression.Subexpression.Extent.Text -eq 'Get-ComputerName'
            }, $true).Extent

        ## New code uses a Computer Name loop to speed up execution so need to find that as well
        $InstanceNameForEach = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
            param ($ast) 
            $ast -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $ast.expression.Subexpression.Extent.Text -eq 'Get-Instance'
        }, $true).Extent


        ## Old code we can use the describes
        $Describes = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
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
            elseif ($Describe.Parent -match "Get-ComputerName" -or $Describe.Parent -match "AllServerInfo") {
                $type = "ComputerName"
            }
            elseif ($Describe.Parent -match "Get-ClusterObject") {
                $Type = "ClusterNode"
            }
            else {
                #Choose the type from the new way from inside the foreach
                if ($ComputerNameForEach -match $title) {
                    $type = "ComputerName"
                }
                elseif($InstanceNameForEach -match $title){
                    $type = "Sqlinstance"
                }
                else {
                    $type = $null
                }
            }

            if ($filename -eq 'HADR') {
                ## HADR configs are outside of describe
                $configs = [regex]::matches($check, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
            }
            else {
                $configs = [regex]::matches($describe.Parent.Extent.Text, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{$_.Name -eq 1}.Value
            }
            $Config = ''
            foreach ($c in $Configs) {$config += "$c "} # DON't DELETE THE SPACE in "$c "
            if ($filename -eq 'MaintenanceSolution') {
                # The Maintenance Solution needs a bit of faffing as the configs for the jobnames are used to create the titles
                switch ($tags -match $PSItem) {
                    {$Tags.Contains('SystemFull')} {
                        $config = 'ola.JobName.SystemFull ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.systemfull)
                    }                
                    {$Tags.Contains('UserFull')} {
                        $config = 'ola.JobName.UserFull ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userfull)
                    }                
                    {$Tags.Contains('UserDiff')} {
                        $config = 'ola.JobName.UserDiff ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userdiff)
                    }                
                    {$Tags.Contains('UserLog')} {
                        $config = 'ola.JobName.UserLog ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userlog)
                    }                
                    {$Tags.Contains('CommandLog')} {
                        $config = 'ola.JobName.CommandLogCleanup ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.commandlogcleanup)
                    }                
                    {$Tags.Contains('SystemIntegrityCheck')} {
                        $config = 'ola.JobName.SystemIntegrity ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.systemintegrity)
                    }                
                    {$Tags.Contains('UserIntegrityCheck')} {
                        $config = 'ola.JobName.UserIntegrity ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userintegrity)
                    }                
                    {$Tags.Contains('UserIndexOptimize')} {
                        $config = 'ola.JobName.UserIndex ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userindex)
                    }                
                    {$Tags.Contains('OutputFileCleanup')} {
                        $config = 'ola.JobName.OutputFileCleanup ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.outputfilecleanup)
                    }                
                    {$Tags.Contains('DeleteBackupHistory')} {
                        $config = 'ola.JobName.DeleteBackupHistory ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.deletebackuphistory)
                    }                
                    {$Tags.Contains('PurgeJobHistory')} {
                        $config = 'ola.JobName.PurgeBackupHistory ' + $config
                        $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.purgebackuphistory)
                    }                
                    Default {}
                }
            }
            # add the config for the type
            switch ($type) {
                SqlInstance {$config = 'app.sqlinstance ' + $config}
                ComputerName {$config = 'app.computername ' + $config}
                ClusterNode {$config = 'app.sqlinstance ' + $config}
                Default {}
            }
            if (-not $config) {$config = "None"}
            $collection += [pscustomobject]@{
                Group       = $filename
                Type        = $type
                UniqueTag   = $null
                AllTags     = "$tags, $filename"
                Config      = $config
                Description = $null
                Describe    = $title
            }
        }
    }
    $singletags = (($collection.AllTags -split ",").Trim() | Group-Object | Where-Object { $_.Count -eq 1 -and $_.Name -notin $groups })
    $Descriptions = Get-Content $script:ModuleRoot\internal\configurations\DbcCheckDescriptions.json -Raw| ConvertFrom-Json
    foreach ($check in $collection) {
        $unique = $singletags | Where-Object { $_.Name -in ($check.AllTags -split ",").Trim() }
        $check.UniqueTag = $unique.Name
        $Check.Description = $Descriptions.Where{$_.UniqueTag -eq $Check.UniqueTag}.Description
    }
    ConvertTo-Json -InputObject $collection | Out-File "$script:localapp\checks.json"
}
    
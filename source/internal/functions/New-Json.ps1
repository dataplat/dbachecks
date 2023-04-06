
function New-Json {
    [CmdletBinding(SupportsShouldProcess)]
    Param()
    # Parse repo for tags and descriptions then write json
    $script:localapp = Get-DbcConfigValue -Name app.localapp
    $repos = Get-CheckRepo
    $collection = $groups = $repofiles = @()
    foreach ($repo in $repos) {
        $folders = Join-Path -Path $repo -ChildPath '*.Tests.ps1'
        $repofiles += (Get-ChildItem $folders )
    }
    $tokens = $null
    $errors = $null
    foreach ($file in $repofiles) {
        $Check = $null
        # We dont want to mess with v5 files - although we will need to write the json for them
        if ($file.Name -notmatch 'v5') {
            $message = "We are going to look at this file {0}" -f $file.Name
            Write-PSFMessage -Message $message -Level Verbose
            $filename = $file.Name.Replace(".Tests.ps1", "")
            #  Write-Verbose "Processing $FileName"
            #  Write-Verbose "Getting Content of File"
            $Check = [System.IO.File]::ReadAllText($file)

            # because custom checks if they are not coded correctly will break this json creation
            # and they wont get added nicely so that they can be targetted with tags (checks)
            # this part will check all of the files and ensure that they have the filename variabel at the top and that
            # each describe is using Tags not Tag and the last tag is the $filename

            if ($Filename -notin ('Agent', 'Database', 'Domain', 'HADR', 'Instance', 'LogShipping', 'MaintenanceSolution', 'Server')) {

                #all checks files MUST have this at the top
                if ($Check -notmatch '\$filename = \$MyInvocation\.MyCommand\.Name\.Replace\("\.Tests\.ps1", ""\)') {
                    Write-Verbose "$Filename does not have the correct value at the top so we will add it"
                    $filecontent = @"
  `$filename = `$MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

"@
                    $filecontent = $filecontent + $Check
                    if ($PSCmdlet.ShouldProcess("$($File.Name)" , "Adding the filename variable to the file")) {
                        $Check = $null
                        Set-Content -Path $file -Value $filecontent
                        Write-Verbose "Getting Content of File again"
                        $Check = [System.IO.File]::ReadAllText($file)
                    }

                }

                ## Parse the file with AST
                $CheckFileAST = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$tokens, [ref]$errors)

                #Check that the tags are set correctly otherwise the json doesnt get properly created
                $Statements = $CheckFileAST.EndBlock.statements.Extent
                ## Ignore the filename line
                @($Statements.Where{ $PSItem.StartLineNumber -ne 1 }).ForEach{
                    #  Write-Verbose "Checking the Describe Tag $($PSItem.Text.SubString(0,50) )"
                    if ($PSItem.Text -notmatch 'Describe ".*" -Tags .*,.*\$filename \{') {
                        $RogueDescribe = $PSItem.Text.SubString(0, $PSitem.Text.IndexOf('{'))
                        Write-Warning "The Describe Tag $RogueDescribe in $($File.Name) is not set up correctly - we will try to fix it for you"
                        $replace = $RogueDescribe + ', $Filename '
                        $Check = $Check -replace $RogueDescribe , $replace
                        $Check = $Check -replace '-Tag ', '-Tags '
                        if ($PSCmdlet.ShouldProcess("$($File.Name)" , "Fixing the tags on the files")) {
                            Set-Content $file -Value $Check
                            $Check = $null
                        }
                        #  Write-Verbose "Getting Content of File again"
                        $Check = [System.IO.File]::ReadAllText($file)

                    }
                }
            }

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
                    $ast.CommandElements[0].Value -eq 'Describe'
                }, $true)

            @($describes).ForEach{
                $groups += $filename
                $Describe = $_.CommandElements.Where{ $PSItem.StaticType.name -eq 'string' }[1]
                $title = $Describe.Value
                $Tags = $PSItem.CommandElements.Where{ $PSItem.StaticType.name -eq 'Object[]' -and $null -eq $psitem.Value }.Extent.Text.ToString().Replace(', $filename', '')
                # CHoose the type
                if ($Describe.Parent -match "Get-Instance") {
                    $type = "Sqlinstance"
                } elseif ($Describe.Parent -match "Get-ComputerName" -or $Describe.Parent -match "AllServerInfo") {
                    $type = "ComputerName"
                } elseif ($Describe.Parent -match "Get-ClusterObject") {
                    $Type = "ClusterNode"
                } else {
                    #Choose the type from the new way from inside the foreach
                    if ($ComputerNameForEach -match $title) {
                        $type = "ComputerName"
                    } elseif ($InstanceNameForEach -match $title) {
                        $type = "Sqlinstance"
                    } else {
                        $type = $null
                    }
                }

                if ($filename -eq 'HADR') {
                    ## HADR configs are outside of describe
                    $configs = [regex]::matches($check, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{ $_.Name -eq 1 }.Value
                } else {
                    $configs = [regex]::matches($describe.Parent.Extent.Text, "Get-DbcConfigValue\s([a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*.[a-zA-Z\d]*\b)").groups.Where{ $_.Name -eq 1 }.Value
                }
                $Config = ''
                foreach ($c in $Configs) { $config += "$c " } # DON't DELETE THE SPACE in "$c "
                if ($filename -eq 'MaintenanceSolution') {
                    # The Maintenance Solution needs a bit of faffing as the configs for the jobnames are used to create the titles
                    switch ($tags -match $PSItem) {
                        { $Tags.Contains('SystemFull') } {
                            $config = 'ola.JobName.SystemFull ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.systemfull)
                        }
                        { $Tags.Contains('UserFull') } {
                            $config = 'ola.JobName.UserFull ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userfull)
                        }
                        { $Tags.Contains('UserDiff') } {
                            $config = 'ola.JobName.UserDiff ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userdiff)
                        }
                        { $Tags.Contains('UserLog') } {
                            $config = 'ola.JobName.UserLog ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userlog)
                        }
                        { $Tags.Contains('CommandLog') } {
                            $config = 'ola.JobName.CommandLogCleanup ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.commandlogcleanup)
                        }
                        { $Tags.Contains('SystemIntegrityCheck') } {
                            $config = 'ola.JobName.SystemIntegrity ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.systemintegrity)
                        }
                        { $Tags.Contains('UserIntegrityCheck') } {
                            $config = 'ola.JobName.UserIntegrity ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userintegrity)
                        }
                        { $Tags.Contains('UserIndexOptimize') } {
                            $config = 'ola.JobName.UserIndex ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.userindex)
                        }
                        { $Tags.Contains('OutputFileCleanup') } {
                            $config = 'ola.JobName.OutputFileCleanup ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.outputfilecleanup)
                        }
                        { $Tags.Contains('DeleteBackupHistory') } {
                            $config = 'ola.JobName.DeleteBackupHistory ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.deletebackuphistory)
                        }
                        { $Tags.Contains('PurgeJobHistory') } {
                            $config = 'ola.JobName.PurgeBackupHistory ' + $config
                            $title = 'Ola - ' + (Get-DbcConfigValue -Name ola.jobname.purgebackuphistory)
                        }
                        Default {}
                    }
                }
                # add the config for the type
                switch ($type) {
                    SqlInstance { $config = 'app.sqlinstance ' + $config }
                    ComputerName { $config = 'app.computername ' + $config }
                    ClusterNode { $config = 'app.sqlinstance ' + $config }
                    Default {}
                }
                if (-not $config) { $config = "None" }
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
    }
    $singletags = (($collection.AllTags -split ",").Trim() | Group-Object | Where-Object { $_.Count -eq 1 -and $_.Name -notin $groups })
    $descriptionsFile = Join-Path -Path $script:ModuleRoot -ChildPath 'internal\configurations\DbcCheckDescriptions.json'
    $descriptions = [System.IO.File]::ReadAllText($descriptionsFile) | ConvertFrom-Json
    foreach ($check in $collection) {
        $unique = $singletags | Where-Object { $_.Name -in ($check.AllTags -split ",").Trim() }
        $check.UniqueTag = $unique.Name
        $Check.Description = $Descriptions.Where{ $_.UniqueTag -eq $Check.UniqueTag }.Description
    }
    try {
        $checksfile = Join-Path -Path $script:localapp -ChildPath 'checks.json'
        if ($PSCmdlet.ShouldProcess($checksfile  , "Convert Json and write to file")) {
            ConvertTo-Json -InputObject $collection | Out-File $checksfile
        }
    } catch {
        Write-PSFMessage "Failed to create the json, something weird might happen now with tags and things" -Level Significant
    }

}

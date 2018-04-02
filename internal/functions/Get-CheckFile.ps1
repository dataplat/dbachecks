function Get-CheckFile {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Repo,
        [Parameter(Mandatory=$true)]
        [String[]]$Check
    )
    
    $script:selectedFiles = New-Object System.Collections.Generic.List[String]

    if ($Check.Count -gt 0) { 
        # specific checks were requested. find them.
        (Get-ChildItem -Path "$Repo\*.Tests.ps1").ForEach{
            $script:checksFile = $psitem.FullName
            
            if ($Check -contains ($PSItem.Name -replace ".Tests.ps1", "")) {
                # file matches by name 
                if (!($script:selectedFiles -contains $script:checksFile)) {
                    $script:selectedFiles.Add($script:checksFile)
                }
            } else {
                @($check).ForEach{
                    if (@(Get-Content -Path $script:checksFile | Select-String -Pattern "^Describe.*-Tags\s+.*($psitem)[`",\s]+[,\w]?.*`$").Matches.Count) {
                        # file matches by one of the tags
                        if (!($script:selectedFiles -contains $script:checksFile)) {
                            $script:selectedFiles.Add($script:checksFile)
                        }
                    }
                }
            }
        }
    }

    return $script:selectedFiles
}

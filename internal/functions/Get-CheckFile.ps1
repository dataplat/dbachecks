<#
.SYNOPSIS
This will return all of the files that match a Check name - either by name or by pester tag

.DESCRIPTION
This will return all of the files that match a Check name - either by name or by pester tag

for either v4 or v5 Pester checks using the v5 switch

.PARAMETER Repo
The repo paths to check - normally defined by Get-CheckRepo

.PARAMETER Check
The Check

.PARAMETER v5
Are we looking for Pester v5 files or not

.EXAMPLE
Get-CheckFile -Check AutoClose

Gets the files for the AutoClose check

.NOTES
Internal - used in Invoke-DbcCheckv4 and Invoke-DbcCheckv5
#>
function Get-CheckFile {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Repo,
        [Parameter(Mandatory = $true)]
        [String[]]$Check,
        [Parameter()]
        [switch]$v5
    )

    $script:selectedFiles = New-Object System.Collections.Generic.List[String]

    switch ($v5) {
        $false {
            if ($Check.Count -gt 0) {
                # specific checks were requested. find them.
                @(Get-ChildItem -Path "$Repo\*.Tests.ps1").ForEach{
                    $script:checksFile = $psitem.FullName

                    if ($Check -contains ($PSItem.Name -replace ".Tests.ps1", "")) {
                        # file matches by name
                        if (!($script:selectedFiles -contains $script:checksFile)) {
                            $script:selectedFiles.Add($script:checksFile)
                        }
                    } else {
                        @($check).ForEach{
                            if (@(Get-Content -Path $script:checksFile | Select-String -Pattern "^\s*Describe.*-Tags\s+.*($psitem)").Matches.Count) {
                                # file matches by one of the tags
                                if (!($script:selectedFiles -contains $script:checksFile)) {
                                    $script:selectedFiles.Add($script:checksFile)
                                }
                            }
                        }
                    }
                }
            }
        }
        $true {
            if ($Check.Count -gt 0) {
                # specific checks were requested. find them.
                @(Get-ChildItem -Path "$Repo\*.Tests.ps1").ForEach{
                    # but we only want v5 files
                    if($psitem.Name -match 'v5'){
                        $script:checksFile = $psitem.FullName

                        if ($Check -contains ($PSItem.Name -replace "v5.Tests.ps1", "")) {
                            # file matches by name
                            if (!($script:selectedFiles -contains $script:checksFile)) {
                                $script:selectedFiles.Add($script:checksFile)
                            }
                        } else {
                            @($check).ForEach{
                                if (@(Get-Content -Path $script:checksFile | Select-String -Pattern "^\s*Describe.*-Tags\s+.*($psitem)").Matches.Count) {
                                    # file matches by one of the tags
                                    if (!($script:selectedFiles -contains $script:checksFile)) {
                                        $script:selectedFiles.Add($script:checksFile)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return $script:selectedFiles
}
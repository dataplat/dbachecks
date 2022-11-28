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
    [CmdletBinding()]
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
                    # we do not want v5 files here
                    if ($psitem.Name -notmatch 'v5') {
                        $script:checksFile = $psitem.FullName

                        if ($Check -contains ($PSItem.Name -replace '.Tests.ps1', '')) {
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
        $true {
            $message = 'We are going to use v5 files'
            Write-PSFMessage -Message $message -Level Verbose
            if ($Check.Count -gt 0) {
                # specific checks were requested. find them.
                $message = 'Specific checks were requested. find them'
                Write-PSFMessage -Message $message -Level Verbose
                $message = 'Searching Path {0} for test files' -f $repo
                Write-PSFMessage -Message $message -Level Verbose
                @(Get-ChildItem -Path "$Repo\*.Tests.ps1").ForEach{
                    $message = 'Processing {0}' -f $psitem.Name
                    Write-PSFMessage -Message $message -Level Verbose
                    # but we only want v5 files
                    if ($psitem.Name -match 'v5') {

                        $message = '{0} is a v5 file' -f $psitem.Name
                        Write-PSFMessage -Message $message -Level Verbose

                        $script:checksFile = $psitem.FullName

                        if ($Check -contains ($PSItem.Name -replace 'v5.Tests.ps1', '')) {
                            $message = '{0} file matches check {1}' -f $psitem.Name, ($Check | Out-String)
                            Write-PSFMessage -Message $message -Level Verbose
                            # file matches by name
                            if (!($script:selectedFiles -contains $script:checksFile)) {
                                $script:selectedFiles.Add($script:checksFile)
                            }
                        } else {
                            $message = '{0} file does not match check {1} lets check for the tag' -f $psitem.Name, ($Check | Out-String)
                            Write-PSFMessage -Message $message -Level Verbose
                            $fileContent = Get-Content -Path $script:checksFile
                            @($check).ForEach{
                                $message = 'Check file {0} for the tag {1}' -f $script:checksFile, $psitem
                                Write-PSFMessage -Message $message -Level Verbose
                                if (@($fileContent | Select-String -Pattern "^\s*Describe.*-Tag\s+.*($psitem)").Matches.Count) {
                                    $message = 'The file {0} has the tag {1}' -f $script:checksFile, $psitem
                                    Write-PSFMessage -Message $message -Level Verbose
                                    # file matches by one of the tags
                                    if (!($script:selectedFiles -contains $script:checksFile)) {
                                        $script:selectedFiles.Add($script:checksFile)
                                    }
                                } else {
                                    $message = 'The file {0} does not have the tag {1}' -f $script:checksFile, $psitem
                                    Write-PSFMessage -Message $message -Level Verbose
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
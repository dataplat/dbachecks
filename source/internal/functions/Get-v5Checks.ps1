function Get-v5Checks {
    $v5files = Get-ChildItem -Path $v5Path -Recurse -Filter *.ps1 -Exclude *-v5.ps1        
    [Management.Automation.Language.Parser]::ParseInput($GroupContent, [ref]$tokens, [ref]$errors).
        FindAll([Func[Management.Automation.Language.Ast, bool]] {
                param ($ast)
                $ast.CommandElements -and
                $ast.CommandElements[0].Value -eq 'describe'
            }, $true) |
            ForEach-Object {
                $CE = $PSItem.CommandElements
                $secondString = ($CE | Where-Object { $PSItem.StaticType.name -eq 'string' })[1]
                $tagIdx = $CE.IndexOf(($CE | Where-Object ParameterName -EQ 'Tags')) + 1
                $tags = if ($tagIdx -and $tagIdx -lt $CE.Count) {
                    $CE[$tagIdx].Extent
                }
                New-Object PSCustomObject -Property @{
                    GroupName  = $GroupName
                    CheckTitle = $secondString
                    CheckTags  = $tags
                }
            }
}
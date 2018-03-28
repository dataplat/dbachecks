param([string]$workspace, [string]$fullPath, [string]$file, [int]$line)

Import-Module $workspace -Force 

if ($file -like "*.Tests.ps1") {
    # if it is a pester file try to get the 'current' tag
    $code = [Management.Automation.Language.Parser]::ParseInput((Get-Content $fullPath -Raw), [ref]$null, [ref]$null)

    $firstTag = $null 

    $code.FindAll([Func[Management.Automation.Language.Ast, bool]] {
        param($ast) 
        $ast.Extent.StartLineNumber -le $line -and 
        $ast.Extent.EndLineNumber -ge $line -and
        $ast.CommandElements -and 
        $ast.CommandElements[0].Value -eq "describe"
    }, $true) | ForEach-Object {
        $ce = $psitem.CommandElements
        $tagsIndex = $ce.IndexOf(($ce | Where-Object ParameterName -eq "Tags")) + 1
        $tags = if ($tagsIndex -and $tagsIndex -lt $ce.Count) { $ce[$tagsIndex].Extent }

        if ($tags) {
            $firstTag = $tags.Text.Split(',')[0].Trim()
        }
    }

    # if first tag has been found execute the test only for that tag 
    if ($firstTag) {
        Invoke-DbcCheck -Script $fullPath -Tag $firstTag
    }
}

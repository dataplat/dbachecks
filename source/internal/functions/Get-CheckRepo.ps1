# Can't set arrays right now, w/e
function Get-CheckRepo {
    $repos = Get-DbcConfigValue app.checkrepos
    if ($repos -match ", ") {
        $repos = $repos.Replace(", ", ",")
        $repos = $repos.Split(",")
    }
    return $repos
}
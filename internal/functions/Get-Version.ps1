function Get-Version {
    Param($SqlInstance)
    (Connect-DbaInstance -SqlInstance $SqlInstance).Version.Major
}
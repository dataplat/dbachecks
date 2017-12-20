# dbachecks

Checkin pester stuff. This module will only be available for PS 5+ and in the Gallery. 
No GitHub support download install will be possible since it has dependencies.

## Prereqs

When you install from the Gallery, it'll auto-install:

* dbatools
* Pester
* PSFramework

When you import, it'll auto-import

* dbatools
* Pester
* PSFramework

## Getting started

```
# Set the servers you'll be working with
Set-DbcConfig -Name Setup.SqlInstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name Setup.ComputerName -Value sql2016, sql2017, sql2008

# Look at the current configs
Get-DbcConfig

# Invoke the tests written so far
Invoke-DbcCheck
```

![image](https://user-images.githubusercontent.com/8278033/34134078-bb26459e-e458-11e7-8e87-9289ab65ba8e.png)

### Notes

* Set-DbcConfig persists the values
* If you `Set-DbcConfig -Name Setup.sqlcredential -Value (Get-Credential sa)` it'll set the SqlCredential for the whole module! but nothing more. So cool.

Same can't be said for WinCredential right now, unfortunately - because we aliased Credential to SqlCredential. Sad face.

## Going more advanced

```
# You can also use $sqlinstance to change checks on the fly
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016

Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster

$sqlinstance = Get-DbaRegisteredServer -SqlInstance sql2017 -Group Express
Invoke-DbcCheck -Tag Backup -SqlInstance $sqlinstance

Invoke-DbcCheck -Tag Storage -ComputerName server1, server2

# You can also modify the params of the actual command that's being executed by
Set-Variable -Name PSDefaultParameterValues -Value @{ 'Get-DbaDiskSpace:ExcludeDrive' = 'C:\'  } -Scope Global
Invoke-DbcCheck -Tag Storage
```

## Getting pretty

```
# https://sqldbawithabeard.com/2017/10/29/a-pretty-powerbi-pester-results-template-file/
$results = Invoke-DbcCheck -Show Summary -PassThru
$results.TestResult | ConvertTo-Json -Depth 5 | Out-File "$env:windir\temp\dbachecks.json"
```

Or use these poorly named commands

```
# Run tests and export its json
New-DbcPowerBiJson

# Launch PowerBi then hit refresh
Show-DbcPowerBi
```

## Sending mail

So far, this is ugly as hell but I'm working on it. [PaperCut](https://github.com/ChangemakerStudios/Papercut/releases) dev smtp server is awesome.

```
$fromto = "get@papercut.ongithub.com"
$smtpserver = "localhost"
$result = Invoke-DbcCheck -Show Summary -PassThru
$resultHTML = $result.TestResult | ConvertTo-Html | Out-String
Send-MailMessage -From $fromto -Subject 'SQL Server Validation Report' -body $resultHTML -BodyAsHtml -To $fromto -SmtpServer $smtpserver
```

## Party

Nice work!

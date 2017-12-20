# dbachecks

dbachecks is a framework created by and for SQL Server pros who need to validate their enviornments. Basically, we all share similar checklists and just the server names change.

This open source module allows us to crowdsource our checklists using Pester tests. Such checks include:

* Backups are being performed
* Identity columns are not about to max out
* Servers have access to backup paths
* Database integrity checks are being performed and corruption does not exist
* Disk space is not about to run out

## Prereqs

PowerShell 5+ is required. Automatic installation will only be provided via the [PowerShell Gallery](https://wwww.powershellgallery.com).

When you install from the Gallery, it'll auto-install:

* dbatools
* Pester
* PSFramework

When you import, it'll auto-import

* dbatools
* Pester
* PSFramework

## Getting started

Checks are performed using `Invoke-DbcCheck` which is basically a wrapper for `Invoke-Pester`.

#### Making server lists

If you have a simplified (single) environment, you can set a permanent list of servers. "Servers" include both SQL Server instances and Windows servers.

Checks that access Windows Server (such as disk space checks) use `-ComputerName`. Pure SQL-based commands (such as backup checks) use `-SqlInstance`

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

Alternatively, you can create a list and pass it to  `Invoke-DbcCheck`

````
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016
Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster

$sqlinstance = Get-DbaRegisteredServer -SqlInstance sql2017 -Group Express
Invoke-DbcCheck -Tag Backup -SqlInstance $sqlinstance

Invoke-DbcCheck -Tag Storage -ComputerName server1, server2
````

## Going more advanced

* Set-DbcConfig persists the values. If you `Set-DbcConfig -Name Setup.sqlcredential -Value (Get-Credential sa)` it'll set the SqlCredential for the whole module! but nothing more. So cool.

Same can't be said for WinCredential right now, unfortunately - because we aliased Credential to SqlCredential. Sad face.

```
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

## How can I download?
No GitHub support download install will be possible since it has dependencies.

## Party

Nice work!

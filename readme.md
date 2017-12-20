# dbachecks

dbachecks is a framework created by and for SQL Server pros who need to validate their enviornments. Basically, we all share similar checklists and mostly just the server names and RPO/RTO/etc change.

This open source module allows us to crowdsource our checklists using [Pester](https://github.com/Pester/Pester) tests. Such checks include:

* Backups are being performed
* Identity columns are not about to max out
* Servers have access to backup paths
* Database integrity checks are being performed and corruption does not exist
* Disk space is not about to run out
* All enabled jobs have succeeded

Have questions about development? Please visit our [Wiki](https://github.com/potatoqualitee/dbachecks/wiki). **Anyone developing this module** should visit that Wiki page (after fully reading this readme) for a brief overview.

## Prereqs

PowerShell 5+ is required. Automatic installation will only be provided via the [PowerShell Gallery](https://www.powershellgallery.com).

When you install from the Gallery, it'll auto-install:

* dbatools
* Pester
* PSFramework

When you import, it'll auto-import

* dbatools
* Pester
* PSFramework

## Getting started

Checks are performed using `Invoke-DbcCheck` which is basically a wrapper for [Invoke-Pester](https://github.com/pester/Pester/wiki/Invoke-Pester). This means that supported `Invoke-Pester` parameters work against `Invoke-DbcCheck`.

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

#### What it looks like

![image](https://user-images.githubusercontent.com/8278033/34208143-93e4ae9a-e58d-11e7-90bb-448e2342ba39.png)

#### Other ways to execute checks against specific servers

Alternatively, you can provide a list of servers and to `Invoke-DbcCheck`

````
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016
Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster

$sqlinstance = Get-DbaRegisteredServer -SqlInstance sql2017 -Group Express
Invoke-DbcCheck -Tag Backup -SqlInstance $sqlinstance

Invoke-DbcCheck -Tag Storage -ComputerName server1, server2
````

## Tag and ExcludeTag

We tag each of our checks using singular descriptions such as Backup, Database or Storage. Each check can have multiple tags. In addition, each command name is automatically 
added to the tag so you can use that to either include (`-Tag`) or Exclude (`-ExcludeTag`) in your results. The Exclude will always take precendence.

For example, the Database tag runs a number of checks including backup checks. The command below will run all Database commands except for the backup checks.

```
Invoke-DbcCheck -Tag Database -ExcludeTag Backup -SqlInstance sql2016
```

All valid [Pester](https://github.com/Pester/Pester) syntax is valid for dbachecks so if you'd like to know more, check out their documentation.

## Reporting on the data

Since this is just PowerShell/Pester, results can be exported and easily converted to pretty reports. We've provided one way (via PowerBI) and are currently working on mail.

#### PowerBI Visualizations!

We've also included a precreated PowerBI report! To run, you must first export the json in the required location, then launch the pbix. Once the PowerBI report is open, just hit refresh.

```
# Run tests and export its json
Update-DbcPowerBiDataSource

# Launch PowerBi then hit refresh
Start-DbcPowerBi
```

Now, the New-DbcPowerBiJson 
#### Sending mail

So far, this is ugly as hell but I'm working on it. [PaperCut](https://github.com/ChangemakerStudios/Papercut/releases) dev smtp server is awesome.

```
$fromto = "get@papercut.ongithub.com"
$smtpserver = "localhost"
$result = Invoke-DbcCheck -Show Summary -PassThru
$resultHTML = $result.TestResult | ConvertTo-Html | Out-String
Send-MailMessage -From $fromto -Subject 'SQL Server Validation Report' -body $resultHTML -BodyAsHtml -To $fromto -SmtpServer $smtpserver
```

## Advanced usage

## Skipping some internal tests

The check `lastbackup` checks for diffs, but some environments don't backup diffs, just nightly fulls. If a diff check needs to be skipped, just:

```
Get-DbcConfig *skip*
Set-DbcConfig -Name skip.backupdiffcheck -Value $true
```

Need to skip a whole test? Just use the `-ExcludeTag` which is auto populated with both check names and Pester test tags

#### Setting a global SQL credential

Set-DbcConfig persists the values. If you `Set-DbcConfig -Name Setup.sqlcredential -Value (Get-Credential sa)` it'll set the SqlCredential for the whole module! but nothing more. So cool.

You can also manually change the SqlCredential or Credential by specifying it in `Invoke-DbaCheck` like:

```
Invoke-DbaCheck -SqlInstance sql2017 -SqlCredential (Get-Credential sqladmin) -Tag maxmemory
```

#### Manipulating the underlying commands 

You can also modify the params of the actual command that's being executed by

```
Set-Variable -Name PSDefaultParameterValues -Value @{ 'Get-DbaDiskSpace:ExcludeDrive' = 'C:\'  } -Scope Global
Invoke-DbcCheck -Tag Storage
```

## I don't have access to the PowerShell Gallery, how can I download this?

No GitHub support download install will be possible since it has dependencies. 

## Party

Nice work!

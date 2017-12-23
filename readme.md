# dbachecks

<img align="left" src="https://user-images.githubusercontent.com/8278033/34322840-ed09114e-e832-11e7-9670-9baa686ade71.png"> 

dbachecks is a framework created by and for SQL Server pros who need to validate their enviornments. Basically, we all share similar checklists and mostly just the server names and RPO/RTO/etc change.

This open source module allows us to crowdsource our checklists using [Pester](https://github.com/Pester/Pester) tests. Such checks include: <br>&nbsp;<br>

* Backups are being performed
* Identity columns are not about to max out
* Servers have access to backup paths
* Database integrity checks are being performed and corruption does not exist
* Disk space is not about to run out
* All enabled jobs have succeeded

Have questions about development? Please visit our [Wiki](https://github.com/potatoqualitee/dbachecks/wiki). **Anyone developing this module** should visit that Wiki page (after fully reading this readme) for a brief overview.

## Prereqs

PowerShell 4+ is required. Automatic installation will only be provided via the [PowerShell Gallery](https://www.powershellgallery.com).

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

Basically, you **Invoke-DbcCheck**, then specify a Check or, in Pester terms, "Tag". You can see a list of available list of checks using `Get-DbcCheck`. 

![image](https://user-images.githubusercontent.com/8278033/34315601-6a93672e-e782-11e7-9688-1d361d8597e1.png)

Once you've decided on the Check or Checks you want to run, it's time to ensure you've got a list of servers to run the checks against.

#### Making server lists

Like [dbatools](https://dbatools.io), dbachecks accepts `-SqlInstance` and `-ComputerName` parameters. 

`Invoke-DbcCheck -SqlInstance $servers -Tags SuspectPage, LastBackup`

If you have a simplified (single) environment, however, you can set a permanent list of servers. "Servers" include both SQL Server instances and Windows servers.Checks that access Windows Server (such as disk space checks) use `-ComputerName`. Pure SQL-based commands (such as backup checks) use `-SqlInstance`

```
# Set the servers you'll be working with
Set-DbcConfig -Name Setup.SqlInstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name Setup.ComputerName -Value sql2016, sql2017, sql2008

# Look at the current configs
Get-DbcConfig

# Invoke a few tests
Invoke-DbcCheck -Tags SuspectPage, LastBackup
```

#### What it looks like

![image](https://user-images.githubusercontent.com/8278033/34315954-431d0b16-e78a-11e7-8f6d-c87b40ed90b2.png)

#### Other ways to execute checks against specific servers

Here are additional `Invoke-DbcCheck` examples

````
Invoke-DbcCheck -Tag Backup -SqlInstance sql2016
Invoke-DbcCheck -Tag RecoveryModel -SqlInstance sql2017, sqlcluster

$sqlinstance = Get-DbaRegisteredServer -SqlInstance sql2017 -Group Express
Invoke-DbcCheck -Tag Backup -SqlInstance $sqlinstance

Invoke-DbcCheck -Tag Storage -ComputerName server1, server2
````

## Tag and ExcludeTag

We tag each of our checks using singular descriptions such as Backup, Database or Storage. You can see all tags using `Get-DbcTagCollection` or `Get-DbcCheck`. 


Each check generally has a few tags but at least one tag is unique. This allows us to essentially name a check and using these tags, you can either include (`-Tag`) or Exclude (`-ExcludeTag`) in your results. The Exclude will always take precendence.

For example, the Database tag runs a number of checks including backup checks. The command below will run all Database commands except for the backup checks.

```
Invoke-DbcCheck -Tag Database -ExcludeTag Backup -SqlInstance sql2016 -SqlCredential (Get-Credential sqladmin)
```

All valid [Pester](https://github.com/Pester/Pester) syntax is valid for dbachecks so if you'd like to know more, check out their documentation.

## Reporting on the data

Since this is just PowerShell/Pester, results can be exported and easily converted to pretty reports. We've provided one way (via PowerBI) and are currently working on mail.

#### PowerBI Visualizations!

We've also included a precreated PowerBI report! To run, you must first export the json in the required location, then launch the pbix. Once the PowerBI report is open, just hit refresh.

```
# Run checks and export its json
Invoke-DbcCheck -SqlInstance sql2017 -Tag identity -Show Summary -PassThru | Update-DbcPowerBiDataSource

# Launch PowerBi then hit refresh
Start-DbcPowerBi
```

Cool! 

#### Sending mail

Got a new command for this! [PaperCut](https://github.com/ChangemakerStudios/Papercut/releases) dev smtp server is awesome, btw.

```
Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -OutputFormat NUnitXml -PassThru | 
Send-DbcMailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SmtpServer smtp.ad.local
```

![image](https://user-images.githubusercontent.com/8278033/34316816-cc157d04-e79e-11e7-971d-1cfee90b2e11.png)

😍😍😍

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

## Can I run tests not in the module?

If you have super specialized checks to run, you can add a new repo, update the `app.checkrepos` config and this will make all of your tests available to `Invoke-DbcCheck`. From here, you can pipe to `Send-DbcMailMessage` or `Update-DbcPowerBiDataSource` or parse however you'd parse Pester results.

![image](https://user-images.githubusercontent.com/8278033/34320729-aeacb72a-e800-11e7-8278-a83de46afcc6.png)

So first, add your repo

```
Set-DbcConfig -Name app.checkrepos -Value C:\temp\checks -Append
```

Then add additional checks. We recommend using the [development guidelines for dbachecks](https://github.com/potatoqualitee/dbachecks/wiki).

![image](https://user-images.githubusercontent.com/8278033/34320819-07fe939c-e802-11e7-8203-a82740cc8f19.png)

## I don't have access to the PowerShell Gallery, how can I download this?

No GitHub support download install will be possible since it has dependencies. 

## Party

Nice work!

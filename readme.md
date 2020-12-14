# dbachecks

<img align="left" src="https://user-images.githubusercontent.com/8278033/34322840-ed09114e-e832-11e7-9670-9baa686ade71.png">

dbachecks is a framework created by and for SQL Server pros who need to validate their environments. Basically, we all share similar checklists and mostly just the server names and RPO/RTO/etc change.

This open source module allows us to crowd-source our checklists using [Pester](https://github.com/Pester/Pester) tests. Such checks include:

* Backups are being performed
* Identity columns are not about to max out
* Servers have access to backup paths
* Database integrity checks are being performed and corruption does not exist
* Disk space is not about to run out
* All enabled jobs have succeeded

## Interactive dbachecks PowerShell Notebooks for Azure Data Studio

You can find a set of interactive PowerShell Notebooks which will introduce you to all of the core concepts in Robs GitHub. There is a set of .NET interactive Jupyter Notebooks

https://github.com/SQLDBAWithABeard/JupyterNotebooks/tree/master/notebooks/dotNETNotebooks/dbachecks

and a set of Jupyter Notebooks that will run in Azure Data Studio

https://github.com/SQLDBAWithABeard/JupyterNotebooks/tree/master/notebooks/NotDotNet/dbachecks

Both will use a docker container to show you how dbachecks works.

There is a zip file containing the Notebooks here

https://github.com/SQLDBAWithABeard/Presentations/raw/master/Notebooks/dbachecks/Notebooks.zip

Have questions about development? Please visit our [Wiki](https://github.com/sqlcollaborative/dbachecks/wiki). **Anyone developing this module** should visit that Wiki page (after fully reading this readme) for a brief overview.

## Build Status
<table>
  <tbody>
    <tr>
      <td><a href="https://sqlcollaborative.visualstudio.com/dbachecks/_build/index?context=mine&path=%5C&definitionId=3&_a=completed" target="_blank"><img align="left" src="https://sqlcollaborative.visualstudio.com/_apis/public/build/definitions/a0deae7b-ae38-4ecc-a836-5f79cc561140/3/badge"></a></td>
      <td>Development Branch Build - Unit testing <a href="https://sqlcollaborative.visualstudio.com/dbachecks/_build/index?context=mine&path=%5C&definitionId=3&_a=completed" target="_blank">Click Here</a></td>
    </tr>
    <tr>
      <td><a href-"https://sqlcollaborative.visualstudio.com/dbachecks/_build/index?context=mine&path=%5C&definitionId=2&_a=completed"><img align="left" src="https://sqlcollaborative.visualstudio.com/_apis/public/build/definitions/a0deae7b-ae38-4ecc-a836-5f79cc561140/2/badge"></a></td>
      <td>Master Branch Build - Module version update and Code Signing <a href="https://sqlcollaborative.visualstudio.com/dbachecks/_build/index?context=mine&path=%5C&definitionId=2&_a=completed" target="_blank">Click Here</a></td>
    </tr>
        <tr>
      <td><a href = "https://sqlcollaborative.visualstudio.com/dbachecks/_releases2?definitionId=3&view=mine&_a=releases"><img align="left" src="https://sqlcollaborative.vsrm.visualstudio.com/_apis/public/Release/badge/a0deae7b-ae38-4ecc-a836-5f79cc561140/2/2"></a></td>
          <td>Master Branch Release - Release to PowerShell Gallery <a href="https://sqlcollaborative.visualstudio.com/dbachecks/_releases2?definitionId=3&view=mine&_a=releases" target="_blank">Click Here</a></td>
    </tr>
  </tbody>
</table>

Want to know how our CD process works? Read this [blog post](https://sqldbawithabeard.com/2018/05/01/version-update-code-signing-and-publishing-to-the-powershell-gallery-with-vsts/) and see how the team manage it

## Prerequisites
### Client requirements
* PowerShell 5 + is required.
* Automatic installation of the dependent modules will only be provided via the [PowerShell Gallery](https://www.powershellgallery.com).

When you install from the Gallery, it'll auto-install:

* dbatools
* PSFramework

You will also need to manually install the Pester module at version 4.10.0, this is due to inconsistencies between dbachecks and Pester v5.  If you have Pester v5 installed it is recommended to remove this and use Pester 4.10.0 or force an import of 4.10.0 when running dbachecks

````
Install-Module Pester -SkipPublisherCheck -Force -RequiredVersion 4.10.0
Import-Module Pester -Force -RequiredVersion 4.10.0
````

When you import, it'll auto-import

* dbatools
* Pester
* PSFramework

If you have already installed the module and you update it, you may be required to update the Pester or the PSFramework modules before it will import. If you see a message like

![error](https://user-images.githubusercontent.com/6729780/35032185-dfe988a2-fb5d-11e7-83e3-6a41a9c89b81.png)

Then you need to

````
Install-Module Pester -SkipPublisherCheck -Force -RequiredVersion 4.10.0
Import-Module Pester -Force -RequiredVersion 4.10.0
````

You may need to do the same thing for the PSFramework or dbatools modules also

### SQL requirements

dbachecks uses dbatools for most of it's data gathering so it supports SQL Versions from SQL 2000 to SQL vNext including SQL running on Linux. (dbachecks will not install on PowerShell Core yet so can not be run on a Linux client) Obviously some of the Services and disk space checks will not work against instances running on Linux as they are using gWindows API calls.

## Getting started

Checks are performed using `Invoke-DbcCheck` which is basically a wrapper for [Invoke-Pester](https://github.com/pester/Pester/wiki/Invoke-Pester). This means that supported `Invoke-Pester` parameters work against `Invoke-DbcCheck`.

In this module, a "Check" is synonymous with a "Tag" in Pester. So you can **Invoke-DbcCheck** and specify a Check that you want to run. You can see a list of the available Checks with **Get-DbcCheck**.

![image](https://user-images.githubusercontent.com/8278033/34329332-57f40a1c-e8fc-11e7-8526-178c415b09bf.png)

Once you've decided on the Check(s) you want to run, it's time to ensure you have a list of servers to run the checks against.

### Making server lists

Similar to the [dbatools](https://dbatools.io) module, dbachecks accepts `-SqlInstance` and `-ComputerName` parameters.

`Invoke-DbcCheck -SqlInstance $servers -Checks SuspectPage, LastBackup`

If you have a simplified (single) environment, however, you can set a permanent list of servers. "Servers" include both SQL Server instances and Windows servers. Checks that access Windows Server (e.g. disk space checks) will utilize `-ComputerName` parameter. A pure SQL Server command(s) (such as the backup check) utilizes the `-SqlInstance` parameter.

```powershell
# Set the servers you'll be working with
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008

# Look at the current configs
Get-DbcConfig

# Invoke a few tests
Invoke-DbcCheck -Checks SuspectPage, LastBackup
```
#### What it looks like

![image](https://user-images.githubusercontent.com/8278033/34315954-431d0b16-e78a-11e7-8f6d-c87b40ed90b2.png)

#### Other ways to execute checks against specific servers

Additional `Invoke-DbcCheck` examples:

```powershell
Invoke-DbcCheck -Check Backup -SqlInstance sql2016
Invoke-DbcCheck -Check RecoveryModel -SqlInstance sql2017, sqlcluster

$sqlinstance = Get-DbaRegisteredServer -SqlInstance sql2017 -Group Express
Invoke-DbcCheck -Check Backup -SqlInstance $sqlinstance

Invoke-DbcCheck -Check Storage -ComputerName server1, server2
```

## Check and ExcludeCheck

We tag each of our Checks using singular descriptions such as Backup, Database or Storage. You can see all the Pester related Tags using `Get-DbcTagCollection` or `Get-DbcCheck`.

Each Check generally has a few Tags but at least one Tag is unique. This allows us to essentially name a Check and using these Tags, you can either include (`-Check`) or Exclude (`-ExcludeCheck`) in your results. The Exclude will always take precedence.

For example, the Database Tag runs a number of Checks including Backup Checks. The command below will run all Database Checks except for the Backup Checks.

```powershell
Invoke-DbcCheck -Check Database -ExcludeCheck Backup -SqlInstance sql2016 -SqlCredential (Get-Credential sqladmin)
```

All valid [Pester](https://github.com/Pester/Pester) syntax is valid for dbachecks so if you'd like to know more, you can review their documentation.

## Reporting on the data

Since this is just PowerShell and Pester, results can be exported then easily converted to pretty reports. We've provided two options: Power BI and SMTP mail.

### Power BI Visualizations!

We've also included a pre-built Power BI Desktop report! You can download Power BI Desktop from [here](https://powerbi.microsoft.com/en-us/downloads/) or it is now offered via the [Microsoft Store on Windows 10](https://www.microsoft.com/store/productId/9NTXR16HNW1T).

Note: We strongly recommend that you keep your PowerBI Desktop updated since we can add brand-new stuff that appears on the most recent releases.

To use the Power BI report, pipe the results of `Invoke-DbcCheck` to `Update-DbcPowerBiDataSource` (defaults to `C:\Windows\temp\dbachecks`), then launch the included `dbachecks.pbix` file using `Start-DbcPowerBi`. Once the Power BI report is open, just hit **refresh**.

```powershell
# Run checks and export its JSON
Invoke-DbcCheck -SqlInstance sql2017 -Checks SuspectPage, LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource

# Launch Power BI then hit refresh
Start-DbcPowerBi
```

![image](https://user-images.githubusercontent.com/19521315/36527050-640d6c0a-17a8-11e8-9781-0aab0a8f8d48.png)

The above report uses `Update-DbcPowerBiDataSource`'s `-Environment` parameter.

```powershell
# Run checks and export its JSON
Invoke-DbcCheck -SqlInstance $prod -Checks LastBackup -Show Summary -PassThru |
Update-DbcPowerBiDataSource -Environment Prod
```

😍😍😍

### Sending mail

We even included a command to make emailing the results easier!

```powershell
$outputDirectory = (Get-DbcConfigValue -Name app.maildirectory)
$filename = $outputDirectory + '\file.xml'
Invoke-Dbccheck -OutputFile $fileName -OutputFormat NunitXML

$outputpath = $outputDirectory + "\index.html"
$reportunit = "ModulePath\bin\ReportUnit.exe"
& $reportunit $outputDirectory

$htmlbody = Get-Content -Path $outputpath -ErrorAction SilentlyContinue | Out-String

Send-MailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SMTP smtp.ad.local -BodyAsHtml $htmlbody
```

![image](https://user-images.githubusercontent.com/8278033/34316816-cc157d04-e79e-11e7-971d-1cfee90b2e11.png)

If you'd like to test locally, check out [PaperCut](https://github.com/ChangemakerStudios/Papercut/releases) which is just a quick email viewer that happens to have a built-in SMTP server. It provides awesome, built-in functionality so you can send the reports!

## Advanced usage

### Skipping some internal tests

The Check `LastGoodCheckDb` includes a test for data purity. You may be in an environment that can't support data purity. If this check needs to be skipped, you can do the following:

```powershell
Get-DbcConfig *skip*
Set-DbcConfig -Name skip.dbcc.datapuritycheck -Value $true
```

Need to skip a whole test? Just use the `-ExcludeCheck` which is auto-populated with both Check names and Pester Tags.

### Setting a global SQL Credential

`Set-DbcConfig` persists the values. If you `Set-DbcConfig -Name app.sqlcredential -Value (Get-Credential sa)` it will set the `SqlCredential` for the whole module, but not your local console! So cool.

You can also manually change the `SqlCredential` or `Credential` by specifying it in `Invoke-DbaCheck`:

```powershell
Invoke-DbaCheck -SqlInstance sql2017 -SqlCredential (Get-Credential sqladmin) -Check MaxMemory
```

### Manipulating the underlying commands

You can also modify the parameters of the actual command that's being executed:

```powershell
Set-Variable -Name PSDefaultParameterValues -Value @{ 'Get-DbaDiskSpace:ExcludeDrive' = 'C:\' } -Scope Global
Invoke-DbcCheck -Check Storage
```

## Can I run tests not included the module?

If you have super specialized checks to run, you can add a new repository, update the `app.checkrepos` config and this will make all of your tests available to `Invoke-DbcCheck`. From here, you can pipe to `Send-DbcMailMessage`, `Update-DbcPowerBiDataSource` or parse however you would parse Pester results.

![image](https://user-images.githubusercontent.com/8278033/34320729-aeacb72a-e800-11e7-8278-a83de46afcc6.png)

So first, add your repository

```powershell
Set-DbcConfig -Name app.checkrepos -Value C:\temp\checks -Append
```

Then add additional checks. We recommend using the [development guidelines for dbachecks](https://github.com/potatoqualitee/dbachecks/wiki).

![image](https://user-images.githubusercontent.com/8278033/34320819-07fe939c-e802-11e7-8203-a82740cc8f19.png)

## I'd like to run my checks in SQL Server Agent

Great idea! Remember that this module requires PowerShell version 4.0, which doesn't always mesh with SQL Server's PowerShell Job Step. To run dbachecks, **we recommend you use CmdExec**. You can read more at [dbatools.io/agent](https://dbatools.io/agent).

If you do choose to use the PowerShell step, don't forget to `Set-Location` somewhere outside of SQLSERVER:, otherwise, you'll get errors similar to this

![image](https://user-images.githubusercontent.com/8771143/35379174-878505fc-01b5-11e8-8731-41be4daff815.png)

## I don't have access to the PowerShell Gallery, how can I download this?

This module has a number of dependencies which makes creating a GitHub-centric installer a bit of a pain. We suggest you use a machine with [PowerShellGet](https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget) installed and Save all the modules you need:

```powershell
Save-Module -Name dbachecks, dbatools, PSFramework, Pester -Path C:\temp
```

Then move them to somewhere in your `$env:PSModulePath`, perhaps **Documents\WindowsPowerShell\Modules** or **C:\Program Files\WindowsPowerShell\Modules**.

## Read more

Read more about dbachecks from a number of our original contributors!

* [Announcing dbachecks – Configurable PowerShell Validation For Your SQL Instances by Rob Sewell](https://sqldbawithabeard.com/2018/02/22/announcing-dbachecks-configurable-powershell-validation-for-your-sql-instances/)
* [introducing dbachecks - a new module from the dbatools team! by Chrissy LeMaire](https://dbachecks.io/introducing)
* [install dbachecks by Chrissy LeMaire](https://dbachecks.io/install)
* [dbachecks commands by Chrissy LeMaire](https://dbachecks.io/commands)
* [dbachecks – Using Power BI dashboards to analyse results by Cláudio Silva](http://claudioessilva.eu/2018/02/22/dbachecks-using-power-bi-dashboards-to-analyse-results/)
* [My wrapper for dbachecks by Tony Wilhelm](https://v-roddba.blogspot.com/2018/02/wrapper-for-dbachecks.html)
* [Checking backups with dbachecks by Jess Pomfret](http://jesspomfret.com/checking-backups-with-dbachecks/)
* [dbachecks please! by Garry Bargsley](https://garrybargsley.com/2018/02/22/dbachecks-please/)
* [dbachecks – Configuration Deep Dive by Rob Sewell](https://sqldbawithabeard.com/2018/02/22/dbachecks-configuration-deep-dive/)
* [Test Log Shipping with dbachecks by Sander Stad](https://www.sqlstad.nl/powershell/test-log-shipping-with-dbachecks/)
* [Checking your backup strategy with dbachecks by Joshua Corrick](https://corrick.io/blog/checking-your-backup-strategy-with-dbachecks)
* [Enterprise-level reporting with dbachecks by Jason Squires](http://www.sqlnotnull.com/2018/02/22/enterprise-level-reporting-with-dbachecks-from-the-makers-of-dbatools/)
* [Adding your own checks to dbachecks by Shane O'Neill](http://nocolumnname.blog/2018/02/22/adding-your-own-checks-to-dbachecks)
* [dbachecks - A different approach for an in-progress and incremental validation by Cláudio Silva](https://claudioessilva.eu/2018/02/22/dbachecks-a-different-approach-for-an-in-progress-and-incremental-validation/)
* [dbachecks - Improved Descriptions by Rob Sewell](https://sqldbawithabeard.com/2018/05/19/dbachecks-improved-descriptions/)
* [DBACHECKS – SQL SERVER COMPLIANCE TESTING WITH SIMPLE CONFIGURATION MANAGEMENT by Stuart Moore](https://stuart-moore.com/dbachecks-sql-server-compliance-testing-simple-configuration-management/)
* [dbachecks – Which Configuration Item For Which Check ? by Rob Sewell](https://sqldbawithabeard.com/2018/05/15/dbachecks-which-configuration-item-for-which-check/)
*[https://sqldbawithabeard.com/2018/04/08/checking-availability-groups-with-dbachecks/ by Rob Sewell](https://sqldbawithabeard.com/2018/04/08/checking-availability-groups-with-dbachecks/)

Know of any more blog posts about dbachecks? - Please add them here.

## Party

Nice work!

# How to Contribute

We welcome contributions to the project. You can fork the repository, make changes and create a Pull Request. [Rob has written a guide here](https://sqldbawithabeard.com/?p=11030)

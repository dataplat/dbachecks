# dbatools-scripts
Holds a number of scripts for use with dbatools mainly from the blog posts at [https://sqldbawithabeard.com/tag/dbatools](https://sqldbawithabeard.com/tag/dbatools )

# Pester Tests

 At present there are the following tests

- Pester Test Backup Share - Server level.Tests.ps1
- Pester Test Database Collation - Database Level.Tests.ps1
- Pester Test Database Collation - Databases detailed.Tests.ps1
- Pester Test Database collation - Server level.Tests.ps1
- Pester Test Identity Usage  - Column Level.Tests.ps1
- Pester Test Identity Usage  - Database Level.Tests.ps1
- Pester Test Identity Usage  - Server Level.Tests.ps1
- Pester Test Last Backup - Individual.Tests.ps1
- Pester Test Last Known good DBCC CheckDB - Database Level.Tests.ps1
- Pester Test Last Known good DBCC CheckDB - Server Level and - Time.Tests.ps1
- Pester Test Last Known good DBCC CheckDB - Server Level.Tests.ps1
- Pester Test Network Latency.Tests.ps1
- Pester Test SPNs.Tests.ps1
- Pester test TempDb.Tests.ps1

All require dbatools and PowerShell version 4 or above. You can get dbatools from [https:\\dbatools.io](https://dbatools.io)

The pester tests are controlled by the TestConfig.Json file.

Alter the values or settigns to fit what you need to test. Setting the Skip value to true will skip the entire test

Then change directory to the folder holding the files and run

```PowerShell
$Config = (Get-Content TestConfig.JSON) -join "`n" | ConvertFrom-Json
```

Then all you need to do is run

```
Invoke-Pester
```

These scripts use gather Server names from a Hyper-V host so if you wish to use that then set the HyperV to your Hyper-V Hostname and NameSearch to perform a wildcard search on your VM Names

```json
            "HyperV": "beardnuc",
            "NameSearch":"SQL2016N3",
```

If you wish to use a different method to gather your SQL instances then you will need to open the folder in VS Code and use the search and replace to replace the below code

```PowerShell
# $SQLServers = (Get-VM -ComputerName $Config.Network.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*$($Config.Network.NameSearch)*" -and $_.State -eq 'Running'}).Name
```

with the method you choose. You can use the TestConfig.Json to filter in the same way if you wish

You can also output to HTML using reportunit.exe in the Pester Test To XML and HTML file
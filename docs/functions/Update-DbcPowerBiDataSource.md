# Update-DbcPowerBiDataSource

## SYNOPSIS
Converts Pester results and exports file in required format for launching the
Power BI command.
**You will need refresh* the Power BI dashboard every time to
see the new results.

## SYNTAX

```
Update-DbcPowerBiDataSource [-InputObject] <PSObject> [[-Path] <String>] [[-FileName] <String>]
 [[-Environment] <String>] [-Force] [-EnableException] [-Append] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Converts Pester results and exports file in required format for launching the
Power BI command.
**You will need refresh* the Power BI dashboard every time to
see the new results.

Basically, it does this:
$InputObject.TestResult | Select-Object -First 20 | ConvertTo-Json -Depth 3 | Out-File "$env:windir\temp\dbachecks.json"

## EXAMPLES

### EXAMPLE 1
```
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource
```

Runs the DatabaseStatus checks against $Instance then saves to json to $env:windir\temp\dbachecks\dbachecks_1_DatabaseStatus.json

### EXAMPLE 2
```
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp
```

Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\dbachecks_1_DatabaseStatus.json

### EXAMPLE 3
```
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -FileName BeardyTests
```

Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\BeardyTests.json

### EXAMPLE 4
```
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -FileName BeardyTests.json
```

Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\BeardyTests.json

### EXAMPLE 5
```
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -Environment Prod_DBChecks
```

Runs the DatabaseStatus checks against $Instance then saves to json to  C:\Temp\dbachecks_1_Prod_DBChecks_DatabaseStatus.json

### EXAMPLE 6
```
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Environment Prod_DBChecks
```

Runs the DatabaseStatus checks against $Instance then saves to json to  C:\Windows\temp\dbachecks\dbachecks_1_Prod_DBChecks_DatabaseStatus.json

### EXAMPLE 7
```
Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Path \\nas\projects\dbachecks.json
Start-DbcPowerBi -Path \\nas\projects\dbachecks.json
```

Runs tests, saves to json to \\\\nas\projects\dbachecks.json
Opens the PowerBi using that file
then you'll have to change your data source in Power BI because by default it
points to C:\Windows\Temp (limitation of Power BI)

### EXAMPLE 8
```
Set-DbcConfig -Name app.checkrepos -Value \\SharedPath\CustomPesterChecks
Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus, CustomCheckTag -PassThru | Update-DbcPowerBiDataSource -Path \\SharedPath\CheckResults -Name CustomCheckResults -Append
```

Because we are using a custom check repository you MUSTR use the Append parameter for Update-DbcPowerBiDataSource
otherwise the json file will be overwritten

Sets the custom check repository to \\\\SharedPath\CustomPesterChecks
Runs the DatabaseStatus checks and custom checks with the CustomCheckTag against $Instance then saves all the results
to json to \\\\SharedPath\CheckResults.json -Name CustomCheckResults

### EXAMPLE 9
```
Invoke-DbcCheck -SqlInstance sql2017 -Check SuspectPage -Show None -PassThru | Update-DbcPowerBiDataSource -Environment Test -Whatif
```

What if: Performing the operation "Removing .json files named *Default*" on target "C:\Windows\temp\dbachecks".
What if: Performing the operation "Passing results" on target "C:\Windows\temp\dbachecks\dbachecks_1_Test__SuspectPage.json".

Will not actually create or update the data sources but will output what happens with the command and what the file name will be
called.

## PARAMETERS

### -InputObject
Required.
Resultset from Invoke-DbcCheck.
If InputObject is not provided, it will be generated using a very generic resultset:

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
The directory to store your JSON files.
"C:\windows\temp\dbachecks\*.json" by default

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "$env:windir\temp\dbachecks"
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName
if you want to give the file a specific name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Environment
A Name to give your suite of tests IE Prod - This will also alter the name of the file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Delete all json files in the data source folder.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Append
Appends results to existing file.
Use this if you have custom check repos

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Update-DbcPowerBiDataSource/](https://dbachecks.readthedocs.io/en/latest/functions/Update-DbcPowerBiDataSource/)


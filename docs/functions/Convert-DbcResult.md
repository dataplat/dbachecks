# Convert-DbcResult

## SYNOPSIS
Takes the results of Invoke-DbcCheck, parses it and converts it to a datatable object

## SYNTAX

```
Convert-DbcResult [-TestResults] <PSObject> [[-Label] <String>] [<CommonParameters>]
```

## DESCRIPTION
You need to run Invoke-DbcCheck with the PassThru parameter and this command will take the
results and parse them creating a datatable object with column headings
Date Label Describe Context Name Database ComputerName Instance Result FailureMessage
so that it can be written to a database with Write-DbcTable (or Write-DbaDataTable) or to
a file with Set-DbcFile

## EXAMPLES

### EXAMPLE 1
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check

### EXAMPLE 2
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Write-DbcTable -SqlInstance sql2017n5 -Database tempdb -Table newdbachecks
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and writes it to a table newdbachecks in tempdb on SQL2017N5 (NB Don't use tempdb!!)

### EXAMPLE 3
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json

## PARAMETERS

### -TestResults
The output of Invoke-DbcCheck (WITH -PassThru)

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

### -Label
An optional label to add to the set of results to identify them - Think Morning-Checks or New-instance

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Data.DataTable
## NOTES
Initial - RMS 28/12/2019

## RELATED LINKS

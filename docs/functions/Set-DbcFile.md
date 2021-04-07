# Set-DbcFile

## SYNOPSIS
Writes the result of Invoke-DbcCheck to a file (after converting with Convert-DbcResult)

## SYNTAX

### Default (Default)
```
Set-DbcFile -InputObject <Object> -FilePath <String> -FileName <String> -FileType <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Force
```
Set-DbcFile -InputObject <Object> -FilePath <String> -FileName <String> -FileType <String> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Append
```
Set-DbcFile -InputObject <Object> -FilePath <String> -FileName <String> -FileType <String> [-Append] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
When a check has been run with Invoke-DbcCheck (and -PassThru) and then converted with
Convert-DbcResult This command will write the results to a CSV, JSON or XML file

## EXAMPLES

### EXAMPLE 1
```
$Date = Get-Date -Format "yyyy-MM-dd"
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close_$Date -FileType xml
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to xml and saves in C:\temp\dbachecks\Auto-close_DATE.xml

### EXAMPLE 2
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.xml -FileType xml
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to xml and saves in C:\temp\dbachecks\Auto-close.xml

### EXAMPLE 3
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.csv -FileType csv
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to csv and saves in C:\temp\dbachecks\Auto-close.csv

### EXAMPLE 4
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json

### EXAMPLE 5
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json -Append
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json appending the results to the existing file

### EXAMPLE 6
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json -Force
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json overwriting the existing file

## PARAMETERS

### -InputObject
The datatable created by Convert-DbcResult

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilePath
The directory for the file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName
The name of the file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileType
The type of file -CSV,JSON,XML

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Append
Add to an existing file or not

```yaml
Type: SwitchParameter
Parameter Sets: Append
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrite Existing file

```yaml
Type: SwitchParameter
Parameter Sets: Force
Aliases:

Required: True
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

### System.String
## NOTES
Initial - RMS 28/12/2019

## RELATED LINKS

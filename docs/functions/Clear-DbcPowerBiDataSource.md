# Clear-DbcPowerBiDataSource

## SYNOPSIS
Clears the data source directory created by Update-DbcPowerBiDataSource

## SYNTAX

```
Clear-DbcPowerBiDataSource [[-Path] <String>] [[-Environment] <String>] [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
Clears the data source directory created by Update-DbcPowerBiDataSource ("C:\windows\temp\dbachecks\*.json" by default).
This command makes it easier to clean up data used by PowerBI via Start-DbcPowerBi.

## EXAMPLES

### EXAMPLE 1
```
Clear-DbcPowerBiDataSource
```

Removes "$env:windir\temp\dbachecks\*.json"

### EXAMPLE 2
```
Clear-DbcPowerBiDataSource -Environment Production
```

Removes "$env:windir\temp\dbachecks\*Production*.json"

## PARAMETERS

### -Path
The directory to your JSON files, which will be removed.
"C:\windows\temp\dbachecks\*.json" by default

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$env:windir\temp\dbachecks"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Environment
Removes the JSON files for a specific environment

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Clear-DbcPowerBiDataSource/](https://dbachecks.readthedocs.io/en/latest/functions/Clear-DbcPowerBiDataSource/)

